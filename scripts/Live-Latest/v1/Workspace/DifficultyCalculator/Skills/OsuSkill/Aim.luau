--!strict
local Workspace = game:GetService("Workspace")

local DifficultyHitObjects = require(Workspace.DifficultyCalculator.DifficultyHitObjects)
local ModData = require(Workspace.ModData)
local VariableLengthStrainSkill = require(Workspace.DifficultyCalculator.Skills.BaseSkill.VariableLengthStrainSkill)
local SnapAimEvaluator = require(Workspace.DifficultyCalculator.DifficultyEvaluator.Aim.SnapAimEvaluator)
local AgilityEvaluator = require(Workspace.DifficultyCalculator.DifficultyEvaluator.Aim.AgilityEvaluator)
local FlowAimEvaluator = require(Workspace.DifficultyCalculator.DifficultyEvaluator.Aim.FlowAimEvaluator)
local DifficultyCalculationUtils = require(Workspace.DifficultyCalculator.DifficultyEvaluator.DifficultyCalculationUtils)

type BaseVLSS = VariableLengthStrainSkill.VariableLengthStrainSkill
type StrainPeak = VariableLengthStrainSkill.StrainPeak

local Aim = {}

export type Aim = BaseVLSS & {
    IncludeSliders: boolean,
    CurrentStrain: number,
    sliderStrains: {number},
    strainDecay: (self: Aim, ms: number) -> number,
    GetDifficultSliders: (self: Aim) -> number,
    CountTopWeightedSliders: (self: Aim, difficultyValue: number) -> number,
}

-- Constants
local SKILL_MULTIPLIER_SNAP = 70.9
local SKILL_MULTIPLIER_AGILITY = 2.35
local SKILL_MULTIPLIER_FLOW = 242.0
local SKILL_MULTIPLIER_TOTAL = 1.12
local COMBINED_SNAP_NORM_EXPONENT = 1.2
local REDUCED_SECTION_TIME = 4000
local REDUCED_STRAIN_BASELINE = 0.727
local CHUNK_SIZE = 20
local K = 7.27

local function overrideSelf(self)
    for k, v in pairs(Aim) do
        self[k] = v
    end
    return self
end

function Aim.new(mods: ModData.ModData, includeSliders: boolean): Aim
    local self = VariableLengthStrainSkill.new(mods) :: Aim

    overrideSelf(self)
    self.IncludeSliders = includeSliders
    self.CurrentStrain = 0
    self.sliderStrains = {} :: {number}

    return self
end

function Aim:strainDecay(ms: number): number
    return math.pow(0.2, ms / 1000)
end

function Aim:CalculateInitialStrain(t: number, current: DifficultyHitObjects.ObjectData): number
    local previous = current.Previous(1)
    if not previous then
        return self.CurrentStrain
    end
    return self.CurrentStrain * self:strainDecay(t - previous.Time)
end

local function calculateSnapFlowProbability(ratio: number): number
    if ratio == 0 then
        return 0
    end
    if math.isnan(ratio) then -- NaN check
        return 1
    end

    return DifficultyCalculationUtils.Logistic(-K * math.log(ratio))
end

function Aim:StrainValueAt(current: DifficultyHitObjects.ObjectData): number
    local decay = self:strainDecay(current.AdjustedDeltaTime)

    local snapDifficulty = SnapAimEvaluator.GetSnapAimDiff(current, self.IncludeSliders) * SKILL_MULTIPLIER_SNAP
    local agilityDifficulty = AgilityEvaluator.GetAimAgilityDiff(current) * SKILL_MULTIPLIER_AGILITY
    local flowDifficulty = FlowAimEvaluator.GetFlowAimDiff(current, self.IncludeSliders) * SKILL_MULTIPLIER_FLOW

    local totalDifficulty = self:calculateTotalValue(snapDifficulty, agilityDifficulty, flowDifficulty)

    local currentStrain = self.CurrentStrain :: number
    currentStrain *= decay
    currentStrain += (totalDifficulty :: number) * (1 - decay)
    self.CurrentStrain = currentStrain

    if current.isSlider then
        self.sliderStrains[#self.sliderStrains + 1] = currentStrain
    end

    return currentStrain
end

function Aim:calculateTotalValue(snapDifficulty: number, agilityDifficulty: number, flowDifficulty: number): number
    local combinedSnapDifficulty = DifficultyCalculationUtils.Normalise(COMBINED_SNAP_NORM_EXPONENT, snapDifficulty, agilityDifficulty)

    local pSnap = calculateSnapFlowProbability(
        combinedSnapDifficulty > 0 and (flowDifficulty / combinedSnapDifficulty) or 0
    )
    local pFlow = 1 - pSnap

    if self.Mods.TD then
        snapDifficulty = math.pow(snapDifficulty, 0.89)
        combinedSnapDifficulty = DifficultyCalculationUtils.Normalise(COMBINED_SNAP_NORM_EXPONENT, snapDifficulty, agilityDifficulty)
    end

    if self.Mods.RX then
        combinedSnapDifficulty *= 0.75
        flowDifficulty *= 0.6
    end

    local totalDifficulty = combinedSnapDifficulty * pSnap + flowDifficulty * pFlow
    return totalDifficulty * SKILL_MULTIPLIER_TOTAL
end

function Aim:GetDifficultSliders(): number
    local sliderStrains = self.sliderStrains
    if #sliderStrains == 0 then
        return 0
    end

    local maxSliderStrain = 0
    for i = 1, #sliderStrains do
        if sliderStrains[i] > maxSliderStrain then
            maxSliderStrain = sliderStrains[i]
        end
    end

    if maxSliderStrain == 0 then
        return 0
    end

    local total = 0
    for i = 1, #sliderStrains do
        total += 1.0 / (1.0 + math.exp(-(sliderStrains[i] / maxSliderStrain * 12.0 - 6.0)))
    end

    return total
end

function Aim:CountTopWeightedSliders(difficultyValue: number): number
    local sliderStrains = self.sliderStrains
    if #sliderStrains == 0 then
        return 0
    end

    local consistentTopStrain = difficultyValue * (1 - self.DecayWeight)
    if consistentTopStrain == 0 then
        return 0
    end

    local count = 0
    for i = 1, #sliderStrains do
        local s = sliderStrains[i] :: number
        count += 1.1 / (1 + math.exp(-10 * (s / consistentTopStrain - 0.88)))
    end

    return count
end

function Aim:DifficultyValue(): number
    local difficulty = 0
    local time = 0

    local strains = self:getReducedStrainPeaks()

    for i = 1, #strains do
        local strain = strains[i] :: StrainPeak
        local startTime = time
        local endTime = time + strain.SectionLength / (self.MaxSectionLength :: number)

        local weight = math.pow(self.DecayWeight :: number, startTime) - math.pow(self.DecayWeight :: number, endTime)

        difficulty += strain.Value * weight
        time = endTime
    end

    return difficulty / (1 - self.DecayWeight)
end

function Aim:getReducedStrainPeaks(): {StrainPeak}
    local peaks = self:GetCurrentStrainPeaks()

    -- Filter out zero-strain peaks
    local strains: {StrainPeak} = {}
    for i = 1, #peaks do
        if peaks[i].Value > 0 then
            strains[#strains + 1] = peaks[i]
        end
    end

    -- Sort descending by value
    table.sort(strains, function(a, b)
        return a.Value > b.Value
    end)

    local time = 0
    local strainsToRemove = 0

    -- Reduce highest strains in chunks to mitigate spikes
    while strainsToRemove < #strains and time < REDUCED_SECTION_TIME do
        local strain = strains[strainsToRemove + 1]

        for addedTime = 0, strain.SectionLength, CHUNK_SIZE do
            local scale = math.log10(math.lerp(1, 10, math.clamp((time + addedTime) / REDUCED_SECTION_TIME, 0, 1)))

            strains[#strains + 1] = {
                Value = strain.Value * math.lerp(REDUCED_STRAIN_BASELINE, 1.0, scale),
                SectionLength = math.min(CHUNK_SIZE, strain.SectionLength - addedTime),
            }
        end

        time += strain.SectionLength
        strainsToRemove += 1
    end

    -- Remove from index 1 <strainsToRemove> times
    for i = 1, strainsToRemove do
        table.remove(strains, 1)
    end

    -- Re-sort the combined list
    table.sort(strains, function(a, b)
        return a.Value > b.Value
    end)

    return strains
end

return Aim

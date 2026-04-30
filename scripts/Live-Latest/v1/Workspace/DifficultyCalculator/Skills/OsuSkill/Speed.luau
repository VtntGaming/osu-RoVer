--!strict
local Workspace = game:GetService("Workspace")

local DifficultyHitObjects = require(Workspace.DifficultyCalculator.DifficultyHitObjects)
local ModData = require(Workspace.ModData)
local HarmonicSkill = require(Workspace.DifficultyCalculator.Skills.BaseSkill.HarmonicSkill)
local SpeedEvaluator = require(Workspace.DifficultyCalculator.DifficultyEvaluator.Speed.SpeedEvaluator)
local RhythmCalculator = require(Workspace.DifficultyCalculator.DifficultyEvaluator.Speed.RhythmCalculator)
local SkillUtils = require(Workspace.DifficultyCalculator.Skills.SkillUtils)

local Speed = {}

type BaseHarmonicSkill = HarmonicSkill.HarmonicSkill

export type Speed = BaseHarmonicSkill & {
    SkillMultiplier: number,
    StrainDecayBase: number,
    CurrentStrain: number,
    sliderStrains: {number},
    strainDecay: (self: Speed, ms: number) -> number,
    RelevantNoteCount: (self: Speed) -> number,
    CountTopWeightedSliders: (self: Speed, difficultyValue: number) -> number,
}

function Speed.new(mods: ModData.ModData): Speed
    local self = HarmonicSkill.new(mods) :: Speed

    SkillUtils.OverrideSelf(self, Speed)
    self.SkillMultiplier = 1.16
    self.StrainDecayBase = 0.3
    self.CurrentStrain = 0
    self.HarmonicScale = 20
    self.DecayExponent = 0.9
    self.sliderStrains = {} :: {number}

    return self
end

function Speed:strainDecay(ms: number): number
    return math.pow(self.StrainDecayBase, ms / 1000)
end

function Speed:ObjectDifficultyOf(current: DifficultyHitObjects.ObjectData): number
    local decay = self:strainDecay(current.AdjustedDeltaTime)

    local currentStrain = self.CurrentStrain :: number
    currentStrain *= decay
    currentStrain += SpeedEvaluator.GetSpeedDiff(current) * (1 - decay) * (self.SkillMultiplier :: number)
    self.CurrentStrain = currentStrain

    local currentRhythm = RhythmCalculator.GetRhythmDiff(current)
    local totalStrain = currentStrain * currentRhythm

    if current.isSlider then
        self.sliderStrains[#self.sliderStrains + 1] = totalStrain
    end

    return totalStrain
end

function Speed:RelevantNoteCount(): number
    local difficulties = self.ObjectDifficulties
    if #difficulties == 0 then
        return 0
    end

    local maxStrain = 0
    for i = 1, #difficulties do
        if difficulties[i] > maxStrain then
            maxStrain = difficulties[i]
        end
    end

    if maxStrain == 0 then
        return 0
    end

    local count = 0
    for i = 1, #difficulties do
        count += 1.0 / (1.0 + math.exp(-(difficulties[i] / maxStrain * 12.0 - 6.0)))
    end

    return count
end

function Speed:CountTopWeightedSliders(difficultyValue: number): number
    local sliderStrains = self.sliderStrains
    if #sliderStrains == 0 then
        return 0
    end

    if self.NoteWeightSum == 0 then
        return 0
    end

    local consistentTopNote = difficultyValue / self.NoteWeightSum
    if consistentTopNote == 0 then
        return 0
    end

    local count = 0
    for i = 1, #sliderStrains do
        local s = sliderStrains[i] :: number
        count += 1.1 / (1 + math.exp(-10 * (s / consistentTopNote - 0.88)))
    end

    return count
end

return Speed

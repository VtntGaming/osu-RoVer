--!strict
local Workspace = game:GetService("Workspace")

local DifficultyHitObjects = require(Workspace.DifficultyCalculator.DifficultyHitObjects)
local ModData = require(Workspace.ModData)
local Skill = require(Workspace.DifficultyCalculator.Skills.BaseSkill.Skill)
local SkillUtils = require(Workspace.DifficultyCalculator.Skills.SkillUtils)

local StrainSkill = {}

type BaseSkill = Skill.Skill

export type StrainSkill = BaseSkill & {
    DecayWeight: number,
    SectionLength: number,
    currentSectionPeak: number,
    currentSectionEnd: number,
    strainPeaks: {number},
    saveCurrentPeak: (self: StrainSkill) -> (),
    startNewSectionFrom: (self: StrainSkill, time: number, current: DifficultyHitObjects.ObjectData) -> (),
    StrainValueAt: (self: StrainSkill, current: DifficultyHitObjects.ObjectData) -> number,
    CalculateInitialStrain: (self: StrainSkill, time: number, current: DifficultyHitObjects.ObjectData) -> number,
    GetCurrentStrainPeaks: (self: StrainSkill) -> {number},
    CountTopWeightedStrains: (self: StrainSkill, difficultyValue: number) -> number,
}

local math_max = math.max
local math_ceil = math.ceil

function StrainSkill.new(mods: ModData.ModData): StrainSkill
    local self = Skill.new(mods) :: StrainSkill

    SkillUtils.OverrideSelf(self, StrainSkill)
    self.DecayWeight = 0.9
    self.SectionLength = 400

    self.currentSectionPeak = 0
    self.currentSectionEnd = 0
    self.strainPeaks = {} :: {number}

    return self
end

function StrainSkill:saveCurrentPeak()
    self.strainPeaks[#self.strainPeaks + 1] = self.currentSectionPeak
end

function StrainSkill:startNewSectionFrom(time: number, current: DifficultyHitObjects.ObjectData)
    self.currentSectionPeak = self:CalculateInitialStrain(time, current)
end

function StrainSkill:StrainValueAt(_current: DifficultyHitObjects.ObjectData): number
    error("StrainValueAt must be implemented by derived skill")
end

function StrainSkill:CalculateInitialStrain(_time: number, _current: DifficultyHitObjects.ObjectData): number
    error("CalculateInitialStrain must be implemented by derived skill")
end

function StrainSkill:ProcessInternal(current: DifficultyHitObjects.ObjectData): number
    if current.objID <= 1 then
        self.currentSectionEnd = math_ceil(current.Time / self.SectionLength) * self.SectionLength
    end

    while current.Time > self.currentSectionEnd do
        self:saveCurrentPeak()
        self:startNewSectionFrom(self.currentSectionEnd, current)
        self.currentSectionEnd += self.SectionLength
    end

    local strain = self:StrainValueAt(current)
    self.currentSectionPeak = math_max(strain, self.currentSectionPeak)

    return strain
end

function StrainSkill:GetCurrentStrainPeaks(): {number}
    local peaks = table.clone(self.strainPeaks)
    peaks[#peaks + 1] = self.currentSectionPeak

    return peaks
end

function StrainSkill:DifficultyValue(): number
    local peaks = self:GetCurrentStrainPeaks()
    local filteredPeaks = {}

    for i = 1, #peaks do
        if peaks[i] > 0 then
            filteredPeaks[#filteredPeaks + 1] = peaks[i]
        end
    end

    table.sort(filteredPeaks, function(a, b)
        return a > b
    end)

    local difficulty = 0
    local weight = 1

    for i = 1, #filteredPeaks do
        difficulty += filteredPeaks[i] * weight
        weight *= self.DecayWeight
    end

    return difficulty
end

function StrainSkill:CountTopWeightedStrains(difficultyValue: number): number
    if #self.ObjectDifficulties == 0 then
        return 0
    end

    local consistentTopStrain = difficultyValue * (1 - self.DecayWeight)
    if consistentTopStrain == 0 then
        return #self.ObjectDifficulties
    end

    local strainCount = 0
    for i = 1, #self.ObjectDifficulties do
        local strain: number = self.ObjectDifficulties[i]
        strainCount += 1.1 / (1 + math.exp(-10 * (strain / consistentTopStrain - 0.88)))
    end

    return strainCount
end

return StrainSkill

--!strict
local Workspace = game:GetService("Workspace")

local DifficultyHitObjects = require(Workspace.DifficultyCalculator.DifficultyHitObjects)
local ModData = require(Workspace.ModData)
local Skill = require(Workspace.DifficultyCalculator.Skills.BaseSkill.Skill)
local SkillUtils = require(Workspace.DifficultyCalculator.Skills.SkillUtils)

local HarmonicSkill = {}

type BaseSkill = Skill.Skill

export type HarmonicSkill = BaseSkill & {
    NoteWeightSum: number,
    HarmonicScale: number,
    DecayExponent: number,
    ObjectDifficultyOf: (self: HarmonicSkill, current: DifficultyHitObjects.ObjectData) -> number,
    ApplyDifficultyTransformation: (self: HarmonicSkill, difficulties: {number}) -> (),
    CountTopWeightedObjectDifficulties: (self: HarmonicSkill, difficultyValue: number) -> number,
}

function HarmonicSkill.new(mods: ModData.ModData): HarmonicSkill
    local self = Skill.new(mods) :: HarmonicSkill

    SkillUtils.OverrideSelf(self, HarmonicSkill)
    self.NoteWeightSum = 0
    self.HarmonicScale = 1
    self.DecayExponent = 0.9

    return self
end

function HarmonicSkill:ObjectDifficultyOf(_current: DifficultyHitObjects.ObjectData): number
    error("ObjectDifficultyOf must be implemented by derived skill")
end

function HarmonicSkill:ProcessInternal(current: DifficultyHitObjects.ObjectData): number
    return self:ObjectDifficultyOf(current)
end

function HarmonicSkill:ApplyDifficultyTransformation(_difficulties: {number})
    -- Optional transform for derived skills.
end

function HarmonicSkill:DifficultyValue(): number
    if #self.ObjectDifficulties == 0 then
        return 0
    end

    local difficulties = {}
    for i = 1, #self.ObjectDifficulties do
        local value = self.ObjectDifficulties[i]
        if value > 0 then
            difficulties[#difficulties + 1] = value
        end
    end

    if #difficulties == 0 then
        return 0
    end

    self:ApplyDifficultyTransformation(difficulties)

    table.sort(difficulties, function(a, b)
        return a > b
    end)

    self.NoteWeightSum = 0

    local difficulty = 0
    for index = 1, #difficulties do
        local i = index - 1
        local note = difficulties[index]
        local harmonicScale = self.HarmonicScale :: number
        local decayExponent = self.DecayExponent :: number
        local harmonicTerm = harmonicScale / (1 + i)
        local weight = (1 + harmonicTerm) / (math.pow(i, decayExponent) + 1 + harmonicTerm)

        self.NoteWeightSum += weight
        difficulty += note * weight
    end

    return difficulty
end

function HarmonicSkill:CountTopWeightedObjectDifficulties(difficultyValue: number): number
    if #self.ObjectDifficulties == 0 or self.NoteWeightSum == 0 then
        return 0
    end

    local consistentTopNote = difficultyValue / self.NoteWeightSum
    if consistentTopNote == 0 then
        return 0
    end

    local count = 0
    for i = 1, #self.ObjectDifficulties do
        local objectDifficulty: number = self.ObjectDifficulties[i]
        count += 1.1 / (1 + math.exp(-10 * (objectDifficulty / consistentTopNote - 0.88)))
    end

    return count
end

function HarmonicSkill.DifficultyToPerformance(difficulty: number): number
    return 4 * math.pow(difficulty, 3)
end

return HarmonicSkill

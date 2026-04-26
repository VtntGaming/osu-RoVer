--!strict
local Workspace = game:GetService("Workspace")

local DifficultyHitObjects = require(Workspace.DifficultyCalculator.DifficultyHitObjects)
local ModData = require(Workspace.ModData)
local HarmonicSkill = require(Workspace.DifficultyCalculator.Skills.BaseSkill.HarmonicSkill)
local ReadingEvaluator = require(Workspace.DifficultyCalculator.DifficultyEvaluator.ReadingEvaluator)
local SkillUtils = require(Workspace.DifficultyCalculator.Skills.SkillUtils)

local Reading = {}

type BaseHarmonicSkill = HarmonicSkill.HarmonicSkill

export type Reading = BaseHarmonicSkill & {
    SkillMultiplier: number,
    StrainDecayBase: number,
    CurrentStrain: number,
    HasHiddenMod: boolean,
    objectList: {DifficultyHitObjects.ObjectData},
    strainDecay: (self: Reading, ms: number) -> number,
    CountTopWeightedObjectDifficulties: (self: Reading, difficultyValue: number) -> number,
}

function Reading.new(mods: ModData.ModData): Reading
    local self = HarmonicSkill.new(mods) :: Reading

    SkillUtils.OverrideSelf(self, Reading)
    self.SkillMultiplier = 2.5
    self.StrainDecayBase = 0.8
    self.CurrentStrain = 0
    self.HasHiddenMod = mods.HD == true
    self.objectList = {} :: {DifficultyHitObjects.ObjectData}

    return self
end

function Reading:strainDecay(ms: number): number
    return math.pow(self.StrainDecayBase, ms / 1000)
end

function Reading:ObjectDifficultyOf(current: DifficultyHitObjects.ObjectData): number
    self.objectList[#self.objectList + 1] = current

    local decay = self:strainDecay(current.DeltaTime)

    local currentStrain = self.CurrentStrain :: number
    currentStrain *= decay
    currentStrain += ReadingEvaluator.GetReadingDiff(current, self.HasHiddenMod) * (1 - decay) * (self.SkillMultiplier :: number)
    self.CurrentStrain = currentStrain

    return currentStrain
end

function Reading:ApplyDifficultyTransformation(difficulties: {number})
    local reducedDifficultyBaseline = 0.0

    local reducedNoteCount = self:_calculateReducedNoteCount()
    local limit = math.min(#difficulties, reducedNoteCount)

    for i = 1, limit do
        local scale = math.log10(1 + (10 - 1) * math.clamp((i - 1) / reducedNoteCount, 0, 1))
        difficulties[i] *= reducedDifficultyBaseline + (1.0 - reducedDifficultyBaseline) * scale
    end
end

function Reading:_calculateReducedNoteCount(): number
    local reducedDifficultyDuration = 60 * 1000

    local objectList = self.objectList :: {DifficultyHitObjects.ObjectData}
    if #objectList == 0 then
        return 0
    end

    local reducedDuration = objectList[1].Time + reducedDifficultyDuration
    local reducedNoteCount = 0

    for i = 1, #objectList do
        if objectList[i].Time > reducedDuration then
            break
        end
        reducedNoteCount += 1
    end

    return reducedNoteCount
end

function Reading:CountTopWeightedObjectDifficulties(difficultyValue: number): number
    local difficulties = self.ObjectDifficulties
    if #difficulties == 0 then
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
    for i = 1, #difficulties do
        local d = difficulties[i] :: number
        count += 1.1 / (1 + math.exp(-5 * (d / consistentTopNote - 1.15)))
    end

    return count
end

return Reading

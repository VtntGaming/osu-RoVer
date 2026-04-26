--!strict
local Workspace = game:GetService("Workspace")

local DifficultyHitObjects = require(Workspace.DifficultyCalculator.DifficultyHitObjects)
local ModData = require(Workspace.ModData)
local StrainSkill = require(Workspace.DifficultyCalculator.Skills.BaseSkill.StrainSkill)

local StrainDecaySkill = {}

type BaseStrainSkill = StrainSkill.StrainSkill

export type StrainDecaySkill = BaseStrainSkill & {
    SkillMultiplier: number,
    StrainDecayBase: number,
    CurrentStrain: number,
    strainDecay: (self: StrainDecaySkill, ms: number) -> number,
    StrainValueOf: (self: StrainDecaySkill, current: DifficultyHitObjects.ObjectData) -> number,
}

local function overrideSelf(self)
    for k, v in pairs(StrainDecaySkill) do
        self[k] = v
    end

    return self
end

function StrainDecaySkill.new(mods: ModData.ModData): StrainDecaySkill
    local self = StrainSkill.new(mods) :: StrainDecaySkill

    overrideSelf(self)
    self.SkillMultiplier = 1
    self.StrainDecayBase = 0.3
    self.CurrentStrain = 0

    return self
end

function StrainDecaySkill:strainDecay(ms: number): number
    return math.pow(self.StrainDecayBase, ms / 1000)
end

function StrainDecaySkill:CalculateInitialStrain(time: number, current: DifficultyHitObjects.ObjectData): number
    local previous = current.Previous(1)
    if not previous then
        return self.CurrentStrain
    end

    return self.CurrentStrain * self:strainDecay(time - previous.Time)
end

function StrainDecaySkill:StrainValueAt(current: DifficultyHitObjects.ObjectData): number
    local currentStrain = self.CurrentStrain :: number
    local skillMultiplier = self.SkillMultiplier :: number
    local strainValue = self:StrainValueOf(current) :: number

    currentStrain *= self:strainDecay(current.DeltaTime)
    currentStrain += strainValue * skillMultiplier

    self.CurrentStrain = currentStrain

    return currentStrain
end

function StrainDecaySkill:StrainValueOf(_current: DifficultyHitObjects.ObjectData): number
    error("StrainValueOf must be implemented by derived skill")
end

return StrainDecaySkill

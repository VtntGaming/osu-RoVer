--!strict
local Workspace = game:GetService("Workspace")

local DifficultyHitObjects = require(Workspace.DifficultyCalculator.DifficultyHitObjects)
local ModData = require(Workspace.ModData)
local StrainSkill = require(Workspace.DifficultyCalculator.Skills.BaseSkill.StrainSkill)
local FLEvaluator = require(Workspace.DifficultyCalculator.DifficultyEvaluator.FLEvaluator)
local SkillUtils = require(Workspace.DifficultyCalculator.Skills.SkillUtils)

local Flashlight = {}

type BaseStrainSkill = StrainSkill.StrainSkill

export type Flashlight = BaseStrainSkill & {
    SkillMultiplier: number,
    StrainDecayBase: number,
    CurrentStrain: number,
    strainDecay: (self: Flashlight, ms: number) -> number,
}

function Flashlight.new(mods: ModData.ModData): Flashlight
    local self = StrainSkill.new(mods) :: Flashlight

    SkillUtils.OverrideSelf(self, Flashlight)
    self.SkillMultiplier = 0.058
    self.StrainDecayBase = 0.15
    self.CurrentStrain = 0

    return self
end

function Flashlight:strainDecay(ms: number): number
    return math.pow(self.StrainDecayBase, ms / 1000)
end

function Flashlight:CalculateInitialStrain(time: number, current: DifficultyHitObjects.ObjectData): number
    local previous = current.Previous(1)
    if not previous then
        return self.CurrentStrain
    end
    return self.CurrentStrain * self:strainDecay(time - previous.Time)
end

function Flashlight:StrainValueAt(current: DifficultyHitObjects.ObjectData): number
    local currentStrain = self.CurrentStrain :: number
    currentStrain *= self:strainDecay(current.DeltaTime)
    currentStrain += FLEvaluator.getFlashLightDiff(current, self.Mods.HD) * (self.SkillMultiplier :: number)
    self.CurrentStrain = currentStrain
    return currentStrain
end

function Flashlight:DifficultyValue(): number
    local peaks = self:GetCurrentStrainPeaks()
    local total = 0
    for i = 1, #peaks do
        total += peaks[i]
    end
    return total
end

function Flashlight.DifficultyToPerformance(difficulty: number): number
    return 25 * math.pow(difficulty, 2)
end

return Flashlight

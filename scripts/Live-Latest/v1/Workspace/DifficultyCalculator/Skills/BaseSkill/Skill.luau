--!strict
local Workspace = game:GetService("Workspace")

local DifficultyHitObjects = require(Workspace.DifficultyCalculator.DifficultyHitObjects)
local SkillUtils = require(Workspace.DifficultyCalculator.Skills.SkillUtils)
local ModData = require(Workspace.ModData)

local Skill = {}

export type Skill = {
    Mods: ModData.ModData,
    ObjectDifficulties: {number},
    Process: (self: Skill, current: DifficultyHitObjects.ObjectData) -> (),
    ProcessInternal: (self: Skill, current: DifficultyHitObjects.ObjectData) -> number,
    DifficultyValue: (self: Skill) -> number,
    GetObjectDifficulties: (self: Skill) -> {number},
}

function Skill.new(mods: ModData.ModData): Skill
    local self = {} :: Skill

    SkillUtils.OverrideSelf(self, Skill)
    self.Mods = mods
    self.ObjectDifficulties = {}

    return self
end

function Skill:Process(current: DifficultyHitObjects.ObjectData)
    local difficultyValue = self:ProcessInternal(current)

    self.ObjectDifficulties[#self.ObjectDifficulties + 1] = difficultyValue
end

function Skill:ProcessInternal(_current: DifficultyHitObjects.ObjectData): number
    error("ProcessInternal must be implemented by derived skill")
end

function Skill:DifficultyValue(): number
    error("DifficultyValue must be implemented by derived skill")
end

function Skill:GetObjectDifficulties(): {number}
    return self.ObjectDifficulties
end

return Skill
--!strict
local Workspace = game:GetService("Workspace")

local DifficultyHitObjects = require(Workspace.DifficultyCalculator.DifficultyHitObjects)
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

local function overrideSelf(self)
    for k, v in pairs(Skill) do
        self[k] = v
    end

    return self
end

function Skill.new(mods: ModData.ModData): Skill
    local self = {} :: Skill

    overrideSelf(self)
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
--!strict
local Workspace = game:GetService("Workspace")

local DifficultyHitObjects = require(Workspace.DifficultyCalculator.DifficultyHitObjects)
local ModData = require(Workspace.ModData)
local Skill = require(Workspace.DifficultyCalculator.Skills.BaseSkill.Skill)
local SkillUtils = require(Workspace.DifficultyCalculator.Skills.SkillUtils)

local math_pow = math.pow
local math_max = math.max
local math_round = math.round

export type StrainPeak = {
    Value: number,
    SectionLength: number,
}

type QueuedStrain = {
    StrainValue: number,
    StartTime: number,
}

type BaseSkill = Skill.Skill

export type VariableLengthStrainSkill = {
    DecayWeight: number,
    MaxSectionLength: number,
    currentSectionPeak: number,
    currentSectionBegin: number,
    currentSectionEnd: number,
    totalLength: number,
    strainPeaks: {StrainPeak},
    queuedStrains: {QueuedStrain},
    ObjectDifficulties: {number},
    Mods: ModData.ModData,
    maxStoredSections: number,
    Process: (self: VariableLengthStrainSkill, current: DifficultyHitObjects.ObjectData) -> number,
    saveCurrentPeak: (self: VariableLengthStrainSkill, sectionLength: number) -> (),
    startNewSectionFrom: (self: VariableLengthStrainSkill, time: number, current: DifficultyHitObjects.ObjectData) -> (),
    backfillPeaks: (self: VariableLengthStrainSkill, current: DifficultyHitObjects.ObjectData) -> (),
    strainDecay: (self: VariableLengthStrainSkill, ms: number) -> number,
    StrainValueAt: (self: VariableLengthStrainSkill, current: DifficultyHitObjects.ObjectData) -> number,
    CalculateInitialStrain: (self: VariableLengthStrainSkill, time: number, current: DifficultyHitObjects.ObjectData) -> number,
    GetCurrentStrainPeaks: (self: VariableLengthStrainSkill) -> {StrainPeak},
    CountTopWeightedStrains: (self: VariableLengthStrainSkill, difficultyValue: number) -> number,
    DifficultyValue: (self: VariableLengthStrainSkill) -> number,
    new: (mods: ModData.ModData) -> VariableLengthStrainSkill,
    ProcessInternal: (self: VariableLengthStrainSkill, current: DifficultyHitObjects.ObjectData) -> number,
    NewStrainPeak: (value: number, length: number) -> StrainPeak,
}


local VariableLengthStrainSkill: VariableLengthStrainSkill = {} :: VariableLengthStrainSkill

function VariableLengthStrainSkill.new(mods: ModData.ModData): VariableLengthStrainSkill
    local self = Skill.new(mods) :: any

    SkillUtils.OverrideSelf(self, VariableLengthStrainSkill)
    self.DecayWeight = 0.9
    self.MaxSectionLength = 400

    self.currentSectionPeak = 0
    self.currentSectionBegin = 0
    self.currentSectionEnd = 0
    self.totalLength = 0
    self.maxStoredSections = 11 / (1 - self.DecayWeight)

    self.strainPeaks = {} :: {StrainPeak}
    self.queuedStrains = {} :: {QueuedStrain}

    return self :: VariableLengthStrainSkill
end

local function NewStrainPeak(value, length)
    return {
        Value = value,
        SectionLength = length
    }
end

local function IsHigher(a: StrainPeak, b: StrainPeak)
    if a.Value == b.Value then
        return a.SectionLength > b.SectionLength
    end
    return a.Value > b.Value
end

-- This is like insert then sort (but doesn't use table.sort() .-.)
-- I still don't know why C# remove at index 0 and still worked normally and luau isn't???
local function AddInPlace(tbl: {StrainPeak}, current: StrainPeak)
    for i = 1, #tbl do
        local strain = tbl[i]
        if IsHigher(current, strain) then
            table.insert(tbl, i, current)
            return
        end
    end

    tbl[#tbl+1] = current
end

VariableLengthStrainSkill.NewStrainPeak = NewStrainPeak

function VariableLengthStrainSkill:saveCurrentPeak(sectionLength: number)
    AddInPlace(self.strainPeaks, NewStrainPeak(self.currentSectionPeak, math_round(sectionLength)))
    self.totalLength += sectionLength

    -- Remove the LAST index
    while self.totalLength > self.maxStoredSections * self.MaxSectionLength and #self.strainPeaks > 0 do
        self.totalLength -= self.strainPeaks[#self.strainPeaks].SectionLength
        self.strainPeaks[#self.strainPeaks] = nil
    end
end

function VariableLengthStrainSkill:startNewSectionFrom(time: number, current: DifficultyHitObjects.ObjectData)
    self.currentSectionPeak = self:CalculateInitialStrain(time, current)
end

function VariableLengthStrainSkill:strainDecay(_ms: number): number
    -- Default: no decay (override in derived skills to match their strain decay rate)
    return 1
end

function VariableLengthStrainSkill:backfillPeaks(current: DifficultyHitObjects.ObjectData)
    while current.Time > self.currentSectionEnd do
        self:saveCurrentPeak(self.currentSectionEnd - self.currentSectionBegin)
        self.currentSectionBegin = self.currentSectionEnd

        if #self.queuedStrains > 0 then
            local queuedStrain = self.queuedStrains[1]
            table.remove(self.queuedStrains, 1)

            self.currentSectionEnd = queuedStrain.StartTime + self.MaxSectionLength
            self:startNewSectionFrom(self.currentSectionBegin, current)
            
            self.currentSectionPeak = math_max(self.currentSectionPeak, queuedStrain.StrainValue)
        else
            self.currentSectionEnd = self.currentSectionBegin + self.MaxSectionLength
            self:startNewSectionFrom(self.currentSectionBegin, current)
        end
    end
end

function VariableLengthStrainSkill:ProcessInternal(current: DifficultyHitObjects.ObjectData): number
    if current.objID <= 1 then
        self.currentSectionBegin = current.Time
        self.currentSectionEnd = self.currentSectionBegin + self.MaxSectionLength
        self.currentSectionPeak = self:StrainValueAt(current)

        return self.currentSectionPeak
    end

    self:backfillPeaks(current)

    local currentStrain = self:StrainValueAt(current)

    if currentStrain > self.currentSectionPeak then
        self.queuedStrains = {}

        self:saveCurrentPeak(current.Time - self.currentSectionBegin)

        self.currentSectionBegin = current.Time
        self.currentSectionEnd = self.currentSectionBegin + self.MaxSectionLength
        self.currentSectionPeak = currentStrain
    else
        local queuedStrain = self.queuedStrains
        while #queuedStrain > 0 and queuedStrain[#queuedStrain].StrainValue < currentStrain do
            table.remove(queuedStrain, #queuedStrain)
        end

        self.queuedStrains[#self.queuedStrains + 1] = {
            StrainValue = currentStrain,
            StartTime = current.Time,
        }
    end

    return currentStrain
end

function VariableLengthStrainSkill:StrainValueAt(_current: DifficultyHitObjects.ObjectData): number
    error("StrainValueAt must be implemented by derived skill")
end

function VariableLengthStrainSkill:CalculateInitialStrain(_time: number, _current: DifficultyHitObjects.ObjectData): number
    error("CalculateInitialStrain must be implemented by derived skill")
end

function VariableLengthStrainSkill:GetCurrentStrainPeaks(): {StrainPeak}
    local peaks = table.clone(self.strainPeaks)
    peaks[#peaks + 1] = NewStrainPeak(self.currentSectionPeak, self.currentSectionEnd - self.currentSectionBegin)

    return peaks
end

function VariableLengthStrainSkill:DifficultyValue(): number
    local peaks = self:GetCurrentStrainPeaks()
    local strains: {StrainPeak} = {}

    for i = 1, #peaks do
        local peak = peaks[i]
        if peak.Value > 0 then
            strains[#strains + 1] = peak
        end
    end

    table.sort(strains, function(a, b)
        if a.Value == b.Value then
            return a.SectionLength > b.SectionLength
        end
        return a.Value > b.Value
    end)

    local t = 0
    local difficulty = 0

    for i = 1, #strains do
        local startTime = t
        local endTime = t + strains[i].SectionLength
        local weight = math_pow(self.DecayWeight, startTime) - math_pow(self.DecayWeight, endTime)

        difficulty += strains[i].Value * weight
        t = endTime
    end

    return difficulty / (1 - self.DecayWeight)
end

function VariableLengthStrainSkill:CountTopWeightedStrains(difficultyValue: number): number
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

return VariableLengthStrainSkill
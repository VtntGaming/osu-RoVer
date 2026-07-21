local Workspace = game:GetService("Workspace")

local ModConfig = require(script.ModConfiguration)
local ModItem = require(script.ModItem)
local ModData = require(Workspace.ModData)
local Container = script.Parent.Parent.ModList.List

type ModData = ModData.ModData

local Items = {} :: {[string]: ModItem.ModItem}

local Piority = {
    "DifficultyIncrease",
    "DifficultyReduction",
    "Conversion",
    "Automation",
    "Misc",
}

local StaticBooleanMods = {
    "HD",
    "HR",
    "EZ",
    "NF",
    "NS",
    "FL",
    "AT",
}

local function GetBooleanStateOrDefault(mod: string, default: boolean?): boolean?
    local item = Items[mod]

    if not item then
        return default
    end

    return item.IsActivated
end

function GetModData(): ModData
    local data = {}

    for _, mod in ipairs(StaticBooleanMods) do
        data[mod] = GetBooleanStateOrDefault(mod, false)
    end

    return data
end

for id, data in pairs(ModConfig.ModList) do
    if data.DisableUI then
        continue
    end
    local modItem = ModItem.new(id)
    modItem:Setup()
    modItem.Frame.Parent = Container

    local piority = table.find(Piority, modItem.Data.Type) or 999

    modItem.Frame.LayoutOrder = piority

    Items[id] = modItem
end

script.Parent.GetMods.OnInvoke = GetModData
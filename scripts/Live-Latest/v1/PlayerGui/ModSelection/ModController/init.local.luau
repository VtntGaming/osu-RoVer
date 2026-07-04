local ModConfig = require(script.ModConfiguration)
local ModItem = require(script.ModItem)
local Container = script.Parent.Parent.ModList.List

local Items = {}

local Piority = {
    "DifficultyIncrease",
    "DifficultyReduction",
    "Conversion",
    "Automation",
    "Misc",
}

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

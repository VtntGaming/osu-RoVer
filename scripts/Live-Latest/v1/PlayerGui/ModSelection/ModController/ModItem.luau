--!strict
local ModConfiguration = require(script.Parent.ModConfiguration)
local Template = script.Parent.Assets.ModItem

type ItemInstance = typeof(Template)

export type ModItem = {
    __index: ModItem,
    ModID: string,
    new: (modId: string) -> ModItem,
    Frame: ItemInstance,
    Data: ModConfiguration.ModData,
    Setup: (self: ModItem) -> (),
}

local ModItem: ModItem = {} :: ModItem
ModItem.__index = ModItem

function ModItem.new(modId)
    local item = setmetatable({} :: any, ModItem)

    item.ModID = modId
    local frame = Template:Clone()
    item.Frame = frame

    local itemData = ModConfiguration.ModList[modId]

    if itemData then
        item.Data = itemData

        frame.MainFrame.Title.Text = itemData.Name
        frame.MainFrame.Desc.Text = itemData.Description
        local itemType = itemData.Type
        local palette = ModConfiguration.Palette[itemType]

        if palette then
            frame.MainFrame.BackgroundColor3 = palette.BackgroundColor
            frame.MainFrame.Title.TextColor3 = palette.TextColor
            frame.MainFrame.Desc.TextColor3 = palette.TextColor
            frame.MainFrame.UIStroke.Color = palette.StrokeColor
            frame.MainFrame.Icon.UIStroke.Color = palette.StrokeColor
            frame.MainFrame.Icon.Icon.ImageColor3 = palette.IconColor
        end
    end

    return item :: ModItem
end

function ModItem:Setup()
    
end

return ModItem
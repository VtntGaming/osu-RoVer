--!strict
local ModConfiguration = require(script.Parent.ModConfiguration)
local Template = script.Parent.Assets.ModItem
local TweenService = game:GetService("TweenService")

local TWEEN_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Linear)

type ItemInstance = typeof(Template)

export type ModItem = {
    __index: ModItem,
    ModID: string,
    Frame: ItemInstance,
    IsActivated: boolean,
    Data: ModConfiguration.ModData,
    OptionData: {[string]: any},
    -- Init
    new: (modId: string) -> ModItem,
    -- Methods
    Setup: (self: ModItem) -> (),
    SetActivated: (self: ModItem, activated: boolean) -> (),
}

local ModItem: ModItem = {} :: ModItem
ModItem.__index = ModItem

function ModItem.new(modId)
    local item = setmetatable({} :: any, ModItem)


    item.ModID = modId
    local frame = Template:Clone()
    item.Frame = frame

    local itemData = ModConfiguration.ModList[modId]
    -- Initial setup
    item.IsActivated = false

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

    item.OptionData = {}

    return item :: ModItem
end

function ModItem:Setup()
    local button = self.Frame.MainFrame.Button

    button.Activated:Connect(function()
        self:SetActivated(not self.IsActivated)
    end)
end

function ModItem:SetActivated(activated)
    self.IsActivated = activated
    script.Parent.Parent.AnyChanged:Fire()

    local itemData = self.Data

    local itemType = itemData.Type
    local palette = ModConfiguration.Palette[itemType]

    if palette then
        local frame = self.Frame
        local backgroundColor = activated and palette.HighlightedBackgroundColor or palette.BackgroundColor
        local textColor = activated and palette.HighlightedTextColor or palette.TextColor
        local strokeColor = activated and palette.HighlightedStrokeColor or palette.StrokeColor
        local iconColor = activated and palette.HighlightedIconColor or palette.IconColor

        TweenService:Create(frame.MainFrame, TWEEN_INFO, {BackgroundColor3 = backgroundColor}):Play()
        TweenService:Create(frame.MainFrame.Title, TWEEN_INFO, {TextColor3 = textColor}):Play()
        TweenService:Create(frame.MainFrame.Desc,TWEEN_INFO, {TextColor3 = textColor}):Play()
        TweenService:Create(frame.MainFrame.UIStroke,TWEEN_INFO, {Color = strokeColor}):Play()
        TweenService:Create(frame.MainFrame.Icon.UIStroke,TWEEN_INFO, {Color = strokeColor}):Play()
        TweenService:Create(frame.MainFrame.Icon.Icon,TWEEN_INFO, {ImageColor3 = iconColor}):Play()
    end
end

return ModItem
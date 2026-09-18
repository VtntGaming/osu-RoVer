--!strict
local ModConfiguration = require(script.Parent.ModConfiguration)
local Template = script.Parent.Assets.ModItem
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Assets = script.Parent.Assets
local CustomizeItem = Assets.CustomizeItem
local CustomizeSlider = Assets.CustomizeSlider

local TWEEN_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Linear)

type ItemInstance = typeof(Template)
type CustomizeItem = typeof(CustomizeItem)
type CustomizeSlider = typeof(CustomizeSlider)

export type ModItem = {
    __index: ModItem,
    ModID: string,
    Frame: ItemInstance,
    IsActivated: boolean,
	Data: ModConfiguration.ModData,
	CustomizeItem: CustomizeItem?,
	ActivateThread: thread?,
    OptionData: {[string]: any},
    -- Init
    new: (modId: string) -> ModItem,
    -- Methods
    Setup: (self: ModItem) -> (),
    SetActivated: (self: ModItem, activated: boolean, system: boolean?) -> (),
}

local ModItem: ModItem = {} :: ModItem
ModItem.__index = ModItem

function ModItem.new(modId)
	local item = setmetatable({} :: any, ModItem) :: ModItem

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
		
		local modOptions = itemData.ModOptions
		
		if modOptions and #modOptions > 0 then
			local customizeItem = CustomizeItem:Clone()
			customizeItem.Visible = false -- Default setup
			customizeItem.Title.Title.Text = itemData.Name
			local customizeColor = Color3.new(1,1,1)
			if palette then
				customizeColor = palette.TextColor
			end
			
			customizeItem.Title.Title.TextColor3 = customizeColor
			
			for index, option in ipairs(modOptions) do
				if option.Type == "Slider" then
					local slider = CustomizeSlider:Clone()
					slider.LayoutOrder = index
					slider.Name = option.Name
					slider.Title.Display.Text = option.Name
					
					local sliderOption = option :: ModConfiguration.ModOptionSlider
					
					slider.Name = sliderOption.Name
					slider.Default.Value = sliderOption.Default
					slider.Current.Value = sliderOption.Default
					slider.Min.Value = sliderOption.Min
					slider.Max.Value = sliderOption.Max
					slider.Precision.Value = sliderOption.Step
					
					local sliderBody = slider.Slider.Body
					
					sliderBody.Ratio.BackgroundColor3 = customizeColor
					sliderBody.Ratio.Center.BackgroundColor3 = customizeColor
					
					slider.SliderControl.Enabled = true
					slider.Parent = customizeItem				
				end
			end
			
			item.CustomizeItem = customizeItem
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
	
	local customizeItem = self.CustomizeItem
	local didChange = false
	if customizeItem then
		for _, item in ipairs(customizeItem:GetChildren()) do
			if item ~= self.CustomizeItem.Title and item ~= self.CustomizeItem.UIListLayout then
				local sliderItem = item :: CustomizeSlider
				
				sliderItem.Current.Changed:Connect(function()
					self.OptionData[sliderItem.Name] = sliderItem.Current.Value
					didChange = true
				end)
				
				sliderItem.Resetted.Event:Connect(function()
					self.OptionData[sliderItem.Name] = nil
				end)
			end
		end
	end
	
	UserInputService.InputEnded:Connect(function(data)
		if didChange and (data.UserInputType == Enum.UserInputType.MouseButton1 or data.UserInputType == Enum.UserInputType.Touch or data.UserInputType == Enum.UserInputType.Focus) then
			didChange = false
			script.Parent.Parent.AnyChanged:Fire(self.ModID)
		end
	end)
end

function ModItem:SetActivated(activated, system)
	local wasActivated = self.IsActivated
	self.IsActivated = activated
	
	if self.CustomizeItem then
		self.CustomizeItem.Visible = activated
		
		if activated and not wasActivated then
			for _, item in ipairs(self.CustomizeItem:GetChildren()) do
				if item ~= self.CustomizeItem.Title and item ~= self.CustomizeItem.UIListLayout then
					local sliderItem = item :: CustomizeSlider
					sliderItem.Current.Value = sliderItem.Default.Value
				end
			end
			
			self.OptionData = {}	-- Reset states
		end
	end
	
	if not system then
		script.Parent.Parent.AnyChanged:Fire(self.ModID)
	end

    local itemData = self.Data

    local itemType = itemData.Type
	local palette = ModConfiguration.Palette[itemType]

	if self.ActivateThread then
		task.cancel(self.ActivateThread)
	end
	
	self.ActivateThread = task.spawn(function()
		if palette then
			local frame = self.Frame
			local backgroundColor = activated and palette.HighlightedBackgroundColor or palette.BackgroundColor
			local textColor = activated and palette.HighlightedTextColor or palette.TextColor
			local strokeColor = activated and palette.HighlightedStrokeColor or palette.StrokeColor
			local iconColor = activated and palette.HighlightedIconColor or palette.IconColor

			for i = 1, 2 do
				task.wait()
			end

			TweenService:Create(frame.MainFrame, TWEEN_INFO, {BackgroundColor3 = backgroundColor}):Play()
			TweenService:Create(frame.MainFrame.Title, TWEEN_INFO, {TextColor3 = textColor}):Play()
			TweenService:Create(frame.MainFrame.Desc,TWEEN_INFO, {TextColor3 = textColor}):Play()
			TweenService:Create(frame.MainFrame.UIStroke,TWEEN_INFO, {Color = strokeColor}):Play()
			TweenService:Create(frame.MainFrame.Icon.UIStroke,TWEEN_INFO, {Color = strokeColor}):Play()
			TweenService:Create(frame.MainFrame.Icon.Icon,TWEEN_INFO, {ImageColor3 = iconColor}):Play()
		end
	end)
end

return ModItem
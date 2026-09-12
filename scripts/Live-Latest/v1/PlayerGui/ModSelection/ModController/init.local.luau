local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

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

local ScoreMultiplierValue = Instance.new("NumberValue")
ScoreMultiplierValue.Value = 1

local function GetBooleanStateOrDefault(mod: string, default: boolean?): boolean?
    local item = Items[mod]

    if not item then
        return default
    end

    return item.IsActivated
end

function GetModData(): ModData
    local data = {} :: ModData

    for _, mod in ipairs(StaticBooleanMods) do
        data[mod] = GetBooleanStateOrDefault(mod, false)
	end
	
	local isDT = GetBooleanStateOrDefault("DT", false)
	local isHT = GetBooleanStateOrDefault("HT", false)
	
	if isDT then
		data.SA = 1.5
	elseif isHT then
		data.SA = 0.75
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

local ScoreMultiplierDisplay = script.Parent.Parent.Properties.ScoreMultiplier.ScoreMultiplier

script.Parent.AnyChanged.Event:Connect(function(modID: string, system: boolean?)
	if system then
		return
	end
	
	local wasDisabledIncompatibleMods = false
	
	local item = Items[modID]
	local itemIncompatibleMods = item.Data.IncompatibleMods
	if itemIncompatibleMods then
		for _, mod in ipairs(itemIncompatibleMods) do
			local incompatibleItem = Items[mod]
			
			if incompatibleItem and incompatibleItem.IsActivated then
				incompatibleItem:SetActivated(false, true)
				wasDisabledIncompatibleMods = true
			end
		end
	end	
	
	local scoreMultiplier = 1
	for _, item in pairs(Items) do
		if item.IsActivated then
			local modMultiplier = item.Data.ScoreMultiplier
			if modMultiplier then
				scoreMultiplier *= modMultiplier
			end
		end
	end
	
	TweenService:Create(ScoreMultiplierValue, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Value = scoreMultiplier
	}):Play()
	
	if wasDisabledIncompatibleMods then
		script.Parent.AnyChanged:Fire(modID, true)
	end
end)

ScoreMultiplierValue.Changed:Connect(function()
	local scoreMultiplier = ScoreMultiplierValue.Value	

	local displayColor = Color3.new(1, 1, 1)

	if scoreMultiplier < 1 then
		displayColor = ModConfig.Palette.DifficultyReduction.TextColor
	elseif scoreMultiplier > 1 then
		displayColor = ModConfig.Palette.DifficultyIncrease.TextColor		
	end

	ScoreMultiplierDisplay.Text = string.format("x%.2f", scoreMultiplier)
	ScoreMultiplierDisplay.TextColor3 = displayColor
end)

script.Parent.GetMods.OnInvoke = GetModData
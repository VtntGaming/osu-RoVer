--!strict
local OsuMapConvert = require(workspace.Gameplay.OsuMapConvert)
local GameTime = require(script.Parent.Parent.GameTime)

local TweenService = game:GetService("TweenService")
local Players = game.Players
local LocalPlayer = Players.LocalPlayer :: Player
local PlayerGui = LocalPlayer.PlayerGui

local GameBackgroundUI = PlayerGui:WaitForChild("GameBackground")
local MainGameplayUI = PlayerGui:WaitForChild("MainGameplay")
local BGDim = GameBackgroundUI.DimBackground
local PlayScreen = MainGameplayUI.PlayScreen
local BreakTimeFrame = PlayScreen.BreakTimeFrame

type BaseBreakTimeDisplay = Frame & {
	MainDisplay: TextLabel
}

local BreakTime = {}

local function AnimateBreakTimeDisplay(baseDisplay: BaseBreakTimeDisplay, isLeft: boolean, isOpen: boolean)
	local objLayoutORder = baseDisplay.LayoutOrder
	local extendDuration = isLeft and isOpen and 0.5 or 0.25
	local tweenDuration = 0.5 + ((objLayoutORder - 1) / 3 * extendDuration)
	local easingDirection = isOpen and Enum.EasingDirection.Out or Enum.EasingDirection.In
	local posX = 0
	local transparency = isOpen and 0 or 1
	
	if isOpen then
		if isLeft then
			posX = -5
		end
	else
		if isLeft then
			posX = -50
		else
			posX = 50
		end
	end
	
	TweenService:Create(baseDisplay.MainDisplay, TweenInfo.new(0.5, Enum.EasingStyle.Quart, easingDirection), {
		Position = UDim2.fromOffset(posX, 0),
		TextTransparency = transparency
	}):Play()
end

function BreakTime.Open()
	TweenService:Create(BreakTimeFrame.Progress,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(1,0,0,5)}):Play()
	TweenService:Create(BreakTimeFrame.TimeDisplay,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,0.25,0), TextTransparency = 0}):Play()

	for _, obj in pairs(BreakTimeFrame.StatusDisplay_L:GetChildren()) do
		if obj:IsA("Frame") then
			AnimateBreakTimeDisplay(obj :: BaseBreakTimeDisplay, true, true)
		end
	end

	for _, obj in pairs(BreakTimeFrame.StatusDisplay_R:GetChildren()) do
		if obj:IsA("Frame") then
			AnimateBreakTimeDisplay(obj :: BaseBreakTimeDisplay, false, true)
		end
	end
end

function BreakTime.Close()
	for _, obj in pairs(BreakTimeFrame.StatusDisplay_L:GetChildren()) do
		if obj:IsA("Frame") then
			AnimateBreakTimeDisplay(obj :: BaseBreakTimeDisplay, true, false)
		end
	end

	for _, obj in pairs(BreakTimeFrame.StatusDisplay_R:GetChildren()) do
		if obj:IsA("Frame") then
			AnimateBreakTimeDisplay(obj :: BaseBreakTimeDisplay, false, false)
		end
	end
end

function BreakTime.Start(mapData: OsuMapConvert.ReturnData)
	task.spawn(function()
		for _, breakTimeData in pairs(mapData.BreakTime) do
			local startTime = breakTimeData.StartTime/1000
			local endTime = breakTimeData.EndTime/1000
			local duration = endTime - startTime
			
			repeat task.wait() until GameTime.GetTime() >= startTime

			if duration < 2 then continue end -- Only process animation if break time is more than 2 sec
			
			TweenService:Create(BGDim ,TweenInfo.new(1, Enum.EasingStyle.Linear),{BackgroundTransparency = 0.4}):Play()

			task.spawn(function()
				while task.wait() do
					local current = GameTime.GetTime()
					if current > endTime then
						break
					end
					BreakTimeFrame.Progress.ActualProgress.Size = UDim2.fromScale((endTime - current) / duration, 1)
					BreakTimeFrame.TimeDisplay.Text = string.format("%d", (endTime - current + 1))
				end
			end)
			
			BreakTime.Open()
			repeat task.wait() until GameTime.GetTime() >= endTime - 0.75			
			BreakTime.Close()
			TweenService:Create(BreakTimeFrame.TimeDisplay,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Position = UDim2.new(0.5,0,0.25,20), TextTransparency = 1}):Play()
			repeat task.wait() until GameTime.GetTime() >= endTime
			TweenService:Create(BGDim,TweenInfo.new(1,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.2}):Play()

			TweenService:Create(BreakTimeFrame.Progress,TweenInfo.new(0,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Size = UDim2.new(0,0,0,5)}):Play()
			BreakTimeFrame.TimeDisplay.Text = "0"
		end
	end)
end

return BreakTime
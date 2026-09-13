--!strict
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game.Players
local LocalPlayer = Players.LocalPlayer :: Player

local ParallaxIntensity = 1

local PARALLAX_BASE = 0.02
local PARALLAX_MENU_BASE = 0.01

local Background = script.Parent.Background
local BackgroundScale = Instance.new("UIScale")
BackgroundScale.Parent = Background
BackgroundScale.Scale = 1 + PARALLAX_BASE

local PlayerGui = LocalPlayer.PlayerGui
local MenuScreen = PlayerGui:WaitForChild("MenuScreen")
local OnCloseValue = MenuScreen.OnClose
local SelectScreen = MenuScreen.MainScreen.SelectScreen

local CurrentOffset = Vector2.zero
local TargetOffset = Vector2.zero

local function UpdateBackgroundParallax(offset: Vector2)
	local adjustedOffset = offset * ParallaxIntensity * PARALLAX_BASE
	local offsetScale = UDim2.fromScale(adjustedOffset.X, adjustedOffset.Y)
	
	local pos = UDim2.fromScale(0.5, 0.5) + offsetScale
	
	Background.Position = pos
end

local function UpdateMenuScreenParallax(offset: Vector2)
	if OnCloseValue.Value then
		return
	end
	local adjustedOffset = offset * ParallaxIntensity * PARALLAX_MENU_BASE
	local offsetScale = UDim2.fromScale(adjustedOffset.X, adjustedOffset.Y)

	local pos = UDim2.fromScale(0.5, 0.5) + offsetScale
	
	SelectScreen.Position = pos
end

local function SetIntensity(intensity: number)
	ParallaxIntensity = intensity
end

local function UpdateParallaxPosition(pos: Vector2)
	local currentCamera = workspace.CurrentCamera :: Camera
	local screenSize = currentCamera.ViewportSize

	local offset = (pos - screenSize / 2) / screenSize

	TargetOffset = offset
end

local function BindCursor()
	local mainGameplayUI = PlayerGui:WaitForChild("MainGameplay")
	local cursorUI = mainGameplayUI.CursorOverlay.Cursor
	cursorUI:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		if mainGameplayUI.Enabled then
			UpdateParallaxPosition(cursorUI.AbsolutePosition)
		end
	end)
end

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		local pos = UserInputService:GetMouseLocation()
		local mainGameplayUI = PlayerGui:FindFirstChild("MainGameplay")
		
		if not mainGameplayUI or not mainGameplayUI.Enabled then
			UpdateParallaxPosition(pos)			
		end
	end
end)

BindCursor()
PlayerGui.ChildAdded:Connect(function(obj)
	if obj.Name == "MainGameplay" then
		BindCursor()
	end
end)

RunService.PreRender:Connect(function(dt)
	if CurrentOffset ~= TargetOffset then
		local lerpAlpha = math.min(dt * 10, 1)
		CurrentOffset = CurrentOffset:Lerp(TargetOffset, lerpAlpha)
		UpdateBackgroundParallax(CurrentOffset)
		UpdateMenuScreenParallax(CurrentOffset)
	end
end)
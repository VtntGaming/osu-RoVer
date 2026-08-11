local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ParallaxIntensity = 1

local PARALLAX_BASE = 0.02
local PARALLAX_MENU_BASE = 0.01

local Background = script.Parent.Background
local BackgroundScale = Instance.new("UIScale")
BackgroundScale.Parent = Background
BackgroundScale.Scale = 1 + PARALLAX_BASE

local MenuScreen = game.Players.LocalPlayer.PlayerGui.MenuScreen
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

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		local pos = UserInputService:GetMouseLocation()
		local screenSize = workspace.CurrentCamera.ViewportSize
		
		local offset = (pos - screenSize / 2) / screenSize
		
		TargetOffset = offset
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
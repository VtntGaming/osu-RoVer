--[LOCATION]:[StarterGui.Settings.SettingFrame.BaseFrame.MainLayer.Component.BigButtons]
local TweenService = game:GetService("TweenService")

local _tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
local _tweenFlash = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
local _tweenHoverIn = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local _tweenHoverOut = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local _tweenImmediate = TweenInfo.new(0)

function bindButton(button:GuiButton)
	local buttonColor = button.BackgroundColor3
	local hoverColor = buttonColor:Lerp(Color3.new(1, 1, 1), 0.2)
	local hoverFlashColor = buttonColor:Lerp(Color3.new(1, 1, 1), 0.5)
	local clickColor = buttonColor:Lerp(Color3.new(1, 1, 1), 0.7)
	local onHover = false

	local sizeHold = UDim2.fromScale(0.9, 0.9)
	local sizeBase = UDim2.fromScale(1 , 1)
	button.MouseEnter:Connect(function()
		onHover = true
		TweenService:Create(button, _tweenImmediate, {BackgroundColor3 = hoverFlashColor}):Play()
		task.wait()		
		TweenService:Create(button, _tweenInfo, {BackgroundColor3 = hoverColor}):Play()
	end)
	
	button.MouseLeave:Connect(function()
		onHover = false
		TweenService:Create(button, _tweenInfo, {BackgroundColor3 = buttonColor}):Play()		
	end)
	
	button.MouseButton1Down:Connect(function()
		TweenService:Create(button, _tweenHoverIn, {Size = sizeHold}):Play()
	end)
	
	button.InputEnded:Connect(function()
		TweenService:Create(button, _tweenHoverOut, {Size = sizeBase}):Play()		
	end)
	
	button.MouseButton1Click:Connect(function()
		TweenService:Create(button, _tweenImmediate, {BackgroundColor3 = clickColor}):Play()
		task.wait()
		TweenService:Create(button, _tweenFlash, {BackgroundColor3 = onHover and hoverColor or buttonColor}):Play()
	end)	
end

for _, obj in pairs(script.Parent.Parent:GetDescendants()) do
	if obj:IsA("BoolValue") and obj.Name == "_BigButtons" then
		bindButton(obj.Parent)
	end
end
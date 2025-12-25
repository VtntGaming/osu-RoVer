--[LOCATION]:[StarterGui.Settings.SettingFrame.BaseFrame.MainLayer.SkinCustomizeLayerSwitch]
local isVisible = false
local TweenService = game:GetService("TweenService")
local animateId

function update()
	local crrId = game.HttpService:GenerateGUID()
	animateId = crrId
	local tweenout = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local tweenin = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tweenlinear = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
	if isVisible then
		TweenService:Create(script.Parent.SkinCustomize, tweenout, {Position = UDim2.new(0.175,0,0,0), AnchorPoint = Vector2.new(0,0)}):Play()
		TweenService:Create(script.Parent.MainSettings, tweenout, {AnchorPoint = Vector2.new(0.75,0)}):Play()
		TweenService:Create(script.Parent.MainSettings.Block.Display, tweenout, {BackgroundTransparency = 0}):Play()
		TweenService:Create(script.Parent.ReturnButton.Base, tweenlinear, {GroupTransparency = 0}):Play()
		script.Parent.MainSettings.ScrollingEnabled = false
		script.Parent.MainSettings.Block.Visible = true
		script.Parent.ReturnButton.Visible = true
	else
		TweenService:Create(script.Parent.SkinCustomize, tweenin, {Position = UDim2.new(0,0,0,0), AnchorPoint = Vector2.new(1,0)}):Play()
		TweenService:Create(script.Parent.MainSettings, tweenout, {AnchorPoint = Vector2.new(0,0)}):Play()
		TweenService:Create(script.Parent.MainSettings.Block.Display, tweenlinear, {BackgroundTransparency = 1}):Play()
		TweenService:Create(script.Parent.ReturnButton.Base, tweenout, {GroupTransparency = 1}):Play()
		for _,obj in pairs(script.Parent.SkinCustomize.Base:GetDescendants()) do
			if obj:IsA("LocalScript") and obj.Name == "KeyRegistering" then
				obj.ForceStop:Fire()
			end
		end
		spawn(function()
			script.Parent.MainSettings.ScrollingEnabled = true
			wait(0.5)
			if crrId ~= animateId then
				return
			end
			script.Parent.MainSettings.Block.Visible = false
			script.Parent.ReturnButton.Visible = false
		end)
	end
end

script.Parent.ReturnButton.Base.Hitbox.MouseButton1Click:Connect(function()
	isVisible = false
	update()
end)

script.Event.Event:Connect(function(state)
	isVisible = state or false
	update()
end)

script.check.OnInvoke = function()
	return isVisible
end
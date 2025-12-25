--[LOCATION]:[StarterGui.Settings.SettingFrame.BaseFrame.MainLayer.SettingsVisibility]
local TweenService = game:GetService("TweenService")

local BaseFrame = script.Parent.Parent
local MainFrame = BaseFrame.Parent
local MainSettingsFrame = script.Parent.MainSettings
local exitArea = script.Parent.Parent.Parent.ExitArea
local keybindLayerSwitch = script.Parent.KeybindLayerSwitch
local skinCustomizeLayerSwitch = script.Parent.SkinCustomizeLayerSwitch
local isVisible = false

function toggle(state, isForce)
	-- isForce is avaiable when there's a critical process that force you to close the entire settings
	if state == false then
		script.Parent.SettingsManage.SaveSettings:Fire()
		
		if keybindLayerSwitch.check:Invoke() then
			keybindLayerSwitch.Event:Fire(false)
			if not isForce then
				return
			else
				task.wait(0.5)
			end
		end
		
		if skinCustomizeLayerSwitch.check:Invoke() then
			skinCustomizeLayerSwitch.Event:Fire(false)
			if not isForce then
				return
			else
				task.wait(0.5)
			end
		end
	end
	
	isVisible = state
	
	local baseTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local baseInTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

	MainFrame.Interactable = isVisible
	if isVisible then
		exitArea.Visible = true
		TweenService:Create(MainFrame, baseTweenInfo, {GroupTransparency = 0}):Play()
		TweenService:Create(BaseFrame, baseTweenInfo, {AnchorPoint = Vector2.new(0,0)}):Play()
		TweenService:Create(MainSettingsFrame, baseTweenInfo, {AnchorPoint = Vector2.new(0,0)}):Play()
		if keybindLayerSwitch.check:Invoke() then
			-- just in case
			keybindLayerSwitch.Event:Fire(false)
		end
		
		if skinCustomizeLayerSwitch.check:Invoke() then
			-- just in case again
			skinCustomizeLayerSwitch.Event:Fire(false)
		end
	else
		TweenService:Create(MainFrame, baseInTweenInfo, {GroupTransparency = 1}):Play()
		TweenService:Create(BaseFrame, baseInTweenInfo, {AnchorPoint = Vector2.new(1,0)}):Play()
		TweenService:Create(MainSettingsFrame, baseInTweenInfo, {AnchorPoint = Vector2.new(0.5,0)}):Play()
		task.spawn(function()
			task.wait(0.5)
			if not isVisible then
				exitArea.Visible = false
			end
		end)
	end
end

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.O and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
		toggle(not isVisible)
	end
end)

exitArea.MouseButton1Click:Connect(function()
	toggle(false)
end)

game.Players.LocalPlayer.PlayerGui:WaitForChild("MenuInterface").DropdownMenu.MenuList.Settings.Hitbox.MouseButton1Click:Connect(function()
	toggle(true)
end)

script.toggle.Event:Connect(function(state, isForce)
	toggle(state, isForce)
end)
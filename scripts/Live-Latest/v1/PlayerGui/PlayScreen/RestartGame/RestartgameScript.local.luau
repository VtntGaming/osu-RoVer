--[LOCATION]:[StarterGui.PlayScreen.RestartGame.RestartgameScript]
local SecurityValue = script:WaitForChild("Key",math.huge)
local ServerSecurityKey = SecurityValue.Value
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local PauseUtils = require(script.Parent.Parent.GameplayScripts.Components.Gameplay.PauseScreen)
local notificationPopupSignal = game.Players.LocalPlayer.PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification
SecurityValue.Value = "no"
SecurityValue:Destroy()
local wait = require(workspace.WaitModule)

local isSpectateReturn = false
local isReplayReturn = false
local SpectateReturnUID = 0

script.Parent.Parent:WaitForChild("GameStarted",math.huge)

local RightSite = script.Parent.Parent.ScriptSettings:WaitForChild("RestartGameRightSite").Value
if not RightSite then
	TweenService:Create(script.Parent,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(1,-3,1,-3)}):Play()
else
	script.Parent.AnchorPoint = Vector2.new(0,1)
	script.Parent.Position = UDim2.new(0,3,1,20)
	TweenService:Create(script.Parent,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(0,3,1,-3)}):Play()
end
spawn(function()
	TweenService:Create(script.Parent.Reminder,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{TextTransparency = 0}):Play()
	wait(3)
	TweenService:Create(script.Parent,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{TextTransparency = 0.75,BackgroundTransparency = 1}):Play()
	TweenService:Create(script.Parent.Reminder,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{TextTransparency = 1}):Play()
	script.Parent.MouseEnter:Connect(function()
		TweenService:Create(script.Parent,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{TextTransparency = 0,BackgroundTransparency = 0}):Play()
		TweenService:Create(script.Parent.Reminder,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{TextTransparency = 0}):Play()
	end)
	script.Parent.MouseLeave:Connect(function()
		TweenService:Create(script.Parent,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{TextTransparency = 0.75,BackgroundTransparency = 1}):Play()
		TweenService:Create(script.Parent.Reminder,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{TextTransparency = 1}):Play()
	end)
end)

local LastHold = 0
local HoldProgress = 0
local OnHold = false
local GotSignal = false

script.Parent.MouseButton1Down:Connect(function()
	OnHold = true
end)
script.Parent.MouseButton1Up:Connect(function()
	if OnHold then
		OnHold = false
		LastHold = tick()
	end
end)

script.Parent.MouseLeave:Connect(function()
	if OnHold then
		OnHold = false
		LastHold = tick()
	end
end)

local pauseSignal = script.Parent.Parent.GameplayPause
local resumeSignal = script.Parent.Parent.GameplayResume
local onPaused = false
local PAUSE_TOGGLE = {
	Enum.KeyCode.P,
	Enum.KeyCode.Escape
}
local lastPauseToggle = 0
local lastUnpause = 0

local function togglePause(isPaused: boolean):boolean
	local pauseAllowed = script.Parent.Parent.GameplayData.PauseAllowed.Value
	if not pauseAllowed then
		return false
	end
	if isPaused and not onPaused then
		if tick() - lastUnpause > 3 then	-- They are NOT suppose to pasue that fast
			GotSignal = true
			onPaused = true
			PauseUtils.Toggle(true, false, {})
			pauseSignal:Fire(true)
			script.Parent.Visible = false
		else
			notificationPopupSignal:Fire("Wait a bit before pausing again!", Color3.new(1,0,0))
		end		
	elseif not isPaused and onPaused then
		task.spawn(function()
			PauseUtils.Toggle(false, false, {})
			task.wait(1)
			lastUnpause = tick()
			GotSignal = false
			resumeSignal:Fire()
			onPaused = false	
			script.Parent.Visible = true	
		end)
	end
	
	return true
end

spawn(function()
	local previous = tick()
	while task.wait() do
		if OnHold then
			HoldProgress += (tick() - previous)
		elseif tick() - LastHold >= 0.1 then
			HoldProgress = math.max(0, HoldProgress - (tick() - previous) * 2)
		end
		script.Parent.DelayFrame.Size = UDim2.new(math.min(1, HoldProgress/0.5),0,0,2)
		previous = tick()
		if HoldProgress >= 0.5 and OnHold and not GotSignal then
			--script.Parent.Event:Fire()
			local canPause = togglePause(true)
			if not canPause then
				-- If they can't pause, leave instead
				GotSignal = true
				script.Parent.Event:Fire()
			end
		end
	end
end)

local LeftCtrlHold = false
local RightCtrlHold = false
local LeftShiftHold = false
local RightShiftHold = false
local FastRestart = false

script.Parent.Parent.PauseScreen.ContinueBeatmap.MouseButton1Click:Connect(function()
	togglePause(false)
end)

script.Parent.Parent.PauseScreen.RestartBeatmap.MouseButton1Click:Connect(function()
	FastRestart = true
	PauseUtils.Toggle(false, false, {})
	script.Parent.Event:Fire()
end)

script.Parent.Parent.PauseScreen.ExitGame.MouseButton1Click:Connect(function()
	PauseUtils.Toggle(false, false, {})
	script.Parent.Event:Fire()
end)

game.Players.LocalPlayer.PlayerGui.BG.ResultScreenOptions.ReturnButton.InputButton.MouseButton1Click:Connect(function()
	wait(0.5)
	script.Parent.Event:Fire()
end)

game.Players.LocalPlayer.PlayerGui.BG.ResultScreenOptions.RestartButton.InputButton.MouseButton1Click:Connect(function()
	wait(0.5)
	FastRestart = true
	script.Parent.Event:Fire()
end)

game:GetService("UserInputService").InputBegan:Connect(function(data)
	if data.KeyCode == Enum.KeyCode.R and (LeftCtrlHold == true or RightCtrlHold == true) then
		if RightShiftHold == true or LeftShiftHold == true then
			FastRestart = true
		end
		script.Parent.Event:Fire()
	elseif data.KeyCode == Enum.KeyCode.LeftControl then
		LeftCtrlHold = true
	elseif data.KeyCode == Enum.KeyCode.RightControl then
		RightCtrlHold = true
	elseif data.KeyCode == Enum.KeyCode.LeftShift then
		LeftShiftHold = true
	elseif data.KeyCode == Enum.KeyCode.RightShift then
		RightShiftHold = true
	elseif table.find(PAUSE_TOGGLE, data.KeyCode) then
		if tick() - lastPauseToggle > 0.5 then
			lastPauseToggle = tick()
			togglePause(not onPaused)
		end
	end
end)

game:GetService("UserInputService").InputEnded:Connect(function(data)
	if data.KeyCode == Enum.KeyCode.LeftControl then
		LeftCtrlHold = false
	elseif data.KeyCode == Enum.KeyCode.RightControl then
		RightCtrlHold = false
	elseif data.KeyCode == Enum.KeyCode.LeftShift then
		LeftShiftHold = false
	elseif data.KeyCode == Enum.KeyCode.RightShift then
		RightShiftHold = false
	end
end)

local QuickRestartHoldDuration = 0

spawn(function()
	--Backquote
	spawn(function()
		local start = tick()
		while wait() do
			local found = false
			for _,key in pairs(game:GetService("UserInputService"):GetKeysPressed()) do
				if key.KeyCode == Enum.KeyCode.Backquote and not game:GetService("UserInputService"):GetFocusedTextBox() then
					found = true
					break
				end
			end
			if found == true then
				QuickRestartHoldDuration += tick() - start
			else
				QuickRestartHoldDuration = 0
			end
			start = tick()
		end
	end)
	
	repeat wait() until QuickRestartHoldDuration >= 0.5
	FastRestart = true
	script.Parent.Event:Fire()
end)


local QuickReturnHoldDuration = 0

spawn(function()
	--Backquote
	spawn(function()
		local start = tick()
		while wait() do
			local found = false
			for _,key in pairs(game:GetService("UserInputService"):GetKeysPressed()) do
				if key.KeyCode == Enum.KeyCode.Backspace  and not game:GetService("UserInputService"):GetFocusedTextBox() then
					found = true
					break
				end
			end
			if found == true then
				QuickReturnHoldDuration += tick() - start
			else
				QuickReturnHoldDuration = 0
			end
			start = tick()
		end
	end)

	repeat wait() until QuickReturnHoldDuration >= 0.5
	script.Parent.Event:Fire()
end)

script.Parent.SpectateReturn.Event:Connect(function(UserId)
	if QuickReturnHoldDuration > 0 or QuickRestartHoldDuration > 0 or OnHold then
		return -- Do not spectate if the player wanted to leave
	end
	isSpectateReturn = true
	SpectateReturnUID = UserId
	script.Parent.Event:Fire()
end)

script.Parent.ReplayReturn.Event:Connect(function()
	if QuickReturnHoldDuration > 0 or QuickRestartHoldDuration > 0 or OnHold then
		return
	end
	
	isReplayReturn = true
	script.Parent.Event:Fire()
end)


script.Parent.ResetcharacterCallback.Event:Connect(function()
	FastRestart = true
	script.Parent.Event:Fire()
end)

local MPForceLeave = script.Parent.Event.Event:Wait()
script.Parent.Parent.Name = "no"
local GameplayTransition = script.GameplayTransition:Clone()
GameplayTransition.Parent = game.Players.LocalPlayer.PlayerGui

local isMultiplayer = not game.Players.LocalPlayer.PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.Disabled
-- If multiplayer, the game will stop and not restart

if not FastRestart or isMultiplayer then
	local NewPreviewSong = script.Parent.Parent.GameSong.Song
	NewPreviewSong.Parent =  game.Players.LocalPlayer.PlayerGui
	NewPreviewSong.Name = "TransitionSong"
end


if FastRestart and not isMultiplayer then
	Instance.new("BoolValue",GameplayTransition).Name = "FastRestart"
end
GameplayTransition.LocalScript.Disabled = false
wait(0.25)
game.Players.LocalPlayer.PlayerGui.BG:Destroy()
game.Players.LocalPlayer.PlayerGui.StoryboardUI:Destroy()
--game.Players.LocalPlayer.PlayerGui.BeatmapChoose:Destroy()
local NewBGFrame = game.StarterGui.BG:Clone()
NewBGFrame.Parent = game.Players.LocalPlayer.PlayerGui
local newStoryboardUI = game.StarterGui.StoryboardUI:Clone()
newStoryboardUI.Parent = game.Players.LocalPlayer.PlayerGui
if isSpectateReturn then
	local SpectateTransition = script.SpectateTransition:Clone()
	SpectateTransition.Parent = game.Players.LocalPlayer.PlayerGui
	local UIDValue = Instance.new("IntValue",SpectateTransition)
	UIDValue.Name = "SpectateUID"
	UIDValue.Value = tonumber(SpectateReturnUID)
	SpectateTransition.LocalScript.Disabled = false
end



--game.StarterGui.BeatmapChoose:Clone().Parent = game.Players.LocalPlayer.PlayerGui
local NewPlayScreen = game.StarterGui.PlayScreen:Clone()
local CorescriptKey = Instance.new("StringValue",NewPlayScreen.OsuGame)
CorescriptKey.Name = "Key"
CorescriptKey.Value = ServerSecurityKey

local ReturnmainKey = Instance.new("StringValue",NewPlayScreen.RestartGame.RestartgameScript)
ReturnmainKey.Name = "Key"
ReturnmainKey.Value = ServerSecurityKey
NewPlayScreen.Parent = game.Players.LocalPlayer.PlayerGui

if isReplayReturn then
	wait(1)
	NewPlayScreen.ReplayCall:Fire(game.ReplicatedStorage.ClientCommunication.GetLocalReplayData:Invoke(1))
end
if FastRestart == true and not isMultiplayer then
	NewPlayScreen.StartupState.Value = "FastRestart"
	--Instance.new("BoolValue",NewPlayScreen).Name = "_FastRestart"
else
	NewPlayScreen.StartupState.Value = "Normal"
end


--game.Players.LocalPlayer.PlayerGui.BG.HitKey.Visible = false
script.Parent.Parent:Destroy()
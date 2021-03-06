osuLocalConvert = require(workspace.OsuConvert)



-- Services load

TweenService = game:GetService("TweenService")
local wait = require(workspace.WaitModule)

-- FPS checker

local GameplayFPS = 0

game:GetService("RunService").Stepped:Connect(function()
	GameplayFPS += 1
	wait(1)
	GameplayFPS -= 1
end)

-- Script default settings (can only change in the script)

BeatmapsList = workspace.Beatmaps

-- just in case I forgot to turn this ^^^ back
if not game:GetService("RunService"):IsStudio() and BeatmapsList ~= workspace.Beatmaps then
	BeatmapsList = workspace.Beatmaps
elseif #workspace.ProcessingBeatmap:GetChildren() > 0 and game:GetService("RunService"):IsStudio() then
	BeatmapsList = workspace.ProcessingBeatmap
	if game.Players.LocalPlayer.PlayerGui:WaitForChild("BeatmapChoose").BG:FindFirstChild("FirstLoad") then
		require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("Processing beatmap found, switching location.",Color3.new(0, 1, 0))
	end
end


-- Security key
SecurityValue = script:WaitForChild("Key",math.huge)
ServerSecurityKey = SecurityValue.Value
SecurityValue.Value = "no u"
SecurityValue:Destroy()




game.Players.LocalPlayer.PlayerGui:WaitForChild("BG"):WaitForChild("StartButton")

if game.Players.LocalPlayer.PlayerGui.SavedSettings:FindFirstChild("SettingsFrame") then
	game.Players.LocalPlayer.PlayerGui.BG.SettingsFrame:Destroy()
	game.Players.LocalPlayer.PlayerGui.SavedSettings.SettingsFrame:Clone().Parent = game.Players.LocalPlayer.PlayerGui.BG
else
	local CurrentSetting = game.Players.LocalPlayer.PlayerGui.BG.SettingsFrame.MainSettings
	local AsyncedSetting = game.ReplicatedStorage.GetSettings:InvokeServer()

	local Option = {["true"] = "Enabled",["false"] = "Disabled"}
	local AdvancedOption = {
		NotelockStyle = {["true"] = "Stable",["false"] = "Lazer"}
	}

	if tonumber(AsyncedSetting.Offset) and tonumber(AsyncedSetting.Offset) ~= 0 then
		local Value = AsyncedSetting.Offset
		if Value ~= 0 then
			CurrentSetting.Offset.ResetButton.Frame1.BackgroundTransparency = 0
			CurrentSetting.Offset.ResetButton.GlowEffect.BackgroundTransparency = 0
			CurrentSetting.Offset.ResetButton.GlowEffect.Size = UDim2.new(1,0,1,0)
		end
		CurrentSetting.Offset.DraggingZone.DragButton.Position = UDim2.new((Value+1000)/2000,0,0.5,0)
		CurrentSetting.Offset.Offset.Text = tostring(Value).."ms"
		CurrentSetting.Offset.Hint.Value = tostring(Value).."ms"
		CurrentSetting.Parent.VirtualSettings.InstantSettings.Offset.Value = Value
	end
	if tonumber(AsyncedSetting.ScrollSpeed) and tonumber(AsyncedSetting.ScrollSpeed) ~= 1 then
		local Value = AsyncedSetting.ScrollSpeed*100
		if Value ~= 100 then
			CurrentSetting.CursorSensitivity.ResetButton.Frame1.BackgroundTransparency = 0
			CurrentSetting.CursorSensitivity.ResetButton.GlowEffect.BackgroundTransparency = 0
			CurrentSetting.CursorSensitivity.ResetButton.GlowEffect.Size = UDim2.new(1,0,1,0)
		end
		CurrentSetting.CursorSensitivity.DraggingZone.DragButton.Position = UDim2.new(Value/300,0,0.5,0)
		CurrentSetting.CursorSensitivity.Sensitivity.Text = tostring(Value/100).."x"
		CurrentSetting.CursorSensitivity.Hint.Value = tostring(Value/100).."x"
		CurrentSetting.Parent.VirtualSettings.InstantSettings.Sensitivity.Value = Value
	end
	if tonumber(AsyncedSetting.BackgroundDimTrans) and tonumber(AsyncedSetting.BackgroundDimTrans) ~= 0.2 then
		local Value = AsyncedSetting.BackgroundDimTrans
		if Value ~= 0.2 then
			CurrentSetting.BackgroundDimTrans.ResetButton.Frame1.BackgroundTransparency = 0
			CurrentSetting.BackgroundDimTrans.ResetButton.GlowEffect.BackgroundTransparency = 0
			CurrentSetting.BackgroundDimTrans.ResetButton.GlowEffect.Size = UDim2.new(1,0,1,0)
		end
		Value *= 100
		CurrentSetting.BackgroundDimTrans.DraggingZone.DragButton.Position = UDim2.new(Value/100,0,0.5,0)
		CurrentSetting.BackgroundDimTrans.Trans.Text = tostring(Value).."%"
		CurrentSetting.BackgroundDimTrans.Hint.Value = tostring(Value).."%"
		CurrentSetting.Parent.VirtualSettings.InstantSettings.BackgroundDim.Value = Value
	end

	if tonumber(AsyncedSetting.SongVolume) and tonumber(AsyncedSetting.SongVolume) ~= 1 then
		local Value = AsyncedSetting.SongVolume
		if Value ~= 50 then
			CurrentSetting.SongVolume.ResetButton.Frame1.BackgroundTransparency = 0
			CurrentSetting.SongVolume.ResetButton.GlowEffect.BackgroundTransparency = 0
			CurrentSetting.SongVolume.ResetButton.GlowEffect.Size = UDim2.new(1,0,1,0)
		end
		CurrentSetting.SongVolume.DraggingZone.DragButton.Position = UDim2.new(Value/200,0,0.5,0)
		CurrentSetting.SongVolume.Volume.Text = tostring(Value).."%"
		CurrentSetting.SongVolume.Hint.Value = tostring(Value).."%"
		CurrentSetting.Parent.VirtualSettings.InstantSettings.SongVolume.Value = Value
	end


	if tonumber(AsyncedSetting.EffectVolume) and tonumber(AsyncedSetting.EffectVolume) ~= 1 then
		local Value = AsyncedSetting.EffectVolume
		if Value ~= 50 then
			CurrentSetting.EffectVolume.ResetButton.Frame1.BackgroundTransparency = 0
			CurrentSetting.EffectVolume.ResetButton.GlowEffect.BackgroundTransparency = 0
			CurrentSetting.EffectVolume.ResetButton.GlowEffect.Size = UDim2.new(1,0,1,0)
		end
		SongVolume = Value
		CurrentSetting.EffectVolume.DraggingZone.DragButton.Position = UDim2.new(Value/200,0,0.5,0)
		CurrentSetting.EffectVolume.Volume.Text = tostring(Value).."%"
		CurrentSetting.EffectVolume.Hint.Value = tostring(Value).."%"
		CurrentSetting.Parent.VirtualSettings.InstantSettings.EffectVolume.Value = Value
	end
	CurrentSetting.K1.KeyInput.Text = tostring(AsyncedSetting.K1)
	CurrentSetting.K2.KeyInput.Text = tostring(AsyncedSetting.K2)
	CurrentSetting.LightningEnabled.Text = "Circle lighting effect: "..Option[tostring(AsyncedSetting.Lightning)]
	CurrentSetting.CursorTrailEnabled.Text = "Cursor trail: "..Option[tostring(AsyncedSetting.CursorTrail)]
	CurrentSetting.Parent.VirtualSettings.CursorImageID.Value = tonumber(AsyncedSetting.Skin.CursorId)
	CurrentSetting.Parent.VirtualSettings.CursorSize.Value = tonumber(AsyncedSetting.Skin.CursorSize)
	CurrentSetting.Parent.VirtualSettings.CursorTrailImageID.Value = tonumber(AsyncedSetting.Skin.CursorTrailId) or -1
	CurrentSetting.Parent.VirtualSettings.CircleImageId.Value = tonumber(AsyncedSetting.Skin.CircleImageId) or -1
	CurrentSetting.Parent.VirtualSettings.CircleOverlayImageId.Value = tonumber(AsyncedSetting.Skin.CircleOverlayImageId) or -1
	CurrentSetting.Parent.VirtualSettings.ApproachCircleImageId.Value = tonumber(AsyncedSetting.Skin.ApproachCircleImageId) or -1
	CurrentSetting.Parent.VirtualSettings.CursorTrailSize.Value = tonumber(AsyncedSetting.Skin.CursorTrailSize) or 1
	CurrentSetting.Parent.VirtualSettings.CursorTrailTransparency.Value = tonumber(AsyncedSetting.Skin.CursorTrailTransparency) or 0.5
	CurrentSetting.MobileModeEnabled.Text = "Mobile mode [Touchscreen only]: "..Option[tostring(AsyncedSetting.MobileHit)]
	CurrentSetting.MouseButtonEnabled.Text = "Mouse button: "..Option[tostring(AsyncedSetting.MouseButton)]
	CurrentSetting.OldCursorMovement.Text = "Virtual cursor movement: "..Option[tostring(not AsyncedSetting.OldCursorMovement)]
	--CurrentSetting.NewCircleOverlay.Text = "New circle overlay: "..Option[tostring(AsyncedSetting.NewCircleOverlay)]
	CurrentSetting.OldScoreInterface.Text = "Old score interface: "..Option[tostring(AsyncedSetting.OldScoreInterface)]
	CurrentSetting.StableNotelock.Text = "In-game notelock: ".. AdvancedOption.NotelockStyle[tostring(AsyncedSetting.osuStableNotelock)]
	CurrentSetting.DisplayPS.Text = "Display perfomance: "..Option[tostring(AsyncedSetting.PerfomanceDisplay)]
	CurrentSetting.RightHitzone.Text = "Right side hitzone: "..Option[tostring(AsyncedSetting.RightHitZone)]
	CurrentSetting.DisableChatInGame.Text = "Disable chat in-game: "..Option[tostring(AsyncedSetting.InGameChatDisabled)]
	CurrentSetting.DisplayInGameLB.Text = "In-game leaderboard: "..Option[tostring(AsyncedSetting.DisplayInGameLB)]
	CurrentSetting.HitZoneEnabled.Text = "Hit zone: "..Option[tostring(AsyncedSetting.HitZone)]
end
if game.Players.LocalPlayer.PlayerGui.SavedSettings:FindFirstChild("PreviewFrame") then
	game.Players.LocalPlayer.PlayerGui.BG.PreviewFrame:Destroy()
	game.Players.LocalPlayer.PlayerGui.SavedSettings.PreviewFrame:Clone().Parent = game.Players.LocalPlayer.PlayerGui.BG
end

-- make everything goes back where it was

PlayerMouse = game.Players.LocalPlayer:GetMouse()
PlayerMouse.Icon = "rbxasset://textures/Cursors/KeyboardMouse"
--game:GetService("UserInputService").MouseIconEnabled = true
game.Players.LocalPlayer.PlayerGui.OsuCursor.Cursor.Visible = true
game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.Default
game.Players.LocalPlayer.PlayerGui.MenuInterface.LeaderboardButton.Visible = true
--game.Players.LocalPlayer.PlayerGui.MenuInterface.WikiButton.Visible = true
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,true)
game.Lighting.Blur.Size = 0


CurrentSetting = game.Players.LocalPlayer.PlayerGui.BG.SettingsFrame

Instance.new("IntValue",CurrentSetting.Parent).Name = "SettingsLoaded"

game.Players.LocalPlayer.PlayerGui.LoadUI.Scripts.EndloadScript.Disabled = false

-- Those settings can be change multiply times before the game start
FileType = 1
AutoPlay = false
CustomMusicID = false
IngamebeatmapID = CurrentSetting.VirtualSettings.IngameBeatmapID
LightningEnabled = true
CursorTrailEnabled = true
MobileMode = true -- Touch screen enabled only
SpeedSync = true
UIPreviewFrame = game.Players.LocalPlayer.PlayerGui.BG.PreviewFrame
CurrentPreviewFrame = UIPreviewFrame.PreviewFrame
MouseButtonEnabled = true
SliderMode = false -- This option will be remove and slider will be in real game soon
OldCursorMovement = false
NewCircelOverlay = false
OldInterface = false
Flashlight = false
PSDisplay = false
osuStableNotelock = true -- If enabled, it will use osu!stable notelock system, else it will use osu!lazer system
HitErrorEnabled = true
OverallInterfaceEnabled = true
NewPerfomanceDisplay = false
FreePlay = false
DefaultBackgroundTrans = 0.2
MobileModeRightHitZone = false
DisableChatInGame = false
KeepOriginalPitch = false
BackgroundBlurEnabled = false
showHealthBar = true
HardCore = false
HiddenMod = false
InGameLeaderboard = true
HitZoneEnabled = true
SongVolume = CurrentSetting.VirtualSettings.InstantSettings.SongVolume.Value
HardRock = false




-- PreviewFrameScriptSettings
PreviewFrameBaseVolume = 0.5




-- Default settings
BeatmapStudio = "playerchoose" --If test on studio, value to "playerchoose" if wanna set it to random
Id = 1
gameEnded = true
onTutorial = false

if script.StudioBeatmap.Value ~= nil then
	BeatmapStudio = script.StudioBeatmap.Value

	for i,beatmap in pairs(workspace.Beatmaps:GetChildren()) do
		if beatmap == BeatmapStudio then
			Id = i
		end
	end
end

BeatmapChangeable = false


-- Check settings, load settings
if IngamebeatmapID.Value == 0 then
	IngamebeatmapID.Value = math.random(1,#BeatmapsList:GetChildren())
	if game.Players.LocalPlayer.PlayerGui.SavedSettings:FindFirstChild("SettingsFrame") then
		game.Players.LocalPlayer.PlayerGui.SavedSettings.SettingsFrame.VirtualSettings.IngameBeatmapID.Value = IngamebeatmapID.Value
	end
end

if BeatmapStudio == "playerchoose" then
	BeatmapStudio = BeatmapsList:GetChildren()[IngamebeatmapID.Value]
	BeatmapChangeable = true
end


-- Settings default config

if CurrentSetting.MainSettings.CustomMusicID.Text == "Custom music: Enabled" then
	CustomMusicID = true
	CurrentSetting.MainSettings.SoundID.TextEditable = true
else
	CustomMusicID = false
	CurrentSetting.MainSettings.SoundID.TextEditable = false
end

if CurrentSetting.MainSettings.CustomBeatmap.Text == "Custom beatmap: Disabled" then
	game.Players.LocalPlayer.PlayerGui.BG.BeatmapChooseButton.Visible = true
	CurrentPreviewFrame.PreviewButton.Visible = false
	CurrentSetting.MainSettings.CustomBeatmap.Barrier.Visible = true
	game.Players.LocalPlayer.PlayerGui.BG.BeatmapLeaderboard.Visible = true
else
	game.Players.LocalPlayer.PlayerGui.BG.BeatmapChooseButton.Visible = false
	CurrentSetting.MainSettings.CustomBeatmap.Barrier.Visible = false
	CurrentPreviewFrame.PreviewButton.Visible = true
	game.Players.LocalPlayer.PlayerGui.BG.BeatmapLeaderboard.Visible = false
end

if CurrentSetting.MainSettings.CustomBeatmap.Text == "Custom beatmap: Direct" then
	FileType = 2
elseif CurrentSetting.MainSettings.CustomBeatmap.Text == "Custom beatmap: Roblox module" then
	FileType = 3
else
	CurrentSetting.MainSettings.CustomBeatmap.Text = "Custom beatmap: Disabled" --Just in case bug happen and make the text isn't like this
	FileType = 1
end

if CurrentSetting.MainSettings.AutoPlay.Text == "Auto play: Enabled" then
	AutoPlay = true
end

if CurrentSetting.MainSettings.LightningEnabled.Text == "Circle lighting effect: Disabled" then
	LightningEnabled = false
end

if CurrentSetting.MainSettings.CursorTrailEnabled.Text == "Cursor trail: Disabled" then
	CursorTrailEnabled = false
end

if CurrentSetting.MainSettings.MobileModeEnabled.Text == "Mobile mode [Touchscreen only]: Disabled" then
	MobileMode = false
end

if CurrentSetting.MainSettings.SpeedSync.Text == "Sync approach time: Disabled" then
	SpeedSync = false
end

if CurrentSetting.MainSettings.Flashlight.Text == "Flashlight: Enabled" then
	Flashlight = true
end

if CurrentSetting.MainSettings.MouseButtonEnabled.Text == "Mouse button: Disabled" then
	MouseButtonEnabled = false
end

if CurrentSetting.MainSettings.SliderMode.Text == "[Beta] Sliders: Enabled" then
	SliderMode = true
end

if CurrentSetting.MainSettings.OldCursorMovement.Text == "Virtual cursor movement: Disabled" then
	OldCursorMovement = true
end


if CurrentSetting.MainSettings.DisplayPS.Text == "Display perfomance: Enabled" then
	PSDisplay = true
end

if CurrentSetting.MainSettings.OldScoreInterface.Text == "Old score interface: Enabled" then
	OldInterface = true
end

if CurrentSetting.MainSettings.StableNotelock.Text == "In-game notelock: Lazer" then
	osuStableNotelock = false
end

if CurrentSetting.MainSettings.HitErrorInterface.Text == "Hit error: Disabled" then
	HitErrorEnabled = false
end

if CurrentSetting.MainSettings.OverallInterface.Text == "Overall interface: Disabled" then
	OverallInterfaceEnabled = false
end

if CurrentSetting.MainSettings.DisplayNewPerfomance.Text == "[Testing] Beta perfomance display: Enabled" then
	NewPerfomanceDisplay = true
end

if CurrentSetting.MainSettings.RightHitzone.Text == "Right side hitzone: Enabled" then
	MobileModeRightHitZone = true
end

if CurrentSetting.MainSettings.DisableChatInGame.Text == "Disable chat in-game: Enabled" then
	DisableChatInGame = true
end

if CurrentSetting.MainSettings.KeepOriginalPitch.Text == "Keep original speed pitch[0.5-2x]: Enabled" then
	KeepOriginalPitch = true
end

if CurrentSetting.MainSettings.HardCore.Text == "Hardcore: Enabled" then
	HardCore = true
end

if CurrentSetting.MainSettings.Hidden.Text == "Hidden: Enabled" then
	HiddenMod = true
end

if CurrentSetting.MainSettings.DisplayInGameLB.Text == "In-game leaderboard: Disabled" then
	InGameLeaderboard = false
end

if CurrentSetting.MainSettings.HitZoneEnabled.Text == "Hit zone: Disabled" then
	HitZoneEnabled = false
end

if CurrentSetting.MainSettings.HardRock.Text == "Hardrock: Enabled" then
	HardRock = true
end

CurrentModData = {
	HD = HiddenMod,
	FL = Flashlight,
	HC = HardCore,
	HR = HardRock,
	Speed = tonumber(CurrentSetting.MainSettings.Speed.Text) or 1
}

function LoadMultiplier()
	local Multiplier = 1
	if CurrentModData.HD then
		Multiplier *= 1.06
	end
	if CurrentModData.HR then
		Multiplier *= 1.06
	end
	if CurrentModData.FL then
		Multiplier *= 1.12
	end
	if CurrentModData.HC then
		Multiplier *= 2
	end
	if CurrentModData.Speed ~= 1 then
		local Speed = CurrentModData.Speed
		if Speed < 1 then
			Multiplier *= Speed^4.185
		elseif Speed > 1 then
			Multiplier *= Speed^0.28
		end
	end
	Multiplier = math.floor((Multiplier*100)+0.5)/100
	CurrentSetting.MainSettings.ScoreMultiplier.Text = "Multiplier: "..tostring(Multiplier).."x"
end

LoadMultiplier()

-- Settings change detect

CurrentSetting.MainSettings.Flashlight.MouseButton1Click:Connect(function()
	Flashlight = not Flashlight
	CurrentModData.FL = Flashlight
	LoadMultiplier()
	if Flashlight == true then 
		CurrentSetting.MainSettings.Flashlight.Text = 'Flashlight: Enabled'
	else 
		CurrentSetting.MainSettings.Flashlight.Text = 'Flashlight: Disabled'
	end
end)

CurrentSetting.MainSettings.DisplayPS.MouseButton1Click:Connect(function()
	PSDisplay = not PSDisplay
	if PSDisplay == true then 
		CurrentSetting.MainSettings.DisplayPS.Text = 'Display perfomance: Enabled'
	else 
		CurrentSetting.MainSettings.DisplayPS.Text = 'Display perfomance: Disabled'
	end
end)

script.Parent.Parent.BG.ResultFrame:GetPropertyChangedSignal('Visible'):Connect(function()
	gameEnded = true
	script.Parent.PlayFrame.Flashlight.Visible = false
end)

CurrentSetting.MainSettings.CustomMusicID.MouseButton1Click:Connect(function()
	CustomMusicID = not CustomMusicID
	if CustomMusicID == true then
		CurrentSetting.MainSettings.CustomMusicID.Text = "Custom music: Enabled"
		CurrentSetting.MainSettings.SoundID.TextEditable = true
	else
		CurrentSetting.MainSettings.CustomMusicID.Text = "Custom music: Disabled"
		CurrentSetting.MainSettings.SoundID.TextEditable = false
	end
end)

CurrentSetting.MainSettings.CustomBeatmap.MouseButton1Click:Connect(function()
	FileType += 1
	if FileType ~= 1 then
		game.Players.LocalPlayer.PlayerGui.BG.BeatmapChooseButton.Visible = false
		game.Players.LocalPlayer.PlayerGui.BG.BeatmapLeaderboard.Visible = false
		CurrentPreviewFrame.PreviewButton.Visible = true
		CurrentSetting.MainSettings.CustomBeatmap.Barrier.Visible = false
	end
	if FileType == 2 then
		CurrentSetting.MainSettings.BeatmapFile.TextEditable = true
		CurrentSetting.MainSettings.CustomBeatmap.Text = "Custom beatmap: Direct"
	elseif FileType == 3 then
		CurrentSetting.MainSettings.BeatmapFile.TextEditable = true
		CurrentSetting.MainSettings.CustomBeatmap.Text = "Custom beatmap: Roblox module"
	else
		FileType = 1
		game.Players.LocalPlayer.PlayerGui.BG.BeatmapChooseButton.Visible = true
		CurrentPreviewFrame.PreviewButton.Visible = false
		CurrentSetting.MainSettings.BeatmapFile.TextEditable = false
		game.Players.LocalPlayer.PlayerGui.BG.BeatmapLeaderboard.Visible = true
		CurrentSetting.MainSettings.CustomBeatmap.Barrier.Visible = true
		CurrentSetting.MainSettings.CustomBeatmap.Text = "Custom beatmap: Disabled"
	end
end)

CurrentSetting.MainSettings.AutoPlay.MouseButton1Click:Connect(function()
	AutoPlay = not AutoPlay
	if AutoPlay == true --[[and ReplayMode ~= true]] then
		CurrentSetting.MainSettings.AutoPlay.Text = "Auto play: Enabled"
	else
		CurrentSetting.MainSettings.AutoPlay.Text = "Auto play: Disabled"
	end
end)


CurrentSetting.MainSettings.LightningEnabled.MouseButton1Click:Connect(function()
	LightningEnabled = not LightningEnabled
	if LightningEnabled == true then
		CurrentSetting.MainSettings.LightningEnabled.Text = "Circle lighting effect: Enabled"
	else
		CurrentSetting.MainSettings.LightningEnabled.Text = "Circle lighting effect: Disabled"
	end
end)

CurrentSetting.MainSettings.CursorTrailEnabled.MouseButton1Click:Connect(function()
	CursorTrailEnabled = not CursorTrailEnabled
	if CursorTrailEnabled == true then
		CurrentSetting.MainSettings.CursorTrailEnabled.Text = "Cursor trail: Enabled"
	else
		CurrentSetting.MainSettings.CursorTrailEnabled.Text = "Cursor trail: Disabled"
	end
end)

CurrentSetting.MainSettings.MobileModeEnabled.MouseButton1Click:Connect(function()
	MobileMode = not MobileMode
	if MobileMode == true then
		CurrentSetting.MainSettings.MobileModeEnabled.Text = "Mobile mode [Touchscreen only]: Enabled"
	else
		CurrentSetting.MainSettings.MobileModeEnabled.Text = "Mobile mode [Touchscreen only]: Disabled"
	end
end)

CurrentSetting.MainSettings.SpeedSync.MouseButton1Click:Connect(function()
	SpeedSync = not SpeedSync
	if SpeedSync == true then
		CurrentSetting.MainSettings.SpeedSync.Text = "Sync approach time: Enabled"
	else
		CurrentSetting.MainSettings.SpeedSync.Text = "Sync approach time: Disabled"
	end
end)

CurrentSetting.MainSettings.MouseButtonEnabled.MouseButton1Click:Connect(function()
	MouseButtonEnabled = not MouseButtonEnabled
	if MouseButtonEnabled == true then
		CurrentSetting.MainSettings.MouseButtonEnabled.Text = "Mouse button: Enabled"
	else
		CurrentSetting.MainSettings.MouseButtonEnabled.Text = "Mouse button: Disabled"
	end
end)

CurrentSetting.MainSettings.SliderMode.MouseButton1Click:Connect(function()
	SliderMode = not SliderMode
	if SliderMode == true then
		CurrentSetting.MainSettings.SliderMode.Text = "[Beta] Sliders: Enabled"
	else
		CurrentSetting.MainSettings.SliderMode.Text = "[Beta] Sliders: Disabled"
	end
end)



CurrentSetting.MainSettings.OldCursorMovement.MouseButton1Click:Connect(function()
	OldCursorMovement = not OldCursorMovement
	if OldCursorMovement == true then
		CurrentSetting.MainSettings.OldCursorMovement.Text = "Virtual cursor movement: Disabled"
	else
		CurrentSetting.MainSettings.OldCursorMovement.Text = "Virtual cursor movement: Enabled"
	end
end)


CurrentSetting.MainSettings.OldScoreInterface.MouseButton1Click:Connect(function()
	OldInterface = not OldInterface
	if OldInterface == true then
		CurrentSetting.MainSettings.OldScoreInterface.Text = "Old score interface: Enabled"
	else
		CurrentSetting.MainSettings.OldScoreInterface.Text = "Old score interface: Disabled"
	end
end)

CurrentSetting.MainSettings.StableNotelock.MouseButton1Click:Connect(function()
	osuStableNotelock = not osuStableNotelock
	if osuStableNotelock == true then
		CurrentSetting.MainSettings.StableNotelock.Text = "In-game notelock: Stable"
	else
		CurrentSetting.MainSettings.StableNotelock.Text = "In-game notelock: Lazer"
	end
end)


CurrentSetting.MainSettings.HitErrorInterface.MouseButton1Click:Connect(function()
	HitErrorEnabled = not HitErrorEnabled
	if HitErrorEnabled == true then
		CurrentSetting.MainSettings.HitErrorInterface.Text = "Hit error: Enabled"
	else
		CurrentSetting.MainSettings.HitErrorInterface.Text = "Hit error: Disabled"
	end
end)

CurrentSetting.MainSettings.OverallInterface.MouseButton1Click:Connect(function()
	OverallInterfaceEnabled = not OverallInterfaceEnabled
	if OverallInterfaceEnabled == true then
		CurrentSetting.MainSettings.OverallInterface.Text = "Overall interface: Enabled"
	else
		CurrentSetting.MainSettings.OverallInterface.Text = "Overall interface: Disabled"
	end
end)


CurrentSetting.MainSettings.DisplayNewPerfomance.MouseButton1Click:Connect(function()
	NewPerfomanceDisplay = not NewPerfomanceDisplay
	if NewPerfomanceDisplay == true then
		CurrentSetting.MainSettings.DisplayNewPerfomance.Text = "[Testing] Beta perfomance display: Enabled"
	else
		CurrentSetting.MainSettings.DisplayNewPerfomance.Text = "[Testing] Beta perfomance display: Disabled"
	end
end)


CurrentSetting.MainSettings.RightHitzone.MouseButton1Click:Connect(function()
	MobileModeRightHitZone = not MobileModeRightHitZone
	if MobileModeRightHitZone == true then
		CurrentSetting.MainSettings.RightHitzone.Text = "Right side hitzone: Enabled"
	else
		CurrentSetting.MainSettings.RightHitzone.Text = "Right side hitzone: Disabled"
	end
end)


CurrentSetting.MainSettings.DisableChatInGame.MouseButton1Click:Connect(function()
	DisableChatInGame = not DisableChatInGame
	if DisableChatInGame == true then
		CurrentSetting.MainSettings.DisableChatInGame.Text = "Disable chat in-game: Enabled"
	else
		CurrentSetting.MainSettings.DisableChatInGame.Text = "Disable chat in-game: Disabled"
	end
end)


CurrentSetting.MainSettings.KeepOriginalPitch.MouseButton1Click:Connect(function()
	KeepOriginalPitch = not KeepOriginalPitch
	if KeepOriginalPitch == true then
		CurrentSetting.MainSettings.KeepOriginalPitch.Text = "Keep original speed pitch[0.5-2x]: Enabled"
	else
		CurrentSetting.MainSettings.KeepOriginalPitch.Text = "Keep original speed pitch[0.5-2x]: Disabled"
	end
end)

CurrentSetting.MainSettings.HardCore.MouseButton1Click:Connect(function()
	HardCore = not HardCore
	CurrentModData.HC = HardCore
	LoadMultiplier()
	if HardCore == true then
		CurrentSetting.MainSettings.HardCore.Text = "Hardcore: Enabled"
	else
		CurrentSetting.MainSettings.HardCore.Text = "Hardcore: Disabled"
	end
end)

CurrentSetting.MainSettings.Hidden.MouseButton1Click:Connect(function()
	HiddenMod = not HiddenMod
	CurrentModData.HD = HiddenMod
	LoadMultiplier()
	if HiddenMod == true then
		CurrentSetting.MainSettings.Hidden.Text = "Hidden: Enabled"
	else
		CurrentSetting.MainSettings.Hidden.Text = "Hidden: Disabled"
	end
end)

CurrentSetting.MainSettings.DisplayInGameLB.MouseButton1Click:Connect(function()
	InGameLeaderboard = not InGameLeaderboard
	if InGameLeaderboard == true then
		CurrentSetting.MainSettings.DisplayInGameLB.Text = "In-game leaderboard: Enabled"
	else
		CurrentSetting.MainSettings.DisplayInGameLB.Text = "In-game leaderboard: Disabled"
	end
end)

CurrentSetting.MainSettings.HitZoneEnabled.MouseButton1Click:Connect(function()
	HitZoneEnabled = not HitZoneEnabled
	if HitZoneEnabled == true then
		CurrentSetting.MainSettings.HitZoneEnabled.Text = "Hit zone: Enabled"
	else
		CurrentSetting.MainSettings.HitZoneEnabled.Text = "Hit zone: Disabled"
	end
end)

CurrentSetting:WaitForChild("VirtualSettings").InstantSettings.SongVolume.Changed:Connect(function()
	SongVolume = CurrentSetting.VirtualSettings.InstantSettings.SongVolume.Value
	TweenService:Create(CurrentPreviewFrame.OverviewSong,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{Volume = PreviewFrameBaseVolume*(SongVolume*0.02)}):Play()
end)

CurrentSetting.MainSettings.HardRock.MouseButton1Click:Connect(function()
	HardRock = not HardRock
	CurrentModData.HR = HardRock
	LoadMultiplier()
	if HardRock == true then
		CurrentSetting.MainSettings.HardRock.Text = "Hardrock: Enabled"
	else
		CurrentSetting.MainSettings.HardRock.Text = "Hardrock: Disabled"
	end
end)

-- Process function [Loop function]

script.Parent.FunctionProcess.Event:Connect(function(Function)
	Function()
end)

function ProcessFunction(Function)
	script.Parent.FunctionProcess:Fire(Function)
end


-- Leaderboard

CurrentKey = ""
BeatmapKey = ""
local RankColor = {
	SS = Color3.fromRGB(255, 255, 0),
	S = Color3.fromRGB(255, 255, 0),
	A = Color3.fromRGB(0, 255, 0),
	B = Color3.fromRGB(0, 85, 255),
	C = Color3.fromRGB(170, 0, 127),
	D = Color3.fromRGB(255, 0, 0)
}

LocalLeaderboardData = {}
LeaderboardFrameConnection = {}

function GetModData(Mod,Detailed)
	local ReturnText = ""
	local ModUsed = false
	local Mods = 0

	if Mod == nil then
		return ""
	end

	if Mod.HC == true then
		ModUsed = true
		if Mods > 0 then
			ReturnText = ReturnText..","
		end
		Mods += 1
		if Detailed then
			ReturnText = ReturnText.."HardCore"
		else
			ReturnText = ReturnText.."HC"
		end
	end

	if Mod.HD == true then
		ModUsed = true
		if Mods > 0 then
			ReturnText = ReturnText..","
		end
		Mods += 1
		if Detailed then
			ReturnText = ReturnText.."Hidden"
		else
			ReturnText = ReturnText.."HD"
		end
	end

	if Mod.HR == true then
		ModUsed = true
		if Mods > 0 then
			ReturnText = ReturnText..","
		end
		Mods += 1
		if Detailed then
			ReturnText = ReturnText.."HardRock"
		else
			ReturnText = ReturnText.."HR"
		end
	end

	if Mod.SL == true then
		ModUsed = true
		if Mods > 0 then
			ReturnText = ReturnText..","
		end
		Mods += 1
		if Detailed then
			ReturnText = ReturnText.."Slider"
		else
			ReturnText = ReturnText.."SL"
		end
	end

	if Mod.FL == true then
		ModUsed = true
		if Mods > 0 then
			ReturnText = ReturnText..","
		end
		Mods += 1
		if Detailed then
			ReturnText = ReturnText.."FlashLight"
		else
			ReturnText = ReturnText.."FL"
		end
	end

	if Mods > 0 and not Detailed then
		ReturnText = ReturnText.." | "
	elseif Mods == 0 and Detailed then
		ReturnText = "None"
	end

	return ReturnText

end

function FillNumber(Num)
	if Num < 10 then
		return "0"..Num
	else
		return Num
	end
end

game:GetService("UserInputService").InputChanged:Connect(function(data)
	if data.UserInputType == Enum.UserInputType.MouseMovement then
		local LeaderboardInterface = game.Players.LocalPlayer.PlayerGui.BG.BeatmapLeaderboard
		local LBPosition = LeaderboardInterface.AbsolutePosition
		local MousePosition = data.Position
		local NewPosition = UDim2.new(0,MousePosition.X-LBPosition.X,0,MousePosition.Y-LBPosition.Y)
		LeaderboardInterface.LeaderboardDetail.Position = NewPosition

		local AnchorPoint = {X=0,Y=0}
		local ScreenSize = workspace.CurrentCamera.ViewportSize
		local FrameSize = LeaderboardInterface.LeaderboardDetail.AbsoluteSize
		local FramePosition = LeaderboardInterface.LeaderboardDetail.AbsolutePosition

		if MousePosition.X+FrameSize.X+25 > ScreenSize.X then
			AnchorPoint.X = 1
		end
		if MousePosition.Y+FrameSize.Y+75 > ScreenSize.Y then
			AnchorPoint.Y = 1
		end
		LeaderboardInterface.LeaderboardDetail.Position += (UDim2.new(0,20,0,35) - UDim2.new(0,AnchorPoint.X*20,0,AnchorPoint.Y*35))
		LeaderboardInterface.LeaderboardDetail.AnchorPoint = Vector2.new(AnchorPoint.X,AnchorPoint.Y)
	end
end)

function ShowLeaderboardPlayDetail(Data)
	local ModDetail = GetModData(Data.Mod,true)
	local PlayedDate = os.date("*t",tonumber(Data.Date))
	local DateDetail = PlayedDate.day.."/"..PlayedDate.month.."/"..PlayedDate.year.." "..FillNumber(PlayedDate.hour)..":"..FillNumber(PlayedDate.min)..":"..FillNumber(PlayedDate.sec)
	local Accuracy = "300:"..Data.ExtraAccurancy[1].." 100:"..Data.ExtraAccurancy[2].." 50:"..Data.ExtraAccurancy[3].." Miss:"..Data.ExtraAccurancy[4]
	local FullText = "Played on "..DateDetail.."\n"..Accuracy.."\nAccuracy:"..Data.Accurancy.."%\nMod:"..ModDetail
	local LeaderboardDetail = game.Players.LocalPlayer.PlayerGui.BG.BeatmapLeaderboard.LeaderboardDetail
	LeaderboardDetail.LeaderboardDetail.Text = FullText
	local Textbounds = LeaderboardDetail.LeaderboardDetail.TextBounds
	LeaderboardDetail.Size = UDim2.new(0,Textbounds.X+6,0,Textbounds.Y+6)
	LeaderboardDetail.Visible = true
end

function HideLeaderboardPlayDetail()
	local LeaderboardDetail = game.Players.LocalPlayer.PlayerGui.BG.BeatmapLeaderboard.LeaderboardDetail
	LeaderboardDetail.Visible = false
end

function AddLeaderboardConnection(LeaderboardFrame,Data)
	if not LeaderboardFrame:IsA("Frame") and not Data then return end
	LeaderboardFrameConnection[#LeaderboardFrameConnection+1] = LeaderboardFrame.MouseEnter:Connect(function()
		ShowLeaderboardPlayDetail(Data)
	end)
	LeaderboardFrameConnection[#LeaderboardFrameConnection+1] = LeaderboardFrame.MouseMoved:Connect(function()
		ShowLeaderboardPlayDetail(Data)
	end)
	LeaderboardFrameConnection[#LeaderboardFrameConnection+1] = LeaderboardFrame.MouseLeave:Connect(function()
		HideLeaderboardPlayDetail()
	end)
end

CurrentLeaderboardSession = ""

LBTweenConnection = {}
local _RefreshEvent = Instance.new("BindableEvent")

function AddLBTweenConnection(Tween,DelayedTime)
	local Key = game.HttpService:GenerateGUID(false)
	LBTweenConnection[Key] = _RefreshEvent.Event:Connect(function()
		wait(DelayedTime)
		if Tween == nil or Tween.Instance == nil and LBTweenConnection[Key] then
			LBTweenConnection[Key]:Disconnect()
			LBTweenConnection[Key] = nil
			return
		end

		if Tween.Instance then
			Tween.Instance.BackgroundTransparency = 0.75
			Tween:Play()
		end
	end)
	if Tween.Instance ~= nil or Tween.Instance.Parent ~= nil then
		Tween.Instance.Destroying:Wait()
	end
	LBTweenConnection[Key]:Disconnect()
	LBTweenConnection[Key] = nil
end

ProcessFunction(function()
	while script.Parent:FindFirstChild("GameStarted") == nil and wait(1.5) do
		_RefreshEvent:Fire()
	end
end)


function LoadLeaderboard()
	local LeaderboardInterface = game.Players.LocalPlayer.PlayerGui.BG.BeatmapLeaderboard
	local ThisLBSession = game.HttpService:GenerateGUID()
	CurrentLeaderboardSession = ThisLBSession

	-- Clear old data
	LeaderboardInterface.GolbalLeaderboard:ClearAllChildren()
	local PersonalBestOldData = LeaderboardInterface.PersonalBest:FindFirstChild("PlayerPB") 
	if PersonalBestOldData then
		PersonalBestOldData:Destroy()
	end
	LocalLeaderboardData = {}
	for _,connection in pairs(LeaderboardFrameConnection) do
		if connection then
			connection:Disconnect()
		end
	end
	LeaderboardFrameConnection = {}

	script.Parent.GameplayData.LeaderboardData.Value = "[]"

	-- Load new data

	LeaderboardInterface.LoadingText.Visible = true
	LeaderboardInterface.NoRecord.Visible = false
	LeaderboardInterface.PersonalBest.NoRecord.Visible = false
	LeaderboardInterface.PersonalBestTitle.TextTransparency = 1

	local GolbalData,PersonalData,SessionChanged = game.ReplicatedStorage.BeatmapLeaderboard:InvokeServer(1,{DatastoreName = CurrentKey})
	if SessionChanged == true or CurrentLeaderboardSession ~= ThisLBSession then return end

	local Leaderboard = LeaderboardInterface.GolbalLeaderboard
	local UIListLayout = Instance.new("UIListLayout",Leaderboard)
	UIListLayout.Padding = UDim.new(0,5)
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local PersonalRank = "-"
	local Top100Score = 1
	local GolbalLoaded = false

	local SendingData = {
		Golbal = GolbalData,
		Local = PersonalData
	}

	script.Parent.GameplayData.LeaderboardData.Value = game.HttpService:JSONEncode(SendingData)


	LeaderboardInterface.LoadingText.Visible = false

	--[[
	Data = {Name,Rank,Score,ExtraData = {Accurancy,MaxCombo,Grade,Date,ExtraAccurancy = {300s,100s,50s,miss}}}
	]]

	local function GetScore(CurrentScore)
		CurrentScore = tostring(CurrentScore)
		local NewScore = ""

		for i = 1,#CurrentScore do
			i = (#CurrentScore-i)+1
			if math.floor((#NewScore+1)/4)-((#NewScore+1)/4) == 0 then
				NewScore = string.sub(CurrentScore,i,i)..","..NewScore
			else
				NewScore = string.sub(CurrentScore,i,i)..NewScore
			end
		end
		return NewScore
	end

	local function GetDate(CurrentDate)
		local PlayedTime = os.time() - tonumber(CurrentDate)

		if PlayedTime < 3600 then
			return tostring(math.floor(PlayedTime/60)).."m"
		elseif PlayedTime < 86400 then
			return tostring(math.floor(PlayedTime/3600)).."h"
		elseif PlayedTime < 2592000 then
			return tostring(math.floor(PlayedTime/86400)).."d"
		elseif PlayedTime < 31104000 then
			return tostring(math.floor(PlayedTime/2592000)).."mo"
		else
			return tostring(math.floor(PlayedTime/31104000)).."yr"
		end
	end
	Leaderboard.CanvasSize = UDim2.new(0,0,0,#GolbalData*45)
	Leaderboard.CanvasPosition = Vector2.new(0,0)

	for i,Data in pairs(GolbalData) do
		ProcessFunction(function()
			wait((i-1)*0.025)
			local NewLBFrame = script.Leaderboard.LeaderboardFrame:Clone()
			NewLBFrame.Parent = Leaderboard
			-- check


			local Success,output = pcall(function()
				NewLBFrame.LayoutOrder = tonumber(Data.Rank)
				NewLBFrame.MainFrame.PlayerName.Text = Data.Name
				local MaxComboText = ""
				if Data.ExtraData ~= nil then
					MaxComboText = " (x"..tostring(Data.ExtraData.MaxCombo)..")"
					NewLBFrame.MainFrame.Accurancy.Text = tostring(Data.ExtraData.Accurancy).."%"
					NewLBFrame.MainFrame.PlayDate.Text = GetDate(Data.ExtraData.Date).." | "..GetModData(Data.ExtraData.Mod)..tostring(Data.ExtraData.Speed).."x"
					NewLBFrame.MainFrame.Grade.Text = Data.ExtraData.Grade
					if Data.ExtraData.Grade == "SS" then
						NewLBFrame.MainFrame.Grade.Text = "S"
						NewLBFrame.MainFrame.Grade_SS.Visible = true
					end
					NewLBFrame.MainFrame.Grade.TextColor3 = RankColor[Data.ExtraData.Grade]
					local PSEarned = Data.ExtraData.PS
					if PSEarned ~= nil then
						NewLBFrame.MainFrame.PSEarned.Text = tostring(math.floor(PSEarned)).."ps"
					else
						NewLBFrame.MainFrame.PSEarned.Text = "-"
					end
				else
					NewLBFrame.MainFrame.Accurancy.Text = "-"
					NewLBFrame.MainFrame.PlayDate.Text = "-"
					NewLBFrame.MainFrame.PSEarned.Text = "-"
				end
				if tostring(Data.Rank) == "100" then
					Top100Score = tonumber(Data.Score)+1
				end
				NewLBFrame.MainFrame.Score.Text = "Score: "..GetScore(Data.Score)..MaxComboText
				NewLBFrame.MainFrame.Rank.Text = "#"..tostring(Data.Rank)
				NewLBFrame.MainFrame.PlayerImage.Image = Data.ThumbnailId
				ProcessFunction(function()
					if Data.Name == game.Players.LocalPlayer.Name then
						NewLBFrame.MainFrame.PlayerName.TextColor3 = Color3.new(0,1,1)
						NewLBFrame.MainFrame.Rank.TextColor3 = Color3.new(0,1,1)
						PersonalRank = tostring(Data.Rank)
					else
						local isLoaded = false
						local isFriend = false
						while isLoaded == false do
							wait()
							if pcall(function()
									isFriend = game.Players.LocalPlayer:IsFriendsWith(game.Players:GetUserIdFromNameAsync(Data.Name))
								end) == true then
								isLoaded = true
							end
						end
						if isFriend == true then
							NewLBFrame.MainFrame.PlayerName.TextColor3 = Color3.new(1,1,0)
							NewLBFrame.MainFrame.Rank.TextColor3 = Color3.new(1,1,0)
						end
					end
				end)
				AddLeaderboardConnection(NewLBFrame,Data.ExtraData)
			end)

			if not Success then print(Data) end
			TweenService:Create(NewLBFrame.MainFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart),{Position = UDim2.new(0,0,0,0)}):Play()
			wait(0.5)
			for _,a in pairs(NewLBFrame.MainFrame:GetChildren()) do
				if a:IsA("TextLabel") then
					TweenService:Create(a,TweenInfo.new(0.75,Enum.EasingStyle.Linear),{TextTransparency = 0}):Play()
				else
					TweenService:Create(a,TweenInfo.new(0.75,Enum.EasingStyle.Linear),{ImageTransparency = 0.95}):Play()
				end
			end
			wait(0.5)
			AddLBTweenConnection(TweenService:Create(NewLBFrame.MainFrame,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true),{BackgroundTransparency = 0.5}),(i-1)*0.1)
			if i == #GolbalData then
				GolbalLoaded = true
			end
		end)
	end
	if #GolbalData == 0 then
		LeaderboardInterface.NoRecord.Visible = true
	end

	spawn(function()
		TweenService:Create(Leaderboard.Parent.PersonalBestTitle,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextTransparency = 0}):Play()
		local Data = PersonalData
		if tonumber(Data.Score) ~= nil then
			local PlayersFitScreen = math.floor(Leaderboard.AbsoluteSize.Y/40)+1
			local WaitTime = (#GolbalData >= PlayersFitScreen and PlayersFitScreen*0.1) or (#GolbalData)*0.1
			wait(WaitTime)
			--[[ 
				Data.ExtraData.Mod = {
					FL = <Fl>
				}
			]]
			local NewLBFrame = script.Leaderboard.LeaderboardFrame:Clone()
			NewLBFrame.Parent = LeaderboardInterface.PersonalBest
			NewLBFrame.Name = "PlayerPB"
			NewLBFrame.ZIndex = tonumber(Data.Rank)
			NewLBFrame.MainFrame.PlayerName.Text = game.Players.LocalPlayer.Name
			local MaxComboText = ""
			if Data.ExtraData ~= nil then
				MaxComboText = " (x"..tostring(Data.ExtraData.MaxCombo)..")"
				NewLBFrame.MainFrame.Accurancy.Text = tostring(Data.ExtraData.Accurancy).."%"
				NewLBFrame.MainFrame.PlayDate.Text = GetDate(Data.ExtraData.Date).." | "..GetModData(Data.ExtraData.Mod)..tostring(Data.ExtraData.Speed).."x"
				NewLBFrame.MainFrame.Grade.Text = Data.ExtraData.Grade
				if Data.ExtraData.Grade == "SS" then
					NewLBFrame.MainFrame.Grade.Text = "S"
					NewLBFrame.MainFrame.Grade_SS.Visible = true
				end
				NewLBFrame.MainFrame.Grade.TextColor3 = RankColor[Data.ExtraData.Grade]
				local PSEarned = Data.ExtraData.PS
				if PSEarned ~= nil then
					NewLBFrame.MainFrame.PSEarned.Text = tostring(math.floor(PSEarned)).."ps"
				else
					NewLBFrame.MainFrame.PSEarned.Text = "-"
				end
			else
				NewLBFrame.MainFrame.Accurancy.Text = "-"
				NewLBFrame.MainFrame.PlayDate.Text = "-"
				NewLBFrame.MainFrame.PSEarned.Text = "-"
			end

			NewLBFrame.MainFrame.Score.Text = "Score: "..GetScore(Data.Score)..MaxComboText
			ProcessFunction(function()
				repeat wait() until GolbalLoaded
				if PersonalRank ~= "-" then
					NewLBFrame.MainFrame.Rank.Text = "#"..tostring(PersonalRank)
				else
					local TopPercent = 1+math.floor((99-(tonumber(Data.Score)/Top100Score)*99)+0.5)
					NewLBFrame.MainFrame.Rank.Text = "Top "..tostring(TopPercent).."%"
				end
			end)
			NewLBFrame.MainFrame.PlayerImage.Image = Data.ThumbnailId
			AddLeaderboardConnection(NewLBFrame,Data.ExtraData)
			TweenService:Create(NewLBFrame.MainFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart),{Position = UDim2.new(0,0,0,0)}):Play()
			wait(0.5)
			for _,a in pairs(NewLBFrame.MainFrame:GetChildren()) do
				if a:IsA("TextLabel") then
					TweenService:Create(a,TweenInfo.new(0.75,Enum.EasingStyle.Linear),{TextTransparency = 0}):Play()
				else
					TweenService:Create(a,TweenInfo.new(0.75,Enum.EasingStyle.Linear),{ImageTransparency = 0.95}):Play()
				end
			end
			wait(0.5)
			AddLBTweenConnection(TweenService:Create(NewLBFrame.MainFrame,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true),{BackgroundTransparency = 0.5}),WaitTime)
		else
			LeaderboardInterface.PersonalBest.NoRecord.Visible = true
		end
	end)
end




--Overview 

PreviewBeatmapset = 0
BeatmapSetId = 0
BeatmapId = 0
BeatmapPreviewSession = ""

function ReloadPreviewFrame()
	local PreviewFrame = CurrentPreviewFrame
	local Settings = CurrentSetting.MainSettings
	local CurrentBeatmap = Settings.BeatmapFile.Text
	local CurrentFileType = FileType
	local CurrentSongDelay = Settings.Parent.VirtualSettings.InstantSettings.Offset.Value
	local SongSpeed = tonumber(Settings.Speed.Text)
	local CurrentPreviewSession = game.HttpService:GenerateGUID()
	BeatmapPreviewSession = CurrentPreviewSession


	if SongSpeed == nil or SongSpeed < 0.1 or SongSpeed > 5 or tostring(SongSpeed) == "nan" or tostring(SongSpeed) == "inf" or tostring(SongSpeed) == "-nan" or tostring(SongSpeed) == "-nan(ind)"  then
		SongSpeed = 1
	end

	CurrentModData.Speed = SongSpeed
	LoadMultiplier()


	if CurrentSongDelay == nil or math.abs(CurrentSongDelay) > 5000 then
		CurrentSongDelay = 0
	end

	if CurrentBeatmap == nil or CurrentBeatmap == "" or FileType == 1 then
		CurrentBeatmap = BeatmapStudio
		CurrentFileType = 1
	end


	local BeatmapData,ReturnData,TimmingPoints,ComboColors = require(workspace.OsuConvert)(CurrentFileType,CurrentBeatmap,SongSpeed,CurrentSongDelay,false,true)

	script.Parent.Parent.BG.StartButtonBeatAnimation.BPMAnimation.Event:Fire(TimmingPoints,SongSpeed)

	if ReturnData.Overview.Metadata ~= nil then
		PreviewFrame.Overview.MapName.Text = "Map: "..ReturnData.Overview.Metadata.SongCreator.." - "..ReturnData.Overview.Metadata.MapName
		PreviewFrame.Overview.DifficultyName.Text = "["..ReturnData.Overview.Metadata.DifficultyName.."] // "..ReturnData.Overview.Metadata.BeatmapCreator
	else
		PreviewFrame.Overview.MapName.Text = "Map: "
		PreviewFrame.Overview.DifficultyName.Text = "[]"
	end

	local function ReturnTime(Length)
		Length = math.floor(tonumber(Length)/1000)
		local Mins = tostring(math.floor(Length/60))
		local Secs = tostring(math.floor(Length-(math.floor(Length/60)*60)))

		if #Secs == 1 then
			Secs = "0"..Secs
		end

		return Mins..":"..Secs

	end

	local SpeedDisplay = ""

	if SongSpeed ~= 1 then
		SpeedDisplay = "(x"..tostring(math.floor(SongSpeed*100)/100)..")"
	end

	local ExtraARRate = ""
	if SongSpeed ~= 1 then
		local CurrentAR = ReturnData.Difficulty.ApproachRate
		local ARTime = 1200
		if CurrentAR < 5 then
			ARTime = 1200 + 600 * (5 - CurrentAR) / 5
		elseif CurrentAR > 5 then
			ARTime = 1200 - 750 * (CurrentAR - 5) / 5
		else
			ARTime = 1200
		end
		ARTime /= SongSpeed

		local NewAR = CurrentAR

		if ARTime == 1200 then
			NewAR = 5
		elseif ARTime > 1200 then
			NewAR = 5 - (ARTime-1200)/120
		elseif ARTime < 1200 then
			NewAR = (1200-ARTime)/150 + 5
		end

		NewAR = math.floor(NewAR*100)/100
		ExtraARRate = "("..tostring(NewAR)..")"
	end

	if ReturnData.Difficulty ~= nil then
		PreviewFrame.Overview.DifficultyInfo.Text = "Lengh - "..ReturnTime(ReturnData.Overview.MapLength)..SpeedDisplay.." CS: "..ReturnData.Difficulty.CircleSize.." OD: "..ReturnData.Difficulty.OverallDifficulty.." HP: "..ReturnData.Difficulty.HPDrainRate.." AR: "..ReturnData.Difficulty.ApproachRate..ExtraARRate
		PreviewFrame.Overview.BeatmapDifficulty.Text = "Star rating: "..tostring(ReturnData.Difficulty.BeatmapDifficulty)
	else
		PreviewFrame.Overview.DifficultyInfo.Text = "Lengh - "..ReturnTime(ReturnData.Overview.MapLength).." CS: ? OD: ? HP:? AR: ?"
		PreviewFrame.Overview.BeatmapDifficulty.Text = "Star rating: 0"
	end

	-- Difficulty strike
	for i = 1,5 do
		wait()
	end

	local DifficultyStrike = ReturnData.Difficulty.DifficultyStrike
	local HighestDiffTime = DifficultyStrike.Highest
	local DiffTimeList = DifficultyStrike.List

	local DiffDisplay = PreviewFrame.DifficultyDisplay.MainFrame

	--DiffDisplay:ClearAllChildren()
	if not DiffDisplay:FindFirstChild("DifficultyStrikeListLayout") then
		script.UILayout.DifficultyStrikeListLayout:Clone().Parent = DiffDisplay
	end
	local List = DiffDisplay:GetChildren()
	local TotalList = #List
	for i,a in pairs(List) do
		if a:IsA("UIListLayout") then
			table.remove(List,i)
		end
	end
	local SpaceUsed = 0

	for i,Diff in pairs(DiffTimeList) do
		local DiffFrame = Instance.new("Frame",DiffDisplay)
		local FrameSize = UDim2.new(1/#DiffTimeList,0,Diff/HighestDiffTime,0)
		SpaceUsed += 1/#DiffTimeList
		local UsedOldFrame = false
		if #List <= 0 then
			DiffFrame.Size = UDim2.new(0,0,0,0)
			DiffFrame.ZIndex = i
			DiffFrame.BorderSizePixel = 0
			DiffFrame.BackgroundTransparency = 1
			--TweenService:Create(DiffFrame,TweenInfo.new(0.1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(1/#DiffTimeList,0,0,0)}):Play()
		else
			UsedOldFrame = true
			DiffFrame:Destroy()
			DiffFrame = List[1]
			table.remove(List,1)
		end

		DiffFrame.LayoutOrder = i
		DiffFrame.BorderSizePixel = 0
		local DifficultyColor = Diff/60
		DifficultyColor = (195 - (DifficultyColor*195))/360
		--195
		--print(Color3.fromHSV(0.666667, 1, 1))

		-- Soul crusing difficulty, like in jtoh lol
		local SatColor = 180 

		if Diff > 60 and Diff <= 90 then
			DifficultyColor = ((Diff-60) / 30)*120
			DifficultyColor = (360-DifficultyColor)/360
			SatColor = 180 + ((Diff-60) / 30)*75
		elseif Diff > 90 and Diff < 110 then
			DifficultyColor = 2/3
			local Color = (Diff-90)/20
			SatColor = (1-Color)*255
		elseif Diff >= 110 then
			SatColor = 0
		end



		if DifficultyColor < 0 then DifficultyColor = 0 end
		if not UsedOldFrame then
			DiffFrame.BackgroundColor3 = Color3.fromHSV(DifficultyColor,SatColor/255,1)
		else
			TweenService:Create(DiffFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{BackgroundColor3 = Color3.fromHSV(DifficultyColor,SatColor/255,1)}):Play()
		end

		spawn(function()
			--local WaitTime = ((i-(1))/#DiffTimeList) * 0.5
			--wait(0.25)
			TweenService:Create(DiffFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = FrameSize,BackgroundTransparency = 0}):Play()
		end)
	end
	--[[
	spawn(function()
		local DiffFrame = Instance.new("Frame",DiffDisplay)
		local FrameSize = UDim2.new(1-SpaceUsed,0,0,0)
		TweenService:Create(DiffFrame,TweenInfo.new(0,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = FrameSize,BackgroundTransparency = 1}):Play()
	end)]]
	spawn(function()
		for _,a in pairs(List) do
			spawn(function()
				TweenService:Create(a,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(0,0,0,0)}):Play()
			end)
		end
		wait(0.1)
		for _,a in pairs(List) do
			a:Destroy()
		end
	end)

	local TotalNotes = #BeatmapData
	local Notes = 0
	local Sliders = 0
	local Spinners = 0
	local AvgNPS = math.floor(TotalNotes/(tonumber(ReturnData.Overview.MapLength)/1000))
	local HighestNote1sec = 0

	local function GetNotes1SecInCurrentTime(Time,Pos)
		local NotesIn1Sec = 1
		for i = Pos+1,#BeatmapData do
			if BeatmapData[i].Time > Time+1000 then
				break
			else
				NotesIn1Sec += 1
			end
		end
		return NotesIn1Sec
	end

	for i,data in pairs(BeatmapData) do
		local Type = data.Type
		if Type ~= 1 and Type ~= 2 and Type ~= 8 then
			if Type <= 12 then
				if Type == 5 then Type = 1
				elseif Type == 6 then Type = 2
				elseif Type == 12 then Type = 8
				end
			else
				for i = 1,8 do
					if Type == 21 + 16*(i-1) then
						Type = 1
						break
					elseif Type == 22 + 16*(i-1) then
						Type = 2
						break
					elseif Type == 28 + 16*(i-1) then
						Type = 8
						break
					end
				end
			end
		end

		if Type == 2 then
			Sliders += 1
		elseif Type == 8  then
			Spinners += 1
		else
			Notes += 1
		end


		local NotesIn1Sec = GetNotes1SecInCurrentTime(data.Time,i)
		if NotesIn1Sec > HighestNote1sec then
			HighestNote1sec = NotesIn1Sec 
		end
	end

	PreviewFrame.Overview.BeatmapInfo.Text = "Total:"..tostring(TotalNotes).." Note:"..tostring(Notes).." Slider:"..tostring(Sliders).." Spinner:"..tostring(Spinners)
	PreviewFrame.Overview.NotespeedAvg.Text = "NPS: "..AvgNPS.."/s Avg | "..HighestNote1sec.."/s Max"


	CurrentKey = ReturnData.BeatmapSetsData.BeatmapsetID.."-"..ReturnData.BeatmapSetsData.BeatmapID
	BeatmapKey = ReturnData.BeatmapSetsData.BeatmapID

	spawn(function()
		if ReturnData.MapSongId ~= nil and (PreviewFrame.OverviewSong.SoundId ~= "rbxassetid://"..tostring(ReturnData.MapSongId) or PreviewFrame.OverviewSong.Playing == false or PreviewBeatmapset ~= ReturnData.BeatmapSetsData.BeatmapsetID) then
			PreviewFrame.OverviewSong.SoundId = "rbxassetid://"..tostring(ReturnData.MapSongId)
			repeat wait() until PreviewFrame.OverviewSong.IsLoaded == true
			local PreviewTime = (ReturnData.Overview.OverviewStartTime/1000)
			if PreviewTime < 0 then PreviewTime = 0 end

			PreviewFrame.OverviewSong.StartTime.Value = PreviewTime
			if game.Players.LocalPlayer.PlayerScripts.DataValue.FirstJoinMusic.Value == true then
				game.Players.LocalPlayer.PlayerScripts.DataValue.FirstJoinMusic.Value = false
				PreviewTime = 0
			end
			PreviewFrame.OverviewSong.TimePosition = PreviewTime
			local PrevMapTime = CurrentSetting.VirtualSettings.PrevMapTime
			if PrevMapTime.Value >= 10 and PrevMapTime.Value < ReturnData.Overview.MapLength/1000 then
				PreviewFrame.OverviewSong.TimePosition = PrevMapTime.Value
				--PreviewFrame.OverviewSong.StartTime.Value = PrevMapTime.Value
				PrevMapTime.Value = -1
			end
			PreviewFrame.OverviewSong.Volume = 0
			PreviewFrameBaseVolume = ReturnData.BeatmapVolume
			PreviewFrame.OverviewSong.PlaybackSpeed = ReturnData.SongSpeed
			PreviewFrame.OverviewSong.DefaultPitch.Octave = ReturnData.SongPitch
			TweenService:Create(PreviewFrame.OverviewSong,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Volume = PreviewFrameBaseVolume*(SongVolume*0.02)}):Play()
			PreviewFrame.OverviewSong.Playing = true
		end
		PreviewBeatmapset = ReturnData.BeatmapSetsData.BeatmapsetID
	end)

	wait()

	-- BackgroundChange

	for i = 1,10 do
		wait()
	end

	repeat until wait() <= 1/30
	local Background = game.Players.LocalPlayer.PlayerGui.BG.Background.Background

	ReturnData.ImageId = tostring(ReturnData.ImageId)


	for _,Obj in pairs(Background:GetChildren()) do 
		if Obj:IsA("ImageLabel") then
			Obj.ZIndex = 999
			TweenService:Create(Obj,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{ImageTransparency = 1,BackgroundTransparency = 1}):Play()
			spawn(function()
				wait(0.5)
				Obj:Destroy()
			end)
		end
	end


	if ReturnData.ImageId ~= "0" then
		local TweenTime = 0.5
		if #Background:GetChildren() >= 1 then
			TweenTime = 0
		end
		local NewBackground = script.BackgroundImage:Clone()
		NewBackground.Parent = Background
		NewBackground.Image = "http://www.roblox.com/asset/?id="..ReturnData.ImageId
		TweenService:Create(NewBackground,TweenInfo.new(TweenTime,Enum.EasingStyle.Linear),{ImageTransparency = 0,BackgroundTransparency = 0}):Play()
	end


	-- BeatmapChooseBackground
	local Background = game.Players.LocalPlayer.PlayerGui.BeatmapChoose.BG.Background.Background

	for _,Obj in pairs(Background:GetChildren()) do 
		if Obj:IsA("ImageLabel") then
			Obj.ZIndex = 999
			TweenService:Create(Obj,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{ImageTransparency = 1,BackgroundTransparency = 1}):Play()
			spawn(function()
				wait(0.25)
				Obj:Destroy()
			end)
		end
	end

	if ReturnData.ImageId ~= "0" then
		local TweenTime = 0.5
		if #Background:GetChildren() >= 1 then
			TweenTime = 0
		end
		local NewBackground = script.BackgroundImage:Clone()
		NewBackground.Parent = Background
		NewBackground.Image = "http://www.roblox.com/asset/?id="..ReturnData.ImageId
		TweenService:Create(NewBackground,TweenInfo.new(TweenTime,Enum.EasingStyle.Linear),{ImageTransparency = 0,BackgroundTransparency = 0}):Play()
	end

end

wait()
if not script.Parent:FindFirstChild("_FastRestart") then
	spawn(function()
		ReloadPreviewFrame()
		LoadLeaderboard()	
	end)
else
	spawn(function()
		local MapData = require(BeatmapStudio)

		local _,firstb = string.find(MapData,"BeatmapID:")
		local _,firstbset =  string.find(MapData,"BeatmapSetID:")
		local lastb,_ = string.find(MapData,"\n",firstb)
		local lastbset,_ = string.find(MapData,"\n",firstbset)
		local mapid = string.sub(MapData,firstb+1,lastb-1)
		local setid = string.sub(MapData,firstbset+1,lastbset-1)

		CurrentKey = setid.."-"..mapid
		BeatmapKey = mapid

		LoadLeaderboard()
	end)
end

-- Developer UI, DO NOT TRY TO ACCESS THIS

if game.Players.LocalPlayer.UserId == 1241445502 or game.Players.LocalPlayer.UserId == 612857722 then
	local DeveloperUI = game.Players.LocalPlayer.PlayerGui.DeveloperUI
	local CurrentUsername = ""
	local Processing = false
	for _,CloseButton in pairs(DeveloperUI.MainUI.CloseFrame:GetChildren()) do
		CloseButton.MouseButton1Click:Connect(function()
			DeveloperUI.MainUI.Visible = false
		end)
		CloseButton.MouseButton2Click:Connect(function()
			DeveloperUI.MainUI.Visible = false
		end)
	end

	local Leaderboard = game.Players.LocalPlayer.PlayerGui.BG.BeatmapLeaderboard.GolbalLeaderboard

	Leaderboard.ChildAdded:Connect(function(lbframe)
		if lbframe:IsA("UIListLayout") then return end

		lbframe.DevButton.MouseButton2Click:Connect(function()
			local MouseLocation = game:GetService("UserInputService"):GetMouseLocation()
			local ScreenSize = script.Parent.AbsoluteSize
			local MouseLocationUdim = MouseLocation/ScreenSize

			DeveloperUI.MainUI.Position = UDim2.new(MouseLocationUdim.X,0,MouseLocationUdim.Y,0)
			DeveloperUI.MainUI.Visible = true
			DeveloperUI.MainUI.UI.Username.Text = lbframe.MainFrame.PlayerName.Text
			CurrentUsername = lbframe.MainFrame.PlayerName.Text
		end)
	end)
	function DevAction(Action)
		if Processing == true or CurrentUsername == "" then return end
		Processing = true
		local issuccess = game.ReplicatedStorage.DevAction:InvokeServer(Action,{Name = CurrentUsername,Key = CurrentKey})
		Processing = false
		spawn(LoadLeaderboard)
	end

	DeveloperUI.MainUI.UI.RemoveScore.MouseButton1Click:Connect(function()
		DeveloperUI.MainUI.UI.RemoveScore.Text = "..."
		DevAction(1)
		DeveloperUI.MainUI.UI.RemoveScore.Text = "Remove this score"
		DeveloperUI.MainUI.Visible = false
	end)
	DeveloperUI.MainUI.UI.UnrankPlr.MouseButton1Click:Connect(function()
		DeveloperUI.MainUI.UI.UnrankPlr.Text = "..."
		DevAction(2)
		DeveloperUI.MainUI.UI.UnrankPlr.Text = "Remove score + unrank player"
		DeveloperUI.MainUI.Visible = false
	end)
end

---------------------------

--CurrentSetting.MainSettings.Speed
local CurrentSpeedText = CurrentSetting.MainSettings.Speed.Text
CurrentSetting.MainSettings.Speed.FocusLost:Connect(function()
	if CurrentSpeedText ~= CurrentSetting.MainSettings.Speed.Text then
		CurrentSpeedText = CurrentSetting.MainSettings.Speed.Text
		ReloadPreviewFrame()
	end
end)



CurrentPreviewFrame.PreviewButton.MouseButton1Click:Connect(ReloadPreviewFrame)

local BeatmapChooseButton = game.Players.LocalPlayer.PlayerGui.BG.BeatmapChooseButton
local BeatmapChooseUI = game.Players.LocalPlayer.PlayerGui.BeatmapChoose
local BeatmapChooseTweening = false
local BeatmapChooseCloseButton = game.Players.LocalPlayer.PlayerGui.BeatmapChoose.CloseUI
local BeatmapchooseOpened = false
local TweenStarted = false
local ArtistSortType = true
local BeatmapCurrentDiffChoose = 0
local BeatmapCurrentChoose = 0
local SearchBar = BeatmapChooseUI.BG.SearchFrame.SearchBar

spawn(function()
	local UIListLayout = BeatmapChooseUI.BG.BeatmapList:WaitForChild("UIListLayout",math.huge)
	local SortTypeButton = BeatmapChooseUI.BG.SortType.SortType
	if UIListLayout.SortOrder == Enum.SortOrder.LayoutOrder then
		ArtistSortType = false
	end
	SortTypeButton.MouseButton1Click:Connect(function()
		ArtistSortType = not ArtistSortType
		if ArtistSortType == true then
			SortTypeButton.Text = "Sort type: Name"
			--UIListLayout.SortOrder = Enum.SortOrder.Name
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			if SearchBar.Text == "" then
				script.Parent.SwitchBeatmap:Fire()
				for i = 1,10 do wait() end
				TweenService:Create(BeatmapChooseUI.BG.BeatmapList,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{CanvasPosition = Vector2.new(0,(BeatmapCurrentChoose*60-(BeatmapChooseUI.BG.BeatmapList.AbsoluteWindowSize.Y*0.5)+30))}):Play()
			end
		else
			SortTypeButton.Text = "Sort type: Difficulty"
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			if SearchBar.Text == "" then
				script.Parent.SwitchBeatmap:Fire()
				for i = 1,10 do wait() end
				TweenService:Create(BeatmapChooseUI.BG.BeatmapList,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{CanvasPosition = Vector2.new(0,(BeatmapCurrentDiffChoose*60-(BeatmapChooseUI.BG.BeatmapList.AbsoluteWindowSize.Y*0.5)+30))}):Play()
			end
		end
	end)
end)

local BeatmapSorting = {}
local SortResult = {}
local BeatmapDiffSorting = {}
local DiffSortResult = {}

function SortBeatmap()
	table.sort(BeatmapSorting,function(firstvalue,secondvalue)
		local StringTitle1 = firstvalue[2]
		local StringTitle2 = secondvalue[2]
		local BeatmapId1 = tonumber(firstvalue[3])
		local BeatmapId2 = tonumber(secondvalue[3])

		for i = 1,50 do
			local _1 = string.sub(StringTitle1,i,i)
			local _2 = string.sub(StringTitle2,i,i)
			if _1 == "" and _2 == "" then
				break
			elseif _2 == "" then
				return true
			elseif _1 == "" then
				return false
			end
			if string.byte(_1) < string.byte(_2) then
				return true
			elseif string.byte(_1) > string.byte(_2) then
				return false
			end
		end
		return BeatmapId1 < BeatmapId2
	end)
	table.sort(BeatmapDiffSorting,function(firstvalue,secondvalue)
		return firstvalue[2] < secondvalue[2]
	end)
	for i,data in pairs(BeatmapSorting) do
		SortResult[data[1]] = i
	end
	for i,data in pairs(BeatmapDiffSorting) do
		DiffSortResult[data[1]] = i
	end
	BeatmapSorting = {}
	BeatmapDiffSorting = {}
end

function ToggleBeatmap(isBeatmapchooseOpen)
	if BeatmapChooseTweening == true then return end
	if script.Parent.Enabled == false and isBeatmapchooseOpen == true then return end
	BeatmapChooseTweening = true
	BeatmapchooseOpened = isBeatmapchooseOpen
	--BeatmapChooseUI.Enabled = isBeatmapchooseOpen
	--script.Parent.Enabled = not isBeatmapchooseOpen

	BeatmapChooseUI.CloseUI.Visible = isBeatmapchooseOpen
	BeatmapChooseUI.GameTitle.Visible = isBeatmapchooseOpen


	local AnimateInfo = {
		["true"] = {TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(0,0)}},
		["false"] = {TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{AnchorPoint = Vector2.new(0,1)}}
	}
	TweenService:Create(BeatmapChooseUI.BG,AnimateInfo[tostring(isBeatmapchooseOpen)][1],AnimateInfo[tostring(isBeatmapchooseOpen)][2]):Play()


	if isBeatmapchooseOpen == true then
		local BeatmapListUI = BeatmapChooseUI.BG.BeatmapList
		CurrentPreviewFrame.Parent = BeatmapChooseUI.BG.OverviewFrame
		local LoadedSongs = 0

		local ConvertBeatmap = require(workspace.OsuConvert)
		if BeatmapChooseUI.BG:FindFirstChild("FirstLoad") then
			BeatmapChooseUI.BG.FirstLoad:Destroy()
			BeatmapListUI:ClearAllChildren()
			local UIListLayout = script.BeatmapChooseUI.UI.UIListLayout:Clone()
			UIListLayout.Parent = BeatmapListUI
			BeatmapChooseUI.BG.LoadStatus.Text = "Loading... (0%)"

			for beatmapid,Beatmap in pairs(BeatmapsList:GetChildren()) do
				spawn(function()
					--local _,returndata = ConvertBeatmap(1,Beatmap,1,0,false,false,true)
					--local _,returndata = game.ReplicatedStorage.ServerGetBeatmapInfo:InvokeServer(1,Beatmap,1,0,false,false,true)
					--[[local _,returndata = osuLocalConvert(1,Beatmap,1,0,false,false,true)
					local metadata = returndata.Overview.Metadata]]
					local BeatmapSortKey = game.HttpService:GenerateGUID(false)
					local newBeatmapFrame = script.BeatmapChooseUI.BeatmapFrame:Clone()
					local BeatmapDifficulty = 0
					local metadata = {DifficultyName = "",MapName = "",SongCreator = "",BeatmapCreator = "",Tags = "",MapId = 0}

					local MapData = require(Beatmap)

					-- Get metadata info
					local ReadList = {
						{"MapName","Title:"},
						{"SongCreator","Artist:"},
						{"BeatmapCreator","Creator:"},
						{"DifficultyName","Version:"},
						{"Tags","Tags:"},
						{"MapId","BeatmapID:"}
					}

					for i,Data in pairs(ReadList) do
						local _,_1 = string.find(MapData,Data[2])
						local _2 = string.find(MapData,"\n",_1)

						local Value = string.sub(MapData,_1+1,_2-1)
						metadata[Data[1]] = Value
					end

					if Beatmap:FindFirstChild("Difficulty") then
						BeatmapDifficulty = Beatmap.Difficulty.Value
					end
					newBeatmapFrame.Parent = BeatmapListUI
					newBeatmapFrame.Name = Beatmap.Name
					newBeatmapFrame.Frame.BeatmapID.Value = beatmapid
					newBeatmapFrame.Frame.DiffName.Text = "["..tostring(BeatmapDifficulty).."]["..metadata.DifficultyName.."] // "..metadata.BeatmapCreator
					newBeatmapFrame.Frame.Title.Text = metadata.SongCreator.." - "..metadata.MapName
					newBeatmapFrame.MapName.Value = metadata.MapName
					newBeatmapFrame.MapArtist.Value = metadata.SongCreator
					newBeatmapFrame.MapCreator.Value = metadata.BeatmapCreator
					newBeatmapFrame.MapDifficultyName.Value = metadata.DifficultyName
					newBeatmapFrame.MapTags.Value = metadata.Tags
					if Beatmap:FindFirstChild("Difficulty") then
						newBeatmapFrame.Frame.Difficulty.Value = Beatmap.Difficulty.Value
						newBeatmapFrame.LayoutOrder = Beatmap.Difficulty.Value*100
					end
					BeatmapListUI.CanvasSize = UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y)
					LoadedSongs += 1
					BeatmapChooseUI.BG.LoadStatus.Text = "Loading... ("..tostring(math.floor((LoadedSongs/#BeatmapsList:GetChildren())*100)).."%)"
					--print("Time left: "..tostring(math.floor(((#BeatmapsList:GetChildren() - LoadedSongs))*0.05775)))
					BeatmapSorting[#BeatmapSorting+1] = {BeatmapSortKey,metadata.MapName,metadata.MapId}
					BeatmapDiffSorting[#BeatmapDiffSorting+1] = {BeatmapSortKey,BeatmapDifficulty}
					spawn(function()
						BeatmapChooseUI.BG.BeatmapList:WaitForChild("-- All beatmap loaded --",math.huge)
						local waittime = 0
						local function Compare(Name,Pos)
							local BeatmapFrameName = Beatmap.Name
							if #Name < Pos and  #BeatmapFrameName >= Pos then
								return 1,true
							elseif #Name >= Pos and  #BeatmapFrameName < Pos then
								return 2,true
							elseif #Name < Pos and  #BeatmapFrameName < Pos then
								return 0,true
							else
								if string.byte(Name,Pos,Pos) < string.byte(BeatmapFrameName,Pos,Pos) then
									return 1,true
								elseif string.byte(Name,Pos,Pos) == string.byte(BeatmapFrameName,Pos,Pos) then
									return 0,false
								else
									return 2,true 
								end 
							end
						end
						--[[for i,BeatmapFrame in pairs(BeatmapListUI:GetChildren()) do
							if BeatmapFrame:IsA("Frame") and BeatmapFrame ~= newBeatmapFrame then
								local islower = 0
								-- 1 = opposite lower, 2 current lower
								for i = 1,100 do -- max 100 text
									local Desision,isBreak = Compare(BeatmapFrame.Name,i)
									islower = Desision
									if isBreak == true then
										break
									end
								end
								if islower == 1 then
									waittime += 0.025
									newBeatmapFrame.LayoutOrderId.Value += 1
								elseif islower == 0 then
									if BeatmapFrame.Frame.BeatmapID.Value < beatmapid then
										waittime += 0.025
										newBeatmapFrame.LayoutOrderId.Value += 1
									end
								end
								local Difficulty = newBeatmapFrame.Frame.Difficulty.Value
								local OppositeDifficulty = BeatmapFrame.Frame.Difficulty.Value

								if Difficulty > OppositeDifficulty or (Difficulty==OppositeDifficulty and BeatmapFrame.Frame.BeatmapID.Value < beatmapid) then
									newBeatmapFrame.DifficultyLayoutOrderId.Value += 1
								end
							end
						end]]
						--[[
						spawn(function()
							if IngamebeatmapID.Value == beatmapid then
								BeatmapChooseUI.BG.BeatmapList:WaitForChild("-- All beatmap loaded --",math.huge)
								TweenService:Create(BeatmapListUI,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{CanvasPosition = Vector2.new(0,(waittime/0.05*60-(BeatmapListUI.AbsoluteWindowSize.Y*0.5)+30))}):Play()
							end
						end)]]
						if waittime > 2 then
							waittime = 2
						end
						--[[
						if #BeatmapsList:GetChildren() <= 400 then
							wait(waittime) -- limit of wait
						end]]
						--TweenService:Create(newBeatmapFrame.Frame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0,0,0,0)}):Play()
						ProcessFunction(function()
							--wait(0.25)
							BeatmapChooseUI.BG.BeatmapList:WaitForChild("-- All beatmap loaded --",math.huge)
							newBeatmapFrame.LayoutOrderId.Value = SortResult[BeatmapSortKey]
							newBeatmapFrame.DifficultyLayoutOrderId.Value = DiffSortResult[BeatmapSortKey]
							SortResult[BeatmapSortKey] = nil
							DiffSortResult[BeatmapSortKey] = nil
							Instance.new("BoolValue",newBeatmapFrame).Name = "TweenDone"
						end)
					end)
					if beatmapid == #BeatmapsList:GetChildren() then
						SortBeatmap()
						BeatmapChooseUI.BG.LoadStatus.Text = "Loaded!"
						TweenService:Create(BeatmapChooseUI.BG.LoadStatus,TweenInfo.new(1,Enum.EasingStyle.Linear),{TextTransparency = 1}):Play()
						--BeatmapChooseUI.BG.LoadStatus.Visible = false
						BeatmapChooseUI.BG.BeatmapList.ScrollingEnabled = true
						wait()
						Instance.new("BoolValue",BeatmapListUI).Name = "-- All beatmap loaded --"
						wait(0.5)
					end
				end)
			end
			BeatmapChooseUI.BG.BeatmapList:WaitForChild("-- All beatmap loaded --",math.huge)
			local TotalWaitTime = (#BeatmapListUI:GetChildren() <= 72 and (#BeatmapListUI:GetChildren()-2)*0.025+0.25) or 2
			wait(TotalWaitTime)
		else
			for _,BeatmapFrame in pairs(BeatmapChooseUI.BG.BeatmapList:GetChildren()) do
				ProcessFunction(function()
					if BeatmapFrame:IsA("Frame") then
						Instance.new("BoolValue",BeatmapFrame).Name = "TweenDone"
					end
				end)
			end
			Instance.new("BoolValue",BeatmapListUI).Name = "-- All beatmap loaded --"
		end
	else
		spawn(LoadLeaderboard)
		CurrentPreviewFrame.Parent = game.Players.LocalPlayer.PlayerGui.BG.PreviewFrame
		for _,BeatmapFrame in pairs(BeatmapChooseUI.BG.BeatmapList:GetChildren()) do
			if BeatmapFrame:IsA("Frame") then
				BeatmapFrame:WaitForChild("TweenDone"):Destroy()
				spawn(function()
					wait(0.5)
					BeatmapFrame.Frame.Position = UDim2.new(1,0,0,0)
				end)
			end
		end
		BeatmapChooseUI.BG.BeatmapList["-- All beatmap loaded --"]:Destroy()
		TweenStarted = false
		wait(0.5)
	end
	BeatmapChooseTweening = false
end

LoadedFrame = 0
TotalFrameLoad = 0
local LoadStatus2 = BeatmapChooseUI.BG.LoadStatus2
local BeatmapChooseConnections = {}

spawn(function()
	while wait() do
		if TweenStarted == false then
			TweenStarted = true
			BeatmapChooseUI.BG.BeatmapList:WaitForChild("-- All beatmap loaded --",math.huge)
			TotalFrameLoad = 0
			LoadedFrame = 0
			LoadStatus2.Visible = true
			for _,connection in pairs(BeatmapChooseConnections) do
				if connection then
					connection:Disconnect()
				end
			end
			BeatmapChooseConnections = {}
			for _,BeatmapFrame in pairs(BeatmapChooseUI.BG.BeatmapList:GetChildren()) do
				if BeatmapFrame:IsA("Frame") and BeatmapFrame:FindFirstChild("Frame") and BeatmapFrame.Frame:FindFirstChild("BeatmapID") then
					TotalFrameLoad += 1
					LoadStatus2.Text = "Loading list... ("..tostring(LoadedFrame).."/"..tostring(TotalFrameLoad)..")"
					local LoadedFirst = false
					local Choosen = false
					ProcessFunction(function()
						BeatmapFrame:WaitForChild("TweenDone",math.huge)
						local CurrentChoose = "no"
						local ScrollBeatmapFrame = BeatmapFrame.Parent
						ScrollBeatmapFrame.Changed:Connect(function()
							local BeatmapFramePosition = BeatmapFrame.AbsolutePosition
							local ScreenSize = workspace.CurrentCamera.ViewportSize

							BeatmapFrame.Frame.Visible = math.abs(BeatmapFramePosition.Y-ScreenSize.Y/2) <= ScreenSize.Y*1.5
						end)
						while true do
							LoadedFrame += 1
							LoadStatus2.Text = "Loading list... ("..tostring(LoadedFrame).."/"..tostring(TotalFrameLoad)..")"
							if LoadedFrame >= TotalFrameLoad and LoadedFrame ~= 0 then
								LoadStatus2.Visible = false
							end
							if BeatmapFrame:FindFirstChild("TweenDone") == nil then break end
							Choosen = IngamebeatmapID.Value == BeatmapFrame.Frame.BeatmapID.Value
							BeatmapFrame.Frame.SelectButton.AutoButtonColor = not Choosen
							local OrderId = BeatmapFrame.LayoutOrderId.Value
							if ArtistSortType == false then
								OrderId = BeatmapFrame.DifficultyLayoutOrderId.Value
							end
							BeatmapFrame.LayoutOrder = OrderId
							if CurrentChoose ~= Choosen then
								if Choosen == true then
									BeatmapCurrentChoose = BeatmapFrame.LayoutOrderId.Value
									BeatmapCurrentDiffChoose = BeatmapFrame.DifficultyLayoutOrderId.Value
								end
								if CurrentChoose == "no" then
									CurrentChoose = Choosen
									if Choosen == false then
										wait(0.25+OrderId*0.001)
										TweenService:Create(BeatmapFrame.Frame.DiffName,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextStrokeTransparency = 1}):Play()
										TweenService:Create(BeatmapFrame.Frame.Title,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextStrokeTransparency = 1}):Play()
										TweenService:Create(BeatmapFrame.Frame.SelectButton,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{BackgroundColor3 = Color3.fromRGB(132, 132, 132)}):Play()
										TweenService:Create(BeatmapFrame.Frame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0.05,0,0,0)}):Play()
									else
										if SearchBar.Text == "" then
											TweenService:Create(BeatmapChooseUI.BG.BeatmapList,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{CanvasPosition = Vector2.new(0,(OrderId*60-(BeatmapChooseUI.BG.BeatmapList.AbsoluteWindowSize.Y*0.5)+30))}):Play()
										end
										wait(0.25+OrderId*0.001)
										TweenService:Create(BeatmapFrame.Frame.DiffName,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextStrokeTransparency = 0.8}):Play()
										TweenService:Create(BeatmapFrame.Frame.Title,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextStrokeTransparency = 0.8}):Play()
										TweenService:Create(BeatmapFrame.Frame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0,0,0,0)}):Play()
										TweenService:Create(BeatmapFrame.Frame.SelectButton,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{BackgroundColor3 = Color3.fromRGB(206, 206, 43)}):Play()
									end
								else
									CurrentChoose = Choosen
									if Choosen == false then
										if BeatmapFrame.Frame.Position ~= UDim2.new(0.05,0,0,0) then
											for i = 1,10 do
												wait()
											end
											TweenService:Create(BeatmapFrame.Frame.DiffName,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextStrokeTransparency = 1}):Play()
											TweenService:Create(BeatmapFrame.Frame.Title,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextStrokeTransparency = 1}):Play()
											TweenService:Create(BeatmapFrame.Frame,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0.05,0,0,0)}):Play()
											TweenService:Create(BeatmapFrame.Frame.SelectButton,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{BackgroundColor3 = Color3.fromRGB(132, 132, 132)}):Play()
										end
									else
										for i = 1,10 do
											wait()
										end
										TweenService:Create(BeatmapFrame.Frame.DiffName,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextStrokeTransparency = 0.8}):Play()
										TweenService:Create(BeatmapFrame.Frame.Title,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextStrokeTransparency = 0.8}):Play()
										TweenService:Create(BeatmapFrame.Frame,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0,0,0,0)}):Play()
										TweenService:Create(BeatmapFrame.Frame.SelectButton,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{BackgroundColor3 = Color3.fromRGB(206, 206, 43)}):Play()
										if SearchBar.Text == "" then
											TweenService:Create(BeatmapChooseUI.BG.BeatmapList,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{CanvasPosition = Vector2.new(0,(OrderId*60-(BeatmapChooseUI.BG.BeatmapList.AbsoluteWindowSize.Y*0.5)+30))}):Play()
										end
										print(OrderId,BeatmapFrame.LayoutOrder)
									end
								end
							end
							script.Parent.SwitchBeatmap.Event:Wait()
						end
					end)
					BeatmapChooseConnections[#BeatmapChooseConnections+1] =BeatmapFrame.Frame.SelectButton.MouseButton1Click:Connect(function()
						if BeatmapFrame:FindFirstChild("TweenDone") == nil then return end
						local beatmapid = BeatmapFrame.Frame.BeatmapID.Value
						CurrentSetting.VirtualSettings.IngameBeatmapID.Value = beatmapid
						if game.Players.LocalPlayer.PlayerGui.SavedSettings:FindFirstChild("SettingsFrame") then
							game.Players.LocalPlayer.PlayerGui.SavedSettings.SettingsFrame.VirtualSettings.IngameBeatmapID.Value = beatmapid
						end
						IngamebeatmapID.Value = beatmapid
						if BeatmapChangeable == true then
							Id = beatmapid
							BeatmapStudio = BeatmapsList:GetChildren()[beatmapid]
						end
						ReloadPreviewFrame()
						script.Parent.SwitchBeatmap:Fire()
					end)
				end
			end

			repeat wait() until BeatmapChooseUI.BG.BeatmapList:FindFirstChild("-- All beatmap loaded --") == nil
		end
	end
end)

BeatmapChooseButton.MouseButton1Click:Connect(function()
	ToggleBeatmap(true)
end)


BeatmapChooseCloseButton.MouseButton1Click:Connect(function()
	ToggleBeatmap(false)
end)

local BackgroundFrame = game.Players.LocalPlayer.PlayerGui.BG.Background.Background
BackgroundFrame.Size = UDim2.new(1.01,0,1.01,0)
local BackgroundMovement = game:GetService("UserInputService").InputChanged:Connect(function()
	local Center = workspace.CurrentCamera.ViewportSize/2
	local CursorPosition = game:GetService("UserInputService"):GetMouseLocation()
	local Distance = Center - CursorPosition

	local DistanceX = Distance.X
	local DistanceY = Distance.Y

	if math.abs(DistanceX) > Center.X then DistanceX = Center.X*(DistanceX/math.abs(DistanceX)) end
	if math.abs(DistanceY) > Center.Y then DistanceY = Center.Y*(DistanceY/math.abs(DistanceY)) end
	DistanceX = (DistanceX/Center.X)*0.005
	DistanceY = (DistanceY/Center.Y)*0.005
	local NewPosition = UDim2.new(0.5+DistanceX,0,0.5+DistanceY,0)

	BackgroundFrame.Position = NewPosition
end)


local PlaybuttonTriggered = false
local BeatmapStarted = false

script.Parent.Parent.BG.StartButton.MouseButton1Click:Connect(function()
	if BeatmapchooseOpened == false and PlaybuttonTriggered == false then
		PlaybuttonTriggered = true
		local BGFrame = script.Parent.Parent.BG

		BGFrame.StartButtonBeatAnimation:Destroy()

		TweenService:Create(BGFrame.StartButton,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(0,400,0,100),BackgroundTransparency = 1}):Play()
		TweenService:Create(BGFrame.MultiplayerButton,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(0,400,0,100),BackgroundTransparency = 1}):Play()
		TweenService:Create(BGFrame.StartButton.UIStroke,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Transparency = 1}):Play()
		TweenService:Create(BGFrame.StartButton._Text,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()

		TweenService:Create(BGFrame.BeatmapChooseButton,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,0,-30)}):Play()
		TweenService:Create(BGFrame.BeatmapBrowserButton,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,1,30)}):Play()
		TweenService:Create(UIPreviewFrame,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(1,0)}):Play()
		TweenService:Create(BGFrame.BeatmapLeaderboard,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(0,0)}):Play()
		TweenService:Create(BGFrame.BeatmapCount,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(0,0)}):Play()
		TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans+0.2}):Play()
		TweenService:Create(workspace.BackgroundPart.SurfaceGui.Frame.BackgroundFrame.ImageFrame.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans+0.2}):Play()
		wait(0.5)
		script.Parent.StartGame:Fire()
		while wait(0.5) and not BeatmapStarted do
			script.Parent.StartGame:Fire()
		end
	end
end)

script.Parent.onTutorial.Event:Connect(function()
	onTutorial = true
	BeatmapStudio = workspace.TutorialBeatmap["Mitsukiyo - Unwelcome School (VtntGaming) [osu!RoVer tutorial]"]
	script.Parent.StartGame:Fire()
end)

local Multiplayer = false
script.Parent.Parent.BG.MultiplayerButton.MouseButton1Click:Connect(function()
	script.Parent.Enabled = false 
	script.Parent.Parent.Multiplayer.Enabled = true
end)


local isSpectating = false
local SpectateRemote
local SavedSpectateData
local ScoreResultDisplay = false
game.ReplicatedStorage.Gameplay.GetSpectateData:InvokeServer(game.Players.LocalPlayer.UserId,-1)
game.ReplicatedStorage.Gameplay.GetSpectateData:InvokeServer(-1,-1)


------- Check if the play ranked or not
local PlayRanked = true
local Reporter = game.ReplicatedStorage:FindFirstChild("ExpoiltReport")
if Reporter == nil then
	warn("[Client] An error occured, please rejoin to fix this issue")
	require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("An error occured, please rejoin to fix this issue.",Color3.new(1, 0, 0))
	script.Disabled = true
else
	ProcessFunction(function()
		repeat wait(0.1) until Reporter.Parent == nil
		warn("[Client] An error occured, please rejoin to fix this issue")
		require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("An error occured, please rejoin to fix this issue.",Color3.new(1, 0, 0))
		script.Disabled = true
	end)
end
local SecurityKey = game.HttpService:GenerateGUID() -- no

script.Parent.MouseHit.Event:Connect(function(CurrentSecurityKey)
	if isSpectating == true or PlayRanked == false then return end
	if CurrentSecurityKey~=SecurityKey then
		PlayRanked = false
		game.Players.LocalPlayer.PlayerGui.BG.UnrankedSign.Visible = true
		require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("Detected some suspicous activity on your play, your account has been unranked. The report has been sent to the developer.",Color3.new(1, 0, 0))
		Reporter:FireServer(game.Players.LocalPlayer.Name,game.Players.LocalPlayer.UserId,1)
	end
end)

script.Parent.SpectateCall.Event:Connect(function(UID,Username)
	local SpectateData = game.ReplicatedStorage.Gameplay.GetSpectateData:InvokeServer(UID)

	if SpectateData == 0 then
		require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("Unable to spectate "..Username,Color3.new(1,0,0))
		return
	end
	local SpectateName = Instance.new("StringValue",script.Parent.GameplayData)
	SpectateName.Name = "SpectateName"
	SpectateName.Value = Username
	isSpectating = true
	AutoPlay = false
	script.Parent.GameplayData.LeaderboardData.Value = "[]"

	SpectateRemote = SpectateData.Remote
	SavedSpectateData = SpectateData
	spawn(function()
		while wait() do
			if game.Players:GetPlayerByUserId(UID) == nil then
				require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("Player you spectate has left.",Color3.new(1,0,0))
				break
			end
		end
	end)
	game.ReplicatedStorage.Gameplay.UpdateStatus:FireServer(3)
	script.Parent.StartGame:Fire()
end)

spawn(function()
	script.Parent:WaitForChild("_FastRestart",math.huge)
	script.Parent.StartGame:Fire()
end)

game.ReplicatedStorage.Gameplay.UpdateStatus:FireServer(1)

script.Parent.StartGame.Event:Wait() -- The game start from here
local isLoaded = false
BeatmapStarted = true



ProcessFunction(function()
	repeat wait() until isLoaded
	for i = 1,30 do
		wait()
	end
	TweenService:Create(script.Parent.Interface.BG,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false),{BackgroundTransparency = 1}):Play()
end)
TweenService:Create(CurrentPreviewFrame.OverviewSong,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{Volume = 0}):Play()
if not script.Parent:FindFirstChild("_FastRestart") then	
	TweenService:Create(script.Parent.Interface.BG,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false),{BackgroundTransparency = 0}):Play()
	wait(0.25)
end
CurrentPreviewFrame.OverviewSong.Playing = false
script.Parent.Parent.BG.OutlineStuff:Destroy()
script.Parent.Parent.BG.StartButton:Destroy()
script.Parent.Parent.BG.MultiplayerButton:Destroy()
script.Parent.Parent.BG.BeatmapBrowserButton:Destroy()
if script.Parent.Parent.BG:FindFirstChild("StartButtonBeatAnimation") then
	script.Parent.Parent.BG.StartButtonBeatAnimation:Destroy()
end
game.Players.LocalPlayer.PlayerGui.SavedSettings:ClearAllChildren()
CurrentSetting.Parent = game.Players.LocalPlayer.PlayerGui.SavedSettings
CurrentSetting.AnchorPoint = Vector2.new(1,0)
UIPreviewFrame.Parent = game.Players.LocalPlayer.PlayerGui.SavedSettings
UIPreviewFrame.AnchorPoint = Vector2.new(0,0)
script.Parent.Parent.BG.BeatmapChooseButton.Visible = false
--script.Circle.Lightning.Visible = LightningEnabled
--script.Circle.HitCircleLightning.Visible = LightningEnabled
script.Parent.Cursor.TrailEnabled.Value = CursorTrailEnabled
script.Parent.Parent.BG.BeatmapCount.Visible = false
script.Parent.Parent.BG.BeatmapLeaderboard.Visible = false
script.Parent.Parent.BG.GameVersion.Visible = false
game.Players.LocalPlayer.PlayerGui.MenuInterface.LeaderboardButton.Visible = false
game.Players.LocalPlayer.PlayerGui.MenuInterface.WikiButton.Visible = false
script.Parent.Leaderboard.LeaderboardWorking.Disabled = false

do
	local lbvalue =  Instance.new("BoolValue",script.Parent.TempSettings)
	lbvalue.Name = "IngameLB"
	lbvalue.Value = InGameLeaderboard and not onTutorial
end

if BackgroundBlurEnabled == true then
	BackgroundFrame.Visible = false
	BackgroundFrame.Parent.Parent.BG.Visible = false
end

BackgroundMovement:Disconnect()
BackgroundFrame.Position = UDim2.new(0.5,0,0.5,0)

if isSpectating or AutoPlay then
	DisableChatInGame = false
end

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,not DisableChatInGame)




spawn(function()
	while wait(1) do
		SecurityKey = game.HttpService:GenerateGUID(false)
	end
end)


Instance.new("BoolValue",script.Parent).Name = "GameStarted"

local Settings = CurrentSetting.MainSettings


local Key1Input = Enum.KeyCode.X
local Key2Input = Enum.KeyCode.Z
pcall(function()
	if Settings.K1.KeyInput.Text == "Press a key" or Settings.K2.KeyInput.Text == "Press a key" then
		repeat wait() until Settings.K1.KeyInput.Text ~= "Press a key" and Settings.K2.KeyInput.Text ~= "Press a key"
	end
	Key1Input = Enum.KeyCode[Settings.K1.KeyInput.Text]
	Key2Input = Enum.KeyCode[Settings.K2.KeyInput.Text]
end)

--
local CS = 5
local ApproachRate = 5
local OverallDifficulty = 5


-- Load settings from Object data into Script data

SongSpeed = tonumber(Settings.Speed.Text)
SongDelay = Settings.Parent.VirtualSettings.InstantSettings.Offset.Value
Beatmap = Settings.BeatmapFile.Text
SongId = Settings.SoundID.Text
ScrollSpeed = Settings.Parent.VirtualSettings.InstantSettings.Sensitivity.Value*0.01
CursorID = Settings.Parent.VirtualSettings.CursorImageID.Value
DefaultCursorID = 6979941273
CursorSize = Settings.Parent.VirtualSettings.CursorSize.Value
CustomDiff = false
CursorTrailId = Settings.Parent.VirtualSettings.CursorTrailImageID.Value
CursorTrailSize = Settings.Parent.VirtualSettings.CursorTrailSize.Value
CursorTrailTransparency = Settings.Parent.VirtualSettings.CursorTrailTransparency.Value
CircleImageId = Settings.Parent.VirtualSettings.CircleImageId.Value
CircleOverlayImageId = Settings.Parent.VirtualSettings.CircleOverlayImageId.Value
ApproachCircleImageId = Settings.Parent.VirtualSettings.ApproachCircleImageId.Value
EffectVolume = Settings.Parent.VirtualSettings.InstantSettings.EffectVolume.Value



DefaultBackgroundTrans = Settings.Parent.VirtualSettings.InstantSettings.BackgroundDim.Value*0.01
if tonumber(SongId) == nil then
	SongId = "0"
end

if CustomMusicID == true then

	SongId = (string.sub(SongId,1,13) == "rbxassetid://" and SongId) or "rbxassetid://"..SongId
	if SongId == "rbxassetid://0" then
		SongId = "rbxassetid://6460316914"
	end

	script.Parent.Song.SoundId = SongId

end
-- Error check

if isSpectating == false then
	if Key1Input == nil then
		Key1Input = Enum.KeyCode.Z
	end
	if Key2Input == nil then
		Key2Input = Enum.KeyCode.X
	end
	if SongSpeed == nil or SongSpeed < 0.1 or SongSpeed > 5 or tostring(SongSpeed) == "nan" or tostring(SongSpeed) == "inf" or tostring(SongSpeed) == "-nan" or tostring(SongSpeed) == "-nan(ind)"  then
		SongSpeed = 1
	end
	if SongDelay == nil or math.abs(SongDelay) > 5000 then
		SongDelay = 0
	end
	if Beatmap == nil or Beatmap == "" or FileType == 1 then
		Beatmap = BeatmapStudio
		FileType = 1
	end
	if ScrollSpeed == nil or ScrollSpeed < 0.01 or ScrollSpeed > 10 then
		ScrollSpeed = 1
	end
	if CursorID == -1 then
		CursorID =  DefaultCursorID
	end
	if DefaultBackgroundTrans == nil or DefaultBackgroundTrans < 0 or DefaultBackgroundTrans > 1 then
		DefaultBackgroundTrans = 0.2
	end
else
	FileType = SavedSpectateData.FileType
	Beatmap = SavedSpectateData.FileName

	spawn(function()
		local MapData = require(Beatmap)

		local _,firstb = string.find(MapData,"BeatmapID:")
		local _,firstbset =  string.find(MapData,"BeatmapSetID:")
		local lastb,_ = string.find(MapData,"\n",firstb)
		local lastbset,_ = string.find(MapData,"\n",firstbset)
		local mapid = string.sub(MapData,firstb+1,lastb-1)
		local setid = string.sub(MapData,firstbset+1,lastbset-1)

		CurrentKey = setid.."-"..mapid
		BeatmapKey = mapid

		LoadLeaderboard()
	end)
	if FileType == 1 then
		Beatmap = BeatmapsList:FindFirstChild(SavedSpectateData.FileName)
	end
	SongDelay = SavedSpectateData.Offset
	SongSpeed = SavedSpectateData.Speed
	SliderMode = SavedSpectateData.SliderMode
	HiddenMod = SavedSpectateData.HD
	HardCore = SavedSpectateData.HC
	Flashlight = SavedSpectateData.FL
	HardRock = SavedSpectateData.HR
end

spawn(function()
	-- Save settings
	local ClientSettings = {
		Offset = SongDelay,
		ScrollSpeed = ScrollSpeed,
		SongVolume = SongVolume,
		EffectVolume = EffectVolume,
		BackgroundDimTrans = DefaultBackgroundTrans,
		K1 = string.sub(tostring(Key1Input),14,#tostring(Key1Input)),
		K2 = string.sub(tostring(Key2Input),14,#tostring(Key2Input)),
		Lightning = LightningEnabled,
		CursorTrail = CursorTrailEnabled,
		MobileHit = MobileMode,
		MouseButton = MouseButtonEnabled,
		NewCircleOverlay = NewCircelOverlay,
		OldScoreInterface = OldInterface,
		osuStableNotelock = osuStableNotelock,
		PerfomanceDisplay = PSDisplay,
		OldCursorMovement = OldCursorMovement,
		DisplayInGameLB = InGameLeaderboard,
		HitZone = HitZoneEnabled,
		Skin = {
			CursorId = CursorID,
			CursorSize = CursorSize,
			CursorTrailId = CursorTrailId,
			CursorTrailSize = CursorTrailSize,
			CursorTrailTransparency = CursorTrailTransparency,
			CircleImageId = CircleImageId,
			CircleOverlayImageId = CircleOverlayImageId,
			ApproachCircleImageId = ApproachCircleImageId
		}
	}
	game.ReplicatedStorage.GetSettings:InvokeServer(ClientSettings)
end)

-- load spectate data

if isSpectating == true then
	osuStableNotelock = SavedSpectateData.StableNotelock
end
-- Get beatmap data

local BeatmapData,ReturnData,TimingPoints,BeatmapComboColor = require(workspace.OsuConvert)(FileType,Beatmap,SongSpeed,SongDelay,CustomMusicID,true,false)

--------------------------------------------------------------------------------------------------------------------------------------------

CurrentKey = ReturnData.BeatmapSetsData.BeatmapsetID.."-"..ReturnData.BeatmapSetsData.BeatmapID
BeatmapKey = ReturnData.BeatmapSetsData.BeatmapID

-- BackgroundChange
local Background = game.Players.LocalPlayer.PlayerGui.BG.Background.Background

for _,Obj in pairs(Background:GetChildren()) do 
	if Obj:IsA("ImageLabel") then
		TweenService:Create(Obj,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
		spawn(function()
			wait(0.25)
			Obj:Destroy()
		end)
	end
end

ReturnData.ImageId = tostring(ReturnData.ImageId)

if ReturnData.ImageId ~= "0" then
	local NewBackground = script.BackgroundImage:Clone()
	NewBackground.Parent = Background
	NewBackground.Image = "http://www.roblox.com/asset/?id="..ReturnData.ImageId
	workspace.BackgroundPart.SurfaceGui.Frame.BackgroundFrame.ImageFrame.Image = "http://www.roblox.com/asset/?id="..ReturnData.ImageId
	TweenService:Create(NewBackground,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{ImageTransparency = 0}):Play()
end


local CustomCS = tonumber(Settings.CS.Text)
local CustomAR = tonumber(Settings.AR.Text)
local CustomOD = tonumber(Settings.OD.Text)

script.Parent.HitError.Visible = HitErrorEnabled

-- Old score interface
script.Parent.AccurancyDisplay.Visible = OverallInterfaceEnabled and OldInterface
script.Parent.ComboDisplay.Visible = OverallInterfaceEnabled and OldInterface
script.Parent.ScoreDisplay.Visible = OverallInterfaceEnabled and OldInterface
-- New score interface
script.Parent.ScoreFrameDisplay.Visible = OverallInterfaceEnabled and not OldInterface
script.Parent.AccurancyFrameDisplay.Visible = OverallInterfaceEnabled and not OldInterface
script.Parent.ComboFrameDisplay.Visible = OverallInterfaceEnabled and not OldInterface
-----------
game.Players.LocalPlayer.PlayerGui.BG.GameTitle.Visible = false
game.Players.LocalPlayer.PlayerGui.BG.HitKey.Visible = OverallInterfaceEnabled

--script.Circle.Circle.Visible = not NewCircelOverlay
--script.Circle.Circle2.Visible = NewCircelOverlay
if CircleOverlayImageId == -1 then
	CircleOverlayImageId = 8132179567
end

if CircleImageId == -1 then
	CircleImageId = 8132203100
end

if ApproachCircleImageId == -1 then
	ApproachCircleImageId = 6979942451
end

script.Circle.HitCircle.Image = "http://www.roblox.com/asset/?id="..tostring(CircleImageId)
script.Circle.Circle.Image = "http://www.roblox.com/asset/?id="..tostring(CircleOverlayImageId)
script.Circle.ApproachCircle.Image = "http://www.roblox.com/asset/?id="..tostring(ApproachCircleImageId)

if AutoPlay then
	Instance.new("IntValue",script.Parent.GameplayData).Name = "isAT"
end

-----

local HPDrain = 5
if ReturnData.MapSongId ~= nil then
	script.Parent.Song.SoundId = "rbxassetid://"..tostring(ReturnData.MapSongId)
end
if isSpectating == false then
	if ReturnData.Difficulty ~= nil then
		local Difficulty = ReturnData.Difficulty
		local HRMulti = 1
		local CSHRMulti = 1
		if HardRock then
			HRMulti = 1.4
			CSHRMulti = 1.3
		end
		CS = Difficulty.CircleSize * CSHRMulti
		ApproachRate = Difficulty.ApproachRate * HRMulti
		OverallDifficulty = Difficulty.OverallDifficulty * HRMulti
		HPDrain = Difficulty.HPDrainRate * HRMulti
		if CS > 7 then
			CS = 7
		end
		if ApproachRate > 10 then
			ApproachRate = 10
		end
		if OverallDifficulty > 10 then
			OverallDifficulty = 10
		end
		if HPDrain > 10 then
			HPDrain = 10
		end
	end

	if tonumber(CustomCS) then
		CustomDiff = true
		CS = CustomCS
	end
	if tonumber(CustomAR) then
		ApproachRate = CustomAR
	end
	if tonumber(CustomOD) then
		CustomDiff = true
		OverallDifficulty = CustomOD
	end


	if CS == nil or ((not CustomCS and (CS < 2 or CS > 7)) or CS < 1 or CS > 10) then
		CS = 4.5
	end
	if ApproachRate == nil or ApproachRate < 0 or ApproachRate > 12 then
		ApproachRate = 5
	end
	if OverallDifficulty == nil or OverallDifficulty < 0 or OverallDifficulty > 10 then
		OverallDifficulty = 5
	end
else
	local Diff = SavedSpectateData.DiffData
	CS = Diff.CS
	ApproachRate = Diff.AR
	OverallDifficulty = Diff.OD
end

local RankedRequirement = {
	FileType == 1,
	AutoPlay == false,
	script.Parent.TempSettings.ReplayMode.Value == false,
	not game.Players.LocalPlayer:FindFirstChild("PlayerUnranked"),
	CustomDiff == false,
	isSpectating == false,
	game.Players.LocalPlayer.AccountAge >= 28,
	onTutorial == false
}

for _,Requirement in pairs(RankedRequirement) do
	if not Requirement then
		PlayRanked = false
	end
end

--[[

if FileType ~= 1 or AutoPlay == true or SliderMode == true or script.Parent.TempSettings.ReplayMode.Value == true or game.Players.LocalPlayer:FindFirstChild("PlayerUnranked") or CustomDiff == true or isSpectating == true then
	PlayRanked = false
end]]

game.Players.LocalPlayer.PlayerGui.BG.UnrankedSign.Visible = not PlayRanked

if isSpectating == true then
	game.Players.LocalPlayer.PlayerGui.BG.UnrankedSign.Text = "SPECTATING"
elseif onTutorial == true then
	game.Players.LocalPlayer.PlayerGui.BG.UnrankedSign.Text = "TUTORIAL"
	CS = 3.5
	ApproachRate = 4
	OverallDifficulty = 2
	AutoPlay = false
	SliderMode = true
end

local PlayingRemote
local StartPlayingTick = tick()
if isSpectating == false and AutoPlay == false then
	local FileName = Beatmap
	if FileType == 1 then
		FileName = Beatmap.Name
	end

	local Data = {
		FileType = FileType,
		FileName = FileName,
		Offset = SongDelay,
		SliderMode = SliderMode,
		StartTime = tick() - 2,
		Speed = SongSpeed,
		AR = ApproachRate,
		CS = CS,
		OD = OverallDifficulty,
		StableNotelock = osuStableNotelock,
		FL = Flashlight,
		HC = HardCore,
		HD = HiddenMod,
		HR = HardRock
	}
	PlayingRemote = game.ReplicatedStorage.Gameplay.GetSpectateData:InvokeServer(game.Players.LocalPlayer.UserId,Data)
end


-------------------



local ComboColor = { --Combo color
	Color3.fromRGB(241,79,10),
	Color3.fromRGB(153,203,253),
	Color3.fromRGB(54,115,228),
	Color3.fromRGB(98,46,207),
	Color3.fromRGB(227,149,43),
	Color3.fromRGB(37,203,33),
	Color3.fromRGB(16,190,182),
	Color3.fromRGB(255,0,0)
}




if BeatmapComboColor ~= nil then
	ComboColor = BeatmapComboColor
end



--------
local TweenService = game:GetService("TweenService")
local Tween
local Start = tick()+2
local SongStart = tick()+2
local CursorInterfaceUI = game.Players.LocalPlayer.PlayerGui.CursorInterface:Clone() -- The real cursor is in here

if #CursorInterfaceUI:GetChildren() > 1 or #CursorInterfaceUI.PlayFrame:GetChildren() > 1 or #CursorInterfaceUI.PlayFrame.Cursor:GetChildren() > 0 then
	require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("Detected some changed on the system, this play is unranked.",Color3.new(1, 0, 0))
	PlayRanked = false
	game.Players.LocalPlayer.PlayerGui.BG.UnrankedSign.Visible = true
end

CursorInterfaceUI.PlayFrame.Position = UDim2.new(0,script.Parent.PlayFrame.AbsolutePosition.X,0,script.Parent.PlayFrame.AbsolutePosition.Y)
CursorInterfaceUI.PlayFrame.Size = UDim2.new(0,script.Parent.PlayFrame.AbsoluteSize.X,0,script.Parent.PlayFrame.AbsoluteSize.Y)

script.Parent.Changed:Connect(function()
	CursorInterfaceUI.PlayFrame.Position = UDim2.new(0,script.Parent.PlayFrame.AbsolutePosition.X,0,script.Parent.PlayFrame.AbsolutePosition.Y)
	CursorInterfaceUI.PlayFrame.Size = UDim2.new(0,script.Parent.PlayFrame.AbsoluteSize.X,0,script.Parent.PlayFrame.AbsoluteSize.Y)
end)

--local Cursor = script.Parent.PlayFrame.Cursor
local Cursor = script.Parent.PlayFrame.Cursor
--local DisplayingCursor = script.Parent.PlayFrame.Cursor
local CursorTrail = script.Cursor_Trail

local CursorPosition = Vector2.new(256,576)

if AutoPlay == true then
	local ATCursor = script.Parent.GameplayData.ATVC
	ATCursor.Changed:Connect(function()
		CursorPosition = Vector2.new(ATCursor.Position.X.Scale*512,ATCursor.Position.Y.Scale*384)
	end)
end

game:GetService("RunService").RenderStepped:Connect(function()
	local Position = CursorPosition
	Cursor.Position = UDim2.new(Position.X/512,0,Position.Y/384,0)
end)

--[[
Cursor.Changed:Connect(function()
	DisplayingCursor.Visible = Cursor.Visible
	DisplayingCursor.Position = Cursor.Position
	DisplayingCursor.Size = Cursor.Size
	DisplayingCursor.Image = Cursor.Image
end)]]

if isSpectating == true then
	Start = tick()+2
	SongStart = tick()+2
end

if tonumber(ReturnData.BeatmapVolume) ~= nil and ReturnData.BeatmapVolume > 0 and ReturnData.BeatmapVolume < 10 then
	script.Parent.Song.Volume = ReturnData.BeatmapVolume*(SongVolume*0.02)
else
	script.Parent.Song.Volume = SongVolume*0.01
end

script.HitSound.Volume = EffectVolume*0.01
script.HitSoundClap.Volume = EffectVolume*0.01
script.HitSoundFinish.Volume = EffectVolume*0.01
script.HitSoundWhistle.Volume = EffectVolume*0.01
script.Parent.FailSound.Volume = EffectVolume*0.01
script.Parent.ComboBreak.Volume = EffectVolume*0.01


local ReplayData = {}
local ReplayRecordEnabled = false
local Limit = 0.1
local ReplayMode = script.Parent.TempSettings.ReplayMode.Value
local LastPos = UDim2.new(0,0,0,0)
--[[
if ReplayMode == false then
	spawn(function()
		while wait(0.1) do
			if LastPos ~= Cursor.Position and ReplayRecordEnabled == true then
				local PosX = math.floor(Cursor.Position.X.Scale*512)
				local PosY = math.floor(Cursor.Position.Y.Scale*384)
				local Time = math.floor((tick() - Start)*1000)
				local RecordData = {PosX,PosY,Time}
				ReplayData[#ReplayData+1] = RecordData
				LastPos = Cursor.Position
			end
		end
	end)
else
	spawn(function()
		local Replay = script.Parent.Replay.Value
		Replay = game.HttpService:JSONDecode(Replay)
		for i,Data in pairs(Replay) do
			if i ~= 1 then
				repeat wait() until tick() - Start >= Replay[i-1][3]/1000
				local TweenTime = (Data[3] - Replay[i-1][3])/1000
				TweenService:Create(Cursor,TweenInfo.new(TweenTime,Enum.EasingStyle.Linear),{Position = UDim2.new(Data[1]/512,0,Data[2]/384,0)}):Play()
			end
		end
	end)
end]]

--HPDrain

local HealthBarDrainEnabled = false
local HealthPoint = 0
local isDrain = false
local BeatmapFailed = false
local TotalNote = 0
local TotalSliders = 0
-- 3.2 per note
local MissDrain = 12.5
if HPDrain < 5 then
	MissDrain = 12.5 - 10.5 * (5 - HPDrain) / 5
else
	MissDrain = 12.5 + 17.5 * (HPDrain - 5) / 5
end

local HitnoteAnimations = {}
local GameOverAnimations = {}

script.Parent.HealthBar.Visible = showHealthBar

if not SliderMode then
	for _,HitObjData in pairs(BeatmapData) do
		TotalNote += 1
		if HitObjData.Type == 2 or HitObjData.Type == 6 or math.floor((HitObjData.Type-22)/16) == (HitObjData.Type-22)/16 then
			TotalSliders += tonumber(HitObjData.ExtraData[3])
		end
	end
	local Multiplier = (TotalNote + TotalSliders)/TotalNote
	MissDrain *= Multiplier
end

function GameOver()
	ProcessFunction(function()
		if BeatmapFailed or not HardCore then return end
		script.Parent.FailSound:Play()
		TweenService:Create(script.Parent.HealthBar.HPLeft,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Size = UDim2.new(0,0,1,0)}):Play()
		for _,tween in pairs(HitnoteAnimations) do
			ProcessFunction(function()
				if tween:IsA("Tween") then
					tween:Pause()
				--[[
				local TweenObj = tween.Instance
				if TweenObj and TweenObj:IsA("GuiObject") then
					GameOverAnimations[#GameOverAnimations+1] = TweenObj
					local NewPos = TweenObj.Position + UDim2.new(0,math.random(-10,10),0,math.random(200,400))
					local NewRotation = TweenObj.Rotation + math.random(-45,-20)
					local ImageTrans = (TweenObj:IsA("ImageLabel") and 1) or nil
					local TextTrans = (TweenObj:IsA("TextLabel") and 1) or nil
					TweenService:Create(TweenObj,TweenInfo.new(3,Enum.EasingStyle.Linear),{BackgroundTransparency = 1,ImageTransparency = ImageTrans,TextTransparency = TextTrans,Position = NewPos,Rotation = NewRotation}):Play()
				end]]
				end
			end)
		end
		for _,TweenObj in pairs(script.Parent.PlayFrame:GetDescendants()) do
			if TweenObj.Name ~= "Cursor" and TweenObj.Name ~= "Flashlight" and TweenObj.Parent.Name ~= "MessagePatch" and TweenObj.Parent.Name ~= "CursorFade" and TweenObj:IsA("GuiObject") then

				local NewPos = TweenObj.Position + UDim2.new(0,math.random(-10,10),0,math.random(200,400))
				local NewRotation = TweenObj.Rotation + math.random(-45,-20)
				local ImageTrans = (TweenObj:IsA("ImageLabel") and 1) or nil
				local TextTrans = (TweenObj:IsA("TextLabel") and 1) or nil
				TweenService:Create(TweenObj,TweenInfo.new(3,Enum.EasingStyle.Linear),{BackgroundTransparency = 1,ImageTransparency = ImageTrans,TextTransparency = TextTrans,Position = NewPos,Rotation = NewRotation}):Play()
			end
		end
		BeatmapFailed = true
		Start = 1e20
		SongStart = 1e20
		TweenService:Create(script.Parent.Song,TweenInfo.new(3,Enum.EasingStyle.Linear),{PlaybackSpeed = 0}):Play()
		wait(0.5)
		--double check
		for _,TweenObj in pairs(script.Parent.PlayFrame:GetDescendants()) do
			if TweenObj.Name ~= "Cursor" and TweenObj.Name ~= "Flashlight" and TweenObj.Parent.Name ~= "MessagePatch" and TweenObj.Parent.Name ~= "CursorFade" and TweenObj:IsA("GuiObject") then
				local ImageTrans = (TweenObj:IsA("ImageLabel") and 1) or nil
				local TextTrans = (TweenObj:IsA("TextLabel") and 1) or nil
				TweenService:Create(TweenObj,TweenInfo.new(2.5,Enum.EasingStyle.Linear),{BackgroundTransparency = 1,ImageTransparency = ImageTrans,TextTransparency = TextTrans}):Play()
			end
		end
		wait(1.5)
		TweenService:Create(script.Parent.RestartGame,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),
			{AnchorPoint = Vector2.new(0.5,0.5),Position = UDim2.new(0.5,0,0.55,0),Size = UDim2.new(0,400,0,40)}
		):Play()
		script.Parent.RestartGame.Text = "Return"
		script.Parent.RestartGame.Font = Enum.Font.TitilliumWeb
		script.Parent.RestartGame.TextScaled = false
		script.Parent.RestartGame.TextSize = 40
		script.Parent.RestartBeatmap.Visible = true
		TweenService:Create(script.Parent.RestartBeatmap,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextTransparency = 0,BackgroundTransparency = 0}):Play()
		local FailedScreen = script.Parent.Parent.BG.FailedScreen
		if AutoPlay == true then
			FailedScreen.Hint.HintText.Text = "Autoplay could failed sometime isn't it?"
		elseif isSpectating then
			FailedScreen.Hint.HintText.Text = "Player failed"
			script.Parent.RestartBeatmap.Visible = false
		else
			FailedScreen.Hint.HintText.Text = "You've failed, retry?"
		end
		TweenService:Create(FailedScreen,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.25}):Play()
		TweenService:Create(FailedScreen.Hint.HintText,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0,0,0,0)}):Play()
		TweenService:Create(FailedScreen.Title,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextTransparency = 0}):Play()

	end)
end
local DrainSpeed = 1.75

ProcessFunction(function()
	local LastTick = tick()

--[[
	if ApproachRate < 5 then
		CircleApproachTime = 1200 + 600 * (5 - ApproachRate) / 5
	elseif ApproachRate > 5 then
		CircleApproachTime = 1200 - 750 * (ApproachRate - 5) / 5
	else
		CircleApproachTime = 1200
	end]]
	if HPDrain < 5 then
		DrainSpeed = 1.75 - 0.75 * (HPDrain) / 5
	else
		DrainSpeed = 1.75 + 1.75 * (HPDrain - 5) / 5
	end
	DrainSpeed*= SongSpeed
	while wait() do
		if isDrain then
			local HealthDrain = (((tick() - LastTick)*DrainSpeed))
			HealthPoint -= HealthDrain
			if HealthPoint < 0 then
				HealthPoint = 0
			end
		end
		LastTick = tick()
	end
end)

function AddHP(HP)
	if isSpectating then return end
	HealthPoint += HP
	if HealthPoint > 100 then
		HealthPoint = 100
	end
end

function DrainHP(HP)
	if isSpectating then return end
	HealthPoint -= HP
	if HealthPoint < 0 then
		if not BeatmapFailed and not isSpectating then
			GameOver()
		end
		HealthPoint = 0
	end
end

ProcessFunction(function()
	local LastHP = HealthPoint
	while wait() do
		if HealthPoint ~= LastHP or HealthPoint == 0 then
			TweenService:Create(script.Parent.HealthBar.HPLeft,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Size = UDim2.new(HealthPoint/100,0,1,0)}):Play()
			local HolderTrans = 0
			if HealthPoint >= 80 then
				HolderTrans = 0
			elseif HealthPoint >= 50 then
				HolderTrans = 0.25
			elseif HealthPoint >= 30 then
				HolderTrans = 0.75
			else
				HolderTrans = 1
			end
			TweenService:Create(script.Parent.HealthBar.HPLeft.HolderFrame,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{BackgroundTransparency = HolderTrans}):Play()
		end
	end
end)

ReplayRecordEnabled = true

spawn(function()
	while wait() do
		script.Parent.GameplayPause.Event:Wait()
		local PausedTime = tick() - Start
		Start = 9e99
		SongStart = 9e99
		script.Parent.GameplayResume.Event:Wait()
		Start = tick() - PausedTime
		SongStart = tick() - PausedTime
	end
end)


spawn(function()
	spawn(function()
		TweenService:Create(script.Parent.ProgressBar,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(1,-50,0,-16)}):Play()
		wait(0.3)
		TweenService:Create(script.Parent.ProgressBar,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size = UDim2.new(0.3,0,0,4)}):Play()
	end)
	local TimeBreak = 3+BeatmapData[1].Time/1000
	repeat TweenService:Create(script.Parent.ProgressBar.Time,TweenInfo.new(0.05,Enum.EasingStyle.Linear),{Size = UDim2.new(-((tick()-Start) - BeatmapData[1].Time/1000)/TimeBreak,0,1,0)}):Play() wait() until (tick()-Start)*1000 >= BeatmapData[1].Time
	script.Parent.ProgressBar.Time.BackgroundColor3 = Color3.new(1,1,1)
	TweenService:Create(script.Parent.ProgressBar.TimeLeft.Time,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(0,0)}):Play()
	--TweenService:Create(script.Parent.ProgressBar.Time,TweenInfo.new((BeatmapData[#BeatmapData].Time-BeatmapData[1].Time)/1000,Enum.EasingStyle.Linear),{Size = UDim2.new(1,0,1,0)}):Play()

	local TotalTime = (BeatmapData[#BeatmapData].Time-BeatmapData[1].Time)/1000
	while tick() - Start < BeatmapData[#BeatmapData].Time/1000 - 0.5 and not ScoreResultDisplay do
		wait()
		local FullTimeLeft = BeatmapData[#BeatmapData].Time/1000 - (tick() - Start)
		local TimeLeft = math.floor(FullTimeLeft)
		local StringOutput = ""

		local Min = math.floor(TimeLeft/60)
		local Sec = TimeLeft - math.floor(TimeLeft/60)*60

		if Sec < 10 then
			Sec = "0"..tostring(Sec)
		end

		StringOutput = tostring(Min)..":"..tostring(Sec)
		if Start ~= 1e20 then
			script.Parent.ProgressBar.TimeLeft.Time.Text = StringOutput
		else
			script.Parent.ProgressBar.TimeLeft.Time.Text = ""
		end
		TweenService:Create(script.Parent.ProgressBar.Time,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{Size = UDim2.new(1-(FullTimeLeft/TotalTime),0,1,0)}):Play()
	end
	TweenService:Create(script.Parent.ProgressBar.TimeLeft.Time,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(0,1)}):Play()
end)


if AutoPlay == true and ReplayMode ~= true then
	spawn(function()
		repeat wait() until (tick()-Start)*1000 >= BeatmapData[1].Time-1000
		game:GetService("TweenService"):Create(script.Parent.GameplayData.ATVC,TweenInfo.new(0.5,Enum.EasingStyle.Sine),{Position = UDim2.new(0.5,0,0.5,0)}):Play()
	end)
end

local Connection
local Connection2

spawn(function()
	if BeatmapData[1].Time > 4000 then
		TweenService:Create(script.Parent.SkipButton,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,0.8,0)}):Play()
		local function SkipSong()
			Connection:Disconnect()
			Connection2:Disconnect()
			TweenService:Create(script.Parent.Song,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true),{Volume = 0}):Play()
			wait(0.25)
			script.Parent.Song.Playing = true
			Start = tick()-((BeatmapData[1].Time/1000)-2)
			SongStart = tick()-((BeatmapData[1].Time/1000)-2)
			if Tween then
				Tween:Pause()
			end
			TweenService:Create(script.Parent.ProgressBar.Time,TweenInfo.new(2,Enum.EasingStyle.Linear),{Size = UDim2.new(0,0,1,0)}):Play()
			TweenService:Create(script.Parent.SkipButton,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Position = UDim2.new(0.5,0,1.5,0)}):Play()

		end

		Connection = script.Parent.SkipButton.SkipButton.MouseButton1Click:Connect(SkipSong)
		Connection2 = game:GetService("UserInputService").InputBegan:Connect(function(data)
			if data.KeyCode == Enum.KeyCode.Space then
				SkipSong()
			end
		end)
		repeat wait() until (tick()-Start)*1000 >= BeatmapData[1].Time-3250
		Connection:Disconnect()
		Connection2:Disconnect()
		TweenService:Create(script.Parent.SkipButton,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Position = UDim2.new(0.5,0,1,25)}):Play()
	end
end)


spawn(function()
	repeat wait(0.1) until script.Parent.Song.IsLoaded == true
	while wait(0.1) do
		pcall(function()
			if math.abs(script.Parent.Song.TimePosition - ((tick() - SongStart)*SongSpeed*ReturnData.SongSpeed)) > 0.05 and script.Parent.Song.IsLoaded == true and (tick() - Start) <= BeatmapData[#BeatmapData].Time/1000 and not BeatmapFailed then
				script.Parent.Song.TimePosition = (tick() - SongStart)*SongSpeed*ReturnData.SongSpeed
			end
			if tick()-SongStart >= 0 and script.Parent.Song.Playing == false and (tick() - Start) <= BeatmapData[#BeatmapData].Time/1000 then
				script.Parent.Song.Playing = true
			end
			if CurrentPreviewFrame.OverviewSong.Playing == true then
				CurrentPreviewFrame.OverviewSong.Playing = false
			end
		end)
		if not isSpectating then
			CurrentSetting.VirtualSettings.PrevMapTime.Value = (tick()-Start)*SongSpeed
		end
	end
end)


--[[
File type:
1 - Used roblox module return a beatmap text
2 - Used a text send to beatmap to convert

]]

Cursor.Image = "http://www.roblox.com/asset/?id="..tostring(CursorID)
Cursor.Size = UDim2.new(0,CursorSize*80,0,CursorSize*80)

CursorTrail.Image = "http://www.roblox.com/asset/?id="..tostring(CursorTrailId)
CursorTrail.Size = UDim2.new(0,CursorTrailSize*80,0,CursorTrailSize*80)
CursorTrail.ImageTransparency = CursorTrailTransparency

local UserInputService =game:GetService("UserInputService")
local RblxNewCursor = game.Players.LocalPlayer.PlayerGui.OsuCursor.Cursor
local CursorUnlocked = false -- this will change to true at the end of the play

if AutoPlay or isSpectating then
	local restartframeposvalue = Instance.new("BoolValue",script.Parent.ScriptSettings)
	restartframeposvalue.Name = "RestartGameRightSite"
	restartframeposvalue.Value = false
end

if AutoPlay == false and ReplayMode ~= true and isSpectating == false then
	local PlayerMouse = game.Players.LocalPlayer:GetMouse()
	--PlayerMouse.Icon = "http://www.roblox.com/asset/?id=7017066525"
	--UserInputService.MouseIconEnabled = false
	RblxNewCursor.Visible = false
	local MobileHold = false
	local UserInputService = game:GetService("UserInputService")



	if UserInputService.TouchEnabled and MobileMode == true then
		script.Parent.RestartGame.Text = "Return main (Hold)"
		if HitZoneEnabled then
			if MobileModeRightHitZone == true then
				script.Parent.MobileHit.Position = UDim2.new(1,0,0,0)
				script.Parent.MobileHit.AnchorPoint = Vector2.new(0,0)
				script.Parent.MobileHit.Title.Rotation = -90
				TweenService:Create(script.Parent.MobileHit,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(1,0)}):Play()
				local restartframeposvalue = Instance.new("BoolValue",script.Parent.ScriptSettings)
				restartframeposvalue.Name = "RestartGameRightSite"
				restartframeposvalue.Value = true
				script.Parent.ComboDisplay.Position = UDim2.new(0,5,1,-23)
				script.Parent.ComboFrameDisplay.Position = UDim2.new(0,0,1,-23)
				local HitKeyFrame = game.Players.LocalPlayer.PlayerGui.BG.HitKey

				HitKeyFrame.AnchorPoint = Vector2.new(0,0.5)
				HitKeyFrame.Position = UDim2.new(0,0,0.55,0)

			else
				TweenService:Create(script.Parent.MobileHit,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(0,0)}):Play()
				local restartframeposvalue = Instance.new("BoolValue",script.Parent.ScriptSettings)
				restartframeposvalue.Name = "RestartGameRightSite"
				restartframeposvalue.Value = false
			end
		else
			local restartframeposvalue = Instance.new("BoolValue",script.Parent.ScriptSettings)
			restartframeposvalue.Name = "RestartGameRightSite"
			restartframeposvalue.Value = false
		end
		--[[
		script.Parent.PlayFrame.AnchorPoint = Vector2.new(1,0.5)
		script.Parent.PlayFrame.Position = UDim2.new(1,0,0.52,-18)]]

		--script.Parent.PlayFrame.Size = UDim2.new(0.95*4/3,0,0.95,0)


		ScrollSpeed = 1
		PlayerMouse.Move:Connect(function()
			local NewPos = (Vector2.new(PlayerMouse.X-(script.Parent.AbsoluteSize.X-script.Parent.PlayFrame.AbsoluteSize.X)/2,(PlayerMouse.Y)-(script.Parent.AbsoluteSize.Y-script.Parent.PlayFrame.AbsoluteSize.Y)/2))+Vector2.new(0,18)
			NewPos = UDim2.new(NewPos.X/script.Parent.PlayFrame.AbsoluteSize.X,0,NewPos.Y/script.Parent.PlayFrame.AbsoluteSize.Y,0)

			NewPos = Vector2.new(NewPos.X.Scale*512,NewPos.Y.Scale*384)
			CursorPosition = NewPos
			--Cursor.Position = NewPos
		end)
	else
		local restartframeposvalue = Instance.new("BoolValue",script.Parent.ScriptSettings)
		restartframeposvalue.Name = "RestartGameRightSite"
		restartframeposvalue.Value = false
	end
	if not (UserInputService.TouchEnabled and MobileMode == true) then
		if OldCursorMovement == true then
			--UserInputService.MouseIconEnabled = false
			RblxNewCursor.Visible = false
			PlayerMouse.Move:Connect(function()
				local NewPos = (Vector2.new(PlayerMouse.X-(script.Parent.AbsoluteSize.X-script.Parent.PlayFrame.AbsoluteSize.X)/2,(PlayerMouse.Y)-(script.Parent.AbsoluteSize.Y-script.Parent.PlayFrame.AbsoluteSize.Y)/2))+Vector2.new(0,10)
				NewPos = UDim2.new(NewPos.X/script.Parent.PlayFrame.AbsoluteSize.X,0,NewPos.Y/script.Parent.PlayFrame.AbsoluteSize.Y,0)
				NewPos = Vector2.new(NewPos.X.Scale*512,NewPos.Y.Scale*384)
				CursorPosition = NewPos
				--Cursor.Position = NewPos
			end)
		else
			--Cursor.Position = UDim2.new(0.5,0,0.5,0)
			CursorPosition = Vector2.new(256,192)
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			local ShiftEnabled = false
			UserInputService.InputBegan:Connect(function(data)
				if data.KeyCode == Enum.KeyCode.LeftShift and CursorUnlocked == false then
					ShiftEnabled = true
					UserInputService.MouseBehavior = Enum.MouseBehavior.Default
					--UserInputService.MouseIconEnabled = true
					RblxNewCursor.Visible = true
				end
			end)
			UserInputService.InputEnded:Connect(function(data)
				if data.KeyCode == Enum.KeyCode.LeftShift and CursorUnlocked == false then
					ShiftEnabled = false
					UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
					--UserInputService.MouseIconEnabled = false
					RblxNewCursor.Visible = false
				end
			end)

			spawn(function()
				while wait(0.1) do
					if UserInputService.MouseBehavior == Enum.MouseBehavior.Default and ShiftEnabled == false and CursorUnlocked == false then
						UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
					end
				end
			end)

			local CurrentCursorPosition = UDim2.new(0.5,0,0.5,0)

			UserInputService.InputChanged:Connect(function(InputData)
				if CursorUnlocked == true then
					return
				end
				if InputData.UserInputType == Enum.UserInputType.MouseMovement then
					local WindowSize = workspace.CurrentCamera.ViewportSize
					local AbsoluteSize = script.Parent.PlayFrame.AbsoluteSize

					--InputData.Delta

					local MouseMovement = Vector2.new(InputData.Delta.X/AbsoluteSize.X,InputData.Delta.Y/AbsoluteSize.Y)*ScrollSpeed
					local CurrentPos = Vector2.new(CurrentCursorPosition.X.Scale,CurrentCursorPosition.Y.Scale)
					CurrentPos += MouseMovement

					CursorPosition = Vector2.new(512*CurrentPos.X,384*CurrentPos.Y)
					CurrentCursorPosition = UDim2.new(CurrentPos.X,0,CurrentPos.Y,0)
					Cursor.Position = CurrentCursorPosition


					local MiddleCursorPosition = Cursor.AbsolutePosition+Cursor.AbsoluteSize/2

					if MiddleCursorPosition.X < 0 or MiddleCursorPosition.X > WindowSize.X then
						local NewPos = Vector2.new(WindowSize.X,0)
						if MiddleCursorPosition.X < 0 then
							NewPos = Vector2.new(0,0)
						end
						NewPos = (Vector2.new(NewPos.X-(script.Parent.AbsoluteSize.X-script.Parent.PlayFrame.AbsoluteSize.X)/2,(NewPos.Y)-(script.Parent.AbsoluteSize.Y-script.Parent.PlayFrame.AbsoluteSize.Y)/2))
						CurrentCursorPosition = UDim2.new(NewPos.X/script.Parent.PlayFrame.AbsoluteSize.X,0,CurrentCursorPosition.Y.Scale,0)
					end
					if Cursor.AbsolutePosition.Y > WindowSize.Y-36-40*CursorSize or Cursor.AbsolutePosition.Y < -36-40*CursorSize then
						local NewPos = Vector2.new(Cursor.AbsolutePosition.X,WindowSize.Y-26.5)
						if Cursor.AbsolutePosition.Y < -76 then
							NewPos = Vector2.new(Cursor.AbsolutePosition.X,-26.5)
						end
						NewPos = (Vector2.new(NewPos.X-(script.Parent.AbsoluteSize.X-script.Parent.PlayFrame.AbsoluteSize.X)/2,(NewPos.Y)-(script.Parent.AbsoluteSize.Y-script.Parent.PlayFrame.AbsoluteSize.Y)/2))
						CurrentCursorPosition = UDim2.new(CurrentCursorPosition.X.Scale,0,NewPos.Y/script.Parent.PlayFrame.AbsoluteSize.Y,0)
					end

					CursorPosition = Vector2.new(512*CurrentCursorPosition.X.Scale,384*CurrentCursorPosition.Y.Scale)
					Cursor.Position = CurrentCursorPosition
				end
			end)
		end
	end

	game:GetService("UserInputService").InputBegan:Connect(function(data)
		if data.KeyCode == Key1Input and not (MobileMode and game:GetService("UserInputService").TouchEnabled) then
			script.Parent.MouseHit:Fire(SecurityKey,1)
		elseif data.KeyCode == Key2Input and not (MobileMode and game:GetService("UserInputService").TouchEnabled) then
			script.Parent.MouseHit:Fire(SecurityKey,2)
		elseif data.UserInputType == Enum.UserInputType.MouseButton1 and MouseButtonEnabled == true then
			script.Parent.MouseHit:Fire(SecurityKey,3)
		elseif data.UserInputType == Enum.UserInputType.MouseButton2 and MouseButtonEnabled == true then
			script.Parent.MouseHit:Fire(SecurityKey,4)
		end
	end)
	game:GetService("UserInputService").InputEnded:Connect(function(data)
		if data.KeyCode == Key1Input then
			script.Parent.MouseHitEnd:Fire(SecurityKey,1)
		elseif data.KeyCode == Key2Input then
			script.Parent.MouseHitEnd:Fire(SecurityKey,2)
		elseif data.UserInputType == Enum.UserInputType.MouseButton1 and MouseButtonEnabled == true then
			script.Parent.MouseHitEnd:Fire(SecurityKey,3)
		elseif data.UserInputType == Enum.UserInputType.MouseButton2 and MouseButtonEnabled == true then
			script.Parent.MouseHitEnd:Fire(SecurityKey,4)
		end
	end)


	game:GetService("UserInputService").TouchStarted:Connect(function(data)
		local TouchPosition = data.Position
		local NewPos = (Vector2.new(TouchPosition.X-(script.Parent.AbsoluteSize.X-script.Parent.PlayFrame.AbsoluteSize.X)/2,(TouchPosition.Y)-(script.Parent.AbsoluteSize.Y-script.Parent.PlayFrame.AbsoluteSize.Y)/2))+Vector2.new(0,(-script.Parent.AbsoluteSize.Y*0.02)+18)
		NewPos = UDim2.new(NewPos.X/script.Parent.PlayFrame.AbsoluteSize.X,0,NewPos.Y/script.Parent.PlayFrame.AbsoluteSize.Y,0)
		CursorPosition = Vector2.new(NewPos.X.Scale*512,NewPos.Y.Scale*394)
		--Cursor.Position = NewPos

		local HitZone = script.Parent.MobileHit
		local MaxPosition = HitZone.AbsoluteSize.X

		--if TouchPosition.X > MaxPosition or not HitZoneEnabled or not MobileMode then -- no more double click
		script.Parent.MouseHit:Fire(SecurityKey,3)
		--end
	end)
	game:GetService("UserInputService").TouchEnded:Connect(function(data)
		script.Parent.MouseHitEnd:Fire(SecurityKey,3)
	end)
	script.Parent.MobileHit.MouseButton1Down:Connect(function()
		MobileHold = true
		script.Parent.MouseHit:Fire(SecurityKey,4)
	end)
	script.Parent.MobileHit.MouseButton1Up:Connect(function()
		MobileHold = false
		script.Parent.MouseHitEnd:Fire(SecurityKey,4)
	end)
	script.Parent.MobileHit.MouseLeave:Connect(function()
		if MobileHold == true then
			MobileHold = false
			script.Parent.MouseHitEnd:Fire(SecurityKey,4)
		end
	end)
end
local K1 = 0
local K2 = 0
local K3 = 0
local K4 = 0

local DownKey = {
	K1 = false,
	K2 = false,
	M1 = false,
	M2 = false
}

spawn(function()
	local TweenService = game:GetService("TweenService")
	local KeyTweenInfo = TweenInfo.new(0.1,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
	local ChangeIn1 = {Size = UDim2.new(0.18,0,0.18,0),BackgroundColor3 = Color3.new(1, 1, 0)}
	local ChangeIn2 = {Size = UDim2.new(0.18,0,0.18,0),BackgroundColor3 = Color3.new(0.294118, 1, 1)}
	local ChangeOut = {Size = UDim2.new(0.2,0,0.2,0),BackgroundColor3 = Color3.new(1, 1, 1)}
	script.Parent.MouseHit.Event:Connect(function(CurrentSecurityKey,data)
		if data == 1 then
			K1 += 1
			DownKey.K1 = true
			game.Players.LocalPlayer.PlayerGui.BG.HitKey.K1.Keycount.Text = K1
			TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.HitKey.K1,KeyTweenInfo,ChangeIn1):Play()
		elseif data == 2 then
			K2 += 1
			DownKey.K2 = true
			game.Players.LocalPlayer.PlayerGui.BG.HitKey.K2.Keycount.Text = K2
			TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.HitKey.K2,KeyTweenInfo,ChangeIn1):Play()
		elseif data == 3 then
			K3 += 1
			DownKey.M1 = true
			game.Players.LocalPlayer.PlayerGui.BG.HitKey.M1.Keycount.Text = K3
			TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.HitKey.M1,KeyTweenInfo,ChangeIn2):Play()
		elseif data == 4 then
			K4 += 1
			DownKey.M2 = true
			game.Players.LocalPlayer.PlayerGui.BG.HitKey.M2.Keycount.Text = K4
			TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.HitKey.M2,KeyTweenInfo,ChangeIn2):Play()
		end
		script.Parent.KeyDown.Value = DownKey.K1 or DownKey.K2 or DownKey.M1 or DownKey.M2
	end)
	script.Parent.MouseHitEnd.Event:Connect(function(CurrentSecurityKey,data)
		if data == 1 then
			DownKey.K1 = false
			TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.HitKey.K1,KeyTweenInfo,ChangeOut):Play()
		elseif data == 2 then
			DownKey.K2 = false
			TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.HitKey.K2,KeyTweenInfo,ChangeOut):Play()
		elseif data == 3 then
			DownKey.M1 = false
			TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.HitKey.M1,KeyTweenInfo,ChangeOut):Play()
		elseif data == 4 then
			DownKey.M2 = false
			TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.HitKey.M2,KeyTweenInfo,ChangeOut):Play()
		end
		script.Parent.KeyDown.Value = DownKey.K1 or DownKey.K2 or DownKey.M1 or DownKey.M2
	end)
end)



--wait(2)
--CircleSize = 54.4 - 4.48 * CS
--3

--print((54.4 - 4.48 *3)/768*2)

--1.25
-- osu play size: 512x384






local ZIndex = 0

local hit300 = 160 - 12 * OverallDifficulty --148>1 , 40>10
local hit100 = 280 - 16 * OverallDifficulty --264>1 , 120>10
local hit50 = 400 - 20 * OverallDifficulty --380>1 , 200>10
local EarlyMiss = 400

script.Parent.HitError.Size = UDim2.new(0,hit50*(19/16),0,25)
script.Parent.HitError._300s.Size = UDim2.new(hit300/hit50,0,0.5,0)
script.Parent.HitError._100s.Size = UDim2.new(hit100/hit50,0,0.5,0)

local Accurancy = {
	h300 = 0,h100 = 0,h50 = 0,miss = 0,Combo = 0, MaxCombo = 0, MaxPeromanceCombo = 0, PerfomanceCombo = 0, h300Bonus = 0, bonustotal = 0
}
local GameMaxCombo = #BeatmapData


local CircleSize = (54.4 - 4.48 * CS)*2

if AutoPlay == false and ReplayMode ~= true and isSpectating == false and UserInputService.TouchEnabled and MobileMode == true then
	CircleSize *= 1.1875
end
local DisplayCombo = 0
local LastCombo = 0
local LastComboCapture = Instance.new("Frame")
local _currentfadecomboid = ""
script.Parent.ComboDisplay.Changed:Connect(function()
	local id = game.HttpService:GenerateGUID()
	_currentfadecomboid = id
	local NewCombo = tonumber(string.sub(script.Parent.ComboDisplay.Text,1,#script.Parent.ComboDisplay.Text-1)) or 0
	if NewCombo > DisplayCombo then
		TweenService:Create(script.Parent.ComboFrameDisplay,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(0.09,0,0.09,0)}):Play()
		ProcessFunction(function()
			wait(0.05)
			if _currentfadecomboid ~= id then return end
			TweenService:Create(script.Parent.ComboFrameDisplay,TweenInfo.new(0.1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(0.075,0,0.075,0)}):Play()
		end)
		script.Parent.ComboFade:ClearAllChildren()
		if OldInterface == true then
			spawn(function()
				local NewFadeCombo = script.ComboFade:Clone()
				NewFadeCombo.Parent = script.Parent.ComboFade
				NewFadeCombo.Text = tostring(NewCombo).."x"
				game:GetService("TweenService"):Create(NewFadeCombo,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextSize = 60,TextTransparency = 1}):Play()
				wait(0.5)
				NewFadeCombo:Destroy()
			end)
		end

		LastComboCapture:Destroy()
		LastComboCapture = script.Parent.ComboFrameDisplay:Clone()
		local NewFadeCombo = script.Parent.ComboFrameDisplay:Clone()
		NewFadeCombo.Parent = script.Parent.ComboFade

		TweenService:Create(NewFadeCombo,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(NewFadeCombo.Size.Y.Scale*1.5,0,NewFadeCombo.Size.Y.Scale*1.5,0)}):Play()
		for _,obj in pairs(NewFadeCombo:GetChildren()) do
			if obj:IsA("ImageLabel") then
				TweenService:Create(obj,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()
			end
		end
		wait(0.5)
		NewFadeCombo:Destroy()
	elseif NewCombo == 0 and LastCombo >= 20 then
		local BrokenCombo = LastComboCapture:Clone()
		--BrokenCombo.Parent = script.Parent.Interface

	end
	DisplayCombo = NewCombo
end)

local DisplayAccurancy = 100
local CurrentAccurancy = 100

local LastComboDisplay = 0

spawn(function() --Accurancy caculation
	while wait() do
		local h300 = Accurancy.h300
		local h100 = Accurancy.h100
		local h50 = Accurancy.h50
		local miss = Accurancy.miss
		local Total = h300+h100+h50+miss
		local Acc = math.floor(((h300*300+h100*100+h50*50)/(Total*300))*10000)/100
		local tostringAcc = tostring(Acc)
		if tostringAcc == "-nan(ind)" or tostringAcc == "nan" or tostringAcc == "inf" or tostringAcc == "100" then
			tostringAcc = "100.00"
		elseif string.sub(tostringAcc,#tostringAcc-1,#tostringAcc-1) == "." then
			tostringAcc = tostringAcc.."0"
		elseif #tostringAcc <= 2 then
			tostringAcc = tostringAcc..".00"
		end
		if tonumber(tostringAcc) < 10 then
			tostringAcc = "0"..tostringAcc
		end

		local NewAcc = tonumber(tostringAcc)*100
		DisplayAccurancy = NewAcc

		script.Parent.ComboDisplay.Text = tostring(Accurancy.Combo).."x"

		local ComboDisplay = script.Parent.ComboFrameDisplay

		if LastComboDisplay ~= Accurancy.Combo then

			ComboDisplay:ClearAllChildren()
			script.ScoreDisplay.UIComboLayout:Clone().Parent = ComboDisplay
			local TextCombo = tostring(Accurancy.Combo).."x"

			for i = 1,#TextCombo do
				local CurrentText = string.sub(TextCombo,i,i)
				local NewComboText = script.ScoreDisplay:FindFirstChild("Score"..CurrentText):Clone()
				NewComboText.Parent = ComboDisplay
				NewComboText.ZIndex = i
			end
		end
		LastComboDisplay = Accurancy.Combo
	end
end)

spawn(function()
	while wait() do
		if DisplayAccurancy ~= CurrentAccurancy then
			CurrentAccurancy = DisplayAccurancy
			TweenService:Create(script.Parent.GameplayData.Accurancy,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{Value = DisplayAccurancy}):Play()
		end
	end
end)

local PrevAcc = 100

script.Parent.GameplayData.Accurancy.Changed:Connect(function()
	local Acc = script.Parent.GameplayData.Accurancy.Value/100
	local AccurancyDisplay = script.Parent.AccurancyFrameDisplay

	local tostringAcc = tostring(Acc)
	if tostringAcc == "-nan(ind)" or tostringAcc == "inf" or tostringAcc == "100" then
		tostringAcc = "100.00"
	elseif string.sub(tostringAcc,#tostringAcc-1,#tostringAcc-1) == "." then
		tostringAcc = tostringAcc.."0"
	elseif #tostringAcc <= 2 then
		tostringAcc = tostringAcc..".00"
	end
	if tonumber(tostringAcc) < 10 then
		tostringAcc = "0"..tostringAcc
	end

	script.Parent.AccurancyDisplay.Text = tostringAcc.."%"
	local TextAcccurancy = tostringAcc.."%"
	if PrevAcc ~= Acc then
		AccurancyDisplay:ClearAllChildren()
		script.ScoreDisplay.UIAccurancyLayout:Clone().Parent = AccurancyDisplay
		for i = 1,#TextAcccurancy do
			local CurrentTextAcccurancy = string.sub(TextAcccurancy,i,i)
			if CurrentTextAcccurancy == "." then CurrentTextAcccurancy = "," end
			local NewScoreFrame = script.ScoreDisplay:FindFirstChild("Score"..CurrentTextAcccurancy):Clone()
			NewScoreFrame.Parent = AccurancyDisplay
			NewScoreFrame.ZIndex = -i
		end
	end
	PrevAcc = Acc
end)


local Score = 0
local ScoreMultiplier = {
	Difficulty = 6,
	Mod = 1
}

-- SpeedReduce mod:  Speed ^ 0.28
-- SpeedIncrease mod: Speed ^ 4.185

local SpeedMulti = 1
if SongSpeed < 1 then
	SpeedMulti = SongSpeed^4.185
elseif SongSpeed > 1 then
	SpeedMulti = SongSpeed^0.28
end
ScoreMultiplier.Mod *= SpeedMulti

if HardCore == true then
	ScoreMultiplier.Mod *= 2
end

if HiddenMod == true then
	ScoreMultiplier.Mod *= 1.06
end

if HardRock == true then
	ScoreMultiplier.Mod *= 1.06
end

local ScoreDisplay = script.Parent.ScoreFrameDisplay
local PrevScore = -1

spawn(function()
	local PrevScore = 0
	local PrevMaxCombo = 0
	while wait() do
		if Score ~= PrevScore or PrevMaxCombo ~= Accurancy.MaxCombo then
			script.Parent.ScoreUpdate:Fire(Score,Accurancy.MaxCombo)
		end
		PrevScore = Score
		PrevMaxCombo = Accurancy.MaxCombo
	end
end)

spawn(function()
	local CurrentScore = script.Parent.GameplayData.Score.Value
	while wait() do
		if Score ~= CurrentScore then
			CurrentScore = Score
			TweenService:Create(script.Parent.GameplayData.Score,TweenInfo.new(0.4,Enum.EasingStyle.Linear),{Value = Score}):Play()
		end
		script.Parent.ScoreDisplay.Text = tostring(math.floor(script.Parent.GameplayData.Score.Value))
		if PrevScore ~= script.Parent.GameplayData.Score.Value then
			local TextScore = tostring(math.floor(script.Parent.GameplayData.Score.Value))
			--[[
			ScoreDisplay:ClearAllChildren()
			script.ScoreDisplay.UIScoreLayout:Clone().Parent = ScoreDisplay
			for i = 1,#TextScore do
				local CurrentTextScore = string.sub(TextScore,i,i)
				local NewScoreFrame = script.ScoreDisplay:FindFirstChild("Score"..CurrentTextScore):Clone()
				NewScoreFrame.Parent = ScoreDisplay
				NewScoreFrame.ZIndex = -i
			end]]

			for i = 1,#TextScore do
				local Displayer = ScoreDisplay["Num_"..tostring((#TextScore+1)-i)]
				local CurrentTextScore = string.sub(TextScore,i,i)

				Displayer.Visible = true
				for _,a in pairs(Displayer:GetChildren()) do
					if a.Name == "Score"..CurrentTextScore then
						a.Visible = true
					else
						a.Visible = false
					end
				end
			end
			for i = #TextScore+1,12 do
				local Displayer = ScoreDisplay["Num_"..tostring(i)]
				Displayer.Visible = false
			end
		end
		PrevScore = script.Parent.GameplayData.Score.Value
	end
end)

-- Flashlight mod

local FlashlightFrame = script.Parent.PlayFrame.Flashlight
FlashlightFrame.Visible = Flashlight
gameEnded = false

ProcessFunction(function()
	while wait(0.1) do
		if (FlashlightFrame.Visible == false or FlashlightFrame.Parent == nil) and Flashlight == true and gameEnded == false then
			warn("[Client] An error occured, please rejoin to fix this issue")
			require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("An error occured, please rejoin to fix this issue.",Color3.new(1, 0, 0))
			script.Disabled = true
		end
	end
end)

-- Original size: {30,0,30,0}
-- In-game size = {8,0,8,0}
-- 300+ Combo Size = {5,0,5,0}

if Flashlight == true then
	TweenService:Create(FlashlightFrame,TweenInfo.new(1,Enum.EasingStyle.Linear),{Size = UDim2.new(15,0,15,0),ImageTransparency = 0}):Play()
	ScoreMultiplier.Mod *= 1.12
	script.Parent.PlayFrame.ZIndex = 0
	spawn(function()
		wait(2.5)
		TweenService:Create(FlashlightFrame,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = UDim2.new(8,0,8,0),ImageTransparency = 0}):Play()

		local CurrentCombo = 0
		while wait(0.1) do
			if CurrentCombo ~= Accurancy.Combo then
				CurrentCombo = Accurancy.Combo
				local FLSize = (CurrentCombo <= 300 and 10-((CurrentCombo/300)*5)) or 5

				TweenService:Create(FlashlightFrame,TweenInfo.new(1,Enum.EasingStyle.Linear),{Size = UDim2.new(FLSize,0,FLSize,0)}):Play()
			end
		end
	end)
end

---- Perfomance
local CurrentPerfomance = 0
local HighestPerfomance = 1

local isSpecTimeSet = false
local StartTick = 0
local SpectateDelay = CurrentSetting.VirtualSettings.SpectateDelay.Value
local SpecDelayFrame = game.Players.LocalPlayer.PlayerGui.BG.SpectateDelay
local SpectateGotFirstData = false

function FindForSpectateSignal()
	local UserId = SavedSpectateData.SpectateUID
	local SearchStartTime = tick()
	repeat wait() until game.Players.LocalPlayer.PlayerGui.BG.PlayerListFrame.PlayerList.GetUserStatus:Invoke(UserId,true) == 1 or tick() - SearchStartTime > 10 -- Player need to be out, but there would be some delay
	wait(0.5)
	repeat wait() until game.Players.LocalPlayer.PlayerGui.BG.PlayerListFrame.PlayerList.GetUserStatus:Invoke(UserId,true) == 2
	while wait(0.1) do
		script.Parent.RestartGame.SpectateReturn:Fire(UserId)
	end
end

if isSpectating == true then
	spawn(function()
		SpecDelayFrame.Visible = true
		SpecDelayFrame.DelayDisplay.Text = tostring(SpectateDelay)
		local function ChangeSpecValue(Value)
			SpectateDelay += Value
			if SpectateDelay < 0 then
				SpectateDelay = 0
			elseif SpectateDelay > 10000 then
				SpectateDelay = 10000
			end
			CurrentSetting.VirtualSettings.SpectateDelay.Value = SpectateDelay
			SpecDelayFrame.DelayDisplay.Text = tostring(SpectateDelay).."ms"
		end

		SpecDelayFrame.DelayAdd.MouseButton1Click:Connect(function()
			ChangeSpecValue(500)
		end)
		SpecDelayFrame.DelaySub.MouseButton1Click:Connect(function()
			ChangeSpecValue(-500)
		end)
	end)
	if SpectateRemote then
		SpectateRemote.OnClientEvent:Connect(function(Data)
			if Data == -1 then
				require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("Player you spectate has left, waiting for player to start another play...",Color3.new(1,0,0))
				FindForSpectateSignal()
				return
			end
			local TimeProcess = Data.TimeProcess
			local CurrentSpecTime = Data.SpecTime
			local HostTime = Data.HostTime
			local HostFPS = Data.HostFPS

			if isSpecTimeSet == false then
				isSpecTimeSet = true
				StartTick = tick() - CurrentSpecTime
			else
				if tick() - StartTick < CurrentSpecTime + SpectateDelay/1000 or SpectateDelay <= 0 then
					repeat wait() until tick() - StartTick >= CurrentSpecTime + SpectateDelay/1000 or SpectateDelay <= 0
				end
			end

			script.Parent.PSEarned.Text = tostring(math.floor(Data.InGameData.Perfomance)).."ps"
			CurrentPerfomance = Data.InGameData.Perfomance
			HighestPerfomance = Data.InGameData.HighestPerfomance

			local ServerTick = workspace.ServerStatus.ServerTick.Value
			local HostDelay = math.floor((ServerTick - HostTime)*1000)

			SpecDelayFrame.HostDelay.Text = tostring(HostDelay).."ms"
			SpecDelayFrame.HostFPS.Text = tostring(HostFPS).." FPS"

			Start = tick() - TimeProcess
			SongStart = tick() - TimeProcess
			ScoreResultDisplay = Data.ScoreResult
			SpectateGotFirstData = true



			CursorPosition = Data.Changes.CursorPos
			if Data.Changes.KeyHit then
				if Data.Changes.KeyHit <= 4 then
					script.Parent.MouseHit:Fire(SecurityKey,Data.Changes.KeyHit)
				else
					script.Parent.MouseHitEnd:Fire(SecurityKey,Data.Changes.KeyHit-4)
				end
			end
			local InGameData = Data.InGameData
			Score = InGameData.Score
			Accurancy.h300 = InGameData.Acc[1]
			Accurancy.h100 = InGameData.Acc[2]
			Accurancy.h50 = InGameData.Acc[3]
			Accurancy.miss = InGameData.Acc[4]
			Accurancy.Combo = InGameData.Combo
			Accurancy.MaxCombo = InGameData.MaxCombo
			K1 = InGameData.KeyData[1]-1
			K2 = InGameData.KeyData[2]-1
			K3 = InGameData.KeyData[3]-1
			K4 = InGameData.KeyData[4]-1
			HealthPoint = InGameData.HP
			if InGameData.Failed == true then
				GameOver()
			end
		end)
	end
end
if isSpectating == false and AutoPlay == false then
	--[[
	PlayingRemote.OnClientEvent:Connect(function(Name)
		if typeof(Name) == "String" then
			require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)(Name.." is spectating you",Color3.new(0, 1, 0))
		end
	end)]]
end


script.Parent.MouseHit.Event:Connect(function(CurrentSecurityKey,data)
	if isSpectating == false and AutoPlay == false then
		if #game.Players:GetPlayers() > 1 and not gameEnded then
			PlayingRemote:FireServer({
				StartTime = Start,
				ScoreResult = ScoreResultDisplay,
				TimeProcess = tick()-Start,
				SpecTime = tick() - StartPlayingTick,
				HostFPS = GameplayFPS,
				HostTime = workspace.ServerStatus.ServerTick.Value,
				InGameData = {
					Score = Score,
					Acc = {
						Accurancy.h300,
						Accurancy.h100,
						Accurancy.h50,
						Accurancy.miss
					},
					Combo = Accurancy.Combo,
					MaxCombo = Accurancy.MaxCombo,
					HP = HealthPoint,
					Failed = BeatmapFailed,
					KeyData = {K1,K2,K3,K4},
					Perfomance = CurrentPerfomance,
					HighestPerfomance = HighestPerfomance
				},
				Changes = {
					CursorPos = CursorPosition,
					KeyHit = data
				}
			})
		end
	end
end)

script.Parent.MouseHitEnd.Event:Connect(function(CurrentSecurityKey,data)
	if isSpectating == false and AutoPlay == false then
		if #game.Players:GetPlayers() > 1 and not gameEnded then
			PlayingRemote:FireServer({
				StartTime = Start,
				TimeProcess = tick()-Start,
				SpecTime = tick() - StartPlayingTick,
				ScoreResult = ScoreResultDisplay,
				HostFPS = GameplayFPS,
				HostTime = workspace.ServerStatus.ServerTick.Value,
				InGameData = {
					Score = Score,
					Acc = {
						Accurancy.h300,
						Accurancy.h100,
						Accurancy.h50,
						Accurancy.miss
					},
					Combo = Accurancy.Combo,
					MaxCombo = Accurancy.MaxCombo,
					HP = HealthPoint,
					Failed = BeatmapFailed,
					KeyData = {K1,K2,K3,K4},
					Perfomance = CurrentPerfomance,
					HighestPerfomance = HighestPerfomance
				},
				Changes = {
					CursorPos = CursorPosition,
					KeyHit = data+4
				}
			})
		end
	end
end)

spawn(function()
	if isSpectating == false and AutoPlay == false and onTutorial ~= true then
		local MetaData = ReturnData.Overview.Metadata
		game.ReplicatedStorage.Gameplay.UpdateStatus:FireServer(2,{BeatmapPlaying = MetaData.SongCreator.." - "..MetaData.MapName.." ["..MetaData.DifficultyName.."]"})
		while wait(1/60) do -- record cursor movement at 60FPS
			if #game.Players:GetPlayers() > 1 then
				if gameEnded then
					wait(1)
				end
				spawn(function()
					PlayingRemote:FireServer({
						StartTime = Start,
						TimeProcess = tick()-Start,
						SpecTime = tick() - StartPlayingTick,
						ScoreResult = ScoreResultDisplay,
						HostFPS = GameplayFPS,
						HostTime = workspace.ServerStatus.ServerTick.Value,
						InGameData = {
							Score = Score,
							Acc = {
								Accurancy.h300,
								Accurancy.h100,
								Accurancy.h50,
								Accurancy.miss
							},
							Combo = Accurancy.Combo,
							MaxCombo = Accurancy.MaxCombo,
							HP = HealthPoint,
							Failed = BeatmapFailed,
							KeyData = {K1,K2,K3,K4},
							Perfomance = CurrentPerfomance,
							HighestPerfomance = HighestPerfomance
						},
						Changes = {
							CursorPos = CursorPosition
						}
					})
				end)
			end
		end
	elseif onTutorial == true then
		game.ReplicatedStorage.Gameplay.UpdateStatus:FireServer(5)
	elseif AutoPlay == true and isSpectating == false then
		game.ReplicatedStorage.Gameplay.UpdateStatus:FireServer(4)
	end
end)

local CircleApproachTime = 1200

if ApproachRate < 5 then
	CircleApproachTime = 1200 + 600 * (5 - ApproachRate) / 5
elseif ApproachRate > 5 then
	CircleApproachTime = 1200 - 750 * (ApproachRate - 5) / 5
else
	CircleApproachTime = 1200
end


if SpeedSync == true then
	CircleApproachTime /= SongSpeed
end

-- 1 - 1680 | 10 - 450


--CircleApproachTime = 10000

script.Parent.Song.PlaybackSpeed = SongSpeed * ReturnData.SongSpeed
script.Parent.Song.DefaultPitch.Octave = ReturnData.SongPitch
if SongSpeed >= 0.5 and SongSpeed <= 2 and not KeepOriginalPitch then
	script.Parent.Song.PitchShiftSoundEffect.Octave = 1/SongSpeed
end

local NPS = 0
local VisibleNotes = 0
local Combo = 0



local CurrentComboColor = 1
local LastCirclePos = {X = 0,Y = 0}

--BPM = 1 / BeatLength * 1000 * 60
--[[
spawn(function()
	local BPM = 110
	while wait(60/BPM) do
		for i,Obj in pairs(script.Parent.PlayFrame:GetChildren()) do
			local NewObj
			pcall(function()
				if Obj.Name == "Circle" then
					NewObj = Obj:Clone()
					NewObj.Parent = script.Parent.PlayFrame
					NewObj.ApproachCircle:Destroy()
					NewObj.BackgroundTransparency = 0.75
					NewObj.TextLabel.TextTransparency = 0.5
					NewObj.Circle.ImageTransparency = 0.5

					game:GetService("TweenService"):Create(NewObj,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{BackgroundTransparency = 1,Size = UDim2.new(0.214,0,0.214,0)}):Play()
					game:GetService("TweenService"):Create(NewObj.TextLabel,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{TextTransparency = 1}):Play()
					game:GetService("TweenService"):Create(NewObj.Circle,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
				end
			end)
			spawn(function()
				wait(0.2)
				if Obj.Name == "Circle" then
					NewObj:Destroy()
				end
			end)
		end
	end
end)
]]
local CurrentHitnote = 1


--Autoplay only
local CurrentCursorPos = 1
local MissclickTotal = 0
local MissclickOn50 = 0
local LastClick = 0
local RightClick = true

local KeySession = {
	K1 = "", K2 = ""
}


function AutoClick() 
	ProcessFunction(function()
		if tick() - LastClick > 0.25 then
			RightClick = false
			LastClick = tick()
			script.Parent.MouseHit:Fire(SecurityKey,3)
			local CurrentSession = game.HttpService:GenerateGUID()
			KeySession.K1 = CurrentSession
			wait(0.1)
			if KeySession.K1 == CurrentSession then
				script.Parent.MouseHitEnd:Fire(SecurityKey,3)
			end
		else
			if RightClick == true then
				RightClick = false
				LastClick = tick()
				script.Parent.MouseHit:Fire(SecurityKey,3)
				local CurrentSession = game.HttpService:GenerateGUID()
				KeySession.K1 = CurrentSession
				wait(0.1)
				if KeySession.K1 == CurrentSession then
					script.Parent.MouseHitEnd:Fire(SecurityKey,3)
				end
			else
				RightClick = true
				LastClick = tick()
				local CurrentSession = game.HttpService:GenerateGUID()
				KeySession.K2 = CurrentSession
				script.Parent.MouseHit:Fire(SecurityKey,4)
				wait(0.1)
				if KeySession.K2 == CurrentSession then
					script.Parent.MouseHitEnd:Fire(SecurityKey,4)
				end
			end
		end
	end)
end

local BreakTimeFrame = script.Parent.BreakTimeFrame

spawn(function()
	if isSpectating then
		repeat wait() until SpectateGotFirstData
	end
	local Section = ""
	for _,BreakTime in pairs(ReturnData.BreakTime) do
		repeat wait() until tick() - Start >= BreakTime[1]/1000
		script.Parent.Leaderboard.LbTrigger:Fire(true)
		local CurrentSection = game.HttpService:GenerateGUID()
		Section = CurrentSection
		BreakTimeFrame.Visible = true
		BreakTimeFrame.Size = UDim2.new(0,0,0,0)
		BreakTimeFrame.TimeProgress.BackgroundTransparency = 0
		local Duration = (BreakTime[2] - BreakTime[1])/1000
		TweenService:Create(script.Parent.HitError.CurrentDelay.Delay.Delay,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{TextTransparency = 1}):Play()
		TweenService:Create(script.Parent.HitError.CurrentDelay.Delay.UnstableRate,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{TextTransparency = 1}):Play()
		TweenService:Create(script.Parent.HitError,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{AnchorPoint = Vector2.new(0.5,0)}):Play()
		TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans+0.2}):Play()
		TweenService:Create(workspace.BackgroundPart.SurfaceGui.Frame.BackgroundFrame.ImageFrame.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans+0.2}):Play()
		if BackgroundBlurEnabled == true then
			TweenService:Create(game.Lighting.Blur,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = 15}):Play()
		end
		ProcessFunction(function()
			isDrain = false
			repeat wait() until tick() - Start >= (BreakTime[2]/1000)
			script.Parent.Leaderboard.LbTrigger:Fire(false)
			isDrain = true
			TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans}):Play()
			TweenService:Create(workspace.BackgroundPart.SurfaceGui.Frame.BackgroundFrame.ImageFrame.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans}):Play()
			if BackgroundBlurEnabled == true then
				TweenService:Create(game.Lighting.Blur,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = 0}):Play()
			end
		end)
		if Duration > 3 then
			BreakTimeFrame.Rotation = 20
			--TweenService:Create(BreakTimeFrame,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,0.5,-18)}):Play()
			TweenService:Create(BreakTimeFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(0,400,0,200),Rotation = 0}):Play()
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,true)
			local TotalNoteResult = Accurancy.h300+Accurancy.h100+Accurancy.h50+Accurancy.miss
			local GameAccurancy = math.floor(((Accurancy.h300*300+Accurancy.h100*100+Accurancy.h50*50)/(TotalNoteResult*300))*100*100)/100
			local GameplayRank = "D"
			local percent300s = Accurancy.h300/(Accurancy.h300+Accurancy.h100+Accurancy.h50+Accurancy.miss)
			local percent50s = Accurancy.h50/(Accurancy.h300+Accurancy.h100+Accurancy.h50+Accurancy.miss)
			local misstotal = Accurancy.miss

			local tostringAcc = tostring(GameAccurancy)

			if tostringAcc == "-nan(ind)" or tostringAcc == "inf" or tostringAcc == "100" then
				tostringAcc = "100.00"
			elseif string.sub(tostringAcc,#tostringAcc-1,#tostringAcc-1) == "." then
				tostringAcc = tostringAcc.."0"
			elseif #tostringAcc <= 2 then
				tostringAcc = tostringAcc..".00"
			end
			if tonumber(tostringAcc) < 10 then
				tostringAcc = "0"..tostringAcc
			end

			local RankColor = {
				SS = Color3.fromRGB(255, 255, 0),
				S = Color3.fromRGB(255, 255, 0),
				A = Color3.fromRGB(0, 255, 0),
				B = Color3.fromRGB(0, 85, 255),
				C = Color3.fromRGB(170, 0, 127),
				D = Color3.fromRGB(255, 0, 0)
			}

			local SS = false

			if percent300s >= 0.6 then
				GameplayRank = "C"
			end
			if (percent300s >= 0.7 and misstotal <= 0) or percent300s >= 0.8 then
				GameplayRank = "B"
			end
			if (percent300s >= 0.8 and misstotal <= 0) or percent300s >= 0.9 then
				GameplayRank = "A"
			end
			if percent300s >= 0.9 and misstotal <= 0 and percent50s < 0.01 then
				GameplayRank = "S"
			end
			if GameAccurancy >= 100 then
				GameplayRank = "SS"
				SS = true
			end

			BreakTimeFrame.Accurancy.Text = tostringAcc.."%"
			BreakTimeFrame.RankDisplay.Text = (not SS and GameplayRank) or "S"
			BreakTimeFrame.RankDisplay.TextColor3 = RankColor[GameplayRank] 
			BreakTimeFrame.MaxCombo.Text = tostring(Accurancy.MaxCombo).."x"
			BreakTimeFrame.MissTotal.Text = tostring(Accurancy.miss).." miss"
			BreakTimeFrame.SS_Rank.Visible = SS
			if Accurancy.miss > 0 then
				BreakTimeFrame.MissTotal.TextColor3 = Color3.fromRGB(255, 107, 107)
			else
				BreakTimeFrame.MissTotal.TextColor3 = Color3.fromRGB(255, 255, 255)
			end


			while tick() - Start < (BreakTime[2]/1000)-0.5 do
				wait()
				local TimeElapsed = (tick() - Start) - BreakTime[1]/1000
				local TimeLeft = ((TimeElapsed+0.5 < Duration and (Duration - TimeElapsed)-0.5) or 0)
				local DisplayTime = TimeLeft + 1
				if TimeLeft == 0 then
					DisplayTime = 0
				end
				BreakTimeFrame.TimeDisplay.Text = tostring(math.floor(DisplayTime))
				BreakTimeFrame.TimeProgress.Size = UDim2.new((((TimeLeft)/Duration)*0.9),0,0,5)
			end


			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,not DisableChatInGame)

			spawn(function()
				wait(0.5)
				if Section == CurrentSection then
					BreakTimeFrame.Visible = false
				end
			end)
			TweenService:Create(BreakTimeFrame.TimeProgress,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{BackgroundTransparency = 1}):Play()
			TweenService:Create(BreakTimeFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{Size = UDim2.new(0,0,0,0),Rotation = -20}):Play()
			--TweenService:Create(BreakTimeFrame,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Position = UDim2.new(0.5,0,-1.5,-18)}):Play()
		end
	end
end)


local TotalNotes = 0 
local NoteDisplayLimit = 1024
local BPM = -1
local CurrentSliderMultiplier = 1
local SliderMultiplier = ReturnData.Difficulty.SliderMultiplier
local BPMLoaded = false
local VelocityLoaded = false

-- max 5 timming point

local NextBPM = {
	[1] = {Time = 9e99,Value = 1},
	[2] = {Time = 9e99,Value = 1},
	[3] = {Time = 9e99,Value = 1},
	[4] = {Time = 9e99,Value = 1},
	[5] = {Time = 9e99,Value = 1},
}

local NextSliderMulti = {
	[1] = {Time = 9e99,Value = 1},
	[2] = {Time = 9e99,Value = 1},
	[3] = {Time = 9e99,Value = 1},
	[4] = {Time = 9e99,Value = 1},
	[5] = {Time = 9e99,Value = 1},
}

for _,Timming in pairs(TimingPoints) do
	local BeatLength =  Timming[2]
	if BeatLength / math.abs(BeatLength) == 1 and BPMLoaded == false then
		BPMLoaded = true
		BPM = 1 / BeatLength * 1000 * 60
	elseif VelocityLoaded == false then
		VelocityLoaded = true
		CurrentSliderMultiplier = 1/((-BeatLength)/100)
	else
		break
	end
end

--AccuracyChart

local BeatmapLength = BeatmapData[#BeatmapData].Time
local AvgLength = BeatmapLength/100
local TimeAccurancy = {}
local TimePerfomance = {}

spawn(function()
	for i = 1,101 do
		repeat wait() until (tick() - Start)*1000 > AvgLength*i

		-- Accurancy

		local TotalNoteResult = Accurancy.h300+Accurancy.h100+Accurancy.h50+Accurancy.miss
		local GameAccurancy = math.floor(((Accurancy.h300*300+Accurancy.h100*100+Accurancy.h50*50)/(TotalNoteResult*300))*100*100)/100

		if tostring(GameAccurancy) == "-nan(ind)" then
			GameAccurancy = 100
		end

		local GameplayRank = "D"
		local percent300s = Accurancy.h300/(Accurancy.h300+Accurancy.h100+Accurancy.h50+Accurancy.miss)
		local percent50s = Accurancy.h50/(Accurancy.h300+Accurancy.h100+Accurancy.h50+Accurancy.miss)
		local misstotal = Accurancy.miss

		local SS = false

		if percent300s >= 0.6 then
			GameplayRank = "C"
		end
		if (percent300s >= 0.7 and misstotal <= 0) or percent300s >= 0.8 then
			GameplayRank = "B"
		end
		if (percent300s >= 0.8 and misstotal <= 0) or percent300s >= 0.9 then
			GameplayRank = "A"
		end
		if percent300s >= 0.9 and misstotal <= 0 and percent50s < 0.01 then
			GameplayRank = "S"
		end
		if GameAccurancy >= 100 then
			GameplayRank = "SS"
			SS = true
		end

		local AccurancyPoint = (GameAccurancy-60)/40
		if AccurancyPoint < 0 then
			AccurancyPoint = 0
		end

		TimeAccurancy[i] = {AccurancyPoint,GameplayRank}

		-- Perfomance score

		if CurrentPerfomance > HighestPerfomance then
			HighestPerfomance = CurrentPerfomance
		end
		TimePerfomance[i] = CurrentPerfomance
	end
end)


--TimmingPoints

--local DefaultBackgroundTrans = --[[game.Players.LocalPlayer.PlayerGui.BG.Background.Background.BackgroundDim.BackgroundTransparency]] 0.2
-- BackgroundTrans = 1-(BackgroundDim/100)

spawn(function()
	TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans+0.2}):Play()
	TweenService:Create(workspace.BackgroundPart.SurfaceGui.Frame.BackgroundFrame.ImageFrame.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans+0.2}):Play()
	repeat wait() until tick() - Start > (BeatmapData[1].Time/1000 - 1.2)
	HealthPoint = 100
	TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans}):Play()
	TweenService:Create(workspace.BackgroundPart.SurfaceGui.Frame.BackgroundFrame.ImageFrame.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans}):Play()
	repeat wait() until tick() - Start > (BeatmapData[1].Time/1000)
	isDrain = true
end)

spawn(function()
	for i,TimingData in pairs(TimingPoints) do
		if TimingData ~= nil and #TimingData > 0 then
			repeat wait() until (tick()-Start) >= (TimingData[1]/1000)
			script.HitSound.Volume = TimingData[6]/100*EffectVolume*0.01
			script.HitSoundClap.Volume = TimingData[6]/100*EffectVolume*0.01
			script.HitSoundFinish.Volume = TimingData[6]/100*EffectVolume*0.01
			script.HitSoundWhistle.Volume = TimingData[6]/100*EffectVolume*0.01
			local BeatLength =  TimingData[2]
			if BeatLength / math.abs(BeatLength) == 1 then
				BPM = 1 / BeatLength * 1000 * 60
			else
				CurrentSliderMultiplier = 1/((-BeatLength)/100)
			end

			if i ~= #TimingPoints then
				local SliderMultiCount = 0
				local BPMCount = 0
				for e = 1,20 do
					local NextTimmingPoint = TimingPoints[i+e]
					if NextTimmingPoint ~= nil then
						local NextTimmingPointTime = NextTimmingPoint[1]
						local NextBeatLength = NextTimmingPoint[2]

						if NextBeatLength / math.abs(NextBeatLength) == 1 then
							BPMCount += 1
							NextBPM[BPMCount] = {
								Time = NextTimmingPointTime,
								Value = 1 / NextBeatLength * 1000 * 60
							}
						else
							SliderMultiCount += 1
							NextSliderMulti[SliderMultiCount] = {
								Time = NextTimmingPointTime,
								Value = 1/((-NextBeatLength)/100)
							}
						end
					else
						break
					end

					for i = SliderMultiCount,20 do
						NextSliderMulti[i] = {Time = 9e99,Value = 1}
					end
					for i = BPMCount,5 do
						NextBPM
						[i] = {Time = 9e99,Value = 1}
					end
				end
			end

			local Positive = BeatLength/math.abs(BeatLength)
			if Positive > 0 then -- there's no way Positive = 0
				local BPM = (1 / BeatLength * 1000 * 60)*SongSpeed
				script.Parent.BPMTick.Disabled = true
				script.Parent.BPMTick.BPM.Value = BPM
				script.Parent.BPMTick.Disabled = false
			end
			if TimingData[8] == 1 then
				if Flashlight == false and DefaultBackgroundTrans > 0 then
					spawn(function()
						TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans+0.2}):Play()
						TweenService:Create(workspace.BackgroundPart.SurfaceGui.Frame.BackgroundFrame.ImageFrame.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans+0.2}):Play()
						wait(0.1)
						TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans}):Play()
						TweenService:Create(workspace.BackgroundPart.SurfaceGui.Frame.BackgroundFrame.ImageFrame.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans}):Play()
					end)
				end
				script.Parent.BPMTick.KiaiTime.Value = true
			else
				script.Parent.BPMTick.KiaiTime.Value = false
			end
		end
	end
end)

script.Parent.SpinnerScore.Event:Connect(function(SpinnerScore)
	Score += SpinnerScore
	AddHP(DrainSpeed*0.75)
end)
--[[
spawn(function()
	if AutoPlay == true and ReplayMode ~= true then
		local RPM = 500	
		TweenService:Create(script.Parent.ATSpinner.SpinPart,TweenInfo.new(1/RPM,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,math.huge),{Orientation = Vector3.new(0,--[[(RPM/60)*2592000360,0)}):Play()
	end
end)]]

local SpinStart = tick()
local RPM = 500	

if AutoPlay then
	game:GetService("RunService").Stepped:Connect(function()
		local TimeElapsed = tick() - SpinStart
		local Rotation = (TimeElapsed - math.floor(TimeElapsed))*360*(RPM/60)
		script.Parent.ATSpinner.SpinPart.Orientation = Vector3.new(0,Rotation,0)
	end)
end

--[[
Cursor.Changed:Connect(function()
	if isSpectating == true or PlayRanked == false then return end
	if (math.abs(Cursor.Position.X.Scale) > 1000 or math.abs(Cursor.Position.Y.Scale) > 1000 ) and AutoPlay == false then
		PlayRanked = false
		game.Players.LocalPlayer.PlayerGui.BG.UnrankedSign.Visible = true
		require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("Detected some suspicous activity on your play, your account has been unranked. The report has been sent to the developer.",Color3.new(1, 0, 0))
		Reporter:FireServer(game.Players.LocalPlayer.Name,game.Players.LocalPlayer.UserId,2)
	end
end)]]


if isSpectating == true then
	repeat wait() until Start ~= tick()+2
end

--------    Perfomance score - This will effect alot on player's online rank

local PSPunishment = 0 -- Limit: [0,TotalNote*10] Each miss will add 50 point on it, getting 300s will reduce 1 point
local PSPunishmentLimit = #BeatmapData*10
local PSPunishmentMin = 0 -- Each miss will add 5 point on this, this thing CAN NOT be recovered

-- AccuracyPS
local MaxAccurancyPS = ReturnData.Difficulty.BeatmapDifficulty * 12


-- GameplayPS
-- Higher ps, more ps will reward. This thing work like top play of osu

local AimPSList = {0}
local StreamPSList = {0}
local RecentPerfomanceList = {}
local AimRecentPerfomanceList = {}
local OverallPSList = {}
local ExtraPerfomance = 0

local Missed = false -- If turn on, pp based on combo will enabled

if PSDisplay == true then
	script.Parent.PSEarned.Visible = true
end

function AddPerfomanceScore(AimPS,StreamPS,Multiplier)
	local DefaultMultiplier = 100
	AimPS *= DefaultMultiplier
	StreamPS *= DefaultMultiplier
	local PerfomanceKey = game.HttpService:GenerateGUID()
	local JugdementCombo = (Accurancy.Combo < 20 and Missed and Accurancy.Combo) or 20
	if tonumber(Multiplier) == nil then Multiplier = 1 end
	local DefaultMultiplier = 0.851737 -- due to the recent update difficulty multiplier
	AimPS *= DefaultMultiplier
	StreamPS *= DefaultMultiplier

	-- this thing to prevent spamming keys and get free PS. Miss = lost alot of ps
	AimPS = AimPS * Multiplier * 0.75^(20-JugdementCombo)
	StreamPS = StreamPS * Multiplier * 0.75^(20-JugdementCombo)
	local OverallPS = (AimPS*2+StreamPS) * 0.75^(20-JugdementCombo)

	local PunishmentRatio = PSPunishment/PSPunishmentLimit

	-- New perfomance

	--[[
	
	-- Stream [New]

	local RecentPerfomance = 0
	local TopPerfomance = {}
	for _,CurrentPerfomance in pairs(RecentPerfomanceList) do
		table.insert(TopPerfomance,1,CurrentPerfomance)
	end
	table.sort(TopPerfomance,function(a,b) return a>b end)

	table.insert(TopPerfomance,1,StreamPS)
	table.sort(TopPerfomance,function(a,b) return a>b end)

	for Top,Perfomance in pairs(TopPerfomance) do
		RecentPerfomance += Perfomance * 0.7^(Top-1)
	end

	local StreamPerfomance = RecentPerfomance/700

	-- Aim [New]

	local AimRecentPerfomance = 0
	local TopPerfomance = {}
	for _,CurrentPerfomance in pairs(AimRecentPerfomanceList) do
		table.insert(TopPerfomance,1,CurrentPerfomance)
	end
	table.sort(TopPerfomance,function(a,b) return a>b end)

	table.insert(TopPerfomance,1,AimPS)
	table.sort(TopPerfomance,function(a,b) return a>b end)

	for Top,Perfomance in pairs(TopPerfomance) do
		AimRecentPerfomance += Perfomance * 0.7^(Top-1)
	end

	--

	local AimPerfomance = AimRecentPerfomance/300
	AimPerfomance = 0]]

	if Multiplier == 0 then
		if not HardCore then
			PSPunishment += 100
			ExtraPerfomance -= 30
			PSPunishmentMin += 25
		else
			PSPunishment += 50
			ExtraPerfomance -= 10
			PSPunishmentMin += 5
		end
	elseif Multiplier == 1/6 then
		if PunishmentRatio >= 1-1/6 then
			if not HardCore then
				PSPunishment += 70
				PSPunishmentMin += 10
				ExtraPerfomance -= 10
			else
				PSPunishment += 35
				PSPunishmentMin += 2
				ExtraPerfomance -= 2
			end
		end
		--ExtraPerfomance += (AimPerfomance + StreamPerfomance)/6
	elseif Multiplier == 1/3 then
		if PunishmentRatio >= 1-1/3 then
			if not HardCore then
				PSPunishment += 55
				PSPunishmentMin += 1
				ExtraPerfomance -= 5
			else
				PSPunishment += 25
			end
		end
		--ExtraPerfomance += (AimPerfomance + StreamPerfomance)/3
	elseif Multiplier == 1 then
		--ExtraPerfomance += (AimPerfomance + StreamPerfomance)
		PSPunishment -= 1
	end

	if ExtraPerfomance < 0 then
		ExtraPerfomance = 0
	end

	if PSPunishment > PSPunishmentLimit then
		PSPunishment = PSPunishmentLimit
	elseif PSPunishment < PSPunishmentMin then
		PSPunishment = PSPunishmentMin
	end

	local Top = #AimPSList + 1
	--[[
	for T,TopPS in pairs(AimPSList) do
		if AimPS > TopPS then
			Top = T
			break
		end 
	end]]
	if AimPS > 0 then
		--table.insert(AimPSList,1,AimPS)
		AimPSList[#AimPSList+1] = AimPS
		table.sort(AimPSList,function(ps1,ps2) return ps1 > ps2 end)
	end

	if StreamPS > 0 then
		--table.insert(StreamPSList,1,StreamPS)
		StreamPSList[#StreamPSList+1] = StreamPS
		table.sort(StreamPSList,function(ps1,ps2) return ps1 > ps2 end)
	end

	--[[

	if OverallPS > 0 then
		table.insert(OverallPSList,1,OverallPS)
		table.sort(OverallPSList,function(ps1,ps2) return ps1 > ps2 end)
	end]]

	-- print result for test
	local TotalNoteResult = Accurancy.h300+Accurancy.h100+Accurancy.h50+Accurancy.miss
	local acc = ((Accurancy.h300*300+Accurancy.h100*100+Accurancy.h50*50)/(TotalNoteResult*300))*100

	local RewaredAccPS = MaxAccurancyPS* 0.727^(100-acc) -- get whole accurancy
	local RewaredAimPS = 0
	local RewaredStreamPS = 0
	local RewaredOverallPS = 0

	local AimClearNum = -1
	local StreamClearNum = -1

	for Top,AimPS in pairs(AimPSList) do
		if AimPS*0.8^(Top-1) < 0.001 then
			AimClearNum = Top
			break
		end
		RewaredAimPS += AimPS*0.8^(Top-1)
	end

	for i = #AimPSList,1,-1 do
		if AimPSList[i]*0.8^(i-1) < 0.001 then
			AimPSList[i] = nil
		else
			break
		end
	end

	for Top,StreamPS in pairs(StreamPSList) do
		if StreamPS*0.8^(Top-1) < 0.001 then
			StreamClearNum = Top
			break
		end
		RewaredStreamPS += StreamPS*0.8^(Top-1)
	end

	for i = #StreamPSList,1,-1 do
		if StreamPSList[i]*0.8^(i-1) < 0.001 then
			StreamPSList[i] = nil
		else
			break
		end
	end
	--[[
	for Top,OverallPS in pairs(OverallPSList) do
		RewaredOverallPS += OverallPS*0.9025^(Top-1)
	end]]

	local ComboPerfomanceMultiplier = 1 --1*0.25^((1-(Accurancy.MaxPeromanceCombo/GameMaxCombo))*2)

	RewaredAimPS = RewaredAimPS * (1 - (PSPunishment/PSPunishmentLimit)) * ComboPerfomanceMultiplier
	RewaredStreamPS = RewaredStreamPS * (1 - (PSPunishment/PSPunishmentLimit)) * ComboPerfomanceMultiplier

	local AimStreamPS = AimPS + StreamPS

	local TotalRewardedPS =  RewaredStreamPS + RewaredAccPS + RewaredAimPS
	local BetaPS = RewaredOverallPS + RewaredAccPS

	if Flashlight == true then
		TotalRewardedPS *= 1.12
		BetaPS *= 1.12
	end

	if HiddenMod then
		TotalRewardedPS *= 1.06
		BetaPS *= 1.06
	end

	if HardRock then
		TotalRewardedPS *= 1.06
		BetaPS *= 1.06
	end

	CurrentPerfomance = TotalRewardedPS

	--TotalRewardedPS = 2^(TotalRewardedPS^(1/3.23))
	local NewPerfomanceText = ""

	if NewPerfomanceDisplay == true then
		local ExtraPerfomance = ExtraPerfomance * (1 - (PSPunishment/PSPunishmentLimit))
		--NewPerfomanceText = "(BetaPS: "..tostring(math.floor((ExtraPerfomance + RewaredAimPS + RewaredAccPS)*((Flashlight and 1.12) or 1))).."ps)"
		NewPerfomanceText = "(BetaPS: "..tostring(math.floor(BetaPS)).."ps)"
	end

	if not isSpectating then
		script.Parent.PSEarned.Text = tostring(math.floor(TotalRewardedPS)).."ps "..NewPerfomanceText
	end


	ProcessFunction(function()
		RecentPerfomanceList[PerfomanceKey] = StreamPS
		AimRecentPerfomanceList[PerfomanceKey] = AimPS
		wait(1)
		RecentPerfomanceList[PerfomanceKey] = 0
		AimRecentPerfomanceList[PerfomanceKey] = 0
	end)
end


local LastHitError = 0

ProcessFunction(function()
	while wait() do
		local HitElapsed = (tick() - LastHitError)
		if HitElapsed > 2 and script.Parent.HitError.CurrentDelay.Delay.Delay.TextTransparency == 0 then
			TweenService:Create(script.Parent.HitError.CurrentDelay.Delay.Delay,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{TextTransparency = 1}):Play()
			TweenService:Create(script.Parent.HitError.CurrentDelay.Delay.UnstableRate,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{TextTransparency = 1}):Play()
			TweenService:Create(script.Parent.HitError,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{AnchorPoint = Vector2.new(0.5,0)}):Play()
			wait(0.5)
		end
	end
end)

TotalHit = 0
TotalUnstableTime = 0
LastHit = 0

function CreateHitDelay(Color,HitDelay)
	local Pos = (HitDelay+hit50)/(hit50*2)
	TweenService:Create(script.Parent.HitError,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(0.5,1)}):Play()
	TweenService:Create(script.Parent.HitError.CurrentDelay.Delay.Delay,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(Pos,0,0.5,0),TextTransparency = 0}):Play()
	TweenService:Create(script.Parent.HitError.CurrentDelay.Delay.UnstableRate,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{TextTransparency = 0}):Play()
	LastHitError = tick()

	TotalHit += 1

	if TotalHit > 1 then
		local LocalUnstableRate = math.abs(HitDelay)
		TotalUnstableTime += LocalUnstableRate

		local UnstableRate = (TotalUnstableTime/(TotalHit-1))*10
		script.Parent.HitError.CurrentDelay.Delay.UnstableRate.Text = tostring(math.floor(UnstableRate))
	end
	LastHit = HitDelay

	local NewHitDelay = script.NoteDelay:Clone()
	NewHitDelay.Parent = script.Parent.HitError
	NewHitDelay.Position = UDim2.new(Pos,0,0.5,0)
	NewHitDelay.BackgroundColor3 = Color
	ProcessFunction(function()
		game:GetService("TweenService"):Create(NewHitDelay,TweenInfo.new(10,Enum.EasingStyle.Linear),{BackgroundTransparency = 1}):Play()
		wait(10)
		NewHitDelay:Destroy()
	end)
end

--warn((tick()-Start)*1000 - HitObj.Time,hit50)






local FramePerSec = 0

game:GetService("RunService").Stepped:Connect(function()
	FramePerSec += 1
	wait(1)
	FramePerSec -= 1
end)


local MetaDataFrame = script.Parent.MetaData

spawn(function()
	wait(0.5)
	MetaDataFrame.Artist.Text = ReturnData.Overview.Metadata.SongCreator
	MetaDataFrame.SongName.Text = ReturnData.Overview.Metadata.MapName

	local _1 = TweenInfo.new(1.5,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out)
	local _2 = TweenInfo.new(1.5,Enum.EasingStyle.Exponential,Enum.EasingDirection.In)


	TweenService:Create(MetaDataFrame,_1,{Position = UDim2.new(0,0,1,-50)}):Play()
	TweenService:Create(MetaDataFrame.Artist,_1,{TextTransparency = 0}):Play()
	TweenService:Create(MetaDataFrame.SongName,_1,{TextTransparency = 0}):Play()
	wait(3.5)
	TweenService:Create(MetaDataFrame,_2,{Position = UDim2.new(0,50,1,-50)}):Play()
	TweenService:Create(MetaDataFrame.Artist,_2,{TextTransparency = 1}):Play()
	TweenService:Create(MetaDataFrame.SongName,_2,{TextTransparency = 1}):Play()
end)

isLoaded = true

------------------------------
-- osu!RoVer gameplay start here

local DisplayingHitnote = {}

local ReplayData = {
	PositionData = {},
	ClickData = {K1={},K2={},K3={},K4={}}
}

local ReplayDataValue = script.Parent.GameplayData.CurrentReplayData
ReplayDataValue.Value = game.HttpService:JSONEncode(ReplayData)
--[[
game.ReplicatedStorage.UserReplaySaves.ControlRemote.ReplayUpload:FireServer(1,CurrentKey.."-"..tostring(game.Players.LocalPlayer.UserId))

function UploadReplay(Method,Data1,Data2,Data3)
	game.ReplicatedStorage.UserReplaySaves.ControlRemote.ReplayUpload:FireServer(Method,Data1,Data2,Data3)
end

ProcessFunction(function()
	while wait(1) do
		local FileSize = game.ReplicatedStorage.UserReplaySaves.ControlRemote.GetCurrentReplaySize:InvokeServer()
		script.Parent.ReplayDataStatusDisplay.Text = "Replay file size: "..tostring(math.floor(FileSize/1024)).."Kb"
	end
end)

ProcessFunction(function()
	local PastPosition = UDim2.new(0,0,0,0)
	while wait(1/60) do
		local CurrentTime = math.floor((tick() - Start)*1000+0.5)
		local CursorPosition = Cursor.Position
		if PastPosition ~= CursorPosition then
			local DecodedPosition = {X=math.floor(CursorPosition.X.Scale*512+0.5),Y=math.floor(CursorPosition.Y.Scale*384+0.5)}

			local FullData = {P = DecodedPosition,T = CurrentTime}
			UploadReplay(2,FullData,1)
		end
		PastPosition = CursorPosition
	end
end)

script.Parent.MouseHit.Event:Connect(function(_,KeyHit)
	local CurrentTime = math.floor((tick() - Start)*1000+0.5)
	local FullData = {H = true,T = CurrentTime}
	
	UploadReplay(2,FullData,2,KeyHit)
end)

script.Parent.MouseHitEnd.Event:Connect(function(_,KeyHit)
	local CurrentTime = math.floor((tick() - Start)*1000+0.5)
	local FullData = {H = false,T = CurrentTime}
	
	UploadReplay(2,FullData,2,KeyHit)
end)]]



--[[ 
	{
		[HitnoteId] = {X = (...),Y = (...), Id = HitnoteId, Time = time},
		[HitnoteId2] = (...)
	}
	
	Added if they are ready to be display
	Removed if they are hitted/missed
]]

-- Current combo note data

local ComboNoteData = {
	Missor50 = false,
	Full300 = true
}

LastNoteData = "NotLoaded"
CurrentNoteId = ""

local EstimatedTotalScore = 0

for i = 1,#BeatmapData do
	EstimatedTotalScore += 300 + (300 * ((((i > 2 and i-2) or 0) * ScoreMultiplier.Difficulty * 1) / 25))
end

if onTutorial then
	script.Parent.Storyboard.TutorialStoryboard.StoryboardScript.LocalScript.Disabled = false
	script.Parent.Leaderboard.Visible = false
end

-- when all loaded, reset the timer
Start = tick()+3
SongStart = tick()+3


for i,HitObj in pairs(BeatmapData) do
	local HitNoteID = i
	local HitMiss = false
	local Is = false
	local isLastComboNote = false
	local AnimationIdList = {}
	local SliderATKey = 3

	if HardRock then
		HitObj.Position = {X = HitObj.Position.X,Y=384-HitObj.Position.Y}
	end

	local NoteId = game.HttpService:GenerateGUID()

	function AddHitnoteAnimation(TweenAnimation)
		if not TweenAnimation:IsA("Tween") then
			return TweenAnimation
		end
		local AnimationId = game.HttpService:GenerateGUID(false)
		local order = #AnimationIdList+1
		AnimationIdList[order] = AnimationId
		HitnoteAnimations[AnimationId] = TweenAnimation
		TweenAnimation.Completed:Connect(function()
			HitnoteAnimations[AnimationId] = nil
			table.remove(AnimationIdList,order)
		end)
		return TweenAnimation
	end

	local CurrentType = HitObj.Type
	if CurrentType == 8 or CurrentType == 12 or math.floor((CurrentType-28)/16) == (CurrentType-28)/16 then
		repeat wait() until (tick()-Start) >= (HitObj.Time-500)/1000
	else
		if i == 1 then
			repeat wait() until (tick()-Start) >= (HitObj.Time-CircleApproachTime)/1000
		elseif (tick()-Start)*1000 < HitObj.Time-CircleApproachTime or NPS >= 60 then
			wait((HitObj.Time-CircleApproachTime)/1000 - (tick()-Start))
		end
		if TotalNotes > NoteDisplayLimit then
			repeat wait() until TotalNotes <= NoteDisplayLimit
		end
	end


	local Type = HitObj.Type -- Will be useful

	if Type ~= 1 and Type ~= 2 and Type ~= 8 then
		Combo = 1
		ComboNoteData = {Full300 = true,Missor50 = false}
		if CurrentComboColor >= #ComboColor then
			CurrentComboColor = 1
		else
			CurrentComboColor += 1
		end
		if Type <= 12 then
			if Type == 5 then Type = 1
			elseif Type == 6 then Type = 2
			elseif Type == 12 then Type = 8
			end
		else
			for i = 1,#ComboColor do
				if Type == 21 + 16*(i-1) then
					Type = 1
					break
				elseif Type == 22 + 16*(i-1) then
					Type = 2
					break
				elseif Type == 28 + 16*(i-1) then
					Type = 8
					break
				else
					if CurrentComboColor >= #ComboColor then
						CurrentComboColor = 1
					else
						CurrentComboColor += 1
					end
				end
			end
			if CurrentComboColor >= #ComboColor then
				CurrentComboColor = 1
			else
				CurrentComboColor += 1
			end
		end
	else
		Combo += 1
	end

	if Type ~= 8 then
		DisplayingHitnote[HitNoteID] = {X = HitObj.Position.X,Y = HitObj.Position.Y, Id = HitNoteID, Time = HitObj.Time}
	end

	TotalNotes += 1
	ProcessFunction(function()

		if isSpectating == true and tick() - Start > (HitObj.Time+hit50)/1000 then
			Combo = 1
			CurrentCursorPos = HitNoteID + 1
			CurrentHitnote = HitNoteID + 1
			TotalNotes -= 1
			return
		end
		if HitObj.Time < -1550 then
			local Type = HitObj.Type
			if Type ~= 1 and Type ~= 2 and Type ~= 8 then
				Combo = 1
				if CurrentComboColor >= #ComboColor then
					CurrentComboColor = 1
				else
					CurrentComboColor += 1
				end
				if Type <= 12 then
					if Type == 5 then Type = 1
					elseif Type == 6 then Type = 2
					elseif Type == 12 then Type = 8
					end
				else
					for i = 1,#ComboColor do
						if Type == 21 + 16*(i-1) then
							Type = 1
							break
						elseif Type == 22 + 16*(i-1) then
							Type = 2
							break
						elseif Type == 28 + 16*(i-1) then
							Type = 8
							break
						else
							if CurrentComboColor >= #ComboColor then
								CurrentComboColor = 1
							else
								CurrentComboColor += 1
							end
						end
					end
					if CurrentComboColor >= #ComboColor then
						CurrentComboColor = 1
					else
						CurrentComboColor += 1
					end
				end
			else
				Combo += 1
			end
			Combo = 1
			CurrentCursorPos = HitNoteID + 1
			CurrentHitnote = HitNoteID + 1
			TotalNotes -= 1
			return
		end



		if Type == 8 then -- Spinner
			if AutoPlay == true and ReplayMode ~= true then
				local SpinKey = 3
				ProcessFunction(function() -- auto spin (beta)
					if HitMiss == true then
						CurrentCursorPos = HitNoteID + 1
						return
					end
					repeat wait() until (tick() - Start) >= HitObj.Time/1000
					local SpinnerTime = (HitObj.SpinTime - HitObj.Time)/1000
					if tick() - LastClick > 0.25 then
						RightClick = false
						LastClick = tick()
						script.Parent.MouseHit:Fire(SecurityKey,3)
						SpinKey = 3
						local CurrentSession = game.HttpService:GenerateGUID()
						KeySession.K1 = CurrentSession
					else
						if RightClick == true then
							RightClick = false
							LastClick = tick()
							script.Parent.MouseHit:Fire(SecurityKey,3)
							SpinKey = 3
							local CurrentSession = game.HttpService:GenerateGUID()
							KeySession.K1 = CurrentSession
						else
							RightClick = true
							LastClick = tick()
							script.Parent.MouseHit:Fire(SecurityKey,4)
							SpinKey = 4
							local CurrentSession = game.HttpService:GenerateGUID()
							KeySession.K2 = CurrentSession
						end
					end
					local Connection = script.Parent.ATSpinner.SpinPart.Changed:Connect(function()
						local LookVector = script.Parent.ATSpinner.SpinPart.CFrame.LookVector
						local Pos = UDim2.new(((256+(LookVector.X*128)))/512,0,((192+(LookVector.Z*96)))/384,0)
						TweenService:Create(script.Parent.GameplayData.ATVC,TweenInfo.new(0,Enum.EasingStyle.Linear),{Position = Pos}):Play()
					end)
					wait(SpinnerTime-0.1)
					Connection:Disconnect()
					wait(0.1)
					script.Parent.MouseHitEnd:Fire(SecurityKey,SpinKey)
					CurrentCursorPos = HitNoteID + 1
				end)
			end


			ProcessFunction(function()
				repeat wait() until CurrentHitnote == HitNoteID
				CurrentHitnote = HitNoteID + 1
			end)


			local Spinner = script.SpinnerFrame:Clone()
			Spinner.Parent = script.Parent.PlayFrame
			Spinner.ZIndex = ZIndex

			ZIndex -= 1

			local SpinnerTime = (HitObj.SpinTime - HitObj.Time)/1000
			local RoundRequiredPerSec = 5

			RoundRequiredPerSec = 5/3


			local RoundRequired = SpinnerTime*RoundRequiredPerSec -- 100 RPM avg for 300s, 75 for 100s, 50 for 50s, else = miss

			Spinner.SpinTime.Value = SpinnerTime
			Spinner.RoundRequired.Value = RoundRequired
			Spinner.SpinnerSpeed.Value = SongSpeed
			Spinner.Spinner.SpinnerScript.Disabled = false


			wait(SpinnerTime+0.5)

			local Ratio = Spinner.Spinner.RoundSpinned.Value/Spinner.RoundRequired.Value


			local function CreateHitResult(HitResult)
				ProcessFunction(function()
					local FrameList = {
						[1] = script.HitMiss,
						[2] = script.Hit50,
						[3] = script.Hit100}

					local NewHitResult = FrameList[HitResult]:Clone()
					NewHitResult.Parent = script.Parent.PlayFrame
					NewHitResult.ZIndex = ZIndex
					if HitResult ~= 1 then
						NewHitResult.Size = UDim2.new((CircleSize/384)*0.6,0,(CircleSize/384)*0.6,0)
						NewHitResult.Position = UDim2.new(0.5,0,0.5,0)
						AddHitnoteAnimation(TweenService:Create(NewHitResult,TweenInfo.new(0.1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(((CircleSize*4/3)/384)*1,0,((CircleSize*4/3)/384)*1,0)})):Play()
						wait(0.5)
						if BeatmapFailed then return end
						AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(0.2,Enum.EasingStyle.Linear),{ImageTransparency = 1})):Play()
						wait(0.2)
						if BeatmapFailed then return end
						NewHitResult:Destroy()
					else
						NewHitResult.Size = UDim2.new(0.5,0,0.5,0)
						NewHitResult.Image.ImageTransparency = 0.5
						NewHitResult.Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0)
						local CurrentRotation = math.random(-10,10)
						local Positive = CurrentRotation/math.abs(CurrentRotation)
						NewHitResult.Rotation = CurrentRotation
						local CurrentPos = NewHitResult.Position
						AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{ImageTransparency = 0,Size = UDim2.new((CircleSize/384),0,(CircleSize/384),0)})):Play()
						wait(0.1)
						if BeatmapFailed then return end
						AddHitnoteAnimation(TweenService:Create(NewHitResult,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Rotation = CurrentRotation+(Positive*15),Position = CurrentPos+UDim2.new(0,0,0.15,0)})):Play()
						AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{ImageTransparency = 1})):Play()
						wait(1)
						if BeatmapFailed then return end
						NewHitResult:Destroy()
					end
				end)
			end

			local function AddScore(HitValue)
				local Combo = Accurancy.Combo
				Score += HitValue + (HitValue * ((((Combo > 2 and Combo-2) or 0) * ScoreMultiplier.Difficulty * ScoreMultiplier.Mod) / 25))
			end


			if Ratio >= 0.5 then
				Accurancy.Combo += 1
				Accurancy.PerfomanceCombo += 1 
				if Accurancy.PerfomanceCombo > Accurancy.MaxPeromanceCombo then
					Accurancy.MaxPeromanceCombo = Accurancy.PerfomanceCombo
				end
				if Accurancy.Combo > Accurancy.MaxCombo then
					Accurancy.MaxCombo = Accurancy.Combo
				end
				spawn(function()
					local Sound = script.HitSound:Clone()
					Sound.Parent = script.Parent.HitSounds
					Sound.Playing = true
					wait(0.208)
					Sound:Destroy()
				end)
				if Ratio >= 1 then
					Accurancy.h300 += 1
					--CreateHitResult(4)
					AddScore(300)
					AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,1)
				elseif Ratio >= 0.75 then
					Accurancy.h100 += 1
					CreateHitResult(3)
					AddScore(100)
					AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,1/3)
				else
					Accurancy.h50 += 1
					CreateHitResult(2)
					AddScore(50)
					AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,1/6)
				end
			else
				if Accurancy.Combo >= 20 then
					script.Parent.ComboBreak:Play()
				end
				Accurancy.Combo = 0
				Accurancy.PerfomanceCombo = 0
				Missed = true
				AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,0)
				Accurancy.miss += 1
				CreateHitResult(1)
				HitMiss = true
			end

			wait(1)
			Spinner:Destroy()
		else -- HitNote and Slider
			LastNoteData = {Slider = false}
			if AutoPlay == true and ReplayMode ~= true then --auto play time
				ProcessFunction(function()
					if (CurrentCursorPos < HitNoteID or CurrentHitnote < HitNoteID) and (tick() - Start)*1000 <= HitObj.Time then
						repeat wait() until CurrentCursorPos >= HitNoteID and CurrentHitnote >= HitNoteID
					end
					if HitMiss == true then
						CurrentCursorPos = HitNoteID + 1
						return
					end
					if CurrentHitnote < HitNoteID then
						repeat wait() until CurrentHitnote >= HitNoteID
					end
					local TimeUntilNoteClicked = (tick() - Start)*1000 - (HitObj.Time)
					local TimeWithAR = TimeUntilNoteClicked - CircleApproachTime
					local CursorTweenTime = math.abs((TimeWithAR > 0 and 0) or (TimeWithAR > -500 and -TimeWithAR) or 500)
					if TimeUntilNoteClicked < 0  then
						wait((-TimeUntilNoteClicked-CursorTweenTime)/1000)
					end
					-- Recaculate after a wait to prevent high delay
					local TimeUntilNoteClicked = (tick() - Start)*1000 - (HitObj.Time)
					local CursorTweenTime = math.abs((TimeUntilNoteClicked > 0 and 0) or (TimeUntilNoteClicked > -500 and -TimeUntilNoteClicked) or 500)
					local AvgFrameTime = (1/FramePerSec)*1000
					if CursorTweenTime > AvgFrameTime then
						game:GetService("TweenService"):Create(script.Parent.GameplayData.ATVC,TweenInfo.new(CursorTweenTime/1000,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0)}):Play()
					else -- if TweenTime <= 17ms then not gonna tween
						script.Parent.GameplayData.ATVC.Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0)
					end
					if CursorTweenTime > AvgFrameTime and (tick()-Start) <= (HitObj.Time + hit300)/1000 then
						wait(CursorTweenTime/1000)
					end
					CurrentNoteId = NoteId
					if Type ~= 2 or not SliderMode then
						AutoClick()
					else
						if tick() - LastClick > 0.25 then
							RightClick = false
							LastClick = tick()
							script.Parent.MouseHit:Fire(SecurityKey,3)
							SliderATKey = 3
							local CurrentSession = game.HttpService:GenerateGUID()
							KeySession.K1 = CurrentSession
						else
							if RightClick == true then
								RightClick = false
								LastClick = tick()
								script.Parent.MouseHit:Fire(SecurityKey,3)
								SliderATKey = 3
								local CurrentSession = game.HttpService:GenerateGUID()
								KeySession.K1 = CurrentSession
							else
								RightClick = true
								LastClick = tick()
								script.Parent.MouseHit:Fire(SecurityKey,4)
								SliderATKey = 4
								local CurrentSession = game.HttpService:GenerateGUID()
								KeySession.K2 = CurrentSession
							end
						end
					end
				--[[
				wait(HitObj.Time/1000 - (tick() - Start))
				spawn(function() --Check if the bot missclick
					wait(((HitObj.Time+hit300)/1000) - (tick() - Start))
					if CurrentHitnote == HitNoteID then --If missclick then the bot will return to the note
						game:GetService("TweenService"):Create(Cursor,TweenInfo.new(0,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0)}):Play()
						AutoClick()
					end
				end)]]
					if Type ~= 2 or SliderMode == false then
						CurrentCursorPos = HitNoteID + 1
					end
				end)
			end

			local Connection


			ProcessFunction(function()
				if BeatmapData[i+1] ~= nil and (BeatmapData[i+1].Type == 1 or BeatmapData[i+1].Type == 2) then
					local NextHitObj = BeatmapData[i+1]
					local HitObjPos = Vector2.new(HitObj.Position.X,HitObj.Position.Y)

					local NextHitObjPos = Vector2.new(NextHitObj.Position.X,NextHitObj.Position.Y)
					if HardRock then
						NextHitObjPos = Vector2.new(NextHitObj.Position.X,384-NextHitObj.Position.Y)
					end
					local Point = HitObjPos-NextHitObjPos
					local Rotation = math.deg(math.atan2(Point.Y,Point.X))

					local LookVector = Vector2.new(0,0)
					local VectorDistance = NextHitObjPos - HitObjPos

					if math.abs(VectorDistance.X) > math.abs(VectorDistance.Y) then
						LookVector = Vector2.new(VectorDistance.X/math.abs(VectorDistance.X),VectorDistance.Y/math.abs(VectorDistance.X))
					else
						LookVector = Vector2.new(VectorDistance.X/math.abs(VectorDistance.Y),VectorDistance.Y/math.abs(VectorDistance.Y))
					end

					LookVector *= (CircleSize/2)


					-- check

					if math.abs((HitObjPos-NextHitObjPos).magnitude) > CircleSize then

						Connection = script.Connection:Clone()
						local Pos = (HitObjPos+NextHitObjPos)/2
						local Size = math.abs((HitObjPos-NextHitObjPos).magnitude)-(CircleSize)
						local FirstPos = UDim2.new((HitObjPos.X+LookVector.X)/512,0,(HitObjPos.Y+LookVector.Y)/384,0)

						local EndPos = UDim2.new((NextHitObjPos.X-LookVector.X)/512,0,(NextHitObjPos.Y-LookVector.Y)/384,0)

						local Pos = UDim2.new(Pos.X/512,0,Pos.Y/384,0)
						local Size = UDim2.new(Size/512,0,0,2)

						Connection.Parent = script.Parent.PlayFrame
						Connection.Position = FirstPos
						Connection.Rotation = Rotation
						Connection.Size = UDim2.new(0,0,0,2)
						Connection.ZIndex = ZIndex-2
						--Connection.RemoveTime.Value = NextHitObj.Time

						ProcessFunction(function()
							wait((NextHitObj.Time/1000+2) - (tick()-Start))
							if Connection and Connection.Parent ~= nil then
								Connection:Destroy()
							end
						end)


						local DisplayTime = (((NextHitObj.Time+100)-HitObj.Time)> 100 and NextHitObj.Time-HitObj.Time) or 100
						local TweenTime = (NextHitObj.Time-HitObj.Time > 50 and NextHitObj.Time-HitObj.Time) or 50
						local ct_ = game:GetService("TweenService"):Create(Connection,TweenInfo.new(TweenTime/1000,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{BackgroundTransparency = 0.5,Position = Pos,Size = Size})
						AddHitnoteAnimation(ct_)
						ct_:Play()
						if (tick() - Start)*1000 < NextHitObj.Time-250 then
							wait((NextHitObj.Time-250)/1000 - (tick()-Start))
							local ct_ = game:GetService("TweenService"):Create(Connection,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{BackgroundTransparency = 1,Position = EndPos,Size = UDim2.new(0,0,0,2)})
							AddHitnoteAnimation(ct_)
							ct_:Play()
						end
						wait(NextHitObj.Time/1000 - (tick()-Start))
						Connection:Destroy()
					end
				elseif BeatmapData[i+1] ~= nil and BeatmapData[i+1].Type ~= 8 then
					isLastComboNote = true
				end
			end)
			ZIndex = ZIndex - 1
			local Circle = script.Circle:Clone()
			Circle.Parent = script.Parent.PlayFrame
			Circle.Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0)
			Circle.Size = UDim2.new(CircleSize/384,0,CircleSize/384,0)
			Circle.ZIndex = ZIndex
			Circle.TextLabel.Text = Combo
			Circle.HitCircle.ImageColor3 = ComboColor[CurrentComboColor]
			Circle.ApproachCircle.ImageColor3= ComboColor[CurrentComboColor]
			local FadeInTime = 0.8
			if ApproachRate < 5 then
				FadeInTime = (800 + 400 * (5 - ApproachRate) / 5)/1000
			elseif ApproachRate > 5 then
				FadeInTime = (800 - 500 * (ApproachRate - 5) / 5)/1000
			end
			if SpeedSync then
				FadeInTime /= SongSpeed
			end
			if BeatmapFailed then return end
			if HiddenMod then
				FadeInTime = (CircleApproachTime - (CircleApproachTime*1/6))/2000
			else
				--[[
				local CurrentTrans = script.Parent.BPMTick.CurrentTrans.Value
				Circle.Lightning.Transparency = CurrentTrans
				local FullFadeTime = 1/script.Parent.BPMTick.BPM.Value - 0.1
				local FadeTime = FullFadeTime * ((1-CurrentTrans)*10)
				TweenService:Create(Circle.Lightning,TweenInfo.new(FadeTime,Enum.EasingStyle.Linear),{BackgroundTransparecy = 1}):Play()
				]]
			end
			local hitcirclet_ = game:GetService("TweenService"):Create(Circle.HitCircle,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{ImageTransparency = 0})
			AddHitnoteAnimation(hitcirclet_)
			hitcirclet_:Play()
			for _,Object in pairs(Circle:GetChildren()) do
				ProcessFunction(function()
					if Object:IsA("ImageLabel") and Object.Name ~= "Lightning" then
						if not (HiddenMod and Object.Name == "ApproachCircle" and i ~= 1) then
							local t_ = game:GetService("TweenService"):Create(Object,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{ImageTransparency = 0})
							AddHitnoteAnimation(t_)
							t_:Play()
						end
					end
					if Object:IsA("TextLabel") then
						local t_ = game:GetService("TweenService"):Create(Object,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{TextTransparency = 0,TextStrokeTransparency = 0.9})
						AddHitnoteAnimation(t_)
						t_:Play()
					end
				end)
			end

			ProcessFunction(function()
				if HiddenMod then
					local VisibleTime = FadeInTime

					repeat wait() until tick() - Start >= HitObj.Time/1000 - CircleApproachTime/1000 + VisibleTime
					local hitcirclet_ = game:GetService("TweenService"):Create(Circle.HitCircle,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{ImageTransparency = 1})
					AddHitnoteAnimation(hitcirclet_)
					hitcirclet_:Play()
					for _,Object in pairs(Circle:GetChildren()) do
						ProcessFunction(function()
							if Object:IsA("ImageLabel") and Object.Name ~= "Lightning" and Object.Name ~= "ApproachCircle"  then
								local t_ = game:GetService("TweenService"):Create(Object,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{ImageTransparency = 1})
								AddHitnoteAnimation(t_)
								t_:Play()
							end
							if Object:IsA("TextLabel") then
								local t_ = game:GetService("TweenService"):Create(Object,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{TextTransparency = 1,TextStrokeTransparency = 1})
								AddHitnoteAnimation(t_)
								t_:Play()
							end
						end)
					end
				end
			end)


			-------------------- Hit result -------------------------------

			local function CreateHitResult(HitResult)
				ProcessFunction(function()
					local FrameList = {
						[1] = script.HitMiss,
						[2] = script.Hit50,
						[3] = script.Hit100}

					local NewHitResult = FrameList[HitResult]:Clone()
					NewHitResult.Parent = script.Parent.PlayFrame
					NewHitResult.ZIndex = ZIndex
					if HitResult ~= 1 then
						NewHitResult.Size = UDim2.new((CircleSize/384)*0.6,0,(CircleSize/384)*0.6,0)
						NewHitResult.Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0)
						AddHitnoteAnimation(TweenService:Create(NewHitResult,TweenInfo.new(0.1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(((CircleSize*4/3)/384)*1,0,((CircleSize*4/3)/384)*1,0)})):Play()
						wait(0.5)
						if BeatmapFailed then return end
						AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(0.2,Enum.EasingStyle.Linear),{ImageTransparency = 1})):Play()
						wait(0.2)
						if BeatmapFailed then return end
						NewHitResult:Destroy()
					else
						NewHitResult.Size = UDim2.new((CircleSize/384)*2,0,(CircleSize/384)*2,0)
						NewHitResult.Image.ImageTransparency = 0.5
						NewHitResult.Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0)
						local CurrentRotation = math.random(-10,10)
						local Positive = CurrentRotation/math.abs(CurrentRotation)
						NewHitResult.Rotation = CurrentRotation
						local CurrentPos = NewHitResult.Position
						AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{ImageTransparency = 0,Size = UDim2.new((CircleSize/384),0,(CircleSize/384),0)})):Play()
						wait(0.1)
						if BeatmapFailed then return end
						AddHitnoteAnimation(TweenService:Create(NewHitResult,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Rotation = CurrentRotation+(Positive*15),Position = CurrentPos+UDim2.new(0,0,0.15,0)})):Play()
						AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{ImageTransparency = 1})):Play()
						wait(1)
						if BeatmapFailed then return end
						NewHitResult:Destroy()
					end
				end)
			end

			local function CreateSliderHitResult(HitResult,Pos)
				ProcessFunction(function()
					local FrameList = {
						[1] = script.HitMiss,
						[2] = script.Hit50,
						[3] = script.Hit100}

					local NewHitResult = FrameList[HitResult]:Clone()
					NewHitResult.Parent = script.Parent.PlayFrame
					NewHitResult.ZIndex = ZIndex
					if HitResult ~= 1 then
						NewHitResult.Size = UDim2.new((CircleSize/384)*0.6,0,(CircleSize/384)*0.6,0)
						NewHitResult.Position = UDim2.new(Pos.X/512,0,Pos.Y/384,0)
						TweenService:Create(NewHitResult,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{Size = UDim2.new(((CircleSize*4/3)/384)*1.2,0,((CircleSize*4/3)/384)*1.2,0)}):Play()
						wait(0.1)
						TweenService:Create(NewHitResult.Image,TweenInfo.new(0.2,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
						wait(0.2)
						NewHitResult:Destroy()
					else
						NewHitResult.Size = UDim2.new((CircleSize/384)*2,0,(CircleSize/384)*2,0)
						NewHitResult.Image.ImageTransparency = 0.5
						NewHitResult.Position = UDim2.new(Pos.X/512,0,Pos.Y/384,0)
						local CurrentRotation = math.random(-10,10)
						local Positive = CurrentRotation/math.abs(CurrentRotation)
						NewHitResult.Rotation = CurrentRotation
						local CurrentPos = NewHitResult.Position
						TweenService:Create(NewHitResult.Image,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{ImageTransparency = 0,Size = UDim2.new((CircleSize/384)*1.2,0,(CircleSize/384)*1.2,0)}):Play()
						wait(0.1)
						TweenService:Create(NewHitResult,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Rotation = CurrentRotation+(Positive*15),Position = CurrentPos+UDim2.new(0,0,0.15,0)}):Play()
						TweenService:Create(NewHitResult.Image,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{ImageTransparency = 1}):Play()
						wait(1)
						NewHitResult:Destroy()
					end
				end)
			end

			local function AddScore(HitValue)
				local Combo = Accurancy.Combo
				Score += HitValue + (HitValue * ((((Combo > 2 and Combo-2) or 0) * ScoreMultiplier.Difficulty * ScoreMultiplier.Mod) / 25))
			end

			----------------------------------- Slider -----------------------------------


		--[[
		
			lengthperbeat = slidermulti * 100
			lengthpersec = lengthperbeat*BPS
			
			slidertime = sliderlength/lengthpersec
		]]

			local TickCollected = 0
			local SliderTime = -1 -- wait until slider time loaded


			if Type == 2 and SliderMode == true then
				local FollowCircleZIndex = ZIndex
				local SliderFolder = Instance.new("Folder",script.Parent.PlayFrame)
				SliderFolder.Name = "Slider"
				local GolbalSliderConnections = "none"


				--(BPM*SliderMulti)*SliderLength*10000
				local ExtraData = HitObj.ExtraData
				ZIndex = ZIndex-1
				local SliderCurvePoints = {}
				local Slides = tonumber(ExtraData[3])



				local CurrentBPM = 60
				local CurrentSliderMulti = 1
				local DefaultSliderMultiplier = SliderMultiplier

				local LoadedData = {
					BPMLoaded = false,MultiLoaded = false,FirstBPM = false,FirstSliderMulti = true
				}

				for order,TimingData in pairs(TimingPoints) do
					local BeatLength =  TimingData[2]
					local Positive = BeatLength/math.abs(BeatLength)
					if TimingData[1] > HitObj.Time and LoadedData.FirstBPM and LoadedData.FirstSliderMulti then
						break
					end
					if Positive > 0 then -- there's no way Positive = 0
						local BPM = (1 / BeatLength * 1000 * 60)*SongSpeed
						if not LoadedData.FirstBPM then
							LoadedData.FirstBPM = true
							CurrentBPM = BPM
						end
						if TimingData[1] <= HitObj.Time then
							CurrentBPM = BPM
						end
					else
						local SliderMulti = 1/((-BeatLength)/100)
						if TimingData[1] <= HitObj.Time then
							CurrentSliderMulti = SliderMulti
						end
					end
				end


				local SliderMulti = CurrentSliderMulti * DefaultSliderMultiplier
				local Delayed = (tick() - Start) - HitObj.Time/1000
				local LengthPerBeat = SliderMulti*100
				local LengthPerSec = LengthPerBeat*(CurrentBPM/60)

				SliderTime = (((ExtraData[4]*Slides)/LengthPerSec))
				if i >= #BeatmapData then
					LastNoteData = {Slider = true,SliderTime = SliderTime}
				end

				--[[
				ProcessFunction(function()
					wait(HitObj.Time/1000 - (tick() - Start))

					local CurrentBPM = BPM
					local CurrentSliderMulti = CurrentSliderMultiplier

					for i = 1,20 do
						if NextBPM[i] and NextBPM[i].Time <= HitObj.Time then
							CurrentBPM = NextBPM.Value
						end
						if NextSliderMulti[i] and NextSliderMulti[i].Time <= HitObj.Time then
							CurrentSliderMulti = NextSliderMulti.Value
						end
					end

					local SliderMulti = SliderMultiplier*CurrentSliderMultiplier

					local LengthPerBeat = SliderMulti*100
					local LengthPerSec = LengthPerBeat*(BPM/60)

					local Delayed = (tick() - Start) - HitObj.Time/1000

					-- due to wait() is sometime delayed, this will help the slider less delay
					SliderTime = (((ExtraData[4]*Slides)/LengthPerSec)/SongSpeed) - Delayed
				end)]]
				local CurrentPos = 3
				local CurveData = HitObj.ExtraData[2]
				-- Follow circle
				local FollowCircle = script.SliderFollowCircle:Clone()
				FollowCircle.Parent = SliderFolder
				FollowCircle.ZIndex = ZIndex + 1
				FollowCircle.Size = UDim2.new(CircleSize/384,0,CircleSize/384,0)
				FollowCircle.Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0)


				SliderCurvePoints[1] = HitObj.Position
				for i = 3,#CurveData do
					if string.sub(CurveData,i,i) == "|" or i == #CurveData then
						for a = CurrentPos,i-1 do
							if string.sub(CurveData,a,a) == ":" then
								if i ~= #CurveData then
									SliderCurvePoints[#SliderCurvePoints+1] = {
										X = tonumber(string.sub(CurveData,CurrentPos,a-1)),
										Y = tonumber(string.sub(CurveData,a+1,i-1))
									}
								else
									SliderCurvePoints[#SliderCurvePoints+1] = {
										X = tonumber(string.sub(CurveData,CurrentPos,a-1)),
										Y = tonumber(string.sub(CurveData,a+1,i))
									}
								end
								break
							end
						end
						CurrentPos = i+1
					end
				end

				if HardRock then
					for i,a in pairs(SliderCurvePoints) do
						if i~=1 then
							SliderCurvePoints[i] = {X = a.X,Y=384-a.Y}
						end
					end
				end

				local resultpos = string.find(CurveData,"|")
				local SliderCurveType = string.sub(CurveData,resultpos-1,resultpos-1)


				local Alvaiable = false

				if SliderCurveType == "P" and Alvaiable then
					local OriginalPoints = SliderCurvePoints
					if #OriginalPoints == 3 then
						local HighestDistance = 0
						for i = 1,2 do
							local Distance = math.abs((Vector2.new(OriginalPoints[i].X,OriginalPoints[i].Y) - Vector2.new(OriginalPoints[i+1].X,OriginalPoints[i+1].Y)).Magnitude)
							if Distance > HighestDistance then
								HighestDistance = Distance
							end
						end

						local CircleDrawData = {}

						for i = 1,3 do
							local a = OriginalPoints[i].X
							local b = OriginalPoints[i].Y
							CircleDrawData[i] = {a=a,b=b}
						end

						local IntersectingPoints = {}

						for i = 2,3 do
							local Intersecting = {}
							local LowestDistance = {Distance = 999999999,Position = {X=0,Y=0}}
							local PreviousDistance = ""
							local a1 = CircleDrawData[1].a
							local b1 = CircleDrawData[1].b
							local a2 = CircleDrawData[i].a
							local b2 = CircleDrawData[i].b

							local CircleData = {}
							local Decreasing = false

							for XPos = -math.floor(HighestDistance),512+math.floor(HighestDistance) do
								local YPos1 = math.sqrt(HighestDistance^2-(XPos-a1)^2)+b1
								local YPos2 = math.sqrt(HighestDistance^2-(XPos-a2)^2)+b2
								local Distance = math.abs((Vector2.new(XPos,YPos1)-Vector2.new(XPos,YPos2)).Magnitude)
								if tostring(Distance) ~= "nan" then
									if Distance < LowestDistance.Distance then
										Decreasing = true
									else
										if (PreviousDistance ~= "" and Distance > PreviousDistance) or Distance == 0 then
											if Decreasing then
												Intersecting[#Intersecting+1] = LowestDistance
												Decreasing = false
												LowestDistance = {Distance = 999999999,Position = {X=0,Y=0}}
											end
										elseif PreviousDistance ~= "" and Distance < PreviousDistance then
											Decreasing = true
										end
									end
								elseif Intersecting[1] then
									Intersecting[2] = LowestDistance
									break
								end
								LowestDistance = {Distance = Distance,Position = {X = XPos,Y = YPos1}}
								PreviousDistance = Distance
							end

							PreviousDistance = ""
							LowestDistance = {Distance = 999999999,Position = {X=0,Y=0}}

							if not Intersecting[2] then
								for XPos = -math.floor(HighestDistance),512+math.floor(HighestDistance) do
									local YPos1 = -math.sqrt(HighestDistance^2-(XPos-a1)^2)+b1
									local YPos2 = -math.sqrt(HighestDistance^2-(XPos-a2)^2)+b2
									local Distance = math.abs((Vector2.new(XPos,YPos1)-Vector2.new(XPos,YPos2)).Magnitude)
									if tostring(Distance) ~= "nan" then
										if Distance < LowestDistance.Distance then
											Decreasing = true
										else
											if (PreviousDistance ~= "" and Distance > PreviousDistance) or Distance == 0 then
												if Decreasing then
													Intersecting[#Intersecting+1] = LowestDistance
													Decreasing = false
													LowestDistance = {Distance = 999999999,Position = {X=0,Y=0}}
												end
											elseif PreviousDistance ~= "" and Distance < PreviousDistance then
												Decreasing = true
											end
										end
									elseif Intersecting[1] then
										Intersecting[2] = LowestDistance
										break
									end
									LowestDistance = {Distance = Distance,Position = {X = XPos,Y = YPos1}}
									PreviousDistance = Distance
								end
							end



							local a = Intersecting[2].Position.X-Intersecting[1].Position.X
							local b = Intersecting[1].Position.Y-Intersecting[2].Position.Y
							local X1 = Intersecting[1].Position.X
							local Y1 = Intersecting[1].Position.Y

							IntersectingPoints[i-1] = {a=a,b=b,X1=X1,Y1=Y1}
						end


						local a1 = IntersectingPoints[1].a
						local b1 = IntersectingPoints[1].b
						local x1 = IntersectingPoints[1].X1
						local y1 = IntersectingPoints[1].Y1
						local a2 = IntersectingPoints[2].a
						local b2 = IntersectingPoints[2].b
						local x2 = IntersectingPoints[2].X1
						local y2 = IntersectingPoints[2].Y1
						local PrevIntersectionDistance = ""
						local PrevData = Vector2.new(0,0)

						local PerfectCircleCenter = Vector2.new(0,0)

						for PosX = 0,512 do
							local PosY1 = (-b1*(PosX-x1)/a1)+y1
							local PosY2 = (-b2*(PosX-x2)/a2)+y2

							local Distance = math.abs((Vector2.new(PosX,PosY1)-Vector2.new(PosX,PosY2)).Magnitude)

							if PrevIntersectionDistance ~= "" and (Distance > PrevIntersectionDistance or Distance == 0) then
								PerfectCircleCenter = PrevData
								break
							end 
							PrevIntersectionDistance = Distance
							PrevData = Vector2.new(PosX,PosY1)
						end


						local NewPoints = {}
						local ReversePoints = {}
						local isReverse = false
						local UpDirection = false
						local UpEndDirection = false

						NewPoints[1] = OriginalPoints[1]


						if OriginalPoints[1].Y < PerfectCircleCenter.Y then
							UpDirection = true
						end

						if (OriginalPoints[1].X > OriginalPoints[2].X and not UpDirection) or (OriginalPoints[1].X < OriginalPoints[2].X and UpDirection) then
							isReverse = true
						end

						if OriginalPoints[3].Y < PerfectCircleCenter.Y then
							UpEndDirection = true
						end


						local LastDistance = ""

						local a = PerfectCircleCenter.X
						local b = PerfectCircleCenter.Y
						local c = -(HighestDistance^2)+a^2+b^2
						local _1st = false

						print(UpDirection,isReverse)

						if UpDirection then
							local Gotten = false


							local ValueA = math.ceil(OriginalPoints[1].X)
							local ValueB = math.ceil(PerfectCircleCenter.X+HighestDistance)
							local ValueC = 1

							if isReverse then
								ValueB = math.ceil(OriginalPoints[1].X)
								ValueA = math.ceil(PerfectCircleCenter.X-HighestDistance)
								ValueC = -1
							end

							for PosX = ValueA,ValueB,ValueC do
								local PosY = -math.sqrt(HighestDistance^2-(PosX-a)^2)+b
								if _1st == false then
									_1st = true
								else
									local Distance = math.abs((Vector2.new(PosX,PosY)-Vector2.new(OriginalPoints[3].X,OriginalPoints[3].Y)).Magnitude)
									if UpEndDirection and LastDistance ~= "" and (LastDistance == 0 or Distance > LastDistance) then
										Gotten = true
										break
									end
									if tostring(Distance) ~= "nan" then
										NewPoints[#NewPoints+1] = {X = PosX,Y=PosY}
										LastDistance = Distance
									end
								end
							end

							if not Gotten then
								local ValueA = math.ceil(PerfectCircleCenter.X+HighestDistance)
								local ValueB = math.ceil(PerfectCircleCenter.X-HighestDistance)
								local ValueC = -1

								if isReverse then
									ValueB = math.ceil(PerfectCircleCenter.X-HighestDistance)
									ValueA = math.ceil(PerfectCircleCenter.X+HighestDistance)
									ValueC = 1
								end

								for PosX = ValueA,ValueB,ValueC do
									local PosY = math.sqrt(HighestDistance^2-(PosX-a)^2)+b
									local Distance = math.abs((Vector2.new(PosX,PosY)-Vector2.new(OriginalPoints[3].X,OriginalPoints[3].Y)).Magnitude)
									if not UpEndDirection and LastDistance ~= "" and (LastDistance == 0 or Distance > LastDistance) then
										Gotten = true
										break
									end
									if tostring(Distance) ~= "nan" then
										NewPoints[#NewPoints+1] = {X = PosX,Y=PosY}
										LastDistance = Distance
									end
								end

								if not Gotten then
									local ValueA = math.ceil(PerfectCircleCenter.X-HighestDistance)
									local ValueB = math.ceil(OriginalPoints[3].X)
									local ValueC = 1

									if isReverse then
										ValueB = math.ceil(PerfectCircleCenter.X+HighestDistance)
										ValueA = math.ceil(OriginalPoints[3].X)
										ValueC = -1
									end

									for PosX = ValueA,ValueB,ValueC do
										local PosY = -math.sqrt(HighestDistance^2-(PosX-a)^2)+b
										if _1st == false then
											_1st = true
										else
											local Distance = math.abs((Vector2.new(PosX,PosY)-Vector2.new(OriginalPoints[3].X,OriginalPoints[3].Y)).Magnitude)
											if UpEndDirection and LastDistance ~= "" and (LastDistance == 0 or Distance > LastDistance) then
												Gotten = true
												break
											end
											if tostring(Distance) ~= "nan" then
												NewPoints[#NewPoints+1] = {X = PosX,Y=PosY}
												LastDistance = Distance
											end
										end
									end
								end
							end

						else
							local Gotten = true
							local ValueA = math.ceil(OriginalPoints[1].X)
							local ValueB = math.ceil(PerfectCircleCenter.X+HighestDistance)
							local ValueC = 1

							if not isReverse then
								ValueB = math.ceil(OriginalPoints[1].X)
								ValueA = math.ceil(PerfectCircleCenter.X-HighestDistance)
								ValueC = -1
							end

							for PosX = ValueA,ValueB,ValueC do
								local PosY = math.sqrt(HighestDistance^2-(PosX-a)^2)+b
								if _1st == false then
									_1st = true
								else
									local Distance = math.abs((Vector2.new(PosX,PosY)-Vector2.new(OriginalPoints[3].X,OriginalPoints[3].Y)).Magnitude)
									if not UpEndDirection and LastDistance ~= "" and (LastDistance == 0 or Distance > LastDistance) then
										Gotten = true
										break
									end
									if tostring(Distance) ~= "nan" then
										NewPoints[#NewPoints+1] = {X = PosX,Y=PosY}
										LastDistance = Distance
									end
								end
							end
							if not Gotten then
								local ValueA = math.ceil(PerfectCircleCenter.X+HighestDistance)
								local ValueB = math.ceil(PerfectCircleCenter.X-HighestDistance)
								local ValueC = -1

								if not isReverse then
									ValueB = math.ceil(PerfectCircleCenter.X-HighestDistance)
									ValueA = math.ceil(PerfectCircleCenter.X+HighestDistance)
									ValueC = 1
								end

								for PosX = ValueA,ValueB,ValueC do
									local PosY = -math.sqrt(HighestDistance^2-(PosX-a)^2)+b
									local Distance = math.abs((Vector2.new(PosX,PosY)-Vector2.new(OriginalPoints[3].X,OriginalPoints[3].Y)).Magnitude)
									if not UpEndDirection and LastDistance ~= "" and (LastDistance == 0 or Distance > LastDistance) then
										Gotten = true
										break
									end
									if tostring(Distance) ~= "nan" then
										NewPoints[#NewPoints+1] = {X = PosX,Y=PosY}
										LastDistance = Distance
									end
								end

								if not Gotten then
									local ValueA = math.ceil(PerfectCircleCenter.X-HighestDistance)
									local ValueB = math.ceil(OriginalPoints[3].X)
									local ValueC = 1

									if not isReverse then
										ValueB = math.ceil(PerfectCircleCenter.X+HighestDistance)
										ValueA = math.ceil(OriginalPoints[3].X)
										ValueC = -1
									end

									for PosX = ValueA,ValueB,ValueC do
										local PosY = -math.sqrt(HighestDistance^2-(PosX-a)^2)+b
										local Distance = math.abs((Vector2.new(PosX,PosY)-Vector2.new(OriginalPoints[3].X,OriginalPoints[3].Y)).Magnitude)
										if not UpEndDirection and LastDistance ~= "" and (LastDistance == 0 or Distance > LastDistance) then
											Gotten = true
											break
										end
										if tostring(Distance) ~= "nan" then
											NewPoints[#NewPoints+1] = {X = PosX,Y=PosY}
											LastDistance = Distance
										end
									end
								end
							end

						end
						print(NewPoints)
						SliderCurvePoints = NewPoints
					end
				end

				local ReverseArrowData = {}
				local ReverseArrowObject = {}

				-- Caculate reverse arrow position

				local CurvePointPos_1 = SliderCurvePoints[1]
				local CurvePointPos_2 = SliderCurvePoints[2]
				local CurvePointPos_L1 = SliderCurvePoints[#SliderCurvePoints]
				local CurvePointPos_L2 = SliderCurvePoints[#SliderCurvePoints-1]

				local Point = Vector2.new(CurvePointPos_1.X,CurvePointPos_1.Y) - Vector2.new(CurvePointPos_2.X,CurvePointPos_2.Y)
				local RotationF = math.deg(math.atan2(Point.Y,Point.X))
				local Point2 = Vector2.new(CurvePointPos_L1.X,CurvePointPos_L1.Y) - Vector2.new(CurvePointPos_L2.X,CurvePointPos_L2.Y)
				local RotationL = math.deg(math.atan2(Point2.Y,Point2.X))

				ReverseArrowData[1] = {CurvePointPos_1,RotationF}
				ReverseArrowData[2] = {CurvePointPos_L1,RotationL}

				for i = 1,Slides do
					local ReverseArrow = script.ReverseArrow:Clone()
					ReverseArrow.Parent = SliderFolder
					local Data = (i/2 - math.floor(i/2) == 0.5 and ReverseArrowData[2]) or ReverseArrowData[1]

					ReverseArrow.ZIndex = ZIndex
					ReverseArrow.Size = UDim2.new((CircleSize*0.6)/384,0,(CircleSize*0.6)/384,0)
					ReverseArrow.Position = UDim2.new(Data[1].X/512,0,Data[1].Y/384,0)
					ReverseArrow.Rotation = Data[2]+180

					ReverseArrowObject[i] = ReverseArrow
				end



				local SliderLength = 0
				local SliderConnections = {}
				for i,a in pairs(SliderCurvePoints) do
					if i ~= #SliderCurvePoints then
						local NextCurvePointPos = SliderCurvePoints[i+1]
						local Point1st = Vector2.new(a.X,a.Y)
						local Point2nd = Vector2.new(NextCurvePointPos.X,NextCurvePointPos.Y)
						local Point3rd = Vector2.new(a.Y,NextCurvePointPos.X)
						local Length = (Point1st-Point2nd).magnitude
						SliderLength = SliderLength + Length
						local Length3rd = (Point2nd-Point3rd).magnitude
						local Point = Point2nd-Point1st
						local Rotation = math.deg(math.atan2(Point.Y,Point.X))
						--local Rotation = math.deg(math.asin(Length3rd/Length))

						SliderConnections[#SliderConnections+1] = {Length = Length,Rotation = Rotation,Pos = (Point1st+Point2nd)/2}
					end

					GolbalSliderConnections = SliderConnections
				end
				for i,Data in pairs(SliderConnections) do
					local HoldCircle = script.HoldCircle:Clone()
					HoldCircle.Name = tostring((i/#SliderConnections)*0.25)
					HoldCircle.Parent = SliderFolder
					HoldCircle.Position = UDim2.new(Data.Pos.X/512,0,Data.Pos.Y/384,0)
					HoldCircle.Rotation = Data.Rotation
					HoldCircle.Size = UDim2.new(((Data.Length)/512),0,CircleSize/384-0.026,0)
					HoldCircle.BackgroundColor3 = Color3.new(0,0,0)
					HoldCircle.ZIndex = ZIndex-2
					HoldCircle.UICorner:Destroy()
					TweenService:Create(HoldCircle,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.new(0.133333, 0.133333, 0.133333)}):Play()
					local Outline = HoldCircle:Clone()
					Outline.Name = tostring((i/#SliderConnections)*0.25)
					Outline.Size = UDim2.new(((Data.Length)/512),0,CircleSize/384,0)
					Outline.Parent = SliderFolder
					Outline.ZIndex = ZIndex-3
					Outline.BackgroundColor3 = Color3.new(0,0,0)
					TweenService:Create(Outline,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.new(0.584314, 0.584314, 0.584314)}):Play()
				end

				local ReverseSliderConnection = {}

				for i = 1,#SliderConnections do
					table.insert(ReverseSliderConnection,1,SliderConnections[i])
				end

				for i,SliderPoint in pairs(SliderCurvePoints) do
					local HoldCircle = script.HoldCircle:Clone()
					HoldCircle.Name = tostring((i/#SliderCurvePoints)*0.25)
					HoldCircle.BackgroundColor3 = Color3.new(0,0,0)
					HoldCircle.Parent = SliderFolder
					HoldCircle.Position = UDim2.new(SliderPoint.X/512,0,SliderPoint.Y/384,0)
					HoldCircle.Size = UDim2.new(CircleSize/384-0.026,0,CircleSize/384-0.026,0)
					HoldCircle.SizeConstraint = Enum.SizeConstraint.RelativeYY
					HoldCircle.ZIndex = ZIndex-1
					TweenService:Create(HoldCircle,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.new(0.133333, 0.133333, 0.133333)}):Play()
					local Outline = HoldCircle:Clone()
					Outline.Name = tostring((i/#SliderCurvePoints)*0.25)
					Outline.Size = UDim2.new(CircleSize/384,0,CircleSize/384,0)
					Outline.Parent = SliderFolder
					Outline.ZIndex = ZIndex-3
					Outline.BackgroundColor3 = Color3.new(0,0,0)
					TweenService:Create(Outline,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.new(0.584314, 0.584314, 0.584314)}):Play()
				end
				ZIndex -= 3
				local Completed = false
				ProcessFunction(function()
					if Slides > 1 then
						TweenService:Create(ReverseArrowObject[1],TweenInfo.new(0.25,Enum.EasingStyle.Linear),{ImageTransparency = 0}):Play()
						TweenService:Create(ReverseArrowObject[1],TweenInfo.new((30/BPM)-0.05,Enum.EasingStyle.Sine,Enum.EasingDirection.In,math.huge,true,0.1),{Size = UDim2.new((CircleSize/384*0.9),0,(CircleSize/384*0.9),0)}):Play()
					end
					repeat wait() until (tick() - Start) >= HitObj.Time/1000 and SliderTime ~= -1
					if AutoPlay == true and ReplayMode ~= true then
						script.Parent.MouseHit:Fire(SecurityKey,SliderATKey)
					end
					local TotalDuration = 0
					FollowCircle.Visible = true
					for CurrentSlide = 1,Slides do
						if Completed == true then
							break
						end
						if CurrentSlide > 1 then
							ProcessFunction(function()
								TweenService:Create(ReverseArrowObject[CurrentSlide-1],TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1,Size = UDim2.new(CircleSize*1.5/384,0,CircleSize*1.5/384,0)}):Play()
							end)
						end
						if CurrentSlide < Slides-1 then
							ProcessFunction(function()
								TweenService:Create(ReverseArrowObject[CurrentSlide+1],TweenInfo.new(0.25,Enum.EasingStyle.Linear),{ImageTransparency = 0}):Play()						
							end)
						end
						if (CurrentSlide/2)-math.floor(CurrentSlide/2) == 0.5 then
							for i,SliderPoint in pairs(SliderCurvePoints) do
								if i ~= 1 then
									local SliderPointLength = SliderConnections[i-1].Length
									local SliderPointDuration = (SliderTime*(SliderPointLength/SliderLength))/Slides
									game:GetService("TweenService"):Create(FollowCircle,TweenInfo.new(SliderPointDuration,Enum.EasingStyle.Linear),{Position = UDim2.new(SliderCurvePoints[i].X/512,0,SliderCurvePoints[i].Y/384,0)}):Play()
									ProcessFunction(function()
										if AutoPlay == true and ReplayMode ~= true then
											if Is == false then
												repeat wait() until Is == true
											end
											if not Completed then
												game:GetService("TweenService"):Create(script.Parent.GameplayData.ATVC,TweenInfo.new(SliderPointDuration,Enum.EasingStyle.Linear),{Position = UDim2.new(SliderCurvePoints[i].X/512,0,SliderCurvePoints[i].Y/384,0)}):Play()
											end
										end
									end)
									TotalDuration += SliderPointDuration
									if tick() - Start < HitObj.Time/1000 + TotalDuration then
										repeat wait() until tick() - Start >= HitObj.Time/1000 + TotalDuration
									end
									--wait((HitObj.Time/1000 + TotalDuration) - (tick() - Start))
								end
							end
						else
							local ReverseSliderCurvePoints = {}
							for i = #SliderCurvePoints,1,-1. do
								--i = #SliderCurvePoints - i
								table.insert(ReverseSliderCurvePoints,1,SliderCurvePoints[i])
							end
							for i,SliderPoint in pairs(ReverseSliderCurvePoints) do
								if i ~= 1 then
									local SliderPointLength = ReverseSliderConnection[i-1].Length
									--HitObj.Time
									local SliderPointDuration = (SliderTime*(SliderPointLength/SliderLength))/Slides
									game:GetService("TweenService"):Create(FollowCircle,TweenInfo.new(SliderPointDuration,Enum.EasingStyle.Linear),{Position = UDim2.new(SliderCurvePoints[#SliderCurvePoints-i+1].X/512,0,SliderCurvePoints[#SliderCurvePoints-i+1].Y/384,0)}):Play()
									spawn(function()
										if AutoPlay == true and ReplayMode ~= true then
											if Is == false then
												repeat wait() until Is == true
											end
											if not Completed then
												game:GetService("TweenService"):Create(script.Parent.GameplayData.ATVC,TweenInfo.new(SliderPointDuration,Enum.EasingStyle.Linear),{Position = UDim2.new(SliderCurvePoints[#SliderCurvePoints-i+1].X/512,0,SliderCurvePoints[#SliderCurvePoints-i+1].Y/384,0)}):Play()
											end
										end
									end)
									TotalDuration += SliderPointDuration
									if tick() - Start < HitObj.Time/1000 + TotalDuration then
										repeat wait() until tick() - Start >= HitObj.Time/1000 + TotalDuration
									end
									--wait((HitObj.Time/1000 + TotalDuration) - (tick() - Start))
								end
							end
						end
					end
					if AutoPlay == true and ReplayMode ~= true then
						script.Parent.MouseHitEnd:Fire(SecurityKey,SliderATKey)
					end
				end)

				local LastHold = 0


				local function isInFollowCircle()
					local FollowCirclePos = Vector2.new(FollowCircle.Position.X.Scale*512,FollowCircle.Position.Y.Scale*384)
					local CursorPos = CursorPosition --Vector2.new(Cursor.Position.X.Scale*512,Cursor.Position.Y.Scale*384)
					local Distance = math.abs((FollowCirclePos-CursorPos).magnitude)
					if Distance <= (CircleSize/2)*2.5 then
						return true
					else
						return false
					end
				end

				ProcessFunction(function()
					if (tick() - Start) < HitObj.Time/1000 or SliderTime == -1 then
						repeat wait() until (tick() - Start) >= HitObj.Time/1000 and SliderTime ~= -1
					end
					ProcessFunction(function()
						while wait() and not Completed do
							if isInFollowCircle() == true and script.Parent.KeyDown.Value == true then
								if FollowCircle:FindFirstChild("isFollow") then
									FollowCircle.isFollow.Visible = true
								end
								LastHold = tick()
							else
								if FollowCircle:FindFirstChild("isFollow") then
									FollowCircle.isFollow.Visible = false
								end
							end
						end
					end)

					ProcessFunction(function()
						for i = 1,Slides do
							if tick() - Start < HitObj.Time/1000 + SliderTime/Slides*i then
								repeat wait() until tick() - Start >= HitObj.Time/1000 + SliderTime/Slides*i
							end
							--wait(SliderTime/Slides)
							if Completed == true then
								break
							end

							if (isInFollowCircle() == true and script.Parent.KeyDown.Value == true) or i ~= Slides or tick() - LastHold < 0.1 then
								if (isInFollowCircle() == true and script.Parent.KeyDown.Value == true) or tick() - LastHold < 0.1 then
									if i ~= Slides then
										Score += 30
									end
									Accurancy.Combo+=1
									TickCollected += 1
									AddHP(1.6)
									if Accurancy.Combo > Accurancy.MaxCombo then
										Accurancy.MaxCombo = Accurancy.Combo
									end
									spawn(function()
										local Sound = script.HitSound:Clone()
										Sound.Parent = script.Parent.HitSounds
										Sound:Play()
										wait(0.208)
										Sound:Destroy()
									end)
								else
									DrainHP(MissDrain/4)
								end
							else
								if Accurancy.Combo >= 20 then
									script.Parent.ComboBreak:Play()
								end
								Accurancy.Combo = 0
								Accurancy.PerfomanceCombo = 0
								Missed = true
								AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,0)
								DrainHP(MissDrain/2)
							end
						end
						-----------------
						local TickRequired = Slides+1
						if TickCollected >= TickRequired then
							if isLastComboNote then
								if ComboNoteData.Full300 then
									AddHP(10)
								elseif not ComboNoteData.Missor50 then
									AddHP(5)
								else
									AddHP(3.2)
								end
							else
								AddHP(3.2)
							end
							Accurancy.PerfomanceCombo += 1 
							if Accurancy.PerfomanceCombo > Accurancy.MaxPeromanceCombo then
								Accurancy.MaxPeromanceCombo = Accurancy.PerfomanceCombo
							end
							Accurancy.h300 += 1
							AddScore(300)
							AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,1)
						elseif TickCollected/TickRequired >= 0.5 then
							if isLastComboNote then
								if not ComboNoteData.Missor50 then
									AddHP(5)
								else
									AddHP(1.6)
								end
							else
								ComboNoteData.Full300 = false
								AddHP(1.6)
							end
							Accurancy.h100 += 1
							AddScore(100)
							CreateSliderHitResult(3,SliderCurvePoints[#SliderCurvePoints])
							AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,1/3)
						elseif TickCollected > 0 then
							Accurancy.h50 += 1
							AddScore(50)
							DrainHP(0)
							CreateSliderHitResult(2,SliderCurvePoints[#SliderCurvePoints])
							AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,1/6)
						else
							Accurancy.PerfomanceCombo = 0
							Accurancy.miss += 1
							DrainHP(MissDrain/2)
							CreateSliderHitResult(1,SliderCurvePoints[#SliderCurvePoints])
							Accurancy.Combo = 0
							Accurancy.PerfomanceCombo = 0
							Missed = true
							AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,0)
						end
						CurrentCursorPos = HitNoteID + 1
						Completed = true
						local FollowCircle = SliderFolder.SliderFollowCircle
						FollowCircle.Parent = script.Parent.PlayFrame
						SliderFolder:Destroy()
						--SliderFolder:Destroy()
						TweenService:Create(FollowCircle.isFollow,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Size = UDim2.new(2,0,2,0),ImageTransparency = 1}):Play()
						FollowCircle.isFollow.Visible = tick() - LastHold <= 0.1
						FollowCircle.SliderFollowCircle:Destroy()
						wait(0.25)
						FollowCircle:Destroy()
					end)
				end)
			end

			---------------------------------------------------------------------------------------------------------





			local FixedApproachTime = -((tick()-Start)*1000 - HitObj.Time)
			if FixedApproachTime < 0 then
				FixedApproachTime = 0
			end
			local ApproachSize = (1-(CircleApproachTime-FixedApproachTime)/CircleApproachTime)*3 + 1.1

			if ApproachSize > 4.1 then
				ApproachSize = 4.1
			end

			Circle.ApproachCircle.Size = UDim2.new(ApproachSize,0,ApproachSize,0)
			local ApproachCircleTween = game:GetService("TweenService"):Create(Circle.ApproachCircle,TweenInfo.new(FixedApproachTime/1000,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Size = UDim2.new(1.1,0,1.1,0)})
			AddHitnoteAnimation(ApproachCircleTween)
			ApproachCircleTween:Play()


			local CircleHitConnection = false

			ProcessFunction(function()
				if (HitObj.Time/1000) - (tick()-Start) > 0 then -- prevent high delay
					wait((HitObj.Time/1000) - (tick()-Start))
				end
				if Is == false and not BeatmapFailed then
					Circle.ApproachCircle.Visible = false
					if Type ~= 2 or not SliderMode then
						if ((HitObj.Time+hit50)/1000) - (tick()-Start) > 0 then
							wait(((HitObj.Time+hit50)/1000) - (tick()-Start))
						end
					else
						ProcessFunction(function()
							local t2_ = game:GetService("TweenService"):Create(Circle.HitCircle,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1})
							AddHitnoteAnimation(t2_)
							t2_:Play()
							for _,Object in pairs(Circle:GetChildren()) do
								ProcessFunction(function()
									if Object:IsA("ImageLabel") and Object.Name ~= "Lightning" then
										game:GetService("TweenService"):Create(Object,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()
									end
									if Object:IsA("TextLabel") then
										game:GetService("TweenService"):Create(Object,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{TextTransparency = 1,TextStrokeTransparency = 1}):Play()
									end
								end)
							end
						end)
						Circle.Visible = false
						local SliderHitTime = SliderTime/tonumber(HitObj.ExtraData[3])
						if SliderHitTime > hit50 then
							SliderHitTime = hit50
						elseif SliderHitTime <= hit300 then
							SliderHitTime = hit300
						end
						if ((HitObj.Time+SliderHitTime*1000)/1000) - (tick()-Start) > 0 then
							wait(((HitObj.Time+SliderHitTime*1000)/1000) - (tick()-Start))
						end
					end
					if Is == false then
						if CircleHitConnection then
							CircleHitConnection:Disconnect()
						end
						Is = true
						if Accurancy.Combo >= 20 then
							script.Parent.ComboBreak:Play()
						end
						Accurancy.Combo = 0
						Accurancy.PerfomanceCombo = 0
						Missed = true
						DrainHP(MissDrain)
						ComboNoteData.Missor50 = true
						ComboNoteData.Full300 = false
						AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,0)
						CurrentHitnote = HitNoteID + 1
						TotalNotes -= 1
						if Type ~= 2 or SliderMode == false then
							Accurancy.miss += 1
							HitMiss = true
							CreateHitResult(1)
						end
						ProcessFunction(function()
							local t2_ = game:GetService("TweenService"):Create(Circle.HitCircle,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1})
							AddHitnoteAnimation(t2_)
							t2_:Play()
							Circle.HitCircleLightning:Destroy()
							Circle.Lightning:Destroy()
							for _,Object in pairs(Circle:GetChildren()) do
								ProcessFunction(function()
									if Object:IsA("ImageLabel") and Object.Name ~= "Lightning" then
										game:GetService("TweenService"):Create(Object,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()
									end
									if Object:IsA("TextLabel") then
										game:GetService("TweenService"):Create(Object,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{TextTransparency = 1,TextStrokeTransparency = 1}):Play()
									end
								end)
							end
							wait(0.5)
							Circle:Destroy()
						end)

						DisplayingHitnote[HitNoteID] = nil
					end
				else
					if CircleHitConnection then
						CircleHitConnection:Disconnect()
					end
				end
			end)
			ProcessFunction(function()
				wait(((HitObj.Time+hit50+1000)/1000) - (tick()-Start))
				-- everything in this note should be done by now
				for _,tweenid in pairs(AnimationIdList) do
					HitnoteAnimations[tweenid] = nil
				end
			end)
			local function isincircle()
				local CirclePos = Vector2.new(HitObj.Position.X,HitObj.Position.Y)
				local CursorPos = CursorPosition -- Vector2.new(Cursor.Position.X.Scale*512,Cursor.Position.Y.Scale*384)
				local Distance = math.abs((CirclePos-CursorPos).magnitude)
				if Distance <= ((CircleSize)/2) then
					return true
				else
					return false
				end
			end

			local function isinPosition(PosX,PosY)
				local CirclePos = Vector2.new(PosX,PosY)
				local CursorPos = CursorPosition --Vector2.new(Cursor.Position.X.Scale*512,Cursor.Position.Y.Scale*384)
				local Distance = math.abs((CirclePos-CursorPos).magnitude)
				if Distance <= (CircleSize/2) then
					return true
				else
					return false
				end
			end



			--Hit Value + (Hit Value * ((Combo multiplier * Difficulty multiplier * Mod multiplier) / 25))


			local function get_data()
				return game.HttpService:GenerateGUID()
			end

			script.Parent.MouseHit.Event:Connect(function(CurrentSecurityKey)
				if CurrentSecurityKey ~= SecurityKey then
					return "no"
				end
				local CurrentTime = (tick()-Start)*1000
				local HitDelay = CurrentTime - HitObj.Time
				--[[
				local CurrentHitNotePos = BeatmapData[CurrentHitnote].Position
				local Distance = math.abs((Vector2.new(CurrentHitNotePos.X,CurrentHitNotePos.Y) - Vector2.new(HitObj.Position.X,HitObj.Position.Y)).Magnitude)
				spawn(function()
					if isincircle() and Is == false and ((CurrentHitnote ~= HitNoteID and Distance > CircleSize) or HitDelay < -EarlyMiss) then -- rip notelock
						local ShakeValue = Instance.new("NumberValue",script.Parent.PlayFrame)
						ShakeValue.Value = 5
						TweenService:Create(ShakeValue,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{Value = 0}):Play()
						local PositiveValue = 1
						local Connection = ShakeValue.Changed:Connect(function()
							PositiveValue *= -1
							Circle.AnchorPoint = Vector2.new(0.5+(PositiveValue*ShakeValue.Value*0.01),0.5)
						end)
						wait(0.25)
						Connection:Disconnect()
						ShakeValue:Destroy()
						Circle.AnchorPoint = Vector2.new(0.5,0.5)
					end
				end)]]
				if Is == false then
					if osuStableNotelock == true then -- osu!stable notelock
						if CurrentHitnote ~= HitNoteID then
							return
						end
					else -- osu!lazer notelock

						local isTop = true
						local PrevNoteExist = false

						for _,data in pairs(DisplayingHitnote) do
							if data.Id > HitNoteID and isinPosition(data.X,data.Y) and (CurrentTime - data.Time) > -hit50 and not isincircle() then
								isTop = false
								break
							elseif data.Id < HitNoteID and not data.Is == true then
								PrevNoteExist = true
							end
						end

						if isTop == false then
							-- this note will auto miss as the newer obj get hitted inside h50 window

							Is = true
							if Accurancy.Combo >= 20 then
								script.Parent.ComboBreak:Play()
							end
							Accurancy.Combo = 0
							Accurancy.PerfomanceCombo = 0
							Missed = true
							if Type ~= 2 or SliderMode == false then
								Accurancy.miss += 1
								CreateHitResult(1)
								AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,0)
							end
							DrainHP(MissDrain)
							ComboNoteData.Missor50 = true
							ComboNoteData.Full300 = false
							HitMiss = true
							Circle.ApproachCircle:Destroy()
							Circle:Destroy()

							TotalNotes -= 1

							DisplayingHitnote[HitNoteID] = nil
							return
						else -- If checked, then the game will check if the position that cursor are in have more than 2 notes or not
							local CanbePressed = true
							for _,data in pairs(DisplayingHitnote) do
								if data.Id < HitNoteID and isinPosition(data.X,data.Y) and not data.Is == true then
									CanbePressed = false
									break -- if another note were found inside the position, then check if that note is a previous note. If true, current note can't be processed at current click
								end
							end
							if CanbePressed == false then
								return 
							end

							-- Notelock check

							if PrevNoteExist and HitDelay < -hit50 then -- note can't be hit if exist
								return
							end
						end
					end

					if (HitDelay >= -EarlyMiss or isSpectating) and isincircle() then

						Is = true
						DisplayingHitnote[HitNoteID].Is = true
						ProcessFunction(function()
							wait()
							DisplayingHitnote[HitNoteID] = nil
						end)
						CurrentHitnote = HitNoteID + 1
						if math.abs(HitDelay) > hit50 and not isSpectating then -- Just in case they hit too early or "too late"
							if Accurancy.Combo >= 20 then
								script.Parent.ComboBreak:Play()
							end
							Accurancy.Combo = 0
							Accurancy.PerfomanceCombo = 0
							Missed = true
							DrainHP(MissDrain)
							ComboNoteData.Missor50 = true
							ComboNoteData.Full300 = false
							if Type ~= 2 or SliderMode == false then
								Accurancy.miss += 1
								CreateHitResult(1)
								AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,0)
							end
							HitMiss = true
							Circle.ApproachCircle:Destroy()
							Circle:Destroy()
						else
							Circle.ApproachCircle:Destroy()
							Accurancy.Combo += 1
							TickCollected += 1
							if Accurancy.Combo > Accurancy.MaxCombo then
								Accurancy.MaxCombo = Accurancy.Combo
							end
							ProcessFunction(function()
								local HitsountType = tonumber(HitObj.ExtraData[1])
								local HitSounds = {}
								HitSounds[#HitSounds+1] = script.HitSound:Clone()
								if HitsountType == 2 or HitsountType == 14 or HitsountType == 6 or HitsountType == 10 then
									HitSounds[#HitSounds+1] = script.HitSoundWhistle:Clone()
								end
								if HitsountType == 4 or HitsountType == 14 or HitsountType == 6 or HitsountType == 12 then
									HitSounds[#HitSounds+1] = script.HitSoundFinish:Clone()
								end
								if HitsountType == 8 or HitsountType == 14 or HitsountType == 10 or HitsountType == 12 then
									HitSounds[#HitSounds+1] = script.HitSoundClap:Clone()
								end
								for _,Sound in pairs(HitSounds) do
									Sound.Parent = script.Parent.HitSounds
									Sound:Play()
								end
								wait(1.4)
								for _,Sound in pairs(HitSounds) do
									Sound:Destroy()
								end
							end)
							if Type ~= 2 or SliderMode == false then
								Accurancy.PerfomanceCombo += 1 
								if Accurancy.PerfomanceCombo > Accurancy.MaxPeromanceCombo then
									Accurancy.MaxPeromanceCombo = Accurancy.PerfomanceCombo
								end
								if math.abs(HitDelay) < hit300 then
									if isLastComboNote then
										if ComboNoteData.Full300 then
											AddHP(10)
										elseif not ComboNoteData.Missor50 then
											AddHP(5)
										else
											AddHP(3.2)
										end
									else
										AddHP(3.2)
									end

									Accurancy.h300Bonus += hit300 - math.abs(HitDelay)
									Accurancy.bonustotal += hit300
									Accurancy.h300 += 1
									CreateHitDelay(Color3.new(0.686275, 1, 1),HitDelay)
									--CreateHitResult(4)
									AddScore(300)
									AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,1)
								elseif math.abs(HitDelay) < hit100 then
									if isLastComboNote then
										if not ComboNoteData.Missor50 then
											AddHP(5)
										else
											AddHP(1.6)
										end
									else
										ComboNoteData.Full300 = false
										AddHP(1.6)
									end
									Accurancy.h100 += 1
									CreateHitDelay(Color3.new(0.686275, 1, 0.686275),HitDelay)
									CreateHitResult(3)
									AddScore(100)
									AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,1/3)
								else
									ComboNoteData.Missor50 = true
									ComboNoteData.Full300 = false
									DrainHP(0)
									Accurancy.h50 += 1
									CreateHitDelay(Color3.new(1, 1, 0.686275),HitDelay)
									CreateHitResult(2)
									AddScore(50)
									AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,1/6)
								end
							else
								AddHP(1.6)
								Score += 30
								if math.abs(HitDelay) < hit300 then
									CreateHitDelay(Color3.new(0.686275, 1, 1),HitDelay)
								elseif math.abs(HitDelay) < hit100 then
									CreateHitDelay(Color3.new(0.686275, 1, 0.686275),HitDelay)
								else
									CreateHitDelay(Color3.new(1, 1, 0.686275),HitDelay)
								end
							end

							local t_ = game:GetService("TweenService"):Create(Circle,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Size = UDim2.new(CircleSize*1.5/384,0,CircleSize*1.5/384,0)})
							local t2_ = game:GetService("TweenService"):Create(Circle.HitCircle,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1})
							AddHitnoteAnimation(t_)
							AddHitnoteAnimation(t2_)
							t_:Play()
							t2_:Play()
							Circle.HitCircleLightning:Destroy()
							Circle.Lightning:Destroy()

							for _,Object in pairs(Circle:GetChildren()) do
								ProcessFunction(function()
									if Object:IsA("ImageLabel") and Object.Name ~= "Lightning" then
										game:GetService("TweenService"):Create(Object,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()
									end
									if Object:IsA("TextLabel") then
										game:GetService("TweenService"):Create(Object,TweenInfo.new(0,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{TextTransparency = 1,TextStrokeTransparency = 1}):Play()
									end
								end)
							end
							wait(0.25)
							Circle:Destroy()
						end
						TotalNotes -= 1
					end
				end
			end)
		end

	end)
end

isDrain = false
TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans}):Play()
TweenService:Create(workspace.BackgroundPart.SurfaceGui.Frame.BackgroundFrame.ImageFrame.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans}):Play()



if isSpectating == false then
	repeat wait() until tick() - Start > (BeatmapData[#BeatmapData].Time + hit50)/1000

	local Type = BeatmapData[#BeatmapData].Type


	if Type == 8 or Type == 12 or math.floor((Type-28)/16) == (Type-28)/161 then
		repeat wait() until (tick()-Start) >= BeatmapData[#BeatmapData].SpinTime/1000
		spawn(function()
			TweenService:Create(script.Parent.ProgressBar,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Size = UDim2.new(0,4,0,4)}):Play()
			wait(1.1)
			TweenService:Create(script.Parent.ProgressBar,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Position = UDim2.new(1,-50,0,-41)}):Play()
		end)
		wait(2)
	else
		repeat wait() until LastNoteData ~= "NotLoaded"
		if LastNoteData.Slider == true then
			wait(LastNoteData.SliderTime)
		end
		spawn(function()
			TweenService:Create(script.Parent.ProgressBar,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Size = UDim2.new(0,4,0,4)}):Play()
			wait(1.1)
			TweenService:Create(script.Parent.ProgressBar,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Position = UDim2.new(1,-50,0,-41)}):Play()
		end)
		wait(2)
	end
else
	repeat wait() until ScoreResultDisplay == true
end

ScoreResultDisplay = true

if ReplayMode == false then
	ReplayRecordEnabled = false

	local Data = game.HttpService:JSONEncode(ReplayData)

	script.Parent.Replay.Value = Data
end

spawn(function()
	TweenService:Create(script.Parent.Song,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true),{Volume = 0.5}):Play()
end)

TweenService:Create(script.Parent.Interface.BG,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true),{BackgroundTransparency = 0}):Play()
wait(0.25)

CursorUnlocked = true
UserInputService.MouseBehavior = Enum.MouseBehavior.Default
Cursor.Visible = false
RblxNewCursor.Visible = true


local ResultFrame = game.Players.LocalPlayer.PlayerGui.BG.ResultFrame.MainFrame.DisplayFrame
ResultFrame.hit300s.Text = Accurancy.h300.."x"
ResultFrame.hit100s.Text = Accurancy.h100.."x"
ResultFrame.hit50s.Text = Accurancy.h50.."x"
ResultFrame.hit0s.Text = Accurancy.miss.."x"
if Accurancy.miss > 0 then
	ResultFrame.hit0s.TextColor3 = Color3.fromRGB(255, 107, 107)
end
local TotalNoteResult = Accurancy.h300+Accurancy.h100+Accurancy.h50+Accurancy.miss
local RawAccurancy = ((Accurancy.h300*300+Accurancy.h100*100+Accurancy.h50*50)/(TotalNoteResult*300))*100
local GameAccurancy = math.floor((RawAccurancy)*100)/100
local tostringAcc = tostring(GameAccurancy)
if tostringAcc == "-nan(ind)" or tostringAcc == "inf" or tostringAcc == "100" then
	tostringAcc = "100.00"
elseif string.sub(tostringAcc,#tostringAcc-1,#tostringAcc-1) == "." then
	tostringAcc = tostringAcc.."0"
elseif #tostringAcc <= 2 then
	tostringAcc = tostringAcc..".00"
end
if tonumber(tostringAcc) < 10 then
	tostringAcc = "0"..tostringAcc
end
ResultFrame.Accurancy.Text = Accurancy.MaxCombo.."x | "..tostringAcc.."%"

local GameplayRank = "D"
local percent300s = Accurancy.h300/(Accurancy.h300+Accurancy.h100+Accurancy.h50+Accurancy.miss)
local percent50s = Accurancy.h50/(Accurancy.h300+Accurancy.h100+Accurancy.h50+Accurancy.miss)
local misstotal = Accurancy.miss

local RankColor = {
	SS = Color3.fromRGB(255, 255, 0),
	S = Color3.fromRGB(255, 255, 0),
	A = Color3.fromRGB(0, 255, 0),
	B = Color3.fromRGB(0, 85, 255),
	C = Color3.fromRGB(170, 0, 127),
	D = Color3.fromRGB(255, 0, 0)
}

local SS = false

if percent300s >= 0.6 then
	GameplayRank = "C"
end
if (percent300s >= 0.7 and misstotal <= 0) or percent300s >= 0.8 then
	GameplayRank = "B"
end
if (percent300s >= 0.8 and misstotal <= 0) or percent300s >= 0.9 then
	GameplayRank = "A"
end
if percent300s >= 0.9 and misstotal <= 0 and percent50s < 0.01 then
	GameplayRank = "S"
end
if GameAccurancy >= 100 then
	GameplayRank = "SS"
	SS = true
end

script.Parent.MobileHit.Visible = false
script.Parent.ComboDisplay.Visible = false
script.Parent.ScoreDisplay.Visible = false
script.Parent.HitError.Visible = false
script.Parent.AccurancyDisplay.Visible = false
script.Parent.ComboFrameDisplay.Visible = false
script.Parent.ScoreFrameDisplay.Visible = false
script.Parent.AccurancyFrameDisplay.Visible = false
game.Players.LocalPlayer.PlayerGui.BG.UnrankedSign.Visible = false
game.Players.LocalPlayer.PlayerGui.BG.HitKey.Visible = false
script.Parent.PSEarned.Visible = false
script.Parent.HealthBar.Visible = false
script.Parent.Leaderboard.Visible = false

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,true)

----------- Caculate perfomance score -----------

local RewaredAccPS = MaxAccurancyPS* 0.727^(100-tonumber(RawAccurancy)) -- get whole accurancy
local RewaredAimPS = 0
local RewaredStreamPS = 0

for Top,AimPS in pairs(AimPSList) do
	RewaredAimPS += AimPS*0.8^(Top-1)
end
for Top,StreamPS in pairs(StreamPSList) do
	RewaredStreamPS += StreamPS*0.8^(Top-1)
end
local ComboPerfomanceMultiplier = 1 --1*0.25^((1-(Accurancy.MaxPeromanceCombo/GameMaxCombo))*2)
RewaredAimPS = RewaredAimPS * (1 - (PSPunishment/PSPunishmentLimit)) * ComboPerfomanceMultiplier
RewaredStreamPS = RewaredStreamPS * (1 - (PSPunishment/PSPunishmentLimit)) * ComboPerfomanceMultiplier


local TotalRewardedPS = RewaredAccPS + RewaredAimPS + RewaredStreamPS -- This will be needed for golbal ranking

if Flashlight == true then TotalRewardedPS *= 1.12 end
if HiddenMod == true then TotalRewardedPS *= 1.06 end
if HardRock == true then TotalRewardedPS *= 1.06 end

----------- Submit play result ---------------
local function GetNewNum(CurrentNum)
	CurrentNum = tostring(CurrentNum)
	local NewNum = ""

	for i = 1,#CurrentNum do
		i = (#CurrentNum-i)+1
		if math.floor((#NewNum+1)/4)-((#NewNum+1)/4) == 0 then
			NewNum = string.sub(CurrentNum,i,i)..","..NewNum
		else
			NewNum = string.sub(CurrentNum,i,i)..NewNum
		end
	end
	return NewNum
end


local MetaData = ReturnData.Overview.Metadata
local OnlineResult = ResultFrame.Parent.OnlineDisplayFrame

ResultFrame.Score.Text = "Score: "..math.floor(Score)
ResultFrame.Grade.Text = (not SS and GameplayRank) or "S"
ResultFrame.Grade.TextColor3 = RankColor[GameplayRank]
ResultFrame.Parent.Parent.DetailedInfo.Text = "Beatmap: "..MetaData.SongCreator.." - "..MetaData.MapName.." | ["..MetaData.DifficultyName.."] // "..MetaData.BeatmapCreator.." | "..tostring(SongSpeed).."x"
ResultFrame.Display_SS.Visible = SS


OnlineResult.OnlineScore.Score.Text = GetNewNum(math.floor(Score))
OnlineResult.OnlineAccurancy.Accurancy.Text = tostringAcc.."%"
OnlineResult.OnlineMaxCombo.MaxCombo.Text = GetNewNum(Accurancy.MaxCombo).."x"
OnlineResult.OnlinePS.PerfomanceScore.Text = GetNewNum(math.floor(TotalRewardedPS)).."ps"
OnlineResult.OverallPerfomance.TotalPS.Text = game.Players.LocalPlayer.leaderstats.Perfomance.Value

-- AccurancyChart
local AccurancyChartFrame = ResultFrame.AccurancyChart.MainFrame.MainFrame

local FrameList = {}
local LastDataAccuracy = 1

for i,Accurancy in pairs(TimeAccurancy) do
	local RankColor = {
		SS = Color3.fromRGB(0, 255, 255),
		S = Color3.fromRGB(255, 255, 0),
		A = Color3.fromRGB(0, 255, 0),
		B = Color3.fromRGB(0, 85, 255),
		C = Color3.fromRGB(217, 0, 130),
		D = Color3.fromRGB(255, 0, 0)
	}

	local ChartFrame = script.ChartFrame:Clone()
	ChartFrame.Parent = AccurancyChartFrame
	ChartFrame.LayoutOrder = i
	ChartFrame.ConnectionFrame.BackgroundColor3 = RankColor[Accurancy[2]]
	ChartFrame.PointFrame.Position = UDim2.new(0,0,1-Accurancy[1],0)
	ChartFrame.ConnectionFrame.Position = UDim2.new(0,0,1-LastDataAccuracy,0)
	ChartFrame.ConnectionFrame.Size = UDim2.new(0,0,0,0)
	LastDataAccuracy = Accurancy[1]
	FrameList[i] = ChartFrame
end

for i,ChartFrame in pairs(FrameList) do
	if i ~= #FrameList then
		local NextPointPos = Vector2.new(FrameList[i+1].PointFrame.AbsolutePosition.X,FrameList[i+1].PointFrame.AbsolutePosition.Y)
		local CurrentPointPos = Vector2.new(ChartFrame.PointFrame.AbsolutePosition.X,ChartFrame.PointFrame.AbsolutePosition.Y)


		ChartFrame.ConnectionFrame.Visible = true
		local ConnectionLength = math.abs((NextPointPos-CurrentPointPos).Magnitude)
		local AvgPos = (FrameList[i+1].PointFrame.Position.Y.Scale+ChartFrame.PointFrame.Position.Y.Scale)/2
		local Point = NextPointPos-CurrentPointPos
		local Rotation = math.deg(math.atan2(Point.Y,Point.X))
		spawn(function()
			wait(((i-1)/#FrameList)*3)
			TweenService:Create(ChartFrame.ConnectionFrame,TweenInfo.new((1/#FrameList)*3,Enum.EasingStyle.Linear),{Position = UDim2.new(0.5,0,AvgPos,0),Size = UDim2.new(0,ConnectionLength+2,0,2),Rotation = Rotation}):Play()
		end)

		--[[
		ChartFrame.ConnectionFrame.Position = UDim2.new(0.5,0,AvgPos)
		ChartFrame.ConnectionFrame.Size = UDim2.new(0,ConnectionLength+2,0,2)
		ChartFrame.ConnectionFrame.Rotation = Rotation]]
	end
end

-- Perfomance chart

local PerfomanceChartFrame = ResultFrame.PerfomanceChart.MainFrame.MainFrame

local PerfomanceFrameList = {}
local LastPerfomance = 0

for i,PerfomanceScore in pairs(TimePerfomance) do
	local ChartFrame = script.ChartFrame:Clone()
	ChartFrame.Parent = PerfomanceChartFrame
	ChartFrame.LayoutOrder = i
	ChartFrame.PointFrame.Position = UDim2.new(0,0,1-(PerfomanceScore/HighestPerfomance),0)
	PerfomanceFrameList[i] = ChartFrame
	ChartFrame.ConnectionFrame.Position = UDim2.new(0,0,1-LastPerfomance,0)
	ChartFrame.ConnectionFrame.Size = UDim2.new(0,0,0,0)
	LastPerfomance = PerfomanceScore/HighestPerfomance
end

for i,ChartFrame in pairs(PerfomanceFrameList) do
	if i ~= #PerfomanceFrameList then
		local NextPointPos = Vector2.new(PerfomanceFrameList[i+1].PointFrame.AbsolutePosition.X,PerfomanceFrameList[i+1].PointFrame.AbsolutePosition.Y)
		local CurrentPointPos = Vector2.new(ChartFrame.PointFrame.AbsolutePosition.X,ChartFrame.PointFrame.AbsolutePosition.Y)


		ChartFrame.ConnectionFrame.Visible = true
		local ConnectionLength = math.abs((NextPointPos-CurrentPointPos).Magnitude)
		local AvgPos = (PerfomanceFrameList[i+1].PointFrame.Position.Y.Scale+ChartFrame.PointFrame.Position.Y.Scale)/2
		local Point = NextPointPos-CurrentPointPos
		local Rotation = math.deg(math.atan2(Point.Y,Point.X))

		spawn(function()
			wait(((i-1)/#PerfomanceFrameList)*3)
			TweenService:Create(ChartFrame.ConnectionFrame,TweenInfo.new((1/#PerfomanceFrameList)*3,Enum.EasingStyle.Linear),{Position = UDim2.new(0.5,0,AvgPos,0),Size = UDim2.new(0,ConnectionLength+2,0,2),Rotation = Rotation}):Play()
		end)

		--[[
		ChartFrame.ConnectionFrame.Position = UDim2.new(0.5,0,AvgPos)
		ChartFrame.ConnectionFrame.Size = UDim2.new(0,ConnectionLength+2,0,2)
		ChartFrame.ConnectionFrame.Rotation = Rotation]]
	end
end

-----

if isSpectating == true then
	OnlineResult.OnlinePS.PerfomanceScore.Text = "-"
end

ResultFrame.Parent.Parent.Visible = true

if AutoPlay == true and ReplayMode ~= true then
	--game:GetService("TweenService"):Create(Cursor,TweenInfo.new(1,Enum.EasingStyle.Sine),{Position = UDim2.new(0.5,0,1.5,0)}):Play()
end

local CanbeSubmitted = true

if not HardCore and Score < 1000 then
	CanbeSubmitted = false
end

if PlayRanked == true and CanbeSubmitted then
	local RankedScore = math.floor(Score)
	OnlineResult.SubmitStatus.Text = "Submitting play..."
	--ResultFrame.Score.Text = "[Submitting...]"
	local ReturnResult = game.ReplicatedStorage.BeatmapLeaderboard:InvokeServer(2,{DatastoreName = CurrentKey,BeatmapKey = tostring(BeatmapKey),PlayData = {
		Score = RankedScore,
		ExtraData = {
			Accurancy = tostringAcc,
			MaxCombo = Accurancy.MaxCombo,
			Grade = GameplayRank,
			Date = os.time(),
			ExtraAccurancy = {Accurancy.h300,Accurancy.h100,Accurancy.h50,Accurancy.miss},
			Speed = SongSpeed,
			PS = TotalRewardedPS,
			Mod = {
				FL = Flashlight,
				SL = SliderMode,
				HC = HardCore,
				HD = HiddenMod,
				HR = HardRock
			}
		},
		SecurityData = { -- You somehow change this? you gonna get kick
			BeatmapName = Beatmap.Name,
			beatmapid = ReturnData.BeatmapSetsData.BeatmapID,
			metadata = ReturnData.Overview.Metadata,
			SecurityKey = ServerSecurityKey -- There's no way you get this key.. do you?
		}
	}})

	local OldScore = ReturnResult.Score

	repeat wait() until OnlineResult.Visible == true

	if OldScore == nil then
		TweenService:Create(OnlineResult.OnlineScore,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,200)}):Play()
		TweenService:Create(OnlineResult.OnlineAccurancy,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,200)}):Play()
		TweenService:Create(OnlineResult.OnlineMaxCombo,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,200)}):Play()
		TweenService:Create(OnlineResult.OnlinePS,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,200)}):Play()


		--OnlineResult.OnlineScore.BackgroundColor3 = Color3.fromRGB(0,200,200)
		--OnlineResult.OnlineAccurancy.BackgroundColor3 = Color3.fromRGB(0,200,200)
		--OnlineResult.OnlineMaxCombo.BackgroundColor3 = Color3.fromRGB(0,200,200)
		--OnlineResult.OnlinePS.BackgroundColor3 = Color3.fromRGB(0,200,200)

		OnlineResult.OnlineScore.Improvement.Text = "new!"
		OnlineResult.OnlineAccurancy.Improvement.Text = "new!"
		OnlineResult.OnlineMaxCombo.Improvement.Text = "new!"
		OnlineResult.OnlinePS.Improvement.Text = "new!"
	else
		local OldPS = ReturnResult.ExtraData.PS

		if OldPS == nil	 then
			OldPS = 0
		end
		OldPS = math.floor(OldPS)
		if RankedScore > OldScore then
			TweenService:Create(OnlineResult.OnlineScore,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,0)}):Play()
			OnlineResult.OnlineScore.Improvement.Text = "+"..GetNewNum(RankedScore - OldScore)



			if TotalRewardedPS > OldPS then
				TweenService:Create(OnlineResult.OnlinePS,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,0)}):Play()
				OnlineResult.OnlinePS.Improvement.Text = "+"..GetNewNum(math.floor(TotalRewardedPS - OldPS)).."ps"
			else
				OnlineResult.OnlinePS.Improvement.Text = "PB: "..GetNewNum(OldPS).."ps"
			end
		else
			OnlineResult.OnlineScore.Improvement.Text = "PB: "..GetNewNum(OldScore)
			OnlineResult.OnlinePS.Improvement.Text = "PB: "..tostring(OldPS).."ps"
		end

		local PBAccurancy = ReturnResult.ExtraData.Accurancy
		local Acc = tonumber(PBAccurancy)

		if tonumber(tostringAcc) > Acc then
			TweenService:Create(OnlineResult.OnlineAccurancy,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,0)}):Play()
			OnlineResult.OnlineAccurancy.Improvement.Text = "+"..tostring(tonumber(tostringAcc-Acc)).."%"
		else
			OnlineResult.OnlineAccurancy.Improvement.Text = "PB: "..tostring(tonumber(Acc)).."%"
		end

		local PBMaxCombo = ReturnResult.ExtraData.MaxCombo

		if Accurancy.MaxCombo > PBMaxCombo then
			TweenService:Create(OnlineResult.OnlineMaxCombo,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,0)}):Play()
			OnlineResult.OnlineMaxCombo.Improvement.Text = "+"..GetNewNum(Accurancy.MaxCombo-PBMaxCombo)
		else
			OnlineResult.OnlineMaxCombo.Improvement.Text = "PB: "..GetNewNum(PBMaxCombo).."x"
		end
	end

	if ReturnResult.NewPerfomance then
		OnlineResult.OverallPerfomance.TotalPS.Text = GetNewNum(ReturnResult.NewPerfomance).."ps"
		local StringImprovement = "-"

		if ReturnResult.PSImprovement > 0 then
			TweenService:Create(OnlineResult.OverallPerfomance,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,0)}):Play()
			local Improvement = math.floor(ReturnResult.PSImprovement)
			StringImprovement = "+"..tostring(Improvement)
		elseif ReturnResult.PSImprovement < 0 then
			TweenService:Create(OnlineResult.OverallPerfomance,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(200,0,0)}):Play()
			local Improvement = math.floor(ReturnResult.PSImprovement)
			StringImprovement = GetNewNum(Improvement)
			if Improvement == 0 then
				StringImprovement = "-"..GetNewNum(Improvement)
			end
		end

		OnlineResult.OverallPerfomance.Improvement.Text = StringImprovement.."ps"
	else
		OnlineResult.OverallPerfomance.TotalPS.Text = game.Players.LocalPlayer.leaderstats.Perfomance.Value
		OnlineResult.OverallPerfomance.Improvement.Text = "-"
	end

	OnlineResult.SubmitStatus.Text = ""
	--ResultFrame.Score.Text = "Score: "..tostring(RankedScore)..ExtraText
else
	if isSpectating == true then
		OnlineResult.SubmitStatus.Text = "!The play won't submit from your site!"
	elseif AutoPlay then
		OnlineResult.SubmitStatus.Text = "!This is an AutoPlay!"
	elseif not CanbeSubmitted then
		OnlineResult.SubmitStatus.Text = "!Score too low, get a better score!"
	else
		OnlineResult.SubmitStatus.Text = "!This play is unranked!"
	end
end


--[[
	Data = {Name,Rank,Score,ExtraData = {Speed,Accurancy,MaxCombo,Grade,Date,ExtraAccurancy = {300s,100s,50s,miss}}}
	]]


--------------------------------------------------










-- osu!corescript by VtntGaming

----------------- End script -----------------

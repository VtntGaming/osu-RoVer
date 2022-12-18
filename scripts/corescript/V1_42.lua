osuLocalConvert = require(workspace.OsuConvert)



-- Services load

TweenService = game:GetService("TweenService")
local wait = require(workspace.WaitModule)




-- Instance load

local MouseHitEvent = Instance.new("BindableEvent")
local MouseHitEndEvent = Instance.new("BindableEvent")
game.StarterGui:SetCore("ResetButtonCallback",false)

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
	if tonumber(AsyncedSetting.CursorSensitivity) and tonumber(AsyncedSetting.CursorSensitivity) ~= 1 then
		local Value = AsyncedSetting.CursorSensitivity*100
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
	CurrentSetting.Parent.VirtualSettings.CustomComboColor.Value = AsyncedSetting.CustomComboColorData or "[]"
	CurrentSetting.Parent.VirtualSettings.CircleNumberData.Value = AsyncedSetting.CircleNumberData or "[]"
	CurrentSetting.MobileModeEnabled.Text = "Mobile mode: "..Option[tostring(AsyncedSetting.MobileHit)]
	CurrentSetting.MouseButtonEnabled.Text = "Mouse button: "..Option[tostring(AsyncedSetting.MouseButton)]
	CurrentSetting.OldCursorMovement.Text = "Virtual cursor movement: "..Option[tostring(not AsyncedSetting.OldCursorMovement)]
	--CurrentSetting.NewCircleOverlay.Text = "New circle overlay: "..Option[tostring(AsyncedSetting.NewCircleOverlay)]
	CurrentSetting.OldScoreInterface.Text = "Old score interface: "..Option[tostring(AsyncedSetting.OldScoreInterface)]
	CurrentSetting.StableNotelock.Text = "In-game notelock: ".. AdvancedOption.NotelockStyle[tostring(AsyncedSetting.osuStableNotelock)]
	CurrentSetting.DisplayPS.Text = "Display PS: "..Option[tostring(AsyncedSetting.PerfomanceDisplay)]
	CurrentSetting.RightHitzone.Text = "Right side hitzone: "..Option[tostring(AsyncedSetting.RightHitZone)]
	CurrentSetting.DisableChatInGame.Text = "Disable chat in-game: "..Option[tostring(AsyncedSetting.InGameChatDisabled)]
	CurrentSetting.DisplayInGameLB.Text = "In-game leaderboard: "..Option[tostring(AsyncedSetting.DisplayInGameLB)]
	CurrentSetting.HitZoneEnabled.Text = "Hit zone: "..Option[tostring(AsyncedSetting.HitZone)]
	CurrentSetting.CustomComboColor.Text = "Custom combo color: "..Option[tostring(AsyncedSetting.CustomComboColor)]
	CurrentSetting.DisplayDetailedPS.Text = "Detailed PS: "..Option[tostring(AsyncedSetting.DetailedPSDisplay)]
	CurrentSetting.DisplayFramerate.Text = "Show FPS: "..Option[tostring(AsyncedSetting.DisplayFPS)]
	CurrentSetting.OptimizedPerfomance.Text = "Optimized perfomance: "..Option[tostring(AsyncedSetting.OptimizedPerfomance)]
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
game.Players.LocalPlayer.PlayerGui.MenuInterface.ProfileButton.Visible = true
game.Players.LocalPlayer.PlayerGui.MenuInterface.MultiplayerButton.Visible = true
game.Players.LocalPlayer.PlayerGui.MenuInterface.UpdateLogButton.Visible = true
game.Players.LocalPlayer.PlayerGui.MenuInterface.ExpandButton.ExpandButton.Visible = true
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
DetailedPSDisplay = false
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
EasyMod = false
InGameLeaderboard = true
HitZoneEnabled = true
SongVolume = CurrentSetting.VirtualSettings.InstantSettings.SongVolume.Value
HardRock = false
CustomComboColorEnabled = false
OnMultiplayer = false
MultiplayerMatchFailed = false
OptimizedPerfomance = false
ScoreV2Enabled = false

-- PreviewFrameScriptSettings
PreviewFrameBaseVolume = 0.5




-- Default settings
BeatmapStudio = "playerchoose" --If test on studio, value to "playerchoose" if wanna set it to random
Id = 1
gameEnded = true
onTutorial = false
PlayRanked = true

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

if CurrentSetting.MainSettings.MobileModeEnabled.Text == "Mobile mode: Disabled" then
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

if CurrentSetting.MainSettings.SliderMode.Text == "Sliders: Enabled" then
	SliderMode = true
end

if CurrentSetting.MainSettings.OldCursorMovement.Text == "Virtual cursor movement: Disabled" then
	OldCursorMovement = true
end


if CurrentSetting.MainSettings.DisplayPS.Text == "Display PS: Enabled" then
	PSDisplay = true
end

if CurrentSetting.MainSettings.OldScoreInterface.Text == "Old score interface: Enabled" then
	OldInterface = true
end

if CurrentSetting.MainSettings.StableNotelock.Text == "In-game notelock: Lazer" then
	osuStableNotelock = false
end

if CurrentSetting.MainSettings.HitErrorInterface.Text == "Hit error display: Disabled" then
	HitErrorEnabled = false
end

if CurrentSetting.MainSettings.OverallInterface.Text == "Overall interface: Disabled" then
	OverallInterfaceEnabled = false
end

if CurrentSetting.MainSettings.DisplayNewPerfomance.Text == "Show converted PP: Enabled" then
	NewPerfomanceDisplay = true
end

if CurrentSetting.MainSettings.RightHitzone.Text == "Right side hitzone: Enabled" then
	MobileModeRightHitZone = true
end

if CurrentSetting.MainSettings.DisableChatInGame.Text == "Disable chat in-game: Enabled" then
	DisableChatInGame = true
end

if CurrentSetting.MainSettings.KeepOriginalPitch.Text == "Speed pitch: Enabled" then
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

if CurrentSetting.MainSettings.Easy.Text == "Easy: Enabled" then
	EasyMod = true
end

if CurrentSetting.MainSettings.CustomComboColor.Text == "Custom combo color: Enabled" then
	CustomComboColorEnabled = true
end

if CurrentSetting.MainSettings.OptimizedPerfomance.Text == "Optimized perfomance: Enabled" then
	OptimizedPerfomance = true
end

if CurrentSetting.MainSettings.ScoreV2.Text == "ScoreV2: Enabled" then
	ScoreV2Enabled = true
end

if CurrentSetting.MainSettings.DisplayDetailedPS.Text == "Detailed PS: Enabled" then
	DetailedPSDisplay = true
end


CurrentModData = {
	HD = HiddenMod,
	FL = Flashlight,
	HC = HardCore,
	HR = HardRock,
	EZ = EasyMod,
	Speed = tonumber(CurrentSetting.MainSettings.Speed.Text) or 1
}

function LoadMultiplier()
	local Multiplier = 1
	local PSMultiplier = 1
	if CurrentModData.HD then
		Multiplier *= 1.06
		PSMultiplier *= 1.04 --1.08
	end
	if CurrentModData.HR then
		Multiplier *= 1.06
		PSMultiplier *= 1.2 --1.45
	end
	if CurrentModData.FL then
		Multiplier *= 1.12
		PSMultiplier *= 1.00
	end
	if CurrentModData.HC then
		Multiplier *= 2
		PSMultiplier *= 1.05 --1.11
	end
	if CurrentModData.EZ then
		Multiplier *= 0.5
		PSMultiplier *= 0.87 --0.75
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
	PSMultiplier = math.floor((PSMultiplier*100)+0.5)/100
	local ExtraScoreMPText = ""
	local ExtraPSMPText = ""
	if SliderMode == true then
		ExtraScoreMPText = " (+?)"
	end
	if CurrentModData.Speed > 1 and CurrentModData.HR then
		ExtraPSMPText = " (+?)"
	elseif CurrentModData.FL then
		ExtraPSMPText = " (+?)"
	elseif CurrentModData.EZ then
		ExtraPSMPText = " (-?)"
	elseif CurrentModData.Speed < 1 then
		ExtraPSMPText = " (-?)"
	elseif CurrentModData.HR then
		ExtraPSMPText = " (+?)"
	end
	CurrentSetting.MainSettings.ScoreMultiplier.Text = "Score multiplier: "..tostring(Multiplier).."x"..ExtraScoreMPText
	CurrentSetting.MainSettings.PerfomanceMultiplier.Text = "PS multiplier: "..tostring(PSMultiplier).."x"..ExtraPSMPText
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
		CurrentSetting.MainSettings.DisplayPS.Text = 'Display PS: Enabled'
	else 
		CurrentSetting.MainSettings.DisplayPS.Text = 'Display PS: Disabled'
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
	if workspace.GamePlaceId == 6983932919 and not game:GetService("RunService"):IsStudio() then
		game.Players.LocalPlayer.PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("Custom beatmap is disabled in StablePlace, you can visit BetaPlace to test.",Color3.new(1,0,0))
		return
	end
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
		CurrentSetting.MainSettings.MobileModeEnabled.Text = "Mobile mode: Enabled"
	else
		CurrentSetting.MainSettings.MobileModeEnabled.Text = "Mobile mode: Disabled"
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
		CurrentSetting.MainSettings.SliderMode.Text = "Sliders: Enabled"
	else
		CurrentSetting.MainSettings.SliderMode.Text = "Sliders: Disabled"
	end

	LoadMultiplier()
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
		CurrentSetting.MainSettings.HitErrorInterface.Text = "Hit error display: Enabled"
	else
		CurrentSetting.MainSettings.HitErrorInterface.Text = "Hit error display: Disabled"
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
		CurrentSetting.MainSettings.DisplayNewPerfomance.Text = "Show converted PP: Enabled"
	else
		CurrentSetting.MainSettings.DisplayNewPerfomance.Text = "Show converted PP: Disabled"
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
		CurrentSetting.MainSettings.KeepOriginalPitch.Text = "Speed pitch: Enabled"
	else
		CurrentSetting.MainSettings.KeepOriginalPitch.Text = "Speed pitch: Disabled"
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
	if HardRock == true then
		CurrentSetting.MainSettings.HardRock.Text = "Hardrock: Enabled"
		CurrentSetting.MainSettings.Easy.Text = "Easy: Disabled"
		EasyMod = false
		CurrentModData.EZ = false
	else
		CurrentSetting.MainSettings.HardRock.Text = "Hardrock: Disabled"
	end

	LoadMultiplier()
	ReloadPreviewFrame()
end)

CurrentSetting.MainSettings.Easy.MouseButton1Click:Connect(function()
	EasyMod = not EasyMod
	CurrentModData.EZ = EasyMod
	if EasyMod == true then
		CurrentSetting.MainSettings.Easy.Text = "Easy: Enabled"
		CurrentSetting.MainSettings.HardRock.Text = "Hardrock: Disabled"
		HardRock = false
		CurrentModData.HR = false
	else
		CurrentSetting.MainSettings.Easy.Text = "Easy: Disabled"
	end


	LoadMultiplier()
	ReloadPreviewFrame()
end)

CurrentSetting.MainSettings.CustomComboColor.MouseButton1Click:Connect(function()
	CustomComboColorEnabled = not CustomComboColorEnabled
	if CustomComboColorEnabled == true then
		CurrentSetting.MainSettings.CustomComboColor.Text = "Custom combo color: Enabled"
	else
		CurrentSetting.MainSettings.CustomComboColor.Text = "Custom combo color: Disabled"
	end
end)

CurrentSetting.MainSettings.OptimizedPerfomance.MouseButton1Click:Connect(function()
	OptimizedPerfomance = not OptimizedPerfomance
	if OptimizedPerfomance == true then
		CurrentSetting.MainSettings.OptimizedPerfomance.Text = "Optimized perfomance: Enabled"
	else
		CurrentSetting.MainSettings.OptimizedPerfomance.Text = "Optimized perfomance: Disabled"
	end
end)

CurrentSetting.MainSettings.ScoreV2.MouseButton1Click:Connect(function()
	ScoreV2Enabled = not ScoreV2Enabled
	if ScoreV2Enabled == true then
		CurrentSetting.MainSettings.ScoreV2.Text = "ScoreV2: Enabled"
	else
		CurrentSetting.MainSettings.ScoreV2.Text = "ScoreV2: Disabled"
	end
end)

CurrentSetting.MainSettings.DisplayDetailedPS.MouseButton1Click:Connect(function()
	DetailedPSDisplay = not DetailedPSDisplay
	if DetailedPSDisplay == true then
		CurrentSetting.MainSettings.DisplayDetailedPS.Text = "Detailed PS: Enabled"
	else
		CurrentSetting.MainSettings.DisplayDetailedPS.Text = "Detailed PS: Disabled"
	end
end)
DisplayFPS = false

-- Save settings
function SaveGameSettings()
	spawn(function()
		local Settings = CurrentSetting.MainSettings
		SongDelay = Settings.Parent.VirtualSettings.InstantSettings.Offset.Value
		CursorSensitivity= Settings.Parent.VirtualSettings.InstantSettings.Sensitivity.Value*0.01
		CursorID = Settings.Parent.VirtualSettings.CursorImageID.Value
		CursorSize = Settings.Parent.VirtualSettings.CursorSize.Value
		CursorTrailId = Settings.Parent.VirtualSettings.CursorTrailImageID.Value
		CursorTrailSize = Settings.Parent.VirtualSettings.CursorTrailSize.Value
		CursorTrailTransparency = Settings.Parent.VirtualSettings.CursorTrailTransparency.Value
		CircleImageId = Settings.Parent.VirtualSettings.CircleImageId.Value
		CircleOverlayImageId = Settings.Parent.VirtualSettings.CircleOverlayImageId.Value
		ApproachCircleImageId = Settings.Parent.VirtualSettings.ApproachCircleImageId.Value
		EffectVolume = Settings.Parent.VirtualSettings.InstantSettings.EffectVolume.Value
		CircleNumberData = Settings.Parent.VirtualSettings.CircleNumberData.Value
		CircleConfigData = Settings.Parent.VirtualSettings.CircleConfigData.Value
		DisplayFPS = Settings.DisplayFramerate.isEnabled.Value

		local Key1Input = Enum.KeyCode.X
		local Key2Input = Enum.KeyCode.Z
		pcall(function()
			if Settings.K1.KeyInput.Text == "Press a key" or Settings.K2.KeyInput.Text == "Press a key" then
				repeat wait() until Settings.K1.KeyInput.Text ~= "Press a key" and Settings.K2.KeyInput.Text ~= "Press a key"
			end
			Key1Input = Enum.KeyCode[Settings.K1.KeyInput.Text] or Enum.KeyCode.X
			Key2Input = Enum.KeyCode[Settings.K2.KeyInput.Text] or Enum.KeyCode.Z
		end)

		-- Save settings
		local ClientSettings = {
			Offset = SongDelay,
			CursorSensitivity= CursorSensitivity,
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
			CustomComboColor = CustomComboColorEnabled,
			CustomComboColorData = Settings.Parent.VirtualSettings.CustomComboColor.Value,
			CircleNumberData = CircleNumberData,
			CircleConfigData = CircleConfigData, 
			RightHitZone = MobileModeRightHitZone,
			InGameChatDisabled = DisableChatInGame,
			DetailedPSDisplay = DetailedPSDisplay,
			OptimizedPerfomance = OptimizedPerfomance,
			DisplayFPS = DisplayFPS,
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
end

-- Process function [Loop function]

--[[script.Parent.FunctionProcess.Event:Connect(function(Function)
	Function()
end)]]

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

	if Mod.AT == true then
		ModUsed = true
		if Mods > 0 then
			ReturnText = ReturnText..","
		end
		Mods += 1
		if Detailed then
			ReturnText = ReturnText.."AutoPlay"
		else
			ReturnText = ReturnText.."AT"
		end
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

	if Mod.EZ == true then
		ModUsed = true
		if Mods > 0 then
			ReturnText = ReturnText..","
		end
		Mods += 1
		if Detailed then
			ReturnText = ReturnText.."Easy"
		else
			ReturnText = ReturnText.."EZ"
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

LBDetailMovementConnection = game:GetService("UserInputService").InputChanged:Connect(function(data)
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

game.Players.LocalPlayer.PlayerGui.BG.BeatmapLeaderboard.Destroying:Connect(function()
	LBDetailMovementConnection:Disconnect()
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
	LeaderboardFrameConnection[#LeaderboardFrameConnection+1] = LeaderboardFrame.TouchPan:Connect(function()
		local LeaderboardDetail = game.Players.LocalPlayer.PlayerGui.BG.BeatmapLeaderboard.LeaderboardDetail
		LeaderboardDetail.AnchorPoint = Vector2.new(1,0.5)
		LeaderboardDetail.Position = UDim2.new(0,-15,0.5,0)

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
			Tween.Instance.BackgroundTransparency = 0.9
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
	
	if script.Parent:FindFirstChild("GameStarted") or script.Parent:FindFirstChild("_FastRestart") then return end


	LeaderboardInterface.LoadingText.Visible = false

	--[[
	Data = {Name,Rank,Score,ExtraData = {Accurancy,MaxCombo,Grade,Date,ExtraAccurancy = {300s,100s,50s,miss}}}
	]]
	if not script.Parent:FindFirstChild("GameStarted") then

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

				NewLBFrame.MouseEnter:Connect(function()
					TweenService:Create(NewLBFrame.MainFrame.PlayerName,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{TextTransparency = 1}):Play()
					TweenService:Create(NewLBFrame.MainFrame.UserName,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{TextTransparency = 0}):Play()
				end)
				NewLBFrame.MouseLeave:Connect(function()
					TweenService:Create(NewLBFrame.MainFrame.PlayerName,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{TextTransparency = 0}):Play()
					TweenService:Create(NewLBFrame.MainFrame.UserName,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{TextTransparency = 1}):Play()
				end)
				-- check


				local Success,output = pcall(function()
					NewLBFrame.LayoutOrder = tonumber(Data.Rank)
					NewLBFrame.MainFrame.PlayerName.Text = Data.DisplayName
					NewLBFrame.MainFrame.UserName.Text = "@"..Data.Name
					local MaxComboText = ""
					if Data.ExtraData ~= nil then
						MaxComboText = " ("..tostring(Data.ExtraData.MaxCombo).."x)"
						NewLBFrame.MainFrame.Accurancy.Text = tostring(Data.ExtraData.Accurancy).."%"
						NewLBFrame.MainFrame.PlayDate.Text = GetDate(Data.ExtraData.Date).." | "..GetModData(Data.ExtraData.Mod)..tostring(Data.ExtraData.Speed).."x"
						NewLBFrame.MainFrame.Grade.Text = Data.ExtraData.Grade
						if Data.ExtraData.Grade == "SS" then
							NewLBFrame.MainFrame.Grade.Text = "S"
							if Data.ExtraData.Mod and (Data.ExtraData.Mod.HD or Data.ExtraData.Mod.FL) then
								NewLBFrame.MainFrame.Grade_SSH.Visible = true
							else
								NewLBFrame.MainFrame.Grade_SS.Visible = true
							end
						end
						NewLBFrame.MainFrame.Grade.TextColor3 = RankColor[Data.ExtraData.Grade]
						if Data.ExtraData.Grade == "SS" or Data.ExtraData.Grade == "S" then
							if Data.ExtraData.Mod and (Data.ExtraData.Mod.HD or Data.ExtraData.Mod.FL) then
								NewLBFrame.MainFrame.Grade.TextColor3 = Color3.fromRGB(177,177,177)
							end
						end
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
					--NewLBFrame.MainFrame.PlayerImage.Image = Data.ThumbnailId
					ProcessFunction(function()
						if Data.Name == game.Players.LocalPlayer.Name then
							NewLBFrame.MainFrame.PlayerName.TextColor3 = Color3.new(0,1,1)
							NewLBFrame.MainFrame.Rank.TextColor3 = Color3.new(0,1,1)
							NewLBFrame.MainFrame.UserName.TextColor3 = Color3.new(0,1,1)
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
								NewLBFrame.MainFrame.PlayerName.TextColor3 = Color3.new(1, 1, 0.215686)
								NewLBFrame.MainFrame.Rank.TextColor3 = Color3.new(1, 1, 0.215686)
								NewLBFrame.MainFrame.UserName.TextColor3 = Color3.new(1, 1, 0.215686)
							end
						end
					end)
					AddLeaderboardConnection(NewLBFrame,Data.ExtraData)
				end)

				if not Success then print(Data) end
				if not OptimizedPerfomance then
					TweenService:Create(NewLBFrame.MainFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart),{Position = UDim2.new(0,0,0,0)}):Play()
				else
					NewLBFrame.MainFrame.Position = UDim2.new(0,0,0,0)
				end
				wait(0.5)
				for _,a in pairs(NewLBFrame.MainFrame:GetChildren()) do
					if a:IsA("TextLabel") then
						if a.Name ~= "UserName" then
							TweenService:Create(a,TweenInfo.new(0.75,Enum.EasingStyle.Linear),{TextTransparency = 0}):Play()
						end
					else
						TweenService:Create(a,TweenInfo.new(0.75,Enum.EasingStyle.Linear),{ImageTransparency = 0.95}):Play()
					end
				end
				wait(0.5)
				if not OptimizedPerfomance then
					AddLBTweenConnection(TweenService:Create(NewLBFrame.MainFrame,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true),{BackgroundTransparency = 0.8}),(i-1)*0.1)
				end
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
				NewLBFrame.MainFrame.PlayerName.Text = game.Players.LocalPlayer.DisplayName
				NewLBFrame.MainFrame.UserName.Text = "@"..game.Players.LocalPlayer.Name

				NewLBFrame.MouseEnter:Connect(function()
					TweenService:Create(NewLBFrame.MainFrame.PlayerName,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{TextTransparency = 1}):Play()
					TweenService:Create(NewLBFrame.MainFrame.UserName,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{TextTransparency = 0}):Play()
				end)
				NewLBFrame.MouseLeave:Connect(function()
					TweenService:Create(NewLBFrame.MainFrame.PlayerName,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{TextTransparency = 0}):Play()
					TweenService:Create(NewLBFrame.MainFrame.UserName,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{TextTransparency = 1}):Play()
				end)
				local MaxComboText = ""
				if Data.ExtraData ~= nil then
					MaxComboText = " ("..tostring(Data.ExtraData.MaxCombo).."x)"
					NewLBFrame.MainFrame.Accurancy.Text = tostring(Data.ExtraData.Accurancy).."%"
					NewLBFrame.MainFrame.PlayDate.Text = GetDate(Data.ExtraData.Date).." | "..GetModData(Data.ExtraData.Mod)..tostring(math.floor(Data.ExtraData.Speed*100)/100).."x"
					NewLBFrame.MainFrame.Grade.Text = Data.ExtraData.Grade
					if Data.ExtraData.Grade == "SS" then
						NewLBFrame.MainFrame.Grade.Text = "S"
						if Data.ExtraData.Mod and (Data.ExtraData.Mod.HD or Data.ExtraData.Mod.FL) then
							NewLBFrame.MainFrame.Grade_SSH.Visible = true
						else
							NewLBFrame.MainFrame.Grade_SS.Visible = true
						end
					end
					NewLBFrame.MainFrame.Grade.TextColor3 = RankColor[Data.ExtraData.Grade]
					if Data.ExtraData.Grade == "SS" or Data.ExtraData.Grade == "S" then
						if Data.ExtraData.Mod and (Data.ExtraData.Mod.HD or Data.ExtraData.Mod.FL) then
							NewLBFrame.MainFrame.Grade.TextColor3 = Color3.fromRGB(177,177,177)
						end
					end
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
					NewLBFrame.MainFrame.Rank.Text = "-"
					repeat wait() until GolbalLoaded
					if PersonalRank ~= "-" then
						NewLBFrame.MainFrame.Rank.Text = "#"..tostring(PersonalRank)
					else
						local TopPercent = 1+math.floor((99-(tonumber(Data.Score)/Top100Score)*99)+0.5)
						NewLBFrame.MainFrame.Rank.Text = "Top "..tostring(TopPercent).."%"
					end
				end)
				--NewLBFrame.MainFrame.PlayerImage.Image = Data.ThumbnailId
				AddLeaderboardConnection(NewLBFrame,Data.ExtraData)
				if not OptimizedPerfomance then
					TweenService:Create(NewLBFrame.MainFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart),{Position = UDim2.new(0,0,0,0)}):Play()
				else
					NewLBFrame.MainFrame.Position = UDim2.new(0,0,0,0)
				end

				wait(0.5)
				for _,a in pairs(NewLBFrame.MainFrame:GetChildren()) do
					if a:IsA("TextLabel") then
						if a.Name ~= "UserName" then
							TweenService:Create(a,TweenInfo.new(0.75,Enum.EasingStyle.Linear),{TextTransparency = 0}):Play()
						end
					else
						TweenService:Create(a,TweenInfo.new(0.75,Enum.EasingStyle.Linear),{ImageTransparency = 0.95}):Play()
					end
				end
				wait(0.5)
				if not OptimizedPerfomance then
					AddLBTweenConnection(TweenService:Create(NewLBFrame.MainFrame,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true),{BackgroundTransparency = 0.8}),WaitTime)
				end
			else
				LeaderboardInterface.PersonalBest.NoRecord.Visible = true
			end
		end)
	end
end



--Overview 

PreviewBeatmapset = 0
BeatmapSetId = 0
BeatmapId = 0

function UpdateRule()
	script.Parent.MultiplayerData.ChangeRule:Fire({
		SL = SliderMode,
		--StableNL = osuStableNotelock,
		ScoreV2 = ScoreV2Enabled
	})
end

script.Parent.MultiplayerData.RuleChanged.Event:Connect(function(Rule)
	SliderMode = Rule.Slider
	--osuStableNotelock = Rule.StableNL
	ScoreV2Enabled = Rule.ScoreV2
	
	--[[
	if SliderMode == true then
		CurrentSetting.MainSettings.SliderMode.Text = "Sliders: Enabled"
	else
		CurrentSetting.MainSettings.SliderMode.Text = "Sliders: Disabled"
	end
	
	if ScoreV2Enabled == true then
		CurrentSetting.MainSettings.ScoreV2.Text = "ScoreV2: Enabled"
	else
		CurrentSetting.MainSettings.ScoreV2.Text = "ScoreV2: Disabled"
	end]]
	
	--[[
	if osuStableNotelock == true then
		CurrentSetting.MainSettings.StableNotelock.Text = "In-game notelock: Stable"
	else
		CurrentSetting.MainSettings.StableNotelock.Text = "In-game notelock: Lazer"
	end]]
end)

CurrentSetting.MainSettings.SliderMode:GetPropertyChangedSignal("Text"):Connect(UpdateRule)
CurrentSetting.MainSettings.ScoreV2:GetPropertyChangedSignal("Text"):Connect(UpdateRule)

script.Parent.GetMapData.OnInvoke = function()
	local SongSpeed = tonumber(CurrentSetting.MainSettings.Speed.Text)
	local CurrentMapData = require(BeatmapStudio)
	local _,e = string.find(CurrentMapData,"ApproachRate:")
	local s = string.find(CurrentMapData,"\n",e)
	local MapAR = tonumber(string.sub(CurrentMapData,e+1,s-1))
	local CustomAR = tonumber(CurrentSetting.MainSettings.AR.Text) or MapAR

	if SongSpeed == nil or SongSpeed < 0.5 or SongSpeed > 2 or tostring(SongSpeed) == "nan" or tostring(SongSpeed) == "inf" or tostring(SongSpeed) == "-nan" or tostring(SongSpeed) == "-nan(ind)"  then
		SongSpeed = 1
	end

	return {
		Filename = BeatmapStudio.Name,
		Speed = SongSpeed,
		HD = HiddenMod,
		HR = HardRock,
		FL = Flashlight,
		SL = SliderMode,
		HC = HardCore,
		ScoreV2 = ScoreV2Enabled
	}
end

function ReloadPreviewFrame()
	local _1,_2,_3,_4,_5 = script.Parent.GameplayScripts.ReloadPreviewFrame.LoadPreviewFrame:Invoke(
		CurrentPreviewFrame,CurrentSetting,FileType,CurrentModData,BeatmapStudio,CurrentKey,BeatmapKey
		,PreviewFrameBaseVolume,SongVolume,PreviewBeatmapset,HardRock,Flashlight,EasyMod
	)
	CurrentModData = _1
	CurrentKey = _2
	BeatmapKey = _3
	PreviewFrameBaseVolume = _4
	PreviewBeatmapset = _5
	LoadMultiplier()
end

script.Parent.MultiplayerData.ChangeMap.Event:Connect(function(MapFile,Speed)
	CurrentSetting.MainSettings.Speed.Text = tostring(Speed or "")
	BeatmapStudio = workspace.Beatmaps:FindFirstChild(MapFile)
	ReloadPreviewFrame()
	LoadLeaderboard()
end)



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

-- Developer UI, use to remove score (and unrank players from score)
-- DO NOT ABUSE, Try to remove owner score = kick

Administrator = {
	1241445502,   -- VtntGaming
	101640888,    -- NoobBlx
	1555282549,   -- Lytogo
	324532788,    -- neffcena1337 (Chocomint)
	1180390897,   -- Hanjin_yau   (Sh3rk)
	56408291      -- jnguyen050 (Julinko)
}

if table.find(Administrator,game.Players.LocalPlayer.UserId) then
	local LeftClickEnabled = false

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
	local DevButton = Leaderboard.Parent.DevButton
	DevButton.Visible = true

	DevButton.MouseButton1Click:Connect(function()
		LeftClickEnabled = not LeftClickEnabled
		if LeftClickEnabled then
			DevButton.BackgroundColor3 = Color3.new(0.203922, 1, 0.203922)
		else
			DevButton.BackgroundColor3 = Color3.new(1, 0.203922, 0.203922)
		end
	end)

	Leaderboard.ChildAdded:Connect(function(lbframe)
		if lbframe:IsA("UIListLayout") then return end

		local function Action()
			local MouseLocation = game:GetService("UserInputService"):GetMouseLocation()
			local ScreenSize = script.Parent.AbsoluteSize
			local MouseLocationUdim = MouseLocation/ScreenSize

			DeveloperUI.MainUI.Position = UDim2.new(MouseLocationUdim.X,0,MouseLocationUdim.Y,0)
			DeveloperUI.MainUI.Visible = true
			DeveloperUI.MainUI.UI.Username.Text = lbframe.MainFrame.UserName.Text
			CurrentUsername = string.split(lbframe.MainFrame.UserName.Text,"@")[2]
		end

		lbframe.DevButton.MouseButton2Click:Connect(Action)
		lbframe.DevButton.MouseButton1Click:Connect(function()
			if LeftClickEnabled then
				Action()
			end
		end)
	end)
	function DevAction(Action)
		if Processing == true or CurrentUsername == "" then return end
		Processing = true
		local issuccess = game.ReplicatedStorage.DevAction:InvokeServer(Action,{Name = CurrentUsername,Key = CurrentKey,BeatmapKey = tostring(BeatmapKey)}) 
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
	DeveloperUI.MainUI.UI.GotoProfile.MouseButton1Click:Connect(function()
		local ProfileUI = game.Players.LocalPlayer.PlayerGui.MenuInterface.UserProfile
		TweenService:Create(ProfileUI.Parent.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.5}):Play()
		TweenService:Create(ProfileUI,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(0.5,1)}):Play()
		ProfileUI.UserProfile.ProfilePage.ProcessScripts.LoadNewInfo:Fire(game.Players:GetUserIdFromNameAsync(CurrentUsername))
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


--[[
CurrentSetting.MainSettings.HardRock:GetPropertyChangedSignal("Text"):Connect(function()
	ReloadPreviewFrame()
end)

CurrentSetting.MainSettings.Easy:GetPropertyChangedSignal("Text"):Connect(function()
	ReloadPreviewFrame()
end)

CurrentSetting.MainSettings.Flashlight:GetPropertyChangedSignal("Text"):Connect(function()
	ReloadPreviewFrame()
end)]]





CurrentPreviewFrame.PreviewButton.MouseButton1Click:Connect(ReloadPreviewFrame)

local BeatmapChooseButton = game.Players.LocalPlayer.PlayerGui.BG.BeatmapChooseButton
local BeatmapChooseUI = game.Players.LocalPlayer.PlayerGui.BeatmapChoose
local BeatmapChooseTweening = false
local BeatmapChooseCloseButton = game.Players.LocalPlayer.PlayerGui.BeatmapChoose.CloseUI
local BeatmapchooseOpened = false
local TweenStarted = false
local NameSortType = true
local BeatmapCurrentDiffChoose = 0
local BeatmapCurrentChoose = 0
local SearchBar = BeatmapChooseUI.BG.SearchFrame.SearchBar

spawn(function()
	local UIListLayout = BeatmapChooseUI.BG.BeatmapList:WaitForChild("UIListLayout",math.huge)
	local SortTypeButton = BeatmapChooseUI.BG.SortType.SortType
	if CurrentSetting.VirtualSettings.DiffSortType.Value == true then
		NameSortType = false
		SortTypeButton.Text = "Sort by: Difficulty"
	end
	SortTypeButton.MouseButton1Click:Connect(function()
		NameSortType = not NameSortType
		CurrentSetting.VirtualSettings.DiffSortType.Value = not NameSortType
		if NameSortType == true then
			SortTypeButton.Text = "Sort by: Name"
			--UIListLayout.SortOrder = Enum.SortOrder.Name
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			if SearchBar.Text == "" then
				script.Parent.SwitchBeatmap:Fire()
				for i = 1,10 do wait() end
				TweenService:Create(BeatmapChooseUI.BG.BeatmapList,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{CanvasPosition = Vector2.new(0,(BeatmapCurrentChoose*60-(BeatmapChooseUI.BG.BeatmapList.AbsoluteWindowSize.Y*0.5)+30))}):Play()
			end
		else
			SortTypeButton.Text = "Sort by: Difficulty"
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			if SearchBar.Text == "" then
				script.Parent.SwitchBeatmap:Fire()
				for i = 1,10 do wait() end
				TweenService:Create(BeatmapChooseUI.BG.BeatmapList,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{CanvasPosition = Vector2.new(0,(BeatmapCurrentDiffChoose*60-(BeatmapChooseUI.BG.BeatmapList.AbsoluteWindowSize.Y*0.5)+30))}):Play()
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
	if isBeatmapchooseOpen then
		TweenService:Create(BeatmapChooseUI.BG.Background.Background,TweenInfo.new(0.4,Enum.EasingStyle.Linear),{Size = UDim2.new(1.01,0,1.01,0)}):Play()
	else
		TweenService:Create(BeatmapChooseUI.BG.Background.Background,TweenInfo.new(0.4,Enum.EasingStyle.Linear),{Size = UDim2.new(1,0,1,0)}):Play()
	end
	if isBeatmapchooseOpen == true then
		local BeatmapListUI = BeatmapChooseUI.BG.BeatmapList
		CurrentPreviewFrame.Parent = BeatmapChooseUI.BG.OverviewFrame
		local LoadedSongs = 0

		local ConvertBeatmap = require(workspace.OsuConvert)
		wait(0.6)
		if BeatmapChooseUI.BG:FindFirstChild("FirstLoad") then
			BeatmapChooseUI.BG.FirstLoad:Destroy()
			BeatmapListUI:ClearAllChildren()
			--[[
			local UIListLayout = script.BeatmapChooseUI.UI.UIListLayout:Clone()
			UIListLayout.Parent = BeatmapListUI]]
			BeatmapChooseUI.BG.LoadStatus.Text = "Loading... (0%)"
			local LoadStartTime = tick()
			local IsDisplayed = false

			for beatmapid,Beatmap in pairs(BeatmapsList:GetChildren()) do
				ProcessFunction(function()
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

					local HColor =  (BeatmapDifficulty <= 1.5 and 200) or (BeatmapDifficulty <= 4.5 and (1-(BeatmapDifficulty/4.5))*200) or (BeatmapDifficulty <= 6.5 and 360-((BeatmapDifficulty-4.5)/2)*120) or (BeatmapDifficulty <= 9.9 and 240) or 0
					local SColor = (BeatmapDifficulty <= 8.5 and 255) or (BeatmapDifficulty <= 10 and 255 - (BeatmapDifficulty-8.5)*170) or (BeatmapDifficulty <= 12 and (BeatmapDifficulty-10)*127.5) or 255--(BeatmapDifficulty <= 6.5 and 140) or (140 + (BeatmapDifficulty-6.5)*40)
					local VColor = 255--(BeatmapDifficulty <= 6.5 and 255) or (BeatmapDifficulty < 9 and 255 - (BeatmapDifficulty-6.5)*102) or 0

					HColor /= 360
					SColor /= 255
					VColor /= 255

					local BeatmapDiffColor = Color3.fromHSV(HColor,SColor,VColor):ToHex()
					
					newBeatmapFrame.Parent = BeatmapListUI
					newBeatmapFrame.Name = Beatmap.Name
					newBeatmapFrame.Frame.BeatmapID.Value = beatmapid
					-- check map markup (remove < and >)
					
					while string.find(metadata.DifficultyName,"<") or string.find(metadata.DifficultyName,">") do
						local Left = string.find(metadata.DifficultyName,"<")
						local Right = string.find(metadata.DifficultyName,">")
						
						if Left then metadata.DifficultyName = string.sub(metadata.DifficultyName,1,Left-1)..string.sub(metadata.DifficultyName,Left+1,#metadata.DifficultyName) end
						if Right then metadata.DifficultyName = string.sub(metadata.DifficultyName,1,Right-1)..string.sub(metadata.DifficultyName,Right+1,#metadata.DifficultyName) end
					end
					
					
					newBeatmapFrame.Frame.DiffName.Text = "<font color = '#"..BeatmapDiffColor.."'>["..tostring(BeatmapDifficulty).."]</font>["..metadata.DifficultyName.."] // "..metadata.BeatmapCreator
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
					LoadedSongs += 1
					BeatmapChooseUI.BG.LoadStatus.Text = "Loading... ("..tostring(math.floor((LoadedSongs/#BeatmapsList:GetChildren())*100)).."%)"
					local TimeElapsed = tick() - LoadStartTime
					local EstimatedTime = math.ceil((TimeElapsed/LoadedSongs*#BeatmapsList:GetChildren()) - TimeElapsed)
					BeatmapChooseUI.BG.LoadStatus.EstimatedTime.Text = "[Estimated: "..tostring(EstimatedTime).."s]"
					if TimeElapsed > 5 and IsDisplayed == false then
						IsDisplayed = true
						TweenService:Create(BeatmapChooseUI.BG.LoadStatus.EstimatedTime,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextTransparency = 0}):Play()
					end
					--print("Time left: "..tostring(math.floor(((#BeatmapsList:GetChildren() - LoadedSongs))*0.05775)))
					BeatmapSorting[#BeatmapSorting+1] = {BeatmapSortKey,metadata.MapName,metadata.MapId}
					BeatmapDiffSorting[#BeatmapDiffSorting+1] = {BeatmapSortKey,BeatmapDifficulty}
					ProcessFunction(function()
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
						local UIListLayout = script.BeatmapChooseUI.UI.UIListLayout:Clone()
						UIListLayout.Parent = BeatmapListUI
						BeatmapListUI.CanvasSize = UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y)
						BeatmapChooseUI.BG.LoadStatus.Text = "Loaded!"
						TweenService:Create(BeatmapChooseUI.BG.LoadStatus,TweenInfo.new(1,Enum.EasingStyle.Linear),{TextTransparency = 1}):Play()
						TweenService:Create(BeatmapChooseUI.BG.LoadStatus.EstimatedTime,TweenInfo.new(1,Enum.EasingStyle.Linear),{TextTransparency = 1}):Play()
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

ProcessFunction(function()
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
				ProcessFunction(function()
					local listloadstarttime = tick()
					if BeatmapFrame:IsA("Frame") and BeatmapFrame:FindFirstChild("Frame") and BeatmapFrame.Frame:FindFirstChild("BeatmapID") then
						TotalFrameLoad += 1
						LoadStatus2.Text = "Loading list... ("..tostring(LoadedFrame).."/"..tostring(TotalFrameLoad)..")"
						local LoadedFirst = false
						local Choosen = false
						ProcessFunction(function()
							local TweenDoneSignal = BeatmapFrame:WaitForChild("TweenDone",math.huge)
							local CurrentChoose = "no"
							local ScrollBeatmapFrame = BeatmapFrame.Parent
							local Connection = BeatmapFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
								local BeatmapFramePosition = BeatmapFrame.AbsolutePosition
								local ScreenSize = workspace.CurrentCamera.ViewportSize

								BeatmapFrame.Frame.Visible = math.abs(BeatmapFramePosition.Y-ScreenSize.Y/2) <= ScreenSize.Y*1.5
							end)

							TweenDoneSignal.Destroying:Connect(function()
								Connection:Disconnect()
							end)

							while true and TweenDoneSignal.Parent do
								LoadedFrame += 1
								local Elapsed = tick() - listloadstarttime
								local Estimated = math.ceil(Elapsed/LoadedFrame*TotalFrameLoad)
								Elapsed = math.floor(Elapsed)
								LoadStatus2.Text = "Loading list... ("..tostring(LoadedFrame).."/"..tostring(TotalFrameLoad)..") ["..tostring(Elapsed).."/"..tostring(Estimated).."s]"
								if LoadedFrame >= TotalFrameLoad and LoadedFrame ~= 0 then
									LoadStatus2.Visible = false
								end
								if BeatmapFrame:FindFirstChild("TweenDone") == nil then break end
								Choosen = IngamebeatmapID.Value == BeatmapFrame.Frame.BeatmapID.Value
								BeatmapFrame.Frame.SelectButton.AutoButtonColor = not Choosen
								local OrderId = BeatmapFrame.LayoutOrderId.Value
								if NameSortType == false then
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
											--wait(0.25+OrderId*0.001)
											--[[
											TweenService:Create(BeatmapFrame.Frame.DiffName,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextStrokeTransparency = 1}):Play()
											TweenService:Create(BeatmapFrame.Frame.Title,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextStrokeTransparency = 1}):Play()
											TweenService:Create(BeatmapFrame.Frame.SelectButton,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{BackgroundColor3 = Color3.fromRGB(132, 132, 132)}):Play()
											TweenService:Create(BeatmapFrame.Frame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0.05,0,0,0)}):Play()]]
											BeatmapFrame.Frame.Position = UDim2.new(0.05,0,0,0)
											
										else
											if SearchBar.Text == "" then
												TweenService:Create(BeatmapChooseUI.BG.BeatmapList,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{CanvasPosition = Vector2.new(0,(OrderId*60-(BeatmapChooseUI.BG.BeatmapList.AbsoluteWindowSize.Y*0.5)+30))}):Play()
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
												TweenService:Create(BeatmapChooseUI.BG.BeatmapList,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{CanvasPosition = Vector2.new(0,(OrderId*60-(BeatmapChooseUI.BG.BeatmapList.AbsoluteWindowSize.Y*0.5)+30))}):Play()
											end
											--print(OrderId,BeatmapFrame.LayoutOrder)
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
				end)
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
local BackgroundFrame2 = game.Players.LocalPlayer.PlayerGui.BeatmapChoose.BG.Background.Background
BackgroundFrame.Size = UDim2.new(1.01,0,1.01,0)
local BackgroundMovement = game:GetService("UserInputService").InputChanged:Connect(function()
	if script.Parent:FindFirstChild("GameStarted") then return end
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
	
	TweenService:Create(BackgroundFrame,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{Position = NewPosition}):Play()
	TweenService:Create(BackgroundFrame2,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{Position = NewPosition}):Play()
	--BackgroundFrame.Position = NewPosition
end)


local PlaybuttonTriggered = false
local BeatmapStarted = false

script.Parent.Parent.BG.StartButton.MouseButton1Click:Connect(function()
	if BeatmapchooseOpened == false and PlaybuttonTriggered == false then

		if not game.Players.LocalPlayer.PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.Disabled then
			local GameAlreadyStarted = game.Players.LocalPlayer.PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.MultiplayerFolder.Value.IsMatchInProgress:InvokeServer()
			if GameAlreadyStarted then
				game.Players.LocalPlayer.PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("The current match is not finished, try again later.",Color3.fromRGB(255,0,0))
				return
			end
		end

		PlaybuttonTriggered = true
		local BGFrame = script.Parent.Parent.BG

		BGFrame.StartButtonBeatAnimation:Destroy()

		TweenService:Create(BGFrame.StartButton,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(0,400,0,100),BackgroundTransparency = 1}):Play()
		TweenService:Create(BGFrame.MultiplayerButton,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(0,400,0,100),BackgroundTransparency = 1}):Play()
		TweenService:Create(BGFrame.StartButton.UIStroke,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Transparency = 1}):Play()
		TweenService:Create(BGFrame.StartButton._Text,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()

		TweenService:Create(BGFrame.BeatmapChooseButton,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,0,-30)}):Play()
		TweenService:Create(BGFrame.SettingsButton,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,1,30)}):Play()
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

MouseHitEvent.Event:Connect(function(CurrentSecurityKey)
	if isSpectating == true or PlayRanked == false then return end
	if CurrentSecurityKey ~= SecurityKey then
		PlayRanked = false
		game.Players.LocalPlayer.PlayerGui.BG.UnrankedSign.Visible = true
		require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("Detected some suspicous activity on your play, your account has been unranked. The report has been sent to the developer.",Color3.new(1, 0, 0))
		Reporter:FireServer(game.Players.LocalPlayer.Name,game.Players.LocalPlayer.UserId,1)
	else
		SecurityKey = game.HttpService:GenerateGUID(false)
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
	SpectatorCountRemote = SpectateData.SpectatorCountRemote
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

isHost = true
MultiplayerData = {
	MatchRule = {}, MatchData = {}
}

script.Parent.MultiplayerData.StartGame.Event:Connect(function(Host,Rule,MapData)
	isHost = Host
	MultiplayerData.MatchRule = Rule
	MultiplayerData.MatchData = MapData

	script.Parent.StartGame:Fire()
end)

game.ReplicatedStorage.Gameplay.UpdateStatus:FireServer(1)

Instance.new("BoolValue",script.Parent).Name = "ReadyToStart"
script.Parent.StartGame.Event:Wait() -- The game start from here

OnMultiplayer = not game.Players.LocalPlayer.PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.Disabled  -- Multiplayer

if OnMultiplayer then
	if (game.PlaceId == 6983932919 and not game:GetService("RunService"):IsStudio()) or (game.Players.LocalPlayer.UserId ~= 1241445502 and game.Players.LocalPlayer.UserId ~= 1608539863) then
		AutoPlay = false
	end
	if isHost then
		local MapData = script.Parent.GetMapData:Invoke()

		game.Players.LocalPlayer.PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.MultiplayerFolder.Value.StartGameRequest:InvokeServer(MapData)
	end
	script.Parent.MultiplayerWaitFrame.Visible = true
	PlayersInMatch = game.Players.LocalPlayer.PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.MultiplayerFolder.Value.WaitForAllLoaded:InvokeServer()
	script.Parent.MultiplayerLeaderboard.MultiplayerData.Value = game.HttpService:JSONEncode(PlayersInMatch)
	script.Parent.MultiplayerWaitFrame.Visible = false
end

game.StarterGui:SetCore("ResetButtonCallback",script.Parent.RestartGame.ResetcharacterCallback)
local isLoaded = false
BeatmapStarted = true



ProcessFunction(function()
	repeat wait() until isLoaded
	for i = 1,30 do
		wait()
	end
	--TweenService:Create(script.Parent.Interface.BG,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false),{BackgroundTransparency = 1}):Play()
	TweenService:Create(CurrentPreviewFrame.OverviewSong,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{Volume = 0}):Play()
	TweenService:Create(script.Parent.Interface.Background,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{GroupTransparency = 1}):Play()
	wait(0.25)
	script.Parent.Interface.Background.Visible = false
	CurrentPreviewFrame.OverviewSong.Playing = false
end)

if not script.Parent:FindFirstChild("_FastRestart") then	
	--TweenService:Create(script.Parent.Interface.BG,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false),{BackgroundTransparency = 0}):Play()
	local FileData = require(BeatmapStudio)
	
	local _,e = string.find(FileData,"BackgroundImageId: ")
	local s,_ = string.find(FileData,"\n",e)
	local result = ""
	if s and e then
		result = string.sub(FileData,e+1,s-1)
	end
	local ID = "http://www.roblox.com/asset/?id="..result
	
	script.Parent.Interface.Background.BackgroundImage.Image = ID
	script.Parent.Interface.Background.Visible = true
	TweenService:Create(script.Parent.Interface.Background,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{GroupTransparency = 0}):Play()
	wait(1)
end


script.Parent.Parent.BG.OutlineStuff:Destroy()
script.Parent.Parent.BG.StartButton:Destroy()
script.Parent.Parent.BG.MultiplayerButton:Destroy()
script.Parent.Parent.BG.SettingsButton:Destroy()
if script.Parent.Parent.BG:FindFirstChild("StartButtonBeatAnimation") then
	script.Parent.Parent.BG.StartButtonBeatAnimation:Destroy()
end
game.Players.LocalPlayer.PlayerGui.SavedSettings:ClearAllChildren()
CurrentSetting.Parent = game.Players.LocalPlayer.PlayerGui.SavedSettings
CurrentSetting.AnchorPoint = Vector2.new(1,0)
--CurrentSetting.GroupTransparency = 1
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
game.Players.LocalPlayer.PlayerGui.MenuInterface.ProfileButton.Visible = false
game.Players.LocalPlayer.PlayerGui.MenuInterface.MultiplayerButton.Visible = false
game.Players.LocalPlayer.PlayerGui.MenuInterface.UpdateLogButton.Visible = false
game.Players.LocalPlayer.PlayerGui.MenuInterface.ExpandButton.ExpandButton.Visible = false
game.Players.LocalPlayer.PlayerGui.MenuInterface.WikiButton.Visible = false
script.Parent.Parent.BG.BeatmapLeaderboard.GolbalLeaderboard:ClearAllChildren()


if OnMultiplayer then
	script.Parent.MultiplayerLeaderboard.LeaderboardWorking.Disabled = false	
else
	script.Parent.Leaderboard.LeaderboardWorking.Disabled = false
end

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
ProcessFunction(function()
	wait()
	BackgroundFrame.Position = UDim2.new(0.5,0,0.5,0)
	BackgroundFrame.Size = UDim2.new(1,0,1,0)
end)

if isSpectating or AutoPlay then
	DisableChatInGame = false
end

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,not DisableChatInGame)
if DisableChatInGame then
	game.StarterGui:SetCore("ChatActive",false)
end


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
CursorSensitivity= Settings.Parent.VirtualSettings.InstantSettings.Sensitivity.Value*0.01
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

CircleNumberData = game.HttpService:JSONDecode(Settings.Parent.VirtualSettings.CircleNumberData.Value)
CircleConfigData = game.HttpService:JSONDecode(Settings.Parent.VirtualSettings.CircleConfigData.Value)

DefaultCircleId = {
	Overlap = -0.5,
	NumberScale = 0.5,
	["0"] = 9188735058,
	["1"] = 9188734932,
	["2"] = 9188734853,
	["3"] = 9188734740,
	["4"] = 9188734608,
	["5"] = 9188734466,
	["6"] = 9188734381,
	["7"] = 9188734322,
	["8"] = 9188734249,
	["9"] = 9188734133
}

for i = 0,9 do
	script.HitCircleNumber["Number_"..tostring(i)].Image = "rbxassetid://"..tostring(CircleNumberData[tostring(i)] or DefaultCircleId[(tostring(i))])
end
CircleNumberScale = CircleConfigData.NumberScale or DefaultCircleId.NumberScale
script.Circle.CircleNumber.Size = UDim2.new(CircleNumberScale,0,CircleNumberScale,0)
script.Circle.CircleNumber.UIListLayout.Padding = UDim.new(CircleConfigData.Overlap or DefaultCircleId.Overlap,0)

DefaultBackgroundTrans = Settings.Parent.VirtualSettings.InstantSettings.BackgroundDim.Value*0.01
if tonumber(SongId) == nil then
	SongId = "0"
end

if CustomMusicID == true then

	SongId = (string.sub(SongId,1,13) == "rbxassetid://" and SongId) or "rbxassetid://"..SongId
	if SongId == "rbxassetid://0" then
		SongId = "rbxassetid://9177125646"
	end

	script.Parent.Song.SoundId = SongId

end
-- Error check

if Key1Input == nil then
	Key1Input = Enum.KeyCode.Z
end
if Key2Input == nil then
	Key2Input = Enum.KeyCode.X
end
if SongDelay == nil or math.abs(SongDelay) > 5000 then
	SongDelay = 0
end
if CursorSensitivity== nil or CursorSensitivity< 0.01 or CursorSensitivity> 10 then
	CursorSensitivity= 1
end

if DefaultBackgroundTrans == nil or DefaultBackgroundTrans < 0 or DefaultBackgroundTrans > 1 then
	DefaultBackgroundTrans = 0.2
end

if isSpectating == false then
	if SongSpeed == nil or SongSpeed < 0.5 or SongSpeed > 2 or tostring(SongSpeed) == "nan" or tostring(SongSpeed) == "inf" or tostring(SongSpeed) == "-nan" or tostring(SongSpeed) == "-nan(ind)"  then
		SongSpeed = 1
	end

	if Beatmap == nil or Beatmap == "" or FileType == 1 then
		Beatmap = BeatmapStudio
		FileType = 1
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
	if true then
		SaveGameSettings()
		return
	end
	-- Save settings
	local ClientSettings = {
		Offset = SongDelay,
		CursorSensitivity= CursorSensitivity,
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

-- Load multiplayer data

if OnMultiplayer and not isHost then
	if MultiplayerData.MatchRule.ForceMod then
		--[[
		{
		Filename = BeatmapStudio.Name,
		Speed = SongSpeed,
		CustomAR = CustomAR,
		HD = HiddenMod,
		HR = HardRock,
		FL = Flashlight,
		SL = SliderMode,
		HC = HardCore,
		StableNotelock = osuStableNotelock
	}]]

		HiddenMod = MultiplayerData.MatchData.HD
		HardRock = MultiplayerData.MatchData.HR
		Flashlight = MultiplayerData.MatchData.FL
		SliderMode = MultiplayerData.MatchData.SL
		HardCore = MultiplayerData.MatchData.HC
	end

	if MultiplayerData.MatchRule.ForceAR then
		ApproachRate = MultiplayerData.MatchData.CustomAR
	end
	
	
	SongSpeed = MultiplayerData.MatchData.Speed
	Beatmap = workspace.Beatmaps[MultiplayerData.MatchData.Filename]
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

		--LoadLeaderboard()
	end)
	--osuStableNotelock = MultiplayerData.MatchData.StableNotelock
	ScoreV2Enabled = MultiplayerData.MatchData.ScoreV2
	
end

-- load spectate data

if isSpectating == true then
	osuStableNotelock = SavedSpectateData.StableNotelock
end


-- Get beatmap data

local BeatmapData,ReturnData,TimingPoints,BeatmapComboColor = require(workspace.OsuConvert)(FileType,Beatmap,SongSpeed,SongDelay,CustomMusicID,true,false,false,HardRock,Flashlight,EasyMod)

--------------------------------------------------------------------------------------------------------------------------------------------

CurrentKey = ReturnData.BeatmapSetsData.BeatmapsetID.."-"..ReturnData.BeatmapSetsData.BeatmapID
BeatmapKey = ReturnData.BeatmapSetsData.BeatmapID
script.Parent.GameplayData.SongSpeed.Value = SongSpeed

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
local CustomHP = tonumber(Settings.HP.Text)

if OnMultiplayer and not isHost and MultiplayerData.MatchRule.ForceAR then
	CustomAR = MultiplayerData.MatchData.CustomAR
end

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
script.Parent.HitKey.Visible = OverallInterfaceEnabled

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

-- Remove unused content

for _,a in pairs(game.Players.LocalPlayer.PlayerGui.BG:GetChildren()) do
	if not a:FindFirstChild("LoadIngame") then
		a:Destroy()
	end
end


---

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
		elseif EasyMod then
			HRMulti = 0.5
			CSHRMulti = 0.5
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

	if tonumber(CustomHP) then
		HPDrain = CustomHP
		if  HardCore then
			CustomDiff = true
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
	AutoPlay == false or (game.Players.LocalPlayer.UserId == 1241445502 and game:GetService("RunService"):IsStudio() and false),
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
elseif AutoPlay then
	game.Players.LocalPlayer.PlayerGui.BG.UnrankedSign.Text = "AUTOPLAY"
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
if isSpectating == false and (AutoPlay == false or ((game.Players.LocalPlayer.UserId == 1241445502 or game.Players.LocalPlayer.UserId == 1608539863) and game.PlaceId ~= 6983932919)) then
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
	PlayingRemote,SpectatorCountRemote = game.ReplicatedStorage.Gameplay.GetSpectateData:InvokeServer(game.Players.LocalPlayer.UserId,Data)
end

-------------------

ProcessFunction(function()
	if SpectatorCountRemote then
		while wait(5) do
			local SpectatorsCount = SpectatorCountRemote:InvokeServer()
			if SpectatorsCount > 0 then
				script.Parent.SpectatorsCount.Visible = true
				script.Parent.SpectatorsCount.Text = "Spectators: "..tostring(SpectatorsCount)
			else
				script.Parent.SpectatorsCount.Visible = false
			end
		end
	end
end)

-------------------

CustomComboColor = game.HttpService:JSONDecode(Settings.Parent.VirtualSettings.CustomComboColor.Value)
CustomComboColorRaw = Settings.Parent.VirtualSettings.CustomComboColor.Value

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

if CustomComboColor and #CustomComboColor > 1 then
	local ConvertedCustomComboColor = {}
	for _,a in pairs(CustomComboColor) do
		ConvertedCustomComboColor[#ConvertedCustomComboColor+1] = Color3.fromHex(a)
	end
	ComboColor = ConvertedCustomComboColor
end

if BeatmapComboColor ~= nil and not CustomComboColorEnabled then
	ComboColor = BeatmapComboColor
end



--------
local TweenService = game:GetService("TweenService")
local Tween
local Start = tick()+2
local SongStart = tick()+2

--local Cursor = script.Parent.PlayFrame.Cursor
local Cursor = script.Parent.CursorField.Cursor
--local DisplayingCursor = script.Parent.PlayFrame.Cursor
local CursorTrail = script.Cursor_Trail

local CursorPosition = Vector2.new(256,576)
local ATVC = Instance.new("Frame")
ATVC.Position = UDim2.new(0.5,0,1.5,0)

--[[
LastCursorPosition = {CursorPosition,tick()}
CursorTeportViolationCount = 0
if PlayRanked and not game:GetService("UserInputService").TouchEnabled then
	game:GetService("RunService").RenderStepped:Connect(function()
		if PlayRanked and not game:GetService("UserInputService").TouchEnabled and LastCursorPosition[1] ~= CursorPosition then
			local TimeBetweenLastFrame = tick() - LastCursorPosition[2]
			local DistanceMoved = (LastCursorPosition[1] - CursorPosition).Magnitude
			local MoveSpeed = DistanceMoved/TimeBetweenLastFrame
			if MoveSpeed > 60000 then
				CursorTeportViolationCount += 1
				if CursorTeportViolationCount <= 10 then
					require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("You're moving the cursor too fast, slow down!",Color3.new(1 ,0 ,0))
				elseif CursorTeportViolationCount <= 14 then
					require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("You have "..tostring(16 - CursorTeportViolationCount).." more chance to stop cursor teleporting.",Color3.new(1 ,0 ,0))
				elseif CursorTeportViolationCount <= 15 then
					require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("This your last chance to stop cursor teleporting.",Color3.new(1 ,0 ,0))
				else
					require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("This play is unranked.",Color3.new(1 ,0 ,0))
					
					PlayRanked = false
					game.Players.LocalPlayer.PlayerGui.BG.UnrankedSign.Visible = true
				end
			end
		end

		LastCursorPosition = {CursorPosition,tick()}
	end)
end]]

if AutoPlay == true then
	local ATCursor = ATVC
	ATCursor.Changed:Connect(function()
		CursorPosition = Vector2.new(ATCursor.Position.X.Scale*512,ATCursor.Position.Y.Scale*384)
	end)
end

local LastPosition = UDim2.new(CursorPosition.X/512,0,CursorPosition.Y/384,0)

game:GetService("RunService").RenderStepped:Connect(function()
	if CursorPosition ~= LastPosition then
		Cursor.Position = UDim2.new(CursorPosition.X/512,0,CursorPosition.Y/384,0)
	end
	LastPosition = CursorPosition
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

for _,Hitsound in pairs(script.Hitsounds:GetChildren()) do
	Hitsound.Volume = EffectVolume*0.01
end


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

-- Cursor lock
local CursorUnlocked = false

--HPDrain

local HealthBarDrainEnabled = false
local MaxHealthPoint = 100
local HealthPoint = 0
local EZModCheckpoint = 3
local isDrain = false
local BeatmapFailed = false
local TotalNote = 0
local TotalSliders = 0

script.Parent.HealthBar.EZModHPCheckpoint.Visible = EasyMod
-- 3.2 per note
local MissDrain = 12.5

if EasyMod then
	MaxHealthPoint = 300
end

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
		if OnMultiplayer then
			if not MultiplayerMatchFailed then
				MultiplayerMatchFailed = true
				PlayRanked = false
				game.Players.LocalPlayer.PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("You've failed, but you can still continue to play.",Color3.fromRGB(255,0,0))
				return
			else
				return
			end
		end
		CursorUnlocked = true
		game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.Default
		Cursor.Visible = false
		game.Players.LocalPlayer.PlayerGui.OsuCursor.Cursor.Visible = true
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

				local NewPos = TweenObj.Position + UDim2.new(0,math.random(-10,10),0,(TweenObj.AbsolutePosition.Y/workspace.CurrentCamera.ViewportSize.Y)*math.random(200,400))
				local NewRotation = TweenObj.Rotation + math.random(-45,45)
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
			{TextTransparency = 1,BackgroundTransparency = 1}
		):Play()
		ProcessFunction(function()
			wait(0.5)
			script.Parent.RestartGame.Visible = false
		end)
		script.Parent.RestartBeatmap.Visible = true
		script.Parent.ReturnGame_Failed.Visible = true
		TweenService:Create(script.Parent.RestartBeatmap,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextTransparency = 0,BackgroundTransparency = 0}):Play()
		TweenService:Create(script.Parent.ReturnGame_Failed,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextTransparency = 0,BackgroundTransparency = 0}):Play()
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
		wait(1)
		for _,a in pairs(script.Parent.PlayFrame:GetChildren()) do
			if a.Name ~= "FlashLight" then
				a:Destroy()
			end
		end
	end)
end
DrainSpeed = 1.75
CurrentDrainSpeed = 0
HealthDrainMultiplier = 1

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
		DrainSpeed = (1.75 - 0.75 * (5 - HPDrain) / 5) * HealthDrainMultiplier
	else
		DrainSpeed = (1.75 + 1.25 * (HPDrain - 5) / 5) * HealthDrainMultiplier
	end
	DrainSpeed*= SongSpeed
	while wait() do
		if isDrain then
			local DrainSpeed = 1.75

			if HPDrain < 5 then
				DrainSpeed = (1.75 - 0.75 * (5 - HPDrain) / 5) * HealthDrainMultiplier
			else
				DrainSpeed = (1.75 + 0.75 * (HPDrain - 5) / 5) * HealthDrainMultiplier
			end
			DrainSpeed*= SongSpeed
			CurrentDrainSpeed = DrainSpeed

			local HealthDrain = (((tick() - LastTick)*DrainSpeed))
			HealthPoint -= HealthDrain
			if HealthDrainMultiplier < 1 then
				HealthDrainMultiplier = 1
			end
			if HealthPoint < 0 then
				HealthPoint = 0
			elseif HealthPoint < MaxHealthPoint*((EZModCheckpoint-1)/3) and EasyMod then
				HealthPoint = MaxHealthPoint*((EZModCheckpoint-1)/3)
			end
		end
		local DrainMultiplierDrainSpeed = (HealthDrainMultiplier-1)* 0.85 / 3 * SongSpeed
		if DrainMultiplierDrainSpeed < 2 then
			DrainMultiplierDrainSpeed = 2
		end
		local MultiplierDrain = (((tick() - LastTick)*DrainMultiplierDrainSpeed))
		HealthDrainMultiplier -= MultiplierDrain
		LastTick = tick()
	end
end)

function AddHP(HP)
	if isSpectating then return end
	HealthPoint += HP
	if HealthPoint > MaxHealthPoint*(EZModCheckpoint/3) then
		HealthPoint = MaxHealthPoint*(EZModCheckpoint/3)
	end
end

local ImmortalTime = 0

function DrainHP(HP)
	if isSpectating then return end
	if tick() - ImmortalTime >= 0 then
		HealthPoint -= HP
	end
	if EasyMod then
		if HealthPoint < MaxHealthPoint * ((EZModCheckpoint-1)/3) and EZModCheckpoint > 1 then
			HealthPoint = MaxHealthPoint * ((EZModCheckpoint-1)/3)
			EZModCheckpoint -= 1
			ImmortalTime = tick() + 1
		end
	end
	if HealthPoint < 0 then
		if not BeatmapFailed and not isSpectating then
			GameOver()
		end
		HealthPoint = 0
	end
end

ProcessFunction(function()
	local LastHP = HealthPoint
	local LastHPDrainSpeed = CurrentDrainSpeed
	while wait() do
		if LastHPDrainSpeed ~= CurrentDrainSpeed and not OptimizedPerfomance and HealthPoint ~= 0 then
			TweenService:Create(script.Parent.HealthBar.HPLeft.HealthDrainSpeed,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Size = UDim2.new((CurrentDrainSpeed/100)/(HealthPoint/100),0,1,0)}):Play()
		end
		if HealthPoint ~= LastHP or HealthPoint == 0 then
			if OptimizedPerfomance then
				script.Parent.HealthBar.HPLeft.Size = UDim2.new(HealthPoint/100,0,1,0)
			else	
				if HealthPoint ~= 0 then
					TweenService:Create(script.Parent.HealthBar.HPLeft.HealthDrainSpeed,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Size = UDim2.new((CurrentDrainSpeed/MaxHealthPoint)/(HealthPoint/MaxHealthPoint),0,1,0)}):Play()
				end
				TweenService:Create(script.Parent.HealthBar.HPLeft,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Size = UDim2.new(HealthPoint/MaxHealthPoint,0,1,0)}):Play()
			end
			script.Parent.HealthBar.HealthDisplay.Text = tostring(math.ceil(script.Parent.HealthBar.HPLeft.Size.X.Scale*100)).."%"
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
			if OptimizedPerfomance then
				script.Parent.HealthBar.HPLeft.HolderFrame.BackgroundTransparency = HolderTrans
			else
				TweenService:Create(script.Parent.HealthBar.HPLeft.HolderFrame,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{BackgroundTransparency = HolderTrans}):Play()
			end
		end
		LastHP = HealthPoint
		LastHPDrainSpeed = DrainSpeed
	end
end)

ReplayRecordEnabled = true

spawn(function()
	while wait() do
		script.Parent.GameplayPause.Event:Wait()
		local TimeElapsed = tick() - Start
		Start = Start + 100000
		SongStart = Start

		script.Parent.Song.Volume = 0
		script.Parent.GameplayResume.Event:Wait()
		script.Parent.Song.Volume = ReturnData.BeatmapVolume*(SongVolume*0.02)
		Start = tick() - TimeElapsed
		SongStart = tick() - TimeElapsed
	end
end)


spawn(function()
	spawn(function()
		TweenService:Create(script.Parent.ProgressBar,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(1,-10,0,18)}):Play()
		wait(0.3)
		TweenService:Create(script.Parent.ProgressBar,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size = UDim2.new(0.3,0,0,4)}):Play()
	end)
	local TimeBreak = 3+BeatmapData[1].Time/1000
	repeat TweenService:Create(script.Parent.ProgressBar.Time,TweenInfo.new(0.05,Enum.EasingStyle.Linear),{Size = UDim2.new(-((tick()-Start) - BeatmapData[1].Time/1000)/TimeBreak,0,1,0)}):Play() wait() until (tick()-Start)*1000 >= BeatmapData[1].Time
	script.Parent.ProgressBar.Time.BackgroundColor3 = Color3.new(1,1,1)
	TweenService:Create(script.Parent.ProgressBar.TimeLeft.Time,TweenInfo.new(0.75,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{TextTransparency = 0}):Play()
	--TweenService:Create(script.Parent.ProgressBar.Time,TweenInfo.new((BeatmapData[#BeatmapData].Time-BeatmapData[1].Time)/1000,Enum.EasingStyle.Linear),{Size = UDim2.new(1,0,1,0)}):Play()

	local TotalTime = (BeatmapData[#BeatmapData].Time-BeatmapData[1].Time)/1000
	while tick() - Start < BeatmapData[#BeatmapData].Time/1000 and not ScoreResultDisplay do
		wait()
		local FullTimeLeft = BeatmapData[#BeatmapData].Time/1000 - (tick() - Start)
		local TimeLeft = math.ceil(FullTimeLeft) + 2
		local StringOutput = ""

		local Min = math.floor(TimeLeft/60)
		local Sec = TimeLeft - math.floor(TimeLeft/60)*60

		if Sec < 10 then
			Sec = "0"..tostring(Sec)
		end

		StringOutput = tostring(Min)..":"..tostring(Sec)
		if tick() - Start > -30 then
			script.Parent.ProgressBar.TimeLeft.Time.Text = StringOutput
		else
			script.Parent.ProgressBar.TimeLeft.Time.Text = "-:--"
		end
		TweenService:Create(script.Parent.ProgressBar.Time,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{Size = UDim2.new(1-(FullTimeLeft/TotalTime),0,1,0)}):Play()
	end
	TweenService:Create(script.Parent.ProgressBar.TimeLeft.Time,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{TextTransparency = 1}):Play()
end)


if AutoPlay == true and ReplayMode ~= true then
	spawn(function()
		repeat wait() until (tick()-Start)*1000 >= BeatmapData[1].Time-1000
		game:GetService("TweenService"):Create(ATVC,TweenInfo.new(0.5,Enum.EasingStyle.Sine),{Position = UDim2.new(0.5,0,0.5,0)}):Play()
	end)
end

local Connection
local Connection2

spawn(function()
	if BeatmapData[1].Time > 4000 then
		script.Parent.SkipButton.Visible = true
		TweenService:Create(script.Parent.SkipButton,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,0.8,0),GroupTransparency = 0}):Play()
		if MobileMode and game:GetService("UserInputService").TouchEnabled then
			script.Parent.SkipButton.SkipButton.Text = "Skip"
		end

		local SkipAlvaiable = true

		local function SkipSong()
			if not SkipAlvaiable then
				return
			end
			SkipAlvaiable = false
			Connection:Disconnect()
			Connection2:Disconnect()
			TweenService:Create(script.Parent.Song,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true),{Volume = 0}):Play()
			wait(0.25)
			script.Parent.Song.Playing = true
			Start = tick()-((BeatmapData[1].Time/1000)-2)
			SongStart = tick()-((BeatmapData[1].Time/1000)-2)
			TweenService:Create(script.Parent.ProgressBar.Time,TweenInfo.new(2,Enum.EasingStyle.Linear),{Size = UDim2.new(0,0,1,0)}):Play()
			TweenService:Create(script.Parent.SkipButton,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,1,0),GroupTransparency = 1}):Play()
			ProcessFunction(function()
				wait(0.5)
				script.Parent.SkipButton.Visible = false
			end)
		end
		local SkipRequest = false

		local function Trigger()
			Connection:Disconnect()
			Connection2:Disconnect()
			if not OnMultiplayer then
				SkipSong()
			else
				if SkipRequest then return end
				SkipRequest = true
				game.Players.LocalPlayer.PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("Skip request sent.",Color3.new(1,1,1))				
				game.Players.LocalPlayer.PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.MultiplayerFolder.Value.SkipSongRequest:InvokeServer()
				SkipSong()
			end
		end

		Connection = script.Parent.SkipButton.SkipButton.MouseButton1Click:Connect(Trigger)
		Connection2 = game:GetService("UserInputService").InputBegan:Connect(function(data)
			if data.KeyCode == Enum.KeyCode.Space then
				Trigger()
			end
		end)
		repeat wait() until (tick()-Start)*1000 >= BeatmapData[1].Time-3250
		if not SkipAlvaiable then
			return
		end
		SkipAlvaiable = false
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
			if CurrentPreviewFrame.OverviewSong.Playing == true and tick()-SongStart >= 0.5 then
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
if not CursorID or tostring(CursorID) == "-1" or tostring(CursorID) == "0" then
	CursorID = 6979941273
end
Cursor.Image = "http://www.roblox.com/asset/?id="..tostring(CursorID)
Cursor.Size = UDim2.new(0,CursorSize*80,0,CursorSize*80)

CursorTrail.Image = "http://www.roblox.com/asset/?id="..tostring(CursorTrailId)
CursorTrail.Size = UDim2.new(0,CursorTrailSize*80,0,CursorTrailSize*80)
CursorTrail.ImageTransparency = CursorTrailTransparency

local UserInputService =game:GetService("UserInputService")
local RblxNewCursor = game.Players.LocalPlayer.PlayerGui.OsuCursor.Cursor
--local CursorUnlocked = false -- this will change to true at the end of the play

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
		script.Parent.RestartGame.Text = "Return (Hold)"
		if HitZoneEnabled then
			if MobileModeRightHitZone == true then
				script.Parent.PSEarned.Position = UDim2.new(1,-5,1,0)
				script.Parent.MobileHit.Position = UDim2.new(1,0,0,-36)
				script.Parent.MobileHit.AnchorPoint = Vector2.new(0,0)
				script.Parent.MobileHit.Title.Rotation = -90
				TweenService:Create(script.Parent.MobileHit,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(1,0)}):Play()
				local restartframeposvalue = Instance.new("BoolValue",script.Parent.ScriptSettings)
				restartframeposvalue.Name = "RestartGameRightSite"
				restartframeposvalue.Value = true
				script.Parent.ComboDisplay.Position = UDim2.new(0,5,1,-23)
				script.Parent.ComboFrameDisplay.Position = UDim2.new(0,0,1,-23)
				local HitKeyFrame = script.Parent.HitKey

				HitKeyFrame.AnchorPoint = Vector2.new(0,0.5)
				HitKeyFrame.Position = UDim2.new(0,0,0.55,0)
				HitKeyFrame.Frame.Position = UDim2.new(0.4,0,0.5,0)
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


		CursorSensitivity= 1
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

			local CurrentCursorPosition = Vector2.new(256,192)

			UserInputService.InputChanged:Connect(function(InputData)
				if CursorUnlocked == true then
					return
				end
				if InputData.UserInputType == Enum.UserInputType.MouseMovement then
					local WindowSize = workspace.CurrentCamera.ViewportSize
					local AbsoluteSize = script.Parent.PlayFrame.AbsoluteSize

					--InputData.Delta

					local MouseMovement = Vector2.new(InputData.Delta.X/AbsoluteSize.X,InputData.Delta.Y/AbsoluteSize.Y)*CursorSensitivity
					local CurrentPos = CursorPosition
					CurrentPos += MouseMovement*Vector2.new(512,384)

					local PlayScreenCenterPos = WindowSize * Vector2.new(0.5,0.53) -- Vector2.new(0,18)
					local PlayScreenSize = Vector2.new(1.067*WindowSize.Y-36,0.8*WindowSize.Y-36)
					local PlayScreenCornerPos = PlayScreenCenterPos - PlayScreenSize/2
					local MaxPosition = (WindowSize - PlayScreenCornerPos)/PlayScreenSize*Vector2.new(512,384)
					local MinPosition = (-PlayScreenCornerPos)/PlayScreenSize*Vector2.new(512,384)

					if CurrentPos.X > MaxPosition.X then
						CurrentPos = Vector2.new(MaxPosition.X,CurrentPos.Y)
					elseif CurrentPos.X < MinPosition.X then
						CurrentPos = Vector2.new(MinPosition.X,CurrentPos.Y)
					end

					if CurrentPos.Y > MaxPosition.Y then
						CurrentPos = Vector2.new(CurrentPos.X,MaxPosition.Y)
					elseif CurrentPos.Y < MinPosition.Y then
						CurrentPos = Vector2.new(CurrentPos.X,MinPosition.Y)
					end

					CursorPosition = CurrentPos

				end
			end)
		end
	end

	game:GetService("UserInputService").InputBegan:Connect(function(data)
		if data.KeyCode == Key1Input and not (MobileMode and game:GetService("UserInputService").TouchEnabled) then
			MouseHitEvent:Fire(SecurityKey,1)
		elseif data.KeyCode == Key2Input and not (MobileMode and game:GetService("UserInputService").TouchEnabled) then
			MouseHitEvent:Fire(SecurityKey,2)
		elseif data.UserInputType == Enum.UserInputType.MouseButton1 and MouseButtonEnabled == true and not (MobileMode and game:GetService("UserInputService").TouchEnabled) then
			MouseHitEvent:Fire(SecurityKey,3)
		elseif data.UserInputType == Enum.UserInputType.MouseButton2 and MouseButtonEnabled == true and not (MobileMode and game:GetService("UserInputService").TouchEnabled) then
			MouseHitEvent:Fire(SecurityKey,4)
		end
	end)
	game:GetService("UserInputService").InputEnded:Connect(function(data)
		if data.KeyCode == Key1Input then
			MouseHitEndEvent:Fire(SecurityKey,1)
		elseif data.KeyCode == Key2Input then
			MouseHitEndEvent:Fire(SecurityKey,2)
		elseif data.UserInputType == Enum.UserInputType.MouseButton1 and MouseButtonEnabled == true then
			MouseHitEndEvent:Fire(SecurityKey,3)
		elseif data.UserInputType == Enum.UserInputType.MouseButton2 and MouseButtonEnabled == true then
			MouseHitEndEvent:Fire(SecurityKey,4)
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
		MouseHitEvent:Fire(SecurityKey,3)
		--end
	end)
	game:GetService("UserInputService").TouchEnded:Connect(function(data)
		MouseHitEndEvent:Fire(SecurityKey,3)
	end)
	script.Parent.MobileHit.MouseButton1Down:Connect(function()
		MobileHold = true
		MouseHitEvent:Fire(SecurityKey,4)
	end)
	script.Parent.MobileHit.MouseButton1Up:Connect(function()
		MobileHold = false
		MouseHitEndEvent:Fire(SecurityKey,4)
	end)
	script.Parent.MobileHit.MouseLeave:Connect(function()
		if MobileHold == true then
			MobileHold = false
			MouseHitEndEvent:Fire(SecurityKey,4)
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
	MouseHitEvent.Event:Connect(function(CurrentSecurityKey,data)
		if data == 1 then
			K1 += 1
			DownKey.K1 = true
			script.Parent.HitKey.K1.Keycount.Text = K1
			TweenService:Create(script.Parent.HitKey.K1,KeyTweenInfo,ChangeIn1):Play()
		elseif data == 2 then
			K2 += 1
			DownKey.K2 = true
			script.Parent.HitKey.K2.Keycount.Text = K2
			TweenService:Create(script.Parent.HitKey.K2,KeyTweenInfo,ChangeIn1):Play()
		elseif data == 3 then
			K3 += 1
			DownKey.M1 = true
			script.Parent.HitKey.M1.Keycount.Text = K3
			TweenService:Create(script.Parent.HitKey.M1,KeyTweenInfo,ChangeIn2):Play()
		elseif data == 4 then
			K4 += 1
			DownKey.M2 = true
			script.Parent.HitKey.M2.Keycount.Text = K4
			TweenService:Create(script.Parent.HitKey.M2,KeyTweenInfo,ChangeIn2):Play()
		end
		script.Parent.KeyDown.Value = DownKey.K1 or DownKey.K2 or DownKey.M1 or DownKey.M2
	end)
	MouseHitEndEvent.Event:Connect(function(CurrentSecurityKey,data)
		if data == 1 then
			DownKey.K1 = false
			TweenService:Create(script.Parent.HitKey.K1,KeyTweenInfo,ChangeOut):Play()
		elseif data == 2 then
			DownKey.K2 = false
			TweenService:Create(script.Parent.HitKey.K2,KeyTweenInfo,ChangeOut):Play()
		elseif data == 3 then
			DownKey.M1 = false
			TweenService:Create(script.Parent.HitKey.M1,KeyTweenInfo,ChangeOut):Play()
		elseif data == 4 then
			DownKey.M2 = false
			TweenService:Create(script.Parent.HitKey.M2,KeyTweenInfo,ChangeOut):Play()
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
local hit300 = 119.5 - 9 * OverallDifficulty --148>1 ,  40 OD10   | New: 19.5
local hit100 = 219.5 - 12 * OverallDifficulty --264>1 , 120 OD10  | New: 59.5
local hit50  = 299.5 - 15 * OverallDifficulty --380>1 , 200 OD10  | New: 199.5
local EarlyMiss = 400
local HitErrorMulti = 1.5

if MobileMode and game:GetService("UserInputService").TouchEnabled then
	hit300 = 159.5 - 12 * OverallDifficulty 
	hit100 = 279.5 - 16 * OverallDifficulty
	hit50  = 399.5 - 20 * OverallDifficulty
	EarlyMiss = 500
	HitErrorMulti = 1
end

script.Parent.HitError.Size = UDim2.new(0,hit50*(19/16)*HitErrorMulti,0,25)
script.Parent.HitError._300s.Size = UDim2.new(hit300/hit50,0,0.5,0)
script.Parent.HitError._100s.Size = UDim2.new(hit100/hit50,0,0.5,0)

local Accurancy = {
	h300 = 0,h100 = 0,h50 = 0,miss = 0,Combo = 0, MaxCombo = 0, MaxPeromanceCombo = 0, PerfomanceCombo = 0, h300Bonus = 0, bonustotal = 0,
	HitErrorGraph = {

	},
	OffsetPositive = {Value = 0,Total = 0},
	OffsetNegative = {Value = 0,Total = 0},
	OffsetOverall = {Value = 0,Total = 0}
}
for i = 1,50 do
	local HitErrorGraph = Accurancy.HitErrorGraph
	if i == 1 then
		HitErrorGraph[#HitErrorGraph+1] = {-2,2,0,0}
	else
		HitErrorGraph[#HitErrorGraph+1] = {i*2,(i+1)*2,0,i-1}
		HitErrorGraph[#HitErrorGraph+1] = {-(i+1)*2,-i*2,0,-i+1}
	end
end
local GameMaxCombo = #BeatmapData


local CircleSize = (54.4 - 4.48 * CS)*2

if AutoPlay == false and ReplayMode ~= true and isSpectating == false and UserInputService.TouchEnabled and MobileMode == true then
	CircleSize *= 1.1875
end
local DisplayCombo = 0
local LastCombo = 0
local LastComboCapture = Instance.new("Frame")
local _currentfadecomboid = ""
script.Parent.ComboDisplay:GetPropertyChangedSignal("Text"):Connect(function()
	if OptimizedPerfomance then return end
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
			TweenService:Create(script.Parent.ComboDisplay,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextSize = 60}):Play()
			ProcessFunction(function()
				wait(0.05)
				TweenService:Create(script.Parent.ComboDisplay,TweenInfo.new(0.1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextSize = 50}):Play()
			end)
			ProcessFunction(function()
				local NewFadeCombo = script.ComboFade:Clone()
				NewFadeCombo.Parent = script.Parent.ComboFade
				NewFadeCombo.Text = tostring(NewCombo).."x"
				NewFadeCombo.TextSize = script.Parent.ComboDisplay.TextSize
				NewFadeCombo.TextTransparency = 0.25
				
				game:GetService("TweenService"):Create(NewFadeCombo,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextSize = script.Parent.ComboDisplay.TextSize*1.5,TextTransparency = 1}):Play()
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

local DisplayAccurancy = 10000
local CurrentAccurancy = 10000

local LastComboDisplay = 0

spawn(function() --Accurancy caculation
	local WaitTime = 0
	if OptimizedPerfomance then
		WaitTime = 0.1
	end
	while wait(WaitTime) do
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
	local WaitTime = 0
	if OptimizedPerfomance then
		WaitTime = 0.25
	end

	while wait(WaitTime) do
		if DisplayAccurancy ~= CurrentAccurancy then
			CurrentAccurancy = DisplayAccurancy
			TweenService:Create(script.Parent.GameplayData.Accurancy,TweenInfo.new(0.1/SongSpeed,Enum.EasingStyle.Linear),{Value = DisplayAccurancy}):Play()
		end
	end
end)

local PrevAcc = 100

script.Parent.GameplayData.Accurancy.Changed:Connect(function()
	local Acc = script.Parent.GameplayData.Accurancy.Value/100
	local AccurancyDisplay = script.Parent.AccurancyFrameDisplay

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

-- ScoreV2
TotalScoreEstimated = 0
EstimatedCombo = 0

local ScoreMultiplier = {
	Difficulty = 6,
	Mod = 1
}

script.Parent.MultiplayerData.GetInGameData.OnInvoke = function()
	return {Score = Score,Combo = Accurancy.Combo}
end

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
	local PrevCombo = 0
	local WaitTime = 0
	local PrevHealth = HealthPoint
	if OptimizedPerfomance then
		WaitTime = 0.5
	end
	while wait(WaitTime) do
		if Score ~= PrevScore or PrevMaxCombo ~= Accurancy.MaxCombo then
			script.Parent.ScoreUpdate:Fire(Score,Accurancy.MaxCombo)
		end
		
		ProcessFunction(function()
			if Score ~= PrevScore or PrevCombo ~= Accurancy.Combo or PrevHealth ~= HealthPoint then
				if ScoreV2Enabled then
					script.Parent.MultiplayerLeaderboard.LocalScoreUpdate:Fire({Score = math.round(Score/TotalScoreEstimated*1000000),Combo = Accurancy.Combo,Failed = MultiplayerMatchFailed,HealthPercentage = HealthPoint/MaxHealthPoint})
				else
					script.Parent.MultiplayerLeaderboard.LocalScoreUpdate:Fire({Score = Score,Combo = Accurancy.Combo,Failed = MultiplayerMatchFailed,HealthPercentage = HealthPoint/MaxHealthPoint})
				end
			end
		end)
		PrevScore = Score
		PrevMaxCombo = Accurancy.MaxCombo
		PrevCombo = Accurancy.Combo
		PrevHealth = HealthPoint
	end
end)

spawn(function()
	local CurrentScore = script.Parent.GameplayData.Score.Value
	local CurrentTotalScore = TotalScoreEstimated

	local WaitTime = 0
	if OptimizedPerfomance then
		WaitTime = 0.04
	end
	while wait(WaitTime) do
		if Score ~= CurrentScore or (ScoreV2Enabled and CurrentTotalScore~=TotalScoreEstimated) then
			local DisplayScore = Score
			CurrentScore = Score
			if ScoreV2Enabled then
				local ScoreV2 = (Score/TotalScoreEstimated)*1000000

				if tostring(ScoreV2) == "nan" or tostring(ScoreV2) == "inf" then
					ScoreV2 = 0
				end
				DisplayScore = ScoreV2
			end
			TweenService:Create(script.Parent.GameplayData.Score,TweenInfo.new(0.4/SongSpeed,Enum.EasingStyle.Linear),{Value = DisplayScore}):Play()
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
		if (FlashlightFrame.Visible == false or FlashlightFrame.Parent == nil) and Flashlight == true and gameEnded == false and not BeatmapFailed then
			warn("[Client] An error occured, please rejoin to fix this issue")
			require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("An error occured, please rejoin to fix this issue.",Color3.new(1, 0, 0))
			script.Disabled = true
		end
	end
end)

-- Original size: {30,0,30,0}
-- In-game size = {8,0,8,0}
-- 300+ Combo Size = {5,0,5,0}
FLAnimate = true

if Flashlight == true then
	TweenService:Create(FlashlightFrame,TweenInfo.new(1,Enum.EasingStyle.Linear),{Size = UDim2.new(15,0,15,0),ImageTransparency = 0}):Play()
	ScoreMultiplier.Mod *= 1.12
	script.Parent.PlayFrame.ZIndex = 0
	spawn(function()
		wait(2.5)
		TweenService:Create(FlashlightFrame,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = UDim2.new(8,0,8,0),ImageTransparency = 0}):Play()

		local CurrentCombo = 0
		while wait(0.1) do
			if not FLAnimate then break end
			if CurrentCombo ~= Accurancy.Combo then
				CurrentCombo = Accurancy.Combo
				local FLSize = (CurrentCombo <= 200 and 8-((CurrentCombo/200)*3)) or 5

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
			ChangeSpecValue(250)
		end)
		SpecDelayFrame.DelaySub.MouseButton1Click:Connect(function()
			ChangeSpecValue(-250)
		end)
	end)
	if SpectateRemote then
		local LastEventData = {Pos = Vector2.new(0,0),Time = tick(),Data = false}
		local function QueueSpectateEvent(Data,isSystemCreated)
			if Data == -1 then
				require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("Player you spectate has left, waiting for player to start another play...",Color3.new(1,0,0))
				FindForSpectateSignal()
				return
			end
			local TimeProcess = Data.TimeProcess
			local CurrentSpecTime = Data.SpecTime
			local HostTime = Data.HostTime
			local HostFPS = Data.HostFPS

			if not isSystemCreated and LastEventData.Data and false then
				local FPS = GameplayFPS
				local RespondTime = 1/60
				local Pos1 = LastEventData.Pos
				local Pos2 = Data.Changes.CursorPos
				local Change = Pos2 - Pos1
				local Time1 = LastEventData.Time
				local Time2 = CurrentSpecTime
				local TimeChange = Time2-Time1
				local FramerateCreate = math.floor((Time2-Time1)/RespondTime)
				local DataClone = {}
				for k,v in pairs(Data) do
					DataClone[k]=v
				end
				for i = 1,FramerateCreate do
					ProcessFunction(function()
						DataClone.Changes.CursorPos = Pos1 + Change/(FramerateCreate+1)*i
						DataClone.SpecTime = Time1 + TimeChange/(FramerateCreate+1)*i
						QueueSpectateEvent(DataClone,true)
					end)
				end
			end
			
			if not isSystemCreated then
				LastEventData = {Pos = Data.Changes.CursorPos,Time = CurrentSpecTime,Data = true}
			end

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
					MouseHitEvent:Fire(SecurityKey,Data.Changes.KeyHit)
				else
					MouseHitEndEvent:Fire(SecurityKey,Data.Changes.KeyHit-4)
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
		end
		
		SpectateRemote.OnClientEvent:Connect(QueueSpectateEvent)
	end
end
if isSpectating == false and (AutoPlay == false or (game.Players.LocalPlayer.UserId == 1241445502 and game.PlaceId ~= 6983932919)) then
	--[[
	PlayingRemote.OnClientEvent:Connect(function(Name)
		if typeof(Name) == "String" then
			require(game.Players.LocalPlayer.PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)(Name.." is spectating you",Color3.new(0, 1, 0))
		end
	end)]]
end


MouseHitEvent.Event:Connect(function(CurrentSecurityKey,data)
	if isSpectating == false and (AutoPlay == false or ((game.Players.LocalPlayer.UserId == 1241445502 or game.Players.LocalPlayer.UserId == 1608539863) and game.PlaceId ~= 6983932919)) then
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

MouseHitEndEvent.Event:Connect(function(CurrentSecurityKey,data)
	if isSpectating == false and (AutoPlay == false or ((game.Players.LocalPlayer.UserId == 1241445502 or game.Players.LocalPlayer.UserId == 1608539863) and game.PlaceId ~= 6983932919)) then
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
	if isSpectating == false and (AutoPlay == false or ((game.Players.LocalPlayer.UserId == 1241445502 or game.Players.LocalPlayer.UserId == 1608539863) and game.PlaceId ~= 6983932919)) and onTutorial ~= true then
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
			MouseHitEvent:Fire(SecurityKey,3)
			local CurrentSession = game.HttpService:GenerateGUID()
			KeySession.K1 = CurrentSession
			wait(0.1)
			if KeySession.K1 == CurrentSession then
				MouseHitEndEvent:Fire(SecurityKey,3)
			end
		else
			if RightClick == true then
				RightClick = false
				LastClick = tick()
				MouseHitEvent:Fire(SecurityKey,3)
				local CurrentSession = game.HttpService:GenerateGUID()
				KeySession.K1 = CurrentSession
				wait(0.1)
				if KeySession.K1 == CurrentSession then
					MouseHitEndEvent:Fire(SecurityKey,3)
				end
			else
				RightClick = true
				LastClick = tick()
				local CurrentSession = game.HttpService:GenerateGUID()
				KeySession.K2 = CurrentSession
				MouseHitEvent:Fire(SecurityKey,4)
				wait(0.1)
				if KeySession.K2 == CurrentSession then
					MouseHitEndEvent:Fire(SecurityKey,4)
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
		script.Parent.MultiplayerLeaderboard.LbTrigger:Fire(true)
		local CurrentSection = game.HttpService:GenerateGUID()
		Section = CurrentSection
		BreakTimeFrame.Visible = true
		BreakTimeFrame.Size = UDim2.new(0,0,0,0)
		BreakTimeFrame.TimeProgress.BackgroundTransparency = 0
		local Duration = (BreakTime[2] - BreakTime[1])/1000
		TweenService:Create(script.Parent.HitError.CurrentDelay.Delay,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{TextTransparency = 1}):Play()
		TweenService:Create(script.Parent.HitError.CurrentDelay.UnstableRate,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{TextTransparency = 1}):Play()
		TweenService:Create(script.Parent.HitError,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{AnchorPoint = Vector2.new(0.5,0)}):Play()
		TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans+0.2}):Play()
		TweenService:Create(workspace.BackgroundPart.SurfaceGui.Frame.BackgroundFrame.ImageFrame.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans+0.2}):Play()
		TweenService:Create(FlashlightFrame,TweenInfo.new(1,Enum.EasingStyle.Linear),{Size = UDim2.new(30,0,30,0),ImageTransparency = 0}):Play()
		if BackgroundBlurEnabled == true then
			TweenService:Create(game.Lighting.Blur,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = 15}):Play()
		end
		ProcessFunction(function()
			isDrain = false
			repeat wait() until tick() - Start >= (BreakTime[2]/1000)
			script.Parent.Leaderboard.LbTrigger:Fire(false)
			script.Parent.MultiplayerLeaderboard.LbTrigger:Fire(false)
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
			TweenService:Create(BreakTimeFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(0,400,0,200),Rotation = 0,GroupTransparency = 0}):Play()
			TweenService:Create(script.Parent.BreaktimeFrameOutline,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(0,400,0,200)}):Play()
			TweenService:Create(script.Parent.BreaktimeFrameOutline.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Transparency = 0}):Play()
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,true)
			local TotalNoteResult = Accurancy.h300+Accurancy.h100+Accurancy.h50+Accurancy.miss
			local GameAccurancy = math.floor(((Accurancy.h300*300+Accurancy.h100*100+Accurancy.h50*50)/(TotalNoteResult*300))*100*100)/100
			local GameplayRank = "D"
			local percent300s = Accurancy.h300/(Accurancy.h300+Accurancy.h100+Accurancy.h50+Accurancy.miss)
			local percent50s = Accurancy.h50/(Accurancy.h300+Accurancy.h100+Accurancy.h50+Accurancy.miss)
			local misstotal = Accurancy.miss

			local tostringAcc = tostring(GameAccurancy)

			if tostringAcc == "-nan(ind)" or tostringAcc == "inf" or tostringAcc == "100" or tostringAcc == "nan" then
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
			if (GameplayRank == "S" or SS) and (HiddenMod or Flashlight) then
				BreakTimeFrame.RankDisplay.TextColor3 = Color3.fromRGB(177,177,177)
			end
			BreakTimeFrame.MaxCombo.Text = tostring(Accurancy.MaxCombo).."x"
			BreakTimeFrame.MissTotal.Text = tostring(Accurancy.miss).." miss"
			BreakTimeFrame.SS_Rank.Visible = SS and not (HiddenMod or Flashlight)
			BreakTimeFrame.SSH_Rank.Visible = SS and (HiddenMod or Flashlight)
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
				BreakTimeFrame.TimeDisplay.Text = "<b>"..tostring(math.floor(DisplayTime)).."</b>"
				BreakTimeFrame.TimeProgress.Size = UDim2.new((((TimeLeft)/Duration)*0.9),0,0,5)
			end


			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,not DisableChatInGame)

			spawn(function()
				wait(0.5)
				if Section == CurrentSection then
					--BreakTimeFrame.Visible = false
				end
			end)
			local FLSize = (Accurancy.Combo <= 200 and 8-((Accurancy.Combo/200)*3)) or 5

			TweenService:Create(FlashlightFrame,TweenInfo.new(1,Enum.EasingStyle.Linear),{Size = UDim2.new(FLSize,0,FLSize,0)}):Play()
			TweenService:Create(BreakTimeFrame.TimeProgress,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{BackgroundTransparency = 1}):Play()
			TweenService:Create(BreakTimeFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{Size = UDim2.new(0,4,0,2),Rotation = -20,GroupTransparency = 1}):Play()
			TweenService:Create(script.Parent.BreaktimeFrameOutline,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{Size = UDim2.new(1.067,0,0.8,0)}):Play()
			TweenService:Create(script.Parent.BreaktimeFrameOutline.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{Transparency = 1}):Play()
			--TweenService:Create(BreakTimeFrame,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Position = UDim2.new(0.5,0,-1.5,-18)}):Play()
		end
	end
end)


local TotalNotes = 0 
local NoteDisplayLimit = 1200
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

--

local ComboNoteData = {
	Missed = false,
	Missor50 = false,
	Full300 = true
}

--AccuracyChart

local BeatmapLength = BeatmapData[#BeatmapData].Time
local AvgLength = BeatmapLength/100
local TimeAccurancy = {}
local TimePerfomance = {}
local MissedInCurrentTime = false

spawn(function()
	for i = 1,101 do
		repeat wait() until (tick() - Start)*1000 > AvgLength*i

		-- Accurancy

		local TotalNoteResult = Accurancy.h300+Accurancy.h100+Accurancy.h50+Accurancy.miss
		local GameAccurancy = math.floor(((Accurancy.h300*300+Accurancy.h100*100+Accurancy.h50*50)/(TotalNoteResult*300))*100*100)/100

		if tostring(GameAccurancy) == "nan" then
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

		TimeAccurancy[i] = {AccurancyPoint,GameplayRank,MissedInCurrentTime}

		MissedInCurrentTime = false

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
	HealthPoint = MaxHealthPoint
	TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans}):Play()
	TweenService:Create(workspace.BackgroundPart.SurfaceGui.Frame.BackgroundFrame.ImageFrame.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans}):Play()
	repeat wait() until tick() - Start > (BeatmapData[1].Time/1000)
	isDrain = true
end)


SliderTickEvent = Instance.new("BindableEvent")
CurrentTickId = "0"
if string.sub(ReturnData.SampleSet,1,1) == " " then
	ReturnData.SampleSet = string.sub(ReturnData.SampleSet,2,#ReturnData.SampleSet)
end
CurrentHitsoundSample = ReturnData.SampleSet
HitsoundSampleset = {
	[0] = "default",
	[1] = "normal",
	[2] = "soft",
	[3] = "drum"
}
HitsoundTypeset = {
	[0] = "hitnormal",
	[1] = "hitfinish",
	[2] = "hitwhistle",
	[3] = "hitclap",
	[4] = "hitclap2",
	[5] = "slidertick"
}

function CreateHitSound(HitsoundType,CustomSampleSet)
	local SelectedSampleSet = CustomSampleSet

	if not SelectedSampleSet or SelectedSampleSet == "0" then
		SelectedSampleSet = CurrentHitsoundSample
	else
		SelectedSampleSet = HitsoundSampleset[tonumber(SelectedSampleSet)]
	end

	if HitsoundType == 4 and SelectedSampleSet == "drum" then
		return
	end

	local HitsoundFilename = SelectedSampleSet.."-"..HitsoundTypeset[HitsoundType]
	local CurrentHitsound = script.Hitsounds[HitsoundFilename]:Clone()
	CurrentHitsound.Parent = script.Parent.HitSounds

	CurrentHitsound:Play()
	ProcessFunction(function()
		wait(0.5)
		CurrentHitsound:Destroy()
	end)
end


ProcessFunction(function()
	for i,TimingData in pairs(TimingPoints) do
		if TimingData ~= nil and #TimingData > 0 then
			repeat wait() until (tick()-Start) >= (TimingData[1]/1000)
			script.HitSound.Volume = TimingData[6]/100*EffectVolume*0.01
			script.HitSoundClap.Volume = TimingData[6]/100*EffectVolume*0.01
			script.HitSoundFinish.Volume = TimingData[6]/100*EffectVolume*0.01
			script.HitSoundWhistle.Volume = TimingData[6]/100*EffectVolume*0.01

			for _,Hitsound in pairs(script.Hitsounds:GetChildren()) do
				Hitsound.Volume = TimingData[6]/100*EffectVolume*0.01
			end
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

			local Sampleset = TimingData[4]
			if Sampleset == 0 then
				CurrentHitsoundSample = ReturnData.SampleSet
			else
				CurrentHitsoundSample = HitsoundSampleset[Sampleset]
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
	TotalScoreEstimated += SpinnerScore
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

NoteTotal = #BeatmapData
NoteCompleted = 0
script.Parent.PSEarned.DetailedDisplay.Visible = DetailedPSDisplay

if NewPerfomanceDisplay then
	script.Parent.PSEarned.TextTransparency = 0
	script.Parent.PSEarned.AnimatedPSEarned:Destroy()
end


function AddPerfomanceScore(AimPS,StreamPS,Multiplier)
	local DefaultMultiplier = 100
	AimPS *= DefaultMultiplier
	StreamPS *= DefaultMultiplier
	local PerfomanceKey = game.HttpService:GenerateGUID()
	local JugdementCombo = (Accurancy.Combo < 20 and Missed and Accurancy.Combo) or 20
	if tonumber(Multiplier) == nil then Multiplier = 1 end
	local DefaultMultiplier = 0.68 -- due to the recent update difficulty multiplier
	AimPS *= DefaultMultiplier
	StreamPS *= DefaultMultiplier

	-- this thing to prevent spamming keys and get free PS. Miss = lost alot of ps
	AimPS = AimPS * Multiplier * 0.75^(20-JugdementCombo)
	StreamPS = StreamPS * Multiplier * 0.75^(20-JugdementCombo)
	local OverallPS = (AimPS+StreamPS) * 0.75^(20-JugdementCombo)

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
		NoteCompleted -= 1
		if PunishmentRatio <= 0.85 then
			if not HardCore then
				PSPunishment += 135
				--ExtraPerfomance -= 30
			else
				PSPunishment += 110
				--ExtraPerfomance -= 10
			end
		else
			PSPunishment += math.ceil((((PSPunishmentLimit-PSPunishment)/PSPunishmentLimit) ^ 2) / 0.0225 * 110)
		end

	elseif Multiplier == 1/6 then
		if PunishmentRatio >= 1-1/6 then
			if not HardCore then
				PSPunishment += 20
				--ExtraPerfomance -= 10
			else
				PSPunishment += 20
				--ExtraPerfomance -= 2
			end
		end
		--ExtraPerfomance += (AimPerfomance + StreamPerfomance)/6
	elseif Multiplier == 1/3 then
		if PunishmentRatio >= 1-1/3 then
			if not HardCore then
				PSPunishment += 10
				--ExtraPerfomance -= 5
			else
				PSPunishment += 10
			end
		end
		--ExtraPerfomance += (AimPerfomance + StreamPerfomance)/3
	elseif Multiplier == 1 then
		--ExtraPerfomance += (AimPerfomance + StreamPerfomance)
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

	if OverallPS > 0 then
		--table.insert(StreamPSList,1,StreamPS)
		OverallPSList[#OverallPSList+1] = OverallPS
		table.sort(OverallPSList,function(ps1,ps2) return ps1 > ps2 end)
	end

	--[[

	if OverallPS > 0 then
		table.insert(OverallPSList,1,OverallPS)
		table.sort(OverallPSList,function(ps1,ps2) return ps1 > ps2 end)
	end]]

	-- print result for test
	local TotalNoteResult = Accurancy.h300+Accurancy.h100+Accurancy.h50+Accurancy.miss
	local acc = ((Accurancy.h300*300+Accurancy.h100*100+Accurancy.h50*50)/(TotalNoteResult*300))*100
	local CompletedRatio = NoteCompleted/NoteTotal
	local NoteCompletedMultiplier = CompletedRatio

	local RewaredAccPS = MaxAccurancyPS* 0.727^(100-acc) -- get whole accurancy
	local RewaredAimPS = 0
	local RewaredStreamPS = 0
	local RewaredOverallPS = 0

	local AimClearNum = -1
	local StreamClearNum = -1
	local OverallClearNum = -1

	for Top,AimPS in pairs(AimPSList) do -- 0.8
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

	for Top,OverallPS in pairs(OverallPSList) do
		if OverallPS*0.8^(Top-1) < 0.001 then
			StreamClearNum = Top
			break
		end
		RewaredOverallPS += OverallPS*0.8^(Top-1)
	end

	for i = #StreamPSList,1,-1 do
		if StreamPSList[i]*0.8^(i-1) < 0.001 then
			StreamPSList[i] = nil
		else
			break
		end
	end

	for i = #OverallPSList,1,-1 do
		if OverallPSList[i]*0.8^(i-1) < 0.001 then
			OverallPSList[i] = nil
		else
			break
		end
	end
	--[[
	for Top,OverallPS in pairs(OverallPSList) do
		RewaredOverallPS += OverallPS*0.9025^(Top-1)
	end]]

	local ComboPerfomanceMultiplier = 1 --1*0.25^((1-(Accurancy.MaxPeromanceCombo/GameMaxCombo))*2)

	local BonusFLMultiplier = (NoteCompleted*0.00035)
	if not Flashlight then
		BonusFLMultiplier = 0
	elseif NoteCompleted > 1000 then
		--BonusFLMultiplier = 0.7
	end
	BonusFLMultiplier *= (Score/TotalScoreEstimated)
	
	local accAim = RewaredAimPS * ComboPerfomanceMultiplier * NoteCompletedMultiplier * (1 + BonusFLMultiplier)
	local accStream = RewaredStreamPS * ComboPerfomanceMultiplier * NoteCompletedMultiplier
	local accOverall = RewaredOverallPS * ComboPerfomanceMultiplier * NoteCompletedMultiplier * 0.1

	RewaredAimPS = RewaredAimPS * (1 - (PSPunishment/PSPunishmentLimit)) * ComboPerfomanceMultiplier * NoteCompletedMultiplier * (1 + BonusFLMultiplier)
	RewaredStreamPS = RewaredStreamPS * (1 - (PSPunishment/PSPunishmentLimit)) * ComboPerfomanceMultiplier * NoteCompletedMultiplier
	RewaredOverallPS = RewaredOverallPS * (1 - (PSPunishment/PSPunishmentLimit)) * ComboPerfomanceMultiplier * NoteCompletedMultiplier * 0.1
	
	
	local AimStreamPS = AimPS + StreamPS

	RewaredAccPS += (accAim+accStream+accOverall) * 0.2 * 0.727^(100-acc)

	RewaredAimPS *= 0.8
	RewaredStreamPS *= 0.8
	RewaredOverallPS *= 0.8

	if RewaredAimPS < 0 then
		RewaredAimPS = 0
	end 

	if RewaredStreamPS < 0 then
		RewaredStreamPS = 0
	end

	local TotalRewardedPS =  RewaredAccPS + (RewaredAimPS +RewaredStreamPS) + RewaredOverallPS

	local Multiplier = 1



	if Flashlight == true then
		--TotalRewardedPS *= 1.12
		--BetaPS *= 1.12
	end

	if HardCore then -- 1.11
		TotalRewardedPS *= 1.05
		Multiplier *= 1.05 
	end

	if HiddenMod then -- 1.08
		TotalRewardedPS *= 1.04
		Multiplier *= 1.04
	end

	if HardRock then -- 1.45
		TotalRewardedPS *= 1.2
		Multiplier *= 1.2
	end

	if EasyMod then -- 0.75
		TotalRewardedPS *= 0.87
		Multiplier *= 0.87
	end
	

	local BetaPS = (TotalRewardedPS/50*0.86)^2-- * (Score/TotalScoreEstimated) -- osu PP


	--RewaredOverallPS = BetaPS + TotalRewardedPS


	CurrentPerfomance = TotalRewardedPS

	local DisplayOverallPS = RewaredOverallPS + ((TotalRewardedPS-(RewaredOverallPS)/Multiplier)-(TotalRewardedPS/Multiplier-RewaredOverallPS))

	--TotalRewardedPS = 2^(TotalRewardedPS^(1/3.23))
	local NewPerfomanceText = ""

	local DisplayData = {
		Aim = math.floor(RewaredAimPS/0.8),
		Speed = math.floor(RewaredStreamPS/0.8),
		Mod = math.floor(RewaredOverallPS/0.8 + TotalRewardedPS*(Multiplier-1)),
		Acc = math.floor(MaxAccurancyPS* 0.727^(100-acc)),
		AccPercentage = math.floor(20 * 0.727^(100-acc)*10)/10,
		PunishmentPercentage = math.floor(PunishmentRatio*1000)/10
	}



	if NewPerfomanceDisplay == true then
		local ExtraPerfomance = ExtraPerfomance * (1 - (PSPunishment/PSPunishmentLimit))
		--NewPerfomanceText = "(BetaPS: "..tostring(math.floor((ExtraPerfomance + RewaredAimPS + RewaredAccPS)*((Flashlight and 1.12) or 1))).."ps)"
		NewPerfomanceText = " ("..tostring(math.floor(BetaPS)).."pp)"
	end

	if not isSpectating then
		--script.Parent.PSEarned.DetailedDisplay.Text = tostring(math.floor(RewaredAimPS*0.7)).."/"..tostring(math.floor(RewaredStreamPS*0.7)).."/"..tostring(math.floor(DisplayOverallPS)).."/"..tostring(math.floor(RewaredAccPS))
		local DetailedDisplayPanel = script.Parent.PSEarned.DetailedDisplay
		DetailedDisplayPanel.Aim.Text = "Aim | "..DisplayData.Aim.."ps"
		DetailedDisplayPanel.Speed.Text = "Speed | "..DisplayData.Speed.."ps"
		DetailedDisplayPanel.Mod.Text = "Mod | "..DisplayData.Mod.."ps"
		DetailedDisplayPanel.Accuracy.Text = "Acc | "..DisplayData.AccPercentage.."% + "..DisplayData.Acc.."ps"
		DetailedDisplayPanel.Punishment.Text = "Punishment | "..DisplayData.PunishmentPercentage.."%"
		script.Parent.PSEarned.Text = tostring(math.floor(TotalRewardedPS)).."ps"..NewPerfomanceText
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
		if HitElapsed > 2 and script.Parent.HitError.CurrentDelay.Delay.TextTransparency == 0 then
			TweenService:Create(script.Parent.HitError.CurrentDelay.Delay,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{TextTransparency = 1}):Play()
			TweenService:Create(script.Parent.HitError.CurrentDelay.UnstableRate,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{TextTransparency = 1}):Play()
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
	TweenService:Create(script.Parent.HitError.CurrentDelay.Delay,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(Pos,0,0.5,0),TextTransparency = 0}):Play()
	TweenService:Create(script.Parent.HitError.CurrentDelay.UnstableRate,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{TextTransparency = 0}):Play()
	LastHitError = tick()

	TotalHit += 1

	if HitDelay >= 0 then
		Accurancy.OffsetPositive.Total += 1
		Accurancy.OffsetPositive.Value += HitDelay
	else
		Accurancy.OffsetNegative.Total += 1
		Accurancy.OffsetNegative.Value += HitDelay
	end
	Accurancy.OffsetOverall.Total += 1
	Accurancy.OffsetOverall.Value += HitDelay

	if TotalHit > 1 then
		local LocalUnstableRate = math.abs(HitDelay)
		TotalUnstableTime += LocalUnstableRate

		local UnstableRate = (TotalUnstableTime/(TotalHit-1))*10
		script.Parent.HitError.CurrentDelay.UnstableRate.Text = tostring(math.floor(UnstableRate))
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
	MetaDataFrame.Artist.Text = ReturnData.Overview.Metadata.SongCreatorUnicode
	MetaDataFrame.SongName.Text = "<b>"..ReturnData.Overview.Metadata.MapNameUnicode.."</b>"

	local _1 = TweenInfo.new(1.5,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out)
	local _2 = TweenInfo.new(1.5,Enum.EasingStyle.Exponential,Enum.EasingDirection.In)


	TweenService:Create(MetaDataFrame,_1,{Position = UDim2.new(0,0,1,-50)}):Play()
	TweenService:Create(MetaDataFrame.Artist,_1,{TextTransparency = 0.6}):Play()
	TweenService:Create(MetaDataFrame.SongName,_1,{TextTransparency = 0.5}):Play()
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

MouseHitEvent.Event:Connect(function(_,KeyHit)
	local CurrentTime = math.floor((tick() - Start)*1000+0.5)
	local FullData = {H = true,T = CurrentTime}
	
	UploadReplay(2,FullData,2,KeyHit)
end)

MouseHitEndEvent.Event:Connect(function(_,KeyHit)
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
if SliderMode == true then
	if ReturnData.WeirdSliderAlert == true then
		game.Players.LocalPlayer.PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("This beatmap contain some weird sliders shape/movement that may lead you to miss.",Color3.fromRGB(255,0,0))
	end
	if ReturnData.SliderCrashAlert == true then
		game.Players.LocalPlayer.PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("This beatmap contain some sliders that may make your device to lag/crash.",Color3.fromRGB(255,0,0))
	end
end

-- Note score

function AddScore(HitValue)
	local Combo = Accurancy.Combo
	Score += HitValue + (HitValue * ((((Combo > 2 and Combo-2) or 0) * ScoreMultiplier.Difficulty * ScoreMultiplier.Mod) / 25))
	TotalScoreEstimated += 300 + (300 * ((((EstimatedCombo > 2 and EstimatedCombo-2) or 0) * ScoreMultiplier.Difficulty * ScoreMultiplier.Mod) / 25))
end

-- HIT OBJ LINE

for i,HitObj in pairs(BeatmapData) do
	local HitNoteID = i
	local HitMiss = false
	local IsHitted = false
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
		elseif (tick()-Start)*1000 < HitObj.Time-CircleApproachTime then
			if (HitObj.Time-CircleApproachTime)/1000 - (tick()-Start) < 3600 then
				wait((HitObj.Time-CircleApproachTime)/1000 - (tick()-Start))
			else
				repeat wait() until (tick()-Start) >= (HitObj.Time-CircleApproachTime)/1000
			end
		end
		if TotalNotes > NoteDisplayLimit then
			repeat wait() until TotalNotes <= NoteDisplayLimit
		end
	end
	NoteCompleted += 1

	ProcessFunction(function()
		wait((HitObj.Time)/1000 - (tick()-Start))
		NPS += 1 wait(1/SongSpeed) NPS -= 1
		HealthDrainMultiplier += 0.3
		if HealthDrainMultiplier > 20 then
			HealthDrainMultiplier = 20
		end
		--[[local DrainMulti = (1+NPS*0.95/5)
		if DrainMulti > 10 then DrainMulti = 10 end
		HealthDrainMultiplier = DrainMulti
		wait(5/SongSpeed)
		NPS -= 1
		if DrainMulti > 20 then DrainMulti = 20 end
		HealthDrainMultiplier = DrainMulti]]
	end)


	local Type = HitObj.Type -- Will be useful

	if Type ~= 1 and Type ~= 2 and Type ~= 8 then
		Combo = 1
		ComboNoteData = {Full300 = true,Missor50 = false,Missed = false}
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
		local NoteNormalSampleSet = "0"
		local NoteAditionSampleSet = "0"

		local HitsoundCustomSampleSet = HitObj.ExtraData[#HitObj.ExtraData]
		if string.find(HitsoundCustomSampleSet,":") then
			local _s1,_e1 = 1,string.find(HitsoundCustomSampleSet,":")-1
			local _s2,_e2 = _e1+2,string.find(HitsoundCustomSampleSet,":",_e1+2)-1
			NoteNormalSampleSet,NoteAditionSampleSet = string.sub(HitsoundCustomSampleSet,_s1,_e1),string.sub(HitsoundCustomSampleSet,_s2,_e2)
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
						MouseHitEvent:Fire(SecurityKey,3)
						SpinKey = 3
						local CurrentSession = game.HttpService:GenerateGUID()
						KeySession.K1 = CurrentSession
					else
						if RightClick == true then
							RightClick = false
							LastClick = tick()
							MouseHitEvent:Fire(SecurityKey,3)
							SpinKey = 3
							local CurrentSession = game.HttpService:GenerateGUID()
							KeySession.K1 = CurrentSession
						else
							RightClick = true
							LastClick = tick()
							MouseHitEvent:Fire(SecurityKey,4)
							SpinKey = 4
							local CurrentSession = game.HttpService:GenerateGUID()
							KeySession.K2 = CurrentSession
						end
					end
					local Connection = script.Parent.ATSpinner.SpinPart.Changed:Connect(function()
						local LookVector = script.Parent.ATSpinner.SpinPart.CFrame.LookVector
						local Pos = UDim2.new(((256+(LookVector.X*128)))/512,0,((192+(LookVector.Z*128)))/384,0)
						TweenService:Create(ATVC,TweenInfo.new(0,Enum.EasingStyle.Linear),{Position = Pos}):Play()
					end)
					wait(SpinnerTime-0.1)
					Connection:Disconnect()
					wait(0.1)
					MouseHitEndEvent:Fire(SecurityKey,SpinKey)
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
					NewHitResult.ZIndex = 1
					if HitResult ~= 1 then
						NewHitResult.Size = UDim2.new((CircleSize/384)*0.3,0,(CircleSize/384)*0.3,0)
						NewHitResult.Position = UDim2.new(0.5,0,0.5,0)
						TweenService:Create(NewHitResult,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{Size = UDim2.new((CircleSize/384)*0.6,0,(CircleSize/384)*0.6,0)}):Play()
						TweenService:Create(NewHitResult.Image,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{ImageTransparency = 0}):Play()
						wait(0.5)
						if BeatmapFailed then return end
						AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(0.2,Enum.EasingStyle.Sine),{ImageTransparency = 1,Position = UDim2.new(0.5,0,0.6,0)})):Play()
						wait(0.2)
						if BeatmapFailed then return end
						NewHitResult:Destroy()
					else
						NewHitResult.Size = UDim2.new((CircleSize/384)*0.37,0,(CircleSize/384)*0.37,0)
						NewHitResult.Image.ImageTransparency = 0.5
						NewHitResult.Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0)
						local CurrentRotation = math.random(-10,10)
						local Positive = CurrentRotation/math.abs(CurrentRotation)
						if tostring(Positive) == "nan" then
							Positive = 1
						end 
						NewHitResult.Rotation = CurrentRotation
						local CurrentPos = NewHitResult.Position
						AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{ImageTransparency = 0,Size = UDim2.new(1,0,1,0)})):Play()
						wait(0.1)
						if BeatmapFailed then return end
						AddHitnoteAnimation(TweenService:Create(NewHitResult,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Rotation = CurrentRotation+(Positive*15),Position = CurrentPos+UDim2.new(0,0,0.15,0)})):Play()
						AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{ImageTransparency = 1})):Play()
						wait(1)
						if BeatmapFailed then return end
						NewHitResult:Destroy()
					end
				end)
			end


			if Ratio >= 0.5 or SpinnerTime < 0.2 then
				Accurancy.Combo += 1
				EstimatedCombo += 1
				Accurancy.PerfomanceCombo += 1 
				if Accurancy.PerfomanceCombo > Accurancy.MaxPeromanceCombo then
					Accurancy.MaxPeromanceCombo = Accurancy.PerfomanceCombo
				end
				if Accurancy.Combo > Accurancy.MaxCombo then
					Accurancy.MaxCombo = Accurancy.Combo
				end
				spawn(function()
					local HitSoundType = tonumber(HitObj.ExtraData[1])
					CreateHitSound(0,NoteNormalSampleSet) -- normal
					if HitSoundType == 2 or HitSoundType == 14 or HitSoundType == 6 or HitSoundType == 10 then
						CreateHitSound(2,NoteAditionSampleSet) -- whistle
					end
					if HitSoundType == 4 or HitSoundType == 14 or HitSoundType == 6 or HitSoundType == 12 then
						CreateHitSound(1,NoteAditionSampleSet) -- finish
					end
					if HitSoundType == 8 or HitSoundType == 14 or HitSoundType == 10 or HitSoundType == 12 then
						CreateHitSound(3,NoteAditionSampleSet) -- clap
						if NoteAditionSampleSet ~= "3" then
							CreateHitSound(4,NoteAditionSampleSet) -- clap2
						end
					end
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
				EstimatedCombo += 1
				Accurancy.PerfomanceCombo = 0
				Missed = true
				AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,0)
				Accurancy.miss += 1
				MissedInCurrentTime = true
				AddScore(0)
				CreateHitResult(1)
				HitMiss = true
			end
			if not OptimizedPerfomance then
				wait(1)
			end
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
					local Tween
					if CursorTweenTime > AvgFrameTime then
						Tween = game:GetService("TweenService"):Create(ATVC,TweenInfo.new(CursorTweenTime/1000,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0)}) 
						Tween:Play()
					else -- if TweenTime <= 17ms then not gonna tween
						ATVC.Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0)
					end
					if CursorTweenTime > AvgFrameTime and (tick()-Start) <= (HitObj.Time + hit300)/1000 then
						--wait(CursorTweenTime/1000)
						repeat wait() until (tick()-Start) >= (HitObj.Time)/1000
					end
					if Tween then
						Tween:Pause()
					end


					ATVC.Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0)

					CurrentNoteId = NoteId

					if Type ~= 2 or not SliderMode then
						AutoClick()
					else
						if tick() - LastClick > 0.25 then
							RightClick = false
							LastClick = tick()
							MouseHitEvent:Fire(SecurityKey,3)
							SliderATKey = 3
							local CurrentSession = game.HttpService:GenerateGUID()
							KeySession.K1 = CurrentSession
						else
							if RightClick == true then
								RightClick = false
								LastClick = tick()
								MouseHitEvent:Fire(SecurityKey,3)
								SliderATKey = 3
								local CurrentSession = game.HttpService:GenerateGUID()
								KeySession.K1 = CurrentSession
							else
								RightClick = true
								LastClick = tick()
								MouseHitEvent:Fire(SecurityKey,4)
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
			for i = 1,#tostring(Combo) do
				local Current = string.sub(tostring(Combo),i,i)
				local NumberFrame = script.HitCircleNumber["Number_"..Current]:Clone()
				NumberFrame.Parent = Circle.CircleNumber
				NumberFrame.ImageTransparency = 1
				NumberFrame.LayoutOrder = i
			end

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
					if Object.Name == "CircleNumber" then
						for _,a in pairs(Object:GetChildren()) do 
							if a:IsA("ImageLabel") then
								AddHitnoteAnimation(game:GetService("TweenService"):Create(a,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{ImageTransparency = 0})):Play()
							end
						end
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
							if Object.Name == "CircleNumber" then
								for _,a in pairs(Object:GetChildren()) do 
									if a:IsA("ImageLabel") then
										game:GetService("TweenService"):Create(a,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
									end
								end
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
					NewHitResult.ZIndex = 1
					if HitResult ~= 1 then
						NewHitResult.Size = UDim2.new((CircleSize/384)*0.3,0,(CircleSize/384)*0.3,0)
						NewHitResult.Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0)
						TweenService:Create(NewHitResult,TweenInfo.new(0.1/SongSpeed,Enum.EasingStyle.Linear),{Size = UDim2.new((CircleSize/384)*0.6,0,(CircleSize/384)*0.6,0)}):Play()
						TweenService:Create(NewHitResult.Image,TweenInfo.new(0.1/SongSpeed,Enum.EasingStyle.Linear),{ImageTransparency = 0}):Play()
						wait(0.5/SongSpeed)
						if BeatmapFailed then return end
						AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(0.2/SongSpeed,Enum.EasingStyle.Sine),{ImageTransparency = 1,Position = UDim2.new(0.5,0,0.6,0)})):Play()
						wait(0.2/SongSpeed)
						if BeatmapFailed then return end
						NewHitResult:Destroy()
					else
						NewHitResult.Size = UDim2.new((CircleSize/384)*0.37,0,(CircleSize/384)*0.37,0)
						NewHitResult.Image.ImageTransparency = 1
						local HitResultPosition = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0) 
						NewHitResult.Position = HitResultPosition
						local CurrentRotation = math.random(-10,10)
						local Positive = CurrentRotation/math.abs(CurrentRotation)
						if tostring(Positive) == "nan" then
							Positive = 1
						end 
						NewHitResult.Rotation = CurrentRotation
						local CurrentPos = NewHitResult.Position
						AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(0.1/SongSpeed,Enum.EasingStyle.Linear),{ImageTransparency = 0,Size = UDim2.new(1,0,1,0)})):Play()
						wait(0.1/SongSpeed)
						if BeatmapFailed then return end
						AddHitnoteAnimation(TweenService:Create(NewHitResult,TweenInfo.new(1/SongSpeed,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Rotation = CurrentRotation+(Positive*15),Position = HitResultPosition+UDim2.new(0,0,0.15,0)})):Play()
						AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(1/SongSpeed,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{ImageTransparency = 1})):Play()
						wait(1/SongSpeed)
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
					NewHitResult.ZIndex = 1
					if HitResult ~= 1 then
						NewHitResult.Size = UDim2.new((CircleSize/384)*0.5,0,(CircleSize/384)*0.5,0)
						NewHitResult.Position = UDim2.new(Pos.X/512,0,Pos.Y/384,0)
						TweenService:Create(NewHitResult,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{Size = UDim2.new((CircleSize/384)*0.6,0,(CircleSize/384)*0.6,0)}):Play()
						TweenService:Create(NewHitResult.Image,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{ImageTransparency = 0}):Play()
						wait(0.5)
						if BeatmapFailed then return end
						AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(0.2,Enum.EasingStyle.Sine),{ImageTransparency = 1,Position = UDim2.new(0.5,0,0.6,0)})):Play()
						wait(0.2)
						if BeatmapFailed then return end
						NewHitResult:Destroy()
					else
						NewHitResult.Size = UDim2.new((CircleSize/384)*0.37,0,(CircleSize/384)*0.37,0)
						NewHitResult.Image.ImageTransparency = 0.5
						NewHitResult.Position = UDim2.new(Pos.X/512,0,Pos.Y/384,0)
						local CurrentRotation = math.random(-10,10)
						local Positive = CurrentRotation/math.abs(CurrentRotation)
						if tostring(Positive) == "nan" then
							Positive = 1
						end 
						NewHitResult.Rotation = CurrentRotation
						local CurrentPos = NewHitResult.Position
						TweenService:Create(NewHitResult.Image,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{ImageTransparency = 0,Size = UDim2.new(1,0,1,0)}):Play()
						wait(0.1)
						TweenService:Create(NewHitResult,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Rotation = CurrentRotation+(Positive*15),Position = CurrentPos+UDim2.new(0,0,0.15,0)}):Play()
						TweenService:Create(NewHitResult.Image,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{ImageTransparency = 1}):Play()
						wait(1)
						NewHitResult:Destroy()
					end
				end)
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
				local SliderFolder = Instance.new("CanvasGroup",script.Parent.PlayFrame)
				SliderFolder.Name = "Slider"
				SliderFolder.BackgroundTransparency = 1
				local SLCanvasScale = 2
				SliderFolder.Size = UDim2.new(SLCanvasScale,0,SLCanvasScale,0)
				SliderFolder.ZIndex = ZIndex-1
				SliderFolder.Position = UDim2.new(0.5,0,0.5,0)
				SliderFolder.AnchorPoint = Vector2.new(0.5,0.5)
				SliderFolder.GroupTransparency = 1
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
				if CurrentSliderMulti < 0.1 then
					CurrentSliderMulti = 0.1
				end
				local Delayed = (tick() - Start) - HitObj.Time/1000
				local LengthPerBeat = CurrentSliderMulti*100
				local LengthPerSec = LengthPerBeat*(CurrentBPM/60)

				SliderTime = (((tonumber(ExtraData[4])*Slides)/LengthPerSec)/DefaultSliderMultiplier)


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
				FollowCircle.Size = UDim2.new(CircleSize/384/SLCanvasScale,0,CircleSize/384/SLCanvasScale,0)
				FollowCircle.Position = UDim2.new(0.5-(0.5-HitObj.Position.X/512)/SLCanvasScale,0,0.5-(0.5-HitObj.Position.Y/384)/SLCanvasScale,0)


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

				if SliderCurveType == "B" or SliderCurveType == "P"  then
					local NumberOfPoints = 20
					local NewCurvePoints = {}
					local isLinear = false

					local function lerp(a, b, c)
						return a + (b - a) * c
					end

					for i = 1,#SliderCurvePoints-1 do
						local a = SliderCurvePoints[i]
						local b = SliderCurvePoints[i+1]
						if Vector2.new(a.X,a.Y) == Vector2.new(b.X,b.Y) then
							isLinear = true
							break
						end
					end
					if not isLinear then
						local function GetBenzierPosition(t)
							local PointData = {}
							for _,a in pairs(SliderCurvePoints) do
								PointData[#PointData+1] = Vector2.new(a.X,a.Y)
							end
							local PointsLeft = #PointData
							for i = PointsLeft+1,3,-1 do
								local PointDataNew = {}
								for a = 1,PointsLeft-1 do
									PointDataNew[#PointDataNew+1] = Vector2.new(lerp(PointData[a].X,PointData[a+1].X,t),lerp(PointData[a].Y,PointData[a+1].Y,t))
								end
								PointData = PointDataNew
								PointsLeft-=1
							end
							return {X=PointData[1].X,Y=PointData[1].Y}
						end

						for i = 1,NumberOfPoints do
							NewCurvePoints[#NewCurvePoints+1] = GetBenzierPosition((i-1)/(NumberOfPoints-1))
						end
						SliderCurvePoints = NewCurvePoints
					else
						for i = 1,#SliderCurvePoints do
							local a = SliderCurvePoints[i]
							if i <= 1 then
								NewCurvePoints[#NewCurvePoints+1] = a
							else
								local b =  SliderCurvePoints[i-1]
								if a.X ~= b.X or a.Y ~= b.Y then
									NewCurvePoints[#NewCurvePoints+1] = a
								end
							end
						end

						SliderCurvePoints = NewCurvePoints
					end
				end




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

						--print(UpDirection,isReverse)

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
						--print(NewPoints)
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
					ReverseArrow.Size = UDim2.new((CircleSize*0.6)/384/SLCanvasScale,0,(CircleSize*0.6)/384/SLCanvasScale,0)
					ReverseArrow.Position = UDim2.new(0.5-(0.5-Data[1].X/512)/SLCanvasScale,0,0.5-(0.5-Data[1].Y/384)/SLCanvasScale,0)
					ReverseArrow.Rotation = Data[2]+180

					ReverseArrowObject[i] = ReverseArrow
				end



				local SliderLength = 0
				local SliderConnections = {}
				local LengthData = {0}

				for i,a in pairs(SliderCurvePoints) do
					if i ~= #SliderCurvePoints then
						local NextCurvePointPos = SliderCurvePoints[i+1]
						local Point1st = Vector2.new(a.X,a.Y)
						local Point2nd = Vector2.new(NextCurvePointPos.X,NextCurvePointPos.Y)
						local Point3rd = Vector2.new(a.Y,NextCurvePointPos.X)
						local Length = (Point1st-Point2nd).magnitude
						SliderLength = SliderLength + Length
						LengthData[i+1] = SliderLength
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
					HoldCircle.Position = UDim2.new(0.5-(0.5-Data.Pos.X/512)/SLCanvasScale,0,0.5-(0.5-Data.Pos.Y/384)/SLCanvasScale,0)
					HoldCircle.Rotation = Data.Rotation
					HoldCircle.Size = UDim2.new(((Data.Length)/512/SLCanvasScale),0,(CircleSize/384-0.026)/SLCanvasScale,0)
					HoldCircle.BackgroundColor3 = Color3.new(0,0,0)
					HoldCircle.ZIndex = ZIndex-2
					HoldCircle.UICorner:Destroy()
					--TweenService:Create(HoldCircle,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.new(0.133333, 0.133333, 0.133333)}):Play()
					local Outline = HoldCircle:Clone()
					Outline.Name = tostring((i/#SliderConnections)*0.25)
					Outline.Size = UDim2.new(((Data.Length)/512/SLCanvasScale),0,CircleSize/384/SLCanvasScale,0)
					Outline.Parent = SliderFolder
					Outline.ZIndex = ZIndex-3
					Outline.BackgroundColor3 = Color3.new(0,0,0)
					--TweenService:Create(Outline,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.new(0.584314, 0.584314, 0.584314)}):Play()
					HoldCircle.BackgroundColor3 = Color3.new(0.133333, 0.133333, 0.133333)
					Outline.BackgroundColor3 = Color3.new(0.584314, 0.584314, 0.584314)
					ProcessFunction(function()
						if true then return end
						HoldCircle.Visible = false
						Outline.Visible = false
						local SliderPoint = SliderCurvePoints[i]
						HoldCircle.Position = UDim2.new(SliderPoint.X/5120,0,SliderPoint.Y/3840,0)
						HoldCircle.Size = UDim2.new(0,0,CircleSize/384-0.026,0)
						Outline.Position = UDim2.new(SliderPoint.X/5120,0,SliderPoint.Y/3840,0)
						Outline.Size = UDim2.new(0,0,CircleSize/3840,0)
						local LengthData = LengthData[i]
						local MoveTime = Data.Length/SliderLength*CircleApproachTime*0.5/1000
						repeat wait() until (tick() - Start)*1000 >=  HitObj.Time - ((SliderLength-LengthData)/SliderLength*CircleApproachTime*0.5 + CircleApproachTime*0.5)
						--TweenService:Create(HoldCircle,TweenInfo.new(MoveTime,Enum.EasingStyle.Linear),{Position = UDim2.new(Data.Pos.X/512,0,Data.Pos.Y/384,0),Size = UDim2.new(((Data.Length)/512),0,CircleSize/384-0.026,0)}):Play()
						--TweenService:Create(Outline,TweenInfo.new(MoveTime,Enum.EasingStyle.Linear),{Position = UDim2.new(Data.Pos.X/512,0,Data.Pos.Y/384,0),Size = UDim2.new(((Data.Length)/512),0,CircleSize/384,0)}):Play()
						HoldCircle.Visible = true
						Outline.Visible = true
					end)
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
					HoldCircle.Position = UDim2.new(0.5-(0.5-SliderPoint.X/512)/SLCanvasScale,0,0.5-(0.5-SliderPoint.Y/384)/SLCanvasScale,0)
					HoldCircle.Size = UDim2.new((CircleSize/384-0.026)/SLCanvasScale,0,(CircleSize/384-0.026)/SLCanvasScale,0)
					HoldCircle.SizeConstraint = Enum.SizeConstraint.RelativeYY
					HoldCircle.ZIndex = ZIndex-1
					--TweenService:Create(HoldCircle,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.new(0.133333, 0.133333, 0.133333)}):Play()
					local Outline = HoldCircle:Clone()
					Outline.Name = tostring((i/#SliderCurvePoints)*0.25)
					Outline.Size = UDim2.new((CircleSize/384)/SLCanvasScale,0,(CircleSize/384)/SLCanvasScale,0)
					Outline.Parent = SliderFolder
					Outline.ZIndex = ZIndex-3
					Outline.BackgroundColor3 = Color3.new(0,0,0)
					--TweenService:Create(Outline,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.new(0.584314, 0.584314, 0.584314)}):Play()
					HoldCircle.BackgroundColor3 = Color3.new(0.133333, 0.133333, 0.133333)
					Outline.BackgroundColor3 = Color3.new(0.584314, 0.584314, 0.584314)
					ProcessFunction(function()
						if true then return end
						HoldCircle.Visible = false
						Outline.Visible = false
						local LengthData = LengthData[i]
						repeat wait() until (tick() - Start)*1000 >=  HitObj.Time - ((SliderLength-LengthData)/SliderLength*CircleApproachTime*0.5 + CircleApproachTime*0.5)
						HoldCircle.Visible = true
						Outline.Visible = true
					end)
				end


				TweenService:Create(SliderFolder,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{GroupTransparency = 0.2}):Play()
				if HiddenMod then
					ProcessFunction(function()
						local FadeTime = SliderTime*0.75
						if FadeTime <= 0.25 then
							FadeTime = 0.25
						end
						repeat wait() until tick() - Start >= HitObj.Time/1000
						TweenService:Create(SliderFolder,TweenInfo.new(FadeTime,Enum.EasingStyle.Linear),{GroupTransparency = 1}):Play()						
					end)
				end
				ZIndex -= 3
				local Completed = false
				local LastComboTime = 0
				local NextComboTime = 0
				local LastHold = 0
				local InSliderTickRequired = 0
				local function isInFollowCircle()
					local FollowCirclePos = Vector2.new((0.5-(0.5-FollowCircle.Position.X.Scale)*SLCanvasScale)*512,(0.5-(0.5-FollowCircle.Position.Y.Scale)*SLCanvasScale)*384)
					local CursorPos = CursorPosition --Vector2.new(Cursor.Position.X.Scale*512,Cursor.Position.Y.Scale*384)
					local Distance = math.abs((FollowCirclePos-CursorPos).magnitude)
					if Distance <= (CircleSize/2)*2.5 then
						return true
					else
						return false
					end
				end
				ProcessFunction(function()
					if Slides > 1 then
						TweenService:Create(ReverseArrowObject[1],TweenInfo.new(0.25,Enum.EasingStyle.Linear),{ImageTransparency = 0}):Play()
						TweenService:Create(ReverseArrowObject[1],TweenInfo.new((30/BPM)-0.05,Enum.EasingStyle.Sine,Enum.EasingDirection.In,math.huge,true,0.1),{Size = UDim2.new((CircleSize/384*0.9/SLCanvasScale),0,(CircleSize/384*0.9/SLCanvasScale),0)}):Play()
					end
					repeat wait() until (tick() - Start) >= HitObj.Time/1000 and SliderTime ~= -1
					if AutoPlay == true and ReplayMode ~= true then
						--MouseHitEvent:Fire(SecurityKey,SliderATKey)
					end
					local TotalDuration = 0
					local TimePerBeat = 60/CurrentBPM
					local MaxTick = math.floor(SliderTime/TimePerBeat*ReturnData.Difficulty.SliderTickRate)-1
					local TickTime = (60/CurrentBPM)/ReturnData.Difficulty.SliderTickRate
					local StartComboTime = Start + HitObj.Time/1000
					LastComboTime = Start + HitObj.Time/1000
					ProcessFunction(function()
						for CurrentTick = 1,MaxTick do
							local Next = StartComboTime + TickTime * CurrentTick
							repeat wait() until tick() >= Next
							if Completed then break end
							if math.abs(Next - LastComboTime) > 0.1/SongSpeed and math.abs(Next - NextComboTime) > 0.1 then
								InSliderTickRequired += 1
								if (isInFollowCircle() == true and script.Parent.KeyDown.Value == true) or tick() - LastHold < 0.1 then
									if i ~= Slides then
										Score += 10
										TotalScoreEstimated += 10
									end
									Accurancy.Combo+=1
									EstimatedCombo += 1
									TickCollected += 1
									AddHP(0.5)
									if Accurancy.Combo > Accurancy.MaxCombo then
										Accurancy.MaxCombo = Accurancy.Combo
									end
									CreateHitSound(5)
								else
									if Accurancy.Combo >= 20 then
										script.Parent.ComboBreak:Play()
									end
									Accurancy.Combo = 0
									EstimatedCombo += 1
									Accurancy.PerfomanceCombo = 0
									Missed = true
									DrainHP(MissDrain/4)
								end
							end
						end
					end)
					FollowCircle.Visible = true
					for CurrentSlide = 1,Slides do
						if Completed == true then
							break
						end
						if CurrentSlide > 1 then
							ProcessFunction(function()
								TweenService:Create(ReverseArrowObject[CurrentSlide-1],TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1,Size = UDim2.new(CircleSize*1.5/384/SLCanvasScale,0,CircleSize*1.5/384/SLCanvasScale,0)}):Play()
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
									game:GetService("TweenService"):Create(FollowCircle,TweenInfo.new(SliderPointDuration,Enum.EasingStyle.Linear),{Position = UDim2.new(0.5-(0.5-SliderCurvePoints[i].X/512)/SLCanvasScale,0,0.5-(0.5-SliderCurvePoints[i].Y/384)/SLCanvasScale,0)}):Play()
									ProcessFunction(function()
										if AutoPlay == true and ReplayMode ~= true then
											if IsHitted == false then
												repeat wait() until IsHitted == true
											end
											if not Completed then
												game:GetService("TweenService"):Create(ATVC,TweenInfo.new(SliderPointDuration,Enum.EasingStyle.Linear),{Position = UDim2.new(0.5-(0.5-SliderCurvePoints[i].X/512)/1,0,0.5-(0.5-SliderCurvePoints[i].Y/384)/1,0)}):Play()
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
									game:GetService("TweenService"):Create(FollowCircle,TweenInfo.new(SliderPointDuration,Enum.EasingStyle.Linear),{Position = UDim2.new(0.5-(0.5-SliderCurvePoints[#SliderCurvePoints-i+1].X/512)/SLCanvasScale,0,0.5-(0.5-SliderCurvePoints[#SliderCurvePoints-i+1].Y/384)/SLCanvasScale,0)}):Play()
									spawn(function()
										if AutoPlay == true and ReplayMode ~= true then
											if IsHitted == false then
												repeat wait() until IsHitted == true
											end
											if not Completed then
												game:GetService("TweenService"):Create(ATVC,TweenInfo.new(SliderPointDuration,Enum.EasingStyle.Linear),{Position = UDim2.new(0.5-(0.5-SliderCurvePoints[#SliderCurvePoints-i+1].X/512)/1,0,0.5-(0.5-SliderCurvePoints[#SliderCurvePoints-i+1].Y/384),0)}):Play()
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
					if AutoPlay == true then
						MouseHitEndEvent:Fire(SecurityKey,SliderATKey)
					end
				end)





				ProcessFunction(function()
					if (tick() - Start) < HitObj.Time/1000 or SliderTime == -1 then
						repeat wait() until (tick() - Start) >= HitObj.Time/1000 and SliderTime ~= -1
					end
					ProcessFunction(function()
						while wait() and not Completed do
							if isInFollowCircle() == true and script.Parent.KeyDown.Value == true then
								if not script.Parent.PlayFrame.Flashlight.SliderDim.isDim.Value then
									script.Parent.PlayFrame.Flashlight.SliderDim.isDim.Value = true
									TweenService:Create(script.Parent.PlayFrame.Flashlight.SliderDim,TweenInfo.new(0.05,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.2}):Play()
								end
								if FollowCircle:FindFirstChild("isFollow") then
									FollowCircle.isFollow.Visible = true
								end
								LastHold = tick()
							else
								if script.Parent.PlayFrame.Flashlight.SliderDim.isDim.Value then
									script.Parent.PlayFrame.Flashlight.SliderDim.isDim.Value = false
									TweenService:Create(script.Parent.PlayFrame.Flashlight.SliderDim,TweenInfo.new(0.05,Enum.EasingStyle.Linear),{BackgroundTransparency = 1}):Play()
								end
								if FollowCircle:FindFirstChild("isFollow") then
									FollowCircle.isFollow.Visible = false
								end
							end
						end
					end)

					ProcessFunction(function()

						for i = 1,Slides do
							NextComboTime = HitObj.Time/1000 + SliderTime/Slides*i
							if tick() - Start < HitObj.Time/1000 + SliderTime/Slides*i then
								repeat wait() until tick() - Start >= HitObj.Time/1000 + SliderTime/Slides*i
							end
							LastComboTime = HitObj.Time/1000 + SliderTime/Slides*i
							--wait(SliderTime/Slides)
							if Completed == true then
								break
							end

							if (isInFollowCircle() == true and script.Parent.KeyDown.Value == true) or i ~= Slides or tick() - LastHold < 0.1 then
								if (isInFollowCircle() == true and script.Parent.KeyDown.Value == true) or tick() - LastHold < 0.1 then
									if i ~= Slides then
										Score += 30
										TotalScoreEstimated += 30
									end
									Accurancy.Combo+=1
									EstimatedCombo += 1
									TickCollected += 1
									AddHP(1.6)
									if Accurancy.Combo > Accurancy.MaxCombo then
										Accurancy.MaxCombo = Accurancy.Combo
									end
									if i < Slides then
										CreateHitSound(0,NoteNormalSampleSet)
									else
										local HitSoundType = tonumber(HitObj.ExtraData[1])
										CreateHitSound(0,NoteNormalSampleSet) -- normal
										if HitSoundType == 2 or HitSoundType == 14 or HitSoundType == 6 or HitSoundType == 10 then
											CreateHitSound(2,NoteAditionSampleSet) -- whistle
										end
										if HitSoundType == 4 or HitSoundType == 14 or HitSoundType == 6 or HitSoundType == 12 then
											CreateHitSound(1,NoteAditionSampleSet) -- finish
										end
										if HitSoundType == 8 or HitSoundType == 14 or HitSoundType == 10 or HitSoundType == 12 then
											CreateHitSound(3,NoteAditionSampleSet) -- clap
											if NoteAditionSampleSet ~= "3" then
												CreateHitSound(4,NoteAditionSampleSet) -- clap2
											end
										end
									end
								else
									DrainHP(MissDrain/2)
								end
							elseif i < Slides then
								if Accurancy.Combo >= 20 then
									script.Parent.ComboBreak:Play()
								end
								Accurancy.Combo = 0
								EstimatedCombo += 1
								Accurancy.PerfomanceCombo = 0
								Missed = true
								AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,0)
								DrainHP(MissDrain/2)
							end
						end
						-----------------
						local TickRequired = Slides+1+InSliderTickRequired
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
							MissedInCurrentTime = true
							AddScore(0)
							DrainHP(MissDrain/2)
							CreateSliderHitResult(1,SliderCurvePoints[#SliderCurvePoints])
							Accurancy.Combo = 0
							EstimatedCombo += 1
							Accurancy.PerfomanceCombo = 0
							Missed = true
							AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,0)
							if Accurancy.Combo >= 20 then
								script.Parent.ComboBreak:Play()
							end
						end
						CurrentCursorPos = HitNoteID + 1
						Completed = true
						local FollowCircle = SliderFolder.SliderFollowCircle
						if script.Parent.PlayFrame.Flashlight.SliderDim.isDim.Value then
							script.Parent.PlayFrame.Flashlight.SliderDim.isDim.Value = false
							TweenService:Create(script.Parent.PlayFrame.Flashlight.SliderDim,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{BackgroundTransparency = 1}):Play()
						end
						if not OptimizedPerfomance then
							--FollowCircle.Parent = script.Parent.PlayFrame
							TweenService:Create(SliderFolder,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{GroupTransparency = 1}):Play()
							--SliderFolder:Destroy()
							TweenService:Create(FollowCircle.isFollow,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Size = UDim2.new(2,0,2,0),ImageTransparency = 1}):Play()
							FollowCircle.isFollow.Visible = tick() - LastHold <= 0.1
							FollowCircle.SliderFollowCircle:Destroy()
							wait(0.25)
						else
							FollowCircle.SliderFollowCircle:Destroy()
						end
						SliderFolder:Destroy()
						FollowCircle:Destroy()
					end)
				end)
			end

			---------------------------------------------------------------------------------------------------------





			local FixedApproachTime = -((tick()-Start)*1000 - HitObj.Time)
			if FixedApproachTime < 0 then
				FixedApproachTime = 0
			end
			if FixedApproachTime >= 10000 then
				repeat wait() FixedApproachTime = -((tick()-Start)*1000 - HitObj.Time) until FixedApproachTime < 10000
			end
			local ApproachSize = (1-(CircleApproachTime-FixedApproachTime)/CircleApproachTime)*3 + 1.1

			if ApproachSize > 4.1 then
				ApproachSize = 4.1
			end

			Circle.ApproachCircle.Size = UDim2.new(ApproachSize,0,ApproachSize,0)
			local ApproachCircleTween = game:GetService("TweenService"):Create(Circle.ApproachCircle,TweenInfo.new(FixedApproachTime/1000,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Size = UDim2.new(1.1,0,1.1,0)})
			AddHitnoteAnimation(ApproachCircleTween)
			ApproachCircleTween:Play()
			ProcessFunction(function()
				while not IsHitted do
					script.Parent.GameplayPause.Event:Wait()
					ApproachCircleTween:Pause()
					script.Parent.GameplayResume.Event:Wait()
					if IsHitted then break end
					local FixedApproachTime = -((tick()-Start)*1000 - HitObj.Time)
					local ApproachSize = (1-(CircleApproachTime-FixedApproachTime)/CircleApproachTime)*3 + 1.1
					Circle.ApproachCircle.Size = UDim2.new(ApproachSize,0,ApproachSize,0)
					local ApproachCircleTween = game:GetService("TweenService"):Create(Circle.ApproachCircle,TweenInfo.new(FixedApproachTime/1000,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Size = UDim2.new(
						)})
					AddHitnoteAnimation(ApproachCircleTween)
					ApproachCircleTween:Play()
				end
			end)



			local CircleHitConnection = false

			ProcessFunction(function()
				if true then return end --not alvaiable
				repeat wait() until CurrentHitnote == HitNoteID or (tick()-Start) >= ((HitObj.Time+hit50)/1000)
				if (tick()-Start) >= ((HitObj.Time+hit50)/1000)  then
					return --skip
				end
				TweenService:Create(script.Parent.CursorField.AimAssitTarget,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0)}):Play()
			end)

			ProcessFunction(function()
				if (HitObj.Time/1000) - (tick()-Start) > 0 then -- prevent high delay
					wait((HitObj.Time/1000) - (tick()-Start))
					if tick() - Start < 10000 then
						repeat wait() until (tick()-Start) >= (HitObj.Time/1000)
					end
				end
				if IsHitted == false and not BeatmapFailed then
					Circle.ApproachCircle.Visible = false
					if Type ~= 2 or not SliderMode then
						if ((HitObj.Time+hit50)/1000) - (tick()-Start) > 0 then
							wait(((HitObj.Time+hit50)/1000) - (tick()-Start))
							if tick() - Start < 10000 then
								repeat wait() until (tick()-Start) >= ((HitObj.Time+hit50)/1000) 
							end
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
									if Object.Name == "CircleNumber" then
										for _,a in pairs(Object:GetChildren()) do 
											if a:IsA("ImageLabel") then
												AddHitnoteAnimation(game:GetService("TweenService"):Create(a,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1})):Play()
											end
										end
									end
								end)
							end
						end)
						Circle.Visible = false
						local SliderHitTime = SliderTime/tonumber(HitObj.ExtraData[3])
						if SliderHitTime > hit50/1000 then
							SliderHitTime = hit50/1000
						elseif SliderHitTime <= hit300/1000 then
							SliderHitTime = hit300/1000
						end
						if ((HitObj.Time+SliderHitTime*1000)/1000) - (tick()-Start) > 0 then
							wait(((HitObj.Time+SliderHitTime*1000)/1000) - (tick()-Start))
						end
					end
					if IsHitted == false then
						if CircleHitConnection then
							CircleHitConnection:Disconnect()
						end
						IsHitted = true
						if Accurancy.Combo >= 20 then
							script.Parent.ComboBreak:Play()
						end
						Accurancy.Combo = 0
						EstimatedCombo += 1
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
							MissedInCurrentTime = true
							AddScore(0)
							HitMiss = true
							CreateHitResult(1)
						end
						ProcessFunction(function()
							if not OptimizedPerfomance then
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
										if Object.Name == "CircleNumber" then
											for _,a in pairs(Object:GetChildren()) do 
												if a:IsA("ImageLabel") then
													game:GetService("TweenService"):Create(a,TweenInfo.new(0.2,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
												end
											end
										end
									end)
								end
								wait(0.5)
							end
							Circle:Destroy()
						end)

						DisplayingHitnote[HitNoteID] = nil
					end
					if CircleHitConnection then
						CircleHitConnection:Disconnect()
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

			CircleHitConnection = MouseHitEvent.Event:Connect(function(CurrentSecurityKey)
				if CurrentSecurityKey ~= SecurityKey then
					return "no"
				end
				local CurrentTime = (tick()-Start)*1000
				local HitDelay = CurrentTime - HitObj.Time
				--[[
				local CurrentHitNotePos = BeatmapData[CurrentHitnote].Position
				local Distance = math.abs((Vector2.new(CurrentHitNotePos.X,CurrentHitNotePos.Y) - Vector2.new(HitObj.Position.X,HitObj.Position.Y)).Magnitude)
				spawn(function()
					if isincircle() and IsHitted == false and ((CurrentHitnote ~= HitNoteID and Distance > CircleSize) or HitDelay < -EarlyMiss) then -- rip notelock
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
				if IsHitted == false then
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
							elseif data.Id < HitNoteID and not data.IsHitted == true then
								PrevNoteExist = true
							end
						end

						if isTop == false then
							-- this note will auto miss as the newer obj get hitted inside h50 window

							IsHitted = true
							if Accurancy.Combo >= 20 then
								script.Parent.ComboBreak:Play()
							end
							Accurancy.Combo = 0
							EstimatedCombo += 1
							Accurancy.PerfomanceCombo = 0
							Missed = true
							if Type ~= 2 or SliderMode == false then
								Accurancy.miss += 1
								MissedInCurrentTime = true
								AddScore(0)
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
								if data.Id < HitNoteID and isinPosition(data.X,data.Y) and not data.IsHitted == true then
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

						IsHitted = true
						DisplayingHitnote[HitNoteID].IsHitted = true
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
							EstimatedCombo += 1
							Accurancy.PerfomanceCombo = 0
							Missed = true
							DrainHP(MissDrain)
							CreateHitDelay(Color3.new(1, 0.372549, 0.372549),HitDelay)
							ComboNoteData.Missor50 = true
							ComboNoteData.Full300 = false
							if Type ~= 2 or SliderMode == false then
								Accurancy.miss += 1
								MissedInCurrentTime = true
								AddScore(0)
								CreateHitResult(1)
								AddPerfomanceScore(HitObj.PSValue.Aim,HitObj.PSValue.Stream,0)
							end
							HitMiss = true
							Circle.ApproachCircle:Destroy()
							Circle:Destroy()
						else
							Circle.ApproachCircle:Destroy()
							Accurancy.Combo += 1
							EstimatedCombo += 1
							TickCollected += 1
							if Accurancy.Combo > Accurancy.MaxCombo then
								Accurancy.MaxCombo = Accurancy.Combo
							end
							ProcessFunction(function()
								local HitSoundType = tonumber(HitObj.ExtraData[1])
								CreateHitSound(0,NoteNormalSampleSet) -- normal
								if HitSoundType == 2 or HitSoundType == 14 or HitSoundType == 6 or HitSoundType == 10 then
									CreateHitSound(2,NoteAditionSampleSet) -- whistle
								end
								if HitSoundType == 4 or HitSoundType == 14 or HitSoundType == 6 or HitSoundType == 12 then
									CreateHitSound(1,NoteAditionSampleSet) -- finish
								end
								if HitSoundType == 8 or HitSoundType == 14 or HitSoundType == 10 or HitSoundType == 12 then
									CreateHitSound(3,NoteAditionSampleSet) -- clap
									if NoteAditionSampleSet ~= "3" then
										CreateHitSound(4,NoteAditionSampleSet) -- clap2
									end
								end
							end)
							if Type ~= 2 or SliderMode == false then
								Accurancy.PerfomanceCombo += 1 
								if Accurancy.PerfomanceCombo > Accurancy.MaxPeromanceCombo then
									Accurancy.MaxPeromanceCombo = Accurancy.PerfomanceCombo
								end
								local HitErrorGraph = Accurancy.HitErrorGraph
								for i,Data in pairs(HitErrorGraph) do
									if HitDelay > Data[1] and  HitDelay <= Data[2] then
										HitErrorGraph[i][3] += 1
										break
									end
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
								TotalScoreEstimated += 30
								if math.abs(HitDelay) < hit300 then
									CreateHitDelay(Color3.new(0.686275, 1, 1),HitDelay)
								elseif math.abs(HitDelay) < hit100 then
									CreateHitDelay(Color3.new(0.686275, 1, 0.686275),HitDelay)
								else
									CreateHitDelay(Color3.new(1, 1, 0.686275),HitDelay)
								end
							end

							if not OptimizedPerfomance then
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
										if Object.Name == "CircleNumber" then
											for _,a in pairs(Object:GetChildren()) do 
												if a:IsA("ImageLabel") then
													game:GetService("TweenService"):Create(a,TweenInfo.new(0,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
												end
											end
										end
									end)
								end
								wait(0.25)
							end
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


function doAnim()
	script.Parent.Interface.Background.Visible = true
	script.Parent.Interface.Background.BackgroundImage.Image = "http://www.roblox.com/asset/?id="..ReturnData.ImageId
	TweenService:Create(script.Parent.Interface.Background,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{GroupTransparency = 0}):Play()
end

if isSpectating == false then
	repeat wait() until tick() - Start > (BeatmapData[#BeatmapData].Time + hit50)/1000

	local Type = BeatmapData[#BeatmapData].Type


	if Type == 8 or Type == 12 or math.floor((Type-28)/16) == (Type-28)/161 then
		repeat wait() until (tick()-Start) >= BeatmapData[#BeatmapData].SpinTime/1000
		spawn(function()
			TweenService:Create(script.Parent.ProgressBar,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Size = UDim2.new(0,4,0,4)}):Play()
			wait(1.1)
			TweenService:Create(script.Parent.ProgressBar,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Position = UDim2.new(1,-10,0,-5)}):Play()
		end)
		TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.4}):Play()
		script.Parent.Leaderboard.LbTrigger:Fire(true)
		script.Parent.MultiplayerLeaderboard.LbTrigger:Fire(true)
		FLAnimate = false
		TweenService:Create(FlashlightFrame,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = UDim2.new(30,0,30,0),ImageTransparency = 0}):Play()
		doAnim()
		wait(2)
	else
		repeat wait() until LastNoteData ~= "NotLoaded"
		if LastNoteData.Slider == true then
			wait(LastNoteData.SliderTime)
		end
		spawn(function()
			TweenService:Create(script.Parent.ProgressBar,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Size = UDim2.new(0,4,0,4)}):Play()
			wait(1.1)
			TweenService:Create(script.Parent.ProgressBar,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Position = UDim2.new(1,-10,0,-5)}):Play()
		end)
		TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.4}):Play()
		script.Parent.Leaderboard.LbTrigger:Fire(true)
		script.Parent.MultiplayerLeaderboard.LbTrigger:Fire(true)
		FLAnimate = false
		TweenService:Create(FlashlightFrame,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = UDim2.new(30,0,30,0),ImageTransparency = 0}):Play()
		doAnim()
		wait(2)
	end
else
	repeat wait() until ScoreResultDisplay == true
	FLAnimate = false
	TweenService:Create(FlashlightFrame,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = UDim2.new(30,0,30,0),ImageTransparency = 0}):Play()
	TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.4}):Play()
	script.Parent.Leaderboard.LbTrigger:Fire(true)
	script.Parent.MultiplayerLeaderboard.LbTrigger:Fire(true)
end

if OnMultiplayer then
	script.Parent.MultiplayerWaitFrame.Visible = true
	game.Players.LocalPlayer.PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.MultiplayerFolder.Value.WaitForFinish:InvokeServer()
	script.Parent.MultiplayerWaitFrame.Visible = false
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
--TweenService:Create(script.Parent.Interface.BG,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true),{BackgroundTransparency = 0}):Play()
wait(0.25)
script.Parent.Interface.Background.Visible = false



CursorUnlocked = true
UserInputService.MouseBehavior = Enum.MouseBehavior.Default
Cursor.Visible = false
RblxNewCursor.Visible = true


local ResultFrame = game.Players.LocalPlayer.PlayerGui.BG.ResultFrame.MainFrame.DisplayFrame
ResultFrame.Parent.Parent.Parent.ResultScreenOptions.Visible = true
TweenService:Create(ResultFrame.Parent.Parent.Parent.ResultScreenOptions,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Position = UDim2.new(0.5,0,0.5,0)}):Play()
TweenService:Create(ResultFrame.Parent.Parent,TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{GroupTransparency = 0}):Play()
TweenService:Create(ResultFrame.Parent.Parent,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{Size = UDim2.new(1,-86,1,-86)}):Play()
TweenService:Create(ResultFrame.Parent.Parent.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Transparency = 0.4}):Play()

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
if tostringAcc == "nan" or tostringAcc == "inf" or tostringAcc == "100" then
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
script.Parent.HitKey.Visible = false
script.Parent.PSEarned.Visible = false
script.Parent.HealthBar.Visible = false
script.Parent.Leaderboard.Visible = false
script.Parent.RestartGame.Visible = false

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,true)

----------- Calculate perfomance score -----------

RewaredAccPS = MaxAccurancyPS* 0.727^(100-tonumber(RawAccurancy)) -- get whole accurancy
RewaredAimPS = 0
RewaredStreamPS = 0
RewaredOverallPS = 0

for Top,AimPS in pairs(AimPSList) do
	RewaredAimPS += AimPS*0.8^(Top-1)
end
for Top,StreamPS in pairs(StreamPSList) do
	RewaredStreamPS += StreamPS*0.8^(Top-1)
end
for Top,Overall in pairs(OverallPSList) do
	RewaredOverallPS += Overall*0.8^(Top-1)
end
local ComboPerfomanceMultiplier = 1 --1*0.25^((1-(Accurancy.MaxPeromanceCombo/GameMaxCombo))*2)
local BonusFLMultiplier = (NoteCompleted*0.00035)
if not Flashlight then
	BonusFLMultiplier = 0
elseif NoteCompleted > 1000 then
	--BonusFLMultiplier = 0.7
end
BonusFLMultiplier *= (Score/TotalScoreEstimated)
AccAimPS = RewaredAimPS *  ComboPerfomanceMultiplier * (1+BonusFLMultiplier) * (NoteCompleted/NoteTotal)
AccStreamPS = RewaredStreamPS * ComboPerfomanceMultiplier * (NoteCompleted/NoteTotal)
AccOverallPS = RewaredOverallPS * 0.1 * (NoteCompleted/NoteTotal)

RewaredAimPS = RewaredAimPS * (1 - (PSPunishment/PSPunishmentLimit)) * ComboPerfomanceMultiplier * (1+BonusFLMultiplier) * (NoteCompleted/NoteTotal)
RewaredStreamPS = RewaredStreamPS * (1 - (PSPunishment/PSPunishmentLimit)) * ComboPerfomanceMultiplier * (NoteCompleted/NoteTotal)
RewaredOverallPS = RewaredOverallPS * 0.1 * (NoteCompleted/NoteTotal) * (1 - (PSPunishment/PSPunishmentLimit))


RewaredAccPS += (AccAimPS+AccStreamPS+AccOverallPS) * 0.2 * 0.727^(100-tonumber(RawAccurancy)) 

--local TotalRewardedPS = RewaredAccPS + RewaredAimPS + RewaredStreamPS -- This will be needed for golbal ranking
local TotalRewardedPS = RewaredAccPS + (RewaredAimPS +RewaredStreamPS+RewaredOverallPS) * 0.8

if Flashlight == true then TotalRewardedPS *= 1.00 end -- 1
if HiddenMod == true then TotalRewardedPS *= 1.04 end  -- 1.08
if HardRock == true then TotalRewardedPS *= 1.2 end    -- 1.45
if HardCore == true then TotalRewardedPS *= 1.05 end   -- 1.11
if EasyMod == true then TotalRewardedPS *= 0.87 end    -- 0.75

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


MetaData = ReturnData.Overview.Metadata
OnlineResult = ResultFrame.Parent.OnlineDisplayFrame


if ScoreV2Enabled then
	ResultFrame.Score.Text = "Score: <b>"..GetNewNum(tostring(math.floor(Score/TotalScoreEstimated*1000000))).." ["..GetNewNum(tostring(math.floor(Score))).."]</b>"
else
	ResultFrame.Score.Text = "Score: <b>"..GetNewNum(tostring(math.floor(Score))).."</b>"	
end
ResultFrame.Grade.Text = (not SS and GameplayRank) or "S"
ResultFrame.Grade.TextColor3 = RankColor[GameplayRank]
SubmitTime = os.date("*t")
DisplaySubmitTime = "Played on "..SubmitTime.day.."/"..SubmitTime.month.."/"..SubmitTime.year.." "..SubmitTime.hour..":"..string.rep("0",2-#tostring(SubmitTime.min))..SubmitTime.min..":"..string.rep("0",2-#tostring(SubmitTime.sec))..SubmitTime.sec
DisplayModPlayed = (function()
	local ModDisplay = " | "
	local isMod = EasyMod or HardRock or HardCore or HiddenMod or Flashlight or SliderMode or AutoPlay or ScoreV2Enabled 
	if isMod then
		ModDisplay = " | "..((AutoPlay and "AT") or "")..((ScoreV2Enabled and ",V2") or "")..((HardCore and ",HC") or "")
			..((HiddenMod and ",HD") or "")..((HardRock and ",HR") or "")..((EasyMod and ",EZ") or "")
			..((SliderMode and ",SL") or "")..((Flashlight and ",FL") or "")
		if string.find(ModDisplay," ,") then
			ModDisplay = " | "..string.sub(ModDisplay,5,#ModDisplay)
		end
		return ModDisplay
	else
		return ""
	end
end)()

CombineDisplay = DisplaySubmitTime..DisplayModPlayed
ResultFrame.Parent.Parent.DetailedDate.Text = CombineDisplay
ResultFrame.Parent.Parent.DetailedInfo.Text = "Beatmap: "..MetaData.SongCreator.." - "..MetaData.MapName.." | ["..MetaData.DifficultyName.."] // "..MetaData.BeatmapCreator.." | "..tostring(SongSpeed).."x"
ResultFrame.Display_SS.Visible = SS and not (HiddenMod or Flashlight)
ResultFrame.Display_SSH.Visible = SS and (HiddenMod or Flashlight)

if (GameplayRank == "S" or SS) and (HiddenMod or Flashlight) then
	ResultFrame.Grade.TextColor3 = Color3.fromRGB(177,177,177)
end

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
	ChartFrame.ConnectionFrame.Size = UDim2.new(0,0,0,2)
	ChartFrame.GraphFrame.Position =  UDim2.new(1,0,1-Accurancy[1],0)
	ChartFrame.GraphFrame.Size = UDim2.new(1,0,1,0)
	ChartFrame.GraphFrame.AnchorPoint = Vector2.new(1,0)
	ChartFrame.GraphFrame.Visible = true
	--ChartFrame.GraphFrame.Size = UDim2.new(1,0,1-Accurancy[1],0)
	ChartFrame.GraphFrame.BackgroundTransparency = 1
	ChartFrame.GraphFrame.BackgroundColor3 = RankColor[Accurancy[2]]
	ChartFrame.Miss.Visible = Accurancy[3]
	LastDataAccuracy = Accurancy[1]
	FrameList[i] = ChartFrame
end

for i,ChartFrame in pairs(FrameList) do
	if i ~= #FrameList then
		local function change(value)
			local NextPointPos = Vector2.new(FrameList[i+1].PointFrame.AbsolutePosition.X,FrameList[i+1].PointFrame.AbsolutePosition.Y)
			local CurrentPointPos = Vector2.new(ChartFrame.PointFrame.AbsolutePosition.X,ChartFrame.PointFrame.AbsolutePosition.Y)


			ChartFrame.ConnectionFrame.Visible = true
			local ConnectionLength = math.abs((NextPointPos-CurrentPointPos).Magnitude)
			local AvgPos = (FrameList[i+1].PointFrame.Position.Y.Scale+ChartFrame.PointFrame.Position.Y.Scale)/2
			local Point = NextPointPos-CurrentPointPos
			local Rotation = math.deg(math.atan2(Point.Y,Point.X))
			ProcessFunction(function()
				if value ~= 1 then
					wait(((i-1)/#FrameList)*3)
					if ChartFrame.Miss.Visible then
						TweenService:Create(ChartFrame.Miss,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.5}):Play()
					end
					TweenService:Create(ChartFrame.ConnectionFrame,TweenInfo.new((1/#FrameList)*3,Enum.EasingStyle.Linear),{Position = UDim2.new(0.5,0,AvgPos,0),Size = UDim2.new(0,ConnectionLength+2,0,2),Rotation = Rotation}):Play()
					TweenService:Create(ChartFrame.GraphFrame,TweenInfo.new((1/#FrameList)*3,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.9}):Play()
				else
					ChartFrame.ConnectionFrame.Size = UDim2.new(0,ConnectionLength+2,0,2)
					ChartFrame.ConnectionFrame.Rotation = Rotation
				end
			end)
		end

		change()
		
		ProcessFunction(function()
			wait(3)
			change(1)
			local currentpos = workspace.CurrentCamera.ViewportSize
			while wait(2) do
				if workspace.CurrentCamera.ViewportSize ~= currentpos then
					currentpos = workspace.CurrentCamera.ViewportSize
					change(1)
				end
			end
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
	ChartFrame.ConnectionFrame.Size = UDim2.new(0,0,0,2)
	--ChartFrame.GraphFrame.Visible = true
	--ChartFrame.GraphFrame.Size = UDim2.new(1,0,(PerfomanceScore/HighestPerfomance),0)
	ChartFrame.GraphFrame.BackgroundTransparency = 1
	ChartFrame.GraphFrame.Position =  UDim2.new(1,0,1-PerfomanceScore/HighestPerfomance,0)
	ChartFrame.GraphFrame.Size = UDim2.new(1,0,1,0)
	ChartFrame.GraphFrame.AnchorPoint = Vector2.new(1,0)
	ChartFrame.GraphFrame.Visible = true
	
	ChartFrame.ConnectionFrame.BackgroundColor3 = Color3.new(1, 1, 1)
	ChartFrame.GraphFrame.BackgroundColor3 = Color3.new(1, 1, 1)
	LastPerfomance = PerfomanceScore/HighestPerfomance
end

for i,ChartFrame in pairs(PerfomanceFrameList) do
	if i ~= #PerfomanceFrameList then
		local function change(value)
			local NextPointPos = Vector2.new(PerfomanceFrameList[i+1].PointFrame.AbsolutePosition.X,PerfomanceFrameList[i+1].PointFrame.AbsolutePosition.Y)
			local CurrentPointPos = Vector2.new(ChartFrame.PointFrame.AbsolutePosition.X,ChartFrame.PointFrame.AbsolutePosition.Y)


			ChartFrame.ConnectionFrame.Visible = true
			local ConnectionLength = math.abs((NextPointPos-CurrentPointPos).Magnitude)
			local AvgPos = (PerfomanceFrameList[i+1].PointFrame.Position.Y.Scale+ChartFrame.PointFrame.Position.Y.Scale)/2
			local Point = NextPointPos-CurrentPointPos
			local Rotation = math.deg(math.atan2(Point.Y,Point.X))

			spawn(function()
				if value ~= 1 then
					wait(((i-1)/#PerfomanceFrameList)*3)
					TweenService:Create(ChartFrame.ConnectionFrame,TweenInfo.new((1/#PerfomanceFrameList)*3,Enum.EasingStyle.Linear),{Position = UDim2.new(0.5,0,AvgPos,0),Size = UDim2.new(0,ConnectionLength+2,0,2),Rotation = Rotation}):Play()
					TweenService:Create(ChartFrame.GraphFrame,TweenInfo.new((1/#FrameList)*3,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.9}):Play()
				else
					ChartFrame.ConnectionFrame.Size = UDim2.new(0,ConnectionLength+2,0,2)
					ChartFrame.ConnectionFrame.Rotation = Rotation
				end
			end)
		end
		change()
		
		ProcessFunction(function()
			wait(3)
			change(1)
			local currentpos = workspace.CurrentCamera.ViewportSize
			while wait(2) do
				if workspace.CurrentCamera.ViewportSize ~= currentpos then
					currentpos = workspace.CurrentCamera.ViewportSize
					change(1)
				end
			end
		end)
		--[[
		ChartFrame.ConnectionFrame.Position = UDim2.new(0.5,0,AvgPos)
		ChartFrame.ConnectionFrame.Size = UDim2.new(0,ConnectionLength+2,0,2)
		ChartFrame.ConnectionFrame.Rotation = Rotation]]
	end
end
HighestHitErrorClick = 1
OffsetFrame = game.Players.LocalPlayer.PlayerGui.BG.ResultFrame.MainFrame.OffsetFrame

for _,a in pairs(Accurancy.HitErrorGraph) do
	if a[3] > HighestHitErrorClick then
		HighestHitErrorClick = a[3]
	end
end

for _,a in pairs(Accurancy.HitErrorGraph) do
	local Frame = script.OffsetFrame:Clone()
	Frame.Parent = OffsetFrame.MainFrame.MainFrame
	Frame.Size = UDim2.new(1/99,-2,a[3]/HighestHitErrorClick,0)
	Frame.LayoutOrder = a[4]
end

UnstableRate = math.round((TotalUnstableTime/(TotalHit-1))*10)
OffsetPositive = math.round(Accurancy.OffsetPositive.Value/Accurancy.OffsetPositive.Total)
OffsetNegative = math.round(Accurancy.OffsetNegative.Value/Accurancy.OffsetNegative.Total)
OffsetOverall = math.round(Accurancy.OffsetOverall.Value/Accurancy.OffsetOverall.Total)

OffsetFrame.MainFrame.DetailedDisplay.Text = "Unstable rate: "..tostring(UnstableRate).." | Error: "..tostring(OffsetNegative).."ms - "..tostring(OffsetPositive).."ms Avg | Overall Offset: "..tostring(OffsetOverall).."ms"

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
				HR = HardRock,
				EZ = EasyMod,
				AT = AutoPlay
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
		TweenService:Create(OnlineResult.OnlineScore.Improvement,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextColor3 = Color3.fromRGB(255,255,255)}):Play()
		TweenService:Create(OnlineResult.OnlineAccurancy.Improvement,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextColor3 = Color3.fromRGB(255,255,255)}):Play()
		TweenService:Create(OnlineResult.OnlineMaxCombo.Improvement,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextColor3 = Color3.fromRGB(255,255,255)}):Play()
		TweenService:Create(OnlineResult.OnlinePS.Improvement,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextColor3 = Color3.fromRGB(255,255,255)}):Play()
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
			TweenService:Create(OnlineResult.OnlineScore.Improvement,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			OnlineResult.OnlineScore.Improvement.Text = "+"..GetNewNum(RankedScore - OldScore)



			if TotalRewardedPS > OldPS then
				TweenService:Create(OnlineResult.OnlinePS,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,0)}):Play()
				TweenService:Create(OnlineResult.OnlinePS.Improvement,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextColor3 = Color3.fromRGB(255,255,255)}):Play()
				OnlineResult.OnlinePS.Improvement.Text = "+"..GetNewNum(math.floor(TotalRewardedPS - OldPS)).."ps"
			else
				OnlineResult.OnlinePS.Improvement.Text = "Best: "..GetNewNum(OldPS).."ps"
			end
		else
			OnlineResult.OnlineScore.Improvement.Text = "Best: "..GetNewNum(OldScore)
			OnlineResult.OnlinePS.Improvement.Text = "Best: "..tostring(OldPS).."ps"
		end

		local PBAccurancy = ReturnResult.ExtraData.Accurancy
		local Acc = tonumber(PBAccurancy)

		if tonumber(tostringAcc) > Acc then
			TweenService:Create(OnlineResult.OnlineAccurancy,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,0)}):Play()
			TweenService:Create(OnlineResult.OnlineAccurancy.Improvement,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			OnlineResult.OnlineAccurancy.Improvement.Text = "+"..tostring(tonumber(tostringAcc-Acc)).."%"
		else
			OnlineResult.OnlineAccurancy.Improvement.Text = "Best: "..tostring(tonumber(Acc)).."%"
		end

		local PBMaxCombo = ReturnResult.ExtraData.MaxCombo

		if Accurancy.MaxCombo > PBMaxCombo then
			TweenService:Create(OnlineResult.OnlineMaxCombo,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,0)}):Play()
			TweenService:Create(OnlineResult.OnlineMaxCombo.Improvement,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			OnlineResult.OnlineMaxCombo.Improvement.Text = "+"..GetNewNum(Accurancy.MaxCombo-PBMaxCombo)
		else
			OnlineResult.OnlineMaxCombo.Improvement.Text = "Best: "..GetNewNum(PBMaxCombo).."x"
		end
	end

	if ReturnResult.NewPerfomance then
		OnlineResult.OverallPerfomance.TotalPS.Text = GetNewNum(ReturnResult.NewPerfomance).."ps"
		local StringImprovement = "-"

		if ReturnResult.PSImprovement > 0 then
			TweenService:Create(OnlineResult.OverallPerfomance,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,0)}):Play()
			TweenService:Create(OnlineResult.OverallPerfomance.Improvement,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			local Improvement = math.floor(ReturnResult.PSImprovement)
			StringImprovement = "+"..tostring(Improvement)
		elseif ReturnResult.PSImprovement < 0 then
			TweenService:Create(OnlineResult.OverallPerfomance,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(200,0,0)}):Play()
			TweenService:Create(OnlineResult.OverallPerfomance.Improvement,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextColor3 = Color3.fromRGB(255,255,255)}):Play()
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


-- Script note: Some value name may spell incorrectly (And it may take ages to change bk .-.)





-->         osu!RoVer       <--
-- osu!corescript by VtntGaming
-- String size: 285.06KB (V1.42)

-- Source code used as a backup script, if you're not VtntGaming and see this please use it right :>
----------------- End script -----------------

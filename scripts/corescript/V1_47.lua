osuLocalConvert = require(workspace.OsuConvert) 



-- Services instance load

TweenService = game:GetService("TweenService")
UserInputService = game:GetService("UserInputService")
RunService = game:GetService("RunService")
HttpService = game:GetService("HttpService")
StarterGui = game.StarterGui
ScriptComponent = script.Parent.GameplayScripts.Components
ObjectTools = require(ScriptComponent.Gameplay.CircleObject)
LocalPlayer = game.Players.LocalPlayer
PlayerGui = LocalPlayer.PlayerGui
ObjectManagement_Actor = game.Players.LocalPlayer.PlayerScripts.ObjectManagement_Actor
ExternalFunction_Actor = game.Players.LocalPlayer.PlayerScripts.ExternalFunction_Actor
local wait = require(workspace.WaitModule)

if script.Parent.StartupState.Value == "Waiting" then
	repeat wait() until script.Parent.StartupState.Value ~= "Waiting"
end

local StartupState = script.Parent.StartupState.Value
local StateReady = false

function cloneTable(a)
	local c = {}
	for i,b in pairs(a) do
		c[i] = b
	end
	return c
end

-- Instance load

local MouseHitEvent = Instance.new("BindableEvent")
local MouseHitEndEvent = Instance.new("BindableEvent")
StarterGui:SetCore("ResetButtonCallback",false)

-- FPS checker

local GameplayFPS = 0
local LastFramerate = tick()

RunService.RenderStepped:Connect(function()
	LastFramerate = tick()
end)

--RunService.RenderStepped:Connect(function()
workspace.ClientWaitModule.AccurateEvent.Event:Connect(function()
	GameplayFPS += 1
	wait(1)
	GameplayFPS -= 1
end)

-- Script default settings (can only change in the script)

BeatmapsList = workspace.Beatmaps

-- just in case I forgot to turn this ^^^ back
if not RunService:IsStudio() and BeatmapsList ~= workspace.Beatmaps then
	BeatmapsList = workspace.Beatmaps
elseif #workspace.ProcessingBeatmap:GetChildren() > 0 and RunService:IsStudio() then
	BeatmapsList = workspace.ProcessingBeatmap
	if PlayerGui:WaitForChild("BeatmapListing"):FindFirstChild("FirstLoad") then
		require(PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("Processing beatmap found, switching location.",Color3.new(0, 1, 0))
		PlayerGui.BeatmapListing.FirstLoad:Destroy()
	end
end

-- Security key
SecurityValue = script:WaitForChild("Key",math.huge)
ServerSecurityKey = SecurityValue.Value
SecurityValue.Value = "no u"
SecurityValue:Destroy()

PlayerGui:WaitForChild("BG"):WaitForChild("StartButton")

if PlayerGui.SavedSettings:FindFirstChild("SettingsFrame") then
	PlayerGui.BG.SettingsFrame:Destroy()
	PlayerGui.SavedSettings.SettingsFrame:Clone().Parent = PlayerGui.BG
else
	local CurrentSetting = PlayerGui.BG.SettingsFrame.MainSettings
	local AsyncedSetting = game.ReplicatedStorage.GetSettings:InvokeServer()

	local Option = {["true"] = "Enabled",["false"] = "Disabled"}
	local AdvancedOption = {
		NotelockStyle = {["true"] = "Stable",["false"] = "Lazer"}
	}
end
if PlayerGui.SavedSettings:FindFirstChild("PreviewFrame") then
	PlayerGui.BG.PreviewFrame:Destroy()
	PlayerGui.SavedSettings.PreviewFrame.Parent = PlayerGui.BG
end

-- make everything goes back where it was

PlayerMouse = LocalPlayer:GetMouse()
PlayerMouse.Icon = "rbxasset://textures/Cursors/KeyboardMouse"
--UserInputService.MouseIconEnabled = true
PlayerGui.OsuCursor.Cursor.Visible = true
UserInputService.MouseBehavior = Enum.MouseBehavior.Default
--[[
PlayerGui.MenuInterface.PlayerListButton.Visible = true
PlayerGui.MenuInterface.LeaderboardButton.Visible = true
PlayerGui.MenuInterface.ProfileButton.Visible = true
PlayerGui.MenuInterface.MultiplayerButton.Visible = true
PlayerGui.MenuInterface.UpdateLogButton.Visible = true
PlayerGui.MenuInterface.ExpandButton.ExpandButton.Visible = true]]
PlayerGui.MenuInterface.DropdownMenu.MenuListAnimate.hiddenRequest:Fire(false)
--PlayerGui.MenuInterface.WikiButton.Visible = true
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,true)
game.Lighting.Blur.Size = 0
TweenService:Create(PlayerGui.OverallInterface.FPSCounter,
	TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(1,-10,1,-40)}
):Play()

GameSettingManage = game.Players.LocalPlayer.PlayerGui.Settings.SettingFrame.BaseFrame.MainLayer.SettingsManage
CurrentSetting = PlayerGui.BG.SettingsFrame

Instance.new("IntValue",CurrentSetting.Parent).Name = "SettingsLoaded"

PlayerGui.LoadUI.Scripts.EndloadScript.Disabled = false

-- Those settings can be change multiply times before the game start
FileType = 1
AutoPlay = false
IngamebeatmapID = CurrentSetting.VirtualSettings.IngameBeatmapID
PrevBeatmapID = CurrentSetting.VirtualSettings.PrevBeatmapID
CursorTrailEnabled = true
EnableTouchDevice = true -- Touch screen enabled only
SpeedSync = true
UIPreviewFrame = PlayerGui.BG.PreviewFrame
CurrentPreviewFrame = UIPreviewFrame.PreviewFrame
MouseButtonEnabled = true
SliderMode = false -- This option will be remove and slider will be in real game soon
OldCursorMovement = false
NewCircelOverlay = false
OldInterface = false
Flashlight = false
PSDisplay = false
DetailedPSDisplay = false
HitErrorEnabled = true
OverallInterfaceEnabled = true
FreePlay = false
DefaultBackgroundTrans = 0.2
MobileModeRightHitZone = false
DisableChatInGame = false
KeepOriginalPitch = false
BackgroundBlurEnabled = false
showHealthBar = true
NoFail = false
HiddenMod = false
EasyMod = false
InGameLeaderboard = true
HitZoneEnabled = true
HardRock = false
CustomComboColorEnabled = false
OnMultiplayer = false
MultiplayerMatchFailed = false
OptimizedPerfomance = false
MPScoreV2Enabled = false
ScoreV2Enabled = false
ReplayMode = false
ExclusiveEffects = false
Hit300Display = false
TouchDeviceDetected = false
HitKeyOverlay = true
InstaFadeCircle = false
LiveDifficultyDisplay = false
Replay_TouchDevice = false
AimAssist = false
CursorRipplesEnabled = false
DifficultyAdjust = {Active = false}

-- PreviewFrameScriptSettings
PreviewFrameBaseVolume = 0.5




-- Default settings
BeatmapStudio = "playerchoose" --If test on studio, value to "playerchoose" if wanna set it to random
Id = 1
gameEnded = true
onTutorial = false
PlayRanked = true

local BadgeCondition = {
	AllComboGone = false,
	CloseOne = false
}

local ConditionFailed = {
	AllComboGone = false
}

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
	if PlayerGui.SavedSettings:FindFirstChild("SettingsFrame") then
		PlayerGui.SavedSettings.SettingsFrame.VirtualSettings.IngameBeatmapID.Value = IngamebeatmapID.Value
	end
end

if BeatmapStudio == "playerchoose" then
	--BeatmapStudio = BeatmapsList:GetChildren()[IngamebeatmapID.Value]

	local CurrentBeatmap = PlayerGui.BeatmapListing.CurrentBeatmap
	local Map = BeatmapsList:GetChildren()[math.random(1,#BeatmapsList:GetChildren())]

	if not CurrentBeatmap.Value then
		CurrentBeatmap.Value = Map
	end

	BeatmapStudio = CurrentBeatmap.Value or Map
	BeatmapChangeable = true
end


-- Settings default config

if CursorRipplesEnabled then
	MouseHitEvent.Event:Connect(function()
		script.Parent.CursorField.CursorRipples.RippleBind:Fire()
	end)
end

if CurrentSetting.MainSettings.AutoPlay.Text == "[AT] Auto play: Enabled" then
	AutoPlay = true
end

if CurrentSetting.MainSettings.SpeedSync.Text == "[ST] Sync approach time: Disabled" then
	SpeedSync = false
end

if CurrentSetting.MainSettings.Flashlight.Text == "[FL] Flashlight: Enabled" then
	Flashlight = true
end

if CurrentSetting.MainSettings.SliderMode.Text == "[SL] Sliders: Enabled" then
	SliderMode = true
end

if CurrentSetting.MainSettings.NoFail.Text == "[NF] No Fail: Enabled" then
	TweenService:Create(CurrentSetting.MainSettings.HP,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{PlaceholderColor3 = Color3.new(0.698039, 0.423529, 0.423529)}):Play()
	NoFail = true
end

if CurrentSetting.MainSettings.Hidden.Text == "[HD] Hidden: Enabled" then
	HiddenMod = true
end

if CurrentSetting.MainSettings.HardRock.Text == "[HR] Hard Rock: Enabled" then
	HardRock = true
end

if CurrentSetting.MainSettings.Easy.Text == "[EZ] Easy: Enabled" then
	EasyMod = true
end

CurrentModData = {
	HD = HiddenMod,
	FL = Flashlight,
	NF = NoFail,
	HR = HardRock,
	EZ = EasyMod,
	DA = DifficultyAdjust.Active,
	Speed = tonumber(CurrentSetting.MainSettings.Speed.Text) or 1
}

-- blank function to prevent warnings and errors
function ReloadPreviewFrame() end
function LoadLeaderboard() end

function LoadMultiplier()
	local Multiplier = 1
	local isRankable = true
	if CurrentModData.HD then
		Multiplier *= 1.06
	end
	if CurrentModData.HR then
		Multiplier *= 1.06
	end
	if CurrentModData.FL then
		Multiplier *= 1.12
	end
	if CurrentModData.NF then
		Multiplier *= 0.5
	end
	if CurrentModData.EZ then
		Multiplier *= 0.5
	end
	if CurrentModData.Speed ~= 1 then
		local Speed = CurrentModData.Speed
		if Speed < 1 then
			Multiplier *= Speed^4.185
		elseif Speed > 1 then
			Multiplier *= Speed^0.28
		end
	end
	if CurrentModData.DA then
		Multiplier *= 0.5
		isRankable = false
	end

	Multiplier = math.floor((Multiplier*100)+0.5)/100
	local ExtraScoreMPText = ""
	if SliderMode == true then
		ExtraScoreMPText = " (+?)"
	end

	CurrentSetting.MainSettings.ScoreMultiplier.Raw.Value = Multiplier
	CurrentSetting.MainSettings.ScoreMultiplier.Rankable.Value = isRankable
	--CurrentSetting.MainSettings.ScoreMultiplier.Text = "Score multiplier: "..tostring(Multiplier).."x"..ExtraScoreMPText
end

LoadMultiplier()

function checkDifficultyAdjustState()
	local AR = CurrentSetting.MainSettings.AR
	local OD = CurrentSetting.MainSettings.OD
	local CS = CurrentSetting.MainSettings.CS
	local HP = CurrentSetting.MainSettings.HP

	local function checkVaild(data)
		if tonumber(data) and tonumber(data) >= 0 and tonumber(data) <= 11 then
			return true
		else
			return false
		end
	end

	if checkVaild(AR.Text) or checkVaild(CS.Text) or checkVaild(OD.Text) or checkVaild(HP.Text) then
		CurrentSetting.MainSettings.DifficultyAdjust.Text = "[DA] Difficulty adjust: Enabled"
		DifficultyAdjust.Active = true
		DifficultyAdjust.AR = checkVaild(AR.Text) and tonumber(AR.Text) or nil
		DifficultyAdjust.OD = checkVaild(OD.Text) and tonumber(OD.Text) or nil
		DifficultyAdjust.CS = checkVaild(CS.Text) and tonumber(CS.Text) or nil
		DifficultyAdjust.HP = checkVaild(HP.Text) and tonumber(HP.Text) or nil
	else
		DifficultyAdjust.Active = false
		DifficultyAdjust.AR = nil
		DifficultyAdjust.OD = nil
		DifficultyAdjust.CS = nil
		DifficultyAdjust.HP = nil
		CurrentSetting.MainSettings.DifficultyAdjust.Text = "[DA] Difficulty adjust: Disabled"
	end


	CurrentModData.DA = DifficultyAdjust.Active
	LoadMultiplier()
end

checkDifficultyAdjustState()

-- Settings change detect

CurrentSetting.MainSettings.AR.FocusLost:Connect(checkDifficultyAdjustState)
CurrentSetting.MainSettings.CS.FocusLost:Connect(checkDifficultyAdjustState)
CurrentSetting.MainSettings.OD.FocusLost:Connect(checkDifficultyAdjustState)
CurrentSetting.MainSettings.HP.FocusLost:Connect(checkDifficultyAdjustState)

CurrentSetting.MainSettings.Flashlight.MouseButton1Click:Connect(function()
	Flashlight = not Flashlight
	CurrentModData.FL = Flashlight
	if Flashlight == true then
		CurrentSetting.MainSettings.Flashlight.Text = '[FL] Flashlight: Enabled'
	else 
		CurrentSetting.MainSettings.Flashlight.Text = '[FL] Flashlight: Disabled'
	end


	LoadMultiplier()
	ReloadPreviewFrame()
end)

script.Parent.Parent.BG.ResultFrame:GetPropertyChangedSignal('Visible'):Connect(function()
	gameEnded = true
	script.Parent.PlayFrame.Flashlight.Visible = false
end)

CurrentSetting.MainSettings.AutoPlay.MouseButton1Click:Connect(function()
	AutoPlay = not AutoPlay
	if AutoPlay == true --[[and ReplayMode ~= true]] then
		CurrentSetting.MainSettings.AutoPlay.Text = "[AT] Auto play: Enabled"
	else
		CurrentSetting.MainSettings.AutoPlay.Text = "[AT] Auto play: Disabled"
	end
end)


CurrentSetting.MainSettings.SpeedSync.MouseButton1Click:Connect(function()
	SpeedSync = not SpeedSync
	if SpeedSync == true then
		CurrentSetting.MainSettings.SpeedSync.Text = "[ST] Sync approach time: Enabled"
	else
		CurrentSetting.MainSettings.SpeedSync.Text = "[ST] Sync approach time: Disabled"
	end
end)

CurrentSetting.MainSettings.SliderMode.MouseButton1Click:Connect(function()
	SliderMode = not SliderMode
	if SliderMode == true then
		CurrentSetting.MainSettings.SliderMode.Text = "[SL] Sliders: Enabled"
	else
		CurrentSetting.MainSettings.SliderMode.Text = "[SL] Sliders: Disabled"
	end

	LoadMultiplier()
	ReloadPreviewFrame()
end)

CurrentSetting.MainSettings.NoFail.MouseButton1Click:Connect(function()
	NoFail = not NoFail
	CurrentModData.NF = NoFail
	LoadMultiplier()
	if NoFail == true then
		TweenService:Create(CurrentSetting.MainSettings.HP,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{PlaceholderColor3 = Color3.new(0.698039, 0.698039, 0.423529)}):Play()
		CurrentSetting.MainSettings.NoFail.Text = "[NF] No Fail: Enabled"
	else
		TweenService:Create(CurrentSetting.MainSettings.HP,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{PlaceholderColor3 = Color3.new(0.698039, 0.423529, 0.423529)}):Play()
		CurrentSetting.MainSettings.NoFail.Text = "[NF] No Fail: Disabled"
	end
	ReloadPreviewFrame()
end)

CurrentSetting.MainSettings.Hidden.MouseButton1Click:Connect(function()
	HiddenMod = not HiddenMod
	CurrentModData.HD = HiddenMod

	LoadMultiplier()
	if HiddenMod == true then
		CurrentSetting.MainSettings.Hidden.Text = "[HD] Hidden: Enabled"
	else
		CurrentSetting.MainSettings.Hidden.Text = "[HD] Hidden: Disabled"
	end

	ReloadPreviewFrame()
end)

GameSettingManage.SubscribeSettingChange:Fire("MusicVolume", script, function(value)
	TweenService:Create(CurrentPreviewFrame.OverviewSong,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{Volume = PreviewFrameBaseVolume*(value*0.01)}):Play()
end)

CurrentSetting.MainSettings.HardRock.MouseButton1Click:Connect(function()
	HardRock = not HardRock
	CurrentModData.HR = HardRock
	if HardRock == true then
		CurrentSetting.MainSettings.HardRock.Text = "[HR] Hard Rock: Enabled"
		CurrentSetting.MainSettings.Easy.Text = "[EZ] Easy: Disabled"
		EasyMod = false
		CurrentModData.EZ = false
	else
		CurrentSetting.MainSettings.HardRock.Text = "[HR] Hard Rock: Disabled"
	end

	LoadMultiplier()
	ReloadPreviewFrame()
end)

CurrentSetting.MainSettings.Easy.MouseButton1Click:Connect(function()
	EasyMod = not EasyMod
	CurrentModData.EZ = EasyMod
	if EasyMod == true then
		CurrentSetting.MainSettings.Easy.Text = "[EZ] Easy: Enabled"
		CurrentSetting.MainSettings.HardRock.Text = "[HR] Hard Rock: Disabled"
		HardRock = false
		CurrentModData.HR = false
	else
		CurrentSetting.MainSettings.Easy.Text = "[EZ] Easy: Disabled"
	end


	LoadMultiplier()
	ReloadPreviewFrame()
end)
-- Process function [Loop function]

--[[script.Parent.FunctionProcess.Event:Connect(function(Function)
	Function()
end)]]

function ProcessFunction(Function)
	script.Parent.GameplayScripts.ProcessFunction.Process:Fire(Function)
end

local spawn = ProcessFunction


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

	if Mod.TD == true then
		ModUsed = true
		if Mods > 0 then
			ReturnText = ReturnText..","
		end
		Mods += 1
		if Detailed then
			ReturnText = ReturnText.."TouchDevice"
		else
			ReturnText = ReturnText.."TD"
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

	if Mod.NF == true then
		ModUsed = true
		if Mods > 0 then
			ReturnText = ReturnText..","
		end
		Mods += 1
		if Detailed then
			ReturnText = ReturnText.."NoFail"
		else
			ReturnText = ReturnText.."NF"
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

LBDetailMovementConnection = UserInputService.InputChanged:Connect(function(data)
	if data.UserInputType == Enum.UserInputType.MouseMovement then
		local LeaderboardInterface = PlayerGui.BG.BeatmapLeaderboard
		local LBPosition = LeaderboardInterface.AbsolutePosition
		local MousePosition = data.Position
		local NewPosition = UDim2.new(0,MousePosition.X-LBPosition.X,0,MousePosition.Y-LBPosition.Y)
		--LeaderboardInterface.LeaderboardDetail.Position = NewPosition

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

		NewPosition += (UDim2.new(0,20,0,35) - UDim2.new(0,AnchorPoint.X*20,0,AnchorPoint.Y*35))

		TweenService:Create(LeaderboardInterface.LeaderboardDetail,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = NewPosition,AnchorPoint = Vector2.new(AnchorPoint.X,AnchorPoint.Y)}):Play()

		--LeaderboardInterface.LeaderboardDetail.Position 
		--LeaderboardInterface.LeaderboardDetail.AnchorPoint = Vector2.new(AnchorPoint.X,AnchorPoint.Y)
	end
end)

PlayerGui.BG.BeatmapLeaderboard.Destroying:Connect(function()
	LBDetailMovementConnection:Disconnect()
end)

function GetUserPlayUpdatedPS(Data)
	local aim = PreviewMapPS.Aim
	local speed = PreviewMapPS.Speed
	local mod = PreviewMapPS.Mod
	local fl = PreviewMapPS.AimFL
	local acc = PreviewMapPS.Acc
	local td = PreviewMapPS.TD
	local objCount = PreviewMapPS.objCount
	local MaxPS = 0

	local AimMultiplier = mod.Aim
	local SpeedMultiplier = mod.Speed
	local AccMultiplier = mod.Acc

	local h300 = Data.ExtraAccurancy[1]
	local h100 = Data.ExtraAccurancy[2]
	local h50 = Data.ExtraAccurancy[3]
	local MissCount = Data.ExtraAccurancy[4]

	if Data.Mod.TD then
		AimMultiplier *= 0.6
	end

	if not Data.Mod.HC then
		AimMultiplier *= 0.9
		SpeedMultiplier *= 0.9
		AccMultiplier *= 0.9
	end

	local OverallDifficulty = PreviewMapPS.OD
	local TotalHit = h300  + h100 + h50 + MissCount
	local Accuracy = (h300*3 + h100 + h50*0.5) / (TotalHit * 3)
	local BetterAcc = ((h300 - (TotalHit - objCount)) * 3 + h100 + h50 * 0.5) / (objCount * 3)
	local MissCount = MissCount
	local AimPS = aim
	local SpeedPS = speed
	local AccPS = acc
	local BaseModPS = AimPS * (AimMultiplier-1) + SpeedPS * (SpeedMultiplier-1) + AccPS * (AccMultiplier-1)
	MaxPS = AimPS + SpeedPS +  AccPS + BaseModPS
	local Scaling = math.min(math.pow(TotalHit, 0.8) / math.pow(objCount, 0.8), 1.0)

	if MissCount > 0 then
		AimPS *= 0.97 * math.pow(1 - math.pow(MissCount / TotalHit, 0.775), MissCount)
		SpeedPS *= 0.97 * math.pow(1 - math.pow(MissCount / TotalHit, 0.775), math.pow(MissCount, 0.875))
	end

	-- it's pretty easy to adjust AimPS based on Accuracy
	AimPS *= Accuracy

	-- but in the other hand, SpeedPS and AccPS isn't that easy...
	SpeedPS *= (0.95 + math.pow(OverallDifficulty, 2) / 750) * math.pow(Accuracy, (14.5 - math.max(OverallDifficulty, 8)) / 2)
	-- nerf doubletapping effect
	SpeedPS *= math.pow(0.99, (h50 < TotalHit / 500) and 0 or (h50 - TotalHit / 500))

	AccPS *= math.pow(BetterAcc, 24)

	AimPS *= Scaling
	SpeedPS *= Scaling
	AccPS *= Scaling

	local ModPS = AimPS * (AimMultiplier-1) + SpeedPS * (SpeedMultiplier-1) + AccPS * (AccMultiplier-1)
	local TotalPS = AimPS + SpeedPS + AccPS + ModPS

	return TotalPS,MaxPS
end


function ShowLeaderboardPlayDetail(Data)
	if Data.Mod == nil then -- old plays
		Data.Mod = {} -- just replace it with no value instead
	end

	local ModDetail = GetModData(Data.Mod,true)
	local PlayedDate = os.date("*t",tonumber(Data.Date))

	local DisplayPS = ""

	if Data.ExtraAccurancy then
		DisplayPS = "\nUpdatedPS: "..tostring(math.round(GetUserPlayUpdatedPS(Data))).."ps"
	end


	local DateDetail = string.format("%.2d/%.2d/%.4d %.2d:%.2d:%.2d",PlayedDate.day,PlayedDate.month,PlayedDate.year,PlayedDate.hour,PlayedDate.min,PlayedDate.sec)
	--local Accuracy = "<font color='#00ffff'>300</font>:"..Data.ExtraAccurancy[1].." <font color='#00ff00'>100</font>:"..Data.ExtraAccurancy[2].." <font color='#ffff00'>50</font>:"..Data.ExtraAccurancy[3].." <font color='#ff0000'>miss</font>:"..Data.ExtraAccurancy[4]
	local Accuracy = string.format("Statistic: <font color='#00ffff'>%d</font>/<font color='#00ff00'>%d</font>/<font color='#ffff00'>%d</font>/<font color='#ff0000'>%d</font>",Data.ExtraAccurancy[1],Data.ExtraAccurancy[2],Data.ExtraAccurancy[3],Data.ExtraAccurancy[4])

	local FullText = "Played on "..DateDetail.."\n"..Accuracy.."\nAccuracy: "..Data.Accurancy.."%\nMod: "..ModDetail..DisplayPS
	local LeaderboardDetail = PlayerGui.BG.BeatmapLeaderboard.LeaderboardDetail
	LeaderboardDetail.LeaderboardDetail.Text = FullText
	local Textbounds = LeaderboardDetail.LeaderboardDetail.TextBounds
	LeaderboardDetail.Size = UDim2.new(0,Textbounds.X+10,0,Textbounds.Y+10)

	local TweenProperties = {
		BG = {BackgroundTransparency = 0.25},
		Text = {TextTransparency = 0},
		Stroke = {Transparency = 0.5}
	}

	local TweenInfo1 = TweenInfo.new(0.25,Enum.EasingStyle.Linear)
	TweenService:Create(LeaderboardDetail,TweenInfo1,TweenProperties.BG):Play()
	TweenService:Create(LeaderboardDetail.LeaderboardDetail,TweenInfo1,TweenProperties.Text):Play()
	TweenService:Create(LeaderboardDetail.UIStroke,TweenInfo1,TweenProperties.Stroke):Play()

	--LeaderboardDetail.Visible = true
end

function HideLeaderboardPlayDetail()
	local LeaderboardDetail = PlayerGui.BG.BeatmapLeaderboard.LeaderboardDetail
	local TweenProperties = {
		BG = {BackgroundTransparency = 1},
		Text = {TextTransparency = 1},
		Stroke = {Transparency = 1}
	}

	local TweenInfo1 = TweenInfo.new(0.25,Enum.EasingStyle.Linear)
	TweenService:Create(LeaderboardDetail,TweenInfo1,TweenProperties.BG):Play()
	TweenService:Create(LeaderboardDetail.LeaderboardDetail,TweenInfo1,TweenProperties.Text):Play()
	TweenService:Create(LeaderboardDetail.UIStroke,TweenInfo1,TweenProperties.Stroke):Play()

	--LeaderboardDetail.Visible = false
end

function GetScore(CurrentScore)
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

local UserPlayInformationAnimateID
local DisplayLBInformationValue = {
	Score = Instance.new("IntValue"),
	MaxCombo = Instance.new("IntValue"),
	h300 = Instance.new("IntValue"),
	h100 = Instance.new("IntValue"),
	h50 = Instance.new("IntValue"),
	miss = Instance.new("IntValue"),
	rankedPS = Instance.new("NumberValue"),
	calculatedBasePS = Instance.new("NumberValue"),
	calculatedMaxPS = Instance.new("NumberValue")
}

function updateLBStaistic()
	local LbInformation = PlayerGui.BG.BeatmapLeaderboard.UserPlayInformation
	local MainFrame = LbInformation.MainFrame

	local Score = DisplayLBInformationValue.Score.Value
	local MaxCombo = DisplayLBInformationValue.MaxCombo.Value
	local h300 = DisplayLBInformationValue.h300.Value
	local h100 = DisplayLBInformationValue.h100.Value
	local h50 = DisplayLBInformationValue.h50.Value
	local miss =DisplayLBInformationValue.miss.Value
	local rankedPS = DisplayLBInformationValue.rankedPS.Value
	local calculatedBasePS = DisplayLBInformationValue.calculatedBasePS.Value
	local calculatedMaxPS = DisplayLBInformationValue.calculatedMaxPS.Value

	MainFrame.ScoreDisplay.Text = string.format("Score: %s (%dx)",GetScore(Score),MaxCombo)
	MainFrame.AccuracyDisplay.Text = string.format('Statistics: <font color = "#00ffff">%d</font>/<font color = "#55ff00">%d</font>/<font color = "#ffff00">%d</font>/<font color = "#ff0000">%d</font>',h300,h100,h50,miss)
	local Total = (h300+h100+h50+miss)
	local Acc = (h300*3+h100+h50*0.5)/(Total*3)*100
	local GameplayRank = "D"

	local RankColor = {
		SS = Color3.fromRGB(255, 255, 0),
		S = Color3.fromRGB(255, 255, 0),
		A = Color3.fromRGB(0, 255, 0),
		B = Color3.fromRGB(0, 85, 255),
		C = Color3.fromRGB(170, 0, 127),
		D = Color3.fromRGB(255, 0, 0)
	}

	local percent300s = h300/Total
	local percent50s = h50/Total
	local misstotal = miss


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
	if percent300s >= 1 then
		GameplayRank = "SS"
	end

	MainFrame.GradeDisplay.Text = string.format('Accuracy: %.2f%% [<font color = "#%s">%s</font>]',Acc,RankColor[GameplayRank]:ToHex(),GameplayRank)
	MainFrame.PSDisplay.Text = string.format("Ranked Perfomance: %.2fps",rankedPS)
	MainFrame.UpdatedPSDisplay.Text = string.format("Updated Perfomance: %.2f/%.2fps",calculatedBasePS,calculatedMaxPS)
end

for _, obj in pairs(DisplayLBInformationValue) do
	obj:GetPropertyChangedSignal("Value"):Connect(updateLBStaistic)
end

function AddLeaderboardConnection(LeaderboardFrame,Data,Score,UID,DateFormat)
	if not LeaderboardFrame:IsA("Frame") and not Data then return end
	LeaderboardFrameConnection[#LeaderboardFrameConnection+1] = LeaderboardFrame.MouseEnter:Connect(function()
		ShowLeaderboardPlayDetail(Data)
	end)
	LeaderboardFrameConnection[#LeaderboardFrameConnection+1] = LeaderboardFrame.MouseMoved:Connect(function()
		ShowLeaderboardPlayDetail(Data)
	end)
	LeaderboardFrameConnection[#LeaderboardFrameConnection+1] = LeaderboardFrame.TouchPan:Connect(function()
		local LeaderboardDetail = PlayerGui.BG.BeatmapLeaderboard.LeaderboardDetail
		LeaderboardDetail.AnchorPoint = Vector2.new(1,0.5)
		LeaderboardDetail.Position = UDim2.new(0,-15,0.5,0)

		ShowLeaderboardPlayDetail(Data)
	end)
	LeaderboardFrameConnection[#LeaderboardFrameConnection+1] = LeaderboardFrame.MouseLeave:Connect(function()
		HideLeaderboardPlayDetail()
	end)

	LeaderboardFrame.DevButton.MouseButton1Click:Connect(function()
		local LbInformation = PlayerGui.BG.BeatmapLeaderboard.UserPlayInformation
		local MainFrame = LbInformation.MainFrame

		local function add(obj, value)
			TweenService:Create(obj, TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Value = value}):Play()
		end

		add(DisplayLBInformationValue.Score, Score)
		add(DisplayLBInformationValue.MaxCombo, Data.MaxCombo)
		add(DisplayLBInformationValue.h300, Data.ExtraAccurancy[1])
		add(DisplayLBInformationValue.h100, Data.ExtraAccurancy[2])
		add(DisplayLBInformationValue.h50, Data.ExtraAccurancy[3])
		add(DisplayLBInformationValue.miss, Data.ExtraAccurancy[4])
		add(DisplayLBInformationValue.rankedPS, Data.PS or 0)
		local UpdatedPS,MaxPS = GetUserPlayUpdatedPS(Data)
		add(DisplayLBInformationValue.calculatedBasePS, UpdatedPS)
		add(DisplayLBInformationValue.calculatedMaxPS, MaxPS)
		local crrID = HttpService:GenerateGUID()
		UserPlayInformationAnimateID = crrID
		local ReplayOption = MainFrame.ReplayOption
		if Data.HaveReplay then
			ReplayOption.Visible = true
			TweenService:Create(MainFrame.Parent, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 150)}):Play()
			TweenService:Create(ReplayOption, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
		else
			TweenService:Create(MainFrame.Parent, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 115)}):Play()
			TweenService:Create(ReplayOption, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {GroupTransparency = 1}):Play()
			ProcessFunction(function()
				wait(0.25)
				if UserPlayInformationAnimateID == crrID then
					ReplayOption.Visible = false
				end
			end)
		end

		if CurrentKey == MainFrame.DatastoreName.Value and UID == MainFrame.Key.Value then
			MainFrame.DatastoreName.Value = ""
			MainFrame.Key.Value = ""
			TweenService:Create(MainFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(1.5,0,0.5,0)}):Play()
			return
		end
		MainFrame.DatastoreName.Value = CurrentKey
		MainFrame.Key.Value = UID
		TweenService:Create(MainFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,0.5,0)}):Play()
		TweenService:Create(LbInformation,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Position = UDim2.new(0,-20,0,math.max(math.min(LeaderboardFrame.AbsolutePosition.Y+58,workspace.CurrentCamera.ViewportSize.Y-216),36))}):Play()
	end)

	local function Check()
		if LeaderboardFrame.AbsoluteSize.X < 250 then
			LeaderboardFrame.MainFrame.Score.Text = GetScore(Score).."("..tostring(Data.MaxCombo).."x)"
			LeaderboardFrame.MainFrame.Accuracy.Visible = false
			LeaderboardFrame.MainFrame.PlayDate.Visible = false
			LeaderboardFrame.MainFrame.PSEarned.Position = UDim2.new(1,-8,0.6666,0)
			LeaderboardFrame.MainFrame.PSEarned.Text = DateFormat.." | "..tostring(math.round(Data.PS)).."ps"
		else
			LeaderboardFrame.MainFrame.Accuracy.Visible = true
			LeaderboardFrame.MainFrame.PlayDate.Visible = true
			LeaderboardFrame.MainFrame.PSEarned.Position = UDim2.new(1,-8,1,0)
			LeaderboardFrame.MainFrame.PSEarned.Text = tostring(math.round(Data.PS)).."ps"
			LeaderboardFrame.MainFrame.Score.Text = "Score: "..GetScore(Score).." ("..tostring(Data.MaxCombo).."x)"
		end
	end
	wait()
	Check()
	LeaderboardFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(Check)
end

CurrentLeaderboardSession = ""

LBTweenConnection = {}
local _RefreshEvent = Instance.new("BindableEvent")

function AddLBTweenConnection(Tween,DelayedTime)
	local Key = HttpService:GenerateGUID(false)
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

PSLeaderboard = false

LoadLeaderboard = function()
	local OptimizedPerfomance = GameSettingManage.getSettings:Invoke("OptimizedPerfomance")
	local LeaderboardInterface = PlayerGui.BG.BeatmapLeaderboard
	local ThisLBSession = HttpService:GenerateGUID()
	CurrentLeaderboardSession = ThisLBSession

	-- Clear old data
	for i,obj in pairs(LeaderboardInterface.GolbalLeaderboard:GetChildren()) do
		if not obj:IsA("Frame") or not obj:FindFirstChild("MainFrame") then continue end
		TweenService:Create(obj.MainFrame,TweenInfo.new(0.75+obj.LayoutOrder*0.01, Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Position = UDim2.new(1,0,0,0)}):Play()
	end
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

	--LeaderboardInterface.LoadingText.Visible = true
	ProcessFunction(function()
		LeaderboardInterface.UILoad.LoadingUI.Frame.LocalScript.Disabled = false
		TweenService:Create(LeaderboardInterface.UILoad,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{GroupTransparency = 0}):Play()
	end)
	LeaderboardInterface.NoRecord.Visible = false
	LeaderboardInterface.PersonalBest.NoRecord.Visible = false
	LeaderboardInterface.PersonalBestTitle.TextTransparency = 1

	-- Get map lb data from the server
	local GolbalData,PersonalData,SessionChanged = game.ReplicatedStorage.BeatmapLeaderboard:InvokeServer(1,{DatastoreName = CurrentKey})
	-- prevent duplicating request
	if SessionChanged == true or CurrentLeaderboardSession ~= ThisLBSession then return end

	local Leaderboard = LeaderboardInterface.GolbalLeaderboard
	Leaderboard:ClearAllChildren()

	local UIListLayout = Instance.new("UIListLayout",Leaderboard)
	UIListLayout.Padding = UDim.new(0,5)
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local PersonalRank = "-"
	local Top100Score = 1
	local GolbalLoaded = false

	local SendingData = {
		Golbal = GolbalData,
		Local = PersonalData,
		PSLeaderboard = PSLeaderboard
	}
	

	script.Parent.GameplayData.LbStateAvaiable.LbDataProcess.Update:Fire(SendingData)
	--script.Parent.GameplayData.LeaderboardData.Value = HttpService:JSONEncode(SendingData)
	--CurrentPreviewFrame.Overview.LeaderboardDisplay.LBData.Value = HttpService:JSONEncode(SendingData)

	if script.Parent:FindFirstChild("GameStarted") or StartupState == "FastRestart" then return end
	
	local function getps(plr)
		return plr.ExtraData and (plr.ExtraData.PS or 0) or 0
	end

	if PSLeaderboard then
		table.sort(GolbalData,function(plr1,plr2)
			return getps(plr1) > getps(plr2) or (getps(plr1) == getps(plr2) and plr1.Rank < plr2.Rank)
		end)

		for newrank,plr in pairs(GolbalData) do
			plr.Rank = newrank
		end
	end

	--LeaderboardInterface.LoadingText.Visible = false
	ProcessFunction(function()
		LeaderboardInterface.UILoad.LoadingUI.Frame.CloseRequest:Fire()
		wait(0.15)
		TweenService:Create(LeaderboardInterface.UILoad,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{GroupTransparency = 1}):Play()
	end)

	wait(0.4)
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
			local PlayedTime = os.time() - (tonumber(CurrentDate) or 0)

			if PlayedTime < 3600 then
				return tostring(math.floor(PlayedTime/60)).."mi"
			elseif PlayedTime < 86400 then
				return tostring(math.floor(PlayedTime/3600)).."h"
			elseif PlayedTime < 2592000 then
				return tostring(math.floor(PlayedTime/86400)).."d"
			elseif PlayedTime < 62208000 then
				return tostring(math.floor(PlayedTime/2592000)).."m"
			else
				return tostring(math.floor(PlayedTime/31104000)).."y"
			end
		end
		Leaderboard.CanvasSize = UDim2.new(0,0,0,#GolbalData*45)
		Leaderboard.CanvasPosition = Vector2.new(0,0)

		local Total = #GolbalData + ((PersonalData and PersonalData.Data and tonumber(PersonalData.Data.Score) and 1) or 0)
		local Loaded = 0

		for i,Data in pairs(GolbalData) do
			ProcessFunction(function()
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
						NewLBFrame.MainFrame.Accuracy.Text = tostring(Data.ExtraData.Accurancy).."%"
						NewLBFrame.MainFrame.PlayDate.Text = GetDate(Data.ExtraData.Date).." | "..GetModData(Data.ExtraData.Mod)..string.format("%.2fx",Data.ExtraData.Speed)
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
						NewLBFrame.MainFrame.Accuracy.Text = "-"
						NewLBFrame.MainFrame.PlayDate.Text = "-"
						NewLBFrame.MainFrame.PSEarned.Text = "-"
					end
					if tostring(Data.Rank) == "100" then
						Top100Score = (tonumber(Data.Score) or 0)+1
					end
					NewLBFrame.MainFrame.Score.Text = "Score: "..GetScore(Data.Score)..MaxComboText
					NewLBFrame.MainFrame.Rank.Text = "#"..tostring(Data.Rank)
					--NewLBFrame.MainFrame.PlayerImage.Image = Data.ThumbnailId
					ProcessFunction(function()
						if not NewLBFrame.Parent then
							-- posibility of being removed while loading
							return
						end
						if Data.UID == "1241445502" then -- the creator mark
							NewLBFrame.MainFrame.PlayerName.TextColor3 = Color3.new(0.333333, 1, 0.498039)
							NewLBFrame.MainFrame.Rank.TextColor3 = Color3.new(0.333333, 1, 0.498039)
							NewLBFrame.MainFrame.UserName.TextColor3 = Color3.new(0.333333, 1, 0.498039)
						end

						if Data.Name == LocalPlayer.Name then
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
										isFriend = LocalPlayer:IsFriendsWith(game.Players:GetUserIdFromNameAsync(Data.Name))
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
					AddLeaderboardConnection(NewLBFrame,Data.ExtraData,Data.Score,Data.UID,GetDate(Data.ExtraData.Date))
				end)

				if not Success then print(Data) end
				for i = 1,10 do
					wait()
				end
				Loaded += 1
				if Loaded < Total then
					repeat wait() until Loaded >= Total
				end

				wait((i-1)*0.05)
				if not OptimizedPerfomance then
					TweenService:Create(NewLBFrame.MainFrame,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0,0,0,0),BackgroundTransparency = 0.9}):Play()
					TweenService:Create(NewLBFrame,TweenInfo.new(.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(1,0,0,40)}):Play()
				else
					NewLBFrame.MainFrame.Position = UDim2.new(0,0,0,0)
					NewLBFrame.MainFrame.BackgroundTransparency = 0.9
					NewLBFrame.Size = UDim2.new(1,0,0,40)
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
				LeaderboardInterface.PersonalBest.Visible = true
				LeaderboardInterface.PersonalBestTitle.Visible = true
				LeaderboardInterface.GolbalLeaderboard.Size = UDim2.new(1,0,1,-100)
				LeaderboardInterface.ScrollSide.Size = UDim2.new(0,4,1,-100)

				local PlayersFitScreen = math.floor(Leaderboard.AbsoluteSize.Y/40)+1
				local WaitTime = (#GolbalData >= PlayersFitScreen and PlayersFitScreen*0.1) or (#GolbalData)*0.1
			--[[ 
				Data.ExtraData.Mod = {
					FL = <Fl>
				}
			]]
				local NewLBFrame = script.Leaderboard.LeaderboardFrame:Clone()
				NewLBFrame.Parent = LeaderboardInterface.PersonalBest
				NewLBFrame.Name = "PlayerPB"
				NewLBFrame.ZIndex = tonumber(Data.Rank)
				NewLBFrame.MainFrame.PlayerName.Text = LocalPlayer.DisplayName
				NewLBFrame.MainFrame.UserName.Text = "@"..LocalPlayer.Name

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
					NewLBFrame.MainFrame.Accuracy.Text = tostring(Data.ExtraData.Accurancy).."%"
					NewLBFrame.MainFrame.PlayDate.Text = GetDate(Data.ExtraData.Date).." | "..GetModData(Data.ExtraData.Mod)..string.format("%.2fx",math.floor(Data.ExtraData.Speed*100)/100)
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
					NewLBFrame.MainFrame.Accuracy.Text = "-"
					NewLBFrame.MainFrame.PlayDate.Text = "-"
					NewLBFrame.MainFrame.PSEarned.Text = "-"
				end

				NewLBFrame.MainFrame.Score.Text = "Score: "..GetScore(Data.Score)..MaxComboText
				ProcessFunction(function()
					NewLBFrame.MainFrame.Rank.Text = "-"
					--repeat wait() until GolbalLoaded
					for i,e in pairs(GolbalData) do
						if e.UID == LocalPlayer.UserId then
							PersonalRank = tostring(i)
							break
						end
					end
					if PersonalRank ~= "-" then
						NewLBFrame.MainFrame.Rank.Text = "#"..tostring(PersonalRank)
					else
						local TopPercent = 1+math.floor((99-(tonumber(Data.Score)/Top100Score)*99)+0.5)
						NewLBFrame.MainFrame.Rank.Text = "Top "..string.format("%.1f",TopPercent).."%"
					end
				end)
				--NewLBFrame.MainFrame.PlayerImage.Image = Data.ThumbnailId
				AddLeaderboardConnection(NewLBFrame,Data.ExtraData,Data.Score,Data.UID,GetDate(Data.ExtraData.Date))
				for i = 1,10 do
					wait()
				end
				Loaded += 1
				if Loaded < Total then
					repeat wait() until Loaded >= Total
				end
				wait(WaitTime)
				NewLBFrame.Size = UDim2.new(1,0,0,40)
				if not OptimizedPerfomance then
					TweenService:Create(NewLBFrame.MainFrame,TweenInfo.new(0.75,Enum.EasingStyle.Quart),{Position = UDim2.new(0,0,0,0),BackgroundTransparency = 0.9}):Play()
				else
					NewLBFrame.MainFrame.Position = UDim2.new(0,0,0,0)
				end

				wait(0.25)
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
				LeaderboardInterface.PersonalBest.Visible = false
				LeaderboardInterface.PersonalBestTitle.Visible = false
				LeaderboardInterface.GolbalLeaderboard.Size = UDim2.new(1,0,1,-40)
				LeaderboardInterface.ScrollSide.Size = UDim2.new(0,4,1,-40)

				--LeaderboardInterface.PersonalBest.NoRecord.Visible = true
			end
		end)
	end
end

GameSettingManage.SubscribeSettingChange:Fire("UsePSLeaderboard", script, function(value)
	PSLeaderboard = value
	LoadLeaderboard()
end)



--Overview 

PreviewBeatmapset = 0
BeatmapSetId = 0
BeatmapId = 0

function UpdateRule()
	script.Parent.MultiplayerData.ChangeRule:Fire({
		SL = SliderMode,
		ScoreV2 = MPScoreV2Enabled
	})
end

script.Parent.MultiplayerData.RuleChanged.Event:Connect(function(Rule)
	SliderMode = Rule.Slider
	--osuStableNotelock = Rule.StableNL
	MPScoreV2Enabled = Rule.ScoreV2
end)

--CurrentSetting.MainSettings.SliderMode:GetPropertyChangedSignal("Text"):Connect(UpdateRule)
--CurrentSetting.MainSettings.ScoreV2:GetPropertyChangedSignal("Text"):Connect(UpdateRule)

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
		NF = NoFail,
		ScoreV2 = ScoreV2Enabled
	}
end

PreviewMapPS = {
	Aim = 0, Speed = 0, Mod = 0, AimFL = 0, Acc = 0, objCount = 0
}

ReloadPreviewFrame = function()
	local _1,_2,_3,_4,_5,_6 = script.Parent.GameplayScripts.ReloadPreviewFrame.LoadPreviewFrame:Invoke(
		CurrentPreviewFrame,CurrentSetting,FileType,CurrentModData,BeatmapStudio,CurrentKey,BeatmapKey
		,PreviewFrameBaseVolume,PreviewBeatmapset, NoFail,not SliderMode,HardRock,Flashlight,EasyMod,HiddenMod
	)
	CurrentModData = _1
	CurrentKey = _2
	BeatmapKey = _3
	PreviewFrameBaseVolume = _4
	PreviewBeatmapset = _5
	PreviewMapPS = _6
	LoadMultiplier()
end

script.Parent.MultiplayerData.ChangeMap.Event:Connect(function(MapFile,Speed)
	CurrentSetting.MainSettings.Speed.Text = tostring(Speed or "")
	BeatmapStudio = workspace.Beatmaps:FindFirstChild(MapFile)
	PlayerGui.BeatmapListing.CurrentBeatmap.Value = workspace.Beatmaps:FindFirstChild(MapFile)
	PlayerGui.BeatmapListing.MainFrame.MainFrame.WorkingScript.MPForceUpdate:Fire()
	ReloadPreviewFrame()
	LoadLeaderboard()
end)

GameSettingManage.SubscribeSettingChange:Fire("EnableSpeedPitch", script, function()
	ReloadPreviewFrame()
end)

wait()
if StartupState == "Normal" then
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

if table.find(Administrator,LocalPlayer.UserId) then
	local LeftClickEnabled = false

	local DeveloperUI = PlayerGui.DeveloperUI
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

	local Leaderboard = PlayerGui.BG.BeatmapLeaderboard.GolbalLeaderboard
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
			local MouseLocation = UserInputService:GetMouseLocation()
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
		local ProfileUI = PlayerGui.MenuInterface.UserProfile
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

ChangingQueue = 0

script.Parent.MapListingChange.Event:Connect(function(MapFile,beatmapid)
	ChangingQueue += 1
	local PrevMapID = IngamebeatmapID.Value
	CurrentSetting.VirtualSettings.PrevBeatmapID.Value = CurrentSetting.VirtualSettings.IngameBeatmapID.Value
	CurrentSetting.VirtualSettings.IngameBeatmapID.Value = beatmapid
	if PlayerGui.SavedSettings:FindFirstChild("SettingsFrame") then
		PlayerGui.SavedSettings.SettingsFrame.VirtualSettings.PrevBeatmapID.Value = PlayerGui.SavedSettings.SettingsFrame.VirtualSettings.IngameBeatmapID.Value
		PlayerGui.SavedSettings.SettingsFrame.VirtualSettings.IngameBeatmapID.Value = beatmapid
	end
	PrevBeatmapID.Value = PrevMapID
	IngamebeatmapID.Value = beatmapid
	if BeatmapChangeable == true then
		Id = beatmapid
		BeatmapStudio = MapFile
	end
	ChangingQueue -= 1
	ReloadPreviewFrame()
end)

script.Parent.MapLbUpdate.Event:Connect(function()
	if ChangingQueue > 0 then
		repeat wait() until ChangingQueue == 0
	end
	LoadLeaderboard()
end)



CurrentPreviewFrame.PreviewButton.MouseButton1Click:Connect(ReloadPreviewFrame)


local BackgroundFrame = PlayerGui.BG.Background.Background



local PlaybuttonTriggered = false
local BeatmapStarted = false
local StartButton
local StartButtonAnimated = false

function AnimateStartButton()
	if BeatmapStarted then return end
	StartButtonAnimated = true
	local BGFrame = script.Parent.Parent.BG
	StartButton = BGFrame.StartButton
	StartButton.Visible = true
	StartButton.LocalScript:Destroy()
	StartButton.Parent = PlayerGui.PlayScreen
	StartButton.ZIndex = 12
	TweenService:Create(StartButton,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(0.3,0,0.3,0),BackgroundTransparency = 0.75}):Play()
end

script.Parent.Parent.BG.StartButton.MouseButton1Click:Connect(function()
	if PlaybuttonTriggered == false then
		local DefaultBackgroundTrans = 1-GameSettingManage.getSettings:Invoke("BGDim")*0.01
		if not PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.Disabled then
			local GameAlreadyStarted = PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.MultiplayerFolder.Value.IsMatchInProgress:InvokeServer()
			if GameAlreadyStarted then
				PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("The current match is not finished, try again later.",Color3.fromRGB(255,0,0))
				return
			end
		end

		PlaybuttonTriggered = true
		local BGFrame = script.Parent.Parent.BG
		AnimateStartButton()

		--BGFrame.StartButtonBeatAnimation:Destroy()

		--TweenService:Create(BGFrame.StartButton,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(0,400,0,100),BackgroundTransparency = 1}):Play()

		TweenService:Create(BGFrame.MultiplayerButton,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(0,400,0,100),BackgroundTransparency = 1}):Play()
		--TweenService:Create(BGFrame.StartButton.UIStroke,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Transparency = 1}):Play()
		--TweenService:Create(BGFrame.StartButton._Text,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()

		TweenService:Create(BGFrame.BeatmapChooseButton,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,0,-30)}):Play()
		TweenService:Create(BGFrame.SettingsButton,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,1,30)}):Play()
		TweenService:Create(UIPreviewFrame,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(1,0)}):Play()
		TweenService:Create(BGFrame.BeatmapLeaderboard,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(0,0)}):Play()
		TweenService:Create(BGFrame.BeatmapCount,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(0,0)}):Play()
		TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = math.max(0.8,DefaultBackgroundTrans+0.2)}):Play()
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
game.ReplicatedStorage.Gameplay.GetSpectateData:InvokeServer(LocalPlayer.UserId,-1)
game.ReplicatedStorage.Gameplay.GetSpectateData:InvokeServer(-1,-1)


-- Replay data

local ReplayDataRaw = ""
FinaleReplayData = {Score = 0, MaxCombo = 0, Accuracy = {0,0,0,0}, User = "",Date = 0,PS = 0,FileName = "", Speed = 1}

------- Check if the play ranked or not
local Reporter = game.ReplicatedStorage:FindFirstChild("ExpoiltReport")
if Reporter == nil then
	warn("[Client] An error occured, please rejoin to fix this issue")
	require(PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("An error occured, please rejoin to fix this issue.",Color3.new(1, 0, 0))
	script.Disabled = true
else
	ProcessFunction(function()
		repeat wait(0.1) until Reporter.Parent == nil
		warn("[Client] An error occured, please rejoin to fix this issue")
		require(PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("An error occured, please rejoin to fix this issue.",Color3.new(1, 0, 0))
		script.Disabled = true
	end)
end
local SecurityKey = HttpService:GenerateGUID() -- no

MouseHitEvent.Event:Connect(function(CurrentSecurityKey)
	if isSpectating == true or PlayRanked == false then return end
	if CurrentSecurityKey ~= SecurityKey then
		PlayRanked = false
		script.Parent.UnrankedSign.Visible = true
		require(PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("Detected some suspicous activity on your play, your account has been unranked. The report has been sent to the developer.",Color3.new(1, 0, 0))
		Reporter:FireServer(LocalPlayer.Name,LocalPlayer.UserId,1)
	else
		SecurityKey = HttpService:GenerateGUID(false)
	end
end)



script.Parent.SpectateCall.Event:Connect(function(UID,Username)
	local SpectateData = game.ReplicatedStorage.Gameplay.GetSpectateData:InvokeServer(UID)

	if SpectateData == 0 then
		require(PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("Unable to spectate "..Username,Color3.new(1,0,0))
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
				require(PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("Player you spectate has left.",Color3.new(1,0,0))
				break
			end
		end
	end)
	game.ReplicatedStorage.Gameplay.UpdateStatus:FireServer(3)
	script.Parent.StartGame:Fire()
end)

function ProcessReplayData(stringdata)
	if string.find(stringdata,"USER") then
		FinaleReplayData.User = string.sub(stringdata,6,#stringdata)
	elseif string.find(stringdata,"DATE") then
		FinaleReplayData.Date = tonumber(string.sub(stringdata,6,#stringdata))
	elseif string.find(stringdata,"SCORE") then
		FinaleReplayData.Score = tonumber(string.sub(stringdata,7,#stringdata))
	elseif string.find(stringdata,"MAXCOMBO") then
		FinaleReplayData.MaxCombo = tonumber(string.sub(stringdata,10,#stringdata))
	elseif string.find(stringdata,"PS") then
		FinaleReplayData.PS = tonumber(string.sub(stringdata,4,#stringdata))
	elseif string.find(stringdata,"ACCURACY") then
		local AccFormat = string.sub(stringdata,10,#stringdata)
		local _next = string.find(AccFormat," ")
		_next -= 1
		local a = 1
		for i = 1,4 do
			FinaleReplayData.Accuracy[i] = tonumber(string.sub(AccFormat,a,_next))
			a = _next
			if i <= 3 then
				if i < 3 then
					_next = string.find(AccFormat," ",_next+1)
				else
					_next = string.find(AccFormat,"\n",_next+1)
				end
			end
		end
	elseif string.find(stringdata,"MOD") then
		local ModFormatString = string.sub(stringdata,5,#stringdata)
		local BitBoolean = {["0"]=false,["1"]=true}
		-- MOD StableNL EnableTouchDevice AT HC HD HR EZ SL FL

		local ModFormat = {
			"--osuStableNotelock",
			"Replay_TouchDevice",
			"AutoPlay",
			"NoFail",
			"HiddenMod",
			"HardRock",
			"EasyMod",
			"SliderMode",
			"Flashlight"
		}
		for i = 1,#ModFormatString do
			getfenv()[ModFormat[i]] = BitBoolean[string.sub(ModFormatString,i,i)]
		end
	elseif string.find(stringdata,"FILENAME") then
		local Filename = string.sub(stringdata,10,#stringdata)
		FinaleReplayData.FileName = Filename
		BeatmapStudio = workspace.Beatmaps:FindFirstChild(Filename) or workspace.ProcessingBeatmap:FindFirstChild(Filename)
	elseif string.find(stringdata,"SPEED") then
		FinaleReplayData.Speed = tonumber(string.sub(stringdata,7,#stringdata)) or 1
	end
end

script.Parent.ReplayCall.Event:Connect(function(replaydata)
	ReplayDataRaw = replaydata

	local i = 1
	local Finish = false
	local count = 0
	repeat 
		local Next,_ = string.find(ReplayDataRaw,"\n",i)
		if not Next then
			Finish = true
			break
		elseif i == 0 or not tonumber(string.sub(ReplayDataRaw,i,i)) then
			ProcessReplayData(string.sub(ReplayDataRaw,i,Next-1))
			i = Next+1
			continue
		end
		Finish = true
		i = Next+1
	until Finish == true


	script.Parent.GameplayData.LeaderboardData.Value = "[]"

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

	ReplayMode = true


	game.ReplicatedStorage.Gameplay.UpdateStatus:FireServer(3)
	script.Parent.StartGame:Fire()
end)



spawn(function()
	--script.Parent:WaitForChild("_FastRestart",math.huge)
	if StartupState == "FastRestart" then
		if not StateReady then
			repeat wait() until StateReady
		end
		script.Parent.StartGame:Fire()
	end
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
StateReady = true
script.Parent.StartGame.Event:Wait() -- The game start from here

local SavedGameSettings = game.Players.LocalPlayer.PlayerGui.Settings.SettingFrame.BaseFrame.MainLayer.SettingsManage.getSettings:Invoke("All")

if not StartButtonAnimated then
	AnimateStartButton()
end


PlayerGui.MenuInterface.DropdownMenu.MenuListAnimate.bindRequest:Fire(false)

TweenService:Create(CurrentPreviewFrame.OverviewSong.EqualizerSoundEffect,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{HighGain = -20,MidGain = -20}):Play()
if CurrentPreviewFrame:FindFirstChild("OverviewSong2") then
	TweenService:Create(CurrentPreviewFrame.OverviewSong2.EqualizerSoundEffect,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{HighGain = -20,MidGain = -20}):Play()
end

OnMultiplayer = not PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.Disabled  -- Multiplayer

if OnMultiplayer then
	if (game.PlaceId == 6983932919 and not RunService:IsStudio()) or (LocalPlayer.UserId >= 1 and LocalPlayer.UserId ~= 1241445502 and LocalPlayer.UserId ~= 1608539863 and LocalPlayer.UserId ~= 1447265087) then
		AutoPlay = false
	end
	if isHost then
		local MapData = script.Parent.GetMapData:Invoke()

		PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.MultiplayerFolder.Value.StartGameRequest:InvokeServer(MapData)
	end
end

StarterGui:SetCore("ResetButtonCallback",script.Parent.RestartGame.ResetcharacterCallback)
local isLoaded = false
BeatmapStarted = true



ProcessFunction(function()
	repeat wait() until isLoaded
	for i = 1,30 do
		wait()
	end
	--TweenService:Create(script.Parent.Interface.BG,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false),{BackgroundTransparency = 1}):Play()
	TweenService:Create(CurrentPreviewFrame.OverviewSong.EqualizerSoundEffect,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{HighGain = 0,MidGain = 0}):Play()
	TweenService:Create(CurrentPreviewFrame.OverviewSong,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{Volume = 0}):Play()
	
	if CurrentPreviewFrame:FindFirstChild("OverviewSong2") then
		TweenService:Create(CurrentPreviewFrame.OverviewSong2.EqualizerSoundEffect,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{HighGain = 0,MidGain = 0}):Play()
		TweenService:Create(CurrentPreviewFrame.OverviewSong2,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{Volume = 0}):Play()
	end
	TweenService:Create(script.Parent.Interface.Background,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{GroupTransparency = 1}):Play()
	wait(0.25)
	script.Parent.Interface.Background.Visible = false
	CurrentPreviewFrame.OverviewSong.Playing = false
	if CurrentPreviewFrame:FindFirstChild("OverviewSong2") then
		CurrentPreviewFrame.OverviewSong2.Playing = false
	end
end)

do
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
	if StartupState == "Normal" then	
		TweenService:Create(script.Parent.Interface.Background,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{GroupTransparency = 0}):Play()
		wait(1)
	else
		script.Parent.Interface.Background.GroupTransparency = 0
	end
end



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

ProcessFunction(function()
	wait()
	BackgroundFrame.Position = UDim2.new(0.5,0,0.5,0)
	BackgroundFrame.Size = UDim2.new(1,0,1,0)
end)

if isSpectating or AutoPlay then
	DisableChatInGame = false
end

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,not DisableChatInGame)
if DisableChatInGame then
	StarterGui:SetCore("ChatActive",false)
end


Instance.new("BoolValue",script.Parent).Name = "GameStarted"

local Settings = CurrentSetting.MainSettings
--
local CS = 5
local ApproachRate = 5
local OverallDifficulty = 5


-- Load settings from Object data into Script data

SongSpeed = tonumber(Settings.Speed.Text)
SongDelay = SavedGameSettings.AudioOffset
Beatmap = Settings.BeatmapFile.Text
CursorSensitivity = SavedGameSettings.VirtualCursorSensitivity
CursorID = SavedGameSettings.CursorID
CursorSize = SavedGameSettings.CursorSize
CustomDiff = false
CursorTrailId = SavedGameSettings.CursorTrailID
CursorTrailSize = SavedGameSettings.CursorTrailSize
CursorTrailTransparency = 1-(SavedGameSettings.CursorTrailOpacity)*0.01
CircleImageId = SavedGameSettings.BaseCircleID
CircleOverlayImageId = SavedGameSettings.CircleOverlayID
ApproachCircleImageId = SavedGameSettings.ApproachCircleID
EffectVolume = SavedGameSettings.EffectVolume
HitZoneArea = SavedGameSettings.HitzoneArea * 0.01
SongVolume = SavedGameSettings.SongVolume
ClassicNotelock = not AutoPlay and SavedGameSettings.ClassicNotelock or true -- If enabled, it will use osu!stable notelock system, else it will use osu!lazer system
PSLeaderboard = SavedGameSettings.UsePSLeaderboard
CursorTrailEnabled = SavedGameSettings.CursorTrail
EnableTouchDevice = SavedGameSettings.EnableTouchDevice
MouseButtonEnabled = SavedGameSettings.MouseButton
OldCursorMovement = not SavedGameSettings.VirtualCursor
PSDisplay = SavedGameSettings.PerfomanceOverlay
OldInterface = SavedGameSettings.LegacyOverlay
HitErrorEnabled = SavedGameSettings.HitError
OverallInterfaceEnabled = SavedGameSettings.ScoreOverlay
MobileModeRightHitZone = SavedGameSettings.RightSizeHitzone
DisableChatInGame = SavedGameSettings.DisableChatIngame
KeepOriginalPitch = SavedGameSettings.EnableSpeedPitch
InGameLeaderboard = SavedGameSettings.ShowInGameLeaderboard
HitZoneEnabled = SavedGameSettings.EnableHitzone
CustomComboColorEnabled = SavedGameSettings.CustomComboColor
OptimizedPerfomance = SavedGameSettings.OptimizedPerfomance
DetailedPSDisplay = SavedGameSettings.DetailedPerformance
ExclusiveEffects = false--SavedGameSettings.
InstaFadeCircle = SavedGameSettings.InstaFadeCircle
ScoreV2Enabled = SavedGameSettings.ScoreV2
HitKeyOverlay = SavedGameSettings.KeyOverlay
LiveDifficultyDisplay = SavedGameSettings.LiveDifficultyOverlay
Hit300Display = SavedGameSettings.ShowHit300
Key1Input = Enum.KeyCode:FromName(SavedGameSettings.LeftKey)
Key2Input = Enum.KeyCode:FromName(SavedGameSettings.RightKey)
DefaultBackgroundTrans = 1-(SavedGameSettings.BGDim * 0.01)
EnableSliderShadow = SavedGameSettings.EnableSliderShadow

if OnMultiplayer then
	ScoreV2Enabled = MPScoreV2Enabled
end

function checkFPSCounterPos()
	if PSDisplay then
		if DetailedPSDisplay then
			if workspace.CurrentCamera.ViewportSize.Y >= 470 then
				TweenService:Create(PlayerGui.OverallInterface.FPSCounter,
					TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(1,-10,1,-95)}
				):Play()
			else
				TweenService:Create(PlayerGui.OverallInterface.FPSCounter,
					TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(1,-10,0.5,-110)}
				):Play()
			end
		else
			if workspace.CurrentCamera.ViewportSize.Y >= 520 then
				TweenService:Create(PlayerGui.OverallInterface.FPSCounter,
					TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(1,-10,1,-50)}
				):Play()
			else
				TweenService:Create(PlayerGui.OverallInterface.FPSCounter,
					TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(1,-10,0.5,-110)}
				):Play()
			end
		end
	else
		TweenService:Create(PlayerGui.OverallInterface.FPSCounter,
			TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(1,-10,1,-40)}
		):Play()
	end
end

function updateLbState(state)
	script.Parent.Leaderboard.StateEnabled.Value = state
	script.Parent.MultiplayerLeaderboard.StateEnabled.Value = state
	script.Parent.Leaderboard.LbTrigger:Fire(state)
	script.Parent.MultiplayerLeaderboard.LbTrigger:Fire(state)
end

function toggleScoreOverlay()
	-- Old score interface
	script.Parent.AccurancyDisplay.Visible = OverallInterfaceEnabled and OldInterface
	script.Parent.ComboDisplay.Visible = OverallInterfaceEnabled and OldInterface
	script.Parent.ScoreDisplay.Visible = OverallInterfaceEnabled and OldInterface
	-- New score interface
	script.Parent.ScoreFrameDisplay.Visible = OverallInterfaceEnabled and not OldInterface
	script.Parent.AccurancyFrameDisplay.Visible = OverallInterfaceEnabled and not OldInterface
	script.Parent.ComboFrameDisplay.Visible = OverallInterfaceEnabled and not OldInterface
end
toggleScoreOverlay()
updateLbState(InGameLeaderboard)

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(checkFPSCounterPos)

checkFPSCounterPos()

function ToggleDirectChange(settingName, callback)
	GameSettingManage.SubscribeSettingChange:Fire(settingName, script, callback)
end

ToggleDirectChange("InstaFadeCircle", function(value) InstaFadeCircle = value end)
ToggleDirectChange("OptimizedPerfomance", function(value)
	OptimizedPerfomance = value
	script.Parent.PSEarned.AnimatedPSEarned.Visible = not value
	script.Parent.PSEarned.TextTransparency = value and 0 or 1
end)
ToggleDirectChange("ShowHit300", function(value) Hit300Display = value end)
ToggleDirectChange("ScoreV2", function(value) ScoreV2Enabled = value end)
ToggleDirectChange("BGDim", function(value)
	DefaultBackgroundTrans = 1-(value * 0.01)
	TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans}):Play()
end)
ToggleDirectChange("LiveDifficultyOverlay", function(value) LiveDifficultyDisplay = value end)
ToggleDirectChange("PerfomanceOverlay", function(value)
	PSDisplay = value
	script.Parent.PSEarned.Visible = value

	checkFPSCounterPos()
end)
ToggleDirectChange("DetailedPerformance", function(value)
	DetailedPSDisplay = value
	script.Parent.PSEarned.DetailedDisplay.Visible = value

	checkFPSCounterPos()
end)
ToggleDirectChange("EnableSliderShadow", function(value) EnableSliderShadow = value end)
ToggleDirectChange("ShowInGameLeaderboard", function(value)
	InGameLeaderboard = value
	updateLbState(value)
end)
ToggleDirectChange("CursorTrail", function(value)
	script.Parent.Cursor.TrailEnabled.Value = value
end)
ToggleDirectChange("CursorTrailDuration", function(value)
	script.Parent.Cursor.FadeTime.Value = value
end)
ToggleDirectChange("LegacyOverlay", function(value)
	OldInterface = value
	toggleScoreOverlay()
end)
ToggleDirectChange("ScoreOverlay", function(value)
	OverallInterfaceEnabled = value
	toggleScoreOverlay()
end)



CircleConfigData = {
	Overlap = SavedGameSettings.NumberOverlaps,
	NumberScale = SavedGameSettings.NumberDisplaySize
}

CircleNumberData = {
	["0"] = SavedGameSettings.Number0,
	["1"] = SavedGameSettings.Number1,
	["2"] = SavedGameSettings.Number2,
	["3"] = SavedGameSettings.Number3,
	["4"] = SavedGameSettings.Number4,
	["5"] = SavedGameSettings.Number5,
	["6"] = SavedGameSettings.Number6,
	["7"] = SavedGameSettings.Number7,
	["8"] = SavedGameSettings.Number8,
	["9"] = SavedGameSettings.Number9
}

--CircleNumberData = HttpService:JSONDecode(Settings.Parent.VirtualSettings.CircleNumberData.Value)
--CircleConfigData = HttpService:JSONDecode(Settings.Parent.VirtualSettings.CircleConfigData.Value)

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
-- Apply settings

script.Parent.Parent.BG.OutlineStuff:Destroy()
script.Parent.Parent.BG.MultiplayerButton:Destroy()
script.Parent.Parent.BG.SettingsButton:Destroy()

PlayerGui.SavedSettings:ClearAllChildren()
CurrentSetting.Parent = PlayerGui.SavedSettings
CurrentSetting.AnchorPoint = Vector2.new(1,0)
--CurrentSetting.GroupTransparency = 1
UIPreviewFrame.Parent = PlayerGui.SavedSettings
UIPreviewFrame.AnchorPoint = Vector2.new(0,0)
script.Parent.Parent.BG.BeatmapChooseButton.Visible = false
script.Parent.Cursor.TrailEnabled.Value = CursorTrailEnabled
script.Parent.Cursor.FadeTime.Value = SavedGameSettings.CursorTrailDuration
script.Parent.Parent.BG.BeatmapCount.Visible = false
script.Parent.Parent.BG.BeatmapLeaderboard.Visible = false
script.Parent.Parent.BG.GameVersion.Visible = false
PlayerGui.MenuInterface.PlayerListButton.Visible = false
PlayerGui.MenuInterface.LeaderboardButton.Visible = false
PlayerGui.MenuInterface.ProfileButton.Visible = false
PlayerGui.MenuInterface.MultiplayerButton.Visible = false
PlayerGui.MenuInterface.UpdateLogButton.Visible = false
PlayerGui.MenuInterface.ExpandButton.ExpandButton.Visible = false
PlayerGui.MenuInterface.WikiButton.Visible = false
script.Parent.Parent.BG.BeatmapLeaderboard.GolbalLeaderboard:ClearAllChildren()

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
	NoFail = SavedSpectateData.HC
	Flashlight = SavedSpectateData.FL
	HardRock = SavedSpectateData.HR
	TouchDeviceDetected = SavedSpectateData.TD
end
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
		HC = NoFail,
		StableNotelock = osuStableNotelock
	}]]

		HiddenMod = MultiplayerData.MatchData.HD
		HardRock = MultiplayerData.MatchData.HR
		Flashlight = MultiplayerData.MatchData.FL
		SliderMode = MultiplayerData.MatchData.SL
		NoFail = MultiplayerData.MatchData.NF
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
	MPScoreV2Enabled = MultiplayerData.MatchData.ScoreV2
end

-- load spectate data

if isSpectating == true then
	ClassicNotelock = SavedSpectateData.StableNotelock
end

-- Replay data
if ReplayMode then
	SongSpeed = FinaleReplayData.Speed
end


-- Get beatmap data

local BeatmapData,ReturnData,TimingPoints,BeatmapComboColor = require(workspace.OsuConvert)(FileType,Beatmap,SongSpeed,SongDelay,true,false,false,HardRock,Flashlight,EasyMod,HiddenMod)

--------------------------------------------------------------------------------------------------------------------------------------------

CurrentKey = ReturnData.BeatmapSetsData.BeatmapsetID.."-"..ReturnData.BeatmapSetsData.BeatmapID
BeatmapKey = ReturnData.BeatmapSetsData.BeatmapID
script.Parent.GameplayData.SongSpeed.Value = SongSpeed

-- BackgroundChange
local Background = PlayerGui.BG.Background.Background

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

-----------
PlayerGui.BG.GameTitle.Visible = false
script.Parent.HitKey.Visible = HitKeyOverlay

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

for _,a in pairs(script.Circle:GetChildren()) do
	a:Clone().Parent = script.Circle_FL
end

-- Remove unused content

for _,a in pairs(PlayerGui.BG:GetChildren()) do
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
-- indicate if the map have 2 song
-- this is mostly possible on 7+ minute song length
ExistSecondSong = (ReturnData.MapSongId2 ~= nil)
if ReturnData.MapSongId or ReturnData.CustomSongFile then
	script.Parent.Song.SoundId = ReturnData.CustomSongFile or "rbxassetid://"..tostring(ReturnData.MapSongId)
	script.Parent.Song2.SoundId = ExistSecondSong and "rbxassetid://"..tostring(ReturnData.MapSongId2) or ""
end

-- load all the assets
ContentList = {}

function CheckDupeContent(obj)
	for _,a in pairs(ContentList) do
		if a.ClassName == obj.ClassName then
			if (obj:IsA("ImageLabel") or obj:IsA("ImageButton")) and obj.Image == a.Image then
				return false
			elseif obj:IsA("Sound") and obj.SoundId == a.SoundId then
				return false
			end
		end
	end
	return true
end
for _,obj in pairs(script.Parent:GetDescendants()) do
	if not (obj:IsA("ImageLabel") or obj:IsA("ImageButton") or obj:IsA("Sound")) or not CheckDupeContent(obj) then continue end
	ContentList[#ContentList+1] = obj
end

pcall(function()
	for i = 1,10 do wait() end
	local ContentLoadingUI = script.Parent.ContentLoadingUI
	ContentLoadingUI.Visible = true

	local DiffFormat = ReturnData.Difficulty.BeatmapDifficulty
	if DiffFormat > 10 then DiffFormat = 10 end

	local HColor =  (DiffFormat <= 1.5 and 200) or (DiffFormat <= 4.5 and (1-(DiffFormat/4.5))*200) or (DiffFormat <= 6.5 and 360-((DiffFormat-4.5)/2)*120) or (DiffFormat <= 9.9 and 240) or 0
	local SColor = (DiffFormat <= 8.5 and 255) or (DiffFormat <= 10 and 255 - (DiffFormat-8.5)*170) or (DiffFormat <= 12 and (DiffFormat-10)*127.5) or 255--(diffdata.DiffRating <= 6.5 and 140) or (140 + (diffdata.DiffRating-6.5)*40)
	local VColor = (DiffFormat <= 6.5 and 255) or (DiffFormat < 9 and 255 - (DiffFormat-6.5)*102) or 0

	HColor /= 360
	SColor /= 255
	VColor /= 255


	if DiffFormat >= 6 then
		ContentLoadingUI.BeatmapDisplay.Difficulty.UIStroke.Enabled = true
	end

	ContentLoadingUI.BeatmapDisplay.Title.Text = ReturnData.Overview.Metadata.MapName
	ContentLoadingUI.BeatmapDisplay.Artist.Text = ReturnData.Overview.Metadata.SongCreator
	ContentLoadingUI.BeatmapDisplay.Difficulty.TextColor3 = Color3.fromHSV(HColor,SColor,VColor)
	ContentLoadingUI.BeatmapDisplay.Difficulty.Text = string.format("[%.2f] %s",ReturnData.Difficulty.BeatmapDifficulty,ReturnData.Overview.Metadata.DifficultyName)


	TweenService:Create(ContentLoadingUI,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
		Size = UDim2.new(1,0,0.25,0),GroupTransparency = 0
	}):Play()

	TweenService:Create(ContentLoadingUI.UISizeConstraint,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
		MaxSize = Vector2.new(math.huge,120)
	}):Play()
	for phrase = 1,2 do -- check twice
		local ContentLoaded = 0 -- default
		game:GetService("ContentProvider"):PreloadAsync(ContentList,function()
			ContentLoaded += 1
			local progress = (ContentLoaded/#ContentList) * 0.9
			if phrase == 2 then
				progress = 0.9 + (ContentLoaded/#ContentList) * 0.1
			end
			TweenService:Create(ContentLoadingUI.ProgressBar.Progress,TweenInfo.new(0.1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
				Size = UDim2.new(progress,0,1,0)
			}):Play()

		end)
	end

	ContentLoadingUI.LoadUIDisplay.LoadText.Text = "Ready!"
	TweenService:Create(ContentLoadingUI.ProgressBar.Progress,TweenInfo.new(0.1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
		Size = UDim2.new(1,0,1,0)
	}):Play()
	wait(2)

	TweenService:Create(ContentLoadingUI,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
		Size = UDim2.new(1,0,0.17,0),GroupTransparency = 1
	}):Play()

	TweenService:Create(ContentLoadingUI.UISizeConstraint,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
		MaxSize = Vector2.new(math.huge,80)
	}):Play()

	if OnMultiplayer then
		script.Parent.MultiplayerWaitFrame.Visible = true
		local PlayersInMatch = PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.MultiplayerFolder.Value.WaitForAllLoaded:InvokeServer()
		script.Parent.MultiplayerLeaderboard.MultiplayerData.Value = HttpService:JSONEncode(PlayersInMatch)
		script.Parent.MultiplayerWaitFrame.Visible = false
	end
	TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans+0.2}):Play()
	TweenService:Create(StartButton,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{Size = UDim2.new(0.2,0,0.2,0),BackgroundTransparency = 1}):Play()
	TweenService:Create(StartButton._Text,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{ImageTransparency = 1}):Play()

	spawn(function()
		wait(1)
		script.Parent.Parent.BG.StartButtonBeatAnimation:Destroy()
		StartButton:Destroy()
		ContentLoadingUI.Visible = false
	end)

end)




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
		if CS > math.max(7,Difficulty.CircleSize) then
			CS = math.max(7,Difficulty.CircleSize)
		end
		if ApproachRate > math.max(10,Difficulty.ApproachRate) then
			ApproachRate = math.max(10,Difficulty.ApproachRate)
		end
		if OverallDifficulty > math.max(10,Difficulty.OverallDifficulty)  then
			OverallDifficulty = math.max(10,Difficulty.OverallDifficulty)
		end
		if HPDrain > math.max(10,Difficulty.HPDrainRate) then
			HPDrain = math.max(10,Difficulty.HPDrainRate)
		end
	end

	if tonumber(CustomHP) then
		HPDrain = CustomHP
		if not NoFail then
			CustomDiff = true
		end
	end

	if tonumber(CustomCS) then
		CustomDiff = true
		CS = CustomCS
	end
	if tonumber(CustomAR) then
		ApproachRate = CustomAR
		CustomDiff = true
	end
	if tonumber(CustomOD) then
		CustomDiff = true
		OverallDifficulty = CustomOD
	end

	if not SpeedSync and Flashlight then
		CustomDiff = true
	end


	if CS == nil or ((not CustomCS and (CS < 0 or CS > 11)) or CS < 0 or CS > 11) then
		CS = 4
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
	AutoPlay == false or (LocalPlayer.UserId == 1241445502 and RunService:IsStudio() and false),
	ReplayMode == false,
	SpeedSync == true,
	not LocalPlayer:FindFirstChild("PlayerUnranked"),
	CustomDiff == false,
	isSpectating == false,
	LocalPlayer.UserId >= 1,
	onTutorial == false
}

ProcessFunction(function()
	wait(2)
	for _,Requirement in pairs(RankedRequirement) do
		if not Requirement then
			PlayRanked = false
			break
		end
	end

	script.Parent.UnrankedSign.Visible = not PlayRanked
end)
--[[
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Return and game.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		PlayRanked = false
		if not AutoPlay then
			AutoPlay = true
			script.Parent.UnrankedSign.Text = "AUTOPLAY"
			warn("[SYSTEM] AutoPlay has been Enabled")
		else
			AutoPlay = false
			script.Parent.UnrankedSign.Text = "UNRANKED"
			warn("[SYSTEM] AutoPlay has been Disabled")
		end
		
	end
end)
]]
--[[

if FileType ~= 1 or AutoPlay == true or SliderMode == true or script.Parent.TempSettings.ReplayMode.Value == true or LocalPlayer:FindFirstChild("PlayerUnranked") or CustomDiff == true or isSpectating == true then
	PlayRanked = false
end]]


if isSpectating == true or ReplayMode == true then
	script.Parent.UnrankedSign.Text = "SPECTATING"
elseif AutoPlay then
	script.Parent.UnrankedSign.Text = "AUTOPLAY"
elseif onTutorial == true then
	script.Parent.UnrankedSign.Text = "TUTORIAL"
	-- load the most default mode
	CS = 3.5
	ApproachRate = 4
	OverallDifficulty = 2
	AutoPlay = false
	SliderMode = true
	SongSpeed = 1
	HiddenMod = false
	HardRock = false
	EasyMod = false
	NoFail = false
end

local PlayingRemote
local StartPlayingTick = tick()
if isSpectating == false and (AutoPlay == false or ((LocalPlayer.UserId == 1241445502 or LocalPlayer.UserId == 1608539863) and game.PlaceId ~= 6983932919)) then
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
		HP = HPDrain,
		StableNotelock = ClassicNotelock,
		FL = Flashlight,
		NF = NoFail,
		HD = HiddenMod,
		HR = HardRock,
		TD = TouchDeviceDetected
	}
	PlayingRemote,SpectatorCountRemote = game.ReplicatedStorage.Gameplay.GetSpectateData:InvokeServer(LocalPlayer.UserId,Data)
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

CustomComboColor = HttpService:JSONDecode(Settings.Parent.VirtualSettings.CustomComboColor.Value)
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
local Tween
local Start = tick()+2
local SongStart = tick()+2

--local Cursor = script.Parent.PlayFrame.Cursor
local Cursor = script.Parent.CursorField.Cursor
--local DisplayingCursor = script.Parent.PlayFrame.Cursor
local CursorTrail = script.Cursor_Trail

local CursorPosition = Vector2.new(256,576)
local ATVC = Instance.new("Frame") -- AutoPlay Virtual Cursor
ATVC.Position = UDim2.new(0.5,0,1.5,0)

if AutoPlay == true then
	local ATCursor = ATVC
	ATCursor.Changed:Connect(function()
		CursorPosition = Vector2.new(ATCursor.Position.X.Scale*512,ATCursor.Position.Y.Scale*384)
	end)
end

local LastPosition = UDim2.new(CursorPosition.X/512,0,CursorPosition.Y/384,0)

RunService.RenderStepped:Connect(function()
	if CursorPosition ~= LastPosition then
		Cursor.Position = UDim2.new(CursorPosition.X/512,0,CursorPosition.Y/384,0)
	end
	LastPosition = CursorPosition
end)


if isSpectating == true then
	Start = tick()+2
	SongStart = tick()+2
end



if tonumber(ReturnData.BeatmapVolume) ~= nil and ReturnData.BeatmapVolume > 0 and ReturnData.BeatmapVolume < 10 then
	script.Parent.Song.Volume = ReturnData.BeatmapVolume*(SavedGameSettings.MusicVolume*0.01)
	script.Parent.Song2.Volume = ReturnData.BeatmapVolume*(SavedGameSettings.MusicVolume*0.01)
else
	script.Parent.Song.Volume = SavedGameSettings.MusicVolume*0.01
	script.Parent.Song2.Volume = SavedGameSettings.MusicVolume*0.01
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

script.Parent.HealthBar.Overlay.EZModHPCheckpoint.Visible = EasyMod
-- 3.2 per note
local MissDrain = 12.5	

if EasyMod then
	MaxHealthPoint = 300
end
-- HP rate:			0 - 5 - 10
-- Miss drain:		5 - 10.5 - 20
-- Miss until fail:	20 - 10 - 5

if HPDrain < 5 then
	MissDrain = 10.5 - 5.5 * (5 - HPDrain) / 5
else
	MissDrain = 10.5 + 9.5 * (HPDrain - 5) / 5
end

local HitnoteAnimations = {}
local GameOverAnimations = {}

script.Parent.HealthBar.Visible = showHealthBar

if not SliderMode then
	for _,HitObjData in pairs(BeatmapData) do
		TotalNote += 1
		if ObjectTools.GetObjectProperties(HitObjData.Type).isSlider then
			TotalSliders += tonumber(HitObjData.ExtraData[3])
		end
	end
	local Multiplier = (TotalNote + TotalSliders)/TotalNote
	MissDrain *= Multiplier
end

function GameOver()
	ProcessFunction(function()
		if BeatmapFailed or NoFail or ReplayMode then
			return
		end

		if OnMultiplayer then
			if not MultiplayerMatchFailed then
				MultiplayerMatchFailed = true
				PlayRanked = false
				PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("You've failed, but you can still continue to play.", Color3.fromRGB(255, 0, 0))
				return
			else
				return
			end
		end

		CursorUnlocked = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		Cursor.Visible = false
		PlayerGui.OsuCursor.Cursor.Visible = true
		script.Parent.FailSound:Play()

		local hpLeftTween = TweenService:Create(script.Parent.HealthBar.Overlay.HPLeft, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.new(0, 0, 1, 0) })
		hpLeftTween:Play()

		for _, tween in pairs(HitnoteAnimations) do
			ProcessFunction(function()
				if tween:IsA("Tween") then
					tween:Pause()
				end
			end)
		end
		BeatmapFailed = true
		Start = 1e20
		SongStart = 1e20

		--[[ NEW GAMEOVER ANIMATION
		for _, TweenObj in pairs(script.Parent.PlayFrame:GetChildren()) do
			if TweenObj:IsA("GuiObject") then
				if TweenObj.Name == "Slider" then
					for _,obj in pairs(TweenObj:GetChildren()) do
						ProcessFunction(function()
							require(script.Parent.GameplayScripts.UISeparate)(obj)
						end)
					end
					continue
				end
				ProcessFunction(function()
					require(script.Parent.GameplayScripts.UISeparate)(TweenObj)
				end)
			end
		end]]

		for _, TweenObj in pairs(script.Parent.PlayFrame:GetDescendants()) do
			if TweenObj.Name ~= "Cursor" and TweenObj.Name ~= "Flashlight" and TweenObj.Parent.Name ~= "MessagePatch" and TweenObj.Parent.Name ~= "CursorFade" and TweenObj:IsA("GuiObject") then
				local NewPos = TweenObj.Position + UDim2.new(0, math.random(-10, 10), 0, (TweenObj.AbsolutePosition.Y / workspace.CurrentCamera.ViewportSize.Y) * math.random(200, 400))
				local NewRotation = TweenObj.Rotation + math.random(-45, 45)
				local ImageTrans = (TweenObj:IsA("ImageLabel") and 1) or nil
				local TextTrans = (TweenObj:IsA("TextLabel") and 1) or nil
				TweenService:Create(TweenObj, TweenInfo.new(3, Enum.EasingStyle.Linear), { BackgroundTransparency = 1, ImageTransparency = ImageTrans, TextTransparency = TextTrans, Position = NewPos, Rotation = NewRotation }):Play()
			end
		end

		TweenService:Create(script.Parent.Song, TweenInfo.new(3, Enum.EasingStyle.Linear), {Volume = 0, PlaybackSpeed = 0 }):Play()
		wait(0.5)

		for _, TweenObj in pairs(script.Parent.PlayFrame:GetDescendants()) do
			if TweenObj.Name ~= "Cursor" and TweenObj.Name ~= "Flashlight" and TweenObj.Parent.Name ~= "MessagePatch" and TweenObj.Parent.Name ~= "CursorFade" and TweenObj:IsA("GuiObject") then
				local ImageTrans = (TweenObj:IsA("ImageLabel") and 1) or nil
				local TextTrans = (TweenObj:IsA("TextLabel") and 1) or nil
				TweenService:Create(TweenObj, TweenInfo.new(2.5, Enum.EasingStyle.Linear), { BackgroundTransparency = 1, ImageTransparency = ImageTrans, TextTransparency = TextTrans }):Play()
			end
		end

		wait(1.5)

		local restartGameTween = TweenService:Create(script.Parent.RestartGame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { TextTransparency = 1, BackgroundTransparency = 1 })
		restartGameTween:Play()

		ProcessFunction(function()
			wait(0.5)
			script.Parent.RestartGame.Visible = false
		end)


		local FailedScreen = script.Parent.FailedScreen

		FailedScreen.RestartBeatmap.Visible = true
		FailedScreen.ReturnGame_Failed.Visible = true

		local restartBeatmapTween = TweenService:Create(FailedScreen.RestartBeatmap, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5,0,0.5,-5),TextTransparency = 0, BackgroundTransparency = 0.1 })
		local returnGameFailedTween = TweenService:Create(FailedScreen.ReturnGame_Failed, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5,0,0.5,5), TextTransparency = 0, BackgroundTransparency = 0.1 })

		restartBeatmapTween:Play()
		returnGameFailedTween:Play()


		if AutoPlay == true then
			FailedScreen.Hint.HintText.Text = "Autoplay could fail sometimes, isn't it?"
		elseif isSpectating then
			FailedScreen.Hint.HintText.Text = "Player failed"
			script.Parent.RestartBeatmap.Visible = false
		else
			FailedScreen.Hint.HintText.Text = "You've failed, retry?"
		end

		local failedScreenTween = TweenService:Create(FailedScreen, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {BackgroundTransparency = 0.25 })
		local hintTextTween = TweenService:Create(FailedScreen.Hint.HintText, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0, Position = UDim2.new(0, 0, 0, 0) })
		local titleTween = TweenService:Create(FailedScreen.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0 })

		failedScreenTween:Play()
		hintTextTween:Play()
		titleTween:Play()

		wait(1)

		for _, a in pairs(script.Parent.PlayFrame:GetChildren()) do
			if a.Name ~= "FlashLight" then
				a:Destroy()
			end
		end
	end)
end

DrainSpeed = 1.75
CurrentDrainSpeed = 0
HealthDrainMultiplier = 1

function AddHealthDrainMultiplier(rate)
	HealthDrainMultiplier += rate * 0.1
end

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
		DrainSpeed = (5 - 2 * (5 - HPDrain) / 5) * HealthDrainMultiplier

	else
		DrainSpeed = (5 + 5 * (HPDrain - 5) / 5) * HealthDrainMultiplier

	end
	DrainSpeed*= SongSpeed
	while wait() do
		if isDrain then
			if HealthDrainMultiplier > 10 then
				HealthDrainMultiplier = 10
			end
			local DrainSpeed = 8

			-- base drain: 3 - 5 - 10
			-- Multiplier: 1 - 3

			if HPDrain < 5 then
				DrainSpeed = (5 - 2 * (5 - HPDrain) / 5) * HealthDrainMultiplier
			else
				DrainSpeed = (5 + 5 * (HPDrain - 5) / 5) * HealthDrainMultiplier
			end
			DrainSpeed *= SongSpeed
			CurrentDrainSpeed = DrainSpeed

			local HealthDrain = (((tick() - LastTick)*DrainSpeed))
			HealthPoint -= HealthDrain

			if HealthPoint < 10 and DrainSpeed >= 15 and NoFail and ReturnData.Difficulty.BeatmapDifficulty >= 6 and tick() - Start >= 60 then
				BadgeCondition.CloseOne = true
			end


			if HealthDrainMultiplier < 1 then
				HealthDrainMultiplier = 1
			end
			if HealthPoint < 0 then
				HealthPoint = 0
			elseif HealthPoint < MaxHealthPoint*((EZModCheckpoint-1)/3) and EasyMod then
				HealthPoint = MaxHealthPoint*((EZModCheckpoint-1)/3)
			end
		end
		local DrainMultiplierDrainSpeed = ((HealthDrainMultiplier-1) * 0.5) 
		if DrainMultiplierDrainSpeed < 1.5 then
			DrainMultiplierDrainSpeed = 1.5
		end
		local MultiplierDrain = (((tick() - LastTick)*DrainMultiplierDrainSpeed)) * SongSpeed
		HealthDrainMultiplier -= MultiplierDrain
		LastTick = tick()
	end
end)

function AddHP(HP)
	if isSpectating then return end
	HealthPoint += HP * 100
	if HealthPoint > MaxHealthPoint*(EZModCheckpoint/3) then
		HealthPoint = MaxHealthPoint*(EZModCheckpoint/3)
	end
end

local ImmortalTime = 0

function DrainHP(min, mid, max)
	if not ConditionFailed.AllComboGone and BeatmapData[#BeatmapData].Time > 120000 and ReturnData.Difficulty.BeatmapDifficulty >= 5 then
		local Progress = (tick() - SongStart) / (BeatmapData[#BeatmapData].Time/1000)
		if Progress < 0.9 and AccuracyData.miss > 1 then
			ConditionFailed.AllComboGone = true
		elseif Progress >= 0.9 and AccuracyData.miss > 1 then
			BadgeCondition.AllComboGone = true	
		end
	end

	if isSpectating then return end
	if tick() - ImmortalTime >= 0 then
		local scale = (HPDrain - 5) / 5
		local HPLose = mid

		if (HPDrain > 5) then
			HPLose = mid + (max - mid) * scale
		elseif (HPDrain < 5) then
			HPLose =  mid + (mid - min) * scale
		end
		HealthPoint += HPLose * 100
	end
	if EasyMod then
		if HealthPoint < MaxHealthPoint * ((EZModCheckpoint-1)/3) and EZModCheckpoint > 1 then
			HealthPoint = MaxHealthPoint * ((EZModCheckpoint-1)/3)
			EZModCheckpoint -= 1
			ImmortalTime = tick() + 0.5
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
	local HealthBar = script.Parent.HealthBar
	local HPLeft = HealthBar.Overlay.HPLeft
	local HolderFrame = HPLeft.Overlay.HolderFrame
	local HealthDisplay = HealthBar.HealthDisplay

	while wait() do
		if LastHPDrainSpeed ~= CurrentDrainSpeed and HealthPoint ~= 0 then
			if not OptimizedPerfomance then
				TweenService:Create(HPLeft.Overlay.HealthDrainSpeed, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new((CurrentDrainSpeed / 100) / (HealthPoint / 100), 0, 1, 0) }):Play()
			else
				HPLeft.Overlay.HealthDrainSpeed.Size = UDim2.new((CurrentDrainSpeed / 100) / (HealthPoint / 100), 0, 1, 0)
			end
		end
--[[
		if HealthPoint < 40 and isDrain then
			local transparency = 0.5 * HealthPoint / 40
			local color = Color3.fromHSV(0, 1 - HealthPoint / 40, 0.588235 + 0.411765 * (1 - HealthPoint / 40))
			TweenService:Create(HealthBar, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundTransparency = transparency, BackgroundColor3 = color }):Play()
		else
			TweenService:Create(HealthBar, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromHSV(0, 0, 0.588235) }):Play()
		end]]

		if HealthPoint ~= LastHP or HealthPoint == 0 then
			if OptimizedPerfomance then
				HPLeft.Size = UDim2.new(HealthPoint / 100, 0, 1, 0)
			else
				if HealthPoint ~= 0 then
					TweenService:Create(HPLeft.Overlay.HealthDrainSpeed, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.new((CurrentDrainSpeed / MaxHealthPoint) / (HealthPoint / MaxHealthPoint), 0, 1, 0) }):Play()
				end
				TweenService:Create(HPLeft, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.new(HealthPoint / MaxHealthPoint, 0, 1, 0) }):Play()
			end
			-- -0.03, -0.125, -0.2
			
			local scale = (HPDrain - 5) / 5
			local HPMissDrain = 12.5

			if (HPDrain > 5) then
				HPMissDrain = 12.5 + (20 - 12.5) * scale
			elseif (HPDrain < 5) then
				HPMissDrain =  12.5 + (12.5 - 0.03) * scale
			end
			
			local MissLeftBeforeFail = math.ceil(HealthPoint/(HPMissDrain + 1))
			local display = ""
			if HealthPoint < 50 and not NoFail then
				display = string.format('<font color = "#ff0000">(%d)</font>',MissLeftBeforeFail)
			end
			
			HealthDisplay.Text = tostring(math.ceil(HPLeft.Size.X.Scale * 100)) .. "% "..display

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
				HolderFrame.BackgroundTransparency = HolderTrans
			else
				TweenService:Create(HolderFrame, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundTransparency = HolderTrans }):Play()
			end
		end

		LastHP = HealthPoint
		LastHPDrainSpeed = CurrentDrainSpeed
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
		script.Parent.Song2.Volume = 0
		script.Parent.GameplayResume.Event:Wait()
		script.Parent.Song.Volume = ReturnData.BeatmapVolume*(SongVolume*0.01)
		script.Parent.Song2.Volume = ReturnData.BeatmapVolume*(SongVolume*0.01)
		Start = tick() - TimeElapsed
		SongStart = tick() - TimeElapsed
	end
end)

script.Parent.ProgressBar.Visible = true
spawn(function()
	local TimeBreak = 3+BeatmapData[1].Time/1000
	repeat TweenService:Create(script.Parent.ProgressBar.Time,TweenInfo.new(0.05,Enum.EasingStyle.Linear),{Size = UDim2.new(-((tick()-Start) - BeatmapData[1].Time/1000)/TimeBreak,0,1,0)}):Play() wait() until (tick()-Start)*1000 >= BeatmapData[1].Time
	script.Parent.ProgressBar.Time.BackgroundColor3 = Color3.new(1,1,1)
	TweenService:Create(script.Parent.ProgressBar.TimeLeft.Time,TweenInfo.new(0.75,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{TextTransparency = 0}):Play()
	--TweenService:Create(script.Parent.ProgressBar.Time,TweenInfo.new((BeatmapData[#BeatmapData].Time-BeatmapData[1].Time)/1000,Enum.EasingStyle.Linear),{Size = UDim2.new(1,0,1,0)}):Play()

	local TotalTime = (BeatmapData[#BeatmapData].Time-BeatmapData[1].Time)/1000
	while tick() - Start < BeatmapData[#BeatmapData].Time/1000 and not ScoreResultDisplay do
		wait()
		local FullTimeLeft = BeatmapData[#BeatmapData].Time/1000 - (tick() - Start)
		local maxTime = (BeatmapData[#BeatmapData].Time - BeatmapData[1].Time)/1000
		local TimeLeft = math.ceil(FullTimeLeft)

		local Min = TimeLeft/60
		local Sec = math.abs(TimeLeft%60)
		local Min_max = maxTime/60
		local Sec_max = math.abs(maxTime%60)



		local StringOutput = string.format("%d:%.2d", Min, Sec)
		local StringOutput_max = string.format("%d:%.2d", Min_max, Sec_max)
		if tick() - Start > -0.5 then
			script.Parent.ProgressBar.TimeLeft.Time.Text = StringOutput.."/"..StringOutput_max
		else
			script.Parent.ProgressBar.TimeLeft.Time.Text = ""
		end
		TweenService:Create(script.Parent.ProgressBar.Time,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{Size = UDim2.new(1-(FullTimeLeft/TotalTime),0,1,0)}):Play()
	end
	TweenService:Create(script.Parent.ProgressBar.TimeLeft.Time,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{TextTransparency = 1}):Play()
end)


if AutoPlay == true and ReplayMode ~= true then
	spawn(function()
		repeat wait() until (tick()-Start)*1000 >= BeatmapData[1].Time-1000
		TweenService:Create(ATVC,TweenInfo.new(0.5,Enum.EasingStyle.Sine),{Position = UDim2.new(0.5,0,0.5,0)}):Play()
	end)
end

local Connection
local Connection2

spawn(function()
	wait(2)
	if BeatmapData[1].Time > 4000 then
		script.Parent.SkipButton.Visible = true
		TweenService:Create(script.Parent.SkipButton,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,0.8,0),GroupTransparency = 0}):Play()
		if EnableTouchDevice and UserInputService.TouchEnabled then
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
			TweenService:Create(script.Parent.SkipButton,TweenInfo.new(0.5,Enum.EasingStyle.Sine		,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,0.8,40),GroupTransparency = 1}):Play()
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
				PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("Skip request sent.",Color3.new(1,1,1))				
				PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.MultiplayerFolder.Value.SkipSongRequest:InvokeServer()
				SkipSong()
			end
		end

		Connection = script.Parent.SkipButton.SkipButton.MouseButton1Click:Connect(Trigger)
		Connection2 = UserInputService.InputBegan:Connect(function(data)
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
		TweenService:Create(script.Parent.SkipButton,TweenInfo.new(1,Enum.EasingStyle.Exponential,Enum.EasingDirection.In),{Position = UDim2.new(0.5,0,0.8,40) ,GroupTransparency = 1}):Play()
	end
end)

script.Parent.Development.GetCurrentAudioLatency.OnInvoke = function()
	-- return the latency result in ms
	return ((tick() - SongStart)*SongSpeed*ReturnData.SongSpeed - script.Parent.Song.TimePosition) * 1000
end

-- align the song with the time
spawn(function()
	local MinimumLatency = 0.04 -- secs
	repeat wait(0.1) until script.Parent.Song.IsLoaded == true
	while wait(0.1) do
		pcall(function()
			local checkingSongObj = script.Parent.Song
			local ExtraLength = 0
			if ExistSecondSong and ((tick() - SongStart)*SongSpeed*ReturnData.SongSpeed > script.Parent.Song.TimeLength) then
				ExtraLength = script.Parent.Song.TimeLength
				checkingSongObj = script.Parent.Song2
				if script.Parent.Song.Playing then
					script.Parent.Song.Playing = false
					script.Parent.Song2:Play()
					-- the first song must stop
				end
			elseif script.Parent.Song2.Playing then
				script.Parent.Song2.Playing = false
			end
			if math.abs((checkingSongObj.TimePosition + ExtraLength) - ((tick() - SongStart)*SongSpeed*ReturnData.SongSpeed)) > 0.04 and script.Parent.Song.IsLoaded == true and (tick() - Start) <= BeatmapData[#BeatmapData].Time/1000 and not BeatmapFailed then
				checkingSongObj.TimePosition = (tick() - SongStart)*SongSpeed*ReturnData.SongSpeed - ExtraLength
			end
			if tick()-SongStart >= 0 and checkingSongObj.Playing == false and (tick() - Start) <= BeatmapData[#BeatmapData].Time/1000 then
				checkingSongObj.Playing = true
			end
			if CurrentPreviewFrame.OverviewSong.Playing == true and tick()-SongStart >= 0.5 then
				CurrentPreviewFrame.OverviewSong.Playing = false
			end
			
			if CurrentPreviewFrame:FindFirstChild("OverviewSong2") and CurrentPreviewFrame.OverviewSong2.Playing == true and tick()-SongStart >= 0.5 then
				CurrentPreviewFrame.OverviewSong2.Playing = false
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

local RblxNewCursor = PlayerGui.OsuCursor.Cursor
--local CursorUnlocked = false -- this will change to true at the end of the play

if AutoPlay or isSpectating then
	local restartframeposvalue = Instance.new("BoolValue",script.Parent.ScriptSettings)
	restartframeposvalue.Name = "RestartGameRightSite"
	restartframeposvalue.Value = false
end

if AutoPlay == false and ReplayMode ~= true and isSpectating == false then
	local PlayerMouse = LocalPlayer:GetMouse()
	--PlayerMouse.Icon = "http://www.roblox.com/asset/?id=7017066525"
	--UserInputService.MouseIconEnabled = false
	RblxNewCursor.Visible = false
	local MobileHold = false

	local isTouchOutsiteHitzone = false
	local TouchCount = 0

	local function isInHitzone(pos)
		local Hitzone = script.Parent.MobileHit
		local HitzoneMaxposX = Hitzone.AbsoluteSize.X

		return pos.X < HitzoneMaxposX
	end

	if UserInputService.TouchEnabled and EnableTouchDevice == true then
		script.Parent.RestartGame.Text = "Exit (Hold)"
		if HitZoneEnabled then
			TweenService:Create(script.Parent.MobileHit,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(HitZoneArea,0,1,0)}):Play()
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
				script.Parent.ComboFrameDisplay.ComboFrameDisplay.Position = UDim2.new(0,0,1,-23)
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
			if (not isTouchOutsiteHitzone) and isInHitzone(PlayerMouse) then return end
			local Offset = PlayerGui.PlayScreen.AbsolutePosition.Y
			local NewPos = (Vector2.new(PlayerMouse.X-(script.Parent.AbsoluteSize.X-script.Parent.PlayFrame.AbsoluteSize.X)/2,(PlayerMouse.Y)-(script.Parent.AbsoluteSize.Y-script.Parent.PlayFrame.AbsoluteSize.Y)/2))
			NewPos = UDim2.new(NewPos.X/script.Parent.PlayFrame.AbsoluteSize.X,0,(NewPos.Y-Offset)/(script.Parent.PlayFrame.AbsoluteSize.Y),0)

			NewPos = Vector2.new(NewPos.X.Scale*512,NewPos.Y.Scale*384)
			CursorPosition = NewPos
			--Cursor.Position = NewPos
		end)
	else
		local restartframeposvalue = Instance.new("BoolValue",script.Parent.ScriptSettings)
		restartframeposvalue.Name = "RestartGameRightSite"
		restartframeposvalue.Value = false
	end
	if not (UserInputService.TouchEnabled and EnableTouchDevice == true) then
		if OldCursorMovement == true then
			--UserInputService.MouseIconEnabled = false
			RblxNewCursor.Visible = false
			PlayerMouse.Move:Connect(function()
				local Offset = PlayerGui.PlayScreen.AbsolutePosition.Y
				local NewPos = (Vector2.new(PlayerMouse.X-(script.Parent.AbsoluteSize.X-script.Parent.PlayFrame.AbsoluteSize.X)/2,(PlayerMouse.Y)-(script.Parent.AbsoluteSize.Y-script.Parent.PlayFrame.AbsoluteSize.Y)/2))+Vector2.new(0,10)
				NewPos = UDim2.new(NewPos.X/script.Parent.PlayFrame.AbsoluteSize.X,0,(NewPos.Y-Offset)/script.Parent.PlayFrame.AbsoluteSize.Y,0)
				NewPos = Vector2.new(NewPos.X.Scale*512,NewPos.Y.Scale*384)
				CursorPosition = NewPos
				--Cursor.Position = NewPos
			end)
		else
			--Cursor.Position = UDim2.new(0.5,0,0.5,0)
			-- Get current mouse position from the menu then apply it into the gameplay
			ProcessFunction(function()
				wait(0.5)
				TweenService:Create(script.Parent.VirtualMouseReminder,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{TextTransparency = 0.5}):Play()
				wait(2.5)
				TweenService:Create(script.Parent.VirtualMouseReminder,TweenInfo.new(1,Enum.EasingStyle.Linear),{TextTransparency = 1}):Play()
			end)

			local CurrentMousePosition = game.UserInputService:GetMouseLocation()
			local WindowsPosition = workspace.CurrentCamera.ViewportSize
			local FrameSize = Vector2.new(WindowsPosition.Y*1.067,WindowsPosition.Y*0.8)
			local FramePosition = WindowsPosition*Vector2.new(0.5,0.53)-FrameSize/2

			CursorPosition = -((FramePosition-CurrentMousePosition)/FrameSize)*Vector2.new(512,384)  --Vector2.new(256,192)
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

			local prevtick = tick()
			local GamepadDelta = Vector2.new(0,0)
			ProcessFunction(function()
				while ScoreResultDisplay == false and wait() do
					if not CursorUnlocked and UserInputService.GamepadEnabled then
						local WindowSize = workspace.CurrentCamera.ViewportSize
						local MouseMovement = GamepadDelta * (tick()-prevtick)
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
					prevtick = tick()
				end
			end)
			UserInputService.InputChanged:Connect(function(InputData)
				if InputData.KeyCode == Enum.KeyCode.Thumbstick1 or InputData.KeyCode == Enum.KeyCode.Thumbstick2 then
					local AbsoluteSize = script.Parent.PlayFrame.AbsoluteSize
					local GamepadSpeed = 500
					GamepadDelta = Vector2.new(InputData.Position.X/AbsoluteSize.X,-InputData.Position.Y/AbsoluteSize.Y)*CursorSensitivity*GamepadSpeed
				end
			end)

			UserInputService.InputEnded:Connect(function(InputData)
				if InputData.KeyCode == Enum.KeyCode.Thumbstick1 or InputData.KeyCode == Enum.KeyCode.Thumbstick2 then
					local AbsoluteSize = script.Parent.PlayFrame.AbsoluteSize
					local GamepadSpeed = 20
					GamepadDelta = Vector2.new(0,0)
				end
			end)

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

	ProcessFunction(function()
		UserInputService.InputBegan:Connect(function(data)
			if data.KeyCode == Key1Input and not (EnableTouchDevice and UserInputService.TouchEnabled) then
				MouseHitEvent:Fire(SecurityKey,1)
			elseif data.KeyCode == Key2Input and not (EnableTouchDevice and UserInputService.TouchEnabled) then
				MouseHitEvent:Fire(SecurityKey,2)
			elseif data.UserInputType == Enum.UserInputType.MouseButton1 and MouseButtonEnabled == true and not (EnableTouchDevice and UserInputService.TouchEnabled) then
				MouseHitEvent:Fire(SecurityKey,3)
			elseif data.UserInputType == Enum.UserInputType.MouseButton2 and MouseButtonEnabled == true and not (EnableTouchDevice and UserInputService.TouchEnabled) then
				MouseHitEvent:Fire(SecurityKey,4)
			end
		end)
	end)

	ProcessFunction(function()
		UserInputService.InputEnded:Connect(function(data)
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

	end)

	local function ScanforNearbyObj(Pos)
		if not DisplayingHitnote or not CircleSize then return end
		local ExactCircleSize = CircleSize/384*workspace.CurrentCamera.ViewportSize.Y
		local CursorPos = Vector2.new(Pos.X,Pos.Y)

		for _,data in pairs(DisplayingHitnote) do
			local ScreenSize = workspace.CurrentCamera.ViewportSize
			local CirclePos = Vector2.new(data.X,data.Y)/Vector2.new(512,384)*script.Parent.PlayFrame.AbsoluteSize+script.Parent.PlayFrame.AbsolutePosition

			if (CirclePos-CursorPos).Magnitude <= ExactCircleSize/2 then return true end
		end

		return false
	end

	local HitzoneBlocked = false
	local LastHitzoneHit = 0

	ProcessFunction(function()
		UserInputService.TouchStarted:Connect(function(data)
			local TouchPosition = data.Position
			local InHitzone = isInHitzone(TouchPosition)
			if InHitzone and not ScanforNearbyObj(TouchPosition) then return end -- won't register if they made their finger into the hitzone
			TouchCount += 1
			isTouchOutsiteHitzone = true
			local NewPos = (Vector2.new(TouchPosition.X-(script.Parent.AbsoluteSize.X-script.Parent.PlayFrame.AbsoluteSize.X)/2,(TouchPosition.Y+36)-(script.Parent.AbsoluteSize.Y-script.Parent.PlayFrame.AbsoluteSize.Y)/2))
			NewPos = UDim2.new(NewPos.X/script.Parent.PlayFrame.AbsoluteSize.X,0,NewPos.Y/(script.Parent.PlayFrame.AbsoluteSize.Y),0)
			CursorPosition = Vector2.new(NewPos.X.Scale*512,NewPos.Y.Scale*394)
			--Cursor.Position = NewPos

			local HitZone = script.Parent.MobileHit
			local MaxPosition = HitZone.AbsoluteSize.X

			if InHitzone and ScanforNearbyObj(TouchPosition) then
				HitzoneBlocked = true
			else
				HitzoneBlocked = false
			end

			--if TouchPosition.X > MaxPosition or not HitZoneEnabled or not EnableTouchDevice then -- no more double click
			MouseHitEvent:Fire(SecurityKey,3)
			--end
		end)

		UserInputService.TouchEnded:Connect(function(data)
			local TouchPosition = data.Position
			local InHitzone = isInHitzone(TouchPosition)
			if InHitzone and not ScanforNearbyObj(TouchPosition) then return end
			isTouchOutsiteHitzone = false
			LastHitzoneHit = tick()
			MouseHitEndEvent:Fire(SecurityKey,3)
		end)
		script.Parent.MobileHit.MouseButton1Down:Connect(function()
			if HitzoneBlocked then return end
			MobileHold = true
			LastHitzoneHit = tick()
			MouseHitEvent:Fire(SecurityKey,4)
		end)
		script.Parent.MobileHit.MouseButton1Up:Connect(function()
			if HitzoneBlocked then return end
			MobileHold = false
			MouseHitEndEvent:Fire(SecurityKey,4)
		end)
		script.Parent.MobileHit.MouseLeave:Connect(function()
			if MobileHold == true then
				MobileHold = false
				MouseHitEndEvent:Fire(SecurityKey,4)
			end
		end)
	end)
end

local keycount = {
	K1 = 0, K2 = 0, M1 = 0, M2 = 0
}

local DownKey = {
	K1 = false,
	K2 = false,
	M1 = false,
	M2 = false
}

local KeyHistory = script.Parent.HitKey.KeyHistory

spawn(function()
	local LastTick = tick()
	local count = 0
	while wait() do
		if OptimizedPerfomance then
			count += 1
			if count < 2 then
				continue -- on OptmimizedPerfomance, it only update 1 per 3 frame
			end
			count = 0
		end
		local Passed = tick() - LastTick
		LastTick = tick()

		for _, obj in pairs(KeyHistory:GetDescendants()) do
			if obj.Name == "Released" then
				obj.Position -= UDim2.new(Passed, 0, 0, 0)
				if obj.Position.X.Scale < -0.2 then
					obj:Destroy()
				end
			elseif obj.Name == "Current" then
				obj.Size += UDim2.new(Passed, 0, 0, 0)
			end
		end
	end
end)

function clearOldCurrentHistory(Crr)
	for _, obj in pairs(Crr:GetChildren()) do
		if obj.Name == "Current" then
			obj.Name = "Released"
		end
	end
end

spawn(function()
	local KeyTweenInfo = TweenInfo.new(0.1,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
	local ChangeIn1 = {--[[Size = UDim2.new(0.18,0,0.18,0),]]BackgroundColor3 = Color3.new(1, 1, 0.72549),BackgroundTransparency = 0}
	local ChangeIn2 = {--[[Size = UDim2.new(0.18,0,0.18,0),]]BackgroundColor3 = Color3.new(0.862745, 1, 1),BackgroundTransparency = 0}
	local ChangeOut = {--[[Size = UDim2.new(0.2,0,0.2,0),]]BackgroundColor3 = Color3.new(0,0,0),BackgroundTransparency = 0.5}

	MouseHitEvent.Event:Connect(function(CurrentSecurityKey,data)
		local CrrPosFrame = KeyHistory["Pos"..data]
		clearOldCurrentHistory(CrrPosFrame)
		local new = script.KeyHistoryHit:Clone()
		new.Parent = CrrPosFrame
		new.Position = UDim2.new(1, 0, 0, 0)
		new.Name = "Current"
		if data == 3 or data == 4 then
			new.BackgroundColor3 = Color3.new(0.666667, 1, 1)
		end
		TweenService:Create(new, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {BackgroundTransparency = 0}):Play()

		local keyName = {
			"K1", "K2", "M1", "M2"
		}
		if typeof(data) == "number" and data >= 1 and data <= 4 then
			local crrName = keyName[data]
			keycount[crrName] += 1
			DownKey[crrName] = true
			script.Parent.HitKey[crrName].Keycount.Text = keycount[crrName]
			TweenService:Create(script.Parent.HitKey[crrName].Keycount,KeyTweenInfo,{TextColor3 = Color3.new(0,0,0)}):Play()
			TweenService:Create(script.Parent.HitKey[crrName],KeyTweenInfo,ChangeIn1):Play()
			TweenService:Create(script.Parent.HitKey[crrName].GlowEffect,KeyTweenInfo,{ImageTransparency = 0}):Play()
		end

		--[[
		
		if data == 1 then
			K1 += 1
			DownKey.K1 = true
			script.Parent.HitKey.K1.Keycount.Text = K1
			TweenService:Create(script.Parent.HitKey.K1.Keycount,KeyTweenInfo,{TextColor3 = Color3.new(0,0,0)}):Play()
			TweenService:Create(script.Parent.HitKey.K1,KeyTweenInfo,ChangeIn1):Play()
			TweenService:Create(script.Parent.HitKey.K1.GlowEffect,KeyTweenInfo,{ImageTransparency = 0}):Play()
		elseif data == 2 then
			K2 += 1
			DownKey.K2 = true
			script.Parent.HitKey.K2.Keycount.Text = K2
			TweenService:Create(script.Parent.HitKey.K2.Keycount,KeyTweenInfo,{TextColor3 = Color3.new(0,0,0)}):Play()
			TweenService:Create(script.Parent.HitKey.K2,KeyTweenInfo,ChangeIn1):Play()
			TweenService:Create(script.Parent.HitKey.K2.GlowEffect,KeyTweenInfo,{ImageTransparency = 0}):Play()
		elseif data == 3 then
			K3 += 1
			DownKey.M1 = true
			script.Parent.HitKey.M1.Keycount.Text = K3
			TweenService:Create(script.Parent.HitKey.M1.Keycount,KeyTweenInfo,{TextColor3 = Color3.new(0,0,0)}):Play()
			TweenService:Create(script.Parent.HitKey.M1,KeyTweenInfo,ChangeIn2):Play()
			TweenService:Create(script.Parent.HitKey.M1.GlowEffect,KeyTweenInfo,{ImageTransparency = 0}):Play()
		elseif data == 4 then
			K4 += 1
			DownKey.M2 = true
			script.Parent.HitKey.M2.Keycount.Text = K4
			TweenService:Create(script.Parent.HitKey.M2.Keycount,KeyTweenInfo,{TextColor3 = Color3.new(0,0,0)}):Play()
			TweenService:Create(script.Parent.HitKey.M2,KeyTweenInfo,ChangeIn2):Play()
			TweenService:Create(script.Parent.HitKey.M2.GlowEffect,KeyTweenInfo,{ImageTransparency = 0}):Play()
		end]]
		script.Parent.KeyDown.Value = DownKey.K1 or DownKey.K2 or DownKey.M1 or DownKey.M2
	end)
	MouseHitEndEvent.Event:Connect(function(CurrentSecurityKey,data)
		local CrrPosFrame = KeyHistory["Pos"..data]
		clearOldCurrentHistory(CrrPosFrame)

		local keyName = {
			"K1", "K2", "M1", "M2"
		}
		if typeof(data) == "number" and data >= 1 and data <= 4 then
			local crrName = keyName[data]
			DownKey[crrName] = false
			TweenService:Create(script.Parent.HitKey[crrName].Keycount,KeyTweenInfo,{TextColor3 = Color3.new(1,1,1)}):Play()
			TweenService:Create(script.Parent.HitKey[crrName],KeyTweenInfo,ChangeOut):Play()
			TweenService:Create(script.Parent.HitKey[crrName].GlowEffect,KeyTweenInfo,{ImageTransparency = 1}):Play()
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






local ZIndex = 999999999
-- The default hit windows for Keyboard + Mouse/Tablet users
local hit300 = (100 - 8 * OverallDifficulty) / SongSpeed -- 100 - 20
local hit100 = (175 - 10 * OverallDifficulty) / SongSpeed -- 175 - 75
local hit50  = (250 - 12.5 * OverallDifficulty) / SongSpeed -- 200 - 125
local EarlyMiss = 425 / SongSpeed
local HitErrorMulti = 1.5

if ReplayMode or AutoPlay then
	EnableTouchDevice = false
end

--[[
Original timing (osu):
OD0:	80/140/200
OD10: 	20/60/100

Timing in osu!lazer:
OD0: 80/140/200
OD10: 20/60/100


OD Compare:
OD0:			      300     100  50
Bancho:		0ms -------|-----|-----|			200.0ms
PC:			0ms ---------|-------|------|		250.0ms
TD:			0ms --------------|------|-----|	275.0ms

OD10:			300	100  50
Bancho:		0ms -|---|---|		100.0ms
PC:			0ms	-|-----|----|	125.0ms
TD:			0ms	--|------|---|	140.0ms
]]

if (EnableTouchDevice and UserInputService.TouchEnabled) or TouchDeviceDetected or Replay_TouchDevice then
	-- Adjust hit window for TD
	hit300 = (150 - 12 * OverallDifficulty) / SongSpeed -- 150 - 30
	hit100 = (220 - 12.5 * OverallDifficulty) / SongSpeed -- 220 - 95
	hit50  = (275 - 13.5 * OverallDifficulty) / SongSpeed -- 275 - 140
	EarlyMiss = 440 / SongSpeed
	HitErrorMulti = 1
	TouchDeviceDetected = true
end

script.Parent.HitError.Size = UDim2.new(0,hit50*(19/16)*HitErrorMulti,0,25)
script.Parent.HitError.HitErrorDisplay._300s.Size = UDim2.new(hit300/hit50,0,0.25,0)
script.Parent.HitError.HitErrorDisplay._100s.Size = UDim2.new(hit100/hit50,0,0.25,0)
EstimatedCombo = 0

AccuracyData = {
	h300 = 0,h100 = 0,h50 = 0,miss = 0,Combo = 0, MaxCombo = 0, MaxPeromanceCombo = 0, PerfomanceCombo = 0, h300Bonus = 0, bonustotal = 0,
	HitErrorGraph = {

	},
	OffsetPositive = {Value = 0,Total = 0},
	OffsetNegative = {Value = 0,Total = 0},
	OffsetOverall = {Value = 0,Total = 0},
	BaseConsistency = 0,
	MaxConsistency = 0,
	SpinnerScore = 0
}

function getConsistency()
	local function lerp(a, b, ratio)
		return a + (b - a)*ratio
	end
	local Consistency = math.pow(AccuracyData.BaseConsistency/math.max(1,AccuracyData.MaxConsistency), 0.5) * 100
	Consistency = math.max(Consistency, lerp(AccuracyData.MaxCombo/math.max(EstimatedCombo or 1, 1), 1, 1/(AccuracyData.miss+1)) * 100)
	Consistency = math.max(Consistency, AccuracyData.MaxCombo/math.max(EstimatedCombo or 1, 1) * 100)
	return Consistency
end

ProcessFunction(function()
	while wait() do
		local Consistency = getConsistency()
		script.Parent.ConsistencyDisplay.Text = string.format("Consistency: %.2f%%", Consistency)
	end
end)
script.Parent.ConsistencyDisplay.Visible = true



local AccTemplate = cloneTable(AccuracyData)
for i = 1,50 do
	local HitErrorGraph = AccuracyData.HitErrorGraph
	if i == 1 then
		HitErrorGraph[#HitErrorGraph+1] = {-2,2,0,0}
	else
		HitErrorGraph[#HitErrorGraph+1] = {i*2,(i+1)*2,0,i-1}
		HitErrorGraph[#HitErrorGraph+1] = {-(i+1)*2,-i*2,0,-i+1}
	end
end
local GameMaxCombo = #BeatmapData


CircleSize = (54.4 - 4.48 * CS)*2

if TouchDeviceDetected or ((ReplayMode and Replay_TouchDevice) or (AutoPlay == false and ReplayMode ~= true and isSpectating == false and UserInputService.TouchEnabled and EnableTouchDevice == true)) then
	-- Increase the cursor size for TD
	CircleSize *= 1.1875
end
local DisplayCombo = 0
local LastCombo = 0
local LastComboCapture = Instance.new("Frame")
local _currentfadecomboid = ""
local ComboVisibleState = false
local ComboFrameExpandRate = 0

ProcessFunction(function()
	local lasttick = tick()
	while wait() do
		local TimePassed = tick() - lasttick
		ComboFrameExpandRate -= TimePassed / 0.2
		ComboFrameExpandRate = math.clamp(ComboFrameExpandRate,0,1.2)
		local BaseSize = 0.075 + ComboFrameExpandRate * 0.025
		TweenService:Create(script.Parent.ComboFrameDisplay.ComboFrameDisplay,TweenInfo.new(0.05/SongSpeed,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(BaseSize,0,BaseSize,0)}):Play()
		lasttick = tick()
	end
end)
script.Parent.ComboDisplay:GetPropertyChangedSignal("Text"):Connect(function()
	if OptimizedPerfomance then return end
	local id = HttpService:GenerateGUID()
	_currentfadecomboid = id
	local NewCombo = tonumber(string.sub(script.Parent.ComboDisplay.Text,1,#script.Parent.ComboDisplay.Text-1)) or 0
	if (NewCombo > 0) ~= ComboVisibleState then
		ComboVisibleState = (NewCombo > 0)
		local DisplayTransparency = ComboVisibleState and 0 or 1
		local FadeTime = ComboVisibleState and 0.75 or 0.25
		TweenService:Create(script.Parent.ComboFrameDisplay,TweenInfo.new(FadeTime,Enum.EasingStyle.Linear),{GroupTransparency = DisplayTransparency}):Play()
		TweenService:Create(script.Parent.ComboFade.ComboFade,TweenInfo.new(FadeTime,Enum.EasingStyle.Linear),{GroupTransparency = DisplayTransparency}):Play()
	end

	if NewCombo > DisplayCombo then
		ComboFrameExpandRate += 0.4
		ComboFrameExpandRate = math.clamp(ComboFrameExpandRate,0,1.2)
		--[[
		TweenService:Create(script.Parent.ComboFrameDisplay.ComboFrameDisplay,TweenInfo.new(1/SongSpeed,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(0.09,0,0.09,0)}):Play()
		ProcessFunction(function()
			wait(0.05)
			if _currentfadecomboid ~= id then return end
			TweenService:Create(script.Parent.ComboFrameDisplay.ComboFrameDisplay,TweenInfo.new(0.1/SongSpeed,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(0.075,0,0.075,0)}):Play()
		end)]]
		script.Parent.ComboFade.ComboFade:ClearAllChildren()
		if OldInterface == true then
			TweenService:Create(script.Parent.ComboDisplay,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextSize = 60}):Play()
			ProcessFunction(function()
				wait(0.05)
				TweenService:Create(script.Parent.ComboDisplay,TweenInfo.new(0.1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextSize = 50}):Play()
			end)
			ProcessFunction(function()
				local NewFadeCombo = script.ComboFade:Clone()
				NewFadeCombo.Parent = script.Parent.ComboFade.ComboFade
				NewFadeCombo.Text = tostring(NewCombo).."x"
				NewFadeCombo.TextSize = script.Parent.ComboDisplay.TextSize
				NewFadeCombo.TextTransparency = 0.25

				TweenService:Create(NewFadeCombo,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextSize = script.Parent.ComboDisplay.TextSize*1.5,TextTransparency = 1}):Play()
				wait(0.5)
				NewFadeCombo:Destroy()
			end)
		end

		LastComboCapture:Destroy()
		LastComboCapture = script.Parent.ComboFrameDisplay.ComboFrameDisplay:Clone()
		local NewFadeCombo = script.Parent.ComboFrameDisplay.ComboFrameDisplay:Clone()
		NewFadeCombo.Parent = script.Parent.ComboFade.ComboFade
		NewFadeCombo.Visible = OverallInterfaceEnabled and not OldInterface

		TweenService:Create(NewFadeCombo,TweenInfo.new(0.5/SongSpeed,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(NewFadeCombo.Size.Y.Scale*1.5,0,NewFadeCombo.Size.Y.Scale*1.5,0)}):Play()
		for _,obj in pairs(NewFadeCombo:GetChildren()) do
			if obj:IsA("ImageLabel") then
				TweenService:Create(obj,TweenInfo.new(0.5/SongSpeed,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()
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

local DisplayAccuracy = 10000
local CurrentAccuracy = 10000

local LastComboDisplay = 0

spawn(function() --Accurancy caculation
	repeat wait() until tick() - SongStart >= 0

	local WaitTime = 0
	if OptimizedPerfomance then
		WaitTime = 0.1
	end
	while wait(WaitTime) do
		if OptimizedPerfomance and WaitTime == 0 then
			WaitTime = 0.1
		elseif not OptimizedPerfomance and WaitTime == 0.1 then
			WaitTime = 0
		end
		local h300 = AccuracyData.h300
		local h100 = AccuracyData.h100
		local h50 = AccuracyData.h50
		local miss = AccuracyData.miss
		local Total = h300+h100+h50+miss
		local Acc = math.floor(((h300*300+h100*100+h50*50)/(Total*300))*10000)/100
		local tostringAcc = string.format("%02d.%02d", math.floor(Acc), (Acc * 100) % 100)

		local NewAcc = math.round(Acc*100)
		if NewAcc ~= NewAcc then NewAcc = 10000 end
		DisplayAccuracy = NewAcc

		script.Parent.ComboDisplay.Text = tostring(AccuracyData.Combo).."x"

		local ComboDisplay = script.Parent.ComboFrameDisplay.ComboFrameDisplay

		if LastComboDisplay ~= AccuracyData.Combo then

			ComboDisplay:ClearAllChildren()
			script.ScoreDisplay.UIComboLayout:Clone().Parent = ComboDisplay
			local TextCombo = tostring(AccuracyData.Combo).."x"

			for i = 1,#TextCombo do
				local CurrentText = string.sub(TextCombo,i,i)
				local NewComboText = script.ScoreDisplay:FindFirstChild("Score"..CurrentText):Clone()
				NewComboText.Parent = ComboDisplay
				NewComboText.ZIndex = i
			end
		end
		LastComboDisplay = AccuracyData.Combo
	end
end)

TweenService:Create(script.Parent.GameplayData.Accuracy,TweenInfo.new(2.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Value = 10000}):Play()

spawn(function()
	local WaitTime = 0
	if OptimizedPerfomance then
		WaitTime = 0.25
	end

	while wait(WaitTime) do
		if OptimizedPerfomance and WaitTime == 0 then
			WaitTime = 0.25
		elseif not OptimizedPerfomance and WaitTime == 0.25 then
			WaitTime = 0
		end
		if DisplayAccuracy ~= CurrentAccuracy then
			CurrentAccuracy = DisplayAccuracy
			TweenService:Create(script.Parent.GameplayData.Accuracy,TweenInfo.new(0.1/SongSpeed,Enum.EasingStyle.Linear),{Value = DisplayAccuracy}):Play()
		end
	end
end)

local PrevAcc = 100
AccFrameLastUpdate = 0

script.Parent.GameplayData.Accuracy:GetPropertyChangedSignal("Value"):Connect(function()
	if OptimizedPerfomance and (tick() - AccFrameLastUpdate < 0.04) then return end
	AccFrameLastUpdate = tick()
	
	local Acc = script.Parent.GameplayData.Accuracy.Value/100
	local AccurancyDisplay = script.Parent.AccurancyFrameDisplay

	if Acc ~= Acc or Acc == math.huge then
		Acc = 100
	end

	local tostringAcc = string.format("%s%s%%",string.format("%.2d",Acc),string.sub(string.format("%.2f",Acc%1),2,4))

	script.Parent.AccurancyDisplay.Text = tostringAcc
	local TextAcccurancy = tostringAcc
	if PrevAcc ~= Acc then
		AccurancyDisplay:ClearAllChildren()
		script.ScoreDisplay.UIAccurancyLayout:Clone().Parent = AccurancyDisplay
		for i = 1,#TextAcccurancy do
			local CurrentTextAcccurancy = string.sub(TextAcccurancy,i,i)
			--if CurrentTextAcccurancy == "." then CurrentTextAcccurancy = "," end
			local NewScoreFrame = script.ScoreDisplay:FindFirstChild("Score"..CurrentTextAcccurancy):Clone()
			NewScoreFrame.Parent = AccurancyDisplay
			NewScoreFrame.ZIndex = -i
		end
	end
	PrevAcc = Acc
end)

-- ScoreV1

local Score = 0 -- Base score


---- Perfomance
local CurrentPerfomance = 0
local HighestPerfomance = 1

-- ScoreV2
TotalScoreEstimated = 0
EstimatedCombo = 0

-- Note completed rate
NoteTotal = #BeatmapData
NoteCompleted = 0

local ScoreMultiplier = {
	Difficulty = 6,
	Mod = 1
}

script.Parent.MultiplayerData.GetInGameData.OnInvoke = function()
	return {Score = Score,Combo = AccuracyData.Combo}
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

if NoFail == true then
	ScoreMultiplier.Mod *= 0.5
end

if HiddenMod == true then
	ScoreMultiplier.Mod *= 1.06
end

if HardRock == true then
	ScoreMultiplier.Mod *= 1.06
end

if EasyMod == true then
	ScoreMultiplier.Mod *= 0.5
end

local ScoreDisplay = script.Parent.ScoreFrameDisplay
local PrevScore = -1

function getAccuracyScore()
	-- For SL mod (or will be NM soon), I will add an extra score to catch up the scale to be same with the ConsistencyScore
	local Accuracy = (AccuracyData.h300*300+AccuracyData.h100*100+AccuracyData.h50*50)/((AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss)*300)
	-- When the total possible combo (maximum current combo player can get) more than total note of the game
	-- Accuracy score will rise up even more
	local ExtraCombo = EstimatedCombo-#BeatmapData
	-- penalty for each miss given
	-- prevent players just "chilling out" and watching the score keep increasing
	local ExtraAccPoint = math.max(0, ExtraCombo * Accuracy - AccuracyData.miss)

	return math.pow(ExtraAccPoint + (AccuracyData.h300*300+AccuracyData.h100*100+AccuracyData.h50*50)/300,2.265) * ScoreMultiplier.Difficulty * ScoreMultiplier.Mod * 0.3
end

function getConsistencyScore()
	return math.pow(AccuracyData.BaseConsistency, 1.1704417) * 1.2255 * ScoreMultiplier.Difficulty * ScoreMultiplier.Mod * 0.7
end

function getScoreV1()
	local AccuracyScore = getAccuracyScore()
	local ConsistencyScore = getConsistencyScore()
	-- Spinner score provide fixed value
	return math.round(ConsistencyScore+AccuracyScore+AccuracyData.SpinnerScore)
end

function getScoreV2()
	local ExtraCombo = EstimatedCombo-#BeatmapData
	local ExtraAccPoint = math.max(0, ExtraCombo)
	local AccScoreMax = math.pow(ExtraAccPoint + (AccuracyData.h300*300+AccuracyData.h100*300+AccuracyData.h50*300+AccuracyData.miss*300)/300,2.265) * ScoreMultiplier.Difficulty * ScoreMultiplier.Mod * 0.3
	local ConsistencyScoreMax = math.pow(AccuracyData.MaxConsistency, 1.1704417) * 1.2255 * ScoreMultiplier.Difficulty * ScoreMultiplier.Mod * 0.7

	local ActualAccScore = getAccuracyScore()
	local ActualConsistencyScore = getConsistencyScore()

	local MaxPossibleScore = AccScoreMax + ConsistencyScoreMax
	local ActualScore = ActualAccScore + ActualConsistencyScore

	local TotalNote = #BeatmapData
	local TotalHit = AccuracyData.h300 + AccuracyData.h100 + AccuracyData.h50
	local ScalingRatio = TotalHit/#BeatmapData

	local ScoreV2 = math.pow(ActualScore/MaxPossibleScore,0.44150110375) * ScalingRatio * 1000000 * ScoreMultiplier.Mod

	-- Spinner score only gives 10% points in ScoreV2
	return math.round(ScoreV2 + AccuracyData.SpinnerScore * 0.1)
end

spawn(function()
	local PrevScore = 0
	local PrevScoreV2 = 1
	local PrevMaxCombo = 0
	local PrevCombo = 0
	local WaitTime = 0
	local PrevHealth = HealthPoint




	if OptimizedPerfomance then
		WaitTime = 0.5
	end
	while wait(WaitTime) do
		if OptimizedPerfomance and WaitTime == 0 then
			WaitTime = 0.5
		elseif not OptimizedPerfomance and WaitTime == 0.5 then
			WaitTime = 0
		end
		local AccuracyScore = getAccuracyScore()
		local ConsistencyScore = getConsistencyScore()

		local Score = getScoreV1()
		if Score ~= PrevScore or PrevMaxCombo ~= AccuracyData.MaxCombo then

			--if ScoreV2Enabled then
			--script.Parent.Leaderboard.ScoreV2MaxScore.Value = TotalScoreEstimated
			--end
			script.Parent.ScoreUpdate:Fire(Score,AccuracyData.MaxCombo,CurrentPerfomance)
		end

		ProcessFunction(function()
			if Score ~= PrevScore or PrevCombo ~= AccuracyData.Combo or PrevHealth ~= HealthPoint or (ScoreV2Enabled and Score/TotalScoreEstimated~=PrevScoreV2) then
				if ScoreV2Enabled then
					--local ScoreV2AccScore = math.pow((AccuracyData.h300*300+AccuracyData.h100*300+AccuracyData.h50*300+AccuracyData.miss*300)/300,2.265) * ScoreMultiplier.Difficulty * ScoreMultiplier.Mod * 0.3
					--local ScoreV2 = math.pow(Score/(TotalScoreEstimated*0.8 + ScoreV2AccScore)*(NoteCompleted/NoteTotal),0.768621)*(NoteCompleted/NoteTotal)*1000000
					local ScoreV2 = getScoreV2()
					script.Parent.MultiplayerLeaderboard.LocalScoreUpdate:Fire({Score = math.round(ScoreV2),Combo = AccuracyData.Combo,Failed = MultiplayerMatchFailed,HealthPercentage = HealthPoint/MaxHealthPoint},CurrentPerfomance)
				else
					script.Parent.MultiplayerLeaderboard.LocalScoreUpdate:Fire({Score = Score,Combo = AccuracyData.Combo,Failed = MultiplayerMatchFailed,HealthPercentage = HealthPoint/MaxHealthPoint},CurrentPerfomance)
				end
			end
		end)
		PrevScore = Score
		PrevScoreV2 = Score/TotalScoreEstimated
		PrevMaxCombo = AccuracyData.MaxCombo
		PrevCombo = AccuracyData.Combo
		PrevHealth = HealthPoint
	end
end)

spawn(function()
	local ScoreVisibleData = {
		[-1] = 0
	}
	local CurrentScore = script.Parent.GameplayData.Score.Value
	local CurrentTotalScore = TotalScoreEstimated

	local WaitTime = 0
	local TweenTimeMultiplier = 1
	if OptimizedPerfomance then
		WaitTime = 0.04
		TweenTimeMultiplier = 0
	end
	while wait(WaitTime) do
		if OptimizedPerfomance and WaitTime == 0 then
			WaitTime = 0.04
			TweenTimeMultiplier = 0
		elseif not OptimizedPerfomance and WaitTime == 0.04 then
			WaitTime = 0
			TweenTimeMultiplier = 1
		end
		if Score ~= CurrentScore or (ScoreV2Enabled and CurrentTotalScore~=TotalScoreEstimated) then
			local AccuracyScore = getAccuracyScore()
			local ConsistencyScore = getConsistencyScore()

			local Score = getScoreV1() -- overwrite the current score
			local DisplayScore = Score
			CurrentScore = Score
			if ScoreV2Enabled then
				--local ScoreV2AccScore = math.pow((AccuracyData.h300*300+AccuracyData.h100*300+AccuracyData.h50*300+AccuracyData.miss*300)/300,2.265) * ScoreMultiplier.Difficulty * ScoreMultiplier.Mod * 0.3
				--local ScoreV2 = math.pow(Score/(TotalScoreEstimated*0.8 + ScoreV2AccScore)*(NoteCompleted/NoteTotal),0.768621)*(NoteCompleted/NoteTotal)*1000000
				local ScoreV2 = getScoreV2()

				if tostring(ScoreV2) == "nan" or tostring(ScoreV2) == "inf" then
					ScoreV2 = 0
				end
				DisplayScore = ScoreV2
			end
			TweenService:Create(script.Parent.GameplayData.Score,TweenInfo.new(TweenTimeMultiplier*0.4/SongSpeed,Enum.EasingStyle.Linear),{Value = DisplayScore}):Play()
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
						if ScoreVisibleData[Displayer.LayoutOrder] then
							a.ImageTransparency = math.clamp(1-(tick() - ScoreVisibleData[Displayer.LayoutOrder])/0.25,0,1)
						else
							a.ImageTransparency = 1
							ScoreVisibleData[Displayer.LayoutOrder] = tick()
						end
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
FlashlightFrame.ImageTransparency = 1
gameEnded = false

ProcessFunction(function()
	while wait(0.1) do
		if (FlashlightFrame.Visible == false or FlashlightFrame.Parent == nil) and Flashlight == true and gameEnded == false and not BeatmapFailed then
			warn("[Client] An error occured, please rejoin to fix this issue")
			require(PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("An error occured, please rejoin to fix this issue.",Color3.new(1, 0, 0))
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
		TweenService:Create(FlashlightFrame,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = UDim2.new(7,0,7,0),ImageTransparency = 0}):Play()

		local CurrentCombo = 0
		while wait(0.1) do
			if not FLAnimate then break end
			if CurrentCombo ~= AccuracyData.Combo then
				CurrentCombo = AccuracyData.Combo
				local FLSize = (CurrentCombo <= 200 and 7-((CurrentCombo/200)*3)) or 4

				script.Parent.GameplayData.FLSize.Value = ((HiddenMod and -1) or 1) * FLSize
				TweenService:Create(FlashlightFrame,TweenInfo.new(1,Enum.EasingStyle.Linear),{Size = UDim2.new(FLSize,0,FLSize,0)}):Play()
			end
		end
	end)
end


local StartTick = 0
local SpecStartTickChange = 0
local SpectateDelay = CurrentSetting.VirtualSettings.SpectateDelay.Value
local SpecDelayFrame = script.Parent.SpectateDelay
local SpectateGotFirstData = false

function FindForSpectateSignal()
	local UserId = SavedSpectateData.SpectateUID
	local SearchStartTime = tick()
	repeat wait() until PlayerGui.MenuInterface.PlayerListFrame.PlayerList.GetUserStatus:Invoke(UserId,true) == 1 or tick() - SearchStartTime > 10 -- Player need to be out, but there would be some delay
	wait(0.5)
	repeat wait() until PlayerGui.MenuInterface.PlayerListFrame.PlayerList.GetUserStatus:Invoke(UserId,true) == 2
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
		local yieldingSpectateAction

		local function QueueSpectateEvent(Data,isSystemCreated)
			if Data == -1 then
				require(PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("Player you spectate has left, waiting for player to start another play...",Color3.new(1,0,0))
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

			if tick() - SpecStartTickChange > 5 or SpecStartTickChange == 0 then
				local ServerTick = workspace.ServerStatus.ServerTick.Value

				SpecStartTickChange = tick()
				local NewStartTick = (tick() - TimeProcess)
				if math.abs(StartTick - NewStartTick) > 0.5 then -- more than 500ms then update
					StartTick = NewStartTick
				end
			end
			if SpecStartTickChange ~= 0 then
				if tick() - StartTick < CurrentSpecTime + SpectateDelay/1000 or SpectateDelay <= 0 then
					repeat wait() until tick() - StartTick >= CurrentSpecTime + SpectateDelay/1000 - 3 or SpectateDelay <= 0
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
			if SavedSpectateData.TD then
				-- yield the action to the next move
				if yieldingSpectateAction then
					yieldingSpectateAction()
				end
				if Data.Changes.KeyHit then

					yieldingSpectateAction = function()
						if Data.Changes.KeyHit <= 4 then
							MouseHitEvent:Fire(SecurityKey,Data.Changes.KeyHit)
						else
							MouseHitEndEvent:Fire(SecurityKey,Data.Changes.KeyHit-4)
						end
					end
				else
					yieldingSpectateAction = nil
				end
			else
				-- for non-TD, do as normal
				if Data.Changes.KeyHit then
					if Data.Changes.KeyHit <= 4 then
						MouseHitEvent:Fire(SecurityKey,Data.Changes.KeyHit)
					else
						MouseHitEndEvent:Fire(SecurityKey,Data.Changes.KeyHit-4)
					end
				end
			end
			local InGameData = Data.InGameData
			Score = InGameData.Score
			AccuracyData.h300 = InGameData.Acc[1]
			AccuracyData.h100 = InGameData.Acc[2]
			AccuracyData.h50 = InGameData.Acc[3]
			AccuracyData.miss = InGameData.Acc[4]
			AccuracyData.Combo = InGameData.Combo
			AccuracyData.MaxCombo = InGameData.MaxCombo
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
if isSpectating == false and (AutoPlay == false or (LocalPlayer.UserId == 1241445502 and game.PlaceId ~= 6983932919)) then
	--[[
	PlayingRemote.OnClientEvent:Connect(function(Name)
		if typeof(Name) == "String" then
			require(PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)(Name.." is spectating you",Color3.new(0, 1, 0))
		end
	end)]]
end


MouseHitEvent.Event:Connect(function(CurrentSecurityKey,data)
	if isSpectating == false and (AutoPlay == false or ((LocalPlayer.UserId == 1241445502 or LocalPlayer.UserId == 1608539863) and game.PlaceId ~= 6983932919)) then
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
						AccuracyData.h300,
						AccuracyData.h100,
						AccuracyData.h50,
						AccuracyData.miss
					},
					Combo = AccuracyData.Combo,
					MaxCombo = AccuracyData.MaxCombo,
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
	if isSpectating == false and (AutoPlay == false or ((LocalPlayer.UserId == 1241445502 or LocalPlayer.UserId == 1608539863) and game.PlaceId ~= 6983932919)) then
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
						AccuracyData.h300,
						AccuracyData.h100,
						AccuracyData.h50,
						AccuracyData.miss
					},
					Combo = AccuracyData.Combo,
					MaxCombo = AccuracyData.MaxCombo,
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
	if isSpectating == false and ReplayMode == false and (AutoPlay == false or ((LocalPlayer.UserId == 1241445502 or LocalPlayer.UserId == 1608539863) and game.PlaceId ~= 6983932919)) and onTutorial ~= true then
		local MetaData = ReturnData.Overview.Metadata
		game.ReplicatedStorage.Gameplay.UpdateStatus:FireServer(2,{BeatmapPlaying = MetaData.SongCreator.." - "..MetaData.MapName.." ["..MetaData.DifficultyName.."]"})
		while wait(1/60) do -- record cursor movement at most 60FPS
			if #game.Players:GetPlayers() > 1 then -- for better perfomance, data should only send when there's more than 1 player in the server.
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
								AccuracyData.h300,
								AccuracyData.h100,
								AccuracyData.h50,
								AccuracyData.miss
							},
							Combo = AccuracyData.Combo,
							MaxCombo = AccuracyData.MaxCombo,
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

if CircleApproachTime/SongSpeed < hit50 then
	local MissTiming = math.max(0,hit50 - CircleApproachTime/SongSpeed)
	script.Parent.HitError.MissArea.Size = UDim2.new(MissTiming/(hit50*2),0,0.25,0)
end

if SpeedSync == true then
	CircleApproachTime /= SongSpeed
end

-- 1 - 1680 | 10 - 450


--CircleApproachTime = 10000

PlayerGui.MenuInterface.DropdownMenu.MenuListAnimate.hiddenRequest:Fire(true)

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
		if tick() - LastClick > 0.15 then
			RightClick = false
			LastClick = tick()
			MouseHitEvent:Fire(SecurityKey,3)
			local CurrentSession = HttpService:GenerateGUID()
			KeySession.K1 = CurrentSession
			wait(0.05)
			if KeySession.K1 == CurrentSession then
				MouseHitEndEvent:Fire(SecurityKey,3)
			end
		else
			if RightClick == true then
				RightClick = false
				LastClick = tick()
				MouseHitEvent:Fire(SecurityKey,3)
				local CurrentSession = HttpService:GenerateGUID()
				KeySession.K1 = CurrentSession
				wait(0.05)
				if KeySession.K1 == CurrentSession then
					MouseHitEndEvent:Fire(SecurityKey,3)
				end
			else
				RightClick = true
				LastClick = tick()
				local CurrentSession = HttpService:GenerateGUID()
				KeySession.K2 = CurrentSession
				MouseHitEvent:Fire(SecurityKey,4)
				wait(0.05)
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
		local CurrentSection = HttpService:GenerateGUID()
		Section = CurrentSection
		BreakTimeFrame.Visible = true
		BreakTimeFrame.Size = UDim2.new(0,0,0,0)
		BreakTimeFrame.TimeProgress.BackgroundTransparency = 0
		local Duration = (BreakTime[2] - BreakTime[1])/1000
		TweenService:Create(script.Parent.HitError.CurrentDelay.Delay,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{ImageTransparency = 1}):Play()
		TweenService:Create(script.Parent.HitError.CurrentDelay.UnstableRate,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{TextTransparency = 1}):Play()
		TweenService:Create(script.Parent.HitError,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{AnchorPoint = Vector2.new(0.5,0)}):Play()
		TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans+0.2}):Play()
		TweenService:Create(FlashlightFrame,TweenInfo.new(1,Enum.EasingStyle.Linear),{Size = UDim2.new(15,0,15,0),ImageTransparency = 0}):Play()
		TweenService:Create(script.Parent.ComboFrameDisplay,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{GroupTransparency = 1}):Play()
		TweenService:Create(script.Parent.ComboFade.ComboFade,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{GroupTransparency = 1}):Play()
		if BackgroundBlurEnabled == true then
			TweenService:Create(game.Lighting.Blur,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = 15}):Play()
		end
		ProcessFunction(function()
			isDrain = false
			repeat wait() until tick() - Start >= (BreakTime[2]/1000)
			script.Parent.Leaderboard.LbTrigger:Fire(false)
			script.Parent.MultiplayerLeaderboard.LbTrigger:Fire(false)
			isDrain = true
			TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans}):Play()
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
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,true)
			local TotalNoteResult = AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss
			local GameAccurancy = math.floor(((AccuracyData.h300*300+AccuracyData.h100*100+AccuracyData.h50*50)/(TotalNoteResult*300))*100*100)/100
			local GameplayRank = "D"
			local percent300s = AccuracyData.h300/(AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss)
			local percent50s = AccuracyData.h50/(AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss)
			local misstotal = AccuracyData.miss

			local tostringAcc = string.format("%s%s%%",string.format("%.2d",GameAccurancy),string.sub(string.format("%.2f",GameAccurancy%1),2,4))

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

			BreakTimeFrame.Accuracy.Text = tostringAcc
			BreakTimeFrame.RankDisplay.Text = (not SS and GameplayRank) or "S"
			BreakTimeFrame.RankDisplay.TextColor3 = RankColor[GameplayRank] 
			if (GameplayRank == "S" or SS) and (HiddenMod or Flashlight) then
				BreakTimeFrame.RankDisplay.TextColor3 = Color3.fromRGB(177,177,177)
			end
			BreakTimeFrame.MaxCombo.Text = tostring(AccuracyData.MaxCombo).."x"
			BreakTimeFrame.MissTotal.Text = tostring(AccuracyData.miss).." miss"
			BreakTimeFrame.SS_Rank.Visible = SS and not (HiddenMod or Flashlight)
			BreakTimeFrame.SSH_Rank.Visible = SS and (HiddenMod or Flashlight)
			if AccuracyData.miss > 0 then
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


			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,not DisableChatInGame)

			spawn(function()
				wait(0.5)
				if Section == CurrentSection then
					--BreakTimeFrame.Visible = false
				end
			end)
			local FLSize = (AccuracyData.Combo <= 200 and 8-((AccuracyData.Combo/200)*3)) or 5

			if AccuracyData.Combo > 0 then
				TweenService:Create(script.Parent.ComboFrameDisplay,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{GroupTransparency = 0}):Play()
				TweenService:Create(script.Parent.ComboFade.ComboFade,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{GroupTransparency = 0}):Play()
			end

			TweenService:Create(FlashlightFrame,TweenInfo.new(2,Enum.EasingStyle.Linear),{Size = UDim2.new(FLSize,0,FLSize,0)}):Play()
			TweenService:Create(BreakTimeFrame.TimeProgress,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{BackgroundTransparency = 1}):Play()
			TweenService:Create(BreakTimeFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{Size = UDim2.new(0,4,0,2),Rotation = -20,GroupTransparency = 1}):Play()
			TweenService:Create(script.Parent.BreaktimeFrameOutline,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{Size = UDim2.new(1.067,0,0.8,0)}):Play()
			TweenService:Create(script.Parent.BreaktimeFrameOutline.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{Transparency = 1}):Play()
			--TweenService:Create(BreakTimeFrame,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Position = UDim2.new(0.5,0,-1.5,-18)}):Play()
		end
	end
end)


local TotalNotes = 0 
local NoteDisplayLimit = 1200 -- there could possibly no way would a map displaying this much notes at the same time
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

		-- Accuracy

		local TotalNoteResult = AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss
		local GameAccurancy = math.floor(((AccuracyData.h300*300+AccuracyData.h100*100+AccuracyData.h50*50)/(TotalNoteResult*300))*100*100)/100

		if tostring(GameAccurancy) == "nan" then
			GameAccurancy = 100
		end

		local GameplayRank = "D"
		local percent300s = AccuracyData.h300/(AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss)
		local percent50s = AccuracyData.h50/(AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss)
		local misstotal = AccuracyData.miss

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
		--[[

		if CurrentPerfomance > HighestPerfomance then
			HighestPerfomance = CurrentPerfomance
		end]]
		local Consistency = math.pow(AccuracyData.BaseConsistency/math.max(1,AccuracyData.MaxConsistency), 0.5) * 100
		Consistency = math.max(Consistency, AccuracyData.MaxCombo/math.max(EstimatedCombo or 1, 1) * 100)
		TimePerfomance[i] = Consistency--CurrentPerfomance
	end
end)
HighestPerfomance = 100


--TimmingPoints

--local DefaultBackgroundTrans = --[[PlayerGui.BG.Background.Background.BackgroundDim.BackgroundTransparency]] 0.2
-- BackgroundTrans = 1-(BackgroundDim/100)

spawn(function()
	TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans+0.2}):Play()
	repeat wait() until tick() - Start > (BeatmapData[1].Time/1000 - 1.2)
	HealthPoint = MaxHealthPoint
	TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans}):Play()
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

function CreateHitSound(HitsoundType,CustomSampleSet, AmbientRatio)
	ProcessFunction(function()
		if not tonumber(AmbientRatio) or AmbientRatio > 1 or AmbientRatio < 0 then
			AmbientRatio = 0.5
		end

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
		local CurrentHitsound2 = script.Hitsounds[HitsoundFilename]:Clone()

		CurrentHitsound.Volume *= 0.5 + (1-AmbientRatio)*0.5
		CurrentHitsound2.Volume *= 0.5 + (AmbientRatio)*0.5

		CurrentHitsound.Parent = workspace.AudioOutput.Audio_L
		CurrentHitsound2.Parent = workspace.AudioOutput.Audio_R

		--CurrentHitsound.Parent = script.Parent.HitSounds

		CurrentHitsound:Play()
		CurrentHitsound2:Play()
		ProcessFunction(function()
			wait(0.5)
			CurrentHitsound:Destroy()
			CurrentHitsound2:Destroy()
		end)
	end)
end


ProcessFunction(function()
	for i, TimingData in pairs(TimingPoints) do
		if TimingData ~= nil and #TimingData > 0 then
			repeat wait() until (tick() - Start) >= (TimingData[1] / 1000)
			local volumeMultiplier = TimingData[6] / 100 * EffectVolume * 0.01

			script.HitSound.Volume = volumeMultiplier
			script.HitSoundClap.Volume = volumeMultiplier
			script.HitSoundFinish.Volume = volumeMultiplier
			script.HitSoundWhistle.Volume = volumeMultiplier

			for _, Hitsound in pairs(script.Hitsounds:GetChildren()) do
				Hitsound.Volume = volumeMultiplier
			end

			local BeatLength = TimingData[2]
			local CurrentSliderMultiplier

			if BeatLength / math.abs(BeatLength) == 1 then
				BPM = 1 / BeatLength * 1000 * 60
			else
				CurrentSliderMultiplier = 1 / ((-BeatLength) / 100)
			end

			if i ~= #TimingPoints then
				local SliderMultiCount = 0
				local BPMCount = 0

				for e = 1, 20 do
					local NextTimingPoint = TimingPoints[i + e]

					if NextTimingPoint then
						local NextTimingPointTime = NextTimingPoint[1]
						local NextBeatLength = NextTimingPoint[2]

						if NextBeatLength / math.abs(NextBeatLength) == 1 then
							BPMCount = BPMCount + 1
							NextBPM[BPMCount] = {
								Time = NextTimingPointTime,
								Value = 1 / NextBeatLength * 1000 * 60
							}
						else
							SliderMultiCount = SliderMultiCount + 1
							NextSliderMulti[SliderMultiCount] = {
								Time = NextTimingPointTime,
								Value = 1 / ((-NextBeatLength) / 100)
							}
						end
					else
						break
					end
				end
			end

			local Positive = BeatLength / math.abs(BeatLength)

			if Positive > 0 then
				local BPM = (1 / BeatLength * 1000 * 60) * SongSpeed
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
				if not Flashlight and DefaultBackgroundTrans > 0 then
					spawn(function()
						local BackgroundDim = PlayerGui.BG.Background.Background.BackgroundDim
						local transparencyValue = DefaultBackgroundTrans + 0.1

						TweenService:Create(BackgroundDim, TweenInfo.new(0.1, Enum.EasingStyle.Linear), { BackgroundTransparency = transparencyValue }):Play()
						wait(0.1)
						TweenService:Create(BackgroundDim, TweenInfo.new(0.5, Enum.EasingStyle.Linear), { BackgroundTransparency = DefaultBackgroundTrans }):Play()
					end)
				end

				script.Parent.BPMTick.KiaiTime.Value = true
				script.Parent.GameplayScripts.KiaiEffect.Disabled = not ExclusiveEffects
			else
				script.Parent.BPMTick.KiaiTime.Value = false
				script.Parent.GameplayScripts.KiaiEffect.Disabled = true

				local PlayFrame = script.Parent.PlayFrame
				local CursorArea = script.Parent.CursorField
				local Background = PlayerGui.BG.Background.Background

				TweenService:Create(PlayFrame, TweenInfo.new(math.abs(PlayFrame.Rotation) / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Rotation = 0, Position = UDim2.new(.5, 0, .5, 0) }):Play()
				TweenService:Create(CursorArea, TweenInfo.new(math.abs(PlayFrame.Rotation) / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Rotation = 0, Position = UDim2.new(.5, 0, .5, 0) }):Play()
				TweenService:Create(Background, TweenInfo.new(math.abs(PlayFrame.Rotation) / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Rotation = 0, Position = UDim2.new(.5, 0, .5, 0) }):Play()
			end
		end
	end
end)

script.Parent.SpinnerScore.Event:Connect(function(SpinnerScore)
	-- Spinner only affect score, not accuracy
	AccuracyData.SpinnerScore += SpinnerScore
	Score += SpinnerScore
	TotalScoreEstimated += SpinnerScore
	if SpinnerScore == 100 then
		AddHP(0.0085)
	else
		AddHP(0.01)
	end
end)

local SpinStart = tick()
local RPM = 500	

if AutoPlay then
	RunService.Stepped:Connect(function()
		local TimeElapsed = tick() - SpinStart
		local Rotation = (TimeElapsed - math.floor(TimeElapsed))*360*(RPM/60)
		script.Parent.ATSpinner.SpinPart.Orientation = Vector3.new(0,Rotation,0)
	end)
end


if isSpectating == true then
	repeat wait() until Start ~= tick()+2
end

--------    Perfomance score - This will effect alot on player's online rank

local PSPunishment = 0 -- Limit: [0,TotalNote*10] Each miss will add 50 point on it, getting 300s will reduce 1 point
local PSPunishmentLimit = #BeatmapData*10 
local PSPunishmentMin = 0 -- Each miss will add 5 point on this, this thing CAN NOT be recovered

-- Calculate the maxPS value
local DiffValue = {
	Aim = ReturnData.Difficulty.AimDifficulty,
	Speed = ReturnData.Difficulty.SpeedDifficulty,
	Flashlight = ReturnData.Difficulty.FlashLightDifficulty,
	Base = ReturnData.Difficulty.BeatmapDifficulty,
	LengthBonus = 0.95 + 0.4 * math.min(1,#BeatmapData/2000) + ((#BeatmapData > 2000 and math.log10(#BeatmapData/2000) * 0.5) or 0)
}

local ConvertedODRate = math.clamp(ReturnData.Difficulty.OverallDifficulty * (EasyMod and 0.5 or (HardRock and 1.4 or 1)),0,10)
local Hit300Time = 80 - 6 * ConvertedODRate
Hit300Time /= SongSpeed
ConvertedODRate = -(Hit300Time - 80) / 6

local MaxPSValue = {
	Aim = math.pow(5 * math.max(1,DiffValue.Aim/0.0675) - 4, 3) / 100000 * DiffValue.LengthBonus * (0.98 + math.pow(ConvertedODRate, 2) / 2500),
	Speed = math.pow(5.0 * math.max(1, DiffValue.Speed / 0.0675) - 4, 3) / 100000 * DiffValue.LengthBonus * (0.95 + math.pow(ConvertedODRate,2)/750),
	Acc = math.pow(1.52163,ConvertedODRate) * 2.83 * math.min(1.15,math.pow(#BeatmapData/1000,0.3)) / 1.0858,
	Flashlight = 25 * math.pow(DiffValue.Flashlight, 2) * (0.7 + 0.2 * math.min(1,#BeatmapData/200)) + (#BeatmapData > 200 and (0.2 * math.min(1, (#BeatmapData-200)/200)) or 0) * (0.98 + math.pow(ConvertedODRate,2)/2500),
	Mod = {Aim = 1, Speed = 1, Acc = 1, Flashlight = 1}
}	

if true then
	local ModdedARRate = ApproachRate

	if SongSpeed ~= 1 then
		local ARTime = 1200
		if ApproachRate < 5 then
			ARTime = 1200 + 600 * (5 - ApproachRate) / 5
		elseif ApproachRate > 5 then
			ARTime = 1200 - 750 * (ApproachRate - 5) / 5
		else
			ARTime = 1200
		end

		ARTime /= SongSpeed

		if ARTime > 1200 then
			ModdedARRate = 5 - (ARTime - 1200)*5/600
		else
			ModdedARRate = 5 + (1200 - ARTime)*5/750
		end
	end

	local AimARFactor = 0
	local SpeedARFactor = 0

	if ModdedARRate > 10.33 then
		AimARFactor = 0.3 * (ModdedARRate - 10.33)
		SpeedARFactor = 0.3 * (ModdedARRate - 10.33)
	elseif ModdedARRate < 8 then
		AimARFactor = 0.05 * (8 - ModdedARRate)
	end

	MaxPSValue.Aim *= 1 + AimARFactor * DiffValue.LengthBonus
	MaxPSValue.Speed *= 1 + SpeedARFactor * DiffValue.LengthBonus

	if NoFail then
		MaxPSValue.Mod.Aim *= 0.9
		MaxPSValue.Mod.Speed *= 0.9
		MaxPSValue.Mod.Acc *= 0.9
		MaxPSValue.Mod.Flashlight *= 0.9
	end

	if HiddenMod then
		MaxPSValue.Mod.Aim *= 1 + 0.04 * (12 - ModdedARRate)
		MaxPSValue.Mod.Speed *= 1 + 0.04 * (12 - ModdedARRate)
		MaxPSValue.Mod.Acc *= 1.08
		MaxPSValue.Mod.Flashlight *= 1 + 0.04 * (12 - ModdedARRate)
	end

	if Flashlight then
		MaxPSValue.Mod.Acc *= 1.02
	end

	if TouchDeviceDetected then 
		MaxPSValue.Mod.Aim *= 0.6
		MaxPSValue.Mod.Flashlight *= 0.6
	end

	if SongSpeed ~= 1 then
		MaxPSValue.Mod.Acc *= math.pow(SongSpeed, 1.45)
	end
end




-- GameplayPS
-- Higher ps, more ps will reward. This thing work like top play of osu

local AimPSList = {0}
local StreamPSList = {0}
local RecentPerfomanceList = {}
local AimRecentPerfomanceList = {}
local OverallPSList = {}
local ExtraPerfomance = 0

local StrainData = {
	CurrentAim = 0,
	HighestAim = 0,
	CurrentStream = 0,
	HighestStream = 0,
	CurrentOverall = 0,
	HighestOverall = 0
}

CurrentLiveDiffAim = 0
CurrentLiveDiffSpeed = 0
CurrentLiveDiffFL = 0
LiveDiffLastHit = tick()

local Missed = false -- If turn on, pp based on combo will enabled

if PSDisplay == true then
	script.Parent.PSEarned.Visible = true
end

script.Parent.PSEarned.DetailedDisplay.Visible = DetailedPSDisplay
if OptimizedPerfomance then
	script.Parent.PSEarned.AnimatedPSEarned.Visible = false
	script.Parent.PSEarned.TextTransparency = 0
end

LiveDiffValue = Instance.new("NumberValue")
DiffGraphList = ReturnData.Difficulty.DifficultyStrike.List
StrikeLock = false
if not Flashlight then
	script.Parent.LiveDiffDisplay.Flashlight.Visible = false
end

ProcessFunction(function()
	local LiveDiffDisplay = script.Parent.LiveDiffDisplay
	local DiffStrikeWarning = LiveDiffDisplay.DiffStrikeWarning
	local basePerfomance = require(workspace.PerfomanceCalculator.BasePerfomance)
	--local LiveDiffValue = LiveDiffDisplay.LiveDiffValue

	local waittime = 0
	if OptimizedPerfomance then
		waittime = 0.1
	end
	while wait(waittime) do
		script.Parent.LiveDiffDisplay.Visible = LiveDifficultyDisplay
		if not LiveDifficultyDisplay then
			wait(1)
			continue
		end
		if OptimizedPerfomance and waittime == 0 then
			waittime = 0.1
		elseif not OptimizedPerfomance and waittime == 0.1 then
			waittime = 0
		end
		local exRate = 1/2.25
		local mulRate = 1.44226

		local CalculatedAimDiff = math.pow(CurrentLiveDiffAim, exRate) * mulRate * math.pow(0.15, tick() - LiveDiffLastHit)
		local CalculatedSpeedDiff = math.pow(CurrentLiveDiffSpeed, exRate) * mulRate * math.pow(0.3, tick() - LiveDiffLastHit)
		local CalculatedFLDiff = math.pow(CurrentLiveDiffFL, exRate) * mulRate * math.pow(0.15, tick() - LiveDiffLastHit)

		CalculatedAimDiff /= 4.53871
		CalculatedSpeedDiff /= 4.53871
		CalculatedFLDiff /= 4.53871

		local RewardedAimPS = basePerfomance(CalculatedAimDiff)
		local RewardedSpeedPS = basePerfomance(CalculatedSpeedDiff)
		local RewardedFlashlightPS =  basePerfomance(CalculatedFLDiff)

		local diffCalcPS = ((RewardedAimPS^1.1+RewardedSpeedPS^1.1 +RewardedFlashlightPS^1.1)^(1/1.1))

		local CalculatedLiveDiff = 0.027 * math.pow(1.15, 1/3) * (math.pow(100000 / math.pow(2, 1 / 1.1) * diffCalcPS ,1/3) + 4)
		if diffCalcPS < 0.01 then
			CalculatedLiveDiff = 0
		end

		local CurrentGraphNum = math.floor(#DiffGraphList / (BeatmapLength / 1000) * (tick() - Start)) + 1
		local CurrentGraph = DiffGraphList[CurrentGraphNum] or DiffGraphList[1]
		local NextGraph = math.max(DiffGraphList[CurrentGraphNum + 1] or 0, DiffGraphList[CurrentGraphNum + 2] or 0)

		if NextGraph and NextGraph >= 60 and NextGraph >= ReturnData.Difficulty.BeatmapDifficulty - 40 and NextGraph >= CurrentGraph + 10 then
			DiffStrikeWarning.Visible = true
			StrikeLock = true
		elseif not StrikeLock or CalculatedLiveDiff * 10 >= DiffGraphList[CurrentGraphNum - 1] or 0 + 7.5 then
			StrikeLock = false
			DiffStrikeWarning.Visible = false
		end

		TweenService:Create(LiveDiffValue, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {Value = CalculatedLiveDiff}):Play()

		local CurrentDiff = LiveDiffValue.Value
		local ActualDiff = CalculatedLiveDiff
		LiveDiffDisplay.Text = string.format("DR: %.2f",math.max(ActualDiff))
		LiveDiffDisplay.Aim.Text = string.format("%.2f",math.max(CalculatedAimDiff))
		LiveDiffDisplay.Speed.Text = string.format("%.2f",math.max(CalculatedSpeedDiff))
		LiveDiffDisplay.Flashlight.Text = string.format("%.2f",math.max(CalculatedFLDiff))
	end
end)
if not Flashlight then
	script.Parent.PSEarned.DetailedDisplay.Flashlight.Visible = false
end

function AddPerfomanceScore(PSValue)
	if PSValue then
		CurrentLiveDiffAim *= PSValue.AimStrainDecay
		CurrentLiveDiffAim += PSValue.Aim
		CurrentLiveDiffSpeed *= PSValue.SpeedStrainDecay
		CurrentLiveDiffSpeed += PSValue.Stream
		if Flashlight then
			CurrentLiveDiffFL *= PSValue.FLStrainDecay
			CurrentLiveDiffFL += PSValue.Flashlight
		end
		LiveDiffLastHit = tick()
	end

	local TotalHit = AccuracyData.h300 + AccuracyData.h100 + AccuracyData.h50 + AccuracyData.miss
	local Accuracy = (AccuracyData.h300*3 + AccuracyData.h100 + AccuracyData.h50*0.5) / (TotalHit * 3)
	local BetterAcc = ((AccuracyData.h300 - (TotalHit - #BeatmapData)) * 3 + AccuracyData.h50 + AccuracyData.h50 * 0.5) / (#BeatmapData * 3)
	local MissCount = AccuracyData.miss
	local AimPS = MaxPSValue.Aim
	local SpeedPS = MaxPSValue.Speed
	local FlashlightPS = MaxPSValue.Flashlight
	local AccPS = MaxPSValue.Acc
	local Consistency = 1
	local Scaling = math.min(math.pow(TotalHit, 0.8) / math.pow(#BeatmapData, 0.8), 1.0)



	if MissCount > 0 then
		AimPS *= 0.97 * math.pow(1 - math.pow(MissCount / TotalHit, 0.775), MissCount)
		SpeedPS *= 0.97 * math.pow(1 - math.pow(MissCount / TotalHit, 0.775), math.pow(MissCount, 0.875))
		FlashlightPS *= 0.97 * math.pow(1 - math.pow(MissCount / TotalHit, 0.775), math.pow(MissCount, .875))
	end

	-- it's pretty easy to adjust AimPS based on Accuracy
	AimPS *= Accuracy

	-- but in the other hand, SpeedPS and AccPS isn't that easy...
	SpeedPS *= (0.95 + math.pow(OverallDifficulty, 2) / 750) * math.pow(Accuracy, (14.5 - math.max(OverallDifficulty, 8)) / 2)
	-- nerf doubletapping effect
	SpeedPS *= math.pow(0.99, (AccuracyData.h50 < TotalHit / 500) and 0 or (AccuracyData.h50 - TotalHit / 500))

	AccPS *= math.pow(BetterAcc, 24)

	-- flashlight (if avaiable)

	FlashlightPS *= 0.5 + Accuracy / 2.0;

	AimPS *= Scaling
	SpeedPS *= Scaling
	AccPS *= Scaling
	FlashlightPS *= Scaling


	local ModPS = AimPS * (MaxPSValue.Mod.Aim-1) + SpeedPS * (MaxPSValue.Mod.Speed-1) + AccPS * (MaxPSValue.Mod.Acc-1) + FlashlightPS * (MaxPSValue.Mod.Flashlight-1)


	local TotalPS = math.pow(AimPS^0.95 + SpeedPS^0.95 + AccPS^0.95 + FlashlightPS^0.95,1/0.95) + ModPS
	CurrentPerfomance = TotalPS
	local LivePSDisplay = script.Parent.PSEarned
	local DetailedPSDisplay = LivePSDisplay.DetailedDisplay
	LivePSDisplay.Text = string.format("%.0fps",TotalPS)
	DetailedPSDisplay.Aim.Text = string.format("Aim | %.1fps",AimPS)
	DetailedPSDisplay.Speed.Text = string.format("Speed | %.1fps",SpeedPS)
	DetailedPSDisplay.Flashlight.Text = string.format("Flashlight | %.1fps",FlashlightPS)
	DetailedPSDisplay.Mod.Text = string.format("Mod | %.1fps",ModPS)
	DetailedPSDisplay.Accuracy.Text = string.format("Acc | %.1fps",AccPS)

	return TotalPS
end


local LastHitError = 0

ProcessFunction(function()
	while wait() do
		local HitElapsed = (tick() - LastHitError)
		if HitElapsed > 2 and script.Parent.HitError.CurrentDelay.Delay.ImageTransparency == 0 then
			TweenService:Create(script.Parent.HitError.CurrentDelay.Delay,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{ImageTransparency = 1}):Play()
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
	-- can be called as HitWindow hit 
	local Pos = (HitDelay+hit50)/(hit50*2)
	TweenService:Create(script.Parent.HitError,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(0.5,1)}):Play()
	TweenService:Create(script.Parent.HitError.CurrentDelay.Delay,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(Pos,0,0.5,0),ImageTransparency = 0}):Play()
	TweenService:Create(script.Parent.HitError.CurrentDelay.UnstableRate,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{TextTransparency = 0}):Play()
	LastHitError = tick()

	TotalHit += 1

	if HitDelay >= 0 then
		AccuracyData.OffsetPositive.Total += 1
		AccuracyData.OffsetPositive.Value += HitDelay
	else
		AccuracyData.OffsetNegative.Total += 1
		AccuracyData.OffsetNegative.Value += HitDelay
	end
	AccuracyData.OffsetOverall.Total += 1
	AccuracyData.OffsetOverall.Value += HitDelay

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
		TweenService:Create(NewHitDelay,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{Size = UDim2.new(0,2,0.75,0), BackgroundTransparency = 0.1}):Play()
		wait(0.25)
		TweenService:Create(NewHitDelay,TweenInfo.new(9.75,Enum.EasingStyle.Linear),{BackgroundTransparency = 1}):Play()
		wait(9.75)
		NewHitDelay:Destroy()
	end)
end

--warn((tick()-Start)*1000 - HitObj.Time,hit50)



local FramePerSec = 0

RunService.Stepped:Connect(function()
	FramePerSec += 1
	wait(1)
	FramePerSec -= 1
end)


local MetaDataFrame = script.Parent.MetaData

spawn(function()
	wait(1)
	MetaDataFrame.Artist.Text = ReturnData.Overview.Metadata.SongCreatorUnicode
	MetaDataFrame.SongName.Text = "<b>"..ReturnData.Overview.Metadata.MapNameUnicode.."</b>"

	local _1 = TweenInfo.new(2.25,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out)
	local _2 = TweenInfo.new(2.25,Enum.EasingStyle.Exponential,Enum.EasingDirection.In)

	TweenService:Create(MetaDataFrame.Artist,_1,{TextTransparency = 0, Position = UDim2.new(0.5,0,0,0)}):Play()
	TweenService:Create(MetaDataFrame.SongName,_1,{TextTransparency = 0, Position = UDim2.new(0.5,0,0,22)}):Play()
	wait(2.75)
	TweenService:Create(MetaDataFrame.Artist,_2,{TextTransparency = 1, Position = UDim2.new(0.5,50,0,0)}):Play()
	TweenService:Create(MetaDataFrame.SongName,_2,{TextTransparency = 1, Position = UDim2.new(0.5,-100,0,22)}):Play()
end)

isLoaded = true

------------------------------
-- osu!RoVer gameplay start here

DisplayingHitnote = {}

ProcessFunction(function()
	if not AutoPlay and not isSpectating and not ReplayMode then return end
	while wait(0.5) do
		if gameEnded then break end
		for id, data in pairs(DisplayingHitnote) do
			if tick() - Start > data.Time/1000 + 10 then
				DisplayingHitnote[id] = nil
			end 
		end
	end
end)

local ReplayData = {
	PositionData = {},
	ClickData = {K1={},K2={},K3={},K4={}}
}

local ReplayDataValue = script.Parent.GameplayData.CurrentReplayData
ReplayDataValue.Value = HttpService:JSONEncode(ReplayData)

game.ReplicatedStorage.UserReplaySaves.ControlRemote.ReplayUpload:FireServer(1,CurrentKey.."-"..tostring(LocalPlayer.UserId))

function UploadReplay(Method,Data1,Data2,Data3)
	game.ReplicatedStorage.UserReplaySaves.ControlRemote.ReplayUpload:FireServer(Method,Data1,Data2,Data3)
end

ProcessFunction(function()
	while wait(1) do
		local FileSize = game.ReplicatedStorage.UserReplaySaves.ControlRemote.GetCurrentReplaySize:InvokeServer()
		script.Parent.ReplayDataStatusDisplay.Text = "Replay file size: "..tostring(math.floor(FileSize/1024)).."Kb"
	end
end)

TotalReplayLength = 0
ReplayDataEncoded = ""

--[[
Encoded = [[
	1234567890ABC
		1: HitValue
		2345: Position X (0000 - 9999) (BasePos: 5000 - Pos)
		4567: Position Y (like above)
		890ABC: Timing in ms (-99999 - 999999)
]
]]
if not ReplayMode and not isSpectating and not onTutorial then

	function getReplayFormat(P,H,T)
		local Digit1 = "0" -- Hit [0 - false, 1 - true, 2 - nil] (1 byte)
		local Digit2 = "00000000" -- Position of X and Y (8 bytes) (0000 - 4999: NegativePosition) (5000 - 9999:PositivePosition)
		local DigitOthers = "0" -- Timing in ms (1 - 6 byte)
		if H then
			Digit1 = tostring(H)
		end
		local Digit2_1 = tostring(math.round(5000+P.X.Scale*512))
		local Digit2_2 = tostring(math.round(5000+P.Y.Scale*384))
		Digit2_1 = string.rep("0",4-#Digit2_1)..Digit2_1
		Digit2_2 = string.rep("0",4-#Digit2_2)..Digit2_2
		local Digit3 = tostring(math.round(T))
		local Encoded = Digit1..Digit2_1..Digit2_2..Digit3
		ReplayDataEncoded = ReplayDataEncoded.."\n"..Encoded
		--print(string.len(ReplayDataEncoded))
	end

	ProcessFunction(function()
		local PastPosition = UDim2.new(0,0,0,0)
		local LastRecord = tick()
		while wait() do
			if tick() - LastRecord < 1/120 then
				continue
			end
			LastRecord = tick()
			ProcessFunction(function()
				local CurrentTime = math.round((tick() - Start)*1000-SongDelay/SongSpeed)
				local CursorPosition = Cursor.Position
				if PastPosition ~= CursorPosition then
					--local DecodedPosition = {X=math.floor(CursorPosition.X.Scale*512+0.5),Y=math.floor(CursorPosition.Y.Scale*384+0.5)}

					--local FullData = {P = DecodedPosition,T = CurrentTime}
					local FullData = getReplayFormat(CursorPosition,nil,CurrentTime)
					--UploadReplay(2,FullData,1)
				end
				PastPosition = CursorPosition
			end)
		end
	end)

	MouseHitEvent.Event:Connect(function(_,KeyHit)
		local CurrentTime = math.round((tick() - Start)*1000-SongDelay/SongSpeed)
		--local FullData = {H = true,T = CurrentTime}

		--UploadReplay(2,FullData,2,KeyHit)
		local FullData = getReplayFormat(Cursor.Position,KeyHit,CurrentTime)
	end)

	MouseHitEndEvent.Event:Connect(function(_,KeyHit)
		local CurrentTime = math.round((tick() - Start)*1000-SongDelay/SongSpeed)
		--local FullData = {H = false,T = CurrentTime}

		--UploadReplay(2,FullData,2,KeyHit)
		local FullData = getReplayFormat(Cursor.Position,KeyHit+4,CurrentTime)
	end)
end

--[[
-- Hit mark

MouseHitEvent.Event:Connect(function()
	local CursorLocation = CursorPosition
	
	local new = Instance.new("Frame")
	new.Parent = script.Parent.PlayFrame
	new.Size = UDim2.new(0,10,0,10)
	new.BackgroundColor3 = Color3.new(1,1,1)
	new.Position = UDim2.new(CursorLocation.X/512,0,CursorLocation.Y/384,0)
	
	TweenService:Create(new, TweenInfo.new(2, Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
	wait(2)
	new:Destroy()
end)
]]
replayReRun = false
replayReady = true

if ReplayMode then
	-- Disable all common mods (to prevent bugs)
	ClassicNotelock = false
	-------
	local ReplayData = {}

	local i = 1
	local Finish = false
	local count = 0
	repeat 
		local Next,_ = string.find(ReplayDataRaw,"\n",i)
		if not Next then
			Finish = true
			break
		elseif i == 0 or not tonumber(string.sub(ReplayDataRaw,i,i)) then
			ProcessReplayData(string.sub(ReplayDataRaw,i,Next-1))
			i = Next+1
			continue
		end
		local End = Next-1
		local KeyPress = tonumber(string.sub(ReplayDataRaw,i,i))
		local PositionX = tonumber(string.sub(ReplayDataRaw,i+1,i+4))
		local PositionY = tonumber(string.sub(ReplayDataRaw,i+5,i+8))
		local Timing = tonumber(string.sub(ReplayDataRaw,i+9,End))
		ReplayData[#ReplayData+1] = {Timing,KeyPress,PositionX,PositionY}
		i = Next+1
	until Finish == true
	local restartframeposvalue = Instance.new("BoolValue",script.Parent.ScriptSettings)
	restartframeposvalue.Name = "RestartGameRightSite"
	restartframeposvalue.Value = false
	local SpectateName = Instance.new("StringValue",script.Parent.GameplayData)
	SpectateName.Name = "SpectateName"
	SpectateName.Value = FinaleReplayData.User
	local Display = string.format("Watching replay:\n<b>%s</b>\nPlayed by <b>%s</b>",FinaleReplayData.FileName,FinaleReplayData.User)

	PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire(Display,Color3.new(1,1,1))
	--PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("This feature is on beta testing, some possible bugs and isssue can appear.",Color3.new(1,1,1))
	--PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("Make a new play to watch it's replay.",Color3.new(1,1,1))

	local ReplayDelay = 0
	if Replay_TouchDevice then
		ReplayDelay = -100
	end
	local CurrentYieldHit

	ProcessFunction(function()
		local function play()
			local disabled = false
			ProcessFunction(function()
				while wait() do
					if replayReRun then
						disabled = true

						replayReady = true
						repeat wait() until not replayReRun
						play()
					end
				end
			end)
			for _,data in pairs(ReplayData) do
				if disabled then break end
				local HitTiming = data[1]
				if Replay_TouchDevice then
					-- add a timing for TD replay
					HitTiming += 100
				end
				if (tick() - Start) + (1/GameplayFPS) < (HitTiming/1000+SongDelay/1000/SongSpeed) + ReplayDelay/1000 then
					repeat wait() until (tick() - Start) + (1/GameplayFPS) >= (HitTiming/1000+SongDelay/1000/SongSpeed) + ReplayDelay/1000
				end
				ProcessFunction(function()
					--print(math.floor(((tick() - Start) - data[1]/1000)*1000))
					CursorPosition = Vector2.new(data[3]-5000,data[4]-5000)
					--MouseHitEvent
					--MouseHitEndEvent
					if Replay_TouchDevice then
						if CurrentYieldHit then
							CurrentYieldHit()
						end

						-- I will put this in the next move
						CurrentYieldHit = (function()
							if data[2] > 0 and data[2] <=4 then
								MouseHitEvent:Fire(SecurityKey,data[2])
							elseif data[2] > 0 then
								MouseHitEndEvent:Fire(SecurityKey,data[2]-4)
							end
						end)
					else
						-- for non TD mod, we do it instantly

						if data[2] > 0 and data[2] <=4 then
							MouseHitEvent:Fire(SecurityKey,data[2])
						elseif data[2] > 0 then
							MouseHitEndEvent:Fire(SecurityKey,data[2]-4)
						end
					end
				end)
			end
		end
		play()
	end)

end

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

--[[
local EstimatedTotalScore = 0

for i = 1,#BeatmapData do
	EstimatedTotalScore += 300 + (300 * ((((i > 2 and i-2) or 0) * ScoreMultiplier.Difficulty * 1) / 25))
end]]

--[[
	local Score = 0
for i = 1,1000 do
	Score += 300 + (300 * ((((i > 2 and i-2) or 0) * 6 * 1) / 25))
end
print(Score)
]]



if onTutorial then
	script.Parent.Storyboard.TutorialStoryboard.StoryboardScript.LocalScript.Disabled = false
	script.Parent.Leaderboard.Visible = false
end

-- when all loaded, reset the timer
Start = tick()+3
SongStart = tick()+3
isIn_GameQuickRestart = false
isOnTimeJump = false

script.Parent.Development.TimeJump.Event:Connect(function(Time)
	if not (tonumber(Time)) or Time < -3 or Time > 999 or Time ~= Time or OnMultiplayer then return end
	isOnTimeJump = true
	local New = Start + (tick() - Start) - Time
	if New > Start then
		isIn_GameQuickRestart = true
	end

	repeat wait() until not isIn_GameQuickRestart
	AccuracyData = cloneTable(AccTemplate)

	for _,obj in pairs(script.Parent.PlayFrame:GetChildren()) do
		if obj.Name ~= "Flashlight" then
			obj:Destroy()
		end
	end

	Start = New
	SongStart = New


	for i = 1,60 do wait() end
	HealthPoint = MaxHealthPoint
	HealthDrainMultiplier = 1

	isOnTimeJump = false

	PlayRanked = false
	script.Parent.UnrankedSign.Visible = true
end)
if SliderMode == true then
	if ReturnData.WeirdSliderAlert == true then
		PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("This beatmap contain some weird sliders shape/movement that may lead you to miss.",Color3.fromRGB(255,0,0))
	end
	if ReturnData.SliderCrashAlert == true then
		PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("This beatmap contain some sliders that may make your device to lag/crash.",Color3.fromRGB(255,0,0))
	end
end

-- Note score

function AddScore(HitValue)
	local Combo = AccuracyData.Combo
	Score += HitValue + (HitValue * ((((Combo > 2 and Combo-2) or 0) * ScoreMultiplier.Difficulty * ScoreMultiplier.Mod) / 25))
	TotalScoreEstimated += 300 + (300 * ((((EstimatedCombo > 2 and EstimatedCombo-2) or 0) * ScoreMultiplier.Difficulty * ScoreMultiplier.Mod) / 25))
end


-- Lagstrike Fix
PrevRenderTick = tick()
LagStrikeEvent = Instance.new("BindableEvent")

if not ReplayMode and not isSpectating and not OnMultiplayer then
	RunService.Stepped:Connect(function()
		local DelayPerFrame = tick() - PrevRenderTick
		if DelayPerFrame > 1/GameplayFPS + 0.1 then
			Start += DelayPerFrame
			SongStart += DelayPerFrame
			LagStrikeEvent:Fire()
		end

		PrevRenderTick = tick()
	end)
end

-- AT Configuration 
if AutoPlay then
	ClassicNotelock = true -- AT can only run stable on this
	if ReturnData.BeatmapSetsData.BeatmapID == "1529760" and not NoFail and SliderMode then
		PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("The autoplay cannot pass this trust me.",Color3.fromRGB(255,0,0))
	end
end

-- Secret perks

if ReturnData.BeatmapSetsData.BeatmapID == "1529760" and SliderMode and math.random(1,100) == 100 then
	PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("Fun fact, this map's difficulty rating is actually approximately 110.55 and might worth around 1,414,302ps",Color3.fromRGB(255, 255, 255))
end

if math.random(1,10000) == 727 then
	Score += 1
	PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("You have found a secret message, therefore you've got 1 extra point for this play :D",Color3.fromRGB(0, 255, 0))
end



-- SORTING THE TIMING BEFORE PLAYING

table.sort(BeatmapData, function(obj1,obj2)
	if obj1.Time<obj2.Time then
		return true
	elseif obj1.Time==obj2.Time then
		return obj1.ObjId<obj2.ObjId
	end
	return false
end)

function NextComboColorIndex(jumpCount)
	for i = 1, jumpCount do
		if CurrentComboColor >= #ComboColor then
			CurrentComboColor = 1
		else
			CurrentComboColor += 1
		end
	end
end

NoteBasePreloadTime = 500 -- Time in ms for the circle to preload, help decrease latency
StackLeniency = ReturnData.StackLeniency
StackVector = 0
do
	local CSRate = ReturnData.Difficulty.CircleSize * ((HardRock and 1.3) or (EasyMod and 0.5) or 1)
	local ObjectRadius = 54.4 - 4.48 * CSRate
	StackVector = ObjectRadius / 10
end

-- HIT OBJ LINE
function LetTheGameBegin()
	for i,HitObj in pairs(BeatmapData) do
		if isIn_GameQuickRestart then break end
		local HitNoteID = i
		local HitMiss = false
		local IsHitted = false
		local isLastComboNote = false
		local AnimationIdList = {}
		local SliderATKey = 3

		if HardRock then
			HitObj.Position = {X = HitObj.Position.X,Y=384-HitObj.Position.Y} -- swap the note Y-Axis
		end

		local NoteId = HttpService:GenerateGUID()

		local function AddHitnoteAnimation(TweenAnimation)
			if not TweenAnimation:IsA("Tween") then
				return TweenAnimation
			end
			local AnimationId = HttpService:GenerateGUID(false)
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
		local HitObjProperties = ObjectTools.GetObjectProperties(CurrentType)

		if HitObjProperties.isSpinner then  --- spinner
			repeat wait() until (tick()-Start) >= (HitObj.Time-1500)/1000
		else
			if i == 1 then -- the very first note
				repeat wait() until (tick()-Start) >= (HitObj.Time-CircleApproachTime-NoteBasePreloadTime)/1000
			elseif (tick()-Start)*1000 < HitObj.Time-CircleApproachTime then	-- yield until the next note avaiable
				repeat wait() until (tick()-Start) >= (HitObj.Time-CircleApproachTime-NoteBasePreloadTime)/1000
			end
		end


		if TotalNotes > NoteDisplayLimit then -- The note count should not exceed the display limit
			repeat wait() until TotalNotes <= NoteDisplayLimit
		end
		NoteCompleted += 1

		ProcessFunction(function()
			wait((HitObj.Time)/1000 - (tick()-Start))
			NPS += 1 wait(1/SongSpeed) NPS -= 1
			AddHealthDrainMultiplier(1)
		end)

		-- Combo here is the Combo is a color group
		-- Not combo used to calculate point

		if HitObjProperties.isNewCombo then
			Combo = 1
			ComboNoteData = {Full300 = true,Missor50 = false,Missed = false} -- reset the combo data
			local ComboJump = 1 + HitObjProperties.ColorSkip
			NextComboColorIndex(ComboJump)
		else
			Combo += 1
		end

		if not HitObjProperties.isSpinner then
			DisplayingHitnote[HitNoteID] = {X = HitObj.Position.X,Y = HitObj.Position.Y, Id = HitNoteID, Time = HitObj.Time}
		end

		TotalNotes += 1
		ProcessFunction(function()
			if (isSpectating == true or isOnTimeJump) and tick() - Start > (HitObj.Time+hit50)/1000 then
				Combo = 1
				CurrentCursorPos = HitNoteID + 1
				CurrentHitnote = HitNoteID + 1
				TotalNotes -= 1
				return
			end
			if HitObj.Time < -1550 then
				local Type = HitObj.Type
				if HitObjProperties.isNewCombo then
					Combo = 1
					local ComboJump = 1 + HitObjProperties.ColorSkip
					NextComboColorIndex(ComboJump)
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

			if HitObjProperties.isSpinner then -- Spinner
				if AutoPlay == true and ReplayMode ~= true then
					local SpinKey = 3 -- default
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
							local CurrentSession = HttpService:GenerateGUID()
							KeySession.K1 = CurrentSession
						else
							if RightClick == true then
								RightClick = false
								LastClick = tick()
								MouseHitEvent:Fire(SecurityKey,3)
								SpinKey = 3
								local CurrentSession = HttpService:GenerateGUID()
								KeySession.K1 = CurrentSession
							else
								RightClick = true
								LastClick = tick()
								MouseHitEvent:Fire(SecurityKey,4)
								SpinKey = 4
								local CurrentSession = HttpService:GenerateGUID()
								KeySession.K2 = CurrentSession
							end
						end
						local Connection = script.Parent.ATSpinner.SpinPart.Changed:Connect(function()
							local LookVector = script.Parent.ATSpinner.SpinPart.CFrame.LookVector
							local Pos = UDim2.new(((256+(LookVector.X*128)))/512,0,((192+(LookVector.Z*128)))/384,0)
							TweenService:Create(ATVC,TweenInfo.new(0.01,Enum.EasingStyle.Linear),{Position = Pos}):Play()
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
				local RoundRequiredPerSec = 2.5  -- OD 5: 150RPM
				local MaximumRoundPerSec = 4.5 -- Maximum 450RPM


				if OverallDifficulty < 5 then
					RoundRequiredPerSec = 2.5 - 1 * (5-OverallDifficulty)/5  -- 90 - 150RPM
				else
					RoundRequiredPerSec = 2.5 + 1.25 * (OverallDifficulty-5)/5 -- 150 - 225RPM
				end


				local RoundRequired = SpinnerTime*RoundRequiredPerSec -- 100 RPM avg for 300s, 75 for 100s, 50 for 50s, else = miss
				local RoundMaximum = math.ceil(SpinnerTime*MaximumRoundPerSec)


				Spinner.SpinEnd.Value = HitObj.SpinTime
				Spinner.SpinTime.Value = SpinnerTime
				Spinner.RoundRequired.Value = RoundRequired
				Spinner.MaxSpin.Value = math.max(RoundRequired+1, RoundMaximum)
				Spinner.SpinnerSpeed.Value = SongSpeed
				Spinner.StartTick.Value = Start
				Spinner.SpinnerTiming.Value = HitObj.Time
				Spinner.Spinner.SpinnerScript.Disabled = false


				repeat wait() until tick() - Start >= (HitObj.SpinTime)/1000

				local Ratio = Spinner.Spinner.RoundSpinned.Value/Spinner.RoundRequired.Value


				local function CreateHitResult(HitResult)
					if HitResult == 4 and not Hit300Display then return end

					ProcessFunction(function()
						local FrameList = {
							[1] = script.HitMiss,
							[2] = script.Hit50,
							[3] = script.Hit100,
							[4] = script.Hit300
						}

						local NewHitResult = FrameList[HitResult]:Clone()
						NewHitResult.Parent = script.Parent.PlayFrame
						NewHitResult.ZIndex = 999999999
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
							AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{ImageTransparency = 0,Size = UDim2.new(2,0,2,0)})):Play()
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


				if Ratio >= 0.25 or SpinnerTime < 0.2 then
					AccuracyData.Combo += 1
					EstimatedCombo += 1

					AccuracyData.BaseConsistency += AccuracyData.Combo
					AccuracyData.MaxConsistency += EstimatedCombo
					AccuracyData.PerfomanceCombo += 1 
					if AccuracyData.PerfomanceCombo > AccuracyData.MaxPeromanceCombo then
						AccuracyData.MaxPeromanceCombo = AccuracyData.PerfomanceCombo
					end
					if AccuracyData.Combo > AccuracyData.MaxCombo then
						AccuracyData.MaxCombo = AccuracyData.Combo
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
					if Ratio >= 1 or SpinnerTime < 0.05 then
						AccuracyData.h300 += 1
						CreateHitResult(4)
						AddScore(300)
						AddHP(0.03 + 0.07)
						AddPerfomanceScore(HitObj.PSValue)
					elseif Spinner.RoundRequired.Value-Spinner.Spinner.RoundSpinned.Value <= 1 then
						AccuracyData.h100 += 1
						CreateHitResult(3)
						AddScore(100)
						AddHP(0.011 + 0.05)
						AddPerfomanceScore(HitObj.PSValue)
					else
						AccuracyData.h50 += 1
						CreateHitResult(2)
						AddScore(50)
						AddHP(0.002 + 0.03)
						AddPerfomanceScore(HitObj.PSValue)
					end
				else
					if AccuracyData.Combo >= 20 then
						script.Parent.ComboBreak:Play()
					end
					AccuracyData.Combo = 0
					EstimatedCombo += 1
					AccuracyData.MaxConsistency += EstimatedCombo
					AccuracyData.PerfomanceCombo = 0
					Missed = true
					AddPerfomanceScore(HitObj.PSValue)
					AccuracyData.miss += 1
					MissedInCurrentTime = true
					AddScore(0)
					DrainHP(-0.03, -0.125, -0.2)
					CreateHitResult(1)
					HitMiss = true
				end
				if not OptimizedPerfomance then
					wait(1)
				end
				Spinner:Destroy()
			else -- HitNote and Slider
				LastNoteData = {Slider = false}
				local function waitUntil(condition)
					while not condition() do
						wait()
					end
				end
				
				-- Process autoplay of the hit circle
				if AutoPlay == true and ReplayMode ~= true then
					ProcessFunction(function()
						local EarlyRequired = false

						if (CurrentCursorPos < HitNoteID or CurrentHitnote < HitNoteID) and (tick() - Start) * 1000 <= HitObj.Time then
							waitUntil(function()
								return CurrentCursorPos >= HitNoteID and CurrentHitnote >= HitNoteID
							end)
						end

						if HitMiss == true then
							CurrentCursorPos = HitNoteID + 1
							return
						end

						if CurrentHitnote < HitNoteID then
							waitUntil(function()
								return CurrentHitnote >= HitNoteID
							end)
						end

						local TimeUntilNoteClicked = (tick() - Start) * 1000 - HitObj.Time

						local bonustiming = (EarlyRequired and hit300 * 0.5) or 0
						local TimeWithAR = TimeUntilNoteClicked - CircleApproachTime
						local CursorTweenTime = math.abs((TimeWithAR > 0 and 0) or (TimeWithAR > -500 and -TimeWithAR) or 500)

						if TimeUntilNoteClicked < 0 then
							wait(math.max((-TimeUntilNoteClicked - CursorTweenTime) / 1000, 0))
						end

						local TimeUntilNoteClicked = math.min((tick() - Start) * 1000 - (HitObj.Time + bonustiming), 0)
						local CursorTweenTime = math.abs((TimeUntilNoteClicked > 0 and 0) or (TimeUntilNoteClicked > -500 and -TimeUntilNoteClicked) or 500)

						local AvgFrameTime = (1 / FramePerSec) * 1000
						local Tween = TweenService:Create(ATVC, TweenInfo.new(CursorTweenTime / 1000, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Position = UDim2.new(HitObj.Position.X / 512, 0, HitObj.Position.Y / 384, 0) })

						if CursorTweenTime > AvgFrameTime then
							Tween:Play()
						else
							ATVC.Position = UDim2.new(HitObj.Position.X / 512, 0, HitObj.Position.Y / 384, 0)
						end

						if CursorTweenTime > AvgFrameTime and (tick() - Start) <= (HitObj.Time + hit300) / 1000 then
							waitUntil(function()
								return (tick() - Start) > (HitObj.Time-1000/GameplayFPS*0.5) / 1000 or (tick() - Start) >= (HitObj.Time) / 1000
							end)
						end

						if Tween then
							Tween:Pause()
						end

						ATVC.Position = UDim2.new(HitObj.Position.X / 512, 0, HitObj.Position.Y / 384, 0)

						CurrentNoteId = NoteId

						if not HitObjProperties.isSlider or not SliderMode then
							AutoClick()
						else
							if tick() - LastClick > 0.25 then
								RightClick = false
								LastClick = tick()
								MouseHitEvent:Fire(SecurityKey, 3)
								SliderATKey = 3
								KeySession.K1 = HttpService:GenerateGUID()
							else
								if RightClick == true then
									RightClick = false
									LastClick = tick()
									MouseHitEvent:Fire(SecurityKey, 3)
									SliderATKey = 3
									KeySession.K1 = HttpService:GenerateGUID()
								else
									RightClick = true
									LastClick = tick()
									MouseHitEvent:Fire(SecurityKey, 4)
									SliderATKey = 4
									KeySession.K2 = HttpService:GenerateGUID()
								end
							end
						end

						if not HitObjProperties.isSlider or SliderMode == false then
							CurrentCursorPos = HitNoteID + 1
						end
					end)
				end

				local Connection
				local SLEndPos


				ProcessFunction(function()
					-- processing the circle connection
					if BeatmapData[i+1] ~= nil and (BeatmapData[i+1].Type == 1 or BeatmapData[i+1].Type == 2) then
						local NextHitObj = BeatmapData[i+1]
						local HitObjPos = Vector2.new(HitObj.Position.X,HitObj.Position.Y)

						if SliderMode and HitObjProperties.isSlider then
							repeat wait() until SLEndPos
							if HardRock then
								HitObjPos = Vector2.new(SLEndPos.X,384-SLEndPos.Y)
							else
								HitObjPos = Vector2.new(SLEndPos.X,SLEndPos.Y)
							end
						end

						local NextHitObjPos

						if HardRock and not (SliderMode and HitObjProperties.isSlider) then
							NextHitObjPos = Vector2.new(NextHitObj.Position.X,384-NextHitObj.Position.Y)
						else
							NextHitObjPos = Vector2.new(NextHitObj.Position.X,NextHitObj.Position.Y)
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
						LookVector /= (LookVector.Magnitude/(CircleSize*0.5))

						-- check

						if math.abs((HitObjPos-NextHitObjPos).magnitude) > CircleSize then

							Connection = script.Connection:Clone()
							local Pos = (HitObjPos+NextHitObjPos)/2
							local Size = math.abs((HitObjPos-NextHitObjPos).magnitude)-(CircleSize)
							local FirstPos = UDim2.new((HitObjPos.X+LookVector.X)/512,0,(HitObjPos.Y+LookVector.Y)/384,0)

							local EndPos = UDim2.new((NextHitObjPos.X-LookVector.X)/512,0,(NextHitObjPos.Y-LookVector.Y)/384,0)

							local Pos = UDim2.new(Pos.X/512,0,Pos.Y/384,0)
							local Size = UDim2.new(Size/512,0,0,3)

							Connection.Parent = script.Parent.PlayFrame
							Connection.Position = FirstPos
							Connection.Rotation = Rotation
							Connection.Size = UDim2.new(0,0,0,6)
							Connection.ZIndex = ZIndex-2
							Connection.BackgroundTransparency = 0
							--Connection.RemoveTime.Value = NextHitObj.Time

							ProcessFunction(function()
								wait((NextHitObj.Time/1000+2) - (tick()-Start))
								if Connection and Connection.Parent ~= nil then
									Connection:Destroy()
								end
							end)



							local DisplayTime = (((NextHitObj.Time+100)-HitObj.Time)> 100/SongSpeed and NextHitObj.Time-HitObj.Time) or 100/SongSpeed
							local TweenTime = (NextHitObj.Time-HitObj.Time > 50/SongSpeed and NextHitObj.Time-HitObj.Time) or 50/SongSpeed

							ProcessFunction(function()
								repeat wait() until tick() - Start >= (HitObj.Time - CircleApproachTime)/1000
								local ct_ = TweenService:Create(Connection,TweenInfo.new(TweenTime/1000,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{BackgroundTransparency = 0.5,Position = Pos,Size = Size})
								AddHitnoteAnimation(ct_)
								ct_:Play()
							end)
							if (tick() - Start)*1000 < NextHitObj.Time-250/SongSpeed then
								wait((NextHitObj.Time-250/SongSpeed)/1000 - (tick()-Start))
								local ct_ = TweenService:Create(Connection,TweenInfo.new(0.25/SongSpeed,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{BackgroundTransparency = 0.5,Position = EndPos,Size = UDim2.new(0,0,0,3)})
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
				HitObj.ComboColor = ComboColor[CurrentComboColor]
				if tick() - Start < (HitObj.Time - CircleApproachTime)/1000 then
					ProcessFunction(function()
						Circle.Visible = false
						repeat wait() until tick() - Start >= (HitObj.Time - CircleApproachTime)/1000
						Circle.Visible = true
					end)
				end
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
				end

				-------------------- Hit result -------------------------------

				local function CreateHitResult(HitResult)
					if HitResult == 4 and not Hit300Display then return end
					ProcessFunction(function()
						local FrameList = {
							[1] = script.HitMiss,
							[2] = script.Hit50,
							[3] = script.Hit100,
							[4] = script.Hit300}

						local NewHitResult = FrameList[HitResult]:Clone()
						NewHitResult.Parent = script.Parent.PlayFrame
						NewHitResult.ZIndex = 999999999
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
							AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(0.1/SongSpeed,Enum.EasingStyle.Linear),{ImageTransparency = 0,Size = UDim2.new(2,0,2,0)})):Play()
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
					if HitResult == 4 and not Hit300Display then return end
					ProcessFunction(function()
						local FrameList = {
							[1] = script.HitMiss,
							[2] = script.Hit50,
							[3] = script.Hit100,
							[4] = script.Hit300}

						local NewHitResult = FrameList[HitResult]:Clone()
						NewHitResult.Parent = script.Parent.PlayFrame
						NewHitResult.ZIndex = 999999999
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
							TweenService:Create(NewHitResult.Image,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{ImageTransparency = 0,Size = UDim2.new(2,0,2,0)}):Play()
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
				local SliderTime = HitObj.SliderTime  -- -1 -- wait until slider time loaded
				local SliderTickOffset = 0
				local LastHold = 0


				if HitObjProperties.isSlider and SliderMode == true then
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


					local CurrentBPM = HitObj.HitObjBPMData.BPM
					local CurrentSliderMulti = HitObj.HitObjBPMData.SliderMultiplier
					local DefaultSliderMultiplier = SliderMultiplier
					local LastBPMTiming = HitObj.HitObjBPMData.LastBPMTiming

					if i >= #BeatmapData then
						LastNoteData = {Slider = true,SliderTime = SliderTime}
					end

					local CurrentPos = 3
					local CurveData = HitObj.ExtraData[2]
					-- Follow circle
					local FollowCircle = script.SliderFollowCircle:Clone()
					local H,S,V = HitObj.ComboColor:ToHSV()
					if V < 0.75 then
						V = 0.75
					end
					FollowCircle.isFollow.ImageColor3 = Color3.fromHSV(H, S, V)
					FollowCircle.SliderFollowCircle.ImageColor3 = HitObj.ComboColor
					FollowCircle.Parent = SliderFolder
					FollowCircle.ZIndex = ZIndex + 1
					FollowCircle.Size = UDim2.new(CircleSize/384/SLCanvasScale,0,CircleSize/384/SLCanvasScale,0)
					FollowCircle.Position = UDim2.new(0.5-(0.5-HitObj.Position.X/512)/SLCanvasScale,0,0.5-(0.5-HitObj.Position.Y/384)/SLCanvasScale,0)


					SliderCurvePoints[1] = HitObj.Position
					if StackLeniency > 0 and HitObj.StackCount > 0 then
						-- we set it back to default
						SliderCurvePoints[1].X += HitObj.StackCount * StackVector
						SliderCurvePoints[1].Y += HitObj.StackCount * StackVector
					end
					local raw = string.split(CurveData, "|")
					for i, crrPos in pairs(raw) do
						if i == 1 then continue end -- this is the curve type, pass it

						local posData = string.split(crrPos, ":")
						SliderCurvePoints[#SliderCurvePoints+1] = {X = tonumber(posData[1]), Y = tonumber(posData[2])} --Vector2.new(tonumber(posData[1], tonumber(posData[2])))
					end
					if Slides % 2 == 0 then
						SLEndPos = SliderCurvePoints[1]
					else
						SLEndPos = SliderCurvePoints[#SliderCurvePoints]
					end

					if HardRock then
						for i,a in pairs(SliderCurvePoints) do
							if i~=1 then
								SliderCurvePoints[i] = {X = a.X,Y=384-a.Y}
							end
						end
					end

					if #SliderCurvePoints > 400 then -- I will have to decrease the points count to make it less lag
						local env = ExternalFunction_Actor.ProcessCommand:Invoke("Core_OsuGame_ProcessLargeSliderPoints",{
							SliderCurvePoints = SliderCurvePoints
						})
						SliderCurvePoints = env.SliderCurvePoints
					end

					local resultpos = string.find(CurveData,"|")
					local SliderCurveType = string.sub(CurveData,resultpos-1,resultpos-1)


					local Alvaiable = false

					if SliderCurveType == "B" or SliderCurveType == "P" then
						local env = ExternalFunction_Actor.ProcessCommand:Invoke("Core_OsuGame_ProcessSliderCurveType",{
							SliderCurvePoints = SliderCurvePoints
						})
						
						SliderCurvePoints = env.SliderCurvePoints
					end
					local function calculateCircleCurve(pointA, pointB, pointC, numPoints)
						numPoints = numPoints or 20  -- Default to 20 if not provided
						local curvePoints = {}

						-- Validate input points and return an empty table if invalid
						if not (pointA and pointB and pointC) or 
							(type(pointA) ~= "table" or type(pointB) ~= "table" or type(pointC) ~= "table") or
							(not pointA.X or not pointA.Y or not pointB.X or not pointB.Y or not pointC.X or not pointC.Y) then
							return curvePoints  -- Return empty table if inputs are invalid
						end

						-- Precompute some values
						local lengthAB = (pointB - pointA).Magnitude
						local lengthBC = (pointC - pointB).Magnitude
						local angleAB = math.atan2(pointB.Y - pointA.Y, pointB.X - pointA.X)
						local angleBC = math.atan2(pointC.Y - pointB.Y, pointC.X - pointB.X)
						local angleDiff = math.abs(angleBC - angleAB)

						-- Use table preallocation for performance
						curvePoints = table.create(numPoints)

						-- Generate curve points
						for i = 1, numPoints do
							local tFraction = i / numPoints
							local angle = angleAB + tFraction * angleDiff

							-- Calculate radius based on the progression along the arc
							local radius = lengthAB + lengthBC * tFraction

							local x = math.cos(angle) * radius + pointA.X
							local y = math.sin(angle) * radius + pointA.Y

							curvePoints[i] = {X = x, Y = y}  -- Direct insertion for performance
						end

						return curvePoints
					end



					if SliderCurveType == "P" and false then
						local OriginalPoints = SliderCurvePoints
						if #OriginalPoints == 3 then
							local NewPoints = calculateCircleCurve(
								Vector2.new(SliderCurvePoints[1].X,SliderCurvePoints[1].Y),
								Vector2.new(SliderCurvePoints[2].X,SliderCurvePoints[2].Y),
								Vector2.new(SliderCurvePoints[3].X,SliderCurvePoints[3].Y)
							)

							SliderCurvePoints = NewPoints
						end
					end
					
					if StackLeniency > 0 and HitObj.StackCount > 0 then
						-- set the curve point to adjust with the stack leniency
						for _, vector in pairs(SliderCurvePoints) do
							vector.X -= HitObj.StackCount * StackVector
							vector.Y -= HitObj.StackCount * StackVector
						end
					end

					local ReverseArrowData = {}
					local ReverseArrowObject = {}

					-- Caclculate reverse arrow position

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

						ReverseArrow.ZIndex = ZIndex+1
						ReverseArrow.Size = UDim2.new((CircleSize*0.6)/384/SLCanvasScale,0,(CircleSize*0.6)/384/SLCanvasScale,0)
						ReverseArrow.Position = UDim2.new(0.5-(0.5-Data[1].X/512)/SLCanvasScale,0,0.5-(0.5-Data[1].Y/384)/SLCanvasScale,0)
						ReverseArrow.Rotation = Data[2]+180

						ReverseArrowObject[i] = ReverseArrow
					end



					local SliderLength = 0
					local SliderConnections = {}
					local LengthData = {0}
					
					local env = ExternalFunction_Actor.ProcessCommand:Invoke("Core_OsuGame_ProcessSliderConnection", {
						SliderLength = SliderLength,
						SliderConnections = SliderConnections,
						LengthData = LengthData,
						SliderCurvePoints = SliderCurvePoints,
						GolbalSliderConnections = GolbalSliderConnections
					}) 
					
					SliderLength = env.SliderLength
					SliderConnections = env.SliderConnections
					LengthData = env.LengthData
					SliderCurvePoints = env.SliderCurvePoints
					GolbalSliderConnections = env.GolbalSliderConnections
					
					-- Evaculate timing and position of the slider tick
					-- SliderTickOffset


					local SliderTickData = {}

					for Slide = 1, Slides do
						local TickData = {}
						local SlideStart = HitObj.Time / 1000 + SliderTickOffset + SliderTime * (Slide - 1) / Slides
						local SlideTime = SliderTime / Slides

						for ConnectionOrder, a in pairs(SliderConnections) do
							local ConnectionStart = SlideStart + a.LengthStart / SliderLength * SlideTime
							local ConnectionEnd = SlideStart + a.LengthStop / SliderLength * SlideTime
							local ConnectionTimingOffset = (ConnectionStart - LastBPMTiming / 1000) % (60 / CurrentBPM)
							ConnectionTimingOffset = ConnectionTimingOffset - (60 / CurrentBPM)
							local MaxTick = math.floor((ConnectionEnd - (ConnectionStart + ConnectionTimingOffset)) / (60 / CurrentBPM))

							local InvaildCount = 0

							for i = 1, MaxTick do
								local Timing = ConnectionStart + ConnectionTimingOffset + 60 / CurrentBPM * (i - InvaildCount - 1)
								local TimingLength = Timing / (ConnectionEnd - ConnectionStart)

								if Timing > ConnectionEnd then
									break
								end

								if math.abs(Timing - ConnectionStart) > 0.01 and math.abs(Timing - ConnectionEnd) > 0.01 then
									TickData[#TickData + 1] = { Timing, ConnectionOrder, TimingLength }
								else
									InvaildCount = InvaildCount + 1
								end
							end
						end

						SliderTickData[Slide] = TickData
					end



					-- Draw slider shadow
					-- This feature is still working on progress
					-- Might cause lag for mid-end and low-end device
					local function lerp(a,b,rate)
						return a + (b-a)*rate
					end
					local ShadowCount = 15
					local ShadowSizeMax = 1
					local ShadowSizeMin = 0.1
					local ColorValueMin = 0
					local ColorValueMax = 0.1
					if OptimizedPerfomance then
						ShadowCount = 5
					end


					for i,Data in pairs(SliderConnections) do
						local HoldCircle = ObjectManagement_Actor.ToggleCloneObject:Invoke(script.HoldCircle, SliderFolder, {
							Name = tostring((i/#SliderConnections)*0.25),
							Position = UDim2.new(0.5-(0.5-Data.Pos.X/512)/SLCanvasScale,0,0.5-(0.5-Data.Pos.Y/384)/SLCanvasScale,0),
							Rotation = Data.Rotation,
							Size = UDim2.new(((Data.Length-Data.ExtraLength)/512/SLCanvasScale),0,(CircleSize/384)*0.85/SLCanvasScale,0),
							BackgroundColor3 = Color3.new(0.0392157, 0.0392157, 0.0392157),
							ZIndex = ZIndex-ShadowCount-2
						})
						HoldCircle.UICorner:Destroy()
						local Outline = ObjectManagement_Actor.ToggleCloneObject:Invoke(HoldCircle, SliderFolder, {
							Name = tostring((i/#SliderConnections)*0.25),
							Size = UDim2.new(((Data.Length-Data.ExtraLength)/512/SLCanvasScale),0,CircleSize/384/SLCanvasScale,0),
							ZIndex = ZIndex-ShadowCount-3,
							BackgroundColor3 = Color3.new(1, 1, 1),
						})
						if EnableSliderShadow then
							-- drawing shadows
							for i = ShadowCount-1,0,-1 do
								local SizeRate = lerp(ShadowSizeMin, ShadowSizeMax, i/ShadowCount)
								local HoldCircle = ObjectManagement_Actor.ToggleCloneObject:Invoke(script.HoldCircle, SliderFolder, 
									{
										Name = tostring((i/#SliderConnections)*0.25),
										Position = UDim2.new(0.5-(0.5-Data.Pos.X/512)/SLCanvasScale,0,0.5-(0.5-Data.Pos.Y/384)/SLCanvasScale,0),
										Rotation = Data.Rotation,
										Size = UDim2.new(((Data.Length-Data.ExtraLength)/512/SLCanvasScale),0,(CircleSize/384)*SizeRate*0.85/SLCanvasScale,0),
										BackgroundColor3 = Color3.fromHSV(0,0,lerp(ColorValueMax,ColorValueMin,i/ShadowCount)),
										ZIndex = ZIndex-i,
									}
								)

								HoldCircle.UICorner:Destroy()
							end
						end
					end

					local ReverseSliderConnection = {}

					for i = 1,#SliderConnections do
						table.insert(ReverseSliderConnection,1,SliderConnections[i])
					end

					for i,SliderPoint in pairs(SliderCurvePoints) do
						local HoldCircle = ObjectManagement_Actor.ToggleCloneObject:Invoke(script.HoldCircle, SliderFolder, {
							Name = tostring((i/#SliderCurvePoints)*0.25),
							BackgroundColor3 = Color3.new(0.0392157, 0.0392157, 0.0392157),
							Position = UDim2.new(0.5-(0.5-SliderPoint.X/512)/SLCanvasScale,0,0.5-(0.5-SliderPoint.Y/384)/SLCanvasScale,0),
							Size = UDim2.new((CircleSize/384)*0.85/SLCanvasScale,0,(CircleSize/384)*0.85/SLCanvasScale,0),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							ZIndex = ZIndex-ShadowCount-1
						})
						local Outline = ObjectManagement_Actor.ToggleCloneObject:Invoke(HoldCircle, SliderFolder, {
							Name = tostring((i/#SliderCurvePoints)*0.25),
							Size = UDim2.new((CircleSize/384)/SLCanvasScale,0,(CircleSize/384)/SLCanvasScale,0),
							ZIndex = ZIndex-ShadowCount-3,
							BackgroundColor3 = Color3.new(1, 1, 1)
						})

						if EnableSliderShadow then
							-- drawing shadows
							for i = ShadowCount-1,0,-1 do
								local SizeRate = lerp(ShadowSizeMin, ShadowSizeMax, i/ShadowCount)
								local HoldCircle = ObjectManagement_Actor.ToggleCloneObject:Invoke(script.HoldCircle, SliderFolder, 
									{
										Name = tostring((i/#SliderCurvePoints)*0.25),
										BackgroundColor3 = Color3.fromHSV(0,0,lerp(ColorValueMax,ColorValueMin,i/ShadowCount)),
										Position = UDim2.new(0.5-(0.5-SliderPoint.X/512)/SLCanvasScale,0,0.5-(0.5-SliderPoint.Y/384)/SLCanvasScale,0),
										Size = UDim2.new((CircleSize/384)*SizeRate*0.85/SLCanvasScale,0,(CircleSize/384)*SizeRate*0.85/SLCanvasScale,0),
										SizeConstraint = Enum.SizeConstraint.RelativeYY,
										ZIndex = ZIndex-i
									})
							end
						end
					end

					-- We're just creating the slider base, not running it yet
					-- Wait until it's ready to run
					repeat wait() until tick() - Start >= (HitObj.Time - CircleApproachTime)/1000
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
						local MaxTick = math.floor((SliderTime-SliderTickOffset)/TimePerBeat*ReturnData.Difficulty.SliderTickRate)-1
						local TickTime = (60/CurrentBPM)/ReturnData.Difficulty.SliderTickRate
						local StartComboTime = Start + HitObj.Time/1000
						LastComboTime = Start + HitObj.Time/1000
						ProcessFunction(function()
							for CurrentTick = 1,MaxTick do
								local Next = StartComboTime + TickTime * CurrentTick
								repeat wait() until tick() >= Next
								if Completed then

									break 
								end
								if math.abs(Next - LastComboTime) > 0.1/SongSpeed and math.abs(Next - NextComboTime) > 0.1 then
									InSliderTickRequired += 1
									if (isInFollowCircle() == true and script.Parent.KeyDown.Value == true) or tick() - LastHold < 0.1 then
										if i ~= Slides then
											Score += 10
											TotalScoreEstimated += 10
										end
										AccuracyData.Combo+=1
										EstimatedCombo += 1
										AccuracyData.BaseConsistency += AccuracyData.Combo
										AccuracyData.MaxConsistency += EstimatedCombo
										TickCollected += 1
										AddHP(0.015)
										if AccuracyData.Combo > AccuracyData.MaxCombo then
											AccuracyData.MaxCombo = AccuracyData.Combo
										end
										CreateHitSound(5)
									else
										if AccuracyData.Combo >= 20 then
											script.Parent.ComboBreak:Play()
										end
										AccuracyData.Combo = 0
										EstimatedCombo += 1
										AccuracyData.MaxConsistency += EstimatedCombo
										AccuracyData.PerfomanceCombo = 0
										Missed = true
										DrainHP(-0.02, -0.075, -0.14)
									end
								end
							end
						end)
						FollowCircle.Visible = true
						local function createSliderTween(positionX, positionY, scale, duration)
							local function waitForHitted()
								if AutoPlay == true and ReplayMode ~= true then
									if not IsHitted and not Completed then
										repeat
											wait()
										until IsHitted == true or Completed
									end

								end
							end

							TweenService:Create(FollowCircle, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Position = UDim2.new(0.5 - (0.5 - positionX / 512) / SLCanvasScale, 0, 0.5 - (0.5 - positionY / 384) / SLCanvasScale, 0) }):Play()
							if AimAssist then
								TweenService:Create(script.Parent.CursorField.AimAssitTarget,TweenInfo.new(duration,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Position = UDim2.new(0.5 - (0.5 - positionX / 512) / SLCanvasScale, 0, 0.5 - (0.5 - positionY / 384) / SLCanvasScale, 0)}):Play()
							end
							if Circle.Parent then
								TweenService:Create(Circle, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Position = UDim2.new(0.5 - (0.5 - positionX / 512), 0, 0.5 - (0.5 - positionY / 384), 0) }):Play()
							end

							ProcessFunction(function()
								waitForHitted()

								if not Completed then
									TweenService:Create(ATVC, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Position = UDim2.new(0.5 - (0.5 - positionX / 512) / 1, 0, 0.5 - (0.5 - positionY / 384) / 1, 0) }):Play()
								end
							end)
						end
						for CurrentSlide = 1,Slides do
							AddHealthDrainMultiplier(0.7)
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
							if (CurrentSlide / 2) - math.floor(CurrentSlide / 2) == 0.5 then


								for i, SliderPoint in pairs(SliderCurvePoints) do
									if i ~= 1 then
										local SliderPointLength = SliderConnections[i - 1].Length
										local SliderPointDuration = (SliderTime * (SliderPointLength / SliderLength)) / Slides

										TotalDuration = TotalDuration + SliderPointDuration

										createSliderTween(SliderCurvePoints[i].X, SliderCurvePoints[i].Y, SLCanvasScale, SliderPointDuration)
										if tick() - Start < HitObj.Time / 1000 + TotalDuration then
											repeat
												wait()
											until tick() - Start >= HitObj.Time / 1000 + TotalDuration
										end
									end
								end
							else
								local ReverseSliderCurvePoints = {}

								for i = #SliderCurvePoints, 1, -1 do
									table.insert(ReverseSliderCurvePoints, 1, SliderCurvePoints[i])
								end

								for i, SliderPoint in pairs(ReverseSliderCurvePoints) do
									if i ~= 1 then
										local SliderPointLength = ReverseSliderConnection[i - 1].Length
										local SliderPointDuration = (SliderTime * (SliderPointLength / SliderLength)) / Slides
										createSliderTween(SliderCurvePoints[#SliderCurvePoints - i + 1].X, SliderCurvePoints[#SliderCurvePoints - i + 1].Y, SLCanvasScale, SliderPointDuration)

										TotalDuration = TotalDuration + SliderPointDuration

										if tick() - Start < HitObj.Time / 1000 + TotalDuration then
											repeat
												wait()
											until tick() - Start >= HitObj.Time / 1000 + TotalDuration
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
							local onTouch = false
							while wait() and not Completed do
								if isInFollowCircle() == true and script.Parent.KeyDown.Value == true then
									if not script.Parent.PlayFrame.Flashlight.SliderDim.isDim.Value then
										script.Parent.PlayFrame.Flashlight.SliderDim.isDim.Value = true
										TweenService:Create(script.Parent.PlayFrame.Flashlight.SliderDim,TweenInfo.new(0.05,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.2}):Play()
									end
									if FollowCircle:FindFirstChild("isFollow") then
										--FollowCircle.isFollow.Visible = true
										if not onTouch then
											TweenService:Create(FollowCircle.isFollow,TweenInfo.new(math.min(0.25/SongSpeed,SliderTime*0.75),Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{ImageTransparency = 0, Size = UDim2.new(2.5,0,2.5,0)}):Play()
										end
										onTouch = true
									end
									LastHold = tick()
								else
									if script.Parent.PlayFrame.Flashlight.SliderDim.isDim.Value then
										script.Parent.PlayFrame.Flashlight.SliderDim.isDim.Value = false
										TweenService:Create(script.Parent.PlayFrame.Flashlight.SliderDim,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{BackgroundTransparency = 1}):Play()
									end
									if FollowCircle:FindFirstChild("isFollow") then
										--FollowCircle.isFollow.Visible = false
										if onTouch then
											TweenService:Create(FollowCircle.isFollow,TweenInfo.new(0.25/SongSpeed,Enum.EasingStyle.Linear),{ImageTransparency = 1, Size = UDim2.new(4,0,4,0)}):Play()
										end
										onTouch = false
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
										AccuracyData.Combo+=1
										EstimatedCombo += 1
										AccuracyData.BaseConsistency += AccuracyData.Combo
										AccuracyData.MaxConsistency += EstimatedCombo
										TickCollected += 1
										AddHP(0.02)
										if AccuracyData.Combo > AccuracyData.MaxCombo then
											AccuracyData.MaxCombo = AccuracyData.Combo
										end
										if i < Slides then
											CreateHitSound(0,NoteNormalSampleSet,math.clamp(HitObj.Position.X/512,0,1))
										else
											local HitSoundType = tonumber(HitObj.ExtraData[1])
											CreateHitSound(0,NoteNormalSampleSet) -- normal
											if HitSoundType == 2 or HitSoundType == 14 or HitSoundType == 6 or HitSoundType == 10 then
												CreateHitSound(2,NoteAditionSampleSet,math.clamp(HitObj.Position.X/512,0,1)) -- whistle
											end
											if HitSoundType == 4 or HitSoundType == 14 or HitSoundType == 6 or HitSoundType == 12 then
												CreateHitSound(1,NoteAditionSampleSet,math.clamp(HitObj.Position.X/512,0,1)) -- finish
											end
											if HitSoundType == 8 or HitSoundType == 14 or HitSoundType == 10 or HitSoundType == 12 then
												CreateHitSound(3,NoteAditionSampleSet,math.clamp(HitObj.Position.X/512,0,1)) -- clap
												if NoteAditionSampleSet ~= "3" then
													CreateHitSound(4,NoteAditionSampleSet,math.clamp(HitObj.Position.X/512,0,1)) -- clap2
												end
											end
										end
									else
										DrainHP(-0.02, -0.075, -0.14)
									end
								elseif i < Slides then
									if AccuracyData.Combo >= 20 then
										script.Parent.ComboBreak:Play()
									end
									AccuracyData.Combo = 0
									EstimatedCombo += 1
									AccuracyData.MaxConsistency += EstimatedCombo
									AccuracyData.PerfomanceCombo = 0
									Missed = true
									AddPerfomanceScore(HitObj.PSValue)
									DrainHP(-0.02, -0.075, -0.14)
								end
							end
							-----------------
							local TickRequired = Slides+1+InSliderTickRequired
							local HitResultPosition = Slides%2 == 1 and SliderCurvePoints[#SliderCurvePoints] or SliderCurvePoints[1]

							AddHealthDrainMultiplier(0.7)

							if TickCollected >= TickRequired then
								if isLastComboNote then
									if ComboNoteData.Full300 then
										AddHP(0.03 + 0.07)
									elseif not ComboNoteData.Missor50 then
										AddHP(0.03 + 0.05)
									else
										AddHP(0.03 + 0.03)
									end
								else
									AddHP(0.03)
								end
								AccuracyData.PerfomanceCombo += 1 
								if AccuracyData.PerfomanceCombo > AccuracyData.MaxPeromanceCombo then
									AccuracyData.MaxPeromanceCombo = AccuracyData.PerfomanceCombo
								end
								AccuracyData.h300 += 1
								AddScore(300)
								AddPerfomanceScore(HitObj.PSValue)
								CreateSliderHitResult(4,SliderCurvePoints[#SliderCurvePoints])
							elseif TickCollected/TickRequired >= 0.5 then
								if isLastComboNote then
									if not ComboNoteData.Missor50 then
										AddHP(0.011 + 0.05)
									else
										AddHP(0.011)
									end
								else
									ComboNoteData.Full300 = false
									AddHP(0.011)
								end
								AccuracyData.h100 += 1
								AddScore(100)
								CreateSliderHitResult(3,SliderCurvePoints[#SliderCurvePoints])
								AddPerfomanceScore(HitObj.PSValue)
							elseif TickCollected > 0 then
								AccuracyData.h50 += 1
								AddScore(50)
								if isLastComboNote then
									AddHP(0.002 + 0.03)
								else
									AddHP(0.002)
								end
								CreateSliderHitResult(2,SliderCurvePoints[#SliderCurvePoints])
								AddPerfomanceScore(HitObj.PSValue)
							else
								AccuracyData.PerfomanceCombo = 0
								AccuracyData.miss += 1
								MissedInCurrentTime = true
								AddScore(0)
								DrainHP(-0.03, -0.125, -0.2)
								CreateSliderHitResult(1,SliderCurvePoints[#SliderCurvePoints])
								AccuracyData.Combo = 0
								EstimatedCombo += 1
								AccuracyData.MaxConsistency += EstimatedCombo
								AccuracyData.PerfomanceCombo = 0
								Missed = true
								AddPerfomanceScore(HitObj.PSValue)
								if AccuracyData.Combo >= 20 then
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
							if not InstaFadeCircle then
								--FollowCircle.Parent = script.Parent.PlayFrame
								TweenService:Create(SliderFolder,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{GroupTransparency = 1}):Play()
								--SliderFolder:Destroy()
								TweenService:Create(FollowCircle.isFollow,TweenInfo.new(0,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Size = UDim2.new(2.5,0,2.5,0)}):Play()
								wait()
								TweenService:Create(FollowCircle.isFollow,TweenInfo.new(0.3/SongSpeed,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Size = UDim2.new(1,0,1,0),ImageTransparency = 1}):Play()
								FollowCircle.isFollow.Visible = tick() - LastHold <= 0.1
								FollowCircle.SliderFollowCircle:Destroy()
								wait(0.3/SongSpeed)
							else
								FollowCircle.SliderFollowCircle:Destroy()
							end
							SliderFolder:Destroy()
							FollowCircle:Destroy()
						end)
					end)
				end

				---------------------------------------------------------------------------------------------------------


				local function UpdateHitCircleTransparency(Transparency)
					for _,obj in pairs(Circle:GetDescendants()) do
						if obj:IsA("ImageLabel") then
							if HiddenMod and obj.Name == "ApproachCircle" then continue end
							obj.ImageTransparency = Transparency
						end
					end
				end

				ProcessFunction(function()
					while (tick()-Start)*1000 < HitObj.Time and Circle.Parent do
						local TimeLeft = (HitObj.Time)/1000 - (tick() - Start)
						local TimePassed = CircleApproachTime/1000 - TimeLeft
						local Size = 1+3*TimeLeft/(CircleApproachTime/1000)

						local ObjTrans = (FadeInTime - TimePassed)/FadeInTime
						if HiddenMod then
							if ObjTrans < 0 then
								ObjTrans = math.abs(ObjTrans)
							end
						end

						UpdateHitCircleTransparency(ObjTrans)

						if Circle:FindFirstChild("ApproachCircle") then
							Circle.ApproachCircle.Size = UDim2.new(Size,0,Size,0)
						else
							-- the object got removed, break it
							break
						end

						RunService.RenderStepped:Wait()
					end
				end)
				ProcessFunction(function()
					LagStrikeEvent.Event:Connect(function()
						if IsHitted then return end
						--local FixedApproachTime = -((tick()-Start)*1000 - HitObj.Time)
						--local ApproachSize = (1-(CircleApproachTime-FixedApproachTime)/CircleApproachTime)*3 + 1.1
						--Circle.ApproachCircle.Size = UDim2.new(ApproachSize,0,ApproachSize,0)
						--local ApproachCircleTween = TweenService:Create(Circle.ApproachCircle,TweenInfo.new(FixedApproachTime/1000,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Size = UDim2.new(1.1,0,1.1,0)})
						--AddHitnoteAnimation(ApproachCircleTween)
						--ApproachCircleTween:Play()
					end)

					local ApproachCircleTween

					while not IsHitted do
						script.Parent.GameplayPause.Event:Wait()
						ApproachCircleTween:Pause()
						script.Parent.GameplayResume.Event:Wait()
						if IsHitted then break end
						local FixedApproachTime = -((tick()-Start)*1000 - HitObj.Time)
						local ApproachSize = (1-(CircleApproachTime-FixedApproachTime)/CircleApproachTime)*3 + 1.1
						Circle.ApproachCircle.Size = UDim2.new(ApproachSize,0,ApproachSize,0)
						ApproachCircleTween = TweenService:Create(Circle.ApproachCircle,TweenInfo.new(FixedApproachTime/1000,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Size = UDim2.new(1.1,0,1.1,0)})
						AddHitnoteAnimation(ApproachCircleTween)
						ApproachCircleTween:Play()
					end
				end)



				local CircleHitConnection = false


				ProcessFunction(function()
					if not AimAssist then return end
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
						if not HitObjProperties.isSlider or not SliderMode then
							if ((HitObj.Time+hit50)/1000) - (tick()-Start) > 0 then
								wait(((HitObj.Time+hit50)/1000) - (tick()-Start))
								if tick() - Start < 10000 then
									repeat wait() until (tick()-Start) >= ((HitObj.Time+hit50)/1000) 
								end
							end
						else
							ProcessFunction(function()
								local t2_ = TweenService:Create(Circle.HitCircle,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1})
								AddHitnoteAnimation(t2_)
								t2_:Play()
								for _,Object in pairs(Circle:GetChildren()) do
									ProcessFunction(function()
										if Object:IsA("ImageLabel") and Object.Name ~= "Lightning" then
											TweenService:Create(Object,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()
										end
										if Object:IsA("TextLabel") then
											TweenService:Create(Object,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{TextTransparency = 1,TextStrokeTransparency = 1}):Play()
										end
										if Object.Name == "CircleNumber" then
											for _,a in pairs(Object:GetChildren()) do 
												if a:IsA("ImageLabel") then
													AddHitnoteAnimation(TweenService:Create(a,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1})):Play()
												end
											end
										end
									end)
								end
							end)
							ProcessFunction(function()
								if not OptimizedPerfomance then
									local t2_ = TweenService:Create(Circle.HitCircle,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1})
									AddHitnoteAnimation(t2_)
									t2_:Play()
									Circle.HitCircleLightning:Destroy()
									Circle.Lightning:Destroy()
									for _,Object in pairs(Circle:GetChildren()) do
										ProcessFunction(function()
											if Object:IsA("ImageLabel") and Object.Name ~= "Lightning" then
												TweenService:Create(Object,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()
											end
											if Object:IsA("TextLabel") then
												TweenService:Create(Object,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{TextTransparency = 1,TextStrokeTransparency = 1}):Play()
											end
											if Object.Name == "CircleNumber" then
												for _,a in pairs(Object:GetChildren()) do 
													if a:IsA("ImageLabel") then
														TweenService:Create(a,TweenInfo.new(0.2,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
													end
												end
											end
										end)
									end
								end
							end)
							--Circle.Visible = false
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
								DisplayingHitnote[HitNoteID] = nil
								CircleHitConnection:Disconnect()
							end
							IsHitted = true
							if AccuracyData.Combo >= 20 then
								script.Parent.ComboBreak:Play()
							end
							AccuracyData.Combo = 0
							EstimatedCombo += 1
							AccuracyData.MaxConsistency += EstimatedCombo
							AccuracyData.PerfomanceCombo = 0
							Missed = true
							DrainHP(-0.03, -0.125, -0.2)
							ComboNoteData.Missor50 = true
							ComboNoteData.Full300 = false
							AddPerfomanceScore(HitObj.PSValue)
							CurrentHitnote = HitNoteID + 1
							TotalNotes -= 1
							if not HitObjProperties.isSlider or SliderMode == false then
								AccuracyData.miss += 1
								MissedInCurrentTime = true
								AddScore(0)
								HitMiss = true
								CreateHitResult(1)
							end
							ProcessFunction(function()
								if not Circle.Parent then return end
								if not InstaFadeCircle then
									local t2_ = TweenService:Create(Circle.HitCircle,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1})
									AddHitnoteAnimation(t2_)
									t2_:Play()
									Circle.HitCircleLightning:Destroy()
									Circle.Lightning:Destroy()
									for _,Object in pairs(Circle:GetChildren()) do
										ProcessFunction(function()
											if Object:IsA("ImageLabel") and Object.Name ~= "Lightning" then
												TweenService:Create(Object,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()
											end
											if Object:IsA("TextLabel") then
												TweenService:Create(Object,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{TextTransparency = 1,TextStrokeTransparency = 1}):Play()
											end
											if Object.Name == "CircleNumber" then
												for _,a in pairs(Object:GetChildren()) do 
													if a:IsA("ImageLabel") then
														TweenService:Create(a,TweenInfo.new(0.2,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
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
					return HttpService:GenerateGUID()
				end

				CircleHitConnection = MouseHitEvent.Event:Connect(function(CurrentSecurityKey)
					ProcessFunction(function()
						if CurrentSecurityKey ~= SecurityKey then
							return "no"
						end
						local FramerateFix = 0
						if not AutoPlay and not isSpectating and not ReplayMode then
							-- Experimental
							-- Since the game is likely to get input lag
							-- I'll make so that the game will add an extra timing
							-- Player's input will be half frame earlier
							FramerateFix = (tick() - LastFramerate) * 1000 * 0.5
						end
						local CurrentTime = (tick()-Start)*1000 - FramerateFix
						local HitDelay = CurrentTime - HitObj.Time
						if IsHitted == false then
							local spectatingRetryCount = 10

							--[[
							-- I'm leaving a chance of hit for TD mod
							while (ReplayMode or isSpectating) and (HitDelay <= hit50 and not isincircle()) and spectatingRetryCount < 5 do
								spectatingRetryCount+= 1
								wait()
							end]]

							if ClassicNotelock == true then -- osu!stable notelock
								-- Prevent players from hitting note without clearing previous note
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
									elseif data.Id < HitNoteID and not data.IsHitted then
										PrevNoteExist = true
									end
								end

								if isTop == false then
									-- this note will auto miss as the newer obj get hitted inside h50 window

									IsHitted = true
									if AccuracyData.Combo >= 20 then
										script.Parent.ComboBreak:Play()
									end
									AccuracyData.Combo = 0
									EstimatedCombo += 1
									AccuracyData.MaxConsistency += EstimatedCombo
									AccuracyData.PerfomanceCombo = 0
									Missed = true
									if not HitObjProperties.isSlider or SliderMode == false then
										AccuracyData.miss += 1
										MissedInCurrentTime = true
										AddScore(0)
										CreateHitResult(1)
										AddPerfomanceScore(HitObj.PSValue)
									end
									DrainHP(-0.03, -0.125, -0.2)
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
										if data.Id < HitNoteID and isinPosition(data.X,data.Y) and not data.IsHitted then
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
									if AccuracyData.Combo >= 20 then
										script.Parent.ComboBreak:Play()
									end
									AccuracyData.Combo = 0
									EstimatedCombo += 1
									AccuracyData.MaxConsistency += EstimatedCombo
									AccuracyData.PerfomanceCombo = 0
									Missed = true
									DrainHP(-0.03, -0.125, -0.2)
									CreateHitDelay(Color3.new(1, 0.372549, 0.372549),HitDelay)
									ComboNoteData.Missor50 = true
									ComboNoteData.Full300 = false
									if not HitObjProperties.isSlider or SliderMode == false then
										AccuracyData.miss += 1
										MissedInCurrentTime = true
										AddScore(0)
										CreateHitResult(1)
										AddPerfomanceScore(HitObj.PSValue)
									end
									HitMiss = true
									ProcessFunction(function()
										if Circle.Parent == nil then return end
										if not InstaFadeCircle then
											local t2_ = TweenService:Create(Circle.HitCircle,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1})
											AddHitnoteAnimation(t2_)
											t2_:Play()
											Circle.HitCircleLightning:Destroy()
											Circle.Lightning:Destroy()
											for _,Object in pairs(Circle:GetChildren()) do
												ProcessFunction(function()
													if Object:IsA("ImageLabel") and Object.Name ~= "Lightning" then
														TweenService:Create(Object,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()
													end
													if Object:IsA("TextLabel") then
														TweenService:Create(Object,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{TextTransparency = 1,TextStrokeTransparency = 1}):Play()
													end
													if Object.Name == "CircleNumber" then
														for _,a in pairs(Object:GetChildren()) do 
															if a:IsA("ImageLabel") then
																TweenService:Create(a,TweenInfo.new(0.2,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
															end
														end
													end
												end)
											end
											wait(0.5)
										end
										Circle:Destroy()
									end)
									if Circle.Parent then
										Circle.ApproachCircle:Destroy()
									end
								else
									if Circle.Parent then
										Circle.ApproachCircle:Destroy()
									end

									AccuracyData.Combo += 1
									EstimatedCombo += 1
									AccuracyData.BaseConsistency += AccuracyData.Combo
									AccuracyData.MaxConsistency += EstimatedCombo
									TickCollected += 1
									LastHold = tick()

									if AccuracyData.Combo > AccuracyData.MaxCombo then
										AccuracyData.MaxCombo = AccuracyData.Combo
									end
									ProcessFunction(function()
										local HitSoundType = tonumber(HitObj.ExtraData[1])
										CreateHitSound(0,NoteNormalSampleSet,math.clamp(HitObj.Position.X/512,0,1)) -- normal
										if HitSoundType == 2 or HitSoundType == 14 or HitSoundType == 6 or HitSoundType == 10 then
											CreateHitSound(2,NoteAditionSampleSet,math.clamp(HitObj.Position.X/512,0,1)) -- whistle
										end
										if HitSoundType == 4 or HitSoundType == 14 or HitSoundType == 6 or HitSoundType == 12 then
											CreateHitSound(1,NoteAditionSampleSet,math.clamp(HitObj.Position.X/512,0,1)) -- finish
										end
										if HitSoundType == 8 or HitSoundType == 14 or HitSoundType == 10 or HitSoundType == 12 then
											CreateHitSound(3,NoteAditionSampleSet,math.clamp(HitObj.Position.X/512,0,1)) -- clap
											if NoteAditionSampleSet ~= "3" then
												CreateHitSound(4,NoteAditionSampleSet,math.clamp(HitObj.Position.X/512,0,1)) -- clap2
											end
										end
									end)
									if not HitObjProperties.isSlider or SliderMode == false then
										AccuracyData.PerfomanceCombo += 1 
										if AccuracyData.PerfomanceCombo > AccuracyData.MaxPeromanceCombo then
											AccuracyData.MaxPeromanceCombo = AccuracyData.PerfomanceCombo
										end
										local HitErrorGraph = AccuracyData.HitErrorGraph
										for i,Data in pairs(HitErrorGraph) do
											if HitDelay > Data[1] and  HitDelay <= Data[2] then
												HitErrorGraph[i][3] += 1
												break
											end
										end
										if math.abs(HitDelay) <= hit300 then
											if isLastComboNote then
												if ComboNoteData.Full300 then
													AddHP(0.03 + 0.07)
												elseif not ComboNoteData.Missor50 then
													AddHP(0.03 + 0.05)
												else
													AddHP(0.03 + 0.03)
												end
											else
												AddHP(0.03)
											end

											AccuracyData.h300Bonus += hit300 - math.abs(HitDelay)
											AccuracyData.bonustotal += hit300
											AccuracyData.h300 += 1
											CreateHitDelay(Color3.new(0.686275, 1, 1),HitDelay)
											CreateHitResult(4)
											AddScore(300)
											AddPerfomanceScore(HitObj.PSValue)
										elseif math.abs(HitDelay) <= hit100 then
											if isLastComboNote then
												if not ComboNoteData.Missor50 then
													AddHP(0.011 + 0.05)
												else
													AddHP(0.011 + 0.03)
												end
											else
												ComboNoteData.Full300 = false
												AddHP(0.011 + 0.03)
											end
											AccuracyData.h100 += 1
											CreateHitDelay(Color3.new(0.686275, 1, 0.686275),HitDelay)
											CreateHitResult(3)
											AddScore(100)
											AddPerfomanceScore(HitObj.PSValue)
										else
											ComboNoteData.Missor50 = true
											ComboNoteData.Full300 = false
											if isLastComboNote then
												AddHP(0.002 + 0.03)
											else
												AddHP(0.002)
											end
											AccuracyData.h50 += 1
											CreateHitDelay(Color3.new(1, 1, 0.686275),HitDelay)
											CreateHitResult(2)
											AddScore(50)
											AddPerfomanceScore(HitObj.PSValue)
										end
									else
										AddHP(0.02)
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

									if not InstaFadeCircle then
										local t_ = TweenService:Create(Circle,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Size = UDim2.new(CircleSize*1.25/384,0,CircleSize*1.25/384,0)})
										local t2_ = TweenService:Create(Circle.HitCircle,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{ImageTransparency = 1})
										AddHitnoteAnimation(t_)
										AddHitnoteAnimation(t2_)
										t_:Play()
										t2_:Play()
										Circle.HitCircleLightning:Destroy()
										Circle.Lightning:Destroy()

										for _,Object in pairs(Circle:GetChildren()) do
											ProcessFunction(function()
												if Object:IsA("ImageLabel") and Object.Name ~= "Lightning" then
													TweenService:Create(Object,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()
												end
												if Object:IsA("TextLabel") then
													TweenService:Create(Object,TweenInfo.new(0,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{TextTransparency = 1,TextStrokeTransparency = 1}):Play()
												end
												if Object.Name == "CircleNumber" then
													for _,a in pairs(Object:GetChildren()) do 
														if a:IsA("ImageLabel") then
															TweenService:Create(a,TweenInfo.new(0,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
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
				end)
			end
		end)
	end
	if isIn_GameQuickRestart then
		if ReplayMode then
			replayReady = false
			replayReRun = true

			repeat wait() until replayReady
			replayReRun = false
		end

		isIn_GameQuickRestart = false
		LetTheGameBegin() 
	end
end

LetTheGameBegin()

isDrain = false
TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = DefaultBackgroundTrans}):Play()


function doAnim()
	script.Parent.Interface.Background.Visible = true
	script.Parent.Interface.Background.BackgroundImage.Image = "http://www.roblox.com/asset/?id="..ReturnData.ImageId
	script.Parent.Interface.Background.BackgroundDim.BackgroundTransparency = 0.4
	TweenService:Create(script.Parent.Interface.Background,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{GroupTransparency = 0}):Play()
end

function checkSSAnim()
	-- SS animation process

	if AccuracyData.h100 == 0 and AccuracyData.h50 == 0 and AccuracyData.miss == 0 then
		script.Parent.SS_Animation.MainFrame.StartAnimation.Disabled = false
		wait(1.5)
	end 
end

if isSpectating == false then
	repeat wait() until tick() - Start > (BeatmapData[#BeatmapData].Time + hit50)/1000

	local Type = BeatmapData[#BeatmapData].Type


	if ObjectTools.GetObjectProperties(Type).isSpinner then
		repeat wait() until (tick()-Start) >= BeatmapData[#BeatmapData].SpinTime/1000
		TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.4}):Play()
		script.Parent.Leaderboard.LbTrigger:Fire(true)
		script.Parent.MultiplayerLeaderboard.LbTrigger:Fire(true)
		FLAnimate = false
		TweenService:Create(FlashlightFrame,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = UDim2.new(30,0,30,0),ImageTransparency = 0}):Play()
		doAnim()
		checkSSAnim()
		wait(2)
	else
		repeat wait() until LastNoteData ~= "NotLoaded"
		if LastNoteData.Slider == true then
			wait(LastNoteData.SliderTime)
		end
		TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.4}):Play()
		script.Parent.Leaderboard.LbTrigger:Fire(true)
		script.Parent.MultiplayerLeaderboard.LbTrigger:Fire(true)
		FLAnimate = false
		TweenService:Create(FlashlightFrame,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = UDim2.new(30,0,30,0),ImageTransparency = 0}):Play()
		checkSSAnim()
		doAnim()
		wait(2)
	end
else
	repeat wait() until ScoreResultDisplay == true
	FLAnimate = false
	TweenService:Create(FlashlightFrame,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = UDim2.new(30,0,30,0),ImageTransparency = 0}):Play()
	TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.4}):Play()
	script.Parent.Leaderboard.LbTrigger:Fire(true)
	script.Parent.MultiplayerLeaderboard.LbTrigger:Fire(true)
end




if BeatmapFailed and not OnMultiplayer then
	PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("Dude, how did you failed on that last note!",Color3.fromRGB(255,0,0))
	return -- just in case they failed on the last note
end


if OnMultiplayer then
	script.Parent.MultiplayerWaitFrame.Visible = true
	PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.MultiplayerFolder.Value.WaitForFinish:InvokeServer()
	script.Parent.MultiplayerWaitFrame.Visible = false
end

ScoreResultDisplay = true

if ReplayMode == false then
	ReplayRecordEnabled = false

	local Data = HttpService:JSONEncode(ReplayData)

	script.Parent.Replay.Value = Data
end

spawn(function()
	TweenService:Create(script.Parent.Song,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true),{Volume = 0.5}):Play()
end)
--TweenService:Create(script.Parent.Interface.BG,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true),{BackgroundTransparency = 0}):Play()
wait(0.25)
script.Parent.Interface.Background.ReturnButton.Visible = false
script.Parent.Interface.Background.Visible = false



CursorUnlocked = true
UserInputService.MouseBehavior = Enum.MouseBehavior.Default
Cursor.Visible = false
RblxNewCursor.Visible = true


local ResultFrame = PlayerGui.BG.ResultFrame.MainFrame.DisplayFrame
ResultFrame.Visible = true
ResultFrame.Parent.Parent.Parent.ResultScreenOptions.Visible = true
TweenService:Create(ResultFrame.Parent.Parent.Parent.ResultScreenOptions,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Position = UDim2.new(0.5,0,0.5,0)}):Play()
TweenService:Create(ResultFrame.Parent.Parent,TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{GroupTransparency = 0}):Play()
TweenService:Create(ResultFrame.Parent.Parent,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{Size = UDim2.new(1,-86,1,-86)}):Play()
TweenService:Create(ResultFrame.Parent.Parent.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Transparency = 0.4}):Play()


ProcessFunction(function()
	wait(1.1)
	local NewResultFrame = PlayerGui.BG.ResultFrame_EndRender
	local OldResultFrame = PlayerGui.BG.ResultFrame

	for _,obj in pairs(OldResultFrame:GetChildren()) do
		obj.Parent = NewResultFrame
	end

	NewResultFrame.Visible = true
	OldResultFrame:Destroy()
end)

ResultFrame.hit300s.Text = AccuracyData.h300.."x"
ResultFrame.hit100s.Text = AccuracyData.h100.."x"
ResultFrame.hit50s.Text = AccuracyData.h50.."x"
ResultFrame.hit0s.Text = AccuracyData.miss.."x"
if AccuracyData.miss > 0 then
	ResultFrame.hit0s.TextColor3 = Color3.fromRGB(255, 107, 107)
end
local TotalNoteResult = AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss
local RawAccurancy = ((AccuracyData.h300*300+AccuracyData.h100*100+AccuracyData.h50*50)/(TotalNoteResult*300))*100
local GameAccurancy = math.floor((RawAccurancy)*100)/100
local tostringAcc = string.format("%s%s",string.format("%.2d",GameAccurancy),string.sub(string.format("%.2f",GameAccurancy%1),2,4))
ResultFrame.Accuracy.Text = AccuracyData.MaxCombo.."x | "..tostringAcc.."%"

local GameplayRank = "D"
local percent300s = AccuracyData.h300/(AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss)
local percent50s = AccuracyData.h50/(AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss)
local misstotal = AccuracyData.miss

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

ResultFrame.Parent.Parent.ResultFrameAnim.Disabled = false

ProcessFunction(function()
	local AccuracyValue = 0

	if percent300s < 0.6 then
		AccuracyValue = math.min(percent300s/0.6*0.4,0.39)
	elseif misstotal > 0 and percent300s >= 0.7 then
		AccuracyValue = math.min(0.4 + (percent300s-0.6)/0.4*0.6 - 0.15,0.84)
	elseif percent300s >= 0.9 and percent50s >= 0.01 then
		AccuracyValue = 0.84
	else
		AccuracyValue = 0.4 + (percent300s-0.6)/0.4*0.6
	end

	wait(0.5)
	local AccuracyLine = ResultFrame.AccuracyLine.DisplayLine

	for _,obj in pairs(AccuracyLine:GetChildren()) do
		TweenService:Create(obj.FullLine.Progress,TweenInfo.new(1.75,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Size = UDim2.new(AccuracyValue,0,1,0)}):Play()
	end


end)

-- We clean up the gameplay, only display the result

script.Parent.MobileHit.Visible = false
script.Parent.ComboDisplay.Visible = false
script.Parent.ScoreDisplay.Visible = false
script.Parent.HitError.Visible = false
script.Parent.AccurancyDisplay.Visible = false
script.Parent.ComboFrameDisplay.Visible = false
script.Parent.ScoreFrameDisplay.Visible = false
script.Parent.AccurancyFrameDisplay.Visible = false
script.Parent.UnrankedSign.Visible = false
script.Parent.HitKey.Visible = false
script.Parent.PSEarned.Visible = false
script.Parent.HealthBar.Visible = false
script.Parent.Leaderboard.Visible = false
script.Parent.RestartGame.Visible = false
script.Parent.LiveDiffDisplay.Visible = false
script.Parent.ProgressBar.Visible = false

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,true)

----------- Calculate perfomance score -----------

local TotalRewardedPS = AddPerfomanceScore()

----------- Submit play result ---------------
local function GetNewNum(CurrentNum)
	local isNeg = false
	CurrentNum = tonumber(CurrentNum)

	if CurrentNum < 0 then
		CurrentNum = math.abs(CurrentNum)
		isNeg = true
	end
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

	if isNeg then
		NewNum = "-"..NewNum
	end
	return NewNum
end


MetaData = ReturnData.Overview.Metadata
OnlineResult = ResultFrame.Parent.OnlineDisplayFrame
local AccuracyScore = getAccuracyScore()
local ConsistencyScore = getConsistencyScore()

local Score = getScoreV1() -- overwrite the current score

if ScoreV2Enabled then
	--local ScoreV2AccScore = math.pow((AccuracyData.h300*300+AccuracyData.h100*300+AccuracyData.h50*300+AccuracyData.miss*300)/300,2.265) * ScoreMultiplier.Difficulty * ScoreMultiplier.Mod * 0.3
	--local ScoreV2 = math.pow(Score/(TotalScoreEstimated*0.8 + ScoreV2AccScore)*(NoteCompleted/NoteTotal),0.768621)*(NoteCompleted/NoteTotal)*1000000
	local ScoreV2 = getScoreV2()
	ResultFrame.Score.Text = "Score: <b>"..GetNewNum(string.format("%.0f",ScoreV2)).." ["..GetNewNum(tostring(math.floor(Score))).."]</b>"
else
	ResultFrame.Score.Text = "Score: <b>"..GetNewNum(tostring(math.floor(Score))).."</b>"	
end
--ResultFrame.Grade.Text = (not SS and GameplayRank) or "S"
--ResultFrame.Grade.TextColor3 = RankColor[GameplayRank]
ProcessFunction(function()
	local GradeFrame = ResultFrame.GradeHugeDisplay
	local RankingDisplayID = script.GradeDisplay["Rank_"..GameplayRank].Image

	GradeFrame.BaseDisplay.Image = RankingDisplayID
	GradeFrame.EffectDisplay.Image = RankingDisplayID

	wait(1.75)
	TweenService:Create(GradeFrame.BaseDisplay,TweenInfo.new(0.75,Enum.EasingStyle.Exponential,Enum.EasingDirection.In),{Size = UDim2.new(1,0,1,0),ImageTransparency = 0}):Play()
	wait(0.75)
	GradeFrame.EffectDisplay.Visible = true
	TweenService:Create(GradeFrame.EffectDisplay,TweenInfo.new(2,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Size = UDim2.new(1.5,0,1.5,0)}):Play()
	TweenService:Create(GradeFrame.EffectDisplay,TweenInfo.new(2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()
end)
SubmitTime = os.date("*t", ReplayMode and FinaleReplayData.Date or nil)

local DisplayUser = AutoPlay and "osu!AT" or (ReplayMode and FinaleReplayData.User) or LocalPlayer.Name
DisplaySubmitTime = string.format("Played by %s on %.2d/%.2d/%.4d %.2d:%.2d:%.2d", DisplayUser, SubmitTime.day, SubmitTime.month, SubmitTime.year, SubmitTime.hour, SubmitTime.min, SubmitTime.sec)
DisplayModPlayed = (function()
	local ModDisplay = " | "
	local mods = {}

	-- Check which mods are active and add them to the mods table
	if AutoPlay then table.insert(mods, "AT") end
	if ScoreV2Enabled then table.insert(mods, ",V2") end
	if TouchDeviceDetected then table.insert(mods, ",TD") end
	if NoFail then table.insert(mods, ",NF") end
	if HiddenMod then table.insert(mods, ",HD") end
	if HardRock then table.insert(mods, ",HR") end
	if EasyMod then table.insert(mods, ",EZ") end
	if SliderMode then table.insert(mods, ",SL") end
	if Flashlight then table.insert(mods, ",FL") end
	if ClassicNotelock then table.insert(mods, ",CL") end

	-- Check for SongSpeed and format if necessary
	if SongSpeed ~= 1 then
		table.insert(mods, string.format(",SA(%sx)", tostring(math.round(SongSpeed * 100) / 100)))
	end
	-- Only concatenate if mods exist
	if #mods > 0 then
		local display = table.concat(mods)
		if string.sub(display,1,1) == "," then
			display = string.sub(display,2,#display)
		end
		ModDisplay = ModDisplay .. display
		
		return ModDisplay
	else
		return ""
	end
end)()


CombineDisplay = DisplaySubmitTime..DisplayModPlayed
ResultFrame.Parent.Parent.DetailedDate.Text = CombineDisplay
ResultFrame.Parent.Parent.DetailedInfo.Text = "Beatmap: "..MetaData.SongCreator.." - "..MetaData.MapName.." | ["..MetaData.DifficultyName.."] // "..MetaData.BeatmapCreator--.." | "..tostring(SongSpeed).."x"
--ResultFrame.Display_SS.Visible = SS and not (HiddenMod or Flashlight)
--ResultFrame.Display_SSH.Visible = SS and (HiddenMod or Flashlight)

if (GameplayRank == "S" or SS) and (HiddenMod or Flashlight) then
	ResultFrame.Grade.TextColor3 = Color3.fromRGB(177,177,177)
end

OnlineResult.OnlineScore.Score.Text = GetNewNum(math.floor(Score))
OnlineResult.OnlineAccuracy.Accuracy.Text = tostringAcc.."%"
OnlineResult.OnlineMaxCombo.MaxCombo.Text = GetNewNum(AccuracyData.MaxCombo).."x"
OnlineResult.OnlinePS.PerfomanceScore.Text = GetNewNum(math.floor(TotalRewardedPS)).."ps"
OnlineResult.OverallPerfomance.TotalPS.Text = LocalPlayer.leaderstats.Perfomance.Value

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
	end
end
HighestHitErrorClick = 1
OffsetFrame = PlayerGui.BG.ResultFrame.MainFrame.OffsetFrame

for _,a in pairs(AccuracyData.HitErrorGraph) do
	if a[3] > HighestHitErrorClick then
		HighestHitErrorClick = a[3]
	end
end

for _,a in pairs(AccuracyData.HitErrorGraph) do
	local Frame = script.OffsetFrame:Clone()
	Frame.Parent = OffsetFrame.MainFrame.MainFrame
	local ExtraVerticalSize = math.round(1/99*workspace.Camera.ViewportSize.X*0.728625)-2
	Frame.Size = UDim2.new(1/99,-2,a[3]/HighestHitErrorClick,ExtraVerticalSize)

	if a[3] <= 0 then
		Frame.BackgroundColor3 = Color3.new(0.333333, 0.333333, 0.333333)
	end
	Frame.LayoutOrder = a[4]
end

UnstableRate = math.round((TotalUnstableTime/(TotalHit-1))*10)
OffsetPositive = math.round(AccuracyData.OffsetPositive.Value/AccuracyData.OffsetPositive.Total)
OffsetNegative = math.round(AccuracyData.OffsetNegative.Value/AccuracyData.OffsetNegative.Total)
OffsetOverall = math.round(AccuracyData.OffsetOverall.Value/AccuracyData.OffsetOverall.Total)

OffsetFrame.MainFrame.UnstableRateArea.UnstableRateArea.Size = UDim2.new(UnstableRate/2200,0,0,0)
OffsetFrame.MainFrame.UnstableRateArea.UnstableRateArea.Position = UDim2.new(0.5+OffsetOverall/2200,0,0,0)

OffsetFrame.MainFrame.DetailedDisplay.Text = "Unstable rate: "..tostring(UnstableRate).." | Error: "..tostring(OffsetNegative).."ms - "..tostring(OffsetPositive).."ms Avg | Overall Offset: "..tostring(OffsetOverall).."ms"

-----

if isSpectating == true then
	OnlineResult.OnlinePS.PerfomanceScore.Text = "-"
end

ResultFrame.Parent.Parent.Visible = true

if AutoPlay == true and ReplayMode ~= true then
	--TweenService:Create(Cursor,TweenInfo.new(1,Enum.EasingStyle.Sine),{Position = UDim2.new(0.5,0,1.5,0)}):Play()
end

local CanbeSubmitted = true

if NoFail and Score < 1000 then
	CanbeSubmitted = false
end

if not ReplayMode and not isSpectating and not onTutorial --[[and not RunService:IsStudio()]] then
	local function get(format)
		local BooleanFormat = {["true"] = "1", ["false"] = "0"}

		return BooleanFormat[tostring(format)]
	end
	local ReplayVersion = "VERSION 2\n"
	local PlayerName = "USER "..((not AutoPlay and LocalPlayer.Name) or "osu!AT").."\n"
	local DateFormat = "DATE "..tostring(os.time()).."\n"
	-- MOD StableNL EnableTouchDevice AT NF HD HR EZ SL FL
	local ModFormat = "MOD "..get(ClassicNotelock)..get(EnableTouchDevice and UserInputService.TouchEnabled)
		..get(AutoPlay)..get(NoFail)..get(HiddenMod)..get(HardRock)..get(EasyMod)..get(SliderMode)..get(Flashlight).."\n"
	local SpeedFormat = "SPEED "..tostring(SongSpeed).."\n"
	local FilenameForamt = "FILENAME "..Beatmap.Name.."\n"
	local ScoreFormat = "SCORE "..tostring(math.round(Score)).."\n"
	local MaxcomboFormat = "MAXCOMBO "..tostring(math.round(AccuracyData.MaxCombo)).."\n"
	local PSFormat = "PS "..tostring(math.round(CurrentPerfomance)).."\n"
	local AccuracyFormat = "ACCURACY "..tostring(AccuracyData.h300).." "..tostring(AccuracyData.h100).." "..tostring(AccuracyData.h50).." "..tostring(AccuracyData.miss).."\n"

	ReplayDataEncoded = "\nOVERALL\n"..ReplayVersion..PlayerName..DateFormat..ModFormat..SpeedFormat..FilenameForamt..ScoreFormat..MaxcomboFormat..PSFormat..AccuracyFormat.."REPLAY\n"..ReplayDataEncoded

	game.ReplicatedStorage.ClientCommunication.UpdateLocalReplayData:Invoke(ReplayDataEncoded)
end

if not ReplayMode and not isSpectating and not onTutorial then
	local Trigger = PlayerGui.BG.ResultFrame_EndRender:WaitForChild("MainFrame").OnlineDisplayFrame.WatchReplay.TriggerButton

	Trigger.MouseButton1Click:Connect(function()
		script.Parent.RestartGame.ReplayReturn:Fire()
	end)
else
	PlayerGui.BG.ResultFrame_EndRender:WaitForChild("MainFrame").OnlineDisplayFrame.WatchReplay.Visible = false
end

CanUploadReplay = #ReplayDataEncoded <= 4294967296

if not CanUploadReplay then
	PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("Your replay is too big to upload, your replay size was "..string.format("%.2f/4096.00kB",#ReplayDataEncoded/(1024^2)),Color3.new(1,0,0))
end

if PlayRanked == true and CanbeSubmitted then
	local RankedScore = math.round(Score)
	OnlineResult.SubmitStatus.Text = "Submitting score"
	--ResultFrame.Score.Text = "[Submitting...]"
	local ReturnResult = game.ReplicatedStorage.BeatmapLeaderboard:InvokeServer(2,{DatastoreName = CurrentKey,BeatmapKey = tostring(BeatmapKey),PlayData = {
		Score = RankedScore,
		ReplayData = (CanUploadReplay and ReplayDataEncoded) or "",
		ExtraData = {
			HaveReplay = CanUploadReplay,
			Accurancy = tostringAcc,
			MaxCombo = AccuracyData.MaxCombo,
			Grade = GameplayRank,
			Date = os.time(),
			ExtraAccurancy = {AccuracyData.h300,AccuracyData.h100,AccuracyData.h50,AccuracyData.miss},
			Speed = SongSpeed,
			PS = TotalRewardedPS,
			Mod = {
				FL = Flashlight,
				SL = SliderMode,
				NF = NoFail,
				HD = HiddenMod,
				HR = HardRock,
				EZ = EasyMod,
				AT = AutoPlay,
				TD = TouchDeviceDetected
			}
		},
		BadgeCondition = BadgeCondition,
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
		TweenService:Create(OnlineResult.OnlineAccuracy,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,200)}):Play()
		TweenService:Create(OnlineResult.OnlineMaxCombo,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,200)}):Play()
		TweenService:Create(OnlineResult.OnlinePS,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,200)}):Play()
		TweenService:Create(OnlineResult.OnlineScore.Improvement,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextColor3 = Color3.fromRGB(255,255,255)}):Play()
		TweenService:Create(OnlineResult.OnlineAccuracy.Improvement,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextColor3 = Color3.fromRGB(255,255,255)}):Play()
		TweenService:Create(OnlineResult.OnlineMaxCombo.Improvement,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextColor3 = Color3.fromRGB(255,255,255)}):Play()
		TweenService:Create(OnlineResult.OnlinePS.Improvement,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextColor3 = Color3.fromRGB(255,255,255)}):Play()
		OnlineResult.OnlineScore.Improvement.Text = "new!"
		OnlineResult.OnlineAccuracy.Improvement.Text = "new!"
		OnlineResult.OnlineMaxCombo.Improvement.Text = "new!"
		OnlineResult.OnlinePS.Improvement.Text = "new!"
	else
		local OldPS = ReturnResult.ExtraData.PS

		if OldPS == nil	then
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
			TweenService:Create(OnlineResult.OnlineAccuracy,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,0)}):Play()
			TweenService:Create(OnlineResult.OnlineAccuracy.Improvement,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			OnlineResult.OnlineAccuracy.Improvement.Text = string.format("Best: %.2f%%",tonumber(tostringAcc - Acc) or 0)
		else
			OnlineResult.OnlineAccuracy.Improvement.Text = string.format("Best: %.2f%%",tonumber(Acc) or 0)
		end

		local PBMaxCombo = ReturnResult.ExtraData.MaxCombo

		if AccuracyData.MaxCombo > PBMaxCombo then
			TweenService:Create(OnlineResult.OnlineMaxCombo,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.fromRGB(0,200,0)}):Play()
			TweenService:Create(OnlineResult.OnlineMaxCombo.Improvement,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			OnlineResult.OnlineMaxCombo.Improvement.Text = "+"..GetNewNum(AccuracyData.MaxCombo-PBMaxCombo)
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
			local Improvement = math.abs(math.floor(ReturnResult.PSImprovement))
			StringImprovement = "-"..GetNewNum(Improvement)
			if Improvement == 0 then
				StringImprovement = "-0"
			end
		end

		OnlineResult.OverallPerfomance.Improvement.Text = StringImprovement.."ps"
	else
		OnlineResult.OverallPerfomance.TotalPS.Text = LocalPlayer.leaderstats.Perfomance.Value
		OnlineResult.OverallPerfomance.Improvement.Text = "-"
	end

	OnlineResult.SubmitStatus.Text = ""
	--ResultFrame.Score.Text = "Score: "..tostring(RankedScore)..ExtraText
else
	if isSpectating == true or ReplayMode then
		OnlineResult.SubmitStatus.Text = ""
	elseif AutoPlay then
		OnlineResult.SubmitStatus.Text = ""
	elseif not CanbeSubmitted then
		OnlineResult.SubmitStatus.Text = "Result send failed: Get a better score!"
	else
		OnlineResult.SubmitStatus.Text = "Result send failed: Result is unranked!"
	end
end



--[[
	Data = {Name,Rank,Score,ExtraData = {Speed,Accurancy,MaxCombo,Grade,Date,ExtraAccurancy = {300s,100s,50s,miss}}}
	]]


--------------------------------------------------


-- Script note: Some value name may spell incorrectly (And it may take ages to change bk .-.)





-->   2021 - 2024 osu!RoVer   <--
-- osu!corescript by VtntGaming
-- String size: 311.909KB (V1.47)

-- Source code used as a backup script, if you're not VtntGaming and see this please use it right :>
-- Some mathmethic is inspired/taken from osu! and osu!Lazer github source
----------------- End script -----------------

--[LOCATION]:[StarterGui.PlayScreen.OsuGame]
-- Services instance load
TweenService = game:GetService("TweenService")
UserInputService = game:GetService("UserInputService")
RunService = game:GetService("RunService")
HttpService = game:GetService("HttpService")
local workspace = game:GetService("Workspace")
StarterGui = game:GetService("StarterGui")
ScriptComponent = script.Parent.GameplayScripts.Components
ObjectTools = require(ScriptComponent.Gameplay.CircleObject)
LocalPlayer = game.Players.LocalPlayer
PlayerGui = LocalPlayer.PlayerGui
ObjectManagement_Actor = game.Players.LocalPlayer.PlayerScripts.ObjectManagement_Actor
ExternalFunction_Actor = game.Players.LocalPlayer.PlayerScripts.ExternalFunction_Actor
ParallelProcessingFolder = game.Players.LocalPlayer.PlayerScripts.ParallelProcessing
local tick = os.clock
local PerformanceCalculator = require(workspace.PerformanceCalculator)
SliderComponent = require(ScriptComponent.Gameplay.SliderComponent)
local modData = require(workspace.ModData)
StreamingLoop = require(ScriptComponent.Perfomance.StreamingCode).create()
SliderObjManage = require(ScriptComponent.Perfomance.SliderObjManage).init()
local ScoreStaticticConverter = require(ScriptComponent.Gameplay.ScoreStatisticConverter)
local PauseScreenUtils = require(ScriptComponent.Gameplay.PauseScreen)
local TimeUtils = require(ScriptComponent.Gameplay.GameplayTimeUtils)

local UtilsModule = ScriptComponent.Gameplay.Utils
local ScoreFormat = require(UtilsModule.ScoreFormat)
local ReplayParser = require(UtilsModule.ReplayParser)

-- basic function

if script.Parent.StartupState.Value == "Waiting" then
	repeat task.wait() until script.Parent.StartupState.Value ~= "Waiting"
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

local MouseHitRegisterEvent = Instance.new("BindableEvent") -- it will gained an unquie id to make sure it only accept 1 circle input
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
	task.wait(1)
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

print("Waiting for BG")
PlayerGui:WaitForChild("BG"):WaitForChild("StartButton")

print("Waiting for settings")
if PlayerGui.SavedSettings:FindFirstChild("SettingsFrame") then
	PlayerGui.BG.SettingsFrame:Destroy()
	PlayerGui.SavedSettings.SettingsFrame:Clone().Parent = PlayerGui.BG
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

print("Everything loaded")
Instance.new("IntValue",CurrentSetting.Parent).Name = "SettingsLoaded"

PlayerGui.LoadUI.Scripts.EndloadScript.Disabled = false

-- Those settings can be change multiply times before the game start
local coreConfig = {
	FileType = 1,
	AutoPlay = false,
	IngamebeatmapID = CurrentSetting.VirtualSettings.IngameBeatmapID,
	PrevBeatmapID = CurrentSetting.VirtualSettings.PrevBeatmapID,
	CursorTrailEnabled = true,
	EnableTouchDevice = true, -- Touch screen enabled only
	SpeedSync = true,
	UIPreviewFrame = PlayerGui.BG.PreviewFrame,
	CurrentPreviewFrame = PlayerGui.BG.PreviewFrame.PreviewFrame,
	PreviewMapPS = {
		Aim = 0,
		Speed = 0,
		Mod = 0,
		AimFL = 0,
		Acc = 0,
		objCount = 0,
		MaxCombo = 0,
		MaxAccScore = 0,
		MaxConsistencyScore = 0,
		MaxSpinnerScore = 0,
	},
	MouseButtonEnabled = true,
	SliderMode = true, -- This option will be remove and slider will be in real game soon
	OldCursorMovement = false,
	NewCircelOverlay = false,
	OldInterface = false,
	Flashlight = false,
	PSDisplay = false,
	DetailedPSDisplay = false,
	HitErrorEnabled = true,
	OverallInterfaceEnabled = true,
	FreePlay = false,
	DefaultBackgroundTrans = 0.2,
	MobileModeRightHitZone = false,
	DisableChatInGame = false,
	KeepOriginalPitch = false,
	BackgroundBlurEnabled = false,
	showHealthBar = true,
	NoFail = false,
	HiddenMod = false,
	EasyMod = false,
	InGameLeaderboard = true,
	HitZoneEnabled = true,
	HardRock = false,
	CustomComboColorEnabled = false,
	OnMultiplayer = false,
	MultiplayerMatchFailed = false,
	OptimizedPerfomance = false,
	MPScoreV2Enabled = false,
	ScoreV2Enabled = GameSettingManage.getSettings:Invoke("ScoreV2"),
	ReplayMode = false,
	ExclusiveEffects = false,
	Hit300Display = false,
	TouchDeviceDetected = false,
	HitKeyOverlay = true,
	InstaFadeCircle = false,
	LiveDifficultyDisplay = false,
	Replay_TouchDevice = false,
	AimAssist = false,
	CursorRipplesEnabled = false,
	StoryboardEnabled = true,
	StoryboardAvailable = false,
}

local AdjustIngameSongVolume
local AdjustIngameEffectVolume
local KeyHistoryOverlayEnabled = false
local AccuracyData
local DisplayingHitnote
local CircleSize
type Mod_DA = {
	Active:boolean?,
	Data:{
		CS:number?,
		AR:number?,
		OD:number?,
		HP:number?
	}?
}

DifficultyAdjust = {Active = false, Data = {}}::Mod_DA

-- PreviewFrameScriptSettings
PreviewFrameBaseVolume = 0.2

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
if coreConfig.IngamebeatmapID.Value == 0 then
	coreConfig.IngamebeatmapID.Value = math.random(1,#BeatmapsList:GetChildren())
	if PlayerGui.SavedSettings:FindFirstChild("SettingsFrame") then
		PlayerGui.SavedSettings.SettingsFrame.VirtualSettings.IngameBeatmapID.Value = coreConfig.IngamebeatmapID.Value
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

if coreConfig.CursorRipplesEnabled then
	MouseHitEvent.Event:Connect(function()
		script.Parent.CursorField.CursorRipples.RippleBind:Fire()
	end)
end

if CurrentSetting.MainSettings.AutoPlay.Text == "[AT] Auto play: Enabled" then
	coreConfig.AutoPlay = true
end

if CurrentSetting.MainSettings.Flashlight.Text == "[FL] Flashlight: Enabled" then
	coreConfig.Flashlight = true
end

if CurrentSetting.MainSettings.SliderMode.Text == "[NS] No sliders: Enabled" then
	coreConfig.SliderMode = false
end

if CurrentSetting.MainSettings.NoFail.Text == "[NF] No Fail: Enabled" then
	TweenService:Create(CurrentSetting.MainSettings.HP,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{PlaceholderColor3 = Color3.new(0.698039, 0.423529, 0.423529)}):Play()
	coreConfig.NoFail = true
end

if CurrentSetting.MainSettings.Hidden.Text == "[HD] Hidden: Enabled" then
	coreConfig.HiddenMod = true
end

if CurrentSetting.MainSettings.HardRock.Text == "[HR] Hard Rock: Enabled" then
	coreConfig.HardRock = true
end

if CurrentSetting.MainSettings.Easy.Text == "[EZ] Easy: Enabled" then
	coreConfig.EasyMod = true
end

CurrentModData = {
	HD = coreConfig.HiddenMod,
	FL = coreConfig.Flashlight,
	NF = coreConfig.NoFail,
	HR = coreConfig.HardRock,
	EZ = coreConfig.EasyMod,
	DA = DifficultyAdjust.Active,
	Speed = tonumber(CurrentSetting.MainSettings.Speed.Text) or 1
}

function IsTouchDeviceActive():boolean
	return not coreConfig.AutoPlay and coreConfig.EnableTouchDevice and UserInputService.TouchEnabled
end

-- blank function to prevent warnings and errors
function ReloadPreviewFrame(isInit: boolean?) end
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

	CurrentSetting.MainSettings.ScoreMultiplier.Raw.Value = Multiplier
	CurrentSetting.MainSettings.ScoreMultiplier.Rankable.Value = isRankable
end

LoadMultiplier()

function checkDifficultyAdjustState()
	local AR = CurrentSetting.MainSettings.AR
	local OD = CurrentSetting.MainSettings.OD
	local CS = CurrentSetting.MainSettings.CS
	local HP = CurrentSetting.MainSettings.HP

	local function checkVaild(data, isAR)
		local max = 11
		local min = isAR and -10 or 0
		if tonumber(data) and tonumber(data) >= min and tonumber(data) <= max then
			return true
		else
			return false
		end
	end

	if checkVaild(AR.Text, true) or checkVaild(CS.Text) or checkVaild(OD.Text) or checkVaild(HP.Text) then
		CurrentSetting.MainSettings.DifficultyAdjust.Text = "[DA] Difficulty adjust: Enabled"
		DifficultyAdjust.Active = true
		DifficultyAdjust.Data.AR = checkVaild(AR.Text, true) and tonumber(AR.Text) or nil
		DifficultyAdjust.Data.OD = checkVaild(OD.Text) and tonumber(OD.Text) or nil
		DifficultyAdjust.Data.CS = checkVaild(CS.Text) and tonumber(CS.Text) or nil
		DifficultyAdjust.Data.HP = checkVaild(HP.Text) and tonumber(HP.Text) or nil
	else
		DifficultyAdjust.Active = false
		DifficultyAdjust.Data.AR = nil
		DifficultyAdjust.Data.OD = nil
		DifficultyAdjust.Data.CS = nil
		DifficultyAdjust.Data.HP = nil
		CurrentSetting.MainSettings.DifficultyAdjust.Text = "[DA] Difficulty adjust: Disabled"
	end

	CurrentModData.DA = DifficultyAdjust.Active
	LoadMultiplier()
	ReloadPreviewFrame()
end

function getDifficultyNameByValue(diff:number):string
	local format = "Difficulty - "
	if diff < 2 then
		format..= "Easy [0-2]"
	elseif diff < 3 then
		format..= "Normal [2-3]"
	elseif diff < 4 then
		format..= "Hard [3-4]"
	elseif diff < 5.5 then
		format..= "Insane [4-5.5]"
	elseif diff < 6.5 then
		format..= "Expert [5.5-6.5]"
	elseif diff < 8.5 then
		format..= "Expert+ [6.5-8.5]"
	elseif diff < 10 then
		format..= "Master [8.5-10]"
	elseif diff < 25 then		
		format..= "Master+ [10+]"
	else
		format..= "Aspire? [25+]"
	end
	return format
end

function getMapLengthNameByTime(t:number):string
	local format = "Length - "
	if t < 60 then
		format..= "Short [<1:00]"
	elseif t < 180 then
		format..= "Medium [1:00-2:59]"
	elseif t < 300 then
		format..= "Long [3:00-4:59]"
	else
		format..= "Marathon [>5:00]"
	end
	return format
end

function getMapTypeByDiff(aim:number, speed:number, t:number):string
	local format = "Map type - "
	if aim ~= aim or speed ~= speed or math.abs(aim) > 999 or math.abs(speed) > 999 then
		format..= "Unknown maps"
	elseif t >= 300 and (aim/speed >= 0.75 and aim/speed <= 1.33) and speed >= 2.5 and aim >= 2.5 then
		format..= "[Tiebreaker] maps [0.75<r<1.33|t>5:00]"
	elseif speed >= 2 or aim >= 2 then
		if speed >= 0.9 * aim and speed <= 1.11 * aim then
			format..= "Aim/Speed mixed maps [0.9<ratio<1.11]"
		elseif speed > 1.11 * aim then
			format..= "Speed maps [speed>111% aim]"
		else
			format..= "Aim maps [aim>111% speed]"
		end
	else
		format..= "Easy maps [aim<2 & speed<2]"
	end
	return format
end

checkDifficultyAdjustState()

-- Settings change detect

CurrentSetting.MainSettings.AR.FocusLost:Connect(checkDifficultyAdjustState)
CurrentSetting.MainSettings.CS.FocusLost:Connect(checkDifficultyAdjustState)
CurrentSetting.MainSettings.OD.FocusLost:Connect(checkDifficultyAdjustState)
CurrentSetting.MainSettings.HP.FocusLost:Connect(checkDifficultyAdjustState)

CurrentSetting.MainSettings.Flashlight.MouseButton1Click:Connect(function()
	coreConfig.Flashlight = not coreConfig.Flashlight
	CurrentModData.FL = coreConfig.Flashlight
	if coreConfig.Flashlight == true then
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
	coreConfig.AutoPlay = not coreConfig.AutoPlay
	if coreConfig.AutoPlay == true --[[and ReplayMode ~= true]] then
		CurrentSetting.MainSettings.AutoPlay.Text = "[AT] Auto play: Enabled"
	else
		CurrentSetting.MainSettings.AutoPlay.Text = "[AT] Auto play: Disabled"
	end

	ReloadPreviewFrame()
end)

CurrentSetting.MainSettings.SliderMode.MouseButton1Click:Connect(function()
	coreConfig.SliderMode = not coreConfig.SliderMode
	if coreConfig.SliderMode == false then
		CurrentSetting.MainSettings.SliderMode.Text = "[NS] No sliders: Enabled"
	else
		CurrentSetting.MainSettings.SliderMode.Text = "[NS] No sliders: Disabled"
	end

	LoadMultiplier()
	ReloadPreviewFrame()
end)

CurrentSetting.MainSettings.NoFail.MouseButton1Click:Connect(function()
	coreConfig.NoFail = not coreConfig.NoFail
	CurrentModData.NF = coreConfig.NoFail
	LoadMultiplier()
	if coreConfig.NoFail == true then
		TweenService:Create(CurrentSetting.MainSettings.HP,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{PlaceholderColor3 = Color3.new(0.698039, 0.698039, 0.423529)}):Play()
		CurrentSetting.MainSettings.NoFail.Text = "[NF] No Fail: Enabled"
	else
		TweenService:Create(CurrentSetting.MainSettings.HP,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{PlaceholderColor3 = Color3.new(0.698039, 0.423529, 0.423529)}):Play()
		CurrentSetting.MainSettings.NoFail.Text = "[NF] No Fail: Disabled"
	end
	ReloadPreviewFrame()
end)

CurrentSetting.MainSettings.Hidden.MouseButton1Click:Connect(function()
	coreConfig.HiddenMod = not coreConfig.HiddenMod
	CurrentModData.HD = coreConfig.HiddenMod

	LoadMultiplier()
	if coreConfig.HiddenMod == true then
		CurrentSetting.MainSettings.Hidden.Text = "[HD] Hidden: Enabled"
	else
		CurrentSetting.MainSettings.Hidden.Text = "[HD] Hidden: Disabled"
	end

	ReloadPreviewFrame()
end)

GameSettingManage.SubscribeSettingChange:Fire("MusicVolume", script, function(value)
	TweenService:Create(coreConfig.CurrentPreviewFrame.OverviewSong,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{Volume = PreviewFrameBaseVolume*(value*0.01)}):Play()
	TweenService:Create(coreConfig.CurrentPreviewFrame.OverviewSong,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{Volume = PreviewFrameBaseVolume*(value*0.01)}):Play()
end)

CurrentSetting.MainSettings.HardRock.MouseButton1Click:Connect(function()
	coreConfig.HardRock = not coreConfig.HardRock
	CurrentModData.HR = coreConfig.HardRock
	if coreConfig.HardRock == true then
		CurrentSetting.MainSettings.HardRock.Text = "[HR] Hard Rock: Enabled"
		CurrentSetting.MainSettings.Easy.Text = "[EZ] Easy: Disabled"
		coreConfig.EasyMod = false
		CurrentModData.EZ = false
	else
		CurrentSetting.MainSettings.HardRock.Text = "[HR] Hard Rock: Disabled"
	end

	LoadMultiplier()
	ReloadPreviewFrame()
end)

CurrentSetting.MainSettings.Easy.MouseButton1Click:Connect(function()
	coreConfig.EasyMod = not coreConfig.EasyMod
	CurrentModData.EZ = coreConfig.EasyMod
	if coreConfig.EasyMod == true then
		CurrentSetting.MainSettings.Easy.Text = "[EZ] Easy: Enabled"
		CurrentSetting.MainSettings.HardRock.Text = "[HR] Hard Rock: Disabled"
		coreConfig.HardRock = false
		CurrentModData.HR = false
	else
		CurrentSetting.MainSettings.Easy.Text = "[EZ] Easy: Disabled"
	end

	LoadMultiplier()
	ReloadPreviewFrame()
end)

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

function GetModData(Mod:modData.ModData,Detailed)
	local ReturnText = ""
	local Mods = 0

	if Mod == nil then
		return ""
	end

	if Mod.AT == true then
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

	if Mod.SA and Mod.SA ~= 1 then
		if Mods > 0 then
			ReturnText = ReturnText..","
		end
		Mods += 1
		local _format = string.format("SA(%.1fx)", Mod.SA)
		local _formatDetailed = string.format("SpeedAdjust(%.1fx)", Mod.SA)

		if Mod.SA == 1.5 then
			_format = "DT"
			_formatDetailed = "DoubleTime"
		elseif Mod.SA == 0.75 then
			_format = "HT"	
			_formatDetailed = "HalfTime"	
		end

		if Detailed then
			ReturnText = ReturnText.._formatDetailed
		else
			ReturnText = ReturnText.._format
		end
	end

	if Mod.NS == true then
		if Mods > 0 then
			ReturnText = ReturnText..","
		end
		Mods += 1
		if Detailed then
			ReturnText = ReturnText.."NoSliders"
		else
			ReturnText = ReturnText.."NS"
		end
	end

	if Mod.FL == true then
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

	if Mod.DA and Mod.DA.Active then
		if Mods > 0 then
			ReturnText = ReturnText..","
		end
		Mods += 1
		local _format = "DA("
		local _longFormat = "DifficultyAdjust("
		local function _add(txt, num, addComma)
			local strNum = tostring(math.floor(num*10)/10)
			_format..= txt..strNum..(addComma and "," or ")")
			_longFormat..= txt..strNum..(addComma and "," or ")")
		end
		local _data = Mod.DA.Data
		if _data.CS then
			_add("CS", _data.CS, true)
		end
		if _data.AR then
			_add("AR", _data.AR, true)
		end
		if _data.OD then
			_add("OD", _data.OD, true)
		end
		if _data.HP then
			_add("HP", _data.HP, false)
		end
		if Detailed then
			ReturnText = ReturnText.._longFormat
		else
			ReturnText = ReturnText.._format
		end
	end

	if Mod.RX then
		if Mods > 0 then
			ReturnText = ReturnText..","
		end
		Mods += 1
		if Detailed then
			ReturnText = ReturnText.."Relax"
		else
			ReturnText = ReturnText.."RX"
		end
	end

	if Mod.SO then
		if Mods > 0 then
			ReturnText = ReturnText..","
		end
		Mods += 1
		if Detailed then
			ReturnText = ReturnText.."SpunOut"
		else
			ReturnText = ReturnText.."SO"
		end
	end

	if Mod.AP then
		if Mods > 0 then
			ReturnText = ReturnText..","
		end
		Mods += 1
		if Detailed then
			ReturnText = ReturnText.."AutoPilot"
		else
			ReturnText = ReturnText.."AP"
		end
	end

	if Mods > 0 and not Detailed then
		ReturnText = " | "..ReturnText
	elseif Mods == 0 and Detailed then
		ReturnText = "None"
	end

	return ReturnText
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

		if MousePosition.X+FrameSize.X+25 > ScreenSize.X then
			AnchorPoint.X = 1
		end
		if MousePosition.Y+FrameSize.Y+75 > ScreenSize.Y then
			AnchorPoint.Y = 1
		end

		NewPosition += (UDim2.new(0,20,0,35) - UDim2.new(0,AnchorPoint.X*20,0,AnchorPoint.Y*35))

		TweenService:Create(LeaderboardInterface.LeaderboardDetail,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = NewPosition,AnchorPoint = Vector2.new(AnchorPoint.X,AnchorPoint.Y)}):Play()
	end
end)

PlayerGui.BG.BeatmapLeaderboard.Destroying:Connect(function()
	LBDetailMovementConnection:Disconnect()
end)

function GetUserPlayUpdatedPS(Data:ScoreStatistic, externalData):(number, number, number)
	local PreviewMapPS = coreConfig.PreviewMapPS :: any
	local AimDiff = PreviewMapPS.AimDiff
	local SpeedDiff = PreviewMapPS.SpeedDiff
	local FLDiff = PreviewMapPS.FLdDiff
	local objCount = PreviewMapPS.objCountData
	local mapMaxCombo = PreviewMapPS.MaxCombo

	if externalData then
		AimDiff = externalData.AimDiff
		SpeedDiff = externalData.SpeedDiff
		FLDiff = externalData.FLDiff
	end

	local h300 = Data.Statistic.h300
	local h100 = Data.Statistic.h100
	local h50 = Data.Statistic.h50
	local MissCount = Data.Statistic.missCount

	local ODRate = PreviewMapPS.OD
	local ARRate = PreviewMapPS.AR
	local AimDiffStrainCount = PreviewMapPS.AimDiffStrainCount
	local SpeedDiffStrainCount = PreviewMapPS.AimDiffStrainCount
	local SpeedRelevantNoteCount = PreviewMapPS.SpeedRelevantNoteCount
	local CurrentSpeed = PreviewMapPS.CurrentSpeed


	local ModData:modData.ModData = Data.ModData

	local AccuracyData:PerformanceCalculator.AccuracyData = {
		h300 = h300, h100 = h100, h50 = h50, missCount = MissCount, EffectiveMissCount = MissCount
	}

	local ReturnData = PerformanceCalculator(AimDiff, SpeedDiff, FLDiff, ODRate, ARRate, ModData, objCount, false, AimDiffStrainCount, SpeedDiffStrainCount, SpeedRelevantNoteCount, AccuracyData)::PerformanceCalculator.PerfomanceAttributes

	--print(ActualPS, AimDiff, SpeedDiff, externalData~=nil)
	return ReturnData.Max, ReturnData.Current, mapMaxCombo
end

function ShowLeaderboardPlayDetail(Data:ScoreStatistic)
	if Data.ModData == nil then -- old plays
		Data.ModData = {} -- just replace it with no value instead
	end

	local ModDetail = GetModData(Data.ModData,true)
	local PlayedDate = os.date("*t",tonumber(Data.Date))

	local DisplayPS = ""

	if Data.Statistic then
		local _, updatedPS, _ = GetUserPlayUpdatedPS(Data)
		DisplayPS = "\nUpdatedPS: "..tostring(math.round(updatedPS.TotalPS)).."ps"
	end

	local DateDetail = string.format("%.2d/%.2d/%.4d %.2d:%.2d:%.2d",PlayedDate.day,PlayedDate.month,PlayedDate.year,PlayedDate.hour,PlayedDate.min,PlayedDate.sec)
	--local Accuracy = "<font color='#00ffff'>300</font>:"..Data.ExtraAccurancy[1].." <font color='#00ff00'>100</font>:"..Data.ExtraAccurancy[2].." <font color='#ffff00'>50</font>:"..Data.ExtraAccurancy[3].." <font color='#ff0000'>miss</font>:"..Data.ExtraAccurancy[4]
	local Accuracy = string.format("Statistic: <font color='#00ffff'>%d</font>/<font color='#00ff00'>%d</font>/<font color='#ffff00'>%d</font>/<font color='#ff0000'>%d</font>",Data.Statistic.h300,Data.Statistic.h100,Data.Statistic.h50,Data.Statistic.missCount)

	local FullText = string.format("Played on %s\n%s\nAccuracy:%.2f%%\nMod:%s%s",
		DateDetail,Accuracy,Data.Accuracy,ModDetail,DisplayPS
	)
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
end

function GetScore(CurrentScore)
	return ScoreFormat.GetScore(CurrentScore)
end

local UserPlayInformationAnimateID
local DisplayLBInformationValue = {
	Score = Instance.new("IntValue"),
	MaxCombo = Instance.new("IntValue"),
	MapMaxCombo = Instance.new("IntValue"),
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
	local MapMaxCombo = DisplayLBInformationValue.MapMaxCombo.Value
	local h300 = DisplayLBInformationValue.h300.Value
	local h100 = DisplayLBInformationValue.h100.Value
	local h50 = DisplayLBInformationValue.h50.Value
	local miss =DisplayLBInformationValue.miss.Value
	local rankedPS = DisplayLBInformationValue.rankedPS.Value
	local calculatedBasePS = DisplayLBInformationValue.calculatedBasePS.Value
	local calculatedMaxPS = DisplayLBInformationValue.calculatedMaxPS.Value

	MainFrame.ScoreDisplay.Text = string.format("Score: %s (%dx/%dx)",GetScore(Score),MaxCombo,MapMaxCombo)
	MainFrame.AccuracyDisplay.Text = string.format('Statistics: <font color = "#00ffff">%d</font>/<font color = "#55ff00">%d</font>/<font color = "#ffff00">%d</font>/<font color = "#ff0000">%d</font>',h300,h100,h50,miss)
	local Total = (h300+h100+h50+miss)
	local Acc = (h300*3+h100+h50*0.5)/(Total*3)*100
	local GameplayRank = "D"

	local misstotal = miss

	if Acc >= 70 then
		GameplayRank = "C"
	end
	if Acc >= 80 then
		GameplayRank = "B"
	end
	if Acc >= 90 then
		GameplayRank = "A"
	end
	if Acc >= 95 and misstotal <= 0 then
		GameplayRank = "S"
	end
	if Acc >= 100 then
		GameplayRank = "SS"
	end

	MainFrame.GradeDisplay.Text = string.format('Accuracy: %.2f%% [<font color = "#%s">%s</font>]',Acc,RankColor[GameplayRank]:ToHex(),GameplayRank)
	MainFrame.PSDisplay.Text = string.format("Ranked Perfomance: %.2fps",rankedPS)
	MainFrame.UpdatedPSDisplay.Text = string.format("Updated Perfomance: %.2f/%.2fps",calculatedBasePS,calculatedMaxPS)
end

for _, obj in pairs(DisplayLBInformationValue) do
	obj:GetPropertyChangedSignal("Value"):Connect(updateLBStaistic)
end

function tweenLbComponent(obj, value)
	TweenService:Create(obj, TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Value = value}):Play()
end

function AddLeaderboardConnection(LeaderboardFrame,Data:ScoreStatistic,Score,UID,DateFormat)
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

		local externalData
		local PreviewMapPS = coreConfig.PreviewMapPS :: any
		local DiffChangeModEnabled = 
			Data.ModData.EZ ~= coreConfig.EasyMod or 
			Data.ModData.HR ~= coreConfig.HardRock or 
			Data.ModData.FL ~= coreConfig.Flashlight or 
			(coreConfig.Flashlight and Data.ModData.HD ~= coreConfig.HiddenMod) or
			Data.ModData.TD ~= IsTouchDeviceActive()
		if Data.ModData.SA ~= PreviewMapPS.CurrentSpeed or DiffChangeModEnabled then
			-- We re-calculate the map and update if the player's current mod data is difference than the current set
			-- Player're not always set the NM mod to set so
			local MapFile = PreviewMapPS.MapFile
			local _, returnData = require(workspace.OsuConvert)(1, MapFile, 0, true, false, Data.ModData)
			externalData = {
				AimDiff = returnData.Difficulty.AimDifficulty,
				SpeedDiff = returnData.Difficulty.SpeedDifficulty,
				FLDiff = returnData.Difficulty.FlashLightDifficulty
			}
		end

		tweenLbComponent(DisplayLBInformationValue.Score, Score)
		tweenLbComponent(DisplayLBInformationValue.MaxCombo, Data.MaxCombo)
		tweenLbComponent(DisplayLBInformationValue.h300, Data.Statistic.h300)
		tweenLbComponent(DisplayLBInformationValue.h100, Data.Statistic.h100)
		tweenLbComponent(DisplayLBInformationValue.h50, Data.Statistic.h50)
		tweenLbComponent(DisplayLBInformationValue.miss, Data.Statistic.missCount)
		tweenLbComponent(DisplayLBInformationValue.rankedPS, Data.Performance or 0)
		local MaxPS, UpdatedPS, mapMaxCombo = GetUserPlayUpdatedPS(Data, externalData)
		tweenLbComponent(DisplayLBInformationValue.MapMaxCombo, mapMaxCombo)
		tweenLbComponent(DisplayLBInformationValue.calculatedBasePS, UpdatedPS.TotalPS)
		tweenLbComponent(DisplayLBInformationValue.calculatedMaxPS, MaxPS.TotalPS)
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
			task.spawn(function()
				task.wait(0.25)
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
	local AccData = {
		h300 = Data.Statistic.h300,
		h100 = Data.Statistic.h100,
		h50 = Data.Statistic.h50,
		miss = Data.Statistic.missCount,
		MaxCombo = Data.MaxCombo
	}

	local sendData = {
		coreConfig.PreviewMapPS.objCount, coreConfig.PreviewMapPS.MaxCombo, coreConfig.PreviewMapPS.MaxAccScore, coreConfig.PreviewMapPS.MaxConsistencyScore, coreConfig.PreviewMapPS.MaxSpinnerScore,
		Data.ModData
	}

	local DisplayScore:number = Score

	if coreConfig.ScoreV2Enabled then
		local ScoreV2 = require(ScriptComponent.Gameplay.RawV1ToV2)(Score, AccData, table.unpack(sendData))
		DisplayScore = ScoreV2
	end

	local function Check()
		if LeaderboardFrame.AbsoluteSize.X < 250 then
			LeaderboardFrame.MainFrame.Score.Text = string.format("%s (%dx)", GetScore(DisplayScore), Data.MaxCombo)
			LeaderboardFrame.MainFrame.Score.Text = GetScore(Score).."("..tostring(Data.MaxCombo).."x)"
			LeaderboardFrame.MainFrame.Accuracy.Visible = false
			LeaderboardFrame.MainFrame.PlayDate.Visible = false
			LeaderboardFrame.MainFrame.PSEarned.Position = UDim2.new(1,-8,0.6666,0)
			LeaderboardFrame.MainFrame.PSEarned.Text = DateFormat.." | "..tostring(math.round(Data.Performance)).."ps"
		else
			LeaderboardFrame.MainFrame.Accuracy.Visible = true
			LeaderboardFrame.MainFrame.PlayDate.Visible = true
			LeaderboardFrame.MainFrame.PSEarned.Position = UDim2.new(1,-8,1,0)
			LeaderboardFrame.MainFrame.PSEarned.Text = tostring(math.round(Data.Performance)).."ps"
			LeaderboardFrame.MainFrame.Score.Text = string.format("Score: %s (%dx)", GetScore(DisplayScore), Data.MaxCombo)
		end
	end
	task.wait()
	Check()
	LeaderboardFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(Check)
end

CurrentLeaderboardSession = ""

LBTweenConnection = {}
local _RefreshEvent = Instance.new("BindableEvent")

function AddLBTweenConnection(Tween,DelayedTime)
	local Key = HttpService:GenerateGUID(false)
	LBTweenConnection[Key] = _RefreshEvent.Event:Connect(function()
		task.wait(DelayedTime)
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

task.spawn(function()
	while script.Parent:FindFirstChild("GameStarted") == nil and task.wait(1.5) do
		_RefreshEvent:Fire()
	end
end)

PSLeaderboard = false

-- Legacy user leaderboard data
type UserPlayInfo = {
	Version:number,
	HaveReplay:boolean,
	Accuracy:number,
	MaxCombo:number,
	Date:number,
	Statistic:{
		h300:number,
		h100:number,
		h50:number,
		missCount:number
	},
	ModData:modData.ModData,
	Consistency:number,
	Score:number,
	ScoreV2:number,
	Performance:number
}
type UserLeaderboardData = {
	Score:number,
	Rank:number,
	ExtraData:UserPlayInfo,
	ThumbnailId:string,
	UID:number
}

local lbLoadTask:thread?

function getGrade(accuracy:number, missCount:number)
	if accuracy >= 100 then
		return "SS"
	elseif accuracy >= 95 and missCount <= 0 then
		return "S"
	elseif accuracy >= 90 then
		return "A"
	elseif accuracy >= 80 then
		return "B"
	elseif accuracy >= 70 then
		return "C"
	else
		return "D"
	end
end

function GetDate(CurrentDate)
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

LoadLeaderboard = function()
	if lbLoadTask then
		task.cancel(lbLoadTask)
	end

	lbLoadTask = task.spawn(function()
		local PSLeaderboard = GameSettingManage.getSettings:Invoke("UsePSLeaderboard")
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
		task.spawn(function()
			LeaderboardInterface.UILoad.LoadingUI.Frame.LocalScript.Disabled = false
			TweenService:Create(LeaderboardInterface.UILoad,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{GroupTransparency = 0}):Play()
		end)
		LeaderboardInterface.NoRecord.Visible = false
		LeaderboardInterface.PersonalBest.NoRecord.Visible = false
		LeaderboardInterface.PersonalBestTitle.TextTransparency = 1

		-- Get map lb data from the server
		local GlobalData:{UserLeaderboardData}, PersonalData:UserLeaderboardData, SessionChanged:boolean = game.ReplicatedStorage.BeatmapLeaderboard:InvokeServer(1,{DatastoreName = CurrentKey, UsingPerformanceLeaderboard = PSLeaderboard})

		for _, data in pairs(GlobalData) do
			data.ExtraData = ScoreStaticticConverter.ConvertStatictic(data.ExtraData)
		end

		if PersonalData.ExtraData then
			PersonalData.ExtraData = ScoreStaticticConverter.ConvertStatictic(PersonalData.ExtraData)
		end


		-- prevent duplicating request
		if SessionChanged == true or CurrentLeaderboardSession ~= ThisLBSession then return end

		local Leaderboard = LeaderboardInterface.GolbalLeaderboard
		Leaderboard:ClearAllChildren()

		local UIListLayout = Instance.new("UIListLayout",Leaderboard)
		UIListLayout.Padding = UDim.new(0,5)
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local PersonalRank = "-"
		local Top100Score = 1

		local SendingData = {
			Golbal = GlobalData,
			Local = PersonalData,
			PSLeaderboard = PSLeaderboard,
			V2Leaderboard = coreConfig.ScoreV2Enabled
		}
		script.Parent.GameplayData.LbStateAvaiable.LbDataProcess.Update:Fire(SendingData)
		--script.Parent.GameplayData.LeaderboardData.Value = HttpService:JSONEncode(SendingData)
		--CurrentPreviewFrame.Overview.LeaderboardDisplay.LBData.Value = HttpService:JSONEncode(SendingData)

		if script.Parent:FindFirstChild("GameStarted") or StartupState == "FastRestart" then return end

		local function getps(plr:UserLeaderboardData)
			return plr.ExtraData and (plr.ExtraData.Performance or 0) or 0
		end

		local SavedScoreV2:{[number]:number} = {}

		local PreviewMapPS = coreConfig.PreviewMapPS :: any

		local function getScoreV2(data:UserLeaderboardData):number
			if SavedScoreV2[data.UID] then
				return SavedScoreV2[data.UID]
			end
			local ScoreV2 = require(ScriptComponent.Gameplay.RawV1ToV2)(
				data.Score,
				{
					MaxCombo = data.ExtraData.MaxCombo, 
					h300 = data.ExtraData.Statistic.h300,
					h100 = data.ExtraData.Statistic.h100,
					h50 = data.ExtraData.Statistic.h50,
					miss = data.ExtraData.Statistic.missCount,
				},
				PreviewMapPS.objCount, PreviewMapPS.MaxCombo, PreviewMapPS.MaxAccScore, PreviewMapPS.MaxConsistencyScore, PreviewMapPS.MaxSpinnerScore,
				data.ExtraData.ModData
			)

			SavedScoreV2[data.UID] = ScoreV2
			return ScoreV2
		end

		if PSLeaderboard then
			table.sort(GlobalData,function(plr1,plr2)
				return getps(plr1) > getps(plr2) or (getps(plr1) == getps(plr2) and plr1.Rank < plr2.Rank)
			end)

			for newrank,plr in pairs(GlobalData) do
				plr.Rank = newrank
			end
		elseif coreConfig.ScoreV2Enabled then
			table.sort(GlobalData,function(plr1,plr2)
				return getScoreV2(plr1) > getScoreV2(plr2) or (getScoreV2(plr1) == getScoreV2(plr2) and plr1.Rank < plr2.Rank)
			end)

			for newrank,plr in pairs(GlobalData) do
				plr.Rank = newrank
			end
		end

		--LeaderboardInterface.LoadingText.Visible = false
		task.spawn(function()
			LeaderboardInterface.UILoad.LoadingUI.Frame.CloseRequest:Fire()
			task.wait(0.15)
			TweenService:Create(LeaderboardInterface.UILoad,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{GroupTransparency = 1}):Play()
		end)

		task.wait(0.4)
		if not script.Parent:FindFirstChild("GameStarted") then
			local function GetScore(CurrentScore)
				return ScoreFormat.GetScore(CurrentScore)
			end
			Leaderboard.CanvasSize = UDim2.new(0,0,0,#GlobalData*45)
			Leaderboard.CanvasPosition = Vector2.new(0,0)

			local Total = #GlobalData + ((PersonalData and tonumber(PersonalData.Score) and 1) or 0)
			local Loaded = 0

			for i,Data in pairs(GlobalData) do
				task.spawn(function()
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
							local achievedGrade = getGrade(Data.ExtraData.Accuracy, Data.ExtraData.Statistic.missCount)
							MaxComboText = " ("..tostring(Data.ExtraData.MaxCombo).."x)"
							NewLBFrame.MainFrame.Accuracy.Text = string.format("%.2f%%",Data.ExtraData.Accuracy)
							NewLBFrame.MainFrame.PlayDate.Text = GetDate(Data.ExtraData.Date)..GetModData(Data.ExtraData.ModData)
							NewLBFrame.MainFrame.Grade.Text = achievedGrade
							if achievedGrade == "SS" then
								NewLBFrame.MainFrame.Grade.Text = "S"
								if Data.ExtraData.ModData and (Data.ExtraData.ModData.HD or Data.ExtraData.ModData.FL) then
									NewLBFrame.MainFrame.Grade_SSH.Visible = true
								else
									NewLBFrame.MainFrame.Grade_SS.Visible = true
								end
							end
							NewLBFrame.MainFrame.Grade.TextColor3 = RankColor[achievedGrade]
							if achievedGrade == "SS" or achievedGrade == "S" then
								if Data.ExtraData.ModData and (Data.ExtraData.ModData.HD or Data.ExtraData.ModData.FL) then
									NewLBFrame.MainFrame.Grade.TextColor3 = Color3.fromRGB(177,177,177)
								end
							end
							local PSEarned = Data.ExtraData.Performance
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
						task.spawn(function()
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
									task.wait()
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

					if not Success then 
						warn("Player leaderboard load failed ",Data)
						warn(output)
					end
					for i = 1,10 do
						task.wait()
					end
					Loaded += 1
					if Loaded < Total then
						repeat task.wait() until Loaded >= Total
					end

					task.wait((i-1)*0.05)
					if NewLBFrame.Parent then
						if not OptimizedPerfomance then
							TweenService:Create(NewLBFrame.MainFrame,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0,0,0,0),BackgroundTransparency = 0.9}):Play()
							TweenService:Create(NewLBFrame,TweenInfo.new(.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(1,0,0,40)}):Play()
						else
							NewLBFrame.MainFrame.Position = UDim2.new(0,0,0,0)
							NewLBFrame.MainFrame.BackgroundTransparency = 0.9
							NewLBFrame.Size = UDim2.new(1,0,0,40)
						end
						task.wait(0.5)
						if NewLBFrame.Parent then
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
						end					
					end
				end)
			end

			if #GlobalData == 0 then
				LeaderboardInterface.NoRecord.Visible = true
			end

			task.spawn(function()
				TweenService:Create(Leaderboard.Parent.PersonalBestTitle,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{TextTransparency = 0}):Play()
				local Data = PersonalData
				if tonumber(Data.Score) ~= nil then
					LeaderboardInterface.PersonalBest.Visible = true
					LeaderboardInterface.PersonalBestTitle.Visible = true
					LeaderboardInterface.GolbalLeaderboard.Size = UDim2.new(1,0,1,-100)
					LeaderboardInterface.ScrollSide.Size = UDim2.new(0,4,1,-100)

					local PlayersFitScreen = math.floor(Leaderboard.AbsoluteSize.Y/40)+1
					local WaitTime = (#GlobalData >= PlayersFitScreen and PlayersFitScreen*0.1) or (#GlobalData)*0.1
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
						local achievedGrade = getGrade(Data.ExtraData.Accuracy, Data.ExtraData.Statistic.missCount)
						MaxComboText = " ("..tostring(Data.ExtraData.MaxCombo).."x)"
						NewLBFrame.MainFrame.Accuracy.Text = string.format("%.2f%%",Data.ExtraData.Accuracy)
						NewLBFrame.MainFrame.PlayDate.Text = GetDate(Data.ExtraData.Date)..GetModData(Data.ExtraData.Mod)
						NewLBFrame.MainFrame.Grade.Text = achievedGrade
						if achievedGrade == "SS" then
							NewLBFrame.MainFrame.Grade.Text = "S"
							if Data.ExtraData.ModData and (Data.ExtraData.ModData.HD or Data.ExtraData.ModData.FL) then
								NewLBFrame.MainFrame.Grade_SSH.Visible = true
							else
								NewLBFrame.MainFrame.Grade_SS.Visible = true
							end
						end
						NewLBFrame.MainFrame.Grade.TextColor3 = RankColor[achievedGrade]
						if achievedGrade == "SS" or achievedGrade == "S" then
							if Data.ExtraData.ModData and (Data.ExtraData.ModData.HD or Data.ExtraData.ModData.FL) then
								NewLBFrame.MainFrame.Grade.TextColor3 = Color3.fromRGB(177,177,177)
							end
						end
						local PSEarned = Data.ExtraData.Performance
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
					task.spawn(function()
						NewLBFrame.MainFrame.Rank.Text = "-"
						for i,e in pairs(GlobalData) do
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
						task.wait()
					end
					Loaded += 1
					if Loaded < Total then
						repeat task.wait() until Loaded >= Total
					end
					task.wait(WaitTime)
					NewLBFrame.Size = UDim2.new(1,0,0,40)
					if not coreConfig.OptimizedPerfomance then
						TweenService:Create(NewLBFrame.MainFrame,TweenInfo.new(0.75,Enum.EasingStyle.Quart),{Position = UDim2.new(0,0,0,0),BackgroundTransparency = 0.9}):Play()
					else
						NewLBFrame.MainFrame.Position = UDim2.new(0,0,0,0)
					end

					task.wait(0.25)
					for _,a in pairs(NewLBFrame.MainFrame:GetChildren()) do
						if a:IsA("TextLabel") then
							if a.Name ~= "UserName" then
								TweenService:Create(a,TweenInfo.new(0.75,Enum.EasingStyle.Linear),{TextTransparency = 0}):Play()
							end
						else
							TweenService:Create(a,TweenInfo.new(0.75,Enum.EasingStyle.Linear),{ImageTransparency = 0.95}):Play()
						end
					end
					task.wait(0.5)
					if not coreConfig.OptimizedPerfomance then
						AddLBTweenConnection(TweenService:Create(NewLBFrame.MainFrame,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true),{BackgroundTransparency = 0.8}),WaitTime)
					end
				else
					LeaderboardInterface.PersonalBest.Visible = false
					LeaderboardInterface.PersonalBestTitle.Visible = false
					LeaderboardInterface.GolbalLeaderboard.Size = UDim2.new(1,0,1,-40)
					LeaderboardInterface.ScrollSide.Size = UDim2.new(0,4,1,-40)
				end
			end)
		end
	end)
end

function UpdateMultiplayerRule()
	script.Parent.MultiplayerData.ChangeRule:Fire({
		SL = coreConfig.SliderMode,
		ScoreV2 = coreConfig.MPScoreV2Enabled
	})
end

GameSettingManage.SubscribeSettingChange:Fire("UsePSLeaderboard", script, function(value)
	PSLeaderboard = value
	LoadLeaderboard()
end)

GameSettingManage.SubscribeSettingChange:Fire("ScoreV2", script, function(value)
	coreConfig.ScoreV2Enabled = value
	LoadLeaderboard()
	coreConfig.MPScoreV2Enabled = value
	UpdateMultiplayerRule()
end)

GameSettingManage.SubscribeSettingChange:Fire("EnableTouchDevice", script, function(value)
	coreConfig.EnableTouchDevice = value
	ReloadPreviewFrame()
end)
--Overview 
PreviewBeatmapset = 0
BeatmapSetId = 0
BeatmapId = 0
script.Parent.MultiplayerData.RuleChanged.Event:Connect(function(Rule)
	coreConfig.SliderMode = Rule.Slider
	--osuStableNotelock = Rule.StableNL
	coreConfig.MPScoreV2Enabled = Rule.ScoreV2
end)

script.Parent.GetMapData.OnInvoke = function()
	local SongSpeed = tonumber(CurrentSetting.MainSettings.Speed.Text)

	if SongSpeed == nil or SongSpeed < 0.5 or SongSpeed > 2 or tostring(SongSpeed) == "nan" or tostring(SongSpeed) == "inf" or tostring(SongSpeed) == "-nan" or tostring(SongSpeed) == "-nan(ind)"  then
		SongSpeed = 1
	end

	return {
		Filename = BeatmapStudio.Name,
		Speed = SongSpeed,
		HD = coreConfig.HiddenMod,
		HR = coreConfig.HardRock,
		FL = coreConfig.Flashlight,
		SL = coreConfig.SliderMode,
		NF = coreConfig.NoFail,
		ScoreV2 = coreConfig.ScoreV2Enabled
	}
end

coreConfig.PreviewMapPS = {
	Aim = 0, Speed = 0, Mod = 0, AimFL = 0, Acc = 0, objCount = 0, MaxCombo = 0
}

previewFrameFirstLoad = false

ReloadPreviewFrame = function(isInit: boolean?)
	if isInit then
		previewFrameFirstLoad = true
	elseif not previewFrameFirstLoad then
		return
	end
	local ModData:modData.ModData = {
		HD = coreConfig.HiddenMod,
		HR = coreConfig.HardRock,
		EZ = coreConfig.EasyMod,
		NF = coreConfig.NoFail,
		NS = not coreConfig.SliderMode,
		FL = coreConfig.Flashlight,
		RX = false,
		AP = false,
		AT = coreConfig.AutoPlay,
		SO = false,
		V2 = coreConfig.ScoreV2Enabled,
		TD = IsTouchDeviceActive(),	-- By deafault it is false
		DA = DifficultyAdjust
	}
	local _1,_2,_3,_4,_5,_6 = script.Parent.GameplayScripts.ReloadPreviewFrame.LoadPreviewFrame:Invoke(
		coreConfig.CurrentPreviewFrame,CurrentSetting,coreConfig.FileType,CurrentModData,BeatmapStudio,CurrentKey,BeatmapKey
		,PreviewFrameBaseVolume,PreviewBeatmapset, ModData
	)
	CurrentModData = _1
	CurrentKey = _2
	BeatmapKey = _3
	PreviewFrameBaseVolume = _4
	PreviewBeatmapset = _5
	coreConfig.PreviewMapPS = _6
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

task.wait()
if StartupState == "Normal" then
	task.spawn(function()
		ReloadPreviewFrame(true)
		LoadLeaderboard()	
	end)
else
	task.spawn(function()
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
	1241445502,		-- @VtntOsu (Vtnt)
	1608539863,		-- @VtntAlt (VtntAlt)
	324532788,		-- @neffcena1337 (neffcena)
	868720498,		-- @Nop4660 (miinr)
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
		local _issuccess = game.ReplicatedStorage.DevAction:InvokeServer(Action,{Name = CurrentUsername,Key = CurrentKey,BeatmapKey = tostring(BeatmapKey)}) 
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
	local PrevMapID = coreConfig.IngamebeatmapID.Value
	CurrentSetting.VirtualSettings.PrevBeatmapID.Value = CurrentSetting.VirtualSettings.IngameBeatmapID.Value
	CurrentSetting.VirtualSettings.IngameBeatmapID.Value = beatmapid
	if PlayerGui.SavedSettings:FindFirstChild("SettingsFrame") then
		PlayerGui.SavedSettings.SettingsFrame.VirtualSettings.PrevBeatmapID.Value = PlayerGui.SavedSettings.SettingsFrame.VirtualSettings.IngameBeatmapID.Value
		PlayerGui.SavedSettings.SettingsFrame.VirtualSettings.IngameBeatmapID.Value = beatmapid
	end
	coreConfig.PrevBeatmapID.Value = PrevMapID
	coreConfig.IngamebeatmapID.Value = beatmapid
	if BeatmapChangeable == true then
		Id = beatmapid
		BeatmapStudio = MapFile
	end
	ChangingQueue -= 1
	ReloadPreviewFrame()
end)

script.Parent.MapLbUpdate.Event:Connect(function()
	if ChangingQueue > 0 then
		repeat task.wait() until ChangingQueue == 0
	end
	LoadLeaderboard()
end)
coreConfig.CurrentPreviewFrame.PreviewButton.MouseButton1Click:Connect(ReloadPreviewFrame)
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
		TweenService:Create(coreConfig.UIPreviewFrame,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(1,0)}):Play()
		TweenService:Create(BGFrame.BeatmapLeaderboard,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(0,0)}):Play()
		TweenService:Create(BGFrame.BeatmapCount,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{AnchorPoint = Vector2.new(0,0)}):Play()
		TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = math.max(0.8,DefaultBackgroundTrans+0.2)}):Play()
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			coreConfig.AutoPlay = true	-- Right control to toggle auto-play
			print("Toggle autoplay")
		end
		task.wait(0.5)
		script.Parent.StartGame:Fire()
		StreamingLoop:AddLoop(function() return not BeatmapStarted end, 0.5, function()
			script.Parent.StartGame:Fire()
		end)
	end
end)

script.Parent.onTutorial.Event:Connect(function()
	onTutorial = true
	BeatmapStudio = workspace.TutorialBeatmap["Mitsukiyo - Unwelcome School (VtntGaming) [osu!RoVer tutorial]"]
	script.Parent.StartGame:Fire()
end)

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
function replayDataDefault()
	return ReplayParser.defaultData()
end
FinaleReplayData = replayDataDefault()

------- Check if the play ranked or not
local Reporter = game.ReplicatedStorage:FindFirstChild("ExpoiltReport")
if Reporter == nil then
	warn("[Client] An error occured, please rejoin to fix this issue")
	require(PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("An error occured, please rejoin to fix this issue.",Color3.new(1, 0, 0))
	script.Disabled = true
else
	task.spawn(function()
		repeat task.wait(0.1) until Reporter.Parent == nil
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
	coreConfig.AutoPlay = false
	script.Parent.GameplayData.LeaderboardData.Value = "[]"

	SpectateRemote = SpectateData.Remote
	SavedSpectateData = SpectateData
	SpectatorCountRemote = SpectateData.SpectatorCountRemote
	task.spawn(function()
		while task.wait() do
			if game.Players:GetPlayerByUserId(UID) == nil then
				require(PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("Player you spectate has left.",Color3.new(1,0,0))
				break
			end
		end
	end)	
	game.ReplicatedStorage.Gameplay.UpdateStatus:FireServer(3)
	script.Parent.StartGame:Fire()
end)

function ProcessReplayData(stringdata):boolean
	local function setBeatmapByFilename(filename: string): boolean
		BeatmapStudio = workspace.Beatmaps:FindFirstChild(filename) or workspace.ProcessingBeatmap:FindFirstChild(filename)
		if not BeatmapStudio then
			PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire(
				`Replay data load failed: Could not found beatmap {filename} for the replay.`,
				Color3.fromRGB(255, 0, 0)
			)
			return false
		end
		return true
	end

	local ok = ReplayParser.processLine(stringdata, {
		finalReplayData = FinaleReplayData,
		setFinalReplayData = function(newData)
			FinaleReplayData = newData
		end,
		setBeatmapByFilename = setBeatmapByFilename,
		setEnvKey = function(key, value)
			coreConfig[key] = value
		end,
	})

	return ok
end

script.Parent.ReplayCall.Event:Connect(function(replaydata)
	ReplayDataRaw = replaydata

	local i = 1
	local Finish = false
	repeat 
		local Next,_ = string.find(ReplayDataRaw,"\n",i)
		if not Next then
			Finish = true
			break
		elseif i == 0 or not tonumber(string.sub(ReplayDataRaw,i,i)) then
			local isOk = ProcessReplayData(string.sub(ReplayDataRaw,i,Next-1))
			if not isOk then
				-- failed to load replay
				return
			end
			i = Next+1
			continue
		end
		Finish = true
		i = Next+1
	until Finish == true


	script.Parent.GameplayData.LeaderboardData.Value = "[]"

	task.spawn(function()
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

	coreConfig.ReplayMode = true


	game.ReplicatedStorage.Gameplay.UpdateStatus:FireServer(3)
	script.Parent.StartGame:Fire()
end)
task.spawn(function()
	--script.Parent:WaitForChild("_FastRestart",math.huge)
	if StartupState == "FastRestart" then
		if not StateReady then
			repeat task.wait() until StateReady
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

TweenService:Create(coreConfig.CurrentPreviewFrame.OverviewSong.EqualizerSoundEffect,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{HighGain = -20,MidGain = -20}):Play()
if coreConfig.CurrentPreviewFrame:FindFirstChild("OverviewSong2") then
	TweenService:Create(coreConfig.CurrentPreviewFrame.OverviewSong2.EqualizerSoundEffect,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{HighGain = -20,MidGain = -20}):Play()
end

coreConfig.OnMultiplayer = not PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.Disabled  -- Multiplayer

if coreConfig.OnMultiplayer then
	if (game.PlaceId == 6983932919 and not RunService:IsStudio()) or (LocalPlayer.UserId >= 1 and LocalPlayer.UserId ~= 1241445502 and LocalPlayer.UserId ~= 1608539863 and LocalPlayer.UserId ~= 1447265087) then
		coreConfig.AutoPlay = false
	end
	if isHost then
		local MapData = script.Parent.GetMapData:Invoke()

		PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.MultiplayerFolder.Value.StartGameRequest:InvokeServer(MapData)
	end
end

StarterGui:SetCore("ResetButtonCallback",script.Parent.RestartGame.ResetcharacterCallback)
local isLoaded = false
BeatmapStarted = true

task.spawn(function()
	repeat task.wait() until isLoaded
	for i = 1,30 do
		task.wait()
	end
	--TweenService:Create(script.Parent.Interface.BG,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false),{BackgroundTransparency = 1}):Play()
	TweenService:Create(coreConfig.CurrentPreviewFrame.OverviewSong.EqualizerSoundEffect,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{HighGain = 0,MidGain = 0}):Play()
	TweenService:Create(coreConfig.CurrentPreviewFrame.OverviewSong,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{Volume = 0}):Play()

	if coreConfig.CurrentPreviewFrame:FindFirstChild("OverviewSong2") then
		TweenService:Create(coreConfig.CurrentPreviewFrame.OverviewSong2.EqualizerSoundEffect,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{HighGain = 0,MidGain = 0}):Play()
		TweenService:Create(coreConfig.CurrentPreviewFrame.OverviewSong2,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{Volume = 0}):Play()
	end
	TweenService:Create(script.Parent.Interface.Background,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{GroupTransparency = 1}):Play()
	task.wait(0.25)
	script.Parent.Interface.Background.Visible = false
	coreConfig.CurrentPreviewFrame.OverviewSong:Stop()
	if coreConfig.CurrentPreviewFrame:FindFirstChild("OverviewSong2") then
		coreConfig.CurrentPreviewFrame.OverviewSong2:Stop()
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
		task.wait(1)
	else
		script.Parent.Interface.Background.GroupTransparency = 0
	end
end

if coreConfig.OnMultiplayer then
	script.Parent.MultiplayerLeaderboard.StateEnabled.Value = coreConfig.InGameLeaderboard
	script.Parent.MultiplayerLeaderboard.LbTrigger:Fire(coreConfig.InGameLeaderboard)
	script.Parent.MultiplayerLeaderboard.LeaderboardWorking.Disabled = false	
else
	script.Parent.Leaderboard.LeaderboardWorking.Disabled = false
end

do
	local lbvalue =  Instance.new("BoolValue",script.Parent.TempSettings)
	lbvalue.Name = "IngameLB"
	lbvalue.Value = coreConfig.InGameLeaderboard and not onTutorial
end

if coreConfig.BackgroundBlurEnabled == true then
	BackgroundFrame.Visible = false
	BackgroundFrame.Parent.Parent.BG.Visible = false
end

task.spawn(function()
	task.wait()
	BackgroundFrame.Position = UDim2.new(0.5,0,0.5,0)
	BackgroundFrame.Size = UDim2.new(1,0,1,0)
end)

if isSpectating or coreConfig.AutoPlay then
	coreConfig.DisableChatInGame = false
end

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,not coreConfig.DisableChatInGame)
if coreConfig.DisableChatInGame then
	StarterGui:SetCore("ChatActive",false)
end
Instance.new("BoolValue",script.Parent).Name = "GameStarted"

local Settings = CurrentSetting.MainSettings

-- The game main difficulty value
local CS = 5
local ApproachRate = 5
local OverallDifficulty = 5
local HPDrain = 5

-- Load settings from Object data into Script data
SongSpeed = tonumber(Settings.Speed.Text)
SongDelay = SavedGameSettings.AudioOffset
Beatmap = Settings.BeatmapFile.Text
CursorSensitivity = SavedGameSettings.VirtualCursorSensitivity
CursorID = SavedGameSettings.CursorID
CursorSize = SavedGameSettings.CursorSize
CursorTrailId = SavedGameSettings.CursorTrailID
CursorTrailSize = SavedGameSettings.CursorTrailSize
CursorTrailTransparency = 1-(SavedGameSettings.CursorTrailOpacity)*0.01
CircleImageId = SavedGameSettings.BaseCircleID
CircleOverlayImageId = SavedGameSettings.CircleOverlayID
ApproachCircleImageId = SavedGameSettings.ApproachCircleID
EffectVolume = SavedGameSettings.EffectVolume
HitZoneArea = SavedGameSettings.HitzoneArea * 0.01
SongVolume = SavedGameSettings.SongVolume
ClassicNotelock = (coreConfig.AutoPlay and true) or SavedGameSettings.ClassicNotelock -- If enabled, it will use osu!stable notelock system, else it will use osu!lazer system
PSLeaderboard = SavedGameSettings.UsePSLeaderboard
coreConfig.CursorTrailEnabled = SavedGameSettings.CursorTrail
coreConfig.EnableTouchDevice = SavedGameSettings.EnableTouchDevice
coreConfig.MouseButtonEnabled = SavedGameSettings.MouseButton
coreConfig.OldCursorMovement = not SavedGameSettings.VirtualCursor
coreConfig.PSDisplay = SavedGameSettings.PerfomanceOverlay
coreConfig.OldInterface = SavedGameSettings.LegacyOverlay
coreConfig.HitErrorEnabled = SavedGameSettings.HitError
coreConfig.OverallInterfaceEnabled = SavedGameSettings.ScoreOverlay
coreConfig.MobileModeRightHitZone = SavedGameSettings.RightSizeHitzone
coreConfig.DisableChatInGame = SavedGameSettings.DisableChatIngame
coreConfig.KeepOriginalPitch = SavedGameSettings.EnableSpeedPitch
coreConfig.InGameLeaderboard = SavedGameSettings.ShowInGameLeaderboard
coreConfig.HitZoneEnabled = SavedGameSettings.EnableHitzone
coreConfig.CustomComboColorEnabled = SavedGameSettings.CustomComboColor
coreConfig.OptimizedPerfomance = SavedGameSettings.OptimizedPerfomance
coreConfig.DetailedPSDisplay = SavedGameSettings.DetailedPerformance
coreConfig.ExclusiveEffects = false--SavedGameSettings.
coreConfig.InstaFadeCircle = SavedGameSettings.InstaFadeCircle
coreConfig.ScoreV2Enabled = SavedGameSettings.ScoreV2
coreConfig.HitKeyOverlay = SavedGameSettings.KeyOverlay
coreConfig.LiveDifficultyDisplay = SavedGameSettings.LiveDifficultyOverlay
coreConfig.Hit300Display = SavedGameSettings.ShowHit300
Key1Input = Enum.KeyCode:FromName(SavedGameSettings.LeftKey)
Key2Input = Enum.KeyCode:FromName(SavedGameSettings.RightKey)
coreConfig.DefaultBackgroundTrans = 1-(SavedGameSettings.BGDim * 0.01)
EnableSliderShadow = SavedGameSettings.EnableSliderShadow
KeyHistoryOverlayEnabled = SavedGameSettings.KeyHistoryOverlay
SnakingInSlider = SavedGameSettings.SnakingInSliders
SnakingOutSlider = SavedGameSettings.SnakingOutSlider
coreConfig.StoryboardEnabled = SavedGameSettings.EnableStoryboard

if coreConfig.OnMultiplayer then
	coreConfig.ScoreV2Enabled = coreConfig.MPScoreV2Enabled
end

function checkFPSCounterPos()
	if coreConfig.PSDisplay then
		if coreConfig.DetailedPSDisplay then
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
	script.Parent.AccurancyDisplay.Visible = coreConfig.OverallInterfaceEnabled and coreConfig.OldInterface
	script.Parent.ComboDisplay.Visible = coreConfig.OverallInterfaceEnabled and coreConfig.OldInterface
	script.Parent.ScoreDisplay.Visible = coreConfig.OverallInterfaceEnabled and coreConfig.OldInterface
	-- New score interface
	script.Parent.ScoreFrameDisplay.Visible = coreConfig.OverallInterfaceEnabled and not coreConfig.OldInterface
	script.Parent.AccurancyFrameDisplay.Visible = coreConfig.OverallInterfaceEnabled and not coreConfig.OldInterface
	script.Parent.ComboFrameDisplay.Visible = coreConfig.OverallInterfaceEnabled and not coreConfig.OldInterface
end
toggleScoreOverlay()
updateLbState(coreConfig.InGameLeaderboard)

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(checkFPSCounterPos)

checkFPSCounterPos()

function ToggleDirectChange(settingName, callback)
	GameSettingManage.SubscribeSettingChange:Fire(settingName, script, callback)
end

-- Those settings can be applied instantly when players change it
ToggleDirectChange("InstaFadeCircle", function(value) coreConfig.InstaFadeCircle = value end)
ToggleDirectChange("OptimizedPerfomance", function(value)
	coreConfig.OptimizedPerfomance = value
	script.Parent.PSEarned.AnimatedPSEarned.Visible = not value
	script.Parent.PSEarned.TextTransparency = value and 0 or 1
end)
ToggleDirectChange("ShowHit300", function(value) coreConfig.Hit300Display = value end)
ToggleDirectChange("ScoreV2", function(value)
	if not coreConfig.OnMultiplayer then
		coreConfig.ScoreV2Enabled = value
		LoadLeaderboard()
	end
end)
ToggleDirectChange("BGDim", function(value)
	coreConfig.DefaultBackgroundTrans = 1-(value * 0.01)
	TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{BackgroundTransparency = coreConfig.DefaultBackgroundTrans}):Play()
end)
ToggleDirectChange("LiveDifficultyOverlay", function(value) coreConfig.LiveDifficultyDisplay = value end)
ToggleDirectChange("PerfomanceOverlay", function(value)
	coreConfig.PSDisplay = value
	script.Parent.PSEarned.Visible = value

	checkFPSCounterPos()
end)
ToggleDirectChange("DetailedPerformance", function(value)
	coreConfig.DetailedPSDisplay = value
	script.Parent.PSEarned.DetailedDisplay.Visible = value

	checkFPSCounterPos()
end)
ToggleDirectChange("EnableSliderShadow", function(value) EnableSliderShadow = value end)
ToggleDirectChange("ShowInGameLeaderboard", function(value)
	coreConfig.InGameLeaderboard = value
	updateLbState(value)
end)
ToggleDirectChange("CursorTrail", function(value)
	coreConfig.CursorTrailEnabled = value
	script.Parent.Cursor.TrailEnabled.Value = value
end)
ToggleDirectChange("CursorTrailDuration", function(value)
	script.Parent.Cursor.FadeTime.Value = value
end)
ToggleDirectChange("LegacyOverlay", function(value)
	coreConfig.OldInterface = value
	toggleScoreOverlay()
end)
ToggleDirectChange("ScoreOverlay", function(value)
	coreConfig.OverallInterfaceEnabled = value
	toggleScoreOverlay()
end)
ToggleDirectChange("KeyOverlay", function(value)
	coreConfig.HitKeyOverlay = value
	script.Parent.HitKey.Visible = value
end)

ToggleDirectChange("KeyHistoryOverlay", function(value)
	KeyHistoryOverlayEnabled = value
end)

ToggleDirectChange("MusicVolume", function(value)
	SongVolume = value
	if AdjustIngameSongVolume then
		AdjustIngameSongVolume(value)
	end
end)

ToggleDirectChange("EffectVolume", function(value)
	EffectVolume = value
	if AdjustIngameEffectVolume then
		AdjustIngameEffectVolume(value)
	end
end)

ToggleDirectChange("CursorSize", function(value)
	local CursorSize = 0.2 * value
	script.Parent.CursorField.Cursor.Size = UDim2.fromScale(CursorSize, CursorSize)
end)

ToggleDirectChange("CursorTrailSize", function(value)
	local CursorTrailSize = 0.2 * value
	script.Cursor_Trail.Size = UDim2.fromScale(CursorTrailSize, CursorTrailSize)
end)

ToggleDirectChange("SnakingInSliders", function(value)
	SnakingInSlider = value
end)

ToggleDirectChange("SnakingOutSlider", function(value)
	SnakingOutSlider = value
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
coreConfig.UIPreviewFrame.Parent = PlayerGui.SavedSettings
coreConfig.UIPreviewFrame.AnchorPoint = Vector2.new(0,0)
script.Parent.Parent.BG.BeatmapChooseButton.Visible = false
script.Parent.Cursor.TrailEnabled.Value = coreConfig.CursorTrailEnabled
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

if coreConfig.DefaultBackgroundTrans == nil or coreConfig.DefaultBackgroundTrans < 0 or coreConfig.DefaultBackgroundTrans > 1 then
	coreConfig.DefaultBackgroundTrans = 0.2
end

if isSpectating == false then
	if SongSpeed == nil or SongSpeed < 0.5 or SongSpeed > 2 or tostring(SongSpeed) == "nan" or tostring(SongSpeed) == "inf" or tostring(SongSpeed) == "-nan" or tostring(SongSpeed) == "-nan(ind)"  then
		SongSpeed = 1
	end

	if Beatmap == nil or Beatmap == "" or coreConfig.FileType == 1 then
		Beatmap = BeatmapStudio
		coreConfig.FileType = 1
	end

else
	coreConfig.FileType = SavedSpectateData.FileType
	Beatmap = workspace.Beatmaps[SavedSpectateData.FileName]

	task.spawn(function()
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
	if coreConfig.FileType == 1 then
		Beatmap = BeatmapsList:FindFirstChild(SavedSpectateData.FileName)
	end
	SongDelay = SavedSpectateData.Offset
	SongSpeed = SavedSpectateData.Speed
	coreConfig.SliderMode = SavedSpectateData.SliderMode
	coreConfig.HiddenMod = SavedSpectateData.HD
	coreConfig.NoFail = SavedSpectateData.HC
	coreConfig.Flashlight = SavedSpectateData.FL
	coreConfig.HardRock = SavedSpectateData.HR
	coreConfig.TouchDeviceDetected = SavedSpectateData.TD
end

-- Load multiplayer data
if coreConfig.OnMultiplayer and not isHost then
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

		coreConfig.HiddenMod = MultiplayerData.MatchData.HD
		coreConfig.HardRock = MultiplayerData.MatchData.HR
		coreConfig.Flashlight = MultiplayerData.MatchData.FL
		coreConfig.SliderMode = MultiplayerData.MatchData.SL
		coreConfig.NoFail = MultiplayerData.MatchData.NF
	end

	if MultiplayerData.MatchRule.ForceAR then
		ApproachRate = MultiplayerData.MatchData.CustomAR
	end


	SongSpeed = MultiplayerData.MatchData.Speed
	Beatmap = workspace.Beatmaps[MultiplayerData.MatchData.Filename]
	task.spawn(function()
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
	coreConfig.MPScoreV2Enabled = MultiplayerData.MatchData.ScoreV2
end

-- load spectate data

if isSpectating == true then
	ClassicNotelock = SavedSpectateData.StableNotelock
end

-- Replay data
if coreConfig.ReplayMode then
	SongSpeed = FinaleReplayData.Speed
end


-- Get beatmap data
local ModData:modData.ModData = {
	HD = coreConfig.HiddenMod,
	HR = coreConfig.HardRock,
	EZ = coreConfig.EasyMod,
	NF = coreConfig.NoFail,
	NS = not coreConfig.SliderMode,
	FL = coreConfig.Flashlight,
	RX = false,
	AP = false,
	AT = coreConfig.AutoPlay,
	SO = false,
	V2 = coreConfig.ScoreV2Enabled,
	TD = not coreConfig.ReplayMode and IsTouchDeviceActive() or coreConfig.Replay_TouchDevice,
	DA = DifficultyAdjust,
	SA = SongSpeed
}

local BeatmapData,ReturnData,TimingPoints,BeatmapComboColor = require(workspace.OsuConvert)(coreConfig.FileType,Beatmap,SongDelay,true,false, ModData)

--	Initiate important stuff for the gameplay
--------------------------------------------------------------------------------------------------------------------------------------------
local customFields = {
	[Enum.AnalyticsCustomFieldKeys.CustomField01.Name] = getDifficultyNameByValue(ReturnData.Difficulty.BeatmapDifficulty),
	[Enum.AnalyticsCustomFieldKeys.CustomField02.Name] = getMapLengthNameByTime(ReturnData.Overview.MapLength/1000),
	[Enum.AnalyticsCustomFieldKeys.CustomField03.Name] = getMapTypeByDiff(ReturnData.Difficulty.AimDifficulty,ReturnData.Difficulty.SpeedDifficulty,ReturnData.Overview.MapLength/1000),
}


CurrentKey = ReturnData.BeatmapSetsData.BeatmapsetID.."-"..ReturnData.BeatmapSetsData.BeatmapID
BeatmapKey = ReturnData.BeatmapSetsData.BeatmapID
script.Parent.GameplayData.SongSpeed.Value = SongSpeed

-- BackgroundChange
local Background = PlayerGui.BG.Background.Background

for _,Obj in pairs(Background:GetChildren()) do 
	if Obj:IsA("ImageLabel") then
		TweenService:Create(Obj,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
		task.spawn(function()
			task.wait(0.25)
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

script.Parent.HitError.Visible = coreConfig.HitErrorEnabled

-----------
PlayerGui.BG.GameTitle.Visible = false
script.Parent.HitKey.Visible = coreConfig.HitKeyOverlay

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

if coreConfig.AutoPlay then
	Instance.new("IntValue",script.Parent.GameplayData).Name = "isAT"
end

-- indicate if the map have 2 song
-- this is mostly possible on 7+ minute song length
ExistSecondSong = (ReturnData.MapSongId2 ~= nil)
if ReturnData.MapSongId or ReturnData.CustomSongFile then
	script.Parent.GameSong.Song.Asset = ReturnData.CustomSongFile or "rbxassetid://"..tostring(ReturnData.MapSongId)
	script.Parent.GameSong.Song2.Asset = ExistSecondSong and "rbxassetid://"..tostring(ReturnData.MapSongId2) or ""
end

-- load all the assets
ContentList = {}

function CheckDupeContent(obj)
	for _,a in pairs(ContentList) do
		if a.ClassName == obj.ClassName then
			if (obj:IsA("ImageLabel") or obj:IsA("ImageButton")) and obj.Image == a.Image then
				return false
			elseif obj:IsA("AudioPlayer") and obj.Asset == a.Asset then
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
	for i = 1,10 do task.wait() end
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
	if coreConfig.StoryboardEnabled then
		local id = ReturnData.BeatmapSetsData.BeatmapsetID
		local storyboardMap = workspace.Storyboards:FindFirstChild(id)
		if storyboardMap then
			coreConfig.StoryboardAvailable = true
			local storyboardUI = game.Players.LocalPlayer.PlayerGui.StoryboardUI
			storyboardUI.StoryboardMap.Value = storyboardMap
			--storyboardUI.DifficultyMap.Value = Beatmap
			storyboardUI.Scripts.Actor.Storyboard.Enabled = true
			ContentLoadingUI.LoadUIDisplay.LoadText.Text = "Loading storyboard..."
			print("Storyboard enabled...")
			if not storyboardUI.StoryboardLoaded.Value then
				local t = -1
				repeat task.wait()
					if storyboardUI.LoadProgress.Value ~= t then
						t = storyboardUI.LoadProgress.Value
						TweenService:Create(ContentLoadingUI.ProgressBar.Progress,TweenInfo.new(0.1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
							Size = UDim2.new(t,0,1,0)
						}):Play()
					end
				until storyboardUI.StoryboardLoaded.Value
			end
		end		
	end

	ContentLoadingUI.LoadUIDisplay.LoadText.Text = "Ready!"
	TweenService:Create(ContentLoadingUI.ProgressBar.Progress,TweenInfo.new(0.1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
		Size = UDim2.new(1,0,1,0)
	}):Play()
	task.wait(2)

	TweenService:Create(ContentLoadingUI,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
		Size = UDim2.new(1,0,0.17,0),GroupTransparency = 1
	}):Play()

	TweenService:Create(ContentLoadingUI.UISizeConstraint,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
		MaxSize = Vector2.new(math.huge,80)
	}):Play()

	if coreConfig.OnMultiplayer then
		script.Parent.MultiplayerWaitFrame.Visible = true
		local PlayersInMatch = PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.MultiplayerFolder.Value.WaitForAllLoaded:InvokeServer()
		script.Parent.MultiplayerLeaderboard.MultiplayerData.Value = HttpService:JSONEncode(PlayersInMatch)
		script.Parent.MultiplayerWaitFrame.Visible = false
	end
	TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = coreConfig.DefaultBackgroundTrans+0.2}):Play()
	TweenService:Create(StartButton,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{Size = UDim2.new(0.2,0,0.2,0),BackgroundTransparency = 1}):Play()
	TweenService:Create(StartButton._Text,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{ImageTransparency = 1}):Play()
	TweenService:Create(StartButton._Text2,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{ImageTransparency = 1}):Play()

	task.spawn(function()
		task.wait(1)
		script.Parent.Parent.BG.StartButtonBeatAnimation:Destroy()
		StartButton:Destroy()
		ContentLoadingUI.Visible = false
	end)
end)

-- Setup difficulty values
if isSpectating == false then
	if ReturnData.Difficulty ~= nil then		
		local ConvertTools = require(workspace.OsuConvert.converterTools)
		local Difficulty = ReturnData.Difficulty
		CS = ConvertTools.GetDifficultyValueAfterMod.CS(Difficulty.CircleSize, ModData)
		ApproachRate = ConvertTools.GetDifficultyValueAfterMod.AR(Difficulty.ApproachRate, ModData)
		_, OverallDifficulty = ConvertTools.GetDifficultyValueAfterMod.OD(Difficulty.OverallDifficulty, ModData)
		HPDrain = ConvertTools.GetDifficultyValueAfterMod.HP(Difficulty.HPDrainRate, ModData)
	end
else
	local Diff = SavedSpectateData.DiffData
	CS = Diff.CS
	ApproachRate = Diff.AR
	OverallDifficulty = Diff.OD
end

local RankedRequirement = {
	coreConfig.FileType == 1,
	coreConfig.AutoPlay == false or (LocalPlayer.UserId == 1241445502 and RunService:IsStudio() and false),
	coreConfig.ReplayMode == false,
	coreConfig.SpeedSync == true,
	not LocalPlayer:FindFirstChild("PlayerUnranked"),
	not DifficultyAdjust or not DifficultyAdjust.Active,
	isSpectating == false,
	LocalPlayer.UserId >= 1,
	onTutorial == false,
}

task.spawn(function()
	task.wait(2)
	for _,Requirement in pairs(RankedRequirement) do
		if not Requirement then
			PlayRanked = false
			break
		end
	end

	script.Parent.UnrankedSign.Visible = not PlayRanked
end)

if isSpectating == true or coreConfig.ReplayMode == true then
	script.Parent.UnrankedSign.Text = "SPECTATING"
elseif coreConfig.AutoPlay then
	script.Parent.UnrankedSign.Text = "AUTOPLAY"
elseif onTutorial == true then
	script.Parent.UnrankedSign.Text = "TUTORIAL"
	-- load the most default mode
	CS = 3.5
	ApproachRate = 4
	OverallDifficulty = 2
	coreConfig.AutoPlay = false
	coreConfig.SliderMode = true
	SongSpeed = 1
	coreConfig.HiddenMod = false
	coreConfig.HardRock = false
	coreConfig.EasyMod = false
	coreConfig.NoFail = false
end

local PlayingRemote
local StartPlayingTick = tick()

function isActivelyPlaying()
	-- Return if the player is playing or not
	-- We make some exception for testing
	return isSpectating == false 
		and (coreConfig.AutoPlay == false 
			or (string.sub(LocalPlayer.Name,1,6) == "Player" and RunService:IsStudio()) 
			or ((LocalPlayer.UserId == 1241445502 
				or LocalPlayer.UserId == 1608539863) 
				and game.PlaceId ~= 6983932919))
end

if isActivelyPlaying() then
	local FileName = Beatmap
	if coreConfig.FileType == 1 then
		FileName = Beatmap.Name
	end

	local Data = {
		FileType = coreConfig.FileType,
		FileName = FileName,
		Offset = SongDelay,
		SliderMode = coreConfig.SliderMode,
		StartTime = tick() - 2,
		Speed = SongSpeed,
		AR = ApproachRate,
		CS = CS,
		OD = OverallDifficulty,
		HP = HPDrain,
		StableNotelock = ClassicNotelock,
		FL = coreConfig.Flashlight,
		NF = coreConfig.NoFail,
		HD = coreConfig.HiddenMod,
		HR = coreConfig.HardRock,
		TD = coreConfig.TouchDeviceDetected
	}
	PlayingRemote,SpectatorCountRemote = game.ReplicatedStorage.Gameplay.GetSpectateData:InvokeServer(LocalPlayer.UserId,Data)
end

-------------------
task.spawn(function()
	if SpectatorCountRemote then
		StreamingLoop:AddLoop(function() return true end, 5, function()
			local SpectatorsCount = SpectatorCountRemote:InvokeServer()
			if SpectatorsCount > 0 then
				script.Parent.SpectatorsCount.Visible = true
				script.Parent.SpectatorsCount.Text = "Spectators: "..tostring(SpectatorsCount)
			else
				script.Parent.SpectatorsCount.Visible = false
			end
		end)
	end
end)

-------------------
CustomComboColor = HttpService:JSONDecode(SavedGameSettings.ComboColorList) --HttpService:JSONDecode(Settings.Parent.VirtualSettings.CustomComboColor.Value)
local GameDefaultColor = {	-- osu!RoVer default combo color (if no color is set)
	Color3.fromRGB(241,79,10),
	Color3.fromRGB(153,203,253),
	Color3.fromRGB(54,115,228),
	Color3.fromRGB(98,46,207),
	Color3.fromRGB(227,149,43),
	Color3.fromRGB(37,203,33),
	Color3.fromRGB(16,190,182),
	Color3.fromRGB(255,0,0)
}

local ComboColor = GameDefaultColor

if CustomComboColor and #CustomComboColor > 1 then
	local ConvertedCustomComboColor = {}
	for _,a in pairs(CustomComboColor) do
		ConvertedCustomComboColor[#ConvertedCustomComboColor+1] = Color3.fromHex(a)
	end
	ComboColor = ConvertedCustomComboColor
end

if BeatmapComboColor ~= nil and not coreConfig.CustomComboColorEnabled then
	ComboColor = BeatmapComboColor
end

ToggleDirectChange("ComboColorList", function(CustomComboColor)
	CustomComboColor = HttpService:JSONDecode(CustomComboColor)
	if CustomComboColor and #CustomComboColor > 1 and (BeatmapComboColor == nil or coreConfig.CustomComboColorEnabled) then
		local ConvertedCustomComboColor = {}
		for _,a in pairs(CustomComboColor) do
			ConvertedCustomComboColor[#ConvertedCustomComboColor+1] = Color3.fromHex(a)
		end
		ComboColor = ConvertedCustomComboColor
	elseif BeatmapComboColor then
		ComboColor = BeatmapComboColor
	else
		ComboColor = GameDefaultColor
	end
end)
--------
TimeUtils.InitTimeClock(2)
local Start = tick()+2
local SongStart = tick()+2

--local Cursor = script.Parent.PlayFrame.Cursor
local Cursor = script.Parent.CursorField.Cursor
--local DisplayingCursor = script.Parent.PlayFrame.Cursor
local CursorTrail = script.Cursor_Trail

local CursorPosition = Vector2.new(256,576)
local ATVC = Instance.new("Frame") -- AutoPlay Virtual Cursor
ATVC.Position = UDim2.new(0.5,0,1.5,0)

if coreConfig.AutoPlay == true then
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

AdjustIngameSongVolume = function(volume)
	if tonumber(ReturnData.BeatmapVolume) ~= nil and ReturnData.BeatmapVolume > 0 and ReturnData.BeatmapVolume < 10 then
		TweenService:Create(script.Parent.GameSong.Song, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Volume = ReturnData.BeatmapVolume*(volume*0.002)}):Play()
		TweenService:Create(script.Parent.GameSong.Song2, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Volume = ReturnData.BeatmapVolume*(volume*0.002)}):Play()
	else
		TweenService:Create(script.Parent.GameSong.Song, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Volume = volume*0.002}):Play()
		TweenService:Create(script.Parent.GameSong.Song2, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Volume = volume*0.002}):Play()
	end
end
AdjustIngameSongVolume(SavedGameSettings.MusicVolume)

local timingPointEffectVolumeMultiplier = 1
AdjustIngameEffectVolume = function(volume)
	--print("Adjust volume to: ", volume*0.004*timingPointEffectVolumeMultiplier)
	for _,Hitsound in pairs(script.Hitsounds:GetChildren()) do
		Hitsound.Volume = volume*0.004*timingPointEffectVolumeMultiplier
	end
end
AdjustIngameEffectVolume(EffectVolume)

-- storyboard
local storyboardUI = game.Players.LocalPlayer.PlayerGui.StoryboardUI

if coreConfig.StoryboardAvailable then
	storyboardUI.Enabled = true
	storyboardUI.GameReady.Value = true

	task.spawn(function()
		task.wait(0.5)
		storyboardUI.Scripts.Actor:SendMessage("SetTime", os.clock() - Start)
		storyboardUI.Scripts.Actor:SendMessage("SetSpeed", SongSpeed)
	end)
end

-- Cursor lock
local CursorUnlocked = false

--HPDrain
local MaxHealthPoint = 100
local HealthPoint = 0
local EZModCheckpoint = 3
local isDrain = false
local BeatmapFailed = false
local TotalNote = 0
local TotalSliders = 0

script.Parent.HealthBar.Overlay.EZModHPCheckpoint.Visible = coreConfig.EasyMod
-- 3.2 per note

if coreConfig.EasyMod then
	MaxHealthPoint = 300
end
-- HP rate:			0 - 5 - 10
-- Miss drain:		5 - 10.5 - 20
-- Miss until fail:	20 - 10 - 5

local HitnoteAnimations = {}

script.Parent.HealthBar.Visible = coreConfig.showHealthBar

if not coreConfig.SliderMode then
	for _,HitObjData in pairs(BeatmapData) do
		TotalNote += 1
		if ObjectTools.GetObjectProperties(HitObjData.Type).isSlider then
			TotalSliders += tonumber(HitObjData.ExtraData[3])
		end
	end
	local Multiplier = (TotalNote + TotalSliders)/TotalNote
end

function GameOver()
	task.spawn(function()
		if BeatmapFailed or coreConfig.NoFail or coreConfig.ReplayMode then
			return
		end
		if PlayRanked then
			game.ReplicatedStorage.AnalyticCustomEvent:FireServer("Failcount", 1, customFields)
			game.ReplicatedStorage.AnalyticCustomEvent:FireServer("DifficultyFailedDistribution", ReturnData.Difficulty.BeatmapDifficulty, customFields)
		end

		if coreConfig.OnMultiplayer then
			if not coreConfig.MultiplayerMatchFailed then
				coreConfig.MultiplayerMatchFailed = true
				PlayRanked = false
				PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("You've failed, but you can still continue to play.", Color3.fromRGB(255, 0, 0))
				return
			else
				return
			end
		end	
		PauseScreenUtils.Toggle(false, false, {})	-- Just in case they are doing it....
		script.Parent.GameplayData.PauseAllowed.Value = false

		CursorUnlocked = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		Cursor.Visible = false
		PlayerGui.OsuCursor.Cursor.Visible = true
		script.Parent.FailSound:Play()

		local hpLeftTween = TweenService:Create(script.Parent.HealthBar.Overlay.HPLeft, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.new(0, 0, 1, 0) })
		hpLeftTween:Play()



		for _, tween in pairs(HitnoteAnimations) do
			task.spawn(function()
				if tween:IsA("Tween") then
					tween:Pause()
				end
			end)
		end
		BeatmapFailed = true
		TimeUtils.PauseTime()
		Start = 1e20
		SongStart = 1e20

		--[[ NEW GAMEOVER ANIMATION
		for _, TweenObj in pairs(script.Parent.PlayFrame:GetChildren()) do
			if TweenObj:IsA("GuiObject") then
				if TweenObj.Name == "Slider" then
					for _,obj in pairs(TweenObj:GetChildren()) do
						task.spawn(function()
							require(script.Parent.GameplayScripts.UISeparate)(obj)
						end)
					end
					continue
				end
				task.spawn(function()
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

		TweenService:Create(script.Parent.GameSong.Song, TweenInfo.new(3, Enum.EasingStyle.Linear), {Volume = 0, PlaybackSpeed = 0 }):Play()
		task.wait(0.5)

		for _, TweenObj in pairs(script.Parent.PlayFrame:GetDescendants()) do
			if TweenObj.Name ~= "Cursor" and TweenObj.Name ~= "Flashlight" and TweenObj.Parent.Name ~= "MessagePatch" and TweenObj.Parent.Name ~= "CursorFade" and TweenObj:IsA("GuiObject") then
				local ImageTrans = (TweenObj:IsA("ImageLabel") and 1) or nil
				local TextTrans = (TweenObj:IsA("TextLabel") and 1) or nil
				TweenService:Create(TweenObj, TweenInfo.new(2.5, Enum.EasingStyle.Linear), { BackgroundTransparency = 1, ImageTransparency = ImageTrans, TextTransparency = TextTrans }):Play()
			end
		end

		task.wait(1.5)

		local restartGameTween = TweenService:Create(script.Parent.RestartGame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { TextTransparency = 1, BackgroundTransparency = 1 })
		restartGameTween:Play()

		task.spawn(function()
			task.wait(0.5)
			script.Parent.RestartGame.Visible = false
		end)

		local pauseScreenArgs = {}


		if coreConfig.AutoPlay == true then
			pauseScreenArgs.CustomText = "Player failed"
		elseif isSpectating then
			pauseScreenArgs.CustomText = "Player failed"
			pauseScreenArgs.DisableRestart = true
		else
			-- do nothing xd
		end

		PauseScreenUtils.Toggle(true, true, pauseScreenArgs)

		task.wait(1)

		for _, a in pairs(script.Parent.PlayFrame:GetChildren()) do
			if a.Name ~= "FlashLight" then
				a:Destroy()
			end
		end
	end)
end

local DrainSpeed = 1.75
local CurrentDrainSpeed = 0
local HealthDrainMultiplier = 1

function AddHealthDrainMultiplier(rate)
	HealthDrainMultiplier += rate * 0.1
end

task.spawn(function()
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
	StreamingLoop:AddLoop(function() return true end, function() return 0 end, function(t)
		if isDrain and not isSpectating and not TimeUtils.IsPaused() then
			-- do not drain while on break
			-- when spectating, it get the host's HP instead
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

			if HealthPoint < 10 and DrainSpeed >= 15 and coreConfig.NoFail and ReturnData.Difficulty.BeatmapDifficulty >= 6 and TimeUtils.GetTime() >= 60 then
				BadgeCondition.CloseOne = true
			end


			if HealthDrainMultiplier < 1 then
				HealthDrainMultiplier = 1
			end
			if HealthPoint < 0 then
				HealthPoint = 0
			elseif HealthPoint < MaxHealthPoint*((EZModCheckpoint-1)/3) and coreConfig.EasyMod then
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
	end)
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
		local Progress = (TimeUtils.GetTime()) / (BeatmapData[#BeatmapData].Time/1000)
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
	if coreConfig.EasyMod then
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

task.spawn(function()
	local LastHP = HealthPoint
	local LastHPDrainSpeed = CurrentDrainSpeed
	local HealthBar = script.Parent.HealthBar
	local HPLeft = HealthBar.Overlay.HPLeft
	local HolderFrame = HPLeft.Overlay.HolderFrame
	local HealthDisplay = HealthBar.HealthDisplay

	StreamingLoop:AddLoop(function() return true end, function() return 0 end, function(t)
		if LastHPDrainSpeed ~= CurrentDrainSpeed and HealthPoint ~= 0 then
			if not coreConfig.OptimizedPerfomance then
				TweenService:Create(HPLeft.Overlay.HealthDrainSpeed, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new((CurrentDrainSpeed / 100) / (HealthPoint / 100), 0, 1, 0) }):Play()
			else
				HPLeft.Overlay.HealthDrainSpeed.Size = UDim2.new((CurrentDrainSpeed / 100) / (HealthPoint / 100), 0, 1, 0)
			end
		end

		if HealthPoint ~= LastHP or HealthPoint == 0 then
			if coreConfig.OptimizedPerfomance then
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
			if HealthPoint < 50 and not coreConfig.NoFail then
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
			if coreConfig.OptimizedPerfomance then
				HolderFrame.BackgroundTransparency = HolderTrans
			else
				TweenService:Create(HolderFrame, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundTransparency = HolderTrans }):Play()
			end
		end

		LastHP = HealthPoint
		LastHPDrainSpeed = CurrentDrainSpeed
	end)
end)


local ReplayRecordEnabled = true

task.spawn(function()
	StreamingLoop:AddLoop(function() return true end, function() return 0 end, function(t)
		script.Parent.GameplayPause.Event:Wait()
		AdjustIngameSongVolume(0)
		task.wait(0.25)
		TimeUtils.PauseTime()
		local TimeElapsed = TimeUtils.GetTime()
		script.Parent.GameplayResume.Event:Wait()
		AdjustIngameSongVolume(SavedGameSettings.MusicVolume)
		TimeUtils.ResumeTime()
	end)
end)

script.Parent.ProgressBar.Visible = true
task.spawn(function()
	local TimeBreak = 3+BeatmapData[1].Time/1000
	repeat
		TweenService:Create(script.Parent.ProgressBar.Time,TweenInfo.new(0.05,Enum.EasingStyle.Linear),{Size = UDim2.new(-((TimeUtils.GetTime()) - BeatmapData[1].Time/1000)/TimeBreak,0,1,0)}):Play()
		task.wait() 
	until (TimeUtils.GetTime())*1000 >= BeatmapData[1].Time
	script.Parent.ProgressBar.Time.BackgroundColor3 = Color3.new(1,1,1)
	TweenService:Create(script.Parent.ProgressBar.TimeLeft.Time,TweenInfo.new(0.75,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{TextTransparency = 0}):Play()
	--TweenService:Create(script.Parent.ProgressBar.Time,TweenInfo.new((BeatmapData[#BeatmapData].Time-BeatmapData[1].Time)/1000,Enum.EasingStyle.Linear),{Size = UDim2.new(1,0,1,0)}):Play()

	local TotalTime = (BeatmapData[#BeatmapData].Time-BeatmapData[1].Time)/1000
	while TimeUtils.GetTime() < BeatmapData[#BeatmapData].Time/1000 and not ScoreResultDisplay do
		task.wait()
		local FullTimeLeft = BeatmapData[#BeatmapData].Time/1000 - (TimeUtils.GetTime())
		local maxTime = (BeatmapData[#BeatmapData].Time - BeatmapData[1].Time)/1000
		local TimeLeft = math.ceil(FullTimeLeft)

		local Min = TimeLeft/60
		local Sec = math.abs(TimeLeft%60)
		local Min_max = maxTime/60
		local Sec_max = math.abs(maxTime%60)



		local StringOutput = string.format("%d:%.2d", Min, Sec)
		local StringOutput_max = string.format("%d:%.2d", Min_max, Sec_max)
		if TimeUtils.GetTime() > 0 then
			script.Parent.ProgressBar.TimeLeft.Time.Text = StringOutput.."/"..StringOutput_max
		else
			local t = -TimeUtils.GetTime()
			local p_m = t//60
			local p_s = t%60
			local stringOutput_prepare = string.format("-%d:%.2d", p_m, p_s)
			script.Parent.ProgressBar.TimeLeft.Time.Text = stringOutput_prepare.."/"..StringOutput_max
		end


		local SongLoudness = script.Parent.GameSong.AudioAnalyzer.RmsLevel
		local LoudnessMulti = math.clamp(SongLoudness * 1, 0, 1)
		local Progress = 1-(FullTimeLeft/TotalTime)
		Progress += LoudnessMulti/10
		TweenService:Create(script.Parent.ProgressBar.Time,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{Size = UDim2.new(Progress,0,1,0)}):Play()
	end
	TweenService:Create(script.Parent.ProgressBar.TimeLeft.Time,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{TextTransparency = 1}):Play()
end)


if coreConfig.AutoPlay == true and coreConfig.ReplayMode ~= true then
	task.spawn(function()
		repeat task.wait() until (TimeUtils.GetTime())*1000 >= BeatmapData[1].Time-1000
		TweenService:Create(ATVC,TweenInfo.new(0.5,Enum.EasingStyle.Sine),{Position = UDim2.new(0.5,0,0.5,0)}):Play()
	end)
end

local Connection
local Connection2

task.spawn(function()
	task.wait(2)
	if BeatmapData[1].Time > 4000 then
		script.Parent.SkipButton.Visible = true
		TweenService:Create(script.Parent.SkipButton,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,0.8,0),GroupTransparency = 0}):Play()
		if IsTouchDeviceActive() then
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
			TweenService:Create(script.Parent.GameSong.Song,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true),{Volume = 0}):Play()
			task.wait(0.25)
			if not script.Parent.GameSong.Song.IsPlaying then
				script.Parent.GameSong.Song:Play()
			end
			local timeSet = (BeatmapData[1].Time/1000)-2
			print("Set the time to ", timeSet)
			TimeUtils.TimeJump(timeSet)
			TweenService:Create(script.Parent.ProgressBar.Time,TweenInfo.new(2,Enum.EasingStyle.Linear),{Size = UDim2.new(0,0,1,0)}):Play()
			TweenService:Create(script.Parent.SkipButton,TweenInfo.new(0.5,Enum.EasingStyle.Sine		,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,0.8,40),GroupTransparency = 1}):Play()
			task.spawn(function()
				task.wait(0.5)
				script.Parent.SkipButton.Visible = false
			end)
		end
		local SkipRequest = false

		local function Trigger()
			Connection:Disconnect()
			Connection2:Disconnect()
			if not coreConfig.OnMultiplayer then
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
		repeat task.wait() until (TimeUtils.GetTime())*1000 >= BeatmapData[1].Time-3250
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
	return ((TimeUtils.GetTime())*SongSpeed*ReturnData.SongSpeed - script.Parent.GameSong.Song.TimePosition) * 1000
end
LastAudioTimeAdjust = tick()

-- align the song with the time
task.spawn(function()	
	repeat task.wait(0.1) until script.Parent.GameSong.Song.IsReady == true
	StreamingLoop:AddLoop(function() return true end, 0.1, function(t)
		local s,e = pcall(function()
			local checkingSongObj = script.Parent.GameSong.Song
			local ExtraLength = 0
			local Offset = 0.1 -- due to some of roblox audio latency
			if SongSpeed > 1 then
				Offset = 0.1 * SongSpeed
			end
			if ExistSecondSong and ((TimeUtils.GetTime())*SongSpeed*ReturnData.SongSpeed > script.Parent.GameSong.Song.TimeLength) then
				ExtraLength = script.Parent.GameSong.Song.TimeLength
				checkingSongObj = script.Parent.GameSong.Song2
				if script.Parent.GameSong.Song.IsPlaying then
					script.Parent.GameSong.Song:Stop()
					script.Parent.GameSong.Song2:Play()
					-- the first song must stop
				end
			elseif script.Parent.GameSong.Song2.IsPlaying then
				script.Parent.GameSong.Song2:Stop()
			end
			local CurrentGameTime = ((TimeUtils.GetTime())*SongSpeed*ReturnData.SongSpeed)
			local CheckPeriod = 1
			if CurrentGameTime < 1 then
				CheckPeriod = 0.1
			end

			script.Parent.SongOffsetDisplay.Text = string.format("%.1fms", ((checkingSongObj.TimePosition + ExtraLength) - CurrentGameTime)*1000)
			if (tick()-LastAudioTimeAdjust) >= CheckPeriod and CurrentGameTime >= 0 and math.abs((checkingSongObj.TimePosition + ExtraLength) - CurrentGameTime) > 0.05 and script.Parent.GameSong.Song.IsReady == true and (TimeUtils.GetTime()) <= BeatmapData[#BeatmapData].Time/1000 and not BeatmapFailed then
				checkingSongObj.TimePosition = (TimeUtils.GetTime())*SongSpeed*ReturnData.SongSpeed - ExtraLength + Offset
				if coreConfig.StoryboardAvailable then
					storyboardUI.Scripts.Actor:SendMessage("SetTime", (TimeUtils.GetTime()))
				end
				LastAudioTimeAdjust = tick()
			end
			if CurrentGameTime >= 0 and checkingSongObj.IsPlaying == false and (TimeUtils.GetTime()) <= BeatmapData[#BeatmapData].Time/1000 then
				checkingSongObj:Play()
			end
			if coreConfig.CurrentPreviewFrame.OverviewSong.IsPlaying == true and tick()-SongStart >= 0.5 then
				coreConfig.CurrentPreviewFrame.OverviewSong:Stop()
			end

			if coreConfig.CurrentPreviewFrame:FindFirstChild("OverviewSong2") and coreConfig.CurrentPreviewFrame.OverviewSong2.IsPlaying == true and tick()-SongStart >= 0.5 then
				coreConfig.CurrentPreviewFrame.OverviewSong2:Stop()
			end
		end)
		if not s then warn(e) end
		if not isSpectating then
			CurrentSetting.VirtualSettings.PrevMapTime.Value = (TimeUtils.GetTime())*SongSpeed
		end
	end)
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
CursorSize = 0.2 * CursorSize
Cursor.Size = UDim2.fromScale(CursorSize, CursorSize)

CursorTrailSize = 0.2 * CursorTrailSize

CursorTrail.Image = "http://www.roblox.com/asset/?id="..tostring(CursorTrailId)
CursorTrail.Size = UDim2.fromScale(CursorTrailSize, CursorTrailSize)
CursorTrail.ImageTransparency = CursorTrailTransparency

local RblxNewCursor = PlayerGui.OsuCursor.Cursor
--local CursorUnlocked = false -- this will change to true at the end of the play

if coreConfig.AutoPlay or isSpectating then
	local restartframeposvalue = Instance.new("BoolValue",script.Parent.ScriptSettings)
	restartframeposvalue.Name = "RestartGameRightSite"
	restartframeposvalue.Value = false
end

if coreConfig.AutoPlay == false and coreConfig.ReplayMode ~= true and isSpectating == false then
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

	if UserInputService.TouchEnabled and coreConfig.EnableTouchDevice == true then
		script.Parent.RestartGame.Text = "Menu (Hold)"
		if coreConfig.HitZoneEnabled then
			TweenService:Create(script.Parent.MobileHit,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(HitZoneArea,0,1,0)}):Play()
			if coreConfig.MobileModeRightHitZone == true then
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
		end)
	else
		local restartframeposvalue = Instance.new("BoolValue",script.Parent.ScriptSettings)
		restartframeposvalue.Name = "RestartGameRightSite"
		restartframeposvalue.Value = false
	end
	if not (UserInputService.TouchEnabled and coreConfig.EnableTouchDevice == true) then
		if coreConfig.OldCursorMovement == true then
			--UserInputService.MouseIconEnabled = false
			RblxNewCursor.Visible = false
			PlayerMouse.Move:Connect(function()
				if not PlayerGui.Parent or not PlayerGui:FindFirstChild("PlayScreen") then
					return
				end
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
			task.spawn(function()
				task.wait(0.5)
				TweenService:Create(script.Parent.VirtualMouseReminder,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{TextTransparency = 0.5}):Play()
				task.wait(2.5)
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

			task.spawn(function()
				StreamingLoop:AddLoop(function() return true end, function() return 0 end, function(t)
					if UserInputService.MouseBehavior == Enum.MouseBehavior.Default and ShiftEnabled == false and CursorUnlocked == false then
						UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
					end
				end)
			end)


			local prevtick = tick()
			local GamepadDelta = Vector2.new(0,0)
			task.spawn(function()
				while ScoreResultDisplay == false and task.wait() do
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

					local mouseDelta = UserInputService:GetMouseDelta()

					local MouseMovement = mouseDelta/AbsoluteSize*CursorSensitivity
					--local MouseMovement = Vector2.new(InputData.Delta.X/AbsoluteSize.X,InputData.Delta.Y/AbsoluteSize.Y)*CursorSensitivity
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

	local limit = 0.0667	-- 15 clicks per sec on 1 btn
	local lastMouseHit = {
		M1 = 0, M2 = 0
	}

	task.spawn(function()
		UserInputService.InputBegan:Connect(function(data)
			if data.KeyCode == Key1Input and not IsTouchDeviceActive() then
				MouseHitEvent:Fire(SecurityKey,1)
			elseif data.KeyCode == Key2Input and not (IsTouchDeviceActive()) then
				MouseHitEvent:Fire(SecurityKey,2)
			elseif data.UserInputType == Enum.UserInputType.MouseButton1 and coreConfig.MouseButtonEnabled == true and not (IsTouchDeviceActive()) then
				if os.clock() - lastMouseHit.M1 >= limit then
					MouseHitEvent:Fire(SecurityKey,3)
					lastMouseHit.M1 = os.clock()
				end
			elseif data.UserInputType == Enum.UserInputType.MouseButton2 and coreConfig.MouseButtonEnabled == true and not (IsTouchDeviceActive()) then
				if os.clock() - lastMouseHit.M2 >= limit then
					MouseHitEvent:Fire(SecurityKey,4)
					lastMouseHit.M1 = os.clock()
				end
			end
		end)
	end)

	task.spawn(function()
		UserInputService.InputEnded:Connect(function(data)
			if data.KeyCode == Key1Input then
				MouseHitEndEvent:Fire(SecurityKey,1)
			elseif data.KeyCode == Key2Input then
				MouseHitEndEvent:Fire(SecurityKey,2)
			elseif data.UserInputType == Enum.UserInputType.MouseButton1 and coreConfig.MouseButtonEnabled == true then
				MouseHitEndEvent:Fire(SecurityKey,3)
			elseif data.UserInputType == Enum.UserInputType.MouseButton2 and coreConfig.MouseButtonEnabled == true then
				MouseHitEndEvent:Fire(SecurityKey,4)
			end
		end)

	end)

	local function ScanforNearbyObj(Pos)
		if not DisplayingHitnote or not CircleSize then return end
		local ExactCircleSize = CircleSize/384*workspace.CurrentCamera.ViewportSize.Y
		local CursorPos = Vector2.new(Pos.X,Pos.Y)

		for _,data in pairs(DisplayingHitnote) do
			local CirclePos = Vector2.new(data.X,data.Y)/Vector2.new(512,384)*script.Parent.PlayFrame.AbsoluteSize+script.Parent.PlayFrame.AbsolutePosition

			if (CirclePos-CursorPos).Magnitude <= ExactCircleSize/2 then return true end
		end

		return false
	end

	local HitzoneBlocked = false

	task.spawn(function()
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


			if InHitzone and ScanforNearbyObj(TouchPosition) then
				HitzoneBlocked = true
			else
				HitzoneBlocked = false
			end

			MouseHitEvent:Fire(SecurityKey,3)
		end)

		UserInputService.TouchEnded:Connect(function(data)
			local TouchPosition = data.Position
			local InHitzone = isInHitzone(TouchPosition)
			if InHitzone and not ScanforNearbyObj(TouchPosition) then return end
			isTouchOutsiteHitzone = false
			MouseHitEndEvent:Fire(SecurityKey,3)
		end)
		script.Parent.MobileHit.MouseButton1Down:Connect(function()
			if HitzoneBlocked then return end
			MobileHold = true
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

task.spawn(function()
	local LastTick = tick()
	local count = 0
	StreamingLoop:AddLoop(function() return true end, function() return 0 end, function(t)
		if coreConfig.OptimizedPerfomance then
			count += 1
			if count < 2 then
				return "continue" -- on OptmimizedPerfomance, it only update 1 per 3 frame
			end
			count = 0
		end
		local Passed = tick() - LastTick
		LastTick = tick()

		ParallelProcessingFolder.Core_OsuGame_KeyHistoryUpdate:SendMessage("Process",{
			KeyHistory = KeyHistory,
			Passed = Passed
		})

		--[[for _, obj in pairs(KeyHistory:GetDescendants()) do
			if obj.Name == "Released" then
				obj.Position -= UDim2.new(Passed, 0, 0, 0)
				if obj.Position.X.Scale < -0.2 then
					obj:Destroy()
				end
			elseif obj.Name == "Current" then
				obj.Size += UDim2.new(Passed, 0, 0, 0)
			end
		end]]
	end)
end)

function clearOldCurrentHistory(Crr)
	for _, obj in pairs(Crr:GetChildren()) do
		if obj.Name == "Current" then
			obj.Name = "Released"
		end
	end
end

task.spawn(function()
	local KeyTweenInfo = TweenInfo.new(0.1,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
	local ChangeIn1 = {--[[Size = UDim2.new(0.18,0,0.18,0),]]BackgroundColor3 = Color3.new(1, 1, 0.72549),BackgroundTransparency = 0}
	-- local ChangeIn2 = {--[[Size = UDim2.new(0.18,0,0.18,0),]]BackgroundColor3 = Color3.new(0.862745, 1, 1),BackgroundTransparency = 0}
	local ChangeOut = {--[[Size = UDim2.new(0.2,0,0.2,0),]]BackgroundColor3 = Color3.new(0,0,0),BackgroundTransparency = 0.5}

	MouseHitEvent.Event:Connect(function(CurrentSecurityKey,data)
		if KeyHistoryOverlayEnabled and coreConfig.HitKeyOverlay then
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
		end

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



--task.wait(2)
--CircleSize = 54.4 - 4.48 * CS
--3

--print((54.4 - 4.48 *3)/768*2)

--1.25
-- osu play size: 512x384


local CircleApproachTime = 1200

if ApproachRate < 5 then
	CircleApproachTime = 1200 + 600 * (5 - ApproachRate) / 5
elseif ApproachRate > 5 then
	CircleApproachTime = 1200 - 750 * (ApproachRate - 5) / 5
else
	CircleApproachTime = 1200
end

local ZIndex = 999999999
-- The default hit windows for Keyboard + Mouse/Tablet users
local hit300 = (100 - 8 * OverallDifficulty) / SongSpeed -- 100 - 20
local hit100 = (175 - 10 * OverallDifficulty) / SongSpeed -- 175 - 75
local hit50  = (250 - 12.5 * OverallDifficulty) / SongSpeed -- 200 - 125
local EarlyMiss = 425 / SongSpeed

local HitErrorMulti = 1.5

if coreConfig.ReplayMode or coreConfig.AutoPlay then
	coreConfig.EnableTouchDevice = false
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

if (IsTouchDeviceActive()) or coreConfig.TouchDeviceDetected or coreConfig.Replay_TouchDevice then
	-- Adjust hit window for TD
	hit300 = (150 - 12 * OverallDifficulty) / SongSpeed -- 150 - 30
	hit100 = (220 - 12.5 * OverallDifficulty) / SongSpeed -- 220 - 95
	hit50  = (275 - 13.5 * OverallDifficulty) / SongSpeed -- 275 - 140
	EarlyMiss = 440 / SongSpeed
	HitErrorMulti = 1
	coreConfig.TouchDeviceDetected = true
end


EarlyMiss = math.min(EarlyMiss, CircleApproachTime)

if CircleApproachTime < hit50 then
	local MissTiming = math.max(0,hit50 - CircleApproachTime)
	script.Parent.HitError.MissArea.Size = UDim2.new(MissTiming/(hit50*2),0,0.25,0)
end

script.Parent.HitError.Size = UDim2.new(0,hit50*(19/16)*HitErrorMulti,0,25)
script.Parent.HitError.HitErrorDisplay._300s.Size = UDim2.new(hit300/hit50,0,0.25,0)
script.Parent.HitError.HitErrorDisplay._100s.Size = UDim2.new(hit100/hit50,0,0.25,0)
EstimatedCombo = 0

AccuracyData = {
	h300 = 0,h100 = 0,h50 = 0,miss = 0, Combo = 0, MaxCombo = 0, MaxPeromanceCombo = 0, PerfomanceCombo = 0, h300Bonus = 0, bonustotal = 0,
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
	local Consistency = math.pow(AccuracyData.BaseConsistency/math.max(1,AccuracyData.MaxConsistency), 0.5) * 100
	Consistency = math.max(Consistency, math.lerp(AccuracyData.MaxCombo/math.max(EstimatedCombo or 1, 1), 1, 1/(AccuracyData.miss+1)) * 100)
	Consistency = math.max(Consistency, AccuracyData.MaxCombo/math.max(EstimatedCombo or 1, 1) * 100)
	return Consistency
end

task.spawn(function()
	StreamingLoop:AddLoop(function() return true end, function() return 0 end, function(t)
		local Consistency = getConsistency()
		script.Parent.ConsistencyDisplay.Text = string.format("Consistency: %.2f%%", Consistency)
	end)
end)
--script.Parent.ConsistencyDisplay.Visible = true



local AccTemplate = cloneTable(AccuracyData)
for i = 1,50 do
	local HitErrorGraph = AccuracyData.HitErrorGraph
	if i == 1 then
		HitErrorGraph[#HitErrorGraph+1] = {-1,1,0,0}
	else
		HitErrorGraph[#HitErrorGraph+1] = {i*2-1,(i+1)*2-1,0,i-1}
		HitErrorGraph[#HitErrorGraph+1] = {-(i+1)*2+1,-i*2+1,0,-i+1}
	end
end


CircleSize = (54.4 - 4.48 * CS)*2

if coreConfig.TouchDeviceDetected or ((coreConfig.ReplayMode and coreConfig.Replay_TouchDevice) or (coreConfig.AutoPlay == false and coreConfig.ReplayMode ~= true and isSpectating == false and UserInputService.TouchEnabled and coreConfig.EnableTouchDevice == true)) then
	-- Increase the cursor size for TD
	CircleSize *= 1.1875
end
local DisplayCombo = 0
local LastCombo = 0
local LastComboCapture = Instance.new("Frame")
local _currentfadecomboid = ""
local ComboVisibleState = false
local ComboFrameExpandRate = 0

task.spawn(function()
	local lasttick = tick()
	StreamingLoop:AddLoop(function() return true end, function() return 0 end, function(t)
		local TimePassed = tick() - lasttick
		ComboFrameExpandRate -= TimePassed / 0.2
		ComboFrameExpandRate = math.clamp(ComboFrameExpandRate,0,1.2)
		local BaseSize = 0.075 + ComboFrameExpandRate * 0.025
		TweenService:Create(script.Parent.ComboFrameDisplay.ComboFrameDisplay,TweenInfo.new(0.05/SongSpeed,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(BaseSize,0,BaseSize,0)}):Play()
		lasttick = tick()
	end)
end)
script.Parent.ComboDisplay:GetPropertyChangedSignal("Text"):Connect(function()
	if coreConfig.OptimizedPerfomance then return end
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
		task.spawn(function()
			task.wait(0.05)
			if _currentfadecomboid ~= id then return end
			TweenService:Create(script.Parent.ComboFrameDisplay.ComboFrameDisplay,TweenInfo.new(0.1/SongSpeed,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(0.075,0,0.075,0)}):Play()
		end)]]
		script.Parent.ComboFade.ComboFade:ClearAllChildren()
		if coreConfig.OldInterface == true then
			TweenService:Create(script.Parent.ComboDisplay,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextSize = 60}):Play()
			task.spawn(function()
				task.wait(0.05)
				TweenService:Create(script.Parent.ComboDisplay,TweenInfo.new(0.1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextSize = 50}):Play()
			end)
			task.spawn(function()
				local NewFadeCombo = script.ComboFade:Clone()
				NewFadeCombo.Parent = script.Parent.ComboFade.ComboFade
				NewFadeCombo.Text = tostring(NewCombo).."x"
				NewFadeCombo.TextSize = script.Parent.ComboDisplay.TextSize
				NewFadeCombo.TextTransparency = 0.25

				TweenService:Create(NewFadeCombo,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextSize = script.Parent.ComboDisplay.TextSize*1.5,TextTransparency = 1}):Play()
				task.wait(0.5)
				NewFadeCombo:Destroy()
			end)
		end

		LastComboCapture:Destroy()
		LastComboCapture = script.Parent.ComboFrameDisplay.ComboFrameDisplay:Clone()
		local NewFadeCombo = script.Parent.ComboFrameDisplay.ComboFrameDisplay:Clone()
		NewFadeCombo.Parent = script.Parent.ComboFade.ComboFade
		NewFadeCombo.Visible = coreConfig.OverallInterfaceEnabled and not coreConfig.OldInterface

		TweenService:Create(NewFadeCombo,TweenInfo.new(0.5/SongSpeed,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(NewFadeCombo.Size.Y.Scale*1.5,0,NewFadeCombo.Size.Y.Scale*1.5,0)}):Play()
		for _,obj in pairs(NewFadeCombo:GetChildren()) do
			if obj:IsA("ImageLabel") then
				TweenService:Create(obj,TweenInfo.new(0.5/SongSpeed,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()
			end
		end
		task.wait(0.5)
		NewFadeCombo:Destroy()
	elseif NewCombo == 0 and LastCombo >= 20 then
		local _brokenCombo = LastComboCapture:Clone()
		-- todo: make a combobreak animation
	end
	DisplayCombo = NewCombo
end)

local DisplayAccuracy = 10000
local CurrentAccuracy = 10000

local LastComboDisplay = 0

task.spawn(function() --Accurancy caculation
	repeat task.wait() until TimeUtils.GetTime() >= 0

	local WaitTime = 0
	if coreConfig.OptimizedPerfomance then
		WaitTime = 0.1
	end
	StreamingLoop:AddLoop(function() return true end, function() return 0 end, function(t)
		if coreConfig.OptimizedPerfomance and WaitTime == 0 then
			WaitTime = 0.1
		elseif not coreConfig.OptimizedPerfomance and WaitTime == 0.1 then
			WaitTime = 0
		end
		local h300 = AccuracyData.h300
		local h100 = AccuracyData.h100
		local h50 = AccuracyData.h50
		local miss = AccuracyData.miss
		local Total = h300+h100+h50+miss
		local Acc = math.floor(((h300*300+h100*100+h50*50)/(Total*300))*10000)/100

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
	end)
end)

TweenService:Create(script.Parent.GameplayData.Accuracy,TweenInfo.new(2.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Value = 10000}):Play()

task.spawn(function()
	local WaitTime = 0
	if coreConfig.OptimizedPerfomance then
		WaitTime = 0.25
	end

	StreamingLoop:AddLoop(function() return true end, function() return WaitTime end, function(t)
		if coreConfig.OptimizedPerfomance and WaitTime == 0 then
			WaitTime = 0.25
		elseif not coreConfig.OptimizedPerfomance and WaitTime == 0.25 then
			WaitTime = 0
		end
		if DisplayAccuracy ~= CurrentAccuracy then
			CurrentAccuracy = DisplayAccuracy
			TweenService:Create(script.Parent.GameplayData.Accuracy,TweenInfo.new(0.1/SongSpeed,Enum.EasingStyle.Linear),{Value = DisplayAccuracy}):Play()
		end
	end)
end)

local PrevAcc = 100
AccFrameLastUpdate = 0

script.Parent.GameplayData.Accuracy:GetPropertyChangedSignal("Value"):Connect(function()
	if coreConfig.OptimizedPerfomance and (tick() - AccFrameLastUpdate < 0.04) then return end
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
	Mod = 1,
	ModV2 = 1
}

script.Parent.MultiplayerData.GetInGameData.OnInvoke = function()
	return {Score = Score,Combo = AccuracyData.Combo}
end

-- SpeedReduce mod:  Speed ^ 0.28
-- SpeedIncrease mod: Speed ^ 4.185

local SpeedMulti = 1
local SpeedMultiV2 = 1
if SongSpeed < 1 then
	SpeedMulti = SongSpeed^4.185
	SpeedMultiV2 = 0.1 + ((SongSpeed - 0.5)/0.5)*0.4
elseif SongSpeed > 1 then
	SpeedMulti = SongSpeed^0.28
	SpeedMultiV2 = 1 + (SongSpeed - 1) * 0.2
end
ScoreMultiplier.Mod *= SpeedMulti
ScoreMultiplier.ModV2 *= SpeedMultiV2

if coreConfig.NoFail == true then
	ScoreMultiplier.Mod *= 0.5
	ScoreMultiplier.ModV2 *= 0.5
end

if coreConfig.HiddenMod == true then
	ScoreMultiplier.Mod *= 1.06
	ScoreMultiplier.ModV2 *= 1.06
end

if coreConfig.HardRock == true then
	ScoreMultiplier.Mod *= 1.06
	ScoreMultiplier.ModV2 *= 1.06
end

if coreConfig.EasyMod == true then
	ScoreMultiplier.Mod *= 0.5
	ScoreMultiplier.ModV2 *= 0.5
end

local ScoreDisplay = script.Parent.ScoreFrameDisplay

function getAccuracyScore()
	-- For SL mod (or will be NM soon), I will add an extra score to catch up the scale to be same with the ConsistencyScore
	local Accuracy = (AccuracyData.h300*300+AccuracyData.h100*100+AccuracyData.h50*50)/((AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss)*300)
	-- When the total possible combo (maximum current combo player can get) more than total note of the game
	-- Accuracy score will rise up even more
	local ExtraCombo = EstimatedCombo-#BeatmapData
	-- penalty for each miss given
	-- prevent players just "chilling out" and watching the score keep increasing
	local ExtraAccPoint = math.max(0, ExtraCombo * Accuracy - AccuracyData.miss)

	return math.pow(ExtraAccPoint + (AccuracyData.h300*300+AccuracyData.h100*100+AccuracyData.h50*50)/300,2.265) * ScoreMultiplier.Difficulty * 0.3
end

function getConsistencyScore()
	return math.pow(AccuracyData.BaseConsistency, 1.1704417) * 1.2255 * ScoreMultiplier.Difficulty * 0.7
end

function getScoreMissPenaltyMultiplier(missCount, noteCount)
	-- miss penalty can take up to 25% of the current score
	local penaltyMax = 0.25	
	local penalty = math.min((1 - penaltyMax) + penaltyMax / ((missCount / (4 * math.pow(math.log(noteCount), 0.94))) + 1), (noteCount - missCount)/math.max(1, noteCount))
	return penalty
end

function getScoreV1()
	local totalNotes = AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss
	local missPenalty = getScoreMissPenaltyMultiplier(AccuracyData.miss, totalNotes)
	local AccuracyScore = getAccuracyScore() * missPenalty
	local ConsistencyScore = getConsistencyScore() * missPenalty
	-- Spinner score provide fixed value
	local ScoreV1 = ConsistencyScore+AccuracyScore+AccuracyData.SpinnerScore
	return math.round(ScoreV1 * ScoreMultiplier.Mod)
end

function getScoreV2()
	local totalNotes = AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss
	local missPenalty = getScoreMissPenaltyMultiplier(AccuracyData.miss, totalNotes)
	local ActualAccScore = getAccuracyScore()
	local ActualConsistencyScore = getConsistencyScore()
	local maxAccScore, maxConsistencyScore = ReturnData.Difficulty.MaxScoreV1.AccuracyScore, ReturnData.Difficulty.MaxScoreV1.ConsistencyScore

	local MaxPossibleScore = require(ScriptComponent.Gameplay.GetMaxScore)(#BeatmapData, ReturnData.Difficulty.MaxCombo) --AccScoreMax + ConsistencyScoreMax
	local ActualScore = ActualAccScore + ActualConsistencyScore

	local exRate = 0.44150110375

	local accScore = math.pow(ActualAccScore/maxAccScore, exRate) * 300000 * missPenalty
	local consistencyScore = math.pow(ActualConsistencyScore/maxConsistencyScore, exRate) * 700000 * missPenalty

	-- Spinner score only gives 10% points in ScoreV2
	local ScoreV2 = accScore + consistencyScore + AccuracyData.SpinnerScore * 0.1
	--local ScoreV2 = math.pow(ActualScore/MaxPossibleScore,exRate) * 1000000 * ScoreMultiplier.Mod * missPenalty

	return math.round(ScoreV2 * ScoreMultiplier.ModV2)
end

task.spawn(function()
	local PrevScore = 0
	local PrevScoreV2 = 1
	local PrevMaxCombo = 0
	local PrevCombo = 0
	local WaitTime = 0
	local PrevHealth = HealthPoint




	if coreConfig.OptimizedPerfomance then
		WaitTime = 0.5
	end
	StreamingLoop:AddLoop(function() return true end, function() return WaitTime end, function()
		if coreConfig.OptimizedPerfomance and WaitTime == 0 then
			WaitTime = 0.5
		elseif not coreConfig.OptimizedPerfomance and WaitTime == 0.5 then
			WaitTime = 0
		end

		local Score = getScoreV1()
		if Score ~= PrevScore or PrevMaxCombo ~= AccuracyData.MaxCombo then

			--if ScoreV2Enabled then
			--script.Parent.Leaderboard.ScoreV2MaxScore.Value = TotalScoreEstimated
			--end
			script.Parent.ScoreUpdate:Fire(Score,AccuracyData.MaxCombo,CurrentPerfomance)
		end

		task.spawn(function()
			if Score ~= PrevScore or PrevCombo ~= AccuracyData.Combo or PrevHealth ~= HealthPoint or (coreConfig.ScoreV2Enabled and Score/TotalScoreEstimated~=PrevScoreV2) then
				if coreConfig.ScoreV2Enabled then
					--local ScoreV2AccScore = math.pow((AccuracyData.h300*300+AccuracyData.h100*300+AccuracyData.h50*300+AccuracyData.miss*300)/300,2.265) * ScoreMultiplier.Difficulty * ScoreMultiplier.Mod * 0.3
					--local ScoreV2 = math.pow(Score/(TotalScoreEstimated*0.8 + ScoreV2AccScore)*(NoteCompleted/NoteTotal),0.768621)*(NoteCompleted/NoteTotal)*1000000
					local ScoreV2 = getScoreV2()
					script.Parent.MultiplayerLeaderboard.LocalScoreUpdate:Fire({Score = math.round(ScoreV2),Combo = AccuracyData.Combo,Failed = coreConfig.MultiplayerMatchFailed,HealthPercentage = HealthPoint/MaxHealthPoint},CurrentPerfomance)
				else
					script.Parent.MultiplayerLeaderboard.LocalScoreUpdate:Fire({Score = Score,Combo = AccuracyData.Combo,Failed = coreConfig.MultiplayerMatchFailed,HealthPercentage = HealthPoint/MaxHealthPoint},CurrentPerfomance)
				end
			end
		end)
		PrevScore = Score
		PrevScoreV2 = Score/TotalScoreEstimated
		PrevMaxCombo = AccuracyData.MaxCombo
		PrevCombo = AccuracyData.Combo
		PrevHealth = HealthPoint
	end)
end)

task.spawn(function()
	local ScoreVisibleData = {
		[-1] = 0
	}
	local CurrentTotalScore = TotalScoreEstimated

	local WaitTime = 0
	local TweenTimeMultiplier = 1
	if coreConfig.OptimizedPerfomance then
		WaitTime = 0.04
		TweenTimeMultiplier = 0
	end
	StreamingLoop:AddLoop(function() return true end, function() return WaitTime end, function()
		if coreConfig.OptimizedPerfomance and WaitTime == 0 then
			WaitTime = 0.04
			TweenTimeMultiplier = 0
		elseif not coreConfig.OptimizedPerfomance and WaitTime == 0.04 then
			WaitTime = 0
			TweenTimeMultiplier = 1
		end

		ParallelProcessingFolder.Core_OsuGame_ScoreProcessing:SendMessage("Process", {
			Score = coreConfig.ScoreV2Enabled and getScoreV2() or getScoreV1(),
			script = script,
			ScoreV2Enabled = coreConfig.ScoreV2Enabled,
			CurrentTotalScore = CurrentTotalScore,
			TotalScoreEstimated = TotalScoreEstimated,
			AccuracyData = AccuracyData,
			EstimatedCombo = EstimatedCombo,
			NoteCount = #BeatmapData,
			ScoreMultiplier = ScoreMultiplier,
			TweenTimeMultiplier = TweenTimeMultiplier,
			SongSpeed = SongSpeed,
			ScoreDisplay = ScoreDisplay,
			ScoreVisibleData = ScoreVisibleData, 
			ScriptComponent = ScriptComponent,
			ReturnData = ReturnData
		})

		--[[if Score ~= CurrentScore or (ScoreV2Enabled and CurrentTotalScore~=TotalScoreEstimated) then
			local AccuracyScore = getAccuracyScore()
			local ConsistencyScore = getConsistencyScore()

			local Score = getScoreV1() -- overwrite the current score
			local DisplayScore = Score
			CurrentScore = Score
			if ScoreV2Enabled then
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
			
			for i, char in ipairs(TextScore:split("")) do
				local Displayer = ScoreDisplay["Num_"..tostring((#TextScore+1)-i)]
				Displayer.Visible = true
				
				for _,a in pairs(Displayer:GetChildren()) do
					if a.Name == "Score"..char then
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
		PrevScore = script.Parent.GameplayData.Score.Value]]
	end)
end)

-- Flashlight mod

local FlashlightFrame = script.Parent.PlayFrame.Flashlight
FlashlightFrame.Visible = coreConfig.Flashlight
FlashlightFrame.ImageTransparency = 1
gameEnded = false

task.spawn(function()
	StreamingLoop:AddLoop(function() return true end, 0.1, function()
		if (FlashlightFrame.Visible == false or FlashlightFrame.Parent == nil) and coreConfig.Flashlight == true and gameEnded == false and not BeatmapFailed then
			warn("[Client] An error occured, please rejoin to fix this issue")
			require(PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("An error occured, please rejoin to fix this issue.",Color3.new(1, 0, 0))
			script.Disabled = true
		end
	end)
end)

-- Original size: {30,0,30,0}
-- In-game size = {8,0,8,0}
-- 300+ Combo Size = {5,0,5,0}
FLAnimate = true

if coreConfig.Flashlight == true then
	TweenService:Create(FlashlightFrame,TweenInfo.new(1,Enum.EasingStyle.Linear),{Size = UDim2.new(15,0,15,0),ImageTransparency = 0}):Play()
	ScoreMultiplier.Mod *= 1.12
	ScoreMultiplier.ModV2 *= 1.12
	script.Parent.PlayFrame.ZIndex = 0
	task.spawn(function()
		task.wait(2.5)
		TweenService:Create(FlashlightFrame,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = UDim2.new(7,0,7,0),ImageTransparency = 0}):Play()

		local CurrentCombo = 0
		StreamingLoop:AddLoop(function() return true end, 0.1, function()
			if not FLAnimate then return "break" end
			if CurrentCombo ~= AccuracyData.Combo then
				CurrentCombo = AccuracyData.Combo
				local FLSize = (CurrentCombo <= 200 and 7-((CurrentCombo/200)*3)) or 4

				script.Parent.GameplayData.FLSize.Value = ((coreConfig.HiddenMod and -1) or 1) * FLSize
				TweenService:Create(FlashlightFrame,TweenInfo.new(1,Enum.EasingStyle.Linear),{Size = UDim2.new(FLSize,0,FLSize,0)}):Play()
			end
		end)
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
	repeat task.wait() until PlayerGui.MenuInterface.PlayerListFrame.PlayerList.GetUserStatus:Invoke(UserId,true) == 1 or tick() - SearchStartTime > 10 -- Player need to be out, but there would be some delay
	task.wait(0.5)
	repeat task.wait() until PlayerGui.MenuInterface.PlayerListFrame.PlayerList.GetUserStatus:Invoke(UserId,true) == 2
	while task.wait(0.1) do
		script.Parent.RestartGame.SpectateReturn:Fire(UserId)
	end
end

if isSpectating == true then
	task.spawn(function()
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
		local yieldingSpectateAction
		local queue = {}

		local function QueueSpectateEvent(Data,isSystemCreated)
			if Data == -1 then
				require(PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)("Player you spectate has left, waiting for player to start another play...",Color3.new(1,0,0))
				FindForSpectateSignal()
				return
			end
			queue[#queue+1] = Data
			table.sort(queue, function(a,b)
				return a.TimeProcess < b.TimeProcess
			end)
		end

		SpectateRemote.OnClientEvent:Connect(QueueSpectateEvent)

		-- we will keep reading from the queue list
		-- read from the first, remove that data until there's no queue

		task.spawn(function()
			SpecStartTickChange = tick()
			while true do
				local Data = queue[1]
				if not Data then
					task.wait()
					continue
				end
				table.remove(queue,1)
				-- read the first queue data
				local TimeProcess = Data.TimeProcess
				local CurrentSpecTime = Data.SpecTime
				local HostTime = Data.HostTime
				local HostFPS = Data.HostFPS

				if tick() - SpecStartTickChange > 5 or SpecStartTickChange == 0 then
					local HostStartTick = tick() - CurrentSpecTime

					local HostLatency = (workspace.ServerStatus.ServerTick.Value - HostTime)
					print(HostLatency)
					if HostLatency > SpectateDelay/1000 + 0.5 or HostLatency < SpectateDelay/1000 then -- more than 500ms then update
						if HostLatency < SpectateDelay/1000 then
							repeat task.wait() until (workspace.ServerStatus.ServerTick.Value - HostTime) >= SpectateDelay/1000
						end
						StartTick = HostStartTick
					end
				end
				if SpecStartTickChange ~= 0 then
					if tick() - StartTick < CurrentSpecTime and SpectateDelay > 0 then
						repeat task.wait() until tick() - StartTick >= CurrentSpecTime or SpectateDelay <= 0
					end
				end

				script.Parent.PSEarned.AnimatedPSEarned.PerformanceValue.Value = Data.InGameData.Perfomance

				--script.Parent.PSEarned.Text = tostring(math.floor(Data.InGameData.Perfomance)).."ps"
				CurrentPerfomance = Data.InGameData.Perfomance
				HighestPerfomance = Data.InGameData.HighestPerfomance

				local ServerTick = workspace.ServerStatus.ServerTick.Value
				local HostDelay = math.floor((ServerTick - HostTime)*1000)

				SpecDelayFrame.HostDelay.Text = tostring(HostDelay).."ms"
				SpecDelayFrame.HostFPS.Text = tostring(HostFPS).." FPS"

				TimeUtils.TimeJump(TimeProcess)
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
				keycount.K1 = InGameData.KeyData[1]-1
				keycount.K2 = InGameData.KeyData[2]-1
				keycount.K3 = InGameData.KeyData[3]-1
				keycount.K4 = InGameData.KeyData[4]-1
				HealthPoint = InGameData.HP
				if InGameData.Failed == true then
					GameOver()
				end
			end
		end)
	end
end
if isSpectating == false and (coreConfig.AutoPlay == false or (LocalPlayer.UserId == 1241445502 and game.PlaceId ~= 6983932919)) then
	--[[
	PlayingRemote.OnClientEvent:Connect(function(Name)
		if typeof(Name) == "String" then
			require(PlayerGui:WaitForChild("NotificationPopup").NotificationsPopup.CreateNotification)(Name.." is spectating you",Color3.new(0, 1, 0))
		end
	end)]]
end

function PostPlayingDataSignal(data)
	PlayingRemote:FireServer({
		StartTime = Start,
		ScoreResult = ScoreResultDisplay,
		TimeProcess = TimeUtils.GetTime(),
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
			KeyData = {keycount.K1,keycount.K2,keycount.M1,keycount.M2},
			Perfomance = CurrentPerfomance,
			HighestPerfomance = HighestPerfomance
		},
		Changes = {
			CursorPos = CursorPosition,
			KeyHit = data
		}
	})
end


MouseHitEvent.Event:Connect(function(CurrentSecurityKey,data)
	if isActivelyPlaying() then
		if #game.Players:GetPlayers() > 1 and not gameEnded then
			PostPlayingDataSignal(data)
		end
	end
end)

MouseHitEndEvent.Event:Connect(function(CurrentSecurityKey,data)
	if isActivelyPlaying() then
		if #game.Players:GetPlayers() > 1 and not gameEnded then
			PostPlayingDataSignal(data)
		end
	end
end)

task.spawn(function()
	if isActivelyPlaying() and onTutorial ~= true then
		local MetaData = ReturnData.Overview.Metadata
		game.ReplicatedStorage.Gameplay.UpdateStatus:FireServer(2,{BeatmapPlaying = MetaData.SongCreator.." - "..MetaData.MapName.." ["..MetaData.DifficultyName.."]"})
		StreamingLoop:AddLoop(function() return true end, 1/60, function() -- record cursor movement at most 60FPS
			if #game.Players:GetPlayers() > 1 then -- for better perfomance, data should only send when there's more than 1 player in the server.
				if gameEnded then
					task.wait(1)
				end
				task.spawn(function()
					PostPlayingDataSignal()
				end)
			end
		end)
	elseif onTutorial == true then
		game.ReplicatedStorage.Gameplay.UpdateStatus:FireServer(5)
	elseif coreConfig.AutoPlay == true and isSpectating == false then
		game.ReplicatedStorage.Gameplay.UpdateStatus:FireServer(4)
	end
end)

-- 1 - 1680 | 10 - 450


--CircleApproachTime = 10000

PlayerGui.MenuInterface.DropdownMenu.MenuListAnimate.hiddenRequest:Fire(true)

script.Parent.GameSong.Song.PlaybackSpeed = SongSpeed * ReturnData.SongSpeed
script.Parent.GameSong.Song.DefaultPitch.Pitch = ReturnData.SongPitch

script.Parent.GameSong.Song2.PlaybackSpeed = SongSpeed * ReturnData.SongSpeed
script.Parent.GameSong.Song2.DefaultPitch.Pitch = ReturnData.SongPitch
if SongSpeed >= 0.5 and SongSpeed <= 2 then
	if not coreConfig.KeepOriginalPitch then
		script.Parent.GameSong.Song.DefaultPitch.Pitch = ReturnData.SongPitch/SongSpeed
		script.Parent.GameSong.Song2.DefaultPitch.Pitch = ReturnData.SongPitch/SongSpeed		
	end

	ToggleDirectChange("EnableSpeedPitch", function(isEnable)
		local pitch = 1
		if not isEnable then
			pitch = 1 / SongSpeed
		end
		script.Parent.GameSong.Song.DefaultPitch.Pitch = ReturnData.SongPitch * pitch
		script.Parent.GameSong.Song2.DefaultPitch.Pitch = ReturnData.SongPitch * pitch		
	end)
end


local NPS = 0
local Combo = 0



local CurrentComboColor = 1

--BPM = 1 / BeatLength * 1000 * 60
local CurrentHitnote = 1


--Autoplay only
local CurrentCursorPos = 1
local LastClick = 0
local RightClick = true

local KeySession = {
	K1 = "", K2 = ""
}


function AutoClick()
	task.spawn(function()
		if tick() - LastClick > 0.15 then
			RightClick = false
			LastClick = tick()
			MouseHitEvent:Fire(SecurityKey,3)
			local CurrentSession = HttpService:GenerateGUID()
			KeySession.K1 = CurrentSession
			task.wait(0.05)
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
				task.wait(0.05)
				if KeySession.K1 == CurrentSession then
					MouseHitEndEvent:Fire(SecurityKey,3)
				end
			else
				RightClick = true
				LastClick = tick()
				local CurrentSession = HttpService:GenerateGUID()
				KeySession.K2 = CurrentSession
				MouseHitEvent:Fire(SecurityKey,4)
				task.wait(0.05)
				if KeySession.K2 == CurrentSession then
					MouseHitEndEvent:Fire(SecurityKey,4)
				end
			end
		end
	end)
end

local BreakTimeFrame = script.Parent.BreakTimeFrame

task.spawn(function()
	if isSpectating then
		repeat task.wait() until SpectateGotFirstData
	end
	local Section = ""
	for _,BreakTime in pairs(ReturnData.BreakTime) do
		repeat task.wait() until TimeUtils.GetTime() >= BreakTime[1]/1000
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
		TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = coreConfig.DefaultBackgroundTrans+0.2}):Play()
		TweenService:Create(FlashlightFrame,TweenInfo.new(1,Enum.EasingStyle.Linear),{Size = UDim2.new(15,0,15,0),ImageTransparency = 0}):Play()
		TweenService:Create(script.Parent.ComboFrameDisplay,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{GroupTransparency = 1}):Play()
		TweenService:Create(script.Parent.ComboFade.ComboFade,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{GroupTransparency = 1}):Play()
		if coreConfig.BackgroundBlurEnabled == true then
			TweenService:Create(game.Lighting.Blur,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = 15}):Play()
		end
		task.spawn(function()
			isDrain = false
			repeat task.wait() until TimeUtils.GetTime() >= (BreakTime[2]/1000)
			script.Parent.Leaderboard.LbTrigger:Fire(false)
			script.Parent.MultiplayerLeaderboard.LbTrigger:Fire(false)
			isDrain = true
			TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = coreConfig.DefaultBackgroundTrans}):Play()
			if coreConfig.BackgroundBlurEnabled == true then
				TweenService:Create(game.Lighting.Blur,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = 0}):Play()
			end
		end)
		if Duration > 2 then
			local _rotation = 20
			if math.random(0,1) == 1 then
				_rotation = -20
			end
			BreakTimeFrame.Rotation = _rotation
			local tInfoOut = TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			--TweenService:Create(BreakTimeFrame,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,0.5,-18)}):Play()
			TweenService:Create(BreakTimeFrame,tInfoOut,{Size = UDim2.new(0,400,0,200),Rotation = 0,GroupTransparency = 0}):Play()
			TweenService:Create(script.Parent.BreaktimeFrameOutline,tInfoOut,{Size = UDim2.new(0,400,0,200)}):Play()
			TweenService:Create(script.Parent.BreaktimeFrameOutline.UIStroke,tInfoOut,{Transparency = 0}):Play()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,true)
			local TotalNoteResult = AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss
			local GameAccuracy = math.floor(((AccuracyData.h300*300+AccuracyData.h100*100+AccuracyData.h50*50)/(TotalNoteResult*300))*100*100)/100
			local GameplayRank = "D"
			local misstotal = AccuracyData.miss

			local tostringAcc = string.format("%s%s%%",string.format("%.2d",GameAccuracy),string.sub(string.format("%.2f",GameAccuracy%1),2,4))

			local SS = false

			if GameAccuracy >= 70 then
				GameplayRank = "C"
			end
			if GameAccuracy >= 80 then
				GameplayRank = "B"
			end
			if GameAccuracy >= 90 then
				GameplayRank = "A"
			end
			if GameAccuracy >= 95 and misstotal <= 0 then
				GameplayRank = "S"
			end
			if GameAccuracy >= 100 then
				GameplayRank = "SS"
				SS = true
			end

			BreakTimeFrame.Accuracy.Text = tostringAcc
			BreakTimeFrame.RankDisplay.Text = (not SS and GameplayRank) or "S"
			BreakTimeFrame.RankDisplay.TextColor3 = RankColor[GameplayRank] 
			if (GameplayRank == "S" or SS) and (coreConfig.HiddenMod or coreConfig.Flashlight) then
				BreakTimeFrame.RankDisplay.TextColor3 = Color3.fromRGB(177,177,177)
			end
			BreakTimeFrame.MaxCombo.Text = tostring(AccuracyData.MaxCombo).."x"
			BreakTimeFrame.MissTotal.Text = tostring(AccuracyData.miss).."x"
			BreakTimeFrame.SS_Rank.Visible = SS and not (coreConfig.HiddenMod or coreConfig.Flashlight)
			BreakTimeFrame.SSH_Rank.Visible = SS and (coreConfig.HiddenMod or coreConfig.Flashlight)
			if AccuracyData.miss > 0 then
				BreakTimeFrame.MissTotal.TextColor3 = Color3.fromRGB(255, 107, 107)
			else
				BreakTimeFrame.MissTotal.TextColor3 = Color3.fromRGB(255, 255, 255)
			end


			while TimeUtils.GetTime() < (BreakTime[2]/1000)-1 do
				task.wait()
				local TimeElapsed = (TimeUtils.GetTime()) - BreakTime[1]/1000
				local TimeLeft = ((TimeElapsed+0.5 < Duration and (Duration - TimeElapsed)-1) or 0)
				local DisplayTime = TimeLeft + 1
				if TimeLeft == 0 then
					DisplayTime = 0
				end
				BreakTimeFrame.TimeDisplay.Text = tostring(math.floor(DisplayTime))
				BreakTimeFrame.TimeProgress.Size = UDim2.new(((TimeLeft/Duration)*0.9),0,0,5)
			end

			task.spawn(function()
				task.wait(0.5)
				if Section == CurrentSection then
					--BreakTimeFrame.Visible = false
				end
			end)			

			local tInfoIn = TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.In)

			TweenService:Create(BreakTimeFrame.TimeProgress,tInfoIn,{BackgroundTransparency = 1}):Play()
			TweenService:Create(BreakTimeFrame,tInfoIn,{Size = UDim2.new(0,4,0,2),Rotation = -_rotation,GroupTransparency = 1}):Play()
			TweenService:Create(script.Parent.BreaktimeFrameOutline,tInfoIn,{Size = UDim2.new(1.067,0,0.8,0)}):Play()
			TweenService:Create(script.Parent.BreaktimeFrameOutline.UIStroke,tInfoIn,{Transparency = 1}):Play()
			--TweenService:Create(BreakTimeFrame,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Position = UDim2.new(0.5,0,-1.5,-18)}):Play()
		else
			while TimeUtils.GetTime() < (BreakTime[2]/1000)-1 do
				task.wait()
			end
		end
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,not coreConfig.DisableChatInGame)
		if AccuracyData.Combo > 0 then
			TweenService:Create(script.Parent.ComboFrameDisplay,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{GroupTransparency = 0}):Play()
			TweenService:Create(script.Parent.ComboFade.ComboFade,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{GroupTransparency = 0}):Play()
		end
		local FLSize = (AccuracyData.Combo <= 200 and 8-((AccuracyData.Combo/200)*3)) or 5
		TweenService:Create(FlashlightFrame,TweenInfo.new(2,Enum.EasingStyle.Linear),{Size = UDim2.new(FLSize,0,FLSize,0)}):Play()
	end
end)


local TotalNotes = 0 
local NoteDisplayLimit = 1200 -- there could possibly no way would a map displaying this much notes at the same time
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

task.spawn(function()
	for i = 1,101 do
		repeat task.wait() until (TimeUtils.GetTime())*1000 > AvgLength*i

		-- Accuracy

		local TotalNoteResult = AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss
		local GameAccurancy = math.floor(((AccuracyData.h300*300+AccuracyData.h100*100+AccuracyData.h50*50)/(TotalNoteResult*300))*100*100)/100

		if tostring(GameAccurancy) == "nan" then
			GameAccurancy = 100
		end

		local GameplayRank = "D"
		local misstotal = AccuracyData.miss

		if GameAccurancy >= 70 then
			GameplayRank = "C"
		end
		if GameAccurancy >= 80 then
			GameplayRank = "B"
		end
		if GameAccurancy >= 90 then
			GameplayRank = "A"
		end
		if GameAccurancy >= 95 and misstotal <= 0 then
			GameplayRank = "S"
		end
		if GameAccurancy >= 100 then
			GameplayRank = "SS"
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

task.spawn(function()
	TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = coreConfig.DefaultBackgroundTrans+0.2}):Play()
	repeat task.wait() until TimeUtils.GetTime() > (BeatmapData[1].Time/1000 - 1.2)
	HealthPoint = MaxHealthPoint
	TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = coreConfig.DefaultBackgroundTrans}):Play()
	repeat task.wait() until TimeUtils.GetTime() > (BeatmapData[1].Time/1000)
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
	task.spawn(function()
		if not tonumber(AmbientRatio) or AmbientRatio > 1 or AmbientRatio < 0 then
			AmbientRatio = 0.5
		end

		local SelectedSampleSet = CustomSampleSet

		if not SelectedSampleSet or SelectedSampleSet == "0" then
			SelectedSampleSet = CurrentHitsoundSample
		else
			SelectedSampleSet = HitsoundSampleset[tonumber(SelectedSampleSet)]
		end
		
		SelectedSampleSet = SelectedSampleSet:gsub("none", "normal")

		if HitsoundType == 4 and SelectedSampleSet == "drum" then
			return
		end

		local HitsoundFilename = SelectedSampleSet.."-"..HitsoundTypeset[HitsoundType]
		local CurrentHitsound = script.Hitsounds[HitsoundFilename]:Clone()
		local CurrentHitsound2 = script.Hitsounds[HitsoundFilename]:Clone()


		CurrentHitsound.Volume *= 0.5 + (1-AmbientRatio)*0.5
		CurrentHitsound2.Volume *= 0.5 + (AmbientRatio)*0.5

		CurrentHitsound.Parent = workspace.AudioOutput:WaitForChild("Audio_L")
		CurrentHitsound2.Parent = workspace.AudioOutput:WaitForChild("Audio_R")

		--CurrentHitsound.Parent = script.Parent.HitSounds

		CurrentHitsound:Play()
		CurrentHitsound2:Play()
		task.spawn(function()
			task.wait(0.5)
			CurrentHitsound:Destroy()
			CurrentHitsound2:Destroy()
		end)
	end)
end


task.spawn(function()
	for i, TimingData in pairs(TimingPoints) do
		if TimingData ~= nil and #TimingData > 0 then
			repeat task.wait() until (TimeUtils.GetTime()) >= (TimingData[1] / 1000)
			local volumeMultiplier = TimingData[6] / 100
			timingPointEffectVolumeMultiplier = volumeMultiplier
			AdjustIngameEffectVolume(EffectVolume)

			local BeatLength = TimingData[2]

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
				if not coreConfig.Flashlight and coreConfig.DefaultBackgroundTrans > 0 then
					task.spawn(function()
						local BackgroundDim = PlayerGui.BG.Background.Background.BackgroundDim
						local transparencyValue = coreConfig.DefaultBackgroundTrans + 0.1

						TweenService:Create(BackgroundDim, TweenInfo.new(0.1, Enum.EasingStyle.Linear), { BackgroundTransparency = transparencyValue }):Play()
						task.wait(0.1)
						TweenService:Create(BackgroundDim, TweenInfo.new(0.5, Enum.EasingStyle.Linear), { BackgroundTransparency = coreConfig.DefaultBackgroundTrans }):Play()
					end)
				end

				script.Parent.BPMTick.KiaiTime.Value = true
				script.Parent.GameplayScripts.KiaiEffect.Disabled = not coreConfig.ExclusiveEffects
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

if coreConfig.AutoPlay then
	RunService.Stepped:Connect(function()
		local TimeElapsed = tick() - SpinStart
		local Rotation = (TimeElapsed - math.floor(TimeElapsed))*360*(RPM/60)
		script.Parent.ATSpinner.SpinPart.Orientation = Vector3.new(0,Rotation,0)
	end)
end


if isSpectating == true then
	repeat task.wait() until Start ~= tick()+2
end

--------    Perfomance score - This will effect alot on player's online rank

-- Calculate the maxPS value
local DiffValue = {
	Aim = ReturnData.Difficulty.AimDifficulty,
	Speed = ReturnData.Difficulty.SpeedDifficulty,
	Flashlight = ReturnData.Difficulty.FlashLightDifficulty,
	Base = ReturnData.Difficulty.BeatmapDifficulty,
	LengthBonus = 0.95 + 0.4 * math.min(1,#BeatmapData/2000) + ((#BeatmapData > 2000 and math.log10(#BeatmapData/2000) * 0.5) or 0)
}

local ConvertedODRate = math.clamp(ReturnData.Difficulty.OverallDifficulty * (coreConfig.EasyMod and 0.5 or (coreConfig.HardRock and 1.4 or 1)),0,10)
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

	if coreConfig.NoFail then
		MaxPSValue.Mod.Aim *= 0.9
		MaxPSValue.Mod.Speed *= 0.9
		MaxPSValue.Mod.Acc *= 0.9
		MaxPSValue.Mod.Flashlight *= 0.9
	end

	if coreConfig.HiddenMod then
		MaxPSValue.Mod.Aim *= 1 + 0.04 * (12 - ModdedARRate)
		MaxPSValue.Mod.Speed *= 1 + 0.04 * (12 - ModdedARRate)
		MaxPSValue.Mod.Acc *= 1.08
		MaxPSValue.Mod.Flashlight *= 1 + 0.04 * (12 - ModdedARRate)
	end

	if coreConfig.Flashlight then
		MaxPSValue.Mod.Acc *= 1.02
	end

	if coreConfig.TouchDeviceDetected then 
		MaxPSValue.Mod.Aim *= 0.6
		MaxPSValue.Mod.Flashlight *= 0.6
	end

	if SongSpeed ~= 1 then
		MaxPSValue.Mod.Acc *= math.pow(SongSpeed, 1.45)
	end
end

LiveDiffLastHit = tick()


if coreConfig.PSDisplay == true then
	script.Parent.PSEarned.Visible = true
end

script.Parent.PSEarned.DetailedDisplay.Visible = coreConfig.DetailedPSDisplay
if coreConfig.OptimizedPerfomance then
	script.Parent.PSEarned.AnimatedPSEarned.Visible = false
	script.Parent.PSEarned.TextTransparency = 0
end

LiveDiffValue = Instance.new("NumberValue")
PeakDiffValue = Instance.new("NumberValue")
DiffGraphList = ReturnData.Difficulty.DifficultyStrike.List
StrikeLock = false
if not coreConfig.Flashlight then
	script.Parent.LiveDiffDisplay.Flashlight.Visible = false
end

local LivePlayProcessing = require(ScriptComponent.Gameplay.LivePlayProcessing)
local LivePlaySession = LivePlayProcessing.new()
LivePlaySession:SetupData({
	ModData = {
		HD = coreConfig.HiddenMod,
		HR = coreConfig.HardRock,
		EZ = coreConfig.EasyMod,
		NF = coreConfig.NoFail,
		NS = not coreConfig.SliderMode,
		FL = coreConfig.Flashlight,
		RX = false,
		AP = false,
		AT = coreConfig.AutoPlay,
		SO = false,
		V2 = coreConfig.ScoreV2Enabled,
		TD = coreConfig.TouchDeviceDetected,
		DA = DifficultyAdjust,
		SA = SongSpeed
	},
	ODRate = ReturnData.Difficulty.OverallDifficulty,
	ARRate = ReturnData.Difficulty.ApproachRate,
	NoteCount = ReturnData.NoteCount,
	AimDiffStrainCount = ReturnData.Difficulty.AimDifficultyStrainCount,
	SpeedDiffStrainCount = ReturnData.Difficulty.SpeedDifficultyStrainCount,
	SpeedRelevantNoteCount = ReturnData.Difficulty.SpeedRelevantNoteCount,
	AimDifficulty = ReturnData.Difficulty.AimDifficulty,
	SpeedDifficulty = ReturnData.Difficulty.SpeedDifficulty,
	FlashlightDifficulty = ReturnData.Difficulty.FlashLightDifficulty
})

task.spawn(function()
	local LiveDiffDisplay = script.Parent.LiveDiffDisplay
	local DiffStrikeWarning = LiveDiffDisplay.DiffStrikeWarning

	local waittime = 0
	if coreConfig.OptimizedPerfomance then
		waittime = 0.1
	end
	StreamingLoop:AddLoop(function() return true end, function() return waittime end, function()
		if gameEnded then return "break" end -- no need to load anymore 
		script.Parent.LiveDiffDisplay.Visible = coreConfig.LiveDifficultyDisplay
		if not coreConfig.LiveDifficultyDisplay then
			task.wait(1)
			return "continue"
		end
		if coreConfig.OptimizedPerfomance and waittime == 0 then
			waittime = 0.1
		elseif not coreConfig.OptimizedPerfomance and waittime == 0.1 then
			waittime = 0
		end

		local _env = ParallelProcessingFolder.Core_OsuGame_LiveDifficultyProcess:SendMessage("Process",{
			CurrentLiveDiffAim = LivePlaySession.CurrentLiveDiffAim,
			CurrentLiveDiffSpeed = LivePlaySession.CurrentLiveDiffSpeed,
			CurrentLiveDiffFL = LivePlaySession.CurrentLiveDiffFL,
			LiveDiffLastHit = LivePlaySession.LiveDiffLastHit,
			DiffGraphList = DiffGraphList,
			BeatmapLength = BeatmapLength,
			Start = Start,
			ReturnData = ReturnData,
			DiffStrikeWarning = DiffStrikeWarning,
			StrikeLock = StrikeLock,
			LiveDiffValue = LiveDiffValue,
			PeakDiffValue = PeakDiffValue,
			LiveDiffDisplay = LiveDiffDisplay,
			LiveDiffData = {
				AimFinal = LivePlaySession.AimDiffFinal,
				SpeedFinal = LivePlaySession.SpeedDiffFinal,
				FLFinal = LivePlaySession.FLDiffFinal,
				StarRating = LivePlaySession.CurrentStarRating
			}
		})		
	end)
end)
if not coreConfig.Flashlight then
	script.Parent.PSEarned.DetailedDisplay.Flashlight.Visible = false
end

function AddPerfomanceScore(HitObj):number
	local _accData:PerformanceCalculator.AccuracyData = {
		h300 = AccuracyData.h300, h100 = AccuracyData.h100,
		h50 = AccuracyData.h50, missCount = AccuracyData.miss
	}
	LivePlaySession:ProcessPerfomanceScore(HitObj and HitObj.PSValue or nil, HitObj and HitObj.Time or 0, _accData)
	CurrentPerfomance = LivePlaySession.CurrentPerformance

	return LivePlaySession.CurrentPerformance
end


local LastHitError = 0

task.spawn(function()
	StreamingLoop:AddLoop(function() return true end, 0, function()
		local HitElapsed = (tick() - LastHitError)
		if HitElapsed > 2 and script.Parent.HitError.CurrentDelay.Delay.ImageTransparency == 0 then
			TweenService:Create(script.Parent.HitError.CurrentDelay.Delay,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{ImageTransparency = 1}):Play()
			TweenService:Create(script.Parent.HitError.CurrentDelay.UnstableRate,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{TextTransparency = 1}):Play()
			TweenService:Create(script.Parent.HitError,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{AnchorPoint = Vector2.new(0.5,0)}):Play()
			task.wait(0.5)
		end
	end)
end)

TotalHit = 0
TotalUnstableTime = 0
LastHit = 0
OffsetAvg = 0

function CreateHitDelay(Color,HitDelay)
	-- can be called as HitWindow hit
	OffsetAvg = math.lerp(OffsetAvg, HitDelay, 1/10)
	local Pos = (OffsetAvg+hit50)/(hit50*2)
	local DrawPos = (HitDelay+hit50)/(hit50*2)
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
	NewHitDelay.Position = UDim2.new(DrawPos,0,0.5,0)
	NewHitDelay.BackgroundColor3 = Color
	task.spawn(function()
		TweenService:Create(NewHitDelay,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{Size = UDim2.new(0,2,0.75,0), BackgroundTransparency = 0.1}):Play()
		task.wait(0.25)
		TweenService:Create(NewHitDelay,TweenInfo.new(9.75,Enum.EasingStyle.Linear),{BackgroundTransparency = 1}):Play()
		task.wait(9.75)
		NewHitDelay:Destroy()
	end)
end

--warn((TimeUtils.GetTime())*1000 - HitObj.Time,hit50)



FramePerSec = 0

RunService.Stepped:Connect(function()
	FramePerSec += 1
	task.wait(1)
	FramePerSec -= 1
end)


local MetaDataFrame = script.Parent.MetaData

task.spawn(function()
	task.wait(1)
	MetaDataFrame.Artist.Text = ReturnData.Overview.Metadata.SongCreatorUnicode
	MetaDataFrame.SongName.Text = "<b>"..ReturnData.Overview.Metadata.MapNameUnicode.."</b>"

	local _1 = TweenInfo.new(2.25,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out)
	local _2 = TweenInfo.new(2.25,Enum.EasingStyle.Exponential,Enum.EasingDirection.In)

	TweenService:Create(MetaDataFrame.Artist,_1,{TextTransparency = 0, Position = UDim2.new(0.5,0,0,0)}):Play()
	TweenService:Create(MetaDataFrame.SongName,_1,{TextTransparency = 0, Position = UDim2.new(0.5,0,0,22)}):Play()
	task.wait(2.75)
	TweenService:Create(MetaDataFrame.Artist,_2,{TextTransparency = 1, Position = UDim2.new(0.5,50,0,0)}):Play()
	TweenService:Create(MetaDataFrame.SongName,_2,{TextTransparency = 1, Position = UDim2.new(0.5,-100,0,22)}):Play()
end)

isLoaded = true

------------------------------
-- osu!RoVer gameplay start here

DisplayingHitnote = {}

task.spawn(function()
	if not coreConfig.AutoPlay and not isSpectating and not coreConfig.ReplayMode then return end
	StreamingLoop:AddLoop(function() return true end, 0.5, function()
		if gameEnded then return "break" end
		for id, data in pairs(DisplayingHitnote) do
			if TimeUtils.GetTime() > data.Time/1000 + 10 then
				DisplayingHitnote[id] = nil
			end 
		end
	end)
end)

local ReplayData = {
	PositionData = {},
	ClickData = {K1={},K2={},K3={},K4={}}
}

local ReplayDataValue = script.Parent.GameplayData.CurrentReplayData
ReplayDataValue.Value = HttpService:JSONEncode(ReplayData)

task.spawn(function()
	StreamingLoop:AddLoop(function() return true end, 1, function()
		local FileSize = game.ReplicatedStorage.UserReplaySaves.ControlRemote.GetCurrentReplaySize:InvokeServer()
		script.Parent.ReplayDataStatusDisplay.Text = "Replay file size: "..tostring(math.floor(FileSize/1024)).."Kb"
	end)
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
if not coreConfig.ReplayMode and not isSpectating and not onTutorial then

	local function updateReplayFormat(P,H,T)
		local Digit1 = "0" -- Hit [0 - false, 1 - true, 2 - nil] (1 byte)
		if H then
			Digit1 = tostring(H)
		end
		-- Position of X and Y (8 bytes) (0000 - 4999: NegativePosition) (5000 - 9999:PositivePosition)
		local Digit2_1 = tostring(math.round(5000+P.X.Scale*512))
		local Digit2_2 = tostring(math.round(5000+P.Y.Scale*384))
		Digit2_1 = string.rep("0",4-#Digit2_1)..Digit2_1
		Digit2_2 = string.rep("0",4-#Digit2_2)..Digit2_2
		local Digit3 = tostring(math.round(T))	-- Timing in ms (1 - 6 byte)
		local Encoded = Digit1..Digit2_1..Digit2_2..Digit3
		ReplayDataEncoded = ReplayDataEncoded.."\n"..Encoded
	end

	task.spawn(function()
		local LastRecord = tick()
		local PastPosition
		StreamingLoop:AddLoop(function() return true end, 0, function()
			if tick() - LastRecord < 1/120 then
				return "continue"
			end
			LastRecord = tick()
			task.spawn(function()
				local CurrentTime = math.round((TimeUtils.GetTime())*1000-SongDelay/SongSpeed)
				local CursorPosition = Cursor.Position
				if PastPosition ~= CursorPosition then
					--local DecodedPosition = {X=math.floor(CursorPosition.X.Scale*512+0.5),Y=math.floor(CursorPosition.Y.Scale*384+0.5)}

					--local FullData = {P = DecodedPosition,T = CurrentTime}
					updateReplayFormat(CursorPosition,nil,CurrentTime)
					--UploadReplay(2,FullData,1)
				end
				PastPosition = CursorPosition
			end)
		end)
	end)

	MouseHitEvent.Event:Connect(function(_,KeyHit)
		local CurrentTime = math.round((TimeUtils.GetTime())*1000-SongDelay/SongSpeed)
		--local FullData = {H = true,T = CurrentTime}

		--UploadReplay(2,FullData,2,KeyHit)
		updateReplayFormat(Cursor.Position,KeyHit,CurrentTime)
	end)

	MouseHitEndEvent.Event:Connect(function(_,KeyHit)
		local CurrentTime = math.round((TimeUtils.GetTime())*1000-SongDelay/SongSpeed)
		--local FullData = {H = false,T = CurrentTime}

		--UploadReplay(2,FullData,2,KeyHit)
		local _FullData = updateReplayFormat(Cursor.Position,KeyHit+4,CurrentTime)
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
	task.wait(2)
	new:Destroy()
end)
]]
replayReRun = false
replayReady = true

if coreConfig.ReplayMode then
	-- Disable all common mods (to prevent bugs)
	ClassicNotelock = false
	-------
	local ReplayData = {}

	local i = 1
	local Finish = false
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
	if coreConfig.Replay_TouchDevice then
		ReplayDelay = -100
	end
	local CurrentYieldHit

	task.spawn(function()
		local function play()
			local disabled = false
			task.spawn(function()
				StreamingLoop:AddLoop(function() return true end, 0, function()
					if replayReRun then
						disabled = true

						replayReady = true
						repeat task.wait() until not replayReRun
						play()
					end
				end)
			end)
			for _,data in pairs(ReplayData) do
				if disabled then break end
				local HitTiming = data[1]
				if coreConfig.Replay_TouchDevice then
					-- add a timing for TD replay
					HitTiming += 100
				end
				if (TimeUtils.GetTime()) + (1/GameplayFPS) < (HitTiming/1000+SongDelay/1000/SongSpeed) + ReplayDelay/1000 then
					repeat task.wait() until (TimeUtils.GetTime()) + (1/GameplayFPS) >= (HitTiming/1000+SongDelay/1000/SongSpeed) + ReplayDelay/1000
				end
				task.spawn(function()
					--print(math.floor(((TimeUtils.GetTime()) - data[1]/1000)*1000))
					CursorPosition = Vector2.new(data[3]-5000,data[4]-5000)
					--MouseHitEvent
					--MouseHitEndEvent
					if coreConfig.Replay_TouchDevice then
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
	if not (tonumber(Time)) or Time < -3 or Time > 999 or Time ~= Time or coreConfig.OnMultiplayer then return end
	isOnTimeJump = true
	local New = Start + (TimeUtils.GetTime()) - Time
	if New > Start then
		isIn_GameQuickRestart = true
	end

	repeat task.wait() until not isIn_GameQuickRestart
	AccuracyData = cloneTable(AccTemplate)

	for _,obj in pairs(script.Parent.PlayFrame:GetChildren()) do
		if obj.Name ~= "Flashlight" then
			obj:Destroy()
		end
	end

	TimeUtils.TimeJump(Time)

	if coreConfig.StoryboardAvailable then
		storyboardUI.Scripts.Actor:SendMessage("SetTime", os.clock() - Start)
	end


	for i = 1,60 do task.wait() end
	HealthPoint = MaxHealthPoint
	HealthDrainMultiplier = 1

	isOnTimeJump = false

	PlayRanked = false
	script.Parent.UnrankedSign.Visible = true
end)
if coreConfig.SliderMode == true then
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

if not coreConfig.ReplayMode and not isSpectating and not coreConfig.OnMultiplayer then
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
if coreConfig.AutoPlay then
	ClassicNotelock = true -- AT can only run stable on this
	if ReturnData.BeatmapSetsData.BeatmapID == "1529760" and not coreConfig.NoFail and coreConfig.SliderMode then
		PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("The autoplay cannot pass this trust me.",Color3.fromRGB(255,0,0))
	end
end

-- Secret perks

if ReturnData.BeatmapSetsData.BeatmapID == "1529760" and coreConfig.SliderMode and math.random(1,100) == 100 then
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

NoteBasePreloadTime = 0 -- Time in ms for the circle to preload, help decrease latency
StackLeniency = ReturnData.StackLeniency
StackVector = 0
do
	local CSRate = ReturnData.Difficulty.CircleSize * ((coreConfig.HardRock and 1.3) or (coreConfig.EasyMod and 0.5) or 1)
	local ObjectRadius = 54.4 - 4.48 * CSRate
	StackVector = ObjectRadius / 10
end

local prevNoteRegisterId = ""
MouseHitEvent.Event:Connect(function(key)
	MouseHitRegisterEvent:Fire(key, HttpService:GenerateGUID())
end)

-- When a note is finished, instead of destroying the note, we will put the note to invisible
-- It will be added to here, decrease load of constantly creating and destroying objects
local UnusedNotes = {}

function newHitCircle(HitObj, NoteZIndex)
	local Circle

	if #UnusedNotes > 0 then
		local _index = #UnusedNotes
		Circle = UnusedNotes[_index]
		UnusedNotes[_index] = nil
		if not Circle.Parent then
			-- the circle somehow got destroyed already
			return newHitCircle(HitObj, NoteZIndex)
		end
		-- We need to re-align the circle to the origin
		Circle.Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0)
		Circle.Size = UDim2.new(CircleSize/384,0,CircleSize/384,0)
		Circle.ZIndex = NoteZIndex		
		Circle.ApproachCircle.Visible = true
		Circle.Parent = script.Parent.PlayFrame
	else
		Circle = ObjectManagement_Actor.ToggleCloneObject:Invoke(script.Circle, script.Parent.PlayFrame, {
			Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0),
			Size = UDim2.new(CircleSize/384,0,CircleSize/384,0),
			ZIndex = NoteZIndex
		})
	end

	return Circle
end

function clearHitCircle(Circle)
	-- The circle has done it's work
	-- It will be either invisible and add to idle queue or just completely destroy
	local MaxCircleNote = 10

	if #UnusedNotes >= MaxCircleNote then
		Circle:Destroy()
	else
		Circle.Visible = false
		Circle.Parent = nil
		UnusedNotes[#UnusedNotes+1] = Circle
	end
end

-- Analytics
task.spawn(function()
	task.wait(3)
	if PlayRanked then
		game.ReplicatedStorage.AnalyticCustomEvent:FireServer("Playcount", 1, customFields)
		game.ReplicatedStorage.AnalyticCustomEvent:FireServer("DifficultyPlayDistribution", ReturnData.Difficulty.BeatmapDifficulty, customFields)
		game.ReplicatedStorage.AnalyticFunnelEvent:FireServer("Played a map", 2)
	end
end)

-- Check if pause is allowed
if not (coreConfig.OnMultiplayer or isSpectating or coreConfig.ReplayMode or coreConfig.AutoPlay) then
	script.Parent.GameplayData.PauseAllowed.Value = true
else
	script.Parent.RestartGame.Text = "Menu (Hold)"	-- Hold to exit to main menu
end

local conn:{thread} = {}

function clearTasks()
	for _,t in pairs(conn) do
		task.cancel(t)
	end
	conn = {}
end

-- HIT OBJ LINE
function LetTheGameBegin()
	if #conn > 0 then
		clearTasks()
	end
	for i,HitObj in pairs(BeatmapData) do
		local NoteZIndex = ZIndex
		ZIndex -= 5
		if isIn_GameQuickRestart then break end
		local HitNoteID = i
		local HitMiss = false
		local IsHitted = false
		local isLastComboNote = false
		local AnimationIdList = {}
		local SliderATKey = 3

		--if HardRock then
		--	HitObj.Position = {X = HitObj.Position.X,Y=384-HitObj.Position.Y} -- swap the note Y-Axis
		--end

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
			repeat task.wait() until (TimeUtils.GetTime()) >= (HitObj.Time-1500)/1000
		else
			if i == 1 then -- the very first note
				repeat task.wait() until (TimeUtils.GetTime()) >= (HitObj.Time-CircleApproachTime-NoteBasePreloadTime)/1000
			elseif (TimeUtils.GetTime())*1000 < HitObj.Time-CircleApproachTime then	-- yield until the next note avaiable
				repeat task.wait() until (TimeUtils.GetTime()) >= (HitObj.Time-CircleApproachTime-NoteBasePreloadTime)/1000
			end
		end


		if TotalNotes > NoteDisplayLimit then -- The note count should not exceed the display limit
			repeat task.wait() until TotalNotes <= NoteDisplayLimit
		end
		NoteCompleted += 1

		task.spawn(function()
			task.wait((HitObj.Time)/1000 - (TimeUtils.GetTime()))
			NPS += 1
			task.wait(1/SongSpeed)
			NPS -= 1
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
		task.spawn(function()
			-- Start processing the note
			if (isSpectating == true or isOnTimeJump) and TimeUtils.GetTime() > (HitObj.Time+hit50)/1000 then
				Combo = 1
				CurrentCursorPos = HitNoteID + 1
				CurrentHitnote = HitNoteID + 1
				TotalNotes -= 1
				return
			end
			if HitObj.Time < -1550 then
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
			do
				local colon1 = string.find(HitsoundCustomSampleSet, ":", 1, true)
				if colon1 then
					local colon2 = string.find(HitsoundCustomSampleSet, ":", colon1 + 1, true)
					if colon2 then
						local _s1, _e1 = 1, colon1 - 1
						local _s2, _e2 = _e1 + 2, colon2 - 1
						NoteNormalSampleSet, NoteAditionSampleSet = string.sub(HitsoundCustomSampleSet, _s1, _e1), string.sub(HitsoundCustomSampleSet, _s2, _e2)
					end
				end
			end

			if HitObjProperties.isSpinner then -- Spinner
				if coreConfig.AutoPlay == true and coreConfig.ReplayMode ~= true then
					local SpinKey = 3 -- default
					task.spawn(function() -- auto spin (beta)
						if HitMiss == true then
							CurrentCursorPos = HitNoteID + 1
							return
						end
						repeat task.wait() until (TimeUtils.GetTime()) >= HitObj.Time/1000
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
						--[[
						local Connection = script.Parent.ATSpinner.SpinPart.Changed:Connect(function()
							local LookVector = script.Parent.ATSpinner.SpinPart.CFrame.LookVector
							local Pos = UDim2.new(((256+(LookVector.X*128)))/512,0,((192+(LookVector.Z*128)))/384,0)
							TweenService:Create(ATVC,TweenInfo.new(0.01,Enum.EasingStyle.Linear),{Position = Pos}):Play()
						end)]]

						local ATSpinnerRPM = 440
						local ATSpinnerSPR = 1/(ATSpinnerRPM/60)
						local origin = Vector2.new(256, 192)
						local Distance = 144
						while TimeUtils.GetTime() <= HitObj.Time/1000 + SpinnerTime do
							local t = 1-(TimeUtils.GetTime() % ATSpinnerSPR)/ATSpinnerSPR
							local r = t * math.pi * 2
							local offsetX = math.cos(r) * Distance
							local offsetY = math.sin(r) * Distance
							local newPos = (origin + Vector2.new(offsetX, offsetY))/Vector2.new(512,384)
							TweenService:Create(ATVC,TweenInfo.new(0),{Position = UDim2.fromScale(newPos.X, newPos.Y)}):Play()
							task.wait()
						end

						--task.wait(SpinnerTime-0.1)
						--Connection:Disconnect()
						task.wait(0.1)
						MouseHitEndEvent:Fire(SecurityKey,SpinKey)
						CurrentCursorPos = HitNoteID + 1
					end)
				end





				task.spawn(function()
					repeat task.wait() until CurrentHitnote == HitNoteID
					CurrentHitnote = HitNoteID + 1
				end)


				local Spinner = script.SpinnerFrame:Clone()
				Spinner.Parent = script.Parent.PlayFrame
				Spinner.ZIndex = NoteZIndex


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


				repeat task.wait() until TimeUtils.GetTime() >= (HitObj.SpinTime)/1000

				local Ratio = Spinner.Spinner.RoundSpinned.Value/Spinner.RoundRequired.Value


				local function CreateHitResult(HitResult)
					if HitResult == 4 and not coreConfig.Hit300Display then return end

					task.spawn(function()
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
							task.wait(0.5)
							if BeatmapFailed then return end
							AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(0.2,Enum.EasingStyle.Sine),{ImageTransparency = 1,Position = UDim2.new(0.5,0,0.6,0)})):Play()
							task.wait(0.2)
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
							task.wait(0.1)
							if BeatmapFailed then return end
							AddHitnoteAnimation(TweenService:Create(NewHitResult,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Rotation = CurrentRotation+(Positive*15),Position = CurrentPos+UDim2.new(0,0,0.15,0)})):Play()
							AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{ImageTransparency = 1})):Play()
							task.wait(1)
							if BeatmapFailed then return end
							NewHitResult:Destroy()
						end
					end)
				end


				if Ratio >= 0.25 or SpinnerTime < 0.2 then
					if not TimeUtils.IsPaused() then
						AccuracyData.Combo += 1
						EstimatedCombo += 1
					end

					AccuracyData.BaseConsistency += AccuracyData.Combo
					AccuracyData.MaxConsistency += EstimatedCombo
					AccuracyData.PerfomanceCombo += 1 
					if AccuracyData.PerfomanceCombo > AccuracyData.MaxPeromanceCombo then
						AccuracyData.MaxPeromanceCombo = AccuracyData.PerfomanceCombo
					end
					if AccuracyData.Combo > AccuracyData.MaxCombo then
						AccuracyData.MaxCombo = AccuracyData.Combo
					end
					task.spawn(function()
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
						AddPerfomanceScore(HitObj)
					elseif Spinner.RoundRequired.Value-Spinner.Spinner.RoundSpinned.Value <= 1 then
						AccuracyData.h100 += 1
						CreateHitResult(3)
						AddScore(100)
						AddHP(0.011 + 0.05)
						AddPerfomanceScore(HitObj)
					else
						AccuracyData.h50 += 1
						CreateHitResult(2)
						AddScore(50)
						AddHP(0.002 + 0.03)
						AddPerfomanceScore(HitObj)
					end
				else
					if AccuracyData.Combo >= 20 then
						script.Parent.ComboBreak:Play()
					end
					AccuracyData.Combo = 0
					EstimatedCombo += 1
					AccuracyData.MaxConsistency += EstimatedCombo
					AccuracyData.PerfomanceCombo = 0
					AddPerfomanceScore(HitObj)

					AccuracyData.miss += 1
					MissedInCurrentTime = true
					AddScore(0)
					DrainHP(-0.03, -0.125, -0.2)
					CreateHitResult(1)
					HitMiss = true
				end
				if not coreConfig.OptimizedPerfomance then
					task.wait(1)
				end
				Spinner:Destroy()
			else -- HitNote and Slider
				LastNoteData = {Slider = false}
				local function waitUntil(condition)
					while not condition() do
						task.wait()
					end
				end

				-- Process autoplay of the hit circle
				if coreConfig.AutoPlay == true and coreConfig.ReplayMode ~= true then
					task.spawn(function()
						local EarlyRequired = false

						if (CurrentCursorPos < HitNoteID or CurrentHitnote < HitNoteID) and (TimeUtils.GetTime()) * 1000 <= HitObj.Time then
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

						local TimeUntilNoteClicked = (TimeUtils.GetTime()) * 1000 - HitObj.Time

						local bonustiming = (EarlyRequired and hit300 * 0.5) or 0
						local TimeWithAR = TimeUntilNoteClicked - CircleApproachTime
						local CursorTweenTime = math.abs((TimeWithAR > 0 and 0) or (TimeWithAR > -500 and -TimeWithAR) or 500)

						if TimeUntilNoteClicked < 0 then
							task.wait(math.max((-TimeUntilNoteClicked - CursorTweenTime) / 1000, 0))
						end

						TimeUntilNoteClicked = math.min((TimeUtils.GetTime()) * 1000 - (HitObj.Time + bonustiming), 0)
						CursorTweenTime = math.abs((TimeUntilNoteClicked > 0 and 0) or (TimeUntilNoteClicked > -500 and -TimeUntilNoteClicked) or 500)

						local AvgFrameTime = (1 / FramePerSec) * 1000
						local Tween = TweenService:Create(ATVC, TweenInfo.new(CursorTweenTime / 1000, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Position = UDim2.new(HitObj.Position.X / 512, 0, HitObj.Position.Y / 384, 0) })

						if CursorTweenTime > AvgFrameTime then
							Tween:Play()
						else
							ATVC.Position = UDim2.new(HitObj.Position.X / 512, 0, HitObj.Position.Y / 384, 0)
						end

						if CursorTweenTime > AvgFrameTime and (TimeUtils.GetTime()) <= (HitObj.Time + hit300) / 1000 then
							waitUntil(function()
								return (TimeUtils.GetTime()) > (HitObj.Time-1000/GameplayFPS*0.5) / 1000 or (TimeUtils.GetTime()) >= (HitObj.Time) / 1000
							end)
						end

						if Tween then
							Tween:Pause()
						end

						ATVC.Position = UDim2.new(HitObj.Position.X / 512, 0, HitObj.Position.Y / 384, 0)

						CurrentNoteId = NoteId

						if not HitObjProperties.isSlider or not coreConfig.SliderMode then
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

						if not HitObjProperties.isSlider or coreConfig.SliderMode == false then
							CurrentCursorPos = HitNoteID + 1
						end
					end)
				end

				local Connection
				local SLEndPos


				task.spawn(function()
					-- processing the circle connection
					if BeatmapData[i+1] ~= nil and (BeatmapData[i+1].Type == 1 or BeatmapData[i+1].Type == 2) then
						local NextHitObj = BeatmapData[i+1]
						local HitObjPos = Vector2.new(HitObj.Position.X,HitObj.Position.Y)

						if coreConfig.SliderMode and HitObjProperties.isSlider then
							repeat task.wait() until SLEndPos
							--if HardRock then
							--	HitObjPos = Vector2.new(SLEndPos.X,384-SLEndPos.Y)
							--else
							--	HitObjPos = Vector2.new(SLEndPos.X,SLEndPos.Y)
							--end
							HitObjPos = Vector2.new(SLEndPos.X,SLEndPos.Y)
						end

						local NextHitObjPos

						--if HardRock then
						--	NextHitObjPos = Vector2.new(NextHitObj.Position.X,384-NextHitObj.Position.Y)
						--else
						--	NextHitObjPos = Vector2.new(NextHitObj.Position.X,NextHitObj.Position.Y)
						--end

						NextHitObjPos = Vector2.new(NextHitObj.Position.X,NextHitObj.Position.Y)
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

							local scalingFactor = CircleSize / 80
							Pos = UDim2.new(Pos.X/512,0,Pos.Y/384,0)
							Size = UDim2.new(Size/512,0,0.01 * scalingFactor,0)

							Connection.Parent = script.Parent.PlayFrame
							Connection.Position = FirstPos
							Connection.Rotation = Rotation
							Connection.Size = UDim2.new(0,0,0.02 * scalingFactor,0)
							Connection.ZIndex = NoteZIndex-2
							Connection.BackgroundTransparency = 0
							--Connection.RemoveTime.Value = NextHitObj.Time

							task.spawn(function()
								task.wait((NextHitObj.Time/1000+2) - (TimeUtils.GetTime()))
								if Connection and Connection.Parent ~= nil then
									Connection:Destroy()
								end
							end)
							local TweenTime = (NextHitObj.Time-HitObj.Time > 50/SongSpeed and NextHitObj.Time-HitObj.Time) or 50/SongSpeed
							task.spawn(function()
								repeat task.wait() until TimeUtils.GetTime() >= (HitObj.Time - CircleApproachTime)/1000
								local ct_ = TweenService:Create(Connection,TweenInfo.new(TweenTime/1000,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{BackgroundTransparency = 0.5,Position = Pos,Size = Size})
								AddHitnoteAnimation(ct_)
								ct_:Play()
							end)
							if (TimeUtils.GetTime())*1000 < NextHitObj.Time-250/SongSpeed then
								task.wait((NextHitObj.Time-250/SongSpeed)/1000 - (TimeUtils.GetTime()))
								local ct_ = TweenService:Create(Connection,TweenInfo.new(0.25/SongSpeed,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{BackgroundTransparency = 0.5,Position = EndPos,Size = UDim2.new(0,0,0.01 * scalingFactor,0)})
								AddHitnoteAnimation(ct_)
								ct_:Play()
							end
							task.wait(NextHitObj.Time/1000 - (TimeUtils.GetTime()))
							Connection:Destroy()
						end
					elseif BeatmapData[i+1] ~= nil and BeatmapData[i+1].Type ~= 8 then
						isLastComboNote = true
					end
				end)

				-- Stop processing further if the beatmap has failed
				if BeatmapFailed then return end

				-- Create hit circle
				--[[
				local Circle = ObjectManagement_Actor.ToggleCloneObject:Invoke(script.Circle, script.Parent.PlayFrame, {
					Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0),
					Size = UDim2.new(CircleSize/384,0,CircleSize/384,0),
					ZIndex = NoteZIndex
				})]]

				local Circle = newHitCircle(HitObj, NoteZIndex)

				Circle.TextLabel.Text = Combo
				Circle.HitCircle.ImageColor3 = ComboColor[CurrentComboColor]
				Circle.ApproachCircle.ImageColor3 = ComboColor[CurrentComboColor]

				local _list = {}
				if #Circle.CircleNumber:GetChildren() > 1 then
					for _, obj in pairs(Circle.CircleNumber:GetChildren()) do
						if not obj:IsA("UIListLayout") then
							local i = #_list+1
							if i > string.len(tostring(Combo)) then
								obj:Destroy()
								continue
							end
							_list[i] = obj
						end
					end
				end


				for i, char in pairs(tostring(Combo):split("")) do
					local NumberBase = script.HitCircleNumber["Number_"..char]
					local NumberFrame
					if _list[i] then
						-- re-use the old one
						NumberFrame = _list[i]
						NumberFrame.Image = NumberBase.Image
					else
						-- if not found then just create one
						NumberFrame = NumberBase:Clone()
						NumberFrame.Parent = Circle.CircleNumber
					end


					NumberFrame.LayoutOrder = i

					NumberFrame.ImageTransparency = 1
				end
				HitObj.ComboColor = ComboColor[CurrentComboColor]


				if TimeUtils.GetTime() < (HitObj.Time - CircleApproachTime)/1000 then
					task.spawn(function()
						Circle.Visible = false
						repeat task.wait() until TimeUtils.GetTime() >= (HitObj.Time - CircleApproachTime)/1000
						Circle.Visible = true
					end)
				end
				local FadeInTime = 0.8
				if ApproachRate < 5 then
					FadeInTime = (800 + 400 * (5 - ApproachRate) / 5)/1000
				elseif ApproachRate > 5 then
					FadeInTime = (800 - 500 * (ApproachRate - 5) / 5)/1000
				end
				if coreConfig.SpeedSync then
					FadeInTime /= SongSpeed
				end
				if coreConfig.HiddenMod then
					FadeInTime = (CircleApproachTime - (CircleApproachTime*1/6))/2000
				end

				-------------------- Hit result -------------------------------

				local function CreateHitResult(HitResult)
					if HitResult == 4 and not coreConfig.Hit300Display then return end
					task.spawn(function()
						local FrameList = {
							[1] = script.HitMiss,
							[2] = script.Hit50,
							[3] = script.Hit100,
							[4] = script.Hit300}

						local NewHitResult = FrameList[HitResult]:Clone()
						NewHitResult.Parent = script.Parent.PlayFrame
						NewHitResult.ZIndex = 999999999 -- on top of everything
						if HitResult ~= 1 then
							NewHitResult.Size = UDim2.new((CircleSize/384)*0.3,0,(CircleSize/384)*0.3,0)
							NewHitResult.Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0)
							TweenService:Create(NewHitResult,TweenInfo.new(0.1/SongSpeed,Enum.EasingStyle.Linear),{Size = UDim2.new((CircleSize/384)*0.6,0,(CircleSize/384)*0.6,0)}):Play()
							TweenService:Create(NewHitResult.Image,TweenInfo.new(0.1/SongSpeed,Enum.EasingStyle.Linear),{ImageTransparency = 0}):Play()
							task.wait(0.5/SongSpeed)
							if BeatmapFailed then return end
							AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(0.2/SongSpeed,Enum.EasingStyle.Sine),{ImageTransparency = 1,Position = UDim2.new(0.5,0,0.6,0)})):Play()
							task.wait(0.2/SongSpeed)
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
							AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(0.1/SongSpeed,Enum.EasingStyle.Linear),{ImageTransparency = 0,Size = UDim2.new(2,0,2,0)})):Play()
							task.wait(0.1/SongSpeed)
							if BeatmapFailed then return end
							AddHitnoteAnimation(TweenService:Create(NewHitResult,TweenInfo.new(1/SongSpeed,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Rotation = CurrentRotation+(Positive*15),Position = HitResultPosition+UDim2.new(0,0,0.15,0)})):Play()
							AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(1/SongSpeed,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{ImageTransparency = 1})):Play()
							task.wait(1/SongSpeed)
							if BeatmapFailed then return end
							NewHitResult:Destroy()
						end
					end)
				end

				local function CreateSliderHitResult(HitResult,Pos)
					if HitResult == 4 and not coreConfig.Hit300Display then return end
					task.spawn(function()
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
							task.wait(0.5)
							if BeatmapFailed then return end
							AddHitnoteAnimation(TweenService:Create(NewHitResult.Image,TweenInfo.new(0.2,Enum.EasingStyle.Sine),{ImageTransparency = 1,Position = UDim2.new(0.5,0,0.6,0)})):Play()
							task.wait(0.2)
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
							task.wait(0.1)
							TweenService:Create(NewHitResult,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Rotation = CurrentRotation+(Positive*15),Position = CurrentPos+UDim2.new(0,0,0.15,0)}):Play()
							TweenService:Create(NewHitResult.Image,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{ImageTransparency = 1}):Play()
							task.wait(1)
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
				local SliderTime = HitObj.SliderTime
				local LastHold = 0


				if HitObjProperties.isSlider and coreConfig.SliderMode == true then
					task.spawn(function()
						local ExtraData = HitObj.ExtraData
						local SliderCurvePoints = HitObj.SliderCurvePoints
						local Slides = tonumber(ExtraData[3])

						if i >= #BeatmapData then
							LastNoteData = {Slider = true,SliderTime = SliderTime}
						end

						local H,S,V = HitObj.ComboColor:ToHSV()
						if V < 0.75 then
							V = 0.75
						end

						local ExtraLengthData

						if #SliderCurvePoints > 400 then -- I will have to decrease the points count to make it less lag
							local env = ExternalFunction_Actor.ProcessCommand:Invoke("Core_OsuGame_ProcessLargeSliderPoints",{
								SliderCurvePoints = SliderCurvePoints
							})
							SliderCurvePoints = env.SliderCurvePoints
							ExtraLengthData = env.ExtraLengthData
						end

						if StackLeniency > 0 and HitObj.StackCount > 0 then
							-- set the curve point to adjust with the stack leniency
							for i, vector in pairs(SliderCurvePoints) do
								SliderCurvePoints[i] -= Vector2.new(StackVector, StackVector) * HitObj.StackCount
								if coreConfig.HardRock then
									SliderCurvePoints[i] = Vector2.new(vector.X, 384 - vector.Y)
								end
							end
						end

						if Slides % 2 == 0 then
							SLEndPos = SliderCurvePoints[1]
						else
							SLEndPos = SliderCurvePoints[#SliderCurvePoints]
						end

						-- Draw the slider
						local newCurvePoint = SliderCurvePoints
						local sliderTickData = HitObj.SliderTickData

						local SliderObject = SliderComponent.new(newCurvePoint, sliderTickData, Slides, CircleSize, ExtraLengthData, SliderObjManage)
						SliderObject.SliderBase.ZIndex = NoteZIndex-3

						local FollowCircle = SliderObject.SliderFollowCircle
						FollowCircle.isFollow.ImageColor3 = Color3.fromHSV(H, S, V)
						FollowCircle.SliderFollowCircle.ImageColor3 = HitObj.ComboColor
						FollowCircle.ZIndex = NoteZIndex-2
						SliderObject.setFollowCirclePosition(0, false)
						local SnakeInTime = math.min(FadeInTime, 0.2/SongSpeed)

						task.spawn(function()
							if Slides > 1 then
								local SliderBPMStartTime = HitObj.SliderBPMStartTime/100
								local SliderBeatTime = 1/(HitObj.SliderBPM/60)
								StreamingLoop:AddLoop(function() return TimeUtils.GetTime() <= HitObj.Time/1000 + SliderTime end, 0, function()
									-- Reverse arrow beat handler
									local t = ((TimeUtils.GetTime() - SliderBPMStartTime)/SliderBeatTime)%1

									SliderObject.setReverseArrowBeat(t)
									task.wait()
								end)
							end
						end)

						if not SnakingInSlider then
							SliderObject.SetSnakingIn(1)
						end

						repeat task.wait() until TimeUtils.GetTime() >= (HitObj.Time - CircleApproachTime)/1000
						SliderObject.ShowCurrentTickOnSlide(1, SliderTime * 1000, true)
						while TimeUtils.GetTime() < (HitObj.Time - CircleApproachTime)/1000 + FadeInTime do
							local t = ((TimeUtils.GetTime()) - (HitObj.Time - CircleApproachTime)/1000)/FadeInTime
							local t2 = ((TimeUtils.GetTime()) - (HitObj.Time - CircleApproachTime)/1000)/SnakeInTime
							if SnakingInSlider then
								SliderObject.SetSnakingIn(t2)
							end
							SliderObject.SetTransparency(math.lerp(1, 0.2, t))
							task.wait()
						end

						SliderObject.SetSnakingIn(1)
						SliderObject.SetTransparency(0.2)
						if coreConfig.HiddenMod then
							task.spawn(function()
								local FadeTime = SliderTime*0.75
								if FadeTime <= 0.25 then
									FadeTime = 0.25
								end
								while TimeUtils.GetTime() < HitObj.Time/1000 + FadeTime do
									local t = ((TimeUtils.GetTime()) - HitObj.Time/1000)/FadeTime
									SliderObject.SetTransparency(math.lerp(0.2, 1, t))
									task.wait()
								end
								SliderObject.SetTransparency(1)		
							end)
						end
						local Completed = false
						local InSliderTickRequired = HitObj.SliderTickData and #HitObj.SliderTickData or 0
						local function isInFollowCircle(t)
							if not t then
								t = ((((TimeUtils.GetTime()) - HitObj.Time/1000) / SliderTime)  % (1/Slides)) / (1/Slides)
							end
							local currentSlide = math.floor(((TimeUtils.GetTime() - HitObj.Time/1000) / SliderTime) / (1/Slides)) + 1


							return SliderObject.isCursorInFollowCircle(CursorPosition, t, currentSlide%2==0)
						end
						task.spawn(function()
							repeat task.wait() until (TimeUtils.GetTime()) >= HitObj.Time/1000 and SliderTime ~= -1

							local currentProcessingSlide = 1
							local currentTickOnSlide = 1

							task.spawn(function()
								-- Slider tick handler
								for i, tickData in pairs(HitObj.SliderTickData) do
									local nextTick = tickData[1]
									local nextTickSlide = tickData[2]
									if nextTickSlide > currentProcessingSlide then
										currentProcessingSlide = nextTickSlide
										SliderObject.ShowCurrentTickOnSlide(nextTickSlide, SliderTime * 1000)
										currentTickOnSlide = 1
									end
									if TimeUtils.GetTime() < nextTick/1000 then
										repeat task.wait() until TimeUtils.GetTime() >= nextTick/1000
									end
									SliderObject.CleanTick(currentProcessingSlide, currentTickOnSlide)
									currentTickOnSlide += 1
									if Completed then
										break 
									end

									if (isInFollowCircle() == true and script.Parent.KeyDown.Value == true) or tick() - LastHold < 0.1 then
										if i ~= Slides then
											Score += 10
											TotalScoreEstimated += 10
										end
										if not TimeUtils.IsPaused() then
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
										end
									else
										if AccuracyData.Combo >= 20 then
											script.Parent.ComboBreak:Play()
										end
										if not TimeUtils.IsPaused() then
											AccuracyData.Combo = 0
											EstimatedCombo += 1
											AccuracyData.MaxConsistency += EstimatedCombo
											AccuracyData.PerfomanceCombo = 0
											DrainHP(-0.02, -0.075, -0.14)
										end
									end
								end
							end)
							TweenService:Create(FollowCircle.SliderFollowCircle, TweenInfo.new(0.015/SongSpeed, Enum.EasingStyle.Linear),{ImageTransparency = 0}):Play()
							local function isATReady()
								return IsHitted or Completed
							end

							local PreviousSlide = 0

							while TimeUtils.GetTime() < HitObj.Time/1000 + SliderTime do
								if Completed then
									-- if somehow the slider is completed, we will add up all at once
									AddHealthDrainMultiplier(0.7 * (Slides - PreviousSlide))
									break
								end
								local t = (TimeUtils.GetTime() - HitObj.Time/1000) % (SliderTime/Slides) / (SliderTime/Slides)  --(((TimeUtils.GetTime()) - HitObj.Time/1000) / SliderTime) % (1/Slides)
								local CurrentSlide = math.floor((TimeUtils.GetTime() - HitObj.Time/1000)/(SliderTime/Slides)) + 1
								local isReverse = CurrentSlide % 2 == 0
								SliderObject.setFollowCirclePosition(t, isReverse)
								if CurrentSlide == Slides and SnakingOutSlider then
									SliderObject.SetSnakingOut(t)
								end								

								-- Handler for AT
								if coreConfig.AutoPlay and isATReady() then
									local Pos = SliderObject.PositionOf(math.clamp(t,0,1), isReverse)
									TweenService:Create(ATVC, TweenInfo.new(0), {Position = UDim2.fromScale(Pos.X, Pos.Y)}):Play()
								end
								PreviousSlide = CurrentSlide
								task.wait()
							end

							if coreConfig.AutoPlay then -- AT
								local Pos = SliderObject.PositionOf(1, Slides%2==0)
								TweenService:Create(ATVC, TweenInfo.new(0), {Position = UDim2.fromScale(Pos.X, Pos.Y)}):Play()
								MouseHitEndEvent:Fire(SecurityKey,SliderATKey)
							end
						end)

						task.spawn(function()
							if (TimeUtils.GetTime()) < HitObj.Time/1000 or SliderTime == -1 then
								repeat task.wait() until (TimeUtils.GetTime()) >= HitObj.Time/1000 and SliderTime ~= -1
							end
							task.spawn(function()
								-- Slider holding handler
								-- Check if player is holding correctly in the slider
								local onTouch = false
								StreamingLoop:AddLoop(function() return not Completed end, 0, function()
									if isInFollowCircle() == true and script.Parent.KeyDown.Value == true then
										if not script.Parent.PlayFrame.Flashlight.SliderDim.isDim.Value then
											script.Parent.PlayFrame.Flashlight.SliderDim.isDim.Value = true
											TweenService:Create(script.Parent.PlayFrame.Flashlight.SliderDim,TweenInfo.new(0.05,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.2}):Play()
										end
										if FollowCircle:FindFirstChild("isFollow") then
											if not onTouch then
												local FollowCircleApproachSize = 2.25
												TweenService:Create(FollowCircle.isFollow,TweenInfo.new(math.min(0.25/SongSpeed,SliderTime*0.75),Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{ImageTransparency = 0, Size = UDim2.new(FollowCircleApproachSize,0,FollowCircleApproachSize,0)}):Play()
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
											if onTouch then
												TweenService:Create(FollowCircle.isFollow,TweenInfo.new(0.25/SongSpeed,Enum.EasingStyle.Linear),{ImageTransparency = 1, Size = UDim2.new(1,0,1,0)}):Play()
											end
											onTouch = false
										end
									end
								end)
							end)

							task.spawn(function()
								-- local MaximumHoldTime = 0.1 -- releasing the cursor above this time will make a slider break
								local previousSlide = 1
								-- Check if the slider passed any reverse
								local SLPositionData = {
									[1] = SliderObject.PositionOf(1), [0] = SliderObject.PositionOf(0)
								}

								local function checkSlides(Multiplier, CurrentSlide)
									if Multiplier > 100 then
										-- it is NOT SUPPOSE to be that high
										return
									end
									if (isInFollowCircle(Slides%2) == true and script.Parent.KeyDown.Value == true) or tick() - LastHold <= 0.1 then

										if not TimeUtils.IsPaused() then
											Score += 30 * Multiplier
											TotalScoreEstimated += 30 * Multiplier
											AccuracyData.Combo+=Multiplier
											EstimatedCombo += Multiplier
											AccuracyData.BaseConsistency += AccuracyData.Combo
											AccuracyData.MaxConsistency += EstimatedCombo
											TickCollected += Multiplier
											AddHP(0.02*Multiplier)
											if AccuracyData.Combo > AccuracyData.MaxCombo then
												AccuracyData.MaxCombo = AccuracyData.Combo
											end
											if CurrentSlide then
												CreateHitSound(0,NoteNormalSampleSet,math.clamp(SLPositionData[CurrentSlide%2].X,0,1))
											end
										end
									else -- Combo break when player released
										if AccuracyData.Combo >= 20 then
											script.Parent.ComboBreak:Play()
										end
										if not TimeUtils.IsPaused() then
											AccuracyData.Combo = 0
											EstimatedCombo += 1
											AccuracyData.MaxConsistency += EstimatedCombo
											AccuracyData.PerfomanceCombo = 0
											AddPerfomanceScore(HitObj)
											for i = 1, Multiplier do
												DrainHP(-0.02, -0.075, -0.14)
											end
										end
									end
									AddHealthDrainMultiplier(0.7*Multiplier)
								end

								local reverseFadeInTime = math.min(SliderTime/Slides, 0.015/SongSpeed)
								local reverseFadeOutTime = 0.25/SongSpeed

								local function processReverseArrow(slideStart, slideEnd)
									slideEnd = math.min(slideEnd, Slides)
									for i = slideStart, slideEnd do
										SliderObject.clearCurrentReverseArrow(i-1, reverseFadeOutTime, reverseFadeInTime, i~=slideEnd)
									end
								end

								while TimeUtils.GetTime() < HitObj.Time/1000 + SliderTime and not Completed do
									if Slides > 1 then  -- If slides <= 1, just wait
										local CurrentSlide = math.floor((TimeUtils.GetTime() - HitObj.Time/1000)/(SliderTime/Slides))+1
										if CurrentSlide > previousSlide then
											local Multiplier = math.max(1, CurrentSlide - previousSlide) -- If it somehow passed more than 1 slides, the current hold will judge for the previous slide
											checkSlides(Multiplier, CurrentSlide)
											processReverseArrow(CurrentSlide-Multiplier+1, CurrentSlide)
										end
										previousSlide = CurrentSlide
									end
									task.wait()
								end

								if previousSlide < Slides-1 then
									local Multiplier = math.max(1, (Slides-1) - previousSlide)
									processReverseArrow(Slides-Multiplier+1, Slides)
									checkSlides(Multiplier, Slides)
								end

								AddHealthDrainMultiplier(0.7)

								if (isInFollowCircle(Slides%2) == true and script.Parent.KeyDown.Value == true) or tick() - LastHold <= 0.1 then
									-- Now we check the slider tail
									if not TimeUtils.IsPaused() then
										AccuracyData.Combo+=1
										EstimatedCombo += 1
										AccuracyData.BaseConsistency += AccuracyData.Combo
										AccuracyData.MaxConsistency += EstimatedCombo
										TickCollected += 1
										AddHP(0.02)
										if AccuracyData.Combo > AccuracyData.MaxCombo then
											AccuracyData.MaxCombo = AccuracyData.Combo
										end
										local raw = tonumber(HitObj.ExtraData[1])::number
										local raw2 = {}
										while raw > 0 do
											raw2[#raw2+1] = raw%2
											raw = math.floor(raw/2)
										end

										local HitsoundSampleset = {}
										for i = #raw2, 1, -1 do
											HitsoundSampleset[#HitsoundSampleset+1] = raw2[i]
										end

										CreateHitSound(0,NoteNormalSampleSet) -- normal
										if HitsoundSampleset[2]==1 then -- whistle
											CreateHitSound(2,NoteAditionSampleSet,math.clamp(HitObj.Position.X/512,0,1))
										end
										if HitsoundSampleset[3]==1 then -- finish
											CreateHitSound(1,NoteAditionSampleSet,math.clamp(HitObj.Position.X/512,0,1))
										end
										if HitsoundSampleset[4]==1 then -- clap
											CreateHitSound(3,NoteAditionSampleSet,math.clamp(HitObj.Position.X/512,0,1))
										end
									end
								else
									DrainHP(-0.02, -0.075, -0.14)
								end
								-----------------
								local TickRequired = Slides+1+InSliderTickRequired

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
									AddPerfomanceScore(HitObj)
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
									AddPerfomanceScore(HitObj)
								elseif TickCollected > 0 then
									AccuracyData.h50 += 1
									AddScore(50)
									if isLastComboNote then
										AddHP(0.002 + 0.03)
									else
										AddHP(0.002)
									end
									CreateSliderHitResult(2,SliderCurvePoints[#SliderCurvePoints])
									AddPerfomanceScore(HitObj)
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
									AddPerfomanceScore(HitObj)
									if AccuracyData.Combo >= 20 then
										script.Parent.ComboBreak:Play()
									end
								end
								CurrentCursorPos = HitNoteID + 1
								Completed = true
								if script.Parent.PlayFrame.Flashlight.SliderDim.isDim.Value then
									script.Parent.PlayFrame.Flashlight.SliderDim.isDim.Value = false
									TweenService:Create(script.Parent.PlayFrame.Flashlight.SliderDim,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{BackgroundTransparency = 1}):Play()
								end
								if not coreConfig.InstaFadeCircle then
									local SliderFadeOutTime = 0.2
									if SnakingOutSlider then
										SliderFadeOutTime = 0.015
									end
									TweenService:Create(SliderObject.SliderBase,TweenInfo.new(SliderFadeOutTime/SongSpeed,Enum.EasingStyle.Linear),{GroupTransparency = 1}):Play()
									TweenService:Create(FollowCircle.isFollow,TweenInfo.new(0,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Size = UDim2.new(2.25,0,2.25,0)}):Play()
									task.wait()
									TweenService:Create(FollowCircle.isFollow,TweenInfo.new(0.2/SongSpeed,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Size = UDim2.new(1.5,0,1.5,0),ImageTransparency = 1}):Play()
									FollowCircle.isFollow.Visible = tick() - LastHold <= 0.1
									TweenService:Create(FollowCircle.SliderFollowCircle,TweenInfo.new(0.015/SongSpeed,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
									FollowCircle.SliderFollowCircle:Destroy()
									task.wait(0.3/SongSpeed)
								else
									FollowCircle.SliderFollowCircle:Destroy()
								end
								SliderObject.CleanUp()
								SliderObject.SliderBase:Destroy()
								FollowCircle:Destroy()
							end)
						end)
					end)
				end
				---------------------------------------------------------------------------------------------------------


				local function UpdateHitCircleTransparency(Transparency)
					for _,obj in pairs(Circle:GetDescendants()) do
						if obj:IsA("ImageLabel") then
							if coreConfig.HiddenMod and obj.Name == "ApproachCircle" then continue end
							obj.ImageTransparency = Transparency
						end
					end
				end

				task.spawn(function()
					StreamingLoop:AddLoop(function() return (TimeUtils.GetTime())*1000 < HitObj.Time and Circle.Parent and not IsHitted end, 0, function()
						local TimeLeft = (HitObj.Time)/1000 - (TimeUtils.GetTime())
						local TimePassed = CircleApproachTime/1000 - TimeLeft
						local Size = 1+3*TimeLeft/(CircleApproachTime/1000)

						local ObjTrans = (FadeInTime - TimePassed)/FadeInTime
						if coreConfig.HiddenMod then
							if ObjTrans < 0 then
								ObjTrans = math.abs(ObjTrans)
							end
						end

						UpdateHitCircleTransparency(ObjTrans)

						if Circle:FindFirstChild("ApproachCircle") then
							Circle.ApproachCircle.Size = UDim2.new(Size,0,Size,0)
						else
							-- the object got removed, break it
							return "break"
						end

						RunService.RenderStepped:Wait()
					end)
				end)
				task.spawn(function()
					LagStrikeEvent.Event:Connect(function()
						if IsHitted then return end
						--local FixedApproachTime = -((TimeUtils.GetTime())*1000 - HitObj.Time)
						--local ApproachSize = (1-(CircleApproachTime-FixedApproachTime)/CircleApproachTime)*3 + 1.1
						--Circle.ApproachCircle.Size = UDim2.new(ApproachSize,0,ApproachSize,0)
						--local ApproachCircleTween = TweenService:Create(Circle.ApproachCircle,TweenInfo.new(FixedApproachTime/1000,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Size = UDim2.new(1.1,0,1.1,0)})
						--AddHitnoteAnimation(ApproachCircleTween)
						--ApproachCircleTween:Play()
					end)
				end)



				local CircleHitConnection = false


				task.spawn(function()
					if not coreConfig.AimAssist then return end
					repeat task.wait() until CurrentHitnote == HitNoteID or (TimeUtils.GetTime()) >= ((HitObj.Time+hit50)/1000)
					if (TimeUtils.GetTime()) >= ((HitObj.Time+hit50)/1000)  then
						return --skip
					end
					TweenService:Create(script.Parent.CursorField.AimAssitTarget,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position = UDim2.new(HitObj.Position.X/512,0,HitObj.Position.Y/384,0)}):Play()
				end)

				task.spawn(function()
					if (HitObj.Time/1000) - (TimeUtils.GetTime()) > 0 then -- prevent high delay
						task.wait((HitObj.Time/1000) - (TimeUtils.GetTime()))
						if TimeUtils.GetTime() < 10000 then
							repeat task.wait() until (TimeUtils.GetTime()) >= (HitObj.Time/1000)
						end
					end
					if IsHitted == false and not BeatmapFailed then
						Circle.ApproachCircle.Visible = false
						if not HitObjProperties.isSlider or not coreConfig.SliderMode then
							if ((HitObj.Time+hit50)/1000) - (TimeUtils.GetTime()) > 0 then
								task.wait(((HitObj.Time+hit50)/1000) - (TimeUtils.GetTime()))
								if TimeUtils.GetTime() < 10000 then
									repeat task.wait() until (TimeUtils.GetTime()) >= ((HitObj.Time+hit50)/1000) 
								end
							end
						else
							task.spawn(function()
								local t2_ = TweenService:Create(Circle.HitCircle,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1})
								AddHitnoteAnimation(t2_)
								t2_:Play()
								for _,Object in pairs(Circle:GetChildren()) do
									task.spawn(function()
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
							task.spawn(function()
								if not coreConfig.OptimizedPerfomance then
									local t2_ = TweenService:Create(Circle.HitCircle,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1})
									AddHitnoteAnimation(t2_)
									t2_:Play()
									Circle.HitCircleLightning.Visible = false
									Circle.Lightning.Visible = false
									for _,Object in pairs(Circle:GetChildren()) do
										task.spawn(function()
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
							if ((HitObj.Time+SliderHitTime*1000)/1000) - (TimeUtils.GetTime()) > 0 then
								task.wait(((HitObj.Time+SliderHitTime*1000)/1000) - (TimeUtils.GetTime()))
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
							DrainHP(-0.03, -0.125, -0.2)
							ComboNoteData.Missor50 = true
							ComboNoteData.Full300 = false
							AddPerfomanceScore(HitObj)
							CurrentHitnote = HitNoteID + 1
							TotalNotes -= 1
							if not HitObjProperties.isSlider or coreConfig.SliderMode == false then
								AccuracyData.miss += 1
								MissedInCurrentTime = true
								AddScore(0)
								HitMiss = true
								CreateHitResult(1)
							end
							task.spawn(function()
								if not Circle.Parent then return end
								if not coreConfig.InstaFadeCircle then
									local t2_ = TweenService:Create(Circle.HitCircle,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1})
									AddHitnoteAnimation(t2_)
									t2_:Play()
									if Circle.Parent then
										Circle.HitCircleLightning.Visible = false
										Circle.Lightning.Visible = false
									end
									for _,Object in pairs(Circle:GetChildren()) do
										task.spawn(function()
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
									task.wait(0.5)
								end
								clearHitCircle(Circle)
								--Circle:Destroy()
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
				task.spawn(function()
					task.wait(((HitObj.Time+hit50+1000)/1000) - (TimeUtils.GetTime()))
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

				CircleHitConnection = MouseHitRegisterEvent.Event:Connect(function(CurrentSecurityKey, unquieRegisterId)
					task.spawn(function()
						if CurrentSecurityKey ~= SecurityKey then
							return "no"
						end
						if unquieRegisterId == prevNoteRegisterId then
							return -- this input has processed the prev note, so we will ignore all other note
						end
						local FramerateFix = 0
						if not coreConfig.AutoPlay and not isSpectating and not coreConfig.ReplayMode then
							-- Experimental
							-- Since the game is likely to get input lag
							-- I'll make so that the game will add an extra timing
							-- Player's input will be half frame earlier
							FramerateFix = (tick() - LastFramerate) * 1000 * 0.5
						end
						local CurrentTime = (TimeUtils.GetTime())*1000 - FramerateFix
						local HitDelay = CurrentTime - HitObj.Time
						if IsHitted == false then
							-- local spectatingRetryCount = 10

							--[[
							-- I'm leaving a chance of hit for TD mod
							while (ReplayMode or isSpectating) and (HitDelay <= hit50 and not isincircle()) and spectatingRetryCount < 5 do
								spectatingRetryCount+= 1
								task.wait()
							end]]
							if ClassicNotelock == true then -- osu!stable notelock
								-- Prevent players from hitting note without clearing previous note
								if CurrentHitnote < HitNoteID then
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
									if not HitObjProperties.isSlider or coreConfig.SliderMode == false then
										AccuracyData.miss += 1
										MissedInCurrentTime = true
										AddScore(0)
										CreateHitResult(1)
										AddPerfomanceScore(HitObj)
									end
									DrainHP(-0.03, -0.125, -0.2)
									ComboNoteData.Missor50 = true
									ComboNoteData.Full300 = false
									HitMiss = true
									Circle.ApproachCircle.Visible = false
									clearHitCircle(Circle)
									--Circle:Destroy()

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
								-- once passed all the note, this input will be used
								-- and no other circle can process this input session
								prevNoteRegisterId = unquieRegisterId

								IsHitted = true
								DisplayingHitnote[HitNoteID].IsHitted = true
								task.spawn(function()
									task.wait()
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
									DrainHP(-0.03, -0.125, -0.2)
									CreateHitDelay(Color3.new(1, 0.372549, 0.372549),HitDelay)
									ComboNoteData.Missor50 = true
									ComboNoteData.Full300 = false
									if not HitObjProperties.isSlider or coreConfig.SliderMode == false then
										AccuracyData.miss += 1
										MissedInCurrentTime = true
										AddScore(0)
										CreateHitResult(1)
										AddPerfomanceScore(HitObj)
									end
									HitMiss = true
									task.spawn(function()
										if Circle.Parent == nil then return end
										if not coreConfig.InstaFadeCircle then
											local t2_ = TweenService:Create(Circle.HitCircle,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1})
											AddHitnoteAnimation(t2_)
											t2_:Play()
											Circle.HitCircleLightning.Visible = false
											Circle.Lightning.Visible = false
											for _,Object in pairs(Circle:GetChildren()) do
												task.spawn(function()
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
											task.wait(0.5)
										end
										clearHitCircle(Circle)
										--Circle:Destroy()
									end)
									if Circle.Parent then
										Circle.ApproachCircle.Visible = false
									end
								else
									if Circle.Parent then
										Circle.ApproachCircle.Visible = false
									end

									if not TimeUtils.IsPaused() then
										AccuracyData.Combo += 1
										EstimatedCombo += 1										
									end
									AccuracyData.BaseConsistency += AccuracyData.Combo
									AccuracyData.MaxConsistency += EstimatedCombo
									TickCollected += 1
									LastHold = tick()

									if AccuracyData.Combo > AccuracyData.MaxCombo then
										AccuracyData.MaxCombo = AccuracyData.Combo
									end
									task.spawn(function()
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
									if not HitObjProperties.isSlider or coreConfig.SliderMode == false then
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
											AddPerfomanceScore(HitObj)
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
											AddPerfomanceScore(HitObj)
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
											AddPerfomanceScore(HitObj)
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

									if not coreConfig.InstaFadeCircle then
										local t_ = TweenService:Create(Circle,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Size = UDim2.new(CircleSize*1.25/384,0,CircleSize*1.25/384,0)})
										local t2_ = TweenService:Create(Circle.HitCircle,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{ImageTransparency = 1})
										AddHitnoteAnimation(t_)
										AddHitnoteAnimation(t2_)
										t_:Play()
										t2_:Play()
										Circle.HitCircleLightning.Visible = false
										Circle.Lightning.Visible = false

										-- process the fade out circle

										for _,Object in pairs(Circle:GetChildren()) do
											task.spawn(function()
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
										task.wait(0.25)
									end
									clearHitCircle(Circle)
									--Circle:Destroy()
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
		if coreConfig.ReplayMode then
			replayReady = false
			replayReRun = true

			repeat task.wait() until replayReady
			replayReRun = false
		end

		isIn_GameQuickRestart = false
		LetTheGameBegin() 
	end
end

LetTheGameBegin()

isDrain = false
TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = coreConfig.DefaultBackgroundTrans}):Play()


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
		task.wait(1.5)
	end 
end

if isSpectating == false then
	repeat task.wait() until TimeUtils.GetTime() > (BeatmapData[#BeatmapData].Time + hit50)/1000

	local Type = BeatmapData[#BeatmapData].Type


	if ObjectTools.GetObjectProperties(Type).isSpinner then
		repeat task.wait() until (TimeUtils.GetTime()) >= BeatmapData[#BeatmapData].SpinTime/1000
		TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.4}):Play()
		script.Parent.Leaderboard.LbTrigger:Fire(true)
		script.Parent.MultiplayerLeaderboard.LbTrigger:Fire(true)
		FLAnimate = false
		TweenService:Create(FlashlightFrame,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = UDim2.new(30,0,30,0),ImageTransparency = 0}):Play()
		doAnim()
		checkSSAnim()
		task.wait(2)
	else
		repeat task.wait() until LastNoteData ~= "NotLoaded"
		if LastNoteData.Slider == true then
			task.wait(LastNoteData.SliderTime)
		end
		TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.4}):Play()
		script.Parent.Leaderboard.LbTrigger:Fire(true)
		script.Parent.MultiplayerLeaderboard.LbTrigger:Fire(true)
		FLAnimate = false
		TweenService:Create(FlashlightFrame,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = UDim2.new(30,0,30,0),ImageTransparency = 0}):Play()
		checkSSAnim()
		doAnim()
		task.wait(2)
	end
else
	repeat task.wait() until ScoreResultDisplay == true
	FLAnimate = false
	TweenService:Create(FlashlightFrame,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Size = UDim2.new(30,0,30,0),ImageTransparency = 0}):Play()
	TweenService:Create(PlayerGui.BG.Background.Background.BackgroundDim,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.4}):Play()
	script.Parent.Leaderboard.LbTrigger:Fire(true)
	script.Parent.MultiplayerLeaderboard.LbTrigger:Fire(true)
end




if BeatmapFailed and not coreConfig.OnMultiplayer then
	PlayerGui.NotificationPopup.NotificationsPopup.ClientCreateNotification:Fire("Dude, how did you failed on that last note!",Color3.fromRGB(255,0,0))
	return -- just in case they failed on the last note
end


if coreConfig.OnMultiplayer then
	script.Parent.MultiplayerWaitFrame.Visible = true
	PlayerGui.MenuInterface.MultiplayerPanel.MultiplayerScript.MultiplayerRoom.MultiplayerFolder.Value.WaitForFinish:InvokeServer()
	script.Parent.MultiplayerWaitFrame.Visible = false
end

ScoreResultDisplay = true

if coreConfig.ReplayMode == false then
	ReplayRecordEnabled = false

	local Data = HttpService:JSONEncode(ReplayData)

	script.Parent.Replay.Value = Data
end

task.spawn(function()
	TweenService:Create(script.Parent.GameSong.Song,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true),{Volume = 0.5}):Play()
end)
--TweenService:Create(script.Parent.Interface.BG,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true),{BackgroundTransparency = 0}):Play()
task.wait(0.25)
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


task.spawn(function()
	task.wait(1.1)
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
local RawAccuracy = ((AccuracyData.h300*300+AccuracyData.h100*100+AccuracyData.h50*50)/(TotalNoteResult*300))*100
local GameAccuracy = math.floor((RawAccuracy)*100)/100
local tostringAcc = string.format("%s%s",string.format("%.2d",GameAccuracy),string.sub(string.format("%.2f",GameAccuracy%1),2,4))
ResultFrame.Accuracy.Text = string.format("%dx/%dx | %s%%", AccuracyData.MaxCombo, ReturnData.Difficulty.MaxCombo, tostringAcc)

local GameplayRank = "D"
local percent300s = AccuracyData.h300/(AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss)
local percent50s = AccuracyData.h50/(AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss)
local misstotal = AccuracyData.miss

local SS = false

if GameAccuracy >= 70 then
	GameplayRank = "C"
end
if GameAccuracy >= 80 then
	GameplayRank = "B"
end
if GameAccuracy >= 90 then
	GameplayRank = "A"
end
if GameAccuracy >= 95 and misstotal <= 0 then
	GameplayRank = "S"
end
if GameAccuracy >= 100 then
	GameplayRank = "SS"
	SS = true
end

ResultFrame.Parent.Parent.ResultFrameAnim.Disabled = false

task.spawn(function()
	local AccuracyValue = 0

	if GameAccuracy < 70 then
		AccuracyValue = math.min(GameAccuracy/70*0.4,0.4)
	elseif GameAccuracy < 95 or misstotal > 0 then
		AccuracyValue = math.min(0.4 + (GameAccuracy-70)/30*0.45, 0.845)
	else
		AccuracyValue = 0.85 + (GameAccuracy-95)/5*0.15
	end

	task.wait(0.5)
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
if coreConfig.StoryboardAvailable then
	storyboardUI.Enabled = false
end

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,true)

----------- Calculate perfomance score -----------
local _accData:PerformanceCalculator.AccuracyData = {
	h300 = AccuracyData.h300, h100 = AccuracyData.h100,
	h50 = AccuracyData.h50, missCount = AccuracyData.miss
}
LivePlaySession:ProcessFinalResult(_accData)
local TotalRewardedPS = LivePlaySession.CurrentPerformance

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
Score = getScoreV1() -- overwrite the current score

if coreConfig.ScoreV2Enabled then
	--local ScoreV2AccScore = math.pow((AccuracyData.h300*300+AccuracyData.h100*300+AccuracyData.h50*300+AccuracyData.miss*300)/300,2.265) * ScoreMultiplier.Difficulty * ScoreMultiplier.Mod * 0.3
	--local ScoreV2 = math.pow(Score/(TotalScoreEstimated*0.8 + ScoreV2AccScore)*(NoteCompleted/NoteTotal),0.768621)*(NoteCompleted/NoteTotal)*1000000
	local ScoreV2 = getScoreV2()
	ResultFrame.Score.Text = "Score: <b>"..GetNewNum(string.format("%.0f",ScoreV2)).." ["..GetNewNum(tostring(math.floor(Score))).."]</b>"
else
	ResultFrame.Score.Text = "Score: <b>"..GetNewNum(tostring(math.floor(Score))).."</b>"	
end
--ResultFrame.Grade.Text = (not SS and GameplayRank) or "S"
--ResultFrame.Grade.TextColor3 = RankColor[GameplayRank]
task.spawn(function()
	local GradeFrame = ResultFrame.GradeHugeDisplay
	local RankingDisplayID = script.GradeDisplay["Rank_"..GameplayRank].Image

	GradeFrame.BaseDisplay.Image = RankingDisplayID
	GradeFrame.EffectDisplay.Image = RankingDisplayID

	task.wait(1.75)
	TweenService:Create(GradeFrame.BaseDisplay,TweenInfo.new(0.75,Enum.EasingStyle.Exponential,Enum.EasingDirection.In),{Size = UDim2.new(1,0,1,0),ImageTransparency = 0}):Play()
	task.wait(0.75)
	GradeFrame.EffectDisplay.Visible = true
	TweenService:Create(GradeFrame.EffectDisplay,TweenInfo.new(2,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Size = UDim2.new(1.5,0,1.5,0)}):Play()
	TweenService:Create(GradeFrame.EffectDisplay,TweenInfo.new(2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()
end)
SubmitTime = os.date("*t", coreConfig.ReplayMode and FinaleReplayData.Date or nil)

local DisplayUser = coreConfig.AutoPlay and "osu!AT" or (coreConfig.ReplayMode and FinaleReplayData.User) or LocalPlayer.Name
DisplaySubmitTime = string.format("Played by %s on %.2d/%.2d/%.4d %.2d:%.2d:%.2d", DisplayUser, SubmitTime.day, SubmitTime.month, SubmitTime.year, SubmitTime.hour, SubmitTime.min, SubmitTime.sec)
DisplayModPlayed = (function()
	local ModDisplay = " | "
	local mods = {}

	-- Check which mods are active and add them to the mods table
	if coreConfig.AutoPlay then table.insert(mods, "AT") end
	if coreConfig.ScoreV2Enabled then table.insert(mods, ",V2") end
	if coreConfig.TouchDeviceDetected then table.insert(mods, ",TD") end
	if coreConfig.NoFail then table.insert(mods, ",NF") end
	if coreConfig.HiddenMod then table.insert(mods, ",HD") end
	if coreConfig.HardRock then table.insert(mods, ",HR") end
	if coreConfig.EasyMod then table.insert(mods, ",EZ") end
	if not coreConfig.SliderMode then table.insert(mods, ",NS") end
	if coreConfig.Flashlight then table.insert(mods, ",FL") end
	if ClassicNotelock then table.insert(mods, ",CL") end

	-- Check for SongSpeed and format if necessary
	if SongSpeed ~= 1 then
		if SongSpeed == 1.5 then
			table.insert(mods, "DT")
		elseif SongSpeed == 0.75 then
			table.insert(mods, "HT")
		else
			table.insert(mods, string.format(",SA(%sx)", tostring(math.round(SongSpeed * 100) / 100)))
		end
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

if (GameplayRank == "S" or SS) and (coreConfig.HiddenMod or coreConfig.Flashlight) then
	ResultFrame.Grade.TextColor3 = Color3.fromRGB(177,177,177)
end

OnlineResult.OnlineScore.Score.Text = GetNewNum(math.floor(Score))
OnlineResult.OnlineAccuracy.Accuracy.Text = tostringAcc.."%"
OnlineResult.OnlineMaxCombo.MaxCombo.Text = GetNewNum(AccuracyData.MaxCombo).."x"
OnlineResult.OnlinePS.PerfomanceScore.Text = GetNewNum(math.floor(TotalRewardedPS)).."ps"
OnlineResult.OverallPerfomance.TotalPS.Text = LocalPlayer.leaderstats.Performance.Value

-- AccurancyChart
local AccurancyChartFrame = ResultFrame.AccurancyChart.MainFrame.MainFrame

local FrameList = {}
local LastDataAccuracy = 1

for i,Accurancy in pairs(TimeAccurancy) do
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
			task.spawn(function()
				if value ~= 1 then
					task.wait(((i-1)/#FrameList)*3)
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

		task.spawn(function()
			task.wait(3)
			change(1)
			local currentpos = workspace.CurrentCamera.ViewportSize
			StreamingLoop:AddLoop(function() return true end, 2, function()
				if workspace.CurrentCamera.ViewportSize ~= currentpos then
					currentpos = workspace.CurrentCamera.ViewportSize
					change(1)
				end
			end)
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

			task.spawn(function()
				if value ~= 1 then
					task.wait(((i-1)/#PerfomanceFrameList)*3)
					TweenService:Create(ChartFrame.ConnectionFrame,TweenInfo.new((1/#PerfomanceFrameList)*3,Enum.EasingStyle.Linear),{Position = UDim2.new(0.5,0,AvgPos,0),Size = UDim2.new(0,ConnectionLength+2,0,2),Rotation = Rotation}):Play()
					TweenService:Create(ChartFrame.GraphFrame,TweenInfo.new((1/#FrameList)*3,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.9}):Play()
				else
					ChartFrame.ConnectionFrame.Size = UDim2.new(0,ConnectionLength+2,0,2)
					ChartFrame.ConnectionFrame.Rotation = Rotation
				end
			end)
		end
		change()

		task.spawn(function()
			task.wait(3)
			change(1)
			local currentpos = workspace.CurrentCamera.ViewportSize
			StreamingLoop:AddLoop(function() return true end, 2, function()
				if workspace.CurrentCamera.ViewportSize ~= currentpos then
					currentpos = workspace.CurrentCamera.ViewportSize
					change(1)
				end
			end)
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


for i,a in pairs(AccuracyData.HitErrorGraph) do
	local Frame = script.OffsetFrame:Clone()
	Frame.Parent = OffsetFrame.MainFrame.MainFrame
	local ExtraVerticalSize = math.round(1/99*workspace.Camera.ViewportSize.X*0.728625)-2
	Frame.Size = UDim2.new(1/99,-2,a[3]/HighestHitErrorClick,ExtraVerticalSize)

	if a[3] <= 0 then
		Frame.BackgroundColor3 = Color3.new(0.333333, 0.333333, 0.333333)
	else
		if i == 1 then
			Frame.BackgroundColor3 = Color3.new(1, 1, 1)
		elseif math.abs(a[1]) <= hit300 then
			Frame.BackgroundColor3 = Color3.new(0.294118, 0.764706, 1)
		elseif math.abs(a[1]) <= hit100 then
			Frame.BackgroundColor3 = Color3.new(0.294118, 1, 0.294118)
		elseif math.abs(a[1]) <= hit50 then
			Frame.BackgroundColor3 = Color3.new(1, 1, 0.294118)		
		else
			Frame.BackgroundColor3 = Color3.new(1, 0.294118, 0.294118)					
		end 
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

-- Analytics
if PlayRanked then
	game.ReplicatedStorage.AnalyticFunnelEvent:FireServer("Finished a map", 3)
	game.ReplicatedStorage.AnalyticCustomEvent:FireServer("Offset distribution", OffsetOverall, customFields)
	game.ReplicatedStorage.AnalyticCustomEvent:FireServer("Unstable rate distribution", UnstableRate, customFields)
	game.ReplicatedStorage.AnalyticCustomEvent:FireServer("Accuracy distribution", GameAccuracy, customFields)
	game.ReplicatedStorage.AnalyticCustomEvent:FireServer("Difficulty finished distribution", ReturnData.Difficulty.BeatmapDifficulty, customFields)
	game.ReplicatedStorage.AnalyticCustomEvent:FireServer("Performance distribution", TotalRewardedPS, customFields)
end

-----

if isSpectating == true then
	OnlineResult.OnlinePS.PerfomanceScore.Text = "-"
end

ResultFrame.Parent.Parent.Visible = true

if coreConfig.AutoPlay == true and coreConfig.ReplayMode ~= true then
	--TweenService:Create(Cursor,TweenInfo.new(1,Enum.EasingStyle.Sine),{Position = UDim2.new(0.5,0,1.5,0)}):Play()
end

local CanbeSubmitted = true

if coreConfig.NoFail and Score < 1000 then
	CanbeSubmitted = false
end

if not coreConfig.ReplayMode and not isSpectating and not onTutorial --[[and not RunService:IsStudio()]] then
	local function get(format)
		local BooleanFormat = {["true"] = "1", ["false"] = "0"}

		return BooleanFormat[tostring(format)]
	end
	local ReplayVersion = "VERSION 2\n"
	local PlayerName = "USER "..((not coreConfig.AutoPlay and LocalPlayer.Name) or "osu!AT").."\n"
	local DateFormat = "DATE "..tostring(os.time()).."\n"
	-- MOD StableNL EnableTouchDevice AT NF HD HR EZ SL FL
	local ModFormat = "MOD "..get(ClassicNotelock)..get(IsTouchDeviceActive())
		..get(coreConfig.AutoPlay)..get(coreConfig.NoFail)..get(coreConfig.HiddenMod)..get(coreConfig.HardRock)..get(coreConfig.EasyMod)..get(coreConfig.SliderMode)..get(coreConfig.Flashlight).."\n"
	local SpeedFormat = "SPEED "..tostring(SongSpeed).."\n"
	local FilenameForamt = "FILENAME "..Beatmap.Name.."\n"
	local ScoreFormat = "SCORE "..tostring(math.round(Score)).."\n"
	local MaxcomboFormat = "MAXCOMBO "..tostring(math.round(AccuracyData.MaxCombo)).."\n"
	local PSFormat = "PS "..tostring(math.round(CurrentPerfomance)).."\n"
	local AccuracyFormat = "ACCURACY "..tostring(AccuracyData.h300).." "..tostring(AccuracyData.h100).." "..tostring(AccuracyData.h50).." "..tostring(AccuracyData.miss).."\n"

	ReplayDataEncoded = "\nOVERALL\n"..ReplayVersion..PlayerName..DateFormat..ModFormat..SpeedFormat..FilenameForamt..ScoreFormat..MaxcomboFormat..PSFormat..AccuracyFormat.."REPLAY\n"..ReplayDataEncoded

	game.ReplicatedStorage.ClientCommunication.UpdateLocalReplayData:Invoke(ReplayDataEncoded)
end

if not coreConfig.ReplayMode and not isSpectating and not onTutorial then
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

--[[
	Version 0:
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
		
	Version 1:
	ExtraData = {
			Version = 1,
			HaveReplay = CanUploadReplay,
			Accuracy = GameAccuracy,
			MaxCombo = AccuracyData.MaxCombo,
			Date = os.time(),
			Statistic = {
				h300 = AccuracyData.h300,
				h100 = AccuracyData.h100,
				h50 = AccuracyData.h50,
				missCount = AccuracyData.miss
			},
			Performance = TotalRewardedPS,
			ModData = {
				FL = Flashlight,
				NS = not SliderMode,
				NF = NoFail,
				HD = HiddenMod,
				HR = HardRock,
				EZ = EasyMod,
				AT = AutoPlay,
				TD = TouchDeviceDetected,
				SA = SongSpeed
			},
			Score = RankedScore,
			ScoreV2 = getScoreV2(),			
			Consistency = getConsistency(),
		}::ScoreStatistic,
]]

--[[
	Versions:
	*no specified* (We will call it 0) - V1.47.3 and before
	1 - V1.47.4 and beyond
]]

type ScoreStatistic = {
	Version:number,
	HaveReplay:boolean,
	Accuracy:number,
	MaxCombo:number,
	Date:number,
	Statistic:{
		h300:number,
		h100:number,
		h50:number,
		missCount:number
	},
	ModData:modData.ModData,
	Consistency:number,
	Score:number,
	ScoreV2:number,
	Performance:number
}

if PlayRanked == true and CanbeSubmitted then
	local RankedScore = math.round(Score)
	OnlineResult.SubmitStatus.Text = "Submitting score"
	--ResultFrame.Score.Text = "[Submitting...]"
	local _datastoreScope = `{ReturnData.BeatmapSetsData.BeatmapsetID}-{ReturnData.BeatmapSetsData.BeatmapID}`
	local ReturnResult = game.ReplicatedStorage.BeatmapLeaderboard:InvokeServer(2,{
		DatastoreName = _datastoreScope,
		BeatmapKey = ReturnData.BeatmapSetsData.BeatmapID,
		PlayData = {
			Score = RankedScore,
			ReplayData = (CanUploadReplay and ReplayDataEncoded) or "",
			ExtraData = {
				Version = 1,
				HaveReplay = CanUploadReplay,
				Accuracy = GameAccuracy,
				MaxCombo = AccuracyData.MaxCombo,
				Date = os.time(),
				Statistic = {
					h300 = AccuracyData.h300,
					h100 = AccuracyData.h100,
					h50 = AccuracyData.h50,
					missCount = AccuracyData.miss
				},
				Performance = TotalRewardedPS,
				ModData = {
					FL = coreConfig.Flashlight,
					NS = not coreConfig.SliderMode,
					NF = coreConfig.NoFail,
					HD = coreConfig.HiddenMod,
					HR = coreConfig.HardRock,
					EZ = coreConfig.EasyMod,
					AT = coreConfig.AutoPlay,
					TD = coreConfig.TouchDeviceDetected,
					SA = SongSpeed
				},
				Score = RankedScore,
				ScoreV2 = getScoreV2(),			
				Consistency = getConsistency(),
			}::ScoreStatistic,
			BadgeCondition = BadgeCondition,
			SecurityData = {	-- This let the server re-check again if the sending data is actually correct or not
				BeatmapName = Beatmap.Name,
				beatmapid = ReturnData.BeatmapSetsData.BeatmapID,
				metadata = ReturnData.Overview.Metadata,	-- The beatmap information for report gathering
				SecurityKey = ServerSecurityKey -- A key to let the server know if it's a true obtained score
			}
		}})

	local OldScore = ReturnResult.Score

	repeat task.wait() until OnlineResult.Visible == true

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
		OnlineResult.OverallPerfomance.TotalPS.Text = LocalPlayer.leaderstats.Performance.Value
		OnlineResult.OverallPerfomance.Improvement.Text = "-"
	end

	OnlineResult.SubmitStatus.Text = ""
	--ResultFrame.Score.Text = "Score: "..tostring(RankedScore)..ExtraText
else
	if isSpectating == true or coreConfig.ReplayMode then
		OnlineResult.SubmitStatus.Text = ""
	elseif coreConfig.AutoPlay then
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

--------------->	2021 - 2026 osu!RoVer	<---------------
-- osu!corescript (OsuGame) by VtntGaming
-- String size: 315.14KB (V1.49)

-- Gameplay inspired by osu! and osu!lazer from ppy
-- Source code mostly used as a backup script.
-- Some mechanic might be taken from osu! github open source.
-- Hope some future Roblox developer can take this "spaghetti code" and improve.
----------------- End script -----------------
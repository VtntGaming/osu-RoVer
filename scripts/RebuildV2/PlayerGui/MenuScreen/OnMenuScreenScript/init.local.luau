local SystemGame = script.Parent.Parent:WaitForChild("SystemGame")
local Song = SystemGame.Song.GameSong
local Song2 = SystemGame.Song.GameSong2
local SongEffectAnalyzer = SystemGame.Song.SongBeatEffect.AudioAnalyzer
local BackgroundFrame = script.Parent.Parent.GameBackground
local TweenService = game:GetService("TweenService")
local SongData = Song.Parent.SongPlayingValue
local SongChoosingValue = SystemGame.Beatmap.SongChoosing
local MapListing = workspace.BeatmapListings
local SongPlayingFrame = script.Parent.MainScreen.SongPlaying
local ContentProvider = game:GetService("ContentProvider")
local CurrentSession = ""
local MainScreen = script.Parent.MainScreen
local SelectScreen = MainScreen.SelectScreen
local ChoosingBar = SelectScreen.ChoosingBar
local SongRandomizer = require(script.SongRandomizer)

local NextChoosen = 0


local function DoInitialSelectScreenAnim()
	local t = TweenService:Create(ChoosingBar, TweenInfo.new(0), {
		Size = UDim2.fromScale(1, 0)
	})
	
	local t2 = TweenService:Create(MainScreen, TweenInfo.new(0), {
		Position = UDim2.fromScale(-1, 0)
	})
	
	t:Play()
	t2:Play()
	if t.PlaybackState ~= Enum.PlaybackState.Completed then
		t.Completed:Wait()
	end

	if t2.PlaybackState ~= Enum.PlaybackState.Completed then
		t2.Completed:Wait()
	end
	TweenService:Create(ChoosingBar, TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(1, 0.4)
	}):Play()

	TweenService:Create(MainScreen, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0, 0)
	}):Play()
end

local function DoOuterAnimation()
	TweenService:Create(ChoosingBar, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
		Size = UDim2.fromScale(1, 0)
	}):Play()
	TweenService:Create(MainScreen, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
		Position = UDim2.fromScale(-0.5, 0)
	}):Play()
end

-- Config when the script enabled
Song.Looping = true
script.Parent.Enabled = true
script.Parent.OnClose.Value = false
DoInitialSelectScreenAnim()
TweenService:Create(BackgroundFrame.DimBackground,TweenInfo.new(1,Enum.EasingStyle.Linear),{BackgroundTransparency = 1}):Play()

-- I need to ensure every set is equal and no duplicated song
local MapList = MapListing:GetChildren()
if not SongRandomizer.IsSettedUp then
	SongRandomizer:Setup(MapList)
end

function GetValue(Data,Pattern,Space)
	if not Space then
		Space = 1
	end

	local _,s = string.find(Data,Pattern)
	if not s then return end

	local e,_ = string.find(Data,"\n",s)
	if not e then e = #Data end

	return string.sub(Data,s+1+Space,e-1)
end

function LoadNextChoosen()
	spawn(function()
		local Map = MapList[NextChoosen]
		local MapData = require(Map)
		local SongId = GetValue(MapData,"RblxSoundID:")
		local ImageId = GetValue(MapData,"BackgroundImageId:") or "0"

		local data = {"rbxassetid://"..SongId,"rbxassetid://"..ImageId}
		ContentProvider:PreloadAsync(data)
	end)
end

local onSwitching = false

function LoadCurrentMapDesc(map)
	local MapData = require(map)
	local ArtistName = GetValue(MapData,"Artist:",0)
	local SongName = GetValue(MapData,"Title:",0)
	SongPlayingFrame.PlayingSong.Text = ArtistName.." - "..SongName
end

local function PickRandomIndex(): number
	local mapPick = SongRandomizer:PickMap()
	local index = table.find(MapList, mapPick) or math.random(1, #MapList)
	
	return index
end

function SwitchSong(customMap)
	local Listing = MapListing:GetChildren()
	local CurrentChoosen = NextChoosen
	if CurrentChoosen == 0 then
		CurrentChoosen = PickRandomIndex()
	end
	local Choosen = customMap or Listing[CurrentChoosen]
	local ThisSession = game:GetService("HttpService"):GenerateGUID()
	CurrentSession = ThisSession
	
	NextChoosen = PickRandomIndex()
	LoadNextChoosen()
	
	onSwitching = true
	
	SongChoosingValue.Value = Choosen
	
	onSwitching = false

	local MapData = require(Choosen)

	local SongId = GetValue(MapData,"RblxSoundID:")
	local SongId2 = GetValue(MapData,"RblxSoundID2:")
	local ImageId = GetValue(MapData,"BackgroundImageId:") or "0"
	local SongName = GetValue(MapData,"Title:",0)
	local ArtistName = GetValue(MapData,"Artist:",0)
	local SongSpeed = GetValue(MapData,"SongSpeed:") or 1
	local SongPitch = GetValue(MapData,"SongPitch:")
	local SongVolume = GetValue(MapData,"BeatmapVolume:") or 1
	
	BackgroundFrame.ChangeRequest:Fire(ImageId)

	SongPlayingFrame.PlayingSong.Text = ArtistName.." - "..SongName
	
	Song:Stop()
	Song.TimePosition = 0
	Song.PlaybackSpeed = SongSpeed
	Song.Asset = "rbxassetid://"..SongId
	Song.Volume = SongVolume
	
	Song2:Stop()
	if SongId2 then
		Song2.TimePosition = 0
		Song2.Asset = "rbxassetid://"..SongId2
		Song2.PlaybackSpeed = SongSpeed
		Song2.Volume = SongVolume
	else
		Song2.Asset = ""
	end	
	
	if not Song.IsReady then
		local s = tick()
		repeat task.wait() until Song.IsReady or tick() - s > 10
		
		if not Song.IsReady and ThisSession == CurrentSession then
			SwitchSong()
			return
		end
	end
	Song:Play()
end

SongChoosingValue:GetPropertyChangedSignal("Value"):Connect(function()
	if onSwitching == false then
		-- directly switch to the selected song if the map manually changed
		-- this is likely a developer only feature
		
		SwitchSong(SongChoosingValue.Value)
	end
end)

function UpdateSongProgress()
	local totalLength = Song.TimeLength
	local timePosition = Song.TimePosition
	
	if Song2.Asset ~= "" then
		totalLength += Song2.TimeLength
		
		if Song2.IsPlaying then
			timePosition = Song.TimeLength + Song2.TimePosition
		end
	end
	
	local Progress = timePosition / totalLength
	if Progress > 1 or Progress ~= Progress then
		Progress = 0
	end

	SongPlayingFrame.SongProgress.Progress.Size = UDim2.new(Progress,0,1,0)
end
spawn(function()
	while task.wait(.5) do
		UpdateSongProgress()
	end
end)

if SongChoosingValue.Value then
	LoadCurrentMapDesc(SongChoosingValue.Value)
end

if not Song.IsPlaying and not Song2.IsPlaying then
	task.spawn(function()
		SwitchSong()
	end)
end
SongPlayingFrame.ActionFrame.Pause.MouseButton1Click:Connect(function()
	if Song.IsReady then
		Song.IsPlaying = not Song.IsPlaying
	else
		Song.IsPlaying = false
	end
end)
SongPlayingFrame.ActionFrame.NextSong.MouseButton1Click:Connect(SwitchSong)
Song.Looped:Connect(function()
	if Song2.Asset ~= "" then
		Song:Stop()
		Song2:Play()
	else
		SwitchSong()
	end
end)

Song2.Looped:Connect(function()
	SwitchSong()
end)

local Count = 0
local Offset = 0
local Previous = 0

function GetPositionX()
	local pos = math.random() * 0.5
	
	if Previous < 0.5 then
		pos += 0.5
	end
	
	return pos
end

local GameIcon = script.Parent.MainScreen.SelectScreen.MainIcon.GameIcon

local loudnessPerSec = 0
local records = 0

local function GetAudioBeatRate()
	local rmsLevel = SongEffectAnalyzer.PeakLevel * 0.25 + SongEffectAnalyzer.RmsLevel * 0.75
	
	return rmsLevel
end

task.spawn(function()	
	while task.wait() do
		local Size = 2 + math.pow(GetAudioBeatRate(),2) / 14
		GameIcon.Size = UDim2.new(Size,0,Size,0)
		task.spawn(function()
			local current = (0.1 + math.pow(GetAudioBeatRate(),2)/3.5)
			loudnessPerSec += current
			records += 1
			task.wait(1)
			records -= 1
			loudnessPerSec -= current
		end)
	end
end)

local isBreak = false
local BreakRequest = false
local onEnteringGame = false
local SelectFrame = script.Parent.MainScreen.SelectScreen

function EnterGame()
	if onEnteringGame then return end
	onEnteringGame = true
	BreakRequest = true
	script.Parent.OnClose.Value = true
	repeat task.wait() until isBreak == false
	DoOuterAnimation()
	task.wait(0.25)

	script.Parent.Enabled = false
	script.Parent.Parent.MapSelectionScreen.Controllers.SetEnabled:Fire(true)
	--script.Parent.Parent.MainGameplay.OsuGame.Disabled = false
	script.Disabled = true
end

GameIcon.Parent.TriggerButton.MouseButton1Click:Connect(EnterGame)
SelectFrame.ChoosingBar.MainFrame.Right.PlayButton.TriggerButton.MouseButton1Click:Connect(EnterGame)

script.Parent.MainScreen.BackgroundEffect:ClearAllChildren()

local Processes = {}

function CreateTriangle(CustomYPos)	
	local PositionX = GetPositionX()
	Count += 1
	Offset += PositionX
	Previous = PositionX

	local Size = math.random(200,400)/1000
	local SpeedMultiplier = Size/0.2 * 0.5
	local Progress = CustomYPos or 1.5


	local obj = script.Triangle:Clone()
	obj.Parent = script.Parent.MainScreen.BackgroundEffect
	obj.Position = UDim2.new(PositionX,0,Progress,0)
	obj.ZIndex = -Size
	obj.Size = UDim2.new(Size,0,Size,0)
	obj.ImageColor3 = Color3.fromHSV(0.933333, 0.5063287, 0.5+(0.2-(Size-0.2))/0.2*0.45)
	obj.ImageLabel.ImageColor3 = Color3.fromHSV(0.933333, 0.5063287, 0.5+(0.2-(Size-0.2))/0.2*0.45)
	if CustomYPos then
		obj.ImageTransparency = 1
		obj.ImageLabel.ImageTransparency = 1
		
		TweenService:Create(obj,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{ImageTransparency = 0.75}):Play()
		TweenService:Create(obj.ImageLabel,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{ImageTransparency = 0}):Play()		
	end
	
	local breakActivated = false
	local breakClock = 0
	
	local cb : (dt: number, audioBeatRate: number) -> ()
	cb = function(dt: number, audioBeatRate: number)
		if Progress <= -0.5 then
			local index = table.find(Processes, cb)
			
			if index then
				table.remove(Processes, index)
			end			

			obj:Destroy()
			
			return
		end
		
		local breakSpeed = (math.max(0, breakClock) ^ 1.5) * 20
		local Speed = (0.1 + math.pow(audioBeatRate,2)/3.5) * dt * SpeedMultiplier + breakSpeed * dt

		Progress -= Speed
		obj.Position = UDim2.new(PositionX,0,Progress,0)
		Count -= 1
		Offset -= PositionX

		if BreakRequest then
			if not breakActivated then
				breakActivated = true
				breakClock = -((Progress ^ 2) * 0.1)
			end
			breakClock += dt
		end
	end
	
	table.insert(Processes, cb)
end

local elapsed = 0
local enableTriangles = true

task.spawn(function()
	while true do
		local dt = task.wait()
		local audioBeatRate = GetAudioBeatRate()
		for _, cb in ipairs(Processes) do
			cb(dt, audioBeatRate)
		end
		
		if enableTriangles then
			if BreakRequest then
				enableTriangles = false
				continue
			end
			
			elapsed += dt
			local requirement = 0.1/math.min(10,loudnessPerSec/records)
			if elapsed >= requirement then
				CreateTriangle()
				elapsed -= requirement
			end
		end
	end
end)

for i = 0, 15 do
	CreateTriangle(i/10)
	task.wait(.05)
end
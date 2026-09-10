--!native
--[[
	-> OsuGame.lua <-
	-> osu!RoVer RebuildVer Beta V2.0 <-
	-> Written by VtntGaming <-
	-> Size: 10.66kB <-
]]

-- Services

local TweenService = game:GetService("TweenService")

-- Default functions

local wait = require(workspace.WaitModule)

-- Core data

local SystemGame = game.Players.LocalPlayer.PlayerGui.SystemGame
local PlayScreen = script.Parent.Parent.PlayScreen.MainGameplay
local GameSong = SystemGame.Song.GameSong
local GameSong2 = SystemGame.Song.GameSong2
local GameTime = require(script.Parent.GameTime)

-- Game data

local SelectedMap = SystemGame.Beatmap.SongChoosing.Value
local OsuMapConvert = workspace.Gameplay.OsuMapConvert
local inputEvent = Instance.new("BindableEvent")
local MapData = require(OsuMapConvert)(SelectedMap,{
	isObject = true,
	ReturnType = 1
})

GameTime.SetTime(-3)

local AppliedMods = {
	Speed = 1,
	Hidden = false,
	HardRock = false,
	Eazy = false,
	NoFail = false,
	DifficultyAdjust = false 
}

-- Game difficulty

local GameDifficulty = {
	AR = 9,
	OD = 8,
	CS = 4,
	HP = 5,
	SliderMultiplier = 1,
	SliderTickRate = 1
}

--[[
HPDrainRate:6
CircleSize:3.8
OverallDifficulty:8.7
ApproachRate:9.5
SliderMultiplier:2
SliderTickRate:1
]]

if MapData.Difficulty then
	GameDifficulty.HP = MapData.Difficulty.HPDrainRate
	GameDifficulty.CS = MapData.Difficulty.CircleSize
	GameDifficulty.OD = MapData.Difficulty.OverallDifficulty
	GameDifficulty.AR = MapData.Difficulty.ApproachRate
	GameDifficulty.SliderMultiplier = MapData.Difficulty.SliderMultiplier
	GameDifficulty.SliderTickRate = MapData.Difficulty.SliderTickRate
end

local NumberImageID = {
	[0] = "10033191843",
	[1] = "10033191668",
	[2] = "10033191346",
	[3] = "10033191060",
	[4] = "10033190865",
	[5] = "10033190699",
	[6] = "10033190461",
	[7] = "10033190205",
	[8] = "10033189908",
	[9] = "10033189638",
}

local MapComboColor = {
	Color3.fromRGB(241,79,10),
	Color3.fromRGB(153,203,253),
	Color3.fromRGB(54,115,228),
	Color3.fromRGB(98,46,207),
	Color3.fromRGB(227,149,43),
	Color3.fromRGB(37,203,33),
	Color3.fromRGB(16,190,182),
	Color3.fromRGB(255,0,0)
}

if #MapData.MapComboColor >= 2 then
	MapComboColor = MapData.MapComboColor
end

-- Gameplay data

--> Calculate the Difficulty Data into Game Data (which make the game functioning)

---> AR
local ApproachTime = 1200

if GameDifficulty.AR < 5 then
	ApproachTime = 1200 + 600 * (5 - GameDifficulty.AR) / 5 -- 1800 > 1200
else
	ApproachTime = 1200 - 750 * (GameDifficulty.AR - 5) / 5		-- 1200 > 450 (300 - AR11, 150 - AR12, 0 - AR13)
end


local CircleFadeInTime = 0.8

if GameDifficulty.AR < 5 then
	CircleFadeInTime = (800 + 400 * (5 - GameDifficulty.AR) / 5)/1000
elseif GameDifficulty.AR > 5 then
	CircleFadeInTime = (800 - 500 * (GameDifficulty.AR - 5) / 5)/1000
end


---> CS
local CircleSize = (54.4 - 4.48 * GameDifficulty.CS)*2

---> OD
local Timing_EarlyMiss = 350
local Timing_300s = 119.5 - 9  * GameDifficulty.OD
local Timing_100s = 219.5 - 12 * GameDifficulty.OD
local Timing_50s  = 299.5 - 15 * GameDifficulty.OD

---> HP
local BaseHP = 100
local BaseDrainSpeed = 1.75
local MissDrain = 12.5

if GameDifficulty.HP < 5 then
	MissDrain = 12.5 - 10.5 * (5 - GameDifficulty.HP) / 5
	DrainSpeed = (1.75 - 0.75 * (5 - GameDifficulty.HP) / 5)
else
	MissDrain = 12.5 + 17.5 * (GameDifficulty.HP - 5) / 5
	DrainSpeed = (1.75 + 1.25 * (GameDifficulty.HP - 5) / 5)
end


--> Modifiers
--[[
	AT - AutoPlay
	
]]

local Modifiers = {
	AT = true
}


--> Game functioning

script.Parent.Parent.Enabled = true

local onBreakTime = true
local Health = 0
local isGameEnded = false

local cursorDisplay = script.Parent.Parent.CursorOverlay.Cursor

-- Process the game song audio

task.spawn(function()
	local audioSpeed =  MapData.RobloxData.SongSpeed or 1
	GameSong.TimePosition = 0
	GameSong.Looping = false
	GameSong.PlaybackSpeed = audioSpeed
	GameSong.Asset = "rbxassetid://"..MapData.RobloxData.RblxSoundID
	local sound2Exist = MapData.RobloxData.RblxSoundID2 ~= nil
	
	if sound2Exist then
		GameSong2.TimePosition = 0
		GameSong2.Looping = false
		GameSong2.PlaybackSpeed = audioSpeed
		GameSong2.Asset = "rbxassetid://"..MapData.RobloxData.RblxSoundID2
	end
	
	GameSong:Stop()
	GameSong2:Stop()
	
	if not GameSong.IsReady then
		repeat task.wait() until GameSong.IsReady
	end
	
	if sound2Exist then
		if not GameSong2.IsReady then
			repeat task.wait() until GameSong2.IsReady
		end
	end
	
	local LastOffsetChange = tick()
	
	while task.wait() do
		local playbackTime = GameTime.GetTime() * audioSpeed
		local isPlayingOnAudio2 = false
		
		if playbackTime > GameSong.TimeLength then
			isPlayingOnAudio2 = true
			playbackTime -= GameSong.TimeLength
		end
		
		local playingSong = isPlayingOnAudio2 and GameSong2 or GameSong
		
		if math.abs(playingSong.TimePosition - playbackTime) > 0.25 and tick() - LastOffsetChange > 1 then
			playingSong.TimePosition = math.max(0, playbackTime)
			LastOffsetChange = tick()
		end
		
		if isPlayingOnAudio2 and GameSong.IsPlaying then
			GameSong:Stop()
		end
		
		if not playingSong.IsPlaying and GameTime.GetTime() >= 0 and not isGameEnded then
			playingSong:Play()
		elseif GameTime.GetTime() < 0 then
			GameSong:Stop()
			GameSong2:Stop()
		end
	end	
end)

-- Process the hitsound handle

function toggleHitsound(sampleSet,HitsoundType,volume)
	game.Players.LocalPlayer.PlayerGui.SystemGame.SoundEffect.AddHitsound:Fire(sampleSet,HitsoundType,volume)
end

-- Process the break time

local BreakTimeFrame = script.Parent.Parent.PlayScreen.BreakTimeFrame

task.spawn(function()
	for _,BreakTimeData in pairs(MapData.BreakTime) do
		repeat task.wait() until GameTime.GetTime() >= BreakTimeData.startTime/1000
		local StartTime = BreakTimeData.startTime/1000
		local EndTime = BreakTimeData.endTime/1000
		local Duration = EndTime-StartTime
		
		if Duration < 2 then continue end -- Only process animation if break time is more than 2 sec
		local BGDim = game.Players.LocalPlayer.PlayerGui.GameBackground.DimBackground
		TweenService:Create(BGDim,TweenInfo.new(1,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.4}):Play()
		
		task.spawn(function()
			while task.wait() and GameTime.GetTime() < EndTime do
				BreakTimeFrame.Progress.ActualProgress.Size = UDim2.new((EndTime - (GameTime.GetTime()))/Duration,0,1,0)
				BreakTimeFrame.TimeDisplay.Text = string.format("%d",(EndTime - (GameTime.GetTime()) + 1))
			end
		end)
		
		TweenService:Create(BreakTimeFrame.Progress,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(1,0,0,5)}):Play()
		TweenService:Create(BreakTimeFrame.TimeDisplay,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0.5,0,0.25,0), TextTransparency = 0}):Play()
		
		for _,obj in pairs(BreakTimeFrame.StatusDisplay_L:GetChildren()) do
			if obj:IsA("Frame") then
				TweenService:Create(obj.MainDisplay,TweenInfo.new(0.5+((obj.LayoutOrder-1)/3*0.5),Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0,-5,0,0),TextTransparency = 0}):Play()
			end
		end
		
		for _,obj in pairs(BreakTimeFrame.StatusDisplay_R:GetChildren()) do
			if obj:IsA("Frame") then
				TweenService:Create(obj.MainDisplay,TweenInfo.new(0.5+((obj.LayoutOrder-1)/3*0.25),Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position = UDim2.new(0,0,0,0),TextTransparency = 0}):Play()
			end
		end
		
		repeat task.wait() until GameTime.GetTime() >= EndTime-0.75
		
		for _,obj in pairs(BreakTimeFrame.StatusDisplay_L:GetChildren()) do
			if obj:IsA("Frame") then
				TweenService:Create(obj.MainDisplay,TweenInfo.new(0.5+((obj.LayoutOrder-1)/3*0.25),Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Position = UDim2.new(0,-50,0,0),TextTransparency = 1}):Play()
			end
		end

		for _,obj in pairs(BreakTimeFrame.StatusDisplay_R:GetChildren()) do
			if obj:IsA("Frame") then
				TweenService:Create(obj.MainDisplay,TweenInfo.new(0.5+((obj.LayoutOrder-1)/3*0.25),Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Position = UDim2.new(0,50,0,0),TextTransparency = 1}):Play()
			end
		end
		
		TweenService:Create(BreakTimeFrame.TimeDisplay,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Position = UDim2.new(0.5,0,0.25,20), TextTransparency = 1}):Play()
		repeat task.wait() until GameTime.GetTime() >= EndTime
		TweenService:Create(BGDim,TweenInfo.new(1,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.2}):Play()
		
		TweenService:Create(BreakTimeFrame.Progress,TweenInfo.new(0,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Size = UDim2.new(0,0,0,5)}):Play()
		BreakTimeFrame.TimeDisplay.Text = "0"
	end
end)

-- Background change before starting game

local BackgroundFrame = game.Players.LocalPlayer.PlayerGui.GameBackground
BackgroundFrame.ChangeRequest:Fire(MapData.RobloxData.BackgroundImageId)
task.spawn(function()
	TweenService:Create(BackgroundFrame.DimBackground,TweenInfo.new(1,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.4}):Play()
	repeat task.wait() until GameTime.GetTime() >= (MapData.ObjectData[1].Timing-1000-ApproachTime)/1000
	TweenService:Create(BackgroundFrame.DimBackground,TweenInfo.new(1,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.2}):Play()
end)

-- BETA game alert

task.spawn(function()
	repeat task.wait() until GameTime.GetTime() > 0
	
	TweenService:Create(game.Players.LocalPlayer.PlayerGui.EarlyDevelopmentAlert.Alert,
		TweenInfo.new(2,Enum.EasingStyle.Linear),{TextTransparency = 0.75}
	):Play()
	TweenService:Create(game.Players.LocalPlayer.PlayerGui.EarlyDevelopmentAlert.Alert2,
		TweenInfo.new(2,Enum.EasingStyle.Linear),{TextTransparency = 1}
	):Play()
	
	script.Parent.Parent.SongMetadata.Text = string.format("%s - %s",MapData.Metadata.Artist,MapData.Metadata.Title)
	
	TweenService:Create(script.Parent.Parent.SongMetadata,
		TweenInfo.new(2,Enum.EasingStyle.Linear),{TextTransparency = 0.5}
	):Play()
end)

script.Parent.Parent.ExitGameplayFrame.DisplayScript.Disabled = false

-- Main gameplay

print("[SYSTEM] Game started.")

local NoteCombo = 0
local NoteComboColorOrder = 1
local HoldingTime = 1000 -- The note load before note appear
local AutoPlayData = {
	CurrentNoteId = 1
}

--[[
	Accuracy = (Hit300*3 + Hit100 + Hi50*0.5 + TickHitted*0.1 + SLTailHitted*0.3 + SpinnerSpin*0.1)/((Hit300+Hit100+Hit50+Miss)*3+TotalTick*0.1+TotalSLTail*0.3) 
   	SS 	-> 100% accuracy
   	S 	-> 95% accuracy and no miss
   	A	-> 90% accuracy
   	B	-> 80% accuracy
   	C	-> 70% accuracy
   	D	-> anything below
]]

local ResultData = {
	Score = 0, Combo = 0, MaxCombo = 0,
	Hit300 = 0, Hit100 = 0, Hit50 = 0, Miss = 0,
	TotalTick = 0, TickHitted = 0, TotalSLTail = 0, SLTailHitted = 0,
	TotalSpin = 0, SpinnerSpin = 0
}

local inputData = {
	{false,0},{false,0}
}	-- K1, K2 (M1 and M2 is now grouped with K1 and K2)


task.spawn(function()
	while task.wait() do
		script.Parent.Parent.DisplayOverlay.ComboDisplay.Text = string.format("%dx",ResultData.Combo)
	end
end)

function addScore(scoreValue)
	ResultData.Score += scoreValue
	local ScoreDisplay = script.Parent.Parent.DisplayOverlay.ScoreDisplay
	local scoreV2 = math.pow(ResultData.Score/MapData.DetailedAnalyse.MaxScore,0.4667510321076327)*1000000
	
	ScoreDisplay.Text = string.format("%.8d",ResultData.Score)
	ScoreDisplay.ScoreV2.Text = string.format("%.6d",scoreV2)
end

function ATMoveCursor(Pos,Time)
	if not Modifiers.AT then
		return
	end
	TweenService:Create(cursorDisplay,TweenInfo.new(Time,Enum.EasingStyle.Linear),{Position = UDim2.new(Pos.X/512,0,Pos.Y/384,0)}):Play()
end

-- any object that is loaded will be placed here, used for notelock
local visibleObjectData = {}

inputEvent.Event:Connect(function(isEnabled, keyType)
	-- there's an input even that triggered the core
	
	local targetingData = inputData[keyType]
	targetingData[1] = isEnabled
	targetingData[2] += 1
	
	if isEnabled then
		
	end
end)

script.Parent.SetTime.Event:Connect(function(t: number)
	GameTime.SetTime(t)
end)

for ObjectId,ObjectData in pairs(MapData.ObjectData) do
	-- Yeidld until the obj is ready to display	
	if GameTime.GetTime() < (ObjectData.Timing-ApproachTime)/1000 then
		repeat task.wait() until GameTime.GetTime() >= (ObjectData.Timing-ApproachTime-HoldingTime)/1000
	end
	
	local ObjType = ObjectData.ObjType
	if ObjType ~= 1 and ObjType ~= 2 and ObjType ~= 8 then
		NoteCombo = 1
		local ComboColorIncrease = math.ceil((ObjType - 8)/8)
		local Base = ObjType%8
		
		if Base == 4 then
			ComboColorIncrease += 1
		end
		
		if ComboColorIncrease <= 0 then
			ComboColorIncrease = 1
		end
		
		for i = 1,ComboColorIncrease do
			NoteComboColorOrder += 1
			if NoteComboColorOrder > #MapComboColor then
				NoteComboColorOrder = 1
			end
		end
		
		if ObjType == 5 then
			ObjType = 1
		elseif ObjType == 6 then
			ObjType = 2
		else
			ObjType = 8
		end
	else
		NoteCombo += 1
	end
	
	local CurrentNoteCombo = NoteCombo
	local CurrentNoteOrder = NoteComboColorOrder
	
	
	-- Main note functioning
	task.spawn(function()
		-- Preparing hitsounds data
		local sampleSet = ObjectData.ExtraData.HitEffectData.GlobalSampleSet
		local Volume = ObjectData.ExtraData.HitEffectData.Volume
		local HitSoundType = tonumber(ObjectData.HitSound)
		local preparingHitsound = {
			[1] = 0
		}
		if HitSoundType == 2 or HitSoundType == 14 or HitSoundType == 6 or HitSoundType == 10 then
			preparingHitsound[#preparingHitsound+1] = 2
		end
		if HitSoundType == 4 or HitSoundType == 14 or HitSoundType == 6 or HitSoundType == 12 then
			preparingHitsound[#preparingHitsound+1] = 1
		end
		if HitSoundType == 8 or HitSoundType == 14 or HitSoundType == 10 or HitSoundType == 12 then
			preparingHitsound[#preparingHitsound+1] = 3
		end
		
		
		local function toggleCurrentObjHitsound()
			for _, hitsound in pairs(preparingHitsound) do
				toggleHitsound(sampleSet,hitsound,Volume)
			end
		end
		
		-- Creating hit circle
		
		local HitCircle = script.HitCircle:Clone()
		local sliderBase
		HitCircle.Parent = PlayScreen
		HitCircle.Size = UDim2.new(CircleSize/384,0,CircleSize/384,0)
		HitCircle.Position = UDim2.new(ObjectData.Position.X/512,0,ObjectData.Position.Y/384,0)
		HitCircle.ZIndex = -ObjectId*2
		HitCircle.HitCircleImage.ImageColor3 = MapComboColor[CurrentNoteOrder]
		HitCircle.ApproachCircle.ImageColor3 = MapComboColor[CurrentNoteOrder]
		
		for i,str in pairs(string.split(tostring(CurrentNoteCombo),"")) do
			local NoteNumber = script.NoteNumber:Clone()
			NoteNumber.Parent = HitCircle.Numbers
			NoteNumber.Image = "rbxassetid://"..NumberImageID[tonumber(str)]
			NoteNumber.LayoutOrder = -i
		end
		
		local function UpdateHitCircleTransparency(Transparency)
			for _,obj in pairs(HitCircle:GetDescendants()) do
				if obj:IsA("ImageLabel") then
					obj.ImageTransparency = Transparency
				end
			end
		end
		UpdateHitCircleTransparency(1)
		
		if ObjectData.ExtraData.isSlider then
			-- process if it's a slider
			sliderBase = script.Slider:Clone()
			sliderBase.Parent = PlayScreen
			sliderBase.ZIndex = -ObjectId*2-1
			local sliderData = ObjectData.ExtraData.Slider
			
			local movementTime = sliderData.MovementTime
			local TimePerSlide = movementTime/sliderData.SlidesCount
			local curvePoints = sliderData.CurvePoints
			local lengthMultiplier = (1/(CircleSize))/0.95
			local baseMultiplier = 0.95*(1/1.15)
			local outLineMulti = 1.15
			local renderData = {}
			for i,data in pairs(curvePoints) do
				local lengthMultiplier = lengthMultiplier
				if i == #curvePoints then
					-- the last hitnote indicate NO connection
					lengthMultiplier = 0
				end
				local baseSLPoint = script.SliderBase:Clone()
				baseSLPoint.Parent = sliderBase.BaseFrame.Base
				baseSLPoint.ZIndex = i
				baseSLPoint.Rotation = data.Rotation
				baseSLPoint.Size = UDim2.new(baseMultiplier*CircleSize/384,0,baseMultiplier*CircleSize/384,0)
				baseSLPoint.Position = UDim2.new(data.Pos.X/512,0,data.Pos.Y/384,0)
				baseSLPoint.ExtendFrame.Size = UDim2.new(data.Length*lengthMultiplier*1.15,0,1,0)
				local baseSLOutline = script.SliderOutline:Clone() -- those 2 are basically the same, it's just the animation
				baseSLOutline.Parent = sliderBase.BaseFrame.Overlay
				baseSLOutline.ZIndex = i - 10000
				baseSLOutline.Rotation = data.Rotation
				baseSLOutline.Size = UDim2.new(baseMultiplier*outLineMulti*CircleSize/384,0,baseMultiplier*outLineMulti*CircleSize/384,0)
				baseSLOutline.Position = UDim2.new(data.Pos.X/512,0,data.Pos.Y/384,0)
				baseSLOutline.ExtendFrame.Size = UDim2.new((data.Length)*lengthMultiplier*1.01,0,1,-1)
				renderData[#renderData+1] = {Pos = data.Pos,moveTime = data.MoveTime, basePoint = baseSLPoint, baseOverlay = baseSLOutline}
			end 
			local endTime = sliderData.EndTime
			-- overlay that overwrite the layout behind
			local baseAnimation = script.SliderBase:Clone()
			baseAnimation.Size = UDim2.new(baseMultiplier*CircleSize/384,0,baseMultiplier*CircleSize/384,0)
			local baseAnimationOverlay = script.SliderOutline:Clone()
			baseAnimationOverlay.Size = UDim2.new(baseMultiplier*outLineMulti*CircleSize/384,0,baseMultiplier*outLineMulti*CircleSize/384,0)
			baseAnimation.Parent = sliderBase.BaseFrame.BaseAnimation
			baseAnimationOverlay.Parent = sliderBase.BaseFrame.BaseAnimation
			baseAnimation.Visible = true
			baseAnimationOverlay.Visible = true
			baseAnimation.ZIndex = 99999
			baseAnimationOverlay.ZIndex = -99999
			baseAnimation.Position = UDim2.new(curvePoints[1].Pos.X/512,0,curvePoints[1].Pos.Y/384,0)
			baseAnimationOverlay.Position = UDim2.new(curvePoints[1].Pos.X/512,0,curvePoints[1].Pos.Y/384,0)
			
			local followCircle = sliderBase.BaseFrame.FollowCircle.SliderFollowCircle
			followCircle.Size = UDim2.new(baseMultiplier*CircleSize/384,0,baseMultiplier*CircleSize/384,0)
			followCircle.Position = UDim2.new(curvePoints[1].Pos.X/512,0,curvePoints[1].Pos.Y/384,0)
			
			if sliderData.TotalTickCount > 0 then
				local SliderTickFolder = Instance.new("Folder",PlayScreen)
				SliderTickFolder.Name = "SliderTick"
				local TickSizeMultiplier = 0.25
				local SliderTickObj = {}
				local SliderTickObjRev = {}
				local TickSize = UDim2.new(TickSizeMultiplier*CircleSize/384,0,TickSizeMultiplier*CircleSize/384,0)
				for i,a in pairs(sliderData.TickData) do
					local new = script.SliderTick:Clone()
					new.Parent = SliderTickFolder
					new.ZIndex = 99999
					new.Position = UDim2.new(a.Pos.X/512,0,a.Pos.Y/384,0)
					SliderTickObj[#SliderTickObj+1] = {Obj = new,Time = a.Time}
				end
				
				for i,a in pairs(sliderData.TickDataRev) do
					local new = script.SliderTick:Clone()
					new.Parent = SliderTickFolder
					new.ZIndex = 99999
					new.Position = UDim2.new(a.Pos.X/512,0,a.Pos.Y/384,0)
					SliderTickObjRev[#SliderTickObjRev+1] = {Obj = new,Time = a.Time}
				end
				
				
				task.spawn(function()
					local function reset()
						for _,a in pairs(SliderTickObj) do
							TweenService:Create(a.Obj,TweenInfo.new(0.1,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size = UDim2.new(0,0,0,0), ImageTransparency = 1}):Play()
						end
					end
					for crrSlide = 1,sliderData.SlidesCount do
						local SlideStart = ObjectData.Timing + sliderData.MovementTime/sliderData.SlidesCount*(crrSlide-1)
						local SlideEnd = ObjectData.Timing + sliderData.MovementTime/sliderData.SlidesCount*crrSlide
						local crrTickList = crrSlide%2==1 and SliderTickObj or SliderTickObjRev
						for tickOrder, data in pairs(crrTickList) do
							task.spawn(function()
								local tickDisplayTime = math.max(SlideStart,SlideStart - 250 + (1/#crrTickList*tickOrder) * sliderData.MovementTime/sliderData.SlidesCount * 0.75)
								if crrSlide == 1 then
									tickDisplayTime = math.max(SlideStart-500,SlideStart - ApproachTime - 250 + (1/#crrTickList*tickOrder) * math.min(sliderData.MovementTime/sliderData.SlidesCount) * 0.75)
								end
								local tickHitTime = SlideStart+data.Time
								if GameTime.GetTime() < (tickDisplayTime)/1000 then
									repeat task.wait() until GameTime.GetTime() >= (tickDisplayTime)/1000
								end
								TweenService:Create(data.Obj,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size = TickSize, ImageTransparency = 0}):Play()
								if GameTime.GetTime() < tickHitTime/1000 then
									repeat task.wait() until GameTime.GetTime() >= tickHitTime/1000
								end
								addScore(30)
								ResultData.Combo += 1
								toggleHitsound("normal",5,100)
								TweenService:Create(data.Obj,TweenInfo.new(0.1,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size = UDim2.new(0,0,0,0), ImageTransparency = 1}):Play()
							end)
						end
						
						repeat task.wait() until GameTime.GetTime() >= SlideEnd/1000
						reset()
					end
					
					SliderTickFolder:Destroy()
				end)
			end
			
			------------
			-- Animate the slider tail out (which is not a thing that V1 can do)
			
			local comboBeforeHit = ResultData.Combo
			
			task.spawn(function()
				repeat task.wait() until GameTime.GetTime() >= (ObjectData.Timing-ApproachTime)/1000
				comboBeforeHit = ResultData.Combo
				while task.wait() and GameTime.GetTime() <= (ObjectData.Timing)/1000 do
					local TimeLeft = (ObjectData.Timing)/1000 - (GameTime.GetTime())
					local TimePassed = ApproachTime/1000 - TimeLeft
					
					for i,data in pairs(renderData) do
						local s = data.moveTime.Start/TimePerSlide*CircleFadeInTime*0.5
						local e = data.moveTime.Stop/TimePerSlide*CircleFadeInTime*0.5
						local duration = data.moveTime.Base/TimePerSlide*CircleFadeInTime*0.5
						if TimePassed >= s then
							data.basePoint.Visible = true
							data.baseOverlay.Visible = true
							local baseprogress = (TimePassed-s)/duration
							local progress = math.min(1,baseprogress)
							if baseprogress <= 1 then
								local NextPos = renderData[i+1].Pos
								local crrPos = data.Pos
								
								local animationPos = crrPos + (NextPos - crrPos) * progress
								baseAnimation.Position = UDim2.new(animationPos.X/512,0,animationPos.Y/384,0)
								baseAnimationOverlay.Position = UDim2.new(animationPos.X/512,0,animationPos.Y/384,0)
							end
							data.basePoint.ExtendFrame.InnerFrame.Size = UDim2.new(progress,0,1,0)
							data.baseOverlay.ExtendFrame.InnerFrame.Size = UDim2.new(progress,0,1,0)
							else break -- ofc the next obj is not gonna visible as well
						end
					end
					
					sliderBase.GroupTransparency = 0.25+math.max(0,0.75*(CircleFadeInTime - TimePassed)/CircleFadeInTime)
				end
				local slideCount = sliderData.SlidesCount
				
				local function changePos(pos)
					followCircle.Position = UDim2.new(pos.X/512,0,pos.Y/384,0)
				end
				
				followCircle.Visible = true
				local lastSlide = 0
				while task.wait() and (GameTime.GetTime() < endTime/1000) do
					local movementTime = sliderData.MovementTime
					local timePassed = (GameTime.GetTime())*1000 - ObjectData.Timing
					local currentSlide = math.floor(timePassed/movementTime*slideCount)
					local usingcurveData = currentSlide%2 == 0 and sliderData.CurvePoints or sliderData.ReverseCurvePoints
					if currentSlide > lastSlide then
						addScore(30)
						ResultData.Combo += 1
						toggleCurrentObjHitsound()
					end
					lastSlide = currentSlide
					
					local timePassedCurrentSlide = timePassed - movementTime/slideCount*currentSlide
					for i,data in pairs(usingcurveData) do
						if timePassedCurrentSlide >= data.MoveTime.Start and timePassedCurrentSlide <= data.MoveTime.Stop then
							if i == #usingcurveData then
								-- apply the current position instead
								if Modifiers.AT and AutoPlayData.CurrentNoteId >= ObjectId then
									ATMoveCursor(data.Pos,0)
								end
								changePos(data.Pos)
							else
								local crrPos = data.Pos
								local nextPos = usingcurveData[i+1].Pos
								
								local Progress = (timePassedCurrentSlide - data.MoveTime.Start)/data.MoveTime.Base
								local newPos = crrPos + (nextPos-crrPos) * Progress
								if Modifiers.AT and AutoPlayData.CurrentNoteId >= ObjectId then
									ATMoveCursor(newPos,0)
								end
								changePos(newPos)
							end

							break
						end
					end
				end

				if true then
					addScore(300 * (1+math.max(comboBeforeHit-1,0)*6/25))
					ResultData.Combo += 1
				end
				toggleCurrentObjHitsound()
				local usingcurveData = slideCount%2 == 1 and sliderData.CurvePoints or sliderData.ReverseCurvePoints
				changePos(usingcurveData[#usingcurveData].Pos)
				AutoPlayData.CurrentNoteId = ObjectId+1
				
				--repeat task.wait() until GameTime.GetTime() >= endTime/1000
				TweenService:Create(sliderBase,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{GroupTransparency = 1}):Play()
				wait(0.25)
				sliderBase:Destroy()
			end)
		end
		
		
		-- Wait until it's the note turn to appear
		
		repeat task.wait() until GameTime.GetTime() >= (ObjectData.Timing-ApproachTime)/1000
		
		task.spawn(function()
			if Modifiers.AT then
				if AutoPlayData.CurrentNoteId < ObjectId then
					repeat task.wait() until AutoPlayData.CurrentNoteId >= ObjectId
				end
				ATMoveCursor(ObjectData.Position,ObjectData.Timing/1000 - (GameTime.GetTime()))
				task.spawn(function()
					if not ObjectData.ExtraData.isSlider then
						repeat task.wait() until GameTime.GetTime() >= ObjectData.Timing/1000
						AutoPlayData.CurrentNoteId = ObjectId+1
					end
				end)

			end
		end)
		
		
		-- Creating connection between notes
		local NextNote = MapData.ObjectData[ObjectId+1]

		if NextNote then
			local NextNoteType = NextNote.ObjType
			if NextNoteType == 1 or NextNoteType == 2 then
				local NextNotePos = NextNote.Position
				local CrrNotePos = ObjectData.Position
				if ObjectData.ExtraData.isSlider then
					local SLData = ObjectData.ExtraData.Slider
					CrrNotePos = SLData.SlidesCount%2 == 1 and SLData.CurvePoints[#SLData.CurvePoints].Pos or SLData.ReverseCurvePoints[#SLData.ReverseCurvePoints].Pos
				end
				local Point = CrrNotePos-NextNotePos
				local Rotation = math.deg(math.atan2(Point.Y,Point.X))
				if Rotation ~= Rotation then
					-- rather 0, than a nil value
					Rotation = 0
				end
				local Distance = Point.Magnitude - CircleSize
				
				if Distance > 0 then
					local StartPos = CrrNotePos - Point/(Point.Magnitude)*(CircleSize*0.5)
					local EndPos = NextNote.Position + Point/(Point.Magnitude)*(CircleSize*0.5)
					

					local NewConnection = script.CircleConnection:Clone()
					NewConnection.Parent = PlayScreen
					NewConnection.Size = UDim2.new(0,0,0.01,0)
					NewConnection.Rotation = Rotation
					NewConnection.Position = UDim2.new(StartPos.X/512,0,StartPos.Y/384,0)
					local CurrentColor = MapComboColor[CurrentNoteOrder]
					local h,s,v = CurrentColor:ToHSV()
					NewConnection.BackgroundColor3 = Color3.fromHSV(h,s,math.min(0.7,math.max(0.4,v)))
					--local movementTime = (NextNote.Timing/1000 - (GameTime.GetTime()))/2
					--TweenService:Create(NewConnection,TweenInfo.new(movementTime, Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,true),{Size = UDim2.new(Distance/512,0,0.01,0)}):Play()
					--TweenService:Create(NewConnection,TweenInfo.new(movementTime, Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Position = UDim2.new(EndPos.X/512,0,EndPos.Y/384,0)}):Play()
					
					task.spawn(function()
						local totalTravelTime = NextNote.Timing  - (ObjectData.Timing - ApproachTime)
						while task.wait() and GameTime.GetTime() <= NextNote.Timing/1000 do
							local progress = ((GameTime.GetTime())*1000 - (ObjectData.Timing - ApproachTime))/totalTravelTime
							--print(progress,totalTravelTime)
							if progress <= 0.75 then
								if progress < 0 then
									continue
								end
								local size = math.pow(progress/0.75,0.5)
								NewConnection.Size = UDim2.new(Distance/512*size,0,0.01,0)
								NewConnection.Position = UDim2.new((StartPos.X + (EndPos.X - StartPos.X)*size*0.5) /512,0,(StartPos.Y + (EndPos.Y - StartPos.Y)*size*0.5) /384,0)
							else
								local size = math.pow((progress-0.75)/0.25,1.1)
								NewConnection.Size = UDim2.new(Distance/512*(1-size),0,0.01,0)
								NewConnection.Position = UDim2.new((StartPos.X + (EndPos.X - StartPos.X)*(0.5+size*0.5)) /512,0,(StartPos.Y + (EndPos.Y - StartPos.Y)*(0.5+size*0.5)) /384,0)
							end
						end
						NewConnection:Destroy()
					end)
				end
			end
		end
		
		while task.wait() and GameTime.GetTime() <= (ObjectData.Timing)/1000 do
			local TimeLeft = (ObjectData.Timing)/1000 - (GameTime.GetTime())
			local TimePassed = ApproachTime/1000 - TimeLeft
			local Size = 1+3*TimeLeft/(ApproachTime/1000)
			
			local ObjTrans = (CircleFadeInTime - TimePassed)/CircleFadeInTime
			UpdateHitCircleTransparency(ObjTrans)
			
			HitCircle.ApproachCircle.Size = UDim2.new(Size,0,Size,0)
		end
		

		if true then -- simulate if the circle got hit in the 300s
			if ObjectData.ExtraData.isSlider then
				addScore(30)
			else
				addScore(300 * (1+math.max(ResultData.Combo-1,0)*6/25))
			end

			ResultData.Combo += 1
		end
		
		toggleCurrentObjHitsound() -- test
		HitCircle.ApproachCircle.Visible = false
		
		local _s = tick()
		
		-- If the circle hitted
		
		for _,obj in pairs(HitCircle:GetDescendants()) do
			if obj:IsA("ImageLabel") then
				TweenService:Create(obj,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()
			end
		end
		
		TweenService:Create(HitCircle,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Size = UDim2.new(CircleSize/384*1.5,0,CircleSize/384*1.5,0)}):Play()
		wait(0.25)
		
		HitCircle:Destroy()
	end)
end

local lastobjData = MapData.ObjectData[#MapData.ObjectData]
wait(ApproachTime/1000 + 1)
if lastobjData.ExtraData.isSlider then
	wait(lastobjData.ExtraData.Slider.MovementTime/1000)
end

isGameEnded = true
wait(2)

script.Parent.Parent.Communications.System.ExitGame:Fire()
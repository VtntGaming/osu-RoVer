--[LOCATION]:[Workspace.OsuConvert]
-- osu!RoVer converter
-- convert raw osu file into readable and excutable lua data
-- V1.47 (Size: 38.56KB)

local PerformanceCalculator = require(workspace.PerformanceCalculator)
local BasePerfomance = require(workspace.PerformanceCalculator.BasePerfomance)
local basePerformanceFL = require(workspace.PerformanceCalculator.BasePerfomanceFL)
local calculator = require(workspace.DifficultyCalculator)
local tool = require(script.converterTools)
local sliderTools = require(script.sliderTools)
local preprocessing = require(workspace.DifficultyCalculator.DifficultyHitObjects)
local evaluatorContainer = workspace.DifficultyCalculator.DifficultyEvaluator
local modData = require(workspace.ModData)
local evaluators = {
	Aim = require(evaluatorContainer.AimEvaluator),
	Speed = require(evaluatorContainer.SpeedEvaluator),
	Rhythm = require(evaluatorContainer.RhythmCalculator),
	Flashlight = require(evaluatorContainer.FLEvaluator)
}

export type ModData = modData.ModData

return function(FileType,Beatmap,DelayedTime,isReturnDifficulty,metadataonly,modData:ModData)
	local OsuData = Beatmap
	if FileType == 1 then
		OsuData = require(Beatmap)
	elseif FileType == 3 then
		OsuData = game.ReplicatedStorage.GetModuleData:InvokeServer(tonumber(Beatmap))
	end
	local Space = "\n" --[[script.Space.Value]]
	local Data = {}
	local TempData = ""

	local ReturningData = {} --Should be useful
	ReturningData.Overview = {OverviewStartTime = 0,Metadata = {}}
	ReturningData.MapFile = Beatmap
	ReturningData.BreakTime = {}
	ReturningData.BeatmapSetsData = {}
	ReturningData.BeatmapVolume = 1
	ReturningData.SongSpeed = 1
	ReturningData.SongPitch = 1
	ReturningData.ImageId = 0
	ReturningData.SampleSet = "normal"
	ReturningData.OriginalOffset = 0
	ReturningData.StackLeniency = 0
	ReturningData.NoteCount = {
		Circle = 0, Slider = 0, Spinner = 0, Total = 0
	}
	local SongSpeed = modData.SA or 1

	local MapData = {}
	local MapDataName = {}
	local TimingPoints = {}
	local BeatmapColor
	local OriginalPreviewTime = -1
	
	--local DIFFICULTY_VALUE_EXPOMENTAL_RATE = 1/2.15
	--local DIFFICULTY_VALUE_MULTIPLIER_RATE = 0.5504298051287392
	
	local DIFFICULTY_VALUE_EXPOMENTAL_RATE = 1/3
	local DIFFICULTY_VALUE_MULTIPLIER_RATE = 0.265
	local DIFFICULTY_VALUE_AIM_MULTIPLIER = 1
	local DIFFICULTY_VALUE_SPEED_MULTIPLIER = 1

	-- Convert string into datatable
	--[[
	-----------
	[Data]
	1
	2
	3
	4
	E
	Data: Data
	[Data2]
	ExampleText
	-----------
	return as {["Data"] = {1,2,3,4,"E","Data: Data"},["Data2"] = {"ExampleText"}}
	]]
	---------------
	local Listraw = string.split(OsuData, "\n")
	local currentIndex = nil
	local onStoryboardLine = false
	for _, crrLine in pairs(Listraw) do
		if currentIndex == "Difficulty" and metadataonly then
			break
		end

		-- if the current index is HitObjects, it's likely to be the last index and won't need further check
		if currentIndex ~= "HitObjects" and string.find(crrLine, "%[") == 1 and string.find(crrLine, "]") then
			-- found index
			local index = string.sub(crrLine, 2, #crrLine-1)
			currentIndex = index

			MapData[index] = {}
		else
			-- normal line
			if currentIndex == nil or string.find(crrLine, "osu file format") or crrLine == "" then continue end
			
			-- ignore storyboard line processing
			if currentIndex == "Events" then
				if onStoryboardLine then continue
				elseif string.find(crrLine,"Storyboard Layer") then	onStoryboardLine = true continue end
			end
			
			MapData[currentIndex][#MapData[currentIndex] + 1] = crrLine
		end
	end
	
	-- Make sure that no data is blank

	local a,_ = pcall(function()
		if MapData.RobloxData ~= nil  then
			local RblxData = {}
			for _,RawData in pairs(MapData.RobloxData) do
				local raw = string.split(RawData,":")
				RblxData[raw[1]] = tonumber(raw[2])
			end

			-- Process RblxData


			if RblxData.SoundOffset ~= nil then
				DelayedTime += 30+RblxData.SoundOffset/SongSpeed
				ReturningData.OriginalOffset = RblxData.SoundOffset
			end

			if RblxData.CustomSoundFile then
				ReturningData.CustomSongFile = tool.ConvertRaw(RblxData.CustomSoundFile)
			end
			if RblxData.RblxSoundID ~= nil then
				ReturningData.MapSongId = RblxData.RblxSoundID
				ReturningData.MapSongId2 = RblxData.RblxSoundID2
				if RblxData.BeatmapVolume ~= nil then
					ReturningData.BeatmapVolume = RblxData.BeatmapVolume
				end
				if RblxData.SongSpeed then
					ReturningData.SongSpeed = RblxData.SongSpeed	
				end
				if RblxData.SongPitch then
					ReturningData.SongPitch = RblxData.SongPitch
				end

			end

			if RblxData.CustomBackgroundFile then
				ReturningData.CustomBackgroundFile = tool.ConvertRaw(RblxData.CustomBackgroundFile)
			end
			if RblxData.BackgroundImageId then
				ReturningData.ImageId = RblxData.BackgroundImageId
			end
			if RblxData.WeirdSliderAlert then
				ReturningData.WeirdSliderAlert = RblxData.WeirdSliderAlert == 1
			end
			if RblxData.SliderCrashAlert then
				ReturningData.SliderCrashAlert = RblxData.SliderCrashAlert == 1
			end
		end
	end)


	pcall(function()
		if MapData.Difficulty ~= nil  then
			local Difficulty = {}
			for _,RawData in pairs(MapData.Difficulty) do
				local raw = string.split(RawData,":")
				Difficulty[raw[1]] = tonumber(raw[2])
			end

			-- Process Difficulty
			ReturningData.Difficulty = Difficulty
		end
	end)


	pcall(function()
		if MapData.Metadata ~= nil then
			local Metadata = {}
			for _,RawData in pairs(MapData.Metadata) do
				local raw = string.split(RawData,":")
				Metadata[raw[1]] = raw[2]
			end
			-- Process Metadata
			ReturningData.Overview.Metadata.MapName = Metadata.Title
			ReturningData.Overview.Metadata.SongCreator = Metadata.Artist
			if Metadata.TitleUnicode == "" then
				Metadata.TitleUnicode = Metadata.Title
			end
			if Metadata.ArtistUnicode == "" then
				Metadata.ArtistUnicode = Metadata.Artist
			end
			ReturningData.Overview.Metadata.MapNameUnicode = Metadata.TitleUnicode
			ReturningData.Overview.Metadata.SongCreatorUnicode = Metadata.ArtistUnicode
			ReturningData.Overview.Metadata.DifficultyName = Metadata.Version
			ReturningData.Overview.Metadata.BeatmapCreator = Metadata.Creator
			ReturningData.Overview.Metadata.Source = Metadata.Source
			ReturningData.Overview.Metadata.Tags = Metadata.Tags

			ReturningData.BeatmapSetsData = {BeatmapsetID = Metadata.BeatmapSetID,BeatmapID = Metadata.BeatmapID}
		end
	end)

	pcall(function()
		if MapData.General ~= nil  then
			local General = {}
			for _,RawData in pairs(MapData.General) do
				local raw = string.split(RawData,":")
				General[raw[1]] = raw[2]
			end

			-- Process beatmap basic settings
			local PreviewTime = tonumber(General.PreviewTime)
			if PreviewTime ~= nil then
				OriginalPreviewTime = PreviewTime
				ReturningData.Overview.OverviewStartTime = PreviewTime+DelayedTime
			end

			local SampleSet = string.lower(General.SampleSet or "normal")
			ReturningData.SampleSet = SampleSet
			ReturningData.StackLeniency = tonumber(General.StackLeniency) or 0
		end
	end)
	pcall(function()
		if MapData.TimingPoints ~= nil  then
			for _,RawData in pairs(MapData.TimingPoints) do
				local raw = string.split(RawData,",")
				local CurrentTimmingPoint = {}
				for _, data in pairs(raw) do
					CurrentTimmingPoint[#CurrentTimmingPoint+1] = tonumber(data)
				end
				CurrentTimmingPoint[1] += DelayedTime
				CurrentTimmingPoint[1] /= SongSpeed
				TimingPoints[#TimingPoints+1] = CurrentTimmingPoint
			end
			table.sort(TimingPoints,function(timing1,timing2)
				return timing1[1] < timing2[1]
			end)
			for _,TimingPoint in pairs(TimingPoints) do
				if TimingPoint[#TimingPoint] == 1 and OriginalPreviewTime == -1 then
					ReturningData.Overview.OverviewStartTime = TimingPoint[1]+DelayedTime
					break
				elseif OriginalPreviewTime ~= -1 then
					break
				end
			end
		end
	end)

	pcall(function()
		if MapData.Colours ~= nil then
			local Colours = {}
			for _,RawData in pairs(MapData.Colours) do
				local raw = string.split(RawData,":")
				Colours[#Colours+1] = string.sub(raw[2], 2, #raw[2])
			end

			-- Process colour
			local ConvertedColors = {}
			for _,RawColor in pairs(Colours) do
				local ColorTable = game:GetService("HttpService"):JSONDecode('['..RawColor..']')
				local ConvertedColor = Color3.fromRGB(ColorTable[1],ColorTable[2],ColorTable[3])
				ConvertedColors[#ConvertedColors+1] = ConvertedColor
			end
			BeatmapColor = ConvertedColors

		end
	end)

	pcall(function()
		if MapData.Events ~= nil  then
			local BeatmapEvents = {}
			local EventName = ""
			for _,RawData in pairs(MapData.Events) do
				if string.sub(RawData,1,2) == "//" then
					EventName = string.sub(RawData,3,#RawData)
					BeatmapEvents[EventName] = {}
				else
					local CurrentLocation = 1
					local Data = {}
					for a = 1,#RawData do
						if string.sub(RawData,a,a) == "," then
							Data[#Data+1] = string.sub(RawData,CurrentLocation,a-1)
							CurrentLocation = a+1
						elseif a == #RawData then
							Data[#Data+1] = string.sub(RawData,CurrentLocation,a)
						end
					end
					BeatmapEvents[EventName][#BeatmapEvents[EventName]+1] = Data
				end
			end

			-- Process events
			for _,breaktime in pairs(BeatmapEvents["Break Periods"]) do
				local BreakStart = (tonumber(breaktime[2])+DelayedTime)/SongSpeed
				local BreakEnd = (tonumber(breaktime[3])+DelayedTime)/SongSpeed

				ReturningData.BreakTime[#ReturningData.BreakTime+1] = {BreakStart,BreakEnd} 
			end
		end
	end)

	--[[
	Type:
	0: Hit circle
	1: Slider
	3: Spinner
	7: osu!mania hold
	2: New combo
	4–6: A 3-bit integer specifying how many combo colours to skip, if this object starts a new combo.
	HitObject:
	x,y,time,type,hitSound,objectParams,hitSample
	
	------------
	Type according to studio:
	0: Hit circle
	1: Slider
	3,2,12: Spinner
	
	6: Slider - NewCombo
	AnythingElse: Hit circle - NewCombo
	]]


	local ConvertedData = {}
	local DiffList = {}
	local NoteDiff = {}
	local DifficultyStrike = {}
	local RawDifficulty = {}
	local RawDifficulty2 = {}
	--local StrainData = {}
	local AimStrainData = {}
	local AimSLStrainData = {}
	local SpeedStrainData = {}
	local RhythmDiffData = {}
	local FLStrainData = {}
	local AimDiff = {}
	local StreamDiff = {}
	local AimDifficulty = 0
	local SpeedDifficulty = 0
	local FlashlightDifficulty = 0
	local CurrentAimStrain = 0
	local CurrentSpeedStrain = 0
	local CurrentFLStrain = 0
	local CurrentStrain = 0
	local HighestStrain = 0
	local AvgStrain = 0
	local PrevVelocity = 0
	local PrevMoveTime = 0
	local FLMultiplier = 0
	local LastNotePosition = Vector2.new(0,0)
	local NoteStackStrain = 0
	local PrevDoubleTapness = 1
	local NoteCount = {
		Circle = 0, Slider = 0, Spinner = 0
	}


	local ODMultiplier = 1 --115 / ((119.5 - 9 * OD))
	ODMultiplier = ODMultiplier ^ 0.2

	-- RawDifficulty = {[1] = {<Time>,<Diff>}}
	-- RawDifficulty2 = {[1] = {[1] = <HighestDiff>,[2] = <2nd highest>}}
	-- DifficultyStrike = {[1] = <Diff>}
	-- Difficulty record each 5 seconds
	local GetPS = true

	local DifficultyStrikeRecord = 2000/SongSpeed -- in milisecond
	
	for i, obj in ipairs(MapData["HitObjects"]) do
		local data = string.split(obj, ",")
		-- valid format checking 
		if not tonumber(data[1]) or not tonumber(data[2]) or not tonumber(data[3]) then
			warn(i)
		end
	end

	-- sort based on the time
	table.sort(MapData["HitObjects"], function(obj1, obj2)
		obj1 = string.split(obj1, ",")
		obj2 = string.split(obj2, ",")
		return tonumber(obj1[3]) < tonumber(obj2[3])
	end)


	if metadataonly ~= true then -- this would reduce lag
		for objectID,HitObj in pairs(MapData["HitObjects"]) do
			local HitPos = {X = 0,Y = 0}
			local Time = 0
			local Type = 0
			local Location = 0
			local SpinTime = 0
			local CurrentType = 1
			local SliderTime = 0
			local crrSLBPM = -1
			local crrSLBPMStartTime = 0
			local ExtraData = {}
			local HitObjBPMData = {BPM = 60,SliderMultiplier = 1,LastBPMTiming = 0}
			local RewardPS:{Aim:number, Speed:number, Flashlight:number, AimStrainDecay:number, SpeedStrainDecay:number, FLStrainDecay:number} = {
				Aim = 0, Speed = 0, Flashlight = 0, AimStrainDecay = 1, SpeedStrainDecay = 1, FLStrainDecay = 1
			}
			local StackCount = 0
			local raw = string.split(HitObj,",")

			for CurrentType, data in pairs(raw) do
				if data == "" then
					break
				elseif CurrentType == 1 then
					HitPos.X = tonumber(data)
				elseif CurrentType == 2 then
					HitPos.Y = tonumber(data)
				elseif CurrentType == 3 then
					Time = (tonumber(data)+DelayedTime)/SongSpeed
				elseif CurrentType == 4 then
					Type = tonumber(data)
				elseif CurrentType >= 5 then
					ExtraData[#ExtraData+1] = data
				end
			end

			--slider
			local isSlider = false
			local isSpinner = false
			local SliderLength = 0 -- default it's length is 0
			local SpinnerDuration = -1 -- default value for non-spinner
			local SliderLengthRaw = ExtraData[4]
			ReturningData.NoteCount.Total += 1
			if Type == 2 or Type == 6 or math.floor((Type-22)/16) == (Type-22)/16 then
				ReturningData.NoteCount.Slider += 1
				isSlider = true
				NoteCount.Slider += 1
				local bpmdata = tool.GetBPMData(Time, TimingPoints, SongSpeed)
				--print(bpmdata.LastBPMTiming,Time)
				crrSLBPM = bpmdata.BPM
				crrSLBPMStartTime = bpmdata.LastBPMTiming
				local Slides = tonumber(ExtraData[3])
				local DefaultMulti = (ReturningData.Difficulty.SliderMultiplier or 1)
				--local SliderMulti = math.max(0.1,bpmdata.SliderMultiplier) * DefaultMulti

				bpmdata.SliderMultiplier = math.max(bpmdata.SliderMultiplier,0.1)

				local LengthPerBeat = bpmdata.SliderMultiplier*100
				local LengthPerSec = LengthPerBeat*(bpmdata.BPM/60)

				HitObjBPMData = bpmdata

				SliderTime = (((tonumber(ExtraData[4])*Slides)/LengthPerSec)/DefaultMulti)
				if not modData.NS then
					SliderLength = tonumber(ExtraData[4] * math.pow(1 + (Slides - 1) / 2.5, 1.0 / 2.5))
				end
			elseif Type == 8 or Type == 12 or math.floor((Type-28)/16) == (Type-28)/16 then
				ReturningData.NoteCount.Spinner += 1
				isSpinner = true
				NoteCount.Spinner += 1
				if string.sub(OsuData,17,18) ~= "v9" then
					SpinTime = (tonumber(ExtraData[#ExtraData-1])+DelayedTime)/SongSpeed
				else
					SpinTime = (tonumber(ExtraData[#ExtraData])+DelayedTime)/SongSpeed
				end
				SpinnerDuration = SpinTime - Time
			else
				ReturningData.NoteCount.Circle += 1
			end

			if not isSpinner and not isSlider then
				NoteCount.Circle += 1
			end
			if isReturnDifficulty == true then
				local StreamDifficulty = 0
				local AimDifficulty = 0


				if objectID ~= 1 and not isSpinner then
					local PrevHitObj = ConvertedData[#ConvertedData]
					local TimeBetween = Time-PrevHitObj.Time
					if TimeBetween*SongSpeed <= 1.1 then
						TimeBetween = 9999999999999
					end
					if TimeBetween == 0 then TimeBetween = 1 end
					local DistanceBetween = math.abs((Vector2.new(PrevHitObj.Position.X,PrevHitObj.Position.Y)-Vector2.new(HitPos.X,HitPos.Y)).Magnitude)
					local CS = ReturningData.Difficulty.CircleSize * ((modData.HR and 1.3) or (modData.EZ and 0.5) or 1)
					if modData.HR or modData.EZ then
						CS = math.clamp(CS, 0, 11)
					end
					
					local Normalized_Radius = 50
					
					-- we will process it in the calculator module
					--local CSMultiplier = Normalized_Radius/((54.4 - 4.48 * CS))
					--DistanceBetween *= CSMultiplier
					local DistanceBetween_Speed = DistanceBetween
					--DistanceBetween -= ((54.4 - 4.48 * CS)*2)*0.75 -- only effect aim rating
					--------------
					-- AIM DIFFICULTY CALCULATOR
					if DistanceBetween < 0 then DistanceBetween = 0 end
					if DistanceBetween_Speed < 0 then DistanceBetween_Speed = 0 end
					local MoveSpeed = DistanceBetween/(TimeBetween/1000)
					local Angle = 0
					local LengthPrev = 0
					local LengthCurrent = DistanceBetween
					local TimePrev = 999999999999999
					local BonusAngle = 0
					local VelocityChangeBonus = 1

					local CrrObjData = {
						MoveTime = TimeBetween, DeltaTime = math.floor((TimeBetween)/16)*16, MoveDistance = DistanceBetween_Speed, isSlider = isSlider, isSpinner = isSpinner,
						Angle = 0
					}

					local PrevObjData = {
						MoveTime = 999999999, MoveDistance = 0, SLTravelDistance = PrevHitObj.SLTravelDistance,
						Angle = 0
					}

					local PrevPrevObjData = {
						MoveTime = 999999999, MoveDistance = 0,
						Angle = 0
					}

					local NextObjData

					if objectID > 2 then
						local nextObjPos
						local crrObjPos = Vector2.new(HitPos.X,HitPos.Y)
						local prevObjPos = Vector2.new(ConvertedData[objectID-1].Position.X,ConvertedData[objectID-1].Position.Y)
						local prevObjTime = ConvertedData[objectID-1].Time
						local prevprevObjPos
						local prevprevObjTime
						local prevprevprevObjPos
						if objectID < #MapData["HitObjects"] then
							local nextObjdata = string.split(MapData["HitObjects"][objectID+1],",")
							if #nextObjdata > 1 then
								nextObjPos = Vector2.new(tonumber(nextObjdata[1]),tonumber(nextObjdata[2]))
								CrrObjData.Angle = tool.getAngle(prevObjPos,crrObjPos,nextObjPos)
								NextObjData = {DeltaTime = math.floor((tonumber(nextObjdata[3]) - Time)/16)*16}
							end
						end
						if objectID > 3 then
							prevprevObjPos = Vector2.new(ConvertedData[objectID-2].Position.X,ConvertedData[objectID-2].Position.Y)
							PrevObjData.Angle = tool.getAngle(prevprevObjPos,prevObjPos,crrObjPos)
							PrevObjData.MoveTime = (Time - prevObjTime)
							PrevObjData.MoveDistance = math.max(((prevObjPos - crrObjPos).Magnitude),0)
							if objectID > 4 then
								prevprevObjTime = ConvertedData[objectID-3].Time
								prevprevprevObjPos = Vector2.new(ConvertedData[objectID-4].Position.X,ConvertedData[objectID-4].Position.Y)
								PrevPrevObjData.Angle = tool.getAngle(prevprevprevObjPos,prevprevObjPos,prevObjPos)
								PrevPrevObjData.MoveTime = (prevObjTime - prevprevObjTime)
								PrevPrevObjData.MoveDistance = math.max(((prevprevObjPos - prevObjPos).Magnitude),0)
							end
						end
					end

					local AimDifficulty = 0--calculator.GetAimDiff(CrrObjData, PrevObjData, PrevPrevObjData, ReturningData.Difficulty.CircleSize, modData.HR, modData.EZ)

					local Difficulty = AimDifficulty --GetSpeedDiff(MoveSpeed) * GetDistanceMultiplier(DistanceBetween) * BonusAngle * VelocityChangeBonus
					--Difficulty *= (1+FLMultiplier*#MapData.HitObjects)

					local CircleSize = (54.4 - 4.48 * CS)
					local DistanceBetween2Note = (LastNotePosition-Vector2.new(HitPos.X,HitPos.Y)).Magnitude
					local TimingNerf = 0
					if DistanceBetween <  CircleSize then -- if there's stacking note, decrease speed ps
						local TimingNerf = DistanceBetween/CircleSize*0.2

						if DistanceBetween2Note < CircleSize then -- if 3+ notes stacked, decrease more
							TimingNerf += DistanceBetween2Note/CircleSize*0.1
						end

						NoteStackStrain *= math.pow(0.15,TimeBetween/1000)
						NoteStackStrain += 1

						TimingNerf *= math.pow(0.5,math.max(NoteStackStrain-1,0)) * 5
						--	print(TimingNerf)
					end




					LastNotePosition = Vector2.new(PrevHitObj.Position.X,PrevHitObj.Position.Y)

					local AimStrainDecay = math.pow(0.15,TimeBetween/1000)

					RewardPS.AimStrainDecay = AimStrainDecay
					Difficulty *= 0.85 -- Adjust the aim diff
					CurrentAimStrain *= AimStrainDecay
					CurrentAimStrain += AimDifficulty

					AimDifficulty = Difficulty 

					-- Get acc diff
					if GetPS then
						RewardPS.Aim =  not isSpinner and Difficulty or 0
					end

					-- FLASHLIGHT DIFFICULTY CALCULATOR

					local FlashlightDifficulty = 0

					if modData.FL then
						local ObjList = {}
						-- get current + latest 10 object data
						for crr = 0,10 do
							local ObjData = MapData["HitObjects"][objectID - crr]
							local PrevObjData = MapData["HitObjects"][objectID - crr - 1]
							if not ObjData or not PrevObjData then
								break
							end

							local prevObj = string.split(PrevObjData,",")
							local crrObj = string.split(ObjData,",")

							local Angle = -1
							local PrevObjTime = tonumber(prevObj[3]) or 0
							local CrrObjTime = tonumber(crrObj[3]) or 0
							local MoveTime = math.abs(CrrObjTime - PrevObjTime) -- just in case
							local MoveDistance = (Vector2.new(tonumber(prevObj[1]),tonumber(prevObj[2])) - Vector2.new(tonumber(crrObj[1]),tonumber(crrObj[2]))).Magnitude

							if crr == 0 then
								Angle = CrrObjData.Angle
							elseif objectID - crr < #ConvertedData and objectID-crr-1 >= 1 then
								local nextObj = string.split(MapData["HitObjects"][objectID - crr + 1],",")

								Angle = tool.getAngle(
									Vector2.new(tonumber(prevObj[1]),tonumber(prevObj[2])),
									Vector2.new(tonumber(crrObj[1]),tonumber(crrObj[2])),
									Vector2.new(tonumber(nextObj[1]),tonumber(nextObj[2]))
								)
							end



							local CrrData = {
								Angle = Angle,
								MoveTime = MoveTime,
								MoveDistance = MoveDistance,
								StartTime = CrrObjTime
							}

							ObjList[crr] = CrrData
						end
						FlashlightDifficulty = 0--calculator.getFlashLightDiff(ObjList, #MapData["HitObjects"], ReturningData.Difficulty.CircleSize, ReturningData.Difficulty.ApproachRate, modData.FL, modData.EZ, modData.HR, modData.HD, SongSpeed)
					end

					local FLStrainDecay = math.pow(0.15,TimeBetween/1000)

					CurrentFLStrain *= FLStrainDecay
					RewardPS.FLStrainDecay = FLStrainDecay

					CurrentFLStrain += FlashlightDifficulty

					if GetPS then
						RewardPS.Flashlight =  not isSpinner and FlashlightDifficulty or 0
					end


					-- SPEED (STREAM) DIFFICULTY CALCULATOR

					local PrevTimeBetween = -1
					local PrevDistanceBetween = 0

					local PrevPrevHitObj = ConvertedData[#ConvertedData-1]
					if PrevPrevHitObj then
						PrevTimeBetween = PrevHitObj.Time  - PrevPrevHitObj.Time
						PrevDistanceBetween = (Vector2.new(HitPos.X,HitPos.Y)-Vector2.new(PrevPrevHitObj.X,PrevPrevHitObj.Y)).Magnitude
					end
					local TimeBetween = Time-PrevHitObj.Time 
					local TimingDifficulty = 0--calculator.GetSpeedDiff(CrrObjData, PrevObjData, NextObjData, ReturningData.Difficulty.CircleSize, ReturningData.Difficulty.OverallDifficulty, ReturningData.Difficulty.ApproachRate, modData.EZ, modData.HR, SongSpeed)
					local bpmdata = tool.GetBPMData(Time, TimingPoints, SongSpeed)
					local RhythmMultiplier = 1 -- base
					TimingDifficulty *= RhythmMultiplier
					
					local SpeedStrainDecay = math.pow(0.3,TimeBetween/1000)
					RewardPS.SpeedStrainDecay = SpeedStrainDecay
					CurrentSpeedStrain *= SpeedStrainDecay
					CurrentSpeedStrain += TimingDifficulty

					if GetPS then
						RewardPS.Speed = not isSpinner and TimingDifficulty or 0
					end

					-- Calculate current difficulty
					-- math.pow(HighestAimStrain,0.5)*2.35
					-- old (all): , 0.4365) * 1.495128

					--local exRate = 1/2.3
					--local mulRate = 1.353255313310456

					local CurrentAimStrain = CurrentAimStrain  --math.pow(CurrentAimStrain, exRate) * mulRate * 1.10
					local CurrentSpeedStrain = CurrentSpeedStrain--math.pow(CurrentSpeedStrain, exRate) * mulRate -- Old: , 0.41) * 1.753802
					local CurrentFLStrain =  CurrentFLStrain --math.pow(CurrentFLStrain, exRate) * mulRate
					
					local multiplierBase = 10

					local crrCalculateAim = math.pow(CurrentAimStrain * multiplierBase, DIFFICULTY_VALUE_EXPOMENTAL_RATE)*DIFFICULTY_VALUE_MULTIPLIER_RATE * DIFFICULTY_VALUE_AIM_MULTIPLIER
					local crrCalculateSpeed = math.pow(CurrentSpeedStrain * multiplierBase, DIFFICULTY_VALUE_EXPOMENTAL_RATE)*DIFFICULTY_VALUE_MULTIPLIER_RATE * DIFFICULTY_VALUE_SPEED_MULTIPLIER
					local crrCalculateFL = math.pow(CurrentFLStrain * multiplierBase, DIFFICULTY_VALUE_EXPOMENTAL_RATE)*DIFFICULTY_VALUE_MULTIPLIER_RATE

					local RewardedAimPS = BasePerfomance(crrCalculateAim)
					local RewardedSpeedPS = BasePerfomance(crrCalculateSpeed)
					local RewardedFlashlightPS = BasePerfomance(crrCalculateFL)

					local basePerfomance = ((RewardedAimPS^1.1+RewardedSpeedPS^1.1+RewardedFlashlightPS^1.1)^(1/1.1))
					local CurrentStrain = 0.027 * math.pow(1.15, 1/3) * (math.pow(100000 / math.pow(2, 1 / 1.1) * basePerfomance ,1/3) + 4)

					if CurrentStrain > HighestStrain then
						HighestStrain = CurrentStrain
					end

					--StrainData[#StrainData+1] = CurrentStrain
					AimStrainData[#AimStrainData+1] = CurrentAimStrain
					SpeedStrainData[#SpeedStrainData+1] = CurrentSpeedStrain
					FLStrainData[#FLStrainData+1] = CurrentFLStrain

					DiffList[#DiffList+1] = Difficulty
					RawDifficulty[#RawDifficulty+1] = {CurrentStrain,Time}

				end
			end
			
			local SLTickData = {}
			local SLDifficultyTickData = {}
			local SLCurvePoints:{Vector2} = {}
			local function _getTickPosition(_tickTime:number, isReverse:boolean):Vector2?
				local _slidesCount = tonumber(ExtraData[3])
				local _beatLength = tonumber(ExtraData[4])
				local _slideTime = (SliderTime * 1000 / _slidesCount)
				local _tickProgressLength = ((Time - _tickTime)%_slideTime)/_slideTime * _beatLength
				if not isReverse then
					local _prevLength = 0
					local _currentLength = 0
					for i = 1, #SLCurvePoints - 1 do
						local _crr = SLCurvePoints[i]
						local _next = SLCurvePoints[i+1]
						local _nextLength = _currentLength + (_next - _crr).Magnitude
						
						if _tickProgressLength >= _currentLength then
							local _ratio = math.min(1, (_tickProgressLength - _currentLength)/(_nextLength - _currentLength))
							local _pos = _crr:Lerp(_next, _ratio)
							
							return _pos
						else
							_prevLength = _currentLength
							_currentLength = _nextLength
						end 
					end
				else
					local _prevLength = 0
					local _currentLength = 0
					for i = #SLCurvePoints, 2, -1 do
						local _crr = SLCurvePoints[i]
						local _next = SLCurvePoints[i-1]
						local _nextLength = _currentLength + (_next - _crr).Magnitude

						if _tickProgressLength >= _currentLength then
							local _ratio = math.min(1, (_tickProgressLength - _currentLength)/(_nextLength - _currentLength))
							local _pos = _crr:Lerp(_next, _ratio)

							return _pos
						else
							_prevLength = _currentLength
							_currentLength = _next	
						end 
					end
				end
				warn("Cannot find tick position from tick time!")
				print(_tickTime, Time, SliderTime, _beatLength, _tickProgressLength, isReverse)
				return nil
			end
			if isSlider then
				-- Calculate slider actual curves from raw curve points
				local beatLength = tonumber(ExtraData[4])
				local headPosition = Vector2.new(HitPos.X, HitPos.Y)
				SLCurvePoints = sliderTools.convertToSliderCurve(headPosition, ExtraData[2], beatLength)
				
				-- Calculate slider ticks
				local ObjBPM = crrSLBPM
				local ObjBPMStartTime = crrSLBPMStartTime
				local tickDuration = (60000 / ObjBPM) / ReturningData.Difficulty.SliderTickRate
				local tickCountsSinceStart = math.floor((Time-ObjBPMStartTime) / tickDuration)
				local StartTick = ObjBPMStartTime + tickDuration * (tickCountsSinceStart+1)
				local i = 0
				local tickCount = 0
				local slidesCount = tonumber(ExtraData[3])
				local SliderTime = SliderTime * 1000
				local SLSlideTime = SliderTime / slidesCount
				while StartTick + tickDuration * i < (Time + SliderTime) do
					local currentTime = StartTick + tickDuration * i
					local TimeSinceNoteStart = currentTime - Time
					local TimeBetweenTail = TimeSinceNoteStart%(SLSlideTime)
					local CurrentSlide = math.floor(TimeSinceNoteStart/SliderTime)+1
					if currentTime > Time and currentTime < Time + SliderTime and TimeBetweenTail > 20 and TimeBetweenTail < SliderTime-20 then
						tickCount += 1
						local tickPosition = _getTickPosition(currentTime, CurrentSlide%2==0)
						SLTickData[#SLTickData+1] = {currentTime, CurrentSlide, tickPosition}
						SLDifficultyTickData[#SLDifficultyTickData+1] = {currentTime, CurrentSlide, tickPosition, "Tick"}
					else
						local _type = CurrentSlide < slidesCount and "Repeat" or "Tail"
						local tickPosition = _getTickPosition(currentTime, CurrentSlide%2==0)
						SLDifficultyTickData[#SLDifficultyTickData+1] = {currentTime, CurrentSlide, tickPosition, _type}
					end
					i += 1
				end
				
				-- Just to make sure it includes the slider end
				if #SLDifficultyTickData == 0 or SLDifficultyTickData[#SLDifficultyTickData][4] ~= "Tail" then
					local _tailPosition = SLCurvePoints[(slidesCount % 2 == 1) and #SLCurvePoints or 1]
					local _tailTime = Time + SliderTime
					SLDifficultyTickData[#SLDifficultyTickData+1] = {_tailTime, slidesCount, _tailPosition, "Tail"}
				end
			end
			local HitObjData = {
				ObjId = objectID,
				Position = HitPos,
				Time = Time,
				Type = Type,
				ExtraData = ExtraData,
				SpinTime = SpinTime,
				SliderTime = SliderTime,
				HitObjBPMData = HitObjBPMData,
				PSValue = RewardPS, 
				StackCount = StackCount, 
				isSlider = isSlider, 
				isSpinner = isSpinner, 
				SLTravelDistance = SliderLength, 
				SliderBPM = crrSLBPM,
				SliderBPMStartTime = crrSLBPMStartTime, 
				SliderTickData = SLTickData, 
				SliderDifficultyTickData = SLDifficultyTickData, 
				SliderCurvePoints = SLCurvePoints,
				SpinnerDuration = SpinnerDuration, 
				SliderLengthRaw = SliderLengthRaw
			}			
			local ARRate = math.clamp(ReturningData.Difficulty.ApproachRate * (modData.EZ and 0.5 or (modData.HR and 1.4 or 1)),0,11)
			local ARTime = 1200
			if ARRate < 5 then
				ARTime = 1200 + 600 * (5 - ARRate) / 5
			elseif ARRate > 5 then
				ARTime = 1200 - 750 * (ARRate - 5) / 5
			else
				ARTime = 1200
			end
			
			if ReturningData.StackLeniency > 0 and not (isSpinner) then
				for i = #ConvertedData, 1, -1 do
					-- we roll back to check the stack leniency
					
					local crr = ConvertedData[i+1] or HitObjData
					local prev = ConvertedData[i]
					if prev.isSpinner or prev.isSlider then
						break
					end
					if prev.Time - crr.Time > ARTime * ReturningData.StackLeniency then
						break
					end
					
					if (Vector2.new(prev.Position.X, prev.Position.Y) - Vector2.new(crr.Position.X, crr.Position.Y)).Magnitude < 0.1 then
						prev.StackCount += 1
					else
						break
					end
				end
			end
			ConvertedData[#ConvertedData+1] = HitObjData
		end

		local RemoveList = {}
		for i,Data in pairs(ConvertedData) do
			if (i ~= #ConvertedData and (Data.Time > ConvertedData[i+1].Time or (Data.SliderNote == true and Data.Time > ConvertedData[i+1].Time-100))) then
				RemoveList[#RemoveList+1] = i
			end
		end

		for _,RemoveData in pairs(RemoveList) do
			table.remove(ConvertedData,RemoveData)
		end
	end
	
	-- Stack leniency process
	if ReturningData.StackLeniency > 0 then
		local CSRate = tool.GetDifficultyValueAfterMod.CS(ReturningData.Difficulty.CircleSize, modData)
		local ObjectRadius = 54.4 - 4.48 * CSRate
		local StackVector = ObjectRadius / 10
		for i, crrObj in pairs(ConvertedData) do
			if not (crrObj.isSpinner) then
				crrObj.Position.X -= StackVector * crrObj.StackCount
				crrObj.Position.Y -= StackVector * crrObj.StackCount
			end
		end
	end
	
	-- Checking max combo and spinner score
	local MapMaxCombo = 0
	local MaxSpinnerScore = 0
	local RoundRequiredPerSec = 2.5  -- OD 5: 150RPM
	local MaximumRoundPerSec = 4.5 -- Maximum 450RPM
	
	local ODRateAfterMod = ReturningData.Difficulty.OverallDifficulty * ((modData.HR and 1.4) or (modData.EZ and 0.5) or 1)
	if ODRateAfterMod < 5 then
		RoundRequiredPerSec = 2.5 - 1 * (5-ODRateAfterMod)/5  -- 90 - 150RPM
	else
		RoundRequiredPerSec = 2.5 + 1.25 * (ODRateAfterMod-5)/5 -- 150 - 225RPM
	end
	
	
	
	for _, obj in pairs(ConvertedData) do
		local NoteCombo = 1
		if obj.isSlider and not modData.NS then
			NoteCombo = 1 + #obj.SliderTickData + (tonumber(obj.ExtraData[3]) or 0)
		end
		MapMaxCombo += NoteCombo
		
		if obj.isSpinner then
			local spinDuration = obj.SpinnerDuration / 1000
			local RoundRequired = math.floor(spinDuration*RoundRequiredPerSec)
			local RoundMaximum = math.ceil(spinDuration*MaximumRoundPerSec)
			
			local MaxBonusRound = RoundMaximum - RoundRequired
			
			local BaseScore = RoundMaximum * 100
			local BonusScore = MaxBonusRound * 1000
			MaxSpinnerScore += BaseScore + BonusScore
		end
	end
	
	----------------------------------------------------------------------------
	-- > Difficulty evaluator
	
	-- ignore the old diff data from the above
	-- this will be changed soon
	
	AimStrainData = {}
	AimSLStrainData = {}
	SpeedStrainData = {}
	RhythmDiffData = {}
	FLStrainData = {}
	
	local baseData = {
		AR = tool.GetDifficultyValueAfterMod.AR(ReturningData.Difficulty.ApproachRate, modData),
		CS = tool.GetDifficultyValueAfterMod.CS(ReturningData.Difficulty.CircleSize, modData),
		OD = tool.GetDifficultyValueAfterMod.OD(ReturningData.Difficulty.OverallDifficulty, modData),
		Speed = SongSpeed,
		SliderTickRate = ReturningData.Difficulty.SliderTickRate,
		ModData = modData
	}
	local ProcessedDifficultyObject = preprocessing(ConvertedData, baseData)
	local AimStrain = 0
	local SpeedStrain = 0
	local FLStrain = 0
	
	-- Skills
	
	-- The aim difficulty is the most inaccurate thing to calculate in osu!RoVer
	-- I need to adjust it back to the original osu! standard
	local aimAdjustedMultiplier = 1
	local speedAdjustedMultiplier = 1
	local aimSkillMultiplier = 26 * aimAdjustedMultiplier
	local speedSkillMultiplier = 1.47 * speedAdjustedMultiplier
	local flashlightSkillMultiplier = 0.05512
	
	local AimFLBaseStrainDecay = 0.15
	local SpeedBaseStrainDecay = 0.3
	
	
	for objectId, objectData in pairs(ProcessedDifficultyObject) do
		local AimDiff = evaluators.Aim.GetAimDiff(objectData) * aimSkillMultiplier
		local SpeedDiff = evaluators.Speed.GetSpeedDiff(objectData) * speedSkillMultiplier
		local RhythmDiff = evaluators.Rhythm.GetRhythmDiff(objectData)
		local FLDiff = modData.FL and evaluators.Flashlight.getFlashLightDiff(objectData, modData.HD) or 0
		
		local AimFLStrainDecay = math.pow(AimFLBaseStrainDecay,objectData.DeltaTime/1000)
		AimStrain *= AimFLStrainDecay
		AimStrain += AimDiff
		local SpeedStrainDecay = math.pow(SpeedBaseStrainDecay,objectData.DeltaTime/1000)
		
		SpeedStrain *= SpeedStrainDecay
		SpeedStrain += SpeedDiff
		
		FLStrain *= AimFLStrainDecay
		FLStrain += FLDiff
		
		ConvertedData[objectId].PSValue.Aim = AimDiff
		ConvertedData[objectId].PSValue.Speed = SpeedDiff
		ConvertedData[objectId].PSValue.Rhythm = RhythmDiff
		ConvertedData[objectId].PSValue.Flashlight = FLDiff
		ConvertedData[objectId].PSValue.AimStrainDecay = AimFLStrainDecay
		ConvertedData[objectId].PSValue.SpeedStrainDecay = SpeedStrainDecay
		ConvertedData[objectId].PSValue.FLStrainDecay = AimFLStrainDecay
		
		AimStrainData[#AimStrainData+1] = {AimStrain, objectData.Time}
		SpeedStrainData[#SpeedStrainData+1] = {SpeedStrain * RhythmDiff, objectData.Time}
		RhythmDiffData[#RhythmDiffData+1] = {RhythmDiff, objectData.Time}
		FLStrainData[#FLStrainData+1] = {FLStrain, objectData.Time}
		
		if objectData.isSlider then
			AimSLStrainData[#AimSLStrainData+1] = {AimStrain, objectData.Time}
		end		
		
		local multiplierBase = 10
		
		local baseAim = math.pow(AimStrain * multiplierBase, DIFFICULTY_VALUE_EXPOMENTAL_RATE)*DIFFICULTY_VALUE_MULTIPLIER_RATE * DIFFICULTY_VALUE_AIM_MULTIPLIER
		local baseSpeed = math.pow(SpeedStrain * RhythmDiff * multiplierBase, DIFFICULTY_VALUE_EXPOMENTAL_RATE)*DIFFICULTY_VALUE_MULTIPLIER_RATE * DIFFICULTY_VALUE_SPEED_MULTIPLIER
		local baseFL = math.pow(FLStrain * multiplierBase, DIFFICULTY_VALUE_EXPOMENTAL_RATE)*DIFFICULTY_VALUE_MULTIPLIER_RATE * DIFFICULTY_VALUE_AIM_MULTIPLIER
		local basePerfomance = ((BasePerfomance(baseAim)^1.1+BasePerfomance(baseSpeed)^1.1+BasePerfomance(baseFL)^1.1)^(1/1.1))
		local CurrentStrain = 0.027 * math.pow(1.15, 1/3) * (math.pow(100000 / math.pow(2, 1 / 1.1) * basePerfomance ,1/3) + 4)
		CurrentStrain = math.clamp(CurrentStrain, 0, 50) -- to prevent the graph jumping out of the limit, I've set it to 0-50
		
		RawDifficulty[#RawDifficulty+1] = {CurrentStrain,objectData.Time}
	end

	local BeatmapDifficulty = 0
	local AimDifficulty = 0
	local StreamDifficulty = 0
	local AimDiffStrainCount = 0
	local SpeedDiffStrainCount = 0
	local SpeedRelevantNoteCount = 0
	local LastNoteData = ConvertedData[#ConvertedData]
	local LastNoteTime = LastNoteData.Time
	if LastNoteData.isSlider then
		LastNoteTime += LastNoteData.SliderTime * 1000
	end
	local MapLength = LastNoteTime - ProcessedDifficultyObject[1].Time

	local DifficultyStrikeList = {
		List = {}, Highest = 0
	}

	-- Difficulty timeline caculation

	if isReturnDifficulty == true then
		-- Convert difficulty Part1
		local DiffTimeline = {}
		local DiffHighest = 0
		
		local ActualMapLength = LastNoteTime
		local TimelineCount = math.max(1, math.ceil(ActualMapLength/DifficultyStrikeRecord))
		
		for i = 1, TimelineCount + 1 do
			DiffTimeline[#DiffTimeline+1] = 0
		end
		
		
		for _, RawDiff in pairs(RawDifficulty) do
			local diffTime = RawDiff[2]
			local diff = RawDiff[1] * 10
			DiffHighest = math.max(DiffHighest, diff)
			local crrTimeLine = math.floor(diffTime/DifficultyStrikeRecord) + 1
			if crrTimeLine < 1 then
				continue
			end
			DiffTimeline[crrTimeLine] = math.max(DiffTimeline[crrTimeLine], diff)
		end

		DifficultyStrikeList = {
			List = DiffTimeline,
			Highest = DiffHighest
		}
		------------

		--BeatmapDifficulty = BeatmapDifficulty * 1.3626 -- Old: 1.22
		
		
		
		-- Get difficulty value of Aim, Speed, Flashlight
		
		local DifficultyValue = {
			CS = tool.GetDifficultyValueAfterMod.CS(ReturningData.Difficulty.CircleSize, modData),
			AR = tool.GetDifficultyValueAfterMod.AR(ReturningData.Difficulty.ApproachRate, modData),
			OD = tool.GetDifficultyValueAfterMod.OD(ReturningData.Difficulty.OverallDifficulty, modData),
			HP = tool.GetDifficultyValueAfterMod.HP(ReturningData.Difficulty.HPDrainRate, modData)
		}
		local attributeData:calculator.Data = {
			AimStrain = AimStrainData,
			AimSLStrain = AimSLStrainData,
			SpeedStrain = SpeedStrainData,
			FlashlightStrain = FLStrainData,
			DifficultyValue = DifficultyValue,
			ModData = modData,
			NoteCount = ReturningData.NoteCount
		}
		local difficultyAttributes = calculator.GetDifficultyAttributes(attributeData)
		AimDifficulty = difficultyAttributes.AimDifficulty
		AimDiffStrainCount = difficultyAttributes.AimDifficultStrainCount
		SpeedDifficulty = difficultyAttributes.SpeedDifficulty
		SpeedDiffStrainCount = difficultyAttributes.SpeedDifficultStrainCount
		SpeedRelevantNoteCount = difficultyAttributes.SpeedNoteCount
		FlashlightDifficulty = difficultyAttributes.FlashlightDifficulty
		
		local ARRate = DifficultyValue.AR
		local ODRate = DifficultyValue.OD
		local PSMultiplier = {
			Aim = 1, Speed = 1, FL = 1, Acc = 1
		}

		BeatmapDifficulty = difficultyAttributes.StarRating
	end
	--warn(tostring(AimDifficulty).."\n"..tostring(StreamDifficulty))


	ReturningData.Difficulty.DifficultyStrike = DifficultyStrikeList
	ReturningData.Difficulty.BeatmapDifficulty = BeatmapDifficulty
	ReturningData.Difficulty.AimDifficulty = AimDifficulty
	ReturningData.Difficulty.SpeedDifficulty = SpeedDifficulty
	ReturningData.Difficulty.FlashLightDifficulty = FlashlightDifficulty
	ReturningData.Difficulty.AimDifficultyStrainCount = AimDiffStrainCount
	ReturningData.Difficulty.SpeedDifficultyStrainCount = SpeedDiffStrainCount
	ReturningData.Difficulty.SpeedRelevantNoteCount = SpeedRelevantNoteCount
	ReturningData.Difficulty.MaxCombo = MapMaxCombo
	ReturningData.Difficulty.MaxSpinnerScore = MaxSpinnerScore

	--2234.05 -> 12.19
	--9.15 -> 1.70


	if metadataonly ~= true then
		ReturningData.Overview.MapLength = MapLength
	end

	return ConvertedData,ReturningData,TimingPoints,BeatmapColor
end
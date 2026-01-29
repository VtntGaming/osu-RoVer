--[LOCATION]:[Workspace.OsuConvert]
-- osu!RoVer converter
-- convert raw osu file into readable and excutable lua data
-- V1.47 (Size: 27.69KB)

local IS_GAME_RUNNING = game:GetService("RunService"):IsRunning()	-- If it's executed from command bar, I will try to disable some of the calculation
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local StrainSkills = require(workspace.DifficultyCalculator.StrainSkills)
local calculator = require(workspace.DifficultyCalculator)
local tool = require(script.converterTools)
local sliderTools = require(script.sliderTools)
local preprocessing = require(workspace.DifficultyCalculator.DifficultyHitObjects)
local modData = require(workspace.ModData)

export type ModData = modData.ModData

local CachedData = {} :: {[number]: {[any]: any}}

local function fnv1a(str: string): number
	local hash = 2166136261
	for i = 1, #str do
		hash = bit32.bxor(hash, string.byte(str, i))
		hash = (hash * 16777619) % 2^32
	end
	return hash
end

return function(FileType,Beatmap,DelayedTime,isReturnDifficulty,metadataonly,modData:ModData)
	local OsuData = Beatmap
	local cacheId = -1
	if FileType == 1 then
		OsuData = require(Beatmap)

		-- We do a quick inspect
		local mapId = string.match(OsuData, "BeatmapID:([^%s]+)") or Beatmap.Name
		local hashName = mapId..HttpService:JSONEncode(modData)
		cacheId = fnv1a(hashName)
		-- Find the cache with the same map, same mod
		if CachedData[cacheId] then
			return table.unpack(CachedData[cacheId])
		end
	elseif FileType == 3 then
		OsuData = ReplicatedStorage.GetModuleData:InvokeServer(tonumber(Beatmap))
	end

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
	local TimingPoints = {}
	local BeatmapColor
	local OriginalPreviewTime = -1	

	-- Spilt into categories
	---------------
	local Listraw = string.split(OsuData, "\n")
	local currentIndex = nil
	local onStoryboardLine = false
	for i = 1, #Listraw do
		local crrLine = Listraw[i]
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
				elseif string.find(crrLine,"Storyboard Layer") then
					onStoryboardLine = true
					continue
				end
			end
			
			MapData[currentIndex][#MapData[currentIndex] + 1] = crrLine
		end
	end
	
	-- Make sure that no data is blank
	pcall(function()
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
				for i = 1, #raw do
					local data = raw[i]
					CurrentTimmingPoint[#CurrentTimmingPoint+1] = tonumber(data)
				end
				CurrentTimmingPoint[1] += DelayedTime
				CurrentTimmingPoint[1] /= SongSpeed
				TimingPoints[#TimingPoints+1] = CurrentTimmingPoint
			end
			table.sort(TimingPoints,function(timing1,timing2)
				return timing1[1] < timing2[1]
			end)
			for i = 1, #TimingPoints do
				local TimingPoint = TimingPoints[i]
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
			for i = 1, #MapData.Colours do
				local RawData = MapData.Colours[i]
				local raw = string.split(RawData,":")
				Colours[#Colours+1] = string.sub(raw[2], 2, #raw[2])
			end

			-- Process colour
			local ConvertedColors = {}
			for i = 1, #Colours do
				local RawColor = Colours[i]
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
			local breakPeriods = BeatmapEvents["Break Periods"]
			for i = 1, #breakPeriods do
				local breaktime = breakPeriods[i]
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
	local RawDifficulty = {}
	--local StrainData = {}
	local AimStrainData = {}
	local AimSLStrainData = {}
	local SpeedStrainData = {}
	local RhythmDiffData = {}
	local ReadingStrainData = {}
	local FLStrainData = {}
	local AimDifficulty = 0
	local SpeedDifficulty = 0
	local FlashlightDifficulty = 0
	local ReadingDifficulty = 0
	local NoteCount = {
		Circle = 0, Slider = 0, Spinner = 0
	}

	local ODMultiplier = 1 --115 / ((119.5 - 9 * OD))
	ODMultiplier = ODMultiplier ^ 0.2

	-- RawDifficulty = {[1] = {<Time>,<Diff>}}
	-- RawDifficulty2 = {[1] = {[1] = <HighestDiff>,[2] = <2nd highest>}}
	-- DifficultyStrike = {[1] = <Diff>}
	-- Difficulty record each 5 seconds

	local DifficultyStrikeRecord = 2000/SongSpeed -- in milisecond
	
	local HitObjectsListing = {}
	local hitObjects = MapData["HitObjects"]

	for i = 1, #hitObjects do
		local obj = hitObjects[i]
		local data = string.split(obj, ",")
		local Time = 0
		local pass = true
		-- valid format checking 
		for i = 1, 3 do
			local num = tonumber(data[i])
			if not num then
				pass = false
				break
			elseif i == 3 then
				Time = num
			end
		end
		
		if pass then
			HitObjectsListing[#HitObjectsListing+1] = {
				Time = Time,
				Data = obj
			}
		end
	end

	-- sort based on the time
	table.sort(HitObjectsListing, function(obj1, obj2)
		if not obj1.Time then
			return false
		elseif not obj2.Time then
			return true
		else
			return obj1.Time < obj2.Time
		end
	end)

	if metadataonly ~= true then -- this would reduce lag
		for objectID = 1, #HitObjectsListing do
			local HitObjData = HitObjectsListing[objectID]
			local HitObj = HitObjData.Data
			local HitPos = {X = 0,Y = 0}
			local Time = 0
			local Type = 0
			local SpinTime = 0
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

			HitPos.X = tonumber(raw[1]) or 0
			local yPos = tonumber(raw[2]) or 0
			if modData.HR then
				yPos = 384 - yPos
			end
			HitPos.Y = yPos
			Time = (tonumber(raw[3])+DelayedTime)/SongSpeed or Time
			Type = tonumber(raw[4]) or Type
			for i = 5, #raw do
				local data = raw[i]
				if data == "" then
					break
				end
				ExtraData[#ExtraData+1] = data
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
			
			local SLTickData = {}
			local SLDifficultyTickData = {}
			local SLCurvePoints:{Vector2} = {}
			if isSlider then
				-- Calculate slider actual curves from raw curve points
				local beatLength = tonumber(ExtraData[4])
				local headPosition = Vector2.new(HitPos.X, HitPos.Y)
				SLCurvePoints = sliderTools.convertToSliderCurve(headPosition, ExtraData[2], beatLength, modData.HR)
				
				-- Calculate slider ticks
				local ObjBPM = crrSLBPM
				local ObjBPMStartTime = crrSLBPMStartTime
				local tickDuration = (60000 / ObjBPM) / ReturningData.Difficulty.SliderTickRate
				local tickCountsSinceStart = math.floor((Time-ObjBPMStartTime) / tickDuration)
				local StartTick = ObjBPMStartTime + tickDuration * (tickCountsSinceStart+1)
				local i = 0
				local tickCount = 0
				local slidesCount = tonumber(ExtraData[3])
				local sliderTimeSec = SliderTime * 1000
				local SLSlideTime = sliderTimeSec / slidesCount
				while StartTick + tickDuration * i < (Time + sliderTimeSec) do
					local currentTime = StartTick + tickDuration * i
					local TimeSinceNoteStart = currentTime - Time
					local TimeBetweenTail = TimeSinceNoteStart%(SLSlideTime)
					local CurrentSlide = math.floor(TimeSinceNoteStart/sliderTimeSec)+1
					if currentTime > Time and currentTime < Time + sliderTimeSec and TimeBetweenTail > 20 and TimeBetweenTail < SliderTime-20 then
						tickCount += 1
						local tickPosition = tool.GetTickPosition(Time, SliderTime, SLCurvePoints, ExtraData, currentTime, CurrentSlide%2==0)
						SLTickData[#SLTickData+1] = {currentTime, CurrentSlide, tickPosition}
						SLDifficultyTickData[#SLDifficultyTickData+1] = {currentTime, CurrentSlide, tickPosition, "Tick"}
					else
						local _type = CurrentSlide < slidesCount and "Repeat" or "Tail"
						local tickPosition = tool.GetTickPosition(Time, SliderTime, SLCurvePoints, ExtraData, currentTime, CurrentSlide%2==0)
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
			local objData = {
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
					
					local crr = ConvertedData[i+1] or objData
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
			ConvertedData[#ConvertedData+1] = objData
		end

		local RemoveList = {}
		for i = 1, #ConvertedData do
			local Data = ConvertedData[i]
			if (i ~= #ConvertedData and (Data.Time > ConvertedData[i+1].Time or (Data.SliderNote == true and Data.Time > ConvertedData[i+1].Time-100))) then
				RemoveList[#RemoveList+1] = i
			end
		end

		for i = 1, #RemoveList do
			local RemoveData = RemoveList[i]
			table.remove(ConvertedData,RemoveData)
		end
	end
	
	-- Stack leniency process
	if ReturningData.StackLeniency > 0 then
		local CSRate = tool.GetDifficultyValueAfterMod.CS(ReturningData.Difficulty.CircleSize, modData)
		local ObjectRadius = 54.4 - 4.48 * CSRate
		local StackVector = ObjectRadius / 10
		for i = 1, #ConvertedData do
			local crrObj = ConvertedData[i]
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
	
	for i = 1, #ConvertedData do
		local obj = ConvertedData[i]
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
	
	-- Skills
	AimStrainData, AimSLStrainData, SpeedStrainData, RhythmDiffData, FLStrainData, ReadingStrainData = StrainSkills.InitializeStrains(ProcessedDifficultyObject, modData, ConvertedData, RawDifficulty)

	local BeatmapDifficulty = 0
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
		local DiffTimeline = {}
		local DiffHighest = 0
		
		local ActualMapLength = LastNoteTime
		local TimelineCount = math.max(1, math.ceil(ActualMapLength/DifficultyStrikeRecord))
		
		for i = 1, TimelineCount + 1 do
			DiffTimeline[#DiffTimeline+1] = 0
		end
		
		for i = 1, #RawDifficulty do
			local RawDiff = RawDifficulty[i]
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
			ReadingStrain = ReadingStrainData,
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
		ReadingDifficulty = difficultyAttributes.ReadingDifficulty

		BeatmapDifficulty = difficultyAttributes.StarRating
	end

	local consistencyScore, accuracyScore, v1Score = tool.GetScoreV1(MapMaxCombo)
	ReturningData.Difficulty.DifficultyStrike = DifficultyStrikeList
	ReturningData.Difficulty.BeatmapDifficulty = BeatmapDifficulty
	ReturningData.Difficulty.AimDifficulty = AimDifficulty
	ReturningData.Difficulty.SpeedDifficulty = SpeedDifficulty
	ReturningData.Difficulty.ReadingDifficulty = ReadingDifficulty
	ReturningData.Difficulty.FlashLightDifficulty = FlashlightDifficulty
	ReturningData.Difficulty.AimDifficultyStrainCount = AimDiffStrainCount
	ReturningData.Difficulty.SpeedDifficultyStrainCount = SpeedDiffStrainCount
	ReturningData.Difficulty.SpeedRelevantNoteCount = SpeedRelevantNoteCount
	ReturningData.Difficulty.MaxCombo = MapMaxCombo
	ReturningData.Difficulty.MaxSpinnerScore = MaxSpinnerScore
	ReturningData.Difficulty.MaxScoreV1 = {
		Total = v1Score,
		AccuracyScore = accuracyScore,
		ConsistencyScore = consistencyScore
	}

	if metadataonly ~= true then
		ReturningData.Overview.MapLength = MapLength
	end
	
	if cacheId ~= -1 and IS_GAME_RUNNING then
		-- Save data to cached, this will be used later
		CachedData[cacheId] = table.pack(ConvertedData,ReturningData,TimingPoints,BeatmapColor)		
	end

	return ConvertedData,ReturningData,TimingPoints,BeatmapColor
end
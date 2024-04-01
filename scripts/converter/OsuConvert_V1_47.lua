--!native
-- osu!RoVer converter
-- convert raw osu file into readable and excutable lua data
-- V1.46 (Size: 41.37KB)

return function(FileType,Beatmap,SongSpeed,DelayedTime,CustomSongIDEnabled,isReturnDifficulty,metadataonly,GetPS,IsHR,isFL,IsEZ,IsHD)
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
	ReturningData.BreakTime = {}
	ReturningData.BeatmapSetsData = {}
	ReturningData.BeatmapVolume = 0.5
	ReturningData.SongSpeed = 1
	ReturningData.SongPitch = 1
	ReturningData.ImageId = 0
	ReturningData.SampleSet = "normal"
	ReturningData.OriginalOffset = 0

	local MapData = {}
	local MapDataName = {}
	local TimingPoints = {}
	local BeatmapColor
	local isDone = false
	local CurrentNameLocation = 1
	local OriginalPreviewTime = -1

	local Allowed = {"RobloxData","General","Editor","Metadata","Difficulty","Events","TimingPoints","Colours","HitObjects"}
	--while isDone == false do
	while string.find(OsuData,"[[]") ~= nil do
		local StartName = -1
		local PrevStartName = -1
		local Start = string.find(OsuData,"[[]",CurrentNameLocation)
		local End = string.find(OsuData,"[]]",Start)
		if Start == nil or End == nil then
			break
		end

		local Result = string.sub(OsuData,Start+1,End-1)
		local FullResult = string.sub(OsuData,Start,End)
		if table.find(Allowed,Result) then
			if #MapDataName > 0 then
				table.remove(MapDataName[1],3)
				table.insert(MapDataName[1],3,Start-1)
			end
			table.insert(MapDataName,1,{FullResult,End+1,#OsuData})
		end
		CurrentNameLocation = End+2
		-- Old down, New up
		--[[
		for i = CurrentNameLocation,#OsuData do
			if string.sub(OsuData,i,i) == "[" then
				PrevStartName = StartName
				StartName = i
			elseif string.sub(OsuData,i,i) == "]" then
				if table.find(Allowed,string.sub(OsuData,StartName+1,i-1)) then
					if #MapDataName > 0 then
						table.remove(MapDataName[1],3)
						table.insert(MapDataName[1],3,StartName-1)
					end
					table.insert(MapDataName,1,{string.sub(OsuData,StartName,i),i+1,#OsuData})
					CurrentNameLocation = i+2
					break
				else
					StartName = PrevStartName
				end
			elseif i == #OsuData then
				isDone = true
			end
		end]]
	end

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
	for _,MapDataName in pairs(MapDataName) do
		local DataName = string.sub(MapDataName[1],2,#MapDataName[1]-1)
		MapData[DataName] = {}
		local CurrentLocation = MapDataName[2]
		local Done = false
		while Done == false do
			local End = string.find(OsuData,"\n",CurrentLocation)
			if End == nil or End > MapDataName[3] then
				break
			end
			MapData[DataName][#MapData[DataName]+1] = string.sub(OsuData,CurrentLocation,End-1)
			local NewStart = string.find(OsuData,"\n",End)
			if NewStart == nil or NewStart > MapDataName[3] then
				break
			end
			CurrentLocation = NewStart+1
		end

		--[[
		for i = MapDataName[2],MapDataName[3] do
			if string.sub(OsuData,i,i) == Space then
				MapData[DataName][#MapData[DataName]+1] = string.sub(OsuData,CurrentLocation,i-1)
				CurrentLocation = i+1
			end
		end]]
		if DataName == "Metadata" and metadataonly == true then
			break
		end
	end

	---------------


	-- Make sure that no data is blank

	for num1,_1 in pairs(MapData) do
		for num2,_2 in pairs(_1) do
			if _2 == "" then
				table.remove(_1,num2)
			end
		end
	end
	
	local function ConvertRaw(FileText)
		local _,e = string.find(FileText,"content\\")
		FileText = string.sub(FileText,e+1,#FileText)
		while true do
			local s = string.find(FileText,"\\")
			if s then
				FileText = string.sub(FileText,1,s-1).."/"..string.sub(FileText,s+1,#FileText)
			else
				break
			end
		end
		
		return "rbxasset://"..FileText
	end

	local a,_ = pcall(function()
		if MapData.RobloxData ~= nil  then
			local RblxData = {}
			for _,RawData in pairs(MapData.RobloxData) do
				for i = 1,#RawData do
					if string.sub(RawData,i,i) == ":" then
						RblxData[string.sub(RawData,1,i-1)] = tonumber(string.sub(RawData,i+1,#RawData)) or string.sub(RawData,i+1,#RawData)
					end
				end
			end

			-- Process RblxData


			if RblxData.SoundOffset ~= nil and CustomSongIDEnabled == false then
				DelayedTime += 30+RblxData.SoundOffset/SongSpeed
				ReturningData.OriginalOffset = RblxData.SoundOffset
			end

			if RblxData.CustomSoundFile then
				ReturningData.CustomSongFile = ConvertRaw(RblxData.CustomSoundFile)
			end
			if RblxData.RblxSoundID ~= nil and CustomSongIDEnabled == false then
				ReturningData.MapSongId = RblxData.RblxSoundID
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
				ReturningData.CustomBackgroundFile = ConvertRaw(RblxData.CustomBackgroundFile)
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
				for i = 1,#RawData do
					if string.sub(RawData,i,i) == ":" then
						Difficulty[string.sub(RawData,1,i-1)] = tonumber(string.sub(RawData,i+1,#RawData))
					end
				end
			end

			-- Process Difficulty
			ReturningData.Difficulty = Difficulty
		end
	end)


	pcall(function()
		if MapData.Metadata ~= nil then
			local Metadata = {}
			for _,RawData in pairs(MapData.Metadata) do
				for i = 1,#RawData do
					if string.sub(RawData,i,i) == ":" then
						Metadata[string.sub(RawData,1,i-1)] = string.sub(RawData,i+1,#RawData)
					end
				end
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
			ReturningData.Overview.Metadata.Tags = Metadata.Tags

			ReturningData.BeatmapSetsData = {BeatmapsetID = Metadata.BeatmapSetID,BeatmapID = Metadata.BeatmapID}
		end
	end)

	pcall(function()
		if MapData.General ~= nil  then
			local General = {}
			for _,RawData in pairs(MapData.General) do
				for i = 1,#RawData do
					if string.sub(RawData,i,i) == ":" then
						General[string.sub(RawData,1,i-1)] = string.sub(RawData,i+1,#RawData)
					end
				end
			end

			-- Process beatmap basic settings
			local PreviewTime = tonumber(General.PreviewTime)
			if PreviewTime ~= nil then
				OriginalPreviewTime = PreviewTime
				ReturningData.Overview.OverviewStartTime = PreviewTime+DelayedTime
			end
			
			local SampleSet = string.lower(General.SampleSet or "normal")
			ReturningData.SampleSet = SampleSet
		end
	end)

	pcall(function()
		if MapData.TimingPoints ~= nil  then
			for _,RawData in pairs(MapData.TimingPoints) do
				if RawData ~= "" then
					local CurrentLocation = 1
					local CurrentTimmingPoint = {}
					for i = 1,#RawData do
						if string.sub(RawData,i,i)  == "," or i == #RawData then
							CurrentTimmingPoint[#CurrentTimmingPoint+1] = tonumber(string.sub(RawData,CurrentLocation,(i~=#RawData and i-1) or i))
							CurrentLocation = i+1
						end
					end
					CurrentTimmingPoint[1] += DelayedTime
					CurrentTimmingPoint[1] /= SongSpeed
					TimingPoints[#TimingPoints+1] = CurrentTimmingPoint
				end
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
				for i = 1,#RawData do
					if string.sub(RawData,i,i) == ":" then
						Colours[#Colours+1] = string.sub(RawData,i+2,#RawData)
					end
				end
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

	local function GetBPMData(Time)
		local data = {BPM = 60,SliderMultiplier = 1,LastBPMTiming = 0}
		local BPMVaild = false
		for i,TimingData in pairs(TimingPoints) do
			if TimingData[1] > Time and BPMVaild then
				break
			end
			
			if TimingData[2] > 0 then -- bpm
				if TimingData[1] > Time and BPMVaild then continue end
				data.BPM = (1 / TimingData[2] * 1000 * 60)*SongSpeed
				data.LastBPMTiming = TimingData[1]
				BPMVaild = true
				
				if not TimingPoints[i-1] or TimingPoints[i-1][1] < TimingData[1] then
					data.SliderMultiplier = 1
				end
			else	-- slider multiplier
				if TimingData[1] > Time then continue end
				data.SliderMultiplier = 1/((-TimingData[2])/100)
			end
		end
		
		return data
	end

	-- Finding HitObjects
	--[[

	local StartFile = 0
	for i = 1,#OsuData do
		if string.sub(OsuData,i,i+11) == "[HitObjects]" then
			StartFile = i+13
			break
		end
	end
	local CurrentLocation = StartFile
	for i = StartFile,#OsuData do
		if string.sub(OsuData,i,i) == Space then
			Data[#Data+1] = string.sub(OsuData,CurrentLocation,i-1)
			CurrentLocation = i+1
		end
	end]]

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
	local StrainData = {}
	local AimStrainData = {}
	local SpeedStrainData = {}
	local AimDiff = {}
	local StreamDiff = {}
	local HighestAimStrain = 0
	local CurrentAimStrain = 0
	local CurrentSpeedStrain = 0
	local HighestSpeedStrain = 0
	local CurrentStrain = 0
	local HighestStrain = 0
	local AvgStrain = 0
	local PrevVelocity = 0
	local PrevMoveTime = 0
	local FLMultiplier = 0
	local LastNotePosition = Vector2.new(0,0)
	local NoteStackStrain = 0
	local PrevDoubleTapness = 1
	
	if isFL then

		local CircleApproachTime = 1200

		local ApproachRate = ReturningData.Difficulty.ApproachRate

		if ApproachRate < 5 then
			CircleApproachTime = 1200 + 600 * (5 - ApproachRate) / 5
		elseif ApproachRate > 5 then
			CircleApproachTime = 1200 - 750 * (ApproachRate - 5) / 5
		else
			CircleApproachTime = 1200
		end

		-- 750

		CircleApproachTime /= SongSpeed
		local Difference = CircleApproachTime - 450
		local ARFLMultiplier = (1-(Difference/750))
		FLMultiplier = 0.0006 + ARFLMultiplier * 0.0001

		if IsHD then
			FLMultiplier = 0.0007 + ARFLMultiplier * 0.0001
		end
	end
	
	local OD = ReturningData.Difficulty.OverallDifficulty * ((IsHR and 1.4) or (IsEZ and 0.5) or 1)
	
	if OD > 10 then
		OD = 10
	end
	
	local ODMultiplier = 56.5 / ((119.5 - 9 * OD))
	ODMultiplier = ODMultiplier ^ 0.2

	-- RawDifficulty = {[1] = {<Time>,<Diff>}}
	-- RawDifficulty2 = {[1] = {[1] = <HighestDiff>,[2] = <2nd highest>}}
	-- DifficultyStrike = {[1] = <Diff>}
	-- Difficulty record each 5 seconds
	GetPS = true

	local DifficultyStrikeRecord = 2000/SongSpeed -- in miliseconds
	



	if metadataonly ~= true then -- this would reduce lag
		for objectID,HitObj in pairs(MapData["HitObjects"]) do
			local HitPos = {X = 0,Y = 0}
			local Time = 0
			local Type = 0
			local Location = 0
			local SpinTime = 0
			local CurrentType = 1
			local SliderTime = 0
			local ExtraData = {}
			local HitObjBPMData = {BPM = 60,SliderMultiplier = 1,LastBPMTiming = 0}
			local RewardPS = {
				Aim = 0, Stream = 0, AimStrainDecay = 1, SpeedStrainDecay = 1, FLStrainDecay = 1
			}
			while true do
				local i = string.find(HitObj,",",Location)
				if i == nil then
					i = #HitObj
				end
				if CurrentType == 1 then
					HitPos.X = tonumber(string.sub(HitObj,Location,i-1))
				end
				if CurrentType == 2 then
					HitPos.Y = tonumber(string.sub(HitObj,Location,i-1))
				end
				if CurrentType == 3 then
					Time = (tonumber(string.sub(HitObj,Location,i-1))+DelayedTime)/SongSpeed
				end
				if CurrentType == 4 then
					Type = tonumber(string.sub(HitObj,Location,i-1))
				end
				if CurrentType >= 5 then
					if i ~= #HitObj then
						ExtraData[#ExtraData+1] = string.sub(HitObj,Location,i-1)
					else
						ExtraData[#ExtraData+1] = string.sub(HitObj,Location,i)
					end
				end
				if string.find(HitObj,",",Location) == nil then
					break
				end
				Location = i+1
				CurrentType = CurrentType + 1

			end
			
			--slider
			if Type == 2 or Type == 6 or math.floor((Type-22)/16) == (Type-22)/16 then
				local bpmdata = GetBPMData(Time)
				--print(bpmdata.LastBPMTiming,Time)
				local Slides = tonumber(ExtraData[3])
				local DefaultMulti = (ReturningData.Difficulty.SliderMultiplier or 1)
				--local SliderMulti = math.max(0.1,bpmdata.SliderMultiplier) * DefaultMulti
				
				bpmdata.SliderMultiplier = math.max(bpmdata.SliderMultiplier,0.1)
				
				local LengthPerBeat = bpmdata.SliderMultiplier*100
				local LengthPerSec = LengthPerBeat*(bpmdata.BPM/60)
				
				HitObjBPMData = bpmdata

				SliderTime = (((tonumber(ExtraData[4])*Slides)/LengthPerSec)/DefaultMulti)
				
				--print(Time,SliderTime,bpmdata.BPM,bpmdata.SliderMultiplier)
			end
			
			--spinner
			local isSpinner = false

			if Type == 8 or Type == 12 or math.floor((Type-28)/16) == (Type-28)/16 then
				isSpinner = true
				if string.sub(OsuData,17,18) ~= "v9" then
					SpinTime = (tonumber(ExtraData[#ExtraData-1])+DelayedTime)/SongSpeed
				else
					SpinTime = (tonumber(ExtraData[#ExtraData])+DelayedTime)/SongSpeed
				end
			end

			local function GetWideAngleBonus(Angle)
				if Angle > 180 then
					Angle = 180 - (Angle - 180)
				end

				Angle = math.rad(Angle)

				if Angle < math.pi / 3 then
					return 0
				elseif Angle < 2 * math.pi / 3 then
					return math.pow(math.sin(1.5 * (Angle - math.pi / 3)), 2)
				else
					return 0.25 + 0.75 * math.pow(math.sin(1.5 * (math.pi - Angle)), 2)
				end
			end

			local function GetAcuteAngleBonus(Angle)
				Angle = math.rad(Angle)

				if Angle < math.pi / 3 then
					return 0.5 + 0.5 * math.pow(math.sin(1.5 * Angle), 2)
				elseif Angle < 2 * math.pi / 3 then
					return math.pow(math.sin(1.5 * (2 * math.pi / 3 - Angle)), 2)
				else
					return 0
				end
			end

			local function GetAngleBonus(Angle, CurrentMoveTime, PrevMoveTime, lengthprev, lengthcurrent)
				local AngleBonus = math.min(lengthprev, lengthcurrent)
				local Acute = GetAcuteAngleBonus(Angle)
				local wide = GetWideAngleBonus(Angle)

				if PrevMoveTime > 100 then
					Acute = 0
				else
					Acute = Acute * math.min(2, math.pow((100 - PrevMoveTime) / 15, 1.5))
					wide = wide * math.pow(PrevMoveTime / 100, 6)
				end

				if Acute > wide then
					AngleBonus = math.min(AngleBonus, 150 / PrevMoveTime) * math.min(1, math.pow(math.min(PrevMoveTime, CurrentMoveTime) / 150, 2))
				end

				AngleBonus = AngleBonus * math.max(Acute, wide) / 130

				local AngleMultiplier = 0.85 + (AngleBonus / 0.75) * 0.15

				return AngleMultiplier
			end

			local function GetDistanceMultiplier(Distance)
				if Distance <= 1 then
					return 0 -- Single note with a very low distance or overlap with the next note => No bonus
				end
				if true then
					return 1+math.pow(360/640,1.9)*0.3
				end
				if Distance <= 80 then
					return 1
				elseif Distance <= 360 then
					return 1 + (Distance - 80) / 560 * 0.1
				elseif Distance <= 640 then
					return 1.1 + (Distance - 360) / 280 * 0.2
				else
					return 1.3
				end
			end
			
			local function GetAimDiff(CrrObj, PrevObj, PrevPrevObj)
				local wide_angle_multiplier = 1.5
				local acute_angle_multiplier = 1.95
				local slider_multiplier = 1.35
				local velocity_change_multiplier = 0.75
				
				local crrVelocity = CrrObj.MoveDistance/CrrObj.MoveTime
				local prevVelocity = PrevObj.MoveDistance/PrevObj.MoveTime
				
				local wideAngleBonus = 0
				local acuteAngleBonus = 0
				local SLBonus = 0
				local velocityChangeBonus = 0
				
				local baseAimStrain = crrVelocity
				
				if math.max(CrrObj.MoveTime,PrevObj.MoveTime) < 1.25 * math.min(CrrObj.MoveTime,PrevObj.MoveTime) then
					-- process for same or "almost same" note time
					if (CrrObj.Angle > 0 and PrevObj.Angle > 0 and PrevPrevObj.Angle > 0) then
						local crrAngle = CrrObj.Angle
						local lastAngle = PrevObj.Angle
						local lastlastAngle = PrevPrevObj.Angle
						
						local angleBonus = math.min(crrVelocity, prevVelocity)
						local function calcWideAngleBonus(angle) return math.pow(math.sin(3.0 / 4 * (math.min(5.0 / 6 * math.pi, math.max(math.pi / 6, angle)) - math.pi / 6)), 2) end
						local function calcAcuteAngleBonus(angle) return 1 - calcWideAngleBonus(angle) end
						
						wideAngleBonus = calcWideAngleBonus(crrAngle)
						acuteAngleBonus = calcAcuteAngleBonus(crrAngle)
						
						
						if CrrObj.MoveTime > 100 then
							acuteAngleBonus = 0
						else
							acuteAngleBonus *= calcAcuteAngleBonus(lastAngle)
							* math.min(angleBonus,125/CrrObj.MoveTime)
							* math.pow(math.sin(math.pi/2*math.min(1,(100-CrrObj.MoveTime)/25)),2)
							* math.pow(math.sin(math.pi/2*(math.clamp(CrrObj.MoveDistance,50,100)-50)/50),2)
						end
						
						wideAngleBonus *= angleBonus * (1 - math.min(wideAngleBonus,math.pow(calcWideAngleBonus(lastAngle),3)))
						acuteAngleBonus *= 0.5 + 0.5 * (1 - math.min(acuteAngleBonus, math.pow(calcAcuteAngleBonus(lastlastAngle),3)))
					end
					
					
					
				end
				
				if math.max(prevVelocity, crrVelocity) ~= 0 then
					local distanceRatio = math.pow(math.sin(math.pi/2*math.abs(prevVelocity-crrVelocity)/math.max(prevVelocity,crrVelocity)),2)
					local overlapVelocityBuff = math.min(125/math.min(CrrObj.MoveTime, PrevObj.MoveTime),math.abs(prevVelocity-crrVelocity))
					
					

					velocityChangeBonus = overlapVelocityBuff * distanceRatio

					velocityChangeBonus *= math.pow(math.min(CrrObj.MoveTime, PrevObj.MoveTime)/ math.max(CrrObj.MoveTime,PrevObj.MoveTime),2)
				end
				

				baseAimStrain += math.max(acuteAngleBonus * acute_angle_multiplier, wideAngleBonus * wide_angle_multiplier + velocityChangeBonus * velocity_change_multiplier)
				
				return baseAimStrain * 23.55
			end
			
			local function GetStreamDiff(CrrObj, prevObj, nextObj)
				local single_spacing_threshold = 125
				local min_speed_bonus = 75
				local speed_balancing_factor = 40
				
				local strainTime = CrrObj.MoveTime
				local doubletapness = 1
				local hit300s = 80 - 6 * ReturningData.Difficulty.OverallDifficulty -- base windows of original osu
				
				if nextObj ~= nil then
					local crrDeltaTime = math.max(CrrObj.DeltaTime)
					local nextDeltaTIme = math.max(1, nextObj.DeltaTime)
					local deltaDifference = math.abs(nextDeltaTIme-crrDeltaTime)
					local speedRatio = crrDeltaTime/math.max(crrDeltaTime,deltaDifference)
					local windowRatio = math.pow(math.min(1, crrDeltaTime / hit300s), 2)
					doubletapness = math.pow(speedRatio, 1-windowRatio)
				end
				
				strainTime /= math.clamp((strainTime/hit300s)/ 0.93, 0.92, 1)
				
				local speedBonus = 1
				
				if (strainTime < min_speed_bonus) then
					speedBonus = 1 + 0.75 * math.pow((min_speed_bonus - strainTime)/speed_balancing_factor , 2)
				end
				
				local travelDistance = prevObj.MoveTime or 0
				local distance = math.min(single_spacing_threshold, travelDistance + CrrObj.MoveDistance)
				
				local SpeedDiff = (speedBonus + speedBonus * math.pow(distance/single_spacing_threshold, 3.5)) * doubletapness / strainTime
				return SpeedDiff * 1375
			end
			
			
			
			
			
			--local MulList = {1,0.4,0.3,0.26}
			local MulList = {0.75,0.3,0.225,0.195}
			
			
			

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
					local CS = ReturningData.Difficulty.CircleSize * ((IsHR and 1.3) or (IsEZ and 0.5) or 1)
					if CS > 11 then CS = 11 end
					DistanceBetween *= 36.48/((54.4 - 4.48 * CS))
					local DistanceBetween_Speed = DistanceBetween
					DistanceBetween -= ((54.4 - 4.48 * CS)*2) -- only effect aim rating
					--------------
					if DistanceBetween < 0 then DistanceBetween = 0 end
					if DistanceBetween_Speed < 0 then DistanceBetween_Speed = 0 end
					if isFL then
						--DistanceBetween *= 3
					end
					local MoveSpeed = DistanceBetween/(TimeBetween/1000)
					local Angle = 0
					local LengthPrev = 0
					local LengthCurrent = DistanceBetween
					local TimePrev = 999999999999999
					local BonusAngle = 0
					local VelocityChangeBonus = 1
					
					
					local CrrObjData = {
						MoveTime = TimeBetween, DeltaTime = math.floor((TimeBetween)/16)*16, MoveDistance = DistanceBetween_Speed,
						Angle = 0
					}
					
					local PrevObjData = {
						MoveTime = 999999999, MoveDistance = 0,
						Angle = 0
					}
					
					local PrevPrevObjData = {
						MoveTime = 999999999, MoveDistance = 0,
						Angle = 0
					}
					
					local NextObjData
					
					local function getAngle(pointA, pointB, pointC) -- in vector2
						local pointA = Vector2.new(1,7)
						local pointB = Vector2.new(3,1)
						local pointC = Vector2.new(9,3)
						local ab = pointB - pointA
						local angleA = math.deg(math.atan2(ab.y,ab.x))
						angleA = math.abs(angleA)
						local bc = pointB - pointC
						local angleB = math.deg(math.atan2(bc.y,bc.x))
						angleB = math.abs(angleB)
						
						local angle = math.max(angleA,angleB) - math.min(angleA, angleB)
						return math.rad(angle)
					end
					
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
								CrrObjData.Angle = getAngle(prevObjPos,crrObjPos,nextObjPos)
								NextObjData = {DeltaTime = math.floor((tonumber(nextObjdata[3]) - Time)/16)*16}
							end
						end
						if objectID > 3 then
							prevprevObjPos = Vector2.new(ConvertedData[objectID-2].Position.X,ConvertedData[objectID-2].Position.Y)
							PrevObjData.Angle = getAngle(prevprevObjPos,prevObjPos,crrObjPos)
							PrevObjData.MoveTime = (Time - prevObjTime)
							PrevObjData.MoveDistance = math.max(((prevObjPos - crrObjPos).Magnitude * 36.48/((54.4 - 4.48 * CS))),0)
							if objectID > 4 then
								prevprevObjTime = ConvertedData[objectID-3].Time
								prevprevprevObjPos = Vector2.new(ConvertedData[objectID-4].Position.X,ConvertedData[objectID-4].Position.Y)
								PrevPrevObjData.Angle = getAngle(prevprevprevObjPos,prevprevObjPos,prevObjPos)
								PrevPrevObjData.MoveTime = (prevObjTime - prevprevObjTime)
								PrevPrevObjData.MoveDistance = math.max(((prevprevObjPos - prevObjPos).Magnitude * 36.48/((54.4 - 4.48 * CS))),0)
							end
						end
					end
					
					local AimDifficulty = GetAimDiff(CrrObjData, PrevObjData, PrevPrevObjData)
					
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
					if CurrentAimStrain > HighestAimStrain then
						HighestAimStrain = CurrentAimStrain
					end
					
					AimDifficulty = Difficulty 

					-- Get acc diff
					if GetPS then
						RewardPS.Aim =  not isSpinner and Difficulty or 0
					end
					
					
					-- SPEED (STREAM) DIFFICULTY CALCULATE
					local PrevTimeBetween = -1
					local PrevDistanceBetween = 0
					
					local PrevPrevHitObj = ConvertedData[#ConvertedData-1]
					if PrevPrevHitObj then
						PrevTimeBetween = PrevHitObj.Time  - PrevPrevHitObj.Time
						PrevDistanceBetween = (Vector2.new(HitPos.X,HitPos.Y)-Vector2.new(PrevPrevHitObj.X,PrevPrevHitObj.Y)).Magnitude
					end
					local TimeBetween = Time-PrevHitObj.Time 
					local TimingDifficulty = GetStreamDiff(CrrObjData, PrevObjData, NextObjData)
					local SpeedStrainDecay = math.pow(0.3,TimeBetween/1000)
					RewardPS.SpeedStrainDecay = SpeedStrainDecay
					CurrentSpeedStrain *= SpeedStrainDecay
					CurrentSpeedStrain += TimingDifficulty

					if CurrentSpeedStrain > HighestSpeedStrain then
						HighestSpeedStrain = CurrentSpeedStrain
					end
				
					if GetPS then
						RewardPS.Stream = not isSpinner and TimingDifficulty or 0
					end
					
					-- Calculate current difficulty
					-- math.pow(HighestAimStrain,0.5)*2.35
					
					local CurrentAimStrain = math.pow(CurrentAimStrain, 0.4365) / 3.2541
					local CurrentSpeedStrain = math.pow(CurrentSpeedStrain, 0.41) / 2.8 --math.pow(CurrentSpeedStrain,0.4)/10.7
					
					local FLMulti = 1
					if isFL then
						FLMulti = 1.5
					end
					local ODRate = ReturningData.Difficulty.OverallDifficulty * (IsEZ and 0.5 or (IsHR and 1.4 or 1))
					local LengthBonus = 0.95 + 0.4 * math.min(1,#MapData["HitObjects"]/2000) + ((#MapData["HitObjects"] > 2000 and math.log10(#MapData["HitObjects"]/2000) * 0.5) or 0)

					local RewardedAimPS = FLMulti * math.pow(5 * math.max(1,(CurrentAimStrain/FLMulti)/0.0675) - 4, 3) / 100000 * LengthBonus * (0.98 + math.pow(ODRate, 2) / 2500) --math.pow(AimDiff,4)
					local RewardedSpeedPS = math.pow(5.0 * math.max(1, CurrentSpeedStrain / 0.066) - 4, 3) / 100000 * LengthBonus * (0.95 + math.pow(ODRate,2)/750) --math.pow(SpeedDiff,3.93)
					local RewardedAccPS = math.pow(1.52163,ODRate) * 2.83 * math.min(1.15,math.pow(#MapData["HitObjects"]/1000,0.3)) / 1.0858--math.pow(BaseDiff,2.21)
					
					local sum = RewardedAimPS + RewardedSpeedPS
					if (sum/2) < RewardedAccPS then
						RewardedAccPS = RewardedAccPS * ((sum/2)/RewardedAccPS)
					end

					local diffCalcPS = ((RewardedAimPS^0.95+RewardedSpeedPS^0.95+RewardedAccPS^0.95)^(1/0.95))
					local CurrentStrain = 0.023557 * (math.pow(100000 / math.pow(2, 1 / 1.1) * diffCalcPS,1/3) + 4)
					
					--[[
					
					local CurrentStrain = math.pow(CurrentAimStrain^1.08 + CurrentSpeedStrain^1.08,1/1.08) * 1.45
					if isFL then
						CurrentStrain = math.pow(((CurrentAimStrain/20)^1.08)*20 + CurrentSpeedStrain^1.08,1/1.08) * 1.45
					end]]
--[[
BeatmapDifficulty = math.pow(FinalAimStrain^1.08 + FinalSpeedStrain^1.08,1/1.08) * 1.1311 --math.floor(BeatmapDifficulty*100+0.5)/100
		if isFL then
			BeatmapDifficulty = math.pow(((FinalAimStrain/20)^1.08)*20 + FinalSpeedStrain^1.08,1/1.08) * 1.1311
		end
]]
					
					--CurrentStrain = CurrentStrain
					if CurrentStrain > HighestStrain then
						HighestStrain = CurrentStrain
					end
					
					StrainData[#StrainData+1] = CurrentStrain
					AimStrainData[#AimStrainData+1] = CurrentAimStrain
					SpeedStrainData[#SpeedStrainData+1] = CurrentSpeedStrain

--[[
					if objectID > 1 then

						local Count = 0
						for i = #ConvertedData-1,1,-1 do
							local PrevHitObj = ConvertedData[i]
							local TimeBetween = math.abs(Time-PrevHitObj.Time)
							Count += 1
							if (TimeBetween < 200*(Count) and Count < 20) or Count == 1 then
								--if TimeBetween < 2000 then warn(TimeBetween) end
								if i ~= #ConvertedData then
									local TimeBetween = Time-PrevHitObj.Time
									if TimeBetween == 0 then TimeBetween = 1 end

									--	local CurrentStreamDifficulty = (2.5/(TimeBetween/1000))*(0.28 - 0.28^(#ConvertedData-i))
									local DifficultySubtract = 1/((#ConvertedData-1)*3)
									if DifficultySubtract == math.huge then
										DifficultySubtract = 0
									end
									--local CurrentStreamDifficulty = 0.025/(TimeBetween/1000) - DifficultySubtract
									--local CurrentStreamDifficulty = (0.025/(TimeBetween/1000))*(0.28 - 0.28^(#ConvertedData-i))
									local CurrentStreamDifficulty = GetStreamDiff(TimeBetween/ODMultiplier) - GetStreamMultiplier(#ConvertedData,i)
									if CurrentStreamDifficulty < 0 then
										CurrentStreamDifficulty = 0
									end
									--Difficulty += CurrentStreamDifficulty
									StreamDifficulty += CurrentStreamDifficulty
								end
							else
								break
							end
						end
						StreamDifficulty *= 1
						
						
						local SpeedStrainDecay = math.pow(0.15,TimeBetween/1000)
						RewardPS.SpeedStrainDecay = SpeedStrainDecay
						CurrentSpeedStrain *= SpeedStrainDecay
						CurrentSpeedStrain += StreamDifficulty
						
						if CurrentSpeedStrain > HighestSpeedStrain then
							HighestSpeedStrain = CurrentSpeedStrain
						end
						
						Difficulty += StreamDifficulty
						
						local BaseStrainDecay = math.pow(0.15,TimeBetween/1000)
						CurrentStrain *= BaseStrainDecay
						CurrentStrain += Difficulty
						
						AvgStrain += CurrentStrain * 1/#MapData.HitObjects
						
						if CurrentStrain > HighestStrain then
							HighestStrain = CurrentStrain
						end
						
						-- stream diff
						if GetPS then
							RewardPS.Stream = StreamDifficulty
						end
						StreamDiff[#StreamDiff+1] = StreamDifficulty
					end
					]]

					

					--[[
					if objectID ~= 2 then
						for i,PrevHitObj in pairs(ConvertedData) do
							if PrevHitObj.Time > Time-(160*(#ConvertedData-i)) and i~=#ConvertedData then
								local TimeBetween = Time-PrevHitObj.Time
								if TimeBetween == 0 then TimeBetween = 1 end
								Difficulty += (1.4/(TimeBetween/1000))*0.75^(#ConvertedData-i)
							end
						end
					end]]

					--[[
					local Top = #DiffList + 1
					for T,TopDiff in pairs(DiffList) do
						if Difficulty > TopDiff then
							Top = T
							break
						end 
					end]]
					--table.insert(NoteDiff,Top,#ConvertedData+1)
					DiffList[#DiffList+1] = Difficulty


					--RawDifficulty[#RawDifficulty+1] = {Difficulty,Time}

					--RawDifficulty[#RawDifficulty+1] = {Difficulty,Time}
					RawDifficulty[#RawDifficulty+1] = {CurrentStrain,Time}
					
				end

			end

			local HitObjData = {ObjId = objectID,Position = HitPos,Time = Time,Type = Type,ExtraData = ExtraData,SpinTime = SpinTime,SliderTime = SliderTime,HitObjBPMData = HitObjBPMData,PSValue = RewardPS}

			ConvertedData[#ConvertedData+1] = HitObjData
			--[[

			--create note as a slider end
			local function GetSliderData(ExtraData,Slides,Length)
				local Pos = ExtraData[#ExtraData-5]



				if ExtraData == nil then
					return
				end

				if #ExtraData < 7 then
					Length = ExtraData[#ExtraData-3+(7-#ExtraData)]
					Pos = ExtraData[#ExtraData-5+(7-#ExtraData)]
				end


				if Slides/2 - math.floor(Slides/2) == 0.5 then
					local StartPos = 0
					for i = 1,#Pos do
						if string.sub(Pos,i,i) == "|" then
							StartPos = i+1
						end
					end			
					for i = StartPos,#Pos do
						if string.sub(Pos,i,i) == ":" then
							Pos = {X = tonumber(string.sub(Pos,StartPos,i-1)),Y = tonumber(string.sub(Pos,i+1,#Pos))}
							break
						end
					end
				else
					Pos = HitPos
				end
				local Time = Time+tonumber(Length)


				return Pos,Time
			end
			if HitObjData.Type == 2 or HitObjData.Type == 6 or math.floor((HitObjData.Type-22)/16) == (HitObjData.Type-22)/16 then
				local BeatLength = 0
				local SliderMulti = 1

				local ExtraData = HitObjData.ExtraData
				local Slides = ExtraData[#ExtraData-4+(7-#ExtraData)]
				local SliderLength = ExtraData[#ExtraData-3+(7-#ExtraData)]

				for _,TimingPointData in pairs(TimingPoints) do
					if TimingPointData[1] > Time then break end
					if TimingPointData[2] < 0 then
						SliderMulti = math.abs(TimingPointData[2]/100)
					else
						BeatLength = TimingPointData[2]
					end
				end


				SliderMulti = SliderMulti * ReturningData.Difficulty.SliderMultiplier
				local BPM = 60/BeatLength/1000

				local LengthPerBeat = SliderMulti*100
				local LengthPerSec = LengthPerBeat*(BPM/60)

				local SliderTime = ((SliderLength*Slides)/LengthPerSec)/1000
				--print(SliderTime)
				
				local Time = Time + SliderTime

				local Pos,_ = GetSliderData(ExtraData,Slides,SliderTime)
				local Distance = math.abs((Vector2.new(Pos.X,Pos.Y) - Vector2.new(HitPos.X,HitPos.Y)).Magnitude)
				local Possible = Distance/(SliderTime/1000) <= 768 and SliderTime > 0
				if Pos ~= nil and Time ~= nil and Possible == true then
					ConvertedData[#ConvertedData+1] = {Position = Pos,Time = Time,Type = 1,ExtraData = {},SliderNote = true}
				end
			end
		--------]]
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
	
	table.sort(ConvertedData,function(obj1,obj2)
		return obj1.Time < obj2.Time
	end)

	local BeatmapDifficulty = 0
	local AimDifficulty = 0
	local StreamDifficulty = 0

	local DifficultyStrikeList = {
		List = {}, Highest = 0
	}

	-- Difficulty caculation part 2

	if isReturnDifficulty == true then
		--[[
		local AvgDiff = 0
		
		for Top,Diff in pairs(DiffList) do
			AvgDiff += Diff/#DiffList
		end

		AvgDiff = (AvgDiff + DiffList[1]*4)/5
		
		local Top = #DiffList + 1
		for T,TopDiff in pairs(DiffList) do
			if AvgDiff > TopDiff then
				Top = T
				break
			end 
		end
		
		table.insert(DiffList,Top,AvgDiff)]]
		
		
		
		table.sort(DiffList,function(a,b) return a>b end)

		for Top,Diff in pairs(DiffList) do
			BeatmapDifficulty += Diff * (0.6^(Top-1))
		end

		-- Convert difficulty Part1

		local BeatmapTime = ConvertedData[#ConvertedData].Time
		local Timeline = math.floor(BeatmapTime/DifficultyStrikeRecord)+1 -- total record

		local CurrentTimeline = 1

		for _,RawDiff in pairs(RawDifficulty) do
			if RawDiff[2] > CurrentTimeline*DifficultyStrikeRecord then
				repeat 
					if RawDifficulty2[CurrentTimeline] == nil then
						RawDifficulty2[CurrentTimeline] = {}
					end 
					CurrentTimeline += 1 until RawDiff[2] <= CurrentTimeline*DifficultyStrikeRecord
			end

			if RawDifficulty2[CurrentTimeline] == nil then
				RawDifficulty2[CurrentTimeline] = {}
			end

			local Difficulty = RawDiff[1]


			table.insert(RawDifficulty2[CurrentTimeline],1,Difficulty)
		end

		for i = 1,CurrentTimeline do
			if #RawDifficulty2[CurrentTimeline] > 0 then
				table.sort(RawDifficulty2[CurrentTimeline],function(a,b) return a>b end)
			end
		end

		-- Convert difficulty Part2

		local HighestDiff = 0

		for i,List in pairs(RawDifficulty2) do
			local TimeDiff = 0
			--[[
			for Top,Diff in pairs(List) do
				TimeDiff += Diff * (0.6^(Top-1)) * 1.2
			end
			TimeDiff /= 1.2
			TimeDiff*=10 * 1.3626
			if TimeDiff > HighestDiff then
				HighestDiff = TimeDiff
			end]]
			
			for Top,Diff in pairs(List) do
				Diff *= 10
				if Diff > TimeDiff then
					TimeDiff = Diff
				end
			end
			
			if TimeDiff > HighestDiff then
				HighestDiff = TimeDiff
			end
			DifficultyStrike[i] = TimeDiff
		end

		DifficultyStrikeList = {
			List = DifficultyStrike,
			Highest = HighestDiff
		}
		------------
		
		local ModData = {
			HR = IsHR,FL = isFL,HD = IsHD,EZ = IsEZ,
			AR = ReturningData.Difficulty.ApproachRate,
			OD = ReturningData.Difficulty.OverallDifficulty,
			CS = ReturningData.Difficulty.CircleSize
		}
		
		local DifficultyData = require(workspace.DifficultyEvaculator)(ConvertedData,TimingPoints,ModData)

		--BeatmapDifficulty = BeatmapDifficulty * 1.3626 -- Old: 1.22
		
		table.sort(StrainData,function(a,b) return a>b end)
		table.sort(AimStrainData,function(a,b) return a>b end)
		table.sort(SpeedStrainData,function(a,b) return a>b end)
		local FinalStrain = 0
		local FinalAimStrain = 0
		local FinalSpeedStrain = 0
		local BaseMultiplier = 1/45.3871
		local Weight = 1
		local DecayRate = 0.98
		
		for _,a in pairs(StrainData) do
			FinalStrain += a*Weight*BaseMultiplier
			Weight *= DecayRate
		end
		Weight = 1 -- reset
		for _,a in pairs(AimStrainData) do
			FinalAimStrain += a*Weight*BaseMultiplier
			Weight *= DecayRate
		end
		Weight = 1 -- reset again
		for _,a in pairs(SpeedStrainData) do
			FinalSpeedStrain += a*Weight*BaseMultiplier
			Weight *= DecayRate
		end
		
		BeatmapDifficulty = FinalStrain --HighestStrain -- V1.46 diff calculate
		--BeatmapDifficulty = math.pow(BeatmapDifficulty,1) * 1.613
		BeatmapDifficulty = math.pow(FinalAimStrain^1.08 + FinalSpeedStrain^1.08,1/1.08) * 1.1311 --math.floor(BeatmapDifficulty*100+0.5)/100
		if isFL then
			BeatmapDifficulty = math.pow(((FinalAimStrain/20)^1.08)*20 + FinalSpeedStrain^1.08,1/1.08) * 1.1311
		end
		---
		HighestAimStrain = FinalAimStrain --math.pow(HighestAimStrain,0.6)*1.585
		HighestSpeedStrain = FinalSpeedStrain --math.pow(HighestSpeedStrain,0.6)*1.9
		HighestAimStrain = math.round(HighestAimStrain*100)/100
		HighestSpeedStrain = math.round(HighestSpeedStrain*100)/100

		local FLMulti = 1
		if isFL then
			FLMulti = 1.5
		end
		local ODRate = ReturningData.Difficulty.OverallDifficulty * (IsEZ and 0.5 or (IsHR and 1.4 or 1))
		local LengthBonus = 0.95 + 0.4 * math.min(1,#ConvertedData/2000) + ((#ConvertedData > 2000 and math.log10(#ConvertedData/2000) * 0.5) or 0)

		local RewardedAimPS = FLMulti * math.pow(5 * math.max(1,(HighestAimStrain/FLMulti)/0.0675) - 4, 3) / 100000 * LengthBonus * (0.98 + math.pow(ODRate, 2) / 2500) --math.pow(AimDiff,4)
		local RewardedSpeedPS = math.pow(5.0 * math.max(1, HighestSpeedStrain / 0.0675) - 4, 3) / 100000 * LengthBonus * (0.95 + math.pow(ODRate,2)/750) --math.pow(SpeedDiff,3.93)
		local RewardedAccPS = math.pow(1.52163,ODRate) * 2.83 * math.min(1.15,math.pow(#ConvertedData/1000,0.3)) / 1.0858--math.pow(BaseDiff,2.21)

		local diffCalcPS = ((RewardedAimPS^0.95+RewardedSpeedPS^0.95+RewardedAccPS^0.95)^(1/0.95))
		BeatmapDifficulty = 0.023809 * (math.pow(100000 / math.pow(2, 1 / 1.1) * diffCalcPS,1/3) + 4)
	end
	--warn(tostring(AimDifficulty).."\n"..tostring(StreamDifficulty))

	ReturningData.Difficulty.DifficultyStrike = DifficultyStrikeList
	ReturningData.Difficulty.BeatmapDifficulty = BeatmapDifficulty
	ReturningData.Difficulty.AimDifficulty = HighestAimStrain
	ReturningData.Difficulty.SpeedDifficulty = HighestSpeedStrain


	if metadataonly ~= true then
		ReturningData.Overview.MapLength = ConvertedData[#ConvertedData].Time
	end
	return ConvertedData,ReturningData,TimingPoints,BeatmapColor
end

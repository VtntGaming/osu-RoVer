return function(FileType,Beatmap,SongSpeed,DelayedTime,CustomSongIDEnabled,isReturnDifficulty,metadataonly,GetPS,IsHR,isFL,IsEZ)
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

	local a,_ = pcall(function()
		if MapData.RobloxData ~= nil  then
			local RblxData = {}
			for _,RawData in pairs(MapData.RobloxData) do
				for i = 1,#RawData do
					if string.sub(RawData,i,i) == ":" then
						RblxData[string.sub(RawData,1,i-1)] = tonumber(string.sub(RawData,i+1,#RawData))
					end
				end
			end

			-- Process RblxData


			if RblxData.SoundOffset ~= nil and CustomSongIDEnabled == false then
				DelayedTime += RblxData.SoundOffset
				ReturningData.OriginalOffset = RblxData.SoundOffset
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
	local StreamDiff = {}
	local AimDiff = {}
	local DifficultyStrike = {}
	local RawDifficulty = {}
	local RawDifficulty2 = {}
	
	local ODMultiplier = 74.5 / ((119.5 - 9 * ReturningData.Difficulty.OverallDifficulty * ((IsHR and 1.3) or (IsEZ and 0.5) or 1)))
	ODMultiplier = ODMultiplier ^ 0.01

	-- RawDifficulty = {[1] = {<Time>,<Diff>}}
	-- RawDifficulty2 = {[1] = {[1] = <HighestDiff>,[2] = <2nd highest>}}
	-- DifficultyStrike = {[1] = <Diff>}
	-- Difficulty record each 5 seconds
	GetPS = true

	local DifficultyStrikeRecord = 5000/SongSpeed -- in miliseconds


	if metadataonly ~= true then -- this would reduce lag
		for objectID,HitObj in pairs(MapData["HitObjects"]) do
			local HitPos = {X = 0,Y = 0}
			local Time = 0
			local Type = 0
			local Location = 0
			local SpinTime = 0
			local CurrentType = 1
			local ExtraData = {}
			local RewardPS = {
				Aim = 0, Stream = 0
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

			--[[
			for i = 1,#HitObj do
				if string.sub(HitObj,i,i) == "," or i == #HitObj then
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
					Location = i+1
					CurrentType = CurrentType + 1
				end
			end]]


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

			-- Difficulty caculation
			
			local function GetWideAngleBonus(Angle)

				if Angle > 180 then
					Angle = 180 - (Angle-180)
				end

				Angle = math.rad(Angle)

				if Angle < math.pi / 3 then -- 60
					return 0
				elseif Angle < 2 * math.pi / 3 then -- 120
					return math.pow(math.sin(1.5 * (Angle - math.pi / 3)), 2)
				else
					return 0.25 + 0.75 * math.pow(math.sin(1.5 * (math.pi - Angle)), 2)
				end
			end

			local function GetAcuteAngleBonus(Angle)
				Angle = math.rad(Angle)

				if Angle < math.pi / 3 then -- 60
					return 0.5 + 0.5 * math.pow(math.sin(1.5 * Angle), 2)
				elseif Angle < 2 * math.pi / 3 then -- 120
					return math.pow(math.sin(1.5 * (2 * math.pi / 3 - Angle)), 2)
				else
					return 0
				end
			end

			local function GetAngleBonus(Angle,CurrentMoveTime,PrevMoveTime,lengthprev,lengthcurrent)

				local AngleBonus = math.min(lengthprev,lengthcurrent)
				local Acute = GetAcuteAngleBonus(Angle)
				local wide = GetWideAngleBonus(Angle)

				if PrevMoveTime > 100 then
					Acute = 0
				else
					Acute *= math.min(2,math.pow((100-PrevMoveTime)/15,1.5))
					wide *= math.pow(PrevMoveTime/100,6)
				end
				if Acute > wide then
					AngleBonus = math.min(AngleBonus,150/PrevMoveTime) * math.min(1,math.pow(math.min(PrevMoveTime,CurrentMoveTime)/150,2))
				end


				AngleBonus *= math.max(Acute,wide)/130

				local AngleMultiplier = 0.85+(AngleBonus/0.75)*0.15

				return AngleMultiplier
			end
			
			local function GetDistanceMultiplier(Distance)
				local Multi = 1
				-- Longer distance > Harder the note is
				
				if Distance <= 80 then
					Multi = 1
				elseif Distance <= 360 then
					Multi = 1 + (Distance-80)/560*0.1
				elseif Distance <= 640 then
					Multi = 1.1 + (Distance-360)/280*0.2
				else
					Multi = 1.3
				end
				-- Ignore above
				if Distance <= 640 then
					Multi = 1 + math.pow(Distance/640,2)*0.2 + (Distance/640)*0.1
				else
					Multi = 1.3
				end
				
				return Multi
			end

			local function GetSpeedDiff(Speed)  -- Aim diff

				local ReturnDiff = 0
				--[[
				if Speed <= 2560 then
					ReturnDiff = Speed/120
					--260
				else
					ReturnDiff = 2560/120
					ReturnDiff += (math.sqrt(math.sqrt(Speed^1.7))-28.105425125437243)
				end]]
				if Speed <= 320 then
					ReturnDiff = 1.15 * (Speed) / 320 * 0.5
				elseif Speed <= 640 then
					ReturnDiff = 0.575 + (Speed-320) / 320 * 0.5
				elseif Speed <= 1600 then
					ReturnDiff = 1.075 + (Speed-640) / 960 * 0.3 * 0.9
				elseif Speed <= 2560 then
					--ReturnDiff = Speed/2015.75
					ReturnDiff = 1.345 + (Speed-1600) / 960 * 0.135 * 0.5
				elseif Speed <= 6400 then
					ReturnDiff = 1.4125 + (Speed-2560) / 3840 * 0.57 * 0.5
				elseif Speed <= 8320 then
					ReturnDiff = 1.7 + (Speed-6400) / 1920 * 0.15  -- 1920
				elseif Speed <= 10240 then
					--ReturnDiff = Speed/7613.38
					ReturnDiff = 1.85 + (Speed-6400)/3840 * 0.405  -- 7680
				else
					ReturnDiff = 2.255
				end
				
				return ReturnDiff
			end
			
			local function GetStreamDiff(TimeBetween)  -- Speed diff .-.
				local ReturnDiff = 0
		
				
				if TimeBetween >= 800 then
					ReturnDiff = 0.21/(TimeBetween/1000)
				elseif TimeBetween >= 400 then
					ReturnDiff = 0.262 + 1000/TimeBetween/2.5*0.08*1.2
				elseif TimeBetween >= 200 then -- Standard 75 - 150 jump/stream
					ReturnDiff = 0.358 + 1000/TimeBetween/5*0.15*1.2
				elseif TimeBetween >= 100 then -- Standard 150 - 300 jump/stream (or fast 75 - 150) bpm sream
					ReturnDiff = 0.538 + 1000/TimeBetween/10*0.15 * 0.3
				elseif TimeBetween >= 50 then -- Standard 300 - 600 jump/stream (or fast 150 - 300) bpm sream
					ReturnDiff = 0.583 + 0.6 * 1000/TimeBetween/20*0.4 * 0.87
				elseif TimeBetween >= 25 then -- Standard 600 - 1200 jump/stream (or fast 300 - 600) bpm sream o.O
					ReturnDiff = 0.7918 + 0.8 * 1000/TimeBetween/20*0.07
				else
					ReturnDiff = 0.9038
				end
				
				
				--print(ReturnDiff)
				return ReturnDiff
				
			end
			
			--local MulList = {1,0.4,0.3,0.26}
			local MulList = {0.75,0.3,0.225,0.195}
			
			
			
			local function GetStreamMultiplier(Num,Num2)
				--local Multiplier = 1
				local Multi = 0.28 - 0.28 ^ (Num - Num2)
				if Multi < 0 then
					Multi = 0
				end
				return Multi
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
					DistanceBetween *= 32/((54.4 - 4.48 * ReturningData.Difficulty.CircleSize * ((IsHR and 1.3) or (IsEZ and 0.5) or 1)))
					DistanceBetween -= ((54.4 - 4.48 * ReturningData.Difficulty.CircleSize * ((IsHR and 1.3) or (IsEZ and 0.5) or 1))*2)
					if DistanceBetween < 0 then DistanceBetween = 0 end
					if isFL then
						--DistanceBetween *= 3
					end
					local MoveSpeed = DistanceBetween/(TimeBetween/1000)
					local Angle = 0
					local LengthPrev = 0
					local LengthCurrent = DistanceBetween
					local TimePrev = 999999999999999
					local BonusAngle = 0
					if objectID > 2 then
						local Prev2HitObj = ConvertedData[#ConvertedData-1]
						
						TimePrev = PrevHitObj.Time - Prev2HitObj.Time
						local Point1 = Vector2.new(Prev2HitObj.Position.X,Prev2HitObj.Position.Y)
						local Point2 = Vector2.new(PrevHitObj.Position.X,PrevHitObj.Position.Y)
						local Point3 = Vector2.new(HitPos.X,HitPos.Y)
						
						local a = (Point1-Point2).Magnitude
						local b = (Point1-Point3).Magnitude
						local c = (Point2-Point3).Magnitude
						
						LengthPrev = a
						
						Angle = math.deg(math.acos((a^2+b^2-c^2)*(2*a*b)))
						
						BonusAngle = GetAngleBonus(Angle,Time,TimePrev,a,c)
						
					end
					
					local Difficulty = GetSpeedDiff(MoveSpeed) * GetDistanceMultiplier(DistanceBetween) * BonusAngle
					
					AimDifficulty = Difficulty

					-- Get acc diff
					if GetPS then
						RewardPS.Aim = Difficulty * 1 * 1.3626-- * 1.16
					end
					AimDiff[#AimDiff+1] = Difficulty
					
					
					--
					
					if objectID > 1 then -- New stream system
						
					end

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
						Difficulty += StreamDifficulty
						-- stream diff
						if GetPS then
							RewardPS.Stream = StreamDifficulty * 1.3626
						end
						StreamDiff[#StreamDiff+1] = StreamDifficulty
					end

					if Type == 8 or Type == 12 or math.floor((Type-28)/16) == (Type-28)/16 or (PrevHitObj.Type == 8 or PrevHitObj.Type == 12 or math.floor((PrevHitObj.Type-28)/16) == (PrevHitObj.Type-28)/16) then
						Difficulty = 0
					end

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

					RawDifficulty[#RawDifficulty+1] = {Difficulty,Time}
				end

			end

			local HitObjData = {ObjId = objectID,Position = HitPos,Time = Time,Type = Type,ExtraData = ExtraData,SpinTime = SpinTime,PSValue = RewardPS}

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


		if GetPS == true then -- Required for perfomance score
			table.sort(AimDiff,function(a,b) return a>b end)
			table.sort(StreamDiff,function(a,b) return a>b end)

			for Top,Diff in pairs(AimDiff) do
				AimDifficulty += Diff * (0.8^(Top-1))
			end

			for Top,Diff in pairs(StreamDiff) do
				StreamDifficulty += Diff * (0.8^(Top-1)) 
			end



			--BeatmapDifficulty = (AimDifficulty + StreamDifficulty)


			--warn("Aim PS: ".. AimDifficulty)
			--warn("Stream PS: "..StreamDifficulty)

			--print(AimDiff)
			--print(StreamDiff)
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
			for Top,Diff in pairs(List) do
				TimeDiff += Diff * (0.6^(Top-1)) * 1.2
			end
			TimeDiff /= 1.2
			TimeDiff*=10 * 1.3626
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

		BeatmapDifficulty = BeatmapDifficulty * 1.3626 -- Old: 1.22

		BeatmapDifficulty = math.floor(BeatmapDifficulty*100+0.5)/100

		--print("Diff: "..BeatmapDifficulty)
	end
	--warn(tostring(AimDifficulty).."\n"..tostring(StreamDifficulty))

	ReturningData.Difficulty.DifficultyStrike = DifficultyStrikeList
	ReturningData.Difficulty.BeatmapDifficulty = BeatmapDifficulty


	if metadataonly ~= true then
		ReturningData.Overview.MapLength = ConvertedData[#ConvertedData].Time
	end
	return ConvertedData,ReturningData,TimingPoints,BeatmapColor
end

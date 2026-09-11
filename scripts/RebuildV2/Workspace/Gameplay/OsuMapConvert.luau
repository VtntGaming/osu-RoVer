--!strict
--[[
	-> OsuMapConvert.lua <-
	-> osu!RoVer RebuildVer Beta V2.0.23 <-
	-> Written by VtntGaming <-
	-> Size: 19.41kB <-	
]]

--[[
All properties:

isObject (boolean)
ReturnType (dictionary)
	{
		1 - All (including ps)
		2 - Not including ps rate
		3 - Not including difficulty rating
		4 - Metadata only, not including any object data
	}

All return data:

]]

export type SliderCurveData = {
	Pos: Vector2,
	Length: number,
	Rotation: number,
	MoveTime: {
		Base: number,
		Start: number,
		Stop: number
	}
}

export type TickData = {
	Time: number,
	Pos: Vector2
}

export type SliderData = {
	IsSlider: boolean,
	CurveType: string,
	VirtualLength: number,
	SlidesCount: number,
	MovementTime: number,
	EndTime: number,
	TotalTickCount: number,
	CurvePoints: {SliderCurveData},
	ReverseCurvePoints: {SliderCurveData},
	TickData: {TickData},
	TickDataRev: {TickData},
}

export type SpinnerData = {
	IsSpinner: boolean,
	SpinEndTime: number
}

export type HitEffectData = {
	Volume: number,
	GlobalSampleSet: string,
}

export type ObjectExtraData = {
	IsSlider: boolean,
	IsSpinner: boolean,
	Slider: SliderData,
	Spinner: SpinnerData,
	HitEffectData: HitEffectData
}


export type ObjectData = {
	Position: Vector2,
	Timing: number,
	ObjType: number,
	HitSound: string,
	HitSample: string,
	ExtraData: ObjectExtraData,
}

export type AttributeRobloxData = {
	RblxCreatorUserID: string?,
	RblxSoundID: string?,
	SoundOffset: string?,
	BackgroundImageId: string?,
	SongSpeed: string?,
	SongPitch: string?,
	BeatmapVolume: string?,
	WeirdSliderAlert: string?,
	SliderCrashAlert: string?,
	RblxSoundID2: string?,
	CustomSoundFile: string?,
	CustomBackgroundFile: string?,
	[string]: any,
}

export type BreakTime = {
	StartTime: number,
	EndTime: number
}

export type DifficultyValues = {
	HPDrainRate: number,
	CircleSize: number,
	OverallDifficulty: number,
	ApproachRate: number,
	SliderMultiplier: number,
	SliderTickRate: number,
	[string]: number,
}

export type AttributeGeneral = {
	AudioFilename: string?,
	AudioLeadIn: number?,
	PreviewTime: number?,
	Countdown: number?,
	SampleSet: string?,
	StackLeniency: number?,
	Mode: number?,
	LetterboxInBreaks: number?,
	WidescreenStoryboard: number?,
	[string]: string | number,
}

export type AttributeMetadata = {
	Title: string?,
	TitleUnicode: string?,
	Artist: string?,
	ArtistUnicode: string?,
	Creator: string?,
	Version: string?,
	Source: string?,
	Tags: string?,
	BeatmapID: string?,
	BeatmapSetID: string?,
	[string]: any
}

export type BaseBPMValue = {
	Time: number,
	Value: number
}

export type ReturnData = {
	MapVersion: number?,
	ObjectData: {ObjectData},
	DetailedAnalyse: {
		MaxCombo: number,
		MaxScore: number,
		Note: number,
		Slider: number,
		Spinner: number,
		SliderTick: number
	},
	RobloxData: AttributeRobloxData,
	BreakTime: {BreakTime},
	MapComboColor: {Color3},
	DifficultyValues: DifficultyValues,
	General: AttributeGeneral?,
	Metadata: AttributeMetadata?,
	TimingPoints: {{number}},
	BPMData: {
		BPM: {BaseBPMValue},
		SliderMulti: {BaseBPMValue}
	}
}

local function Bezier(t: number, curveData: {SliderCurveData}): Vector2
	local pointData = {}
	for _,data in pairs(curveData) do
		pointData[#pointData+1] = data.Pos
	end
	local pointsLeft = #pointData
	for i = pointsLeft+1,3,-1 do
		local new = {}
		for a = 1, pointsLeft-1 do
			new[#new+1] = pointData[a]:Lerp(pointData[a+1], t)
		end
		pointData = new
		pointsLeft -= 1
	end							

	return pointData[1]
end

local function GetTickPositionFromTime(tickTime: number, curvePoints: {SliderCurveData}): Vector2?
	for i, data in pairs(curvePoints) do
		if tickTime >= data.MoveTime.Start and tickTime <= data.MoveTime.Stop then
			return data.Pos+(curvePoints[i+1].Pos - data.Pos)*((tickTime - data.MoveTime.Start)/data.MoveTime.Base)
		end
	end

	return nil
end

local function GetObjectType(objType: number): number?
	if not objType or not tonumber(objType) then
		return nil
	end
	if objType == 1 or objType == 2 or objType == 8 then
		return objType
	else
		local base = objType%8
		if base == 5 then
			return 1
		elseif base == 6 then
			return 2
		else
			return 8
		end
	end
end

local OsuMapConvert = {}

function OsuMapConvert.Convert(mapObject, Properties): ReturnData
	local ReturnData = {
		ObjectData = {},
		DetailedAnalyse = {MaxCombo = 0, MaxScore = 0, Note = 0, Slider = 0, Spinner = 0, SliderTick = 0},
		BreakTime = {},
		RobloxData = {},
		MapComboColor = {},
		DifficultyValues = {},
		TimingPoints = {},
		BPMData = {BPM = {}, SliderMulti = {}}
	} :: ReturnData
	local isObject = Properties.isObject
	local ReturnType = Properties.ReturnType

	if not ReturnType then
		ReturnType = 1 -- it default to return all
	end

	local MapData: string

	if isObject then
		MapData = require(mapObject) :: any
	end
	do
		local _,s = string.find(MapData,"osu file format v")
		local e,_ = string.find(MapData,"\n",s)
		if e and s then
			-- The default version is 14
			ReturnData.MapVersion = tonumber(string.sub(MapData,s+1,e-1))
		end
	end
	-- Spilt map into different stuff

	-- File config	
	if string.find(MapData,"%[RobloxData]") then
		local _,s = string.find(MapData,"%[RobloxData]")
		local e = string.find(MapData,"%[",s)

		if s and e then
			local raw = string.split(string.sub(MapData,s + 1,e - 1),"\n")

			for _,data in pairs(raw) do
				if string.find(data,":") == nil then continue end

				local rawdata = string.split(data,": ")
				ReturnData.RobloxData[rawdata[1]] = rawdata[2] 
			end
		end		
	end

	if string.find(MapData,"//Break Periods") then
		local _,s = string.find(MapData,"//Break Periods")
		local e = string.find(MapData,"/",s)

		if s and e then
			local raw = string.split(string.sub(MapData,s+1,e-1),"\n")

			for _,data in pairs(raw) do
				if not string.find(data,",") then
					continue
				end
				local rawdata = string.split(data,",")
				local startTime = tonumber(rawdata[2]) or 0
				local endTime = tonumber(rawdata[3]) or 0
				ReturnData.BreakTime[#ReturnData.BreakTime+1] = {
					StartTime = startTime,
					EndTime = endTime
				}
			end			
		end
	end

	if string.find(MapData,"%[General]") then
		local attributeGeneral: AttributeGeneral = {}
		local _,s = string.find(MapData,"%[General]")
		local e = string.find(MapData,"%[",s)

		if s and e then
			local raw = string.split(string.sub(MapData,s+1,e-1),"\n")
			for _,data in pairs(raw) do
				if string.find(data,":") == nil then continue end

				local rawdata = string.split(data,":")
				local keyName = rawdata[1]
				local result = string.sub(rawdata[2],2,#rawdata[2])

				attributeGeneral[keyName] = tonumber(result) or result
			end

			ReturnData.General = attributeGeneral
		end		
	end

	if string.find(MapData,"%[Metadata]") then
		ReturnData.Metadata = {}
		local attributeMetadata = {}
		local _,s = string.find(MapData,"%[Metadata]")
		local e = string.find(MapData,"%[",s)

		if s and e then
			local raw = string.split(string.sub(MapData,s+1,e-1),"\n")
			for _,data in pairs(raw) do
				if string.find(data,":") == nil then continue end

				local rawdata = string.split(data,":")

				attributeMetadata[rawdata[1]] = rawdata[2]
			end

			ReturnData.Metadata = attributeMetadata			
		end		
	end	

	if string.find(MapData,"%[Colours]") then
		local _,s = string.find(MapData,"%[Colours]")
		local e = string.find(MapData,"%[",s)

		if s and e then
			local raw = string.split(string.sub(MapData,s+1,e-1),"\n")
			for _,data in pairs(raw) do
				if string.find(data,":") == nil then continue end

				local rawdata = string.split(data,": ")
				local ColorString = rawdata[2]
				local r,g,b = string.match(ColorString, "(%d+),(%d+),(%d+)")

				ReturnData.MapComboColor[#ReturnData.MapComboColor+1] = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
			end
		end
		
	end

	if string.find(MapData,"%[Difficulty]") then
		local attributeDifficulty = {} :: DifficultyValues
		local _,s = string.find(MapData,"%[Difficulty]")
		local e = string.find(MapData,"%[",s)

		if s and e then
			local raw = string.split(string.sub(MapData,s+1,e-1),"\n")
			for _,data in pairs(raw) do
				if string.find(data,":") == nil then continue end

				local rawdata = string.split(data,":")
				local value = tonumber(rawdata[2])

				if value then
					attributeDifficulty[rawdata[1]] = value				
				end
			end

			ReturnData.DifficultyValues = attributeDifficulty			
		end		
	end

	if string.find(MapData,"%[TimingPoints]") then
		ReturnData.TimingPoints = {}
		local _,s = string.find(MapData,"%[TimingPoints]")
		local e = string.find(MapData,"%[",s)

		--[[
		Time (ms), Beatlength (BPM: positive | Slider multiplier: negative), Meter, SampleSet, SampleIndex, Volume (%), Uninherited, Effects (Kiai) 
		]]

		local bpmTimingData = {}
		local sliderMultiData = {}

		if s and e then
			local raw = string.split(string.sub(MapData,s+1,e-1),"\n")
			for _,data in pairs(raw) do
				if not string.find(data,",") then continue end
				local rawdata = string.split(data,",")
				local numberedData: {number} = {}
				for i, a in pairs(rawdata) do
					numberedData[i] = tonumber(a) or -1
				end

				local beatLength = tonumber(rawdata[2])

				if not beatLength then
					continue
				end

				if numberedData[7] == 1 then
					--BPM
					bpmTimingData[#bpmTimingData+1] = {
						Time = numberedData[1],
						Value = 1 / beatLength * 1000 * 60
					}
				else
					--Timing points
					sliderMultiData[#sliderMultiData+1] = {
						Time = numberedData[1], 
						Value = 100/(-beatLength)
					}
				end

				ReturnData.TimingPoints[#ReturnData.TimingPoints+1] = numberedData
			end			
		end		

		-- {Time, BPM/SliderMulti}
		ReturnData.BPMData = {			
			BPM = bpmTimingData,
			SliderMulti = sliderMultiData
		}
	end

	-- Object reader

	local function getSliderTime(noteTime: number, beatLength: number, sliderSlides: number)
		local crrBPM = -1
		local crrBPMTime = 9e99
		local crrSliderMulti = 1
		local defaultSliderMulti = ReturnData.DifficultyValues.SliderMultiplier or 1
		sliderSlides = math.max(1,sliderSlides)

		for _, data in pairs(ReturnData.BPMData.BPM) do
			if crrBPM == -1 or data.Time <= noteTime then
				crrBPM = data.Value
				crrBPMTime = data.Time
			else
				break
			end
		end

		for _,data in pairs(ReturnData.BPMData.SliderMulti) do
			if data.Time > noteTime then
				break
			elseif crrBPMTime > data.Time then
				continue
			else
				crrSliderMulti = data.Value
			end
		end

		if crrBPM == -1 then crrBPM = 60 end
		crrSliderMulti = math.max(crrSliderMulti,0.1)
		local lengthperBeat = crrSliderMulti * 100
		local lengthperSec = lengthperBeat*(crrBPM/60)

		local SliderTime = ((beatLength * sliderSlides) / lengthperSec) / defaultSliderMulti
		return SliderTime * 1000, crrBPMTime, crrBPM
	end
	local HitsoundSampleset = {
		[0] = "default",
		[1] = "normal",
		[2] = "soft",
		[3] = "drum"
	}

	local function getHitsoundData(Time)
		local defaultSampleSet = ReturnData.General and ReturnData.General.SampleSet or "normal"
		for i,timing in pairs(ReturnData.TimingPoints) do
			if timing[1] <= Time then
				if i < #ReturnData.TimingPoints and ReturnData.TimingPoints[i+1][1] < Time then
					continue
				end
				local volume = timing[6]
				local sampleSet = HitsoundSampleset[timing[4]]
				if sampleSet == "default" then
					sampleSet = string.lower(defaultSampleSet)
				end
				if sampleSet == nil then
					warn("TimingPoints no sample set", timing[4])
				end
				return sampleSet,volume
			else
				break
			end
		end
		return string.lower(defaultSampleSet),100
	end

	-- Running the object difficulty calculation
	if ReturnType < 4 then
		local _,_s = string.find(MapData,"%[HitObjects]")
		local e = #MapData
		local maxCombo = 0
		local maxScore = 0

		if _s and e then
			local RawString = string.sub(MapData,_s+1,e)
			local RawData = string.split(RawString,"\n")
			for _,Data in pairs(RawData) do
				local RawPropertiesData = string.split(Data,",")
				if #RawPropertiesData < 2 then
					continue
				end

				local hitCirclePosition = Vector2.new(
					tonumber(RawPropertiesData[1]),
					tonumber(RawPropertiesData[2])
				)

				local PropertieData = {
					Position = hitCirclePosition,
					Timing = tonumber(RawPropertiesData[3]),
					ObjType = tonumber(RawPropertiesData[4]),
					HitSound = RawPropertiesData[5],
					HitSample = RawPropertiesData[#RawPropertiesData],
					ExtraData = {
						Slider = {
							IsSlider = false,
							CurveType = "L", VirtualLength = 0, SlidesCount = 0, MovementTime = 0, EndTime = 0, TotalTickCount = 0, CurvePoints = {}, TickData = {}, TickDataRev = {}, ReverseCurvePoints = {}
						},
						Spinner = {
							IsSpinner = false,
							SpinEndTime = 0
						},
						HitEffectData = {
							Volume = 100, GlobalSampleSet = "Normal"
						}
					}
				} :: ObjectData

				-- Hitsound

				local sampleSet,volume = getHitsoundData(PropertieData.Timing)
				local spiltSample = string.split(PropertieData.HitSample,":")

				if #spiltSample > 1 then
					if spiltSample[1] ~= "0" then
						local currentSampleSet = tonumber(spiltSample[1])
						if currentSampleSet then
							sampleSet = HitsoundSampleset[currentSampleSet]							
						end
						--if sampleSet == nil then
						--	warn("Base object no sample set", spiltSample[1])
						--end
					end

					if spiltSample[4] ~= "0" then
						volume = tonumber(spiltSample[4]) or 1
					end
				end	

				PropertieData.ExtraData.HitEffectData = {Volume = volume, GlobalSampleSet = sampleSet}			

				local baseObjType = GetObjectType(PropertieData.ObjType)

				if baseObjType == 2 then -- slider
					-- On the V2 version, we calculate the slider data right in the converter
					-- Decrease the lag cause during gameplay

					local sliderRawData = string.split(RawPropertiesData[6],"|")
					local sliderSlidesCount = tonumber(RawPropertiesData[7]) or 1
					local sliderBeatLength = tonumber(RawPropertiesData[8]) or 0
					local SliderTime, _BPMStartTime, BPM = getSliderTime(PropertieData.Timing,sliderBeatLength,sliderSlidesCount)
					local TickBPM = BPM * ReturnData.DifficultyValues.SliderTickRate
					local TickTime = 60000/TickBPM				

					PropertieData.ExtraData.Slider.IsSlider = true
					PropertieData.ExtraData.Slider.MovementTime = SliderTime
					PropertieData.ExtraData.Slider.EndTime = PropertieData.Timing + SliderTime
					PropertieData.ExtraData.Slider.SlidesCount = sliderSlidesCount

					local sliderType = sliderRawData[1]
					local sliderVirtualLength = 0
					local sliderTimePerSlide = SliderTime/sliderSlidesCount
					local sliderCurveData = {}
					local sliderCurveDataRev = {}
					--[[
						{Pos = Vector2.new(X,Y), Length = (prevPos - Pos).Magnitude, Rotation = Rotation, MoveTime = {Base, Start, Stop}}
						Base: The total time takes to move, 0 if it's the last point
						Start: The time where it start at the base pos
						Stop: The time where it stop at the next pos, taking the start time if it's the last point
						
						The slider reading process ran 2 times, where:
						First time is to take position of the currentPoint and previous point's length
						Second time is to estimate the time takes on a connection
					]]

					table.remove(sliderRawData,1)

					local function insertPoint(list: {SliderCurveData}, position: Vector2)
						list[#list+1] = {
							Pos = position, Length = 0, Rotation = 0, MoveTime = {Base = 0, Start = 0, Stop = 0}
						}
						-- calculate previous lengthData
						if #list > 1 then
							local data = list[#list-1]
							local crrPos = data.Pos
							local length = (position-crrPos).Magnitude
							local lookVector = (position-crrPos).Unit 
							local rotation = math.deg(math.atan2(lookVector.Y,lookVector.X))
							data.Rotation = rotation
							data.Length = length
							data.MoveTime = {Base = length, Start = sliderVirtualLength, Stop = sliderVirtualLength+length}
							sliderVirtualLength += length
						end
					end

					insertPoint(sliderCurveData,PropertieData.Position)
					for _,data in pairs(sliderRawData) do
						local spilt = string.split(data,":")
						insertPoint(sliderCurveData,Vector2.new(tonumber(spilt[1]), tonumber(spilt[2])))
					end

					if sliderType == "B" or sliderType == "P" then
						local PointsCount = 20
						local isLinear = false
						for i,data in sliderCurveData do
							if i<#sliderCurveData and data.Pos == sliderCurveData[i+1].Pos then
								isLinear = true 
								break
							end
						end
						if not isLinear then
							local CurveDataClone = sliderCurveData
							sliderCurveData = {}
							sliderVirtualLength = 0
							for i = 1,PointsCount do
								insertPoint(sliderCurveData, Bezier((i-1)/(PointsCount-1), CurveDataClone))
							end
						end
					end

					local lengthmultiplier = sliderTimePerSlide/sliderVirtualLength

					for i, data in pairs(sliderCurveData) do
						if i < #sliderCurveData then
							data.MoveTime.Base *= lengthmultiplier
							data.MoveTime.Start *= lengthmultiplier
							data.MoveTime.Stop *= lengthmultiplier
						else
							data.MoveTime.Base = 0
							data.MoveTime.Start = sliderTimePerSlide
							data.MoveTime.Stop = sliderTimePerSlide
						end
					end

					-- For case of multiply slides, making a reverse version

					if sliderSlidesCount > 1 then
						sliderVirtualLength = 0 -- reset
						for i = #sliderCurveData, 1, -1 do
							local pos = sliderCurveData[i].Pos
							insertPoint(sliderCurveDataRev,pos)
						end

						lengthmultiplier = sliderTimePerSlide/sliderVirtualLength -- reset also
						for i, data in sliderCurveDataRev do
							if i < #sliderCurveData then
								data.MoveTime.Base *= lengthmultiplier
								data.MoveTime.Start *= lengthmultiplier
								data.MoveTime.Stop *= lengthmultiplier
							else
								data.MoveTime.Base *= 0
								data.MoveTime.Start *= sliderTimePerSlide
								data.MoveTime.Stop *= sliderTimePerSlide
							end
						end
						--warn(lengthmultiplier )
						--print(sliderCurveData,sliderCurveDataRev)
					end

					PropertieData.ExtraData.Slider.CurvePoints = sliderCurveData
					PropertieData.ExtraData.Slider.ReverseCurvePoints = sliderCurveDataRev				
					--print(PropertieData.ObjType,baseObjType,sliderCurveData)

					if TickTime < SliderTime/sliderSlidesCount-1 then
						local TickPerSlide = math.floor((SliderTime/sliderSlidesCount-1)/TickTime)
						PropertieData.ExtraData.Slider.TotalTickCount = TickPerSlide * sliderSlidesCount
						local tickData = PropertieData.ExtraData.Slider.TickData
						local tickDataRev = PropertieData.ExtraData.Slider.TickDataRev
						for i = 1,TickPerSlide do
							local crrTickTime = TickTime*i

							local tickPoisition = GetTickPositionFromTime(crrTickTime, sliderCurveData)

							if tickPoisition then
								tickData[#tickData+1] = {
									Time = crrTickTime,
									Pos = tickPoisition
								}								
							end
						end
						if sliderSlidesCount > 1 then
							for i = TickPerSlide,1,-1 do
								local crrTickTime = SliderTime/sliderSlidesCount-tickData[i].Time
								tickDataRev[#tickDataRev+1] = {
									Time = crrTickTime,
									Pos = tickData[i].Pos
								}
							end
							--print(tickData,tickDataRev)
						end
					end

					ReturnData.DetailedAnalyse.Slider += 1
					ReturnData.DetailedAnalyse.SliderTick += PropertieData.ExtraData.Slider.TotalTickCount
				elseif baseObjType == 8 then
					ReturnData.DetailedAnalyse.Spinner += 1
				else
					ReturnData.DetailedAnalyse.Note += 1
				end

				maxScore += 300 * (1+math.max(maxCombo-1,0)*6/25) + PropertieData.ExtraData.Slider.TotalTickCount * 10 + PropertieData.ExtraData.Slider.SlidesCount * 30 
				maxCombo += 1 + PropertieData.ExtraData.Slider.SlidesCount + PropertieData.ExtraData.Slider.TotalTickCount

				ReturnData.ObjectData[#ReturnData.ObjectData+1] = PropertieData
			end
			ReturnData.DetailedAnalyse.MaxCombo = maxCombo
			ReturnData.DetailedAnalyse.MaxScore = maxScore
		end
		end
	return ReturnData 
end 

return OsuMapConvert
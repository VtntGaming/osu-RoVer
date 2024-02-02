--[[
	-> OsuMapConvert.lua <-
	-> osu!RoVer RebuildVer Beta V2.0 <-
	-> Written by VtntGaming <-
	-> Size: 6.61kB <-	
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

return function(MapData,Properties)
	local ReturnData = {
		ObjectData = {},
		BreakTime = {},
		RobloxData = {},
		MapComboColor = {},
		Difficulty = {},
		TimingPoints = {},
		BPMData = {BPM = {}, SliderMulti = {}}
	}
	local isObject = Properties.isObject
	local ReturnType = Properties.ReturnType
	
	if not ReturnType then
		ReturnType = 1 -- it default to return all
	end
	
	if isObject then
		MapData = require(MapData)
	end
	local MapVersion = 14
	do
		local _,s = string.find(MapData,"osu file format v")
		local e,_ = string.find(MapData,"\n",s)
		if e and s then
			MapVersion = tonumber(string.sub(MapData,s+1,e-1))
		end
	end
	-- Spilt map into different stuff
	
	-- File config
	
	if string.find(MapData,"%[RobloxData]") then
		local _,s = string.find(MapData,"%[RobloxData]")
		local e = string.find(MapData,"%[",s)
		
		local raw = string.split(string.sub(MapData,s+1,e-1),"\n")
		
		for _,data in pairs(raw) do
			if string.find(data,":") == nil then continue end
			
			local rawdata = string.split(data,": ")
			ReturnData.RobloxData[rawdata[1]] = rawdata[2] 
		end
	end
	
	if string.find(MapData,"//Break Periods") then
		local _,s = string.find(MapData,"//Break Periods")
		local e = string.find(MapData,"/",s)

		local raw = string.split(string.sub(MapData,s+1,e-1),"\n")

		for _,data in pairs(raw) do
			if string.find(data,":") == nil then continue end

			local rawdata = string.split(data,",")
			table.insert(ReturnData.BreakTime,{startTime = rawdata[2], endTime = rawdata[3]})
		end
	end
	
	if string.find(MapData,"%[General]") then
		ReturnData.General = {}
		local _,s = string.find(MapData,"%[General]")
		local e = string.find(MapData,"%[",s)

		local raw = string.split(string.sub(MapData,s+1,e-1),"\n")
		for _,data in pairs(raw) do
			if string.find(data,":") == nil then continue end

			local rawdata = string.split(data,":")

			ReturnData.General[rawdata[1]] = string.sub(rawdata[2],2,#rawdata[2])
		end
	end
	
	if string.find(MapData,"%[Metadata]") then
		ReturnData.Metadata = {}
		local _,s = string.find(MapData,"%[Metadata]")
		local e = string.find(MapData,"%[",s)

		local raw = string.split(string.sub(MapData,s+1,e-1),"\n")
		for _,data in pairs(raw) do
			if string.find(data,":") == nil then continue end

			local rawdata = string.split(data,":")
			
			ReturnData.Metadata[rawdata[1]] = rawdata[2]
		end
	end
	
	
	if string.find(MapData,"%[Colours]") then
		local _,s = string.find(MapData,"%[Colours]")
		local e = string.find(MapData,"%[",s)

		local raw = string.split(string.sub(MapData,s+1,e-1),"\n")
		for _,data in pairs(raw) do
			if string.find(data,":") == nil then continue end

			local rawdata = string.split(data,": ")
			local ColorString = rawdata[2]
			local ColorData = string.split(ColorString,",")
			ReturnData.MapComboColor[#ReturnData.MapComboColor+1] = Color3.fromRGB(ColorData[1],ColorData[2],ColorData[3])
		end
	end
	
	if string.find(MapData,"%[Difficulty]") then
		ReturnData.Difficulty = {}
		local _,s = string.find(MapData,"%[Difficulty]")
		local e = string.find(MapData,"%[",s)

		local raw = string.split(string.sub(MapData,s+1,e-1),"\n")
		for _,data in pairs(raw) do
			if string.find(data,":") == nil then continue end

			local rawdata = string.split(data,":")
			ReturnData.Difficulty[rawdata[1]] = tonumber(rawdata[2])
		end
	end
	
	if string.find(MapData,"%[TimingPoints]") then
		ReturnData.TimingPoints = {}
		local _,s = string.find(MapData,"%[TimingPoints]")
		local e = string.find(MapData,"%[",s)
		
		--[[
		Time (ms), Beatlength (BPM: positive | Slider multiplier: negative), Meter, SampleSet, SampleIndex, Volume (%), Uninherited, Effects (Kiai) 
		]]
		
		local BPMData = {
			-- {Time, BPM/SliderMulti}
			BPM = {},
			SliderMulti = {}
		}

		local raw = string.split(string.sub(MapData,s+1,e-1),"\n")
		for _,data in pairs(raw) do
			if not string.find(data,",") then continue end
			local rawdata = string.split(data,",")
			for i,a in pairs(rawdata) do
				rawdata[i] = tonumber(a) or -1
			end
			
			if rawdata[7] == 1 then
				--BPM
				BPMData.BPM[#BPMData.BPM+1] = {rawdata[1],1 / rawdata[2] * 1000 * 60}
			else
				--Timing points
				BPMData.SliderMulti[#BPMData.SliderMulti+1] = {rawdata[1], 100/(-rawdata[2])}
			end
			ReturnData.TimingPoints[#ReturnData.TimingPoints+1] = rawdata
		end
		
		ReturnData.BPMData = BPMData
	end
	
	-- Object reader
	
	local function getObjectType(ObjType)
		if not ObjType or not tonumber(ObjType) then
			return
		end
		if ObjType == 1 or ObjType == 2 or ObjType == 8 then
			return ObjType
		else
			local base = ObjType%8
			if base == 5 then
				return 1
			elseif base == 6 then
				return 2
			else
				return 8
			end
		end
	end
	
	local function getSliderTime(noteTime, beatLength, sliderSlides)
		local crrBPM = -1
		local crrBPMTime = 9e99
		local crrSliderMulti = 1
		local defaultSliderMulti = ReturnData.Difficulty.SliderMultiplier or 1
		sliderSlides = math.max(1,sliderSlides)
		
		for _,data in pairs(ReturnData.BPMData.BPM) do
			if crrBPM == -1 or data[1] <= noteTime then
				crrBPM = data[2]
				crrBPMTime = data[1]
			else
				break
			end
		end
		
		for _,data in pairs(ReturnData.BPMData.SliderMulti) do
			if data[1] > noteTime then
				break
			elseif crrBPMTime > data[1] then
				continue
			else
				crrSliderMulti = data[2]
			end
		end
		
		if crrBPM == -1 then crrBPM = 60 end
		crrSliderMulti = math.max(crrSliderMulti,0.1)
		local lengthperBeat = crrSliderMulti * 100
		local lengthperSec = lengthperBeat*(crrBPM/60)
		
		local SliderTime = ((beatLength * sliderSlides) / lengthperSec) / defaultSliderMulti
		return SliderTime * 1000
	end
	local HitsoundSampleset = {
		[0] = "default",
		[1] = "normal",
		[2] = "soft",
		[3] = "drum"
	}
	
	local function getHitsoundData(Time)
		local defaultSampleSet = ReturnData.General.SampleSet or "normal"
		for i,timing in pairs(ReturnData.TimingPoints) do
			if timing[1] <= Time then
				if i < #ReturnData.TimingPoints and ReturnData.TimingPoints[i+1][1] < Time then
					continue
				end
				local volume = timing[6]
				local sampleSet = HitsoundSampleset[timing[4]]
				if sampleSet == "default" then
					sampleSet = defaultSampleSet
				end
				if sampleSet == nil then
					warn("TimingPoints no sample set", timing[4])
				end
				return sampleSet,volume
			else
				break
			end
		end
		return defaultSampleSet,100
	end
	
	if ReturnType < 4 then
		local _,_s = string.find(MapData,"%[HitObjects]")
		local e = #MapData
		
		
		local RawString = string.sub(MapData,_s+1,e)
		local RawData = string.split(RawString,"\n")
		for _,Data in pairs(RawData) do
			local RawPropertiesData = string.split(Data,",")
			if #RawPropertiesData < 2 then
				continue
			end
			local PropertieData = {
				Position = Vector2.new(RawPropertiesData[1],RawPropertiesData[2]),
				Timing = tonumber(RawPropertiesData[3]),
				ObjType = tonumber(RawPropertiesData[4]),
				HitSound = RawPropertiesData[5],
				HitSample = RawPropertiesData[#RawPropertiesData],
				ExtraData = {
					isSlider = false, isSpinner = false,
					Slider = {
						CurveType = "L", VirtualLength = 0, SlidesCount = -1, MovementTime = 0, EndTime = 0, CurvePoints = {}, ReverseCurvePoints = {}
					},
					Spinner = {
						SpinEndTime = 0
					},
					HitEffectData = {
						Volume = 100, GlobalSampleSet = "Normal"
					}
				}
			}
			
			-- Hitsound
			
			local sampleSet,volume = getHitsoundData(PropertieData.Timing)
			local spiltSample = string.split(PropertieData.HitSample,":")
			
			if #spiltSample > 1 then
				if spiltSample[1] ~= "0" then
					sampleSet = HitsoundSampleset[tonumber(spiltSample[1])]
					--if sampleSet == nil then
					--	warn("Base object no sample set", spiltSample[1])
					--end
				end

				if spiltSample[4] ~= "0" then
					volume = tonumber(spiltSample[4])
				end
			end
			
			
			
			PropertieData.ExtraData.HitEffectData = {Volume = volume, GlobalSampleSet = sampleSet}
			
			
			local baseObjType = getObjectType(PropertieData.ObjType)
			
			if baseObjType == 2 then -- slider
				-- On the V2 version, we calculate the slider data right in the converter
				-- Decrease the lag cause during gameplay
				
				local sliderRawData = string.split(RawPropertiesData[6],"|")
				local sliderSlidesCount = tonumber(RawPropertiesData[7])
				local sliderBeatLength = tonumber(RawPropertiesData[8])
				local SliderTime = getSliderTime(PropertieData.Timing,sliderBeatLength,sliderSlidesCount)
				PropertieData.ExtraData.isSlider = true
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
				
				
				
				local function insertPoint(list,position)
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
					local newCurvePoints = {}
					local isLinear = false
					for i,data in pairs(sliderCurveData) do
						if i<#sliderCurveData and data.Pos == sliderCurveData[i+1].Pos then
							isLinear = true 
							break
						end
					end
					if not isLinear then
						local CurveDataClone = sliderCurveData
						local function lerp(a,b,c)
							return a + (b - a) * c
						end
						local function Benzier(t)
							local pointData = {}
							for _,data in pairs(CurveDataClone) do
								pointData[#pointData+1] = data.Pos
							end
							local pointsLeft = #pointData
							for i = pointsLeft+1,3,-1 do
								local new = {}
								for a = 1, pointsLeft-1 do
									new[#new+1] = Vector2.new(lerp(pointData[a].X,pointData[a+1].X,t),lerp(pointData[a].Y,pointData[a+1].Y,t))
								end
								pointData = new
								pointsLeft -= 1
							end
							
							
							return pointData[1]
						end
						sliderCurveData = {}
						sliderVirtualLength = 0
						for i = 1,PointsCount do
							insertPoint(sliderCurveData,Benzier((i-1)/(PointsCount-1)))
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
					for i, data in pairs(sliderCurveDataRev) do
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
			end
			
			ReturnData.ObjectData[#ReturnData.ObjectData+1] = PropertieData
		end
	end
	
	return ReturnData 
end

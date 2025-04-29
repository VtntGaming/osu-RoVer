--[[
{ObjId = objectID,
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
SLTravelDistance = SliderLength
}]]
local converterTool = require(workspace.OsuConvert.converterTools)

function h300window(od)
	local max = 64
	local mid = 49
	local min = 34
	local rate = (5 - od)/5
	
	if od > 5 then
		return mid + (max - mid)*rate
	elseif od < 5 then
		return mid + (mid - min)*rate
	else
		return mid
	end
end

function positionOf(vectorTable)
	return Vector2.new(vectorTable.X, vectorTable.Y)
end
function toSLPathData(rawData, basePos)
	local data = string.split(rawData)
	local totalLength = 0
	for i, a in pairs(data) do
		if i > 1 then
			local pos = string.split(a,":")
			data[i] = Vector2.new(pos[1], pos[2])
		end
	end
	data[1] = basePos
	-- {position, time, length}
	local returnData = {}
	
	for i, a in pairs(data) do
		local l = 0
		if i > 1 then
			l = (data[i-1] - a).Magnitude
		end

		totalLength += l
		returnData[#returnData+1] = {a,totalLength,l}
	end
	
	for i, a in pairs(returnData) do
		a[2] /= totalLength
		a[3] /= totalLength
	end
	
	return returnData, totalLength
end

function SLpositionAt(data, lengthRatio)
	if lengthRatio >= 1 then
		return data[#data][1]
	elseif lengthRatio <= 0 then
		return data[1][1]
	end
	for i, a in pairs(data) do
		if i >= #data then
			return data[#data][1]
		end
		local nextData = data[i+1]
		if lengthRatio >= a[2] and lengthRatio <= nextData[2] then
			return a[1] + (nextData[1] - a[1]) * (lengthRatio - a[2])/nextData[3]
		end
	end
end

return function(baseList, baseData)
	local DifficultyObjects = {}
	for objID, crr in pairs(baseList) do
		local crrObj = {}
		
		crrObj.objID = objID
		crrObj.Previous = function(index)
			return DifficultyObjects[objID - index]
		end

		crrObj.Next = function(index)
			return DifficultyObjects[objID + index]
		end
		if crr.isSpinner then
			crrObj.isSpinner = true
		end
		
		
		if objID < 2 or crr.isSpinner or crrObj.Previous(1).isSpinner then
			crrObj.getDoubletapness = function() return 0 end
			local prevTime
			if baseList[objID-1] and baseList[objID-1].Time then
				prevTime =  baseList[objID-1].Time
			end
			if prevTime then
				crrObj.DeltaTime = crr.Time - prevTime
			else
				crrObj.DeltaTime = 9999999999
			end
			crrObj.Time = crr.Time
			crrObj.isInvalid = true
			if objID < 2 then
				crrObj.StrainTime = crr.Time
			else
				crrObj.StrainTime = crr.Time - crrObj.Previous(1).Time
			end
			DifficultyObjects[objID] = crrObj
			continue
		end
		
		-- Angle of 2 previous object with current object
		
		local angle = -1
		if objID > 2 and objID <= #baseList then
			local prevobj = baseList[objID-1]
			local prevprevobj = baseList[objID+1]
			if prevprevobj and not prevprevobj.isSpinner then
				local v1 = Vector2.new(prevprevobj.Position.X, prevprevobj.Position.Y)
				local v2 = Vector2.new(prevobj.Position.X, prevobj.Position.Y)
				local v3 = Vector2.new(crr.Position.X, crr.Position.Y)
				angle = converterTool.getAngle(v1, v2, v3)
			end
		end
		
		-- Cursor position
		local endCursorPosition = positionOf(crr.Position)
		local SLTailPosition = positionOf(crr.Position)
		if crr.isSlider and not baseData.ModData.NS then
			local raw = string.split(crr.ExtraData[2],"|")
			local posRaw = string.split(raw[#raw],":")
			endCursorPosition = Vector2.new(posRaw[1],posRaw[2])
			--[[
			if crr.SliderTime > 36 then -- if the slider time is lower than 36ms, player will just need to hold at the start position already
				local EndPos = Vector2.new(posRaw[1],posRaw[2])
				local StartPos = positionOf(crr.Position)
				
				endCursorPosition = StartPos + (EndPos - StartPos) * ((crr.SliderTime - 36)/crr.SliderTime)
			end]]
		end
		
		-- Lazy jump distance/time
		local prevobj = baseList[objID-1]
		local prevDiffObj = crrObj.Previous(1)
		local normalisedRadius = 50
		local radius = 54.4 - 4.48 * baseData.CS 
		local scalingFactor = normalisedRadius/radius
		local DeltaTime = crr.Time - prevobj.Time
		local minimumDeltaTime = 25
		local StrainTime = math.max(DeltaTime, minimumDeltaTime)
		local Hit300Value = 2 * h300window(baseData.OD)/baseData.Speed
		local LazyJumpDistance = prevDiffObj.endCursorPosition and ((positionOf(crr.Position) * scalingFactor - prevDiffObj.endCursorPosition * scalingFactor).Magnitude) or 0
		local MinimumJumpDistance = LazyJumpDistance
		local MinimumJumpTime = StrainTime
		local BaseTravelDistance = 0
		local BaseTravelTime
		
		if radius < 30 then
			scalingFactor *= 1 + (math.min(30 - radius,5)/50)
		end
		
		
		-- Slider travel distance

		local maxSLRadius = normalisedRadius * 2.4
		local assumedSLRadius = normalisedRadius * 1.8
		
		local minDeltaTime = 25
		local lazySLTravelTime
		local SLTickData = {}
		local SLRepeatCount = 0
		
		if crr.isSlider and not baseData.ModData.NS then
			crrObj.isSlider = true
			--local lazyTravelDistance = tonumber(crr.ExtraData[4])
			local SliderTime = crr.SliderTime * 1000
			local trackingEndTime = math.max(
				crr.Time + SliderTime - 36, crr.Time + SliderTime/2
			)
			
			
			lazySLTravelTime = trackingEndTime - crr.Time
			local SliderPathData, SLActualTotalLength = toSLPathData(crr.ExtraData[2], positionOf(crr.Position))
			local slidesCount = tonumber(crr.ExtraData[3])
			SLRepeatCount = math.max(0, slidesCount - 1)
			if slidesCount%2 == 0 then -- if it ends as a reverse state
				local tmp = {}
				for i = #SliderPathData, 1, -1 do
					tmp[#tmp+1] = SliderPathData[i]
				end
				SliderPathData = tmp
			end
			local endTimeMin = lazySLTravelTime / SliderTime
			endCursorPosition = SLpositionAt(SliderPathData, endTimeMin)
			if slidesCount%2 == 1 then
				SLTailPosition = SLpositionAt(SliderPathData, 1)
			end
			--[[
			for i, data in pairs(SliderPathData) do
				local requiredMovement = assumedSLRadius
				local movementLength = data[3] * SLActualTotalLength * scalingFactor
				
				if i == #SliderPathData then
					local lazyMovement = (positionOf(crr.Position) - data[1]).Magnitude
					if lazyMovement < data[3] * SLActualTotalLength then
						movementLength = lazyMovement * scalingFactor
					end
				end				
			end]]
			
			BaseTravelTime = math.max(lazySLTravelTime, minDeltaTime)
			local LazyDistance = (positionOf(crr.Position) * scalingFactor - endCursorPosition * scalingFactor).Magnitude - radius

			BaseTravelDistance = math.max(0,LazyDistance * math.pow(1 + (slidesCount-1) / 2.5, 1.0 / 2.5))
		end
		
		if prevDiffObj.isSlider then
			local lastTravelTime = math.max(prevDiffObj.lazySLTravelTime, minimumDeltaTime)
			MinimumJumpTime = math.max(StrainTime - lastTravelTime, minimumDeltaTime)
			
			local tailJumpDistance = (positionOf(crr.Position) - prevDiffObj.SLTailPosition).Magnitude * scalingFactor
			local JumpDistance = LazyJumpDistance - (maxSLRadius - assumedSLRadius)
			MinimumJumpDistance = math.max(0, math.min(JumpDistance, tailJumpDistance - maxSLRadius))
		end
		

		
		crrObj.getDoubletapness = function(nextObj)
			if nextObj and not nextObj.isSpinner then
				local crrDeltaTime = math.max(1, DeltaTime)
				local nextDeltaTime = math.max(1, nextObj.DeltaTime)
				local deltaDifference = math.abs(nextDeltaTime-crrDeltaTime)
				local speedRatio = crrDeltaTime/math.max(crrDeltaTime,deltaDifference)
				local windowRatio = math.pow(math.min(1, crrDeltaTime / Hit300Value), 2)
				
				return 1 - math.pow(speedRatio, 1 - windowRatio)
			end
			return 0
		end
		
		crrObj.OpacityAt = function(t)
			if t > crr.Time then
				return 0
			end
			local TimePreempt = converterTool.DifficultyRange(baseData.AR, 1800, 1200, 450)
			
			local fadeInStartTime = crr.Time - TimePreempt
			local TimeFadeIn = 400 * math.min(1, TimePreempt/450)
			
			if baseData.ModData.HD then
				local fadeOutStartTime = crr.Time - TimePreempt + TimeFadeIn
				local fadeOutDuration = TimePreempt * 0.3
				
				return math.min(
					math.clamp((t - fadeInStartTime) / TimeFadeIn, 0.0, 1.0),
					1.0 - math.clamp((t - fadeOutStartTime) / fadeOutDuration, 0.0, 1.0))
			else
				return math.clamp((t - fadeInStartTime) / TimeFadeIn, 0.0, 1.0)
			end
		end
		
		
		crrObj.Time = crr.Time
		crrObj.Angle = angle
		crrObj.DeltaTime = DeltaTime
		crrObj.StrainTime = StrainTime
		crrObj.LazyJumpDistance = LazyJumpDistance
		crrObj.MinimumJumpDistance = MinimumJumpDistance
		crrObj.MinimumJumpTime = MinimumJumpTime
		crrObj.endCursorPosition = endCursorPosition
		crrObj.lazySLTravelTime = lazySLTravelTime
		crrObj.Hit300Value = Hit300Value
		crrObj.BaseTravelTime = BaseTravelTime
		crrObj.BaseTravelDistance = BaseTravelDistance
		crrObj.CirclePosition = Vector2.new(crr.Position.X, crr.Position.Y)
		crrObj.SLTailPosition = SLTailPosition
		crrObj.SLTickData = SLTickData
		crrObj.Radius = radius
		crrObj.SLRepeatCount = SLRepeatCount
		crrObj.lazyTravelDistance = 0 -- I will implement later
		
		DifficultyObjects[objID] = crrObj
		
	end
	
	return DifficultyObjects
end
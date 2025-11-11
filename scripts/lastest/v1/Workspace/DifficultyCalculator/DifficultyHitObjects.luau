--[LOCATION]:[Workspace.DifficultyCalculator.DifficultyHitObjects]
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

function range(value:number):number
	return (value - 5) / 5
end

function difficultyRange(diff:number, min:number, mid:number, max:number):number
	diff = 10 - diff	-- Why does the difficulty return oppositely???????
	if diff > 5 then
		return mid + (max - mid) * range(diff)
	elseif diff < 5 then
		return mid + (mid - min) * range(diff)
	else
		return mid
	end
end

function h300window(od)
	local max = 80
	local mid = 50
	local min = 20
	
	local value = difficultyRange(od, min, mid, max)
	
	return math.floor(value) - 0.5
end

function positionOf(vectorTable):Vector2
	if typeof(vectorTable) == "Vector2" then
		return vectorTable
	end
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

function toSLPathData_New(curvePoints:{Vector2})
	local returnData = {}
	local totalLength = 0

	for i, a in pairs(curvePoints) do
		local l = 0
		if i > 1 then
			l = (curvePoints[i-1] - a).Magnitude
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

export type ObjectData = {
	objID:number,
	Previous:(index:number) -> (ObjectData),
	Next:(index:number) -> (ObjectData),
	getDoubletapness:(nextObj:ObjectData) -> (number),
	isInvalid:boolean,
	isSpinner:boolean,
	isSlider:boolean,
	Position:Vector2,
	Time:number,
	Angle:number,
	DeltaTime:number,
	StrainTime:number,
	LazyJumpDistance:number,
	MinimumJumpDistance:number,
	MinimumJumpTime:number,
	endCursorPosition:Vector2,
	lazySLTravelTime:number,
	Hit300Value:number,
	BaseTravelTime:number,
	BaseTravelDistance:number,
	SmallCircleBonus:number,
	CirclePosition:Vector2,
	SLTailPosition:Vector2,
	TailCirclePosition:Vector2,
	SLTickData:{},
	Radius:number,
	SLRepeatCount:number,
	lazyTravelDistance:number,
}

local NORMALISED_RADIUS = 50
local NORMALISED_DIAMETER = NORMALISED_RADIUS * 2
local MIN_DELTA_TIME = 25
local Maximum_Slider_Radius = NORMALISED_RADIUS * 2.4
local Assumed_Slider_Radius = NORMALISED_RADIUS * 1.8

return function(baseList:{any}, baseData)
	local DifficultyObjects:{ObjectData} = {}
	for objID, crr in pairs(baseList) do
		local crrObj = {}::ObjectData
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
		
		-- It's a spinner, or it's previous is a spinner
		
		if objID < 2 or crr.isSpinner or crrObj.Previous(1).isSpinner then
			crrObj.getDoubletapness = function() return 0 end
			crrObj.Time = crr.Time
			crrObj.isInvalid = true
			local prevObj = crrObj.Previous(1)
			local prevTime = prevObj and prevObj.Time or 0
			crrObj.DeltaTime = crr.Time - prevTime
			crrObj.StrainTime = math.max(crrObj.DeltaTime, MIN_DELTA_TIME)
			crrObj.Hit300Value = 2 * h300window(baseData.OD)
			DifficultyObjects[objID] = crrObj
			continue
		end
		
		-- Angle of 2 previous object with current object
		
		local angle = -1
		--if objID > 2 and objID <= #baseList then
		--	local prevobj = baseList[objID-1]
		--	local prevprevobj = baseList[objID+1]
		--	if prevprevobj and not prevprevobj.isSpinner then
		--		local v1 = Vector2.new(prevprevobj.Position.X, prevprevobj.Position.Y)
		--		local v2 = Vector2.new(prevobj.Position.X, prevobj.Position.Y)
		--		local v3 = Vector2.new(crr.Position.X, crr.Position.Y)
		--		angle = converterTool.getAngle(v1, v2, v3)
		--	end
		--end
		
		if objID > 2 and objID <= #baseList then
			local prevobj = crrObj.Previous(1)
			local prevprevobj = crrObj.Previous(2)
			if prevprevobj and not prevprevobj.isSpinner then
				local prevPrevCursorPosition = prevprevobj.endCursorPosition or prevprevobj.Position
				local prevCursorPosition = prevobj.endCursorPosition
				local prevHeadPosition = prevobj.Position
				local crrHeadPosition = positionOf(crr.Position)
				
				if prevPrevCursorPosition then
					local v1 = prevPrevCursorPosition - prevHeadPosition
					local v2 = crrHeadPosition - prevCursorPosition

					local dot = v1:Dot(v2)
					local det = v1.X * v2.Y - v1.Y * v2.X

					angle = math.abs(math.atan2(det, dot))
				end
			end
		end
		
		-- Cursor position
		local endCursorPosition = positionOf(crr.Position)
		local SLTailPosition = positionOf(crr.Position)
		
		--[[
		if crr.isSlider and not baseData.ModData.NS then
			local raw = string.split(crr.ExtraData[2],"|")
			local posRaw = string.split(raw[#raw],":")
			endCursorPosition = Vector2.new(posRaw[1],posRaw[2])
		end]]
		
		-- Lazy jump distance/time
		local prevobj = baseList[objID-1]
		local prevDiffObj = crrObj.Previous(1)
		local normalisedRadius = 50
		local radius = 54.4 - 4.48 * baseData.CS
		local scalingFactor = normalisedRadius/radius
		local DeltaTime = crr.Time - prevobj.Time
		local minimumDeltaTime = 25
		local StrainTime = math.max(DeltaTime, minimumDeltaTime)
		local Hit300Value = 2 * h300window(baseData.OD)
		local lastCursorPosition:Vector2 = prevDiffObj.endCursorPosition
		local currentPosition:Vector2 = positionOf(crr.Position)
		local TailCirclePosition:Vector2?
		local LazyJumpDistance = lastCursorPosition and ((currentPosition * scalingFactor - lastCursorPosition * scalingFactor).Magnitude) or 0
		local MinimumJumpDistance = LazyJumpDistance
		local MinimumJumpTime = StrainTime
		local BaseTravelDistance = 0
		local BaseTravelTime
		
		
		-- Slider travel distance

		local maxSLRadius = normalisedRadius * 2.4
		local assumedSLRadius = normalisedRadius * 1.8
		
		local lazySLTravelTime
		local SLTickData = {}
		local SLRepeatCount = 0
		
		-- Set distances
		
		if crr.isSlider and not baseData.ModData.NS then
			crrObj.isSlider = true

			
			local SliderTime = crr.SliderTime * 1000
			-- Compute slider cursor position
			local Tail_Leniency = -36
			local trackingEndTime = math.max(
				crr.Time + SliderTime + Tail_Leniency, crr.Time + SliderTime/2
			)
			
			local TickData = crr.SliderDifficultyTickData::{any}
			if TickData then
				local lastRealTick
				for _, _tick in pairs(TickData) do
					if _tick[4] == "Tick" then
						lastRealTick = _tick
					end
				end
				if lastRealTick then
					if lastRealTick[1] > trackingEndTime then
						trackingEndTime = lastRealTick[1]
					end
				end
				
			end
						
			lazySLTravelTime = trackingEndTime - crr.Time
			local _curvePoints = crr.SliderCurvePoints::{Vector2}
			local SliderPathData, SLActualTotalLength = toSLPathData_New(_curvePoints)
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
			if endTimeMin % 2 >= 1 then
				endTimeMin = 1 - endTimeMin % 1
			else
				endTimeMin %= 1
			end
			endCursorPosition = SLpositionAt(SliderPathData, endTimeMin)
			if slidesCount%2 == 1 then
				SLTailPosition = SLpositionAt(SliderPathData, endTimeMin)
			end
			
			local currentCursorPosition = positionOf(crr.Position)
			local LazyTravelDistance = 0
			if TickData then
				for i, currentTick in pairs(TickData) do
					local currentMovement:Vector2 = currentTick[3] - currentCursorPosition
					local currentMovementLength = scalingFactor * currentMovement.Magnitude
					local requiredMovement = Assumed_Slider_Radius
					
					if i == #TickData then
						local lazyMovement = endCursorPosition - currentCursorPosition
						
						if lazyMovement.Magnitude < currentMovement.Magnitude then
							currentMovement = lazyMovement
						end
						
						currentMovementLength = scalingFactor * currentMovement.Magnitude
					elseif currentTick[4] == "Repeat" then
						requiredMovement = NORMALISED_RADIUS
					end
					
					if currentMovementLength > requiredMovement then
						currentCursorPosition = currentCursorPosition + currentMovement * ((currentMovementLength - requiredMovement) / currentMovementLength)
						currentMovementLength *= (currentMovementLength - requiredMovement) / currentMovementLength
						LazyTravelDistance += currentMovementLength
					end
					
					if i == #TickData then
						endCursorPosition = currentCursorPosition
					end
				end
			end
			
			TailCirclePosition = slidesCount % 2 == 1 and _curvePoints[1] or _curvePoints[#_curvePoints]
			--
			
			BaseTravelTime = math.max(lazySLTravelTime, MIN_DELTA_TIME)
			BaseTravelDistance = LazyTravelDistance * math.pow(1 + (slidesCount - 1) / 2.5, 1 / 2.5)
		end
		
		if prevDiffObj.isSlider and not baseData.ModData.NS then
			local lastTravelTime = math.max(prevDiffObj.lazySLTravelTime, MIN_DELTA_TIME)
			MinimumJumpTime = math.max(StrainTime - lastTravelTime, MIN_DELTA_TIME)
			
			local tailJumpDistance = (currentPosition - prevDiffObj.TailCirclePosition).Magnitude * scalingFactor
			MinimumJumpDistance = math.max(0, math.min(LazyJumpDistance - (Maximum_Slider_Radius - Assumed_Slider_Radius), tailJumpDistance - Maximum_Slider_Radius))
		end
		
		crrObj.getDoubletapness = function(nextObj:ObjectData)
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
		
		crrObj.OpacityAt = function(t:number)
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
		
		crrObj.SmallCircleBonus = math.max(1, 1 + (30 - radius) / 40)
		crrObj.Position = positionOf(crr.Position)
		crrObj.Time = crr.Time
		crrObj.Angle = angle
		crrObj.DeltaTime = DeltaTime
		crrObj.StrainTime = StrainTime
		crrObj.LazyJumpDistance = LazyJumpDistance
		crrObj.MinimumJumpDistance = MinimumJumpDistance
		crrObj.MinimumJumpTime = MinimumJumpTime
		crrObj.endCursorPosition = endCursorPosition
		crrObj.TailCirclePosition = TailCirclePosition
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
		
		DifficultyObjects[objID] = crrObj::ObjectData	
	end
	
	return DifficultyObjects
end
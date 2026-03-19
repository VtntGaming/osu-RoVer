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

-- Cache math functions
local math_floor = math.floor
local math_max = math.max
local math_min = math.min
local math_abs = math.abs
local math_pow = math.pow
local math_clamp = math.clamp
local math_atan2 = math.atan2
local Vector2_new = Vector2.new

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

	return math_floor(value) - 0.5
end

function positionOf(vectorTable):Vector2
	if typeof(vectorTable) == "Vector2" then
		return vectorTable
	end
	return Vector2_new(vectorTable.X, vectorTable.Y)
end

function toSLPathData(curvePoints:{Vector2})
	local returnData = {}
	local totalLength = 0

	for i, a in ipairs(curvePoints) do
		local l = 0
		if i > 1 then
			l = (curvePoints[i-1] - a).Magnitude
		end

		totalLength += l
		returnData[#returnData+1] = {a,totalLength,l}
	end

	for i, a in ipairs(returnData) do
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
	for i, a in ipairs(data) do
		if i >= #data then
			return data[#data][1]
		end
		local nextData = data[i+1]
		if lengthRatio >= a[2] and lengthRatio <= nextData[2] then
			return a[1] + (nextData[1] - a[1]) * (lengthRatio - a[2])/nextData[3]
		end
	end

	return nil
end

local OBJECT_RADIUS = 64
local BROKEN_GAMEFIELD_ROUNDING_ALLOWANCE = 1.00041

local function CalculateRadiusFromCircleSize(CSRate: number): number
	local scale = (1 - 0.7 * range(CSRate)) / 2 * BROKEN_GAMEFIELD_ROUNDING_ALLOWANCE

	return OBJECT_RADIUS * scale
end

export type ObjectData = {
	objID:number,
	Previous:(index:number) -> (ObjectData),
	Next:(index:number) -> (ObjectData),
	getDoubletapness:(nextObj:ObjectData) -> (number),
	OpacityAt: (t: number) -> (number),
	isInvalid:boolean,
	isSpinner:boolean,
	isSlider:boolean,
	Position:Vector2,
	Time:number,
	Angle:number,
	DeltaTime:number,
	AdjustedDeltaTime:number,
	JumpDistance:number,
	LazyJumpDistance:number,
	MinimumJumpDistance:number,
	MinimumJumpTime:number,
	AngularVelocity: number?,
	NormalisedVectorAngle: number?,
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
	Preempt: number,
	TimePreempt: number,
	ClockRate: number,
	TimeFadeIn: number
}

export type NestedTick = {
	StartTime: number,
	Type: string
}

local NORMALISED_RADIUS = 50
local NORMALISED_DIAMETER = NORMALISED_RADIUS * 2
local MIN_DELTA_TIME = 25
local Maximum_Slider_Radius = NORMALISED_RADIUS * 2.4
local Assumed_Slider_Radius = NORMALISED_RADIUS * 1.8


local PREEMPT_MIN = 450
local PREEMPT_MID = 1200
local PREEMPT_MAX = 1800

local defaultFunct = function()
	return 0
end

local DifficultyHitObject = {}

DifficultyHitObject.NORMALISED_RADIUS = NORMALISED_RADIUS
DifficultyHitObject.NORMALISED_DIAMETER = NORMALISED_DIAMETER
DifficultyHitObject.MIN_DELTA_TIME = MIN_DELTA_TIME
DifficultyHitObject.Maximum_Slider_Radius = Maximum_Slider_Radius
DifficultyHitObject.Assumed_Slider_Radius = Assumed_Slider_Radius

function DifficultyHitObject.GenerateDifficultyHitObjects(baseList:{any}, baseData):{ObjectData}
	local DifficultyObjects:{ObjectData} = {}
	for objID = 1, #baseList do
		local crr = baseList[objID]
		local crrObj = {}::ObjectData

		-- initialize important properties		
		crrObj.TimePreempt = converterTool.DifficultyRange(baseData.AR, PREEMPT_MAX, PREEMPT_MID, PREEMPT_MIN) // 1
		crrObj.ClockRate = baseData.ModData.SA
		crrObj.Preempt = crrObj.TimePreempt / crrObj.ClockRate
		crrObj.TimeFadeIn = 400 * math.min(1, crrObj.TimePreempt / PREEMPT_MIN)
		--
		local registeredIndex = #DifficultyObjects + 1
		crrObj.objID = objID
		crrObj.Previous = function(index)
			return DifficultyObjects[registeredIndex - index]
		end

		crrObj.Next = function(index)
			return DifficultyObjects[registeredIndex + index]
		end

		if crr.isSpinner then
			crrObj.isSpinner = true
		end

		-- It's a spinner, or it's previous is a spinner

		if objID < 2 or crr.isSpinner or crrObj.Previous(1).isSpinner then
			crrObj.getDoubletapness = defaultFunct
			crrObj.OpacityAt = defaultFunct
			crrObj.Time = crr.Time
			crrObj.isInvalid = true
			crrObj.LazyJumpDistance = 0
			crrObj.JumpDistance = 0
			local prevObj = crrObj.Previous(1)
			local prevTime = prevObj and prevObj.Time or 0
			crrObj.DeltaTime = crr.Time - prevTime
			crrObj.AdjustedDeltaTime = math.max(crrObj.DeltaTime, MIN_DELTA_TIME)
			crrObj.Hit300Value = 2 * h300window(baseData.OD)
			DifficultyObjects[objID] = crrObj
			continue
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
		local radius = CalculateRadiusFromCircleSize(baseData.CS)
		local scalingFactor = normalisedRadius/radius
		local DeltaTime = crr.Time - prevobj.Time
		local minimumDeltaTime = 25
		local AdjustedDeltaTime = math.max(DeltaTime, minimumDeltaTime)
		local Hit300Value = 2 * h300window(baseData.OD)
		local lastCursorPosition:Vector2 = prevDiffObj.endCursorPosition
		local currentPosition:Vector2 = positionOf(crr.Position)
		local TailCirclePosition:Vector2?
		local JumpDistance = prevDiffObj and prevDiffObj.Position and ((currentPosition * scalingFactor - prevDiffObj.Position * scalingFactor).Magnitude) or 0
		local LazyJumpDistance = lastCursorPosition and ((currentPosition * scalingFactor - lastCursorPosition * scalingFactor).Magnitude) or 0
		local MinimumJumpDistance = LazyJumpDistance
		local MinimumJumpTime = AdjustedDeltaTime
		local BaseTravelDistance = 0
		local BaseTravelTime

		
		-- Angle of 2 previous object with current object
		local angle = -1
		local AngularVelocity: number?
		local NormalisedVectorAngle: number?

		if objID > 2 and objID <= #baseList then
			local prevprevDiffObj = crrObj.Previous(2)
			if prevprevDiffObj and not prevprevDiffObj.isSpinner then
				local prevPrevCursorPosition = prevprevDiffObj.endCursorPosition or prevprevDiffObj.Position
				local prevCursorPosition = prevDiffObj.endCursorPosition
				local prevHeadPosition = prevDiffObj.Position
				local crrHeadPosition = positionOf(crr.Position)

				if prevPrevCursorPosition then
					local v1 = prevPrevCursorPosition - prevHeadPosition
					local v2 = crrHeadPosition - prevCursorPosition

					local dot = v1:Dot(v2)
					local det = v1.X * v2.Y - v1.Y * v2.X

					local v = positionOf(crr.Position) - lastCursorPosition
					NormalisedVectorAngle = math.atan2(math.abs(v.Y), math.abs(v.X))

					angle = math_abs(math_atan2(det, dot))

					if prevprevDiffObj.Angle and prevprevDiffObj.Angle ~= -1 then
						local angleDifference = math_abs(angle - prevprevDiffObj.Angle)
						local angleDifferenceAdjusted = math.sin(angleDifference / 2) * 180.0

						AngularVelocity = angleDifferenceAdjusted / (AdjustedDeltaTime * 0.1)
					end
				end
			end
		end

		-- Slider travel distance

		-- local maxSLRadius = normalisedRadius * 2.4
		-- local assumedSLRadius = normalisedRadius * 1.8

		local lazySLTravelTime
		local SLTickData = {}
		local SLRepeatCount = 0

		-- Set distances

		if crr.isSlider and not baseData.ModData.NS then
			crrObj.isSlider = true


			local SliderTime = crr.SliderTime * 1000
			-- Compute slider cursor position
			local Tail_Leniency = -36
			local trackingEndTime = math_max(
				crr.Time + SliderTime + Tail_Leniency, crr.Time + SliderTime/2
			)

			local TickData = crr.SliderDifficultyTickData::{NestedTick}
			if TickData then
				local lastRealTick
				for _, _tick in ipairs(TickData) do
					if _tick.Type == "Tick" then
						lastRealTick = _tick
					end
				end
				if lastRealTick then
					if lastRealTick.StartTime > trackingEndTime then
						trackingEndTime = lastRealTick.StartTime
					end
				end
			end

			lazySLTravelTime = trackingEndTime - crr.Time
			local _curvePoints = crr.SliderCurvePoints::{Vector2}
			local SliderPathData, _ = toSLPathData(_curvePoints)
			local slidesCount = tonumber(crr.ExtraData[3])
			SLRepeatCount = math.max(0, slidesCount - 1)
			if slidesCount%2 == 0 then -- if it ends as a reverse state
				local tmp = {}
				for i = #SliderPathData, 1, -1 do
					tmp[#tmp+1] = SliderPathData[i]
				end
				SliderPathData = tmp
			end
			local spanDuration = SliderTime / slidesCount
			local endTimeMin = lazySLTravelTime / spanDuration
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
				for i, currentTick in ipairs(TickData) do
					local currentMovement:Vector2 = currentTick.Position - currentCursorPosition
					local currentMovementLength = scalingFactor * currentMovement.Magnitude
					local requiredMovement = Assumed_Slider_Radius

					if i == #TickData then
						local lazyMovement = endCursorPosition - currentCursorPosition

						if lazyMovement.Magnitude < currentMovement.Magnitude then
							currentMovement = lazyMovement
						end

						currentMovementLength = scalingFactor * currentMovement.Magnitude
					elseif currentTick.Type == "Repeat" then
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

			TailCirclePosition = slidesCount % 2 == 0 and _curvePoints[1] or _curvePoints[#_curvePoints]
			--

			BaseTravelTime = math_max(lazySLTravelTime, MIN_DELTA_TIME)
			BaseTravelDistance = LazyTravelDistance * math_max(1 , math_pow(slidesCount - 1, 0.3))
		end

		if prevDiffObj.isSlider and not baseData.ModData.NS then
			local lastTravelTime = math_max(prevDiffObj.lazySLTravelTime, MIN_DELTA_TIME)
			MinimumJumpTime = math_max(AdjustedDeltaTime - lastTravelTime, MIN_DELTA_TIME)

			local tailJumpDistance = (currentPosition - prevDiffObj.TailCirclePosition).Magnitude * scalingFactor
			MinimumJumpDistance = math_max(0, math_min(LazyJumpDistance - (Maximum_Slider_Radius - Assumed_Slider_Radius), tailJumpDistance - Maximum_Slider_Radius))
		end

		crrObj.getDoubletapness = function(nextObj:ObjectData)
			if nextObj and not nextObj.isSpinner then
				local crrDeltaTime = math_max(1, DeltaTime)
				local nextDeltaTime = math_max(1, nextObj.DeltaTime)
				local deltaDifference = math_abs(nextDeltaTime-crrDeltaTime)
				local speedRatio = crrDeltaTime/math_max(crrDeltaTime,deltaDifference)
				local windowRatio = math_pow(math_min(1, crrDeltaTime / Hit300Value), 5)

				return 1 - math_pow(speedRatio, 1 - windowRatio)
			end
			return 0
		end

		crrObj.OpacityAt = function(t:number)
			if t > crr.Time then
				return 0
			end
			local TimePreempt = crrObj.TimePreempt

			local fadeInStartTime = crr.Time - TimePreempt
			local TimeFadeIn = 400 * math_min(1, TimePreempt/450)

			if baseData.ModData.HD then
				local fadeOutStartTime = crr.Time - TimePreempt + TimeFadeIn
				local fadeOutDuration = TimePreempt * 0.3

				return math_min(
					math_clamp((t - fadeInStartTime) / TimeFadeIn, 0.0, 1.0),
					1.0 - math_clamp((t - fadeOutStartTime) / fadeOutDuration, 0.0, 1.0))
			else
				return math_clamp((t - fadeInStartTime) / TimeFadeIn, 0.0, 1.0)
			end
		end

		crrObj.SmallCircleBonus = math_max(1, 1 + (30 - radius) / 70)
		crrObj.Position = positionOf(crr.Position)
		crrObj.Time = crr.Time
		crrObj.Angle = angle
		crrObj.AngularVelocity = AngularVelocity
		crrObj.NormalisedVectorAngle = NormalisedVectorAngle
		crrObj.DeltaTime = DeltaTime
		crrObj.AdjustedDeltaTime = AdjustedDeltaTime
		crrObj.JumpDistance = JumpDistance
		crrObj.LazyJumpDistance = LazyJumpDistance
		crrObj.MinimumJumpDistance = MinimumJumpDistance
		crrObj.MinimumJumpTime = MinimumJumpTime
		crrObj.endCursorPosition = endCursorPosition
		crrObj.TailCirclePosition = TailCirclePosition
		crrObj.lazySLTravelTime = lazySLTravelTime
		crrObj.Hit300Value = Hit300Value
		crrObj.BaseTravelTime = BaseTravelTime
		crrObj.BaseTravelDistance = BaseTravelDistance
		crrObj.CirclePosition = Vector2_new(crr.Position.X, crr.Position.Y)
		crrObj.SLTailPosition = SLTailPosition
		crrObj.SLTickData = SLTickData
		crrObj.Radius = radius
		crrObj.SLRepeatCount = SLRepeatCount
		crrObj.lazyTravelDistance = 0 -- I will implement later

		DifficultyObjects[objID] = crrObj::ObjectData	
	end

	return DifficultyObjects
end

return DifficultyHitObject
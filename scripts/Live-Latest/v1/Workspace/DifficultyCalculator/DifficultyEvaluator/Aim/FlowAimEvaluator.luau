--!strict
local Workspace = game:GetService("Workspace")

local DifficultyCalculationUtils = require(Workspace.DifficultyCalculator.DifficultyEvaluator.DifficultyCalculationUtils)
local SnapAimEvaluator = require(script.Parent.SnapAimEvaluator)
local DifficultyHitObjects = require(Workspace.DifficultyCalculator.DifficultyHitObjects)
local FlowAimEvaluator = {}

local VELOCITY_CHANGE_MULTIPLIER = 0.52

type HitObject = DifficultyHitObjects.ObjectData

local function calculateOverlapFactor(first: HitObject, second: HitObject): number
	local radius = first.Radius
	local distance = (first.Position - second.Position).Magnitude

	return math.clamp(1 - math.pow(math.max(distance - radius, 0) / radius, 2), 0, 1)
end

function FlowAimEvaluator.GetFlowAimDiff(currentObject: HitObject, withSliderTravelDistance: boolean?): number
	if currentObject.isSpinner or currentObject.objID < 2 or currentObject.Previous(1).isSpinner then
		return 0
	end

	local lastObject = currentObject.Previous(1)
	local lastLastObject = currentObject.Previous(2)

	local currentDistance = withSliderTravelDistance and currentObject.LazyJumpDistance or currentObject.JumpDistance
	local prevDistance = withSliderTravelDistance and lastObject.LazyJumpDistance or lastObject.JumpDistance

	local currentVelocity = currentDistance / currentObject.AdjustedDeltaTime

	if lastObject.isSlider and withSliderTravelDistance then
		local sliderDistance = lastObject.LazyTravelDistance + currentObject.LazyJumpDistance
		currentVelocity = math.max(currentVelocity, sliderDistance / currentObject.AdjustedDeltaTime)
	end

	local previousVelocity = prevDistance / lastObject.AdjustedDeltaTime

	local flowDifficulty = currentVelocity

	flowDifficulty *= math.sqrt(currentObject.SmallCircleBonus)

	flowDifficulty *= 1 + math.min(0.25, 
		math.pow((math.max(currentObject.AdjustedDeltaTime, lastObject.AdjustedDeltaTime) - math.min(currentObject.AdjustedDeltaTime, lastObject.AdjustedDeltaTime)) / 50, 4))

	if currentObject.Angle and lastObject.Angle and currentObject.Angle ~= -1 and lastObject.Angle ~= -1 then
		local angleDifference = math.abs(currentObject.Angle - lastObject.Angle)
		local angleDifferenceAdjusted = math.sin(angleDifference / 2) * 180
		local angularVelocity = angleDifferenceAdjusted / (currentObject.AdjustedDeltaTime * 0.1)

		flowDifficulty *= 0.8 + math.sqrt(angularVelocity / 270)
	end

	local overlappedNotesWeight = 1

	if currentObject.objID > 3 and lastObject.Position and lastLastObject.Position then
		local o1 = calculateOverlapFactor(currentObject, lastObject)
		local o2 = calculateOverlapFactor(currentObject, lastLastObject)
		local o3 = calculateOverlapFactor(lastObject, lastLastObject)

		overlappedNotesWeight = 1 - o1 * o2 * o3
	end

	if currentObject.Angle and currentObject.Angle ~= -1 then
		flowDifficulty += math.sqrt(currentVelocity) *
			SnapAimEvaluator.CalcAcuteAngleBonus(currentObject.Angle) * overlappedNotesWeight
	end

	if math.max(previousVelocity, currentVelocity) ~= 0 then
		if (withSliderTravelDistance) then
			currentVelocity = currentDistance / currentObject.AdjustedDeltaTime
		end

		local distRatio = DifficultyCalculationUtils.Smoothstep(math.abs(previousVelocity - currentVelocity) / math.max(previousVelocity, currentVelocity), 0, 1)
		local overlapVelocityBuff = math.min(DifficultyHitObjects.NORMALISED_DIAMETER * 1.25 / math.min(currentObject.AdjustedDeltaTime, lastObject.AdjustedDeltaTime),
			math.abs(previousVelocity - currentVelocity))

		flowDifficulty += overlapVelocityBuff * distRatio * overlappedNotesWeight * VELOCITY_CHANGE_MULTIPLIER
	end

	if currentObject.isSlider and withSliderTravelDistance then
		flowDifficulty += currentObject.BaseTravelDistance / currentObject.BaseTravelTime
	end

	flowDifficulty = math.pow(flowDifficulty, 1.45)
	return flowDifficulty * DifficultyCalculationUtils.Smootherstep(currentDistance, 0, DifficultyHitObjects.NORMALISED_RADIUS)
end

return FlowAimEvaluator
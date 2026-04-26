--!strict
local Workspace = game:GetService("Workspace")

local DifficultyCalculationUtils = require(Workspace.DifficultyCalculator.DifficultyEvaluator.DifficultyCalculationUtils)
local DifficultyHitObjects = require(Workspace.DifficultyCalculator.DifficultyHitObjects)
local SnapAimEvaluator = {}

local WIDE_ANGLE_MULTIPLIER = 9.67
local ACUTE_ANGLE_MULTIPLIER = 2.41
local SLIDER_MULTIPLIER = 1.5
local VELOCITY_CHANGE_MULTIPLIER = 0.9
local WIGGLE_MULTIPLIER = 1.02
local MAXIMUM_REPETITION_NERF = 0.15
local MAXIMUM_VECTOR_INFLUENCE = 0.5
local WIDE_ANGLE_TIME_SCALE = 1.45

type HitObject = DifficultyHitObjects.ObjectData

local function calcAngleWideness(angle: number): number
	return DifficultyCalculationUtils.Smoothstep(angle, math.rad(40), math.rad(140))
end

local function CalcAngleAcuteness(angle: number): number
	return DifficultyCalculationUtils.Smoothstep(angle, math.rad(140), math.rad(40))
end
local NOTE_LIMIT = 6;

local function vectorAngleRepetition(current: HitObject, previous: HitObject)
	if not current.Angle or not previous.Angle or current.Angle == -1 or previous.Angle == -1 then
		return 1;
	end

	local constantAngleCount = 0

	for index = 0, NOTE_LIMIT do
		local loopObj = current.Previous(index + 1)

		if not loopObj then
			break
		end

		-- Only consider vectors in the same jump section, stopping to change rhythm ruins momentum
		if (math.max(current.AdjustedDeltaTime, loopObj.AdjustedDeltaTime) > 1.1 * math.min(current.AdjustedDeltaTime, loopObj.AdjustedDeltaTime)) then
			break;
		end

		if (loopObj.NormalisedVectorAngle and current.NormalisedVectorAngle) then
			local angleDifference = math.abs(current.NormalisedVectorAngle - loopObj.NormalisedVectorAngle);
			-- Refer to this desmos for tuning, constants need to be precise so that values stay within the range of 0 and 1.
			constantAngleCount += math.cos(8 * math.min(math.rad(11.25), angleDifference));
		end
	end

    local vectorRepetition = math.pow(math.min(0.5 / constantAngleCount, 1), 2);

    local stackFactor = DifficultyCalculationUtils.Smootherstep(current.LazyJumpDistance, 0, DifficultyHitObjects.NORMALISED_DIAMETER);

    local currAngle = current.Angle;
    local lastAngle = previous.Angle;

    local angleDifferenceAdjusted = math.cos(2 * math.min(math.rad(45), math.abs(currAngle - lastAngle) * stackFactor));

    local baseNerf = 1 - MAXIMUM_REPETITION_NERF * CalcAngleAcuteness(lastAngle) * angleDifferenceAdjusted;

    return math.pow(baseNerf + (1 - baseNerf) * vectorRepetition * MAXIMUM_VECTOR_INFLUENCE * stackFactor, 2);
end

local function highBpmBonus(ms: number): number
	return 1 / (1 - math.pow(0.03, math.pow(ms / 1000, 0.65)))
end

SnapAimEvaluator.CalcAngleAcuteness = CalcAngleAcuteness

function SnapAimEvaluator.GetSnapAimDiff(currentObject: HitObject, withSliderTravelDistance: boolean?): number
	if currentObject.isSpinner or currentObject.objID < 3 or currentObject.Previous(1).isSpinner then
		return 0
	end

	local lastObject = currentObject.Previous(1)
	local lastLastObject = currentObject.Previous(2)
	local last2Object = currentObject.Previous(3)

	local radius = DifficultyHitObjects.NORMALISED_RADIUS
	local diameter = DifficultyHitObjects.NORMALISED_DIAMETER

	local currDistance = withSliderTravelDistance and currentObject.LazyJumpDistance or currentObject.JumpDistance
	local currVelocity = currDistance / currentObject.AdjustedDeltaTime

	if lastObject.isSlider and withSliderTravelDistance then
		local sliderDistance = lastObject.LazyTravelDistance + currentObject.LazyJumpDistance
		currVelocity = math.max(currVelocity, sliderDistance / currentObject.AdjustedDeltaTime)
	end

	local prevDistance = withSliderTravelDistance and lastObject.LazyJumpDistance or lastObject.JumpDistance
	local prevVelocity = prevDistance / lastObject.AdjustedDeltaTime

	local sliderBonus = 0
	local velocityChangeBonus = 0

	local snapDifficulty = currVelocity

	if currentObject.Angle and lastObject.Angle then
		local currAngle = currentObject.Angle
		local lastAngle = lastObject.Angle

		local acuteAngleBonus = 0

		-- Rewarding angles, take the smaller velocity as base.
		local velocityInfluence = math.min(currVelocity, prevVelocity)

		if math.max(currentObject.AdjustedDeltaTime, lastObject.AdjustedDeltaTime) < 1.25 * math.min(currentObject.AdjustedDeltaTime, lastObject.AdjustedDeltaTime) then -- If rhythms are the same.
			acuteAngleBonus = CalcAngleAcuteness(currAngle)

			-- Penalize angle repetition.
			acuteAngleBonus *= 0.08 + 0.92 * (1 - math.min(acuteAngleBonus, math.pow(CalcAngleAcuteness(lastAngle), 3)))

			-- Apply acute angle bonus for BPM above 300 1/2 and distance more than one diameter
			acuteAngleBonus *= velocityInfluence *
				DifficultyCalculationUtils.Smootherstep(DifficultyCalculationUtils.MillisecondsToBPM(currentObject.AdjustedDeltaTime, 2), 300, 400) *
				DifficultyCalculationUtils.Smootherstep(currDistance, 0, diameter * 2)
		end

		local wideAngleBonus = calcAngleWideness(currAngle)

		-- Penalize angle repetition.
		wideAngleBonus *= 0.25 + 0.75 * (1 - math.min(wideAngleBonus, math.pow(calcAngleWideness(lastAngle), 3)))

		-- Rescaling velocity for the wide angle bonus
		local wideAngleCurrVelocity = currDistance / math.pow(currentObject.AdjustedDeltaTime, WIDE_ANGLE_TIME_SCALE);
		local wideAnglePrevVelocity = prevDistance / math.pow(lastObject.AdjustedDeltaTime, WIDE_ANGLE_TIME_SCALE);

		if currentObject.isSlider and withSliderTravelDistance then
			local sliderDistance = lastObject.LazyTravelDistance + currentObject.LazyJumpDistance;
			wideAngleCurrVelocity = math.max(wideAngleCurrVelocity, sliderDistance / math.pow(currentObject.AdjustedDeltaTime, WIDE_ANGLE_TIME_SCALE));
		end

		wideAngleBonus *= math.min(wideAngleCurrVelocity, wideAnglePrevVelocity)

		if last2Object and last2Object.Position then
			-- If objects just go back and forth through a middle point - don't give as much wide bonus
			-- Use Previous(2) and Previous(0) because angles calculation is done prevprev-prev-curr, so any object's angle's center point is always the previous object
			local distance = (last2Object.Position - lastObject.Position).Magnitude

			if distance < 1
			then
				wideAngleBonus *= 1 - 0.55 * (1 - distance)
			end
		end

		-- Add in acute angle bonus or wide angle bonus, whichever is larger.
		snapDifficulty += math.max(acuteAngleBonus * ACUTE_ANGLE_MULTIPLIER, wideAngleBonus * WIDE_ANGLE_MULTIPLIER)

		-- Apply wiggle bonus for jumps that are [radius, 3*diameter] in distance, with < 110 angle
		local wiggleBonus = velocityInfluence
			* DifficultyCalculationUtils.Smootherstep(currDistance, radius, diameter)
			* math.pow(DifficultyCalculationUtils.ReverseLerp(currDistance, diameter * 3, diameter), 1.8)
			* DifficultyCalculationUtils.Smootherstep(currAngle, math.rad(110), math.rad(60))
			* DifficultyCalculationUtils.Smootherstep(prevDistance, radius, diameter)
			* math.pow(DifficultyCalculationUtils.ReverseLerp(prevDistance, diameter * 3, diameter), 1.8)
			* DifficultyCalculationUtils.Smootherstep(lastAngle, math.rad(110), math.rad(60))

		snapDifficulty += wiggleBonus * WIGGLE_MULTIPLIER
	end

	if math.max(prevVelocity, currVelocity) ~= 0 then
		if withSliderTravelDistance then
			-- We want to use the average velocity over the whole object when awarding differences, not the individual jump and slider path velocities.
			prevVelocity = (lastObject.LazyJumpDistance or 0 + lastLastObject.BaseTravelDistance or 0) / lastObject.AdjustedDeltaTime
			currVelocity = (currentObject.LazyJumpDistance + lastObject.BaseTravelDistance) / currentObject.AdjustedDeltaTime
		end

		-- Scale with ratio of difference compared to 0.5 * max dist.
		local distRatio = DifficultyCalculationUtils.Smoothstep(math.abs(prevVelocity - currVelocity) / math.max(prevVelocity, currVelocity), 0, 1)

		-- Reward for % distance up to 125 / strainTime for overlaps where velocity is still changing.
		local overlapVelocityBuff = math.min(diameter * 1.25 / math.min(currentObject.AdjustedDeltaTime, lastObject.AdjustedDeltaTime), math.abs(prevVelocity - currVelocity))

		velocityChangeBonus = overlapVelocityBuff * distRatio

		-- Penalize for rhythm changes.
		velocityChangeBonus *= math.pow(math.min(currentObject.AdjustedDeltaTime, lastObject.AdjustedDeltaTime) / math.max(currentObject.AdjustedDeltaTime, lastObject.AdjustedDeltaTime), 2)
	end

	if currentObject.isSlider then
		-- Reward sliders based on velocity.
		sliderBonus = currentObject.BaseTravelDistance / currentObject.BaseTravelTime
	end

	-- Penalize angle repetition.
	snapDifficulty *= vectorAngleRepetition(currentObject, lastObject)

	snapDifficulty += velocityChangeBonus * VELOCITY_CHANGE_MULTIPLIER

	-- Add in additional slider velocity bonus.
	if withSliderTravelDistance then
		snapDifficulty += (sliderBonus < 1 and sliderBonus or math.pow(sliderBonus, 0.75)) * SLIDER_MULTIPLIER
	end
	-- Apply high circle size bonus
	snapDifficulty *= currentObject.SmallCircleBonus

	snapDifficulty *= highBpmBonus(currentObject.AdjustedDeltaTime)

	return snapDifficulty
end

return SnapAimEvaluator
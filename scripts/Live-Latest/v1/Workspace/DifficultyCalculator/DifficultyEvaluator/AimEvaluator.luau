--[LOCATION]:[Workspace.DifficultyCalculator.DifficultyEvaluator.AimEvaluator]
--!strict

-- Pre-load required modules
local Evaluator = require(script.Parent)
local preprocessing = require(workspace.DifficultyCalculator.DifficultyHitObjects)

-- Localize math library for faster access
local math = math

--[[
	Constants
	Defining these outside the main function prevents them from being recalculated thousands of times.
]]

-- General Multipliers
local WIDE_ANGLE_MULTIPLIER = 1.5
local ACUTE_ANGLE_MULTIPLIER = 2.55
local SLIDER_MULTIPLIER = 1.35
local VELOCITY_CHANGE_MULTIPLIER = 0.75
local WIGGLE_MULTIPLIER = 1.02

-- Calculation Constants
local NORMALIZED_RADIUS = 50
local NORMALIZED_DIAMETER = NORMALIZED_RADIUS * 2

-- Pre-calculated angles (in radians)
local RAD_40 = math.rad(40)
local RAD_60 = math.rad(60)
local RAD_110 = math.rad(110)
local RAD_140 = math.rad(140)

-- Make helper functions local for performance
local function smootherstep(x: number, _start: number, _end: number)
	x = math.clamp((x - _start) / (_end - _start), 0.0, 1.0)
	return x * x * x * (x * (6.0 * x - 15.0) + 10.0)
end

local function smoothstep(x: number, _start: number, _end: number)
	x = math.clamp((x - _start) / (_end - _start), 0, 1)
	return x * x * (3 - 2 * x)
end

local function calcWideAngleBonus(angle:number)
	return smoothstep(angle, RAD_40, RAD_140)
end

local function calcAcuteAngleBonus(angle:number)
	return smoothstep(angle, RAD_140, RAD_40)
end

-- Inlined the calc...Bonus functions as they were simple wrappers.
-- The direct calls to smoothstep are just as clear with named angle constants.

-- The main evaluation function
local function getAimDiff(CrrObj: preprocessing.ObjectData)
	-- Guard clauses for objects that don't contribute to aim strain
	if CrrObj.isSpinner or CrrObj.objID < 3 then
		return 0
	end

	-- Fetch all previous objects ONCE
	local PrevObj = CrrObj.Previous(1)
	if not PrevObj or PrevObj.isSpinner then
		return 0
	end

	local PrevPrevObj = CrrObj.Previous(2)
	local Prev2Obj = CrrObj.Previous(3)

	-- Cache frequently accessed properties into local variables
	local crrStrainTime = CrrObj.StrainTime
	local prevStrainTime = PrevObj.StrainTime
	local crrJumpDist = CrrObj.LazyJumpDistance
	local prevJumpDist = PrevObj.LazyJumpDistance

	-- Calculate base velocities
	local crrVelocity = (crrJumpDist and crrStrainTime > 0) and (crrJumpDist / crrStrainTime) or 0
	if PrevObj.isSlider then
		local travelVelocity = PrevObj.BaseTravelDistance / PrevObj.BaseTravelTime
		local movementVelocity = CrrObj.MinimumJumpDistance / CrrObj.MinimumJumpTime
		crrVelocity = math.max(crrVelocity, travelVelocity + movementVelocity)
	end

	local prevVelocity = (prevJumpDist and prevStrainTime > 0) and (prevJumpDist / prevStrainTime) or 0
	if PrevPrevObj and PrevPrevObj.isSlider then
		local travelVelocity = PrevPrevObj.BaseTravelDistance / PrevPrevObj.BaseTravelTime
		local movementVelocity = PrevObj.MinimumJumpDistance / PrevObj.MinimumJumpTime
		prevVelocity = math.max(prevVelocity, travelVelocity + movementVelocity)
	end

	-- Initialize bonus values
	local wideAngleBonus = 0
	local acuteAngleBonus = 0
	local velocityChangeBonus = 0
	local wiggleBonus = 0
	local sliderBonus = 0
	local baseAimStrain = crrVelocity

	-- Angle-based bonuses
	if CrrObj.Angle and PrevObj.Angle then
		local crrAngle = CrrObj.Angle
		local lastAngle = PrevObj.Angle
		local angleBonus = math.min(crrVelocity, prevVelocity)

		-- Acute Angle Bonus
		if prevStrainTime and math.max(crrStrainTime, prevStrainTime) < 1.25 * math.min(crrStrainTime, prevStrainTime) then
			local acuteBonusFactor = calcAcuteAngleBonus(crrAngle)
			local lastAcuteBonusFactor = calcAcuteAngleBonus(lastAngle)

			acuteAngleBonus = acuteBonusFactor
			acuteAngleBonus *= 0.08 + 0.92 * (1 - math.min(acuteAngleBonus, lastAcuteBonusFactor ^ 3))
			acuteAngleBonus *= angleBonus *
								smootherstep(Evaluator.milisecondToBPM(crrStrainTime, 2), 300, 400) *
								smootherstep(crrJumpDist, NORMALIZED_DIAMETER, NORMALIZED_DIAMETER * 2)
		end

		-- Wide Angle Bonus
		local wideBonusFactor = calcWideAngleBonus(crrAngle)
		local lastWideBonusFactor = calcWideAngleBonus(lastAngle)

		wideAngleBonus = wideBonusFactor
		wideAngleBonus *= 1 - math.min(wideAngleBonus, lastWideBonusFactor ^ 3)
		wideAngleBonus *= angleBonus * smootherstep(crrJumpDist, 0, NORMALIZED_DIAMETER)

		if Prev2Obj and Prev2Obj.CirclePosition then
			local distance = (Prev2Obj.CirclePosition - PrevObj.CirclePosition).Magnitude
			if distance < 1 then
				wideAngleBonus *= 1 - 0.35 * (1 - distance)
			end
		end

		-- Wiggle Bonus (broken down for readability)
		local crrWiggleJumpFactor = smootherstep(crrJumpDist, NORMALIZED_RADIUS, NORMALIZED_DIAMETER)
			* Evaluator.ReverseLerp(crrJumpDist, NORMALIZED_DIAMETER * 3, NORMALIZED_DIAMETER) ^ 1.8		
		local crrWiggleAngleFactor = smootherstep(crrAngle, RAD_110, RAD_60)
		local prevWiggleJumpFactor = smootherstep(prevJumpDist, NORMALIZED_RADIUS, NORMALIZED_DIAMETER)
			* Evaluator.ReverseLerp(prevJumpDist, NORMALIZED_DIAMETER * 3, NORMALIZED_DIAMETER) ^ 1.8
		local prevWiggleAngleFactor = smootherstep(lastAngle, RAD_110, RAD_60)

		wiggleBonus = angleBonus * crrWiggleJumpFactor * crrWiggleAngleFactor * prevWiggleJumpFactor * prevWiggleAngleFactor
	end

	-- Velocity Change Bonus
	if math.max(prevVelocity, crrVelocity) > 0 then
		-- Re-calculate velocity including slider travel distance
		local fullPrevVelocity = (prevJumpDist + (PrevPrevObj and PrevPrevObj.BaseTravelDistance or 0)) / prevStrainTime
		local fullCrrVelocity = (crrJumpDist + (PrevObj.BaseTravelDistance or 0)) / crrStrainTime

		local deltaV = math.abs(fullPrevVelocity - fullCrrVelocity)
		local maxV = math.max(fullPrevVelocity, fullCrrVelocity)
		local minTime = math.min(crrStrainTime, prevStrainTime)

		if maxV > 0 and minTime > 0 then
			local distanceRatio = smoothstep(deltaV / maxV, 0, 1)
			local overlapVelocityBuff = math.min((NORMALIZED_DIAMETER * 1.25) / minTime, deltaV)

			velocityChangeBonus = overlapVelocityBuff * distanceRatio
			velocityChangeBonus *= (minTime / math.max(crrStrainTime, prevStrainTime)) ^ 2
		end
	end

	-- Slider Bonus
	if PrevObj.isSlider then
		sliderBonus = PrevObj.BaseTravelDistance / PrevObj.BaseTravelTime
	end

	-- Final Strain Calculation
	baseAimStrain += wiggleBonus * WIGGLE_MULTIPLIER
	baseAimStrain += velocityChangeBonus * VELOCITY_CHANGE_MULTIPLIER
	baseAimStrain += math.max(acuteAngleBonus * ACUTE_ANGLE_MULTIPLIER, wideAngleBonus * WIDE_ANGLE_MULTIPLIER)
	baseAimStrain *= CrrObj.SmallCircleBonus
	baseAimStrain += sliderBonus * SLIDER_MULTIPLIER

	return baseAimStrain
end

-- Expose the public function
local aimEvaluator = {
	GetAimDiff = getAimDiff,
	-- The helper functions are kept private (local) but can be exposed here if needed elsewhere
	-- Smootherstep = smootherstep, 
	-- Smoothstep = smoothstep,
}

return aimEvaluator
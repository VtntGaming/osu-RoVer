--[LOCATION]:[Workspace.DifficultyCalculator.DifficultyEvaluator.SpeedEvaluator]
local Evaluator = require(script.Parent)
local Preprocessing = require(workspace.DifficultyCalculator.DifficultyHitObjects)

-- Localize for faster access
local math = math

--[[
	CONSTANTS
	Defined once at the script level to avoid re-declaration in a high-frequency function.
]]
local SINGLE_SPACING_THRESHOLD = 125
local MIN_SPEED_BONUS_BPM = 200 -- The BPM threshold to start receiving a speed bonus
local SPEED_BALANCING_FACTOR = 40
local DISTANCE_MULTIPLIER = 0.8
local DISTANCE_EXPONENT = 3.95
local SPEED_BONUS_MULTIPLIER = 0.75

-- Timing window adjustment factors
local TIME_ADJUST_DIVISOR = 0.93
local MIN_TIME_ADJUST_CLAMP = 0.92
local MAX_TIME_ADJUST_CLAMP = 1.0

-- Pre-calculate the result of a constant expression.
-- This avoids calling BPMToMilisecond thousands of times with the same input.
local MIN_STRAIN_TIME_FOR_BONUS = Evaluator.BPMToMilisecond(MIN_SPEED_BONUS_BPM)

-- The main evaluation function, now declared as local
local function getSpeedDiff(CrrObj: Preprocessing.ObjectData)
	if CrrObj.isSpinner then
		return 0
	end

	local prevObj = CrrObj.Previous(1)
	if not prevObj or prevObj.isSpinner then
		return 0
	end

	local nextObj = CrrObj.Next(1)

	-- Cache property access
	local strainTime = CrrObj.StrainTime

	-- Adjust Strain Time based on the object's timing window (OD)
	local timeAdjustment = (strainTime / CrrObj.Hit300Value) / TIME_ADJUST_DIVISOR
	strainTime /= math.clamp(timeAdjustment, MIN_TIME_ADJUST_CLAMP, MAX_TIME_ADJUST_CLAMP)

	-- Calculate Speed Bonus for high BPM sections
	local speedBonus = 0
	if strainTime < MIN_STRAIN_TIME_FOR_BONUS then -- Comparing ms is faster than converting to BPM
		local bonusFactor = (MIN_STRAIN_TIME_FOR_BONUS - strainTime) / SPEED_BALANCING_FACTOR
		speedBonus = SPEED_BONUS_MULTIPLIER * (bonusFactor ^ 2)
	end

	-- Calculate Distance Bonus
	local travelDistance = prevObj.BaseTravelDistance or 0
	local totalDistance = travelDistance + CrrObj.MinimumJumpDistance

	-- Scale the bonus based on how close the distance is to the threshold
	local clampedDistance = math.min(SINGLE_SPACING_THRESHOLD, totalDistance)
	local distanceBonus = math.pow(clampedDistance / SINGLE_SPACING_THRESHOLD, DISTANCE_EXPONENT)
	distanceBonus *= DISTANCE_MULTIPLIER

	-- Apply a small bonus for smaller circle sizes
	distanceBonus *= math.sqrt(CrrObj.SmallCircleBonus)

	local doubletapness = math.max(0, 1 - (CrrObj.getDoubletapness(nextObj)))

	local speedDiff = ((1 + speedBonus + distanceBonus) * 1000 / strainTime) * doubletapness

	return speedDiff
end

-- Expose the public function while keeping the implementation local
local speedEvaluator = {
	GetSpeedDiff = getSpeedDiff
}

return speedEvaluator
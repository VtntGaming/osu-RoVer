--[LOCATION]:[Workspace.DifficultyCalculator.DifficultyEvaluator.SpeedEvaluator]
local workspace = game:GetService("Workspace")
local Evaluator = require(script.Parent)
local Preprocessing = require(workspace.DifficultyCalculator.DifficultyHitObjects)

-- Localize for faster access
local math = math

local function getHighBPMBonus(ms: number)
	return 1 / (1 - math.pow(0.3, ms/1000))
end

--[[
	CONSTANTS
	Defined once at the script level to avoid re-declaration in a high-frequency function.
]]
local MIN_SPEED_BONUS_BPM = 200 -- The BPM threshold to start receiving a speed bonus
local SPEED_BALANCING_FACTOR = 40
local SPEED_BONUS_MULTIPLIER = 0.75

-- Pre-calculate the result of a constant expression.
-- This avoids calling BPMToMilisecond thousands of times with the same input.
local MIN_STRAIN_TIME_FOR_BONUS = Evaluator.BPMToMilisecond(MIN_SPEED_BONUS_BPM)

-- The main evaluation function, now declared as local
local function getSpeedDiff(CrrObj: Preprocessing.ObjectData)
	if CrrObj.isSpinner or CrrObj.objID < 3 then
		return 0
	end
	local nextObj = CrrObj.Next(1)

	-- Cache property access
	local strainTime = CrrObj.StrainTime

	-- Adjust Strain Time based on the object's timing window (OD)
	local timeAdjustment = (strainTime / CrrObj.Hit300Value) / 0.93
	strainTime /= math.clamp(timeAdjustment, 0.92, 1)

	-- Calculate Speed Bonus for high BPM sections
	local speedBonus = 0
	if strainTime < MIN_STRAIN_TIME_FOR_BONUS then -- Comparing ms is faster than converting to BPM
		local bonusFactor = (MIN_STRAIN_TIME_FOR_BONUS - strainTime) / SPEED_BALANCING_FACTOR
		speedBonus = SPEED_BONUS_MULTIPLIER * (bonusFactor ^ 2)
	end


	local doubletapness = math.max(0, 1 - (CrrObj.getDoubletapness(nextObj)))

	local speedDiff = ((1 + speedBonus) * 1000 / strainTime) * doubletapness

	speedDiff *= getHighBPMBonus(CrrObj.StrainTime)

	return speedDiff
end

-- Expose the public function while keeping the implementation local
local speedEvaluator = {
	GetSpeedDiff = getSpeedDiff
}

return speedEvaluator
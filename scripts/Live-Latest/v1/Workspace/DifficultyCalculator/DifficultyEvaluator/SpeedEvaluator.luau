--[LOCATION]:[Workspace.DifficultyCalculator.DifficultyEvaluator.SpeedEvaluator]
local workspace = game:GetService("Workspace")
local DifficultyCalculationUtils = require(script.Parent.DifficultyCalculationUtils)
local Preprocessing = require(workspace.DifficultyCalculator.DifficultyHitObjects)

-- Localize for faster access
local math = math

local function getHighBPMBonus(ms: number)
	return 1 / (1 - math.pow(0.3, ms/1000))
end

local MIN_SPEED_BONUS_BPM = 200 -- The BPM threshold to start receiving a speed bonus
local SPEED_BALANCING_FACTOR = 40

-- The main evaluation function, now declared as local
local function getSpeedDiff(CrrObj: Preprocessing.ObjectData)
	if CrrObj.isSpinner or CrrObj.objID < 3 then
		return 0
	end
	local nextObj = CrrObj.Next(1)

	local strainTime = CrrObj.AdjustedDeltaTime
	local doubletapness = math.max(0, 1 - (CrrObj.getDoubletapness(nextObj)))

	-- Adjust Strain Time based on the object's timing window (OD)
	local timeAdjustment = (strainTime / CrrObj.Hit300Value) / 0.93
	strainTime /= math.clamp(timeAdjustment, 0.92, 1)

	-- Calculate Speed Bonus for high BPM sections
	local speedBonus = 0

	if DifficultyCalculationUtils.MillisecondsToBPM(strainTime) > MIN_SPEED_BONUS_BPM then
		speedBonus = 0.75 * math.pow((DifficultyCalculationUtils.BPMToMilliseconds(MIN_SPEED_BONUS_BPM) - strainTime) / SPEED_BALANCING_FACTOR, 2)
	end
	local speedDiff = ((1 + speedBonus) * 1000 / strainTime)

	speedDiff *= getHighBPMBonus(CrrObj.AdjustedDeltaTime)

	return speedDiff * doubletapness
end

-- Expose the public function while keeping the implementation local
local speedEvaluator = {
	GetSpeedDiff = getSpeedDiff
}

return speedEvaluator
local Evaluator = require(script.Parent)
local Preprocessing = require(workspace.DifficultyCalculator.DifficultyHitObjects)
local speedEvaluator = {}

function speedEvaluator.GetSpeedDiff(CrrObj:Preprocessing.ObjectData)
	if CrrObj.isSpinner then
		return 0
	end

	local prevObj = CrrObj.Previous(1)
	local nextObj = CrrObj.Next(1)

	if not prevObj or prevObj.isSpinner then
		return 0
	end
	local single_spacing_threshold = 125
	local min_speed_bonus = 200
	local speed_balancing_factor = 40
	local distance_multiplier = 0.8

	local strainTime = CrrObj.StrainTime
	local doubletapness = math.max(0, 1 - (CrrObj.getDoubletapness(nextObj)))

	strainTime /= math.clamp((strainTime/CrrObj.Hit300Value)/ 0.93, 0.92, 1)

	local speedBonus = 0

	if (Evaluator.milisecondToBPM(strainTime) > min_speed_bonus) then
		speedBonus = 0.75 * math.pow((Evaluator.BPMToMilisecond(min_speed_bonus) - strainTime)/speed_balancing_factor , 2)
	end

	local travelDistance = (prevObj and prevObj.BaseTravelDistance) or 0
	local distance = travelDistance + CrrObj.MinimumJumpDistance
	distance = math.min(single_spacing_threshold, distance)
	local distanceBonus = math.pow(distance/single_spacing_threshold, 3.95) * distance_multiplier
	
	distanceBonus *= math.sqrt(CrrObj.SmallCircleBonus)

	local SpeedDiff = ((1 + speedBonus + distanceBonus) * 1000 / strainTime) * doubletapness
	return SpeedDiff
end

return speedEvaluator
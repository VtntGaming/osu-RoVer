local Evaculator = require(script.Parent)
local Preprocessing = require(workspace.DifficultyCalculator.Preprocessing)
local speedEvaculator = {}

function speedEvaculator.GetSpeedDiff(CrrObj:Preprocessing.ObjectData)
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

	if (Evaculator.milisecondToBPM(strainTime) > min_speed_bonus) then
		speedBonus = 0.75 * math.pow((Evaculator.BPMToMilisecond(min_speed_bonus) - strainTime)/speed_balancing_factor , 2)
	end

	-- this feature is related to the slider category
	-- and we will pretent all map does not have slider...
	-- probably avaiable in uhh.. V1.48?
	local travelDistance = (prevObj and prevObj.BaseTravelDistance) or 0
	travelDistance += CrrObj.MinimumJumpDistance
	local distance = math.min(single_spacing_threshold, travelDistance)
	local distanceBonus = math.pow(distance/single_spacing_threshold, 3.95) * distance_multiplier
	
	distanceBonus *= math.sqrt(CrrObj.SmallCircleBonus)

	local SpeedDiff = ((1 + speedBonus + distanceBonus) * 1000 / strainTime) * doubletapness
	return SpeedDiff
end

return speedEvaculator
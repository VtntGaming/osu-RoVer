local workspace = game:GetService("Workspace")
local Preprocessing = require(workspace.DifficultyCalculator.DifficultyHitObjects)

local SpeedAimEvaluator = {}

local SINGLE_SPACING_THRESHOLD = 125
local function getHighBPMBonus(ms: number)
	return 1 / (1 - math.pow(0.3, ms/1000))
end

function SpeedAimEvaluator.GetSpeedAimDiff(CrrObj: Preprocessing.ObjectData)
    if CrrObj.isSpinner or CrrObj.objID <= 2 then
		return 0
	end
    local prevObj = CrrObj.Previous(1)
    
    if not prevObj or prevObj.isSpinner then
		return 0
	end
    local travelDistance = prevObj.BaseTravelDistance or 0
    local distance = travelDistance + CrrObj.LazyJumpDistance

    distance = math.min(distance, SINGLE_SPACING_THRESHOLD)

    local distanceBonus = math.pow(distance/SINGLE_SPACING_THRESHOLD, 3.95)

    distanceBonus *= math.sqrt(CrrObj.SmallCircleBonus)

    local strain = distanceBonus * 1000 / CrrObj.StrainTime

    strain *= getHighBPMBonus(CrrObj.StrainTime)

    return strain
end

return SpeedAimEvaluator
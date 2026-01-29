local workspace = game:GetService("Workspace")
local Preprocessing = require(workspace.DifficultyCalculator.DifficultyHitObjects)

local SpeedAimEvaluator = {}

-- Cache math functions
local math_min = math.min
local math_pow = math.pow
local math_sqrt = math.sqrt

local SINGLE_SPACING_THRESHOLD = 125
local INV_SINGLE_SPACING = 1 / SINGLE_SPACING_THRESHOLD

local function getHighBPMBonus(ms: number)
	return 1 / (1 - math_pow(0.3, ms/1000))
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

    distance = math_min(distance, SINGLE_SPACING_THRESHOLD)

    local distanceBonus = math_pow(distance * INV_SINGLE_SPACING, 3.95)

    distanceBonus *= math_sqrt(CrrObj.SmallCircleBonus)

    local strainTime = CrrObj.StrainTime
    local strain = distanceBonus * 1000 / strainTime

    strain *= getHighBPMBonus(strainTime)

    return strain
end

return SpeedAimEvaluator
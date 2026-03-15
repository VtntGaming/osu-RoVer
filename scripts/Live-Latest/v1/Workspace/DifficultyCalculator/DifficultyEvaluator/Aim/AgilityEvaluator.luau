--!strict
local Workspace = game:GetService("Workspace")

local DifficultyCalculationUtils = require(Workspace.DifficultyCalculator.DifficultyEvaluator.DifficultyCalculationUtils)
local DifficultyHitObjects = require(Workspace.DifficultyCalculator.DifficultyHitObjects)
local AgilityEvaluator = {}

local NOMALISED_DIAMETER = 50
local DISTANCE_CAP = NOMALISED_DIAMETER * 1.25

type ObjectData = DifficultyHitObjects.ObjectData

local function GetHighBPMBonus(ms: number): number
	return 1 / (1 - math.pow(0.3, math.pow(ms / 1000, 0.9)))
end

function AgilityEvaluator.GetAimAgilityDiff(currentObject: ObjectData): number
	if currentObject.isSpinner then
		return 0
	end

	local lastObject: ObjectData? = currentObject.Previous(1)

	local travelDistance = lastObject and lastObject.lazyTravelDistance or 0
	local distance = travelDistance + currentObject.LazyJumpDistance

	local distanceScaled = math.min(distance, DISTANCE_CAP) / DISTANCE_CAP
	local strain = distanceScaled * 1000 / currentObject.AdjustedDeltaTime

	strain *= GetHighBPMBonus(currentObject.AdjustedDeltaTime)

	return strain * DifficultyCalculationUtils.Smootherstep(distance, 0, NOMALISED_DIAMETER)
end

return AgilityEvaluator
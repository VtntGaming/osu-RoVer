--!strict
local Workspace = game:GetService("Workspace")

local DifficultyHitObjects = require(Workspace.DifficultyCalculator.DifficultyHitObjects)
local AgilityEvaluator = {}

local NOMALISED_DIAMETER = DifficultyHitObjects.NORMALISED_DIAMETER
local DISTANCE_CAP = NOMALISED_DIAMETER * 1.2

type ObjectData = DifficultyHitObjects.ObjectData

local function GetHighBPMBonus(ms: number): number
	return 1 / (1 - math.pow(0.2, ms / 1000))
end

function AgilityEvaluator.GetAimAgilityDiff(currentObject: ObjectData): number
	if currentObject.isSpinner then
		return 0
	end

	local lastObject: ObjectData? = currentObject.Previous(1)

	local travelDistance = lastObject and lastObject.LazyTravelDistance or 0
	local distance = travelDistance + currentObject.LazyJumpDistance

	local distanceScaled = math.min(distance, DISTANCE_CAP) / DISTANCE_CAP

	local agilityDifficulty = distanceScaled * 1000 / currentObject.AdjustedDeltaTime
	if currentObject.SmallCircleBonus then
		agilityDifficulty *= math.pow(currentObject.SmallCircleBonus, 1.5)		
	end

	agilityDifficulty *= GetHighBPMBonus(currentObject.AdjustedDeltaTime)

	return agilityDifficulty
end

return AgilityEvaluator
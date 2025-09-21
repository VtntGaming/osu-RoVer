--[LOCATION]:[Workspace.DifficultyCalculator.DifficultyEvaluator.RhythmCalculator]
local DifficultyCalculationUtils = require(script.Parent.DifficultyCalculationUtils)

-- Localize for performance
local math = math

--[[
	CONSTANTS
	Defined at the script level to avoid re-declaration.
]]
local HISTORY_TIME_MAX = 5000 -- ms
local HISTORY_OBJ_MAX = 32
local RHYTHM_OVERALL_MULTIPLIER = 1
local RHYTHM_RATIO_MULTIPLIER = 15
local MIN_DELTA_TIME = 25

--[[
	HELPER FUNCTIONS
]]
local function logistic(x, midpointOffset, multiplier, maxValue)
	return (maxValue or 1) / (1 + math.exp(multiplier * (midpointOffset - x)))
end

--[[
	ISLAND "CLASS"
	Defined once using a metatable for extreme efficiency.
]]
local Island = {}
Island.__index = Island

function Island.new(delta, epsilon)
	local newIsland = {
		deltaDifferenceEpsilon = epsilon,
		delta = delta and math.max(delta, MIN_DELTA_TIME) or 9999999999999,
		count = 1,
		deltaCount = delta and 1 or 0,
	}
	return setmetatable(newIsland, Island)
end

function Island:addDelta(delta)
	if self.delta == 9999999999999 then
		self.delta = math.max(delta, MIN_DELTA_TIME)
	end
	self.deltaCount += 1
end

function Island:isSimilarPolarity(otherIsland)
	return self.deltaCount % 2 == otherIsland.deltaCount % 2
end

function Island:getKey()
	local roundedDelta = math.floor(self.delta / self.deltaDifferenceEpsilon + 0.5)
	return roundedDelta .. ":" .. self.deltaCount
end


--[[
	MAIN RHYTHM CALCULATION
]]
local rhythmCalculator = {}

local function getHistory(CrrObj)
	local history = {}
	local historicalNoteCount = math.min(CrrObj.objID - 1, HISTORY_OBJ_MAX)
	local historyStart = 0

	while historyStart < historicalNoteCount - 2 and (CrrObj.Time - CrrObj.Previous(historyStart).Time) < HISTORY_TIME_MAX do
		historyStart += 1
	end

	for i = historyStart, 0, -1 do
		table.insert(history, CrrObj.Previous(i))
	end
	return history
end

function rhythmCalculator.GetRhythmDiff(CrrObj)
	if CrrObj.isSpinner or not CrrObj.Hit300Value then
		return 0
	end

	local history = getHistory(CrrObj)
	if #history < 3 then
		return 0
	end

	local rhythmComplexitySum = 0
	local deltaDifferenceEpsilon = CrrObj.Hit300Value * 0.3

	local islandMap = {}
	local currentIsland = Island.new(nil, deltaDifferenceEpsilon)
	local prevIsland = Island.new(nil, deltaDifferenceEpsilon)
	local startRatio = 0
	local firstDeltaSwitch = false

	-- Loop through the pre-fetched history
	-- CORRECTED LOOP: Starts at #history and ends at 3 to prevent indexing history[0].
	for i = #history, 3, -1 do
		local currentObj = history[i]   -- Newest object in the triplet
		local prevObj = history[i-1]    -- Middle object
		local lastObj = history[i-2]    -- Oldest object in the triplet

		-- Decay
		local timeDecay = (HISTORY_TIME_MAX - (CrrObj.Time - currentObj.Time)) / HISTORY_TIME_MAX
		local noteDecay = (i - 1) / (#history - 1)
		local historicalDecay = math.min(noteDecay, timeDecay)

		-- Deltas
		local currDelta = currentObj.StrainTime
		local prevDelta = prevObj.StrainTime
		local lastDelta = lastObj.StrainTime

		local deltaRatio = math.max(prevDelta, currDelta) / math.min(prevDelta, currDelta)
		local currRatio = 1 + RHYTHM_RATIO_MULTIPLIER * math.min(0.5, DifficultyCalculationUtils.SmoothstepBellCurve(deltaRatio - math.floor(deltaRatio)))

		local differenceMultiplier = math.clamp(2 - deltaRatio / 8, 0, 1)
		local windowPenalty = math.min(1, math.max(0, math.abs(prevDelta - currDelta) - deltaDifferenceEpsilon) / deltaDifferenceEpsilon)
		local effectiveRatio = windowPenalty * currRatio * differenceMultiplier

		if firstDeltaSwitch then
			if math.abs(prevDelta - currDelta) < deltaDifferenceEpsilon then
				currentIsland:addDelta(currDelta)
			else
				local penalty = 1.0
				if currentObj.isSlider then penalty *= 0.125 end
				if prevObj.isSlider then penalty *= 0.3 end
				if currentIsland:isSimilarPolarity(prevIsland) then penalty *= 0.5 end
				if lastDelta > prevDelta + deltaDifferenceEpsilon and prevDelta > currDelta + deltaDifferenceEpsilon then penalty *= 0.125 end
				if prevIsland.deltaCount == currentIsland.deltaCount then penalty *= 0.5 end

				local islandKey = currentIsland:getKey()
				local islandData = islandMap[islandKey]
				if islandData then
					local power = logistic(currentIsland.delta, 58.33, 0.24, 2.75)
					penalty *= math.min(3.0 / islandData.count, (1.0 / islandData.count) ^ power)
					islandData.count += 1
				else
					islandMap[islandKey] = { count = 1 }
				end

				local doubletapness = prevObj.getDoubletapness(currentObj)
				penalty *= 1 - doubletapness * 0.75

				rhythmComplexitySum += math.sqrt(effectiveRatio * penalty * startRatio) * historicalDecay

				startRatio = effectiveRatio
				prevIsland = currentIsland

				if prevDelta + deltaDifferenceEpsilon < currDelta then
					firstDeltaSwitch = false
				end

				currentIsland = Island.new(currDelta, deltaDifferenceEpsilon)
			end
		elseif prevDelta > currDelta + deltaDifferenceEpsilon then
			firstDeltaSwitch = true
			local penalty = 1.0
			if currentObj.isSlider then penalty *= 0.6 end
			if prevObj.isSlider then penalty *= 0.6 end
			startRatio = effectiveRatio * penalty
			currentIsland = Island.new(currDelta, deltaDifferenceEpsilon)
		end
	end

	local rhythmDiff = math.sqrt(4 + rhythmComplexitySum * RHYTHM_OVERALL_MULTIPLIER) / 2.0
	rhythmDiff *= (1 - CrrObj.getDoubletapness(CrrObj.Next(1)))

	return rhythmDiff
end

return rhythmCalculator
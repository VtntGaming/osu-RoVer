--[LOCATION]:[Workspace.DifficultyCalculator.DifficultyEvaluator.RhythmCalculator]
local rhythmCalculator = {}

local function getIslandCount(islandList, currentIsland)
	for i, island in pairs(islandList) do
		if island:IsEqual(currentIsland) then
			return i-1, island
		end
	end
	return nil
end

local function Logistic(x, midpointOffset, multiplier, maxValue)
	if not maxValue then maxValue = 1 end

	return maxValue / (1 + math.exp(multiplier * (midpointOffset - x)))
end

local function smoothstep(x: number, _start: number, _end: number)
	x = math.clamp((x - _start) / (_end - _start), 0, 1)
	return x * x * (3 - 2 * x)
end

local function smoothstepBellCurve(x: number, mean: number?, width: number?) : number
	mean = mean or 0.5
	width = width or 0.5
	
	if mean and width then
		x -= mean
		x = (x > 0) and (width - x) or (width + x)

		
		return smoothstep(x, 0, width)
	end

	return 0
end

local function mathTruncate(x: number):number
	if x >= 0 then
		return math.floor(x)
	else
		return math.ceil(x)
	end
end


local MIN_DELTA_TIME = 25
local EXTRA_MULTIPLIER = 1	-- This being added to ensure stability, until I found out a better way to calculate properly

function rhythmCalculator.GetRhythmDiff(CrrObj)
	-- This is the most complicate section I ever transfer

	local history_time_max = 5000 -- ms
	local history_obj_max = 32
	local rhythm_overall_multiplier = 1.00
	local rhythm_ratio_multiplier = 15

	local function newIsland(delta, epsilon) -- Initiate Island class
		local island = {
			deltaDifferenceEpsilon = epsilon,
			delta = 9999999999999, -- maximum value possible
			Count = 1,
			deltaCount = 0
		}

		if delta then
			island.delta = math.max(delta, MIN_DELTA_TIME)
			island.deltaCount += 1
		end

		function island:AddDelta(delta)
			if self.delta == 9999999999999 then
				self.delta = math.max(delta, MIN_DELTA_TIME)
			end
			self.deltaCount += 1
		end

		function island:IsSimilarPolarity(otherDelta)
			return self.deltaCount % 2 == otherDelta.deltaCount % 2
		end

		function island:IsEqual(otherDelta)
			if not otherDelta then return false	end

			return math.abs(self.delta - otherDelta.delta) < self.deltaDifferenceEpsilon and self.deltaCount == otherDelta.deltaCount
		end

		return island
	end

	if CrrObj.isSpinner or not CrrObj.Hit300Value then
		return 0
	end

	local rhythmComplexitySum = 0
	local deltaDifferenceEpsilon = CrrObj.Hit300Value * 0.3

	local Island = newIsland(nil, deltaDifferenceEpsilon)
	local PrevIsland = newIsland(nil, deltaDifferenceEpsilon)
	local IslandList = {}

	local startRatio = 0
	local firstDeltaSwitch = false
	local historicalNoteCount = math.min(CrrObj.objID - 1, history_obj_max)
	local rhythmStart = 0

	while rhythmStart < historicalNoteCount - 2 and CrrObj.Time - CrrObj.Previous(rhythmStart).Time < history_time_max do
		rhythmStart += 1
	end

	local PrevObj = CrrObj.Previous(rhythmStart)
	local LastObj = CrrObj.Previous(rhythmStart + 1)

	for i = rhythmStart, 1, -1 do
		local currentObj = CrrObj.Previous(i)
		local timeDecay = (history_time_max - (CrrObj.Time - currentObj.Time)) / history_time_max
		local noteDecay = (historicalNoteCount - i) / historicalNoteCount

		local currHistoricalDecay = math.min(noteDecay, timeDecay)
		local currDelta = math.max(currentObj.DeltaTime, 1e-7)
		local prevDelta = math.max(PrevObj.DeltaTime, 1e-7)
		local lastDelta = math.max(LastObj.DeltaTime, 1e-7)

		local deltaDifference = math.max(prevDelta, currDelta) / math.min(prevDelta, currDelta)
		local deltaDifferenceFraction = deltaDifference - mathTruncate(deltaDifference)

		local currRatio = 1.0 + rhythm_ratio_multiplier * math.min(0.5, smoothstepBellCurve(deltaDifferenceFraction))

		local differenceMultiplier = math.clamp(2 - deltaDifference / 8, 0, 1)

		local windowPenalty = math.min(1, math.max(0, math.abs(prevDelta - currDelta) - deltaDifferenceEpsilon) / deltaDifferenceEpsilon)
		local effectiveRatio = windowPenalty * currRatio * differenceMultiplier

		if firstDeltaSwitch then
			if math.abs(prevDelta - currDelta) < deltaDifferenceEpsilon then
				Island:AddDelta(currDelta)
			else
				if currentObj.isSlider then
					effectiveRatio *= 0.125
				end

				if PrevObj.isSlider then
					effectiveRatio *= 0.3
				end
				
				if Island:IsSimilarPolarity(PrevIsland) then
					effectiveRatio *= 0.5
				end

				if (lastDelta > prevDelta + deltaDifferenceEpsilon) and (prevDelta > currDelta + deltaDifferenceEpsilon) then
					effectiveRatio *= 0.125
				end

				if PrevIsland.DeltaCount == Island.DeltaCount then
					effectiveRatio *= 0.5
				end

				local countIndex , islandCount = getIslandCount(IslandList, Island)
				if islandCount then
					if PrevIsland:IsEqual(Island) then
						islandCount.Count += 1
					end

					local power = Logistic(Island.delta, 58.33, 0.24, 2.75)
					effectiveRatio *= math.min(3.0 / islandCount.Count, math.pow(1.0 / islandCount.Count, power))

					IslandList[countIndex+1] = islandCount
				else
					IslandList[#IslandList+1] = Island
				end

				local doubletapness = PrevObj.getDoubletapness(currentObj)
				effectiveRatio *= 1 - doubletapness * 0.75

				rhythmComplexitySum += math.sqrt(effectiveRatio * startRatio) * currHistoricalDecay
				startRatio = effectiveRatio
				PrevIsland = Island

				if prevDelta + deltaDifferenceEpsilon < currDelta then
					-- the beat is slowed down, stop counting
					firstDeltaSwitch = false
				end

				Island = newIsland(currDelta, deltaDifferenceEpsilon)
			end
		elseif prevDelta > currDelta + deltaDifferenceEpsilon then -- the beat is speeding up again
			-- start counting
			firstDeltaSwitch = true

			if currentObj.isSlider then
				effectiveRatio *= 0.6
			end

			if PrevObj.isSlider then
				effectiveRatio *= 0.6
			end

			startRatio = effectiveRatio
			Island = newIsland(currDelta, deltaDifferenceEpsilon)
		end
		LastObj = PrevObj
		PrevObj = currentObj
	end

	local diff = math.sqrt(4 + rhythmComplexitySum * rhythm_overall_multiplier) / 2
	local doubletapness = 1 - CrrObj.getDoubletapness(CrrObj.Next(1))

	return diff * doubletapness
end

return rhythmCalculator
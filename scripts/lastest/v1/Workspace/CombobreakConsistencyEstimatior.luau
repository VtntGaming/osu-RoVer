--[LOCATION]:[Workspace.PerformanceCalculator.CombobreakConsistencyEstimatior]
type Attributes = {
	-- Score
	ConsistencyScore: number,
	MaxCombo: number,
	-- Map
	MapMaxCombo: number
}

function getConsistencyScore(combo:number, missCount: number)
	local splitCount = missCount + 1
	local remainsCombo = combo / splitCount
	local score = (remainsCombo * (remainsCombo + 1) / 2) * splitCount
	
	return score
end

function getMissCount(remainsCombo:number, score:number): number
	local denominator = 2 * score - remainsCombo
	if denominator <= 0 then return remainsCombo end

	local k = remainsCombo^2 / denominator
	local missCount = k - 1
	
	if missCount < 0.1 then
		-- just in case they are just missing the tails
		-- 1% combo drop is acceptable
		missCount = 0
	end

	return math.clamp(math.ceil(missCount), 0, remainsCombo)
end

return function(attributes:Attributes):number
	if attributes.MaxCombo >= attributes.MapMaxCombo then
		return 0
	end
	local minimumConsistencyScore = getConsistencyScore(attributes.MaxCombo, 0)
	local remainsConsistencyScore = math.max(attributes.ConsistencyScore - minimumConsistencyScore, 0)
	
	local remainsCombo = attributes.MapMaxCombo - attributes.MaxCombo
	local missCount = getMissCount(remainsCombo, remainsConsistencyScore)
	
	return missCount
end
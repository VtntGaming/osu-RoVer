--[LOCATION]:[StarterGui.PlayScreen.GameplayScripts.Components.Gameplay.RawV1ToV2]
function getScoreMissPenaltyMultiplier(missCount, noteCount)
	-- miss penalty can take up to 25% of the current score
	local penaltyMax = 0.25	
	local penalty = math.min((1 - penaltyMax) + penaltyMax / ((missCount / (4 * math.pow(math.log(noteCount), 0.94))) + 1), (noteCount - missCount)/math.max(1, noteCount))
	return penalty
end

function getAccuracyScore(AccuracyData, NoteCount, MaxCombo)
	-- For SL mod (or will be NM soon), I will add an extra score to catch up the scale to be same with the ConsistencyScore
	local TotalNotes = AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss
	local Accuracy = (AccuracyData.h300*3+AccuracyData.h100*1+AccuracyData.h50*0.5)/(TotalNotes*3)
	-- When the total possible combo (maximum current combo player can get) more than total note of the game
	-- Accuracy score will rise up even more
	local ExtraCombo = MaxCombo-NoteCount
	-- penalty for each miss given
	-- prevent players just "chilling out" and watching the score keep increasing
	local ExtraAccPoint = math.max(0, ExtraCombo * Accuracy - AccuracyData.miss)
	local ScoreAccuracy = Accuracy
	local AccuracyScore = math.pow(ScoreAccuracy * TotalNotes + ExtraAccPoint, 2.265) * 6 * 1 * 0.3

	return AccuracyScore
end

function getMinimumConsistencyScore(PlayerMaxCombo)
	local MinimumScore = PlayerMaxCombo * (PlayerMaxCombo + 1) // 2
	return math.pow(MinimumScore, 1.1704417) * 1.2255 * 6 * 1 * 0.7
end

function getMaximumConsistencyScore(PlayerMaxCombo:number, MapMaxCombo:number):number
	local MinimumScore = getMinimumConsistencyScore(PlayerMaxCombo)
	local RemainsCombo = math.max(0, MapMaxCombo - PlayerMaxCombo) -- Assume player missed all at that section
	local RemainsScore = RemainsCombo * (RemainsCombo + 1) // 2
	return math.max(0, math.pow(RemainsScore, 1.1704417) * 1.2255 * 6 * 0.7) + MinimumScore
end

local EX_RATE = 0.44150110375

function getConsistencyScoreV2(currentConsistencyScore:number, maxConsistencyScore: number, AccuracyData)
	local TotalNotes = AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss
	local Accuracy = (AccuracyData.h300*3+AccuracyData.h100*1+AccuracyData.h50*0.5)/(TotalNotes*3)
	local comboFactor = math.pow(currentConsistencyScore/maxConsistencyScore, EX_RATE)
	return comboFactor * Accuracy * 500000
end

function getAccuracyScoreV2(AccuracyData)
	local TotalNotes = AccuracyData.h300+AccuracyData.h100+AccuracyData.h50+AccuracyData.miss
	local Accuracy = (AccuracyData.h300*3+AccuracyData.h100*1+AccuracyData.h50*0.5)/(TotalNotes*3)
	
	return math.pow(Accuracy, 5) * 500000
end


function getBaseMultiplier(ModData)
	if not ModData then
		return 1	-- Well.. I have no idea for this ¯\_(ツ)_/¯
	end
	local multiplier = 1
	if ModData.NF then
		multiplier *= 0.5
	end
	if ModData.EZ then
		multiplier *= 0.5
	end
	if ModData.HR then
		multiplier *= 1.06
	end
	if ModData.FL then
		multiplier *= 1.12
	end
	
	return multiplier
end

return function(V1Score:number, AccuracyData:{MaxCombo:number,h300:number,h100:number,h50:number,miss:number},  NoteCount:number,MaxCombo:number, MaxAccScore:number, MaxConsistencyScore:number, MaxSpinnerScore:number, ModUsed:{[string]:any}, Speed:number):number
	-- decrease spin score from V1 and increase later in V2
	local SpinScore = math.min(math.floor(V1Score/100)*100, MaxSpinnerScore)
	V1Score -= SpinScore
	Speed = tonumber(ModUsed and ModUsed.SA) or Speed or 1
	local V1SpeedMultiplier = 1
	if Speed < 1 then
		V1SpeedMultiplier = Speed^4.185
	elseif Speed > 1 then
		V1SpeedMultiplier = Speed^0.28
	end
	local V2SpeedMultiplier = 1
	if Speed < 1 then
		V2SpeedMultiplier = 0.1 + ((Speed - 0.5)/0.5)*0.4
	elseif Speed > 1 then
		V2SpeedMultiplier = 1 + (Speed - 1) * 0.2
	end

	local ScoreMultiplier = 1
	if ModUsed then
		ScoreMultiplier = getBaseMultiplier(ModUsed)
		if ModUsed.HC then
			V1Score *= 0.5 -- normalize the score of HC
		end
		if (ModUsed.Version and ModUsed.NS) or (not ModUsed.Version and not ModUsed.SL) then
			MaxCombo = NoteCount -- non-slider -> no bonus max combo
		end
	end	

	-- We assume that the ScoreV1 follows the new score system
	-- So the miss penalty also apply to this
	local MissPenalty = getScoreMissPenaltyMultiplier(AccuracyData.miss, NoteCount)
	V1Score /= MissPenalty
	V1Score /= ScoreMultiplier * V1SpeedMultiplier
	
	local AccuracyScore = getAccuracyScore(AccuracyData, NoteCount, MaxCombo) * MissPenalty
	local MinimumConsistencyScore = math.max(0, getMinimumConsistencyScore(AccuracyData.MaxCombo) * MissPenalty)
	local MaximumConsistencyScore = math.min(getMaximumConsistencyScore(AccuracyData.MaxCombo, MaxCombo), MaxConsistencyScore) * MissPenalty
	MaximumConsistencyScore = math.max(MaximumConsistencyScore, MinimumConsistencyScore)
	local AssumedConsistencyScore = math.max(0, V1Score - AccuracyScore)
	local ConsistencyScore = math.clamp(AssumedConsistencyScore, MinimumConsistencyScore, MaximumConsistencyScore) -- Clamp up the score
	
	local exRate = 0.44150110375
	local AccV2Score = getAccuracyScoreV2(AccuracyData) * MissPenalty
	local ConsistencyV2Score = getConsistencyScoreV2(ConsistencyScore, MaxConsistencyScore, AccuracyData) * MissPenalty
	local ScoreV2 = AccV2Score + ConsistencyV2Score + SpinScore * 0.1
	ScoreV2 *= ScoreMultiplier * V2SpeedMultiplier
	--print(V1Score, AccV2Score, ConsistencyV2Score, SpinScore * 0.1)
	return math.round(ScoreV2)
end
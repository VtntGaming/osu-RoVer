--[LOCATION]:[StarterGui.PlayScreen.GameplayScripts.Components.Gameplay.GetMaxScore]
return function(NoteCount, MaxCombo, DifficulcyMulti, ModMulti)
	DifficulcyMulti = DifficulcyMulti or 6
	ModMulti = ModMulti or 1
	local ExtraCombo = MaxCombo - NoteCount
	local MaxAccuracyScore = math.pow(ExtraCombo + NoteCount,2.265) * DifficulcyMulti * ModMulti * 0.3
	local MaxBaseConsistencyScore = MaxCombo * (MaxCombo + 1) // 2
	local MaxConsistencyScore = math.pow(MaxBaseConsistencyScore, 1.1704417) * 1.2255 * DifficulcyMulti * ModMulti * 0.7
	
	local MaxScore = MaxAccuracyScore + MaxConsistencyScore
	return MaxScore, MaxAccuracyScore, MaxConsistencyScore
end
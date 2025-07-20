-- Credited the osu! team on the github for the difficulty calculator and preprocessing
-- Even though I have to transfer code from C# to lua all by myself
-- The calculator might different compare to the original one

local calculator = {}

function sortStrain(data)
	table.sort(data,function(a,b) return a>b end)
end

function lerp(a,b,r)
	return a + (b-a)*r
end

function calculator.DifficultyValue(StrainData, IsgetRelevantNoteCount, isAim, RhythmDiffData)
	local reducedSelectionCount = 10
	local weight = 1
	local decayWeight = 0.9
	local difficulty = 0
	local ReducedStrainBaseline = 0.75
	
	if RhythmDiffData then -- it's for speed difficulty
		for i, speedStrain in pairs(StrainData) do
			local rhythmDiff = 1
			if RhythmDiffData[i] then
				rhythmDiff = RhythmDiffData[i]
			end
			StrainData[i] = speedStrain * rhythmDiff
		end
	end
	
	sortStrain(StrainData)
	
	for i,a in pairs(StrainData) do
		local scale = math.log10(lerp(1,10,math.clamp((i-1)/reducedSelectionCount,0,1)))
		StrainData[i] *= lerp(ReducedStrainBaseline, 1, scale)
		if i > 10 then
			break
		end
	end

	sortStrain(StrainData)
	for _,strain in pairs(StrainData) do
		if strain <= 0 then break end
		
		difficulty += strain * weight
		weight *= decayWeight
	end
	
	local StrainCount = 0
	local consistentTopStrain = difficulty/10
	local SpeedRelevantNoteCount = 0
	for _,a in pairs(StrainData) do
		StrainCount += 1.1 / (1 + math.exp(-10 * (a / consistentTopStrain - 0.88)))
		if IsgetRelevantNoteCount then
			SpeedRelevantNoteCount += 1 / (1 + math.exp(-(a / StrainData[1] * 12 - 6)))
		end
	end
	
	return difficulty, StrainCount, SpeedRelevantNoteCount
end

function calculator.DifficultyValueFlashlight(StrainData)
	local difficulty = 0
	sortStrain(StrainData)
	for i, strain in pairs(StrainData) do
		if strain <= 0 or i > 400 then break end
		difficulty += strain
	end
	return difficulty
end

return calculator
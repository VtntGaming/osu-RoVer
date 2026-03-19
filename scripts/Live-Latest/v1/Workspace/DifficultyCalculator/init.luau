--[LOCATION]:[Workspace.DifficultyCalculator]
--!strict
-- Credited the osu! team on the github for the difficulty calculator and preprocessing
-- Even though I have to transfer code from C# to lua all by myself
-- The calculator might different compare to the original one

local workspace = game:GetService("Workspace")

local converterTools = require(workspace.OsuConvert.converterTools)
local basePerfomance = require(workspace.PerformanceCalculator.BasePerfomance)
local basePerfomanceFL = require(workspace.PerformanceCalculator.BasePerfomanceFL)
local evaluator = require(script.DifficultyEvaluator)
local StrainSkills = require(script.StrainSkills)
local modData = require(workspace.ModData)

-- Cache math functions for performance
local math_pow = math.pow
local math_max = math.max
local math_min = math.min
local math_sqrt = math.sqrt
local math_log10 = math.log10
local math_exp = math.exp
local math_clamp = math.clamp
local math_lerp = math.lerp
local table_sort = converterTools.TrySort

local perfomance_base_multiplier = 1.12
local difficulty_multiplier = 0.0675
local normalised_expoment = 1.1

local calculator = {}

function sortPeak(data:{number})
	converterTools.TrySort(data,function(a,b) return a>b end)
end

function sortStrain(data:{{number}})
	converterTools.TrySort(data,function(a,b) return a[1]>b[1] end)
end

function lerp(a:number,b:number,r:number)
	return a + (b-a)*r
end

local function Logistic(x: number, midpointOffset: number, multiplier: number, maxValue: number): number
	if not maxValue then maxValue = 1 end

	return maxValue / (1 + math_exp(multiplier * (midpointOffset - x)))
end

local function _DeepCopy(t:{any}):{any}
	local newT = {}
	for index, data in pairs(t) do
		if typeof(data) == "table" then
			newT[index] = _DeepCopy(data)
		else
			newT[index] = data
		end
	end

	return newT
end

type ModData = modData.ModData

function calculator.CalculateDifficultyMultiplier(ModData:ModData):number
	local multiplier = perfomance_base_multiplier
	return multiplier
end

function calculator.DifficultyValue(StrainData:{{number}}, strainType:string)
	local reducedSelectionCount = 10
	local weight = 1
	local decayWeight = 0.9
	local difficulty = 0
	local ReducedStrainBaseline = 0.75
	
	if strainType == "Speed" then
		reducedSelectionCount = 5
	end
	
	table_sort(StrainData, function(a,b)
		return a[2] < b[2]	-- Sort the timing to be perfect
	end)
	
	local StrainPeak = StrainSkills.GetStrainPeak(StrainData, strainType)
	
	sortPeak(StrainPeak)

	for i = 1, #StrainPeak do
		local scale = math_log10(math_lerp(1,10,math_clamp((i-1)/reducedSelectionCount,0,1)))
		StrainPeak[i] *= lerp(ReducedStrainBaseline, 1, scale)
		if i > 10 then
			break
		end
	end

	sortPeak(StrainPeak)

	for i = 1, #StrainPeak do
		local strain = StrainPeak[i]
		if strain <= 0 then break end
		
		difficulty += strain * weight
		weight *= decayWeight
	end
	return difficulty
end

local HarmonicScale = 1
local DecayExponent = 0.9

local SpeedHarmonicScale = 20
local SpeedDecayExponent = 0.85

local READING_REDUCED_DIFFICULTY_BASELINE = 0.0
local READING_REDUCED_DIFFICULTY_DURATION = 60000	-- 1 minute

local function calculateReducedNoteCount(StrainData: {{number}}): number
	local objectCount = #StrainData
	if objectCount == 0 then
		return 0
	end

	local reducedDuration = StrainData[1][2] + READING_REDUCED_DIFFICULTY_DURATION
	local reducedNoteCount = 0

	for i = 1, #StrainData do
		local strain = StrainData[i]

		if strain[2] > reducedDuration then
			break
		end

		reducedNoteCount += 1
	end

	return reducedNoteCount
end

function calculator.ApplyDifficultyTransformation(StrainData: {{number}}, type: string)
	if type == "Reading" then
		local reducedNoteCount = calculateReducedNoteCount(StrainData)

		for i = 1, math.min(#StrainData, reducedNoteCount) do
			local index = i-1
			local scale = math.log10(math_lerp(1, 10, math_clamp(index/reducedNoteCount, 0, 1)))
			StrainData[i][1] *= math_lerp(READING_REDUCED_DIFFICULTY_BASELINE, 1, scale)
		end
	end
end

function calculator.DifficultyValueHarmonic(StrainData: {{number}}, type: string): (number, number)
	local harmonicScale = type == "Speed" and SpeedHarmonicScale or HarmonicScale
	local decayExponent = type == "Speed" and SpeedDecayExponent or DecayExponent
	local objectCount = #StrainData
	if objectCount == 0 then
		return 0, 0
	end

	calculator.ApplyDifficultyTransformation(StrainData, type)

	-- Unlike the normal strain, we get the strains unfiltered
	local difficulty = 0
	local noteWeightSum = 0
	sortStrain(StrainData)

	for index = 1, objectCount do
		local i = index - 1
		local note = StrainData[index][1]

		if note <= 0 then
			break
		end
		local harmonicTerm = harmonicScale / (1 + i)
		local weight = (1 + harmonicTerm) / (math_pow(i, decayExponent) + 1 + harmonicTerm)
		noteWeightSum += weight

		difficulty += note * weight
	end

	return difficulty, noteWeightSum
end

function calculator.FLDifficultyValue(StrainData:{{number}})
	table_sort(StrainData, function(a,b)
		return a[2] < b[2]	-- Sort the timing to be perfect
	end)
	local StrainPeak = StrainSkills.GetStrainPeak(StrainData, "Flashlight")
	
	-- Since flashlight sum all the value so no need to sort
	
	local difficulty = 0
	for i = 1, #StrainPeak do
		difficulty += StrainPeak[i]
	end
	return difficulty
end

function calculator.LiveDifficultyValue(StrainPeak:{number}, strainType:string):number
	local reducedSelectionCount = 10
	local weight = 1
	local decayWeight = 0.9
	local difficulty = 0
	local ReducedStrainBaseline = 0.75
	
	StrainPeak = _DeepCopy(StrainPeak)::{number}
	
	if strainType == "Speed" then
		reducedSelectionCount = 5
	end
	
	sortPeak(StrainPeak)
	
	for i = 1, #StrainPeak do
		local scale = math_log10(lerp(1,10,math_clamp((i-1)/reducedSelectionCount,0,1)))
		StrainPeak[i] *= lerp(ReducedStrainBaseline, 1, scale)
		if i > 10 then
			break
		end
	end

	sortPeak(StrainPeak)
	for i = 1, #StrainPeak do
		local strain = StrainPeak[i]
		if strain <= 0 then break end

		difficulty += strain * weight
		weight *= decayWeight
	end
	return difficulty
end

function calculator.LiveFLDifficultyValue(StrainPeak:{number}):number
	local difficulty = 0

	StrainPeak = _DeepCopy(StrainPeak)::{number}
	
	for i = 1, #StrainPeak do
		local strain = StrainPeak[i]
		difficulty += strain
	end
	return difficulty
end


function calculator.RelevantNoteCount(strainData:{{number}})
	strainData = _DeepCopy(strainData)
	sortStrain(strainData)
	if #strainData == 0 then
		return 0
	end	
	local maxStrain = strainData[1][1]
	if maxStrain == 0 then
		return 0
	end
	
	local relevantNoteCount = 0
	local invMaxStrain = 1 / maxStrain
	for i = 1, #strainData do
		local strain = strainData[i]
		relevantNoteCount += 1 / (1 + math_exp(-(strain[1] * invMaxStrain * 12 - 6)))
	end
	
	return relevantNoteCount
end

function calculator.CountTopWeightedStrains(strainData:{{number}}, strainType:string)
	if #strainData == 0 then
		return 0
	end
	local decayWeight = 0.9
	
	local consistenTopStrain = calculator.DifficultyValue(strainData, strainType) * (1 - decayWeight)
	if consistenTopStrain == 0 then
		return #strainData
	end
	
	local strainCount = 0
	local invConsistentTopStrain = 1 / consistenTopStrain
	for i = 1, #strainData do
		local strain = strainData[i]
		strainCount += 1.1 / (1 + math_exp(-10 * (strain[1] * invConsistentTopStrain - 0.88)))
	end
	
	return strainCount
end

function calculator.CountTopWeightedDifficultyHarmonic(StrainData: {{number}}, difficulty: number, noteWeightSum: number)
	if #StrainData == 0 then
		return 0
	end

	if noteWeightSum == 0 then
		return 0
	end

	local consistentTopNote = difficulty / noteWeightSum

	if consistentTopNote == 0 then
		return 0
	end

	local sum = 0
	for i = 1, #StrainData do
		local strain = StrainData[i][1]

		sum += Logistic(strain / consistentTopNote, 0.88, 10, 1.1)
	end
	return sum
end

function calculator.getDificultSliders(strainData:{{number}})
	if #strainData == 0 then
		return 0
	end
	
	sortStrain(strainData)
	local maxSLStrain = strainData[1][1]
	
	if maxSLStrain == 0 then
		return 0
	end
	
	local strainDiff = 0
	local invMaxSLStrain = 1 / maxSLStrain
	for i = 1, #strainData do
		local strain = strainData[i]
		strainDiff += 1 / (1 + math_exp(-(strain[1] * invMaxSLStrain * 12 - 6)))
	end
	
	return strainDiff
end

export type Data = {
	AimStrain:{{number}},
	AimSLStrain:{{number}},
	SpeedStrain:{{number}},
	ReadingStrain:{{number}},
	FlashlightStrain:{{number}},
	DifficultyValue:{
		CS:number,
		AR:number,
		OD:number,
		HP:number
	},
	NoteCount:{
		Circle:number,
		Slider:number,
		Spinner:number,
		Total:number
	},
	ModData:ModData
}

export type DifficultyAttributes = {
	StarRating:number,
	AimDifficulty:number,
	AimDifficultySliderCount:number,
	SpeedDifficulty:number,
	ReadingDifficulty:number,
	SpeedNoteCount:number,
	FlashlightDifficulty:number,
	AimDifficultStrainCount:number,
	SpeedDifficultStrainCount:number,
	ReadingDifficultStrainCount: number
}

function calculateDifficultyRatingBase(value)
	return math_sqrt(value) * difficulty_multiplier
end

function calculateStarRating(basePerfomance: number)
	return math_pow(basePerfomance * perfomance_base_multiplier, 1/3)
end
function calculator.CalculateVisibilityBonus(modData:ModData, AR:number, visibilityFactor:number)
	if not visibilityFactor then
		visibilityFactor = 1
	end
	
	local isAlwayParticallyVisible = true
	
	local readingBonus = 0.04 * (12 - math_max(AR, 7))
	readingBonus *= visibilityFactor

	if AR < 7 then
		readingBonus += (isAlwayParticallyVisible and 0.03 or 0.045) * (7 - math_max(AR , 0))
	end
	
	if AR < 0 then
		readingBonus += (isAlwayParticallyVisible and 0.075 or 0.1) * (1 - math_pow(1.5, AR))
	end
	
	return readingBonus
end

function calculator.ComputeAimRating(aimDifficultyValue:number, modData:ModData, totalHit:number, AR:number, OD:number)
	if modData.AP then
		return 0
	end
	
	local aimRating = math_pow(aimDifficultyValue, 0.62) * 0.0248

	if modData.RX then
		aimRating *= 0.9
	end
	
	if modData.MG and modData.MG.Active then
		local magnetisedStrength = modData.MG.Strength or 0
		aimRating *= 1 - magnetisedStrength
	end
	
	local ratingMultiplier = 1
	-- Apply the OD difficulty to the aim rating
	local odMax = math_max(0, OD)
	ratingMultiplier *= 0.98 + odMax * odMax / 2500
	return aimRating * math_pow(ratingMultiplier, 1/3)
end

function calculator.ComputeSpeedRating(speedDifficultyValue:number, modData:ModData, totalHit:number, AR:number, OD:number)
	if modData.RX then
		return 0
	end
	local speedRating = calculateDifficultyRatingBase(speedDifficultyValue)
	if modData.AP then
		speedRating *= 0.5
	end
	
	if modData.MG then
		local magnetisedStrength = modData.MG.Strength or 0
		speedRating *= 1 - magnetisedStrength * 0.3
	end
	
	return speedRating
end

function calculator.ComputeReadingRating(readingDifficultyValue: number, modData:ModData, OD:number)
	local readingRating = calculateDifficultyRatingBase(readingDifficultyValue)

	if modData.TD then
		readingRating = math_pow(readingRating, 0.8)
	end

	if modData.RX then
		readingRating *= 0.6
	elseif modData.AP then
		readingRating *= 0.3
	end

	if modData.MG then
		local magnetisedStrength = modData.MG.Strength or 0
		readingRating *= 1 - magnetisedStrength
	end

	local ratingMultiplier = 1
	local odMax = math_max(0, OD)
	ratingMultiplier *= 0.75 + math_pow(odMax, 2.2) / 800

	return readingRating * math_pow(ratingMultiplier, 1/3)
end

function calculator.ComputeFlashlightRating(flashlightDifficultyValue:number, modData:ModData, totalHit:number, AR:number, OD:number)
	local flRating = calculateDifficultyRatingBase(flashlightDifficultyValue)
	
	if not modData.FL then
		return 0
	end
	
	if modData.TD then
		flRating = math_pow(flRating, 0.8)
	end
	
	if modData.RX then
		flRating *= 0.7
	elseif modData.AP then
		flRating *= 0.4
	end
	
	if modData.MG then
		local magnetisedStrength = modData.MG.Strength or 0
		flRating *= 1 - magnetisedStrength
	end
	
	-- TODO: Add deflate mod
	--if modData.DF then	
	--end
	
	local ratingMultiplier = 1
	ratingMultiplier *= 0.7 + 0.1 * math_min(1.0, totalHit / 200.0) +
		(totalHit > 200 and (0.2 * math_min(1.0, (totalHit - 200) / 200.0)) or 0.0)
	
	local odMax = math_max(0, OD)
	ratingMultiplier *= 0.98 + odMax * odMax / 2500
	
	return flRating * math_sqrt(ratingMultiplier)
end

function calculator.SumCognitionDifficulty(reading: number, flashlight: number)
	if reading <= 0 then
		return flashlight
	elseif flashlight <= 0 then
		return reading
	end

	return evaluator.Normalise(1.1, reading, flashlight * math_clamp(flashlight/reading, 0.25, 1))
end

function calculator.GetDifficultyAttributes(data:Data):DifficultyAttributes
	local speedNotes = calculator.RelevantNoteCount(data.SpeedStrain)
	local difficultSliders = calculator.getDificultSliders(data.AimSLStrain)
	
	local ARRate = data.DifficultyValue.AR
	local ODRate = data.DifficultyValue.OD
	
	local aimDifficultyValue = calculator.DifficultyValue(data.AimStrain, "Aim")
	local speedDifficultyValue, speedNoteWeightSum = calculator.DifficultyValueHarmonic(data.SpeedStrain, "Speed")
	local readingDifficultyValue, readingNoteWeightSum = calculator.DifficultyValueHarmonic(data.ReadingStrain, "Reading")
	local flashlightDifficultyValue = calculator.FLDifficultyValue(data.FlashlightStrain)

	
	local aimDiffStrainCount = calculator.CountTopWeightedStrains(data.AimStrain, "Aim")
	local speedDiffStrainCount = calculator.CountTopWeightedDifficultyHarmonic(data.SpeedStrain, speedDifficultyValue, speedNoteWeightSum)
	local readingDiffStrainCount = calculator.CountTopWeightedDifficultyHarmonic(data.ReadingStrain, readingDifficultyValue, readingNoteWeightSum)
	
	local aimRating = calculator.ComputeAimRating(aimDifficultyValue, data.ModData, data. NoteCount.Total, ARRate, ODRate)
	local speedRating = calculator.ComputeSpeedRating(speedDifficultyValue, data.ModData, data. NoteCount.Total, ARRate, ODRate)
	local flashlightRating = calculator.ComputeFlashlightRating(flashlightDifficultyValue, data.ModData, data.NoteCount.Total, ARRate, ODRate)
	local readingRating = calculator.ComputeReadingRating(readingDifficultyValue, data.ModData, ODRate)
	
	local aimBasePerfomance = basePerfomance(aimRating)
	local speedBasePerfomance = basePerfomance(speedRating)
	local readingBasePerformance = basePerfomance(readingRating)
	local flashlightBasePerfomance = basePerfomanceFL(flashlightRating)
	local baseCognitionPerformance = calculator.SumCognitionDifficulty(readingBasePerformance, flashlightBasePerfomance)
	
	local basePerformance = evaluator.Normalise(normalised_expoment, aimBasePerfomance, speedBasePerfomance, baseCognitionPerformance)
	
	-- local multiplier = calculateDifficultyMultiplier(data.ModData, data.NoteCount.Total, data.NoteCount.Spinner)
	local starRating = calculateStarRating(basePerformance)
	
	local Attributes = {
		StarRating = starRating,
		AimDifficulty = aimRating,
		AimDifficultySliderCount = difficultSliders,
		SpeedDifficulty = speedRating,
		ReadingDifficulty = readingRating,
		SpeedNoteCount = speedNotes,
		FlashlightDifficulty = flashlightRating,
		AimDifficultStrainCount = aimDiffStrainCount,
		SpeedDifficultStrainCount = speedDiffStrainCount,
		ReadingDifficultStrainCount = readingDiffStrainCount
	}
	
	return Attributes
end

export type LiveDifficultyAttributes = {
	AimPeak:{number},
	SpeedPeak:{number},
	FLPeak:{number},
	ModData:modData.ModData,
	ARRate:number,
	ODRate:number,
	NoteCount:{
		Circle:number,
		Slider:number,
		Spinner:number,
		Total:number
	}
}

export type LiveDifficultyReturnAttributes = {
	AimDifficulty:number,
	SpeedDifficulty:number,
	FlashlightDifficulty:number,
	StarRating:number
}

function calculator.GetDifficultyAttributesFromLiveData(Attributes:LiveDifficultyAttributes):LiveDifficultyReturnAttributes
	local aimDifficultyValue = calculator.LiveDifficultyValue(Attributes.AimPeak, "Aim")
	local speedDifficultyValue = calculator.LiveDifficultyValue(Attributes.SpeedPeak, "Speed")
	local flashlightDifficultyValue = Attributes.ModData.FL and calculator.LiveFLDifficultyValue(Attributes.FLPeak) or 0
	
	local aimRating = calculator.ComputeAimRating(aimDifficultyValue, Attributes.ModData, Attributes.NoteCount.Total, Attributes.ARRate, Attributes.ODRate)
	local speedRating = calculator.ComputeSpeedRating(speedDifficultyValue, Attributes.ModData, Attributes.NoteCount.Total, Attributes.ARRate, Attributes.ODRate)
	local flashlightRating = calculator.ComputeFlashlightRating(flashlightDifficultyValue, Attributes.ModData, Attributes.NoteCount.Total, Attributes.ARRate, Attributes.ODRate)
	
	local aimBasePerfomance = basePerfomance(aimRating)
	local speedBasePerfomance = basePerfomance(speedRating)
	local flashlightBasePerformance = basePerfomanceFL(flashlightRating)
	
	local basePerfomance = evaluator.Normalise(normalised_expoment, aimBasePerfomance, speedBasePerfomance, flashlightBasePerformance)
	
	-- local multiplier = calculateDifficultyMultiplier(Attributes.ModData, Attributes.NoteCount.Total, Attributes.NoteCount.Spinner)
	local starRating = calculateStarRating(basePerfomance)
	
	return {
		AimDifficulty = aimRating,
		SpeedDifficulty = speedRating,
		FlashlightDifficulty = flashlightRating,
		StarRating = starRating
	}
end

return calculator
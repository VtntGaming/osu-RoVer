--[LOCATION]:[Workspace.DifficultyCalculator]
--!strict
-- Credited the osu! team on the github for the difficulty calculator and preprocessing
-- Even though I have to transfer code from C# to lua all by myself
-- The calculator might different compare to the original one

local Workspace = game:GetService("Workspace")
local workspace = game:GetService("Workspace")

local BasePerformance = require(Workspace.PerformanceCalculator.BasePerformance)
local converterTools = require(workspace.OsuConvert.converterTools)
local evaluator = require(script.DifficultyEvaluator)
local DifficultyCalculationUtils = require(script.DifficultyEvaluator.DifficultyCalculationUtils)
local RatingCalculator = require(script.RatingCalculator)
local StrainSkills = require(script.StrainSkills)
local modData = require(workspace.ModData)

-- Cache math functions for performance
local math_pow = math.pow
local math_max = math.max
local math_min = math.min
-- local math_sqrt = math.sqrt
local math_log10 = math.log10
local math_exp = math.exp
local math_clamp = math.clamp
local math_lerp = math.lerp
local table_sort = converterTools.TrySort

local perfomance_base_multiplier = 1.12
local normalised_expoment = 1.1

local calculator = {}

function sortPeak(data:{number})
	converterTools.TrySort(data,function(a,b) return a>b end)
end

function sortStrain(data:{{number}})
	converterTools.TrySort(data,function(a,b) return a[1]>b[1] end)
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
		StrainPeak[i] *= math_lerp(ReducedStrainBaseline, 1, scale)
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

local aimReducedSelectionCount = 10
local aimReducedStrainBaseline = 0.75
local aimDecayWeight = 0.9

function calculator.DifficultyValueAim(StrainData:{{number}}): number
	local difficulty = 0
	local weight = 1

	table_sort(StrainData, function(a,b)
		return a[2] < b[2]	-- Sort the timing to be perfect
	end)

	local strains = StrainSkills.GetStrainPeak(StrainData, "Aim")

	sortPeak(strains)

	for i = 1, math_min(#strains, aimReducedSelectionCount) do
		local scale = math_log10(math_lerp(1,10,math_clamp((i - 1) / aimReducedSelectionCount, 0, 1)))
		
		strains[i] *= math_lerp(aimReducedStrainBaseline, 1, scale)
	end

	sortPeak(strains)

	for i = 1, #strains do
		local strain = strains[i]
		if strain <= 0 then break end
		
		difficulty += strain * weight
		weight *= aimDecayWeight
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
		local scale = math_log10(math_lerp(1,10,math_clamp((i-1)/reducedSelectionCount,0,1)))
		StrainPeak[i] *= math_lerp(ReducedStrainBaseline, 1, scale)
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

		sum += DifficultyCalculationUtils.Logistic(strain / consistentTopNote, 0.88, 10, 1.1)
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

function calculator.CalculateStarRating(BasePerformance: number)
	return math_pow(BasePerformance * perfomance_base_multiplier, 1/3)
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
	
	local aimDifficultyValue = calculator.DifficultyValueAim(data.AimStrain)
	local speedDifficultyValue, speedNoteWeightSum = calculator.DifficultyValueHarmonic(data.SpeedStrain, "Speed")
	local readingDifficultyValue, readingNoteWeightSum = calculator.DifficultyValueHarmonic(data.ReadingStrain, "Reading")
	local flashlightDifficultyValue = calculator.FLDifficultyValue(data.FlashlightStrain)

	
	local aimDiffStrainCount = calculator.CountTopWeightedStrains(data.AimStrain, "Aim")
	local speedDiffStrainCount = calculator.CountTopWeightedDifficultyHarmonic(data.SpeedStrain, speedDifficultyValue, speedNoteWeightSum)
	local readingDiffStrainCount = calculator.CountTopWeightedDifficultyHarmonic(data.ReadingStrain, readingDifficultyValue, readingNoteWeightSum)
	
	local aimRating = RatingCalculator.ComputeAimRating(aimDifficultyValue, data.ModData, data. NoteCount.Total, ARRate, ODRate)
	local speedRating = RatingCalculator.ComputeSpeedRating(speedDifficultyValue, data.ModData, data. NoteCount.Total, ARRate, ODRate)
	local flashlightRating = RatingCalculator.ComputeFlashlightRating(flashlightDifficultyValue, data.ModData, data.NoteCount.Total, ARRate, ODRate)
	local readingRating = RatingCalculator.ComputeReadingRating(readingDifficultyValue, data.ModData, ODRate)
	
	local aimBasePerformance = BasePerformance.DifficultyToPerformance(aimRating)
	local speedBasePerformance = BasePerformance.DifficultyToPerformance(speedRating)
	local readingBasePerformance = BasePerformance.DifficultyToPerformance(readingRating)
	local flashlightBasePerformance = BasePerformance.DifficultyToPerformanceFL(flashlightRating)
	local baseCognitionPerformance = calculator.SumCognitionDifficulty(readingBasePerformance, flashlightBasePerformance)
	
	local basePerformance = evaluator.Normalise(normalised_expoment, aimBasePerformance, speedBasePerformance, baseCognitionPerformance)
	
	-- local multiplier = calculateDifficultyMultiplier(data.ModData, data.NoteCount.Total, data.NoteCount.Spinner)
	local starRating = calculator.CalculateStarRating(basePerformance)
	
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
	SpeedObjects:{{number}},
	ReadingObjects:{{number}},
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
	ReadingDifficulty:number,
	FlashlightDifficulty:number,
	StarRating:number
}

function calculator.GetDifficultyAttributesFromLiveData(Attributes:LiveDifficultyAttributes):LiveDifficultyReturnAttributes
	local aimDifficultyValue = calculator.LiveDifficultyValue(Attributes.AimPeak, "Aim")
	local speedDifficultyValue = calculator.DifficultyValueHarmonic(Attributes.SpeedObjects, "Speed")
	local readingDifficultyValue = calculator.DifficultyValueHarmonic(Attributes.ReadingObjects, "Reading")
	local flashlightDifficultyValue = Attributes.ModData.FL and calculator.LiveFLDifficultyValue(Attributes.FLPeak) or 0
	
	local aimRating = RatingCalculator.ComputeAimRating(aimDifficultyValue, Attributes.ModData, Attributes.NoteCount.Total, Attributes.ARRate, Attributes.ODRate)
	local speedRating = RatingCalculator.ComputeSpeedRating(speedDifficultyValue, Attributes.ModData, Attributes.NoteCount.Total, Attributes.ARRate, Attributes.ODRate)
	local readingRating = RatingCalculator.ComputeReadingRating(readingDifficultyValue, Attributes.ModData, Attributes.ODRate)
	local flashlightRating = RatingCalculator.ComputeFlashlightRating(flashlightDifficultyValue, Attributes.ModData, Attributes.NoteCount.Total, Attributes.ARRate, Attributes.ODRate)
	
	local aimBasePerformance = BasePerformance.DifficultyToPerformance(aimRating)
	local speedBasePerformance = BasePerformance.DifficultyToPerformance(speedRating)
	local readingBasePerformance = BasePerformance.DifficultyToPerformance(readingRating)
	local flashlightBasePerformance = BasePerformance.DifficultyToPerformanceFL(flashlightRating)
	local baseCognitionPerformance = calculator.SumCognitionDifficulty(readingBasePerformance, flashlightBasePerformance)
	
	local BasePerformance = evaluator.Normalise(normalised_expoment, aimBasePerformance, speedBasePerformance, baseCognitionPerformance)
	
	-- local multiplier = calculateDifficultyMultiplier(Attributes.ModData, Attributes.NoteCount.Total, Attributes.NoteCount.Spinner)
	local starRating = calculator.CalculateStarRating(BasePerformance)
	
	return {
		AimDifficulty = aimRating,
		SpeedDifficulty = speedRating,
		ReadingDifficulty = readingRating,
		FlashlightDifficulty = flashlightRating,
		StarRating = starRating
	}
end

return calculator
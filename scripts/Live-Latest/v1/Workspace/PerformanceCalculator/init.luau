--[LOCATION]:[Workspace.PerformanceCalculator]
local workspace = game:GetService("Workspace")

local BasePerformance = require(script.BasePerformance)
local DifficultyCalculationUtils = require(workspace.DifficultyCalculator.DifficultyEvaluator.DifficultyCalculationUtils)
local DifficultyCalculator = require(workspace.DifficultyCalculator)
local ConverterTools = require(workspace.OsuConvert.converterTools)
local evaluator = require(workspace.DifficultyCalculator.DifficultyEvaluator)
local modData = require(workspace.ModData)

local normalised_expoment = 1.1


function calculateMissPenalty(missCount:number, diffStrainCount:number):number
	if missCount <= 0 then
		return 1
	end
	return 0.93 / (missCount / (4 * math.log(diffStrainCount)) + 1)
end

function reverseLerp(x, a, b)
	return math.clamp((x - a) / (b - a), 0, 1)
end

function calculateSpeedHighDeviationNerf(Attributes:SpeedAttributes):number
	if not Attributes.AccuracyData.SpeedDeviation then return 0 end
	local speedDeviation = Attributes.AccuracyData.SpeedDeviation
	local speedValue = BasePerformance.DifficultyToPerformance(Attributes.SpeedDiff)
	local excessSpeedDifficultyCutoff = 100 + 220 * math.pow(22 / speedDeviation, 6.5)
	if speedValue <= excessSpeedDifficultyCutoff then
		return 1
	end
	
	local scale = 50
	local adjustedSpeedValue = scale * (math.log((speedValue - excessSpeedDifficultyCutoff) / scale + 1) + excessSpeedDifficultyCutoff / scale)
	
	local lerp = 1 - reverseLerp(speedDeviation, 22.0, 27.0)
	adjustedSpeedValue = ConverterTools.Lerp(adjustedSpeedValue, speedValue, lerp)
	
	return adjustedSpeedValue / speedValue
end

export type AccuracyData = {
	h300:number, h100:number, h50:number, missCount:number,
	EffectiveMissCount:number?,
	Accuracy:number?,
	SpeedDeviation:number?,
}

type AimAttributes = {
	AimDiff:number,
	ModData:modData.ModData,
	AccuracyData:AccuracyData,
	AimDifficultyStrainCount:number
}

local function ComputeAimValue(Attributes:AimAttributes):number
	local aimDiff = Attributes.AimDiff
	-- local estimateImproperlyFollowedDifficultSliders = 0	-- We will calculate this later
	local sliderNerfFactor = 1
	aimDiff *= sliderNerfFactor
	
	local accData = Attributes.AccuracyData
	
	local totalHit = accData.h300 + accData.h100 + accData.h50 + accData.missCount
	
	local aimPS = BasePerformance.DifficultyToPerformance(aimDiff)
	local lengthBonus = 0.95 + 0.35 * math.min(1, totalHit / 2000) + 
		(totalHit > 2000 and math.log10(totalHit/2000) * 0.5 or 0)
	aimPS *= lengthBonus
	if accData.EffectiveMissCount > 0 then
		local relevantMissCount = accData.EffectiveMissCount
		aimPS *= calculateMissPenalty(relevantMissCount, Attributes.AimDifficultyStrainCount)
	end
	
	aimPS *= accData.Accuracy
	
	return aimPS
end

type SpeedAttributes = {
	SpeedDiff:number,
	ModData:modData.ModData,
	AccuracyData:AccuracyData,
	SpeedNoteCount:number,
	SpeedDifficultyStrainCount:number,
	ODRate:number
}

type DeviationAttributes = {
	ModData:modData.ModData,
	AccuracyData:AccuracyData,
	SpeedNoteCount:number,
	ODRate:number
}

local function CalculateDeviation(relevantCount300:number, relevantCount100:number, relevantCount50:number, ODRate:number, ModData:modData.ModData):number?
	if relevantCount300 + relevantCount100 + relevantCount50 <= 0 then
		return nil
	end
	
	local n = math.max(1, relevantCount300 + relevantCount100)
	local p = relevantCount300 / n
	
	local z = 2.32634787404
	local pLowerBound = math.min(p, (n * p + z * z / 2) / (n + z * z) - z / (n + z * z) * math.sqrt(n * p * (1 - p) + z * z / 4))
	
	local deviation:number
	local h300Time = ConverterTools.HitWindowsFor.h300(ODRate, ModData.SA or 1)
	local h100Time = ConverterTools.HitWindowsFor.h100(ODRate, ModData.SA or 1)
	local h50Time = ConverterTools.HitWindowsFor.h50(ODRate, ModData.SA or 1)
	
	if pLowerBound > 0.01 then
		deviation = h300Time / (math.sqrt(2) * DifficultyCalculationUtils.ErfInv(pLowerBound))
		
		local h100WindowTailAmount = math.sqrt(2/math.pi) * h100Time * math.exp(-0.5 * math.pow(h100Time / deviation, 2))
				/ (deviation * DifficultyCalculationUtils.Erf(h100Time / (math.sqrt(2) * deviation)))
		deviation *= math.sqrt(1 - h100WindowTailAmount)
	else
		deviation = h100Time / math.sqrt(3)
	end
	
	local h50Variance = (h50Time * h50Time + h100Time * h50Time + h100Time * h100Time) / 3
	deviation = math.sqrt(((relevantCount300 + relevantCount100) * math.pow(deviation, 2) + relevantCount50 * h50Variance) / (relevantCount300 + relevantCount100 + relevantCount50))
	
	return deviation
end

local function CalculateSpeedDeviation(Attributes:DeviationAttributes):number?
	local accData = Attributes.AccuracyData
	local totalSuccessfulHit = accData.h300 + accData.h100 + accData.h50
	local totalHit = totalSuccessfulHit + accData.missCount
	if totalSuccessfulHit == 0 then
		return nil
	end
	
	local speedNoteCount = Attributes.SpeedNoteCount
	speedNoteCount += (totalHit - Attributes.SpeedNoteCount) * 0.1
	
	local relevantCountMiss = math.min(accData.missCount, speedNoteCount)
	local relevantCount50 = math.min(accData.h50, speedNoteCount - relevantCountMiss);
	local relevantCount100 = math.min(accData.h100, speedNoteCount - relevantCountMiss - relevantCount50);
	local relevantCount300 = math.max(0, speedNoteCount - relevantCountMiss - relevantCount50 - relevantCount100);
	
	return CalculateDeviation(relevantCount300, relevantCount100, relevantCount50, Attributes.ODRate, Attributes.ModData)
end

local function ComputeSpeedValue(Attributes:SpeedAttributes):number
	if not Attributes.AccuracyData.SpeedDeviation then
		return 0
	end
	
	local accData = Attributes.AccuracyData	
	local totalHit = accData.h300 + accData.h100 + accData.h50 + accData.missCount
	
	local speedPS = BasePerformance.DifficultyToPerformance(Attributes.SpeedDiff)
	
	local lengthBonus = 0.95 + 0.4 * math.min(1, totalHit / 2000) + 
		(totalHit > 2000 and math.log10(totalHit/2000) * 0.5 or 0)

	speedPS *= lengthBonus
	
	if accData.EffectiveMissCount > 0 then
		speedPS *= calculateMissPenalty(accData.EffectiveMissCount, Attributes.SpeedDifficultyStrainCount)
	end
	
	local speedHighDeviationMultiplier = calculateSpeedHighDeviationNerf(Attributes)
	speedPS *= speedHighDeviationMultiplier

	local effectiveHitWindow = 20 * math.pow(4 / Attributes.SpeedDiff, 0.35)
	local effectiveAccuracy = DifficultyCalculationUtils.Erf(effectiveHitWindow/Attributes.AccuracyData.SpeedDeviation)

	speedPS *= math.pow(effectiveAccuracy, 2)
	
	return speedPS
end

type ReadingAttributes = {
	ReadingDiff: number,
	ModData:modData.ModData,
	AccuracyData:AccuracyData,
	ReadingDifficultNoteCount: number,
}

local function ComputeReadingValue(Attributes: ReadingAttributes): number
	local readingPS = BasePerformance.DifficultyToPerformance(Attributes.ReadingDiff)

	local effectiveMissCount = Attributes.AccuracyData.EffectiveMissCount

	if effectiveMissCount > 0 then
		readingPS *= calculateMissPenalty(effectiveMissCount, Attributes.ReadingDifficultNoteCount)
	end

	readingPS *= math.pow(Attributes.AccuracyData.Accuracy or 0, 3)

	return readingPS
end

type AccuracyAttributes = {
	ModData:modData.ModData,
	NoteCount:{Circles:number, Sliders:number, Spinners:number},
	AccuracyData:AccuracyData,
	ODRate:number,
	ARRate:number,
}

local function ComputeAccuracyValue(Attributes:AccuracyAttributes):number
	if Attributes.ModData.RX then
		return 0
	end
	
	local betterAccuracyPercentage = 0
	local hitObjectsWithAccuracy = Attributes.NoteCount.Circles
	if Attributes.ModData.NS then
		hitObjectsWithAccuracy += Attributes.NoteCount.Sliders
	end
	
	local totalNotes = hitObjectsWithAccuracy + Attributes.NoteCount.Spinners

	local accData = Attributes.AccuracyData	
	local totalHit = accData.h300 + accData.h100 + accData.h50 + accData.missCount
	
	if totalHit < totalNotes then
		-- Simulate the acc ps they gonna get
		hitObjectsWithAccuracy *= (totalHit / totalNotes)
	end
	
	if hitObjectsWithAccuracy > 0 then
		betterAccuracyPercentage = ((Attributes.AccuracyData.h300 - math.max(totalHit - hitObjectsWithAccuracy, 0)) * 6 + accData.h100 * 2 + accData.h50) / (hitObjectsWithAccuracy * 6)
	end
	
	if betterAccuracyPercentage < 0 then
		betterAccuracyPercentage = 0
	end
	
	local accPS = math.pow(1.52163, Attributes.ODRate) * math.pow(betterAccuracyPercentage, 24) * 2.83
	-- Buff for long maps with many hit circles
	accPS *= hitObjectsWithAccuracy < 1000
		and math.pow(hitObjectsWithAccuracy / 1000, 0.3)
		or math.pow(hitObjectsWithAccuracy / 1000, 0.1)
	
	if Attributes.ModData.HD then
		accPS *= 1 + 0.08 * DifficultyCalculationUtils.ReverseLerp(Attributes.ARRate, 11.5, 10)
	end
	
	return accPS
end

type FlashlightAttributes = {
	FLDiff:number,
	ModData:modData.ModData,
	AccuracyData:AccuracyData,
	MaxCombo:number,
	MapMaxCombo:number
}

local function GetComboScalingFactor(Attributes:FlashlightAttributes):number
	return Attributes.MapMaxCombo <= 0 and 1 or math.min(math.pow(Attributes.MaxCombo, 0.8) / math.pow(Attributes.MapMaxCombo, 0.8), 1.0)
end

local function ComputeFlashlightValue(Attributes:FlashlightAttributes):number
	if not Attributes.ModData.FL then
		return 0
	end
	local accData = Attributes.AccuracyData	
	local totalHit = accData.h300 + accData.h100 + accData.h50 + accData.missCount
	local flashlightPS = BasePerformance.DifficultyToPerformanceFL(Attributes.FLDiff or 0)
	local effectiveMissCount = accData.EffectiveMissCount
	if effectiveMissCount > 0 then
		flashlightPS *= 0.97 * math.pow	(1 - math.pow(effectiveMissCount / totalHit, 0.775), math.pow(effectiveMissCount, .875))
	end
	
	flashlightPS *= GetComboScalingFactor(Attributes)
	flashlightPS *= 0.5 + accData.Accuracy / 2
	
	return flashlightPS
end

type GeneralAttributes = {
	AimValue:number,
	SpeedValue:number,
	ReadingValue:number,
	FLValue:number,
	ODRate:number,
	ARRate:number,
	ModData:modData.ModData,
	NoteCount:{Circles:number, Sliders:number, Spinners:number},
	AccuracyData:AccuracyData,
	AimDifficultyStrainCount:number,
	SpeedDifficultyStrainCount:number,
	ReadingDifficultyStrainCount:number,
	SpeedNoteCount:number,
	MaxCombo:number,
	MapMaxCombo:number
}

type ReturnAttributes = {
	AimPS:number,
	SpeedPS:number,
	ReadingPS:number,
	AccPS:number,
	FlashlightPS:number,
	TotalPS:number,
	SpeedDeviation:number,
	EffectiveMissCount:number
}

local function GetPerfomanceAttributes(Attributes:GeneralAttributes):ReturnAttributes
	local accData = Attributes.AccuracyData
	local h300 = accData.h300
	local h100 = accData.h100
	local h50 = accData.h100
	local missCount = accData.missCount
	local totalHit = h300 + h100 + h50 + missCount
	local accuracy = (h300 * 6 + h100 * 2 + h50) / (totalHit * 6)
	local effectiveMissCount = missCount
	local multiplier = DifficultyCalculator.CalculateDifficultyMultiplier(Attributes.ModData)
	if Attributes.ModData.NF then
		multiplier *= math.max(0.90, 1.0 - 0.02 * effectiveMissCount)
	end
	if Attributes.ModData.RX then
		local h100Multiplier = 0.75 * math.max(0, Attributes.ODRate > 0 and 1 - Attributes.ODRate / 13.33 or 1)
		local h50Multiplier = math.max(0, Attributes.ODRate > 0 and 1 - math.pow(Attributes.ODRate / 13.33, 5) or 1)
		
		effectiveMissCount = math.min(effectiveMissCount + h100 * h100Multiplier + h50 * h50Multiplier, totalHit)
	end
	Attributes.AccuracyData.EffectiveMissCount = effectiveMissCount
	Attributes.AccuracyData.Accuracy = accuracy
	local deviationAttribute:DeviationAttributes = {
		ModData = Attributes.ModData,
		ODRate = Attributes.ODRate,
		SpeedNoteCount = Attributes.SpeedNoteCount,
		AccuracyData = accData
	}
	local aimAttribute:AimAttributes = {
		AimDiff = Attributes.AimValue,
		ModData = Attributes.ModData,
		AccuracyData = Attributes.AccuracyData,
		AimDifficultyStrainCount = Attributes.AimDifficultyStrainCount
	}
	local speedAttribute:SpeedAttributes = {
		SpeedDiff = Attributes.SpeedValue,
		ModData = Attributes.ModData,
		AccuracyData = Attributes.AccuracyData,
		SpeedNoteCount = Attributes.SpeedNoteCount,
		SpeedDifficultyStrainCount = Attributes.SpeedDifficultyStrainCount,
		ODRate = Attributes.ODRate
	}
	local readingAttribute: ReadingAttributes = {
		ReadingDiff = Attributes.ReadingValue,
		ModData = Attributes.ModData,
		AccuracyData = Attributes.AccuracyData,
		ReadingDifficultNoteCount = Attributes.ReadingDifficultyStrainCount,
	}
	local accuracyAttribute:AccuracyAttributes = {
		ModData = Attributes.ModData,
		NoteCount = Attributes.NoteCount,
		AccuracyData = Attributes.AccuracyData,
		ODRate = Attributes.ODRate,
		ARRate = Attributes.ARRate
	}
	local flashlightAttribute:FlashlightAttributes = {
		FLDiff = Attributes.FLValue,
		ModData = Attributes.ModData,
		AccuracyData = Attributes.AccuracyData,
		MaxCombo = Attributes.MaxCombo,
		MapMaxCombo = Attributes.MapMaxCombo
	}
	
	local speedDeviation = CalculateSpeedDeviation(deviationAttribute)
	Attributes.AccuracyData.SpeedDeviation = speedDeviation
	
	local aimPS = ComputeAimValue(aimAttribute)
	local speedPS = ComputeSpeedValue(speedAttribute)
	local readingPS = ComputeReadingValue(readingAttribute)
	local accPS = ComputeAccuracyValue(accuracyAttribute)
	local flashlightPS = ComputeFlashlightValue(flashlightAttribute)
	
	local totalPS = evaluator.Normalise(normalised_expoment, aimPS, speedPS, readingPS, accPS, flashlightPS) * multiplier
	
	local returnAttributes:ReturnAttributes = {
		AimPS = aimPS,
		SpeedPS = speedPS,
		ReadingPS = readingPS,
		AccPS = accPS,
		FlashlightPS = flashlightPS,
		TotalPS = totalPS,
		SpeedDeviation = speedPS,
		EffectiveMissCount = effectiveMissCount
	}
	return returnAttributes
end

export type PerfomanceAttributes = {
	Current:ReturnAttributes,
	Max:ReturnAttributes
}

local function DeepCopy(t:{any})
	local newT = {}
	for index, data in pairs(t) do
		if typeof(data) == "table" then
			newT[index] = DeepCopy(data)
		else
			newT[index] = data
		end
	end
	
	return newT
end

local function CalculatePerformanceAttributes(
	AimValue, 
	SpeedValue, 
	ReadingValue,
	FLValue, 
	ODRate, 
	ARRate, 
	ModData:modData.ModData, 
	NoteCount, 
	MaxOnly, 
	AimDiffStrainCount, 
	SpeedDiffStrainCount, 
	SpeedRelevantNoteCount,
	ReadingDiffStrainCount, 
	AccuracyData:AccuracyData?): PerfomanceAttributes

	--local MaxPSData = PerformanceCalculator(AimDiff, SpeedDiff, FLDiff, ODRate, ARRate, ModData, NoteCount, true, AimDiffStrainCount, SpeedDiffStrainCount, SpeedRelevantNoteCount)
	local ReturnAttributes:PerfomanceAttributes = {}::PerfomanceAttributes
	
	local CRCount = NoteCount.Circle
	local SLCount = NoteCount.Slider
	local SPCount = NoteCount.Spinner
	local ObjectCount = CRCount + SLCount + SPCount
	-- local AccuracyNoteCount = CRCount	
	-- local SongSpeed = ModData.SA
	
	local PerfectScoreAttribute:GeneralAttributes = {
		AimValue = AimValue,
		SpeedValue = SpeedValue,
		ReadingValue = ReadingValue,
		FLValue = FLValue,
		ODRate = ODRate,
		ARRate = ARRate,
		ModData = ModData,
		NoteCount = {Circles = NoteCount.Circle, Sliders = NoteCount.Slider, Spinners = NoteCount.Spinner},
		AccuracyData = {h300 = ObjectCount, h100 = 0, h50 = 0, missCount = 0, Accuracy = 1}::AccuracyData,
		AimDifficultyStrainCount = AimDiffStrainCount,
		SpeedDifficultyStrainCount = SpeedDiffStrainCount,
		SpeedNoteCount = SpeedRelevantNoteCount,
		ReadingDifficultyStrainCount = ReadingDiffStrainCount,
		MaxCombo = 0,
		MapMaxCombo = 0
	}
	
	local perfectScoreResult = GetPerfomanceAttributes(PerfectScoreAttribute)
	ReturnAttributes.Max = perfectScoreResult
	
	if not MaxOnly then
		local PlayerScoreAttribute = DeepCopy(PerfectScoreAttribute)::GeneralAttributes
		PlayerScoreAttribute.AccuracyData = AccuracyData
		
		local playerScoreResult = GetPerfomanceAttributes(PlayerScoreAttribute)
		ReturnAttributes.Current = playerScoreResult
	end
	
	return ReturnAttributes
end

return CalculatePerformanceAttributes
--[LOCATION]:[Workspace.PerformanceCalculator]
local workspace = game:GetService("Workspace")
local basePerformance = require(script.BasePerfomance)
local basePerformanceFL = require(script.BasePerfomanceFL)
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
	return 0.96 / ((missCount / (4 * math.pow(math.log(diffStrainCount), 0.94))) + 1)
end

function reverseLerp(x, a, b)
	return math.clamp((x - a) / (b - a), 0, 1)
end

function calculateSpeedHighDeviationNerf(Attributes:SpeedAttributes):number
	if not Attributes.AccuracyData.SpeedDeviation then return 0 end
	local speedDeviation = Attributes.AccuracyData.SpeedDeviation
	local speedValue = basePerformance(Attributes.SpeedDiff)
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

function _ComputeAimValue(Attributes:AimAttributes):number
	local aimDiff = Attributes.AimDiff
	-- local estimateImproperlyFollowedDifficultSliders = 0	-- We will calculate this later
	local sliderNerfFactor = 1
	aimDiff *= sliderNerfFactor
	
	local accData = Attributes.AccuracyData
	
	local totalHit = accData.h300 + accData.h100 + accData.h50 + accData.missCount
	
	local aimPS = basePerformance(aimDiff)
	local lengthBonus = 0.95 + 0.4 * math.min(1, totalHit / 2000) + 
		(totalHit > 2000 and math.log10(totalHit/2000) * 0.5 or 0)
	aimPS *= lengthBonus
	if accData.EffectiveMissCount > 0 then
		aimPS *= calculateMissPenalty(accData.EffectiveMissCount, Attributes.AimDifficultyStrainCount)
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

function _CalculateDeviation(relevantCount300:number, relevantCount100:number, relevantCount50:number, ODRate:number, ModData:modData.ModData):number?
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

function _CalculateSpeedDeviation(Attributes:DeviationAttributes):number?
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
	
	return _CalculateDeviation(relevantCount300, relevantCount100, relevantCount50, Attributes.ODRate, Attributes.ModData)
end

function _ComputeSpeedValue(Attributes:SpeedAttributes):number
	if not Attributes.AccuracyData.SpeedDeviation then
		return 0
	end
	
	local accData = Attributes.AccuracyData	
	local totalHit = accData.h300 + accData.h100 + accData.h50 + accData.missCount
	
	local speedPS = basePerformance(Attributes.SpeedDiff)
	
	local lengthBonus = 0.95 + 0.4 * math.min(1, totalHit / 2000) + 
		(totalHit > 2000 and math.log10(totalHit/2000) * 0.5 or 0)

	speedPS *= lengthBonus
	
	if accData.EffectiveMissCount > 0 then
		speedPS *= calculateMissPenalty(accData.EffectiveMissCount, Attributes.SpeedDifficultyStrainCount)
	end
	
	local speedHighDeviationMultiplier = calculateSpeedHighDeviationNerf(Attributes)
	speedPS *= speedHighDeviationMultiplier
	
	local relevantTotalDiff = math.max(0, totalHit - Attributes.SpeedNoteCount)
	local relevantCount300 = math.max(0, accData.h300 - relevantTotalDiff)
	local relevantCount100 = math.max(0, accData.h100 - math.max(0, relevantTotalDiff - accData.h300))
	local relevantCount50 = math.max(0, accData.h50 - math.max(0, relevantTotalDiff - accData.h300 - accData.h100))
	local relevantAccuracy = Attributes.SpeedNoteCount == 0 and 0 or (relevantCount300 * 6 + relevantCount100 * 2 + relevantCount50) / (Attributes.SpeedNoteCount * 6)
	
	speedPS *= math.pow((accData.Accuracy + relevantAccuracy) / 2, (14.5 - Attributes.ODRate) / 2)
	return speedPS
end

type AccuracyAttributes = {
	ModData:modData.ModData,
	NoteCount:{Circles:number, Sliders:number, Spinners:number},
	AccuracyData:AccuracyData,
	ODRate:number,
	ARRate:number,
}

function _ComputeAccuracyValue(Attributes:AccuracyAttributes):number
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
	accPS *= math.min(1.15, math.pow(hitObjectsWithAccuracy / 1000, 0.3))
	
	if Attributes.ModData.HD then
		accPS *= 1 + 0.08 * DifficultyCalculationUtils.ReverseLerp(Attributes.ARRate, 11.5, 10)
	end
	
	if Attributes.ModData.FL then
		accPS *= 1.02
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

function _GetComboScalingFactor(Attributes:FlashlightAttributes):number
	return Attributes.MapMaxCombo <= 0 and 1 or math.min(math.pow(Attributes.MaxCombo, 0.8) / math.pow(Attributes.MapMaxCombo, 0.8), 1.0)
end

function _ComputeFlashlightValue(Attributes:FlashlightAttributes):number
	if not Attributes.ModData.FL then
		return 0
	end
	local accData = Attributes.AccuracyData	
	local totalHit = accData.h300 + accData.h100 + accData.h50 + accData.missCount
	local flashlightPS = basePerformanceFL(Attributes.FLDiff or 0)
	local effectiveMissCount = accData.EffectiveMissCount
	if effectiveMissCount > 0 then
		flashlightPS *= 0.97 * math.pow	(1 - math.pow(effectiveMissCount / totalHit, 0.775), math.pow(effectiveMissCount, .875))
	end
	
	flashlightPS *= _GetComboScalingFactor(Attributes)
	flashlightPS *= 0.5 + accData.Accuracy / 2
	
	return flashlightPS
end

type GeneralAttributes = {
	AimValue:number,
	SpeedValue:number,
	FLValue:number,
	ODRate:number,
	ARRate:number,
	ModData:modData.ModData,
	NoteCount:{Circles:number, Sliders:number, Spinners:number},
	AccuracyData:AccuracyData,
	AimDifficultyStrainCount:number,
	SpeedDifficultyStrainCount:number,
	SpeedNoteCount:number,
	MaxCombo:number,
	MapMaxCombo:number
}

type ReturnAttributes = {
	AimPS:number,
	SpeedPS:number,
	AccPS:number,
	FlashlightPS:number,
	TotalPS:number,
	SpeedDeviation:number,
	EffectiveMissCount:number
}

function _GetPerfomanceAttributes(Attributes:GeneralAttributes):ReturnAttributes
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
	
	local speedDeviation = _CalculateSpeedDeviation(deviationAttribute)
	Attributes.AccuracyData.SpeedDeviation = speedDeviation
	
	local aimPS = _ComputeAimValue(aimAttribute)
	local speedPS = _ComputeSpeedValue(speedAttribute)
	local accPS = _ComputeAccuracyValue(accuracyAttribute)
	local flashlightPS = _ComputeFlashlightValue(flashlightAttribute)
	
	local totalPS = evaluator.Normalise(normalised_expoment, aimPS, speedPS, accPS, flashlightPS) * multiplier
	
	local returnAttributes:ReturnAttributes = {
		AimPS = aimPS,
		SpeedPS = speedPS,
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

function _DeepCopy(t:{any})
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

return function(
	AimValue, 
	SpeedValue, 
	FLValue, 
	ODRate, 
	ARRate, 
	ModData:modData.ModData, 
	NoteCount, 
	MaxOnly, 
	AimDiffStrainCount, 
	SpeedDiffStrainCount, 
	SpeedRelevantNoteCount, 
	AccuracyData:AccuracyData?):PerfomanceAttributes
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
		FLValue = FLValue,
		ODRate = ODRate,
		ARRate = ARRate,
		ModData = ModData,
		NoteCount = {Circles = NoteCount.Circle, Sliders = NoteCount.Slider, Spinners = NoteCount.Spinner},
		AccuracyData = {h300 = ObjectCount, h100 = 0, h50 = 0, missCount = 0, Accuracy = 1}::AccuracyData,
		AimDifficultyStrainCount = AimDiffStrainCount,
		SpeedDifficultyStrainCount = SpeedDiffStrainCount,
		SpeedNoteCount = SpeedRelevantNoteCount,
		MaxCombo = 0,
		MapMaxCombo = 0
	}
	
	local perfectScoreResult = _GetPerfomanceAttributes(PerfectScoreAttribute)
	ReturnAttributes.Max = perfectScoreResult
	
	if not MaxOnly then
		local PlayerScoreAttribute = _DeepCopy(PerfectScoreAttribute)::GeneralAttributes
		PlayerScoreAttribute.AccuracyData = AccuracyData
		
		local playerScoreResult = _GetPerfomanceAttributes(PlayerScoreAttribute)
		ReturnAttributes.Current = playerScoreResult
	end
	
	return ReturnAttributes
end

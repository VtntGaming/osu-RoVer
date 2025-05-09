local basePerformance = require(script.BasePerfomance)
local basePerformanceFL = require(script.BasePerfomanceFL)
local utils = require(script.DifficultyCalculationUtils)

function calculateMissPenalty(AccuracyData, diffStrainCount)
	local missCount = AccuracyData.miss
	if missCount <= 0 then
		return 1
	end
	return 0.96 / ((missCount / (4 * math.pow(math.log(diffStrainCount), 0.94))) + 1)
end

function reverseLerp(x, a, b)
	return math.clamp((x - a) / (b - a), 0, 1)
end

function Lerp(a,b,x)
	return a + (b-a)*x
end

function calculateSpeedDeviation(Hit300Time, Hit100Time, Hit50Time, totalSuccessfulHits, speedNoteCount, hit300, hit100, hit50, missCount)
	if totalSuccessfulHits == 0 then return nil end
	local totalHits = hit300 + hit100 + hit50 + missCount
	
	speedNoteCount += (totalHits - speedNoteCount) * 0.1
	local relevantCountMiss = math.min(missCount, speedNoteCount)
	local relevantCount50 = math.min(hit50, speedNoteCount - relevantCountMiss)
	local relevantCount100 = math.min(hit100, speedNoteCount - relevantCountMiss - relevantCount50)
	local relevantCount300 = math.max(0, speedNoteCount - relevantCountMiss - relevantCount50 - relevantCount100)
	
	return calculateDeviation(Hit300Time, Hit100Time, Hit50Time, relevantCount300, relevantCount100, relevantCount50, relevantCountMiss)
end

function calculateDeviation(Hit300Time, Hit100Time, Hit50Time, hit300, hit100, hit50, missCount)
	if hit300 + hit100 + hit50 < 0 then
		return nil
	end
	
	local ObjectCount = hit300 + hit100 + hit50 + missCount
	local n = math.max(1, ObjectCount - missCount - hit50)
	local z = 2.32634787404
	local p = hit100 / n
	
	local pLowerBound = (n * p + z * z / 2) / (n + z * z) - z / (n + z * z) * math.sqrt(n * p * (1 - p) + z * z / 4)
	
	local ErfInv = utils.ErfInv(pLowerBound)
	if not ErfInv then
		return nil
	end
	
	local deviation = Hit300Time / (math.sqrt(2) * ErfInv)
	local randomValue = math.sqrt(2 * math.pi) * Hit100Time * math.exp(-0.5 * math.pow(Hit100Time / deviation, 2)) / (deviation * utils.Erf(Hit100Time / math.sqrt(2) * deviation))
	
	deviation *= math.sqrt(1 - randomValue)
	
	local limitValue = Hit100Time / math.sqrt(3)
	if pLowerBound == 0 or randomValue >= 1 or deviation > limitValue then
		deviation = limitValue
	end
	
	local Hit50Variance = (Hit50Time * Hit50Time + Hit100Time * Hit50Time + Hit100Time * Hit100Time) / 3
	
	deviation = math.sqrt(((hit300 + hit100) * math.pow(deviation, 2) + hit50 * Hit50Variance) / (hit300 + hit100 + hit50))
	
	return deviation
end

function calculateSpeedHighDeviationNerf(speedDeviation, SpeedDiff)
	if not speedDeviation then return 0 end
	local speedValue = basePerformance(SpeedDiff)
	local excessSpeedDifficultyCutoff = 100 + 220 * math.pow(22 / speedDeviation, 6.5)
	if speedValue <= excessSpeedDifficultyCutoff then
		return 1
	end
	
	local scale = 50
	local adjustedSpeedValue = scale * (math.log((speedValue - excessSpeedDifficultyCutoff) / scale + 1) + excessSpeedDifficultyCutoff / scale)
	
	local lerp = 1 - reverseLerp(speedDeviation.Value, 22.0, 27.0)
	adjustedSpeedValue = Lerp(adjustedSpeedValue, speedValue, lerp)
	
	return adjustedSpeedValue / speedValue
end

return function(AimValue, SpeedValue, FLValue, ODRate, ARRate, ModData, NoteCount, SongSpeed, Multiplier, MaxOnly, AimDiffStrainCount, SpeedDiffStrainCount, SpeedRelevantNoteCount, AccuracyData)
	-- If MaxOnly is true, the game only want to get the max value to display
	local AimMulti = Multiplier.Aim or 1
	local SpeedMulti = Multiplier.Speed or 1
	local FLMulti = Multiplier.Flashlight or 1
	local AccMulti = Multiplier.Accuracy or 1
	local GlobalMultiplier = 1
	
	local CRCount = NoteCount.Circle
	local SLCount = NoteCount.Slider
	local SPCount = NoteCount.Spinner
	local ObjectCount = CRCount + SLCount + SPCount
	local AccuracyNoteCount = CRCount
	
	-- We doesn't know if the player is playing in TD mod or not (because they can just disable TD option)
	-- The TD mod only recieve when player is playing
	local AimTDMulti = 0.6
	local SpeedTDMulti = 1
	local AccTDMulti = 1
	local FlashlightTDMulti = 0.6
	
	local Hit300Time = 80 - 6 * ODRate
	Hit300Time /= SongSpeed
	
	local Hit100Time = 140 - 8 * ODRate
	Hit100Time /= SongSpeed
	
	local Hit50Time = 200 - 10 * ODRate
	Hit50Time /= SongSpeed
	

	ODRate = -(Hit300Time - 80) / 6
	
	local ARTime = 1200
	if ARRate < 5 then
		ARTime = 1200 + 600 * (5 - ARRate) / 5
	elseif ARRate > 5 then
		ARTime = 1200 - 750 * (ARRate - 5) / 5
	else
		ARTime = 1200
	end

	ARTime /= SongSpeed

	if ARTime > 1200 then
		ARRate = 5 - (ARTime - 1200)*5/600
	else
		ARRate = 5 + (1200 - ARTime)*5/750
	end
	
	-- Mod multiplier process

	if ModData.FL then
		AccMulti *= 1.02
	else
		FLValue = 0
	end
	
	if ModData.NF then
		GlobalMultiplier *= math.max(0.90, 1.0 - 0.02 * (MaxOnly and 0 or AccuracyData.miss))
	end
	
	if ModData.HD then
		AimMulti *= 1 + 0.04 * (12 - ARRate)
		SpeedMulti *= 1 + 0.04 * (12 - ARRate)
		AccMulti *= 1.08
	end

	if ModData.NS then
		AccuracyNoteCount += SLCount
		local Ratio = 1-(SLCount/ObjectCount)
		local AimNerf = 0.75
		local SpeedNerf = 0.95

		local SLAimNerf = AimNerf + (1 - AimNerf) * Ratio
		local SLSpeedNerf = SpeedNerf + (1 - SpeedNerf) * Ratio


		AimMulti *= SLAimNerf
		SpeedMulti *= SLSpeedNerf
	end
	
	
	local LengthBonus = 0.95 + 0.4 * math.min(1,ObjectCount/2000) + ((ObjectCount > 2000 and math.log10(ObjectCount/2000) * 0.5) or 0)
	local RewardedAimPS = basePerformance(AimValue) * LengthBonus * (0.98 + math.pow(ODRate, 2) / 2500)
	local RewardedSpeedPS = basePerformance(SpeedValue) * LengthBonus * (0.95 + math.pow(ODRate,2)/750)
	local RewardedAccPS = math.pow(1.52163,ODRate) * 2.83 * math.min(1.15,math.pow(AccuracyNoteCount/1000,0.3))
	local RewardedFlashlightPS = basePerformanceFL(FLValue) * ((0.7 + 0.1 * math.min(1,ObjectCount/200)) + (ObjectCount > 200 and (0.2 * math.min(1, (ObjectCount-200)/200)) or 0) * (0.98 + math.pow(ODRate,2)/2500))
	
	local RewardedTDAimPS = basePerformance(math.pow(AimValue, 0.8)) * LengthBonus * (0.98 + math.pow(ODRate, 2) / 2500)
	local RewardedTDFlashlightPS = basePerformanceFL(math.pow(FLValue, 0.8)) * ((0.7 + 0.1 * math.min(1,ObjectCount/200)) + (ObjectCount > 200 and (0.2 * math.min(1, (ObjectCount-200)/200)) or 0) * (0.98 + math.pow(ODRate,2)/2500))
	
	if not ModData.FL then
		RewardedFlashlightPS = 0
	end
	
	local OriginalPS = 1.15 * ((RewardedAimPS^1.1+RewardedSpeedPS^1.1+RewardedAccPS^1.1+RewardedFlashlightPS^1.1)^(1/1.1))
	RewardedAimPS *= AimMulti
	RewardedTDAimPS *= AimMulti
	RewardedSpeedPS *= SpeedMulti
	RewardedAccPS *= AccMulti
	RewardedFlashlightPS *= FLMulti
	RewardedTDFlashlightPS *= FLMulti
	
	local MaxPossiblePSWithTD = 1.15 * GlobalMultiplier * (((RewardedTDAimPS)^1.1+
		(RewardedSpeedPS)^1.1+
		(RewardedAccPS)^1.1+
		(RewardedTDFlashlightPS)^1.1)^(1/1.1))
	local MaxPossiblePS = 1.15 * GlobalMultiplier * ((RewardedAimPS^1.1+RewardedSpeedPS^1.1+RewardedAccPS^1.1+RewardedFlashlightPS^1.1)^(1/1.1))
	
	local MaxPSData = {
		Aim = RewardedAimPS,
		Speed = RewardedSpeedPS,
		Acc = RewardedAccPS,
		FlashLight = RewardedFlashlightPS,
		ModEffects = MaxPossiblePS - OriginalPS,
		TouchDevicePS = MaxPossiblePSWithTD,
		MaxTotalPS = MaxPossiblePS
	}
	
	if MaxOnly then
		return MaxPSData
	end
	-- Calculate the actual ps earned
	
	local TotalHit = AccuracyData.hit300 + AccuracyData.hit100 + AccuracyData.hit50 -- exclude miss
	local ActualLengthBonus = 0.95 + 0.4 * math.min(1,TotalHit/2000) + ((TotalHit > 2000 and math.log10(TotalHit/2000) * 0.5) or 0)
	local Accuracy = (AccuracyData.hit300*3 + AccuracyData.hit100 + AccuracyData.hit50*0.5) / ((TotalHit + AccuracyData.miss) * 3)
	local Scaling = TotalHit/ObjectCount
	
	if ModData.TD then
		AimMulti = AimTDMulti
		SpeedMulti = SpeedTDMulti
		FLMulti = FlashlightTDMulti
		AccMulti = AccTDMulti
		MaxPSData.MaxTotalPS = MaxPSData.TouchDevicePS
	end
	
	-- Aim
	local ActualAimPS = 
		basePerformance(AimValue) 
		* ActualLengthBonus * (0.98 + math.pow(ODRate, 2) / 2500) 
		* calculateMissPenalty(AccuracyData, AimDiffStrainCount) 
		* Accuracy
		* AimMulti
	
	-- Speed
	local SpeedDevilationMultiplier = 1
	local totalSuccessfulHits = AccuracyData.hit300 + AccuracyData.hit100 + AccuracyData.hit50
	local SpeedDevilation = calculateSpeedDeviation(Hit300Time, Hit100Time, Hit50Time, totalSuccessfulHits, SpeedRelevantNoteCount, AccuracyData.hit300, AccuracyData.hit100, AccuracyData.hit50, AccuracyData.miss)
	if not SpeedDevilation then
		SpeedDevilationMultiplier = 0
	end
	local speedHighDeviationMultiplier = math.min(1, calculateSpeedHighDeviationNerf(SpeedDevilation, SpeedValue))
	
	local NoteCountScaling = (TotalHit + AccuracyData.miss)/ObjectCount
	SpeedRelevantNoteCount *= NoteCountScaling
	local relevantTotalDiff = math.max(0, TotalHit - SpeedRelevantNoteCount)
	local relevantCount300 = math.max(0, AccuracyData.hit300 - relevantTotalDiff) 
	local relevantCount100 = math.max(0, AccuracyData.hit100 - math.max(0, relevantTotalDiff - AccuracyData.hit300)) 
	local relevantCount50 = math.max(0, AccuracyData.hit50 - math.max(0, relevantTotalDiff - AccuracyData.hit300 - AccuracyData.hit100)) 
	local RelevantAcc = (relevantCount300 * 6.0 + relevantCount100 * 2.0 + relevantCount50) / (SpeedRelevantNoteCount * 6.0)
	local ActualSpeedPS =
		basePerformance(SpeedValue) 
		* ActualLengthBonus 
		* (0.95 + math.pow(ODRate,2)/750)
		* calculateMissPenalty(AccuracyData, SpeedDiffStrainCount) 
		* math.pow((Accuracy + RelevantAcc) / 2, (14.5 - ODRate) / 2)
		* math.pow(0.99, (AccuracyData.hit50 < TotalHit / 500) and 0 or AccuracyData.hit50 - TotalHit / 500)
		* SpeedMulti
		* SpeedDevilationMultiplier
		* speedHighDeviationMultiplier
	
	-- Accuracy
	local betterAccuracyPercentage = ((AccuracyData.hit300 - (TotalHit - AccuracyNoteCount)) * 6 + AccuracyData.hit100 * 2 + AccuracyData.hit50) / (AccuracyNoteCount * 6)
	local ActualAccPS = math.pow(1.52163,ODRate) 
		* 2.83 
		* math.pow(betterAccuracyPercentage, 24)
		* math.min(1.15,math.pow(AccuracyNoteCount/1000,0.3))
		* AccMulti
		* Scaling
	
	-- Flashlight
	local ActualFlashlightPS = 
		basePerformanceFL(FLValue)
		* ((AccuracyData.miss > 0 and (0.97 * math.pow(1 - math.pow((AccuracyData.miss / TotalHit), 0.775), math.pow(AccuracyData.miss, 0.875))) or 1))
		* (0.7 + 0.1 * math.min(1,ObjectCount/200) + (ObjectCount > 200 and (0.2 * math.min(1, (ObjectCount-200)/200)) or 0) )
		* (0.5 + Accuracy/2)
		* (0.98 + math.pow(ODRate,2)/2500)
		* FLMulti
	
	
	local ActualTotalPS = 1.15 
		* GlobalMultiplier
		* ((ActualAimPS^1.1+ActualSpeedPS^1.1+ActualAccPS^1.1+ActualFlashlightPS^1.1)^(1/1.1))
	
	local ActualTotalPS_BeforeMod = 1.15 
		* (((ActualAimPS/AimMulti)^1.1+(ActualSpeedPS/SpeedMulti)^1.1+(ActualAccPS/AccMulti)^1.1+(ActualFlashlightPS/FLMulti)^1.1)^(1/1.1))
	
	local ActualPSData = {
		Aim = ActualAimPS,
		Speed = ActualSpeedPS,
		Acc = ActualAccPS,
		ActualTotalPS = ActualTotalPS,
		FlashLight = ActualFlashlightPS,
		ModEffects = ActualTotalPS - ActualTotalPS_BeforeMod
	}
	
	return ActualPSData, MaxPSData -- return both the actual perfomance and max perfomance
end
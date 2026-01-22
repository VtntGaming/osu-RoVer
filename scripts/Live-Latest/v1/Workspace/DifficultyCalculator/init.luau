--[LOCATION]:[Workspace.DifficultyCalculator]
--!strict
-- Credited the osu! team on the github for the difficulty calculator and preprocessing
-- Even though I have to transfer code from C# to lua all by myself
-- The calculator might different compare to the original one

local workspace = game:GetService("Workspace")
local basePerfomance = require(workspace.PerformanceCalculator.BasePerfomance)
local basePerfomanceFL = require(workspace.PerformanceCalculator.BasePerfomanceFL)
local evaluator = require(script.DifficultyEvaluator)
local StrainSkills = require(script.StrainSkills)
local modData = require(workspace.ModData)

local perfomance_base_multiplier = 1.12
local difficulty_multiplier = 0.0675
local normalised_expoment = 1.1

local calculator = {}

function sortPeak(data:{number})
	table.sort(data,function(a,b) return a>b end)
end

function sortStrain(data:{{number}})
	table.sort(data,function(a,b) return a[1]>b[1] end)
end

function lerp(a:number,b:number,r:number)
	return a + (b-a)*r
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
	
	table.sort(StrainData, function(a,b)
		return a[2] < b[2]	-- Sort the timing to be perfect
	end)
	
	local StrainPeak = StrainSkills.GetStrainPeak(StrainData, strainType)
	
	sortPeak(StrainPeak)

	for i = 1, #StrainPeak do
		local scale = math.log10(math.lerp(1,10,math.clamp((i-1)/reducedSelectionCount,0,1)))
		StrainPeak[i] *= math.lerp(ReducedStrainBaseline, 1, scale)
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

function calculator.FLDifficultyValue(StrainData:{{number}})
	table.sort(StrainData, function(a,b)
		return a[2] < b[2]	-- Sort the timing to be perfect
	end)
	local StrainPeak = StrainSkills.GetStrainPeak(StrainData, "Flashlight")
	
	-- Since flashlight sum all the value so no need to sort
	
	local difficulty = 0
	for i = 1, #StrainPeak do
		local strain = StrainPeak[i]
		difficulty += strain
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
		local scale = math.log10(lerp(1,10,math.clamp((i-1)/reducedSelectionCount,0,1)))
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
	for i = 1, #strainData do
		local strain = strainData[i]
		relevantNoteCount += 1 / (1 + math.exp(-(strain[1]/maxStrain * 12 - 6)))
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
	for i = 1, #strainData do
		local strain = strainData[i]
		strainCount += 1.1 / (1 + math.exp(-10 * (strain[1] / consistenTopStrain - 0.88)))
	end
	
	return strainCount
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
	for i = 1, #strainData do
		local strain = strainData[i]
		strainDiff += 1 / (1 + math.exp(-(strain[1]/maxSLStrain * 12 - 6)))
	end
	
	return strainDiff
end

export type Data = {
	AimStrain:{{number}},
	AimSLStrain:{{number}},
	SpeedStrain:{{number}},
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
	SpeedNoteCount:number,
	FlashlightDifficulty:number,
	AimDifficultStrainCount:number,
	SpeedDifficultStrainCount:number
}

function calculateDifficultyRatingBase(value)
	return math.sqrt(value) * difficulty_multiplier
end

function calculateStarRating(basePerfomance: number)
	return math.pow(basePerfomance * perfomance_base_multiplier, 1/3)
end
function calculator.CalculateVisibilityBonus(modData:ModData, AR:number, visibilityFactor:number)
	if not visibilityFactor then
		visibilityFactor = 1
	end
	
	local isAlwayParticallyVisible = true
	
	local readingBonus = 0.04 * (12 - math.max(AR, 7))
	readingBonus *= visibilityFactor

	if AR < 7 then
		readingBonus += (isAlwayParticallyVisible and 0.03 or 0.045) * (7 - math.max(AR , 0))
	end
	
	if AR < 0 then
		readingBonus += (isAlwayParticallyVisible and 0.075 or 0.1) * (1 - math.pow(1.5, AR))
	end
	
	return readingBonus
end

function calculateAimVisibilityFactor(AR:number, attributes)
	local ar_factor_end_point = 11.5
	
	local mechanicalDifficultyFactor = evaluator.ReverseLerp(attributes.mechanicalDifficultyRating, 5, 10)
	local arFactorStartingPoint = lerp(9, 10.33, mechanicalDifficultyFactor)
	
	return evaluator.ReverseLerp(AR, ar_factor_end_point, arFactorStartingPoint)
end

function calculateSpeedVisibilityFactor(AR:number, attributes)
	local ar_factor_end_point = 11.5

	local mechanicalDifficultyFactor = evaluator.ReverseLerp(attributes.mechanicalDifficultyRating, 5, 10)
	local arFactorStartingPoint = lerp(10, 10.33, mechanicalDifficultyFactor)

	return evaluator.ReverseLerp(AR, ar_factor_end_point, arFactorStartingPoint)
end

function calculator.ComputeAimRating(aimDifficultyValue:number, modData:ModData, totalHit:number, AR:number, OD:number, attributes)
	if modData.AP then
		return 0
	end
	
	local aimRating = calculateDifficultyRatingBase(aimDifficultyValue)
	
	if modData.TD then
		aimRating = math.pow(aimRating, 0.8)
	end
	
	if modData.RX then
		aimRating *= 0.9
	end
	
	if modData.MG and modData.MG.Active then
		local magnetisedStrength = modData.MG.Strength or 0
		aimRating *= 1 - magnetisedStrength
	end
	
	local ratingMultiplier = 1
	local ARLengthBonus = 0.95 + 0.4 * math.min(1 , totalHit / 2000) + (totalHit > 2000 and math.log10(totalHit/2000) * 0.5 or 0)
	local ARFactor = 0
	
	if AR > 10.33 then
		ARFactor = 0.3 * (AR - 10.33)
	elseif AR < 8 then
		ARFactor = 0.05 * (8 - AR)
	end
	
	if modData.RX then
		ARFactor = 0
	end
	
	ratingMultiplier += ARFactor * ARLengthBonus
	
	if modData.HD then
		local visibilityFactor = calculateAimVisibilityFactor(AR, attributes)
		ratingMultiplier += calculator.CalculateVisibilityBonus(modData, AR, visibilityFactor)
	end
		
	-- Apply the OD difficulty to the aim rating
	ratingMultiplier *= 0.98 + math.pow(math.max(0, OD), 2) / 2500
	return aimRating * math.pow(ratingMultiplier, 1/3)
end

function calculator.ComputeSpeedRating(speedDifficultyValue:number, modData:ModData, totalHit:number, AR:number, OD:number, attributes)
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
	
	local ratingMultiplier = 1
	local ARLengthBonus = 0.95 + 0.4 * math.min(1 , totalHit / 2000) + (totalHit > 2000 and math.log10(totalHit/2000) * 0.5 or 0)
	local ARFactor = 0
	
	if AR > 10.33 then
		ARFactor = 0.3 * (AR - 10.33)
	end
	
	if modData.AP then
		ARFactor = 0
	end
	
	ratingMultiplier += ARFactor * ARLengthBonus
	
	if modData.HD then
		local visibilityFactor = calculateSpeedVisibilityFactor(AR, attributes)
		ratingMultiplier *= 1 + calculator.CalculateVisibilityBonus(modData, AR, visibilityFactor)
	end
	
	ratingMultiplier *= 0.95 + math.pow(math.max(0, OD), 2)/750
	
	return speedRating * math.pow(ratingMultiplier, 1/3)
end

function calculator.ComputeFlashlightRating(flashlightDifficultyValue:number, modData:ModData, totalHit:number, AR:number, OD:number, attributes)
	local flRating = calculateDifficultyRatingBase(flashlightDifficultyValue)
	
	if not modData.FL then
		return 0
	end
	
	if modData.TD then
		flRating = math.pow(flRating, 0.8)
	end
	
	if modData.RX then
		flRating = 0.7
	end
	
	if modData.MG then
		local magnetisedStrength = modData.MG.Strength or 0
		flRating *= 1 - magnetisedStrength
	end
	
	-- TODO: Add deflate mod
	--if modData.DF then	
	--end
	
	local ratingMultiplier = 1
	ratingMultiplier *= 0.7 + 0.1 * math.min(1.0, totalHit / 200.0) +
		(totalHit > 200 and (0.2 * math.min(1.0, (totalHit - 200) / 200.0)) or 0.0)
	
	ratingMultiplier *= 0.98 + math.pow(math.max(0, OD), 2) / 2500
	
	return flRating * math.sqrt(ratingMultiplier)
end

function calculateMechanicalDifficultyRating(aimValue: number, speedValue: number): number
	
	local totalValue = math.pow(aimValue ^ 1.1 + speedValue ^ 1.1, 1/1.1)
	
	return calculateStarRating(totalValue)
end

function calculateDifficultyMultiplier(modData:ModData, totalHits:number, spinnerCount:number)
	local multiplier = perfomance_base_multiplier
	if modData.SO and totalHits > 0 then
		multiplier *= 1 - math.pow(spinnerCount / totalHits, 0.85)
	end
	
	return multiplier
end

function calculator.GetDifficultyAttributes(data:Data):DifficultyAttributes
	local speedNotes = calculator.RelevantNoteCount(data.SpeedStrain)
	
	local aimDiffStrainCount = calculator.CountTopWeightedStrains(data.AimStrain, "Aim")
	local speedDiffStrainCount = calculator.CountTopWeightedStrains(data.SpeedStrain, "Speed")
	
	local difficultSliders = calculator.getDificultSliders(data.AimSLStrain)
	
	local ARRate = data.DifficultyValue.AR
	local ODRate = data.DifficultyValue.OD
	
	local aimDifficultyValue = calculator.DifficultyValue(data.AimStrain, "Aim")
	local speedDifficultyValue = calculator.DifficultyValue(data.SpeedStrain, "Speed")
	local flashlightDifficultyValue = calculator.FLDifficultyValue(data.FlashlightStrain)
	
	local mechanicalDifficultyRating = calculateMechanicalDifficultyRating(aimDifficultyValue, speedDifficultyValue)
	
	local aimRating = calculator.ComputeAimRating(aimDifficultyValue, data.ModData, data. NoteCount.Total, ARRate, ODRate, {mechanicalDifficultyRating = mechanicalDifficultyRating})
	local speedRating = calculator.ComputeSpeedRating(speedDifficultyValue, data.ModData, data. NoteCount.Total, ARRate, ODRate, {mechanicalDifficultyRating = mechanicalDifficultyRating})
	local flashlightRating = calculator.ComputeFlashlightRating(flashlightDifficultyValue, data.ModData, data.NoteCount.Total, ARRate, ODRate, {})
	
	local aimBasePerfomance = basePerfomance(aimRating)
	local speedBasePerfomance = basePerfomance(speedRating)
	local flashlightBasePerfomance = basePerfomanceFL(flashlightRating)
	
	local basePerfomance = math.pow(
		aimBasePerfomance ^ 1.1 + speedBasePerfomance ^ 1.1 + flashlightBasePerfomance ^ 1.1, 1 / 1.1
	)
	
	-- local multiplier = calculateDifficultyMultiplier(data.ModData, data.NoteCount.Total, data.NoteCount.Spinner)
	local starRating = calculateStarRating(basePerfomance)
	
	local Attributes = {
		StarRating = starRating,
		AimDifficulty = aimRating,
		AimDifficultySliderCount = difficultSliders,
		SpeedDifficulty = speedRating,
		SpeedNoteCount = speedNotes,
		FlashlightDifficulty = flashlightRating,
		AimDifficultStrainCount = aimDiffStrainCount,
		SpeedDifficultStrainCount = speedDiffStrainCount
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
	local mechanicalDifficultyRating = calculateMechanicalDifficultyRating(aimDifficultyValue, speedDifficultyValue)
	
	local aimRating = calculator.ComputeAimRating(aimDifficultyValue, Attributes.ModData, Attributes.NoteCount.Total, Attributes.ARRate, Attributes.ODRate, {mechanicalDifficultyRating = mechanicalDifficultyRating})
	local speedRating = calculator.ComputeSpeedRating(speedDifficultyValue, Attributes.ModData, Attributes.NoteCount.Total, Attributes.ARRate, Attributes.ODRate, {mechanicalDifficultyRating = mechanicalDifficultyRating})
	local flashlightRating = calculator.ComputeFlashlightRating(flashlightDifficultyValue, Attributes.ModData, Attributes.NoteCount.Total, Attributes.ARRate, Attributes.ODRate, {})
	
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
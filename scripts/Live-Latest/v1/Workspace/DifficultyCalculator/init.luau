--[LOCATION]:[Workspace.DifficultyCalculator]
--!strict
-- Credited the osu! team on the github for the difficulty calculator and preprocessing
-- Even though I have to transfer code from C# to lua all by myself
-- The calculator might different compare to the original one

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local workspace = game:GetService("Workspace")

local BasePerformance = require(Workspace.PerformanceCalculator.BasePerformance)
local converterTools = require(workspace.OsuConvert.converterTools)
local evaluator = require(script.DifficultyEvaluator)
local DifficultyCalculationUtils = require(script.DifficultyEvaluator.DifficultyCalculationUtils)
local _DifficultyCalculationUtils = DifficultyCalculationUtils -- suppress unused warning
local RatingCalculator = require(script.RatingCalculator)
local StrainSkills = require(script.StrainSkills)
local DifficultyHitObjects = require(Workspace.DifficultyCalculator.DifficultyHitObjects)
local AimSkillModule = require(Workspace.DifficultyCalculator.Skills.OsuSkill.Aim)
local SpeedSkillModule = require(Workspace.DifficultyCalculator.Skills.OsuSkill.Speed)
local ReadingSkillModule = require(Workspace.DifficultyCalculator.Skills.OsuSkill.Reading)
local FlashlightSkillModule = require(Workspace.DifficultyCalculator.Skills.OsuSkill.Flashlight)
local modData = require(workspace.ModData)

-- Cache math functions for performance
local math_pow = math.pow
local math_max = math.max
local _math_min = math.min
-- local math_sqrt = math.sqrt
local math_log10 = math.log10
local math_exp = math.exp
local math_clamp = math.clamp
local math_lerp = math.lerp


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

local HarmonicScale = 1
local DecayExponent = 0.9

local SpeedHarmonicScale = 20
local SpeedDecayExponent = 0.85

local function calculateReadingReducedNoteCount(objectList: {{number}}):number
	local reducedDifficultyDuration = 60 * 1000

    if #objectList == 0 then
        return 0
    end

    local reducedDuration = objectList[1][2] + reducedDifficultyDuration
    local reducedNoteCount = 0

    for i = 1, #objectList do
        if objectList[i][2] > reducedDuration then
            break
        end
        reducedNoteCount += 1
    end

    return reducedNoteCount
end

function calculator.ApplyDifficultyTransformation(StrainData: {{number}}, type: string)
	if type == "Reading" then
		local reducedDifficultyBaseline = 0.0

		local reducedNoteCount = calculateReadingReducedNoteCount(StrainData)
		local limit = math.min(#StrainData, reducedNoteCount)

		for i = 1, limit do
			local scale = math.log10(1 + (10 - 1) * math.clamp((i - 1) / reducedNoteCount, 0, 1))
			StrainData[i][1] *= reducedDifficultyBaseline + (1.0 - reducedDifficultyBaseline) * scale
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
	-- Legacy: kept for compatibility; use Speed skill's RelevantNoteCount() for new code
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

-- CountTopWeightedStrains: removed (replaced by Aim skill's CountTopWeightedStrains)
-- CountTopWeightedDifficultyHarmonic: removed (replaced by Speed/Reading skill's CountTopWeightedObjectDifficulties)
-- getDificultSliders: removed (replaced by Aim skill's GetDifficultSliders)

export type Data = {
	HitObjects: {DifficultyHitObjects.ObjectData},
	BaseObjects: {any},
	IncludeSliders: boolean,
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
	local mods = data.ModData
	local ARRate = data.DifficultyValue.AR
	local ODRate = data.DifficultyValue.OD

	-- Timeline
	local difficultyTimeline = {}
	local timelineRecordEnabled = RunService:IsRunning()

	-- Create skill instances
	local aimSkill = AimSkillModule.new(mods, data.IncludeSliders)
	local speedSkill = SpeedSkillModule.new(mods)
	local readingSkill = ReadingSkillModule.new(mods)
	local flashlightSkill = mods.FL and FlashlightSkillModule.new(mods) or nil

	-- Process all hit objects through each skill
	local hitObjects = data.HitObjects
	for i = 1, #hitObjects do
		local current = hitObjects[i]
		local aimValue = aimSkill:Process(current)
		local speedValue = speedSkill:Process(current)
		local readingValue = readingSkill:Process(current)
		local ms = current.AdjustedDeltaTime
		local dt = current.DeltaTime
		local flValue = 0
		if flashlightSkill then
			flashlightSkill:Process(current)
		end

		local relatedObject = data.BaseObjects[i]

		if relatedObject then
			relatedObject.PSValue = {
				Aim = aimValue, 
				Speed = speedValue,
				Reading = readingValue,
				Flashlight = flValue, 
				AimStrainDecay = aimSkill:strainDecay(ms), 
				SpeedStrainDecay = speedSkill:strainDecay(ms), 
				ReadingStrainDecay = readingSkill:strainDecay(dt),
				FLStrainDecay = flashlightSkill and flashlightSkill:strainDecay(ms) or 0,
			}
		end

		if timelineRecordEnabled then
			local liveDiff = StrainSkills.CalculateCurrentStrainRating(aimValue, speedValue, readingValue, flValue)
			local diffData = {
				Time = current.Time,
				Value = liveDiff
			}
			difficultyTimeline[#difficultyTimeline + 1] = diffData
		end
	end

	-- Get difficulty values from skills
	local aimDifficultyValue = aimSkill:DifficultyValue()
	local speedDifficultyValue = speedSkill:DifficultyValue()
	local readingDifficultyValue = readingSkill:DifficultyValue()
	local flashlightDifficultyValue = flashlightSkill and flashlightSkill:DifficultyValue() or 0

	-- Get strain/note counts
	local difficultSliders = aimSkill:GetDifficultSliders()
	local speedNotes = speedSkill:RelevantNoteCount()
	local aimDiffStrainCount = aimSkill:CountTopWeightedStrains(aimDifficultyValue)
	local speedDiffStrainCount = speedSkill:CountTopWeightedObjectDifficulties(speedDifficultyValue)
	local readingDiffStrainCount = readingSkill:CountTopWeightedObjectDifficulties(readingDifficultyValue)

	-- Compute ratings
	local aimRating = RatingCalculator.ComputeAimRating(aimDifficultyValue, mods, data.NoteCount.Total, ARRate, ODRate)
	local speedRating = RatingCalculator.ComputeSpeedRating(speedDifficultyValue, mods, data.NoteCount.Total, ARRate, ODRate)
	local flashlightRating = RatingCalculator.ComputeFlashlightRating(flashlightDifficultyValue, mods, data.NoteCount.Total, ARRate, ODRate)
	local readingRating = RatingCalculator.ComputeReadingRating(readingDifficultyValue, mods, ODRate)

	-- Compute base performances
	local aimBasePerformance = BasePerformance.DifficultyToPerformance(aimRating)
	local speedBasePerformance = BasePerformance.DifficultyToPerformance(speedRating)
	local readingBasePerformance = BasePerformance.DifficultyToPerformance(readingRating)
	local flashlightBasePerformance = BasePerformance.DifficultyToPerformanceFL(flashlightRating)
	local baseCognitionPerformance = calculator.SumCognitionDifficulty(readingBasePerformance, flashlightBasePerformance)

	local basePerformance = evaluator.Normalise(normalised_expoment, aimBasePerformance, speedBasePerformance, baseCognitionPerformance)
	local starRating = calculator.CalculateStarRating(basePerformance)

	return {
		StarRating = starRating,
		AimDifficulty = aimRating,
		AimDifficultySliderCount = difficultSliders,
		SpeedDifficulty = speedRating,
		ReadingDifficulty = readingRating,
		SpeedNoteCount = speedNotes,
		FlashlightDifficulty = flashlightRating,
		AimDifficultStrainCount = aimDiffStrainCount,
		SpeedDifficultStrainCount = speedDiffStrainCount,
		ReadingDifficultStrainCount = readingDiffStrainCount,
		DifficultyTimeline = difficultyTimeline
	}
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
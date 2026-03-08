--[LOCATION]:[Workspace.DifficultyCalculator.StrainSkills]
--!strict
local Workspace = game:GetService("Workspace")

local DifficultyEvaluator = require(script.Parent.DifficultyEvaluator)
local ModData = require(Workspace.ModData)
local BasePerfomance = require(Workspace.PerformanceCalculator.BasePerfomance)
local StrainSkills = {}

-- Cache math functions
local math_pow = math.pow
local math_max = math.max
local math_ceil = math.ceil
-- local table_sort = table.sort

local SECTION_LENGTH = 400
local STRAIN_DECAY_AIMFL = 0.15
local STRAIN_DECAY_SPEED = 0.30
local MINIMUM_DELTA_TIME = 25

function StrainSkills.StrainDecay(t:number, _type:string):number
	t = math_max(t, MINIMUM_DELTA_TIME)
	local _decayRate = _type == "Speed" and STRAIN_DECAY_SPEED or STRAIN_DECAY_AIMFL
	
	return math_pow(_decayRate, t/1000)
end

StrainSkills.CalculateInitialStrain = {
	Default = function(t:number, strain:{number})
		return strain[1] * StrainSkills.StrainDecay(t, "Aim")
	end,	
	AimSpeed = function(t:number, strain:{number}, previousTime:number, strainType:string)
		return strain[1] * StrainSkills.StrainDecay(math_max(0, t - previousTime), strainType)
	end,
}

local function saveCurrentPeak(strainPeak: {number}, currentSectionPeak: number)
	strainPeak[#strainPeak + 1] = currentSectionPeak
end

function StrainSkills.GetStrainPeak(strainData:{{number}}, strainType:string):{number}
	local StrainPeak:{number} = {}
	local _sectionLength = SECTION_LENGTH
	local _currentSectionEnd = 0
	local _currentSectionPeak = 0
	local strainCount = #strainData
	
	for i = 1, strainCount do
		local strain = strainData[i]
		local strainTime = strain[2]
		if i == 1 then
			_currentSectionEnd = math_ceil(strainTime/_sectionLength) * _sectionLength
		end
		
		while strainTime > _currentSectionEnd do
			local previousTime = 0
			if i > 1 then
				previousTime = strainData[i-1][2]
			end
			saveCurrentPeak(StrainPeak, _currentSectionPeak)
			-- Start new section
			local _initialStrain = StrainSkills.CalculateInitialStrain.AimSpeed(_currentSectionEnd, strain, previousTime, strainType)
			_currentSectionPeak = _initialStrain
			_currentSectionEnd += _sectionLength
		end
		
		local strainValue = strain[1]
		if strainValue > _currentSectionPeak then
			_currentSectionPeak = strainValue
		end
	end
	
	saveCurrentPeak(StrainPeak, _currentSectionPeak)
	
	local FilteredPeaks = {}
	local filteredCount = 0
	-- We need to filters out zero strain for the worst case senario
	for i = 1, #StrainPeak do
		local strain = StrainPeak[i]
		if strain > 0 then
			filteredCount += 1
			FilteredPeaks[filteredCount] = strain
		end
	end
	
	return FilteredPeaks
end

-- Sometime it would not be very easy to match everything with osu! difficulty system
-- I need to adjust it back to the original osu!standard
local aimAdjustedMultiplier = 1
local speedAimAdjustedMultiplier = 1
local totalAdjustedMultiplier = 1
local speedAdjustedMultiplier = 1
local aimSkillMultiplier = 65.2 * aimAdjustedMultiplier
local speedAimSkillMultiplier = 2.8 * speedAimAdjustedMultiplier
local skillMultiplierTotal = 1 * totalAdjustedMultiplier
local speedSkillMultiplier = 1.07 * speedAdjustedMultiplier
local readingSkillMultiplier = 2.5
local meanExpoment = 1.2
local flashlightSkillMultiplier = 0.056

local AimFLBaseStrainDecay = 0.15
local SpeedBaseStrainDecay = 0.3
local ReadingBaseStrainDecay = 0.8

local DIFFICULTY_VALUE_EXPOMENTAL_RATE = 1/3
local DIFFICULTY_VALUE_MULTIPLIER_RATE = 0.265
local DIFFICULTY_VALUE_AIM_MULTIPLIER = 1
local DIFFICULTY_VALUE_SPEED_MULTIPLIER = 1
local EvaluatorContainer = script.Parent.DifficultyEvaluator
local Evaluators = {
	Aim = require(EvaluatorContainer.AimEvaluator),
	SpeedAim = (require(EvaluatorContainer.SpeedAimEvalulator)),
	Speed = require(EvaluatorContainer.SpeedEvaluator),
	Rhythm = require(EvaluatorContainer.RhythmCalculator),
	Flashlight = require(EvaluatorContainer.FLEvaluator),
	Reading = require(EvaluatorContainer.ReadingEvaluator)
}

function StrainSkills.InitializeStrains(ProcessedDifficultyObject, modData: ModData.ModData, ConvertedData, RawDifficulty)	
	local AimStrain = 0
	local SpeedAimStrain = 0
	local SpeedStrain = 0
	local ReadingStrain = 0
	local FLStrain = 0
	
	local AimStrainData = {}
	local AimSLStrainData = {}
	local SpeedStrainData = {}
	local ReadingStrainData = {}
	local FLStrainData = {}
	
	-- Pre-compute mod flags
	local isTD = modData.TD
	local isFL = modData.FL
	local isHD = modData.HD or false
	local isRX = modData.RX
	
	-- Pre-access evaluators
	local EvaluatorAim = Evaluators.Aim
	local EvaluatorSpeedAim = Evaluators.SpeedAim
	local EvaluatorSpeed = Evaluators.Speed
	local EvaluatorRhythm = Evaluators.Rhythm
	local EvaluatorReading = Evaluators.Reading
	local EvaluatorFlashlight = Evaluators.Flashlight
	
	local objectCount = #ProcessedDifficultyObject
	local aimIdx, aimSLIdx, speedIdx, readingIdx, rhythmIdx, flIdx, rawIdx = 0, 0, 0, 0, 0, 0, 0
	
	for objectId = 1, objectCount do
		local objectData = ProcessedDifficultyObject[objectId]
		local strainTime = objectData.StrainTime
		local objectTime = objectData.Time
		
		local AimDiff = EvaluatorAim.GetAimDiff(objectData) * aimSkillMultiplier
		local SpeedAimDiff = EvaluatorSpeedAim.GetSpeedAimDiff(objectData) * speedAimSkillMultiplier
		local SpeedDiff = EvaluatorSpeed.GetSpeedDiff(objectData) * speedSkillMultiplier
		local RhythmDiff = EvaluatorRhythm.GetRhythmDiff(objectData)
		local ReadingDiff = EvaluatorReading.GetReadingDiff(objectData, isHD) * readingSkillMultiplier
		local FLDiff = isFL and EvaluatorFlashlight.getFlashLightDiff(objectData, isHD) * flashlightSkillMultiplier or 0
		
		local strainTimeDiv1000 = strainTime / 1000
		local AimFLStrainDecay = math_pow(AimFLBaseStrainDecay, strainTimeDiv1000)
		local SpeedStrainDecay = math_pow(SpeedBaseStrainDecay, strainTimeDiv1000)
		local ReadingStrainDecay = math_pow(ReadingBaseStrainDecay, strainTimeDiv1000)

		if isTD then
			AimDiff = math_pow(AimDiff, 0.76)
			SpeedAimDiff = math_pow(SpeedAimDiff, 0.95)
		end

		if isRX then
			SpeedAimDiff = 0
		end

		-- Calculate aim skill
		local oneMinusAimDecay = 1 - AimFLStrainDecay
		AimStrain = AimStrain * AimFLStrainDecay + AimDiff * oneMinusAimDecay
		local oneMinusSpeedDecay = 1 - SpeedStrainDecay
		SpeedAimStrain = (SpeedAimStrain * SpeedStrainDecay + SpeedAimDiff * oneMinusSpeedDecay)
		local AimTotalStrain = DifficultyEvaluator.Normalise(meanExpoment, AimStrain, SpeedAimStrain) * skillMultiplierTotal
		-- Calculate speed diff
		SpeedStrain = SpeedStrain * SpeedStrainDecay + SpeedDiff * oneMinusSpeedDecay
		-- Calculate reading diff
		ReadingStrain = ReadingStrain * ReadingStrainDecay + ReadingDiff
		-- Calculate flash light skill
		FLStrain = FLStrain * AimFLStrainDecay + FLDiff
		
		local PSValue = ConvertedData[objectId].PSValue
		PSValue.Aim = AimDiff
		PSValue.Speed = SpeedDiff
		PSValue.Rhythm = RhythmDiff
		PSValue.Flashlight = FLDiff
		PSValue.AimStrainDecay = AimFLStrainDecay
		PSValue.SpeedStrainDecay = SpeedStrainDecay
		PSValue.FLStrainDecay = AimFLStrainDecay
		
		aimIdx += 1
		speedIdx += 1
		rhythmIdx += 1
		flIdx += 1
		readingIdx += 1
		local speedRhythm = SpeedStrain * RhythmDiff
		AimStrainData[aimIdx] = {AimTotalStrain, objectTime}
		SpeedStrainData[speedIdx] = {speedRhythm, objectTime}
		FLStrainData[flIdx] = {FLStrain, objectTime}
		ReadingStrainData[readingIdx] = {ReadingStrain, objectTime}
		
		if objectData.isSlider then
			aimSLIdx += 1
			AimSLStrainData[aimSLIdx] = {AimTotalStrain, objectTime}
		end		
		
		local baseAim = math_pow(AimStrain * 10, DIFFICULTY_VALUE_EXPOMENTAL_RATE)*DIFFICULTY_VALUE_MULTIPLIER_RATE * DIFFICULTY_VALUE_AIM_MULTIPLIER
		local baseSpeed = math_pow(speedRhythm * 10, DIFFICULTY_VALUE_EXPOMENTAL_RATE)*DIFFICULTY_VALUE_MULTIPLIER_RATE * DIFFICULTY_VALUE_SPEED_MULTIPLIER
		local baseFL = math_pow(FLStrain * 10, DIFFICULTY_VALUE_EXPOMENTAL_RATE)*DIFFICULTY_VALUE_MULTIPLIER_RATE * DIFFICULTY_VALUE_AIM_MULTIPLIER
		local basePerfomance = math_pow(math_pow(BasePerfomance(baseAim), 1.1) + math_pow(BasePerfomance(baseSpeed), 1.1) + math_pow(BasePerfomance(baseFL), 1.1), 1/1.1)
		local CurrentStrain = 0.027 * 1.04768955549 * (math_pow(100000 / 1.86606598308 * basePerfomance, 1/3) + 4)
		CurrentStrain = CurrentStrain < 0 and 0 or (CurrentStrain > 50 and 50 or CurrentStrain)
		
		rawIdx += 1
		RawDifficulty[rawIdx] = {CurrentStrain, objectTime}
	end

	return AimStrainData, AimSLStrainData, SpeedStrainData, FLStrainData, ReadingStrainData
end

return StrainSkills
--[LOCATION]:[Workspace.DifficultyCalculator.StrainSkills]
--!strict
local Workspace = game:GetService("Workspace")

local DifficultyEvaluator = require(script.Parent.DifficultyEvaluator)
local ModData = require(Workspace.ModData)
local BasePerfomance = require(Workspace.PerformanceCalculator.BasePerfomance)
local StrainSkills = {}

local SECTION_LENGTH = 400
local STRAIN_DECAY_AIMFL = 0.15
local STRAIN_DECAY_SPEED = 0.30
local MINIMUM_DELTA_TIME = 25

function StrainSkills.StrainDecay(t:number, _type:string):number
	t = math.max(t, MINIMUM_DELTA_TIME)
	local _decayRate = _type == "Speed" and STRAIN_DECAY_SPEED or STRAIN_DECAY_AIMFL
	
	return math.pow(_decayRate, t/1000)
end

StrainSkills.CalculateInitialStrain = {
	Default = function(t:number, strain:{number})
		return strain[1] * StrainSkills.StrainDecay(t, "Aim")
	end,	
	AimSpeed = function(t:number, strain:{number}, previousTime:number, strainType:string)
		return strain[1] * StrainSkills.StrainDecay(math.max(0, t - previousTime), strainType)
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
	
	for i = 1, #strainData do
		local strain = strainData[i]
		if i == 1 then
			_currentSectionEnd = math.ceil(strain[2]/_sectionLength) * _sectionLength
		end
		
		while strain[2] > _currentSectionEnd do
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
		
		_currentSectionPeak = math.max(strain[1], _currentSectionPeak)
	end
	
	saveCurrentPeak(StrainPeak, _currentSectionPeak)
	
	local FilteredPeaks = {}
	-- We need to filters out zero strain for the worst case senario
	for i = 1, #StrainPeak do
		local strain = StrainPeak[i]
		if strain > 0 then
			FilteredPeaks[#FilteredPeaks + 1] = strain
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
local aimSkillMultiplier = 26 * aimAdjustedMultiplier
local speedAimSkillMultiplier = 1.3 * speedAimAdjustedMultiplier
local speedSkillMultiplier = 1.03 * speedAdjustedMultiplier
local skillMultiplierTotal = 1.01 * totalAdjustedMultiplier
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
	local RhythmDiffData = {}
	local FLStrainData = {}
	for objectId = 1, #ProcessedDifficultyObject do
		local objectData = ProcessedDifficultyObject[objectId]
		local AimDiff = Evaluators.Aim.GetAimDiff(objectData) * aimSkillMultiplier
		local SpeedAimDiff = Evaluators.SpeedAim.GetSpeedAimDiff(objectData) * speedAimSkillMultiplier
		local SpeedDiff = Evaluators.Speed.GetSpeedDiff(objectData) * speedSkillMultiplier
		local RhythmDiff = Evaluators.Rhythm.GetRhythmDiff(objectData)
		local ReadingDiff = Evaluators.Reading.GetReadingDiff(objectData, modData.HD or false) * readingSkillMultiplier
		local FLDiff = modData.FL and Evaluators.Flashlight.getFlashLightDiff(objectData, modData.HD) * flashlightSkillMultiplier or 0
		
		local AimFLStrainDecay = math.pow(AimFLBaseStrainDecay,objectData.StrainTime/1000)
		local SpeedStrainDecay = math.pow(SpeedBaseStrainDecay,objectData.StrainTime/1000)
		local ReadingStrainDecay = math.pow(ReadingBaseStrainDecay,objectData.StrainTime/1000)

		if modData.TD then
			AimDiff = math.pow(AimDiff, 0.8)
			SpeedAimDiff = math.pow(SpeedAimDiff, 0.95)
		end

		-- Calculate aim skill
		AimStrain *= AimFLStrainDecay
		AimStrain += AimDiff * (1 - AimFLStrainDecay)
		SpeedAimStrain *= SpeedStrainDecay
		SpeedAimStrain += SpeedAimDiff * (1 - SpeedStrainDecay)
		local AimTotalStrain = DifficultyEvaluator.Normalise(meanExpoment, AimStrain, SpeedAimStrain) * skillMultiplierTotal
		-- Calculate speed diff
		SpeedStrain *= SpeedStrainDecay
		SpeedStrain += SpeedDiff * (1 - SpeedStrainDecay)
		-- Calculate reading diff
		ReadingStrain *= ReadingStrainDecay
		ReadingStrain += ReadingDiff
		-- Calculate flash light skill
		FLStrain *= AimFLStrainDecay
		FLStrain += FLDiff
		
		ConvertedData[objectId].PSValue.Aim = AimDiff
		ConvertedData[objectId].PSValue.Speed = SpeedDiff
		ConvertedData[objectId].PSValue.Rhythm = RhythmDiff
		ConvertedData[objectId].PSValue.Flashlight = FLDiff
		ConvertedData[objectId].PSValue.AimStrainDecay = AimFLStrainDecay
		ConvertedData[objectId].PSValue.SpeedStrainDecay = SpeedStrainDecay
		ConvertedData[objectId].PSValue.FLStrainDecay = AimFLStrainDecay
		
		AimStrainData[#AimStrainData+1] = {AimTotalStrain, objectData.Time}
		SpeedStrainData[#SpeedStrainData+1] = {SpeedStrain * RhythmDiff, objectData.Time}
		RhythmDiffData[#RhythmDiffData+1] = {RhythmDiff, objectData.Time}
		FLStrainData[#FLStrainData+1] = {FLStrain, objectData.Time}
		ReadingStrainData[#ReadingStrainData+1] = {ReadingStrain, objectData.Time}
		
		if objectData.isSlider then
			AimSLStrainData[#AimSLStrainData+1] = {AimTotalStrain, objectData.Time}
		end		
		
		local multiplierBase = 10
		
		local baseAim = math.pow(AimStrain * multiplierBase, DIFFICULTY_VALUE_EXPOMENTAL_RATE)*DIFFICULTY_VALUE_MULTIPLIER_RATE * DIFFICULTY_VALUE_AIM_MULTIPLIER
		local baseSpeed = math.pow(SpeedStrain * RhythmDiff * multiplierBase, DIFFICULTY_VALUE_EXPOMENTAL_RATE)*DIFFICULTY_VALUE_MULTIPLIER_RATE * DIFFICULTY_VALUE_SPEED_MULTIPLIER
		local baseFL = math.pow(FLStrain * multiplierBase, DIFFICULTY_VALUE_EXPOMENTAL_RATE)*DIFFICULTY_VALUE_MULTIPLIER_RATE * DIFFICULTY_VALUE_AIM_MULTIPLIER
		local basePerfomance = ((BasePerfomance(baseAim)^1.1+BasePerfomance(baseSpeed)^1.1+BasePerfomance(baseFL)^1.1)^(1/1.1))
		local CurrentStrain = 0.027 * math.pow(1.15, 1/3) * (math.pow(100000 / math.pow(2, 1 / 1.1) * basePerfomance ,1/3) + 4)
		CurrentStrain = math.clamp(CurrentStrain, 0, 50) -- to prevent the graph jumping out of the limit, I've set it to 0-50
		
		RawDifficulty[#RawDifficulty+1] = {CurrentStrain,objectData.Time}
	end

	return AimStrainData, AimSLStrainData, SpeedStrainData, RhythmDiffData, FLStrainData, ReadingStrainData
end

return StrainSkills
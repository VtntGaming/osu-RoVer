--[LOCATION]:[StarterGui.PlayScreen.GameplayScripts.Components.Gameplay.LivePlayProcessing]
--!strict
local workspace = game:GetService("Workspace")
local modData = require(workspace.ModData)
local DifficultyCalculator = require(workspace.DifficultyCalculator)
local PerformanceCalculator = require(workspace.PerformanceCalculator)
local StrainSkills = require(workspace.DifficultyCalculator.StrainSkills)
local ConverterTools = require(workspace.OsuConvert.converterTools)
export type PSValue = {
	Aim:number, 
	Speed:number, 
	Rhythm:number, 
	Reading: number,
	Flashlight:number, 
	AimStrainDecay:number, 
	SpeedStrainDecay:number, 
	ReadingStrainDecay: number,
	FLStrainDecay:number
}

export type LivePlayProcessing = {
	new:() -> (LivePlayProcessing),
	__index: LivePlayProcessing,
	-- Variable
	--> Base data
	ModData:modData.ModData,
	CSRate:number,
	ODRate:number,
	ARRate:number,
	HPRate:number,
	NoteCount: {Circle:number, Slider:number, Spinner:number, Total:number},
	AimDiffStrainCount:number,
	SpeedDiffStrainCount:number,
	ReadingDiffStrainCount: number,
	SpeedRelevantNoteCount:number,
	BaseAimDiff:number,
	BaseSpeedDiff:number,
	BaseReadingDiff:number,
	BaseFlashlightDiff:number,
	
	--> Live data
	CurrentLiveDiffAim:number,
	CurrentLiveDiffSpeed:number,
	CurrentLiveDiffReading: number,
	CurrentLiveDiffFL:number,
	LiveDiffLastHit:number,
	AimStrain:{{number}},
	SpeedStrain:{{number}},
	FlashlightStrain:{{number}},
	ObjectData: {
		Speed: {{number}},
		Reading: {{number}}
	},
	StrainPeak:{
		Aim:{number}, Flashlight:{number}
	},
	StrainCurrentPeak:{
		Aim:number, Flashlight:number
	},
	PreviousStrain:{
		Aim:number, Flashlight:number
	},
	CurrentSectionEnd:number,
	PreviousTime:number,
	CurrentStarRating:number,
	AimDiffFinal:number,
	SpeedDiffFinal:number,
	ReadingDiffFinal: number,
	FLDiffFinal:number,
	CurrentPerformance:number,
	IsFirstIndex:boolean,
	
	-- Function
	SetupData:(self:LivePlayProcessing, Attributes:InputAttributes) -> (),
	StartLiveDiffDisplay:(self:LivePlayProcessing) -> (),
	ProcessPerfomanceScore:(self:LivePlayProcessing, PSValue:PSValue?, Timing:number?, AccData:PerformanceCalculator.AccuracyData) -> (),
	_ProcessCurrentStrain:(self:LivePlayProcessing, Timing:number, PSValue:BasePSValue) -> (),
	_SaveCurrentPeak:(self:LivePlayProcessing) -> (),
	_StartNewSection:(self:LivePlayProcessing, Timing:number, Strains:{Aim:number, Flashlight:number}) -> (),
	ProcessFinalResult:(self:LivePlayProcessing, AccData:PerformanceCalculator.AccuracyData) -> (),
}

export type InputAttributes = {
	ModData:modData.ModData,
	ODRate:number,
	ARRate:number,
	NoteCount: {Circle:number, Slider:number, Spinner:number, Total:number},
	AimDiffStrainCount:number,
	SpeedDiffStrainCount:number,
	SpeedRelevantNoteCount:number,
	ReadingDiffStrainCount: number,
	AimDifficulty:number,
	SpeedDifficulty:number,
	ReadingDifficulty:number,
	FlashlightDifficulty:number,
}

type BasePSValue = {
	Aim:number, Flashlight:number
}
local LivePlayProcessing:LivePlayProcessing = {}::LivePlayProcessing
LivePlayProcessing.__index = LivePlayProcessing

local function _SortStrain(data:{number})
	table.sort(data,function(a,b) return a>b end)
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

local function _Append(t:{any}, value:any):{any}
	t = _DeepCopy(t)
	t[#t+1] = value
	return t
end

function LivePlayProcessing.new()
	local self:LivePlayProcessing = setmetatable({} :: any, LivePlayProcessing)
	
	self.CurrentLiveDiffAim = 0
	self.CurrentLiveDiffSpeed = 0
	self.CurrentLiveDiffReading = 0
	self.CurrentLiveDiffFL = 0
	self.LiveDiffLastHit = 0
	self.AimStrain = {}
	self.SpeedStrain = {}
	self.FlashlightStrain = {}
	self.CurrentStarRating = 0
	self.AimDiffFinal = 0
	self.SpeedDiffFinal = 0
	self.ReadingDiffFinal = 0
	self.FLDiffFinal = 0
	self.CurrentPerformance = 0
	-- Strain skills
	self.StrainPeak = {
		Aim	 = {}, Flashlight = {}
	}
	self.StrainCurrentPeak = {
		Aim = 0, Flashlight = 0
	}
	self.PreviousStrain = {
		Aim = 0, Speed = 0, Flashlight = 0, Reading = 0
	}
	-- Speed and reading is Harmonic skill and need separate logic
	self.ObjectData = {
		Speed = {}, Reading = {}
	}
	self.CurrentSectionEnd = 0
	self.PreviousTime = 0
	self.IsFirstIndex = true
	
	return self
end

function LivePlayProcessing:SetupData(Attributes:InputAttributes)
	self.ModData = Attributes.ModData
	self.ODRate = ConverterTools.GetDifficultyValueAfterMod.OD(Attributes.ODRate, Attributes.ModData)
	self.ARRate = ConverterTools.GetDifficultyValueAfterMod.OD(Attributes.ARRate, Attributes.ModData)
	self.NoteCount = Attributes.NoteCount
	self.AimDiffStrainCount = Attributes.AimDiffStrainCount
	self.SpeedDiffStrainCount = Attributes.SpeedDiffStrainCount
	self.SpeedRelevantNoteCount = Attributes.SpeedRelevantNoteCount
	self.ReadingDiffStrainCount = Attributes.ReadingDiffStrainCount
	self.BaseAimDiff = Attributes.AimDifficulty
	self.BaseSpeedDiff = Attributes.SpeedDifficulty
	self.BaseReadingDiff = Attributes.ReadingDifficulty
	self.BaseFlashlightDiff = Attributes.FlashlightDifficulty
end

function LivePlayProcessing:StartLiveDiffDisplay()
	
end

local SECTION_LENGTH = 400

function LivePlayProcessing:_SaveCurrentPeak()
	if self.StrainCurrentPeak.Aim > 0 then
		self.StrainPeak.Aim[#self.StrainPeak.Aim+1] = self.StrainCurrentPeak.Aim
	end
	if self.StrainCurrentPeak.Flashlight > 0 then
		self.StrainPeak.Flashlight[#self.StrainPeak.Flashlight+1] = self.StrainCurrentPeak.Flashlight
	end
end

function LivePlayProcessing:_StartNewSection(Timing:number, Strains:{Aim:number, Flashlight:number})
	self.StrainCurrentPeak.Aim = StrainSkills.CalculateInitialStrain.AimSpeed(Timing, {Strains.Aim}, self.PreviousTime, "Aim")
	self.StrainCurrentPeak.Flashlight = StrainSkills.CalculateInitialStrain.Default(Timing, {Strains.Flashlight})
end

function LivePlayProcessing:_ProcessCurrentStrain(Timing:number, PSValue:BasePSValue)
	if self.IsFirstIndex then
		self.IsFirstIndex = false
		self.CurrentSectionEnd = math.ceil(Timing/SECTION_LENGTH) * SECTION_LENGTH
	end
	
	while Timing > self.CurrentSectionEnd do
		self:_SaveCurrentPeak()
		self:_StartNewSection(self.CurrentSectionEnd, {Aim = PSValue.Aim, Flashlight = PSValue.Flashlight})
		self.CurrentSectionEnd += SECTION_LENGTH
	end
	
	self.StrainCurrentPeak = {
		Aim = math.max(self.StrainCurrentPeak.Aim, PSValue.Aim),
		Flashlight = math.max(self.StrainCurrentPeak.Flashlight, PSValue.Flashlight),
	}
	
	self.PreviousStrain = {
		Aim = PSValue.Aim,
		Flashlight = PSValue.Flashlight,
	}
	
	self.PreviousTime = Timing
end

function LivePlayProcessing:ProcessPerfomanceScore(PSValue:PSValue?, Timing:number?, AccData:PerformanceCalculator.AccuracyData)
	if PSValue and Timing then
		self.CurrentLiveDiffAim *= PSValue.AimStrainDecay
		self.CurrentLiveDiffAim += PSValue.Aim * (1 - PSValue.AimStrainDecay)
		self.CurrentLiveDiffSpeed *= PSValue.SpeedStrainDecay
		self.CurrentLiveDiffSpeed += PSValue.Speed * (1 - PSValue.SpeedStrainDecay)
		self.CurrentLiveDiffReading *= PSValue.ReadingStrainDecay
		self.CurrentLiveDiffReading += PSValue.Reading
		if self.ModData.FL then
			self.CurrentLiveDiffFL *= PSValue.FLStrainDecay
			self.CurrentLiveDiffFL += PSValue.Flashlight
		end
		self.LiveDiffLastHit = os.clock()
		
		self:_ProcessCurrentStrain(Timing,
			{
				Aim = self.CurrentLiveDiffAim,
				Flashlight = self.CurrentLiveDiffFL,
				Rhythm = PSValue.Rhythm,
			}
		)

		-- Harmonic skill processing
		self.ObjectData.Speed[#self.ObjectData.Speed + 1] = {self.CurrentLiveDiffSpeed, Timing}
		self.ObjectData.Reading[#self.ObjectData.Reading + 1] = {self.CurrentLiveDiffReading, Timing}
		
		local _noteCount = {
			Circle = self.NoteCount.Circle,
			Slider = self.NoteCount.Slider,
			Spinner = self.NoteCount.Spinner,
			Total = self.NoteCount.Circle + self.NoteCount.Slider + self.NoteCount.Spinner
		}

		local DifficultyAttributes:DifficultyCalculator.LiveDifficultyAttributes = {
			AimPeak = _Append(self.StrainPeak.Aim, self.StrainCurrentPeak.Aim),
			SpeedObjects = _DeepCopy(self.ObjectData.Speed),
			ReadingObjects = _DeepCopy(self.ObjectData.Reading),
			FLPeak = _Append(self.StrainPeak.Flashlight, self.StrainCurrentPeak.Flashlight),
			ARRate = self.ARRate,
			ODRate = self.ODRate,
			NoteCount = _noteCount,
			ModData = self.ModData
		}

		local Attributes = DifficultyCalculator.GetDifficultyAttributesFromLiveData(DifficultyAttributes)
		self.AimDiffFinal = Attributes.AimDifficulty
		self.SpeedDiffFinal = Attributes.SpeedDifficulty
		self.ReadingDiffFinal = Attributes.ReadingDifficulty
		self.FLDiffFinal = Attributes.FlashlightDifficulty
		self.CurrentStarRating = Attributes.StarRating
	end

	local PSData = PerformanceCalculator(
		self.AimDiffFinal, 
		self.SpeedDiffFinal, 
		self.ReadingDiffFinal,
		self.FLDiffFinal, 
		self.ODRate, 
		self.ARRate, 
		self.ModData, 
		self.NoteCount, 
		false, 
		self.AimDiffStrainCount, 
		self.SpeedDiffStrainCount, 
		self.SpeedRelevantNoteCount, 
		self.ReadingDiffStrainCount,
		AccData
	)

	local TotalPS = PSData.Current.TotalPS
	local AimPS = PSData.Current.AimPS
	local SpeedPS = PSData.Current.SpeedPS
	local ReadingPS = PSData.Current.ReadingPS
	local AccPS = PSData.Current.AccPS
	local FlashlightPS = PSData.Current.FlashlightPS

	self.CurrentPerformance = TotalPS

	local LivePSDisplay = script.Parent.Parent.Parent.Parent.PSEarned
	LivePSDisplay.Actor:SendMessage("Process",{
		Aim = AimPS,
		Speed = SpeedPS,
		Reading = ReadingPS,
		Acc = AccPS,
		Flashlight = FlashlightPS
	})
end

function LivePlayProcessing:ProcessFinalResult(AccData:PerformanceCalculator.AccuracyData)
	-- This is the last stage of score processing
	-- It will use the stats of pre-calculated instead of live-calculated
	self.AimDiffFinal = self.BaseAimDiff
	self.SpeedDiffFinal = self.BaseSpeedDiff
	self.FLDiffFinal = self.BaseFlashlightDiff
	self:ProcessPerfomanceScore(nil, nil, AccData)
end

return LivePlayProcessing
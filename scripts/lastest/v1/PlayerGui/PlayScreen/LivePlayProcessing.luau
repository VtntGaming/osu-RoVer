--[LOCATION]:[StarterGui.PlayScreen.GameplayScripts.Components.Gameplay.LivePlayProcessing]
--!strict
local modData = require(workspace.ModData)
local DifficultyCalculator = require(workspace.DifficultyCalculator)
local PerformanceCalculator = require(workspace.PerformanceCalculator)
local StrainSkills = require(workspace.DifficultyCalculator.StrainSkills)
export type PSValue = {Aim:number, Speed:number, Rhythm:number, Flashlight:number, AimStrainDecay:number, SpeedStrainDecay:number, FLStrainDecay:number}
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
	SpeedRelevantNoteCount:number,
	
	--> Live data
	CurrentLiveDiffAim:number,
	CurrentLiveDiffSpeed:number,
	CurrentLiveDiffFL:number,
	LiveDiffLastHit:number,
	AimStrain:{{number}},
	SpeedStrain:{{number}},
	FlashlightStrain:{{number}},
	StrainPeak:{
		Aim:{number}, Speed:{number}, Flashlight:{number}
	},
	StrainCurrentPeak:{
		Aim:number, Speed:number, Flashlight:number
	},
	PreviousStrain:{
		Aim:number, Speed:number, Flashlight:number
	},
	CurrentSectionEnd:number,
	PreviousTime:number,
	CurrentStarRating:number,
	AimDiffFinal:number,
	SpeedDiffFinal:number,
	FLDiffFinal:number,
	CurrentPerformance:number,
	IsFirstIndex:boolean,
	
	-- Function
	SetupData:(self:LivePlayProcessing, Attributes:InputAttributes) -> (),
	StartLiveDiffDisplay:(self:LivePlayProcessing) -> (),
	ProcessPerfomanceScore:(self:LivePlayProcessing, PSValue:PSValue, Timing:number, AccData:PerformanceCalculator.AccuracyData) -> (),
	_ProcessCurrentStrain:(self:LivePlayProcessing, Timing:number, PSValue:BasePSValue) -> (),
	_SaveCurrentPeak:(self:LivePlayProcessing) -> (),
	_StartNewSection:(self:LivePlayProcessing, Timing:number, Strains:{Aim:number, Speed:number, Flashlight:number}) -> (),
}

export type InputAttributes = {
	ModData:modData.ModData,
	ODRate:number,
	ARRate:number,
	NoteCount: {Circle:number, Slider:number, Spinner:number, Total:number},
	AimDiffStrainCount:number,
	SpeedDiffStrainCount:number,
	SpeedRelevantNoteCount:number,
}

type BasePSValue = {
	Aim:number, Speed:number, Flashlight:number
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
	self.CurrentLiveDiffFL = 0
	self.LiveDiffLastHit = 0
	self.AimStrain = {}
	self.SpeedStrain = {}
	self.FlashlightStrain = {}
	self.CurrentStarRating = 0
	self.AimDiffFinal = 0
	self.SpeedDiffFinal = 0
	self.FLDiffFinal = 0
	self.CurrentPerformance = 0
	-- Strain skills
	self.StrainPeak = {
		Aim	 = {}, Speed = {}, Flashlight = {}
	}
	self.StrainCurrentPeak = {
		Aim = 0, Speed = 0, Flashlight = 0
	}
	self.PreviousStrain = {
		Aim = 0, Speed = 0, Flashlight = 0
	}
	self.CurrentSectionEnd = 0
	self.PreviousTime = 0
	self.IsFirstIndex = true
	
	return self
end

function LivePlayProcessing:SetupData(Attributes:InputAttributes)
	self.ModData = Attributes.ModData
	self.ODRate = Attributes.ODRate
	self.ARRate = Attributes.ARRate
	self.NoteCount = Attributes.NoteCount
	self.AimDiffStrainCount = Attributes.AimDiffStrainCount
	self.SpeedDiffStrainCount = Attributes.SpeedDiffStrainCount
	self.SpeedRelevantNoteCount = Attributes.SpeedRelevantNoteCount
end

function LivePlayProcessing:StartLiveDiffDisplay()
	
end

local SECTION_LENGTH = 400

function LivePlayProcessing:_SaveCurrentPeak()
	if self.StrainCurrentPeak.Aim > 0 then
		self.StrainPeak.Aim[#self.StrainPeak.Aim+1] = self.StrainCurrentPeak.Aim
	end
	if self.StrainCurrentPeak.Speed > 0 then
		self.StrainPeak.Speed[#self.StrainPeak.Speed+1] = self.StrainCurrentPeak.Speed
	end
	if self.StrainCurrentPeak.Flashlight > 0 then
		self.StrainPeak.Flashlight[#self.StrainPeak.Flashlight+1] = self.StrainCurrentPeak.Flashlight
	end
end

function LivePlayProcessing:_StartNewSection(Timing:number, Strains:{Aim:number, Speed:number, Flashlight:number})
	self.StrainCurrentPeak.Aim = StrainSkills.CalculateInitialStrain.AimSpeed(Timing, {Strains.Aim}, self.PreviousTime, "Aim")
	self.StrainCurrentPeak.Speed = StrainSkills.CalculateInitialStrain.AimSpeed(Timing, {Strains.Speed}, self.PreviousTime, "Speed")
	self.StrainCurrentPeak.Flashlight = StrainSkills.CalculateInitialStrain.Default(Timing, {Strains.Flashlight})
end

function LivePlayProcessing:_ProcessCurrentStrain(Timing:number, PSValue:BasePSValue)
	if self.IsFirstIndex then
		self.IsFirstIndex = false
		self.CurrentSectionEnd = math.ceil(Timing/SECTION_LENGTH) * SECTION_LENGTH
	end
	
	while Timing > self.CurrentSectionEnd do
		self:_SaveCurrentPeak()
		self:_StartNewSection(self.CurrentSectionEnd, {Aim = PSValue.Aim, Speed = PSValue.Speed, Flashlight = PSValue.Flashlight})
		self.CurrentSectionEnd += SECTION_LENGTH
	end
	
	self.StrainCurrentPeak = {
		Aim = math.max(self.StrainCurrentPeak.Aim, PSValue.Aim),
		Speed = math.max(self.StrainCurrentPeak.Speed, PSValue.Speed),
		Flashlight = math.max(self.StrainCurrentPeak.Flashlight, PSValue.Flashlight)
	}
	
	self.PreviousStrain = {
		Aim = PSValue.Aim,
		Speed = PSValue.Speed,
		Flashlight = PSValue.Flashlight
	}
	
	self.PreviousTime = Timing
end

function LivePlayProcessing:ProcessPerfomanceScore(PSValue:PSValue, Timing:number, AccData:PerformanceCalculator.AccuracyData)
	if PSValue then
		local RhythmDiff = PSValue.Rhythm
		self.CurrentLiveDiffAim *= PSValue.AimStrainDecay
		self.CurrentLiveDiffAim += PSValue.Aim
		self.CurrentLiveDiffSpeed *= PSValue.SpeedStrainDecay
		self.CurrentLiveDiffSpeed += PSValue.Speed
		if self.ModData.FL then
			self.CurrentLiveDiffFL *= PSValue.FLStrainDecay
			self.CurrentLiveDiffFL += PSValue.Flashlight
		end
		self.LiveDiffLastHit = os.clock()
		
		self:_ProcessCurrentStrain(Timing,
			{
				Aim = self.CurrentLiveDiffAim,
				Speed = self.CurrentLiveDiffSpeed,
				Flashlight = self.CurrentLiveDiffFL
			}
		)
		
		local _noteCount = {
			Circle = self.NoteCount.Circle,
			Slider = self.NoteCount.Slider,
			Spinner = self.NoteCount.Spinner,
			Total = self.NoteCount.Circle + self.NoteCount.Slider + self.NoteCount.Spinner
		}
		local DifficultyAttributes:DifficultyCalculator.LiveDifficultyAttributes = {
			AimPeak = _Append(self.StrainPeak.Aim, self.StrainCurrentPeak.Aim),
			SpeedPeak = _Append(self.StrainPeak.Speed, self.StrainCurrentPeak.Speed),
			ARRate = self.ARRate,
			ODRate = self.ODRate,
			NoteCount = _noteCount,
			ModData = self.ModData
		}

		local Attributes = DifficultyCalculator.GetDifficultyAttributesFromLiveData(DifficultyAttributes)
		self.AimDiffFinal = Attributes.AimDifficulty
		self.SpeedDiffFinal = Attributes.SpeedDifficulty
		self.CurrentStarRating = Attributes.StarRating
	end

	local ODRate = self.ODRate
	local ARRate = self.ARRate
	local ModData:modData.ModData = self.ModData
	local Multiplier = {
		Aim = 1, Speed = 1, Flashlight = 1, Accuracy = 1
	}
	local AimDiffStrainCount = self.AimDiffStrainCount
	local SpeedDiffStrainCount = self.SpeedDiffStrainCount
	local SpeedRelevantNoteCount = self.SpeedRelevantNoteCount

	local PSData = PerformanceCalculator(
		self.AimDiffFinal, 
		self.SpeedDiffFinal, 
		self.FLDiffFinal, 
		self.ODRate, 
		self.ARRate, 
		self.ModData, 
		self.NoteCount, 
		false, 
		self.AimDiffStrainCount, 
		self.SpeedDiffStrainCount, 
		self.SpeedRelevantNoteCount, 
		AccData
	)

	local TotalPS = PSData.Current.TotalPS
	local AimPS = PSData.Current.AimPS
	local SpeedPS = PSData.Current.SpeedPS
	local AccPS = PSData.Current.AccPS
	local FlashlightPS = PSData.Current.FlashlightPS
	local ModPS = 0

	self.CurrentPerformance = TotalPS

	local AimSpeed = math.round(AimPS * 10) * 1000000 +  math.round(SpeedPS * 10)
	local AccFL = math.round(AccPS * 10) * 1000000 + math.round(FlashlightPS * 10)
	local Mod = math.round(ModPS * 10)

	local LivePSDisplay = script.Parent.Parent.Parent.Parent.PSEarned
	LivePSDisplay.Actor:SendMessage("Process",{
		AimSpeed = AimSpeed,
		AccFL = AccFL,
		Mod = Mod
	})
end

return LivePlayProcessing
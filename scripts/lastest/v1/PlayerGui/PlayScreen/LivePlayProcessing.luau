--!strict
local modData = require(workspace.ModData)
local DifficultyCalculator = require(workspace.DifficultyCalculator)
local PerformanceCalculator = require(workspace.PerformanceCalculator)
export type PSValue = {Aim:number, Speed:number, Rhythm:number, Flashlight:number, AimStrainDecay:number, SpeedStrainDecay:number, FLStrainDecay:number}
export type LivePlayProcessing = {
	new:() -> (LivePlayProcessing),
	__index: LivePlayProcessing,
	-- Variable
	--> Base data
	ModData:modData.ModData,
	ODRate:number,
	ARRate:number,
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
	AimDiffFinal:number,
	SpeedDiffFinal:number,
	FLDiffFinal:number,
	CurrentPerformance:number,
	
	-- Function
	SetupData:(self:LivePlayProcessing, Attributes:InputAttributes) -> (),
	StartLiveDiffDisplay:(self:LivePlayProcessing) -> (),
	ProcessPerfomanceScore:(self:LivePlayProcessing, PSValue:PSValue, Timing:number, AccData:PerformanceCalculator.AccuracyData) -> ()
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
local LivePlayProcessing:LivePlayProcessing = {}::LivePlayProcessing
LivePlayProcessing.__index = LivePlayProcessing

local function _SortStrain(data:{number})
	table.sort(data,function(a,b) return a>b end)
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
	self.AimDiffFinal = 0
	self.SpeedDiffFinal = 0
	self.FLDiffFinal = 0
	self.CurrentPerformance = 0
	
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
		self.LiveDiffLastHit = tick()

		local CrrData = {self.CurrentLiveDiffAim, self.CurrentLiveDiffSpeed, self.CurrentLiveDiffFL}
		local DiffChange = false
		if CrrData[1] > 0 then
			self.AimStrain[#self.AimStrain+1] = {CrrData[1], Timing}
		end
		if CrrData[2] > 0 then
			self.SpeedStrain[#self.SpeedStrain+1] = {CrrData[2]*RhythmDiff, Timing}
		end
		if self.ModData.FL and CrrData[3] > 0 then
			self.FlashlightStrain[#self.FlashlightStrain+1] = {CrrData[3], Timing}
		end
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
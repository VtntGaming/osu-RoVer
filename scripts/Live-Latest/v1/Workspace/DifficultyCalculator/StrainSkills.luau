--[LOCATION]:[Workspace.DifficultyCalculator.StrainSkills]
--!strict
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


function StrainSkills.GetStrainPeak(strainData:{{number}}, strainType:string):{number}
	local StrainPeak:{number} = {}
	local _sectionLength = SECTION_LENGTH
	local _currentSectionEnd = 0
	local _currentSectionPeak = 0
	
	local function _saveCurrentPeak()
		StrainPeak[#StrainPeak+1] = _currentSectionPeak
	end
	
	local function _startNewSection(t:number, strain:{number}, previousTime:number)
		local _initialStrain = StrainSkills.CalculateInitialStrain.AimSpeed(t, strain, previousTime, strainType)
		_currentSectionPeak = _initialStrain
	end
	
	for i, strain in pairs(strainData) do
		if i == 1 then
			_currentSectionEnd = math.ceil(strain[2]/_sectionLength) * _sectionLength
		end
		
		while strain[2] > _currentSectionEnd do
			local previousTime = 0
			if i > 1 then
				previousTime = strainData[i-1][2]
			end
			_saveCurrentPeak()
			_startNewSection(_currentSectionEnd, strain, previousTime)
			_currentSectionEnd += _sectionLength
		end
		
		_currentSectionPeak = math.max(strain[1], _currentSectionPeak)
	end
	
	_saveCurrentPeak()
	
	local FilteredPeaks = {}
	-- We need to filters out zero strain for the worst case senario
	for _, strain in pairs(StrainPeak) do
		if strain > 0 then
			FilteredPeaks[#FilteredPeaks + 1] = strain
		end
	end
	
	return FilteredPeaks
end

return StrainSkills
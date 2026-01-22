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

return StrainSkills
local calculator = {}

local workspace = game:GetService("Workspace")

local math_pow = math.pow
local math_max = math.max
local math_min = math.min
local math_sqrt = math.sqrt
-- local math_log10 = math.log10
-- local math_exp = math.exp
-- local math_clamp = math.clamp
-- local math_lerp = math.lerp

local difficulty_multiplier = 0.0675

local modData = require(workspace.ModData)
type ModData = modData.ModData

function calculator.CalculateDifficultyRating(value: number): number
    return math_sqrt(value) * difficulty_multiplier
end

function calculator.ComputeAimRating(aimDifficultyValue:number, modData:ModData, totalHit:number, AR:number, ODRate:number)
	if modData.AP then
		return 0
	end
	
	local aimRating = math_pow(aimDifficultyValue, 0.63) * 0.02275

	if modData.RX then
		aimRating *= 0.9
	end
	
	if modData.MG and modData.MG.Active then
		local magnetisedStrength = modData.MG.Strength or 0
		aimRating *= 1 - magnetisedStrength
	end
	
	local ratingMultiplier = 1
	-- Apply the ODRate difficulty to the aim rating
	ratingMultiplier *= 0.98 + math_pow(math_max(0, ODRate), 2) / 2500
	return aimRating * math_pow(ratingMultiplier, 1/3)
end

function calculator.ComputeSpeedRating(speedDifficultyValue:number, modData:ModData, totalHit:number, AR:number, ODRate:number)
	if modData.RX then
		return 0
	end
	local speedRating = calculator.CalculateDifficultyRating(speedDifficultyValue)
	if modData.AP then
		speedRating *= 0.5
	end
	
	if modData.MG then
		local magnetisedStrength = modData.MG.Strength or 0
		speedRating *= 1 - magnetisedStrength * 0.3
	end
	
	return speedRating
end

function calculator.ComputeReadingRating(readingDifficultyValue: number, modData:ModData, ODRate:number)
	local readingRating = calculator.CalculateDifficultyRating(readingDifficultyValue)

	if modData.TD then
		readingRating = math_pow(readingRating, 0.8)
	end

	if modData.RX then
		readingRating *= 0.6
	elseif modData.AP then
		readingRating *= 0.3
	end

	if modData.MG then
		local magnetisedStrength = modData.MG.Strength or 0
		readingRating *= 1 - magnetisedStrength
	end

	local ratingMultiplier = 1
	ratingMultiplier *= 0.75 + math_pow((math_max(0, ODRate)), 2.2) / 800

	return readingRating * math_pow(ratingMultiplier, 1/3)
end

function calculator.ComputeFlashlightRating(flashlightDifficultyValue:number, modData:ModData, totalHit:number, AR:number, ODRate:number)
	local flRating = calculator.CalculateDifficultyRating(flashlightDifficultyValue)
	
	if not modData.FL then
		return 0
	end
	
	if modData.TD then
		flRating = math_pow(flRating, 0.8)
	end
	
	if modData.RX then
		flRating *= 0.7
	elseif modData.AP then
		flRating *= 0.4
	end
	
	if modData.MG then
		local magnetisedStrength = modData.MG.Strength or 0
		flRating *= 1 - magnetisedStrength
	end
	
	-- TODO: Add deflate mod
	--if modData.DF then	
	--end
	
	local ratingMultiplier = 1
	ratingMultiplier *= 0.7 + 0.1 * math_min(1.0, totalHit / 200.0) +
		(totalHit > 200 and (0.2 * math_min(1.0, (totalHit - 200) / 200.0)) or 0.0)
	
	ratingMultiplier *= 0.98 + math_pow(math_max(0, ODRate, 2)) / 2500
	
	return flRating * math_sqrt(ratingMultiplier)
end

return calculator
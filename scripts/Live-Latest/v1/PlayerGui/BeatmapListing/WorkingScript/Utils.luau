--!strict
local psValue = game.Players.LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Performance")::StringValue
local Utils = {}
local MIN_VALUE = 1.5
local MAX_VALUE = 20 -- is it even possible to reach this?
local performance_multiplier = 1.14
local star_rating_multiplier = 0.0265

function stringToNumber(str:string):number
	if str == "-" then
		return 0
	end

	if str:find("ps") then
		str = str:sub(1, -3)
	end
	if str:find(",") then
		local raw = str:split(",")
		str = raw[1]..raw[2]
	end

	local num = tostring(str) or 0
	if num ~= num then
		num = 0
	end

	local result = math.clamp(tonumber(num) or 0, 0, 999999)
	if not math.isfinite(result) then
		result = 0
	end

	return result
end

function calculateRating(basePerfomance:number):number
	if basePerfomance <= 0.00001 then
		return 0
	end

	return math.pow(performance_multiplier, 1/3) * star_rating_multiplier * (math.pow(100000 / math.pow(2, 1/1.1) * basePerfomance, 1/3) + 4)
end

function calculatedRecommended(avgPS:number):(number)
	local baseDiff = math.min(calculateRating(avgPS * 0.7), MAX_VALUE)

	return baseDiff + 0.5
end

function Utils.GetRecommendedDifficulty(): number
	local psCount = stringToNumber(psValue.Value)
	local avgPS = psCount/20

	local result = calculatedRecommended(avgPS)
	
	return result
end

return Utils
--!strict

local ScoreFormat = {}

function ScoreFormat.GetScore(currentScore: number | string): string
	local str = tostring(currentScore)
	local newScore = ""

	for i = 1, #str do
		local idx = (#str - i) + 1
		if math.floor((#newScore + 1) / 4) - ((#newScore + 1) / 4) == 0 then
			newScore = string.sub(str, idx, idx) .. "," .. newScore
		else
			newScore = string.sub(str, idx, idx) .. newScore
		end
	end

	return newScore
end

return ScoreFormat

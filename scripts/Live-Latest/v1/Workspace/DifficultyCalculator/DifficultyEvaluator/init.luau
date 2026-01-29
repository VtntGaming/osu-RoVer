--[LOCATION]:[Workspace.DifficultyCalculator.DifficultyEvaluator]
--!strict
local evaluator = {}

-- Cache math functions
local math_clamp = math.clamp
local math_pow = math.pow

function evaluator.ReverseLerp(x:number, _start:number, _end:number)
	return math_clamp((x - _start) / (_end - _start), 0.0, 1.0)
end

function evaluator.milisecondToBPM(ms:number, delimiter:any)
	delimiter = delimiter or 4
	return 60000 / (ms * delimiter)
end

function evaluator.BPMToMilisecond(bpm:number, delimiter:any)
	delimiter = delimiter or 4
	return 60000 / delimiter / bpm
end

function evaluator.Normalise(power:number, ...:number)
	local count = 0
	local sum = 0

	local data = table.pack(...)
	if data.n == 0 then
		return 0
	end

	for i = 1, data.n do
		local num = data[i]
		sum += math_pow(num, power)
		count += 1
	end

	if count > 0 then
		return math_pow(sum, 1/power)
	else
		return 0
	end
end

return evaluator
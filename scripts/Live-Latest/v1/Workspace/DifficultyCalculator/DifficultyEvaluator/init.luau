--[LOCATION]:[Workspace.DifficultyCalculator.DifficultyEvaluator]
--!strict
local evaluator = {}

function evaluator.ReverseLerp(x:number, _start:number, _end:number)
	return math.clamp((x - _start) / (_end - _start), 0.0, 1.0)
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
		sum += num ^ power
		count += 1
	end

	if count > 0 then
		return math.pow(sum, 1/power)
	else
		return 0
	end
end

return evaluator
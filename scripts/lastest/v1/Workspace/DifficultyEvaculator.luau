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


return evaluator
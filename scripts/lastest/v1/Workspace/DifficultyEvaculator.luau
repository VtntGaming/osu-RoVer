--!strict
local evaculator = {}

function evaculator.ReverseLerp(x:number, _start:number, _end:number)
	return math.clamp((x - _start) / (_end - _start), 0.0, 1.0)
end

function evaculator.milisecondToBPM(ms:number, delimiter:any)
	delimiter = delimiter or 4
	return 60000 / (ms * delimiter)
end

function evaculator.BPMToMilisecond(bpm:number, delimiter:any)
	delimiter = delimiter or 4
	return 60000 / delimiter / bpm
end


return evaculator
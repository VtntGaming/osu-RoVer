local evaculator = {}

function evaculator.ReverseLerp(x, _start, _end)
	return math.clamp((x - _start) / (_end - _start), 0.0, 1.0)
end

function evaculator.milisecondToBPM(ms, delimiter)
	delimiter = delimiter or 4
	return 60000 / (ms * delimiter)
end

function evaculator.BPMToMilisecond(bpm, delimiter)
	delimiter = delimiter or 4
	return 60000 / delimiter / bpm
end


return evaculator
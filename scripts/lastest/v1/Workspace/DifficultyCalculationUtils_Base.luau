--!strict
local utils = {}

function utils.Smootherstep(x:number, _start:number, _end:number)
	x = math.clamp((x - _start) / (_end - _start), 0.0, 1.0)

	return x * x * x * (x * (6.0 * x - 15.0) + 10.0)
end

function utils.Smoothstep(x:number, _start:number, _end:number)
	x = math.clamp((x - _start) / (_end	- _start), 0, 1)

	return x * x * (3 - 2 * x)
end

function utils.SmoothstepBellCurve(x:number, mean:number?, width:number?)
	if not mean then mean = 0.5 end
	if not width then width = 0.5 end
	if mean and width then
		x -= mean
		x = x > 0 and width - x or width + x
		return utils.Smoothstep(x, 0, width)
	end

	return 0
end

return utils
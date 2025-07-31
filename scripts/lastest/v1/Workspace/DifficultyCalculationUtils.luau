--[LOCATION]:[Workspace.DifficultyCalculator.DifficultyEvaluator.DifficultyCalculationUtils]
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

function utils.ReverseLerp(x:number, _start:number, _end:number):number
	return math.clamp((x - _start) / (_end - _start), 0.0, 1.0);
end

function utils.Erf(x:number):number
	if x == 0 then
		return 0
	elseif x == math.huge then
		return 1
	elseif x == - math.huge then
		return -1
	elseif x ~= x then
		return 0/0
	end
	
	local t = 1.0 / (1.0 + 0.3275911 * math.abs(x))
	local tau = t * (0.254829592
		+ t * (-0.284496736
			+ t * (1.421413741
				+ t * (-1.453152027
					+ t * 1.061405429))))
	local erf = 1.0 - tau * math.exp(-x * x)
	
	return x >= 0 and erf or -erf
end

function utils.ErfInv(x:number):number
	if x <= -1 then
		return -math.huge
	elseif x >= 1 then
		return math.huge
	elseif x == 0 then
		return 0
	end
	
	local a = 0.147
	local sgn = math.sign(x)
	local ln = math.log(1 - x * x)
	local t1 = 2 / (math.pi * a) + ln / 2
	local t2 = ln / a
	local baseApprox = math.sqrt(t1 * t1 - t2) - t1
	local c = x >= 0.85 and math.pow((x - 0.85) / 0.293, 8) or 0
	local erfInv = sgn * (math.sqrt(baseApprox) + c)
	
	return erfInv
end

function utils.ErfcInv(x:number):number return utils.ErfInv(1-x) end

return utils
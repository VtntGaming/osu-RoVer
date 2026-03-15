--[LOCATION]:[Workspace.DifficultyCalculator.DifficultyEvaluator.DifficultyCalculationUtils]
--!strict
local utils = {}

-- Cache math functions
local math_clamp = math.clamp
local math_abs = math.abs
local math_exp = math.exp
local math_log = math.log
local math_sign = math.sign
local math_sqrt = math.sqrt
local math_pow = math.pow
local math_huge = math.huge

function utils.Smootherstep(x:number, _start:number, _end:number)
	x = math_clamp((x - _start) / (_end - _start), 0.0, 1.0)
	local x2 = x * x
	return x2 * x * (x * (6.0 * x - 15.0) + 10.0)
end

function utils.Smoothstep(x:number, _start:number, _end:number)
	x = math_clamp((x - _start) / (_end	- _start), 0, 1)

	return x * x * (3 - 2 * x)
end

function utils.MillisecondsToBPM(ms:number, delimiter:any)
	delimiter = delimiter or 4
	return 60000 / (ms * delimiter)
end

function utils.BPMToMilliseconds(bpm:number, delimiter:any)
	delimiter = delimiter or 4
	return 60000 / delimiter / bpm
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
	return math_clamp((x - _start) / (_end - _start), 0.0, 1.0);
end

type LogisticA = (x: number, midpointOffset: number, multiplier: number, maxValue: number?) -> number
type LogisticB = (exponent: number, maxValue: number?) -> number
type Logistic = LogisticA & LogisticB

local function LogisticA(x: number, midpointOffset: number, multiplier: number, maxValue: number?): number
	local _maxValue = maxValue or 1
	
	return _maxValue / (1 + math.exp(multiplier * (midpointOffset - x)))
end

local function LogisticB(exponent: number, maxValue: number?): number
	local _maxValue = maxValue or 1
	return _maxValue / (1 + math.exp(exponent))
end

local function Logistic(...): number
	if select("#", ...) >= 3 then
		return LogisticA(...)
	else
		return LogisticB(...)
	end
end

utils.Logistic = Logistic :: Logistic

function utils.Normalise(power:number, ...:number)
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

function utils.Erf(x:number):number
	if x == 0 then
		return 0
	elseif x == math_huge then
		return 1
	elseif x == -math_huge then
		return -1
	elseif x ~= x then
		return 0/0
	end
	
	local absX = math_abs(x)
	local t = 1.0 / (1.0 + 0.3275911 * absX)
	local tau = t * (0.254829592
		+ t * (-0.284496736
			+ t * (1.421413741
				+ t * (-1.453152027
					+ t * 1.061405429))))
	local erf = 1.0 - tau * math_exp(-x * x)
	
	return x >= 0 and erf or -erf
end

function utils.ErfInv(x:number):number
	if x <= -1 then
		return -math_huge
	elseif x >= 1 then
		return math_huge
	elseif x == 0 then
		return 0
	end
	
	local a = 0.147
	local sgn = math_sign(x)
	x = math_abs(x)
	local ln = math_log(1 - x * x)
	local t1 = 2 / (math.pi * a) + ln / 2
	local t2 = ln / a
	local baseApprox = math_sqrt(t1 * t1 - t2) - t1
	local c = x >= 0.85 and math_pow((x - 0.85) / 0.293, 8) or 0
	local erfInv = sgn * (math_sqrt(baseApprox) + c)
	
	return erfInv
end

function utils.ErfcInv(x:number):number return utils.ErfInv(1-x) end

return utils
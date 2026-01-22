--[LOCATION]:[Workspace.OsuConvert.converterTools]
--!strict
local workspace = game:GetService("Workspace")
-- local diffCalculator = require(workspace.DifficultyCalculator)
local modData = require(workspace.ModData)
local tool = {}

function tool.ConvertRaw(FileText)
	local _,e = string.find(FileText,"content\\")
	if not e then
		warn("Failed to convert asset file")
		return
	end
	FileText = string.sub(FileText,e+1,#FileText)
	while true do
		local s = string.find(FileText,"\\")
		if s then
			FileText = string.sub(FileText,1,s-1).."/"..string.sub(FileText,s+1,#FileText)
		else
			break
		end
	end

	return "rbxasset://"..FileText
end

function tool.GetBPMData(Time:number, TimingPoints, SongSpeed)
	local data = {BPM = 60,SliderMultiplier = 1,LastBPMTiming = 0}
	local BPMVaild = false
	for i,TimingData in ipairs(TimingPoints) do
		if TimingData[1] > Time and BPMVaild then
			break
		end

		if TimingData[2] > 0 then -- bpm
			if TimingData[1] > Time and BPMVaild then continue end
			if TimingData[2] > 100000000 then continue end -- No we are NOT adding a timing with such a low bpm like this one
			data.BPM = (1 / TimingData[2] * 1000 * 60)*SongSpeed
			data.LastBPMTiming = TimingData[1]
			BPMVaild = true

			if not TimingPoints[i-1] or TimingPoints[i-1][1] < TimingData[1] then
				data.SliderMultiplier = 1
			end
		else	-- slider multiplier
			if TimingData[1] > Time then continue end
			data.SliderMultiplier = 1/((-TimingData[2])/100)
		end
	end

	return data
end

function tool.getAngle(pointA:Vector2, pointB:Vector2, pointC:Vector2) -- in vector2
	local ab = pointB - pointA
	local angleA = math.deg(math.atan2(ab.Y,ab.Y))
	angleA = math.abs(angleA)
	local bc = pointB - pointC
	local angleB = math.deg(math.atan2(bc.Y,bc.X))
	angleB = math.abs(angleB)

	local angle = math.max(angleA,angleB) - math.min(angleA, angleB)
	return math.rad(angle)
end

function tool.Lerp(a:number,b:number,rate:number)
	return a + (b-a) * rate
end

function tool.DifficultyRange(difficulty, min, mid, max)
	if (difficulty > 5) then
		return mid + (max - mid) * tool.DifficultyValue(difficulty)
	elseif (difficulty < 5) then
		return mid + (mid - min) * tool.DifficultyValue(difficulty)
	else
		return mid
	end
end

function tool.DifficultyValue(difficulty:number)
	return (difficulty - 5) / 5
end

export type ModData = modData.ModData

tool.HitWindowsFor = {
	h300 = function(ODRate:number, Speed:number, IsTD:boolean?, byPassSA:boolean?):number
		if byPassSA then
			Speed = 1
		end
		local h300 = math.floor(tool.DifficultyRange(ODRate, 80, 50, 20)) - 0.5
		if IsTD then
			h300 = math.floor(tool.DifficultyRange(ODRate, 120, 75, 30)) - 0.5
		end
		return h300 / Speed
	end,
	h100 = function(ODRate:number, Speed:number, byPassSA:boolean?):number
		if byPassSA then
			Speed = 1
		end
		local h100 = math.floor(tool.DifficultyRange(ODRate, 140, 100, 60)) - 0.5
		return h100 / Speed
	end,
	h50 = function(ODRate:number, Speed:number, byPassSA:boolean?):number
		if byPassSA then
			Speed = 1
		end
		local h50 = math.floor(tool.DifficultyRange(ODRate, 200, 150, 100)) - 0.5
		return h50 / Speed
	end,
}

tool.GetDifficultyFromValue = {
	OD = function(rate:number, isTD:boolean?):number
		if isTD then
			local h300 = math.floor(tool.DifficultyRange(rate, 80, 50, 20)) - 0.5	
			rate = (119.5 - h300) / 9
		end		
		return rate
	end,
}

tool.GetDifficultyValueAfterMod = {
	AR = function(rate:number, modData:ModData):(number, number)
		if modData.DA and modData.DA.Active and modData.DA.Data and modData.DA.Data.AR then
			rate = modData.DA.Data.AR
		elseif modData.HR then
			rate *= 1.4
		elseif modData.EZ then
			rate *= 0.5		
		end
		
		if not (modData.DA and modData.DA.Active and modData.DA.Data and modData.DA.Data.AR) then
			rate = math.clamp(rate, 0, 10)
		end
		
		local rateAfterSA = rate
		
		if modData.SA and modData.SA ~= 1 then
			local ARTime = 1200
			if rate < 5 then
				ARTime = 1200 + 600 * (5 - rate) / 5
			elseif rate > 5 then
				ARTime = 1200 - 750 * (rate - 5) / 5
			else
				ARTime = 1200
			end
			
			ARTime /= modData.SA
			
			if ARTime > 1200 then
				rateAfterSA = 5 - ((ARTime - 1200) / 600 * 5)
			elseif ARTime < 1200 then
				rateAfterSA = 5 + ((1200 - ARTime) / 750 * 5)
			else
				rateAfterSA = 5
			end
		end
		
		return rateAfterSA, rate
	end,
	OD = function(rate:number, modData:ModData):(number, number)
		if modData.DA  and modData.DA.Active and modData.DA.Data and modData.DA.Data.OD then
			rate = modData.DA.Data.OD
		elseif modData.HR then
			rate *= 1.4
		elseif modData.EZ then
			rate *= 0.5		
		end
		if not (modData.DA and modData.DA.Active and modData.DA.Data and modData.DA.Data.OD) then
			rate = math.clamp(rate, 0, 10)
		end
		
		local rateAfterSA = rate
		
		if (modData.SA and modData.SA ~= 1) or modData.TD then
			local h300 = tool.HitWindowsFor.h300(rate, modData.SA or 1, modData.TD, true)
			rate = (79.5 - h300) / 6
			
			local h300AfterSA = tool.HitWindowsFor.h300(rate, modData.SA or 1, modData.TD, false)
			rateAfterSA = (79.5 - h300AfterSA) / 6
		end
		
		
		return rateAfterSA, rate
	end,
	HP = function(rate:number, modData:ModData)
		if modData.DA and modData.DA.Active and modData.DA.Data and modData.DA.Data.HP then
			rate = modData.DA.Data.HP
		elseif modData.HR then
			rate *= 1.4
		elseif modData.EZ then
			rate *= 0.5		
		end
		if not (modData.DA and modData.DA.Active and modData.DA.Data and modData.DA.Data.HP) then
			rate = math.clamp(rate, 0, 10)
		end
		
		return rate
	end,
	CS = function(rate:number, modData:ModData)
		if modData.DA and modData.DA.Active and modData.DA.Data and modData.DA.Data.CS then
			rate = modData.DA.Data.CS
		elseif modData.HR then
			rate *= 1.3
		elseif modData.EZ then
			rate *= 0.5		
		end
		if not (modData.DA and modData.DA.Active and modData.DA.Data and modData.DA.Data.CS) then
			rate = math.clamp(rate, 0, 10)
		end
		if modData.TD then
			local radius = (54.4 - 4.48 * rate)*2
			-- In the game I have gave significant advantages to TD's CS and OD rate
			-- So I need to nerf the difficulty rating and PS reward
			radius *= 1.1875
			
			rate = (54.4 -  radius / 2) / 4.48
		end

		return rate
	end,
}

function tool.GetTickPosition(Time: number, SliderTime: number, SLCurvePoints: {Vector2}, ExtraData: {number}, tickTime: number, isReverse:boolean): Vector2?
	local slideCount = tonumber(ExtraData[3]) :: number
	local _slideTime = (SliderTime * 1000 / slideCount)
	local _tickProgressLength = (1 - ((Time - tickTime)%_slideTime)/_slideTime) * tonumber(ExtraData[4]) :: number
	if not isReverse then
		local _currentLength = 0
		for i = 1, #SLCurvePoints - 1 do
			local _crr = SLCurvePoints[i] :: Vector2
			local _next = SLCurvePoints[i+1] :: Vector2
			local _length = (_next - _crr).Magnitude
			local _nextLength = _currentLength + _length
			
			if _nextLength >= _tickProgressLength then
				local _ratio = math.min(1, (_tickProgressLength-_currentLength)/_length)
				local _pos = _crr:Lerp(_next, _ratio)
				return _pos
			else
				_currentLength = _nextLength
			end
		end
	else
		local _currentLength = 0
		for i = #SLCurvePoints, 2, -1 do
			local _crr = SLCurvePoints[i] :: Vector2
			local _next = SLCurvePoints[i-1] :: Vector2
			local _length = (_next - _crr).Magnitude
			local _nextLength = _currentLength + _length

			if _nextLength >= _tickProgressLength then
				local _ratio = math.min(1, _tickProgressLength/_length)
				local _pos = _crr:Lerp(_next, _ratio)

				return _pos
			else
				_currentLength = _nextLength	
			end 
		end
	end
	local lastPoint = SLCurvePoints[isReverse and 1 or #SLCurvePoints]
	
	if lastPoint then
		return lastPoint -- return the last point instead...
	end
	return nil
end

local function getConsistencyScore(combo:number):number
	local score = (combo * (combo + 1) / 2)
	score = math.pow(score, 1.1704417) * 1.2255
	return score * 6 * 0.7
end

local function getAccuracyScore(combo:number):number
	return math.pow(combo ,2.265) * 6 * 0.3
end

function tool.GetScoreV1(maxCombo:number):(number, number, number)
	local consistencyScore = getConsistencyScore(maxCombo)
	local accuracyScore = getAccuracyScore(maxCombo)
	return consistencyScore, accuracyScore, consistencyScore + accuracyScore
end

return tool
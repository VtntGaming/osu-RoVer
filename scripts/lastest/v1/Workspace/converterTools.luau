--!strict
local diffCalculator = require(workspace.DifficultyCalculator)
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

export type ModData = diffCalculator.ModData

tool.GetDifficultyValueAfterMod = {
	AR = function(rate:number, modData:ModData)
		if modData.HR then
			rate *= 1.4
		elseif modData.EZ then
			rate *= 0.5		
		end
		
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
				rate = 5 - ((ARTime - 1200) / 600 * 5)
			elseif ARTime < 1200 then
				rate = 5 + ((1200 - ARTime) / 750 * 5)
			else
				rate = 5
			end
		end
		
		return rate
	end,
	OD = function(rate:number, modData:ModData)
		if modData.HR then
			rate *= 1.4
		elseif modData.EZ then
			rate *= 0.5		
		end
		
		local h300 = math.floor(tool.DifficultyRange(rate, 80, 50, 20)) - 0.5
		
		rate = (79.5 - h300) / 6
		
		return rate
	end,
	HP = function(rate:number, modData:ModData)
		if modData.HR then
			rate *= 1.4
		elseif modData.EZ then
			rate *= 0.5		
		end
		
		return rate
	end,
	CS = function(rate:number, modData:ModData)
		if modData.HR then
			rate *= 1.3
		elseif modData.EZ then
			rate *= 0.5		
		end

		return rate
	end,
}

return tool
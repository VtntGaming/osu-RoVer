local tool = {}

function tool.ConvertRaw(FileText)
	local _,e = string.find(FileText,"content\\")
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

function tool.GetBPMData(Time, TimingPoints, SongSpeed)
	local data = {BPM = 60,SliderMultiplier = 1,LastBPMTiming = 0}
	local BPMVaild = false
	for i,TimingData in pairs(TimingPoints) do
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

function tool.getAngle(pointA, pointB, pointC) -- in vector2
	local ab = pointB - pointA
	local angleA = math.deg(math.atan2(ab.y,ab.x))
	angleA = math.abs(angleA)
	local bc = pointB - pointC
	local angleB = math.deg(math.atan2(bc.y,bc.x))
	angleB = math.abs(angleB)

	local angle = math.max(angleA,angleB) - math.min(angleA, angleB)
	return math.rad(angle)
end

function tool.Lerp(a,b,rate)
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

function tool.DifficultyValue(difficulty)
	return (difficulty - 5) / 5
end

return tool
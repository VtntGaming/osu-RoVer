return function(FileType,Beatmap,SongSpeed,DelayedTime)
	local OsuData = Beatmap
	if FileType == 1 then
		OsuData = require(Beatmap)
	end
	
	local Space = script.Space.Value
	local Data = {}
	local TempData = ""
	local StartFile = 0
	for i = 1,#OsuData do
		if string.sub(OsuData,i,i+11) == "[HitObjects]" then
			StartFile = i+13
			break
		end
	end
	local CurrentLocation = StartFile
	for i = StartFile,#OsuData do
		if string.sub(OsuData,i,i) == Space then
			Data[#Data+1] = string.sub(OsuData,CurrentLocation,i-1)
			CurrentLocation = i+1
		end
	end
	
	--[[
	Type:
	0: Hit circle
	1: Slider
	3: Spinner
	7: osu!mania hold
	2: New combo
	4–6: A 3-bit integer specifying how many combo colours to skip, if this object starts a new combo.
	HitObject:
	x,y,time,type,hitSound,objectParams,hitSample
	
	------------
	Type according to studio:
	0: Hit circle
	1: Slider
	3,2,12: Spinner
	
	6: Slider - NewCombo
	AnythingElse: Hit circle - NewCombo
	]]
	local ConvertedData = {}
	for _,HitObj in pairs(Data) do
		local HitPos = {X = 0,Y = 0}
		local Time = 0
		local Type = 0
		local Location = 0
		local CurrentType = 1
		local ExtraData = {}
		for i = 1,#HitObj do
			if string.sub(HitObj,i,i) == "," or i == #HitObj then
				if CurrentType == 1 then
					HitPos.X = tonumber(string.sub(HitObj,Location,i-1))
				end
				if CurrentType == 2 then
					HitPos.Y = tonumber(string.sub(HitObj,Location,i-1))
				end
				if CurrentType == 3 then
					Time = (tonumber(string.sub(HitObj,Location,i-1))+DelayedTime)/SongSpeed
				end
				if CurrentType == 4 then
					Type = tonumber(string.sub(HitObj,Location,i-1))
				end
				if CurrentType >= 5 then
					ExtraData[#ExtraData+1] = string.sub(HitObj,Location,i-1)
				end
				Location = i+1
				CurrentType = CurrentType + 1
			end
		end
		
		local HitObjData = {Position = HitPos,Time = Time,Type = Type,ExtraData = ExtraData}
		ConvertedData[#ConvertedData+1] = HitObjData
	end
	return ConvertedData
end

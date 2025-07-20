local BeatmapPreviewSession = ""
local BasePreviewBeatmapset = ""
TweenService = game:GetService("TweenService")

local wait = require(workspace.WaitModule)
local PerfomanceCalculator = require(workspace.PerfomanceCalculator)
local GameSettings = game.Players.LocalPlayer.PlayerGui:WaitForChild("Settings").SettingFrame.BaseFrame.MainLayer.SettingsManage

local event = Instance.new("BindableEvent")

event.Event:Connect(function(_f)
	_f()
end)

local function spawn(f)
	event:Fire(f)
end
local thisScript = script

local webRequestID

function getSineValue(a,b,t)
	return a + (b - a) * math.sin((math.pi/2) * t)
end

function GenerateSineTimeline(SourceTimeline)
	local TimelineCount = #SourceTimeline
	local AssumedFrameSize = 500
	local DrawPerTimeline = math.max(1, math.round(AssumedFrameSize/TimelineCount))
	if DrawPerTimeline == 1 then
		return SourceTimeline
	end
	local newTimeline = {}
	for i, valueA in pairs(SourceTimeline) do
		local valueB = SourceTimeline[i+1]
		if not valueB then
			break
		end
		
		for index = 1, DrawPerTimeline do
			local t = index/DrawPerTimeline
			local value = getSineValue(valueA, valueB, t)
			newTimeline[#newTimeline+1] = value
		end
	end
	
	return newTimeline
end

script.LoadPreviewFrame.OnInvoke = function(CurrentPreviewFrame,CurrentSetting,FileType,CurrentModData,BeatmapStudio
	,CurrentKey,BeatmapKey,PreviewFrameBaseVolume,PreviewBeatmapset,NoFail,NoSlider,HardRock,FlashLight,EasyMod,HiddenMod
)
	local script = script.Parent.Parent.OsuGame


	local PreviewFrame = CurrentPreviewFrame
	local Settings = CurrentSetting.MainSettings
	local CurrentBeatmap = Settings.BeatmapFile.Text
	local CurrentFileType = FileType
	local CurrentSongDelay = Settings.Parent.VirtualSettings.InstantSettings.Offset.Value
	local SongSpeed = tonumber(Settings.Speed.Text)
	local CurrentPreviewSession = game.HttpService:GenerateGUID()
	local SongVolume = GameSettings.getSettings:Invoke("MusicVolume")
	local KeepOriginalPitch = GameSettings.getSettings:Invoke("EnableSpeedPitch")
	BeatmapPreviewSession = CurrentPreviewSession


	if SongSpeed == nil or (SongSpeed < 0.5 or SongSpeed > 2) or SongSpeed ~= SongSpeed  then
		SongSpeed = 1
	end

	script.Parent.MultiplayerData.UploadMap:Fire(BeatmapStudio.Name,SongSpeed)

	CurrentModData.Speed = SongSpeed


	if CurrentSongDelay == nil or math.abs(CurrentSongDelay) > 5000 then
		CurrentSongDelay = 0
	end

	if CurrentBeatmap == nil or CurrentBeatmap == "" or FileType == 1 then
		CurrentBeatmap = BeatmapStudio
		CurrentFileType = 1
	end
	
	local s = tick()
	local env = game.Players.LocalPlayer.PlayerScripts.ExternalFunction_Actor.ProcessCommand:Invoke("Core_OsuConvert",
		{
			FileType = CurrentFileType,
			Beatmap = CurrentBeatmap,
			SongSpeed = SongSpeed,
			DelayedTime = CurrentSongDelay,
			isReturnDifficulty = true,
			metadataonly = false,
			GetPS = true,
			IsHR = HardRock,
			isFL = FlashLight,
			IsEZ = EasyMod,
			IsHD = HiddenMod,
			IsNS = NoSlider
		}
	)
	local BeatmapData,ReturnData,TimmingPoints,ComboColors
	
	BeatmapData = env.ConvertedData
	ReturnData = env.ReturningData
	TimmingPoints = env.TimingPoints
	ComboColors = env.BeatmapColor
	
	local MaxCombo = ReturnData.Difficulty.MaxCombo
	local NoteCount = #BeatmapData
	
	local MaxScore, MaxAccScore, MaxConsistencyScore = require(thisScript.Parent.Components.Gameplay.GetMaxScore)(NoteCount, MaxCombo)

	--local BeatmapData,ReturnData,TimmingPoints,ComboColors = require(workspace.OsuConvert)(CurrentFileType,CurrentBeatmap,SongSpeed,CurrentSongDelay,true,false,true,HardRock,FlashLight,EasyMod,HiddenMod)
	
	for i = 1,5 do
		wait()
	end
	
	local TotalNotes = #BeatmapData
	local Notes = 0
	local Sliders = 0
	local Spinners = 0
	local AvgNPS = math.floor(TotalNotes/(tonumber(ReturnData.Overview.MapLength) or 0/1000))
	
	for i,data in pairs(BeatmapData) do
		local Type = data.Type
		if Type ~= 1 and Type ~= 2 and Type ~= 8 then
			if Type <= 12 then
				if Type == 5 then Type = 1
				elseif Type == 6 then Type = 2
				elseif Type == 12 then Type = 8
				end
			else
				for i = 1,8 do
					if Type == 21 + 16*(i-1) then
						Type = 1
						break
					elseif Type == 22 + 16*(i-1) then
						Type = 2
						break
					elseif Type == 28 + 16*(i-1) then
						Type = 8
						break
					end
				end
			end
		end

		if Type == 2 then
			Sliders += 1
		elseif Type == 8  then
			Spinners += 1
		else
			Notes += 1
		end
	end


	script.Parent.Parent.BG.StartButtonBeatAnimation.BPMAnimation.Event:Fire(TimmingPoints,SongSpeed,ReturnData.OriginalOffset)

	if ReturnData.Overview.Metadata ~= nil then
		PreviewFrame.Overview.MapName.Text = ReturnData.Overview.Metadata.MapName
		PreviewFrame.Overview.MapArtist.Text = ReturnData.Overview.Metadata.SongCreator
		PreviewFrame.Overview.MapSource.Visible = ReturnData.Overview.Metadata.Source ~= ""
		PreviewFrame.Overview.MapSource.Text = ReturnData.Overview.Metadata.Source
		--PreviewFrame.Overview.DifficultyName.Text = ReturnData.Overview.Metadata.DifficultyName.." // "..ReturnData.Overview.Metadata.BeatmapCreator
		PreviewFrame.Overview.DifficultyName.Text = string.format("<font weight='SemiBold' size='14' >%s</font> mapped by <font weight='Medium'>%s</font>",ReturnData.Overview.Metadata.DifficultyName,ReturnData.Overview.Metadata.BeatmapCreator)
	else
		PreviewFrame.Overview.MapName.Text = ""
		PreviewFrame.Overview.MapArtist.Text = ""
		PreviewFrame.Overview.DifficultyName.Text = ""
	end

	local function ReturnTime(Length)
		Length = Length//1000
		local Mins = Length//60
		local Secs = Length%60
		
		return string.format("%2d:%2d", Mins, Secs)
	end

	local SpeedDisplay = ""

	if SongSpeed ~= 1 then
		SpeedDisplay = "(x"..tostring(math.floor(SongSpeed*100)/100)..")"
	end

	local ExtraARRate = ""
	local ExtraDiffModText = (HardRock and "[Mod ⬆]") or (EasyMod and "[Mod ⬇️]") or ""
	local CSModMulti = ((HardRock and 1.3) or (EasyMod and 0.5) or 1)
	local DiffModMulti = ((HardRock and 1.4) or (EasyMod and 0.5) or 1)

	local CSRate = math.min(math.max(ReturnData.Difficulty.CircleSize,7),ReturnData.Difficulty.CircleSize*CSModMulti)
	local HPRate = math.min(math.max(ReturnData.Difficulty.HPDrainRate,10),ReturnData.Difficulty.HPDrainRate*DiffModMulti)
	local ARRate = math.min(math.max(ReturnData.Difficulty.ApproachRate,10),ReturnData.Difficulty.ApproachRate*DiffModMulti)
	local ODRate = math.min(math.max(ReturnData.Difficulty.OverallDifficulty,10),ReturnData.Difficulty.OverallDifficulty*DiffModMulti)
	local SpeedAR = ARRate


	if CSRate > 11 then CSRate = 11 end
	if HPRate > 12 then HPRate = 12 end
	if ARRate > 12 then ARRate = 12 end
	if ODRate > 12 then ODRate = 12 end



	if SongSpeed ~= 1 then
		local CurrentAR = ReturnData.Difficulty.ApproachRate * ((HardRock and 1.4) or (EasyMod and 0.5) or 1)
		if CurrentAR > 10 then CurrentAR = 10 end
		local ARTime = 1200
		if CurrentAR < 5 then
			ARTime = 1200 + 600 * (5 - CurrentAR) / 5
		elseif CurrentAR > 5 then
			ARTime = 1200 - 750 * (CurrentAR - 5) / 5
		else
			ARTime = 1200
		end
		ARTime /= SongSpeed

		local NewAR = CurrentAR

		if ARTime == 1200 then
			NewAR = 5
		elseif ARTime > 1200 then
			NewAR = 5 - (ARTime-1200)/120
		elseif ARTime < 1200 then
			NewAR = (1200-ARTime)/150 + 5
		end

		SpeedAR = NewAR
		NewAR = math.round(NewAR*100)/100
		ExtraARRate = " ("..tostring(NewAR)..")"
	end

	local AimDiffRating = ReturnData.Difficulty.AimDifficulty
	local SpeedDiffRating = ReturnData.Difficulty.SpeedDifficulty
	local FlashlightDifficulty = ReturnData.Difficulty.FlashLightDifficulty
	if not FlashLight then
		FlashlightDifficulty = 0
	end
	local MaxDiff = math.max(AimDiffRating, SpeedDiffRating, FlashlightDifficulty)
	if ReturnData.Difficulty ~= nil then
		local Diff = tonumber(ReturnData.Difficulty.BeatmapDifficulty)
		if Diff > 6 then
			if Diff <= 9 then
				if MaxDiff == AimDiffRating then
					PreviewFrame.Overview.BeatmapDifficulty.TextColor3 = Color3.fromHSV(0.5, (Diff-6)/3 * 0.588235, 1)
				elseif MaxDiff == SpeedDiffRating then
					PreviewFrame.Overview.BeatmapDifficulty.TextColor3 = Color3.fromHSV(0, (Diff-6)/3 * 0.588235, 1)
				else
					PreviewFrame.Overview.BeatmapDifficulty.TextColor3 = Color3.fromHSV(0.166667, (Diff-6)/3 * 0.588235, 1)
				end
			elseif Diff <= 13 then
				if MaxDiff == AimDiffRating then
					PreviewFrame.Overview.BeatmapDifficulty.TextColor3 = Color3.fromHSV(0.5, 0.588235 + (Diff-9)/4 * 0.411765, 1)
				elseif MaxDiff == SpeedDiffRating then
					PreviewFrame.Overview.BeatmapDifficulty.TextColor3 = Color3.fromHSV(0, 0.588235 + (Diff-9)/4 * 0.411765, 1)
				else
					PreviewFrame.Overview.BeatmapDifficulty.TextColor3 = Color3.fromHSV(0.166667, 0.588235 + (Diff-9)/4 * 0.411765, 1)
				end
			else
				if MaxDiff == AimDiffRating then
					PreviewFrame.Overview.BeatmapDifficulty.TextColor3 = Color3.fromHSV(0.5, 1, 1)
				elseif MaxDiff == SpeedDiffRating then
					PreviewFrame.Overview.BeatmapDifficulty.TextColor3 = Color3.fromHSV(0, 1, 1)
				else
					PreviewFrame.Overview.BeatmapDifficulty.TextColor3 = Color3.fromHSV(0.166667, 1, 1)
				end
			end
		else
			PreviewFrame.Overview.BeatmapDifficulty.TextColor3 = Color3.fromHSV(0, 0, 1)
		end
		PreviewFrame.Overview.DifficultyInfo.Text = "Length - "..ReturnTime(ReturnData.Overview.MapLength)..SpeedDisplay.." CS: "..tostring(math.round(CSRate*100)/100).." OD: "..tostring(math.round(ODRate*100)/100).." HP: "..tostring(math.round(HPRate*100)/100).." AR: "..tostring(math.round(ARRate*100)/100)..ExtraARRate.."  "..ExtraDiffModText
		PreviewFrame.Overview.Information.Length.TimeValue.Value = ReturnData.Overview.MapLength//1000
		PreviewFrame.Overview.BeatmapDifficulty.Text = "<b>Difficulty rating: "..tostring(ReturnData.Difficulty.BeatmapDifficulty).."</b>"

		local DiffListing = PreviewFrame.Overview.DiffListing
		local TweenInfo_DiffAnimation = TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		local InformationFrame = PreviewFrame.Overview.Information


		local function getPropTable(Value,isDiff)
			local DiffColor

			if Value > 10 then
				Value = 10
			elseif Value < 0 then
				Value = 0
			end

			if isDiff then
				DiffColor = PreviewFrame.Overview.BeatmapDifficulty.TextColor3
			elseif EasyMod then
				DiffColor = Color3.new(0.607843, 1, 1)
			elseif HardRock then
				DiffColor = Color3.new(1, 0.607843, 0.607843)
			else
				DiffColor = Color3.new(1, 1, 1)
			end

			return {Size = UDim2.new(math.min(Value,10)/10,0,1,0),BackgroundColor3 = DiffColor}
		end

		local function getObj(Name)
			return DiffListing[Name].ValueBar.Value
		end

		local function changeText(Name,Value,isDiff)
			local TextObj = DiffListing[Name].Value

			if isDiff then
				TextObj.Text = string.format("%.2f",Value)
			else
				TextObj.Text = tostring(math.round(Value*10)/10)
			end
			if isDiff then
				TweenService:Create(TextObj,TweenInfo_DiffAnimation,{TextColor3 = PreviewFrame.Overview.BeatmapDifficulty.TextColor3}):Play()
			elseif EasyMod then
				TweenService:Create(TextObj,TweenInfo_DiffAnimation,{TextColor3 = Color3.new(0.607843, 1, 1)}):Play()
			elseif HardRock then
				TweenService:Create(TextObj,TweenInfo_DiffAnimation,{TextColor3 = Color3.new(1, 0.607843, 0.607843)}):Play()
			else
				TweenService:Create(TextObj,TweenInfo_DiffAnimation,{TextColor3 = Color3.new(1, 1, 1)}):Play()
			end
		end

		TweenService:Create(getObj("CS"),TweenInfo_DiffAnimation,getPropTable(CSRate)):Play()
		TweenService:Create(getObj("HP"),TweenInfo_DiffAnimation,getPropTable(HPRate)):Play()
		TweenService:Create(getObj("OD"),TweenInfo_DiffAnimation,getPropTable(ODRate)):Play()
		TweenService:Create(getObj("AR"),TweenInfo_DiffAnimation,getPropTable(ARRate)):Play()
		TweenService:Create(getObj("DR"),TweenInfo_DiffAnimation,getPropTable(ReturnData.Difficulty.BeatmapDifficulty,true)):Play()


		changeText("CS",CSRate)
		changeText("HP",HPRate)
		changeText("OD",ODRate)
		changeText("AR",ARRate)
		changeText("DR",ReturnData.Difficulty.BeatmapDifficulty,true)

		-- Display detail infomation

		local RPMRequire = 150
		if ODRate < 5 then
			RPMRequire = 150 - 60 * (5-ODRate)/5  -- 90 - 150RPM
		else
			RPMRequire = 150 + 75 * (ODRate-5)/5 -- 150 - 225RPM
		end
		

		local DetailARTime = 1200
		local Detail300Timing = 100 - 8 * ODRate
		local Detail100Timing = 175 - 10 * ODRate
		local Detail50Timing = 250 - 12.5 * ODRate
		local DetailSpinRequirement = RPMRequire
		local DetailHitObjRadius = 54.4 - 4.48 * CSRate

		if ARRate < 5 then
			DetailARTime = 1200 + 600 * (5 - ARRate) / 5
		elseif ARRate > 5 then
			DetailARTime = 1200 - 750 * (ARRate - 5) / 5
		else
			DetailARTime = 1200
		end
		
		DetailARTime /= SongSpeed
		Detail300Timing /= SongSpeed
		Detail100Timing /= SongSpeed
		Detail50Timing /= SongSpeed

		local DetailedFormat = string.format("Approach time: %dms\n<font color='#00ffff'>300</font>: +-%.1fms\n<font color='#00ff00'>100</font>: +-%.1fms\n<font color='#ffff00'>50</font>: +-%.1fms\nSpin difficulty: %drpm\nHit object radius: %.2f (scaled)",
			DetailARTime,Detail300Timing,Detail100Timing,Detail50Timing,DetailSpinRequirement,DetailHitObjRadius
		)

		game.Players.LocalPlayer.PlayerGui:WaitForChild("TopDisplay").PreviewFrameMapDetail.BeatmapDetail.MapDetail.Text = DetailedFormat
	else
		PreviewFrame.Overview.DifficultyInfo.Text = "Length - "..ReturnTime(ReturnData.Overview.MapLength).." CS: ? OD: ? HP:? AR: ?"
		PreviewFrame.Overview.BeatmapDifficulty.Text = "<b>Difficulty rating: 0</b>"
	end
	
	-- MetaData information frame
	local MetaDataDetailedFrame = game.Players.LocalPlayer.PlayerGui.BG.DetailedBeatmapInformation.MainFrame.MainFrame.MetaData
	local MetaData = ReturnData.Overview.Metadata
	
	MetaDataDetailedFrame.SongTitle.Data.Text = MetaData.MapNameUnicode or ""
	MetaDataDetailedFrame.SongArtist.Data.Text = MetaData.SongCreatorUnicode or ""
	MetaDataDetailedFrame.Source.Data.Text = MetaData.Source or ""
	MetaDataDetailedFrame.MapperName.Data.Text = MetaData.BeatmapCreator or ""
	MetaDataDetailedFrame.DiffName.Data.Text = MetaData.DifficultyName or ""
	MetaDataDetailedFrame.Tags.Data.Text = MetaData.Tags or ""
	
	local soundIDDisplay = ReturnData.MapSongId or ""
	soundIDDisplay ..= ReturnData.MapSongId2 and ", "..ReturnData.MapSongId2 or ""
	
	MetaDataDetailedFrame.AudioID.Data.Text = soundIDDisplay
	MetaDataDetailedFrame.ImageID.Data.Text = ReturnData.ImageId or ""
	
	-- Web information data
	
	local crrWebRequestID = game.HttpService:GenerateGUID()
	webRequestID = crrWebRequestID
	
	local function getBeatmapData(data, mapID)
		for _, map in pairs(data) do
			if tostring(map.id) == tostring(mapID) then
				return map
			end
		end
	end
	spawn(function()
		local BeatmapsetID = ReturnData.BeatmapSetsData.BeatmapsetID
		local BeatmapID = ReturnData.BeatmapSetsData.BeatmapID
		local WebDetailedFrame = game.Players.LocalPlayer.PlayerGui.BG.DetailedBeatmapInformation.MainFrame.MainFrame.WebData
		
		-- Set to default while waiting for data
		WebDetailedFrame.BeatmapID.Data.Text = "-"
		WebDetailedFrame.BeatmapsetID.Data.Text = "-"
		WebDetailedFrame.WebPlayCount.Data.Text = "-"
		WebDetailedFrame.WebFavoriteCount.Data.Text = "-"
		WebDetailedFrame.WebRankedStatus.Data.Text = "-"
		WebDetailedFrame.CreationDate.Data.Text = "-"
		WebDetailedFrame.SuccessRate.Data.Text = "-"
		
		local webData = game.ReplicatedStorage.GetBeatmapWebInfo:InvokeServer(BeatmapID)
		
		if webData == nil or webRequestID ~= crrWebRequestID then
			return
		end
		
		local RelatedUsers = {}
		local mapCreators = {}
		
		-- insert username into uid
		for _, user in pairs(webData.related_users) do
			RelatedUsers[user.id] = user.username
		end
		
		
		for _, map in pairs(webData.beatmaps) do
			local mapOwnerData = map.owners
			if #mapOwnerData > 1 then
				local text = ""
				for i, ownerData in pairs(mapOwnerData) do
					text ..= ownerData.username
					if i == #mapOwnerData-1 then
						text ..= " and "
					elseif i < #mapOwnerData-1 then
						text ..= ", "
					end
				end
				mapCreators[tostring(map.id)] = text
			else
				mapCreators[tostring(map.id)] = mapOwnerData[1].username
			end
		end
		
		mapCreators["set_"..tostring(BeatmapsetID)] = RelatedUsers[webData.user_id]
		
		
		game.Players.LocalPlayer.PlayerGui.BeatmapListing.MainFrame:WaitForChild("MainFrame").WorkingScript.UpdateRelatedMapper:Fire(mapCreators)
		

		WebDetailedFrame.BeatmapID.Data.Text = tostring(BeatmapID)
		WebDetailedFrame.BeatmapsetID.Data.Text = tostring(BeatmapsetID)
		WebDetailedFrame.WebPlayCount.Data.Text = tostring(webData.play_count)
		WebDetailedFrame.WebFavoriteCount.Data.Text = tostring(webData.favourite_count)
		WebDetailedFrame.WebRankedStatus.Data.Text = tostring(webData.status)
		local creationDate
		pcall(function()
			creationDate = DateTime.fromIsoDate(webData.submitted_date)
		end)
		
		if creationDate then
			local creationTime = creationDate:ToLocalTime()
			WebDetailedFrame.CreationDate.Data.Text = string.format("%.2d/%.2d/%.4d", creationTime.Day, creationTime.Month, creationTime.Year)
		end
		local mapData = getBeatmapData(webData.beatmaps, BeatmapID)
		if mapData then
			WebDetailedFrame.SuccessRate.Data.Text = string.format("%.2f%% (%d/%d)", (mapData.passcount/mapData.playcount) * 100, mapData.passcount, mapData.playcount)
		end
	end)

	-- Detailed information frame

	local DetailedInterface = game.Players.LocalPlayer.PlayerGui.BG.DetailedBeatmapInformation.MainFrame.MainFrame.DifficultyData

	local AimDiff = ReturnData.Difficulty.AimDifficulty
	local SpeedDiff = ReturnData.Difficulty.SpeedDifficulty
	local FLDiff = ReturnData.Difficulty.FlashLightDifficulty
	local BaseDiff = ReturnData.Difficulty.BeatmapDifficulty

	local AddsUp = AimDiff + SpeedDiff



	--AimDiff = AimDiff/AddsUp*BaseDiff
	--SpeedDiff = SpeedDiff/AddsUp*BaseDiff
	
	local ModdedARRate = ARRate
	local ActualARValue = PreviewFrame.Overview.DiffListing.AR.ActualValue

	local ModdedODRate = ODRate
	local ActualODValue = PreviewFrame.Overview.DiffListing.OD.ActualValue

	if SongSpeed ~= 1 then
		-- Calculate actual AR
		local ARTime = 1200
		if ARRate < 5 then
			ARTime = 1200 + 600 * (5 - ARRate) / 5
		elseif ARRate > 5 then
			ARTime = 1200 - 750 * (ARRate - 5) / 5
		else
			ARTime = 1200
		end

		ARTime /= SongSpeed

		if ARTime > 1200 then
			ModdedARRate = 5 - (ARTime - 1200)*5/600
		else
			ModdedARRate = 5 + (1200 - ARTime)*5/750
		end

		-- Calculate actual OD
		-- We are using the default hit window
		local Hit300Time = 80 - 6 * ODRate
		Hit300Time /= SongSpeed
		ModdedODRate = -(Hit300Time - 80) / 6
		
		--print(ODRate, ModdedODRate)


		ActualARValue.Text = "("..tostring(math.round(ModdedARRate*100)/100)..")"
		ActualODValue.Text = "("..tostring(math.round(ModdedODRate*100)/100)..")"
		local TweenInfo_DiffAnimation = TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut)
		if EasyMod or (not HardRock and SongSpeed < 1) then
			TweenService:Create(ActualODValue,TweenInfo_DiffAnimation,{TextColor3 = Color3.new(0.607843, 1, 1)}):Play()
			TweenService:Create(ActualARValue,TweenInfo_DiffAnimation,{TextColor3 = Color3.new(0.607843, 1, 1)}):Play()
		elseif HardRock or (not EasyMod and SongSpeed > 1) then
			TweenService:Create(ActualODValue,TweenInfo_DiffAnimation,{TextColor3 = Color3.new(1, 0.607843, 0.607843)}):Play()
			TweenService:Create(ActualARValue,TweenInfo_DiffAnimation,{TextColor3 = Color3.new(1, 0.607843, 0.607843)}):Play()
		else
			TweenService:Create(ActualODValue,TweenInfo_DiffAnimation,{TextColor3 = Color3.new(1, 1, 1)}):Play()
			TweenService:Create(ActualARValue,TweenInfo_DiffAnimation,{TextColor3 = Color3.new(1, 1, 1)}):Play()
		end
	else
		ActualODValue.Text = ""
		ActualARValue.Text = ""
	end

	-- Modifier effects
	local AimMultiplier = 1
	local SpeedMultiplier = 1
	local AccMultiplier = 1
	local FLMultiplier = 1

	local ModData = {
		NS = NoSlider,
		NF = NoFail,
		HD = HiddenMod,
		FL = FlashLight,
		TD = false
	}
	
	local NoteCount = {
		Circle = Notes, Slider = Sliders, Spinner = Spinners
	}
	
	local playMultiplier = {
		Aim = AimMultiplier, Speed = SpeedMultiplier, FlashLight = FLMultiplier, Accuracy = AccMultiplier
	}
	
	local MaxPSData = PerfomanceCalculator(AimDiff, SpeedDiff, FLDiff, ODRate, ARRate, ModData, NoteCount, SongSpeed, playMultiplier, true)
	local RewardedAimPS = MaxPSData.Aim
	local RewardedSpeedPS = MaxPSData.Speed
	local RewardedAccPS = MaxPSData.Acc
	local RewardedFlashlightPS = MaxPSData.FlashLight
	

	-- Nerf 60% aim PS and 60% flaslight PS on Touch devices
	local TouchDevicePS = MaxPSData.TouchDevicePS - MaxPSData.MaxTotalPS
	local ModPS = MaxPSData.ModEffects
	local TotalPS = MaxPSData.MaxTotalPS

	DetailedInterface.Difficulty.Data.Text = string.format("%.2f (%.2fps)",BaseDiff,TotalPS)
	DetailedInterface.AimDifficulty.Data.Text = string.format("%.2f (%.2fps)",AimDiff,RewardedAimPS)
	DetailedInterface.SpeedDifficulty.Data.Text = string.format("%.2f (%.2fps)",SpeedDiff,RewardedSpeedPS)
	if FlashLight then
		DetailedInterface.FlashlightDifficulty.Data.Text = string.format("%.2f (%.2fps)",FLDiff,RewardedFlashlightPS)
		DetailedInterface.FlashlightDifficulty.Data.TextTransparency = 0
	else
		DetailedInterface.FlashlightDifficulty.Data.Text = "Inactive"
		DetailedInterface.FlashlightDifficulty.Data.TextTransparency = 0.5
	end
	DetailedInterface.AccBonus.Data.Text = string.format("%.2fps",RewardedAccPS)
	DetailedInterface.ModsBonus.Data.Text = string.format("%.2fps",ModPS)
	DetailedInterface.TouchDeviceBonus.Data.Text = string.format("%.2fps",TouchDevicePS)

	-- Gameplay Data
	local ConstantHPDrainRate = 5
	DetailedInterface = DetailedInterface.Parent.GameplayData

	if HPRate < 5 then
		ConstantHPDrainRate = (5 - 2 * (5 - HPRate) / 5)
	else
		ConstantHPDrainRate = (5 + 5 * (HPRate - 5) / 5)
	end

	local MissDrain = 10.5

	if HPRate < 5 then
		MissDrain = 10.5 - 5.5 * (5 - HPRate) / 5
	else
		MissDrain = 10.5 + 9.5 * (HPRate - 5) / 5
	end

	ConstantHPDrainRate *= SongSpeed

	DetailedInterface.ConstantDrainRate.Data.Text = string.format("%.1f - %.1f%%/sec",ConstantHPDrainRate,ConstantHPDrainRate*3)
	DetailedInterface.MissDrain.Data.Text = string.format("%.1f%%",MissDrain)
	DetailedInterface.MaxHealth.Data.Text = string.format("%s",EasyMod and "3 x 100%" or "100%")

	local HitWindowData = {
		h300 = 100 - 8 * ODRate,
		h100 = 175 - 10 * ODRate,
		h50 = 250 - 12.5 * ODRate,
		TDh300 = 150 - 12 * ODRate,
		TDh100 = 220 - 12.5 * ODRate,
		TDh50 = 275 - 13.5 * ODRate
	}

	DetailedInterface.HitWindow.Data.Text = string.format("%.1f/%.1f/%.1fms",
		HitWindowData.h300/SongSpeed,
		HitWindowData.h100/SongSpeed,
		HitWindowData.h50/SongSpeed
	)

	DetailedInterface.HitWindowTD.Data.Text = string.format("%.1f/%.1f/%.1fms",
		HitWindowData.TDh300/SongSpeed,
		HitWindowData.TDh100/SongSpeed,
		HitWindowData.TDh50/SongSpeed
	)


	-- Difficulty strike
	for i = 1,5 do
		wait()
	end

	local ExpomentalRate = 2

	local DifficultyStrike = ReturnData.Difficulty.DifficultyStrike
	local HighestDiffTime = DifficultyStrike.Highest
	local DiffTimeList = DifficultyStrike.List
	DiffTimeList = GenerateSineTimeline(DiffTimeList)

	local DiffDisplay = PreviewFrame.DifficultyDisplay.MainFrame

	--DiffDisplay:ClearAllChildren()
	if not DiffDisplay:FindFirstChild("DifficultyStrikeListLayout") then
		script.UILayout.DifficultyStrikeListLayout:Clone().Parent = DiffDisplay
	end
	local List = DiffDisplay:GetChildren()
	local TotalList = #List
	for i,a in pairs(List) do
		if a:IsA("UIListLayout") then
			table.remove(List,i)
		end
	end
	local SpaceUsed = 0
	local TweenInfo_DiffTimeline = TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)

	for i = 1,30 do
		local Frame = PreviewFrame.DifficultyDisplay.Background:WaitForChild(tostring(i))
		local HighestDiffTime = HighestDiffTime/10

		if (i < HighestDiffTime-4 and math.pow((i)/HighestDiffTime,ExpomentalRate) < 0.25) or i > HighestDiffTime + 1 or (HighestDiffTime > 12 and i%2 ~= 0 and i < math.floor(HighestDiffTime)) then
			local TweenPos = math.max(1-math.pow(i/HighestDiffTime,ExpomentalRate),1-math.pow((HighestDiffTime+1)/HighestDiffTime,3))
			TweenService:Create(Frame,TweenInfo_DiffTimeline,{BackgroundTransparency = 1,Position = UDim2.new(0,0,TweenPos,2)}):Play()
			TweenService:Create(Frame.Display,TweenInfo_DiffTimeline,{TextTransparency = 1}):Play()
		else
			TweenService:Create(Frame,TweenInfo_DiffTimeline,{BackgroundTransparency = 0.9,Position = UDim2.new(0,0,1-math.pow(i/HighestDiffTime,ExpomentalRate),0)}):Play()
			TweenService:Create(Frame.Display,TweenInfo_DiffTimeline,{TextTransparency = 0.5}):Play()
		end
	end

	for i,Diff in pairs(DiffTimeList) do
		local DiffFrame = Instance.new("Frame",DiffDisplay)
		local FrameSize = UDim2.new(1/#DiffTimeList,0,math.pow(Diff/HighestDiffTime,ExpomentalRate),0)
		SpaceUsed += 1/#DiffTimeList
		local UsedOldFrame = false
		if #List <= 0 then
			DiffFrame.Size = UDim2.new(0,0,0,0)
			DiffFrame.ZIndex = i
			DiffFrame.BorderSizePixel = 0
			DiffFrame.BackgroundTransparency = 1
			--TweenService:Create(DiffFrame,TweenInfo.new(0.1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(1/#DiffTimeList,0,0,0)}):Play()
		else
			UsedOldFrame = true
			DiffFrame:Destroy()
			DiffFrame = List[1]
			table.remove(List,1)
		end

		DiffFrame.LayoutOrder = i
		DiffFrame.BorderSizePixel = 0
		local DifficultyColor = Diff/50
		DifficultyColor = (195 - (DifficultyColor*195))/360
		--195
		--print(Color3.fromHSV(0.666667, 1, 1))

		-- Soul crusing difficulty color, inspired from Juke's Towers of Hell
		local SatColor = 180 

		if Diff > 50 and Diff <= 80 then
			DifficultyColor = ((Diff-50) / 30)*120
			DifficultyColor = (360-DifficultyColor)/360
			SatColor = 180 + ((Diff-50) / 30)*75
		elseif Diff > 80 and Diff < 100 then
			DifficultyColor = 2/3
			local Color = (Diff-80)/20
			SatColor = (1-Color)*255
		elseif Diff >= 100 then
			SatColor = 0
		end



		if DifficultyColor < 0 then DifficultyColor = 0 end
		if not UsedOldFrame then
			DiffFrame.BackgroundColor3 = Color3.fromHSV(DifficultyColor,SatColor/255,1)
		else
			TweenService:Create(DiffFrame,TweenInfo_DiffTimeline,{BackgroundColor3 = Color3.fromHSV(DifficultyColor,SatColor/255,1)}):Play()
		end

		spawn(function()
			TweenService:Create(DiffFrame,TweenInfo_DiffTimeline,{Size = FrameSize,BackgroundTransparency = 0}):Play()
		end)
	end

	spawn(function()
		for _,a in pairs(List) do
			spawn(function()
				TweenService:Create(a,TweenInfo_DiffTimeline,{Size = UDim2.new(0,0,0,0)}):Play()
			end)
		end
		wait(0.75)
		for _,a in pairs(List) do
			a:Destroy()
		end
	end)
	

	PreviewFrame.Overview.SL_Warnings.Visible = ReturnData.WeirdSliderAlert == true

	local BPMList = {}
	local SortedBPMList = {}
	local List1 = {}
	local HighestBPM = -1
	local LowestBPM = -1
	local MostlyBPM = -1
	for _,Timing in pairs(TimmingPoints) do
		if Timing[2] > 0 then
			BPMList[#BPMList+1] = {Timing[1],math.round(1 / Timing[2] * 1000 * 60)}
		end
	end

	for i,data in pairs(BPMList) do
		if data[2] > HighestBPM or HighestBPM == -1 then
			HighestBPM = data[2]
		end
		if data[2] < LowestBPM or LowestBPM == -1 then
			LowestBPM = data[2]
		end
		if not List1[tonumber(data[2])] then
			List1[tonumber(data[2])] = {BPM = data[2],Length = 0}
		end
		if i == #BPMList then
			List1[tonumber(data[2])].Length += BeatmapData[#BeatmapData].Time - data[1]
		else
			List1[tonumber(data[2])].Length += BPMList[i+1][1] - data[1]
		end
	end

	for i,a in pairs(List1) do
		SortedBPMList[#SortedBPMList+1] = a
	end

	table.sort(SortedBPMList,function(a,b) return a.Length > b.Length end)
	MostlyBPM = math.round(SortedBPMList[1].BPM*SongSpeed)
	HighestBPM = math.round(HighestBPM*SongSpeed)
	LowestBPM = math.round(LowestBPM*SongSpeed)

	local BPMChangeEmoji = ""
	if SongSpeed > 1 then
		BPMChangeEmoji = "⬆️"
	elseif SongSpeed < 1 then
		BPMChangeEmoji = "⬇️"
	end

	if MostlyBPM > 1e10 then
		MostlyBPM = "Infinity"
	end

	if LowestBPM > 1e10 then
		LowestBPM = "Infinity"
	end

	if HighestBPM > 1e10 then
		HighestBPM = "Infinity"
	end

	local InformationFrame = PreviewFrame.Overview.Information

	PreviewFrame.Overview.BeatmapInfo.Text = "Total:"..tostring(TotalNotes).." Note:"..tostring(Notes).." Slider:"..tostring(Sliders).." Spinner:"..tostring(Spinners)
	if HighestBPM == LowestBPM and LowestBPM == MostlyBPM then
		PreviewFrame.Overview.BPMCount.Text = "BPM: "..tostring(MostlyBPM)..BPMChangeEmoji
		
		local Data = {
			SingleBPM = true, MostlyBPM = MostlyBPM
		}
		
		InformationFrame.BPM.Raw.Data.Value = game:GetService("HttpService"):JSONEncode(Data)

		--InformationFrame.BPM.Display.Text = tostring(MostlyBPM)..BPMChangeEmoji
	else
		PreviewFrame.Overview.BPMCount.Text = "BPM: "..tostring(LowestBPM).." - "..tostring(HighestBPM).." ("..tostring(MostlyBPM)..BPMChangeEmoji..")"
		
		local Data = {
			SingleBPM = false, MostlyBPM = MostlyBPM, MinBPM = LowestBPM, MaxBPM = HighestBPM
		}
		
		InformationFrame.BPM.Raw.Data.Value = game:GetService("HttpService"):JSONEncode(Data)

		--InformationFrame.BPM.Display.Text = tostring(LowestBPM).." - "..tostring(HighestBPM).." ("..tostring(MostlyBPM)..BPMChangeEmoji..")"
	end



	CurrentKey = ReturnData.BeatmapSetsData.BeatmapsetID.."-"..ReturnData.BeatmapSetsData.BeatmapID
	BeatmapKey = ReturnData.BeatmapSetsData.BeatmapID

	for i = 1,10 do
		wait()
	end

	local function isRequireSongReload(PreviewFrame, SongId, SongId2, isExistSecondSong)
		SongId = "rbxassetid://"..SongId
		SongId2 = isExistSecondSong and "rbxassetid://"..SongId or ""
		local Id = PreviewFrame.OverviewSong.Asset
		
		if isExistSecondSong then
			if not PreviewFrame:FindFirstChild("OverviewSong2") then return true end
			local Id2 = PreviewFrame.OverviewSong2.Asset
			if Id2 ~= SongId2 then return true end
		end
		
		if Id ~= SongId then return true end
		
		return not (PreviewFrame.OverviewSong.IsPlaying or (isExistSecondSong and PreviewFrame.OverviewSong2.IsPlaying))
	end

	spawn(function()
		local Mixer = PreviewFrame.AudioChannelMixer
		if BasePreviewBeatmapset == "" then
			BasePreviewBeatmapset = PreviewBeatmapset
		end
		local isExistSecondSong = (ReturnData.MapSongId2 ~= nil)
		if (ReturnData.MapSongId or ReturnData.CustomSongFile) and isRequireSongReload(PreviewFrame, ReturnData.MapSongId, ReturnData.MapSongId2, isExistSecondSong) and BasePreviewBeatmapset ~= ReturnData.BeatmapSetsData.BeatmapsetID then
			local OldSongObj = PreviewFrame.OverviewSong
			thisScript.Archive:ClearAllChildren()
			OldSongObj.LocalScript:Destroy()
			OldSongObj.Parent = thisScript.Archive
			local OldSongObj2 = PreviewFrame:FindFirstChild("OverviewSong2")
			if OldSongObj2 then
				OldSongObj2.LocalScript:Destroy()
				OldSongObj2.Parent = thisScript.Archive
			end
			local NewSongObj = thisScript.OverviewSong:Clone()
			NewSongObj.Parent = PreviewFrame
			NewSongObj.LocalScript.Disabled = false

			NewSongObj.Wire.TargetInstance = Mixer
			local NewSongObj2
			if isExistSecondSong then
				NewSongObj2 = thisScript.OverviewSong2:Clone()
				NewSongObj2.Parent = PreviewFrame
				NewSongObj2.LocalScript.Disabled = false
				NewSongObj2.Asset = "rbxassetid://"..tostring(ReturnData.MapSongId2)
				NewSongObj2.Wire.TargetInstance = Mixer
			end


			PreviewFrame.OverviewSong.Asset = ReturnData.CustomSongFile or "rbxassetid://"..tostring(ReturnData.MapSongId)
			
			repeat wait() until PreviewFrame.OverviewSong.IsReady == true and ((NewSongObj2 and NewSongObj2.IsReady == true) or true)
			
			local PreviewTime = (ReturnData.Overview.OverviewStartTime/1000)
			
			if PreviewTime < 0 then PreviewTime = 0 end

			PreviewFrame.OverviewSong.StartTime.Value = PreviewTime
			if isExistSecondSong then
				PreviewFrame.OverviewSong2.StartTime.Value = PreviewTime
			end
			
			if game.Players.LocalPlayer.PlayerScripts.DataValue.FirstJoinMusic.Value == true then
				game.Players.LocalPlayer.PlayerScripts.DataValue.FirstJoinMusic.Value = false
				PreviewTime = 0
			end

			if ReturnData.SongSpeed then
				PreviewTime *= ReturnData.SongSpeed
			end
			if PreviewTime <= PreviewFrame.OverviewSong.TimeLength then
				PreviewFrame.OverviewSong.TimePosition = PreviewTime
			elseif isExistSecondSong then
				PreviewFrame.OverviewSong2.TimePosition = PreviewTime - PreviewFrame.OverviewSong.TimeLength
			end
			local PrevMapTime = CurrentSetting.VirtualSettings.PrevMapTime
			if PrevMapTime.Value >= 10 and PrevMapTime.Value < ReturnData.Overview.MapLength/1000 then
				local PrevTime = PrevMapTime.Value + 1.5
				PreviewTime = PrevTime
				if isExistSecondSong and PrevTime > PreviewFrame.OverviewSong.TimeLength then
					PreviewFrame.OverviewSong2.TimePosition = PrevTime - PreviewFrame.OverviewSong.TimeLength
				else
					PreviewFrame.OverviewSong.TimePosition = PrevTime
				end
			end
			PrevMapTime.Value = -1
			PreviewFrame.OverviewSong.Volume = 0
			if isExistSecondSong then
				PreviewFrame.OverviewSong2.Volume = 0
			end
			local PreviewVolume = PreviewFrameBaseVolume
			PreviewFrame.OverviewVolume.Value = PreviewVolume
			TweenService:Create(PreviewFrame.OverviewSong,TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Volume = PreviewVolume*SongVolume*0.01}):Play()
			if isExistSecondSong then
				TweenService:Create(PreviewFrame.OverviewSong2,TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Volume = PreviewVolume*SongVolume*0.01}):Play()
			end
			TweenService:Create(OldSongObj,TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Volume = 0}):Play()
			if OldSongObj2 then
				TweenService:Create(OldSongObj2,TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Volume = 0}):Play()
			end
			local StateReady = game.Players.LocalPlayer.PlayerGui.LoadUI:WaitForChild("StateReady")
			if not StateReady.Value then
				repeat wait() until StateReady.Value
			end
			
			if PreviewTime > PreviewFrame.OverviewSong.TimeLength and isExistSecondSong then
				print(PreviewFrame.OverviewSong2.TimePosition)
				PreviewFrame.OverviewSong2:Play()
				PreviewFrame.OverviewSong:Stop()
			else
				PreviewFrame.OverviewSong:Play()
			end
			spawn(function()
				local Song
				if game.Players.LocalPlayer.PlayerGui:FindFirstChild("TransitionSong") then
					Song = game.Players.LocalPlayer.PlayerGui.TransitionSong

					--print(PreviewFrame.OverviewSong.TimePosition - Song.TimePosition)
					TweenService:Create(Song,TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Volume = 0}):Play()
				end
				wait(0.5)
				OldSongObj:Destroy()
				if Song then
					Song:Destroy()
				end
			end)
		end

		TweenService:Create(PreviewFrame.OverviewSong,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{PlaybackSpeed = ReturnData.SongSpeed * SongSpeed}):Play()
		if isExistSecondSong then TweenService:Create(PreviewFrame.OverviewSong2,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{PlaybackSpeed = ReturnData.SongSpeed * SongSpeed}):Play() end

		if KeepOriginalPitch then
			TweenService:Create(PreviewFrame.OverviewSong.DefaultPitch,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Pitch = ReturnData.SongPitch}):Play()
			if isExistSecondSong then TweenService:Create(PreviewFrame.OverviewSong2.DefaultPitch,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Pitch = ReturnData.SongPitch}):Play() end
		else
			TweenService:Create(PreviewFrame.OverviewSong.DefaultPitch,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Pitch = ReturnData.SongPitch/SongSpeed}):Play()
			if isExistSecondSong then TweenService:Create(PreviewFrame.OverviewSong2.DefaultPitch,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Pitch = ReturnData.SongPitch/SongSpeed}):Play() end 
		end

		--PreviewFrame.OverviewSong.PlaybackSpeed = ReturnData.SongSpeed * SongSpeed


		PreviewBeatmapset = ReturnData.BeatmapSetsData.BeatmapsetID
		BasePreviewBeatmapset = PreviewBeatmapset
	end)
	wait()

	-- BackgroundChange

	repeat until wait() <= 1/30
	local Background = game.Players.LocalPlayer.PlayerGui.BG.Background.Background
	local Background_Listing = game.Players.LocalPlayer.PlayerGui.BeatmapListing.MainFrame.MainFrame.BG_Ambient.Main.Backgrounds

	ReturnData.ImageId = ReturnData.CustomBackgroundFile or tostring(ReturnData.ImageId)
	local NewBackground
	local NewBackground_Listing

	if ReturnData.ImageId ~= "0" then
		local TweenTime = 0.25
		if #Background:GetChildren() > 1 then
			TweenTime = 0
		end
		NewBackground = script.BackgroundImage:Clone()
		NewBackground.ZIndex = 0
		NewBackground.Parent = Background
		NewBackground.Image = "http://www.roblox.com/asset/?id="..ReturnData.ImageId
		
		NewBackground_Listing = script.BackgroundImage_Listing:Clone()
		NewBackground_Listing.ZIndex = 0
		NewBackground_Listing.Parent = Background_Listing
		NewBackground_Listing.Image = "http://www.roblox.com/asset/?id="..ReturnData.ImageId
		
		
		for i = 1,2 do
			game:GetService("ContentProvider"):PreloadAsync({NewBackground, NewBackground_Listing})
		end
		if NewBackground and NewBackground.Parent then
			TweenService:Create(NewBackground,TweenInfo.new(TweenTime,Enum.EasingStyle.Linear),{ImageTransparency = 0}):Play()
		end
		
		if NewBackground_Listing and NewBackground_Listing.Parent then
			TweenService:Create(NewBackground_Listing,TweenInfo.new(TweenTime,Enum.EasingStyle.Linear),{ImageTransparency = 0.3}):Play()
		end
	end
	
	for _,Obj in pairs(Background:GetChildren()) do 
		if Obj:IsA("ImageLabel") and Obj ~= NewBackground then
			Obj.ZIndex = 999
			TweenService:Create(Obj,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
			spawn(function()
				wait(0.25)
				Obj:Destroy()
			end)
		end
	end
	
	for _,Obj in pairs(Background_Listing:GetChildren()) do 
		if Obj:IsA("ImageLabel") and Obj ~= NewBackground_Listing then
			Obj.ZIndex = 999
			TweenService:Create(Obj,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
			spawn(function()
				wait(0.25)
				Obj:Destroy()
			end)
		end
	end

	local PreviewMapPS = {
		Aim = 0, Speed = 0, Mod = 0, AimFL = 0, Acc = 0, TD = TouchDevicePS, objCount = 0
	}

	local AimPSList = {}
	local SpeedPSList = {}
	local OverallPSList = {}
	local BaseMultiplier = 100

	local CurrentAimStrain = 0
	local CurrentSpeedStrain = 0
	
	-- Add all external information of the beatmap to the game (mostly use for leaderboard)

	PreviewMapPS.Aim = RewardedAimPS
	PreviewMapPS.Speed = RewardedSpeedPS
	PreviewMapPS.Mod = {Aim = AimMultiplier, Speed = SpeedMultiplier, Acc = AccMultiplier}

	PreviewMapPS.AimFL = 0 --PreviewMapPS.Aim*(#BeatmapData/1000)*0.35 * 0
	PreviewMapPS.AimHDFL = 0 --PreviewMapPS.Aim*(#BeatmapData/1000)*0.4 * 0
	PreviewMapPS.Acc = RewardedAccPS
	PreviewMapPS.objCount = #BeatmapData
	PreviewMapPS.objCountData = ReturnData.NoteCount
	PreviewMapPS.OD = ODRate
	PreviewMapPS.AR = ARRate
	PreviewMapPS.MaxCombo = ReturnData.Difficulty.MaxCombo
	PreviewMapPS.MaxSpinnerScore = ReturnData.Difficulty.MaxSpinnerScore
	PreviewMapPS.MaxAccScore = MaxAccScore
	PreviewMapPS.MaxConsistencyScore = MaxConsistencyScore
	PreviewMapPS.AimDiffStrainCount = ReturnData.Difficulty.AimDifficultyStrainCount
	PreviewMapPS.SpeedDiffStrainCount = ReturnData.Difficulty.SpeedDifficultyStrainCount
	PreviewMapPS.SpeedRelevantNoteCount = ReturnData.Difficulty.SpeedRelevantNoteCount
	PreviewMapPS.CurrentSpeed = SongSpeed
	PreviewMapPS.AimDiff = AimDiff
	PreviewMapPS.SpeedDiff = SpeedDiff
	PreviewMapPS.FLDiff = FLDiff
	PreviewMapPS.MapFile = ReturnData.MapFile -- Used for scores that have difference in Speed,EZ,HR,FL

	--print(PreviewMapPS.Aim+PreviewMapPS.Speed+PreviewMapPS.Mod+PreviewMapPS.Acc)


	return CurrentModData,CurrentKey,BeatmapKey,PreviewFrameBaseVolume,PreviewBeatmapset,PreviewMapPS
end
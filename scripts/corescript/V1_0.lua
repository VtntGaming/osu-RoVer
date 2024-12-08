game.Players.LocalPlayer.PlayerGui:WaitForChild("BG"):WaitForChild("StartButton")

if game.Players.LocalPlayer.PlayerGui.SavedSettings:FindFirstChild("SettingsFrame") then
	game.Players.LocalPlayer.PlayerGui.BG.SettingsFrame:Destroy()
	game.Players.LocalPlayer.PlayerGui.SavedSettings.SettingsFrame:Clone().Parent = game.Players.LocalPlayer.PlayerGui.BG
end

local CurrentSetting = game.Players.LocalPlayer.PlayerGui.BG.SettingsFrame

-- Those settings can be change multiply times before the game start
local FileType = 1
local AutoPlay = false
-----

if CurrentSetting.MainSettings.CustomBeatmap.Text == "Custom beatmap: Enabled" then
	FileType = 2
end
if CurrentSetting.MainSettings.AutoPlay.Text == "Auto play: Enabled" then
	AutoPlay = true
end

CurrentSetting.MainSettings.CustomBeatmap.MouseButton1Click:Connect(function()
	if FileType == 1 then
		FileType = 2
		CurrentSetting.MainSettings.BeatmapFile.TextEditable = true
		CurrentSetting.MainSettings.CustomBeatmap.Text = "Custom beatmap: Enabled"
	else
		FileType = 1
		CurrentSetting.MainSettings.BeatmapFile.TextEditable = false
		CurrentSetting.MainSettings.CustomBeatmap.Text = "Custom beatmap: Disabled"
	end
end)

CurrentSetting.MainSettings.AutoPlay.MouseButton1Click:Connect(function()
	AutoPlay = not AutoPlay
	if AutoPlay == true then
		CurrentSetting.MainSettings.AutoPlay.Text = "Auto play: Enabled"
	else
		CurrentSetting.MainSettings.AutoPlay.Text = "Auto play: Disabled"
	end
end)





script.Parent.Parent.BG.StartButton.MouseButton1Click:Wait()
script.Parent.Parent.BG.StartButton:Destroy()
game.Players.LocalPlayer.PlayerGui.SavedSettings:ClearAllChildren()
CurrentSetting.Parent = game.Players.LocalPlayer.PlayerGui.SavedSettings

local Settings = CurrentSetting.MainSettings




local Key1Input = Enum.KeyCode[Settings.K1.Text]
local Key2Input = Enum.KeyCode[Settings.K2.Text]
local SongSpeed = tonumber(Settings.Speed.Text)
local SongDelay = tonumber(Settings.MapDelay.Text)
local Difficulty = 6 --Currently unuse
local CS = tonumber(Settings.CS.Text)
local ApproachRate = tonumber(Settings.AR.Text)
local OverallDifficulty = tonumber(Settings.OD.Text)
local Beatmap = Settings.BeatmapFile.Text
local BeatmapStudio = workspace.Beatmaps.Highscore_GameOver --If test on studio
local SongId = Settings.SoundID.Text
if tonumber(SongId) == nil then
	SongId = "0"
end
SongId = (string.sub(SongId,1,13) == "rbxassetid://" and SongId) or "rbxassetid://"..SongId
script.Parent.Song.SoundId = SongId

-- Error check
if Key1Input == nil then
	Key1Input = Enum.KeyCode.Z
end
if Key2Input == nil then
	Key2Input = Enum.KeyCode.X
end
if SongSpeed == nil or SongSpeed < 0 or SongSpeed > 20 then
	SongSpeed = 1
end
if SongDelay == nil or math.abs(SongDelay) > 2000 then
	SongDelay = 0
end
if CS == nil or CS < 0 or CS > 10 then
	CS = 5
end
if ApproachRate == nil or ApproachRate < 0 or ApproachRate > 10 then
	ApproachRate = 5
end
if OverallDifficulty == nil or OverallDifficulty < 0 or OverallDifficulty > 10 then
	OverallDifficulty = 5
end
if Beatmap == nil or Beatmap == "" then
	Beatmap = BeatmapStudio
	FileType = 1
end



local BeatmapData = require(workspace.OsuConvert)(FileType,Beatmap,SongSpeed,SongDelay)

--------


--[[
File type:
1 - Used roblox module return a beatmap text
2 - Used a text send to beatmap to convert

]]

if AutoPlay == false then
	script.Parent.PlayFrame.Cusor.ImageTransparency = 1
	local PlayerMouse = game.Players.LocalPlayer:GetMouse()
	PlayerMouse.Icon = "http://www.roblox.com/asset/?id=6979941273"
	PlayerMouse.Move:Connect(function()
		local NewPos = Vector2.new(PlayerMouse.X-(script.Parent.AbsoluteSize.X-script.Parent.PlayFrame.AbsoluteSize.X)/2,PlayerMouse.Y-(script.Parent.AbsoluteSize.Y-script.Parent.PlayFrame.AbsoluteSize.Y)/2)
		NewPos = UDim2.new(NewPos.X/script.Parent.PlayFrame.AbsoluteSize.X,0,NewPos.Y/script.Parent.PlayFrame.AbsoluteSize.Y,0)
		script.Parent.PlayFrame.Cusor.Position = NewPos
	end)

	game:GetService("UserInputService").InputBegan:Connect(function(data)
		if data.KeyCode == Key1Input then
			script.Parent.MouseHit:Fire(1)
		elseif data.KeyCode == Key2Input then
			script.Parent.MouseHit:Fire(2)
		elseif data.UserInputType == Enum.UserInputType.MouseButton1 then
			script.Parent.MouseHit:Fire(3)
		elseif data.UserInputType == Enum.UserInputType.MouseButton2 then
			script.Parent.MouseHit:Fire(4)
		end
	end)
	game:GetService("UserInputService").InputEnded:Connect(function(data)
		if data.KeyCode == Key1Input then
			script.Parent.MouseHitEnd:Fire(1)
		elseif data.KeyCode == Key2Input then
			script.Parent.MouseHitEnd:Fire(2)
		elseif data.UserInputType == Enum.UserInputType.MouseButton1 then
			script.Parent.MouseHitEnd:Fire(3)
		elseif data.UserInputType == Enum.UserInputType.MouseButton2 then
			script.Parent.MouseHitEnd:Fire(4)
		end
	end)
end
local K1 = 0
local K2 = 0
local K3 = 0
local K4 = 0

spawn(function()
	local TweenService = game:GetService("TweenService")
	local KeyTweenInfo = TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
	local ChangeIn1 = {Size = UDim2.new(0.18,0,0.18,0),BackgroundColor3 = Color3.new(1, 1, 0)}
	local ChangeIn2 = {Size = UDim2.new(0.18,0,0.18,0),BackgroundColor3 = Color3.new(0, 1, 1)}
	local ChangeOut = {Size = UDim2.new(0.2,0,0.2,0),BackgroundColor3 = Color3.new(1, 1, 1)}
	script.Parent.MouseHit.Event:Connect(function(data)
		if data == 1 then
			K1 += 1
			game.Players.LocalPlayer.PlayerGui.BG.HitKey.K1.Text = K1
			TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.HitKey.K1,KeyTweenInfo,ChangeIn1):Play()
		elseif data == 2 then
			K2 += 1
			game.Players.LocalPlayer.PlayerGui.BG.HitKey.K2.Text = K2
			TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.HitKey.K2,KeyTweenInfo,ChangeIn1):Play()
		elseif data == 3 then
			K3 += 1
			game.Players.LocalPlayer.PlayerGui.BG.HitKey.M1.Text = K3
			TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.HitKey.M1,KeyTweenInfo,ChangeIn2):Play()
		elseif data == 4 then
			K4 += 1
			game.Players.LocalPlayer.PlayerGui.BG.HitKey.M2.Text = K4
			TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.HitKey.M2,KeyTweenInfo,ChangeIn2):Play()
		end
	end)
	script.Parent.MouseHitEnd.Event:Connect(function(data)
		if data == 1 then
			TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.HitKey.K1,KeyTweenInfo,ChangeOut):Play()
		elseif data == 2 then
			TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.HitKey.K2,KeyTweenInfo,ChangeOut):Play()
		elseif data == 3 then
			TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.HitKey.M1,KeyTweenInfo,ChangeOut):Play()
		elseif data == 4 then
			TweenService:Create(game.Players.LocalPlayer.PlayerGui.BG.HitKey.M2,KeyTweenInfo,ChangeOut):Play()
		end
	end)
end)

--CircleSize = 54.4 - 4.48 * CS
--3

--print((54.4 - 4.48 *3)/768*2)

--1.25
-- osu play size: 640x480
local ZIndex = 0

local hit300 = 160 - 12 * OverallDifficulty --148>1 , 40>10
local hit100 = 280 - 16 * OverallDifficulty --264>1 , 120>10
local hit50 = 400 - 20 * OverallDifficulty --380>1 , 200>10
local EarlyMiss = hit50 + 50

script.Parent.AccurancyChart.Size = UDim2.new(0,hit50,0,25)
script.Parent.AccurancyChart._300s.Size = UDim2.new(hit300/hit50,0,1,0)
script.Parent.AccurancyChart._100s.Size = UDim2.new(hit100/hit50,0,1,0)

local Accurancy = {
	h300 = 0,h100 = 0,h50 = 0,miss = 0,Combo = 0
}

local CircleSize = (54.4 - 4.48 * CS)*2
local DisplayCombo = 0
script.Parent.ComboDisplay.Changed:Connect(function()
	local NewCombo = tonumber(string.sub(script.Parent.ComboDisplay.Text,1,#script.Parent.ComboDisplay.Text-1)) or 0
	if NewCombo > DisplayCombo then
		DisplayCombo = NewCombo
		script.Parent.ComboFade:ClearAllChildren()
		local NewFadeCombo = script.ComboFade:Clone()
		NewFadeCombo.Parent = script.Parent.ComboFade
		NewFadeCombo.Text = tostring(NewCombo).."x"
		game:GetService("TweenService"):Create(NewFadeCombo,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextSize = 60,TextTransparency = 1}):Play()
		wait(0.5)
		NewFadeCombo:Destroy()
	else
		DisplayCombo = NewCombo
	end
end)

spawn(function() --Accurancy caculation
	while wait() do
		local h300 = Accurancy.h300
		local h100 = Accurancy.h100
		local h50 = Accurancy.h50
		local miss = Accurancy.miss
		local Total = h300+h100+h50+miss
		local Acc = math.floor(((h300*300+h100*100+h50*50)/(Total*300))*10000)/100
		local tostringAcc = tostring(Acc)
		if tostringAcc == "-nan(ind)" or tostringAcc == "inf" or tostringAcc == "100" then
			tostringAcc = "100.00"
		elseif string.sub(tostringAcc,#tostringAcc-1,#tostringAcc-1) == "." then
			tostringAcc = tostringAcc.."0"
		elseif #tostringAcc <= 2 then
			tostringAcc = tostringAcc..".00"
		end
		if tonumber(tostringAcc) < 10 then
			tostringAcc = "0"..tostringAcc
		end
		script.Parent.AccurancyDisplay.Text = tostringAcc.."%"
		script.Parent.ComboDisplay.Text = tostring(Accurancy.Combo).."x"
	end
end)

local Score = 0
local ScoreMultiplier = {
	Difficulty = 1,
	Mod = 1
}


spawn(function()
	while wait() do
		script.Parent.ScoreDisplay.Text = math.floor(Score)
	end
end)

local CircleApproachTime = 1200

if ApproachRate < 5 then
	CircleApproachTime = 1200 + 600 * (5 - ApproachRate) / 5
elseif ApproachRate > 5 then
	CircleApproachTime = 1200 - 750 * (ApproachRate - 5) / 5
else
	CircleApproachTime = 1200
end

--CircleApproachTime = 10000

repeat wait() until script.Parent.Song.IsLoaded == true
script.Parent.Song.PlaybackSpeed = SongSpeed
local SongStart = tick()

spawn(function()
	while wait() do
		if script.Parent.Song.TimePosition < ((tick() - SongStart)*SongSpeed)-0.05 then
			script.Parent.Song.TimePosition = (tick() - SongStart)*SongSpeed
		end
	end
end)

local NPS = 0

script.Parent.Song:Play()

local Start = tick()
local Cusor = script.Parent.PlayFrame.Cusor
local Combo = 1

local ComboColor = { --Combo color
	Color3.fromRGB(241,79,10),
	Color3.fromRGB(153,203,253),
	Color3.fromRGB(54,115,228),
	Color3.fromRGB(98,46,207),
	Color3.fromRGB(227,149,43),
	Color3.fromRGB(37,203,33),
	Color3.fromRGB(16,190,182),
	Color3.fromRGB(255,0,0)
}
local CurrentComboColor = 1
local LastCirclePos = {X = 0,Y = 0}

--BPM = 1 / BeatLength * 1000 * 60
--[[
spawn(function()
	local BPM = 110
	while wait(60/BPM) do
		for i,Obj in pairs(script.Parent.PlayFrame:GetChildren()) do
			local NewObj
			pcall(function()
				if Obj.Name == "Circle" then
					NewObj = Obj:Clone()
					NewObj.Parent = script.Parent.PlayFrame
					NewObj.ApproachCircle:Destroy()
					NewObj.BackgroundTransparency = 0.75
					NewObj.TextLabel.TextTransparency = 0.5
					NewObj.Circle.ImageTransparency = 0.5

					game:GetService("TweenService"):Create(NewObj,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{BackgroundTransparency = 1,Size = UDim2.new(0.214,0,0.214,0)}):Play()
					game:GetService("TweenService"):Create(NewObj.TextLabel,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{TextTransparency = 1}):Play()
					game:GetService("TweenService"):Create(NewObj.Circle,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
				end
			end)
			spawn(function()
				wait(0.2)
				if Obj.Name == "Circle" then
					NewObj:Destroy()
				end
			end)
		end
	end
end)
]]
local CurrentHitnote = 1

if AutoPlay == true then
	spawn(function()
		repeat wait() until (tick()-Start)*1000 >= BeatmapData[1].Time-1000
		game:GetService("TweenService"):Create(Cusor,TweenInfo.new(0.5,Enum.EasingStyle.Sine),{Position = UDim2.new(0.5,0,0.5,0)}):Play()
	end)
end

--Autoplay only
local MissclickTotal = 0
local MissclickOn50 = 0
local LastClick = 0
local RightClick = true

function AutoClick() 
	spawn(function()
		if tick() - LastClick > 0.25 then
			RightClick = false
			LastClick = tick()
			script.Parent.MouseHit:Fire(3)
			wait(0.1)
			script.Parent.MouseHitEnd:Fire(3)
		else
			if RightClick == true then
				RightClick = false
				LastClick = tick()
				script.Parent.MouseHit:Fire(3)
				wait(0.1)
				script.Parent.MouseHitEnd:Fire(3)
			else
				RightClick = true
				LastClick = tick()
				script.Parent.MouseHit:Fire(4)
				wait(0.1)
				script.Parent.MouseHitEnd:Fire(4)
			end
		end
	end)
end
--

for i,HitObj in pairs(BeatmapData) do
	local HitNoteID = i
	if (tick()-Start)*1000 < HitObj.Time-CircleApproachTime or NPS >= 60 then
		repeat wait() until (tick()-Start)*1000 >= HitObj.Time-CircleApproachTime
	end
	spawn(function()
		if AutoPlay == true then
			spawn(function()
				local TimeUntilNoteClicked = (i~= 1 and i ~= #BeatmapData and HitObj.Time-BeatmapData[i-1].Time < 250 and HitObj.Time-BeatmapData[i-1].Time) or 250
				repeat wait() until (tick()-Start)*1000 >= HitObj.Time-TimeUntilNoteClicked
				if MissclickTotal <= 0 then
					game:GetService("TweenService"):Create(Cusor,TweenInfo.new(TimeUntilNoteClicked/1000,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{Position = UDim2.new(HitObj.Position.X/640,0,HitObj.Position.Y/480,0)}):Play()
					repeat wait() until tick() - Start >= HitObj.Time/1000
					AutoClick()
					spawn(function() --Check if the bot missclick
						wait((hit300+hit100/2)/1000)
						if CurrentHitnote == HitNoteID then --If missclick then the bot will return to the note
							MissclickTotal += 1
							game:GetService("TweenService"):Create(Cusor,TweenInfo.new(0,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{Position = UDim2.new(HitObj.Position.X/640,0,HitObj.Position.Y/480,0)}):Play()
							wait(0)
							AutoClick()
							wait(0.4)
							MissclickTotal -= 1
						end
					end)
				else
					spawn(function()
						repeat wait() until tick() - Start >= HitObj.Time/1000 and CurrentHitnote == HitNoteID
						MissclickTotal += 1
						if MissclickOn50 <= 0 then
							game:GetService("TweenService"):Create(Cusor,TweenInfo.new(0.1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{Position = UDim2.new(HitObj.Position.X/640,0,HitObj.Position.Y/480,0)}):Play()
							wait(0.05)
						else
							game:GetService("TweenService"):Create(Cusor,TweenInfo.new(0,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{Position = UDim2.new(HitObj.Position.X/640,0,HitObj.Position.Y/480,0)}):Play()
							wait()
						end
						AutoClick()
						local got50s = false
						local stable = false
						if math.abs((tick()-Start)*1000-HitObj.Time) >= hit100 then
							got50s = true
							MissclickOn50 += 1
						elseif math.abs((tick()-Start)-HitObj.Time) <= hit300 then
							stable = true
							MissclickTotal -= 1
						end
						wait(0.4)
						if stable == false then
							MissclickTotal -= 1
						end
						if got50s == true then
							wait(0.5)
							MissclickOn50 -= 1
						end
					end)
				end
			end)
		end
		if HitObj.Type == 12 or HitObj.Type == 5 or HitObj.Type == 6 then
			Combo = 1
			if CurrentComboColor >= #ComboColor then
				CurrentComboColor = 1
			else
				CurrentComboColor = CurrentComboColor + 1
			end
		else
			Combo = Combo + 1
		end
		spawn(function()
			if BeatmapData[i+1] ~= nil and BeatmapData[i+1].Type ~= 12 and BeatmapData[i+1].Type ~= 5 and BeatmapData[i+1].Type ~= 6 then
				local NextHitObj = BeatmapData[i+1]
				local HitObjPos = Vector2.new(HitObj.Position.X,HitObj.Position.Y)
				local NextHitObjPos = Vector2.new(NextHitObj.Position.X,NextHitObj.Position.Y)
				local Point = HitObjPos-NextHitObjPos
				local Rotation = math.deg(math.atan2(Point.Y,Point.X))

				local Connection = script.Connection:Clone()
				local Pos = (HitObjPos+NextHitObjPos)/2
				local Size = math.abs((HitObjPos-NextHitObjPos).magnitude)

				local Pos = UDim2.new(Pos.X/640,0,Pos.Y/480,0)
				local FirstPos = UDim2.new(HitObjPos.X/640,0,HitObjPos.Y/480,0)
				local EndPos = UDim2.new(NextHitObjPos.X/640,0,NextHitObjPos.Y/480,0)
				local Size = UDim2.new(Size/640,0,0,2)

				Connection.Parent = script.Parent.PlayFrame
				Connection.Position = FirstPos
				Connection.Rotation = Rotation
				Connection.Size = UDim2.new(0,0,0,2)
				Connection.ZIndex = ZIndex-2


				local DisplayTime = (((NextHitObj.Time+100)-HitObj.Time)> 100 and NextHitObj.Time-HitObj.Time) or 100
				local TweenTime = (NextHitObj.Time-HitObj.Time > 50 and NextHitObj.Time-HitObj.Time) or 50
				game:GetService("TweenService"):Create(Connection,TweenInfo.new(TweenTime/1000,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{BackgroundTransparency = 0.5,Position = Pos,Size = Size}):Play()
				if (tick() - Start)*1000 < NextHitObj.Time-250 then
					repeat wait() until (tick() - Start)*1000 >= NextHitObj.Time-250
					game:GetService("TweenService"):Create(Connection,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{BackgroundTransparency = 1,Position = EndPos,Size = UDim2.new(0,0,0,2)}):Play()
				end
				repeat wait() until (tick() - Start)*1000 >= NextHitObj.Time
				Connection:Destroy()
			end
		end)
		ZIndex = ZIndex - 1
		local Circle = script.Circle:Clone()
		Circle.Parent = script.Parent.PlayFrame
		Circle.Position = UDim2.new(HitObj.Position.X/640,0,HitObj.Position.Y/480,0)
		Circle.Size = UDim2.new(CircleSize/480,0,CircleSize/480,0)
		Circle.ZIndex = ZIndex
		Circle.TextLabel.Text = Combo
		Circle.BackgroundColor3 = ComboColor[CurrentComboColor]
		Circle.ApproachCircle.ImageColor3= ComboColor[CurrentComboColor]
		game:GetService("TweenService"):Create(Circle,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = 0}):Play()
		local FadeInTime = (CircleApproachTime >= 400 and 0.4) or CircleApproachTime/1000
		for _,Object in pairs(Circle:GetChildren()) do
			spawn(function()
				if Object:IsA("ImageLabel") then
					game:GetService("TweenService"):Create(Object,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{ImageTransparency = 0}):Play()
				end
				if Object:IsA("TextLabel") then
					game:GetService("TweenService"):Create(Object,TweenInfo.new(FadeInTime,Enum.EasingStyle.Linear),{TextTransparency = 0}):Play()
				end
			end)
		end
		--local SliderFolder = Instance.new("Folder",script.Parent.PlayFrame)
		--SliderFolder.Name = "Slider"
		local SliderTime = 0
		local GolbalSliderConnections = "none"
		--[[

		if HitObj.Type == 6 or HitObj.Type == 2 then
			ZIndex = ZIndex-1
			local SliderCurvePoints = {}
			SliderTime = HitObj.ExtraData[4]
			local CurrentPos = 3
			local CurveData = HitObj.ExtraData[2]
			SliderCurvePoints[1] = HitObj.Position
			for i = 3,#CurveData do
				if string.sub(CurveData,i,i) == "|" or i == #CurveData then
					for a = CurrentPos,i-1 do
						if string.sub(CurveData,a,a) == ":" then
							SliderCurvePoints[#SliderCurvePoints+1] = {
								X = tonumber(string.sub(CurveData,CurrentPos,a-1)),
								Y = tonumber(string.sub(CurveData,a+1,i-1))
							}
							break
						end
					end
					CurrentPos = i+1
				end
			end
			local SliderLength = 0
			local SliderConnections = {}
			for i,a in pairs(SliderCurvePoints) do
				if i ~= #SliderCurvePoints then
					local NextCurvePointPos = SliderCurvePoints[i+1]
					local Point1st = Vector2.new(a.X,a.Y)
					local Point2nd = Vector2.new(NextCurvePointPos.X,SliderCurvePoints.Y)
					local Point3rd = Vector2.new(a.Y,NextCurvePointPos.X)
					local Length = (Point1st-Point2nd).magnitude
					SliderLength = SliderLength + Length
					local Length3rd = (Point2nd-Point3rd).magnitude
					local Point = Point2nd-Point1st
					local Rotation = math.deg(math.atan2(Point.Y,Point.X))
					--local Rotation = math.deg(math.asin(Length3rd/Length))
					
					SliderConnections[#SliderConnections+1] = {Length = Length,Rotation = Rotation,Pos = (Point1st+Point2nd)/2}
				end
				
				GolbalSliderConnections = SliderConnections
			end
			for i,Data in pairs(SliderConnections) do
				local HoldCircle = script.HoldCircle:Clone()
				HoldCircle.Parent = SliderFolder
				HoldCircle.Position = UDim2.new(Data.Pos.X/1024,0,Data.Pos.Y/768,0)
				HoldCircle.Rotation = Data.Rotation
				HoldCircle.Size = UDim2.new(((Data.Length)/1024)+0.08025,0,0.107,0)
				HoldCircle.ZIndex = ZIndex
			end
			for i,SliderPoint in pairs(SliderCurvePoints) do
				--local HoldCircle = script.HoldCircle:Clone()
				--HoldCircle.BackgroundColor3 = Color3.fromRGB(255,255,0)
				--HoldCircle.Parent = SliderFolder
				--HoldCircle.Position = UDim2.new(SliderPoint.X/1024,0,SliderPoint.Y/768,0)
				--HoldCircle.SizeConstraint = Enum.SizeConstraint.RelativeYY
				if i ~= 1 then
					local SliderPointLength = SliderConnections[i-1].Length
					--HitObj.Time
					local SliderPointDuration = SliderTime*(SliderPointLength/SliderLength)
					local SliderPointTime = (i > 2 and SliderTime*(SliderConnections[i-2].Length/SliderLength)) or 0
					spawn(function()
						warn(SliderPointTime)
						print(SliderPointDuration)
						repeat wait() until (tick() - Start)*1000 >= HitObj.Time+SliderPointTime
						game:GetService("TweenService"):Create(Cusor,TweenInfo.new(SliderPointDuration/1000,Enum.EasingStyle.Linear),{Position = UDim2.new(SliderCurvePoints[i].X/1024,0,SliderCurvePoints[i].Y/768,0)}):Play()
					end)
				end
			end
		end]]
		game:GetService("TweenService"):Create(Circle.ApproachCircle,TweenInfo.new(CircleApproachTime/1000,Enum.EasingStyle.Linear),{Size = UDim2.new(1.2,0,1.2,0)}):Play()
		local IsHit = false
		spawn(function()
			wait((CircleApproachTime+hit50)/1000)
			if IsHit == false then
				IsHit = true
				Accurancy.Combo = 0
				Accurancy.miss += 1
				CurrentHitnote += 1
				Circle.ApproachCircle:Destroy()
				Circle:Destroy()
			end
		end)
		local function isincircle()
			local CirclePos = Vector2.new(HitObj.Position.X,HitObj.Position.Y)
			local CusorPos = Vector2.new(Cusor.Position.X.Scale*640,Cusor.Position.Y.Scale*480)
			local Distance = math.abs((CirclePos-CusorPos).magnitude)
			if Distance <= (CircleSize/2)+42.5 then
				return true
			else
				return false
			end
		end

		--Hit Value + (Hit Value * ((Combo multiplier * Difficulty multiplier * Mod multiplier) / 25))
		function AddScore(HitValue)
			local Combo = Accurancy.Combo
			Score += HitValue + (HitValue * ((((Combo > 2 and Combo-2) or 0) * ScoreMultiplier.Difficulty * ScoreMultiplier.Mod) / 25))
		end

		function CreateHitDelay(Color,HitDelay)
			local Pos = (HitDelay+hit50)/(hit50*2)
			local NewHitDelay = script.NoteDelay:Clone()
			NewHitDelay.Parent = script.Parent.AccurancyChart
			NewHitDelay.Position = UDim2.new(Pos,0,0.5,0)
			NewHitDelay.BackgroundColor3 = Color
			spawn(function()
				game:GetService("TweenService"):Create(NewHitDelay,TweenInfo.new(5,Enum.EasingStyle.Linear),{BackgroundTransparency = 1}):Play()
				wait(5)
				NewHitDelay:Destroy()
			end)

		end

		script.Parent.MouseHit.Event:Connect(function()
			if CurrentHitnote == HitNoteID and IsHit == false then
				local CurrentTime = (tick()-Start)*1000
				local HitDelay = CurrentTime - HitObj.Time
				if HitDelay > -EarlyMiss and isincircle() then
					IsHit = true
					CurrentHitnote += 1
					if HitDelay < -hit50 then
						Accurancy.Combo = 0
						Accurancy.miss += 0
						Circle.ApproachCircle:Destroy()
						Circle:Destroy()
					else
						Circle.ApproachCircle:Destroy()
						Accurancy.Combo += 1
						if math.abs(HitDelay) < hit300 then
							Accurancy.h300 += 1
							CreateHitDelay(Color3.new(0, 1, 1),HitDelay)
							AddScore(300)
						elseif math.abs(HitDelay) < hit100 then
							Accurancy.h100 += 1
							CreateHitDelay(Color3.new(0, 1, 0),HitDelay)
							AddScore(100)
						else
							Accurancy.h50 += 1
							CreateHitDelay(Color3.new(1, 1, 0),HitDelay)
							AddScore(50)
						end
						game:GetService("TweenService"):Create(Circle,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{BackgroundTransparency = 1,Size = UDim2.new(CircleSize*1.5/480,0,CircleSize*1.5/480,0)}):Play()
						for _,Object in pairs(Circle:GetChildren()) do
							spawn(function()
								if Object:IsA("ImageLabel") then
									game:GetService("TweenService"):Create(Object,TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()
								end
								if Object:IsA("TextLabel") then
									game:GetService("TweenService"):Create(Object,TweenInfo.new(0.05,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{TextTransparency = 1}):Play()
								end
							end)
						end
						wait(0.25)
						Circle:Destroy()
					end
				end
			end
		end)

		--wait(SliderTime/1000)



		
		
		--SliderFolder:Destroy()
	end)
end

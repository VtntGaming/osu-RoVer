--!strict

local ScoreFormat = require(script.Parent.ScoreFormat)

type Deps = {
	rootScript: Instance,
	TweenService: TweenService,
	UserInputService: UserInputService,
	HttpService: HttpService,
	workspace: Workspace,
	PlayerGui: PlayerGui,
	LocalPlayer: Player,
	ScriptComponent: Instance,
	modData: any,
	PerformanceCalculator: any,
	ScoreStaticticConverter: any,
	getPreviewMapPS: () -> any,
	getCurrentKey: () -> string,
	getStartupState: () -> string,
	isTouchDeviceActive: () -> boolean,
	getEasyMod: () -> boolean,
	getHardRock: () -> boolean,
	getFlashlight: () -> boolean,
	getHiddenMod: () -> boolean,
	getScoreV2Enabled: () -> boolean,
	getGameSettingManage: () -> any,
	leaderboardFrameConnection: { RBXScriptConnection? },
	localLeaderboardData: { [any]: any },
	getRankColor: () -> { [string]: Color3 },
}

local LeaderboardController = {}

function LeaderboardController.create(deps: Deps)
	local rootScript = deps.rootScript
	local osuGame = rootScript.Parent

	local api = {}

	local lbDetailMovementConnection: RBXScriptConnection? = nil

	local displayLBInformationValue = {
		Score = Instance.new("IntValue"),
		MaxCombo = Instance.new("IntValue"),
		MapMaxCombo = Instance.new("IntValue"),
		h300 = Instance.new("IntValue"),
		h100 = Instance.new("IntValue"),
		h50 = Instance.new("IntValue"),
		miss = Instance.new("IntValue"),
		rankedPS = Instance.new("NumberValue"),
		calculatedBasePS = Instance.new("NumberValue"),
		calculatedMaxPS = Instance.new("NumberValue"),
	}

	local userPlayInformationAnimateID: string? = nil
	local currentLeaderboardSession = ""

	local lbTweenConnection: { [string]: RBXScriptConnection? } = {}
	local refreshEvent = Instance.new("BindableEvent")

	function api.GetModData(mod: any, detailed: boolean?): string
		local returnText = ""
		local mods = 0

		if mod == nil then
			return ""
		end

		local function addToken(short: string, long: string)
			if mods > 0 then
				returnText ..= ","
			end
			mods += 1
			returnText ..= (detailed and long or short)
		end

		if mod.AT == true then addToken("AT", "AutoPlay") end
		if mod.TD == true then addToken("TD", "TouchDevice") end
		if mod.HC == true then addToken("HC", "HardCore") end
		if mod.NF == true then addToken("NF", "NoFail") end
		if mod.HD == true then addToken("HD", "Hidden") end
		if mod.HR == true then addToken("HR", "HardRock") end
		if mod.EZ == true then addToken("EZ", "Easy") end

		if mod.SA and mod.SA ~= 1 then
			if mods > 0 then
				returnText ..= ","
			end
			mods += 1
			local short = string.format("SA(%.1fx)", mod.SA)
			local long = string.format("SpeedAdjust(%.1fx)", mod.SA)

			if mod.SA == 1.5 then
				short = "DT"
				long = "DoubleTime"
			elseif mod.SA == 0.75 then
				short = "HT"
				long = "HalfTime"
			end

			returnText ..= (detailed and long or short)
		end

		if mod.NS == true then addToken("NS", "NoSliders") end
		if mod.FL == true then addToken("FL", "FlashLight") end

		if mod.DA and mod.DA.Active then
			if mods > 0 then
				returnText ..= ","
			end
			mods += 1
			local short = "DA("
			local long = "DifficultyAdjust("

			local function addPart(txt: string, num: number, addComma: boolean)
				local strNum = tostring(math.floor(num * 10) / 10)
				short ..= txt .. strNum .. (addComma and "," or ")")
				long ..= txt .. strNum .. (addComma and "," or ")")
			end

			local data = mod.DA.Data
			if data.CS then addPart("CS", data.CS, true) end
			if data.AR then addPart("AR", data.AR, true) end
			if data.OD then addPart("OD", data.OD, true) end
			if data.HP then addPart("HP", data.HP, false) end

			returnText ..= (detailed and long or short)
		end

		if mod.RX then addToken("RX", "Relax") end
		if mod.SO then addToken("SO", "SpunOut") end
		if mod.AP then addToken("AP", "AutoPilot") end

		if mods > 0 and not detailed then
			returnText = " | " .. returnText
		elseif mods == 0 and detailed then
			returnText = "None"
		end

		return returnText
	end

	function api.GetScore(currentScore: number | string): string
		return ScoreFormat.GetScore(currentScore)
	end

	function api.GetUserPlayUpdatedPS(data: any, externalData: any?): (number, number, number)
		local previewMapPS = deps.getPreviewMapPS()
		local aimDiff = previewMapPS.AimDiff
		local speedDiff = previewMapPS.SpeedDiff
		local flDiff = previewMapPS.FLdDiff
		local objCount = previewMapPS.objCountData
		local mapMaxCombo = previewMapPS.MaxCombo

		if externalData then
			aimDiff = externalData.AimDiff
			speedDiff = externalData.SpeedDiff
			flDiff = externalData.FLDiff
		end

		local h300 = data.Statistic.h300
		local h100 = data.Statistic.h100
		local h50 = data.Statistic.h50
		local missCount = data.Statistic.missCount

		local odRate = previewMapPS.OD
		local arRate = previewMapPS.AR
		local aimDiffStrainCount = previewMapPS.AimDiffStrainCount
		local speedDiffStrainCount = previewMapPS.AimDiffStrainCount
		local speedRelevantNoteCount = previewMapPS.SpeedRelevantNoteCount
		local _currentSpeed = previewMapPS.CurrentSpeed

		local modData = data.ModData

		local accuracyData = {
			h300 = h300,
			h100 = h100,
			h50 = h50,
			missCount = missCount,
			EffectiveMissCount = missCount,
		}

		local returnData = deps.PerformanceCalculator(
			aimDiff,
			speedDiff,
			flDiff,
			odRate,
			arRate,
			modData,
			objCount,
			false,
			aimDiffStrainCount,
			speedDiffStrainCount,
			speedRelevantNoteCount,
			accuracyData
		)

		return returnData.Max, returnData.Current, mapMaxCombo
	end

	function api.ShowLeaderboardPlayDetail(data: any)
		if data.ModData == nil then
			data.ModData = {}
		end

		local modDetail = api.GetModData(data.ModData, true)
		local playedDate = os.date("*t", tonumber(data.Date))

		local displayPS = ""
		if data.Statistic then
			local _, updatedPS, _ = api.GetUserPlayUpdatedPS(data)
			displayPS = "\nUpdatedPS: " .. tostring(math.round(updatedPS.TotalPS)) .. "ps"
		end

		local dateDetail = string.format(
			"%.2d/%.2d/%.4d %.2d:%.2d:%.2d",
			playedDate.day,
			playedDate.month,
			playedDate.year,
			playedDate.hour,
			playedDate.min,
			playedDate.sec
		)

		local accuracy = string.format(
			"Statistic: <font color='#00ffff'>%d</font>/<font color='#00ff00'>%d</font>/<font color='#ffff00'>%d</font>/<font color='#ff0000'>%d</font>",
			data.Statistic.h300,
			data.Statistic.h100,
			data.Statistic.h50,
			data.Statistic.missCount
		)

		local fullText = string.format(
			"Played on %s\n%s\nAccuracy:%.2f%%\nMod:%s%s",
			dateDetail,
			accuracy,
			data.Accuracy,
			modDetail,
			displayPS
		)

		local leaderboardDetail = deps.PlayerGui.BG.BeatmapLeaderboard.LeaderboardDetail
		leaderboardDetail.LeaderboardDetail.Text = fullText
		local textBounds = leaderboardDetail.LeaderboardDetail.TextBounds
		leaderboardDetail.Size = UDim2.new(0, textBounds.X + 10, 0, textBounds.Y + 10)

		local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
		deps.TweenService:Create(leaderboardDetail, tweenInfo, { BackgroundTransparency = 0.25 }):Play()
		deps.TweenService:Create(leaderboardDetail.LeaderboardDetail, tweenInfo, { TextTransparency = 0 }):Play()
		deps.TweenService:Create(leaderboardDetail.UIStroke, tweenInfo, { Transparency = 0.5 }):Play()
	end

	function api.HideLeaderboardPlayDetail()
		local leaderboardDetail = deps.PlayerGui.BG.BeatmapLeaderboard.LeaderboardDetail
		local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
		deps.TweenService:Create(leaderboardDetail, tweenInfo, { BackgroundTransparency = 1 }):Play()
		deps.TweenService:Create(leaderboardDetail.LeaderboardDetail, tweenInfo, { TextTransparency = 1 }):Play()
		deps.TweenService:Create(leaderboardDetail.UIStroke, tweenInfo, { Transparency = 1 }):Play()
	end

	function api.updateLBStaistic()
		local lbInformation = deps.PlayerGui.BG.BeatmapLeaderboard.UserPlayInformation
		local mainFrame = lbInformation.MainFrame
		local score = displayLBInformationValue.Score.Value
		local maxCombo = displayLBInformationValue.MaxCombo.Value
		local mapMaxCombo = displayLBInformationValue.MapMaxCombo.Value
		local h300 = displayLBInformationValue.h300.Value
		local h100 = displayLBInformationValue.h100.Value
		local h50 = displayLBInformationValue.h50.Value
		local miss = displayLBInformationValue.miss.Value
		local rankedPS = displayLBInformationValue.rankedPS.Value
		local calculatedBasePS = displayLBInformationValue.calculatedBasePS.Value
		local calculatedMaxPS = displayLBInformationValue.calculatedMaxPS.Value

		mainFrame.ScoreDisplay.Text = string.format("Score: %s (%dx/%dx)", api.GetScore(score), maxCombo, mapMaxCombo)
		mainFrame.AccuracyDisplay.Text = string.format(
			'Statistics: <font color = "#00ffff">%d</font>/<font color = "#55ff00">%d</font>/<font color = "#ffff00">%d</font>/<font color = "#ff0000">%d</font>',
			h300,
			h100,
			h50,
			miss
		)

		local total = (h300 + h100 + h50 + miss)
		local acc = (h300 * 3 + h100 + h50 * 0.5) / (total * 3) * 100
		local gameplayRank = "D"
		local missTotal = miss

		if acc >= 70 then gameplayRank = "C" end
		if acc >= 80 then gameplayRank = "B" end
		if acc >= 90 then gameplayRank = "A" end
		if acc >= 95 and missTotal <= 0 then gameplayRank = "S" end
		if acc >= 100 then gameplayRank = "SS" end

		local rankColor = deps.getRankColor()[gameplayRank]
		mainFrame.GradeDisplay.Text = string.format(
			'Accuracy: %.2f%% [<font color = "#%s">%s</font>]',
			acc,
			rankColor:ToHex(),
			gameplayRank
		)
		mainFrame.PSDisplay.Text = string.format("Ranked Perfomance: %.2fps", rankedPS)
		mainFrame.UpdatedPSDisplay.Text = string.format("Updated Perfomance: %.2f/%.2fps", calculatedBasePS, calculatedMaxPS)
	end

	for _, obj in pairs(displayLBInformationValue) do
		(obj :: any):GetPropertyChangedSignal("Value"):Connect(api.updateLBStaistic)
	end

	function api.AddLeaderboardConnection(leaderboardFrame: any, data: any, score: number, uid: any, dateFormat: string)
		if (not leaderboardFrame:IsA("Frame")) and (not data) then
			return
		end

		table.insert(deps.leaderboardFrameConnection, leaderboardFrame.MouseEnter:Connect(function()
			api.ShowLeaderboardPlayDetail(data)
		end))
		table.insert(deps.leaderboardFrameConnection, leaderboardFrame.MouseMoved:Connect(function()
			api.ShowLeaderboardPlayDetail(data)
		end))
		table.insert(deps.leaderboardFrameConnection, leaderboardFrame.TouchPan:Connect(function()
			local leaderboardDetail = deps.PlayerGui.BG.BeatmapLeaderboard.LeaderboardDetail
			leaderboardDetail.AnchorPoint = Vector2.new(1, 0.5)
			leaderboardDetail.Position = UDim2.new(0, -15, 0.5, 0)

			api.ShowLeaderboardPlayDetail(data)
		end))
		table.insert(deps.leaderboardFrameConnection, leaderboardFrame.MouseLeave:Connect(function()
			api.HideLeaderboardPlayDetail()
		end))

		leaderboardFrame.DevButton.MouseButton1Click:Connect(function()
			local lbInformation = deps.PlayerGui.BG.BeatmapLeaderboard.UserPlayInformation
			local mainFrame = lbInformation.MainFrame

			local function add(obj: any, value: any)
				deps.TweenService:Create(obj, TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Value = value }):Play()
			end

			local externalData
			local diffChangeModEnabled = (data.ModData.EZ ~= deps.getEasyMod())
				or (data.ModData.HR ~= deps.getHardRock())
				or (data.ModData.FL ~= deps.getFlashlight())
				or ((deps.getFlashlight()) and data.ModData.HD ~= deps.getHiddenMod())
				or (data.ModData.TD ~= deps.isTouchDeviceActive())

			local previewMapPS = deps.getPreviewMapPS()
			if data.ModData.SA ~= previewMapPS.CurrentSpeed or diffChangeModEnabled then
				local mapFile = previewMapPS.MapFile
				local _, returnData = require(deps.workspace.OsuConvert)(1, mapFile, 0, true, false, data.ModData)
				externalData = {
					AimDiff = returnData.Difficulty.AimDifficulty,
					SpeedDiff = returnData.Difficulty.SpeedDifficulty,
					FLDiff = returnData.Difficulty.FlashLightDifficulty,
				}
			end

			add(displayLBInformationValue.Score, score)
			add(displayLBInformationValue.MaxCombo, data.MaxCombo)
			add(displayLBInformationValue.h300, data.Statistic.h300)
			add(displayLBInformationValue.h100, data.Statistic.h100)
			add(displayLBInformationValue.h50, data.Statistic.h50)
			add(displayLBInformationValue.miss, data.Statistic.missCount)
			add(displayLBInformationValue.rankedPS, data.Performance or 0)
			local maxPS, updatedPS, mapMaxCombo = api.GetUserPlayUpdatedPS(data, externalData)
			add(displayLBInformationValue.MapMaxCombo, mapMaxCombo)
			add(displayLBInformationValue.calculatedBasePS, updatedPS.TotalPS)
			add(displayLBInformationValue.calculatedMaxPS, maxPS.TotalPS)
			local crrID = deps.HttpService:GenerateGUID()
			userPlayInformationAnimateID = crrID
			local replayOption = mainFrame.ReplayOption
			if data.HaveReplay then
				replayOption.Visible = true
				deps.TweenService:Create(mainFrame.Parent, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(0, 300, 0, 150) }):Play()
				deps.TweenService:Create(replayOption, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { GroupTransparency = 0 }):Play()
			else
				deps.TweenService:Create(mainFrame.Parent, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(0, 300, 0, 115) }):Play()
				deps.TweenService:Create(replayOption, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { GroupTransparency = 1 }):Play()
				task.spawn(function()
					task.wait(0.25)
					if userPlayInformationAnimateID == crrID then
						replayOption.Visible = false
					end
				end)
			end

			local currentKey = deps.getCurrentKey()
			if currentKey == mainFrame.DatastoreName.Value and uid == mainFrame.Key.Value then
				mainFrame.DatastoreName.Value = ""
				mainFrame.Key.Value = ""
				deps.TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(1.5, 0, 0.5, 0) }):Play()
				return
			end
			mainFrame.DatastoreName.Value = currentKey
			mainFrame.Key.Value = uid
			deps.TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0.5, 0) }):Play()
			deps.TweenService:Create(
				lbInformation,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{ Position = UDim2.new(0, -20, 0, math.max(math.min(leaderboardFrame.AbsolutePosition.Y + 58, deps.workspace.CurrentCamera.ViewportSize.Y - 216), 36)) }
			):Play()
		end)

		local accData = {
			h300 = data.Statistic.h300,
			h100 = data.Statistic.h100,
			h50 = data.Statistic.h50,
			miss = data.Statistic.missCount,
			MaxCombo = data.MaxCombo,
		}

		local previewMapPS = deps.getPreviewMapPS()
		local sendData = {
			previewMapPS.objCount,
			previewMapPS.MaxCombo,
			previewMapPS.MaxAccScore,
			previewMapPS.MaxConsistencyScore,
			previewMapPS.MaxSpinnerScore,
			data.ModData,
		}

		local displayScore: number = score
		if deps.getScoreV2Enabled() then
			local scoreV2 = require(deps.ScriptComponent.Gameplay.RawV1ToV2)(score, accData, table.unpack(sendData))
			displayScore = scoreV2
		end

		local function check()
			if leaderboardFrame.AbsoluteSize.X < 250 then
				leaderboardFrame.MainFrame.Score.Text = string.format("%s (%dx)", api.GetScore(displayScore), data.MaxCombo)
				leaderboardFrame.MainFrame.Score.Text = api.GetScore(score) .. "(" .. tostring(data.MaxCombo) .. "x)"
				leaderboardFrame.MainFrame.Accuracy.Visible = false
				leaderboardFrame.MainFrame.PlayDate.Visible = false
				leaderboardFrame.MainFrame.PSEarned.Position = UDim2.new(1, -8, 0.6666, 0)
				leaderboardFrame.MainFrame.PSEarned.Text = dateFormat .. " | " .. tostring(math.round(data.Performance)) .. "ps"
			else
				leaderboardFrame.MainFrame.Accuracy.Visible = true
				leaderboardFrame.MainFrame.PlayDate.Visible = true
				leaderboardFrame.MainFrame.PSEarned.Position = UDim2.new(1, -8, 1, 0)
				leaderboardFrame.MainFrame.PSEarned.Text = tostring(math.round(data.Performance)) .. "ps"
				leaderboardFrame.MainFrame.Score.Text = string.format("Score: %s (%dx)", api.GetScore(displayScore), data.MaxCombo)
			end
		end

		task.wait()
		check()
		leaderboardFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(check)
	end

	function api.AddLBTweenConnection(tween: Tween, delayedTime: number)
		local key = deps.HttpService:GenerateGUID(false)
		lbTweenConnection[key] = refreshEvent.Event:Connect(function()
			task.wait(delayedTime)
			if tween == nil or tween.Instance == nil and lbTweenConnection[key] then
				(lbTweenConnection[key] :: any):Disconnect()
				lbTweenConnection[key] = nil
				return
			end

			if tween.Instance then
				(tween.Instance :: any).BackgroundTransparency = 0.9
				tween:Play()
			end
		end)

		if tween.Instance ~= nil or (tween.Instance :: any).Parent ~= nil then
			(tween.Instance :: any).Destroying:Wait()
		end
		if lbTweenConnection[key] then
			(lbTweenConnection[key] :: any):Disconnect()
			lbTweenConnection[key] = nil
		end
	end

	function api.getGrade(accuracy: number, missCount: number): string
		if accuracy >= 100 then
			return "SS"
		elseif accuracy >= 95 and missCount <= 0 then
			return "S"
		elseif accuracy >= 90 then
			return "A"
		elseif accuracy >= 80 then
			return "B"
		elseif accuracy >= 70 then
			return "C"
		else
			return "D"
		end
	end

	function api.GetDate(currentDate: any): string
		local playedTime = os.time() - (tonumber(currentDate) or 0)

		if playedTime < 3600 then
			return tostring(math.floor(playedTime / 60)) .. "mi"
		elseif playedTime < 86400 then
			return tostring(math.floor(playedTime / 3600)) .. "h"
		elseif playedTime < 2592000 then
			return tostring(math.floor(playedTime / 86400)) .. "d"
		elseif playedTime < 62208000 then
			return tostring(math.floor(playedTime / 2592000)) .. "m"
		else
			return tostring(math.floor(playedTime / 31104000)) .. "y"
		end
	end

	function api.LoadLeaderboard()
		-- Mirrors the original behavior; we keep state (task cancel) inside this controller.
		(api :: any)._lbLoadTask = (api :: any)._lbLoadTask or nil
		local lbLoadTask: thread? = (api :: any)._lbLoadTask
		if lbLoadTask then
			task.cancel(lbLoadTask)
		end

		(api :: any)._lbLoadTask = task.spawn(function()
			local gameSettingManage = deps.getGameSettingManage()
			local psLeaderboard = gameSettingManage.getSettings:Invoke("UsePSLeaderboard")
			local optimizedPerfomance = gameSettingManage.getSettings:Invoke("OptimizedPerfomance")
			local leaderboardInterface = deps.PlayerGui.BG.BeatmapLeaderboard
			local thisLBSession = deps.HttpService:GenerateGUID()
			currentLeaderboardSession = thisLBSession

			for _, obj in pairs(leaderboardInterface.GolbalLeaderboard:GetChildren()) do
				if not obj:IsA("Frame") or not obj:FindFirstChild("MainFrame") then
					continue
				end
				deps.TweenService:Create(
					(obj :: any).MainFrame,
					TweenInfo.new(0.75 + (obj :: any).LayoutOrder * 0.01, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
					{ Position = UDim2.new(1, 0, 0, 0) }
				):Play()
			end

			local personalBestOldData = leaderboardInterface.PersonalBest:FindFirstChild("PlayerPB")
			if personalBestOldData then
				personalBestOldData:Destroy()
			end

			table.clear(deps.localLeaderboardData)
			for _, connection in pairs(deps.leaderboardFrameConnection) do
				if connection then
					connection:Disconnect()
				end
			end
			table.clear(deps.leaderboardFrameConnection)

			osuGame.GameplayData.LeaderboardData.Value = "[]"

			task.spawn(function()
				leaderboardInterface.UILoad.LoadingUI.Frame.LocalScript.Disabled = false
				deps.TweenService:Create(leaderboardInterface.UILoad, TweenInfo.new(0.25, Enum.EasingStyle.Linear), { GroupTransparency = 0 }):Play()
			end)
			leaderboardInterface.NoRecord.Visible = false
			leaderboardInterface.PersonalBest.NoRecord.Visible = false
			leaderboardInterface.PersonalBestTitle.TextTransparency = 1

			local currentKey = deps.getCurrentKey()
			local globalData, personalData, sessionChanged = game.ReplicatedStorage.BeatmapLeaderboard:InvokeServer(
				1,
				{ DatastoreName = currentKey, UsingPerformanceLeaderboard = psLeaderboard }
			)

			for _, data in pairs(globalData) do
				data.ExtraData = deps.ScoreStaticticConverter.ConvertStatictic(data.ExtraData)
			end
			if personalData.ExtraData then
				personalData.ExtraData = deps.ScoreStaticticConverter.ConvertStatictic(personalData.ExtraData)
			end

			if sessionChanged == true or currentLeaderboardSession ~= thisLBSession then
				return
			end

			local leaderboard = leaderboardInterface.GolbalLeaderboard
			leaderboard:ClearAllChildren()

			local uiListLayout = Instance.new("UIListLayout", leaderboard)
			uiListLayout.Padding = UDim.new(0, 5)
			uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

			local personalRank = "-"
			local top100Score = 1

			local sendingData = {
				Golbal = globalData,
				Local = personalData,
				PSLeaderboard = psLeaderboard,
				V2Leaderboard = deps.getScoreV2Enabled(),
			}
			(osuGame :: any).GameplayData.LbStateAvaiable.LbDataProcess.Update:Fire(sendingData)

			if (osuGame :: any):FindFirstChild("GameStarted") or deps.getStartupState() == "FastRestart" then
				return
			end

			local function getps(plr)
				return plr.ExtraData and (plr.ExtraData.Performance or 0) or 0
			end

			local savedScoreV2: { [any]: number } = {}
			local previewMapPS = deps.getPreviewMapPS()

			local function getScoreV2(data)
				if savedScoreV2[data.UID] then
					return savedScoreV2[data.UID]
				end
				local scoreV2 = require(deps.ScriptComponent.Gameplay.RawV1ToV2)(
					data.Score,
					{
						MaxCombo = data.ExtraData.MaxCombo,
						h300 = data.ExtraData.Statistic.h300,
						h100 = data.ExtraData.Statistic.h100,
						h50 = data.ExtraData.Statistic.h50,
						miss = data.ExtraData.Statistic.missCount,
					},
					previewMapPS.objCount,
					previewMapPS.MaxCombo,
					previewMapPS.MaxAccScore,
					previewMapPS.MaxConsistencyScore,
					previewMapPS.MaxSpinnerScore,
					data.ExtraData.ModData
				)
				savedScoreV2[data.UID] = scoreV2
				return scoreV2
			end

			if psLeaderboard then
				table.sort(globalData, function(plr1, plr2)
					return getps(plr1) > getps(plr2) or (getps(plr1) == getps(plr2) and plr1.Rank < plr2.Rank)
				end)
				for newRank, plr in pairs(globalData) do
					plr.Rank = newRank
				end
			elseif deps.getScoreV2Enabled() then
				table.sort(globalData, function(plr1, plr2)
					return getScoreV2(plr1) > getScoreV2(plr2)
						or (getScoreV2(plr1) == getScoreV2(plr2) and plr1.Rank < plr2.Rank)
				end)
				for newRank, plr in pairs(globalData) do
					plr.Rank = newRank
				end
			end

			task.spawn(function()
				leaderboardInterface.UILoad.LoadingUI.Frame.CloseRequest:Fire()
				task.wait(0.15)
				deps.TweenService:Create(leaderboardInterface.UILoad, TweenInfo.new(0.25, Enum.EasingStyle.Linear), { GroupTransparency = 1 }):Play()
			end)

			task.wait(0.4)
			if not (osuGame :: any):FindFirstChild("GameStarted") then
				leaderboard.CanvasSize = UDim2.new(0, 0, 0, #globalData * 45)
				leaderboard.CanvasPosition = Vector2.new(0, 0)

				local total = #globalData + ((personalData and tonumber(personalData.Score) and 1) or 0)
				local loaded = 0

				local rankColor = deps.getRankColor()

				for i, data in pairs(globalData) do
					task.spawn(function()
						local newLBFrame = (rootScript :: any).Leaderboard.LeaderboardFrame:Clone()
						newLBFrame.Parent = leaderboard

						newLBFrame.MouseEnter:Connect(function()
							deps.TweenService:Create(newLBFrame.MainFrame.PlayerName, TweenInfo.new(0.1, Enum.EasingStyle.Linear), { TextTransparency = 1 }):Play()
							deps.TweenService:Create(newLBFrame.MainFrame.UserName, TweenInfo.new(0.1, Enum.EasingStyle.Linear), { TextTransparency = 0 }):Play()
						end)
						newLBFrame.MouseLeave:Connect(function()
							deps.TweenService:Create(newLBFrame.MainFrame.PlayerName, TweenInfo.new(0.1, Enum.EasingStyle.Linear), { TextTransparency = 0 }):Play()
							deps.TweenService:Create(newLBFrame.MainFrame.UserName, TweenInfo.new(0.1, Enum.EasingStyle.Linear), { TextTransparency = 1 }):Play()
						end)

						local success, output = pcall(function()
							newLBFrame.LayoutOrder = tonumber(data.Rank)
							newLBFrame.MainFrame.PlayerName.Text = data.DisplayName
							newLBFrame.MainFrame.UserName.Text = "@" .. data.Name

							local maxComboText = ""
							if data.ExtraData ~= nil then
								local achievedGrade = api.getGrade(data.ExtraData.Accuracy, data.ExtraData.Statistic.missCount)
								maxComboText = " (" .. tostring(data.ExtraData.MaxCombo) .. "x)"
								newLBFrame.MainFrame.Accuracy.Text = string.format("%.2f%%", data.ExtraData.Accuracy)
								newLBFrame.MainFrame.PlayDate.Text = api.GetDate(data.ExtraData.Date) .. api.GetModData(data.ExtraData.ModData)
								newLBFrame.MainFrame.Grade.Text = achievedGrade
								if achievedGrade == "SS" then
									newLBFrame.MainFrame.Grade.Text = "S"
									if data.ExtraData.ModData and (data.ExtraData.ModData.HD or data.ExtraData.ModData.FL) then
										newLBFrame.MainFrame.Grade_SSH.Visible = true
									else
										newLBFrame.MainFrame.Grade_SS.Visible = true
									end
								end
								newLBFrame.MainFrame.Grade.TextColor3 = rankColor[achievedGrade]
								if achievedGrade == "SS" or achievedGrade == "S" then
									if data.ExtraData.ModData and (data.ExtraData.ModData.HD or data.ExtraData.ModData.FL) then
										newLBFrame.MainFrame.Grade.TextColor3 = Color3.fromRGB(177, 177, 177)
									end
								end

								local psEarned = data.ExtraData.Performance
								newLBFrame.MainFrame.PSEarned.Text = (psEarned ~= nil) and (tostring(math.floor(psEarned)) .. "ps") or "-"
							else
								newLBFrame.MainFrame.Accuracy.Text = "-"
								newLBFrame.MainFrame.PlayDate.Text = "-"
								newLBFrame.MainFrame.PSEarned.Text = "-"
							end

							if tostring(data.Rank) == "100" then
								top100Score = (tonumber(data.Score) or 0) + 1
							end

							newLBFrame.MainFrame.Score.Text = "Score: " .. api.GetScore(data.Score) .. maxComboText
							newLBFrame.MainFrame.Rank.Text = "#" .. tostring(data.Rank)

							task.spawn(function()
								if not newLBFrame.Parent then
									return
								end
								if data.UID == "1241445502" then
									newLBFrame.MainFrame.PlayerName.TextColor3 = Color3.new(0.333333, 1, 0.498039)
									newLBFrame.MainFrame.Rank.TextColor3 = Color3.new(0.333333, 1, 0.498039)
									newLBFrame.MainFrame.UserName.TextColor3 = Color3.new(0.333333, 1, 0.498039)
								end

								if data.Name == deps.LocalPlayer.Name then
									newLBFrame.MainFrame.PlayerName.TextColor3 = Color3.new(0, 1, 1)
									newLBFrame.MainFrame.Rank.TextColor3 = Color3.new(0, 1, 1)
									newLBFrame.MainFrame.UserName.TextColor3 = Color3.new(0, 1, 1)
									personalRank = tostring(data.Rank)
								else
									local isLoaded = false
									local isFriend = false
									while isLoaded == false do
										task.wait()
										if pcall(function()
											isFriend = deps.LocalPlayer:IsFriendsWith(game.Players:GetUserIdFromNameAsync(data.Name))
										end) == true then
											isLoaded = true
										end
									end
									if isFriend == true then
										newLBFrame.MainFrame.PlayerName.TextColor3 = Color3.new(1, 1, 0.215686)
										newLBFrame.MainFrame.Rank.TextColor3 = Color3.new(1, 1, 0.215686)
										newLBFrame.MainFrame.UserName.TextColor3 = Color3.new(1, 1, 0.215686)
									end
								end
							end)

							api.AddLeaderboardConnection(newLBFrame, data.ExtraData, data.Score, data.UID, api.GetDate(data.ExtraData.Date))
						end)

						if not success then
							warn("Player leaderboard load failed ", data)
							warn(output)
						end

						for _ = 1, 10 do
							task.wait()
						end
						loaded += 1
						if loaded < total then
							repeat
								task.wait()
							until loaded >= total
						end

						task.wait((i - 1) * 0.05)
						if newLBFrame.Parent then
							if not optimizedPerfomance then
								deps.TweenService:Create(
									newLBFrame.MainFrame,
									TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
									{ Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.9 }
								):Play()
								deps.TweenService:Create(newLBFrame, TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, 40) }):Play()
							else
								newLBFrame.MainFrame.Position = UDim2.new(0, 0, 0, 0)
								newLBFrame.MainFrame.BackgroundTransparency = 0.9
								newLBFrame.Size = UDim2.new(1, 0, 0, 40)
							end
							task.wait(0.5)
							if newLBFrame.Parent then
								for _, a in pairs(newLBFrame.MainFrame:GetChildren()) do
									if a:IsA("TextLabel") then
										if a.Name ~= "UserName" then
											deps.TweenService:Create(a, TweenInfo.new(0.75, Enum.EasingStyle.Linear), { TextTransparency = 0 }):Play()
										end
									else
										deps.TweenService:Create(a, TweenInfo.new(0.75, Enum.EasingStyle.Linear), { ImageTransparency = 0.95 }):Play()
									end
								end
								if not optimizedPerfomance then
									api.AddLBTweenConnection(
										deps.TweenService:Create(
											newLBFrame.MainFrame,
											TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true),
											{ BackgroundTransparency = 0.8 }
										),
										(i - 1) * 0.1
									)
								end
							end
						end
					end)
				end

				if #globalData == 0 then
					leaderboardInterface.NoRecord.Visible = true
				end

				-- Personal best block is kept inside the controller for parity;
				-- it remains mostly unchanged, but moved out of init.local.luau.
				task.spawn(function()
					deps.TweenService:Create(leaderboard.Parent.PersonalBestTitle, TweenInfo.new(0.5, Enum.EasingStyle.Linear), { TextTransparency = 0 }):Play()
					local data = personalData
					if tonumber(data.Score) ~= nil then
						leaderboardInterface.PersonalBest.Visible = true
						leaderboardInterface.PersonalBestTitle.Visible = true
						leaderboardInterface.GolbalLeaderboard.Size = UDim2.new(1, 0, 1, -100)
						leaderboardInterface.ScrollSide.Size = UDim2.new(0, 4, 1, -100)

						local playersFitScreen = math.floor(leaderboard.AbsoluteSize.Y / 40) + 1
						local waitTime = (#globalData >= playersFitScreen and playersFitScreen * 0.1) or (#globalData) * 0.1
						local newLBFrame = (rootScript :: any).Leaderboard.LeaderboardFrame:Clone()
						newLBFrame.Parent = leaderboardInterface.PersonalBest
						newLBFrame.Name = "PlayerPB"
						newLBFrame.ZIndex = tonumber(data.Rank)
						newLBFrame.MainFrame.PlayerName.Text = deps.LocalPlayer.DisplayName
						newLBFrame.MainFrame.UserName.Text = "@" .. deps.LocalPlayer.Name

						newLBFrame.MouseEnter:Connect(function()
							deps.TweenService:Create(newLBFrame.MainFrame.PlayerName, TweenInfo.new(0.1, Enum.EasingStyle.Linear), { TextTransparency = 1 }):Play()
							deps.TweenService:Create(newLBFrame.MainFrame.UserName, TweenInfo.new(0.1, Enum.EasingStyle.Linear), { TextTransparency = 0 }):Play()
						end)
						newLBFrame.MouseLeave:Connect(function()
							deps.TweenService:Create(newLBFrame.MainFrame.PlayerName, TweenInfo.new(0.1, Enum.EasingStyle.Linear), { TextTransparency = 0 }):Play()
							deps.TweenService:Create(newLBFrame.MainFrame.UserName, TweenInfo.new(0.1, Enum.EasingStyle.Linear), { TextTransparency = 1 }):Play()
						end)

						local maxComboText = ""
						if data.ExtraData ~= nil then
							local achievedGrade = api.getGrade(data.ExtraData.Accuracy, data.ExtraData.Statistic.missCount)
							maxComboText = " (" .. tostring(data.ExtraData.MaxCombo) .. "x)"
							newLBFrame.MainFrame.Accuracy.Text = string.format("%.2f%%", data.ExtraData.Accuracy)
							newLBFrame.MainFrame.PlayDate.Text = api.GetDate(data.ExtraData.Date) .. api.GetModData((data.ExtraData :: any).Mod)
							newLBFrame.MainFrame.Grade.Text = achievedGrade
							if achievedGrade == "SS" then
								newLBFrame.MainFrame.Grade.Text = "S"
								if data.ExtraData.ModData and (data.ExtraData.ModData.HD or data.ExtraData.ModData.FL) then
									newLBFrame.MainFrame.Grade_SSH.Visible = true
								else
									newLBFrame.MainFrame.Grade_SS.Visible = true
								end
							end
							newLBFrame.MainFrame.Grade.TextColor3 = rankColor[achievedGrade]
							if achievedGrade == "SS" or achievedGrade == "S" then
								if data.ExtraData.ModData and (data.ExtraData.ModData.HD or data.ExtraData.ModData.FL) then
									newLBFrame.MainFrame.Grade.TextColor3 = Color3.fromRGB(177, 177, 177)
								end
							end
							local psEarned = data.ExtraData.Performance
							newLBFrame.MainFrame.PSEarned.Text = (psEarned ~= nil) and (tostring(math.floor(psEarned)) .. "ps") or "-"
						else
							newLBFrame.MainFrame.Accuracy.Text = "-"
							newLBFrame.MainFrame.PlayDate.Text = "-"
							newLBFrame.MainFrame.PSEarned.Text = "-"
						end

						newLBFrame.MainFrame.Score.Text = "Score: " .. api.GetScore(data.Score) .. maxComboText

						task.spawn(function()
							newLBFrame.MainFrame.Rank.Text = "-"
							for idx, e in pairs(globalData) do
								if e.UID == deps.LocalPlayer.UserId then
									personalRank = tostring(idx)
									break
								end
							end
							if personalRank ~= "-" then
								newLBFrame.MainFrame.Rank.Text = "#" .. tostring(personalRank)
							else
								local topPercent = 1 + math.floor((99 - (tonumber(data.Score) / top100Score) * 99) + 0.5)
								newLBFrame.MainFrame.Rank.Text = "Top " .. string.format("%.1f", topPercent) .. "%"
							end
						end)

						api.AddLeaderboardConnection(newLBFrame, data.ExtraData, data.Score, data.UID, api.GetDate(data.ExtraData.Date))

						for _ = 1, 10 do
							task.wait()
						end
						loaded += 1
						if loaded < total then
							repeat
								task.wait()
							until loaded >= total
						end
						task.wait(waitTime)
						newLBFrame.Size = UDim2.new(1, 0, 0, 40)
						if not optimizedPerfomance then
							deps.TweenService:Create(newLBFrame.MainFrame, TweenInfo.new(0.75, Enum.EasingStyle.Quart), { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.9 }):Play()
						else
							newLBFrame.MainFrame.Position = UDim2.new(0, 0, 0, 0)
						end

						task.wait(0.25)
						for _, a in pairs(newLBFrame.MainFrame:GetChildren()) do
							if a:IsA("TextLabel") then
								if a.Name ~= "UserName" then
									deps.TweenService:Create(a, TweenInfo.new(0.75, Enum.EasingStyle.Linear), { TextTransparency = 0 }):Play()
								end
							else
								deps.TweenService:Create(a, TweenInfo.new(0.75, Enum.EasingStyle.Linear), { ImageTransparency = 0.95 }):Play()
							end
						end
						task.wait(0.5)
						if not optimizedPerfomance then
							api.AddLBTweenConnection(deps.TweenService:Create(newLBFrame.MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), { BackgroundTransparency = 0.8 }), waitTime)
						end
					else
						leaderboardInterface.PersonalBest.Visible = false
						leaderboardInterface.PersonalBestTitle.Visible = false
						leaderboardInterface.GolbalLeaderboard.Size = UDim2.new(1, 0, 1, -40)
						leaderboardInterface.ScrollSide.Size = UDim2.new(0, 4, 1, -40)
					end
				end)
			end
		end)
	end

	function api.init()
		lbDetailMovementConnection = deps.UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				local leaderboardInterface = deps.PlayerGui.BG.BeatmapLeaderboard
				local lbPosition = leaderboardInterface.AbsolutePosition
				local mousePosition = input.Position
				local newPosition = UDim2.new(0, mousePosition.X - lbPosition.X, 0, mousePosition.Y - lbPosition.Y)

				local anchorPoint = { X = 0, Y = 0 }
				local screenSize = deps.workspace.CurrentCamera.ViewportSize
				local frameSize = leaderboardInterface.LeaderboardDetail.AbsoluteSize

				if mousePosition.X + frameSize.X + 25 > screenSize.X then
					anchorPoint.X = 1
				end
				if mousePosition.Y + frameSize.Y + 75 > screenSize.Y then
					anchorPoint.Y = 1
				end

				newPosition += (UDim2.new(0, 20, 0, 35) - UDim2.new(0, anchorPoint.X * 20, 0, anchorPoint.Y * 35))
				deps.TweenService:Create(
					leaderboardInterface.LeaderboardDetail,
					TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					{ Position = newPosition, AnchorPoint = Vector2.new(anchorPoint.X, anchorPoint.Y) }
				):Play()
			end
		end)

		deps.PlayerGui.BG.BeatmapLeaderboard.Destroying:Connect(function()
			if lbDetailMovementConnection then
				lbDetailMovementConnection:Disconnect()
				lbDetailMovementConnection = nil
			end
		end)

		task.spawn(function()
			while (osuGame :: any):FindFirstChild("GameStarted") == nil and task.wait(1.5) do
				refreshEvent:Fire()
			end
		end)
	end

	return api
end

return LeaderboardController

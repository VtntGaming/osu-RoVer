local MainUI = script.Parent.Parent
local SystemGame = game.Players.LocalPlayer.PlayerGui:WaitForChild("SystemGame")
local SongChoosingValue = SystemGame.Beatmap.SongChoosing
local TweenService = game:GetService("TweenService")
local IsEnabled = false
local BackgroundFrame = game.Players.LocalPlayer.PlayerGui.GameBackground
local MainFrame = script.Parent.Parent.MainFrame

local function SetEnabled(enabled: boolean)
	IsEnabled = enabled
	if enabled then
		MainUI.Enabled = true
		local currentActiveBeatmap = SongChoosingValue.Value
		if currentActiveBeatmap then
			script.Parent.FocusToMap:Fire(currentActiveBeatmap)
		end
		
		TweenService:Create(BackgroundFrame.DimBackground,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.75}):Play()

		local t = TweenService:Create(MainFrame, TweenInfo.new(0), {
			Position = UDim2.fromScale(1, 0)
		})
		
		t:Play()
		if t.PlaybackState ~= Enum.PlaybackState.Completed then
			t.Completed:Wait()
		end
		TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(0, 0)
		}):Play()
	else
		TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
			Position = UDim2.fromScale(1, 0)
		}):Play()
		task.delay(0.25, function()
			if not IsEnabled then
				MainUI.Enabled = false				
			end
		end)
	end	
end

SetEnabled(false)	-- Default state

script.Parent.SetEnabled.Event:Connect(function(enabled: boolean)
	SetEnabled(enabled)
end)

local ReturnButton = MainUI.MainFrame.ReturnButton.Button

ReturnButton.Activated:Connect(function()
	if not IsEnabled then
		return
	end
	SetEnabled(false)
	task.wait(0.1)
	game.Players.LocalPlayer.PlayerGui.MenuScreen.OnMenuScreenScript.Enabled = true
end)

local PlayButton = MainUI.MainFrame.MainIcon

PlayButton.TriggerButton.Activated:Connect(function()
	SetEnabled(false)
	task.wait(0.25)
	game.Players.LocalPlayer.PlayerGui.MainGameplay.Scripts.OsuGame.Enabled = true
end)


local GameIcon = PlayButton.GameIcon
local SongEffectAnalyzer = SystemGame.Song.SongBeatEffect.AudioAnalyzer

local function GetAudioBeatRate()
	local rmsLevel = SongEffectAnalyzer.RmsLevel

	return rmsLevel
end

task.spawn(function()	
	while task.wait() do
		if not IsEnabled then
			continue
		end
		local Size = 2 + math.pow(GetAudioBeatRate(),2) / 14
		GameIcon.Size = UDim2.new(Size,0,Size,0)
	end
end)
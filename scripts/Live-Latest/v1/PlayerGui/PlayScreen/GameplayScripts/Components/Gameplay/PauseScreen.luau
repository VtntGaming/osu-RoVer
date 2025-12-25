local TweenService = game:GetService("TweenService")
local DEFAULT_MESSAGE = {
	Failed = "You've failed, retry?",
	Paused = "Take a breath, the result is waiting!"
}

local PauseFrame = script.Parent.Parent.Parent.Parent.PauseScreen

export type Args = {
	CustomText: string?,
	DisableRestart: boolean?
}

local RENDER_POS = {
	["Enable"] = {
		["true"] = {
			Restart = UDim2.new(0.5, 0, 0.465, 0),
			Exit = UDim2.new(0.5, 0, 0.535, 0),
		},
		["false"] = {
			Continue = UDim2.new(0.5, 0, 0.42, 0),
			Restart = UDim2.new(0.5, 0, 0.5, 0),
			Exit = UDim2.new(0.5, 0, 0.58, 0),
		}
	},
	["Disable"] = {
		Continue = UDim2.new(0.5, 0, 0.6, 0),
		Restart = UDim2.new(0.5, 0, 0.75, 0),
		Exit = UDim2.new(0.5, 0, 0.9, 0),
	}
}

local function setButtonVisible(btn, newState: boolean, isImmediate: boolean?)
	local t_info = isImmediate and TweenInfo.new(0) or TweenInfo.new(0.5, Enum.EasingStyle.Quart, newState and Enum.EasingDirection.Out or Enum.EasingDirection.In)
	TweenService:Create(btn.Title, t_info, {TextTransparency = newState and  0 or 1}):Play()
	TweenService:Create(btn.Title_shadow, t_info, {TextTransparency = newState and 0.75 or 1}):Play()
	TweenService:Create(btn, t_info, {BackgroundTransparency = newState and 0.1 or 1}):Play()
	btn.Interactable = newState
end

local function setPos(btn, pos: UDim2, newState: boolean?, customTime: number?)
	local tTime = customTime or 0.5
	local t_info = tTime == 0 and TweenInfo.new(0) or TweenInfo.new(tTime, Enum.EasingStyle.Quart, newState and Enum.EasingDirection.Out or Enum.EasingDirection.In)
	TweenService:Create(btn, t_info, {Position = pos}):Play()
end
local pauseScreen = {}
function pauseScreen.Toggle(newState: boolean, isFail: boolean?, args: Args)
	if not args then
		args = {}
	end
	if newState then
		-- default set
		setButtonVisible(PauseFrame.RestartBeatmap, false, true)
		setButtonVisible(PauseFrame.ExitGame, false, true)
		setButtonVisible(PauseFrame.ContinueBeatmap, false, true)
		setPos(PauseFrame.ExitGame, RENDER_POS.Disable.Exit, false, 0)
		setPos(PauseFrame.RestartBeatmap, RENDER_POS.Disable.Restart, false, 0)
		setPos(PauseFrame.ContinueBeatmap, RENDER_POS.Disable.Continue, false, 0)
		task.wait()
		-----
		PauseFrame.Visible = true
		PauseFrame.Title.Text = isFail and "BEATMAP FAILED!" or "BEATMAP PAUSED"
		PauseFrame.Title.TextColor3 = Color3.fromHSV(isFail and 0 or 0.110806, 0.72549, 1)
		
		TweenService:Create(PauseFrame, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {BackgroundTransparency = 0.25}):Play()
		TweenService:Create(PauseFrame.Hint.HintText, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0, Position = UDim2.fromScale(0,0) }):Play()
		TweenService:Create(PauseFrame.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0 }):Play()
		
		local displayText = DEFAULT_MESSAGE[isFail and "Failed" or "Paused"]
		
		if args.CustomText then
			displayText = args.CustomText
		end
		if not args.DisableRestart then
			setButtonVisible(PauseFrame.RestartBeatmap, true)
			PauseFrame.RestartBeatmap.Visible = true
			setPos(PauseFrame.RestartBeatmap, RENDER_POS.Enable[tostring(isFail)].Restart, true, isFail and 0.4 or 0.3)
		else
			setButtonVisible(PauseFrame.RestartBeatmap, false, true)
		end
		
		if true then
			setButtonVisible(PauseFrame.ExitGame, true)
			setPos(PauseFrame.ExitGame, RENDER_POS.Enable[tostring(isFail)].Exit, true, 0.5)
			PauseFrame.ExitGame.Visible = true
		end
		
		if not isFail then
			setButtonVisible(PauseFrame.ContinueBeatmap, true)
			setPos(PauseFrame.ContinueBeatmap, RENDER_POS.Enable[tostring(isFail)].Continue, true, 0.3)
			PauseFrame.ContinueBeatmap.Visible = true
		else
			setButtonVisible(PauseFrame.ContinueBeatmap, false, true)
		end
		
		PauseFrame.Hint.HintText.Text = displayText
	else
		task.spawn(function()
			TweenService:Create(PauseFrame, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
			TweenService:Create(PauseFrame.Hint.HintText, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 1, Position = UDim2.fromOffset(-15,0) }):Play()
			TweenService:Create(PauseFrame.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
			setButtonVisible(PauseFrame.RestartBeatmap, false)
			setButtonVisible(PauseFrame.ExitGame, false)
			setButtonVisible(PauseFrame.ContinueBeatmap, false)
			setPos(PauseFrame.ExitGame, RENDER_POS.Disable.Exit, false, 0.3)
			setPos(PauseFrame.RestartBeatmap, RENDER_POS.Disable.Restart, false, 0.4)
			setPos(PauseFrame.ContinueBeatmap, RENDER_POS.Disable.Continue, false, 0.5)
			task.wait(0.5)
			PauseFrame.Visible = false
		end)
		
	end
end

return pauseScreen
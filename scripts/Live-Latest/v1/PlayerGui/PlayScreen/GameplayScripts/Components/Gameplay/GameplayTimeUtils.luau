local timeUtil = {}

local timeTick = 0
local pausedTime = 0
local isPaused = false

function timeUtil.InitTimeClock(timeDelay: number?)	
	timeTick = os.clock() + (timeDelay or 0)
end

function timeUtil.GetTime():number
	if isPaused then
		return pausedTime
	end
	return os.clock() - timeTick
end

function timeUtil.PauseTime()
	if isPaused then
		warn("Can't pause when the game is already paused")
		return
	end

	pausedTime = timeUtil.GetTime()
	isPaused = true	
end

function timeUtil.ResumeTime()
	if not isPaused then
		warn("Can't unpause when the game is not paused")
		return
	end

	isPaused = false
	timeTick = os.clock() - pausedTime
end

function timeUtil.TimeJump(t: number)
	local newTime = os.clock() - t
	timeTick = newTime
end

function timeUtil.IsPaused():boolean
	return isPaused
end

return timeUtil
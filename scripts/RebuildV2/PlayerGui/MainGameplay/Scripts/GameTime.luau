--!strict
local GameTime = {}

local CurrentClockTime = 0
local LastPausedTime = 0
local IsPaused = false

-- Returns the clock time in os.clock
function GameTime.SetTime(t: number): number	
   CurrentClockTime = os.clock() - t

   return CurrentClockTime
end

function GameTime.GetTime(): number
    if IsPaused then
        return LastPausedTime
    else
        return os.clock() - CurrentClockTime
    end
end

function GameTime.SetPaused(paused: boolean)
    if IsPaused ~= paused then
        if paused then            
            LastPausedTime = GameTime.GetTime()
        end

        IsPaused = paused
    end
end

return GameTime
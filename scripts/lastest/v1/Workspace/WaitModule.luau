--!native
--V1.3
--Used user FPS instead of old wait()
--How to use this module: 
--[[
local _wait = require(6425776099) --Note that you can ONLY use this on the server, can't use in the client
--_wait = require(workspace.MainModule) --This can be apply on any type of script

wait(3)
]]

function callMethod()
	if game:GetService("RunService"):IsClient() then
		return workspace.ClientWaitModule.AccurateEvent.Event:Wait()
		--return game:GetService("RunService").RenderStepped:Wait()
	else
		return game:GetService("RunService").Heartbeat:Wait()
	end
end

return function(t)
	return task.wait(t)
end

--[[

return function(_time)
	script.Usage.Value += 1
	_time = tonumber(_time)
	if _time == nil or _time < 0 or tonumber(_time) == nil then
		_time = 0
	end
	local _start = tick()
	local TotalCheck = 0
	while tick() - _start < _time do
		TotalCheck = TotalCheck + 1
		callMethod()
	end
	if TotalCheck <= 0 then
		callMethod()
	end
	script.Usage.Value -= 1
	return tonumber(tick() - _start)
end]]
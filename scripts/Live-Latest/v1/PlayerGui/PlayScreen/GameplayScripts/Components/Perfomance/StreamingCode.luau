--[LOCATION]:[StarterGui.PlayScreen.GameplayScripts.Components.Perfomance.StreamingCode]
local streaming = {}

function generateId()
	return game.HttpService:GenerateGUID()
end

function streaming.create()
	local streamData = {}
	streamData.FunctionData = {} -- saving callbacks
	
	function streamData:RemoveLoop(id)
		self.FunctionData[id] = nil
	end
	
	function streamData:AddLoop(condition, waitTime, callback) 
		--  function, condition is to check if it's able to do the next loop or not
		-- callback is to do the task
		if condition == true then
			-- always execute
			condition = function() return true end
		end
		
		if typeof(waitTime) == "number" then
			local num = waitTime
			waitTime = (function() return num end)
		end
		
		local id = generateId()
		self.FunctionData[id] = {condition, callback, waitTime, 0, false}
		-- condition
		-- callback
		-- waitTime
		-- last tick time
		-- is the callback still executing?
		return id
	end
	
	function streamData:tick()
		for id, data in pairs(self.FunctionData) do
			if data[5] then continue end
			task.spawn(function()
				if not data[1]() then
					self:RemoveLoop(id)
					return
				end -- the condition is met, finishing the loop
				local deltaTime = tick() - data[4]
				if data[3]() > 0 and deltaTime < data[3]() then
					return
				else
					data[4] = tick()
				end
				if data[5] then
					return -- double check
				end
				data[5] = true
				local s, e = pcall(function()
					return data[2](deltaTime)
				end)
				data[5] = false
				if not s or e == "break" then
					-- In the normal loop break they need to do break, in here they must be called with return "break"
					if not s then
						warn(e)
					end
					self:RemoveLoop(id)
				end
			end)
		end
	end
	
	function streamData:Start()
		task.spawn(function()
			while true do				
				streamData:tick()				
				task.wait()
			end
		end)
	end
	
	streamData:Start()
	
	return streamData
end


return streaming
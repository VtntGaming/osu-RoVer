local HttpService = game:GetService("HttpService")

local PROCESS_PER_FRAME:number
local UI_PROCESS_PER_FRAME:number

local DEFAULT_ASSET_ID = "rbxassetid://13227806914"
local DEFAULT_ASSET_SIZE = Vector2.new(32,32)

local callbacks = {}
local callbacks_once = {}
local callbacks_UI = {}
local objectData = {}
local commandsCount = 0
local mainUI = script.Parent.Parent.Parent.Parent

local LayoutPlacement = {
	[0] = mainUI.MainFrame.RatioFrame.Background,
	[1] = nil,
	[2] = nil,
	[3] = mainUI.MainFrame.RatioFrame.Foreground,
}

local startTime = os.clock() - 999999999999999

script.Parent:BindToMessage("SetProcessPerFrame", function(value1:number, value2:number)
	PROCESS_PER_FRAME = value1
	UI_PROCESS_PER_FRAME = value2
end)

script.Parent:BindToMessage("SetStartTime", function(t:number)
	startTime = t
end)

local CORE_INDEX = -1
script.Parent:BindToMessage("SetCoreIndex", function(i)
	CORE_INDEX = i
end)

task.spawn(function()
	if not PROCESS_PER_FRAME then
		repeat task.wait() until PROCESS_PER_FRAME
	end
	while task.wait() do
		task.desynchronize()
		local count = 0
		local defer_count = 0
		local defer_time = 0
		local errors = 0
		local _s = os.clock()
		-- TODO: Make sure this thing must not yield
		-- It can load up to 1k commands at one frame
		for _, callback in pairs(callbacks) do
			local s,e = pcall(function()
				callback()
			end)
			count += 1
			if not s then
				errors += 1
				warn(e)
			end
			if count % PROCESS_PER_FRAME == 0 and count > 0 then
				task.synchronize()
				defer_count += 1
				defer_time += task.wait()
				task.desynchronize()
			end

		end
		for id, callback in pairs(callbacks_once) do
			local s,e = pcall(function()
				callback()
			end)
			count += 1
			if not s then
				errors += 1
				warn(e)
			end
			callbacks_once[id] = nil
			if count % PROCESS_PER_FRAME == 0 and count > 0 then
				task.synchronize()
				defer_count += 1
				defer_time += task.wait()
				task.desynchronize()
			end
		end
		task.synchronize()
		script.Parent.Parent.Parent.Actor:SendMessage("UpdateStats", CORE_INDEX, "ActiveCommands", count)
		script.Parent.Parent.Parent.Actor:SendMessage("UpdateStats", CORE_INDEX, "ComputeTime", (os.clock() - _s) - defer_time)
		--Stats.LastCommandTime = (os.clock() - _s) - defer_time
		--mainUI.Stats.ActiveCommands.Text = `Active commands: {count} [Defered: {defer_count} | Errors: {errors}]`
		--mainUI.Stats.ObjectActiveCommands.Text = `Object commands: {commandsCount}`
	end
end)

task.spawn(function()
	if not UI_PROCESS_PER_FRAME then
		repeat task.wait() until UI_PROCESS_PER_FRAME
	end
	local previous_count = 0
	while true do
		local count_ui = 0
		local continue_count = 0
		local defer_time = 0
		if previous_count % UI_PROCESS_PER_FRAME > UI_PROCESS_PER_FRAME * 0.5 or previous_count < UI_PROCESS_PER_FRAME then
			task.wait()
		else
			continue_count = previous_count % UI_PROCESS_PER_FRAME
		end
		local _s = os.clock()
		local errors = 0
		local defer_count = 0
		for id, callback in pairs(callbacks_UI) do
			local s,e = pcall(function()
				callback()
			end)
			count_ui += 1
			continue_count += 1
			if not s then
				errors += 1
				warn(e)
			end
			if continue_count % UI_PROCESS_PER_FRAME == 0 and continue_count > 0 then
				defer_count += 1
				defer_time += task.wait()
			end
		end

		--Stats.LastUITime = (os.clock() - _s) - defer_time
		previous_count = continue_count
		script.Parent.Parent.Parent.Actor:SendMessage("UpdateStats", CORE_INDEX, "UIActiveCommands", count_ui)
		script.Parent.Parent.Parent.Actor:SendMessage("UpdateStats", CORE_INDEX, "ComputeTime_UI", (os.clock() - _s) - defer_time)
		--mainUI.Stats.ActiveUICommands.Text = `UI Process: {count_ui} [Defered: {defer_count} | Errors: {errors}]`
	end	
end)

local objectData = {}
local unused_objs = {}
local cmdsHaveRanOnce = {}

task.spawn(function()
	while task.wait(0.1) do
		script.Parent.Parent.Parent.Actor:SendMessage("UpdateStats", CORE_INDEX, "ObjsNotInUse", #unused_objs)
	end
end)

-- Functions

local function getObj():ImageLabel
	local obj = unused_objs[1]
	if obj then
		table.remove(unused_objs, 1)
		return obj
	else
		return Instance.new("ImageLabel")
	end
end

function toUDim2(v:Vector2):UDim2
	return UDim2.fromScale(v.X/640, v.Y/480)
end

local function clamp01(t) return math.clamp(t, 0, 1) end
local pi = math.pi

local function bounceOut(t)
	t = clamp01(t)
	if t < 1 / 2.75 then
		return 7.5625 * t * t
	elseif t < 2 / 2.75 then
		t = t - 1.5 / 2.75
		return 7.5625 * t * t + 0.75
	elseif t < 2.5 / 2.75 then
		t = t - 2.25 / 2.75
		return 7.5625 * t * t + 0.9375
	else
		t = t - 2.625 / 2.75
		return 7.5625 * t * t + 0.984375
	end
end

local EASING = {
	[0] = function(t) -- Linear
		t = clamp01(t)
		return t
	end,

	[1] = function(t) -- Easing Out (use cubic out)
		t = clamp01(t)
		return 1 - math.pow(1 - t, 3)
	end,

	[2] = function(t) -- Easing In (use cubic in)
		t = clamp01(t)
		return t * t * t
	end,

	[3] = function(t) -- Quad In
		t = clamp01(t)
		return t * t
	end,

	[4] = function(t) -- Quad Out
		t = clamp01(t)
		return t * (2 - t)
	end,

	[5] = function(t) -- Quad In/Out
		t = clamp01(t)
		if t < 0.5 then
			return 2 * t * t
		else
			return 1 - math.pow(-2 * t + 2, 2) / 2
		end
	end,

	[6] = function(t) -- Cubic In
		t = clamp01(t)
		return t * t * t
	end,

	[7] = function(t) -- Cubic Out
		t = clamp01(t)
		return 1 - math.pow(1 - t, 3)
	end,

	[8] = function(t) -- Cubic In/Out
		t = clamp01(t)
		if t < 0.5 then
			return 4 * t * t * t
		else
			return 1 - math.pow(-2 * t + 2, 3) / 2
		end
	end,

	[9] = function(t) -- Quart In
		t = clamp01(t)
		return math.pow(t, 4)
	end,

	[10] = function(t) -- Quart Out
		t = clamp01(t)
		return 1 - math.pow(1 - t, 4)
	end,

	[11] = function(t) -- Quart In/Out
		t = clamp01(t)
		if t < 0.5 then
			return math.pow(2 * t, 4) / 2
		else
			return 1 - math.pow(-2 * t + 2, 4) / 2
		end
	end,

	[12] = function(t) -- Quint In
		t = clamp01(t)
		return math.pow(t, 5)
	end,

	[13] = function(t) -- Quint Out
		t = clamp01(t)
		return 1 - math.pow(1 - t, 5)
	end,

	[14] = function(t) -- Quint In/Out
		t = clamp01(t)
		if t < 0.5 then
			return math.pow(2 * t, 5) / 2
		else
			return 1 - math.pow(-2 * t + 2, 5) / 2
		end
	end,

	[15] = function(t) -- Sine In
		t = clamp01(t)
		return 1 - math.cos((t * pi) / 2)
	end,

	[16] = function(t) -- Sine Out
		t = clamp01(t)
		return math.sin((t * pi) / 2)
	end,

	[17] = function(t) -- Sine In/Out
		t = clamp01(t)
		return -(math.cos(pi * t) - 1) / 2
	end,

	[18] = function(t) -- Expo In
		t = clamp01(t)
		if t == 0 then return 0 end
		return math.pow(2, 10 * t - 10)
	end,

	[19] = function(t) -- Expo Out
		t = clamp01(t)
		if t == 1 then return 1 end
		return 1 - math.pow(2, -10 * t)
	end,

	[20] = function(t) -- Expo In/Out
		t = clamp01(t)
		if t == 0 then return 0 end
		if t == 1 then return 1 end
		if t < 0.5 then
			return math.pow(2, 20 * t - 10) / 2
		else
			return (2 - math.pow(2, -20 * t + 10)) / 2
		end
	end,

	[21] = function(t) -- Circ In
		t = clamp01(t)
		return 1 - math.sqrt(1 - t * t)
	end,

	[22] = function(t) -- Circ Out
		t = clamp01(t)
		return math.sqrt(1 - math.pow(t - 1, 2))
	end,

	[23] = function(t) -- Circ In/Out
		t = clamp01(t)
		if t < 0.5 then
			return (1 - math.sqrt(1 - (2 * t) ^ 2)) / 2
		else
			return (math.sqrt(1 - (-2 * t + 2) ^ 2) + 1) / 2
		end
	end,

	[24] = function(t) -- Elastic In
		t = clamp01(t)
		if t == 0 then return 0 end
		if t == 1 then return 1 end
		local c = 2 * pi / 3
		return -math.pow(2, 10 * t - 10) * math.sin((t * 10 - 10.75) * c)
	end,

	[25] = function(t) -- Elastic Out
		t = clamp01(t)
		if t == 0 then return 0 end
		if t == 1 then return 1 end
		local c = 2 * pi / 3
		return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c) + 1
	end,

	[26] = function(t) -- ElasticHalf Out (faster oscillation)
		t = clamp01(t)
		if t == 0 then return 0 end
		if t == 1 then return 1 end
		local c = 2 * pi / 1.5
		return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c) + 1
	end,

	[27] = function(t) -- ElasticQuarter Out (slower oscillation)
		t = clamp01(t)
		if t == 0 then return 0 end
		if t == 1 then return 1 end
		local c = 2 * pi / 6
		return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c) + 1
	end,

	[28] = function(t) -- Elastic In/Out
		t = clamp01(t)
		if t == 0 then return 0 end
		if t == 1 then return 1 end
		local c = 2 * pi / 4.5
		if t < 0.5 then
			return -(math.pow(2, 20 * t - 10) * math.sin((20 * t - 11.125) * c)) / 2
		else
			return (math.pow(2, -20 * t + 10) * math.sin((20 * t - 11.125) * c)) / 2 + 1
		end
	end,

	[29] = function(t) -- Back In
		t = clamp01(t)
		local s = 1.70158
		return t * t * ((s + 1) * t - s)
	end,

	[30] = function(t) -- Back Out
		t = clamp01(t)
		local s = 1.70158
		t = t - 1
		return t * t * ((s + 1) * t + s) + 1
	end,

	[31] = function(t) -- Back In/Out
		t = clamp01(t)
		local s = 1.70158 * 1.525
		if t < 0.5 then
			return (math.pow(2 * t, 2) * ((s + 1) * 2 * t - s)) / 2
		else
			t = 2 * t - 2
			return (t * t * ((s + 1) * t + s) + 2) / 2
		end
	end,

	[32] = function(t) -- Bounce In
		t = clamp01(t)
		return 1 - bounceOut(1 - t)
	end,

	[33] = function(t) -- Bounce Out
		return bounceOut(t)
	end,

	[34] = function(t) -- Bounce In/Out
		t = clamp01(t)
		if t < 0.5 then
			return (1 - bounceOut(1 - 2 * t)) / 2
		else
			return (1 + bounceOut(2 * t - 1)) / 2
		end
	end,
}

function getEasing(easing:number)
	return EASING[easing] or EASING[0]
end

script.Parent:BindToMessage("AddObject", function(unquieId:string, objData, extraData)
	local crrObjectData = {
		Position = {X = objData.Position.X, Y = objData.Position.Y},
		Scale = {X = objData.Position.X, Y = objData.Position.Y},
		Opacity = 0,
		Color = Color3.new(1,1,1),
		Rotation = 0,	-- radians
		FlipX = false,
		FlipY = false,
		AdditiveColor = false
	}
	local objectSize =  toUDim2(extraData.ImageSize or DEFAULT_ASSET_SIZE)
	local objectFrame = getObj()
	objectFrame.Image = extraData.Image or DEFAULT_ASSET_ID
	objectFrame.Parent = nil
	objectFrame.BackgroundTransparency = 1
	objectFrame.Size = extraData.Size
	objectFrame.AnchorPoint = objData.AnchorPoint
	objectFrame.Position = toUDim2(objData.Position)
	objectFrame.Name = tostring(objData.Filepath)
	objectFrame.ZIndex = objData.LayoutOrder
	local parentDestination = LayoutPlacement[objData.Layer]
	
	local UI_funct = function()
		local newTransparency = 1 - crrObjectData.Opacity

		if objectFrame.ImageTransparency ~= newTransparency then
			local newPrt = newTransparency < 1 and parentDestination or nil
			if objectFrame.Parent ~= newPrt then
				objectFrame.Parent = newPrt
				if not newPrt then
					return	-- It's alrady invisible, no need to process
				end
			end
			objectFrame.ImageTransparency = newTransparency
		end

		local newColor = crrObjectData.Color
		local newRotation = math.round(math.deg(crrObjectData.Rotation))
		local newPos = toUDim2(Vector2.new(crrObjectData.Position.X, crrObjectData.Position.Y))
		local scaleX = crrObjectData.FlipX and -1 or 1
		local scaleY = crrObjectData.FlipY and -1 or 1
		local newScale = UDim2.fromScale(objectSize.X.Scale * crrObjectData.Scale.X * scaleX, objectSize.Y.Scale * crrObjectData.Scale.Y * scaleY)		

		if objectFrame.Position ~= newPos then
			objectFrame.Position = newPos
		end

		if objectFrame.Size ~= newScale then
			objectFrame.Size = newScale
		end		

		if objectFrame.ImageColor3 ~= newColor then
			objectFrame.ImageColor3 = newColor
		end

		if objectFrame.Rotation ~= newRotation then
			objectFrame.Rotation = newRotation
		end
	end

	callbacks_UI[unquieId] = UI_funct
	
	local data = {
		Object = objectFrame, 
		Data = crrObjectData
	}
	objectData[unquieId] = data
end)

script.Parent:BindToMessage("RemoveObject", function(unquieId:string)
	callbacks_UI[unquieId] = nil
	objectData[unquieId].Object.Parent = nil
	unused_objs[#unused_objs+1] = objectData[unquieId].Object
	objectData[unquieId] = nil
end)

script.Parent:BindToMessage("AddCommand", function(objUnquieId:string, unquieId:string, command)
	if not objectData[objUnquieId] then
		repeat task.wait()
		until objectData[objUnquieId]
	end
	local funct
	local commandType = command.CommandType
	local commandDuration = (command.EndTime - command.StartTime)/1000

	local easing = getEasing(command.Easing)
	local params = command.Params
	local commandHaveRanOnce = false
	
	local crrObjectData = objectData[objUnquieId].Data

	if commandType == "F" then
		funct = function()
			-- Fade
			cmdsHaveRanOnce[unquieId] = true
			local elapsed = (os.clock() - startTime)- command.StartTime/1000
			local t = elapsed/commandDuration
			if t ~= t then t = 0 end
			local progress = easing(t)
			local startOpacity = params[1] or 0
			local endOpacity = params[2] or 0
			crrObjectData.Opacity = math.lerp(startOpacity, endOpacity, progress)
		end
	elseif commandType == "M" then
		funct = function()
			-- Move XY
			cmdsHaveRanOnce[unquieId] = true
			local elapsed = (os.clock() - startTime) - command.StartTime/1000
			local t = elapsed/commandDuration
			if t ~= t then t = 0 end
			local progress = easing(t)
			local startX = params[1] or 0
			local startY = params[2] or 0
			local endX = params[3]
			local endY = params[4]
			if not endX then
				endX = startX
			end
			if not endY then
				endY = startY
			end
			crrObjectData.Position.X = math.lerp(startX, endX, progress)
			crrObjectData.Position.Y = math.lerp(startY, endY, progress)
		end
	elseif commandType == "MX" then
		funct = function()
			-- Move X
			cmdsHaveRanOnce[unquieId] = true
			local elapsed = (os.clock() - startTime) - command.StartTime/1000
			local t = elapsed/commandDuration
			if t ~= t then t = 0 end
			local progress = easing(t)
			local startX = params[1] or 0
			local endX = params[2]
			if not endX then
				endX = startX
			end
			crrObjectData.Position.X = math.lerp(startX, endX, progress)
		end				
	elseif commandType == "MY" then
		funct = function()
			-- Move Y
			cmdsHaveRanOnce[unquieId] = true
			local elapsed = (os.clock() - startTime) - command.StartTime/1000
			local t = elapsed/commandDuration
			if t ~= t then t = 0 end
			local progress = easing(t)
			local startY = params[1] or 0
			local endY = params[2]
			if not endY then
				endY = startY
			end
			crrObjectData.Position.Y = math.lerp(startY, endY, progress)
		end				
	elseif commandType == "S" then
		funct = function()
			-- Scale
			cmdsHaveRanOnce[unquieId] = true
			local elapsed = (os.clock() - startTime) - command.StartTime/1000
			local t = elapsed/commandDuration
			if t ~= t then t = 0 end
			local progress = easing(t)
			local startS = params[1] or 0
			local endS = params[2]
			if not endS	then
				endS = startS
			end
			crrObjectData.Scale.X = math.lerp(startS, endS, progress)
			crrObjectData.Scale.Y = math.lerp(startS, endS, progress)
		end				
	elseif commandType == "V" then
		funct = function()
			-- Scale separated X, Y
			cmdsHaveRanOnce[unquieId] = true
			local elapsed = (os.clock() - startTime) - command.StartTime/1000
			local t = elapsed/commandDuration
			if t ~= t then t = 0 end
			local progress = easing(t)
			local startX = params[1] or 0
			local startY = params[2] or 0
			local endX = params[3]
			local endY = params[4]
			if not endX then
				endX = startX
			end
			if not endY then
				endY = startY
			end
			crrObjectData.Scale.X = math.lerp(startX, endX, progress)
			crrObjectData.Scale.Y = math.lerp(startY, endY, progress)
		end				
	elseif commandType == "C" then
		funct = function()
			-- Colors
			cmdsHaveRanOnce[unquieId] = true
			local elapsed = (os.clock() - startTime) - command.StartTime/1000
			local t = elapsed/commandDuration
			if t ~= t then t = 0 end
			local progress = easing(t)

			local startR = params[1] or 0
			local startG = params[2] or 0
			local startB = params[3] or 0
			local endR = params[4] or 0
			local endG = params[5] or 0
			local endB = params[6] or 0

			local startColor = Color3.fromRGB(startR, startG, startB)
			local endColor = Color3.fromRGB(endR, endG, endB)
			if crrObjectData.AdditiveColor then
				endColor = Color3.fromRGB(startR+endR, startG+endG, startB+endB)
			end

			crrObjectData.Color = startColor:Lerp(endColor, progress)
		end
	elseif commandType == "R" then
		funct = function()
			-- Rotate in randians
			cmdsHaveRanOnce[unquieId] = true
			local elapsed = (os.clock() - startTime) - command.StartTime/1000
			local t = elapsed/commandDuration
			if t ~= t then t = 0 end
			local progress = easing(t)

			local startRotation = params[1] or 0
			local endRotation = params[2] or 0

			crrObjectData.Rotation = math.lerp(startRotation, endRotation, progress)
		end
	end
	
	callbacks[unquieId] = funct
end)

script.Parent:BindToMessage("RemoveCommand", function(cmdUnquieId:string)
	if not cmdsHaveRanOnce[cmdUnquieId] then
		repeat task.wait() until cmdsHaveRanOnce[cmdUnquieId]
	end
	cmdsHaveRanOnce[cmdUnquieId] = nil
	callbacks_once[cmdUnquieId] = callbacks[cmdUnquieId]
	callbacks[cmdUnquieId] = nil
end)

script.Parent:BindToMessage("ToggleParmeterCommand", function(objUnquieId:string, commandType, parmeter, stateEnable:boolean)
	local crrObjectData = objectData[objUnquieId]
	-- Parmeter commands
	-- This is a special command, unlike other commands, this only need to ran twice (start and end)
	if stateEnable then
		if parmeter == "H" then
			crrObjectData.FlipX = true
		elseif parmeter == "V" then
			crrObjectData.FlipY = true
		elseif parmeter == "A" then
			crrObjectData.AdditiveColor = true
		end
	else
		if parmeter == "H" then
			crrObjectData.FlipX = false
		elseif parmeter == "V" then
			crrObjectData.FlipY = false
		elseif parmeter == "A" then
			crrObjectData.AdditiveColor = false
		end
	end
end)
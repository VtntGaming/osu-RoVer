local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")
local StoryboardConverter = require(workspace.StoryboardConverter)
local PathListConverter = require(workspace.StoryboardConverter.PathGenerator)

local s = os.clock()
local difficultyFile = workspace.Beatmaps["Camellia - OOPARTS (xArief) [CASUOZIZ]"]
local storyboardData = StoryboardConverter(workspace.Storyboards.OOPARTS, difficultyFile)
print("Load completed, took", os.clock()-s)
type SpriteObject = StoryboardConverter.spriteObject
local DEFAULT_ASSET_ID = "rbxassetid://13227806914"
local DEFAULT_ASSET_SIZE = Vector2.new(32,32)

--local pathList = PathListConverter(storyboardData)
--print(pathList)

local ImageList = require(workspace.Storyboards.OOPARTS.ImageList)
local appearCount = {}

for _, sprite in pairs(storyboardData) do
	if not appearCount[sprite.Data.Filepath] then
		appearCount[sprite.Data.Filepath] = 1
	else
		appearCount[sprite.Data.Filepath] += 1
	end
end

print(appearCount)

table.sort(storyboardData, function(sprite1:SpriteObject, sprite2:SpriteObject)
	local sprite1Cmd = sprite1.Commands[1]
	local sprite2Cmd = sprite2.Commands[1]
	if not sprite1Cmd then
		return false
	elseif not sprite2Cmd then
		return true
	else
		return sprite1Cmd.StartTime < sprite2Cmd.StartTime
	end
end)

print("Sort completed! took", os.clock()-s)



-- Load all of the image before going into the game

local loadList = {}
for _, item in pairs(ImageList) do
	if item.ImageId and not table.find(loadList,item.ImageId) then
		loadList[#loadList+1] = item.ImageId
	end
end

ContentProvider:PreloadAsync(loadList)

print("All preview image loaded")

local startTime = os.clock()
local spritesCount = #storyboardData
local processingSprites = 0
local commandsCount = 0
local completedCount = 0
local callbacks = {}
local callbacks_once = {}
local callbacks_UI = {}
local LayoutPlacement = {
	[0] = script.Parent.Parent.Parent.MainFrame.RatioFrame.Background,
	[1] = nil,
	[2] = nil,
	[3] = script.Parent.Parent.Parent.MainFrame.RatioFrame.Foreground,
}
local Stats = {
	FPS = 0
}

task.spawn(function()
	game:GetService("RunService").Heartbeat:ConnectParallel(function()
		local count = 0
		local errors = 0
		-- TODO: Make sure this thing must not yield
		-- It can load up to 1k commands at once
		for _, callback in pairs(callbacks) do
			local s,e = pcall(function()
				callback()
			end)
			count += 1
			if not s then
				errors += 1
				warn(e)
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
		end
		task.synchronize()
		for id, callback in pairs(callbacks_UI) do
			local s,e = pcall(function()
				callback()
			end)
			count += 1
			if not s then
				errors += 1
				warn(e)
			end
		end
		script.Parent.Parent.Parent.ActiveCommands.Text = `Active commands: {count} ({errors} errors)`
		script.Parent.Parent.Parent.ObjectActiveCommands.Text = `Object commands: {commandsCount}`
		Stats.FPS += 1
		task.wait(1)
		Stats.FPS -= 1
	end)
end)

task.spawn(function()
	while task.wait(0.1) do
		script.Parent.Parent.Parent.FPS.Text = `FPS: {Stats.FPS}`
	end
end)

local pi = math.pi

local function clamp01(t) return math.clamp(t, 0, 1) end

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

function toUDim2(v:Vector2):UDim2
	return UDim2.fromScale(v.X/640, v.Y/480)
end

function toUDim2FromX(x:number, u:UDim2)
	return UDim2.fromScale(x, u.Y.Scale)
end

function toUDim2FromY(y:number, u:UDim2)
	return UDim2.fromScale(u.X.Scale, y)
end


for i, spriteData in pairs(storyboardData) do
	local objData = spriteData.Data
	local objCommands = spriteData.Commands
	table.sort(objCommands, function(c1, c2)
		if not c1.StartTime then
			return false
		elseif not c2.StartTime then
			return true
		else
			return c1.StartTime < c2.StartTime
		end
	end)
	local firstCmd = objCommands[1]
	if not firstCmd then
		break
	end
	if i == 1 then
		script.Parent.Parent.Parent.Sound.TimePosition = os.clock() - startTime
		script.Parent.Parent.Parent.Sound:Play()
	end

	local objStartTime = firstCmd.StartTime/1000
	if os.clock() - startTime < objStartTime then
		repeat task.wait() until os.clock() - startTime >= objStartTime
	end

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
	local _imgSize = ImageList[objData.Filepath] and ImageList[objData.Filepath].Size
	local _imgId = ImageList[objData.Filepath] and ImageList[objData.Filepath].ImageId
	local objectSize =  toUDim2(_imgSize or DEFAULT_ASSET_SIZE)
	local objectFrame = Instance.new("ImageLabel")
	objectFrame.Image = _imgId or DEFAULT_ASSET_ID
	objectFrame.Parent = nil
	objectFrame.BackgroundTransparency = 1
	objectFrame.Size = objectSize
	objectFrame.AnchorPoint = objData.AnchorPoint
	objectFrame.Position = toUDim2(objData.Position)
	objectFrame.Name = tostring(objData.Filepath)
	objectFrame.ZIndex = objData.LayoutOrder
	local parentDestination = LayoutPlacement[objData.Layer]
	local UI_unquieId = HttpService:GenerateGUID()
	local UI_funct = function()
		local newPos = toUDim2(Vector2.new(crrObjectData.Position.X, crrObjectData.Position.Y))
		local scaleX = crrObjectData.FlipX and -1 or 1
		local scaleY = crrObjectData.FlipY and -1 or 1
		local newScale = UDim2.fromScale(objectSize.X.Scale * crrObjectData.Scale.X * scaleX, objectSize.Y.Scale * crrObjectData.Scale.Y * scaleY)
		local newTransparency = 1 - crrObjectData.Opacity
		local newColor = crrObjectData.Color
		local newRotation = math.round(math.deg(crrObjectData.Rotation))
		if objectFrame.Position ~= newPos then
			objectFrame.Position = newPos
		end

		if objectFrame.Size ~= newScale then
			objectFrame.Size = newScale
		end

		if objectFrame.ImageTransparency ~= newTransparency then
			objectFrame.ImageTransparency = newTransparency
			local newPrt = newTransparency < 1 and parentDestination or nil
			if objectFrame.Parent ~= newPrt then
				objectFrame.Parent = newPrt
			end
		end

		if objectFrame.ImageColor3 ~= newColor then
			objectFrame.ImageColor3 = newColor
		end

		if objectFrame.Rotation ~= newRotation then
			objectFrame.Rotation = newRotation
		end
	end

	callbacks_UI[UI_unquieId] = UI_funct

	task.spawn(function()
		local currentActiveCommand = 0
		local finishedCommands = 0
		for _, command in pairs(objCommands) do
			if not command. StartTime then
				finishedCommands += 1
				continue
			end

			local unquieId = HttpService:GenerateGUID()
			local funct

			local commandType = command.CommandType
			local commandDuration = (command.EndTime - command.StartTime)/1000

			local easing = getEasing(command.Easing)
			local params = command.Params
			local commandHaveRanOnce = false

			if commandType == "F" then
				funct = function()
					-- Fade
					commandHaveRanOnce = true
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
					commandHaveRanOnce = true
					local elapsed = (os.clock() - startTime) - command.StartTime/1000
					local t = elapsed/commandDuration
					if t ~= t then t = 0 end
					local progress = easing(t)
					local startX = params[1] or 0
					local startY = params[2] or 0
					local endX = params[3] or 0
					local endY = params[4] or 0
					crrObjectData.Position.X = math.lerp(startX, endX, progress)
					crrObjectData.Position.Y = math.lerp(startY, endY, progress)
				end
			elseif commandType == "MX" then
				funct = function()
					-- Move X
					commandHaveRanOnce = true
					local elapsed = (os.clock() - startTime) - command.StartTime/1000
					local t = elapsed/commandDuration
					if t ~= t then t = 0 end
					local progress = easing(t)
					local startX = params[1] or 0
					local endX = params[2] or 0
					crrObjectData.Position.X = math.lerp(startX, endX, progress)
				end				
			elseif commandType == "MY" then
				funct = function()
					-- Move Y
					commandHaveRanOnce = true
					local elapsed = (os.clock() - startTime) - command.StartTime/1000
					local t = elapsed/commandDuration
					if t ~= t then t = 0 end
					local progress = easing(t)
					local startY = params[1] or 0
					local endY = params[2] or 0
					crrObjectData.Position.Y = math.lerp(startY, endY, progress)
				end				
			elseif commandType == "S" then
				funct = function()
					-- Scale
					commandHaveRanOnce = true
					local elapsed = (os.clock() - startTime) - command.StartTime/1000
					local t = elapsed/commandDuration
					if t ~= t then t = 0 end
					local progress = easing(t)
					local startS = params[1] or 0
					local endS = params[2] or 0
					crrObjectData.Scale.X = math.lerp(startS, endS, progress)
					crrObjectData.Scale.Y = math.lerp(startS, endS, progress)
				end				
			elseif commandType == "V" then
				funct = function()
					-- Scale separated X, Y
					commandHaveRanOnce = true
					local elapsed = (os.clock() - startTime) - command.StartTime/1000
					local t = elapsed/commandDuration
					if t ~= t then t = 0 end
					local progress = easing(t)
					local startX = params[1] or 0
					local startY = params[2] or 0
					local endX = params[3] or 0
					local endY = params[4] or 0
					crrObjectData.Scale.X = math.lerp(startX, endX, progress)
					crrObjectData.Scale.Y = math.lerp(startY, endY, progress)
				end				
			elseif commandType == "C" then
				funct = function()
					-- Colors
					commandHaveRanOnce = true
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
					commandHaveRanOnce = true
					local elapsed = (os.clock() - startTime) - command.StartTime/1000
					local t = elapsed/commandDuration
					if t ~= t then t = 0 end
					local progress = easing(t)

					local startRotation = params[1] or 0
					local endRotation = params[2] or 0

					crrObjectData.Rotation = math.lerp(startRotation, endRotation, progress)
				end
			end
			if not funct and commandType ~= "P" then
				continue
			end
			currentActiveCommand += 1
			task.spawn(function()
				if os.clock() - startTime < command.StartTime/1000 then
					repeat task.wait() until os.clock() - startTime >= command.StartTime/1000
				end

				if funct then
					callbacks[unquieId] = funct

					commandsCount += 1
					repeat task.wait(0.1) until (os.clock() - startTime > command.EndTime/1000 and commandHaveRanOnce) or not funct
					commandsCount -= 1					

					callbacks[unquieId] = nil
					callbacks_once[unquieId] = funct -- make sure it have finished it's progress

					repeat task.wait(0.1) until not callbacks_once[unquieId]
				elseif commandType == "P" then
					-- Parmeter commands
					-- This is a special command, unlike other commands, this only need to ran twice (start and end)
					local parmeter = params[1]
					if parmeter == "H" then
						crrObjectData.FlipX = true
					elseif parmeter == "V" then
						crrObjectData.FlipY = true
					elseif parmeter == "A" then
						crrObjectData.AdditiveColor = true
					end

					repeat task.wait(0.1) until (os.clock() - startTime > command.EndTime/1000)

					if parmeter == "H" then
						crrObjectData.FlipX = false
					elseif parmeter == "V" then
						crrObjectData.FlipY = false
					elseif parmeter == "A" then
						crrObjectData.AdditiveColor = false
					end
				end				

				finishedCommands += 1
			end)
		end

		while finishedCommands < currentActiveCommand do
			task.wait(1)
		end
		callbacks_UI[UI_unquieId] = nil
		objectFrame:Destroy()
		completedCount += 1
	end)

	script.Parent.Parent.Parent.SpriteIndex.Text = `Current sprite: {i}/{spritesCount} ({completedCount} completed)`
end
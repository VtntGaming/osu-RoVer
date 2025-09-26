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
local LayoutPlacement = {
	[0] = script.Parent.Parent.Parent.MainFrame.Background,
	[1] = nil,
	[2] = nil,
	[3] = script.Parent.Parent.Parent.MainFrame.Foreground,
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
		script.Parent.Parent.Parent.ActiveCommands.Text = `Active commands: {count} ({errors} errors)`
		script.Parent.Parent.Parent.ObjectActiveCommands.Text = `Object commands: {commandsCount}`
	end)
end)

local EASING = {
	Linear = function(t:number)
		return math.clamp(t,0,1)
	end,
}

function getEasing(easing:number)
	-- TODO: Make a conversion here
	return EASING.Linear
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
		Position = objData.Position,
		Scale = Vector2.new(1,1),
		Opacity = 0,
		Color = Color3.new(1,1,1),
		Rotation = 0	-- radians
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
	objectFrame.ZIndex = objData.Layer
	objectFrame.Name = tostring(objData.Filepath)
	objectFrame.ZIndex = objData.LayoutOrder
	local parentDestination = LayoutPlacement[objData.Layer]
	local thread = task.spawn(function()
		while task.wait() do
			local newPos = toUDim2(crrObjectData.Position)
			local newScale = UDim2.fromScale(objectSize.X.Scale * crrObjectData.Scale.X, objectSize.Y.Scale * crrObjectData.Scale.Y)
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
	end)
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
					local progress = easing(elapsed/commandDuration)
					local startOpacity = params[1] or 0
					local endOpacity = params[2] or 0
					crrObjectData.Opacity = math.lerp(startOpacity, endOpacity, progress)
				end
			elseif commandType == "M" then
				funct = function()
					-- Move XY
					commandHaveRanOnce = true
					local elapsed = (os.clock() - startTime) - command.StartTime/1000
					local progress = easing(elapsed/commandDuration)
					local startPos = Vector2.new(params[1], params[2])
					local endPos = Vector2.new(params[3], params[4])
					crrObjectData.Position = startPos:Lerp(endPos, progress)
				end
			elseif commandType == "MX" then
				funct = function()
					-- Move X
					commandHaveRanOnce = true
					local elapsed = (os.clock() - startTime) - command.StartTime/1000
					local progress = easing(elapsed/commandDuration)
					local startX = Vector2.new(params[1] or 0, crrObjectData.Position.Y)
					local endX = Vector2.new(params[2] or 0, crrObjectData.Position.Y)
					crrObjectData.Position = startX:Lerp(endX, progress)
				end				
			elseif commandType == "MY" then
				funct = function()
					-- Move Y
					commandHaveRanOnce = true
					local elapsed = (os.clock() - startTime) - command.StartTime/1000
					local progress = easing(elapsed/commandDuration)
					local startY = Vector2.new(crrObjectData.Position.X, params[1] or 0)
					local endY = Vector2.new(crrObjectData.Position.X, params[2] or 0)
					crrObjectData.Position = startY:Lerp(endY, progress)
				end				
			elseif commandType == "S" then
				funct = function()
					-- Scale
					commandHaveRanOnce = true
					local elapsed = (os.clock() - startTime) - command.StartTime/1000
					local progress = easing(elapsed/commandDuration)
					local startScale = params[1] or 0
					local endScale = params[2] or 0					
					crrObjectData.Scale = (Vector2.one * startScale):Lerp(Vector2.one * endScale, progress)
				end				
			elseif commandType == "V" then
				funct = function()
					-- Scale separated X, Y
					commandHaveRanOnce = true
					local elapsed = (os.clock() - startTime) - command.StartTime/1000
					local progress = easing(elapsed/commandDuration)
					local startScaleX = params[1] or 0
					local startScaleY = params[2] or 0
					local endScaleX = params[3] or 0			
					local endScaleY = params[4] or 0							
					local startScale = Vector2.new(startScaleX,startScaleY)
					local endScale = Vector2.new(endScaleX,endScaleY)				
					crrObjectData.Scale = (Vector2.one * startScale):Lerp(Vector2.one * endScale, progress)
				end				
			elseif commandType == "C" then
				funct = function()
					-- Colors
					commandHaveRanOnce = true
					local elapsed = (os.clock() - startTime) - command.StartTime/1000
					local progress = easing(elapsed/commandDuration)

					local startR = params[1] or 0
					local startG = params[2] or 0
					local startB = params[3] or 0
					local endR = params[4] or 0
					local endG = params[5] or 0
					local endB = params[6] or 0

					local startColor = Color3.fromRGB(startR, startG, startB)
					local endColor = Color3.fromRGB(endR, endG, endB)

					crrObjectData.Color = startColor:Lerp(endColor, progress)
				end
			elseif commandType == "R" then
				funct = function()
					-- Rotate in randians
					commandHaveRanOnce = true
					local elapsed = (os.clock() - startTime) - command.StartTime/1000
					local progress = easing(elapsed/commandDuration)
					
					local startRotation = params[1] or 0
					local endRotation = params[2] or 0
					
					crrObjectData.Rotation = math.lerp(startRotation, endRotation, progress)
				end				
			end
			if not funct then
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
				end
				
				
				finishedCommands += 1
			end)
		end
		
		while finishedCommands < currentActiveCommand do
			task.wait(1)
		end
		task.cancel(thread)
		objectFrame:Destroy()
		completedCount += 1
	end)
	
	script.Parent.Parent.Parent.SpriteIndex.Text = `Current sprite: {i}/{spritesCount} ({completedCount} completed)`
end
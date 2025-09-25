
local HttpService = game:GetService("HttpService")
local StoryboardConverter = require(workspace.StoryboardConverter)

local s = os.clock()
local storyboardData = StoryboardConverter(workspace.Storyboards.Test)
print("Load completed, took", os.clock()-s)
type SpriteObject = StoryboardConverter.spriteObject

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

local startTime = os.clock()
local spritesCount = #storyboardData
local processingSprites = 0
local commandsCount = 0
local completedCount = 0
local callbacks = {}

task.spawn(function()
	while task.wait() do
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
		script.Parent.Parent.ActiveCommands.Text = `Active commands: {count} ({errors} errors)`
		script.Parent.Parent.ObjectActiveCommands.Text = `Object commands: {commandsCount}`
	end
end)

local EASING = {
	Linear = function(t:number)
		return t
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
		script.Parent.Parent.Sound.TimePosition = os.clock() - startTime
		script.Parent.Parent.Sound:Play()
	end
	
	local objStartTime = firstCmd.StartTime/1000
	if os.clock() - startTime < objStartTime then
		repeat task.wait() until os.clock() - startTime >= objStartTime
	end
	
	local objectSize = UDim2.fromScale(0.05, 0.05)
	local objectFrame = Instance.new("ImageLabel")
	objectFrame.Image = "rbxassetid://113759051657843"
	objectFrame.Parent = script.Parent.Parent.MainFrame
	objectFrame.BackgroundTransparency = 1
	objectFrame.Size = objectSize
	objectFrame.AnchorPoint = objData.AnchorPoint
	objectFrame.Position = toUDim2(objData.Position)
	objectFrame.ZIndex = objData.Layer
	local thread = task.spawn(function()
		local finishedCommands = 0
		for _, command in pairs(objCommands) do
			task.spawn(function()
				if os.clock() - startTime < command.StartTime/1000 then
					repeat task.wait() until os.clock() - startTime >= command.StartTime/1000
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
						local startTrans = 1-(params[1] or 0)
						local endTrans = 1-(params[2] or 0)
						objectFrame.ImageTransparency = math.lerp(progress, startTrans, endTrans)
					end
				elseif commandType == "M" then
					funct = function()
						-- Move XY
						commandHaveRanOnce = true
						local elapsed = (os.clock() - startTime) - command.StartTime/1000
						local progress = easing(elapsed/commandDuration)
						local startPos = toUDim2(Vector2.new(params[1], params[2]))
						local endPos = toUDim2(Vector2.new(params[3], params[4]))
						objectFrame.Position = startPos:Lerp(endPos, progress)
					end
				elseif commandType == "MX" then
					-- Move X
					local elapsed = (os.clock() - startTime) - command.StartTime/1000
					local progress = easing(elapsed/commandDuration)
					local startX = toUDim2FromX(params[1] or 0, objectFrame.Position)
					local endX = toUDim2FromX(params[2] or 0, objectFrame.Position)
					objectFrame.Position = startX:Lerp(endX, progress)
				elseif commandType == "MY" then
					-- Move Y
					local elapsed = (os.clock() - startTime) - command.StartTime/1000
					local progress = easing(elapsed/commandDuration)
					local startY = toUDim2FromY(params[1] or 0, objectFrame.Position)
					local endY = toUDim2FromY(params[2] or 0, objectFrame.Position)
					objectFrame.Position = startY:Lerp(endY, progress)
				elseif commandType == "S" then
					local elapsed = (os.clock() - startTime) - command.StartTime/1000
					local progress = easing(elapsed/commandDuration)
					local startScale = params[1] or 0
					local endScale = params[2] or 0					
					local startUDim2 = UDim2.fromScale(objectSize.X.Scale * startScale, objectSize.Y.Scale * startScale)
					local endUDim2 = UDim2.fromScale(objectSize.X.Scale * endScale, objectSize.Y.Scale * endScale)
					
					objectFrame.Size = startUDim2:Lerp(endUDim2, progress)
				end
				
				if funct then
					callbacks[unquieId] = funct

					commandsCount += 1
					repeat task.wait(0.1) until (os.clock() - startTime > command.EndTime/1000 and commandHaveRanOnce) or not funct
					commandsCount -= 1

					callbacks[unquieId] = nil
				end
				
				finishedCommands += 1
			end)
		end
		
		while finishedCommands <= #objCommands do
			task.wait(1)
		end
		
		objectFrame:Destroy()
		completedCount += 1
		
		print(`The object {i} is completed`)
	end)
	
	script.Parent.Parent.SpriteIndex.Text = `Current sprite: {i}/{spritesCount} ({completedCount} completed)`
end
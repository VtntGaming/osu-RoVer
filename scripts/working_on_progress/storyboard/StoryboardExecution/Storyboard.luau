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
	FPS = 0,
	LastCommandTime = 0,
	LastUITime = 0,
	ActiveCommands = {},
	UIActiveCommands = {},
	ComputeTime = {},
	ComputeTime_UI = {},
	ObjsNotInUse = {}
}

local unused_objs = {}
-- We need to analyse the device's speed rate to determine the Process rate
for i = 1, 120 do task.wait() end
local LOAD_TEST_RATE = 1000000
local RATE_PER_COMMANDS = 300000	-- The requirement rate per command for a minimum 45fps 
local test_s = os.clock()
for i = 1,LOAD_TEST_RATE do end
local load_t = os.clock() - test_s
local commandSpeed = LOAD_TEST_RATE / load_t
local CORE_COUNT = 4
local currentCoreIndex = 1
local CalculatedRateLimit = math.max(50, math.ceil(commandSpeed/RATE_PER_COMMANDS))
CalculatedRateLimit = math.max(5, math.ceil(CalculatedRateLimit/CORE_COUNT))


local PROCESS_PER_FRAME = CalculatedRateLimit	-- To prevent significant, when processed more than the limit, it will defer to the next frame
local UI_PROCESS_PER_FRAME = math.ceil(CalculatedRateLimit * 0.75)	-- UI update also use a lot of rss, so it might need yield more

local currentProcessCores = {}

local function addProcessCore()
	local new = script.ProcessCore:Clone()
	new.Parent = script.Parent.Parent.ActiveActors
	new.ProcessCore.Enabled = true
	currentProcessCores[#currentProcessCores+1] = new
end

for i = 1, CORE_COUNT do
	addProcessCore()
end

for i = 1, 60 do
	task.wait()
end

for i, core in pairs(currentProcessCores) do
	core:SendMessage("SetProcessPerFrame", PROCESS_PER_FRAME, UI_PROCESS_PER_FRAME)
	core:SendMessage("SetStartTime", startTime)
	core:SendMessage("SetCoreIndex", i)
end

script.Parent:BindToMessage("UpdateStats", function(index:number, statType:number, value:number)
	Stats[statType][index] = value
end)


print(`The speed of the device is {commandSpeed}, using {CORE_COUNT} Actors. The calculated base rate limit is {PROCESS_PER_FRAME} (UI is {UI_PROCESS_PER_FRAME})`)

game:GetService("RunService").RenderStepped:Connect(function()
	Stats.FPS += 1
	task.wait(1)
	Stats.FPS -= 1
end)

task.spawn(function()
	while task.wait(0.1) do
		script.Parent.Parent.Parent.Core.Stats.ComputeTime.Text = string.format("Compute time: [Cmd: %.2fms | UI: %.2fms]", Stats.LastCommandTime*1000, Stats.LastUITime*1000)
		script.Parent.Parent.Parent.Core.Stats.FPS.Text = `FPS: {Stats.FPS}`
		script.Parent.Parent.Parent.Core.Stats.UnuseObject.Text = `Objs not in use: {#unused_objs}`
		local outCmd = "Active commands: "
		for i, data in pairs(Stats.ActiveCommands) do
			outCmd..= `[{i}]: {data}`
			if i ~= CORE_COUNT then
				outCmd..= " | "
			end
		end
		script.Parent.Parent.Parent.Core.Stats.ActiveCommands.Text = outCmd
		
		local count_ui = 0
		for i, data in pairs(Stats.UIActiveCommands) do
			count_ui += data
		end
		script.Parent.Parent.Parent.Core.Stats.ActiveUICommands.Text = `UI Process: {count_ui}`
		----
		local outCompute = "Compute time: [Cmd: "
		for i, data in pairs(Stats.ComputeTime) do
			outCompute..= `[{i}]: {string.format("%.2fms", data*1000)}`
			if i ~= CORE_COUNT then
				outCompute..= " | "
			end
		end

		local compute_ui = 0
		for i, data in pairs(Stats.ComputeTime_UI) do
			compute_ui += data*1000
		end
		script.Parent.Parent.Parent.Core.Stats.ComputeTime.Text = outCompute..` | UI : {string.format("%.2fms", compute_ui)}]`
		
		local out_unused = "Unused objects: "
		for i, data in pairs(Stats.ObjsNotInUse) do
			out_unused..= `[{i}]: {data}`
			if i ~= CORE_COUNT then
				out_unused..= " | "
			end
		end
		
		script.Parent.Parent.Parent.Core.Stats.UnuseObject.Text = out_unused
	end
end)

function toUDim2(v:Vector2):UDim2
	return UDim2.fromScale(v.X/640, v.Y/480)
end

function toUDim2FromX(x:number, u:UDim2)
	return UDim2.fromScale(x, u.Y.Scale)
end

function toUDim2FromY(y:number, u:UDim2)
	return UDim2.fromScale(u.X.Scale, y)
end

script.Parent:BindToMessage("SetTime", function(t:number)
	startTime = os.clock() - t
	script.Parent.Parent.Parent.Sound.TimePosition = t
	for _, core in pairs(currentProcessCores) do
		core:SendMessage("SetStartTime", startTime)
	end
end)
local SUPPORTED_CMD = {
	"F", "M", "MX", "MY", "S", "V", "C", "R"
}

for i, spriteData in pairs(storyboardData) do
	local objData = spriteData.Data
	local objCommands = spriteData.Commands
	local lastCommandTime = 0
	currentCoreIndex += 1
	if currentCoreIndex > CORE_COUNT then
		currentCoreIndex = 1
	end
	local currentActor = currentProcessCores[currentCoreIndex]::Actor
	local objUnquieId = HttpService:GenerateGUID()
	for _, cmd in pairs(objCommands) do
		if cmd.EndTime > lastCommandTime then
			lastCommandTime = cmd.EndTime
		end
	end
	if os.clock() - startTime > lastCommandTime/1000 then
		-- No need to render this sprite
		continue
	end
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
	local parentDestination = LayoutPlacement[objData.Layer]
	
	local extraData = {
		ImageSize = _imgSize,
		Image = _imgId,
		Size = objectSize
	}
	
	currentActor:SendMessage("AddObject", objUnquieId, objData, extraData)

	task.spawn(function()
		local currentActiveCommand = 0
		local finishedCommands = 0
		for _, command in pairs(objCommands) do
			if not command. StartTime then
				finishedCommands += 1
				continue
			end
			local commandType = command.CommandType
			local commandDuration = (command.EndTime - command.StartTime)/1000
			local params = command.Params
			local commandHaveRanOnce = false
			if not table.find(SUPPORTED_CMD, commandType) and commandType ~= "P" then
				continue
			end
			currentActiveCommand += 1
			task.spawn(function()
				if os.clock() - startTime < command.StartTime/1000 then
					repeat task.wait() until os.clock() - startTime >= command.StartTime/1000
				end

				if table.find(SUPPORTED_CMD, commandType) then
					local commandUnquieId = HttpService:GenerateGUID()
					currentActor:SendMessage("AddCommand", objUnquieId, commandUnquieId, command)

					commandsCount += 1
					repeat task.wait() until (os.clock() - startTime > command.EndTime/1000)
					commandsCount -= 1
					currentActor:SendMessage("RemoveCommand", commandUnquieId)
				elseif commandType == "P" then
					-- Parmeter commands
					-- This is a special command, unlike other commands, this only need to ran twice (start and end)
					local parmeter = params[1]
					currentActor:SendMessage("ToggleParmeterCommand", "P", parmeter, true)
					repeat task.wait() until (os.clock() - startTime > command.EndTime/1000)
					currentActor:SendMessage("ToggleParmeterCommand", "P", parmeter, false)
				end				

				finishedCommands += 1
			end)
		end

		while finishedCommands < currentActiveCommand do
			task.wait(1)
		end
		currentActor:SendMessage("RemoveObject", objUnquieId)
		completedCount += 1
	end)

	script.Parent.Parent.Parent.Core.Stats.SpriteIndex.Text = `Current sprite: {i}/{spritesCount} ({completedCount} completed)`
end
local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")
local workspace = game:GetService("Workspace")
local StoryboardConverter = require(workspace.StoryboardConverter)
-- local PathListConverter = require(workspace.StoryboardConverter.PathGenerator)

local s = os.clock()
local storyboardFile = script.Parent.Parent.Parent.StoryboardMap.Value
local difficultyFile = script.Parent.Parent.Parent.DifficultyMap.Value
local storyboardData = StoryboardConverter(storyboardFile, difficultyFile)
print("Load completed, took", os.clock()-s)
type SpriteObject = StoryboardConverter.spriteObject
local DEFAULT_ASSET_SIZE = Vector2.new(32,32)

--local pathList = PathListConverter(storyboardData)
--print(pathList)

type ImageListType = {
	[string]: {

	}
}

local ImageList = {} :: ImageListType
local currentSpeed = 1

local storyBoardImgList = storyboardFile:FindFirstChild("ImageList")::ModuleScript
if storyBoardImgList then
	ImageList = require(storyBoardImgList) :: ImageListType
end

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
	if not sprite1 or not sprite1.StartTime then
		return false
	elseif not sprite2 or not sprite2.StartTime then
		return true
	end
	return sprite1.StartTime < sprite2.StartTime
end)

print("Sort completed! took", os.clock()-s)

-- Analytic

local stackLoads = {}

for _, item in pairs(storyboardData) do
	local minIndex = 9999
	local maxIndex = 0
	for _, cmd in pairs(item.Commands) do
		local sTime = cmd.StartTime
		local eTime = cmd.EndTime

		local startIndex = sTime // 100 + 1
		local endIndex = eTime // 100 + 1

		minIndex = math.min(startIndex, minIndex)
		maxIndex = math.max(endIndex, maxIndex)

		for i = startIndex, endIndex do
			if not stackLoads[i] then
				stackLoads[i] = 1
			else
				stackLoads[i] += 1
			end
		end
	end

	-- Add another for UI, UI process more than a normal command
	for i = minIndex, maxIndex do
		if not stackLoads[i] then
			stackLoads[i] = 5
		else
			stackLoads[i] += 5
		end
	end
end

table.sort(stackLoads, function(a,b)
	if not tonumber(a) then return false
	elseif not tonumber(b) then return true
	end
	return a > b
end)

local BASE_COMMAND_PROCESS = 1000	

local avgLoad = 0
local highestLoad = stackLoads[1]
local highestTimelineLoad = highestLoad * BASE_COMMAND_PROCESS
local timelineCount = 0

for _, load in pairs(stackLoads) do
	avgLoad += load
	timelineCount += 1
end

avgLoad /= math.max(1, timelineCount)
avgLoad *= BASE_COMMAND_PROCESS



-- Load all of the image before going into the game
local loadList = {}
for _, item in pairs(ImageList) do
	if item.ImageId and not table.find(loadList,item.ImageId) then
		loadList[#loadList+1] = item.ImageId
	end
end

local objLoad = {}

for _, item in pairs(loadList) do
	local img = Instance.new("ImageLabel")
	img.Image = item
	objLoad[#objLoad+1] = img
end
local loadDisplay = script.Parent.Parent.Parent.LoadingDisplay
loadDisplay.Visible = true

for i = 1, 5 do
	local count = 0
	ContentProvider:PreloadAsync(objLoad, function(id, status)
		count += 1
		local progressValue = count/#objLoad * 0.2 + (i - 1) * 0.2
		script.Parent.Parent.Parent.LoadProgress.Value = progressValue
		if i == 1 then
			loadDisplay.Text = `Loading asset: {count}/{#objLoad}`
		else
			local progress = (i-1) * 0.2 + (count/#objLoad)*0.2
			loadDisplay.Text = `Preparing: {string.format("%.0f%%", progress * 100)}`
		end
	end)
end

loadDisplay.Visible = false

print("All preview image loaded")

local startTime = os.clock() + 3
local spritesCount = #storyboardData
local commandsCount = 0
local completedCount = 0
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

local highestLoadTime = highestTimelineLoad/commandSpeed
local avgLoadTime = avgLoad/commandSpeed
warn(`The storyboard might have an avg load of {string.format("%.2fms",avgLoadTime*1000)} and a highest load of {string.format("%.2fms",highestLoadTime*1000)}`)
warn(`Which might drop the FPS down to {string.format("%.1ffps", 1/avgLoadTime)}, max to {string.format("%.1ffps", 1/highestLoadTime)}`)

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

local mainUI = script.Parent.Parent.Parent
mainUI.StoryboardLoaded.Value = true
if not mainUI.GameReady.Value then
	repeat task.wait() until mainUI.GameReady.Value
end

local deferEnabled = script.Parent.Parent.Parent.Core.ObjectsDeferEnabled.DeferEnabled

for i, core in pairs(currentProcessCores) do
	core:SendMessage("SetProcessPerFrame", deferEnabled.Value and PROCESS_PER_FRAME or 99999999, deferEnabled.Value and UI_PROCESS_PER_FRAME or 99999999)
	core:SendMessage("SetStartTime", startTime)
	core:SendMessage("SetCoreIndex", i)
end


deferEnabled.Changed:Connect(function()
	for i, core in pairs(currentProcessCores) do
		core:SendMessage("SetProcessPerFrame", deferEnabled.Value and PROCESS_PER_FRAME or 99999999, deferEnabled.Value and UI_PROCESS_PER_FRAME or 99999999)
	end
end)

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

-- function toUDim2FromX(x:number, u:UDim2)
-- 	return UDim2.fromScale(x, u.Y.Scale)
-- end

-- function toUDim2FromY(y:number, u:UDim2)
-- 	return UDim2.fromScale(u.X.Scale, y)
-- end

script.Parent:BindToMessage("Restart", function()
	local oldUI = script.Parent.Parent.Parent
	local newUI = game.StarterGui.StoryboardUI:Clone()
	newUI.Parent = game.Players.LocalPlayer.PlayerGui
	oldUI:Destroy()
end)

script.Parent:BindToMessage("SetTime", function(t:number)
	startTime = os.clock() - t
	script.Parent.Parent.Parent.Sound.TimePosition = t
	for _, core in pairs(currentProcessCores) do
		core:SendMessage("SetStartTime", startTime)
	end
end)

script.Parent:BindToMessage("SetSpeed", function(speed:number)
	currentSpeed = speed
	for _, core in pairs(currentProcessCores) do
		core:SendMessage("SetSpeed", speed)
	end
end)
local SUPPORTED_CMD = {
	"F", "M", "MX", "MY", "S", "V", "C", "R"
}

-- Start the song
--task.spawn(function()
--	repeat task.wait() until (os.clock() - startTime) * currentSpeed >= 0
--	script.Parent.Parent.Parent.Sound.TimePosition = (os.clock() - startTime) * currentSpeed
--	script.Parent.Parent.Parent.Sound:Play()
--end)

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
	if (os.clock() - startTime) * currentSpeed > (lastCommandTime/1000 + 1) then
		-- No need to render this sprite
		continue
	end
	local firstCmd = objCommands[1]
	if not firstCmd then
		break
	end

	local objStartTime = firstCmd.StartTime/1000
	if (os.clock() - startTime) * currentSpeed < objStartTime then
		repeat task.wait() until (os.clock() - startTime) * currentSpeed >= objStartTime
	end
	local _imgSize = ImageList[objData.Filepath] and ImageList[objData.Filepath].Size
	local _imgId = ImageList[objData.Filepath] and ImageList[objData.Filepath].ImageId
	local objectSize =  toUDim2(_imgSize or DEFAULT_ASSET_SIZE)
	-- local parentDestination = LayoutPlacement[objData.Layer]

	local imageIdList = {}
	local animData = {}
	if spriteData.Type == "Animation" then
		local animData_local = objData::StoryboardConverter.AnimationData
		local raw = animData_local.Filepath:split(".")
		local p = ""
		for i = 1, #raw-1 do
			p = p..raw[i]
		end
		local ex = raw[#raw]
		for i = 0, animData_local.FrameCount-1 do
			local path = `{p}{i}.{ex}`
			local id = ImageList[path] and ImageList[path].ImageId
			imageIdList[i+1] = id
			if i == 0 then
				_imgSize = ImageList[path] and ImageList[path].Size
			end
		end
	end

	local extraData = {
		ImageSize = _imgSize,
		Image = _imgId,
		Size = objectSize,
		ImageIdList = imageIdList,
		AnimData = animData,
		Type = spriteData.Type,
		StartTime = firstCmd.StartTime
	}

	currentActor:SendMessage("AddObject", objUnquieId, objData, extraData)

	task.spawn(function()
		local currentActiveCommand = 0
		local finishedCommands = 0
		for _, command in pairs(objCommands) do
			if not command.StartTime then
				finishedCommands += 1
				print("Where is the start time?")
				continue
			end
			local commandType = command.CommandType
			local params = command.Params
			if not table.find(SUPPORTED_CMD, commandType) and commandType ~= "P" then
				print("Command not supported!", commandType)
				continue
			end
			currentActiveCommand += 1
			if (os.clock() - startTime) * currentSpeed < command.StartTime/1000 then
				repeat task.wait() until (os.clock() - startTime) * currentSpeed >= command.StartTime/1000
			end
			task.spawn(function()
				if table.find(SUPPORTED_CMD, commandType) then
					local commandUnquieId = HttpService:GenerateGUID()
					currentActor:SendMessage("AddCommand", objUnquieId, commandUnquieId, command)

					if command.StartTime ~= command.EndTime then
						commandsCount += 1
						repeat task.wait() until ((os.clock() - startTime) * currentSpeed > command.EndTime/1000)
						commandsCount -= 1
						currentActor:SendMessage("RemoveCommand", commandUnquieId)
					end
				elseif commandType == "P" then
					-- Parmeter commands
					-- This is a special command, unlike other commands, this only need to ran twice (start and end)
					local parmeter = params[1]
					currentActor:SendMessage("ToggleParmeterCommand", objUnquieId, "P", parmeter, true)
					repeat task.wait() until ((os.clock() - startTime) * currentSpeed > command.EndTime/1000)
					if not command.StaysForever then
						currentActor:SendMessage("ToggleParmeterCommand", objUnquieId, "P", parmeter, false)
					end
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
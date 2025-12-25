local COMMAND_DECLARE_CHARACTER = {
	"_", " "
}

--[[
0	Linear: no easing
1	Easing Out: the changes happen fast at first, but then slow down toward the end
2	Easing In: the changes happen slowly at first, but then speed up toward the end
3	Quad In
4	Quad Out
5	Quad In/Out
6	Cubic In
7	Cubic Out
8	Cubic In/Out
9	Quart In
10	Quart Out
11	Quart In/Out
12	Quint In
13	Quint Out
14	Quint In/Out
15	Sine In
16	Sine Out
17	Sine In/Out
18	Expo In
19	Expo Out
20	Expo In/Out
21	Circ In
22	Circ Out
23	Circ In/Out
24	Elastic In
25	Elastic Out
26	ElasticHalf Out
27	ElasticQuarter Out
28	Elastic In/Out
29	Back In
30	Back Out
31	Back In/Out
32	Bounce In
33	Bounce Out
34	Bounce In/Out
]]

local ANCHOR_POINT_ORIGIN = {
	TopLeft = Vector2.new(0, 0),
	Centre = Vector2.new(0.5, 0.5),
	CentreLeft = Vector2.new(0, 0.5),
	TopRight = Vector2.new(1, 0),
	BottomCentre = Vector2.new(0.5, 1),
	TopCentre = Vector2.new(0.5, 0),
	Custom = Vector2.new(0, 0),	-- same as top left
	CentreRight = Vector2.new(1, 0.5),
	BottomLeft = Vector2.new(0, 1),
	BottomRight = Vector2.new(1, 1)
}

local LAYER_VALUE = {
	Background = 0,
	Fail = 1,
	Pass = 2,
	Foreground = 3
}

export type CommandData = {
	CommandType:string,
	Easing:number,
	StartTime:number,
	EndTime:number,
	Params:{number|string},
	InsideALoop: boolean
}

export type LoopCommand = CommandData & {
	LoopCount: number
}

export type ParmeterCommand = CommandData & {
	StaysForever: boolean?
}

export type SpriteData = {
	InitValue: {
		PosX:number?,
		PosY:number?,
		ScaleX:number?,
		ScaleY:number?,
		Opacity:number?,
	},
	Layer:number,
	AnchorPoint:Vector2,
	Filepath:string,
	Position:Vector2,
	LayoutOrder:number
}

export type AnimationData = SpriteData & {
	FrameCount: number,
	FrameDelay: number,
	IsForever: boolean
}

export type spriteObject = {
	Type: string,
	StartTime: number,
	EndTime: number,
	ContainsLoop: boolean,
	localLoop: boolean,
	Data: SpriteData | AnimationData,
	Commands:{CommandData}
}

local function deepCopy(t:{any}):{any}
	local newT = {}
	for key, value in pairs(t) do
		if typeof(value) == "table" then
			newT[key] = deepCopy(value)
		else
			newT[key] = value
		end
	end
	
	return newT
end

local function newSprite():spriteObject
	local spriteObj:spriteObject = {
		Type = "",
		Data = {
			Layer = 0,
			AnchorPoint = ANCHOR_POINT_ORIGIN.TopLeft,
			Filepath = "",
			Position = Vector2.zero,
			LayoutOrder = 0,
			InitValue = {}
		},
		localLoop = false,
		ContainsLoop = false,
		StartTime = 0,
		EndTime = 0,
		Commands = {},
	}
	
	return spriteObj
end

return function(file:ModuleScript, difficultyFile:ModuleScript?)
	local fileData = require(file)::string
	local sprites = {}::{spriteObject}
	local currentSprite:spriteObject? = nil
	local crrOrder = 0
	local crrOrder_diff = 0
	
	for i, lineData in pairs(fileData:split("\n")) do
		local firstChar = lineData:sub(1,1)
		if table.find(COMMAND_DECLARE_CHARACTER, firstChar) then
			if currentSprite then
				local rawData = lineData:split()
				local startTime = tonumber(rawData[3]) or 0
				local secChar = lineData:sub(2,2)
				if not table.find(COMMAND_DECLARE_CHARACTER, secChar) then
					currentSprite.localLoop = false
				end

				local endTime = tonumber(rawData[4]) or startTime
				local commandType = rawData[1]:sub(2,-1)
				if currentSprite.localLoop then
					commandType = rawData[1]:sub(3,-1)
				end
				local newcmdData:CommandData = {
					CommandType = commandType,
					Easing = tonumber(rawData[2]) or 0,
					StartTime = startTime,
					EndTime = endTime,
					Params = {},
					InsideALoop = currentSprite.localLoop
				}
				
				if commandType == "L" then
					currentSprite.localLoop = true
					local loopCommand = newcmdData::LoopCommand
					loopCommand.Easing = 0
					loopCommand.StartTime = tonumber(rawData[2]) or 0
					loopCommand.LoopCount = tonumber(rawData[3]) or 0
					currentSprite.ContainsLoop = true
				elseif commandType == "T" then
					currentSprite.localLoop = true
					local loopCommand = newcmdData::LoopCommand
					loopCommand.Easing = 0
					loopCommand.StartTime = tonumber(rawData[2]) or 0
					loopCommand.LoopCount = 1
					currentSprite.ContainsLoop = true
				elseif commandType == "P" then
					if not tonumber(rawData[4]) then
						-- The command stays forever
						local parmeterCmd = newcmdData :: ParmeterCommand
						parmeterCmd.StaysForever = true
					end
				end
				for i = 5, #rawData do
					newcmdData.Params[#newcmdData.Params+1] = commandType == "P" and tostring(rawData[i]) or (tonumber(rawData[i]) or 0)
				end
				currentSprite.Commands[#currentSprite.Commands+1] = newcmdData
			end
		else
			-- it's a sprite or animation
			local rawData = lineData:split()
			local objType = rawData[1]
			if objType == "Sprite" or objType == "Animation" then
				local sprite = newSprite()::spriteObject
				sprite.Type = objType
				sprite.Data = {
					Layer = LAYER_VALUE[rawData[2]],
					AnchorPoint = ANCHOR_POINT_ORIGIN[rawData[3]],
					Filepath = rawData[4]:sub(2,-2),
					Position = Vector2.new(rawData[5], rawData[6]),
					LayoutOrder = crrOrder
				}
				
				if objType == "Animation" then
					local animationData = sprite.Data::AnimationData
					animationData.FrameCount = tonumber(rawData[7])
					animationData.FrameDelay = tonumber(rawData[8])
					animationData.IsForever = rawData[9] == "LoopForever"
					crrOrder += animationData.FrameCount
				end
				
				currentSprite = sprite
				sprites[#sprites+1] = sprite
				crrOrder += 1
			end
		end
	end
	
	if difficultyFile then
		local diffFileData = require(difficultyFile)::string
		local _, s = diffFileData:find("[[Events]")
		local e, _ = diffFileData:find("//Storyboard Sound Samples")
		diffFileData = diffFileData:sub(s,e)
		for i, lineData in pairs(diffFileData:split("\n")) do
			local firstChar = lineData:sub(1,1)
			if table.find(COMMAND_DECLARE_CHARACTER, firstChar) then
				if currentSprite then
					local rawData = lineData:split()
					local startTime = tonumber(rawData[3]) or 0
					local secChar = lineData:sub(2,2)
					if not table.find(COMMAND_DECLARE_CHARACTER, secChar) then
						currentSprite.localLoop = false
					end

					local endTime = tonumber(rawData[4]) or startTime
					local commandType = rawData[1]:sub(2,-1)
					if currentSprite.localLoop then
						commandType = rawData[1]:sub(3,-1)
					end
					local newcmdData:CommandData = {
						CommandType = commandType,
						Easing = tonumber(rawData[2]) or 0,
						StartTime = startTime,
						EndTime = endTime,
						Params = {},
						InsideALoop = currentSprite.localLoop
					}

					if commandType == "L" then
						currentSprite.localLoop = true
						local loopCommand = newcmdData::LoopCommand
						loopCommand.Easing = 0
						loopCommand.StartTime = tonumber(rawData[2]) or 0
						loopCommand.LoopCount = tonumber(rawData[3]) or 0
						currentSprite.ContainsLoop = true
					elseif commandType == "T" then
						currentSprite.localLoop = true
						local loopCommand = newcmdData::LoopCommand
						loopCommand.Easing = 0
						loopCommand.StartTime = tonumber(rawData[2]) or 0
						loopCommand.LoopCount = 1
						currentSprite.ContainsLoop = true
					end
					for i = 5, #rawData do
						newcmdData.Params[#newcmdData.Params+1] = commandType == "P" and tostring(rawData[i]) or (tonumber(rawData[i]) or 0)
					end
					currentSprite.Commands[#currentSprite.Commands+1] = newcmdData
				end
			else
				-- it's a sprite or animation
				local rawData = lineData:split()
				local objType = rawData[1]
				if objType == "Sprite" or objType == "Animation" then
					local sprite = newSprite()::spriteObject
					sprite.Type = objType
					sprite.Data = {
						Layer = LAYER_VALUE[rawData[2]],
						AnchorPoint = ANCHOR_POINT_ORIGIN[rawData[3]],
						Filepath = rawData[4]:sub(2,-2),
						Position = Vector2.new(rawData[5], rawData[6]),
						LayoutOrder = crrOrder
					}

					if objType == "Animation" then
						local animationData = sprite.Data::AnimationData
						animationData.FrameCount = tonumber(rawData[7])
						animationData.FrameDelay = tonumber(rawData[8])
						animationData.IsForever = rawData[9] == "LoopForever"
						crrOrder += animationData.FrameCount
					end

					currentSprite = sprite
					sprites[#sprites+1] = sprite
					crrOrder += 1
				end
			end
		end
	end
	-- Reprocess the loop commands
	for _, item in pairs(sprites) do
		if item.ContainsLoop then
			local loops = {}
			local remove_index = {}
			local currentLoop = nil
			
			for i, cmd in pairs(item.Commands) do
				if cmd.CommandType == "L" or cmd.CommandType == "T" then
					currentLoop = {
						LoopCount = cmd.LoopCount,
						StartTime = cmd.StartTime,
						Commands = {},
						LoopMaxDuration = 0
					}
					remove_index[#remove_index+1] = i
				else
					if cmd.InsideALoop then
						if currentLoop then
							currentLoop.Commands[#currentLoop.Commands + 1] = cmd
							currentLoop.LoopMaxDuration = math.max(currentLoop.LoopMaxDuration, cmd.EndTime)
						end
						remove_index[#remove_index+1] = i
					else
						if currentLoop then
							loops[#loops+1] = currentLoop
							currentLoop = nil
						end
					end
				end
			end
			
			if currentLoop then
				loops[#loops+1] = currentLoop
				currentLoop = nil
			end
			
			-- Remove these related loop out of the command
			
			for j = #remove_index, 1, -1 do
				local removeIndex = remove_index[j]
				table.remove(item.Commands, removeIndex)
			end
			
			-- Add the new format
			
			for _, loopData in pairs(loops) do
				local startTime = loopData.StartTime
				local loopDuration = loopData.LoopMaxDuration
				local loopCount = loopData.LoopCount
				
				for i = 0, loopCount - 1 do
					for _, cmd in pairs(loopData.Commands) do
						local newCmd = deepCopy(cmd)
						newCmd.StartTime = newCmd.StartTime + startTime + i * loopDuration
						newCmd.EndTime = newCmd.EndTime + startTime + i * loopDuration
						item.Commands[#item.Commands+1] = newCmd
					end
				end
			end
		end
	end	
	
	-- Reprocess all of the sprite
	for i, item in pairs(sprites) do
		local startTime = 999999999999
		local endTime = 0
		local initValue = {} :: {}
		for _, cmd in pairs(item.Commands) do
			startTime = math.min(startTime, cmd.StartTime)
			endTime = math.max(endTime, cmd.EndTime)
			if cmd.CommandType == "F" and not initValue.Opacity then
				local init = tonumber(cmd.Params[1])
				if init then
					initValue.Opacity = init
				end
			elseif cmd.CommandType == "MX" then
				local initX = tonumber(cmd.Params[1])
				if not initValue.PosX and initX then
					initValue.PosX = initX
				end
			elseif cmd.CommandType == "MY" then
				local initY = tonumber(cmd.Params[1])
				if not initValue.PosY and initY then
					initValue.PosY = initY
				end
			elseif cmd.CommandType == "M" then
				local initX = tonumber(cmd.Params[1])
				local initY = tonumber(cmd.Params[2])
				if not initValue.PosX and initX then
					initValue.PosX = initX
				end
				if not initValue.PosY and initY then
					initValue.PosY = initY
				end
			elseif cmd.CommandType == "S" then
				local init = tonumber(cmd.Params[1])
				if init then
					if not initValue.ScaleX then
						initValue.ScaleX = init
					end
					if not initValue.ScaleY then
						initValue.ScaleY = init
					end
				end				
			elseif cmd.CommandType == "V" then
				local initX = tonumber(cmd.Params[1])
				local initY = tonumber(cmd.Params[2])

				if not initValue.ScaleX and initX then
					initValue.ScaleX = initX
				end
				if not initValue.ScaleY and initY then
					initValue.ScaleY = initY
				end
			end
		end
		
		if startTime == 999999999999 then
			startTime = 0
		end
		
		table.sort(item.Commands, function(cmd1, cmd2)
			if cmd1.StartTime == cmd2.StartTime then
				return cmd1.EndTime < cmd2.EndTime
			end
			
			return cmd1.StartTime < cmd2.StartTime
		end)
		
		item.StartTime = startTime
		item.EndTime = endTime
		item.Data.InitValue = initValue
	end
	
	return sprites
end
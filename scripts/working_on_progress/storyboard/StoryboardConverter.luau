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
	Params:{number|string}
}

export type SpriteData = {
	Layer:number,
	AnchorPoint:Vector2,
	Filepath:string,
	Position:Vector2,
	LayoutOrder:number
}

export type spriteObject = {
	-- Currently support sprite only
	Data: SpriteData,
	Commands:{CommandData}
}

local function newSprite():spriteObject
	local spriteObj:spriteObject = {
		Data = {
			Layer = 0,
			AnchorPoint = ANCHOR_POINT_ORIGIN.TopLeft,
			Filepath = "",
			Position = Vector2.zero,
			LayoutOrder = 0
		},
		Commands = {}
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
				local commandType = rawData[1]:sub(2,-1)
				local newcmdData:CommandData = {
					CommandType = commandType,
					Easing = tonumber(rawData[2]) or 0,
					StartTime = tonumber(rawData[3]) or 0,
					EndTime = tonumber(rawData[4]) or 0,
					Params = {}
				}
				
				for i = 5, #rawData do
					newcmdData.Params[#newcmdData.Params+1] = commandType == "P" and tostring(rawData[i]) or (tonumber(rawData[i]) or 0)
				end
				currentSprite.Commands[#currentSprite.Commands+1] = newcmdData
			end
		else
			-- it's a sprite or animation
			local rawData = lineData:split()
			if rawData[1] == "Sprite" then
				local sprite = newSprite()::spriteObject
				sprite.Data = {
					Layer = LAYER_VALUE[rawData[2]],
					AnchorPoint = ANCHOR_POINT_ORIGIN[rawData[3]],
					Filepath = rawData[4]:sub(2,-2),
					Position = Vector2.new(rawData[5], rawData[6]),
					LayoutOrder = crrOrder
				}
				
				currentSprite = sprite
				sprites[#sprites+1] = sprite
				crrOrder -= 1
			end
		end
	end
	
	if difficultyFile then
		local diffFileData = require(difficultyFile)::string
		local _, s = diffFileData:find("[Events]")
		local e, _ = diffFileData:find("//Storyboard Sound Samples")
		diffFileData = diffFileData:sub(s,e)
		for i, lineData in pairs(diffFileData:split("\n")) do
			local firstChar = lineData:sub(1,1)
			if table.find(COMMAND_DECLARE_CHARACTER, firstChar) then
				if currentSprite then
					local rawData = lineData:split()
					local newcmdData:CommandData = {
						CommandType = rawData[1]:sub(2,-1),
						Easing = tonumber(rawData[2]) or 0,
						StartTime = tonumber(rawData[3]) or 0,
						EndTime = tonumber(rawData[4]) or 0,
						Params = {}
					}

					for i = 5, #rawData do
						newcmdData.Params[#newcmdData.Params+1] = tonumber(rawData[i]) or 0
					end
					currentSprite.Commands[#currentSprite.Commands+1] = newcmdData
				end
			else
				-- it's a sprite or animation
				local rawData = lineData:split()
				if rawData[1] == "Sprite" then
					local sprite = newSprite()::spriteObject
					local filePath = rawData[4]
					local match = string.match(filePath, '"(.-)"')
					if match then
						filePath = match
					end
					sprite.Data = {
						Layer = LAYER_VALUE[rawData[2]],
						AnchorPoint = ANCHOR_POINT_ORIGIN[rawData[3]],
						Filepath = filePath,
						Position = Vector2.new(rawData[5], rawData[6]),
						LayoutOrder = crrOrder_diff
					}

					currentSprite = sprite
					sprites[#sprites+1] = sprite
					crrOrder_diff -= 1
				end
			end
		end
	end
	
	return sprites
end
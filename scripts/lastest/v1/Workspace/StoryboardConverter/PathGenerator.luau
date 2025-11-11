type CommandData = {
	CommandType:string,
	Easing:number,
	StartTime:number,
	EndTime:number,
	Params:{number|string}
}

type SpriteData = {
	Layer:number,
	AnchorPoint:Vector2,
	Filepath:string,
	Position:Vector2,
	LayoutOrder:number
}

type AnimationData = SpriteData & {
	FrameCount: number,
	FrameDelay: number,
	IsForever: boolean
}

type spriteObject = {
	Type: string,
	Data: SpriteData | AnimationData,
	Commands:{CommandData}
}

local TEMPLATE = {
	HEAD = "export type ImageData = {\n\tImageId: string?,\n\tSize: Vector2?\n}\n",
	LIST = [[local list:{[string]:ImageData} = {]],
	ITEM = `\n\t["%s"] = `.."{\n\t\tImageId = %s,\n\t\tSize = %s\n\t},",
	END = "\n}\nreturn list"
}

return function(sprites:{spriteObject}, existingFile)
	local existingData = {}
	local pathList = {}::{string}
	
	if existingFile then
		existingData = require(existingFile)
	end
	
	for _, obj in pairs(sprites) do
		local pathName = obj.Data.Filepath
		if obj.Type == "Sprite" then
			if not table.find(pathList, pathName) then
				pathList[#pathList+1] = pathName
			end
		elseif obj.Type == "Animation" then
			local animData = obj.Data::AnimationData
			local raw = pathName:split(".")
			local p = ""
			for i = 1, #raw-1 do
				p = p..raw[i]
			end
			local ex = raw[#raw]
			
			for i = 0, animData.FrameCount-1 do
				local path = `{p}{i}.{ex}`
				if not table.find(pathList, path) then
					pathList[#pathList+1] = path
				end
			end
		end
	end
	
	table.sort(pathList, function(p1, p2)
		return p1 < p2
	end)
	
	local output = TEMPLATE.HEAD..TEMPLATE.LIST
	
	for _, item in pairs(pathList) do
		local imgId = "nil"
		local size = "nil"
		local data = existingData[item]
		item = item:gsub("\\", "\\\\")
		if data then
			if data.ImageId then
				imgId = `"{data.ImageId}"`			
			end
			if data.Size then
				size = `Vector2.new({tostring(data.Size)})`
			end
		end
		output..= TEMPLATE.ITEM:format(item, imgId, size)
	end
	output..= TEMPLATE.END
	return output
end


--[[
How to use:

local storyboardFile = <storyboard file>
local beatmapFile = <beatmap file>
local imgList = nil
local data = require(workspace.StoryboardConverter)(storyboardFile,beatmapFile)
local output = require(workspace.StoryboardConverter.PathGenerator)(data, imgList)

local outputScript = Instance.new("ModuleScript")
outputScript.Name = "ImageList"
outputScript.Source = output
outputScript.Parent = workspace
]]
type CommandData = {
	CommandType:string,
	Easing:number,
	StartTime:number,
	EndTime:number,
	Params:{number}
}

type SpriteData = {
	Layer:number,
	AnchorPoint:Vector2,
	Filepath:string,
	Position:Vector2
}

type spriteObject = {
	-- Currently support sprite only
	Data: SpriteData,
	Commands:{CommandData}
}

local TEMPLATE = {
	HEAD = "export type ImageData = {\n\tImageId: string?,\n\tSize: Vector2?\n}\n",
	LIST = [[local list:{[string]:ImageData} = {]],
	ITEM = `\n\t["%s"] = `.."{\n\t\tImageId = nil,\n\t\tSize = nil\n\t},",
	END = "\n}\nreturn list"
}

return function(sprites:{spriteObject})
	local pathList = {}::{string}
	
	for _, obj in pairs(sprites) do
		local pathName = obj.Data.Filepath
		if not table.find(pathList, pathName) then
			pathList[#pathList+1] = pathName
		end
	end
	
	local output = TEMPLATE.HEAD..TEMPLATE.LIST
	
	for _, item in pairs(pathList) do
		output..= TEMPLATE.ITEM:format(item)
	end
	output..= TEMPLATE.END
	return output
end
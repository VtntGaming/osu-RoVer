local COMMAND_DECLARE_CHARACTER = {
	"_", " "
}

type CommandData = {
	
}
type SpriteData = {
	Layer:number,
	Origin:Vector2,
	Filepath:string,
	
}

type spriteObject = {
	Data: {},
	Commands:{}
}

return function(file:ModuleScript)
	local fileData = require(file)::string
	local sprites = {}::{spriteObject}
	for _, lineData in pairs(fileData:split("\n")) do
		local firstChar = lineData:sub(1,1)
		if table.find(COMMAND_DECLARE_CHARACTER, firstChar) then
			
		end
	end
end
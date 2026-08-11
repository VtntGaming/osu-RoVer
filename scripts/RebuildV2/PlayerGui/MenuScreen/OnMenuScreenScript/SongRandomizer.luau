local Randomizer = {}
Randomizer.IsSettedUp = false

type MapList = {ModuleScript}

local Dictionaries = {} :: {[string]: MapList}
local List = {} :: {MapList}

local function GetValue(Data: string, Pattern: string, Space: number)
	if not Space then
		Space = 1
	end

	local _,s = string.find(Data,Pattern)
	if not s then return end

	local e,_ = string.find(Data,"\n",s)
	if not e then e = #Data end

	return string.sub(Data,s+1+Space,e-1)
end

function Randomizer:Setup(mapList: {Instance})
	if Randomizer.IsSettedUp then
		return
	end
	
	for _, map in ipairs(mapList) do
		if map:IsA("ModuleScript") then
			local data = require(map)
			
			local mapsetID = GetValue(data, "BeatmapSetID:", 0)
			
			local setData = Dictionaries[mapsetID]
			
			if not setData then
				local newSet = {}
				List[#List+1] = newSet
				setData = newSet
			end
			
			setData[#setData+1] = map
		end
	end
	
	Randomizer.IsSettedUp = true
end

-- Every song will have an equal chance to be picked
function Randomizer:PickMap(): ModuleScript?
	local listOfMaps = List[math.random(1, #List)]
	
	local choosenMap = listOfMaps[math.random(1, #listOfMaps)]
	
	return choosenMap
end

return Randomizer
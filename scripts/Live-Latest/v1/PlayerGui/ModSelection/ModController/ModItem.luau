--!strict
local ModConfiguration = require(script.Parent.ModConfiguration)

export type ModItem = {
    __index: ModItem,
    new: (modId: string) -> ModItem,
}

local ModItem: ModItem = {} :: ModItem
ModItem.__index = ModItem

function ModItem.new(modId)
    local item = setmetatable({} :: any, ModItem)

    return item
end

return ModItem
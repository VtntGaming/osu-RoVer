--!strict
local Utils = {}

type AnyTable = {[any]: any}

function Utils.OverrideSelf(t1: AnyTable, t2: AnyTable): AnyTable
    -- Merge methods from t2 into t1
    -- It works like metatable but the table will store the data
    -- Give away some memory to reduce load time
    for k, v in pairs(t2) do
        t1[k] = v
    end
    return t1
end

return Utils
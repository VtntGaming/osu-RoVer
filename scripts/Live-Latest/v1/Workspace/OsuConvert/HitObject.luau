local Manager = {}

export type RawObject = string

export type HitObject = {
    ExtraData: {string}
}

function Manager.Process(listing: {{Time: number, Data: RawObject}}): {HitObject}
    local objectList = {}
    
    for objectID = 1, #listing do
        local object = {
            ExtraData = {}
        }
        local objData = listing[objectID]
        local stringData = objData.Data
        

    end

    return objectList
end

return Manager
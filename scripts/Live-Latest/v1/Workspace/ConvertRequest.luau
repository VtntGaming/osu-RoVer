--!strict
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Cached: {[string]: any} = {}

if not RunService:IsClient() then
	warn("This module is supposed to run on the client!")
	return
end

local Remote = game.ReplicatedStorage.RequestBeatmap

local ConvertRequest = {}
local RequestAwait = {}

function ConvertRequest.Setup()
	Remote.OnClientEvent:Connect(function(requestId, data)
		local thread = RequestAwait[requestId]
		if thread then
			task.spawn(thread, data)
		else
			warn("Thread not found for request: ", requestId)
		end
	end)
end

function ConvertRequest.Request(prop, ...)
	local query = {...}
	local requestOptions
	if type(prop) == "table" and prop.__RequestOptions then
		requestOptions = prop
	else
		table.insert(query, 1, prop)
	end
	
	local map = table.remove(query, 2) :: Instance
	local mapName = map.Name
	local k = mapName..HttpService:JSONEncode(query)..HttpService:JSONEncode(requestOptions)
	if Cached[k] then
		return table.unpack(Cached[k])
	end
	
	local requestId = HttpService:GenerateGUID()
	
	local thread = coroutine.running()
	
	RequestAwait[requestId] = thread
	
	-- Processing on the server
	Remote:FireServer(requestId, mapName, query, requestOptions)	
	
	local result = coroutine.yield()
	
	-- Cleanup
	RequestAwait[requestId] = nil
	
	-- Saving so they won't have to doing it again
	Cached[k] = result

	return table.unpack(result)	
end

return ConvertRequest
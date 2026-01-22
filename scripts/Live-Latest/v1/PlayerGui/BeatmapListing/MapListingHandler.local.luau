local connection:RBXScriptConnection
local crrBeatmapValue = script.Parent.Parent.Parent.Parent.CurrentBeatmap


crrBeatmapValue.Changed:Connect(function(obj)
	if connection then
		connection:Disconnect()
	end
	
	connection = obj.Destroying:Once(function()
		local objName = obj.Name
		
		local beatmapFolder = workspace:WaitForChild("Beatmaps")
		local backupObject = beatmapFolder:WaitForChild(objName, 5)
		if not backupObject then
			-- we get a random map instead
			local mapList = beatmapFolder:GetChildren()
			if #mapList > 0 then
				backupObject = mapList[math.random(1, #mapList)]
			end
		end
		
		crrBeatmapValue.Value = backupObject
	end)
end)

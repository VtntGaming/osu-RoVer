--[LOCATION]:[Workspace.ObjectImport]
return function(Data,Target)
	local VirtualData = {}
	VirtualData[0] = Target
	local RawData = {}
	local Current = 1
	local isLast = false
	
	while string.find(Data,"\n",Current) and not isLast do
		local _,e = string.find(Data,"\n",Current)
		if not e then
			e = #Data+1
			isLast = true
		end
		RawData[#RawData+1] = string.sub(Data,Current,e-1)
		Current = e+1
	end
	
	for i,ObjData in pairs(RawData) do
		local raw = {}
		local crr = 1
		for a = 1,4 do
			local e = #ObjData+1
			if a ~= 4 then
				_,e = string.find(ObjData,"-",crr)
			end
			
			raw[a] = string.sub(ObjData,crr,e-1)

			crr = e+1
		end
		
		local id = tonumber(raw[1])
		local P_id = tonumber(raw[2])
		local c_name = raw[3]
		local name = raw[4]
		
		
		local newObj
		
		local s,_ = pcall(function()
			newObj = Instance.new(c_name,VirtualData[P_id])
		end)
		
		if not s then
			newObj = Instance.new("Folder",VirtualData[P_id])
		end
		
		newObj.Name = name
		
		VirtualData[id] = newObj
	end
end
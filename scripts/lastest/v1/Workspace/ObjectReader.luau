return function(Obj)
	local List = ""
	local ID = 0
	
	local function ReadObj(TargetObj,ParentID)
		pcall(function()
			ID += 1
			local Classname = TargetObj.ClassName
			local Name = TargetObj.Name
			local CurrentID = ID

			List = List..CurrentID.."-"..ParentID.."-"..Classname.."-"..Name.."\n"

			for _,a in pairs(TargetObj:GetChildren()) do
				ReadObj(a,CurrentID)
			end
		end)
	end
	
	ReadObj(Obj,0)
	
	return List
end
--[LOCATION]:[Workspace.SkinModule]
for _,object in pairs(script:GetDescendants()) do
	if object:IsA("Script") or object:IsA("LocalScript") then
		object:Destroy()
	end
end

return script.Skin
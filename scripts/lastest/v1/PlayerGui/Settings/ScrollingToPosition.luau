--[LOCATION]:[StarterGui.Settings.SettingFrame.BaseFrame.Options.ScrollingToPosition]
local TweenService = game:GetService("TweenService")
local ScrollFrame = script.Parent.Parent.MainLayer.MainSettings

function bind(obj)
	local FrameLocation = ScrollFrame.Base:FindFirstChild(obj.Name)
	if not FrameLocation then
		warn(string.format("Object %s was not found in the settings", obj.Name))
		return
	end
	local linked
	if FrameLocation:FindFirstChild("Linked") then
		linked = FrameLocation.Linked.Value
	end
	
	obj.Base.Hitbox.MouseButton1Click:Connect(function()
		local CrrPosY = FrameLocation.AbsolutePosition.Y - ScrollFrame.AbsolutePosition.Y - 50
		TweenService:Create(ScrollFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {CanvasPosition = ScrollFrame.CanvasPosition + Vector2.new(0, CrrPosY)}):Play()
		ScrollFrame.Base.VisibilityManagement.Toggle:Fire(FrameLocation, linked)
	end)
end

for _, obj in pairs(script.Parent:GetChildren()) do
	if obj:IsA("Frame") then
		bind(obj)
	end
end
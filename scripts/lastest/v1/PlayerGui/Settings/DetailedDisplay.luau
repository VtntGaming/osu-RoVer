local TweenService = game:GetService("TweenService")

type DescriptionFrame = Frame & {
	Description: TextLabel
}

local TWEEN_OUT = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_LINEAR = TweenInfo.new(0.25, Enum.EasingStyle.Linear)

function addBinding(obj: DescriptionFrame)
	print("Binding added: ", obj)
	local origin = obj.Size.Y.Offset
	local desc = obj.Description
	desc.Size = UDim2.new(0.75, 0, 0, 1000)
	desc.AutomaticSize = Enum.AutomaticSize.Y
	desc.TextScaled = false
	desc.TextWrapped = true
	
	obj.InputBegan:Connect(function()
		TweenService:Create(obj, TWEEN_OUT, {Size = UDim2.new(1,0,0,30 + desc.TextBounds.Y)}):Play()
		TweenService:Create(desc, TWEEN_LINEAR, {TextTransparency = 0}):Play()
	end)
	
	obj.InputEnded:Connect(function()
		TweenService:Create(obj, TWEEN_OUT, {Size = UDim2.new(1,0,0,origin)}):Play()
		TweenService:Create(desc, TWEEN_LINEAR, {TextTransparency = 1}):Play()
	end)
end

for _, item in pairs(script.Parent.Parent:GetDescendants()) do	
	if item:IsA("Frame") and (item:FindFirstChild("SwitchState") or item:FindFirstChild("Current")) and item:FindFirstChild("Description") then
		addBinding(item)
	end					
end
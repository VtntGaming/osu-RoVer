--[LOCATION]:[StarterGui.Settings.SettingFrame.BaseFrame.Options.OptionsAnimate]
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local event = Instance.new("BindableEvent")
local update = script.Update
local baseTween = TweenInfo.new(0.25,Enum.EasingStyle.Linear)
local currentPosition = script.Parent.General
function bind(Obj)
	local Hitbox = Obj.Hitbox
	local Display = Obj.Display
	local Icon = Obj.Icon

	Hitbox.MouseEnter:Connect(function()
		TweenService:Create(Hitbox,baseTween,{BackgroundTransparency = 0.75}):Play()
		TweenService:Create(Display,baseTween,{TextColor3 = Color3.new(0.843137, 1, 1)}):Play()
		TweenService:Create(Icon,baseTween,{ImageColor3 = Color3.new(0.843137, 1, 1)}):Play()
	end)

	Hitbox.MouseLeave:Connect(function()
		TweenService:Create(Hitbox,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{BackgroundTransparency = 1}):Play()
		TweenService:Create(Display,baseTween,{TextColor3 = Color3.new(0.447059, 0.529412, 0.529412)}):Play()
		TweenService:Create(Icon,baseTween,{ImageColor3 = Color3.new(0.447059, 0.529412, 0.529412)}):Play()
	end)

	Hitbox.MouseButton1Down:Connect(function()
		TweenService:Create(Obj,TweenInfo.new(1,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out), {Size = UDim2.new(3.8,0,0.8,0)}):Play()
		TweenService:Create(Hitbox.activeFrame,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.75}):Play()
		event.Event:Wait()
		TweenService:Create(Obj,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size = UDim2.new(4,0,1,0)}):Play()
		TweenService:Create(Hitbox.activeFrame,TweenInfo.new(1,Enum.EasingStyle.Linear),{BackgroundTransparency = 1}):Play()
	end)

	Hitbox.MouseButton1Click:Connect(function()
		wait()
		TweenService:Create(Hitbox.activeFrame,TweenInfo.new(0,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.5}):Play()
		wait()
		TweenService:Create(Hitbox.activeFrame,TweenInfo.new(1,Enum.EasingStyle.Linear),{BackgroundTransparency = 1}):Play()
	end)
end

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.Focus then
		event:Fire()
	end
end)

for _, obj in pairs(script.Parent:GetChildren()) do
	if obj:IsA("Frame") then
		bind(obj.Base)
	end
end
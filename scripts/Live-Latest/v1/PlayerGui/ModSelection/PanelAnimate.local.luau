local TweenService = game:GetService("TweenService")

local MainFrame = script.Parent.Parent

local TweenIn = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.5, 1.05)})
local TweenOut = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.fromScale(0.5, 2)})

local IsEnabled = false

function SetEnabled(enabled: boolean?)
	if enabled ~= nil then
		IsEnabled = enabled
	else
		IsEnabled = not IsEnabled
	end

	if IsEnabled then
		TweenIn:Play()
	else
		TweenOut:Play()
	end	
end

script.Parent.SetEnabled.Event:Connect(function(enabled: boolean?)
	SetEnabled(enabled)
end)
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")

local ActiveSession

local function CreateTempImage(ImageId: string)
	local img = Instance.new("Decal")
	img.Texture = "rbxassetid://"..ImageId
	
	return img
end

script.Parent.ChangeRequest.Event:Connect(function(ImageId)
	local BackgroundFrame = script.Parent
	ImageId = tostring(ImageId)
	
	local currentSesssion = HttpService:GenerateGUID()
	ActiveSession = currentSesssion
	
	local img = CreateTempImage(ImageId)
	
	ContentProvider:PreloadAsync({
		img
	})
	
	img:Destroy()
	
	if ActiveSession ~= currentSesssion then
		return
	end
	
	for _,a in pairs(BackgroundFrame.Background:GetChildren()) do
		-- If it found one same image, directly stop the function
		if not a:IsA("ImageLabel") then
			continue
		end
		if a.Image == "rbxassetid://"..ImageId then
			return
		end
		a.ZIndex = 0
		TweenService:Create(a,TweenInfo.new(0.15,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
		task.spawn(function()
			task.wait(.15)
			a:Destroy()
		end)
	end

	local newBG = game.ReplicatedStorage.Template.GameBackground.BackroundImage:Clone()
	newBG.Parent = BackgroundFrame.Background
	TweenService:Create(newBG,TweenInfo.new(0.15,Enum.EasingStyle.Linear),{ImageTransparency = 0}):Play()
	newBG.Image = "rbxassetid://"..ImageId
	
	ActiveSession = nil
end)
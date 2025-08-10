--[LOCATION]:[StarterGui.PlayScreen.GameplayScripts.UISeparate]
return function(TargetObject)
	local Count = 3
	local runservice = game:GetService("RunService")
	local wait = require(workspace.WaitModule)

	local function CreateUI(SourceFrame)
		if not SourceFrame then return end
		local baseCanvas = Instance.new("CanvasGroup")
		baseCanvas.Size = UDim2.new(1/Count,0,1/Count,0)
		baseCanvas.BackgroundTransparency = 1
		baseCanvas.ClipsDescendants = true
		local MainFrame = Instance.new("Frame")
		MainFrame.Name = "Object"
		MainFrame.BackgroundTransparency = 1
		local baseFrame = Instance.new("Frame")
		baseFrame.Size = UDim2.new(Count,0,Count,0)
		baseFrame.Parent = baseCanvas
		baseFrame.Name = "baseFrame"
		baseFrame.BackgroundTransparency = 1
		if SourceFrame:IsA("GuiObject") then
			MainFrame.Size = SourceFrame.Size
			MainFrame.Position = SourceFrame.Position
			MainFrame.AnchorPoint = SourceFrame.AnchorPoint
			MainFrame.SizeConstraint = SourceFrame.SizeConstraint
			local new = SourceFrame:Clone()
			new.Parent = baseFrame
			new.Size = UDim2.new(1,0,1,0)
			new.Position = UDim2.new(0.5,0,0.5,0)
			new.AnchorPoint = Vector2.new(0.5,0.5)
		else
			baseFrame.Size = UDim2.new(1,0,1,0)
			baseFrame.Position = UDim2.new(0.5,0,0.5,0)
			baseFrame.AnchorPoint = Vector2.new(0.5,0.5)
			for _,a in pairs(SourceFrame:GetChildren()) do
				a:Clone().Parent = baseFrame
			end
		end

		for _, obj in pairs(baseFrame:GetDescendants()) do
			if obj:IsA("BaseScript") then
				obj:Destroy()
			end
		end
		for i = 0,Count-1 do
			for j = 0,Count-1 do
				local new = baseCanvas:Clone()
				new.Parent = MainFrame
				new.Position = UDim2.new(i/Count,0,j/Count,0)
				new.baseFrame.Position = UDim2.new(-(i),0,-(j),0)
			end
		end

		return MainFrame
	end

	local newUI = CreateUI(TargetObject)
	newUI.Parent = TargetObject.Parent
	TargetObject.Visible = false
	local TweenService = game:GetService("TweenService")
	wait()

	for i,a in pairs(newUI:GetChildren()) do
		local X = a.Position.X.Scale
		local Y = a.Position.Y.Scale
		
		local TargetX = X  + (X-0.5) * (0.5 + math.random(0,100) / 100 * 5)
		local TargetY = Y  + (Y-0.5) * (0.5 + math.random(0,100) / 100 * 5)
		local PositiveValue = X >= 0.5 and 1 or -1
		local TargetRotation = math.random(0, 20) * PositiveValue
		wait(0.05)
		spawn(function()
			TweenService:Create(a,TweenInfo.new(3-i*0.05, Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Position = UDim2.new(TargetX,0,TargetY,0), Rotation = TargetRotation}):Play()
			TweenService:Create(a,TweenInfo.new(3-i*0.05, Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{GroupTransparency = 1}):Play()
		end)
	end
end


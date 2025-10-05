--[LOCATION]:[StarterGui.BeatmapListing.MainFrame.MainFrame.WorkingScript.ScrollingScript]
-- main
local ScrollerFrame = script.Parent.Parent.ScrollingArea.Scroller
local ListingFrame = script.Parent.Parent.Listing
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- standard scroll
local inScroller = false
local onHold = false
local LastHold = 0

-- mouse wheel scroll
local MouseInArea = false
local MouseScrollArea = script.Parent.Parent.Parent.MouseScrollArea
local CanvasPosY = 0

-- virtual scroll
local InputHold = false
local StartHoldPosition = Vector3.new(0,0,0)
local CanvasPosBeforeHold = 0
local CasvasSpeed = 0
local LastPos = 0
local LastRelease = 0


ListingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	local MaxSize = ListingFrame.AbsoluteCanvasSize.Y - ListingFrame.AbsoluteWindowSize.Y
	local PositionScale = ListingFrame.CanvasPosition.Y/MaxSize
	
	ScrollerFrame.Position = UDim2.new(0,0,PositionScale,0)
	ScrollerFrame.AnchorPoint = Vector2.new(0,PositionScale)
end)

local VisibleValue = script.Parent.IsVisible

ScrollerFrame.MouseButton1Down:Connect(function()
	if VisibleValue.Value then
		-- Only scroll if the scrolling is visible
		onHold = true
	end
end)

ScrollerFrame.MouseEnter:Connect(function()
	inScroller = true
end)

ScrollerFrame.MouseMoved:Connect(function()
	inScroller = true
end)

ScrollerFrame.MouseLeave:Connect(function()
	inScroller = false
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Focus then

		onHold = false
		LastHold = tick()
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if onHold and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
		local Position = UserInputService:GetMouseLocation()
		
		local ScrollingArea = script.Parent.Parent.ScrollingAreaHitbox
		local MinPos = ScrollingArea.AbsolutePosition + Vector2.new(0,36)
		local MaxPos = ScrollingArea.AbsolutePosition+ScrollingArea.AbsoluteSize - Vector2.new(0,36)
		local CenterPos = (MinPos+MaxPos)/2
		
		local ScalePositionY = (Position.Y-MinPos.Y)/MaxPos.Y
		local ScalePositionFinal = ScalePositionY
		
		CanvasPosY = ScalePositionFinal * (ListingFrame.AbsoluteCanvasSize.Y - ListingFrame.AbsoluteWindowSize.Y)
		
		
		TweenService:Create(ListingFrame,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
			CanvasPosition = Vector2.new(0,CanvasPosY)
		}):Play()
		
	end
end)




MouseScrollArea.MouseEnter:Connect(function()
	MouseInArea = true
end)

MouseScrollArea.MouseMoved:Connect(function()
	MouseInArea = true
end)

MouseScrollArea.MouseLeave:Connect(function()
	MouseInArea = false
end)

-- Right click drag
local isRightClickHold = false
UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 and VisibleValue.Value then
		isRightClickHold = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Focus then
		isRightClickHold = false
	end
end)

local prevMove = tick()

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement and isRightClickHold then
		if tick() - prevMove < 0.1 then
			return
		end
		prevMove = tick()
		local MixPos = 60
		local MaxPos = workspace.CurrentCamera.ViewportSize.Y - 60
		local Size = MaxPos - MixPos
		
		local Position = input.Position.Y + 58 - MixPos
		local Ratio = Position/Size
		Ratio = math.clamp(Ratio, 0, 1)
		local ActualScrollPos = ListingFrame.AbsoluteCanvasSize.Y * Ratio
		TweenService:Create(ListingFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{CanvasPosition = Vector2.new(0,ActualScrollPos)}):Play()
	end
end)


-- Mouse wheel scroll
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel and MouseInArea then
		if not script.Parent.Parent.Parent.Parent.Enabled or isRightClickHold then return end
		local MaxSize = ListingFrame.AbsoluteCanvasSize.Y - ListingFrame.AbsoluteWindowSize.Y
		local WindowSize = workspace.CurrentCamera.ViewportSize
		CanvasPosY += WindowSize.Y*0.2 * -math.sign(input.Position.Z)
		CanvasPosY = math.clamp(CanvasPosY, 0, MaxSize)
		--[[
		if input.Position.Z == -1 then
			CanvasPosY += WindowSize.Y*0.2
		else
			CanvasPosY -= WindowSize.Y*0.2
		end

		if CanvasPosY < 0 then CanvasPosY = 0
		elseif CanvasPosY > MaxSize then CanvasPosY = MaxSize
		end]]
		
		TweenService:Create(ListingFrame,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{CanvasPosition = Vector2.new(0,CanvasPosY)}):Play()

	end
end)



UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if not onHold and not inScroller and script.Parent.Parent.Parent.Parent.Enabled then
			if input.Position.Y > workspace.Camera.ViewportSize.Y-36 then return end
			StartHoldPosition = input.Position
			CanvasPosBeforeHold = CanvasPosY
			LastPos = CanvasPosY
			CasvasSpeed = 0
			InputHold = true
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.Focus then
		CanvasPosBeforeHold = CanvasPosY
		InputHold = false
		
		
		CanvasPosY -= CasvasSpeed/5
		local MaxSize = ListingFrame.AbsoluteCanvasSize.Y - ListingFrame.AbsoluteWindowSize.Y
		if CanvasPosY < 0 then CanvasPosY = 0
		elseif CanvasPosY > MaxSize then CanvasPosY = MaxSize
		end
		
		TweenService:Create(ListingFrame,TweenInfo.new(math.abs(CasvasSpeed)/1000,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{CanvasPosition = Vector2.new(0,CanvasPosY)}):Play()
		
	end
end)

local LastTick = 0

UserInputService.InputChanged:Connect(function(input)
	if script.Parent.Parent.Parent.Parent.Enabled == false then return end
	if InputHold and input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local Diff = (StartHoldPosition - input.Position)
		CanvasPosY = CanvasPosBeforeHold + Diff.Y
		
		CasvasSpeed = (LastPos - CanvasPosY)/(tick() - LastTick)
		LastPos = CanvasPosY
		LastTick = tick()
		
		
		local MaxSize = ListingFrame.AbsoluteCanvasSize.Y - ListingFrame.AbsoluteWindowSize.Y
		CanvasPosY = math.clamp(CanvasPosY, 0, MaxSize)
		TweenService:Create(ListingFrame,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{CanvasPosition = Vector2.new(0,CanvasPosY)}):Play()
	end
end)

script.Parent.Parent.WorkingScript.CustomScrollChange.Event:Connect(function(NewCanvasPos,TweenTime)
	if not TweenTime then TweenTime = 0 end
	
	repeat wait() until InputHold == false
	CanvasPosY = NewCanvasPos
	if ListingFrame.CanvasPosition ~= Vector2.new(0,CanvasPosY) then
		TweenService:Create(ListingFrame,TweenInfo.new(TweenTime,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{CanvasPosition = Vector2.new(0,CanvasPosY)}):Play()
	end
end)
--[LOCATION]:[StarterGui.PlayScreen.GameplayScripts.Components.Gameplay.SliderComponent]
--!strict
local Players = game:GetService("Players")
local script = script :: typeof(script) & typeof(Players.LocalPlayer.PlayerGui.PlayScreen.GameplayScripts.Components.Gameplay.SliderComponent)
local PlayFrame = script.Parent.Parent.Parent.Parent.PlayFrame
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local SliderObjManage = require(StarterGui.PlayScreen.GameplayScripts.Components.Perfomance.SliderObjManage)
local Slider = {}

function PositionPoint(p1: Vector2, p2: Vector2, t: number): Vector2
	return p1:Lerp(p2, t)
end

function Rotate180(r: number): number
	return (r + 180)%360
end

function sineOut(t)
	t = math.clamp(t, 0, 1)
	return math.sin((t * math.pi) / 2)
end

type TickData = {
	Time: number,
	Slide: number,
	Position: Vector2,
	Object: Instance
}

type PointData = {
	InnerObject: typeof(script.SliderCoverInner),
	OuterObject: typeof(script.SliderCoverOuter),
	StartPos: Vector2,
	EndPos: Vector2,
	BodySize: number,
	Rotation: number,
	Start: number,
	Duration: number
}

function Slider.new(curvePoint:{ [any]: Vector2}, tickData:{{number}}, slideCount:number, circleRadius:number, ExtraLengthData:{[any]:number}, ObjManage:SliderObjManage.ObjectManage)
	local SliderObject = {
		TotalLength = 0
	} 
	local PointData:{[number]:PointData} = {}
	-- preprocessing the data before draw
	for i, currentPoint in pairs(curvePoint) do
		local nextPoint = curvePoint[i+1]
		if not nextPoint then break end
		
		if typeof(currentPoint) == "table" then
			local _current = currentPoint::{X:number, Y:number, ExtraLength:number}
			currentPoint = Vector2.new(_current.X, _current.Y)
		end
		
		if typeof(nextPoint) == "table" then
			local _next = nextPoint::{X:number, Y:number, ExtraLength:number}
			nextPoint = Vector2.new(_next.X, _next.Y)
		end
		
		local Vector = (nextPoint - currentPoint)
		local length = Vector.Magnitude
		local Rotation = math.deg(math.atan2(Vector.Y,Vector.X))
		local lengthRatio = length/circleRadius
		if ExtraLengthData then
			local extra = ExtraLengthData[i]
			if extra then
				length += extra
			end
		end
		PointData[#PointData+1] = {
			InnerObject = nil :: any,
			OuterObject = nil :: any,
			StartPos = currentPoint/Vector2.new(512,384),
			EndPos = nextPoint/Vector2.new(512,384),
			BodySize = lengthRatio,
			Rotation = Rotation,
			Start = SliderObject.TotalLength,
			Duration = length
		}
		SliderObject.TotalLength += length
	end
	
	-- normalise the length
	for i, data in pairs(PointData) do
		data.Start /= SliderObject.TotalLength
		data.Duration /= SliderObject.TotalLength
	end
	
	-- predraw the slider
	local SliderBase = script.SliderBase:Clone()
	SliderObject.SliderBase = SliderBase
	local RadiusBase = circleRadius/384
	
	-- Follow circle is special, it have to be rendered outside the base frame
	local SliderFollowCircle = script.SliderFollowCircle:Clone()
	SliderFollowCircle.Size = UDim2.fromScale(RadiusBase, RadiusBase)
	SliderFollowCircle.Parent = PlayFrame
	SliderObject.SliderFollowCircle = SliderFollowCircle
	
	
	local SliderCoverInner = script.SliderCoverInner:Clone()
	local SliderCoverOuter = script.SliderCoverOuter:Clone()
	SliderCoverInner.Size = UDim2.fromScale(RadiusBase*0.85,RadiusBase*0.85)
	SliderCoverOuter.Size = UDim2.fromScale(RadiusBase,RadiusBase)
	SliderCoverInner.Position = UDim2.fromScale(PointData[1].StartPos.X, PointData[1].StartPos.Y)
	SliderCoverOuter.Position = UDim2.fromScale(PointData[1].StartPos.X, PointData[1].StartPos.Y)
	SliderCoverInner.Parent = SliderBase.BaseInner
	SliderCoverOuter.Parent = SliderBase.BaseOuter

	local newEndSliderInner = SliderCoverInner:Clone()
	local newEndSliderOuter = SliderCoverOuter:Clone()
	newEndSliderInner.Parent = SliderBase.BaseInner
	newEndSliderOuter.Parent = SliderBase.BaseOuter
	newEndSliderInner.Visible = false
	newEndSliderOuter.Visible = false
	
	for i, data in pairs(PointData) do
		local newPoint, _isReused = ObjManage:GetFromCollection(script.SliderPoint, true)  --script.SliderPoint:Clone()
		newPoint.Position = UDim2.fromScale(data.StartPos.X, data.StartPos.Y)
		newPoint.Size = UDim2.fromScale(RadiusBase,RadiusBase)		
		newPoint.Body.Size = UDim2.fromScale(data.BodySize, 1)
		newPoint.Rotation = data.Rotation
		newPoint.ZIndex = i
		if _isReused then
			newPoint.InnerHead.Visible = true
		end
		local newPointOuter, isReused = ObjManage:GetFromCollection(newPoint, false) --  newPoint:Clone()
		if isReused then
			newPointOuter.Position = UDim2.fromScale(data.StartPos.X, data.StartPos.Y)
			newPointOuter.Size = UDim2.fromScale(RadiusBase,RadiusBase)		
			newPointOuter.Body.Size = UDim2.fromScale(data.BodySize, 1)
			newPointOuter.Rotation = data.Rotation
			newPointOuter.ZIndex = i
			newPointOuter.BackgroundTransparency = 0
		end

		newPoint.BackgroundTransparency = 1
		newPoint.Body.Overlay.BackgroundTransparency = 1
		newPointOuter.InnerHead.Visible = false
		newPointOuter.Body.Overlay.Body.Visible = false
		newPoint.Parent = SliderBase.BaseInner
		newPointOuter.Parent = SliderBase.BaseOuter
		data.InnerObject = newPoint
		data.OuterObject = newPointOuter
	end
	
	local PointDataReverse = {}
	local ReverseArrows = {}
	
	-- Point data for the reverse
	
	if slideCount > 1 then
		for i = #PointData, 1, -1 do
			local data = PointData[i]
			PointDataReverse[#PointDataReverse+1] = {
				InnerObject = data.InnerObject,
				OuterObject = data.OuterObject,
				StartPos = data.EndPos,
				EndPos = data.StartPos,
				BodySize = data.BodySize,
				Rotation = Rotate180(data.Rotation),
				Start = data.Start,
				Duration = data.Duration
			}
		end
		
		-- Reverse arrow
		
		for i = 2, slideCount do
			local newReverseArrow
			if i % 2 == 0 then
				-- Only initiate the first and second slide, the next one will just copy the old one
				if i == 2 then
					newReverseArrow = script.ReverseArrow:Clone()
				local pos = PointData[#PointData].EndPos
				local rotation = PointData[#PointData].Rotation
					newReverseArrow.Size = UDim2.fromScale(RadiusBase * 0.6, RadiusBase * 0.6)
					newReverseArrow.Position = UDim2.fromScale(pos.X, pos.Y)
					newReverseArrow.Rotation = Rotate180(rotation)
				else
					newReverseArrow = ReverseArrows[1]:Clone()
				end
			else
				if i == 3 then
					newReverseArrow = ReverseArrows[1]:Clone()
					local pos = PointData[1].StartPos
					local rotation = PointData[1].Rotation
					newReverseArrow.Position = UDim2.fromScale(pos.X, pos.Y)
					newReverseArrow.Rotation = rotation
				else
					newReverseArrow = ReverseArrows[2]:Clone()
				end
			end
			newReverseArrow.Parent = SliderBase.BaseInner
			ReverseArrows[#ReverseArrows+1] = newReverseArrow
		end
	end
	
	SliderObject.ReverseArrow = ReverseArrows
	
	-- Slider ticks
	
	local runtimeTickData:{[number]:{TickData}} = {}
	
	local TickSizeMultiplier = 0.25
	local sizeScale = (TickSizeMultiplier*circleRadius)/384
	local tickSize = UDim2.fromScale(sizeScale, sizeScale)
	
	for i, data in pairs(tickData) do
		local appearTime = data[1]::number
		local tickSlide = data[2]::number
		local tickPosition = (data[3]::any)::Vector2
		local newTick = script.SliderTick:Clone()
		newTick.Parent = SliderBase.TickFrame
		newTick.Visible = false
		newTick.Position = UDim2.fromScale(tickPosition.X/512, tickPosition.Y/384)
		newTick.Size = UDim2.fromScale(0,0)
		
		local _data:TickData = {
			Time = appearTime,
			Slide = tickSlide,
			Position = tickPosition,
			Object = newTick
		}

		if not runtimeTickData[tickSlide] then
			runtimeTickData[tickSlide] = {}
		end
		local dataOfCurrentSlide = runtimeTickData[tickSlide]
		dataOfCurrentSlide[#dataOfCurrentSlide+1] = _data
	end
	
	local function enableTick(t:ImageLabel)
		t.Visible = true
		TweenService:Create(t,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size = tickSize, ImageTransparency = 0}):Play()		
	end
	
	local function disableTick(t:ImageLabel)
		TweenService:Create(t,TweenInfo.new(0.1,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size = UDim2.fromScale(0,0), ImageTransparency = 1}):Play()
		task.delay(0.25, function()
			t.Visible = false
		end)
	end
	
	local currentTaskEnable:thread
	
	function SliderObject.ShowCurrentTickOnSlide(slide:number, movementTime:number, isInit: boolean?)
		local holdTime = isInit and 250 or 500
		if currentTaskEnable then
			task.cancel(currentTaskEnable)
		end
		if slide > 1 then
			local previoudSlideTick = runtimeTickData[slide-1]
			if previoudSlideTick then
				for _, tickData in pairs(previoudSlideTick) do
					disableTick(tickData.Object :: ImageLabel)
				end
			end
		end

		local currentSlideTick = runtimeTickData[slide]
		if currentSlideTick then
			currentTaskEnable = task.spawn(function()
				local _s = os.clock()
				for tickOrder, tickData in pairs(currentSlideTick) do
					local tickDisplayTime = math.max(0, 0 - holdTime + (1/#currentSlideTick*tickOrder) * movementTime/#runtimeTickData * 0.75)
					repeat task.wait() until os.clock()-_s >= tickDisplayTime/1000
					enableTick(tickData.Object :: ImageLabel)
				end
			end)
		end
	end
	
	function SliderObject.CleanTick(slide: number, index: number)
		local crrSlideData = runtimeTickData[slide]
		local tickData = crrSlideData and crrSlideData[index]
		if tickData then
			disableTick(tickData.Object :: ImageLabel)
		end
	end
	
	function SliderObject.CleanUp()
		for _, data in pairs(PointData) do
			ObjManage:AddToCollection(data.InnerObject, true)
			ObjManage:AddToCollection(data.OuterObject, false)
			--data.InnerObject:Destroy()
			--data.OuterObject:Destroy()
		end
	end
	
	-- Important functions
	
	function SliderObject.PositionOf(t:number, isReverse:boolean?): Vector2?
		local targetPoints = PointData
		if isReverse then
			t = 1-t
		end

		local lastPoint = targetPoints[#targetPoints]
		if t >= lastPoint.Start+lastPoint.Duration then
			return lastPoint.EndPos
		end
		for _, data in pairs(targetPoints) do
			local tStart = data.Start
			local tEnd = tStart+data.Duration
			if t >= tStart and t <= tEnd then
				return PositionPoint(data.StartPos, data.EndPos, (t-tStart)/data.Duration)
			end
		end

		return nil
	end
	
	function SliderObject.SetTransparency(t)
		SliderBase.GroupTransparency = math.clamp(t,0,1)
	end
	
	function SliderObject.SetSnakingIn(t, inReverse)
		xpcall(function()				
			local lastRotation = 0
			for _, data in pairs(PointData) do
				local obj = data.InnerObject
				local objOuter = data.OuterObject
				local tStart = data.Start
				local tEnd = tStart+data.Duration
				if t >= tStart then
					obj.Visible = true
					objOuter.Visible = true
					local Ratio = math.min(1, (t - tStart) / data.Duration)
					obj.Body.Overlay.Size = UDim2.fromScale(Ratio,1)
					objOuter.Body.Overlay.Size = UDim2.fromScale(Ratio,1)
					lastRotation = Rotate180(data.Rotation)
			else
					obj.Visible = false
					objOuter.Visible = false
				end
				if t <= tEnd then
					lastRotation = Rotate180(data.Rotation)
					if inReverse then
						continue
					else
						break
					end
				end
			end
			local Position = SliderObject.PositionOf(t) :: Vector2
			if slideCount > 1 and not inReverse then -- animate the first arrow object
				local firstReverseArrow = ReverseArrows[1]
				firstReverseArrow.Position = UDim2.fromScale(Position.X, Position.Y)
				firstReverseArrow.Rotation = lastRotation
				firstReverseArrow.ReverseArrow.ImageTransparency = 0
			end
			SliderCoverInner.Position = UDim2.fromScale(Position.X, Position.Y)
			SliderCoverOuter.Position = UDim2.fromScale(Position.X, Position.Y)
		end, function(e)
			warn(e)
		end)
	end
	
	function SliderObject.SetSnakingOut(t)
		xpcall(function()
			local isLastSlideReverse = (slideCount % 2 == 0)
			
			if isLastSlideReverse then
				-- This is easy, just do the SetSnakingIn and done
				SliderObject.SetSnakingIn(1-t, true)
			else
				-- But this isn't...
				for _, data in pairs(PointData) do
					local obj = data.InnerObject
					local objOuter = data.OuterObject
					local tStart = data.Start
					local tEnd = tStart+data.Duration
					if t-tStart > data.Duration then
						obj.Visible = false
						objOuter.Visible = false
						continue
					else
						local Ratio = math.clamp((t-tStart) / (data.Duration), 0, 1)
						obj.Body.Overlay.Size = UDim2.fromScale(1-Ratio,1)
						objOuter.Body.Overlay.Size = UDim2.fromScale(1-Ratio,1)
						local Pos = PositionPoint(data.StartPos,data.EndPos, Ratio)
						obj.Position = UDim2.fromScale(Pos.X, Pos.Y)
						objOuter.Position = UDim2.fromScale(Pos.X, Pos.Y)
						if Ratio < tEnd and Ratio >= tStart then
							obj.InnerHead.Visible = false
							objOuter.BackgroundTransparency = 1
							break
						end
					end
				end
				local Position = SliderObject.PositionOf(t) :: Vector2
				newEndSliderInner.Visible = true
				newEndSliderOuter.Visible = true
				newEndSliderInner.Position = UDim2.fromScale(Position.X, Position.Y)
				newEndSliderOuter.Position = UDim2.fromScale(Position.X, Position.Y)
			end
		end, function(e)
			warn(e)
		end)
	end
	
	function SliderObject.setFollowCirclePosition(t, isReverse)
		local Position = SliderObject.PositionOf(t, isReverse) :: Vector2
		SliderFollowCircle.Position = UDim2.fromScale(Position.X,Position.Y)
	end
	
	function SliderObject.isCursorInFollowCircle(position:Vector2, t:number, isReverse:boolean)
		local FollowPosition = SliderObject.PositionOf(t, isReverse) :: Vector2
		local Distance = (position - FollowPosition*Vector2.new(512,384)).Magnitude
		
		return Distance <= circleRadius/2 * 2.25
	end
	local currentReverseArrow = 1
	
	function SliderObject.setReverseArrowBeat(t)
		t = sineOut(t)
		for i = currentReverseArrow, #ReverseArrows do
			local arrow = ReverseArrows[i]
			if not arrow then return end
			local size = math.lerp(1, 1.25, t)
			arrow.ReverseArrow.Size = UDim2.fromScale(size, size)
		end
		script.Parent.executeRate.Value += 1
	end
	
	function SliderObject.clearCurrentReverseArrow(currentSlide, fadeOutTime, fadeInTime, noNextArrowFadeIn)
		if not fadeOutTime then
			fadeOutTime = 0.2
		end
		if not fadeInTime then
			fadeInTime = 0.015
		end
		if currentSlide ~= -1 then
			local currentArrow = ReverseArrows[currentSlide]
			local nextArrow = ReverseArrows[currentSlide+1]
			if currentArrow then
				TweenService:Create(currentArrow.ReverseArrow, TweenInfo.new(fadeOutTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.fromScale(1.5, 1.5), ImageTransparency = 1}):Play()
			end
			
			if nextArrow and not noNextArrowFadeIn then
				TweenService:Create(nextArrow.ReverseArrow, TweenInfo.new(fadeInTime, Enum.EasingStyle.Linear), {ImageTransparency = 0}):Play()
			end
		end
	end

	SliderBase.Parent = PlayFrame
	
	return SliderObject
end
return Slider
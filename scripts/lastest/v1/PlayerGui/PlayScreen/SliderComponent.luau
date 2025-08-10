--[LOCATION]:[StarterGui.PlayScreen.GameplayScripts.Components.Gameplay.SliderComponent]
local Slider = {}
local PlayFrame = script.Parent.Parent.Parent.Parent.PlayFrame
local TweenService = game:GetService("TweenService")


function PositionPoint(p1, p2, t)
	return p1 + (p2-p1)*t
end

function Rotate180(r)
	return (r + 180)%360
end

function lerp(a, b, ratio)
	return a + (b - a)*ratio
end

function sineOut(t)
	t = math.clamp(t, 0, 1)
	return math.sin((t * math.pi) / 2)
end

function Slider.new(curvePoint:{ [any]: Vector2}, slideCount:number, circleRadius:number, ExtraLengthData:{[any]:number}, ObjManage)
	local SliderObject = {
		TotalLength = 0
	} 
	local PointData = {} -- {point object inner, point object outer, start pos, end pos, body size, rotation (degree), start, duration
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
		PointData[#PointData+1] = {-1, -1, currentPoint/Vector2.new(512,384), nextPoint/Vector2.new(512,384), lengthRatio, Rotation, SliderObject.TotalLength, length}
		SliderObject.TotalLength += length
	end
	
	-- normalise the length
	for i, data in pairs(PointData) do
		data[7] /= SliderObject.TotalLength
		data[8] /= SliderObject.TotalLength
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
	SliderCoverInner.Position = UDim2.fromScale(PointData[1][3].X, PointData[1][3].Y)
	SliderCoverOuter.Position = UDim2.fromScale(PointData[1][3].X, PointData[1][3].Y)
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
		newPoint.Position = UDim2.fromScale(data[3].X, data[3].Y)
		newPoint.Size = UDim2.fromScale(RadiusBase,RadiusBase)		
		newPoint.Body.Size = UDim2.fromScale(data[5], 1)
		newPoint.Rotation = data[6]
		newPoint.ZIndex = i
		if _isReused then
			newPoint.InnerHead.Visible = true
		end
		local newPointOuter, isReused = ObjManage:GetFromCollection(newPoint, false) --  newPoint:Clone()
		if isReused then
			newPointOuter.Position = UDim2.fromScale(data[3].X, data[3].Y)
			newPointOuter.Size = UDim2.fromScale(RadiusBase,RadiusBase)		
			newPointOuter.Body.Size = UDim2.fromScale(data[5], 1)
			newPointOuter.Rotation = data[6]
			newPointOuter.ZIndex = i
			newPointOuter.BackgroundTransparency = 0
		end

		newPoint.BackgroundTransparency = 1
		newPoint.Body.Overlay.BackgroundTransparency = 1
		newPointOuter.InnerHead.Visible = false
		newPointOuter.Body.Overlay.Body.Visible = false
		newPoint.Parent = SliderBase.BaseInner
		newPointOuter.Parent = SliderBase.BaseOuter
		data[1] = newPoint
		data[2] = newPointOuter
	end
	
	local PointDataReverse = {}
	local ReverseArrows = {}
	
	-- Point data for the reverse
	
	if slideCount > 1 then
		for i = #PointData, 1, -1 do
			local data = PointData[i]
			PointDataReverse[#PointDataReverse] = {data[1], data[2], data[4], data[3], data[5], Rotate180(data[6]), data[7], data[8]}
		end
		
		-- Reverse arrow
		
		for i = 2, slideCount do
			local newReverseArrow
			if i % 2 == 0 then
				-- Only initiate the first and second slide, the next one will just copy the old one
				if i == 2 then
					newReverseArrow = script.ReverseArrow:Clone()
					local pos = PointData[#PointData][4]
					local rotation = PointData[#PointData][6]
					newReverseArrow.Size = UDim2.fromScale(RadiusBase * 0.6, RadiusBase * 0.6)
					newReverseArrow.Position = UDim2.fromScale(pos.X, pos.Y)
					newReverseArrow.Rotation = Rotate180(rotation)
				else
					newReverseArrow = ReverseArrows[1]:Clone()
				end
			else
				if i == 3 then
					newReverseArrow = ReverseArrows[1]:Clone()
					local pos = PointData[1][3]
					local rotation = PointData[1][6]
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
	
	function SliderObject.CleanUp()
		for _, data in pairs(PointData) do
			ObjManage:AddToCollection(data[1], true)
			ObjManage:AddToCollection(data[2], false)
			--data[1]:Destroy()
			--data[2]:Destroy()
		end
	end
	
	-- Important functions
	
	function SliderObject.PositionOf(t:number, isReverse:boolean?)
		local targetPoints = PointData
		if isReverse then
			t = 1-t
		end

		local lastPoint = targetPoints[#targetPoints]
		if t >= lastPoint[7]+lastPoint[8] then
			return lastPoint[4]
		end
		for _, data in pairs(targetPoints) do
			local tStart = data[7]
			local tEnd = tStart+data[8]
			if t >= tStart and t <= tEnd then
				return PositionPoint(data[3], data[4], (t-tStart)/data[8])
			end
		end
	end
	
	function SliderObject.SetTransparency(t)
		SliderBase.GroupTransparency = math.clamp(t,0,1)
	end
	
	function SliderObject.SetSnakingIn(t, inReverse)
		local lastRotation = 0
		for _, data in pairs(PointData) do
			local obj = data[1]
			local objOuter = data[2]
			local tStart = data[7]
			local tEnd = tStart+data[8]
			if t >= tStart then
				obj.Visible = true
				objOuter.Visible = true
				local Ratio = math.min(1, (t - tStart) / data[8])
				obj.Body.Overlay.Size = UDim2.fromScale(Ratio,1)
				objOuter.Body.Overlay.Size = UDim2.fromScale(Ratio,1)
				lastRotation = Rotate180(data[6])
			else
				obj.Visible = false
				objOuter.Visible = false
			end
			if t <= tEnd then
				lastRotation = Rotate180(data[6])
				if inReverse then
					continue
				else
					break
				end
			end
		end
		local Position = SliderObject.PositionOf(t)
		if slideCount > 1 and not inReverse then -- animate the first arrow object
			local firstReverseArrow = ReverseArrows[1]
			firstReverseArrow.Position = UDim2.fromScale(Position.X, Position.Y)
			firstReverseArrow.Rotation = lastRotation
			firstReverseArrow.ReverseArrow.ImageTransparency = 0
		end
		SliderCoverInner.Position = UDim2.fromScale(Position.X, Position.Y)
		SliderCoverOuter.Position = UDim2.fromScale(Position.X, Position.Y)
	end
	
	function SliderObject.SetSnakingOut(t)
		local isLastSlideReverse = (slideCount % 2 == 0)
		
		if isLastSlideReverse then
			-- This is easy, just do the SetSnakingIn and done
			SliderObject.SetSnakingIn(1-t, true)
		else
			-- But this isn't...
			for _, data in pairs(PointData) do
				local obj = data[1]
				local objOuter = data[2]
				local tStart = data[7]
				local tEnd = tStart+data[8]
				if t-tStart > data[8] then
					obj.Visible = false
					objOuter.Visible = false
					continue
				else
					local Ratio = math.clamp((t-tStart) / (data[8]), 0, 1)
					obj.Body.Overlay.Size = UDim2.fromScale(1-Ratio,1)
					objOuter.Body.Overlay.Size = UDim2.fromScale(1-Ratio,1)
					local Pos = PositionPoint(data[3],data[4], Ratio)
					obj.Position = UDim2.fromScale(Pos.X, Pos.Y)
					objOuter.Position = UDim2.fromScale(Pos.X, Pos.Y)
					if Ratio < tEnd and Ratio >= tStart then
						obj.InnerHead.Visible = false
						objOuter.BackgroundTransparency = 1
						break
					end
				end
			end
			local Position = SliderObject.PositionOf(t)
			newEndSliderInner.Visible = true
			newEndSliderOuter.Visible = true
			newEndSliderInner.Position = UDim2.fromScale(Position.X, Position.Y)
			newEndSliderOuter.Position = UDim2.fromScale(Position.X, Position.Y)
		end
	end
	
	function SliderObject.setFollowCirclePosition(t, isReverse)
		local Position = SliderObject.PositionOf(t, isReverse)
		SliderFollowCircle.Position = UDim2.fromScale(Position.X,Position.Y)
	end
	
	function SliderObject.isCursorInFollowCircle(position:Vector2, t:number, isReverse:boolean)
		local FollowPosition = SliderObject.PositionOf(t, isReverse)
		local Distance = (position - FollowPosition*Vector2.new(512,384)).Magnitude
		
		return Distance <= circleRadius/2 * 2.25
	end
	local currentReverseArrow = 1
	
	function SliderObject.setReverseArrowBeat(t)
		t = sineOut(t)
		for i = currentReverseArrow, #ReverseArrows do
			local arrow = ReverseArrows[i]
			if not arrow then return end
			local size = lerp(1, 1.25, t)
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
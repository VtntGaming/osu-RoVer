--[LOCATION]:[Workspace.OsuConvert.sliderTools]
--!strict
local sliderTools = {}
local converterTools = require(script.Parent.converterTools)

--315,336,57671,102,0,B|352:326|352:326|372:332|372:332|440:317,2,100,0|0|0,3:2|0:2|0:2,0:2:0:0:

local function toVector2(str:string):Vector2
	local _convert = str:split(":")	
	return Vector2.new(tonumber(_convert[1]), tonumber(_convert[2]))
end

function isEqual(a, b)
	return a.X == b.X and a.Y == b.Y
end

local function spiltCurveSection(curvePoints:{Vector2}):{{Vector2}}
	-- if the game detect a double point, it will be the cutted to the next section
	-- before there's no such a processing like this, so I leave it all "linear path"

	local sections:{{Vector2}} = {}
	local currentSection = {}
	local previous = nil

	local function newSection()
		currentSection = {}
		sections[#sections+1] = currentSection
	end

	newSection()

	for _, current in pairs(curvePoints) do
		if previous and isEqual(previous, current) then
			-- make a new section
			newSection()
		end
		-- add the point to current section
		currentSection[#currentSection+1] = current
		previous = current
	end

	return sections
end

-- Bezier calculation

local function getSectionLength(curvePoints:{Vector2})
	local length = 0

	local previous:Vector2? = nil
	for _, point in pairs(curvePoints) do
		if previous then
			length += (previous - point).Magnitude
		else
			previous = point
		end
	end

	return length
end

function benzier(curvePoints:{Vector2}, SliderLength:number, CurrentLength:number)
	local sectionLength = getSectionLength(curvePoints)
	local NumberOfPoints = math.clamp(sectionLength/20, 10, 50) -- the curve per point
	local NewCurvePoints = {}

	local function GetBenzierPosition(t)
		local PointData = curvePoints
		local PointsLeft = #PointData
		for i = PointsLeft+1,3,-1 do
			local PointDataNew = {}
			for a = 1,PointsLeft-1 do
				PointDataNew[#PointDataNew+1] = PointData[1]:Lerp(PointData[a+1], t)
			end
			PointData = PointDataNew
			PointsLeft-=1
		end
		return PointData[1]
	end

	local Previous:Vector2?

	for i = 1,NumberOfPoints do
		local newPoint = GetBenzierPosition((i-1)/(NumberOfPoints-1))
		NewCurvePoints[#NewCurvePoints+1] = newPoint

		if Previous then
			CurrentLength += (Previous - newPoint).Magnitude
			if CurrentLength >= SliderLength then
				break
			end
		end

		Previous = newPoint
	end

	return NewCurvePoints, CurrentLength
end

-- Perfect circle calculation

function findCircleCenter(A, B, C, SliderLength):Vector2?
	local function midpoint(p1:Vector2, p2:Vector2)
		return p1:Lerp(p2, 0.5)
	end

	local function perpendicularSlope(p1:Vector2, p2:Vector2)
		local dx = p2.X - p1.X
		local dy = p2.Y - p1.Y
		-- Avoid division by zero
		if dx == 0 then return 0 end
		if dy == 0 then return math.huge end
		return -dx / dy
	end

	local midAB = midpoint(A, B)
	local midBC = midpoint(B, C)

	local slopeAB = perpendicularSlope(A, B)
	local slopeBC = perpendicularSlope(B, C)

	-- Line: y = m*x + b => b = y - m*x
	local b1 = midAB.Y - slopeAB * midAB.X
	local b2 = midBC.Y - slopeBC * midBC.X

	-- Solve for intersection:
	-- m1*x + b1 = m2*x + b2 => (m1 - m2)*x = b2 - b1 => x = (b2 - b1) / (m1 - m2)

	local Slope = math.abs(slopeAB - slopeBC)

	local centerX
	if slopeAB == slopeBC or Slope > 100 or Slope ~= Slope then
		return nil -- Points are colinear, no circle
	else
		centerX = (b2 - b1) / (slopeAB - slopeBC)
	end

	local centerY = slopeAB * centerX + b1
	local PointCenter = Vector2.new(centerX, centerY)


	return PointCenter
end

local function getDirection(A:Vector2, B:Vector2, C:Vector2)
	local AB = Vector2.new(B.X - A.X, B.Y - A.Y)
	local AC = Vector2.new(C.X - A.X, C.Y - A.Y)

	local cross = AB.X * AC.Y - AB.Y * AC.X

	if cross > 0 then
		return 1
	elseif cross < 0 then
		return -1
	else
		return 0 -- We will make the path linear instead
	end
end

local function perfectCircle(SliderCurvePoints:{Vector2}, SliderLength:number):{Vector2}
	local NumberOfPoints = math.clamp(math.round(SliderLength/20), 10, 100)
	local NewCurvePoints = {}

	local PointA = SliderCurvePoints[1]
	local PointB = SliderCurvePoints[2]
	local PointC = SliderCurvePoints[3]
	

	local PointCenter = findCircleCenter(PointA, PointB, PointC, SliderLength)

	if PointCenter == nil then -- Colinear, return the original value
		return SliderCurvePoints
	end

	local Radius = (PointA - PointCenter).Magnitude
	local Perimeter = 2 * math.pi * Radius
	local Ratio = math.min(1, SliderLength/Perimeter)
	local Direction = getDirection(PointA, PointB, PointC)
	local offset = PointA - PointCenter

	if Direction == 0 then -- Colinear
		return SliderCurvePoints
	end

	local function getPointOnCircle(t)
		-- wrap t in [0,1]
		t = math.clamp(t, 0, 1)
		-- angle = start + direction * (fraction‑of‑circle) * 2π
		local angle = math.atan2(offset.Y, offset.X) + Direction * (t * Ratio * 2 * math.pi)
		return Vector2.new(
			PointCenter.X + math.cos(angle) * Radius,
			PointCenter.Y + math.sin(angle) * Radius
		)
	end

	for i = 0, NumberOfPoints-1 do
		local Point = getPointOnCircle(i/(NumberOfPoints-1))
		NewCurvePoints[#NewCurvePoints+1] = Point
	end
	
	return NewCurvePoints
end

local function linearSlider(rawCurve:{Vector2}, sliderLength:number)
	local pointA = rawCurve[1]
	local pointB = rawCurve[2]

	local length = (pointA - pointB).Magnitude
	pointB = pointA:Lerp(pointB, sliderLength/length)
	
	return {pointA, pointB}
end

-- Main function

function sliderTools.convertToBaseCurve(raw:string, headPosition:Vector2, isHR:boolean?)
	local curveType
	local curvePoints = {}
	curvePoints[1] = headPosition	-- Include the circle position
	for i, str in pairs(raw:split("|")) do
		if i == 1 then
			curveType = str
		else
			local _vector = toVector2(str)
			if isHR then
				_vector = Vector2.new(_vector.X, 384 - _vector.Y)
			end
			curvePoints[#curvePoints+1] = _vector
		end
	end
	return curveType, curvePoints
end


function sliderTools.convertToSliderCurve(headPosition:Vector2, raw:string, sliderLength:number, isHR:boolean?)
	local curveType, rawCurve = sliderTools.convertToBaseCurve(raw, headPosition, isHR)
	local returnPoints = {}
	if curveType == "B" and #rawCurve > 2 then
		local function insert(newPoints)
			for _, point in pairs(newPoints) do
				-- ensureing there's no more duplicate points

				if #returnPoints <= 0 or not isEqual(returnPoints[#returnPoints],point) then
					returnPoints[#returnPoints+1] = point
				end
			end
		end
		
		local PointSections = spiltCurveSection(rawCurve)
		local CurrentLength = 0
		
		for _, section in pairs(PointSections) do
			if CurrentLength >= sliderLength then
				break
			end

			if #section <= 2 then -- it's a linear path, just throw it directly
				if #section <= 1 then break end -- it must be the last section
				local A = section[1]
				local B = section[2]
				local sectionLength = (A-B).Magnitude
				local nextLength = CurrentLength + sectionLength

				if nextLength <= sliderLength then
					insert(section)
					if nextLength >= sliderLength then
						break
					end
					CurrentLength = nextLength
				else
					local Alpha = math.clamp((sliderLength - nextLength) / sectionLength, 0, 1)
					section[2] = A:Lerp(B, Alpha)
					insert(section)
					CurrentLength = sectionLength
					break
				end
			else
				local newCurve, newLength = benzier(section, sliderLength, CurrentLength)
				CurrentLength = newLength
				insert(newCurve)
			end
		end		
	elseif curveType == "P" and #rawCurve > 2 then
		returnPoints = perfectCircle(rawCurve, sliderLength)
	else	-- "L" - Linear
		returnPoints = linearSlider(rawCurve, sliderLength)
	end
	
	if #returnPoints < 2 then
		returnPoints = linearSlider(rawCurve, sliderLength)
	end
	
	return returnPoints
end

return sliderTools
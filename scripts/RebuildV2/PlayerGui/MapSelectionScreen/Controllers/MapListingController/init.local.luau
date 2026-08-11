local ScrollSpeed = 1

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local MapsetItem = require(script.MapsetItem)
local MapList = workspace.BeatmapListings:GetChildren()

local CurrentPosition = 0
local MaxPosition = #MapList
local TargetPosition = CurrentPosition
local RenderCap = 10
local MainUI = script.Parent.Parent
local ContainerFrame = MainUI.MainFrame.MapListing.Container

local Items = {} :: {MapsetItem.MapsetItem}
local ActiveItems = {} :: {MapsetItem.MapsetItem}

function GetValue(FileData,Name,Spaces)
	if not Spaces or Spaces < 0 then
		Spaces = 1
	end
	local _,e = string.find(FileData,Name)
	if not e then
		return nil
	end
	local s,_ = string.find(FileData,"\n",e)

	local Value = string.sub(FileData,e+1+Spaces,s-1)

	return Value
end

local function FetchMap()
	
end

local CachedData = {}

local function GetInformationOfMap(mapFile)
	if CachedData[mapFile] then
		return CachedData[mapFile]
	end
	
	local mapData = require(mapFile)
	local title = GetValue(mapData,"Title:",0)
	local artist = GetValue(mapData,"Artist:",0)
	local mapper = GetValue(mapData,"Creator:",0)
	
	local data = {
		Title = title,
		Artist = artist,
		Mapper = mapper
	}
	
	CachedData[mapFile] = data
	return data
end

table.sort(MapList, function(map1, map2)
	local data1 = GetInformationOfMap(map1)
	local data2 = GetInformationOfMap(map2)
	
	if data1.Title:lower() ~= data2.Title:lower() then
		return data1.Title:lower() < data2.Title:lower()
	elseif data1.Artist:lower() ~= data2.Artist:lower() then
		return data1.Artist:lower() < data2.Artist:lower()
	else
		return data1.Mapper:lower() < data2.Mapper:lower()
	end	
end)

for i = 1, #MapList do
	local mapFile = MapList[i]
	local data = GetInformationOfMap(mapFile)
	local item = MapsetItem.new(i, mapFile)
	item.Frame.Position = UDim2.fromScale(0, (i-1) * 0.15)
	local mainFrame = item.Frame.Canvas.MainFrame
	mainFrame.Title.Text = data.Title
	mainFrame.Artist.Text = data.Artist
	mainFrame.Mapper.Text = `Mapped by {data.Mapper}`
	Items[i] = item
end

for _, item in ipairs(Items) do
	item:Setup()
end

local function UpdateContainerPosition()
	local pos = CurrentPosition
	
	ContainerFrame.Position = UDim2.fromScale(0, 0.5 - CurrentPosition * 0.15)
	
	local minIndex = math.max(1, CurrentPosition // 1 - RenderCap)
	local maxIndex = math.min(MaxPosition, CurrentPosition // 1 + RenderCap)
	
	for i = #ActiveItems, 1, -1 do
		local item = ActiveItems[i]		

		local index = item.Index

		if index < minIndex or index > maxIndex then
			-- Out of range
			item.Frame.Parent = nil
			table.remove(ActiveItems, index)
		end
	end
	
	for index = minIndex, maxIndex do
		local item = Items[index]
		if not table.find(ActiveItems, item) then
			table.insert(ActiveItems, item)
		end

		item.Frame.Parent = ContainerFrame
		item:SetPositionOffset(math.clamp(math.abs(CurrentPosition - index) / 5, 0, 1))
	end
end

local function GetItemFromMap(map: Instance)
	for _, item in ipairs(Items) do
		if item.Reference == map then
			return item
		end
	end
	
	return nil
end

local function SetTarget(target: number)
	TargetPosition = math.clamp(target, 0, MaxPosition)
end

local function SetCurrent(current: number)
	CurrentPosition = current
end

script.Parent.FocusToMap.Event:Connect(function(map)
	local item = GetItemFromMap(map)
	
	if item then
		local index = item.Index
		
		CurrentPosition = index - 10
		SetTarget(index)
		item:SetFocus(true)
	end
end)

script.Focused.Event:Connect(function(index)
	SetTarget(index)
	UpdateContainerPosition()
end)

local LastTouchPosition: Vector3?
local LastForce = 0
local LastTouch = 0
local Force = 0

UserInputService.InputChanged:Connect(function(input)
	if not MainUI.Enabled then
		return
	end
	
	local function ProcessMovement()
		local currentPos = input.Position
		if not LastTouchPosition then
			LastTouchPosition = currentPos
		end
		
		local offset = (LastTouchPosition - currentPos).Y
		local screenSizeVertical = workspace.CurrentCamera.ViewportSize.Y
		
		local touchRatio = offset / screenSizeVertical * 7
		
		SetTarget(TargetPosition + touchRatio)
		LastTouchPosition = currentPos
		LastTouch = time()
		LastForce = touchRatio
	end
	
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		local change = math.sign(input.Position.Z)
		
		SetTarget(math.min(MaxPosition, TargetPosition - change * ScrollSpeed))
		
		UpdateContainerPosition()
	elseif input.UserInputType == Enum.UserInputType.MouseMovement then
		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			local verticalPos = input.Position.Y + 58
			local screenSizeVertical = workspace.CurrentCamera.ViewportSize.Y
			
			local ratio = math.clamp((verticalPos - screenSizeVertical * 0.1) / (screenSizeVertical * 0.8), 0, 1)
			
			SetTarget(MaxPosition * ratio)
			
			UpdateContainerPosition()
		elseif UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
			ProcessMovement()
		end
	elseif input.UserInputType == Enum.UserInputType.Touch then
		ProcessMovement()
	end
end)

local OutFocusInput = {
	Enum.UserInputType.MouseButton1,
	Enum.UserInputType.Touch,
	Enum.UserInputType.Focus
}

UserInputService.InputEnded:Connect(function(input)
	if table.find(OutFocusInput, input.UserInputType) then
		LastTouchPosition = nil
		Force = LastForce
	end
end)

local CanRender = false

RunService.PreRender:Connect(function(dt: number)
	CurrentPosition += (TargetPosition - CurrentPosition) * dt * 10
	
	local SlideElapsed = time() - LastTouch
	if SlideElapsed < 2 then
		local SlideMultiplier = 0.995 ^ (math.max(0, SlideElapsed * 1000))
		local SlideSpeed = Force * SlideMultiplier * dt * 50
		SetTarget(TargetPosition + SlideSpeed)
	end
	
	local preciseEnough = false
	
	if math.abs(CurrentPosition - TargetPosition) < 0.05 then
		preciseEnough = true
	end
	
	if preciseEnough then
		if CanRender then
			CanRender = false
		else
			local needRenderMore = false
			for _, item in ipairs(ActiveItems) do
				local focusProgress = item.FocusProgress
				local targetProgress = item.Focused and 0 or 1
				local minimumProgress = math.abs(focusProgress - targetProgress)
				
				if minimumProgress > 0.05 then
					needRenderMore = true
					break
				end
			end
			
			if not needRenderMore then
				return
			end
		end
	else
		CanRender = true
	end
	
	if CanRender then
		UpdateContainerPosition()		
	end
	
	for _, item in ipairs(ActiveItems) do
		item:UpdateInternal(dt)
	end
end)

UpdateContainerPosition()

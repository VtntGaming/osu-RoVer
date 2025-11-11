--[LOCATION]:[StarterGui.BeatmapListing.MainFrame.MainFrame.WorkingScript.ListingProcessor]
local MapList = {}
local SortData = {
	Name = {},
	Artist = {},
	Diff = {},
	DiffRev = {},
	CustomSort = {}
}

local CurrentSort = "Name"
local mapModuleVersion = workspace.BeatmapVersion
local mapVersion = mapModuleVersion.Value
local FirstLoad = true
local isOpen = false
local NavigationSwitching = false
local wait = require(workspace.WaitModule)

local ListingButton = game.Players.LocalPlayer.PlayerGui.BG.BeatmapChooseButton
local ListingFrame = script.Parent.Parent.Listing
local CurrentChoosing
local CurrentDiffChoosing
local CurrentDiffChoosingID = 0
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ExternalFunction_Actor = game.Players.LocalPlayer.PlayerScripts.ExternalFunction_Actor

local TargetListingFolder = workspace.Beatmaps
if #workspace.ProcessingBeatmap:GetChildren() >= 1 then
	TargetListingFolder = workspace.ProcessingBeatmap
end

mapModuleVersion.Changed:Connect(function()
	local newValue = mapModuleVersion.Value
	if newValue > mapVersion then
		mapVersion = newValue
		FirstLoad = true
		warn(`The client map version has updated to version: {newValue}`)
	end
end)

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

function CloneTable(TableData,ResetOrder)
	local NewTable = {}
	for key,value in pairs(TableData) do
		if ResetOrder then
			key = #NewTable+1
		end
		NewTable[key] = value
	end
	return NewTable
end

local emptyvalue = Instance.new("NumberValue")
emptyvalue.Value = 0

function LoadListing()
	local env = ExternalFunction_Actor.ProcessCommand:Invoke("MapListing_ListingProcessor_LoadListing",{
		TargetListingFolder = TargetListingFolder,
		MapList = MapList,
		emptyvalue = emptyvalue
	})
	
	MapList = env.MapList
	--[[for _,MapFile in pairs(TargetListingFolder:GetChildren()) do
		local MapData = require(MapFile)

		local BeatmapID = GetValue(MapData,"BeatmapID:",0)
		local BeatmapSetID = GetValue(MapData,"BeatmapSetID:",0)


		if BeatmapSetID and BeatmapID then


			local Title = GetValue(MapData,"Title:",0)
			local Artist = GetValue(MapData,"Artist:",0)
			local Creator = GetValue(MapData,"Creator:",0)


			local DiffName = GetValue(MapData,"Version:",0)
			local HP = tonumber(GetValue(MapData,"HPDrainRate:",0))
			local CS = tonumber(GetValue(MapData,"CircleSize:",0))
			local OD = tonumber(GetValue(MapData,"OverallDifficulty:",0))
			local AR = tonumber(GetValue(MapData,"ApproachRate:",0))
			local DR = MapFile:FindFirstChild("Difficulty") and MapFile.Difficulty.Value or 0

			local s,e = string.find(DiffName,"'s")
			if s then
				Creator = string.sub(DiffName,1,s-1)
				--DiffName = string.sub(DiffName,e+2,#DiffName)
			end

			if not MapList[BeatmapSetID] then
				MapList[BeatmapSetID] = {
					Metadata = {
						Title = Title,
						Artist = Artist,
						Creator = GetValue(MapData,"Creator:",0),
						Source = GetValue(MapData,"Source:",0),
						Tags = GetValue(MapData,"Tags:",0),
						Mapper = GetValue(MapData,"Creator:",0)
					},
					BeatmapSetID = BeatmapSetID,
					DiffListing = {},
					SortPosition = {
						Name = 1, Diff = 1
					}
				}
			end


			MapList[BeatmapSetID].DiffListing[#MapList[BeatmapSetID].DiffListing+1] = {
				DiffName = DiffName,
				Creator = Creator,
				DiffRating = (MapFile:FindFirstChild("Difficulty") or emptyvalue).Value,
				BeatmapID = BeatmapID,
				DiffData = {HP = HP, CS = CS, OD = OD, AR = AR, DR = DR},
				MapFile = MapFile,
				isCurrentlyMatched = true
			}

		end
	end]]
end

function compareString(s1, s2)
	
end

function SortListing()
	-- Local set diff sorting
	for _,MapsetData in pairs(MapList) do
		local DiffListing = MapsetData.DiffListing

		table.sort(DiffListing,function(map1,map2)
			return map1.DiffRating > map2.DiffRating
		end)
	end

	-- Name sorting
	SortData.Name = CloneTable(MapList,true)

	table.sort(SortData.Name,function(Set1,Set2)
		local Name1 = Set1.Metadata.Title
		local Name2 = Set2.Metadata.Title
		
		local Artist1 = Set1.Metadata.Artist
		local Artist2 = Set2.Metadata.Artist
		
		if Name1 ~= Name2 then
			return Name1 < Name2
		elseif Artist1 ~= Artist2 then
			return Artist1 < Artist2
		else
			return tonumber(Set1.BeatmapSetID) > tonumber(Set2.BeatmapSetID)
		end
	end)

	-- Artist sorting
	SortData.Artist = CloneTable(MapList,true)

	table.sort(SortData.Artist,function(Set1,Set2)
		local Name1 = Set1.Metadata.Title
		local Name2 = Set2.Metadata.Title

		local Artist1 = Set1.Metadata.Artist
		local Artist2 = Set2.Metadata.Artist

		if Artist1 ~= Artist2 then
			return Artist1 < Artist2
		elseif Name1 ~= Name2 then
			return Name1 < Name2
		else
			return tonumber(Set1.BeatmapSetID) > tonumber(Set2.BeatmapSetID)
		end
	end)


	-- Diff sorting
	SortData.Diff = CloneTable(MapList,true)
	table.sort(SortData.Diff,function(set1,set2)
		return set1.DiffListing[1].DiffRating < set2.DiffListing[1].DiffRating
	end)

	-- Diff reverse sorting
	SortData.DiffRev = CloneTable(MapList,true)
	table.sort(SortData.DiffRev,function(set1,set2)
		return set1.DiffListing[#set1.DiffListing].DiffRating > set2.DiffListing[#set2.DiffListing].DiffRating
	end)
end

local BaseScrollPosition
local lastRequest = 0

script.Parent.Parent.ReturnHitbox.MouseMoved:Connect(function()
	if tick()-lastRequest > 1.5 and BaseScrollPosition then
		lastRequest = tick()
		script.Parent.CustomScrollChange:Fire(BaseScrollPosition ,0.5)
	end
end)


function ChooseDiff(DiffFrame,diffdata,DoNotLoadMap)
	if CurrentDiffChoosing and CurrentDiffChoosing.Parent and CurrentDiffChoosing ~= DiffFrame then
		TweenService:Create(CurrentDiffChoosing.MainFrame.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Transparency = 0.75}):Play()
		TweenService:Create(CurrentDiffChoosing.MainFrame.SelectEffect, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
	end

	CurrentDiffChoosing = DiffFrame
	TweenService:Create(DiffFrame.MainFrame.SelectEffect, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {BackgroundTransparency = 0.5}):Play()
	TweenService:Create(DiffFrame.MainFrame.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Transparency = 0}):Play()

	if CurrentDiffChoosingID ~= diffdata.BeatmapID and not DoNotLoadMap then
		CurrentDiffChoosingID = diffdata.BeatmapID
		game.Players.LocalPlayer.PlayerGui.PlayScreen.MapListingChange:Fire(diffdata.MapFile,diffdata.BeatmapID)
	end

	script.Parent.Parent.Parent.Parent.CurrentBeatmap.Value = diffdata.MapFile
	BaseScrollPosition = 60-DiffFrame.Parent.Parent.Parent.Parent.Parent.Parent.AbsoluteSize.Y*0.5 + DiffFrame.Parent.Parent.Parent.Parent.Parent.LayoutOrder*80 + DiffFrame.LayoutOrder * 52
	script.Parent.CustomScrollChange:Fire(BaseScrollPosition ,0.5)
end

local CurrentSetConnection
local CurrentDiffNameConnection = {}

function ChooseSet(MapFrame,Data,CustomDiffOrder,CustomMapID,DoNotLoadMap)
	
	if #CurrentDiffNameConnection > 0 then
		for _, c in pairs(CurrentDiffNameConnection) do
			c:Disconnect()
		end

		CurrentDiffNameConnection = {}
	end
	
	CurrentDiffNameConnection[#CurrentDiffNameConnection+1] = script.Parent.UpdateRelatedMapper.Event:Connect(function(mapperData)
		if mapperData["set_"..tostring(Data.BeatmapSetID)] then
			local mapperName = mapperData["set_"..tostring(Data.BeatmapSetID)]
			if mapperName ~= Data.Metadata.Mapper then
				mapperName = mapperName..string.format(" (%s)", Data.Metadata.Mapper)
			end
			MapFrame.MainFrame.MapInfo.MapperName.Text = "mapset by <font size='16' weight = 'SemiBold'>"..mapperName.."</font>"
		end
	end)
	
	local DiffStoreLocation = MapFrame.MainFrame.DifficultyListing.Actual:FindFirstChild("Base") 
		or MapFrame.MainFrame.DifficultyListing.Overlay:FindFirstChild("Base")
	
	for _,a in pairs(DiffStoreLocation:GetChildren()) do
		if not a:IsA("UIListLayout") then
			a:Destroy()
		end
	end


	if CurrentChoosing then
		if CurrentChoosing == MapFrame then return end
		local DiffStoreLocation = CurrentChoosing.MainFrame.DifficultyListing.Actual:FindFirstChild("Base") 
			or CurrentChoosing.MainFrame.DifficultyListing.Overlay:FindFirstChild("Base")
		DiffStoreLocation.Parent = CurrentChoosing.MainFrame.DifficultyListing.Overlay
		local LocalChoosing = CurrentChoosing
		
		TweenService:Create(CurrentChoosing.MainFrame.DifficultyListing.Overlay, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {GroupTransparency = 1}):Play()
		
		TweenService:Create(CurrentChoosing.MainFrame.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Transparency = 0.75}):Play()
		TweenService:Create(CurrentChoosing,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(1,0,0,60)}):Play()
	end

	if CurrentChoosing == MapFrame then
		--CurrentChoosing = nil
		return -- Do nothing
	end

	CurrentChoosing = MapFrame
	--script.Parent.CustomScrollChange:Fire(MapFrame.LayoutOrder*80-60,1)
	

	local diffListing = CloneTable(Data.DiffListing)
	if CurrentSort == "CustomSort" then
		local new = {}
		for i,a in pairs(diffListing) do
			if a.isCurrentlyMatched then
				new[#new+1] = a
			end
		end
		diffListing = new
	end

	local RandomMap = math.random(1,#diffListing)
	if CustomMapID then
		RandomMap = -1
	elseif CustomDiffOrder == 1 then
		RandomMap = 1
	elseif CustomDiffOrder == 2 then
		RandomMap = #diffListing
	end

	local CurrentSetDiffOrder = RandomMap

	local function ConvertDiffName(Name)

		local characterList = {
			["<"] = "&lt;",
			[">"] = "&gt;",
			['"'] = "&quot;",
			["'"] = "&apos;",
			["&"] = "&amp;"
		}


		local Next = 1

		while true do -- yes

			local isLoop = false
			for i = Next,#Name do
				local Replacement = characterList[string.sub(Name,i,i)]
				if Replacement then
					if Replacement == "&amp;" and string.sub(Name,i,i+4) == "&amp;"  then
						continue
					end
					Name = string.sub(Name,1,i-1)..Replacement..string.sub(Name,i+1,#Name)
					Next = i+1
					isLoop = true
					break
				end
			end

			if not isLoop then break end
		end

		return Name
	end
	
	if MapFrame.MainFrame.DifficultyListing.Actual:FindFirstChild("Base") then
		MapFrame.MainFrame.DifficultyListing.Actual.Base.Parent = MapFrame.MainFrame.DifficultyListing.Overlay
	end

	for order,diffdata in pairs(diffListing) do
		local DiffFrame = script.Diff:Clone()
		DiffFrame.Parent = MapFrame.MainFrame.DifficultyListing.Overlay.Base
		DiffFrame.LayoutOrder = #diffListing-order
		DiffFrame.ZIndex = order
		DiffFrame.MainFrame.DifficultyInfo.Text = string.format("<b><font size='14' color = '#ffff9b'>%s</font></b><font size = '12'> mapped by <b>%s</b></font>",ConvertDiffName(diffdata.DiffName),diffdata.Creator)
		CurrentDiffNameConnection[#CurrentDiffNameConnection+1] = script.Parent.UpdateRelatedMapper.Event:Connect(function(data)
			if data[tostring(diffdata.BeatmapID)] then
				DiffFrame.MainFrame.DifficultyInfo.Text = string.format("<b><font size='14' color = '#ffff9b'>%s</font></b><font size = '12'> mapped by <b>%s</b></font>",ConvertDiffName(diffdata.DiffName),data[tostring(diffdata.BeatmapID)])
			end
		end)
		--DiffFrame.MainFrame.DifficultyDisplay.DiffDisplay.Text = string.format("%.2f",diffdata.DiffRating)
		spawn(function()
			local s = tick()
			local animTime = (1+(#diffListing-order)*0.1) * 0.5
			local value = Instance.new("NumberValue")
			value.Value = math.max(0,diffdata.DiffRating - 2)
			TweenService:Create(value,TweenInfo.new(animTime,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Value = diffdata.DiffRating}):Play()
			while wait() and DiffFrame.Parent and tick() - s < animTime do
				DiffFrame.MainFrame.DifficultyDisplay.DiffDisplay.Text = string.format("%.2f",value.Value)
			end
			if DiffFrame.Parent then
				DiffFrame.MainFrame.DifficultyDisplay.DiffDisplay.Text = string.format("%.2f",diffdata.DiffRating)
			end
		end)
		local DiffFormat = diffdata.DiffRating
		if DiffFormat > 10 then DiffFormat = 10 end

		local HColor =  (diffdata.DiffRating <= 1.5 and 200) or (diffdata.DiffRating <= 4.5 and (1-(diffdata.DiffRating/4.5))*200) or (diffdata.DiffRating <= 6.5 and 360-((diffdata.DiffRating-4.5)/2)*120) or (diffdata.DiffRating <= 9.9 and 240) or 0
		local SColor = (diffdata.DiffRating <= 8.5 and 255) or (diffdata.DiffRating <= 10 and 255 - (diffdata.DiffRating-8.5)*170) or (diffdata.DiffRating <= 12 and (diffdata.DiffRating-10)*127.5) or 255--(diffdata.DiffRating <= 6.5 and 140) or (140 + (diffdata.DiffRating-6.5)*40)
		local VColor = (diffdata.DiffRating <= 6.5 and 255) or (diffdata.DiffRating < 9 and 255 - (diffdata.DiffRating-6.5)*102) or 0

		HColor /= 360
		SColor /= 255
		VColor /= 255
		

		if diffdata.DiffRating >= 6.3 then
			DiffFrame.MainFrame.DifficultyDisplay.DiffDisplay.UIStroke.Enabled = true
			DiffFrame.MainFrame.DifficultyDisplay.Frame.Diff.UIStroke.Enabled = true
		end

		local BeatmapDiffColor = Color3.fromHSV(HColor,SColor,VColor)
		local EffectColor = Color3.fromHSV(math.max(0,HColor-0.05),math.max(SColor-0.1,1),math.min(VColor+0.1,1))

		DiffFrame.MainFrame.DifficultyDisplay.DiffDisplay.TextColor3 = BeatmapDiffColor
		DiffFrame.MainFrame.DifficultyDisplay.Frame.Diff.BackgroundColor3 = BeatmapDiffColor
		DiffFrame.MainFrame.DifficultyDisplay.Frame.Diff.Effect.BackgroundColor3 = EffectColor
		

		diffdata.DiffFrame = DiffFrame

	TweenService:Create(DiffFrame.MainFrame.DifficultyDisplay.Frame.Diff,TweenInfo.new(0.5+(#diffListing-order)*0.1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(DiffFormat/10,0,1,0)}):Play()
		if order ==  RandomMap or CustomMapID == diffdata.BeatmapID then
			CurrentSetDiffOrder = order
			ChooseDiff(DiffFrame,diffdata,DoNotLoadMap)
		end

		DiffFrame.MainFrame.Hitbox.MouseButton1Click:Connect(function()
			CurrentSetDiffOrder = order
			ChooseDiff(DiffFrame,diffdata)
		end)
		
		DiffFrame.MainFrame.Hitbox.MouseEnter:Connect(function()
			TweenService:Create(DiffFrame.MainFrame.HoverEffect, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {BackgroundTransparency = 0.75}):Play()
		end)
		
		DiffFrame.MainFrame.Hitbox.MouseLeave:Connect(function()
			TweenService:Create(DiffFrame.MainFrame.HoverEffect, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
		end)
	end

	if CurrentSetConnection then
		CurrentSetConnection:Disconnect()
	end

	CurrentSetConnection = UserInputService.InputBegan:Connect(function(data)
		if NavigationSwitching or not isOpen then return end
		NavigationSwitching = true

		local function GetSetOrder(MapFrame)
			for i,Data in pairs(SortData[CurrentSort]) do
				if Data.MapFrame == MapFrame then
					return i
				end
			end
		end

		local KeyCode = data.KeyCode
		if KeyCode == Enum.KeyCode.Up or KeyCode == Enum.KeyCode.Down then
			if KeyCode == Enum.KeyCode.Down then
				if CurrentSetDiffOrder > 1 then
					CurrentSetDiffOrder -= 1
				else
					local SetOrder = GetSetOrder(MapFrame)

					if SetOrder < #SortData[CurrentSort] then
						SetOrder += 1
					else
						SetOrder = 1
					end
					local ChoosenSet = SortData[CurrentSort][SetOrder]
					ChooseSet(ChoosenSet.MapFrame,ChoosenSet,2)
					NavigationSwitching = false
					return
				end
			elseif KeyCode == Enum.KeyCode.Up then
				if CurrentSetDiffOrder < #diffListing then
					CurrentSetDiffOrder += 1
				else
					local SetOrder = GetSetOrder(MapFrame)

					if SetOrder > 1 then
						SetOrder -= 1
					else
						SetOrder = #SortData[CurrentSort]
					end

					local ChoosenSet = SortData[CurrentSort][SetOrder]
					ChooseSet(ChoosenSet.MapFrame,ChoosenSet,1)
					NavigationSwitching = false
					return
				end

			end
			local ChoosenDiff = diffListing[CurrentSetDiffOrder]
			ChooseDiff(ChoosenDiff.DiffFrame,ChoosenDiff)
		end

		NavigationSwitching = false
	end)

	local DiffSize = MapFrame.MainFrame.DifficultyListing.Overlay.Base.UIListLayout.AbsoluteContentSize.Y
	local FullSize = DiffSize + 80

	MapFrame.MainFrame.DifficultyListing.Overlay.Base.UIListLayout.Padding = UDim.new(0,-40)
	MapFrame.MainFrame.DifficultyListing.Overlay.Size = UDim2.new(2,0,(#Data.DiffListing+1)*2, 0)
	MapFrame.MainFrame.DifficultyListing.Actual.Size = UDim2.new(2,0,(#Data.DiffListing+1)*2, 0)
	MapFrame.MainFrame.DifficultyListing.Overlay.Base.Size = UDim2.new(0.5,0,1/((#Data.DiffListing+1)*2), 0)
	TweenService:Create(MapFrame.MainFrame.DifficultyListing.Overlay, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {GroupTransparency = 0}):Play()
	spawn(function()
		wait(0.25)
		if MapFrame.MainFrame.DifficultyListing.Overlay:FindFirstChild("Base") then
			MapFrame.MainFrame.DifficultyListing.Overlay.Base.Parent =  MapFrame.MainFrame.DifficultyListing.Actual
		end
	end)
	TweenService:Create(MapFrame.MainFrame.DifficultyListing.Overlay.Base.UIListLayout,TweenInfo.new(1+#Data.DiffListing*0.05,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Padding = UDim.new(0,12)}):Play()
	TweenService:Create(MapFrame,TweenInfo.new(1+#Data.DiffListing*0.05,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(1,0,0,FullSize)}):Play()
	TweenService:Create(MapFrame.MainFrame.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Transparency = 0}):Play()
end

local UpdatePosEvent = Instance.new("BindableEvent")

UpdatePosEvent.Event:Connect(function()
	BaseScrollPosition = CurrentChoosing.LayoutOrder*80-60
	script.Parent.CustomScrollChange:Fire(BaseScrollPosition,0.5)
end)

function BuildListing()
	for _,Data in pairs(MapList) do
		local MapFrame = script.BeatmapFrame:Clone()
		MapFrame.Parent = ListingFrame

		Data.MapFrame = MapFrame
		local _connections:{[any]:RBXScriptConnection} = {}

		local function UpdatePosition()
			if MapFrame.LayoutOrder == -1 then return end -- the frame is invisible on the filter result

			local MaxRender = #Data.DiffListing*50 + 500

			if MapFrame.AbsolutePosition.Y >= -MaxRender  and MapFrame.AbsolutePosition.Y < workspace.CurrentCamera.ViewportSize.Y+MaxRender then
				MapFrame.MainFrame.Visible = true
			else
				MapFrame.MainFrame.Visible = false
			end
		end

		_connections.UpdateCanvas = ListingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(UpdatePosition)
		_connections.UpdatePosEvent = UpdatePosEvent.Event:Connect(UpdatePosition)

		local Title = Data.Metadata.Title
		local Artist = Data.Metadata.Artist

		local infoFrame = MapFrame.MainFrame.MapInfo
		infoFrame.SongName.Text = Title
		infoFrame.SongArtist.Text = Artist
		infoFrame.MapperName.Text = "mapset by <font size='16' weight = 'SemiBold'>"..Data.Metadata.Mapper.."</font>"
		
		_connections.HitboxClick = MapFrame.MainFrame.MapInfo.Hitbox.MouseButton1Click:Connect(function()
			ChooseSet(MapFrame,Data)
		end)
		
		Data._connections = _connections
	end
	
	-- layout

	local SortTable = SortData.Name
	for order,a in pairs(SortTable) do
		a.MapFrame.LayoutOrder = order
		a.MapFrame.ZIndex = order
	end
	local EmptySpace = 	script.EmptySpace:Clone()
	local EmptySpace2 = script.EmptySpace:Clone()
	EmptySpace.Parent = ListingFrame
	EmptySpace2.Parent = ListingFrame
	EmptySpace2.Name = "EmptySpace2"
	local GapSize = math.max(50,workspace.CurrentCamera.ViewportSize.Y*0.1)
	EmptySpace.Size = UDim2.new(1,0,0,GapSize)
	EmptySpace2.Size = UDim2.new(1,0,0,0)
	EmptySpace2.LayoutOrder = -9999
end

local AnimationProcessing = false
local ForceUpdate = false

local Connection


script.Parent.Parent.Parent.Parent.CurrentBeatmap:GetPropertyChangedSignal("Value"):Connect(function()
	if not isOpen then
		ForceUpdate = true
	end
end)

-- Animate/build on first load
-- Open the listing (preload the map listing if first load)
local VisibleValue = script.Parent.IsVisible
function resetDefault()
	for _, item in pairs(MapList) do
		if item._connections then
			for _, connection in pairs(item._connections) do
				connection:Disconnect()
			end
		end
		if item.MapFrame then
			item.MapFrame:Destroy()
		end
	end
	CurrentChoosing = nil
	CurrentDiffChoosing = nil
	CurrentDiffChoosingID = 0
	MapList = {}
	SortData = {
		Name = {},
		Artist = {},
		Diff = {},
		DiffRev = {},
		CustomSort = {}
	}
end
function UpdateConnection()
	Connection = ListingButton.MouseButton1Click:Connect(function()
		if AnimationProcessing then
			return
		end

		AnimationProcessing = true
		isOpen = true
		VisibleValue.Value = true
		script.Parent.Parent.Parent.Parent.ClickProtect.Visible = isOpen

		local objList = script.Parent.Parent.Parent:GetChildren()
		local AnimateFrame = game.Players.LocalPlayer.PlayerGui.BeatmapListing.MainFrame_Animation
		local MainFrame = game.Players.LocalPlayer.PlayerGui.BeatmapListing.MainFrame
		local InnerFrame = MainFrame.MainFrame

		if FirstLoad then
			resetDefault()
			LoadListing()
			SortListing()
			BuildListing()
			FirstLoad = false

			local CurrentMap = script.Parent.Parent.Parent.Parent.CurrentBeatmap.Value or workspace.Beatmaps:GetChildren()[#workspace.Beatmaps:GetChildren()]
			local SetID = GetValue(require(CurrentMap), "BeatmapSetID:", 0)
			local MapID = GetValue(require(CurrentMap), "BeatmapID:", 0)

			local MapData = MapList[SetID]
			local MapFrame = MapData.MapFrame
			

			ChooseSet(MapFrame, MapData, -1, MapID, true)


			for i = 1,30 do
				wait()
			end

		elseif ForceUpdate then
			ForceUpdate = false
		end

		MainFrame.Parent.Enabled = true
		AnimateFrame.GroupTransparency = 1
		AnimateFrame.Position = UDim2.new(0.25, 0, 0, 0)

		MainFrame.Visible = false
		AnimateFrame.Visible = true

		for _, obj in pairs(objList) do
			obj.Parent = AnimateFrame
		end

		TweenService:Create(AnimateFrame, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
			GroupTransparency = 0,
			Position = UDim2.new(0, 0, 0, 0)
		}):Play()
		
		TweenService:Create(InnerFrame.Title,TweenInfo.new(1.25, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),{
			Position = UDim2.new(0,0,0,5)
		}):Play()
		
		TweenService:Create(InnerFrame.OptionsFrame,TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),{
			Position = UDim2.new(-0.4,0,1,0)
		}):Play()
		

		wait(1)

		MainFrame.Visible = true
		AnimateFrame.Visible = false

		for _, obj in pairs(objList) do
			obj.Parent = MainFrame
		end

		AnimationProcessing = false
	end)
end

script.Parent.MPForceUpdate.Event:Connect(function()
	if isOpen then
		ForceUpdate = true
		UpdateConnection()
	end
end)

function YeildForMapChooseButton()
	repeat wait() until game.Players.LocalPlayer.PlayerGui:WaitForChild("BG"):FindFirstChild("BeatmapChooseButton")
	return game.Players.LocalPlayer.PlayerGui:WaitForChild("BG"):FindFirstChild("BeatmapChooseButton")
end

spawn(function()
	UpdateConnection()
	while wait() do
		if ListingButton.Parent == nil then
			ListingButton = YeildForMapChooseButton()

			if Connection then
				Connection:Disconnect()
				UpdateConnection()
			end
		end

		ListingButton.Destroying:Wait()
	end
end)


-- Close the listing
function CloseFrame()
	if AnimationProcessing == true then
		return
	end
	game.Players.LocalPlayer.PlayerGui.PlayScreen.MapLbUpdate:Fire()

	isOpen = false
	VisibleValue.Value = false
	AnimationProcessing = true

	local objList = script.Parent.Parent.Parent:GetChildren()
	local AnimateFrame = game.Players.LocalPlayer.PlayerGui.BeatmapListing.MainFrame_Animation
	local MainFrame = game.Players.LocalPlayer.PlayerGui.BeatmapListing.MainFrame
	local InnerFrame = MainFrame.MainFrame

	AnimateFrame.GroupTransparency = 0
	AnimateFrame.Position = UDim2.new(0,0,0,0)


	MainFrame.Visible = false
	AnimateFrame.Visible = true

	for _,obj in pairs(objList) do
		obj.Parent = AnimateFrame
	end

	TweenService:Create(AnimateFrame,TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{
		GroupTransparency = 1, Position = UDim2.new(0.25,0,0,0)
	}):Play()
	
	TweenService:Create(InnerFrame.Title,TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.In),{
		Position = UDim2.new(0.2,0,0,5)
	}):Play()

	TweenService:Create(InnerFrame.OptionsFrame,TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.In),{
		Position = UDim2.new(-0.2,0,1,0)
	}):Play()
	wait(1)

	MainFrame.Visible = true
	AnimateFrame.Visible = false

	MainFrame.Parent.Enabled = false

	for _,obj in pairs(objList) do
		obj.Parent = MainFrame
	end

	AnimationProcessing = false
end

script.Parent.Parent.ReturnButton.InputButton.MouseButton1Click:Connect(CloseFrame)
script.Parent.Parent.ReturnHitbox.MouseButton1Click:Connect(CloseFrame)

script.Parent.Parent.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if not script.Parent.Parent.Parent.Parent.Enabled and isOpen then
		-- there must be some script outside that force the listing to be closed
		-- therefore this code have to be also closed in a right protocol
		
		if AnimationProcessing then
			repeat wait() until not AnimationProcessing
		end
		
		if isOpen then
			-- if the frame is still open, then close it
			CloseFrame()
		end
	end
end)

local OptionFrame = script.Parent.Parent.OptionsFrame
local LastRandomChoose = 0

function PickRandomMap()
	if tick() - LastRandomChoose >= 0.5 and isOpen then
		LastRandomChoose = tick()
		local ChoosenMap = SortData[CurrentSort][math.random(1,#SortData[CurrentSort])]

		ChooseSet(ChoosenMap.MapFrame,ChoosenMap)
	end
end


OptionFrame.MainFrame.Random.Hitbox.MouseButton1Click:Connect(PickRandomMap)
UserInputService.InputBegan:Connect(function(data)
	if data.KeyCode == Enum.KeyCode.F2 then
		PickRandomMap()
	end
end)


UserInputService.InputBegan:Connect(function(data)
	if NavigationSwitching or not isOpen then return end

	local function GetSetOrder(MapFrame)
		for i,Data in pairs(SortData[CurrentSort]) do
			if Data.MapFrame == MapFrame then
				return i
			end
		end
	end

	NavigationSwitching = true

	local KeyCode = data.KeyCode
	if KeyCode == Enum.KeyCode.Left or KeyCode == Enum.KeyCode.Right then
		local SetOrder = GetSetOrder(CurrentChoosing)

		if not SetOrder then
			return
		end

		if KeyCode == Enum.KeyCode.Left then
			if SetOrder > 1 then
				SetOrder -= 1
			else
				SetOrder = #SortData[CurrentSort]
			end
		elseif KeyCode == Enum.KeyCode.Right then
			if SetOrder < #SortData[CurrentSort] then
				SetOrder += 1
			else
				SetOrder = 1
			end

		end
		local ChoosenSet = SortData[CurrentSort][SetOrder]
		ChooseSet(ChoosenSet.MapFrame,ChoosenSet)
	end

	NavigationSwitching = false
end)



local FilterOpening = false
local FilterButton = OptionFrame.MainFrame.Filter.Hitbox
local FilterFrame = script.Parent.Parent.FilterFrame.FilterFrame
local FilterFrameAnimation = script.Parent.Parent.FilterFrame_animation
local FilterFrameMain = script.Parent.Parent.FilterFrame
local FilterFrameExitArea = script.Parent.Parent.FilterFrameExitArea
local onAnimate = false

local TweenProperties = {
	["true"] = {
		info = TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),
		properties = {Position = UDim2.new(-0.4,15,1,-38),GroupTransparency = 0}
	},
	["false"] = {
		info = TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.In),
		properties = {Position = UDim2.new(-0.4,115,1,-38),GroupTransparency = 1}
	}
}

function TriggerFilter(isOpen)
	if onAnimate then
		return "fail"
	end
	onAnimate = true
	FilterOpening = isOpen

	local properties = TweenProperties[tostring(isOpen)]
	FilterFrameExitArea.Visible = isOpen
	FilterFrameMain.Visible = isOpen
	FilterFrame.Parent = FilterFrameAnimation

	TweenService:Create(FilterFrameAnimation,properties.info,properties.properties):Play()
	wait(0.5)
	FilterFrame.Parent = FilterFrameMain
	onAnimate = false
end

for _,a in pairs(FilterFrameExitArea:GetChildren()) do
	a.MouseButton1Click:Connect(function()
		TriggerFilter(false)
	end)
end

FilterButton.MouseButton1Click:Connect(function()
	TriggerFilter(not FilterOpening)
end)

OptionFrame.MainFrame.Settings.Hitbox.MouseButton1Click:Connect(function()
	local BGHolder = game.Players.LocalPlayer.PlayerGui:WaitForChild("BG").SettingsBG
	local SettingFrame = game.Players.LocalPlayer.PlayerGui.BG.SettingsFrame
	SettingFrame.Visible = true
	SettingFrame.SettingsExitFrame.Visible = true
	game:GetService("TweenService"):Create(SettingFrame.Parent.SettingsBG,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{BackgroundTransparency = 0.5}):Play()
	game:GetService("TweenService"):Create(SettingFrame,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{AnchorPoint = Vector2.new(0,0)--[[,GroupTransparency = 0]]}):Play()
	game:GetService("TweenService"):Create(SettingFrame.Frame.Frame,TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{Size = UDim2.new(0,10,1,0)}):Play()
	SettingFrame.InterfaceScript.UIFIx.Disabled = false

	spawn(function()
		repeat wait() until
		TriggerFilter(false) ~= "fail"
	end)
	CloseFrame()
end)





-- Sort, search maps
local CurrentSortType = 1
local LastKeyword = ""

function ChangeFilterOrder(Data)
	for order,a in pairs(Data) do
		a.MapFrame.LayoutOrder = order
		a.MapFrame.ZIndex = order
	end
end

function SpiltKeyword(keyword)
	local keyList = {}
	local CurrentPosition = 1
	while CurrentPosition < #keyword and wait() do
		local _,i = string.find(keyword," ",CurrentPosition)
		if not i then
			keyList[#keyList+1] = string.sub(keyword,CurrentPosition,#keyword)
			break
		else
			keyList[#keyList+1] = string.sub(keyword,CurrentPosition,i-1)
			CurrentPosition = i+1
		end
	end

	return keyList
end

function CheckTable(Table,Keyword)
	for _,a in pairs(Table) do
		if typeof(a) == "table" then
			if CheckTable(a,Keyword) == true then
				return true
			end
		elseif typeof(a) == "string" or typeof(a) == "number" then
			if string.find(string.lower(tostring(a)),string.lower(Keyword)) then
				return true
			end
		end
	end

	return false
end

function CheckMap(mapData,Keyword)
	if CheckTable(mapData,Keyword) then
		return true
	end
	return false
end

function convertKeyword(keyword) -- We have to make sure it got converted to the format that string.find() can support
	local filtered = ""
	
	for i = 1, #keyword do
		local c = keyword:sub(i,i)
		if c == "%" then
			filtered..= "%%"
		elseif c == "+" then
			filtered..= "%+"
		elseif c == "-" then
			filtered..= "%-"
		elseif c == "*" then
			filtered..= "%*"
		else
			filtered..= c
		end
	end
	return filtered
end

function FilterMaps(data,keyword,diffRange)
	keyword = convertKeyword(keyword)
	local KeyList = SpiltKeyword(keyword)
	local newData = CloneTable(data)
	if not diffRange then
		diffRange = {Max = 999, Min = 0}
	end
	for i,a in pairs(newData) do
		local isMatch = true
		local diffMatchedCount = 0
		for _, diff in pairs(a.DiffListing) do
			if diff.DiffRating >= diffRange.Min and diff.DiffRating <= diffRange.Max then
				-- since it's a first condition, it have to be setted
				diff.isCurrentlyMatched = true
				diffMatchedCount += 1
			else
				diff.isCurrentlyMatched = false
			end
		end
		
		if diffMatchedCount == 0 then
			isMatch = false
		end
		
		local DiffDataSearchList = {
			HP = "HP", HPDRAINRATE = "HP", HEALTHDRAINRATE = "HP", HEALTH = "HP",
			CS = "CS", CIRCLESIZE = "CS", SIZE = "CS",
			OD = "OD", OVERALLDIFFICULTY = "OD", ACC = "OD", ACCURACY = "OD",
			AR = "AR", APPROACHRATE = "AR",
			DR = "DR", DIFFICULTYRATING = "DR", DIFF = "DR", SR = "DR", STARRATING = "DR", STAR = "DR", STARS = "DR"
		}
		
		local function findForCondition(key)
			if string.find(key,">=") then
				return ">="
			elseif string.find(key,"<=") then
				return "<="
			elseif string.find(key,">") then
				return ">"
			elseif string.find(key,"<") then
				return "<"
			elseif string.find(key,"=") then
				return "="
			end
		end
		
		local function checkKey(key)
			local conditionKey = findForCondition(key)
			if not conditionKey then return end
			local s,e = string.find(key,conditionKey)
			local Value1 = string.sub(key,1,s-1)
			local Value2 = string.sub(key,e+1,#key)
			Value1 = DiffDataSearchList[string.upper(Value1)]
			Value2 = tonumber(Value2)
			
			if Value1 and Value2 then
				return conditionKey,Value1,Value2
			end
		end
		
		local function isCondition(conditionKey,a,b)
			-- we take rounded number of maximum 2 digits
			a = math.round(a*100)/100
			b = math.round(b*100)/100
			local list = {
				[">"] = a>b, ["<"] = a<b, [">="] = a>=b, ["<="] = a<=b, ["="] = a==b
			}
			
			return list[conditionKey]
		end
		
		local function checkCondition(conditionKey,Value1,Value2)
			local matchCount = 0
			for _, diff in pairs(a.DiffListing) do
				local DiffValue = diff.DiffData[Value1]
				if isCondition(conditionKey,DiffValue,Value2) then
					matchCount += 1
				else
					diff.isCurrentlyMatched = false
				end
			end
			
			return matchCount > 0
		end
		
		for _,key in pairs(KeyList) do
			local condition,Value1,Value2 = checkKey(key)
			if not (condition and Value1 and Value2 and checkCondition(condition,Value1,Value2)) and not CheckMap(a,key) then
				isMatch = false
				break
			end
		end

		a.MapFrame.Visible = isMatch

		if not isMatch then
			newData[i] = nil
		end
	end

	return CloneTable(newData,true)
end

function isCrrMapMatchSearch()
	for _, map in pairs(SortData.CustomSort) do
		if map.MapFrame == CurrentChoosing then
			return true
		end
	end
	
	return false
end


function UpdateFilter(SortType,Keyword,DifficultyRange)
	TweenService:Create(script.Parent.Parent.NoResult.Display,TweenInfo.new(0.1,Enum.EasingStyle.Linear), {TextTransparency = 1}):Play()
	TweenService:Create(script.Parent.Parent.NoResult.Display,TweenInfo.new(0.1,Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)}):Play()
	CurrentSortType = SortType
	local UpdateEnabled = true
	local PrevSortLength = #SortData[CurrentSort]
	
	local SortTypeList = {
		SortData.Name,SortData.Artist,SortData.Diff,SortData.DiffRev
	}
	local SortTypeListName = {
		"Name","Artist","Diff","DiffRev","CustomSort"
	}

	local SortTable = SortTypeList[SortType]
	if not Keyword and LastKeyword == "" and not DifficultyRange then
		ChangeFilterOrder(SortTable)

		CurrentSort = SortTypeListName[SortType]
	else
		local CustomSort = CloneTable(SortTable)
		CustomSort = FilterMaps(CustomSort,Keyword or LastKeyword,DifficultyRange)
		SortData.CustomSort = CustomSort
		CurrentSort = SortTypeListName[5]

		ChangeFilterOrder(SortData.CustomSort)
		
		if #SortData.CustomSort == 1 and #SortData.Name > 1 and CurrentChoosing ~= SortData.CustomSort[1].MapFrame then
			UpdateEnabled = false
			local data = SortData.CustomSort[1]
			ChooseSet(data.MapFrame,data,SortData.CustomSort)
		elseif not isCrrMapMatchSearch() and #SortData.CustomSort >= 1 then
			UpdateEnabled = false
			local data = SortData.CustomSort[1]
			ChooseSet(data.MapFrame,data,SortData.CustomSort)
		end
	end
	
	
	if #SortData[CurrentSort] < PrevSortLength and #SortData[CurrentSort] > 0 and #SortData[CurrentSort] < 10 and PrevSortLength < 10 then
		local CurrentLength = #SortData[CurrentSort]
		local EmptySpace = ListingFrame.EmptySpace2
		TweenService:Create(EmptySpace,TweenInfo.new(0,Enum.EasingStyle.Linear),{Size = UDim2.new(1,0,0,(PrevSortLength-CurrentLength)*80)}):Play()
		wait()
		TweenService:Create(EmptySpace,TweenInfo.new(1.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size = UDim2.new(1,0,0,0)}):Play()
	end
	
	if #SortData[CurrentSort] == 0 then
		TweenService:Create(script.Parent.Parent.NoResult.Display,TweenInfo.new(0.1,Enum.EasingStyle.Linear), {TextTransparency = 0}):Play()
		TweenService:Create(script.Parent.Parent.NoResult.Display,TweenInfo.new(0.5,Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(-0.1,0,0,0)}):Play()
	end

	if UpdateEnabled then
		UpdatePosEvent:Fire()
	end
end

local SortTypeFrame = FilterFrame.MainFrame.SortType.MainFrame.SortType

function SetVisible(obj)
	for _,a in pairs(SortTypeFrame:GetChildren()) do
		if a:IsA("TextButton") then
			if a ~= obj then
				TweenService:Create(a,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.9 ,BackgroundColor3 = Color3.new(1,1,1), TextColor3 = Color3.new(1, 1, 1)}):Play()
			end
		end
	end
	TweenService:Create(obj,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{BackgroundTransparency = 0.25,BackgroundColor3 = Color3.new(1, 1, 0.498039), TextColor3 = Color3.new(0, 0, 0)}):Play()
end

SortTypeFrame.TitleName.MouseButton1Click:Connect(function()
	SetVisible(SortTypeFrame.TitleName)
	UpdateFilter(1)
end)

SortTypeFrame.Artist.MouseButton1Click:Connect(function()
	SetVisible(SortTypeFrame.Artist)
	UpdateFilter(2)
end)

SortTypeFrame.Diff.MouseButton1Click:Connect(function()
	SetVisible(SortTypeFrame.Diff)
	UpdateFilter(3)
end)

SortTypeFrame.DiffRev.MouseButton1Click:Connect(function()
	SetVisible(SortTypeFrame.DiffRev)
	UpdateFilter(4)
end)

local KeywordInput = FilterFrame.MainFrame.Keyword.SearchBar

UserInputService.InputBegan:Connect(function(input)
	if not game.Players.LocalPlayer.PlayerGui.BeatmapListing.Enabled or UserInputService:GetFocusedTextBox() then return end
	local keyword = UserInputService:GetStringForKeyCode(input.KeyCode)
	if input.UserInputType == Enum.UserInputType.Keyboard and keyword ~= "" and keyword ~= "/" then -- in a special condition, when player's supposed to open the chat and not searching
		if not FilterOpening then
			spawn(function()
				TriggerFilter(true)
			end)
			--[[local SecondaryInput = {
				["`"] = "~", ["1"] = "!", ["2"] = "@", ["3"] = "#", ["4"] = "$", ["5"] = "%", ["6"] = "^", ["7"] = "&",
				["8"] = "*", ["9"] = "(", ["0"] = ")", ["-"] = "_", ["="] = "+", ["["] = "{", ["]"] = "}", ["\\"] = "|",
				[";"] = ":", ["'"] = '"', [","] = "<", ["."] = ">", ["/"] = "?"
			}
			if not UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and not UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
				keyword = string.lower(keyword)
			elseif SecondaryInput[keyword] then
				keyword = SecondaryInput[keyword]
			end
			KeywordInput.Text ..= keyword]]
		end

		KeywordInput:CaptureFocus()
	end
end)

local onTyping = false
local lastTick = tick()

KeywordInput:GetPropertyChangedSignal("Text"):Connect(function()
	lastTick = tick()
	onTyping = true
end)

spawn(function()
	while wait() do
		if onTyping and tick() - lastTick >= 0.5 then
			onTyping = false
			local CurrentKeyword = KeywordInput.Text
			if CurrentKeyword ~= LastKeyword then
				UpdateFilter(CurrentSortType,CurrentKeyword)
				LastKeyword = CurrentKeyword
			end
		end
	end
end)

KeywordInput.FocusLost:Connect(function()
	local CurrentKeyword = KeywordInput.Text
	if CurrentKeyword ~= LastKeyword then
		UpdateFilter(CurrentSortType,CurrentKeyword)
		LastKeyword = CurrentKeyword
	end
end)

UserInputService.InputBegan:Connect(function(data)
	if data.KeyCode == Enum.KeyCode.Delete and (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)) then
		KeywordInput.Text = ""
	end
end)

script.Parent.UpdateDifficultyRange.Event:Connect(function(MinRange,MaxRange)
	if MaxRange == 10 then
		MaxRange = 999
	end
	
	local Package = {Max = MaxRange, Min = MinRange}
	UpdateFilter(CurrentSortType,nil,Package)
end)
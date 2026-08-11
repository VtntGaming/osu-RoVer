local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Item = script.Parent.Assets.MapsetItem

export type ItemFrame = typeof(Item)

local MAX_MOVEMENT = 0.1
local MAX_OUT_OF_FOCUS = 0.1

export type MapsetItem = {
	__index: MapsetItem,
	-- Properties
	Frame: ItemFrame,
	Index: number,
	Offset: number,
	Focused: boolean,
	FocusProgress: number,
	Reference: Instance,
	UpdateThread: thread?,
	-- Methods
	new: (index: number, beatmapID: number) -> MapsetItem,
	Setup: (self: MapsetItem) -> (),
	SetFocus: (self: MapsetItem, focus: boolean) -> (),
	SetPositionOffset: (self: MapsetItem, offset: number) -> (),
	Update: (self: MapsetItem) -> (),
	UpdateInternal: (self: MapsetItem, dt: number) -> (),
}

local MapsetItem: MapsetItem = {} :: MapsetItem
MapsetItem.__index = MapsetItem

function MapsetItem.new(index, ref)
	local self = setmetatable({}, MapsetItem)
	
	local frame = Item:Clone()
	
	self.Index = index
	self.Reference = ref
	self.Focused = false
	self.FocusProgress = 0
	self.Offset = 0
	self.Frame = frame
	
	return self
end

function MapsetItem:Setup()
	local hitbox = self.Frame.Canvas.MainFrame.Hitbox
	
	hitbox.Activated:Connect(function()
		game.Players.LocalPlayer.PlayerGui.SystemGame.Beatmap.SongChoosing.Value = self.Reference
		script.Parent.Focused:Fire(self.Index)
	end)
	
	script.Parent.Focused.Event:Connect(function(index: number)
		local isfocued = index == self.Index
		
		if isfocued ~= self.Focused then
			self:SetFocus(isfocued)
		end
	end)
	
	local canvas = self.Frame.Canvas
	local session
	
	TweenService:Create(canvas, TweenInfo.new(0), {GroupTransparency = 1}):Play()
	
	self.Frame.AncestryChanged:Connect(function()
		if self.Frame.Parent == nil then
			TweenService:Create(canvas, TweenInfo.new(0), {GroupTransparency = 1}):Play()
			session = nil
		else
			local current = HttpService:GenerateGUID()
			session = current
			task.wait()
			if session == current then
				TweenService:Create(canvas, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {GroupTransparency = 0}):Play()
			end
		end
	end)
end

function MapsetItem:SetPositionOffset(offset: number)
	self.Offset = offset
	self:Update()
end

function MapsetItem:SetFocus(focus: boolean)
	self.Focused = focus
	self:Update()
end

function MapsetItem:Update()
	if self.UpdateThread then
		return
	end
	self.UpdateThread = task.defer(function()
		local pos = self.Offset * MAX_MOVEMENT + self.FocusProgress * MAX_OUT_OF_FOCUS
		self.Frame.Canvas.MainFrame.Position = UDim2.fromScale(pos, 0.5)
		
		self.UpdateThread = nil
	end)
end

function MapsetItem:UpdateInternal(dt)
	local targetFocus = self.Focused and 0 or 1
	self.FocusProgress += (targetFocus - self.FocusProgress) * dt * 10
	self:Update()
end

return MapsetItem
--[LOCATION]:[StarterGui.PlayScreen.Cursor]
local Cursor = script.Parent.CursorField.Cursor

local LastCursorPos = Cursor.Position
local LastCursor = Cursor:Clone()
local LastMove = tick()

local wait = require(workspace.WaitModule)
local Bind = Instance.new("BindableEvent")
local TweenService = game:GetService("TweenService")

local ExclusiveCursorList = {}
local CloneCount = 60
local lastMove = tick()

Cursor:GetPropertyChangedSignal("Position"):Connect(function()
	if Cursor.Position ~= LastCursorPos and script.TrailEnabled.Value == true and Cursor.Visible and tick() - LastMove > 0.016 then
		LastMove = tick()
		local CurrentMove = tick()
		LastCursorPos = Cursor.Position
		--local CurrentCursor = LastCursor
		local CurrentCursor = script.Parent.OsuGame.Cursor_Trail:Clone()
		CurrentCursor.Position = LastCursor.Position
		LastCursor = Cursor:Clone()
		local Pos1 = Vector2.new(CurrentCursor.Position.X.Scale*512,CurrentCursor.Position.Y.Scale*384)
		local Pos2 = Vector2.new(LastCursor.Position.X.Scale*512,LastCursor.Position.Y.Scale*384)
		local ChangedPos = math.abs((Pos1-Pos2).magnitude)
		local CursorSpeed = ChangedPos/(CurrentMove-LastMove)
		LastMove = CurrentMove
		CurrentCursor.Parent = script.Parent.CursorField.CursorFade
		local FadeTime = script.FadeTime.Value
		TweenService:Create(CurrentCursor,TweenInfo.new(FadeTime,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{ImageTransparency = 1}):Play()
		wait(FadeTime)
		CurrentCursor:Destroy()
	end
end)
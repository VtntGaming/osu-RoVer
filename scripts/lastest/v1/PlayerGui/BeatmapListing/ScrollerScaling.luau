--[LOCATION]:[StarterGui.BeatmapListing.MainFrame.MainFrame.WorkingScript.ScrollerScaling]
local Listing = script.Parent.Parent.Listing
local Layout = Listing.UIListLayout


Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Listing.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y)
end)
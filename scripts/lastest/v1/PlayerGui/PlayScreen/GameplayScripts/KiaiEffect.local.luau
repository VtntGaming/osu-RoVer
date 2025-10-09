--[LOCATION]:[StarterGui.PlayScreen.GameplayScripts.KiaiEffect]
local TweenService = game:GetService("TweenService")
local PlayFrame = script.Parent.Parent.PlayFrame
local CursorArea = script.Parent.Parent.CursorField
local Background = game.Players.LocalPlayer.PlayerGui.BG.Background.Background

TweenService:Create(PlayFrame,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Rotation = -2,Position = UDim2.new(.5,-10,.5,0)}):Play()
TweenService:Create(CursorArea,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Rotation = -2,Position = UDim2.new(.5,-10,.5,0)}):Play()
--TweenService:Create(Background,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Rotation = -2,Position = UDim2.new(.5,-10,.5,0)}):Play()
wait(1)
TweenService:Create(PlayFrame,TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,math.huge,true),{Rotation = 2,Position = UDim2.new(.5,10,.5,0)}):Play()
TweenService:Create(CursorArea,TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,math.huge,true),{Rotation = 2,Position = UDim2.new(.5,10,.5,0)}):Play()
--TweenService:Create(Background,TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,math.huge,true),{Rotation = 2,Position = UDim2.new(.5,10,.5,0)}):Play()
local CurrentSession
local SystemGame = game.Players.LocalPlayer.PlayerGui:WaitForChild("SystemGame")
local BackgroundFrame = game.Players.LocalPlayer.PlayerGui.GameBackground
local Song = SystemGame.Song.GameSong
local SongChoosingValue = SystemGame.Beatmap.SongChoosing

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

function SwitchSong(customMap)
	local Choosen = customMap
	local ThisSession = game:GetService("HttpService"):GenerateGUID()
	CurrentSession = ThisSession
	SongChoosingValue.Value = Choosen

	local MapData = require(Choosen)

	local SongId = GetValue(MapData,"RblxSoundID:")
	local ImageId = GetValue(MapData,"BackgroundImageId:") or "0"
	-- local SongName = GetValue(MapData,"Title:",0)
	-- local ArtistName = GetValue(MapData,"Artist:",0)
	local SongSpeed = GetValue(MapData,"SongSpeed:") or 1
	-- local SongPitch = GetValue(MapData,"SongPitch:")
	-- local SongVolume = GetValue(MapData,"BeatmapVolume:")
	local PreviewTime = tonumber(GetValue(MapData, "PreviewTime:", 1)) or 0

	BackgroundFrame.ChangeRequest:Fire(ImageId)
	
	-- Don't switch if the song is already playing
	if Song.Asset == "rbxassetid://"..SongId then
		return
	end

	Song:Stop()
	Song.TimePosition = PreviewTime/1000
	Song.PlaybackSpeed = SongSpeed
	Song.Asset = "rbxassetid://"..SongId

	if not Song.IsReady then
		local s = tick()
		repeat task.wait() until Song.IsReady or tick() - s > 10

		if not Song.IsReady and ThisSession == CurrentSession then
			SwitchSong()
			return
		end
	end
	Song:Play()
end

SongChoosingValue.Changed:Connect(function(map)
	SwitchSong(map)
end)
local CurrentSession
local SystemGame = game.Players.LocalPlayer.PlayerGui:WaitForChild("SystemGame")
local BackgroundFrame = game.Players.LocalPlayer.PlayerGui.GameBackground
local Song = SystemGame.Song.GameSong
local Song2 = SystemGame.Song.GameSong2
local SongChoosingValue = SystemGame.Beatmap.SongChoosing

function GetValue(FileData,Name,Spaces): string?
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
	local SongId2 = GetValue(MapData,"RblxSoundID2:")
	local ImageId = GetValue(MapData,"BackgroundImageId:") or "0"
	-- local SongName = GetValue(MapData,"Title:",0)
	-- local ArtistName = GetValue(MapData,"Artist:",0)
	local SongSpeed = GetValue(MapData,"SongSpeed:") or 1
	-- local SongPitch = GetValue(MapData,"SongPitch:")
	local SongVolume = GetValue(MapData,"BeatmapVolume:") or 1
	local PreviewTime = tonumber(GetValue(MapData, "PreviewTime:", 1)) or 0

	BackgroundFrame.ChangeRequest:Fire(ImageId)
	
	-- Don't switch if the song is already playing
	if Song.Asset == "rbxassetid://"..SongId then
		return
	end
	
	local playbackTime = PreviewTime / 1000
	local song2Available = SongId2 ~= nil
	local isRunningOnSong2 = false

	Song:Stop()
	Song.PlaybackSpeed = SongSpeed
	Song.Asset = "rbxassetid://"..SongId
	Song.Volume = SongVolume
	
	Song2:Stop()
	if song2Available then
		Song2.PlaybackSpeed = SongSpeed
		Song2.Asset = "rbxassetid://"..SongId2
		Song2.Volume = SongVolume		
	end

	local s = tick()

	if not Song.IsReady then
		repeat task.wait() until Song.IsReady or tick() - s > 10

		if not Song.IsReady and ThisSession == CurrentSession then
			SwitchSong()
			return
		end
	end
	
	if song2Available then
		if not Song2.IsReady then
			repeat task.wait() until Song2.IsReady or tick() - s > 10

			if not Song2.IsReady and ThisSession == CurrentSession then
				SwitchSong()
				return
			end
		end
	end
	
	if song2Available and playbackTime > Song.TimeLength then
		playbackTime -= Song.TimeLength
		isRunningOnSong2 = true
	end

	if isRunningOnSong2 then
		Song.TimePosition = 0
		Song2.TimePosition = playbackTime
	else
		Song.TimePosition = playbackTime
		Song2.TimePosition = 0
	end
	
	local playbackSound = isRunningOnSong2 and Song2 or Song
	
	playbackSound:Play()
end

SongChoosingValue.Changed:Connect(function(map)
	if script.Parent.Parent.Enabled then
		SwitchSong(map)
	end
end)
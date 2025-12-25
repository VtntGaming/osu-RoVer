--[LOCATION]:[StarterGui.Settings.SettingFrame.BaseFrame.MainLayer.SettingsManage.OldSettingsDataStoreList]
-- {oldDataStoreName, NewRelatedSettings, callback(oldValue) => return new value}

--[[

Offset = 0,
		ScrollSpeed = 1,
		SongVolume = 50,
		EffectVolume = 50,
		BackgroundDimTrans = 0.2,
		K1 = "Z",
		K2 = "X",
		Lightning = true,
		CursorTrail = true,
		MobileHit = true,
		MouseButton = true,
		OldCursorMovement = true,
		NewCircleOverlay = false,
		OldScoreInterface = false,
		osuStableNotelock = true,
		PerfomanceDisplay = false,
		RightHitZone = false,
		InGameChatDisabled = false,
		DisplayInGameLB = true,
		HitZone = true,
		CustomComboColor = false,
		DisplayFPS = false,
		DetailedPSDisplay = false,
		OptimizedPerfomance = false,
		LiveDifficultyDisplay = false,
		Display300s = false,
		CustomComboColorData = "[]",
		CircleNumberData = "[]",
		Skin = {
			CursorId = -1,
			CursorSize = 1,
			CursorTrailId = -1,
			CursorTrailSize = 1,
			CursorTrailTransparency = 0.5,
			CircleImageId = -1,
			CircleOverlayImageId = -1,
			ApproachCircleImageId = -1,
			CursorTrailFadeTime = 0.25
		}
]]

local List = {
	{"ScrollSpeed", "VirtualCursorSensitivity"},
	{"SongVolume", "MusicVolume"},
	{"EffectVolume", "EffectVolume"},
	{"BackgroundDimTrans", "BGDim", function(value) return 100-(value*100) end},
	{"K1", "LeftKey"},
	{"K2", "RightKey"},
	{"Lightning", "CircleLightingEffect"},
	{"CursorTrail", "CursorTrail"},
	{"MobileHit", "EnableTouchDevice"},
	{"MouseButton", "MouseButton"},
	{"OldCursorMovement", "VirtualCursor"},
	{"OldScoreInterface", "LegacyOverlay"},
	{"osuStableNotelock", "ClassicNotelock"},
	{"PerfomanceDisplay", "PerfomanceOverlay"},
	{"RightHitZone", "RightSizeHitzone"},
	{"InGameChatDisabled", "DisableChatIngame"},
	{"DisplayInGameLB", "ShowInGameLeaderboard"},
	{"HitZone", "EnableHitzone"},
	{"CustomComboColor", "CustomComboColor"},
	{"DisplayFPS", "DisplayFPS"},
	{"DetailedPSDisplay", "DetailedPerformance"},
	{"OptimizedPerfomance", "OptimizedPerfomance"},
	{"LiveDifficultyDisplay", "LiveDifficultyOverlay"},
	{"Display300s", "ShowHit300"},
	{"CustomComboColorData", "ComboColorList"}
}

local Skin = {
	{"CursorId", "CursorID", function(value) return (value == "-1" and nil) or value end},
	{"CursorSize", "CursorSize"},
	{"CursorTrailId", "CursorTrailID", function(value) return (value == "-1" and nil) or value end},
	{"CursorTrailSize", "CursorTrailSize"},
	{"CursorTrailTransparency", "CursorTrailOpacity", function(value) return (100 - value*100) end},
	{"CircleImageId", "BaseCircleID", function(value) return (value == "-1" and nil) or value end},
	{"CircleOverlayImageId", "CircleOverlayID", function(value) return (value == "-1" and nil) or value end},
	{"ApproachCircleImageId", "ApproachCircleID", function(value) return (value == "-1" and nil) or value end},
	{"CursorTrailFadeTime", "CursorTrailDuration"},
}

local NumberLayout = {
	{"0", "Number0", function(value) return (value == "-1" and nil) or value end},
	{"1", "Number1", function(value) return (value == "-1" and nil) or value end},
	{"2", "Number2", function(value) return (value == "-1" and nil) or value end},
	{"3", "Number3", function(value) return (value == "-1" and nil) or value end},
	{"4", "Number4", function(value) return (value == "-1" and nil) or value end},
	{"5", "Number5", function(value) return (value == "-1" and nil) or value end},
	{"6", "Number6", function(value) return (value == "-1" and nil) or value end},
	{"7", "Number7", function(value) return (value == "-1" and nil) or value end},
	{"8", "Number8", function(value) return (value == "-1" and nil) or value end},
	{"9", "Number9", function(value) return (value == "-1" and nil) or value end},
}

local FunctionList = {}

function FunctionList.GetBase()
	return List
end
function FunctionList.GetSkin()
	return Skin
end
function FunctionList.GetNumber()
	return NumberLayout
end

return FunctionList
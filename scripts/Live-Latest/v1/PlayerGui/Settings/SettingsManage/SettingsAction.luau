--[LOCATION]:[StarterGui.Settings.SettingFrame.BaseFrame.MainLayer.SettingsManage.SettingsAction]
--[[
	parameter:
		LayerName,		-- string, the layer frame that store the setting category
		CategoryName,	-- string, the category frane that store the setting
		SettingName,	-- string, the setting object name
		ValueName,		-- string, the name that display to store the current value
		DefaultValue,	-- variable, the default data that will set if the current setting is nil
		DataStoreName	-- string?, the data that is assigned in the datastore
		
		
	default settings will be managed on the client-side
	server-side default settings will be deprecated
]]

local SettingsList = {
	{"MainSettings", "Input", "EnableHitzone", "SwitchState", true, "HitZoneEnabled"},
	{"MainSettings", "Input", "EnableTouchDevice", "SwitchState", true, "TouchDeviceEnabled"},
	{"MainSettings", "Input", "HitzoneArea", "Current", 30, "HitZoneAreaSize"},
	{"MainSettings", "Input", "MouseButton", "SwitchState", true, "MouseButtonEnabled"},
	{"MainSettings", "Input", "RightSizeHitzone", "SwitchState", false, "RightSizeHitzoneEnabled"},
	{"MainSettings", "Input", "VirtualCursor", "SwitchState", false, "VirtualCursorEnabled"},
	{"MainSettings", "Input", "VirtualCursorSensitivity", "Current", 1, "VirtualCursorSensitivity"},
	{"MainSettings", "Audio", "AudioOffset", "Current", 0, "AudioOffset"},
	{"MainSettings", "Audio", "EffectVolume", "Current", 50, "EffectVolume"},
	{"MainSettings", "Audio", "MusicVolume", "Current", 50, "MusicVolume"},
	{"MainSettings", "Audio", "EnableSpeedPitch", "SwitchState", false, "EnableSpeedPitch"},
	{"MainSettings", "UserInterface", "BGDim", "Current", 80, "BackgroundDim"},
	{"MainSettings", "UserInterface", "CustomComboColor", "SwitchState", true, "EnableCustomComboColor"},
	{"MainSettings", "UserInterface", "DetailedPerformance", "SwitchState", false, "DetailedPerformance"},
	{"MainSettings", "UserInterface", "DisplayFPS", "SwitchState", false, "DisplayFPS"},
	{"MainSettings", "UserInterface", "HitError", "SwitchState", true, "HitErrorEnabled"},
	{"MainSettings", "UserInterface", "KeyOverlay", "SwitchState", true, "KeyOverlayEnabled"},
	{"MainSettings", "UserInterface", "KeyHistoryOverlay", "SwitchState", false, "KeyHistoryOverlayEnabled"},
	{"MainSettings", "UserInterface", "LegacyOverlay", "SwitchState", false, "LegacyOverlayEnabled"},
	{"MainSettings", "UserInterface", "LiveDifficultyOverlay", "SwitchState", false, "EnableLiveDifficultyOverlay"},
	{"MainSettings", "UserInterface", "PerfomanceOverlay", "SwitchState", false, "EnablePerfomanceOverlay"},
	{"MainSettings", "UserInterface", "ScoreOverlay", "SwitchState", true, "EnableScoreOverlay"},
	{"MainSettings", "UserInterface", "ShowInGameLeaderboard", "SwitchState", true, "ShowInGameLeaderboard"},
	{"MainSettings", "Gameplay", "CircleLightingEffect", "SwitchState", true, "EnableCircleLightingEffect"},
	{"MainSettings", "Gameplay", "ClassicNotelock", "SwitchState", false, "EnableClassicNotelock"},
	{"MainSettings", "Gameplay", "CursorTrail", "SwitchState", true, "EnableCursorTrail"},
	{"MainSettings", "Gameplay", "DisableChatIngame", "SwitchState", false, "DisableChatIngame"},
	{"MainSettings", "Gameplay", "InstaFadeCircle", "SwitchState", false, "InstaFadeCircleEnabled"},
	{"MainSettings", "Gameplay", "OptimizedPerfomance", "SwitchState", false, "EnableOptimizedPerfomance"},
	{"MainSettings", "Gameplay", "ScoreV2", "SwitchState", false, "EnableScoreV2"},
	{"MainSettings", "Gameplay", "ShowHit300", "SwitchState", false, "ShowHit300"},
	{"MainSettings", "Gameplay", "UsePSLeaderboard", "SwitchState", false, "UsePSLeaderboard"},
	{"MainSettings", "Gameplay", "EnableSliderShadow", "SwitchState", false, "EnableSliderShadow"},
	{"MainSettings", "Gameplay", "SnakingInSliders", "SwitchState", true, "SnakingInSliders"},
	{"MainSettings", "Gameplay", "SnakingOutSlider", "SwitchState", false, "SnakingOutSlider"},
	{"MainSettings", "Gameplay", "EnableStoryboard", "SwitchState", false, "EnableStoryboard"},
	{"KeybindAdjust", "InGame_Binding", "LeftKey", "Current", "Z", "Binding.LeftKey"},
	{"KeybindAdjust", "InGame_Binding", "RightKey", "Current", "X", "Binding.RightKey"},
	{"KeybindAdjust", "InGame_Binding", "QuickRestart", "Current", "Backquote", "Binding.QuickRestart"},
	{"KeybindAdjust", "InGame_Binding", "QuickExit", "Current", "Backspace", "Binding.QuickExit"},
	{"SkinCustomize", "Cursor", "CursorID", "Current", "6979941273", "Skin.CursorID"},
	{"SkinCustomize", "Cursor", "CursorSize", "Current", 1, "Skin.CursorSize"},
	{"SkinCustomize", "Cursor", "CursorTrailDuration", "Current", 0.25, "Skin.CursorTrailDuration"},
	{"SkinCustomize", "Cursor", "CursorTrailID", "Current", "6979941273", "Skin.CursorTrailID"},
	{"SkinCustomize", "Cursor", "CursorTrailOpacity", "Current", 50, "Skin.CursorTrailOpacity"},
	{"SkinCustomize", "Cursor", "CursorTrailSize", "Current", 1, "Skin.CursorTrailSize"},
	{"SkinCustomize", "Circle", "ApproachCircleID", "Current", "6979942451", "Skin.ApproachCircleID"},
	{"SkinCustomize", "Circle", "ApproachCircleSize", "Current", 1, "Skin.ApproachCircleSize"},
	{"SkinCustomize", "Circle", "BaseCircleID", "Current", "8132203100", "Skin.BaseCircleID"},
	{"SkinCustomize", "Circle", "BaseCircleSize", "Current", 1.2, "Skin.BaseCircleSize"},
	{"SkinCustomize", "Circle", "CircleOverlayID", "Current", "8132179567", "Skin.CircleOverlayID"},
	{"SkinCustomize", "Circle", "CircleOverlaySize", "Current", 1.2, "Skin.CircleOverlaySize"},
	{"SkinCustomize", "Circle", "NumberDisplaySize", "Current", 0.5, "Skin.NumberDisplaySize"},
	{"SkinCustomize", "Circle", "OverallCircleSize", "Current", 1, "Skin.OverallCircleSize"},
	{"SkinCustomize", "Circle", "ComboColorList", "Current", "[]", "Skin.ComboColor"},
	{"SkinCustomize", "NumberLayout", "Number0", "Current", "9188735058", "Skin.Number0"},
	{"SkinCustomize", "NumberLayout", "Number1", "Current", "9188734932", "Skin.Number1"},
	{"SkinCustomize", "NumberLayout", "Number2", "Current", "9188734853", "Skin.Number2"},
	{"SkinCustomize", "NumberLayout", "Number3", "Current", "9188734740", "Skin.Number3"},
	{"SkinCustomize", "NumberLayout", "Number4", "Current", "9188734608", "Skin.Number4"},
	{"SkinCustomize", "NumberLayout", "Number5", "Current", "9188734466", "Skin.Number5"},
	{"SkinCustomize", "NumberLayout", "Number6", "Current", "9188734381", "Skin.Number6"},
	{"SkinCustomize", "NumberLayout", "Number7", "Current", "9188734322", "Skin.Number7"},
	{"SkinCustomize", "NumberLayout", "Number8", "Current", "9188734249", "Skin.Number8"},
	{"SkinCustomize", "NumberLayout", "Number9", "Current", "9188734133", "Skin.Number9"},
	{"SkinCustomize", "NumberLayout", "NumberOverlaps", "Current", -0.5, "Skin.NumberOverlaps"}
}

local FunctionList = {}

local MainFrame = script.Parent.Parent

local function GetObjFromSetting(data)
	local obj
	local success, data = pcall(function()
		obj = MainFrame[data[1]].Base[data[2]].Base[data[3]][data[4]]
	end)
	if not success then
		warn("[CLIENT] Setting failed to load")
		warn(data)
		return nil
	else
		return obj
	end
end


FunctionList.getSettings = function(SettingName)
	for _, data in pairs(SettingsList) do
		if data[3] == SettingName then
			return GetObjFromSetting(data)
		end
	end
	return nil
end

FunctionList.getAll = function(isReturnValue)
	local List = {}
	
	for _, data in pairs(SettingsList) do
		local value = GetObjFromSetting(data)
		if isReturnValue and value then
			List[data[3]] = value.Value
		else
			List[data[3]] = value
		end
	end
	return List
end

FunctionList.GetSyncable = function(isReturnValue)
	local List = {}

	for _, data in pairs(SettingsList) do
		local value = GetObjFromSetting(data)
		if isReturnValue and value and data[6] then -- only returns if it's cloud-saveable
			List[data[6]] = value.Value
		else
			List[data[6]] = value
		end
	end
	return List
end

local function GetValueFromCloudName(Name)
	for _, data in pairs(SettingsList) do
		if data[6] == Name then
			return GetObjFromSetting(data)
		end
	end
	return nil
end

FunctionList.CheckExternalChange = function(settingName, value, data)
	-- check the object
	if value.Parent:FindFirstChild("KeyRegistering") then
		-- it's a keybind adjust, and we have to directly call the event
		value.Parent.KeyRegistering.Update:Fire(data)
	elseif value.Parent:FindFirstChild("ColorFrameControl") then
		-- combo color value, same as above
		value.Parent.ValueUpdate:Fire(data)
	end
end

FunctionList.SetSyncable = function(CloudData)
	for SettingName, data in pairs(CloudData) do
		local value = GetValueFromCloudName(SettingName)
		if value then
			FunctionList.CheckExternalChange(SettingName, value, data)
			value.Value = data
		end
	end
end

FunctionList.getSkin = function()
	local List = {}

	for _, data in pairs(SettingsList) do
		if data[1] == "SkinCustomize" then
			local value = GetObjFromSetting(data)
			List[data[3]] = value
		end
	end
	return List
end


FunctionList.getRaw = function()
	return SettingsList
end

FunctionList.getAllDataStoreAvaiable = function()
	local List = {}
	
	for _, data in pairs(SettingsList) do
		if data[5] then
			List[data[5]] = GetObjFromSetting(data)
		end
	end
	
	return List
end

return FunctionList
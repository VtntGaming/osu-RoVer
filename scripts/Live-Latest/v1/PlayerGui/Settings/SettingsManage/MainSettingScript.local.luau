--[LOCATION]:[StarterGui.Settings.SettingFrame.BaseFrame.MainLayer.SettingsManage.MainSettingScript]
--!strict

local SettingsAction = require(script.Parent.SettingsAction)
local CustomSkinImport = require(script.Parent.CustomSkinImport)

-- Avoid holding onto callbacks via BindableEvent; we can safely defer callback execution.

script.Parent.getSettings.OnInvoke = function(settingName)
	if settingName == "All" then
		return SettingsAction.getAll(true)
	elseif settingName == "Skin" then
		return SettingsAction.getSkin()
	elseif settingName ~= nil then
		return SettingsAction.getSettings(settingName).Value
	end
end

local SubscribedConnections = {}
-- {ConnectionName, CallbackFunction, ActiveScript}
-- if the ActiveScript is not found or disabled, this connection will be deleted

local function isValidActiveScript(activeScript: any): boolean
	return activeScript ~= nil
		and typeof(activeScript) == "Instance"
		and activeScript.Parent ~= nil
		and activeScript:IsA("LocalScript")
		and not activeScript.Disabled
end

local function cleanupSubscription(settingName: string, id: string)
	local settingConnection = SubscribedConnections[settingName]
	if not settingConnection then
		return
	end

	local entry = settingConnection[id]
	if entry then
		local cleaners = entry.Cleaners
		if typeof(cleaners) == "table" then
			for _, conn in pairs(cleaners) do
				if typeof(conn) == "RBXScriptConnection" then
					conn:Disconnect()
				end
			end
		end
		settingConnection[id] = nil
	end

	if next(settingConnection) == nil then
		SubscribedConnections[settingName] = nil
	end
end

script.Parent.SubscribeSettingChange.Event:Connect(function(SettingsName, ActiveScript, CallbackFunction)
	local SettingConnection = SubscribedConnections[SettingsName]
	if not SettingConnection then
		SettingConnection = {}
		SubscribedConnections[SettingsName] = SettingConnection
	end
	
	if typeof(SettingsName) ~= "string" or not isValidActiveScript(ActiveScript) or typeof(CallbackFunction) ~= "function" then
		return
	end

	local id = game.HttpService:GenerateGUID()
	local cleaners = {}

	-- Proactively remove the subscription when the source script becomes invalid.
	cleaners[#cleaners + 1] = ActiveScript.Destroying:Connect(function()
		cleanupSubscription(SettingsName, id)
	end)
	cleaners[#cleaners + 1] = ActiveScript.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			cleanupSubscription(SettingsName, id)
		end
	end)
	cleaners[#cleaners + 1] = ActiveScript:GetPropertyChangedSignal("Disabled"):Connect(function()
		if ActiveScript.Disabled then
			cleanupSubscription(SettingsName, id)
		end
	end)

	SettingConnection[id] = {
		Callback = CallbackFunction,
		ActiveScript = ActiveScript,
		Cleaners = cleaners,
	}
end)

for _, obj in pairs(SettingsAction.getAll(false)) do
	local SettingName = obj.Parent.Name
	
	obj.Changed:Connect(function()
		local SettingConnection = SubscribedConnections[SettingName]
		if not SettingConnection then
			return
		end
		
		for id, connection in pairs(SettingConnection) do
			local ActiveScript = connection.ActiveScript
			local Callback = connection.Callback

			if not isValidActiveScript(ActiveScript) or typeof(Callback) ~= "function" then
				cleanupSubscription(SettingName, id)
			else
				-- Defer prevents re-entrancy and avoids holding a BindableEvent around.
				task.defer(Callback, obj.Value)
			end
		end
	end)
end

-- Initiate the default settings
for _, setting in pairs(SettingsAction.getRaw()) do
	local relatedSettingObj = SettingsAction.getSettings(setting[3])
	relatedSettingObj.Value = setting[5]
end

-- Get saved settings from the server datastore

local DataStoreSettings = game.ReplicatedStorage.GetSettings:InvokeServer()
local SettingsVersion = "1.0" -- If there's an old version of the settings, when saving it will be upgraded to a new version

function ToggleSaveSettings()
	local Data = SettingsAction.GetSyncable(true)
	Data.SettingsVersion = SettingsVersion
	game.ReplicatedStorage.GetSettings:InvokeServer(Data)
end

script.Parent.SaveSettings.Event:Connect(ToggleSaveSettings) -- save every time the player close the settings


if DataStoreSettings and #DataStoreSettings > 0 and not DataStoreSettings.SettingsVersion then
	-- it's an old settings from the version V1.46 and below
	-- We beed to convert it into the new settings
	local OldSettingAction = require(script.Parent.OldSettingsDataStoreList)
	local OldSettingDataStoreList = OldSettingAction.GetBase()
	local OldSettingNumberLayout = game.HttpService:JSONDecode(DataStoreSettings.CircleNumberData)
	
	local function GetRelatedOldSetting(settingName)
		local oldSettingName
		local oldSkinSettingsName
		local oldNumberLayoutName
		local avaiableCallback
		for _, a in pairs(OldSettingDataStoreList) do
			if a[2] == settingName then
				oldSettingName = a[1]
				if a[3] and typeof(a[3]) == "function" then
					avaiableCallback = a[3]
				end
				break
			end
		end
		-- check if it's a skin settings
		if not oldSettingName and DataStoreSettings.Skin then
			for _, a in pairs(OldSettingAction.GetSkin()) do
				if a[2] == settingName then
					oldSkinSettingsName = a[1]
					if a[3] and typeof(a[3]) == "function" then
						avaiableCallback = a[3]
					end
					break
				end
			end
		end
		-- check if it's a number layout
		if not oldSettingName and not oldSkinSettingsName then
			for _, a in pairs(OldSettingAction.GetNumber()) do
				if a[2] == settingName then
					oldNumberLayoutName = a[1]
					if a[3] and typeof(a[3]) == "function" then
						avaiableCallback = a[3]
					end
					break
				end
			end
		end
		if not oldSettingName and not oldSkinSettingsName and not oldNumberLayoutName then return nil end
		local Data = DataStoreSettings[oldSettingName] or DataStoreSettings.Skin[oldSkinSettingsName] or OldSettingNumberLayout[oldNumberLayoutName]
		if Data ~= nil and avaiableCallback then
			Data = avaiableCallback(Data)
		end
		return Data or nil
	end
	
	-- Apply user saved change to the objects
	
	for _, setting in pairs(SettingsAction.getRaw()) do
		local relatedSettingObj = SettingsAction.getSettings(setting[3])
		local RelatedOldSettingsData = GetRelatedOldSetting(setting[3])
		
		if RelatedOldSettingsData then
			if relatedSettingObj.Parent:FindFirstChild("KeyRegistering") then
				-- it's a keybind adjust, and we have to directly call the event
				relatedSettingObj.Parent.KeyRegistering.Update:Fire(RelatedOldSettingsData)
			elseif relatedSettingObj.Parent:FindFirstChild("ColorFrameControl") then
				-- combo color value, same as above
				relatedSettingObj.Parent.ValueUpdate:Fire(RelatedOldSettingsData)
			else
				relatedSettingObj.Value = RelatedOldSettingsData
			end
		end
	end	
elseif DataStoreSettings.SettingsVersion then
	-- It's the settings with new configuration
	SettingsAction.SetSyncable(DataStoreSettings)
end

type dataType = number|string|boolean

script.Parent.setSkins.OnInvoke = function(skinData:{[string]:dataType}, isFillBlank:boolean)
	local skinValueData = SettingsAction.getSkin()
	for skinName, value in pairs(skinData) do
		if skinValueData[skinName] and typeof(value) then
			if CustomSkinImport[skinName] then
				CustomSkinImport[skinName](skinValueData[skinName], value)
			else
				skinValueData[skinName].Value = skinData[skinName]				
			end
		else
			warn("Failed to imprort the setting: ", skinName,". The name is not found in the library.")
		end
	end
end

-- We re-check to make sure all the value has in the correct type
for _, obj in pairs(SettingsAction.getAll(false)) do
	if obj:IsA("StringValue") and obj.Parent:FindFirstChild("InputProcess") then
		obj.Parent.Input.Input.Text = obj.Value
	end
end

Instance.new("BoolValue", script.Parent).Name = "SettingsLoaded"
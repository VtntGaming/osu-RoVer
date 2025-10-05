--[LOCATION]:[StarterGui.Settings.SettingFrame.BaseFrame.MainLayer.SettingsManage.CustomSkinImport]
export type CustomSkinImport = {
	[any]: (value:valueObjects, data:dataType) -> ()
}

local CustomSkinImport:CustomSkinImport = {}

type valueObjects = BoolValue|NumberValue|IntValue|StringValue
type dataType = number|string|boolean

function CustomSkinImport.ComboColorList(value, data)
	local _event = value.Parent.ValueUpdate::BindableEvent
	_event:Fire(data)
	
end


return CustomSkinImport
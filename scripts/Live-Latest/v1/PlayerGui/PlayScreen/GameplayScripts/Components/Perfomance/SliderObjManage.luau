--[LOCATION]:[StarterGui.PlayScreen.GameplayScripts.Components.Perfomance.SliderObjManage]
local obj = {}

local MaxObject = 100
local PoolingEnabled = false

function obj.init()
	warn("Slider pooling enabled: ", PoolingEnabled)
	local manage = {}
	manage.ObjInner = {}
	manage.ObjOuter = {}
	
	function manage:AddToCollection(pointObj, isInner)
		local _check = isInner and self.ObjInner or self.ObjOuter
		if #_check < MaxObject and PoolingEnabled then
			pointObj.Parent = nil
			_check[#_check+1] = pointObj
			script.Parent.Value.Value = #self.ObjInner + #self.ObjOuter
		else
			pointObj:Destroy()
		end
	end
	
	function manage:GetFromCollection(sliderPointBase, isInner)
		local _check = isInner and self.ObjInner or self.ObjOuter
		if #_check > 0 and PoolingEnabled then
			local _obj = _check[#_check]
			_obj.Visible = true
			_check[#_check] = nil
			script.Parent.Value.Value = #self.ObjInner + #self.ObjOuter
			return _obj, true
		else
			return sliderPointBase:Clone(), false
		end
	end
	
	return manage
end

export type ObjectManage = typeof(obj.init(...))

return obj
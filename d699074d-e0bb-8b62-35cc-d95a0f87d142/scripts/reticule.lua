local api = uevr.api
local uevrUtils = require('libs/uevr_utils')
local reticule = require("libs/reticule")
reticule.init()

function createReticule(reticuleType)	
	local routine_reticule_c = api:find_uobject("WidgetBlueprintGeneratedClass /Game/UI/Game/UI/Player/RUI_Player_Crosshair.RUI_Player_Crosshair_C")
	current_reticule = UEVR_UObjectHook.get_first_object_by_class(routine_reticule_c, false)
	
	if current_reticule ~= nil then
		local options = {
			removeFromViewport = true,
			twoSided = true,
			ignorePawn = true,
			position_2d = {0, 20}
		}
		local widgetName = "WidgetBlueprintGeneratedClass /Game/UI/Game/UI/Player/RUI_Player_Crosshair.RUI_Player_Crosshair_C"
		reticule.createFromWidget(widgetName, options)
		reticule.setTargetMethod(reticule.ReticuleTargetMethod.RIGHT_CONTROLLER)
	end					
end

setInterval(1000, function()
	if not reticule.exists() then
		createReticule()
	end
end)

reticule.showConfiguration(nil, {{id="uevr_reticule_update_distance", initialValue = 400},{id="uevr_reticule_update_scale", initialValue = 1.0}})


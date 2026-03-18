local api = uevr.api
local uevrUtils = require('libs/uevr_utils')
local attachments = require('libs/attachments')
local controllers = require('libs/controllers')

local attachments = require("libs/attachments")

local routine_cat_c = api:find_uobject("Class /Script/Routine.RoutineGameCAT")
attachments.init()

function getWeaponMesh()
	if uevrUtils.getValid(pawn) ~= nil then
		local currentWeapon =  UEVR_UObjectHook.get_first_object_by_class(routine_cat_c, false)      
		if currentWeapon ~= nil then return currentWeapon.RootComponent end
	end
	return nil
end

attachments.registerOnGripUpdateCallback(function()	
	--return getWeaponMesh()
	return getWeaponMesh(), controllers.getController(Handed.Right), nil, nil, nil, nil, false, true
end)


local api = uevr.api
local vr = uevr.params.vr
local params = uevr.params
local callbacks = params.sdk.callbacks
local uevrUtils = require("libs/uevr_utils")
local interaction = require("libs/interaction")
local reticule = require("libs/reticule")
local routine_cat_c = api:find_uobject("Class /Script/Routine.RoutineGameCAT")

local function is_cutscene()
	local cine_video_c = api:find_uobject("WidgetBlueprintGeneratedClass /Game/UI/Game/Cine/RUI_Cine_Video.RUI_Cine_Video_C")
	local cine_video_object = UEVR_UObjectHook.get_first_object_by_class(cine_video_c, false)
	if cine_video_object ~= nil then 
		return true
	end
	return false
end


local function apply_cinematic_mode()
	reticule.destroy()
	vr.set_mod_value("VR_2DScreenMode", true)

	vr.set_mod_value("VR_AimMethod", "0")
	vr.set_mod_value("VR_RoomscaleMovement", "0")
	vr.set_mod_value("VR_DecoupledPitch", "0")
				
	vr.set_mod_value("VR_CameraForwardOffset", "0.000000")
	vr.set_mod_value("VR_CameraRightOffset", "0.000000")
	vr.set_mod_value("VR_CameraUpOffset", "0.000000")				
	vr.set_mod_value("VR_LerpCameraYaw", "false")

	
	vr.set_mod_value("VR_DecoupledPitchUIAdjust", "true")
	
	
	UEVR_UObjectHook.set_disabled(true)

	local pawn = api:get_local_pawn(0)
	if pawn ~= nil and pawn.Mesh ~=nil then
		pawn.Mesh:SetVisibility(true)
		pawn.Mesh:SetRenderInMainPass(true)
		pawn.Mesh:SetRenderCustomDepth(true)
	end 

end

local function is_main_menu()
	local pawn = api:get_local_pawn(0)

	if pawn ~= nil then
		return string.find(pawn:get_full_name(), "Menu_Main")
	end		
	return false
end

local function apply_menu_mode()
	reticule.destroy()
	vr.set_mod_value("VR_2DScreenMode", false)

	vr.set_mod_value("VR_AimMethod", "0")
	vr.set_mod_value("VR_RoomscaleMovement", "0")
	vr.set_mod_value("VR_DecoupledPitch", "0")
				
	vr.set_mod_value("VR_CameraForwardOffset", "0.000000")
	vr.set_mod_value("VR_CameraRightOffset", "0.000000")
	vr.set_mod_value("VR_CameraUpOffset", "0.000000")				
	vr.set_mod_value("VR_LerpCameraYaw", "false")

	
	vr.set_mod_value("VR_DecoupledPitchUIAdjust", "false")

	UEVR_UObjectHook.set_disabled(true)

	local pawn = api:get_local_pawn(0)
	if pawn ~= nil and pawn.Mesh ~=nil then
		pawn.Mesh:SetVisibility(false)
		pawn.Mesh:SetRenderInMainPass(false)
		pawn.Mesh:SetRenderCustomDepth(false)
	end 
end

local function apply_game_mode()
	UEVR_UObjectHook.set_disabled(false)
	vr.set_mod_value("VR_2DScreenMode", false)

	vr.set_mod_value("VR_AimMethod", "2")
	vr.set_mod_value("VR_RoomscaleMovement", "1")
	vr.set_mod_value("VR_DecoupledPitch", "1")
		
	vr.set_mod_value("VR_CameraForwardOffset", "0.000000")
	vr.set_mod_value("VR_CameraRightOffset", "0.000000")
	vr.set_mod_value("VR_CameraUpOffset", "0.000000")				
	vr.set_mod_value("VR_LerpCameraYaw", "false")

	
    vr.set_mod_value("VR_DecoupledPitchUIAdjust", "true")

end

local function apply_6dof_changes()
	local pawn = api:get_local_pawn()

	if pawn ~= nil then

		-- current_weapon = UEVR_UObjectHook.get_first_object_by_class(routine_cat_c, false)
		-- if current_weapon ~=nil then
		-- 	attachment = UEVR_UObjectHook.get_or_add_motion_controller_state(current_weapon.SkeletalMeshComponent)
		-- 	if attachment ~=nil then
		-- 		print("attaching da gun")
		-- 		attachment:set_hand(Handed.Right)
		-- 		attachment:set_permanent(true)
		-- 	end
		-- end
		
		if pawn.Mesh ~= nil then
			local attachedChildrenMeshes = pawn.Mesh.AttachChildren
			for i, mesh in ipairs(attachedChildrenMeshes) do
				if mesh then
					print("hiding da mesh")
					mesh:SetVisibility(false, false)
				end
			end
		end	
	end
end	

function on_level_change(level)
	reticule.destroy()
	if is_main_menu() then
		print("applying menu")
		apply_menu_mode()
	elseif is_cutscene() then
		print("applying cutscene")
		apply_cinematic_mode()
	else
		print("applying game")
		apply_game_mode()
		apply_6dof_changes()
	end
end

uevr.sdk.callbacks.on_pre_engine_tick(function(engine, delta_time)
	current_weapon = UEVR_UObjectHook.get_first_object_by_class(routine_cat_c, false)
	if current_weapon ~= nil then
		if current_weapon.Pointlight_InspectCAT.Intensity > 0.01 then
			local state = UEVR_UObjectHook.get_or_add_motion_controller_state(pawn.CameraComponent)
			local vec = Vector3f.new(0, 0, 0)
			interaction.showInteractionLaser(true)
			state:set_hand(0)
			state:set_permanent(true)
			state:set_location_offset(vec)
		else
			local state = UEVR_UObjectHook.get_or_add_motion_controller_state(pawn.CameraComponent)
			local vec = Vector3f.new(0, -10, 30)
			interaction.showInteractionLaser(false)
			state:set_hand(1)
			state:set_permanent(true)
			state:set_location_offset(vec)
		end			
	end

	local routine_id_c = api:find_uobject("BlueprintGeneratedClass /Game/Blueprint/Equipment/ID/Routine_ID.Routine_ID_C")
	local id = UEVR_UObjectHook.get_first_object_by_class(routine_id_c, false)
	if id~= nil and id.StaticMesh:IsVisible() == true then
		print("hiding da id")
		id.StaticMesh:SetVisibility(false, false)
	end

	local routine_helmet_c = api:find_uobject("BlueprintGeneratedClass /Game/Blueprint/Equipment/Helmet/Routine_Helmet.Routine_Helmet_C")		
	local helmet = UEVR_UObjectHook.get_first_object_by_class(routine_helmet_c, false)
	if helmet~= nil and helmet.SkeletalMesh:IsVisible() == true then
		print("hiding da helmet")
		helmet.SkeletalMesh:SetVisibility(false, false)
	end		
end)
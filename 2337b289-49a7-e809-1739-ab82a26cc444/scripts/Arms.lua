--require(".\\Config\\CONFIG")
--require(".\\Base\\Subsystems\\UEHelperFunctions")
local api = uevr.api
local params = uevr.params
local callbacks = params.sdk.callbacks
local vr=uevr.params.vr

local function find_required_object(name)
	local obj = uevr.api:find_uobject(name)
	if not obj then
		print("Cannot find " .. name)
		return nil
	end

	return obj
end
local find_static_class = function(name)
    local c = find_required_object(name)
    return c:get_class_default_object()
end


local pawn = api:get_local_pawn(0)
local lossy_offset= Vector3f.new(0,math.pi/2,0)
local glove_mesh = nil
local master_mat = nil
local has_found_overlays = false
local can_disable_overlays = false
local goggles = nil
local masks = nil

local last_level = nil
local kismet_math_library = find_static_class("Class /Script/Engine.KismetMathLibrary")

local loadout = nil
local in_loadout = false
local check_refill = false
local last_refill = false
local might_be_refilling = false
local function update_weapon_offset(Body_mesh)
    if not Body_mesh then print("nil") return end
	
   -- local attach_socket_name = weapon_mesh.AttachSocketName
	local PMesh= Body_mesh
	local WeaponMesh=nil
	local ShieldMesh=nil
	local ArrowMesh=nil
	local BowMesh=nil
	for i, Mesh in ipairs(PMesh.AttachChildren) do
		if string.find(Mesh:get_fname():to_string(),"Main") then
		--print(Mesh:get_fname():to_string())
			if Mesh.AttachSocketName:to_string()=="Weapon_Socket" then
			WeaponMesh=Mesh	
			UEVR_UObjectHook.get_or_add_motion_controller_state(WeaponMesh):set_hand(1)
			UEVR_UObjectHook.get_or_add_motion_controller_state(WeaponMesh):set_rotation_offset(Vector3f.new(0,-30/190*math.pi,-math.pi/2))
			--print("foundWeapon")
			elseif Mesh.AttachSocketName:to_string()=="Shield_Socket" then
			ShieldMesh=Mesh
		--	print("foundShield")
			UEVR_UObjectHook.get_or_add_motion_controller_state(ShieldMesh):set_hand(0)
			UEVR_UObjectHook.get_or_add_motion_controller_state(ShieldMesh):set_rotation_offset(Vector3f.new(math.pi,math.pi,0))
			UEVR_UObjectHook.get_or_add_motion_controller_state(ShieldMesh):set_location_offset(Vector3f.new(0,0,-30))
			elseif Mesh.AttachSocketName:to_string()=="Torch_Socket" then
			BowMesh=Mesh
		--	print("foundShield")
			UEVR_UObjectHook.get_or_add_motion_controller_state(BowMesh):set_hand(0)
			UEVR_UObjectHook.get_or_add_motion_controller_state(BowMesh):set_rotation_offset(Vector3f.new(0,0,math.pi/2))--math.pi,math.pi,0))
			UEVR_UObjectHook.get_or_add_motion_controller_state(BowMesh):set_location_offset(Vector3f.new(0,0,0))
			UEVR_UObjectHook.get_or_add_motion_controller_state(BowMesh):set_permanent(false)
			end
		elseif string.find(Mesh:get_fname():to_string(),"Drawn Arrow") then
			ArrowMesh=Mesh
			UEVR_UObjectHook.get_or_add_motion_controller_state(ArrowMesh):set_hand(1)
			UEVR_UObjectHook.get_or_add_motion_controller_state(ArrowMesh):set_rotation_offset(Vector3d.new(0,0,90))
			UEVR_UObjectHook.get_or_add_motion_controller_state(ArrowMesh):set_location_offset(Vector3f.new(0,0,60))
			UEVR_UObjectHook.get_or_add_motion_controller_state(ArrowMesh):set_permanent(true)
		end
	end
	
   
	--	
	pcall(function()

	
	--	UEVR_UObjectHook.get_or_add_motion_controller_state(PMesh):set_location_offset(lossy_offset)
	
	if isWeaponDrawn then 
		WeaponMesh:SetVisibility(true)
	else WeaponMesh:SetVisibility(false)
	end
	UEVR_UObjectHook.get_or_add_motion_controller_state(WeaponMesh):set_permanent(true)
	end)
end
uevr.sdk.callbacks.on_pre_engine_tick(function(engine, delta)
 pawn = api:get_local_pawn(0)
 local BodyMesh=pawn.FirstPersonSkeletalMeshComponent
 update_weapon_offset(BodyMesh)
end)
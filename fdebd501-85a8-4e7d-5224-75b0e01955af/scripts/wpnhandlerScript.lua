--local CurrentEquippedWpnObject=nil
--local LastEquippedWpnObject=nil
--local EquippedWpnMagazine=nil
--local LastEquippedWpnMagazine=nil
--local CurrentMeleeWeaponMesh=nil
--local ArrayGunWpns={}
--local ArrayMeleeWpns={}
--local CurrentEquippedWpnObjectMesh =nil
--local GunAlreadyInUse = 0
--local MeleeAlreadyInUse=0 
	local api = uevr.api
	
	local params = uevr.params
	local callbacks = params.sdk.callbacks
	
	
	
	local pawn = api:get_local_pawn(0)
	--print(pawn)
	if pawn == nil then print("pawn is nil") 
	end

-- equipment slots:
local EquippedPrimary			= nil
local EquippedSecondary		= nil
local EquippedSidearm			= nil
local EquippedMelee			= nil
local EquippedPrimaryLast			= nil
local EquippedSecondaryLast		= nil
local EquippedSidearmLast			= nil
local EquippedMeleeLast			= nil

local CurrentlyUsedMelee		= nil
local CurrentlyUsedWeapon		= nil	
local CurrentlyUsedMeleeLast 		= nil
local CurrentlyUsedWeaponLast		= nil




	pcall(function()
		EquippedPrimary		= 	pawn.Equipped_Primary
		UEVR_UObjectHook.remove_motion_controller_state(EquippedPrimary.SkeletalMesh) 
	end)
	pcall(function()
		EquippedSecondary	= 	pawn.Equipped_Secondary
		UEVR_UObjectHook.remove_motion_controller_state(EquippedSecondary.SkeletalMesh) 
	end)
	pcall(function()
		EquippedMelee   	=	pawn.Equipped_Melee
		UEVR_UObjectHook.remove_motion_controller_state(EquippedMelee.SkeletalMesh) 
	end)
	pcall(function()
		EquippedSidearm 	= 	pawn.Equipped_Pistol
		UEVR_UObjectHook.remove_motion_controller_state(EquippedSidearm.SkeletalMesh) 
	end)


uevr.sdk.callbacks.on_pre_engine_tick(
function(engine, delta)

	pawn = api:get_local_pawn(0)
	--pawn:ChangePlayerPerspective(true)

 pcall(function()	
EquippedPrimary		= 	pawn.Equipped_Primary
end)	
pcall(function()
EquippedSecondary	= 	pawn.Equipped_Secondary
end)
pcall(function()
EquippedSidearm 	= 	pawn.Equipped_Pistol
end)
pcall(function()
EquippedMelee   	=	pawn.Equipped_Melee
end)
pcall(function()
CurrentlyUsedWeapon = 	pawn.CurrentFirearm
end)
pcall(function()
CurrentlyUsedMelee	=   pawn.CurrentMeleeWeapon
end)


pcall(function()
	if string.find(pawn.CurrentMeleeWeapon:get_fname():to_string(), "FiremansAxe") then
	print ("The word Axe was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_rotation_offset(Vector4f.new(0.8751744627952576,-0.48380744457244873,0,0))
	elseif string.find(pawn.CurrentMeleeWeapon:get_fname():to_string(), "Shovel") then
	print ("The word Shovel was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_rotation_offset(Vector3f.new (180,0,0))
		elseif string.find(pawn.CurrentMeleeWeapon:get_fname():to_string(), "Golf") then
	print ("The word Shovel was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_rotation_offset(Vector3f.new (180,0,0))
		elseif string.find(pawn.CurrentMeleeWeapon:get_fname():to_string(), "Kukri") then
	print ("The word Shovel was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_rotation_offset(Vector3f.new (0,90,0))
		elseif string.find(pawn.CurrentMeleeWeapon:get_fname():to_string(), "IceAxe") then
	print ("The word Shovel was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_rotation_offset(Vector3f.new (0,90,0))
	elseif string.find(pawn.CurrentMeleeWeapon:get_fname():to_string(), "PipeWrench") then
	print ("The word Shovel was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_rotation_offset(Vector3f.new (-79*math.pi/2/180,math.pi/(2),0))
	elseif string.find(pawn.CurrentMeleeWeapon:get_fname():to_string(), "BaseballBat") then
	print ("The word Shovel was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_rotation_offset(Vector3f.new (0,0,0))
	elseif string.find(pawn.CurrentMeleeWeapon:get_fname():to_string(), "Pipe_C") then
	print ("The word Shovel was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_rotation_offset(Vector3f.new (0,0,0))
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_location_offset(Vector3f.new (0,-40,0))
	elseif string.find(pawn.CurrentMeleeWeapon:get_fname():to_string(), "CandyCane") then
	print ("The word Shovel was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_rotation_offset(Vector3f.new (-math.pi/2,math.pi/2,0))
	elseif string.find(pawn.CurrentMeleeWeapon:get_fname():to_string(), "SledgeHammer") then
	print ("The word Shovel was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_rotation_offset(Vector3f.new (-math.pi/2,math.pi/2,0))
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_location_offset(Vector3f.new (-20,0,0))
	elseif string.find(pawn.CurrentMeleeWeapon:get_fname():to_string(), "DarkMachete") then
	print ("The word Shovel was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_rotation_offset(Vector3d.new (0,1.571,1.571))
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_location_offset(Vector3f.new (0,0,-15))
	elseif string.find(pawn.CurrentMeleeWeapon:get_fname():to_string(), "HuntingHatchet") then
	print ("The word Shovel was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_rotation_offset(Vector3d.new (-1.571,1.571,0))
	elseif string.find(pawn.CurrentMeleeWeapon:get_fname():to_string(), "WornKnife") then
	print ("The word Shovel was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_rotation_offset(Vector3d.new (1.571*2,1.571,0))
	--UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_location_offset(Vector3f.new (0,0,-15))
	end
end)

pcall(function()
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedPrimary.SkeletalMesh):set_rotation_offset(Vector3d.new (0,math.pi/2,0))
end)
pcall(function()
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedSecondary.SkeletalMesh):set_rotation_offset(Vector3d.new (0,math.pi/2,0))
end)
pcall(function()
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedSidearm.SkeletalMesh):set_rotation_offset(Vector3d.new (0,math.pi/2,0))
end)
pcall(function()	
	if string.find(EquippedPrimary:get_fname():to_string(), "Vector") then
	print ("The word Axe was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedPrimary.SkeletalMesh):set_rotation_offset(Vector3d.new (0,0,0))
	elseif string.find(EquippedPrimary:get_fname():to_string(), "Makeshift") then
	print ("The word Axe was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedPrimary.SkeletalMesh):set_rotation_offset(Vector3d.new (0,0,0))
		elseif string.find(EquippedPrimary:get_fname():to_string(), "Steyr") then
	print ("The word Axe was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedPrimary.SkeletalMesh):set_rotation_offset(Vector3d.new (0,0,0))
			elseif string.find(EquippedPrimary:get_fname():to_string(), "MP5") then
	print ("The word Axe was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedPrimary.SkeletalMesh):set_location_offset(Vector3d.new (-10,0,0))
		elseif string.find(EquippedPrimary:get_fname():to_string(), "Hunting") then
	print ("The word Axe was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedPrimary.SkeletalMesh):set_rotation_offset(Vector3d.new (0,0,0))
		elseif string.find(EquippedPrimary:get_fname():to_string(), "Crossbow") then
	print ("The word Axe was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedPrimary.SkeletalMesh):set_rotation_offset(Vector3d.new (0,0,0))
	end
end)
pcall(function()	
	if string.find(EquippedSecondary:get_fname():to_string(), "Vector") then
	print ("The word Axe was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedSecondary.SkeletalMesh):set_rotation_offset(Vector3d.new (0,0,0))
	elseif string.find(EquippedSecondary:get_fname():to_string(), "Makeshift") then
	print ("The word Axe was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedSecondary.SkeletalMesh):set_rotation_offset(Vector3d.new (0,0,0))
	elseif string.find(EquippedSecondary:get_fname():to_string(), "Steyr") then
	print ("The word Axe was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedSecondary.SkeletalMesh):set_rotation_offset(Vector3d.new (0,0,0))
	elseif string.find(EquippedSecondary:get_fname():to_string(), "MP5") then
	print ("The word Axe was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedSecondary.SkeletalMesh):set_location_offset(Vector3d.new (-10,0,0))
	elseif string.find(EquippedSecondary:get_fname():to_string(), "Hunting") then
	print ("The word Axe was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedSecondary.SkeletalMesh):set_rotation_offset(Vector3d.new (0,0,0))
	elseif string.find(EquippedSecondary:get_fname():to_string(), "Crossbow") then
	print ("The word Axe was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedSecondary.SkeletalMesh):set_rotation_offset(Vector3d.new (0,0,0))
	end
end)	

pcall(function()	
	if string.find(EquippedSidearm:get_fname():to_string(), "G18") then
	print ("The word Axe was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedSidearm.SkeletalMesh):set_rotation_offset(Vector3d.new (0,0,0))
	elseif string.find(EquippedSidearm:get_fname():to_string(), "Makeshift") then
	print ("The word Axe was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedSidearm.SkeletalMesh):set_rotation_offset(Vector3d.new (0,0,0))
	elseif string.find(EquippedSidearm:get_fname():to_string(), "Steyr") then
	print ("The word Axe was found.")
	UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedSidearm.SkeletalMesh):set_rotation_offset(Vector3d.new (0,0,0))
	
	
	end
end)	
	--UEVR_UObjectHook.get_or_add_motion_controller_state(Wmesh):set_location_offset(Vector3d.new(18, 0, 0))     -0.48380744457244873,
	--UEVR_UObjectHook.get_or_add_motion_controller_state(Wmesh):set_permanent(true)                             0.0,
																											
	


--if CurrentlyUsedWeapon ~= CurrentlyUsedWeaponLast or CurrentlyUsedMelee ~= CurrentlyUsedMeleeLast then
if 	EquippedPrimary	== CurrentlyUsedWeapon and EquippedPrimary~=nil  then
		UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedPrimary.SkeletalMesh):set_hand(1)
	 --UEVR_UObjectHook.remove_motion_controller_state(EquippedPrimary.SkeletalMesh) 
		--pcall(function()
		--UEVR_UObjectHook.remove_motion_controller_state(EquippedPrimary.SkeletalMesh) 
		--end)
		pcall(function()
			UEVR_UObjectHook.remove_motion_controller_state(EquippedSecondary.SkeletalMesh) 
			--UEVR_UObjectHook.remove_motion_controller_state(CurrentlyUsedWeaponLast.SkeletalMesh) 
		end)
		
		pcall(function()
			UEVR_UObjectHook.remove_motion_controller_state(EquippedSidearm.SkeletalMesh) 
		end)
		pcall(function()
				UEVR_UObjectHook.remove_motion_controller_state(EquippedMelee.StaticMesh)
		end)
		
elseif EquippedSecondary == CurrentlyUsedWeapon and EquippedSecondary ~=nil  then
		
		UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedSecondary.SkeletalMesh):set_hand(1)
		
		pcall(function()
		UEVR_UObjectHook.remove_motion_controller_state(EquippedPrimary.SkeletalMesh) 
		end)
		--pcall(function()
		--	UEVR_UObjectHook.remove_motion_controller_state(EquippedSecondary.SkeletalMesh) 
		--	--UEVR_UObjectHook.remove_motion_controller_state(CurrentlyUsedWeaponLast.SkeletalMesh)
		--end)
		
		pcall(function()
			UEVR_UObjectHook.remove_motion_controller_state(EquippedSidearm.SkeletalMesh) 
		end)
		pcall(function()
				UEVR_UObjectHook.remove_motion_controller_state(EquippedMelee.StaticMesh)
		end)
		
		
elseif  EquippedMelee == CurrentlyUsedMelee  and EquippedMelee ~=nil then
		UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedMelee.StaticMesh):set_hand(1)
	
		pcall(function()
		UEVR_UObjectHook.remove_motion_controller_state(EquippedPrimary.SkeletalMesh) 
		end)
		pcall(function()
			UEVR_UObjectHook.remove_motion_controller_state(EquippedSecondary.SkeletalMesh) 
			--UEVR_UObjectHook.remove_motion_controller_state(CurrentlyUsedWeaponLast.SkeletalMesh)
		end)
		
		pcall(function()
			UEVR_UObjectHook.remove_motion_controller_state(EquippedSidearm.SkeletalMesh) 
		end)
		--pcall(function()
		--		UEVR_UObjectHook.remove_motion_controller_state(EquippedMelee.StaticMesh)
		--end)
		
elseif EquippedSidearm == CurrentlyUsedWeapon and EquippedSidearm ~= nil then
		UEVR_UObjectHook.get_or_add_motion_controller_state(EquippedSidearm.SkeletalMesh):set_hand(1)
		
		pcall(function()
		UEVR_UObjectHook.remove_motion_controller_state(EquippedPrimary.SkeletalMesh) 
		end)
		pcall(function()
			UEVR_UObjectHook.remove_motion_controller_state(EquippedSecondary.SkeletalMesh) 
			--UEVR_UObjectHook.remove_motion_controller_state(CurrentlyUsedWeaponLast.SkeletalMesh)
		end)
		
		--pcall(function()
		--	UEVR_UObjectHook.remove_motion_controller_state(EquippedSidearm.SkeletalMesh) 
		--end)
		pcall(function()
				UEVR_UObjectHook.remove_motion_controller_state(EquippedMelee.StaticMesh)
		end)
else    
		pcall(function()
		UEVR_UObjectHook.remove_motion_controller_state(CurrentlyUsedWeaponLast.SkeletalMesh) 
		end)
		
		pcall(function()
		UEVR_UObjectHook.remove_motion_controller_state(EquippedPrimary.SkeletalMesh) 
		end)
		
		pcall(function()
			UEVR_UObjectHook.remove_motion_controller_state(EquippedSecondary.SkeletalMesh) 
			--UEVR_UObjectHook.remove_motion_controller_state(CurrentlyUsedWeaponLast.SkeletalMesh)
		end)
		
		pcall(function()
			UEVR_UObjectHook.remove_motion_controller_state(EquippedSidearm.SkeletalMesh) 
		end)
		pcall(function()
				UEVR_UObjectHook.remove_motion_controller_state(CurrentlyUsedMeleeLast.StaticMesh)
		end)
		pcall(function()
				UEVR_UObjectHook.remove_motion_controller_state(EquippedMelee.StaticMesh)
		end)		
end


--end
--	print(CurrentlyUsedWeapon:get_fname():to_string())
--	print("Primary : ".. EquippedPrimary:get_fname():to_string())
--	print("Secondary: "..EquippedSecondary:get_fname():to_string())
--	print(CurrentlyUsedMelee:get_fname():to_string())
--	print("Melee: " .. EquippedMelee:get_fname():to_string())
--	print("   ")
--	print("   ")
--	print("   ")
--end

CurrentlyUsedMeleeLast=CurrentlyUsedMelee
CurrentlyUsedWeaponLast=CurrentlyUsedWeapon
EquippedPrimaryLast		=  EquippedPrimary		
EquippedSecondaryLast	=  EquippedSecondary		
EquippedSidearmLast		=  EquippedSidearm		
EquippedMeleeLast		=  EquippedMelee			




--WeaponRotation Edits:
--if CurrentlyUsedWeapon ~= nil then
--print(CurrentlyUsedWeapon:get_fname():to_string())
--	if string.find(CurrentlyUsedWeapon:get_fname():to_string(), "Steyr") then
--		print ("The word Steyr was found.")
--		UEVR_UObjectHook.get_or_add_motion_controller_state(CurrentlyUsedWeapon.SkeletalMesh):set_rotation_offset(Vector4f.new(1,-0.0,0,0))
--	elseif	string.find(CurrentlyUsedWeapon:get_fname():to_string(), "AKM") then
--		print ("The word AKM was found.")
--		UEVR_UObjectHook.get_or_add_motion_controller_state(CurrentlyUsedWeapon.SkeletalMesh):set_rotation_offset(Vector4f.new(-0.7049100399017334,-0.0,0.709296703338623,0))
--	elseif	string.find(CurrentlyUsedWeapon:get_fname():to_string(), "G18") then
--		print ("The word G18 was found.")
--		UEVR_UObjectHook.get_or_add_motion_controller_state(CurrentlyUsedWeapon.SkeletalMesh):set_rotation_offset(Vector4f.new(1,-0.0,0,0))
--	end
--end
--Rotaion scripts--
	pcall(function()
print(pawn.CurrentMeleeWeapon:get_fname():to_string())
end)


end)	
	
	
---new Code
	--get gun mesh and add to array
--	if pawn.CurrentFirearm ~=nil  then
--		CurrentEquippedWpnObjectMesh = pawn.CurrentFirearm.SkeletalMesh
--		--check if wpn arlready in array
--		for i, Wmesh in ipairs(ArrayGunWpns) do
--			if Wmesh==CurrentEquippedWpnObject then
--				GunAlreadyInUse=1
--			end
--		end
--		-- if not in array add to array 
--		if GunAlreadyInUse== 0 then
--			table.insert(ArrayGunWpns, CurrentEquippedWpnObjectMesh)
--		else	
--		GunAlreadyInUse=0 --reset
--		end
--	end
--	
--	--get melee mesh and add to array
--	if pawn.CurrentMeleeWeapon ~= nil then
--		CurrentMeleeWeaponMesh = pawn.CurrentMeleeWeapon.StaticMesh
--		--check if wpn arlready in array
--		for i, Mmesh in ipairs(ArrayMeleeWpns) do
--			if Mmesh==CurrentMeleeWeaponMesh then
--					MeleeAlreadyInUse=1
--			end
--		end
--		-- if not in array add to array 
--		if MeleeAlreadyInUse == 0 then
--			table.insert(ArrayMeleeWpns, CurrentMeleeWeaponMesh)
--		else
--		MeleeAlreadyInUse =0--reset
--		end		
--	end
--	
--	--go through all meshes in the array and check its status
--	for i, Wmesh in ipairs(ArrayGunWpns) do
--		EquippedWpnMagazine= Wmesh:GetChildComponent(0):GetChildComponent(0)
--		if Wmesh == CurrentEquippedWpnObject then 
--			Wmesh:SetRenderInMainPass(true)
--			EquippedWpnMagazine:SetVisibility(true)
--		elseif Wmesh ~= CurrentEquippedWpnObjectMesh then
--			Wmesh:SetRenderInMainPass(false)
--			EquippedWpnMagazine:SetVisibility(false)
--
--			---INVENTORY???                   MISSING CODE
-- 			---
--			
--			
--		end
--	end
--	
--	for i, Mmesh in ipairs(ArrayMeleeWpns) do
--		if Mmesh == CurrentMeleeWeaponMesh then 
--			Mmesh:SetRenderInMainPass(true)
--			EquippedWpnMagazine:SetVisibility(true)
--		elseif Mmesh ~= CurrentEquippedWpnObjectMesh then
--			Mmesh:SetRenderInMainPass(false)
--			EquippedWpnMagazine:SetVisibility(false)
--		end
--	end	
		
		
--		if CurrentEquippedWpnObject ~=nil then
--			EquippedWpnMagazine=CurrentEquippedWpnObject.SkeletalMesh:GetChildComponent(0):GetChildComponent(0)
--		end
--		--if no weapon equipped
--		if CurrentEquippedWpnObject == nil then
--			--check if LastWeapon has an object
--			if LastEquippedWpnObject ~=nil then
--				--Make last weapon invisible
--				LastEquippedWpnObject.SkeletalMesh:SetRenderInMainPass(false)
--			end
--			--LastEquippedWpnObject.SkeletalMesh.AttachChildren.SceneComponen_DefaultSceneRoot:SetRenderInMainPass(false)
--			if LastEquippedWpnMagazine ~=nil then
--				--EquippedWpnMagazine:SetRenderInMainPass(false)
--				LastEquippedWpnMagazine:SetVisibility(false)
--				--EquippedWpnMagazine:SetVisibility(false)
--			end
--		
--		elseif CurrentEquippedWpnObject ~=nil and LastEquippedWpnObject~= CurrentEquippedWpnObject then
--			if LastEquippedWpnObject ~=nil then
--				LastEquippedWpnObject.SkeletalMesh:SetRenderInMainPass(false)
--			end
--			--Make Current Weapon visible
--			CurrentEquippedWpnObject.SkeletalMesh:SetRenderInMainPass(true)
--			--Last equipped weapon now obsolete and current weapon becomes last equippe weapon for next cycle
--			LastEquippedWpnObject=CurrentEquippedWpnObject
--			
--			--Same for magazine
--			if LastEquippedWpnMagazine ~=nil then
--				--EquippedWpnMagazine:SetRenderInMainPass(false)
--				LastEquippedWpnMagazine:SetVisibility(false)
--			end
--			EquippedWpnMagazine:SetVisibility(true)
--			LastEquippedWpnMagazine=EquippedWpnMagazine
--		elseif CurrentEquippedWpnObject ~=nil and LastEquippedWpnObject== CurrentEquippedWpnObject then
--			CurrentEquippedWpnObject.SkeletalMesh:SetRenderInMainPass(true)
--			EquippedWpnMagazine:SetVisibility(true)
--			LastEquippedWpnObject=CurrentEquippedWpnObject
--			LastEquippedWpnMagazine=EquippedWpnMagazine
--		--elseif CurrentEquippedWpnObject ~= nil  then
--		--	LastEquippedWpnObject=CurrentEquippedWpnObject
--		--	LastEquippedWpnObject.SkeletalMesh:SetRenderInMainPass(true)
--		--	--EquippedWpnMagazine=CurrentEquippedWpnObject.SkeletalMesh:GetChildComponent(0):GetChildComponent(0)
--		--	print(EquippedWpnMagazine:get_fname())
--		--	EquippedWpnMagazine:SetVisibility(true)
--		end
--	
--	--Always make old weapons invisible--
--	
--	
--	--
--	
--	if pawn.CurrentMeleeWeapon ~= nil then
--		CurrentMeleeWeaponMesh = pawn.CurrentMeleeWeapon.StaticMesh
--		CurrentMeleeWeaponMesh:SetVisibility(true)
--	elseif pawn.MeleeWeaponEquipped == false then
--		if CurrentMeleeWeaponMesh ~=nil then
--		CurrentMeleeWeaponMesh:SetVisibility(false)
--		end
--	end
--	
--	
--	if pawn.CurrentMeleeWeapon ~=nil then
--	print(pawn.CurrentMeleeWeapon:get_fname():to_string())
--	end
--if CurrentlyUsedWeapon ~= nil then
--print(CurrentlyUsedWeapon:get_fname():to_string())
--	if string.find(CurrentlyUsedWeapon:get_fname():to_string(), "Steyr") then
--		print ("The word Steyr was found.")
--		UEVR_UObjectHook.get_or_add_motion_controller_state(CurrentlyUsedWeapon.SkeletalMesh):set_rotation_offset(Vector4f.new(1,-0.0,0,0))
--	elseif	string.find(CurrentlyUsedWeapon:get_fname():to_string(), "AKM") then
--		print ("The word AKM was found.")
--		UEVR_UObjectHook.get_or_add_motion_controller_state(CurrentlyUsedWeapon.SkeletalMesh):set_rotation_offset(Vector4f.new(-0.7049100399017334,-0.0,0.709296703338623,0))
--	elseif	string.find(CurrentlyUsedWeapon:get_fname():to_string(), "G18") then
--		print ("The word G18 was found.")
--		UEVR_UObjectHook.get_or_add_motion_controller_state(CurrentlyUsedWeapon.SkeletalMesh):set_rotation_offset(Vector4f.new(1,-0.0,0,0))
--	end
--end
----Rotaion scripts--
--
--if CurrentlyUsedMelee ~= nil then	
--	if string.find(pawn.CurrentMeleeWeapon:get_fname():to_string(), "FiremansAxe") then
--	print ("The word Axe was found.")
--	UEVR_UObjectHook.get_or_add_motion_controller_state(CurrentlyUsedMelee.StaticMesh):set_rotation_offset(Vector4f.new(0.8751744627952576,-0.48380744457244873,0,0))
--	elseif string.find(pawn.CurrentMeleeWeapon:get_fname():to_string(), "FiremansAxe") then
--	print ("The word Axe was found.")
--	UEVR_UObjectHook.get_or_add_motion_controller_state(CurrentlyUsedMelee.StaticMesh):set_rotation_offset(Vector4f.new(0.8751744627952576,-0.48380744457244873,0,0))
--	--UEVR_UObjectHook.get_or_add_motion_controller_state(Wmesh):set_location_offset(Vector3d.new(18, 0, 0))     -0.48380744457244873,
--	--UEVR_UObjectHook.get_or_add_motion_controller_state(Wmesh):set_permanent(true)                             0.0,
--																											
--	end
--end
	
	
	
	--local skeletal_mesh_c = api:find_uobject("Class /Script/Engine.SkeletalMeshComponent")
	--
	--if skeletal_mesh_c == nil then print("skeletal_mesh_c is nil") 
	--end
	--
	--local skeletal_meshes = pawn:K2_GetComponentsByClass(skeletal_mesh_c)
	--
	--local arms_mesh = nil
	--for i, mesh in ipairs(skeletal_meshes) do
	--	if mesh:get_fname():to_string() == "ArmsMesh" then
	--		arms_mesh = mesh
	--		print("found arms " .. mesh:get_full_name())
	--		break
	--	end
	--end
	
	
	

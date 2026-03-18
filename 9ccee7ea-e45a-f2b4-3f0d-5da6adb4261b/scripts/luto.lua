local api = uevr.api
local vr = uevr.params.vr

local prevViewTarget = nil
local wasShowingUI = false
local game_engine_class = uevr.api:find_uobject("Class /Script/Engine.GameEngine")

-- run this every engine tick, *after* the world has been updated
uevr.sdk.callbacks.on_post_engine_tick(function(engine, delta)   	    
    local game_engine       = UEVR_UObjectHook.get_first_object_by_class(game_engine_class)
    local player            = uevr.api:get_player_controller(0)
    if player then               
        local currentVT = player:GetViewTarget()                
        local view_target = currentVT:get_full_name()
        local is_character = view_target:find("LutoFirstPersonCharacter",1,true)~=nil        
        local is_camera_actor = view_target:find("CameraActor",1,true)~=nil     
        local is_ladder = view_target:find("BP_InteractiveLadder",1,true)~=nil     
        local is_interactive_tv = view_target:find("BP_InteractiveTV",1,true)~=nil     
        local is_crouch = view_target:find("BP_CrouchInLine",1,true)~=nil     
        local is_inventory_showing = false
        if currentVT and currentVT.InventoryComponent and currentVT.InventoryComponent.IsShowingUI then
           is_inventory_showing = true 
        end
        if prevViewTarget ~= currentVT or wasShowingUI ~= is_inventory_showing then                                                            
            if (is_character == false and is_camera_actor == false and is_ladder == false and is_interactive_tv == false and is_crouch == false) or is_inventory_showing then
                uevr.params.vr.set_mod_value("UI_InvertAlpha","false")                                            
                uevr.params.vr.set_mod_value("UI_Distance",0.5)                                            
                uevr.params.vr.set_mod_value("UI_Size",0.5)                                            
            else                
                uevr.params.vr.set_mod_value("UI_InvertAlpha","true")                                            
                uevr.params.vr.set_mod_value("UI_Distance",2)                                            
                uevr.params.vr.set_mod_value("UI_Size",2)                                            
            end
            prevViewTarget = currentVT            
            wasShowingUI = is_inventory_showing                                          
        end
    end    
end)


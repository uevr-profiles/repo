-- DrainSim UEVR Inspection Script
-- This script dumps pawn information to the UnrealVR log

print("--- DrainSim Inspector Starting ---")

local function dump_pawn_info()
    local api = uevr.api
    local pawn = api:get_local_pawn(0)
    
    if not pawn then
        print("Inspector: No local pawn found")
        return
    end

    print("Inspector: Found pawn " .. pawn:get_full_name())
    
    -- Try to list properties that look like components
    -- In UEVR, pawn.Property works if it's a property
    local hand_l = pawn.HandLSolver
    if hand_l then
        print("Inspector: Found HandLSolver: " .. hand_l:get_full_name())
    else
        print("Inspector: HandLSolver property not found directly on pawn")
    end

    local hand_r = pawn.HandRSolver
    if hand_r then
        print("Inspector: Found HandRSolver: " .. hand_r:get_full_name())
    else
        print("Inspector: HandRSolver property not found directly on pawn")
    end

    local hand_l1 = pawn.HandLSolver1
    if hand_l1 then
        print("Inspector: Found HandLSolver1: " .. hand_l1:get_full_name())
    end

    local hand_r1 = pawn.HandRSolver1
    if hand_r1 then
        print("Inspector: Found HandRSolver1: " .. hand_r1:get_full_name())
    end

    local held_obj_ptr = pawn:get_property("HeldObj")
    if held_obj_ptr and held_obj_ptr ~= 0 then
        local obj = uevr.api.find_uobject(held_obj_ptr)
        if obj then
            print(string.format("Inspector: Found HeldObj: %s (Class: %s)", obj:get_full_name(), obj:get_class():get_full_name()))
            
            -- Dump components of the held object
            if obj:is_a(uevr.api.find_uobject("Class /Script/Engine.Actor")) then
                local actor = obj
                local components = actor:get_all_components()
                if components then
                    print(string.format("  Components for %s:", actor:get_fname():to_string()))
                    for _, comp in ipairs(components) do
                        print(string.format("    - %s (%s)", comp:get_fname():to_string(), comp:get_class():get_fname():to_string()))
                    end
                end
            end
        else
            print("Inspector: HeldObj property exists but find_uobject failed.")
        end
    else
        print("Inspector: HeldObj property not found directly on pawn")
    end
end

-- Run once on startup
dump_pawn_info()

-- Hook into tick for a few frames to ensure everything is loaded
local frames = 0
uevr.sdk.callbacks.on_pre_engine_tick(function(engine, delta)
    if frames < 60 then -- Run for 60 frames to be sure
        if frames % 20 == 0 then
            dump_pawn_info()
        end
        frames = frames + 1
    end
end)

print("--- DrainSim Inspector Initialized ---")

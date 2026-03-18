-- torso_follow_simple_fixed.lua
local api = assert(uevr and uevr.api, "[TORSO] uevr.api not found")
local cb = assert((uevr.params and uevr.params.sdk and uevr.params.sdk.callbacks) or (uevr.sdk and uevr.sdk.callbacks), "[TORSO] callbacks not found")

local function force_flags()
    local pawn = api:get_local_pawn(0)
    if not pawn then return end
    
    -- NÃO forçar bUseControllerRotationYaw durante movimento
    local velocity = pawn:GetVelocity()
    local is_moving = velocity and (math.abs(velocity.X) > 1 or math.abs(velocity.Y) > 1)
    
    if is_moving then
        -- Durante movimento: permitir orientação livre
        if pawn.bUseControllerRotationYaw ~= nil then
            pawn.bUseControllerRotationYaw = false
        end
        if pawn.CharacterMovement and pawn.CharacterMovement.bOrientRotationToMovement ~= nil then
            pawn.CharacterMovement.bOrientRotationToMovement = true
        end
    else
        -- Parado: seguir HMD
        if pawn.bUseControllerRotationYaw ~= nil then
            pawn.bUseControllerRotationYaw = true
        end
        if pawn.CharacterMovement and pawn.CharacterMovement.bOrientRotationToMovement ~= nil then
            pawn.CharacterMovement.bOrientRotationToMovement = false
        end
    end
    
    -- Rotação rápida
    if pawn.CharacterMovement and pawn.CharacterMovement.RotationRate then
        local rate = pawn.CharacterMovement.RotationRate
        if rate.Yaw then rate.Yaw = 540.0 end
    end
end

local function on_tick(...)
    pcall(force_flags)
end

cb.on_pre_engine_tick(on_tick)
print("[TORSO] Dynamic script loaded: switches between HMD and movement orientation.")
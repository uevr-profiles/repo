-- gestos_melhores_mod.lua
-- Gestos modificados:
-- 1) LEFT shoulder: HOLD Left Stick UP (sThumbLY max)
--    Release when leaving the zone.

local api       = uevr.api
local vr        = uevr.params.vr
local params    = uevr.params
local callbacks = params and params.sdk and params.sdk.callbacks

-- ================== DEBUG ==================
local DEBUG = false
local function dbg(fmt, ...)
    if not DEBUG then return end
    local ok, s = pcall(string.format, fmt, ...)
    print(ok and ("[Gesture Debug] " .. s) or "[Gesture Debug] (fmt err)")
end
-- ===========================================

-- XInput constants
local XINPUT_A  = 0x1000
local XINPUT_B  = 0x2000
local XINPUT_X  = 0x4000
local XINPUT_Y  = 0x8000
local XINPUT_LB = 0x0100
local XINPUT_RB = 0x0200

-- Gesture flags (existing)
local swing_rb   = false
local flick_b    = false
local push_lt    = false
local guard_lb   = false
local y_tap      = false
local behind_back_prev = false

-- ===== thresholds (kept from your version + new zones) =====
local SWING_SPEED    = 4.0
local FLICK_UP_SPEED = 3.0
local PUSH_SPEED     = 2.5
local GUARD_RAD_MIN  = 0.28
local GUARD_Y_MIN    = -0.20
local GUARD_Y_MAX    =  0.40
local GUARD_HYST     =  0.03
local PUSH_RAD_MIN   = 0.18
local PUSH_TANG_RATIO= 1.15
local PUSH_Y_RATIO   = 1.30

-- Fable arts (right hand behind back)
local BACK_Z_THRESH    = -0.12
local BACK_RAD_MAX     = 0.45
local Y_COOLDOWN       = 0.60

-- LEFT shoulder zone (head-local frame)
local SHOULDER_HYST       = 0.04
local LEFT_SHOULDER_CENTER= { x = -0.16, y = -0.20, z = 0.18 }
local LEFT_SHOULDER_RADIUS= 0.20

-- Cooldowns
local COOLDOWN = 0.3
local timers = { swing=0, flick=0, push=0, y=0 }
local push_buffer_time  = 0.05
local push_buffer_timer = 0

-- ====== vector helpers ======
local function v3(x,y,z) return Vector3f.new(x,y,z) end
local function vsub(a,b) return Vector3f.new(a.x-b.x, a.y-b.y, a.z-b.z) end
local function dot(a,b)  return a.x*b.x + a.y*b.y + a.z*b.z end
local function cross(a,b)
    return Vector3f.new(
        a.y*b.z - a.z*b.y,
        a.z*b.x - a.x*b.z,
        a.x*b.y - a.y*b.x
    )
end
local function smul(s,v) return Vector3f.new(s*v.x, s*v.y, s*v.z) end

-- rotate by quaternion
local function rotate_by_quat(v, qx,qy,qz,qw)
    local qv = v3(qx,qy,qz)
    local t  = smul(2.0, cross(qv, v))
    return Vector3f.new(
        v.x + qw*t.x + cross(qv, t).x,
        v.y + qw*t.y + cross(qv, t).y,
        v.z + qw*t.z + cross(qv, t).z
    )
end

-- head frame
local head_pos_raw = UEVR_Vector3f.new()
local head_q_raw   = UEVR_Quaternionf.new()
local H = v3(0,0,0)
local F = v3(0,0,1)
local U = v3(0,1,0)
local R = v3(1,0,0)

local function update_head_frame()
    vr.get_pose(vr.get_hmd_index(), head_pos_raw, head_q_raw)
    H:set(head_pos_raw.x, head_pos_raw.y, head_pos_raw.z)
    F = rotate_by_quat(v3(0,0,1), head_q_raw.x, head_q_raw.y, head_q_raw.z, head_q_raw.w)
    U = rotate_by_quat(v3(0,1,0), head_q_raw.x, head_q_raw.y, head_q_raw.z, head_q_raw.w)
    R = rotate_by_quat(v3(1,0,0), head_q_raw.x, head_q_raw.y, head_q_raw.z, head_q_raw.w)
end

local function body_locals(P)
    local V = vsub(P, H)
    local x_local = dot(V, R)
    local y_local = dot(V, U)
    local z_local = dot(V, F)
    return x_local, y_local, z_local
end

local function tick_timers(delta)
    for k,_ in pairs(timers) do
        timers[k] = math.max(0, timers[k] - delta)
    end
end

-- data store
local gd = {
    right_pos_raw = UEVR_Vector3f.new(),
    right_q_raw   = UEVR_Quaternionf.new(),
    right_pos     = Vector3f.new(0,0,0),
    last_right    = Vector3f.new(0,0,0),

    left_pos_raw  = UEVR_Vector3f.new(),
    left_q_raw    = UEVR_Quaternionf.new(),
    left_pos      = Vector3f.new(0,0,0),
    last_left     = Vector3f.new(0,0,0),

    last_left_local = Vector3f.new(0,0,0),
    first = true,
}

-- guard detection (kept)
local function detect_guard_position()
    update_head_frame()
    local xR, yR, zR = body_locals(gd.right_pos)
    local r_horiz = math.sqrt(xR*xR + zR*zR)

    local on = (r_horiz > GUARD_RAD_MIN) and (yR > GUARD_Y_MIN) and (yR < GUARD_Y_MAX)
    if on and not guard_lb then
        guard_lb = true
        dbg("GUARD ON  r=%.2f  y=%.2f", r_horiz, yR)
    elseif (not on) and guard_lb then
        local off = (r_horiz < (GUARD_RAD_MIN - GUARD_HYST)) or (yR < GUARD_Y_MIN - GUARD_HYST) or (yR > GUARD_Y_MAX + GUARD_HYST)
        if off then
            guard_lb = false
            dbg("GUARD OFF r=%.2f  y=%.2f", r_horiz, yR)
        end
    end
end

-- fable arts: right hand behind back (kept)
local function detect_fable_arts_right(xR, yR, zR, delta)
    local radial = math.sqrt(xR*xR + yR*yR)
    local behind = (zR > BACK_Z_THRESH) and (radial <= BACK_RAD_MAX)

    if behind and not behind_back_prev and timers.y == 0 then
        y_tap = true
        timers.y = Y_COOLDOWN
        dbg("FABLE ARTS: Y tap (behind back)")
    end

    behind_back_prev = behind
end

-- ========= LEFT SHOULDER DETECTOR =========
local lshoulder_up_hold = false

local function detect_left_shoulder_up(xL, yL, zL)
    local dx = xL - LEFT_SHOULDER_CENTER.x
    local dy = yL - LEFT_SHOULDER_CENTER.y
    local dz = zL - LEFT_SHOULDER_CENTER.z
    local dist = math.sqrt(dx*dx + dy*dy + dz*dz)

    if not lshoulder_up_hold and dist <= LEFT_SHOULDER_RADIUS then
        lshoulder_up_hold = true
        dbg("L-Shoulder: UP hold ON dist=%.3f", dist)
    elseif lshoulder_up_hold and dist >= (LEFT_SHOULDER_RADIUS + SHOULDER_HYST) then
        lshoulder_up_hold = false
        dbg("L-Shoulder: UP hold OFF dist=%.3f", dist)
    end
end

-- main detection
local function detect_gestures(delta)
    vr.get_pose(vr.get_right_controller_index(), gd.right_pos_raw, gd.right_q_raw)
    vr.get_pose(vr.get_left_controller_index(),  gd.left_pos_raw,  gd.left_q_raw)

    gd.right_pos:set(gd.right_pos_raw.x, gd.right_pos_raw.y, gd.right_pos_raw.z)
    gd.left_pos:set( gd.left_pos_raw.x,  gd.left_pos_raw.y,  gd.left_pos_raw.z)

    if delta < 1e-4 then delta = 1e-4 end

    if gd.first then
        gd.last_right:set(gd.right_pos.x, gd.right_pos.y, gd.right_pos.z)
        gd.last_left:set( gd.left_pos.x,  gd.left_pos.y,  gd.left_pos.z)
        update_head_frame()
        local xL0, yL0, zL0 = body_locals(gd.left_pos)
        gd.last_left_local:set(xL0, yL0, zL0)
        gd.first = false
        return
    end

    local right_vel = (gd.right_pos - gd.last_right) * (1/delta)
    local left_vel  = (gd.left_pos  - gd.last_left)  * (1/delta)

    gd.last_right:set(gd.right_pos.x, gd.right_pos.y, gd.right_pos.z)
    gd.last_left:set( gd.left_pos.x,  gd.left_pos.y,  gd.left_pos.z)

    if timers.swing==0 and right_vel.y < -SWING_SPEED then
        swing_rb = true; timers.swing=COOLDOWN
    end
    if timers.flick==0 and left_vel.y > FLICK_UP_SPEED then
        flick_b = true; timers.flick=COOLDOWN
    end

    update_head_frame()
    local xL, yL, zL = body_locals(gd.left_pos)
    local r_horiz    = math.sqrt(xL*xL + zL*zL)

    -- outward/tangent speeds for push detection (kept)
    local vxL = (xL - gd.last_left_local.x) / delta
    local vyL = (yL - gd.last_left_local.y) / delta
    local vzL = (zL - gd.last_left_local.z) / delta
    gd.last_left_local:set(xL, yL, zL)

    local outward_speed = 0.0
    local tang_speed    = 0.0
    if r_horiz > 1e-4 then
        local ex = xL / r_horiz
        local ez = zL / r_horiz
        outward_speed = vxL*ex + vzL*ez
        tang_speed    = math.abs(vxL*(-ez) + vzL*(ex))
    end

    local outward_ok = outward_speed > (PUSH_SPEED * 0.85)
    local radial_pos = r_horiz > PUSH_RAD_MIN
    local dominance  = (outward_speed > tang_speed * PUSH_TANG_RATIO) and (outward_speed > math.abs(vyL) * PUSH_Y_RATIO)

    if radial_pos and outward_ok and dominance then
        push_buffer_timer = push_buffer_timer + delta
    else
        push_buffer_timer = math.max(push_buffer_timer - delta*0.5, 0)
    end
    if timers.push==0 and push_buffer_timer >= push_buffer_time then
        push_lt = true; timers.push=COOLDOWN; push_buffer_timer=0
    end

    -- existing kept
    local xR, yR, zR = body_locals(gd.right_pos)
    detect_fable_arts_right(xR, yR, zR, delta)
    detect_guard_position()

    -- LEFT shoulder only
    detect_left_shoulder_up(xL, yL, zL)
end

-- tick
if callbacks and callbacks.on_pre_engine_tick then
    callbacks.on_pre_engine_tick(function(engine, delta)
        tick_timers(delta)
        detect_gestures(delta)
    end)
end

-- synthesize input
if callbacks and callbacks.on_xinput_get_state then
    callbacks.on_xinput_get_state(function(retval, user_index, state)
        if not state then return end

        -- Existing
        if swing_rb then
            state.Gamepad.wButtons = state.Gamepad.wButtons | XINPUT_RB
            swing_rb = false
        end
        if flick_b then
            state.Gamepad.wButtons = state.Gamepad.wButtons | XINPUT_B
            flick_b = false
        end
        if push_lt then
            state.Gamepad.bLeftTrigger = 200
            push_lt = false
        end
        if guard_lb then
            state.Gamepad.wButtons = state.Gamepad.wButtons | XINPUT_LB
        end
        if y_tap then
            state.Gamepad.wButtons = state.Gamepad.wButtons | XINPUT_Y
            y_tap = false
        end

        -- LEFT shoulder: only stick UP
        if lshoulder_up_hold then
            state.Gamepad.sThumbLY = 32767
        end
    end)
else
    print("[Gesture] ERROR: callbacks.on_xinput_get_state unavailable")
end

print("[Gesture] Loaded gestos_melhores_mod.lua (LEFT shoulder UP only, no chest).")

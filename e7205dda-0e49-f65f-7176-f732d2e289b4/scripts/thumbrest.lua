local vr = uevr.params.vr
local params = uevr.params
local callbacks = params.sdk.callbacks

local thumbrestActionPath = "/actions/default/in/ThumbrestTouchRight"
local RightHandle = vr.get_right_joystick_source()
local thumbrestAction = vr.get_action_handle(thumbrestActionPath)

local RightHandPos = UEVR_Vector3f.new()
local startPos = UEVR_Vector3f.new()

local thumb_was_down = false
local triggered = false
local deltaX, deltaY = 0, 0

local prevAimMethod = vr.get_aim_method()
local thumbHeldAimActive = false

local travelThreshold = 0.15

local XINPUT_DPAD_UP    = 0x0001
local XINPUT_DPAD_DOWN  = 0x0002
local XINPUT_DPAD_LEFT  = 0x0004
local XINPUT_DPAD_RIGHT = 0x0008


callbacks.on_pre_engine_tick(function(engine, delta)
    if not RightHandle or not thumbrestAction then return end

    local pressed = vr.is_action_active(thumbrestAction, RightHandle)

    if pressed then
        if not thumbHeldAimActive then
            prevAimMethod = vr.get_aim_method()
            vr.set_aim_method(0)
            thumbHeldAimActive = true
        end
    elseif thumbHeldAimActive then
        vr.set_aim_method(prevAimMethod)
        thumbHeldAimActive = false
    end

    vr.get_pose(vr.get_right_controller_index(), RightHandPos, UEVR_Quaternionf.new())

    if pressed and not thumb_was_down then
        startPos.x = RightHandPos.x
        startPos.y = RightHandPos.y
        startPos.z = RightHandPos.z
        triggered = false
    elseif not pressed then
        triggered = false
    end

    if pressed and not triggered then
        deltaX = RightHandPos.x - startPos.x
        deltaY = RightHandPos.y - startPos.y
    else
        deltaX = 0
        deltaY = 0
    end

    thumb_was_down = pressed
end)

callbacks.on_xinput_get_state(function(retval, user_index, state)
    if not state or not state.Gamepad then return end

    if triggered or not thumb_was_down then return end

    local absX = math.abs(deltaX)
    local absY = math.abs(deltaY)

    if absX >= travelThreshold or absY >= travelThreshold then
        triggered = true

        if absX > absY then
            if deltaX > 0 then
                state.Gamepad.wButtons = state.Gamepad.wButtons | XINPUT_DPAD_RIGHT
            else
                state.Gamepad.wButtons = state.Gamepad.wButtons | XINPUT_DPAD_LEFT
            end
        else
            if deltaY > 0 then
                state.Gamepad.wButtons = state.Gamepad.wButtons | XINPUT_DPAD_UP
            else
                state.Gamepad.wButtons = state.Gamepad.wButtons | XINPUT_DPAD_DOWN
            end
        end
    end
end)

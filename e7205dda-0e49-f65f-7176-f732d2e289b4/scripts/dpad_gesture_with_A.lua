-- dpad_gesture_with_A_local.lua
-- Segura A (controle direito) e move a mão como D-Pad (Up/Down/Left/Right) relativo ao HMD

local api = uevr.api
local vr  = uevr.params.vr
local cb  = uevr.sdk.callbacks

-- Botão A (direito)
local aButtonActionPath = "/actions/default/in/AButtonRight"
local RightHandle = vr.get_right_joystick_source()
local aButtonAction = vr.get_action_handle(aButtonActionPath)

local RH_World = UEVR_Vector3f.new()
local RH_Local = UEVR_Vector3f.new()
local H_Pos    = UEVR_Vector3f.new()
local H_Rot    = UEVR_Quaternionf.new()
local startPos = UEVR_Vector3f.new()

local a_was_down, triggered = false, false
local deltaX, deltaY = 0, 0
local travelThreshold = 0.15

local XINPUT_DPAD_UP    = 0x0001
local XINPUT_DPAD_DOWN  = 0x0002
local XINPUT_DPAD_LEFT  = 0x0004
local XINPUT_DPAD_RIGHT = 0x0008

-- ====== math util (quat/vector) ======
local function vec_sub(a, b, out)
  out.x, out.y, out.z = a.x - b.x, a.y - b.y, a.z - b.z
  return out
end

local function quat_conj(q, out)
  out.x, out.y, out.z, out.w = -q.x, -q.y, -q.z, q.w
  return out
end

local function quat_mul(a, b, out)
  local ax, ay, az, aw = a.x, a.y, a.z, a.w
  local bx, by, bz, bw = b.x, b.y, b.z, b.w
  out.x = aw*bx + ax*bw + ay*bz - az*by
  out.y = aw*by - ax*bz + ay*bw + az*bx
  out.z = aw*bz + ax*by - ay*bx + az*bw
  out.w = aw*bw - ax*bx - ay*by - az*bz
  return out
end

local function rotate_vec_by_quat(v, q, out)
  -- v' = q^-1 * (v,0) * q
  local qv = UEVR_Quaternionf.new(); qv.x, qv.y, qv.z, qv.w = v.x, v.y, v.z, 0
  local qi = UEVR_Quaternionf.new(); quat_conj(q, qi)
  local t  = UEVR_Quaternionf.new()
  quat_mul(qi, qv, t)
  local r = UEVR_Quaternionf.new()
  quat_mul(t, q, r)
  out.x, out.y, out.z = r.x, r.y, r.z
  return out
end

-- Tenta obter pose do HMD (compatível com várias builds)
local function get_hmd_pose(posOut, rotOut)
  if vr.get_hmd_pose then
    local ok = pcall(vr.get_hmd_pose, posOut, rotOut)
    if ok then return true end
  end
  if vr.get_pose and vr.get_hmd_index then
    local ok, idx = pcall(vr.get_hmd_index)
    if ok and idx ~= nil then
      local ok2 = pcall(vr.get_pose, idx, posOut, rotOut)
      if ok2 then return true end
    end
  end
  -- fallback: sem HMD → usa world (vai funcionar, mas pode inverter a 180°)
  posOut.x, posOut.y, posOut.z = 0,0,0
  rotOut.x, rotOut.y, rotOut.z, rotOut.w = 0,0,0,1
  return false
end

-- Converte world → HMD-local (z=forward da face, y=up da cabeça, x=right)
local function world_to_hmd_local(worldPos, out)
  get_hmd_pose(H_Pos, H_Rot)
  local rel = UEVR_Vector3f.new()
  vec_sub(worldPos, H_Pos, rel)
  rotate_vec_by_quat(rel, H_Rot, out)
  return out
end

cb.on_pre_engine_tick(function(_, _dt)
  if not RightHandle or not aButtonAction then return end

  local pressed = vr.is_action_active(aButtonAction, RightHandle)

  -- posição do controle direito em world
  vr.get_pose(vr.get_right_controller_index(), RH_World, UEVR_Quaternionf.new())
  -- transforma para HMD-local
  world_to_hmd_local(RH_World, RH_Local)

  if pressed and not a_was_down then
    startPos.x, startPos.y, startPos.z = RH_Local.x, RH_Local.y, RH_Local.z
    triggered = false
  elseif not pressed then
    triggered = false
  end

  if pressed and not triggered then
    deltaX = RH_Local.x - startPos.x        -- left/right relativo ao HMD
    deltaY = RH_Local.z - startPos.z        -- forward/back relativo ao HMD
  else
    deltaX, deltaY = 0, 0
  end

  a_was_down = pressed
end)

cb.on_xinput_get_state(function(_, _, state)
  if not state or not state.Gamepad then return end
  if triggered or not a_was_down then return end

  local absX, absY = math.abs(deltaX), math.abs(deltaY)
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

print("[DPad] loaded (HMD-local, no to_hmd_local dependency)")

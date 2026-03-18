-- bracos_left_libs.lua — Lies of P (UEVR)
-- LEFT ARM lock/drive integrated with LIBS (STRICT):
--  * Requires libs/uevr_utils.lua and libs/configui.lua
--  * Uses uevr.sdk.callbacks; accepts on_update OR on_pre_engine_tick OR on_present
--  * Autosnap/persist across map loads and Stargazer swaps
--  * Robust controller-state access (no hard-crash if API is unavailable on a frame)
--  * Safe neutralization (pcall everywhere) and regex-based arm discovery
--
-- Based on your previous "bracos_final_v2.lua" but hardened and LIBS-integrated.
-- Offsets are editable via the config UI.

------------------------------ HARD REQS --------------------------------
local api = assert(uevr and uevr.api,               "[ARM-L] uevr.api not found")
local params = assert(uevr.params,                  "[ARM-L] uevr.params not found")
local vr = assert(params.vr,                        "[ARM-L] uevr.params.vr not found")
local cb = assert(uevr.sdk and uevr.sdk.callbacks,  "[ARM-L] uevr.sdk.callbacks not found")
local u  = assert(require("libs/uevr_utils"),       "[ARM-L] libs/uevr_utils.lua missing")
local ui = assert(require("libs/configui"),         "[ARM-L] libs/configui.lua missing")

-- choose a frame hook we can register to
local FRAME = (cb.on_update and "on_update")
          or (cb.on_pre_engine_tick and "on_pre_engine_tick")
          or (cb.on_present and "on_present")
assert(FRAME, "[ARM-L] one of callbacks.on_update|on_pre_engine_tick|on_present is required")
---------------------------------------------------------------------------

------------------------------- CONFIG -----------------------------------
local CFG = {
  DEBUG = false,

  -- Regex for LEFT arm SkeletalMesh (Pino). Keep %d+ wildcards to ignore numeric IDs
  ARM_LEFT_REGEX = "BP_CH_PC_Pino_C_%d+%.SkeletalMeshComponent_%d+",

  -- Offset (relative to controller) and rotation (degrees)
  POS_OFFSET = { x = -30.411, y = 88.444, z = 3.942 },
  ROT_OFFSET = { pitch = -1.353, yaw = -0.684, roll = 0.613 },

  DISABLE_CAMERA_OVERLAP_TICK = true,

  -- Persistence / re-snap behavior
  LEVEL_WAIT_FRAMES = 200,  -- wait world settle after map change
  SNAP_FRAMES       = 90,   -- force-neutralize/drive for N frames when (re)attaching
  PAWN_CHANGE_TRIGGERS_SNAP = true,
}
---------------------------------------------------------------------------

local function log(fmt, ...)
  if not CFG.DEBUG then return end
  local ok, s = pcall(string.format, fmt, ...)
  print(ok and ("[ARM-L] " .. s) or "[ARM-L] (log err)")
end

--------------------------- MATH HELPERS ---------------------------------
local function deg2rad(d) return d * math.pi / 180.0 end
local function rad2deg(r) return r * 180.0 / math.pi end

-- build quaternion from Rotator (pitch,yaw,roll in degrees)
local function quat_from_rot(pitch, yaw, roll)
  local cy, sy = math.cos(deg2rad(yaw)*0.5),  math.sin(deg2rad(yaw)*0.5)
  local cp, sp = math.cos(deg2rad(pitch)*0.5),math.sin(deg2rad(pitch)*0.5)
  local cr, sr = math.cos(deg2rad(roll)*0.5), math.sin(deg2rad(roll)*0.5)
  return { x = sr*cp*cy - cr*sp*sy,
           y = cr*sp*cy + sr*cp*sy,
           z = cr*cp*sy - sr*sp*cy,
           w = cr*cp*cy + sr*sp*sy }
end

local function quat_mul(a,b)
  return {
    x = a.w*b.x + a.x*b.w + a.y*b.z - a.z*b.y,
    y = a.w*b.y - a.x*b.z + a.y*b.w + a.z*b.x,
    z = a.w*b.z + a.x*b.y - a.y*b.x + a.z*b.w,
    w = a.w*b.w - a.x*b.x - a.y*b.y - a.z*b.z,
  }
end

-- convert quaternion to Rotator (Pitch,Yaw,Roll) using standard Tait-Bryan XYZ
local function quat_to_rot(q)
  local qw,qx,qy,qz = q.w,q.x,q.y,q.z
  -- roll (X axis)
  local sinr_cosp = 2*(qw*qx + qy*qz)
  local cosr_cosp = 1 - 2*(qx*qx + qy*qy)
  local roll = math.atan2(sinr_cosp, cosr_cosp)
  -- pitch (Y axis)
  local sinp = 2*(qw*qy - qz*qx)
  local pitch
  if math.abs(sinp) >= 1 then
    pitch = (sinp > 0) and (math.pi/2) or (-math.pi/2)
  else
    pitch = math.asin(sinp)
  end
  -- yaw (Z axis)
  local siny_cosp = 2*(qw*qz + qx*qy)
  local cosy_cosp = 1 - 2*(qy*qy + qz*qz)
  local yaw = math.atan2(siny_cosp, cosy_cosp)
  return { Pitch = rad2deg(pitch), Yaw = rad2deg(yaw), Roll = rad2deg(roll) }
end
---------------------------------------------------------------------------

----------------------------- STATE --------------------------------------
local pawn, leftArm = nil, nil
local leftMCIndex = nil
local reusable_hit_result = _G.UEVR_HitResult and UEVR_HitResult.new() or nil

-- tiny utils
local function exists(obj) return obj and UEVR_UObjectHook and UEVR_UObjectHook.exists and UEVR_UObjectHook.exists(obj) end
local function to_ptr(obj) return obj and tostring(obj) or nil end
local function get_mesh(obj)
  local ok, mesh = pcall(function() return obj and obj.SkeletalMesh end)
  return ok and mesh or nil
end
---------------------------------------------------------------------------

---------------------- CONTROLLER STATE (ROBUST) ------------------------
-- We prefer the API on uevr.api when available; guard with pcall.
local function get_mc_state(idx)
  local p = UEVR_Vector3f.new()
  local q = UEVR_Quaternionf.new()
  local ok = false
  if api and api.get_motion_controller_state then
    ok = pcall(function() return api:get_motion_controller_state(idx, p, q) end)
  end
  if ok then
    return true, p, q
  end
  -- fallback: some builds expose it on vr
  if vr and vr.get_motion_controller_state then
    local ok2 = pcall(function() return vr:get_motion_controller_state(idx, p, q) end)
    if ok2 then return true, p, q end
  end
  return false, nil, nil
end

local function detect_left_mc_index()
  -- Try to prioritise index 1 as left (common mapping). If not valid, pick first valid.
  local ok1 = select(1, get_mc_state(1))
  if ok1 then leftMCIndex = 1; return end
  for i=0,2 do
    local ok = select(1, get_mc_state(i))
    if ok then leftMCIndex = i; return end
  end
  leftMCIndex = nil
end
---------------------------------------------------------------------------

----------------------- CAMERA OVERLAP HANDLER --------------------------
local function try_disable_camera_overlap()
  if not CFG.DISABLE_CAMERA_OVERLAP_TICK then return end
  if not pawn then return end
  local handler = pawn.CameraOverlapHandler or pawn.CameraOverlap or pawn.OverlapCamera
  if handler and handler.IsComponentTickEnabled and handler.SetComponentTickEnabled then
    local ok, enabled = pcall(function() return handler:IsComponentTickEnabled() end)
    if ok and enabled then pcall(function() handler:SetComponentTickEnabled(false) end); log("CameraOverlapHandler tick disabled") end
  end
end
---------------------------------------------------------------------------

---------------------------- FIND LEFT ARM ------------------------------
local function find_left_arm_by_regex()
  local skClass = api:find_uobject("Class /Script/Engine.SkeletalMeshComponent")
  if not skClass or not skClass.get_objects_matching then return nil end
  local list = skClass:get_objects_matching(false)
  for _, comp in ipairs(list or {}) do
    if exists(comp) then
      local nm = comp:get_full_name()
      if nm and string.match(nm, CFG.ARM_LEFT_REGEX) then
        log("Candidate (regex) = %s", nm)
        return comp
      end
    end
  end
  return nil
end
---------------------------------------------------------------------------

-------------------------- NEUTRALIZE & DRIVE ---------------------------
local function neutralize_animation(smc)
  if not smc then return end
  if smc.SetLeaderPoseComponent      then pcall(function() smc:SetLeaderPoseComponent(nil, true, true) end) end
  if smc.SetMasterPoseComponent      then pcall(function() smc:SetMasterPoseComponent(nil) end) end
  if smc.DetachFromComponent         then pcall(function() smc:DetachFromComponent(true, true) end) end
  if smc.SetComponentTickEnabled     then pcall(function() smc:SetComponentTickEnabled(false) end) end
  if smc.SetAnimationMode            then pcall(function() smc:SetAnimationMode(1) end) end
  if smc.Stop                        then pcall(function() smc:Stop() end) end
  if smc.bUpdateAnimation ~= nil     then smc.bUpdateAnimation = false end
  if smc.bAllowAnimCurveEvaluation ~= nil then smc.bAllowAnimCurveEvaluation = false end
  if smc.bNoSkeletonUpdate ~= nil    then smc.bNoSkeletonUpdate = true end
  if smc.SetVisibility               then pcall(function() smc:SetVisibility(true, true) end) end
end

local function drive_with_left_controller(smc)
  if not smc then return end
  if not leftMCIndex then detect_left_mc_index() end
  if not leftMCIndex then return end

  local ok, cpos, cquat = get_mc_state(leftMCIndex)
  if not ok then return end

  -- apply extra rotation offset
  local rq = quat_from_rot(CFG.ROT_OFFSET.pitch, CFG.ROT_OFFSET.yaw, CFG.ROT_OFFSET.roll)
  local out_q = quat_mul({x=cquat.x,y=cquat.y,z=cquat.z,w=cquat.w}, rq)
  local rot = quat_to_rot(out_q)

  -- position (world) + optional offset (left as world-space like your v2)
  local pos = Vector3f.new(cpos.x + CFG.POS_OFFSET.x, cpos.y + CFG.POS_OFFSET.y, cpos.z + CFG.POS_OFFSET.z)

  if smc.K2_SetWorldLocationAndRotation then
    pcall(function() smc:K2_SetWorldLocationAndRotation(pos, rot, false, reusable_hit_result, false) end)
  elseif smc.SetWorldLocationAndRotation then
    pcall(function() smc:SetWorldLocationAndRotation(pos, rot, false) end)
  end
end
---------------------------------------------------------------------------

------------------------------- INIT -------------------------------------
local function init()
  pawn = api:get_local_pawn(0)
  if not pawn or not exists(pawn) then
    leftArm = nil
    return
  end
  try_disable_camera_overlap()
  leftArm = find_left_arm_by_regex()
  if leftArm then log("Left arm component: %s", leftArm:get_full_name()) else log("Left arm NOT found (regex mismatch)") end
end
---------------------------------------------------------------------------

---------------------------- PERSISTENCE ---------------------------------
local LEVEL_WAIT_FRAMES = CFG.LEVEL_WAIT_FRAMES
local SNAP_FRAMES       = CFG.SNAP_FRAMES
local PAWN_CHANGE_TRIGGERS_SNAP = CFG.PAWN_CHANGE_TRIGGERS_SNAP

local level_wait = 0
local snap_counter = 0
local last_pawn_ptr = nil
local last_leftarm_ptr, last_leftarm_mesh = nil, nil

local function arm_changed(new_smc)
  snap_counter = SNAP_FRAMES
  last_leftarm_ptr  = to_ptr(new_smc)
  last_leftarm_mesh = get_mesh(new_smc)
end

if cb.on_level_change then
  cb.on_level_change(function()
    leftArm = nil
    pawn = nil
    level_wait = LEVEL_WAIT_FRAMES
    snap_counter = SNAP_FRAMES
    last_leftarm_ptr, last_leftarm_mesh = nil, nil
  end)
end

local function main_tick()
  -- Detect pawn change (death/respawn)
  do
    local cur_pawn = nil
    if api and api.get_player_pawn then pcall(function() cur_pawn = api:get_player_pawn() end) end
    local cur_ptr = to_ptr(cur_pawn)
    if PAWN_CHANGE_TRIGGERS_SNAP and cur_ptr and cur_ptr ~= last_pawn_ptr then
      leftArm = nil
      pawn = nil
      level_wait = math.max(level_wait or 0, LEVEL_WAIT_FRAMES)
      snap_counter = SNAP_FRAMES
    end
    last_pawn_ptr = cur_ptr or last_pawn_ptr
  end

  if init then pcall(init) end

  if level_wait and level_wait > 0 then level_wait = level_wait - 1 end

  if not leftArm and (not level_wait or level_wait < LEVEL_WAIT_FRAMES - 10) then
    local smc = find_left_arm_by_regex()
    if smc then leftArm = smc; arm_changed(leftArm) end
  end

  if leftArm then
    local ptr, mesh = to_ptr(leftArm), get_mesh(leftArm)
    if ptr ~= last_leftarm_ptr or mesh ~= last_leftarm_mesh then arm_changed(leftArm) end
  end

  if leftArm then
    if snap_counter and snap_counter > 0 then
      pcall(function() neutralize_animation(leftArm) end)
      pcall(function() drive_with_left_controller(leftArm) end)
      snap_counter = snap_counter - 1
    else
      pcall(function() drive_with_left_controller(leftArm) end)
    end
  end
end

if FRAME == "on_update" then
  cb.on_update(function(_) main_tick() end)
elseif FRAME == "on_pre_engine_tick" then
  cb.on_pre_engine_tick(function(_, _) main_tick() end)
else
  cb.on_present(function() main_tick() end)
end

function on_level_change(_)
  pawn, leftArm, leftMCIndex = nil, nil, nil
  log("Level change: cleared refs")
end

print("[ARM-L] Loaded (LIBS STRICT). Locks LEFT arm to controller using regex; autosnap enabled.")

------------------------------ UI PANEL ----------------------------------
cb.on_draw_ui(function()
  local opened = ui.begin and ui.begin("Left Arm — LIBS", true)
  if not opened then if ui.end_ then ui.end_() end return end

  if ui.text then ui.text("Frame hook: " .. (FRAME or "?")) end
  if ui.checkbox then CFG.DEBUG = ui.checkbox("Debug logs", CFG.DEBUG) or CFG.DEBUG end

  if ui.drag_float3 then
    local px,py,pz = CFG.POS_OFFSET.x, CFG.POS_OFFSET.y, CFG.POS_OFFSET.z
    px,py,pz = ui.drag_float3("Pos offset (x,y,z)", px,py,pz, 0.1)
    CFG.POS_OFFSET.x, CFG.POS_OFFSET.y, CFG.POS_OFFSET.z = px or px, py or py, pz or pz
  end

  if ui.drag_float3 then
    local pr,pyaw,prl = CFG.ROT_OFFSET.pitch, CFG.ROT_OFFSET.yaw, CFG.ROT_OFFSET.roll
    pr,pyaw,prl = ui.drag_float3("Rot offset (pitch,yaw,roll)", pr,pyaw,prl, 0.1)
    CFG.ROT_OFFSET.pitch, CFG.ROT_OFFSET.yaw, CFG.ROT_OFFSET.roll = pr or pr, pyaw or pyaw, prl or prl
  end

  if ui.checkbox then
    CFG.DISABLE_CAMERA_OVERLAP_TICK = ui.checkbox("Disable CameraOverlap tick", CFG.DISABLE_CAMERA_OVERLAP_TICK) or CFG.DISABLE_CAMERA_OVERLAP_TICK
  end

  if ui.end_ then ui.end_() end
end)

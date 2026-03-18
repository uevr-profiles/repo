-- lt_hide_hud_leftaim.lua (no-conflict version)
-- Hold LT  -> hide HUD + switch aim to LEFT
-- Release  -> restore HUD + aim

local api     = uevr.api
local params  = uevr.params
local cb      = params.sdk and params.sdk.callbacks
local vr      = params.vr

--==================== CONFIG ====================
local LT_THRESH         = 128        -- analog trigger (0..255)
local LEFT_AIM_METHOD   = 3          -- keep your previous profile's value
local REINFORCE_FRAMES  = 10         -- re-apply for a few frames to avoid flicker
local DEBUG             = false
--================================================

-- HUD keys (cover common UEVR variations)
local UI_SIZE_KEYS    = {"UI_Size","ui_size","overlay_size","Overlay_Size"}
local FW_SIZE_KEYS    = {"Framework_Size","framework_size"}
local UI_ALPHA_KEYS   = {"UI_Alpha","ui_alpha","overlay_alpha"}
local UI_VIS_KEYS     = {"UI_Visible","ui_visible"}

local function log(fmt, ...)
  if not DEBUG then return end
  local ok, s = pcall(string.format, fmt, ...)
  print(ok and ("[LT/HUD] " .. s) or "[LT/HUD] (log err)")
end

--================ Helpers for HUD =================
local function get_mod_number(keys, fallback)
  for _,k in ipairs(keys) do
    local ok, v = pcall(function() return vr:get_mod_value(k) end) -- NOTE ':'
    if ok and v ~= nil then
      local n = tonumber(v)
      if n ~= nil then return n end
    end
  end
  return fallback
end

local function set_all(keys, value_str)
  for _,k in ipairs(keys) do
    pcall(function() vr.set_mod_value(k, value_str) end)           -- NOTE '.'
  end
end
--================================================

--================ Aim save/restore ==============
local savedAim = nil
local function save_aim()
  if savedAim ~= nil then return end
  if vr and vr.get_aim_method then
    local ok, v = pcall(vr.get_aim_method)
    if ok then savedAim = v end
  end
end

local function set_left_aim()
  if vr and vr.set_aim_method then
    pcall(function() vr.set_aim_method(LEFT_AIM_METHOD) end)
  end
end

local function restore_aim()
  if savedAim ~= nil and vr and vr.set_aim_method then
    pcall(function() vr.set_aim_method(savedAim) end)
  end
  savedAim = nil
end
--================================================

--================ State/HUD ======================
local LT_HELD    = false
local reinforce  = 0
local saved = { size=nil, fwsize=nil, alpha=nil, visible=nil }

local function hide_hud()
  if saved.size   == nil then saved.size   = get_mod_number(UI_SIZE_KEYS, 2.0) end
  if saved.fwsize == nil then saved.fwsize = get_mod_number(FW_SIZE_KEYS, 2.0) end
  if saved.alpha  == nil then saved.alpha  = get_mod_number(UI_ALPHA_KEYS, 1.0) end
  if saved.visible== nil then saved.visible= get_mod_number(UI_VIS_KEYS,   1  ) end

  -- compatible strategy: shrink + alpha 0 + visibility flag (if present)
  set_all(UI_SIZE_KEYS,  "0.000")
  set_all(FW_SIZE_KEYS,  "0.000")
  set_all(UI_ALPHA_KEYS, "0.000")
  set_all(UI_VIS_KEYS,   "0")

  reinforce = REINFORCE_FRAMES
end

local function show_hud()
  local sz  = string.format("%.3f", saved.size   or 2.0)
  local fsz = string.format("%.3f", saved.fwsize or 2.0)
  local alp = string.format("%.3f", saved.alpha  or 1.0)
  local vis = tostring(saved.visible or 1)

  set_all(UI_SIZE_KEYS,  sz)
  set_all(FW_SIZE_KEYS,  fsz)
  set_all(UI_ALPHA_KEYS, alp)
  set_all(UI_VIS_KEYS,   vis)

  reinforce = REINFORCE_FRAMES
end
--================================================

-- Re-apply for a few frames after switching (some games rewrite on same tick)
if cb and cb.on_pre_engine_tick then
  cb.on_pre_engine_tick(function(_, _)
    if reinforce > 0 then
      reinforce = reinforce - 1
      if LT_HELD then hide_hud() else show_hud() end
    end
  end)
end

-- XInput hook for LT (edge)
if cb and cb.on_xinput_get_state then
  cb.on_xinput_get_state(function(_, _, state)
    local gp = state.Gamepad or {}
    local lt = (gp.bLeftTrigger or 0) > LT_THRESH

    if lt and not LT_HELD then
      LT_HELD = true
      -- aim -> left + hide HUD
      save_aim()
      set_left_aim()
      hide_hud()
      log("LT down: aim->left + HUD hidden")
    elseif (not lt) and LT_HELD then
      LT_HELD = false
      -- restore aim + HUD
      restore_aim()
      show_hud()
      log("LT up: aim restored + HUD shown")
    end
  end)
else
  print("[LT/HUD] ERROR: callbacks.on_xinput_get_state unavailable.")
end

-- chain-safe level change: call any previously-defined handler first, then reset our state
local __prev_on_level_change = _G.on_level_change
function on_level_change(level)
  if __prev_on_level_change then pcall(__prev_on_level_change, level) end
  LT_HELD   = false
  reinforce = 0
  restore_aim()
  saved = { size=nil, fwsize=nil, alpha=nil, visible=nil }
end

print("[LT/HUD] Ready: hold LT to hide HUD & aim left; release to restore.")

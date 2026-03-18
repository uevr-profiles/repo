-- hands.noconflict.lua — auto-fix v2
-- Impede duplicação de mãos entre mapas e reforça a pose após o load.

-- IMPORTANTE: registre o callback de PRE-LEVEL *antes* de requerer libs/hands
local uevrUtils   = require('libs/uevr_utils')

-- Destrói mãos *antes* de o próprio módulo libs/hands limpar as referências.
if not _G.__hands_prelevel_destroy_registered then
  uevrUtils.registerPreLevelChangeCallback(function(level)
    local ok, hands_mod = pcall(require, 'libs/hands')
    if ok and hands_mod and hands_mod.destroyHands then
      pcall(hands_mod.destroyHands)
    end
  end)
  _G.__hands_prelevel_destroy_registered = true
end

-- Agora podemos carregar as demais libs
local controllers = require('libs/controllers')
local hands       = require('libs/hands')

local params = uevr and uevr.params
local cb     = params and params.sdk and params.sdk.callbacks

-- =============== CONFIG ===============
local PARAMS_FILE    = 'hands_parameters'  -- [profile]/data/<file>.json
local CONFIG_NAME    = 'Main'
local ANIMATION_NAME = ''                  -- vazio se não usar animações
local REAPPLY_FRAMES = {1, 10, 60, 120}    -- reforços após entrar no mapa
-- =====================================

-- Cria controladores (idempotente / protegido)
local function ensure_controllers()
  if not _G.__hands_controllers_created then
    pcall(function()
      controllers.createController(0)
      controllers.createController(1)
    end)
    _G.__hands_controllers_created = true
  end
end

-- Recriação COMPLETA (para troca de mapa): destrói mãos antigas e cria novas
local function rebuild_hands_full()
  ensure_controllers()
  pcall(hands.destroyHands)   -- garante que não haja restos
  pcall(hands.reset)
  pcall(function()
    hands.createFromConfig(PARAMS_FILE, CONFIG_NAME, ANIMATION_NAME)
  end)
end

-- Reforço LEVE (em alguns frames após o load): só recria as mãos
local function rebuild_hands_light()
  pcall(hands.destroyHands)
  pcall(hands.reset)
  pcall(function()
    hands.createFromConfig(PARAMS_FILE, CONFIG_NAME, ANIMATION_NAME)
  end)
end

-- Chain-safe global on_level_change (não sobrescreve outros scripts)
local __prev_on_level_change = _G.on_level_change
local frame_since_load = 0
local reapply_queue    = {}

function on_level_change(level)
  if __prev_on_level_change then pcall(__prev_on_level_change, level) end

  frame_since_load = 0
  reapply_queue = {}
  for i=1,#REAPPLY_FRAMES do reapply_queue[i] = REAPPLY_FRAMES[i] end

  -- 1) troca de mapa: destrói e recria do zero
  rebuild_hands_full()
end

-- Um único enforcer de pré-tick (evita múltiplos registros)
if cb and not _G.__hands_enforcer_registered then
  cb.on_pre_engine_tick(function()
    if #reapply_queue == 0 then return end
    frame_since_load = frame_since_load + 1
    if frame_since_load == reapply_queue[1] then
      -- 2) reforço: recria apenas as mãos (nada de duplicar controladores)
      rebuild_hands_light()
      table.remove(reapply_queue, 1)
    end
  end)
  _G.__hands_enforcer_registered = true
end

-- Também reconstruir ao dar "Reset Scripts" no menu (guardado)
if cb and cb.on_script_reset and not _G.__hands_reset_registered then
  cb.on_script_reset(function()
    rebuild_hands_full()
  end)
  _G.__hands_reset_registered = true
end

print('[hands] noconflict auto-fix v2: destrói no pre-level e reforça nos frames 1,10,60,120.')

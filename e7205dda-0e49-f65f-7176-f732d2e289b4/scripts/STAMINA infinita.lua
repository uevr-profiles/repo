-- stamina_infinite.lua

local api       = uevr.api
local params    = uevr.params
local callbacks = params.sdk.callbacks

-- enum value para stamina
local STAT_STAMINA = 2  -- ELSecondStat.E_STAMINA_POINT_CURRENT

-- função que força stamina sempre cheia
local function refill_stamina()
    local pawn = api:get_local_pawn(0)
    if not pawn then return end

    local statcomp = pawn.StatComponent
    if not statcomp then return end

    -- tenta restaurar sempre o valor máximo
    pcall(function()
        statcomp:RecoveryMaxStat(STAT_STAMINA)
    end)
end

-- roda a cada tick
callbacks.on_pre_engine_tick(function(engine, delta)
    pcall(refill_stamina)
end)

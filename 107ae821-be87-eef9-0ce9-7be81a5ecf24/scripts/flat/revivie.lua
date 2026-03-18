require(".\\Subsystems\\GlobalData")
--require(".\\Subsystems\\GlobalCustomData")
require(".\\Subsystems\\HelperFunctions")

local Deaths=0
local MaxDeaths=1
local function OnLevelChange()
		local engine = game_engine_class:get_first_object_matching(false)
		if not engine then
			return
		end
	
		local viewport = engine.GameViewport
	
		if viewport then
			 world = viewport.World
	
			if world then
				local level = world.PersistentLevel
	
				if last_level ~= level then					
					
				
				Deaths=0


						
				end
	
				last_level = level
			end
		end
end


uevr.sdk.callbacks.on_pre_engine_tick(
function(engine, delta)

OnLevelChange()

local pawn = api:get_local_pawn(0)
local player= api:get_player_controller(0)

if pawn~=nil then
	if pawn.HealthComponent~=nil then
		if pawn.HealthComponent.Health.CurrentData.MinValue~=1 and Deaths <=MaxDeaths then 
			
			--pawn.HealthComponent.Health:SetBaseValue(100) 
			pawn.HealthComponent.Health:SetMinValue(1)
			--pawn.HealthComponent.Health:SetMaxValue(200)
		end
		if pawn.HealthComponent.Health.CurrentData.BaseValue<=1 and Deaths <=MaxDeaths  then
			--pawn.HealthComponent.Health:SetMinValue(1)
			pawn.HealthComponent.Health:SetBaseValue(100)
			--pawn.HealthComponent.Health:SetMaxValue(100)
			player:RequestResetCharacter()
			Deaths=Deaths+1
		
		end
		if Deaths >= MaxDeaths and pawn.HealthComponent.Health.CurrentData.MinValue~=0 then
			pawn.HealthComponent.Health:SetMinValue(0)
		end
	end
end




end)
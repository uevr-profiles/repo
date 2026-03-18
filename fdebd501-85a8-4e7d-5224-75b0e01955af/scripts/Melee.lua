	--CONFIG
	local MeleePower = 1000 --Default = 1000
	---------------------------------------

	local api = uevr.api
	
	--local params = uevr.params
	local callbacks = uevr.params.sdk.callbacks
	local pawn = api:get_local_pawn(0)
	local lHand_Pos =UEVR_Vector3f.new()
	local lHand_Rot =UEVR_Quaternionf.new()
	local rHand_Pos =UEVR_Vector3f.new()
	local rHand_Rot =UEVR_Quaternionf.new()
	local rHand_Joy =UEVR_Vector2f.new()
	local PosZOld=0
	local PosYOld=0
	local PosXOld=0
	local PosZOldR=0
	local PosYOldR=0
	local PosXOldR=0
	local tickskip=0
	local PosDiff = 0
	local PosDiffR = 0
	
--VR to key functions
local function SendKeyPress(key_value, key_up)
    local key_up_string = "down"
    if key_up == true then 
        key_up_string = "up"
    end
    
    api:dispatch_custom_event(key_value, key_up_string)
end

local function SendKeyDown(key_value)
    SendKeyPress(key_value, false)
end

local function SendKeyUp(key_value)
    SendKeyPress(key_value, true)
end
	
function isButtonPressed(state, button)
	return state.Gamepad.wButtons & button ~= 0
end
function isButtonNotPressed(state, button)
	return state.Gamepad.wButtons & button == 0
end
function pressButton(state, button)
	state.Gamepad.wButtons = state.Gamepad.wButtons | button
end
function unpressButton(state, button)
	state.Gamepad.wButtons = state.Gamepad.wButtons & ~(button)
end



uevr.sdk.callbacks.on_pre_engine_tick(
function(engine, delta)
if tickskip==0 then
	tickskip=tickskip+1
elseif tickskip ==1 then
	
	pawn = api:get_local_pawn(0)

	--local rHandIndex = uevr.params.vr.get_right_controller_index()
	uevr.params.vr.get_pose(2, lHand_Pos, lHand_Rot)
	
	local PosXNew=lHand_Pos.x
	local PosYNew=lHand_Pos.y
	local PosZNew=lHand_Pos.z
	
	PosDiff = math.sqrt((PosXNew-PosXOld)^2+(PosYNew-PosYOld)^3+(PosZNew-PosZOld)^2)*10000
	PosZOld=PosZNew
	PosYOld=PosYNew
	PosXOld=PosXNew
	
	uevr.params.vr.get_pose(1, rHand_Pos, rHand_Rot)
	local PosXNewR=rHand_Pos.x
	local PosYNewR=rHand_Pos.y
	local PosZNewR=rHand_Pos.z
	
	PosDiffR = math.sqrt((PosXNewR-PosXOldR)^2+(PosYNewR-PosYOldR)^3+(PosZNewR-PosZOldR)^2)*10000
	PosZOldR=PosZNewR
	PosYOldR=PosYNewR
	PosXOldR=PosXNewR
	--print(PosDiff)
--Show Cursor
	if api:get_player_controller().bShowMouseCursor or pawn["RadialMenuOpen?"] then
		uevr.params.vr.set_mod_value("FrameworkConfig_AlwaysShowCursor", "true")
		--inMenu=true
	else uevr.params.vr.set_mod_value("FrameworkConfig_AlwaysShowCursor", "false")
		--inMenu=false
	end

	tickskip=0
end
end)

local Prep=false
local PrepR=false
local Mouse1=false
uevr.sdk.callbacks.on_xinput_get_state(
function(retval, user_index, state)


if Mouse1==true then
	SendKeyUp('0x01')
	Mouse1 =false
end

local TriggerR = state.Gamepad.bRightTrigger
if PosDiff >= MeleePower and Prep == false then
	Prep=true
elseif PosDiff <=150 and Prep ==true then
	SendKeyDown('0x01')
	Prep=false
	Mouse1=true
end
--if PosDiffR >= MeleePower and PrepR == false then
--	Prep=true
--elseif PosDiffR <=10 and PrepR ==true then
--	state.Gamepad.bRightTrigger= 255
--	PrepR=false
--end	

--Read Gamepad stick input for rotation compensation
	
	
 
	--testrotato.Y= CurrentPressAngle


		--RotationOffset
	--ConvertedAngle= kismet_math_library:Quat_MakeFromEuler(testrotato)
	--print("x: " .. ConvertedAngle.X .. "     y: ".. ConvertedAngle.Y .."     z: ".. ConvertedAngle.Z .. "     w: ".. ConvertedAngle.W)





end)
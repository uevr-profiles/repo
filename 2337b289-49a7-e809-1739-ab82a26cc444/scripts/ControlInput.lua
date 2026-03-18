require(".\\Subsystems\\UEHelper")

uevr.sdk.callbacks.on_xinput_get_state(
function(retval, user_index, state)

if isMenu==false then

	if ThumbRY > 30000 then
		pressButton(state,XINPUT_GAMEPAD_Y)
	end
	if ThumbRY < -30000 then
		pressButton(state,XINPUT_GAMEPAD_B)
	end
end
end)
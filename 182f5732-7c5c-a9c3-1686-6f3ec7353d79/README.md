# UEVR Profile for Supernormal by substatica

| Property | Value |
| :--- | :--- |
| **Game EXE** | `Supernormal-Win64-Shipping` |
| **Source** | [uevr-profiles.com](https://uevr-profiles.com/game/8cebc1de-0d22-46c3-826b-63bd38e40e16) |
| **Created** | 2024-01-08T23:00:00Z |
| **Modified** | 2024-01-08T23:00:00Z |
| **Tags** | 6DOF, Motion Controls |

## Description

Game Settings:
- These settings sometimes reset when you start the experience, and each time the game is run
- Turn off camera motion
- Turn off motion blur
- Limit frames to 60
- Turn on vsync
- Graphic settings Medium (higher has some effects that don't work).

Controls (Quest):
- Right grip trigger = toggle crouch
- Right thumbstick click = toggle flashlight
- A button = interact
- Left Oculus button = menu

*Interacting with the laptop should probably be done in flat/desktop.

Investigate Mode:
- When a small swirl icon appears you can interact with something
- Pressing A will interact
- Interacting with clues will trigger investigate mode
- Investigate mode is a new camera
- When in investigate mode use the right thumbstick to move the spotlight over a clue.
- Once over a clue, hold down Right trigger for 1-5 seconds. The game interprets this as zoom, however you won't see any zoom. Once the trigger is held down for a few seconds the dialog associated with the clue should trigger.
- Press A to leave investigate mode


To run Graphics on High without glitches make these changes to engine.ini courtesy of sofian375 and Metaldeath.

[SystemSettings]
r.TemporalAA.Upsampling=1
r.TemporalAA.Algorithm=1
r.ScreenPercentage=50
r.Tonemapper.Sharpen=1
r.postprocessing.disablematerials=1


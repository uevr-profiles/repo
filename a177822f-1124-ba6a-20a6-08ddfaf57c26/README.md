# UEVR Profile for Ruined Nurse by Sinful_Rose

| Property | Value |
| :--- | :--- |
| **Game EXE** | `RuinedNurse-Win64-Shipping` |
| **Source** | [uevr-profiles.com](https://uevr-profiles.com/game/e060d380-b558-4932-88bb-0674c9fee1e3) |
| **Created** | 2024-12-21T23:00:00Z |
| **Modified** | 2024-12-21T23:00:00Z |
| **Tags** | 6DOF, Motion Controls |

## Description

6DOF Profile with motion controllers support and roomscale.

BINDINGS (I used FreePIE for bindings, see below):

Left Stick -> WASD keys (move)
Right Stick -> mouse movement (turn)
Left Trigger -> F key (flashlight on/off)
Right Trigger -> Left mouse click (fire)
A button -> E key (interaction)
B button -> Tab key (inventory)
X button -> R key (reload)
Y button -> Esc key (options/back)
Left Grip -> Space key (examine items in inventory)
Right Grip -> Q key (switch inventory UI)
Left Thumbstick -> Left Shift key (run)
Right Thumbstick -> Left Ctrl (crouch)

Added a gesture to change weapons lift the left controller on the left side of your helmet and use left stick:

- Left stick up: first weapon
- Left stick right: second weapon
- Left stick down: third weapon
- Left stick left: fourth weapon

Left-handed script has same bindings but inverted triggers.

HOW TO:
- Download the chosen (left or right) UEVR profile from this post
- Import the profile in UEVR
- Download FreePIE v.1.2 (important, v 1.2, NOT v. 1.22) from this link:
https://github.com/Ofisare/VRCompanion/releases

- Unzip in a folder of your wish
- Download the chosen (Ruined_Nurse_Left.py or Ruined_Nurse_Right.py) FreePIE script
- Rename the script to "Ruined_Nurse.py"
- Put the Ruined_Nurse.py file in scripts\user_profiles folder
- Run FreePIE.exe
- Go to Setting->OpenVR and choose your runtime (OpenVR, OpenXR, Oculus)
- Go to File->Open->vr_companion.py
- Go to Script-> Run script
- After few seconds a little launcher will appear -> Choose Ruined_Nurse profile -> Start
- Start game
- Inject UEVR (I suggest to inject when in game's 3D world)
- Enjoy!

ADDITIONAL INFO:
- Be sure to reset to "None" every gamepad setting in the in-game control settings section to avoid interference with the mapping
- The second main menu page (the one where you choose to start a new game or load an old one) needs a mouse to work: manage this page in flat screen
- The saving menu needs a mouse to work: manage this page in flat screen


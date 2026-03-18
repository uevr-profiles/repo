# UEVR Profile for The Elder Scrolls IV: Oblivion Remastered by LandShark

| Property | Value |
| :--- | :--- |
| **Game EXE** | `OblivionRemastered-Win64-Shipping` |
| **Source** | [uevr-profiles.com](https://uevr-profiles.com/game/c7d26ce9-2b05-488c-a23d-5de9e1dd1d18) |
| **Created** | 2025-05-04T22:00:00Z |
| **Modified** | 2025-05-04T22:00:00Z |
| **Tags** | 6DOF, Motion Controls |

## Description

Design goal:
A stable, performant gameplay experience achieved by removing features still under development in Pande's latest releases
(All credit for code goes to Pande4360 In cooperation with Praydog, DJ, Jbusfield, Markmon, Teddybear082)

Installation:
- Get uevr 1061
- Delete old profiles(use "open global dir" button in uevr)
- Import new profile (Win64 for steam, wingdk for gamepass)
- Rename preferred user script preset file to "user_script.txt" (in-game settings will be used without one)
- Review /Config/CONFIG.lua options ()

Changes:
- default shadowquality_outdoors (0->1)
- Added 4 user script presets (pick one & rename to user_script.txt)
- Edit /Config/CONFIG.lua options file for lumenindoors
- Fixed bug causing shield to appear with bow & 2-handed weapons (reverted to older arms.lua)

Vanilla Controls:
- Spell Wheel: Left Grip
- Run: Press L3 (toggle)
- Jump/Crouch: Up/Down on Rstick

- Performance Adjustments
- Enables Lumen Indoors
- Shadows Disabled Outdoors

Features:
- Hands(needs gloves or robe to be worn)
- Vanilla Control layout
- Vanilla Right Controller UI attached aiming only ("UI Follows View" / Head doesn't work)

Disabled Features:
- Config UI Menu (Lua UI)
- 2 handed Bows,
- Collision based combat
- Holster System
- Custom VR control layout


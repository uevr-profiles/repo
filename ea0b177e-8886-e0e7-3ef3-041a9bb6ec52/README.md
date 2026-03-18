# UEVR Profile for The Sinking City by Oziman

| Property | Value |
| :--- | :--- |
| **Game EXE** | `TSCGame-Win64-Shipping` |
| **Source** | [uevr-profiles.com](https://uevr-profiles.com/game/8c850cff-856d-48c4-b82d-ed71778dc8d0) |
| **Created** | 2024-04-02T22:00:00Z |
| **Modified** | 2024-04-02T22:00:00Z |
| **Tags** | 3DOF |

## Description

- Big inconvenience is "insane effects" which are unbearable in VR. But to remove that effect it is enough to enter these lines in "GameSettings.ini".

[/script/tscgame.insanitymanagersettings]
Stages=(Min=0.000000,Max=100.000000,Effects=(None),CurrentEffect=None)

That file is located in: "%localappdata%\TSCGame\Saved\Config\WindowsNoEditor".

- UEVR for some reason does not activate this profile automatically. But after starting it is enough to click on "Main", nothing more.


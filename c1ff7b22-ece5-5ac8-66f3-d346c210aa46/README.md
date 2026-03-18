# UEVR Profile for FINAL FANTASY VII REMAKE INTERGRADE by markmon

| Property | Value |
| :--- | :--- |
| **Game EXE** | `ff7remake_` |
| **Source** | [uevr-profiles.com](https://uevr-profiles.com/game/ff889714-fa4e-44e0-b182-db8e3282533b) |
| **Created** | 2024-08-10T22:00:00Z |
| **Modified** | 2024-08-10T22:00:00Z |
| **Tags** | 3DOF |

## Description

Here is an updated FF7Remake profile that includes praydogs' dll fix, the recommended cvars, the updated cleaner 3dmigotoloader from ponos0393, and my own dll to fix the movies in only one eye. To use this, remove your old profile and import this fresh. Then run 3dmigotoloader first in the profile's 3dmigoto folder. Run UEVR, and inject. You will need a recent nightly build of UEVR from at least late July for the one-eye movie fix to work.  Make sure you use -dx11 or -d3d11 in your steam or epic launcher. Also, this only works on OpenXR because the HUD fix won't work otherwise.  This is a native rendering profile.

Additionally, there is a loader in here that you can drop into your steam command line so you no longer have to load the 3dmigoto stuff separately. To use that, you can ignore the -dx11 stuff and just replace your steam command line to:
%appdata%\UnrealVRMod\ff7remake_\ff7ruevrlauncher.exe %command%


# UEVR Profile for The Complex: Found Footage by impulsehs

| Property | Value |
| :--- | :--- |
| **Game EXE** | `TheComplexFF-Win64-Shipping` |
| **Source** | [uevr-profiles.com](https://uevr-profiles.com/game/162de8fe-6e53-40ed-8d47-ba9f42aa8234) |
| **Created** | 2024-01-05T23:00:00Z |
| **Modified** | 2024-01-05T23:00:00Z |

## Description

Paste this into your Engine.ini file of the game to get rid of the zoomed in, post processing effect of the game (thanks to cfibery):

[SystemSettings]
r.MotionBlur.Max=0
r.MotionBlurQuality=0
r.DefaultFeature.MotionBlur=0
r.DepthOfFieldQuality=0
r.PostProcessAAQuality=1
r.DefaultFeature.AntiAliasing=1
r.SceneColorFringe.Max=0
r.SceneColorFringeQuality=0
r.Tonemapper.GrainQuantization=0
r.Tonemapper.Quality=0
r.LensFlareQuality=0
r.DefaultFeature.LensFlare=0
r.DefaultFeature.Bloom=0
r.BloomQuality=0
r.Shadow.MaxResolution=704
r.postprocessing.disablematerials=1

Folder is located here:
"%localappdata%\TheComplexExpedition\Saved\Config\Windows"


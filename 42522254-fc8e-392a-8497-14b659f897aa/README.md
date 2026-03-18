# UEVR Profile for SCP: 5K by Kuby

| Property | Value |
| :--- | :--- |
| **Game EXE** | `Pandemic` |
| **Source** | [uevr-profiles.com](https://uevr-profiles.com/game/e9bf78fa-9fda-4086-8238-2ac0b42b785e) |
| **Created** | 2026-02-07T23:00:00Z |
| **Modified** | 2026-02-07T23:00:00Z |
| **Tags** | 3DOF, 6DoF, Motion Controls |

## Description

SCP: 5K "Immersion +" Gunstock oriented profile

I wanted a profile for this game that kept the arms and animations as much as possible to preserve the immersion and the depth of the gunplay you get from playing the flat version, while also ironing out some of the major bugs and issues that come with that setup. While this means sometimes the weapon won't line up with the controller because of the animations, I've ensured this only happens in times when you wouldn't be able to use the weapon anyway (Sprinting, Reloading, Vaulting e.t.c). we take differences in normal firing stance from each individual weapon into account by scanning for weapon changes and applying tailor made offsets in real time. This will likely require constant updates as new weapons are added, although the process is fairly straightforward.

This profile was made primarily with VR gunstocks in mind. 
Although you don't necessarily need one, the offsets may feel a little off sometimes without one as the target was getting the sights to line up over the hands when the gun shape is non-standard

There are no special installation steps needed, just import the zip into UEVR and inject!

Features and fixes:
- Fixed ghostly double image/reflection appearing in front of everything else
The Bloom effect doesn't render properly in VR in some cases and causes this bug, we turn it off upon injection by default, if you want the bloom effect, you can delete the user_script.txt file in the profile folder. some known ways of fixing the bloom effect properly is using DLSS on performance or ultra performance presets, using the synced sequential rendering method (costs performance and can look worse) or using "stereo fix" from the nightly UEVR version (causes your spectators to see out of your left eye instead of the right eye)

- Animation tweaks
Several changes have been made to the first person animations to feel more aligned with a VR game:
    - Removed freeaim (the gun stays aligned with the controller when turning with the right stick instead of drifting to the sides)
    - Significantly reduced recoil when firing without holding the ADS button
    - Fixed the bug/oversight that causes the camera to be dragged over to the weapon's sights when using ADS. Now ADS only stabilizes the weapon (Slower movement, lower recoil)
    - Removed Weapon offsets when crouched and walking
Note that walking animations, turning animations, jumping animations e.t.c all still have a slight effect on where the weapon is pointed and will therefore reduce your accuracy, this is intentional and the primary mechanic I wanted to preserve in this profile.

Physical crouch:
- You can get your in game character to crouch by either physically crouching OR by pressing the crouch button, the script will figure out which one you are trying to do and respond accordingly.

Flashlight gesture:
- This allows you to toggle your headlamp by gently bringing your left controller to your head

6 DOF motion controls with dynamic weapon offsets:
- The profile dynamically detects what weapon the player is holding, and applies an offset to align that weapon to the controller during use, we also change the character's pose while they are using a pistol to hold the gun further out for added immersion. (the script includes a configuration file where you can set a global offset and edit each individual weapon's offsets as well)


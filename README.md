This project implements a safe animation/emote blocking system for Roblox characters.
The goal is to prevent players from playing animations too close to each other to mimic weird stuff.

# 📁 Files Overview
## 1. SafetySettings.lua

Stores configuration values used by the safety system.

**Includes:**

 - List of animation types to whitelist
 - Emote-distance limit for detecting emotes too close to another player
 - Other tweakable safety thresholds
 - This file does not perform logic, it only stores settings.

> Put in ServerStorage -> SafetySettings (Module)

## 2. SafetyModule.lua

Main server-side animation protection system.

**Handles:**

 - Loading valid animation IDs from the character’s Animate script
 - Detecting whenever a new animation starts Checking if the animation
 - is whitelisted Doing a forward raycast to see if the player is
 - emoting too close to someone Blocking the animation track from
 - playing if two players are facing each other too close.

*This script ensures bad animations never replicate to other players.*
> Put in ServerScriptService-> SafetyModule (Script)

## 3. ClientSideExample.lua

**Optional** example showing how the client can help detect or block emotes locally.

*This does not enforce replication rules — that happens on the server.*
> Put in StarterPlayer -> StarterCharacterScripts -> Any (LocalScript)

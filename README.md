# PVPToggleTurtleWOW

## Special Thanks ❤️

Special thanks for helping with testing, feedback, and patience during development:

- Curpse
- Leekwangsoo
- Hantingxue
- Sooyaa

Your help was invaluable in making this addon stable and Turtle WoW–compatible.

---

## Overview

PVPToggleTurtleWOW is a lightweight PvP toggle addon designed specifically for Turtle WoW (Vanilla / Lua 5.0).

It provides:
- A movable PvP toggle frame
- A minimap button
- Clear PvP status display (Active / Inactive / Deactivation with countdown)
- Reliable reset detection during PvP deactivation
- A compact and configurable options UI

The addon is written to be fully compatible with Vanilla-era Lua (5.0) and Turtle WoW’s API behavior.

---

## Features

### Main PvP Frame
- Displays PvP status:
  - Active
  - Inactive
  - Deactivation (with countdown timer)
- Sword icon button toggles PvP on/off
- Countdown shown next to the status text
- Frame width dynamically adjusts to text and timer
- Lock icon appears when the frame is locked
- Frame is movable when unlocked

### Minimap Button
- Left Click: Open options  
- Right Click: Show / hide the PvP frame (does not toggle PvP)
- Button can be dragged around the minimap

---

## PvP Deactivation Reset Logic

During the PvP deactivation countdown, the timer will reset if:
- You deal damage
- You receive hostile damage
- You perform PvP-relevant actions (damage, heal, buff)

The timer will NOT reset if:
- You are only healed by other players
- No actual combat result occurs

Reset detection uses a combination of UNIT_COMBAT events and GetPVPTimer() jumps for reliable behavior on Turtle WoW.

---

## Reset Notification

Optional reset notifications include:
- Screen message
- Chat message
- Sound notification (Raid Warning sound)

Notifications have a configurable cooldown (default: 5 seconds).  
The cooldown affects only the notification, not the reset itself.

---

## Options

Accessible via:
- Minimap button (Left Click)
- Slash command: /pvptoggle

Options include:
- Lock / Unlock frame
- Reset notification on/off
- Reset sound on/off (only visible when notification is enabled)
- Reset notification cooldown
- Debug mode

The options window automatically resizes to avoid empty space.

---

## Slash Commands

/pvptoggle  
/pvptoggle options  
/pvptoggle lock  
/pvptoggle unlock  
/pvptoggle show  
/pvptoggle hide  

---

## Compatibility

- Target client: Turtle WoW (Vanilla)
- Lua version: 5.0
- No modern Lua features are used

---

## Installation

1. Create folder:
   Interface/AddOns/PVPToggleTurtleWOW
2. Copy addon files into the folder
3. Restart the game or use /reload

## Files
- `PVPToggleTurtleWOW.toc`
- `PvpToggleTurtle.lua`
- `Icons/Lock.tga`

## License
All Rights Reserved (see LICENSE).
# PVPToggleTurtleWOW

Author: Fragglechen

PvP status frame for Turtle WoW / Vanilla 1.12 with minimap options, lock icon, timer handling, and configurable UI.

## Features
- PvP status frame with sword icon, status text and countdown timer while disabling PvP
- Dynamic frame width (adapts to status text + timer + lock icon space)
- Lock/Unlock frame position (shows lock icon)
- Minimap button:
  - Left click: Options
  - Right click: Toggle PvP
- Options window:
  - Scale slider
  - Lock / Unlock button
  - Timer reset notice toggle
  - Debug mode toggle
- Slash commands:
  - /pvptoggle
  - /pvptoggle help
  - /pvptoggle show | hide
  - /pvptoggle lock | unlock
  - /pvptoggle scale <0.5-2.0>
  - /pvptoggle config
  - /pvptoggle debug [on/off]

## Installation
1. Extract the ZIP into:
   `World of Warcraft\Interface\AddOns\`
2. Ensure the folder name is exactly:
   `PVPToggleTurtleWOW`
3. Restart the game.

## Files
- `PVPToggleTurtleWOW.toc`
- `PvpToggleTurtle.lua`
- `Icons/Lock.tga`

## License
All Rights Reserved (see LICENSE).

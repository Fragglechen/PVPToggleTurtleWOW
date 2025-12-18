# Changelog

## v1.0.0 – Initial Release

### Added
- PvP toggle main frame with clear status display:
  - Active
  - Inactive
  - Deactivation with countdown timer
- Sword icon button to toggle PvP state
- Dynamic frame width based on status text and countdown
- Lockable and movable frame with lock indicator icon
- Minimap button:
  - Left Click: Open options
  - Right Click: Show / hide PvP frame
  - Draggable around the minimap
- Options window with automatic height adjustment:
  - Frame lock / unlock
  - Reset notification toggle
  - Reset sound toggle (only visible when reset notification is enabled)
  - Reset notification cooldown slider
  - Optional debug mode
- Reliable PvP deactivation reset detection:
  - Incoming hostile damage (melee, ranged, spell)
  - Outgoing damage and PvP-relevant actions
  - Detection via UNIT_COMBAT and GetPVPTimer() jumps
- Optional reset notifications:
  - On-screen message
  - Chat message
  - Raid Warning sound
  - Configurable cooldown (default: 5 seconds)

### Behavior
- PvP deactivation countdown resets only on actual combat results
- Incoming heals from other players do not trigger a reset
- Notification cooldown affects only messages/sounds, not the reset logic

### Compatibility
- Designed specifically for Turtle WoW
- Fully compatible with Vanilla Lua 5.0
- No modern Lua syntax or operators used

### Notes
- Default state on login: frame unlocked
- Focus on stability, clarity, and Turtle WoW–specific behavior

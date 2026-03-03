# Skill Runtime Architecture (V1)

## Overview
The combat runtime now supports a unified special-skill pipeline on top of existing normal attacks.

- Lifecycle: `startup -> active -> recovery -> cooldown`
- Directional special routing:
  - `N+SP` -> `signature_a`
  - `6+SP` -> `signature_b`
  - `2+SP` -> `signature_c`
  - `SP+HVY` (with full hype) -> `ultimate`
- Hype meter: `0..100`, consumed by `ultimate`

## Core Runtime Capabilities
Implemented in `scripts/Player.gd`.

- Cooldown system:
  - Per-skill cooldown map (`skill_cooldowns`)
  - Gate checks before attack start
- Status control effects:
  - `silence` (disable signatures/ultimate)
  - `slow` (movement multiplier)
  - `root` (movement/dash lock)
- Buff system (`install`):
  - Damage multiplier
  - Move speed multiplier
  - Startup multiplier
  - Chip bonus
- Runtime skill entities:
  - `projectile`
  - `trap`
  - `summon`
- Mobility effect:
  - `dash`
  - `rising`
  - `teleport`

## Data Contract (Attack Entry)
Skill attacks extend attack table entries with these optional fields:

- `cooldown: float`
- `effect: Dictionary`
  - `type: projectile | trap | summon | mobility | buff`
  - Common payload examples:
    - `speed`, `duration`, `size`, `spawn_delay`, `spawn_offset_x`, `spawn_offset_y`
    - mobility: `mode`, `distance`, `rise_speed`, `forward_speed`
    - buff: `buff = { duration, damage_multiplier, speed_multiplier, startup_multiplier, chip_bonus }`
- `control: Dictionary`
  - `silence_seconds`, `slow_seconds`, `slow_factor`, `root_seconds`, `status_scale_on_block`

## Roster Coverage Strategy
- Wave1 (Elon/Mark/Sam/Peter): explicit signature entries in character attack tables.
- Remaining roster: runtime auto-generation by character ID profile (in `Player.gd`) when signature entries are missing.

This keeps authoring flexible while guaranteeing full 16-fighter runtime coverage.

## Verification
Use `just test`.

Current automated checks include:
- Scene boot smoke tests
- Character attack table validation
- Core damage/block flow
- Skill runtime primitive checks
- Wave1 explicit skill wiring checks
- Full 16-roster runtime signature coverage checks

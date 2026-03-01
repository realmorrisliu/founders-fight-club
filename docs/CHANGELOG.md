# Changelog

## [Unreleased] - MVP Implementation

### Added
- **Dash**: Added Dash mechanic (Key: `L`) with cooldown and duration logic in `Player.gd`.
- **Hitstun**: Added Hitstun state (0.18s) preventing input during damage in `Player.gd`.
- **Hitstop**: Added Global Hitstop (time freeze) on successful hits in `Match.gd`.
- **Block**: Added hold-to-block state (Key: `H`) with blockstun and chip damage rules.
- **Knockdown Flow**: Added `fall` -> `getup` combat states for heavy launches/throws.
- **Guard Feedback**: Added guard-specific hitstop, camera shake profile, and spark particle effect.
- **Guard Counter Window**: Added short post-block counter window that buffs the next strike.
- **Pixel Impact VFX**: Replaced temporary particle sparks with pixel-frame `guard/counter` impact animations.
- **Combat Callouts**: Added HUD popup text for `GUARD` and `COUNTER` with EN/ZH localization.
- **Combo Cancel v1**: Added input buffer, cancel rules (`light -> light/heavy/special`, `heavy -> special`), and combo-hit tracking.
- **Combo Scaling v1**: Added combo damage scaling with a minimum guaranteed damage floor.
- **Tech / OTG Rules**: Added quick tech recovery, roll-tech slide, wake-up invulnerability, and OTG immunity.
- **Layered Combat SFX**: Added placeholder SFX set with hit/block tiers plus counter/combo/tech sounds.
- **Training HUD v1**: Added stun/recovery/frame-advantage training panel with event summary and rolling log.
- **Training Dummy Options**: Added HUD controls for training mode toggle, dummy mode (`Stand` / `Force Block` / `Random Block`), and detailed advantage display.
- **Mixup Feedback**: Added `OVERHEAD` / `LOW` secondary combat callouts and training-log tags for high/low attacks.
- **Data-Driven Move Tables**: Added `AttackTable` resource + external `.tres` attack definitions and per-player table assignment.
- **Mode Select Menu**: Added dedicated `Menu.tscn` entry scene with `VS Match` / `Training Mode` routing.
- **Training Scene**: Added separate `Training.tscn` using `Match.gd` scene exports (no round timeout, training HUD enabled).
- **Training Log Damage Columns**: Training log now records event damage, combo damage, and target HP before/after.
- **Overhead Semantics**: Replaced attack `block_type = high` with `block_type = overhead` (with compatibility fallback in logic).
- **Camera**: Added dynamic `Camera2D` following players via code in `Match.gd`.
- **Arena Walls**: Added invisible `StaticBody2D` boundaries to the arena via code in `Match.gd`.
- **Restart**: Added Match Restart (Key: `R`) logic and input mapping.
- **Pause**: Added Pause toggle (Key: `Esc`).
- **UI**: Added "Press R to Restart" prompt and localized result text hooks.
- **AI Art Template Pack**: Added `docs/AI_ART_TEMPLATE_PACK.md` with reusable templates for style lock, manifest, prompts, naming, and QA.
- **AI Art Execution Guide (2026)**: Added `docs/AI_ART_EXECUTION_GUIDE_2026.md` with model routing, production workflow, rollout plan, and risk controls.

### Changed
- **Match.gd**: Heavily refactored to handle camera, walls, input, and hitstop.
- **Player.gd**: Expanded state machine with `block`, `hit_light`, `hit_heavy`, `fall`, and `getup` behavior.
- **Player.gd**: Split `hit_landed` and `blocked_landed` flow for cleaner combat event handling.
- **Player.gd**: Added per-move blockstun/block-recovery tuning and counter-bonus hit properties.
- **Match.gd**: Added counter-hit feedback branch with stronger hitstop, shake, and impact spark.
- **Match.gd**: Impact spark spawning now uses `AnimatedSprite2D` + `ImpactSpriteFrames.tres`.
- **Match.gd**: Hit callback now consumes combo count and displays localized combo callouts (`%d HIT` / `%d 连击`).
- **Match.gd**: Loads and plays layered one-shot combat SFX by event and attack kind.
- **Player.gd**: Hit callback now returns/handles ignored (OTG-invuln) hits without burning target collision.
- **PlayerSpriteFrames.tres**: Added first-pass animation tracks for block/hit-react/knockdown/getup.
- **project.godot**: Added `block` input action (keyboard + gamepad).
- **Player.gd**: Added training-dummy control path that can override AI for stand/auto-block/random-block practice.
- **Main.tscn**: Player1/Player2 now load separate attack-table resources (`PrototypeP1/P2AttackTable.tres`).
- **project.godot**: Main scene now routes to `scenes/Menu.tscn`.
- **Match.gd**: Added scene-level exports for VS/Training behavior (timer, training panel, training controls, dummy defaults).

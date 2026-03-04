# Smash Execution Sprint V2 (2026-03-04)

Goal: close the biggest remaining gap between current prototype and "easy to start, deep to master" platform-fighter feel.

Status legend: `[ ]` pending, `[~]` in progress, `[x]` done.

## Scope (This Sprint)
- [x] S2-1 Defense Layer V1: shield resource + shield break.
- [x] S2-2 Dodge Layer V1: spot dodge, roll dodge, air dodge.
- [x] S2-3 Recovery Layer V1: double jump + ledge getup options.
- [x] S2-4 Onboarding/Stage Polish V1: training quick-start hint + basic tri-platform arena geometry.

## Acceptance Criteria

### S2-1 Defense Layer V1
- Player has a finite shield resource.
- Holding block drains shield; releasing block regenerates shield after short delay.
- Blocking attacks also damages shield.
- When shield reaches zero: shield break state triggers, player cannot attack/jump/block until break-stun ends.
- HUD state row exposes shield value and break status.
- Tests:
  - `shield breaks when depleted`
  - `shield recovers after break`
  - `shield regens while idle`
Implemented:
- Added shield resource lifecycle in `Player.gd` (drain, regen delay, hit damage to shield, break-stun gate).
- Added shield/break status surfacing to runtime snapshot + HUD combat row.
- Added regression test `_test_shield_resource_and_break_flow`.
- Verification: `./scripts/test.sh smoke` passed.

### S2-2 Dodge Layer V1
- Ground `dash` while blocking triggers defensive dodge instead of regular dash.
- Ground neutral + dodge => spot dodge.
- Ground directional + dodge => roll.
- Air dodge available once per airtime.
- Dodge grants temporary invulnerability and blocks immediate hit confirm.
- Tests:
  - `spot dodge grants invulnerability`
  - `roll dodge moves in requested direction`
  - `air dodge consumes air dodge resource`
Implemented:
- Added defensive dodge state machine in `Player.gd` (`spot` / `roll` / `air`) with per-mode timing and motion.
- Wired player input so `dash` while guarding on ground enters defensive dodge instead of movement dash.
- Added one-airtime air-dodge resource with reset on floor/ledge.
- Added invulnerability windows via dodge startup (`wake_invuln_time`) and blocked attack startup during active dodge.
- Added regression test `_test_defensive_dodge_layer`.
- Verification: `./scripts/test.sh smoke` passed.

### S2-3 Recovery Layer V1
- Player has one extra air jump by default.
- Air jump consumed when jumping in air without floor/coyote permission.
- Air jump refreshes on floor/ledge.
- Ledge hang supports:
  - jump (existing)
  - drop (existing)
  - roll getup (new)
  - attack getup (new)
- Tests:
  - `double jump consumes remaining air jump`
  - `no additional jump after air jumps exhausted`
  - `ledge roll and ledge attack exit hang and change state`
Implemented:
- Added one extra air-jump resource in `Player.gd` with consumption on true airborne jump and refresh on floor/ledge transitions.
- Added ledge hang options for `dash` (roll getup) and `attack_light`/`attack_heavy` (attack getup).
- Added regression test `_test_double_jump_and_ledge_getup_options`.
- Verification: `./scripts/test.sh smoke` passed.

### S2-4 Onboarding/Stage Polish V1
- Training panel surfaces a concise quick-start control hint (localized EN/ZH).
- Arena scene includes two elevated platforms to support platform-fighter routing.
- Tests:
  - `training quick-start hint renders`
  - `arena exposes extra platform colliders`
Implemented:
- Added `TrainingQuickHintLabel` in HUD training panel and localized text key `HUD_TRAINING_QUICK_HINT` (EN/ZH).
- Added two elevated one-way platform colliders (`PlatformLeft`, `PlatformRight`) in `Arena.tscn` for tri-platform routing.
- Added regression tests `_test_training_quick_start_hint_renders` and `_test_arena_extra_platform_colliders`.
- Verification: `./scripts/test.sh smoke` passed.

## Verification Protocol
After each item:
1. Run `./scripts/test.sh smoke`
2. Review failures, fix regressions until green.
3. Mark item as `[x]` with one-line implementation note.

After all items:
1. Run `./scripts/test.sh full`
2. Ensure no leak warnings are introduced.

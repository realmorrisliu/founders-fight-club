# MVP Design Doc

## High Concept
2D pixel-art 1v1 fighter set in a Silicon Valley founders brawl. Single match, 60-second round, one prototype fighter, one arena.

## Core Loop
- Select match (no character select yet) -> fight -> win/lose -> restart.
- Victory by KO (HP to zero) or by timeout with higher HP.

## Combat Pillars
- Tight inputs with readable hit feedback.
- Distinct move categories: light, heavy, special, throw.
- Simple neutral game: spacing, punish, and basic combo routes.
- Defense interaction: block into short counter-hit opportunities.
- Training tooling: frame-advantage readout and dummy block behaviors for iteration.

## Inputs
- Move (left/right), jump, block.
- Light attack, heavy attack, special, throw.
- Optional: dash and pause.

## Prototype Move Set (1 Fighter)
- Light: fast jab, short range.
- Heavy: slower strike, longer range, higher damage.
- Special: forward lunge with brief invulnerability.
- Throw: close-range grab, quick knockdown.
- Cancel routes (v1): `light -> light/heavy/special`, `heavy -> special`.

## Systems (MVP)
- Character controller (ground/air, facing, hitstun, block, knockdown/getup).
- Combat system (hitboxes/hurtboxes, damage, combo scaling, knockback, hitstop).
- Training mode helpers (advantage HUD, event log, dummy stand/block/random-block).
- Round system (timer, HP bars, win/lose state).
- Camera follow and arena bounds.
- UI (timer, HP, simple round result, combat callouts).

## Assets (MVP)
- 1 fighter sprite sheet: idle, walk, jump, attack variants, block, hit reactions, knockdown/getup, KO.
- 1 arena background with collision bounds.
- Basic UI sprites for HP and timer.

## Success Criteria
- One match playable end-to-end with clear win/lose.
- Attacks feel distinct and readable.
- Keyboard + gamepad input works reliably.
- Defense and knockdown interactions support basic tech/OTG rules.

## Scene & Script Layout (Proposal)
- `scenes/Main.tscn`: root, match orchestration.
- `scenes/Arena.tscn`: background + collision bounds.
- `scenes/Player.tscn`: fighter scene.
- `scripts/Match.gd`: round flow, timer, win conditions.
- `scripts/Player.gd`: movement, state machine, animation triggers.
- `scripts/Combat.gd`: hit detection, damage, knockback rules.
- `scripts/resources/AttackTable.gd`: resource format for per-character move data.
- `scenes/ui/Hud.tscn`: HP bars + timer.

## Milestones
- M1: Player movement + jump + facing.
- M2: Light/heavy/special/throw with hit feedback.
- M3: HP, timer, win/lose flow.
- M4: Basic polish (hitstop, knockback tuning, UI pass).

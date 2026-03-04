# Smash Alignment Plan (2026-03-04)

## Goal
Move Founders Fight Club from a traditional HP-based 2D fighter prototype toward a platform-fighter experience inspired by Super Smash Bros:
- Easy onboarding (30-second understanding)
- High expression ceiling (directional options, movement layers, stage interaction)
- Strong character identity and readable match flow

## Critical Audit Summary

### P0 (Core Identity Mismatch)
- Win condition is HP + timeout, not stock + ring-out.
- Stage has hard side walls, blocking edge play and off-stage interaction.
- Main mode is effectively single-player vs AI, not robust local versus.
- Vertical and aerial game depth is too limited for platform-fighter pacing.

### P1 (Gameplay Depth / Feel)
- Input grammar is too narrow; directional attack expression is limited.
- Roster differentiation relies too much on tint and data variance, not per-character animation language.
- Hit/hurt model is too coarse for nuanced spacing and collision storytelling.
- Throw-tech and AI defense logic are currently too forgiving/coarse in key situations.

### P2 (Architecture / Production)
- Stage dimensions and limits are hardcoded in several systems.
- Character signature naming metadata exists but is not surfaced to players.
- Match mode session key is written but unused.
- Runtime audio spawning pattern can become expensive under high event density.

### P3 (Process / Quality)
- CI gate runs only smoke tests; full suite is not mandatory.
- Some docs are stale relative to implemented behavior.

## Step-by-Step Execution Plan

## Step 1 (Now): Core Match Rule Shift to Stock + Ring-out
- Add stock-based mode in `Match.gd` for main battle flow.
- Add blast-zone ring-out checks and stock loss handling.
- Disable side walls for stock mode to enable off-stage play.
- Add fighter respawn API in `Player.gd` and wire match-side respawn.
- Surface stock state to HUD.
- Update regression tests for the new default main match semantics.

Status: Completed (implemented + smoke/full tests passing).

## Step 2: Input Model for Platform Fighter Readability
- Add directional attack families (ground tilt/smash + aerial families).
- Separate player input channels for true local 1P/2P control.
- Keep modern onboarding preset while preserving classic fallback.

Status: Completed.
- Added directional basic attack variants (`light_up/down/air`, `heavy_up/down/air`) in runtime attack model.
- Added dedicated local input channel for Player 2 (`p2_*` actions).
- Wired main match to session `vs` mode so Player 2 is local control (not forced AI).
- Added regression tests for `vs` local-control behavior and directional variant resolution.

## Step 3: Stage & Camera for Off-Stage Play
- Add ledge/off-stage recovery flow.
- Replace hardcoded stage bounds with scene-driven stage config.
- Tune camera framing for vertical kills and edge pressure.

Status: Completed.
- Replaced hardcoded horizontal stage bounds with scene-derived geometry sync (`left/right/floor`) from `Arena/Ground`.
- Added ledge recovery runtime in `Player.gd` (auto-grab near edge while falling, ledge jump, ledge drop, regrab lockout).
- Added dynamic vertical camera framing and vertical-separation zoom response for high-launch readability.
- Added regression tests for stage floor sync, ledge recovery flow, and vertical camera response.

## Step 4: Combat Feel Pass
- Refine knockback growth, hitstop tiers, DI/tech interactions.
- Tighten throw-tech windows and defensive option clarity.
- Improve hitbox/hurtbox authoring granularity beyond single-box baseline.

Status: Completed.
- Added damage-ratio knockback growth scaling in `Player.gd` so high-percent launches feel progressively lethal.
- Added directional influence (DI) steering and deterministic DI test hooks for launch-trajectory control expression.
- Upgraded hit/hurt interaction from a single coarse zone to multi-zone hurt regions (head/body/legs) with per-zone modifiers.
- Refined hitstop/blockstop resolution by attack tier (light/heavy/signature/ultimate) for stronger impact readability.
- Added regression coverage for knockback growth, DI behavior, and tiered hitstop resolution.

## Step 5: Character Identity Pass
- Introduce per-character animation beats and timing personality.
- Expose signature move names and archetype hints in menu/HUD/training.
- Build matchup readability via bespoke effects and silhouettes.

Status: Completed.
- Added character profile surfacing API in `Player.gd` (archetype, hint keys, signature name map).
- Extended attack table resource metadata (`archetype_key`, signature labels) for per-character identity presentation.
- Wired menu and HUD to show archetype labels/hints and per-fighter signature names in live/training readouts.
- Localized new identity/UI strings for both English and Chinese.
- Added regression tests validating menu/HUD profile visibility and per-character signature label resolution.

## Step 6: Production Hardening
- Promote full suite to CI required gate.
- Resolve lifecycle/object leak warnings in test exits.
- Refresh docs to match implemented systems.

Status: Completed.
- Promoted CI test workflow from smoke gate naming/execution to full-suite execution (`scripts/test.sh full`).
- Eliminated exit-time `ObjectDB` leaks by replacing deferred dialogue `SceneTreeTimer` usage with a lifecycle-bound `Timer` node in `Match.gd`.
- Verified leak fix with full-suite run: no `ObjectDB instances leaked at exit` warning remains.
- Updated this alignment plan to reflect implemented behavior and final step completion.

## Step 7: Movement Expression & Onboarding Feel
- Add jump leniency layers expected by platform fighters (coyote time + jump buffer).
- Add fast-fall and short-hop control so air game is readable for beginners and expressive for advanced play.
- Keep every movement tweak covered by deterministic runtime tests.

Status: Completed.
- Added `coyote time` and `jump buffer` runtime handling in `Player.gd` to reduce strict timing failure at ledges/landings.
- Added `fast-fall` state with stronger air gravity and capped descent speed for deliberate downward air tempo.
- Added `jump-cut` (short-hop via early jump release) for controllable jump height.
- Added aerial landing-lag + auto-cancel windows (startup + late-recovery) to improve air-attack risk/reward readability.
- Fixed fast-fall landing-lag bonus application on touchdown and blocked ground attack startup during landing-lag lock.
- Added regression tests for buffered coyote jump, fast-fall velocity delta, short-hop jump-cut behavior, and aerial landing-lag/auto-cancel transitions.

## Notes
- This plan intentionally starts with ruleset identity (Step 1) before deep content expansion.
- Smash-like quality depends on interaction topology first, then move depth and polish.

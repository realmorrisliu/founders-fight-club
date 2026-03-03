# Skill Implementation Tasks (Roster 16)

## Goal
Implement the full 16-fighter special skill system with reusable gameplay primitives and automated regression gates after each task.

## Task List

- [x] Task 0: Create implementation backlog and automated test baseline.
  - Deliverables:
    - Headless test entrypoint (`tests/TestRunner.gd`)
    - CLI test command (`scripts/test.sh`, `just test`)
    - Smoke checks: scene boot, roster attack-table validity, player damage/block flow
  - Gate:
    - `just test` must pass.

- [x] Task 1: Build reusable special-skill runtime primitives.
  - Deliverables:
    - Projectile / Trap / Summon / Mobility / Control / Buff-Debuff effect pipeline
    - Unified startup-active-recovery-cooldown lifecycle
    - Per-skill cooldown tracking and trigger framework
  - Gate:
    - `just test` + skill runtime unit/integration tests must pass.

- [x] Task 2: Integrate first 4 fighters as a vertical slice.
  - Fighters:
    - Elon Mvsk, Mark Zuck, Sam Altmyn, Peter Thyell
  - Deliverables:
    - Signature A/B/C + Ultimate behavior hooks wired to runtime
    - Basic tuning and in-match validation
  - Gate:
    - `just test` + vertical-slice behavior tests must pass.

- [x] Task 3: Integrate all 16 fighters and baseline balancing.
  - Deliverables:
    - Full roster skill behavior coverage
    - Data validation for complete skill kit definitions
    - Baseline balancing pass (damage, cooldown, control duration)
  - Gate:
    - `just test` + full roster validation tests must pass.

- [x] Task 4: Final documentation + full regression pass.
  - Deliverables:
    - Updated docs for runtime architecture and skill authoring
    - Test matrix and maintenance notes
  - Gate:
    - `just test` final pass on full feature set.

## Execution Rule
Every task must finish with automated testing before moving to the next task.

## Completion Snapshot
- Status: Completed (Task 0-4)
- Automated gate: `just test` passes after each milestone and final pass
- CI gate: `.github/workflows/test.yml` runs smoke suite on PRs and `main` pushes
- Runtime coverage:
  - Reusable primitives: projectile / trap / summon / mobility / control / buff-debuff
  - Signature command model: `signature_a`, `signature_b`, `signature_c`, `ultimate`
  - Full roster support: 16 fighters have runtime Signature A/B/C + Ultimate coverage

# Hand Feel Optimization Tasks (V1)

## Goal
Fix current gameplay "odd feel" issues through ordered runtime improvements with automated regression after every task.

## Ordered Task List

- [x] Task 1: Stabilize hitstop timing manager.
  - Scope:
    - Replace overlapping async `Engine.time_scale` hitstop calls with a deterministic manager.
    - Ensure chained hits cannot leave game speed in an incorrect state.
  - Gate:
    - `just test` passes.

- [x] Task 2: Add visible skill entities + combat state UI.
  - Scope:
    - Add runtime visuals/telegraphs for projectile/trap/summon entities.
    - Add HUD visibility for Hype, signature cooldowns, and key debuff states.
  - Gate:
    - `just test` passes.

- [x] Task 3: Improve control reliability (facing lock + input leniency).
  - Scope:
    - Lock facing during active attack lifecycle (except explicit movement effects).
    - Add command leniency for directional specials and ultimate chord input.
  - Gate:
    - `just test` passes.

- [x] Task 4: Improve motion/animation feel.
  - Scope:
    - Add movement acceleration/deceleration transitions.
    - Improve attack phase-to-animation alignment where possible.
  - Gate:
    - `just test` passes.

- [x] Task 5: Improve AI variety + roster expression.
  - Scope:
    - Expand AI attack selection beyond repeated light strings.
    - Add character-profiled behavior tendencies.
  - Gate:
    - `just test` passes.

## Execution Rule
Complete tasks strictly in order and run automated tests after each task before proceeding.

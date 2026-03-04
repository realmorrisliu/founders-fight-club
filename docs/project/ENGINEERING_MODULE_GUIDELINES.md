# Engineering Module Guidelines

## 1. Purpose
Define a stable module structure and quality baseline for Godot gameplay code so new features do not create a new monolith.

This document is implementation-facing and should be used as a merge gate reference.

## 2. Target Structure

```text
scripts/
  config/
    SessionKeys.gd
    CharacterCatalog.gd
    StageConfig.gd
    LocalizationRegistry.gd
  player/
    PlayerData.gd
    GeneratedSkillProfiles.gd
    PlayerSignatureAttackBuilder.gd
    PlayerAttackRuntimeBuilder.gd
  Player.gd
  Match.gd
  Menu.gd
  Hud.gd
```

## 3. Responsibility Rules

- `scripts/config/*`
  - Read-only constants and registries.
  - No scene/node traversal.
  - No runtime side effects.
- `scripts/player/*`
  - Pure gameplay data and pure builder logic.
  - Prefer `static func` APIs.
  - Return defensive copies for mutable containers (`duplicate(true)`).
- `Player.gd`
  - Runtime state owner and orchestration layer only.
  - Keep complex data transformation in `scripts/player/*`.
  - Thin wrappers are allowed for compatibility.
- `Match.gd`, `Menu.gd`, `Hud.gd`
  - Scene-level flow and presentation wiring.
  - Do not store large static data tables.

## 4. Dependency Direction

- Allowed:
  - Scene scripts -> `player/*`, `config/*`
  - `player/*` -> `config/*` (if needed)
- Not allowed:
  - `config/*` -> scene scripts
  - Cross-scene direct coupling (`Menu.gd` importing `Match.gd`, etc.)
  - Cyclic dependencies between `player/*` modules

If a module needs warnings/logging, inject a target object instead of hard-coding scene dependencies.

## 5. Naming and Typing

- File and class names: `PascalCase` (for `.gd` classes and `.tscn` scenes).
- Input actions and session keys: `snake_case`.
- Constants: `UPPER_SNAKE_CASE`.
- Public APIs and internal helpers should use explicit return types where practical.
- Keep dictionaries schema-stable; add defaults when reading optional fields.

## 6. Split Thresholds (When to Extract)

Extract code into a module when any condition is met:

- A script exceeds 1200 lines.
- A function exceeds 80 lines.
- One function handles more than one concern (for example: loading + transforming + validating).
- The same logic appears in at least 2 places.
- Data tables exceed 80 lines in a scene script.

Preferred extraction order:
1. Constants/registry -> `config/*`
2. Static data tables -> `player/*Data*.gd`
3. Pure transformation/validation -> `player/*Builder*.gd`
4. Scene orchestration remains in scene script

## 7. Data Contract Safety

- Treat attack table entries as contracts.
- Always sanitize runtime attack dictionaries before use.
- Ensure fallback defaults for required base attacks (`light`, `heavy`, `special`, `throw`).
- Keep directional variants generated from a single source of truth.

## 8. Testing Gate

Required before merge:

1. `./scripts/test.sh smoke`
2. `./scripts/test.sh full` for structural refactors

For logic added in `player/*`:

- Add or extend regression checks in `tests/TestRunner.gd`.
- Prefer behavior assertions over implementation assertions.

## 9. Change Workflow

1. Introduce new module with focused API.
2. Keep old callsite via thin wrapper in scene script.
3. Move logic behind wrapper.
4. Run smoke/full tests.
5. Remove dead code only after tests pass.

## 10. Done Criteria for Refactor PRs

- No behavior regression in smoke/full suites.
- New module has single responsibility.
- Scene script line count is reduced or complexity is lowered.
- No new cyclic dependencies.
- Docs index updated when new project-level docs are added.

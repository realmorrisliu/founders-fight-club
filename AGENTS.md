# Repository Guidelines

Founders Fight Club is a Godot 4.5.1 Smash-style platform fighter. There is one ruleset: percent damage, knockback that scales with percent, stocks, ring-outs, platforms, air jumps, and ledges. Do not add an HP-bar or duel ruleset, and do not reintroduce a mode switch between them.

`docs/archive/MVP.md` and `docs/plan/SMASH_ALIGNMENT_AND_FIX_PLAN.md` are superseded. They describe an older duel prototype and a migration plan. Current rules and commands are this file and the README.

## Project Structure & Module Organization

- `project.godot` holds the Godot project configuration and input mappings. `run/main_scene` is `scenes/Menu.tscn`. The feature tag is `4.5`.
- `scenes/` contains `.tscn` scenes. `Menu.tscn` is the entry. `Main.tscn`, `Story.tscn`, and `Training.tscn` are matches driven by `scripts/Match.gd`.
- `scripts/` contains gameplay and systems. `Match.gd` owns round flow, stocks, ring-outs, camera, and training drills. `Player.gd` owns movement, combat, knockback, and percent damage. `Hud.gd` and `Menu.gd` own UI.
- `tests/TestRunner.gd` is the headless test suite.
- `assets/` holds sprites, audio, character data, and art-direction inputs.
- `i18n/en.tres` and `i18n/zh.tres` are the English and Chinese UI strings.
- `icon.svg` is the project icon.

Damage percent is `100 - current_hp`. A real match spends a stock on ring-out or when health reaches 0. Training (`training_scene_enabled`) uses the same movement rules but resets the drill instead of spending stocks. The free-practice drill id `duel_core` is a historical name, not a second ruleset.

## Build, Test, and Development Commands

- Engine: Godot 4.5.1, pinned in `GODOT_VERSION`. Godot 4.2 cannot parse the tests.
- Run locally: `just run`, `./scripts/godot.sh run`, or open the project in Godot 4.5.1 and press `F5` (starts `scenes/Menu.tscn`).
- For real-window scene capture on macOS, use `./scripts/godot.sh run-scene-attached <scene_path>`. Plain `run-scene` detaches on macOS.
- Headless tests, full suite: `bash scripts/test.sh full`
- Headless tests, smoke subset: `bash scripts/test.sh` or `just test`
- The test script downloads the official 4.5.1 build into `.godot-bin/` when needed. `GODOT_BIN` must be a 4.5.1 executable if you set it.
- CI (`.github/workflows/test.yml`) runs `bash scripts/test.sh full` on pull requests and on pushes to `main`.
- Headless matches: `bash scripts/ffc.sh --help` or `just ffc`. The verification skill is `.cursor/skills/verify-ffc/SKILL.md`.
- Exports: use the Godot editor export presets for Windows/macOS/Linux when ready.

## Coding Style & Naming Conventions

- GDScript: follow existing file style (tabs for indentation, 1 tab per block).
- Files: use `PascalCase` for scenes and scripts (e.g., `Player.tscn`, `Player.gd`).
- Input actions: use `snake_case` (e.g., `attack_light`, `move_left`) to match `project.godot`.
- Keep identifiers descriptive and gameplay-focused; prefer short verbs for actions.

## Testing Guidelines

- `tests/TestRunner.gd` runs under a headless Godot `SceneTree`. `bash scripts/test.sh` defaults to the smoke suite. `bash scripts/test.sh full` runs smoke plus skill, AI, and roster coverage.
- The script fails if Godot reports a script parse or load error, even when the process exit code is otherwise easy to miss.
- When a rules or HUD change removes a behavior, delete or rewrite the tests that only covered that behavior. Say which tests changed in the pull request.
- Platform dodge, air jump, ledge, shield, knockback growth, and DI stay covered without a duel profile.

## Commit & Pull Request Guidelines

- Commit messages follow a short, sentence-style summary (e.g., “Add image to README.md”).
- Keep commits focused; separate content, code, and config changes when possible.
- PRs should include: a brief description, linked issue (if any), and screenshots/GIFs for visual changes.

## Localization & Configuration Notes

- Game UI must support English and Chinese; keep README and comments in English.
- Player-facing strings belong in `i18n/en.tres` and `i18n/zh.tres`. Avoid new hard-coded gameplay UI copy.

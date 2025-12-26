# Repository Guidelines

## Project Structure & Module Organization
- `project.godot` holds the Godot project configuration and input mappings.
- `scenes/` contains `.tscn` scenes (e.g., `scenes/Main.tscn` as the entry scene).
- `scripts/` contains GDScript files for gameplay and systems (e.g., `scripts/Main.gd`).
- `assets/` does not exist yet; add it for sprites, audio, and UI as the prototype grows.
- `icon.svg` is the project icon; keep vector sources here when available.

## Build, Test, and Development Commands
- Run locally: open the project in the Godot editor and press `F5` to play the main scene.
- Exports: use the Godot editor export presets for Windows/macOS/Linux when ready.
- No CLI build/test commands are defined yet; add them here if tooling is introduced.

## Coding Style & Naming Conventions
- GDScript: follow existing file style (tabs for indentation, 1 tab per block).
- Files: use `PascalCase` for scenes and scripts (e.g., `Player.tscn`, `Player.gd`).
- Input actions: use `snake_case` (e.g., `attack_light`, `move_left`) to match `project.godot`.
- Keep identifiers descriptive and gameplay-focused; prefer short verbs for actions.

## Testing Guidelines
- No automated tests are configured yet.
- If tests are added, document the framework, coverage expectations, and how to run them.

## Commit & Pull Request Guidelines
- Commit messages follow a short, sentence-style summary (e.g., “Add image to README.md”).
- Keep commits focused; separate content, code, and config changes when possible.
- PRs should include: a brief description, linked issue (if any), and screenshots/GIFs for visual changes.

## Localization & Configuration Notes
- Game UI must support English and Chinese; keep README and comments in English.
- Avoid hard-coded strings in gameplay scripts once localization is introduced.

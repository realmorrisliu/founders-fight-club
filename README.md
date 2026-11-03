# Founders Fight Club

Founders Fight Club is a 2D pixel-art Smash-style platform fighter set in a Silicon Valley founders brawl. The goal is a multi-platform release (including Steam) with gamepad support, and possible online versus later. UI is bilingual (Chinese and English).

## Rules

There is one ruleset:

- Damage is shown as a percent. It is still stored as remaining health, so percent is `100 - current health`.
- Knockback grows as that percent rises. Directional influence can bend the launch.
- Leaving a blast zone, or being reduced to 0 health, spends a stock. The match ends when a fighter has no stocks left.
- On timeout, the fighter with more stocks wins. If stocks are tied, the fighter with the lower percent wins.
- Side platforms, air jumps, ledges, and platform drop-through are always available. There are no side walls and no HP-bar win condition.

Training uses the same movement and damage rules in a sandbox. Ring-outs and KOs reset the current drill instead of spending stocks. The free-practice drill id is still `duel_core`. That name is historical and does not select another ruleset. The HUD label is "Free Practice" / "自由练习".

## Direction

- 2D pixel art
- Local versus and versus CPU, plus training and a story sequence
- Multi-platform with gamepad support
- Smash-style platform fighter, not a traditional HP-bar duel

## Controls (Draft)

- Move: WASD or Arrow Keys, Gamepad D-pad or Left Stick
- Jump: Space, Gamepad X
- Light Attack: J, Gamepad A
- Heavy Attack: K, Gamepad B
- Special: I, Gamepad Right Shoulder (RB)
- Throw: U, Gamepad Left Shoulder (LB)
- Dash: L, Gamepad Y
- Block: H (hold), Gamepad Left Trigger (LT)
- Pause: Esc, Gamepad Start

The second fighter is CPU-controlled unless the match is local versus.

## Tech

- Godot 4.5.1

The version is pinned in `GODOT_VERSION`, in `project.godot` (`config/features` includes `4.5`), and in CI. Godot 4.2 cannot parse the test suite (`is not` in `tests/TestRunner.gd`). The full suite passes headless on 4.5.1. CI used to install an unpinned Godot with Homebrew.

## CLI

- Run game: `just run` or `./scripts/godot.sh run`
- Keep Godot attached to terminal output: `GODOT_ATTACH=1 just run`
- Open editor: `just editor`
- Run scene: `just run-scene "res://scenes/Main.tscn"`
- Headless tests, full suite: `bash scripts/test.sh full`
- Headless tests, smoke subset: `bash scripts/test.sh` or `just test`
- Equivalent full suite via just: `just test full`

`bash scripts/test.sh full` is the command to run. It downloads the official Godot 4.5.1 build into `.godot-bin/` when that binary is not already present, then runs `tests/TestRunner.gd` headless. Set `GODOT_BIN` only if it points at another Godot 4.5.1 executable.

CI is `.github/workflows/test.yml`. It runs the same command on pull requests and on pushes to `main`.

## Roadmap

- Keep the Smash match loop (movement, hit, stock, ring-out) playable end to end
- Core pixel characters and stage
- Single-player content
- Optional: online versus prototype

## Pixel Asset Pipeline (Current)

- Character runtime animation source: `assets/sprites/player/PlayerSpriteFrames.tres`
- Required animation names: `idle`, `walk`, `jump`, `light`, `heavy`, `special`, `throw`, `block`, `hit_light`, `hit_heavy`, `hit`, `fall`, `getup`, `ko`
- If any animation is missing, `scripts/Player.gd` uses built-in placeholder pixel frames as fallback
- First-pass real frame files are in `assets/sprites/player/first_pass/` and are now active for all required animations (including block/hit-react/knockdown/getup)
- Pixel stage and HUD textures are active from `assets/sprites/arena/` and `assets/sprites/ui/`

## AI Asset Workflow

- The repository no longer includes the old manifest/API-key image generation pipeline.
- Reusable creative inputs for direct image generation live under `assets/art_direction/`.
- Current runtime-facing guidance lives in `docs/art/ART_PIPELINE.md`.

<img width="800" height="800" alt="image" src="https://github.com/user-attachments/assets/f50265ab-67dd-47fc-8af7-55a8c1ae7fac" />

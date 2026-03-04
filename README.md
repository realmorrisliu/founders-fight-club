# Founders Fight Club

Founders Fight Club is a 2D pixel-art fighting game prototype set in a Silicon Valley founders brawl. The goal is multi-platform release (including Steam) with gamepad support, and possible online versus in the future. The game itself will support bilingual UI (Chinese and English).

## Direction
- 2D pixel art
- Single-player (future online support)
- Multi-platform with gamepad support
- Start as a small prototype

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

Note: The second fighter is AI-controlled in the current prototype.

## Tech
- Godot 4.2

## CLI
- Run game: `just run`
- Open editor: `just editor`
- Run scene: `just run-scene "res://scenes/Main.tscn"`
- Run automated tests: `just test`
- CI smoke tests: `.github/workflows/test.yml` (runs on PR and push to `main`)

## Roadmap
- Prototype loop (move, attack, hit, win/lose)
- Core pixel characters and stage
- Single-player content
- Optional: online versus prototype

## Pixel Asset Pipeline (Current)
- Character runtime animation source: `assets/sprites/player/PlayerSpriteFrames.tres`
- Required animation names: `idle`, `walk`, `jump`, `light`, `heavy`, `special`, `throw`, `block`, `hit_light`, `hit_heavy`, `hit`, `fall`, `getup`, `ko`
- If any animation is missing, `scripts/Player.gd` uses built-in placeholder pixel frames as fallback
- First-pass real frame files are in `assets/sprites/player/first_pass/` and are now active for all required animations (including block/hit-react/knockdown/getup)
- Pixel stage and HUD textures are active from `assets/sprites/arena/` and `assets/sprites/ui/`

## AI Asset Automation (Current)
- Manifest: `assets/pipeline/asset_manifest.csv`
- Character briefs: `assets/pipeline/character_briefs/*.yaml`
- Generator script: `scripts/tools/auto_generate_assets.py`
- Current default route in repository: `doubao45` (base generation) and `doubao45->gpt15` (refinement path)

### Quick Start
```bash
python3 scripts/tools/auto_generate_assets.py --dry-run --status queued --limit 10 --verbose
```

For full setup and operating workflow, see:
- `docs/art/AI_AUTOMATION_WORKFLOW.md`
- `docs/art/AI_ART_TEMPLATE_PACK.md`
- `docs/art/AI_ASSET_WORKFLOW.md`

<img width="800" height="800" alt="image" src="https://github.com/user-attachments/assets/f50265ab-67dd-47fc-8af7-55a8c1ae7fac" />

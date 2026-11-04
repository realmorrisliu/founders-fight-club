# HUD

The match HUD is the corners layout. P1 is the top-left block. P2 is the top-right block. The timer is centred. A big percent sits on each block, with stock icons under it.

## Sub-features

- `hud-percent` shows damage percent, white at rest and red when it is high.
- `hud-stocks` shows the remaining stocks as icons.
- `hud-secondary` hides hype, cooldowns, shield, and item charges while they are at rest.

## How to get to it (user POV)

- Start Local VS, Story, or Training. The corner blocks are already on the match.
- There is no layout switch.

## Driving it with ffc.sh

Preconditions:

- `bash scripts/ffc.sh doctor` prints `ok=1`.
- Screenshot capture uses `--render xvfb`. `--render headless` does not write a PNG.

- **Neutral.** Run `bash scripts/ffc.sh --render xvfb replay --replay scripts/driver/examples/heavy.json --screenshots 12 --screenshot-dir /tmp/ffc-hud-neutral --out /tmp/ffc-hud-neutral.jsonl`. Exit code is 0. `/tmp/ffc-hud-neutral/frame_0012.png` shows both names, `0%`, three stock icons, and the centred timer. The bottom-left layout name is absent.
- **Heavy hit.** Run `bash scripts/ffc.sh --render xvfb run --replay scripts/driver/examples/heavy.json --setup-p2-percent 70 --screenshots 34 --screenshot-dir /tmp/ffc-hud-hit --out /tmp/ffc-hud-hit.jsonl`. Frame 34 has P2 percent above 60. The PNG shows that percent in a hot colour.
- **One stock lost.** Run `bash scripts/ffc.sh --render xvfb run --seed 11 --mode local --stocks 2 --frames 120 --p2-control script --input scripts/driver/examples/walk-right.json --screenshots 110 --screenshot-dir /tmp/ffc-hud-stock --out /tmp/ffc-hud-stock.jsonl`. Frame 110 has P2 `stocks` 1 and `phase` `fight`.
- **Pause.** Run `bash scripts/ffc.sh --render xvfb run --seed 11 --mode local --frames 30 --input scripts/driver/examples/pause.json --screenshots 12 --screenshot-dir /tmp/ffc-hud-pause --out /tmp/ffc-hud-pause.jsonl`. Frame 12 has `paused` true. The pause panel is visible and does not cover the corner blocks.

## Gotchas

- The corner block ends at y 140. The result chip starts at y 168. The training panel starts at y 144.
- A resting fighter hides the secondary line. Item charges that start above zero still show.
- The six seed-11 logs do not include the HUD. Their hashes stay the values in `tests/TestRunner.gd`.

# Result banner

When the match ends, a banner shows the winner under the timer and clear of the corner blocks.

## Sub-features

- `banner-place` keeps the result chip below the corner blocks.
- `banner-show` shows the winner after the last stock.
- `banner-shot` captures that banner from a virtual display.

## How to get to it (user POV)

- Finish a Local VS match. The winner line appears under the timer.
- This file ends the match by walking P2 off the stage on their last stock.

## Driving it with ffc.sh

Preconditions:

- `bash scripts/ffc.sh doctor` prints `ok=1`.
- Screenshot capture uses `--render xvfb`. `--render headless` does not write a PNG.

- **End the match.** Run `bash scripts/ffc.sh run --seed 3 --mode local --stocks 1 --frames 140 --p2-control script --input scripts/driver/examples/walk-right.json --screenshots 112 --screenshot-dir /tmp/ffc-banner --out /tmp/ffc-banner.jsonl`. A frame has `phase` `ended` and `winner` `p1_win`.
- **Capture the banner.** Run `bash scripts/ffc.sh --render xvfb run --seed 3 --mode local --stocks 1 --frames 140 --p2-control script --input scripts/driver/examples/walk-right.json --screenshots 112 --screenshot-dir /tmp/ffc-banner --out /tmp/ffc-banner-shot.jsonl`. `/tmp/ffc-banner/frame_0112.png` exists and shows the winner line below the timer.

## Gotchas

- The result chip is placed at y 168 to 214. The corner blocks end at y 140.
- On `Training.tscn` the training panel occupies y 144 to 392. That rectangle intersects the result chip. Training does not show a match result today, so the overlap is not reachable. Do not treat a training screenshot as the versus banner proof.
- Headless runs can still write the state log. They do not write the PNG.

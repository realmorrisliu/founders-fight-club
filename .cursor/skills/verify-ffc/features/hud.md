# HUD prototypes

A match can draw one of three HUD prototypes. The debug readout stays in place until a prototype id is set. The id is dev-only. It does not change the state log.

## Sub-features

- `hud-cards` draws a bottom-row card for each fighter.
- `hud-corners` draws a compact block in each top corner.
- `hud-marquee` draws a warm band along the bottom.
- `hud-reject` refuses an unknown id.

## How to get to it (user POV)

There is no menu control. Pass `--hud cards`, `--hud corners`, or `--hud marquee` to the match driver.

## Driving it with ffc.sh

Preconditions:

- `bash scripts/ffc.sh doctor` prints `ok=1`.
- Screenshot capture uses `--render xvfb`.

- **Cards.** Run `bash scripts/ffc.sh --render xvfb run --hud cards --seed 11 --mode local --frames 20 --screenshots 12 --screenshot-dir /tmp/ffc-hud-cards --out /tmp/ffc-hud-cards.jsonl`. The run exits 0. `/tmp/ffc-hud-cards/frame_0012.png` shows the bottom cards, the timer, and the `cards` tag.
- **Reject.** Run `bash scripts/ffc.sh run --hud nope --seed 11 --mode local --frames 2 --out /tmp/ffc-hud-nope.jsonl`. Exit code is 1. Stdout contains `hud must be cards, corners, or marquee`.

## Gotchas

- The same six seed-11 replays, without `--hud`, keep their logged hashes. The switch is read before the log and is not written into it.
- A resting fighter hides hype, cooldowns, a full shield, and an empty item. Those lines come back when the value is live.
- The result banner, the pause panel, and the dialogue bar stay on the debug layout and stay above the prototype.

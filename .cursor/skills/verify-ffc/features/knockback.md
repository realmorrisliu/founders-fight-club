# Knockback

A heavy hit adds percent and moves the fighter who was hit. Higher starting percent travels farther.

## Sub-features

- `knockback-replay` runs the committed heavy replay.
- `knockback-growth` compares that same hit at 0% and at 50%.
- `knockback-range` rejects a setup percent outside 0 to 100.

## How to get to it (user POV)

- Start Local VS, stand the fighters close together, and press heavy (K, or the heavy action).
- This file drives that hit from the replay instead of the menu.

## Driving it with ffc.sh

Preconditions:

- `bash scripts/ffc.sh doctor` prints `ok=1`.
- `scripts/driver/examples/heavy.json` is the replay object. It is not an input array.

- **Replay the heavy.** Run `bash scripts/ffc.sh replay --replay scripts/driver/examples/heavy.json --out /tmp/ffc-knockback-0.jsonl`. Exit code is 0. P2 starts at percent 0. After the heavy, P2 percent is above 0 and P2 `x` is greater than it was on the frame before `hitstun`.
- **Same hit at 50%.** Run `bash scripts/ffc.sh run --replay scripts/driver/examples/heavy.json --setup-p2-percent 50 --out /tmp/ffc-knockback-50.jsonl`. P2's peak distance during `hitstun` is larger than the 0% replay.
- **Reject 150%.** Run `bash scripts/ffc.sh run --replay scripts/driver/examples/heavy.json --setup-p2-percent 150 --out /tmp/ffc-knockback-150.jsonl`. Exit code is 1. Stdout contains `setup percent must be from 0 to 100`. No state log is the proof.

## Gotchas

- `--input` on `heavy.json` reads only the `inputs` array. `replay --replay` reads the whole object, including seed, characters, and setup.
- Percent 100 is legal and means 0 hp. A fighter already at 0 hp ignores the next hit, so that replay does not show a longer launch.
- Hitstun can end while the fighter is still sliding. Measure travel from the frame before `hitstun`, through the frames where `hitstun` is above 0.

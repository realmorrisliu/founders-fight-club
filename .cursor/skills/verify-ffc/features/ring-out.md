# Ring-out

Leaving the blast zone spends one stock and respawns that fighter. The last stock ends the match.

## Sub-features

- `ring-out-stock` spends one stock and returns the fighter to the spawn point.
- `ring-out-last` ends the match when the last stock is spent.

## How to get to it (user POV)

- Start Local VS and walk off the side of the stage, or get launched past the blast zone.
- This file walks P2 off the right side with a script.

## Driving it with ffc.sh

Preconditions:

- `bash scripts/ffc.sh doctor` prints `ok=1`.
- `scripts/driver/examples/walk-right.json` holds `move_right` for P2 from frame 0.

- **Spend one stock.** Run `bash scripts/ffc.sh run --seed 3 --mode local --frames 140 --p2-control script --input scripts/driver/examples/walk-right.json --out /tmp/ffc-ring.jsonl`. P2 `x` passes 950 while stocks are still 3. The next frame has stocks 2 and P2 `x` back near 570. `phase` stays `fight`.
- **Last stock.** Run `bash scripts/ffc.sh run --seed 3 --mode local --stocks 1 --frames 140 --p2-control script --input scripts/driver/examples/walk-right.json --out /tmp/ffc-ring-last.jsonl`. The ending frame has `phase` `ended`, `winner` `p1_win`, and P2 `stocks` 0.

## Gotchas

- The stock drop is checked after the physics step. The out-of-bounds position and the respawn are on neighboring frames.
- Training resets a ring-out instead of spending a stock. Use `mode local` for this proof.
- A fighter at 0 hp also spends a stock. That path is a damage KO, not this blast-zone proof.

# Training mode

Training opens a match with the round timer off and a dummy on the other side. Ring-outs reset the drill instead of spending a stock.

## Sub-features

- `training-open` reaches Training from the menu.
- `training-dummy` keeps P2 out of the CPU brain.
- `training-timer` leaves the round clock unchanged.

## How to get to it (user POV)

- On a fresh profile, choose Modern or Classic, then choose Training.
- Guided Start also enters training. This file covers the Training button.

## Driving it with ffc.sh

Preconditions:

- `bash scripts/ffc.sh doctor` prints `ok=1`.

- **Open training.** Choose Modern, then Training. Run `bash scripts/ffc.sh ui --press first-launch-modern --press training --out /tmp/ffc-training-ui.json`. `scene` is `Training`, `match_mode` is `training`, `timer_enabled` is false, and `p2_is_ai` is false.
- **Dummy stands.** Run `bash scripts/ffc.sh run --seed 1 --mode training --frames 30 --out /tmp/ffc-training.jsonl`. Across the log, `timer_enabled` is false, `time_left` stays 60, both `is_ai` values are false, and `stock_count` is 3. P2 does not walk toward P1.

## Gotchas

- Training P2 is a dummy. `p2-control cpu` does not turn on the story CPU while the dummy is active. A log that only shows `mode cpu` is not this feature.
- The drill id `duel_core` is the free-practice drill. It is not a second ruleset.
- Stocks are still displayed. Leaving the stage in training resets the drill instead of ending a versus stock.

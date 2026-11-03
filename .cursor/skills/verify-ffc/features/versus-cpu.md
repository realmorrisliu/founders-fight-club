# Versus and CPU

Local versus starts a stock match between two human fighters. The CPU brain is the same opponent AI Story uses. The Versus button does not turn it on.

## Sub-features

- `versus-open` starts a human-versus-human match from the menu.
- `versus-script` moves a fighter from a replay and records positions.
- `cpu-approach` makes the CPU close distance, attack, and shield.
- `cpu-recover-near` brings a CPU back from just off the side of the stage.
- `cpu-recover-deep` shows whether a CPU under the stage saves the stock.

## How to get to it (user POV)

- On a fresh profile, choose Modern or Classic, then choose Versus. P2 is human.
- There is no Versus CPU item. Choosing Story is the menu path that enables a CPU opponent. That path is `story.md`.
- Keyboard: P1 uses WASD and J/K/I/U/L/H. P2 uses the second keyboard layout. Those keys are not how this harness injects input. The harness presses the named actions directly.

## Driving it with ffc.sh

Preconditions:

- `bash scripts/ffc.sh doctor` prints `ok=1`.
- Evidence paths are outside `.ffc-home/`.

- **Open versus.** Choose Modern, then Versus. Run `bash scripts/ffc.sh ui --press first-launch-modern --press versus --out /tmp/ffc-versus-ui.json`. The JSON `steps` include `Versus`, `scene` is `Main`, `match_mode` is `vs`, and both `p1_is_ai` and `p2_is_ai` are false.
- **Script a walk.** Run `bash scripts/ffc.sh run --seed 7 --mode local --frames 40 --p1 elon_mvsk --p2 mark_zuck --input scripts/driver/examples/walk-right.json --out /tmp/ffc-walk.jsonl`. P2 `x` increases across frames and `on_floor` becomes true after the opening fall.
- **CPU approaches and shields.** Run `bash scripts/ffc.sh run --seed 8 --mode cpu --frames 240 --p1 elon_mvsk --p2 mark_zuck --setup-p1-x 400 --setup-p1-y 300 --setup-p2-x 460 --setup-p2-y 300 --p1-control script --p2-control cpu --input scripts/driver/examples/cpu-punish.json --out /tmp/ffc-cpu.jsonl`. P2 `is_ai` is true. P2 `x` moves toward P1. Some frames have P2 `state` `attack`. Some frames have P2 `state` `block` or `blocking` true after P1's light attacks.
- **Near-edge recovery.** Run `bash scripts/ffc.sh run --seed 8 --mode cpu --frames 180 --p1 elon_mvsk --p2 mark_zuck --p2-control cpu --setup-p2-x 880 --setup-p2-y 200 --out /tmp/ffc-cpu-near.jsonl`. P2 starts in the air just past the right edge, `stocks` stays 3, and P2 `x` returns onto the stage before the blast zone.
- **Deep offstage.** Run `bash scripts/ffc.sh run --seed 8 --mode cpu --frames 80 --p1 elon_mvsk --p2 mark_zuck --p2-control cpu --setup-p2-x 900 --setup-p2-y 460 --out /tmp/ffc-cpu-deep.jsonl`. P2 falls, `stocks` drops, and P2 respawns at the spawn point. Do not call that a recovery.

## Gotchas

- `mode cpu` is the AI brain on the versus scene. It is not what the Versus button does. A log with `p2_is_ai` false does not prove the CPU.
- The CPU shields when the opponent is actually attacking nearby. An idle P1 produces approaches and attacks, not shields.
- Horizontal chase continues in the air, so a CPU just off the ledge can land back on stage. A CPU dropped below the stage falls into the blast zone. There is no separate jump-to-ledge recovery in that log.
- Story replaces the selected P2 with the roster rival. Use `mode cpu` when the test must keep the character named in `--p2`.

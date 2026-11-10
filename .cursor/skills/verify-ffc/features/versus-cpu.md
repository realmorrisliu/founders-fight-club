# Versus and CPU

Local versus starts a stock match between two human fighters. The CPU brain is the same opponent AI Story uses. The Versus button does not turn it on. Difficulty is a driver flag, not a menu item. The default is normal.

## Sub-features

- `versus-open` starts a human-versus-human match from the menu.
- `versus-script` moves a fighter from an input array and records positions.
- `cpu-approach` makes the CPU close distance, attack, and shield.
- `cpu-recover-near` brings a CPU back from just off the side of the stage.
- `cpu-recover-deep` brings a CPU back from below the stage with a jump and an air dodge.
- `cpu-edgeguard` has the CPU stand inside the lip and hit a fighter hanging on the ledge.
- `cpu-platform` puts a CPU on a side platform during a CPU-versus-CPU match.

## How to get to it (user POV)

- On a fresh profile, choose Modern or Classic, then choose Local VS. The press id is `versus`. P2 is human.
- There is no Versus CPU item. Choosing Story is the menu path that enables a CPU opponent. That path is `story.md`.
- Keyboard: P1 uses WASD and J/K/I/U/L/H. P2 uses the second keyboard layout. Those keys are not how this harness injects input. The harness presses the named actions directly.
- Easy, normal, and hard are `--p1-cpu-difficulty` and `--p2-cpu-difficulty`. Omitting them leaves normal.

## Driving it with ffc.sh

Preconditions:

- `bash scripts/ffc.sh doctor` prints `ok=1`.
- Evidence paths are outside `.ffc-home/`.

- **Open versus.** Choose Modern, then Local VS. Run `bash scripts/ffc.sh ui --press first-launch-modern --press versus --out /tmp/ffc-versus-ui.json`. The second step uses press id `versus` and its visible text is `Local VS`. `scene` is `Main`, `match_mode` is `vs`, and both `p1_is_ai` and `p2_is_ai` are false.
- **Script a walk.** Run `bash scripts/ffc.sh run --seed 7 --mode local --frames 40 --p1 elon_mvsk --p2 mark_zuck --input scripts/driver/examples/walk-right.json --out /tmp/ffc-walk.jsonl`. P2 `x` increases across frames and `on_floor` becomes true after the opening fall.
- **CPU approaches and attacks.** Run `bash scripts/ffc.sh run --seed 8 --mode cpu --frames 240 --p1 elon_mvsk --p2 mark_zuck --setup-p1-x 400 --setup-p1-y 300 --setup-p2-x 460 --setup-p2-y 300 --p1-control script --p2-control cpu --input scripts/driver/examples/cpu-punish.json --out /tmp/ffc-cpu.jsonl`. P2 `is_ai` is true. Frame 0 has P2 `state` `attack` at `x` 460.0. Frame 168 has P2 `state` `attack` at `x` 281.3.
- **CPU dodges.** Run the same command with `--seed 4` and `--frames 140`. At frame 125 P1 `state` is `attack` and `attack_phase` is `recovery`. P2 `state` is `dodge` at `x` 418.5.
- **Near-edge recovery.** Run `bash scripts/ffc.sh run --seed 8 --mode cpu --frames 180 --p1 elon_mvsk --p2 mark_zuck --p2-control cpu --setup-p2-x 880 --setup-p2-y 200 --out /tmp/ffc-cpu-near.jsonl`. P2 starts at `x` 879.7, `y` 200.3, `stocks` 3. Frame 28 has P2 `on_floor` true at `x` 808.1 with `state` `walk` and `stocks` 3. The last frame has P2 `on_floor` true at `x` 363.2 and `stocks` 3.
- **Deep recovery.** Run `bash scripts/ffc.sh run --seed 8 --mode cpu --frames 180 --p1 elon_mvsk --p2 mark_zuck --p2-control cpu --setup-p2-x 900 --setup-p2-y 460 --out /tmp/ffc-cpu-deep.jsonl`. Frame 0 has P2 `x` 899.7, `y` 453.7, `vy` -380.0, `state` `air`, `stocks` 3. Frame 25 has `state` `ledge` at `x` 838.0, `stocks` 3. Frame 75 has `on_floor` true at `x` 774.5, `state` `attack`, `stocks` 3. The last frame has `on_floor` true at `x` 449.8 and `stocks` 3.
- **Deeper recovery.** Run the deep command with `--setup-p2-y 480`. Frame 0 has P2 `y` 473.7, `vy` -380.0, `stocks` 3. Frame 25 has `state` `ledge` at `x` 838.0, `stocks` 3. The last frame has `on_floor` true at `x` 449.8 and `stocks` 3. The same height on the left lip (`--setup-p2-x 0`) also keeps 3 stocks.
- **Edgeguard.** Run `bash scripts/ffc.sh run --seed 1 --mode local --frames 70 --p1 elon_mvsk --p2 mark_zuck --p1-control cpu --p2-control script --setup-p1-x 780 --setup-p1-y 300 --setup-p2-x 850 --setup-p2-y 300 --out /tmp/ffc-cpu-edge.jsonl`. P1 `is_ai` is true. Frame 35 has P1 `on_floor` true at `x` 796.1, inside the right lip at 830, `stocks` 3. Frame 13 has P2 `state` `ledge` at `x` 838.0. Frame 57 has P1 `state` `attack`, `action` `light`, `hitbox_active` true, and P2 `percent` 7, `state` `hitstun`, `x` 838.0, `stocks` 3. P1's maximum `x` in the log is 796.1.
- **Platform.** Run `bash scripts/ffc.sh run --seed 3 --mode local --frames 400 --p1 elon_mvsk --p2 mark_zuck --p1-control cpu --p2-control cpu --timer-seconds 60 --out /tmp/ffc-cpu-platform.jsonl`. Frame 332 has P2 `is_ai` true, `on_floor` true, `state` `idle`, `x` 315.2, `y` 251.0, `stocks` 3. That `x` is on the left platform. Standing on the main floor is about `y` 316.
- **Easy still reaches a platform.** Run `bash scripts/ffc.sh run --seed 7 --mode local --frames 400 --p1 elon_mvsk --p2 mark_zuck --p1-control cpu --p2-control cpu --p1-cpu-difficulty easy --p2-cpu-difficulty easy --timer-seconds 60 --out /tmp/ffc-cpu-easy-platform.jsonl`. Frame 378 has P1 `is_ai` true, `on_floor` true, `state` `idle`, `x` 304.2, `y` 251.0, `stocks` 3. That `x` is on the left platform.
- **Difficulty.** Run `bash scripts/ffc.sh run --seed 2 --mode local --frames 40 --p1 elon_mvsk --p2 mark_zuck --p1-control cpu --p2-control cpu --p1-cpu-difficulty hard --p2-cpu-difficulty easy --out /tmp/ffc-cpu-diff.jsonl`. The `hash=` line differs from the same command without the difficulty flags.

## Gotchas

- `mode cpu` is the AI brain on the versus scene. It is not what the Local VS button (`versus`) does. A log with `p2_is_ai` false does not prove the CPU.
- Story runs this same brain. Seed 11 story frame 0 has P2 `character` `mark_zuck` and `is_ai` true, so the story replay hash moves when the brain moves. Heavy, training, pause, and restart do not run it.
- A shield or dodge arrives after the reaction delay. A short light can finish its active frames first. Seed 4 shows a dodge on the recovery of that light, at frame 125.
- An air dodge that is still running inside the ledge-grab box ends so the grab can happen. A spawn at `y` 480 used to fall through that box and lose the stock.
- A CPU dropped under the stage jumps toward the lip and air-dodges inward. Do not read an old log that loses the stock as this brain.
- The CPU will not dash or lunge off the lip on its own. An outward dash that would end past the lip is cancelled.
- Easy, normal, and hard live in one table on `CpuMind`: reaction delay, aggression, and mistake rate. Recovery still aims at the stage on every difficulty. There is no menu control for the table.

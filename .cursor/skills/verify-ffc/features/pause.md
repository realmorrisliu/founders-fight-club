# Pause and rematch

Pause freezes the match. Pause again resumes it. Restart starts the round over at full time and the spawn points.

## Sub-features

- `pause-freeze` stops the clock and the fighters.
- `pause-resume` continues from the frozen clock.
- `rematch` restores spawn positions and a 60 second clock.

## How to get to it (user POV)

- During a match, press Esc or the pause action. The pause panel offers Resume, Restart, and Back to Menu.
- Press pause again to resume.
- Press R, or Restart on the pause panel, to rematch.

## Driving it with ffc.sh

Preconditions:

- `bash scripts/ffc.sh doctor` prints `ok=1`.
- `scripts/driver/examples/pause.json` presses pause at frame 8 and again at frame 18.

- **Freeze and resume.** Run `bash scripts/ffc.sh run --seed 1 --mode local --frames 24 --input scripts/driver/examples/pause.json --out /tmp/ffc-pause.jsonl`. At frame 8, `paused` is true and `time_left` stops changing. P1 `x` stays put. At frame 18, `paused` is false and `time_left` is still that frozen value. Frame 19 is the first frame where `time_left` decreases.
- **Rematch.** Run `bash scripts/ffc.sh run --seed 1 --mode local --frames 20 --input scripts/driver/examples/restart.json --out /tmp/ffc-restart.jsonl`. P1 `x` is past the spawn by frame 11. The frame after `restart` has P1 `x` back at the spawn and `time_left` at 60.

## Gotchas

- Pause is an edge. Holding the button does not toggle every frame. Release it, then press it again to resume.
- The driver writes the state line before `Match._process`. Resume clears `paused` on frame 18. The clock moves on frame 19.
- Restart reloads the match scene. Scripted setup positions from `--setup-p1-x` are not reapplied. The new round uses the scene defaults.
- The pause panel is visible in a `--render xvfb` screenshot. `--render headless` does not write that PNG.

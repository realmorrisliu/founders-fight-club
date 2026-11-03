# Pause and rematch

Pause freezes the match. Fighters, physics, projectiles, CPU, and hitstun stay where they were, and held movement does not slide anyone. The match clock stays put. Pause again resumes from that pose. Restart starts the round over at full time and the spawn points.

## Sub-features

- `pause-freeze` stops the clock and the fighters.
- `pause-resume` continues from the frozen clock and the frozen pose.
- `rematch` restores spawn positions and a 60 second clock.

## How to get to it (user POV)

- During a match, press Esc or the pause action. The pause panel offers Resume, Restart, and Back to Menu.
- Press pause again to resume.
- Press R, or Restart on the pause panel, to rematch.

## Driving it with ffc.sh

Preconditions:

- `bash scripts/ffc.sh doctor` prints `ok=1`.
- `scripts/driver/examples/pause.json` presses pause at frame 8 and again at frame 18.
- `scripts/driver/examples/pause-hold.json` holds `move_right` the whole time, and presses pause at frames 8 and 20.

- **Freeze and resume.** Run `bash scripts/ffc.sh run --seed 1 --mode local --frames 24 --input scripts/driver/examples/pause.json --out /tmp/ffc-pause.jsonl`. Frames 8 through 17 have `paused` true, `time_left` 59.85, and both fighters at the frame-8 pose (`x` 330, `y` 309.8, `vy` 130.6667). Frame 18 has `paused` false and P1 `y` 312.25. Frame 19 is the first clock step, to 59.8333.
- **Held input.** Run `bash scripts/ffc.sh run --seed 11 --mode local --frames 30 --input scripts/driver/examples/pause-hold.json --out /tmp/ffc-pause-hold.jsonl`. Frames 8 through 19 stay `paused` with P1 at `x` 339.8, `y` 309.8, `vx` 130.6667. Frame 20 has `paused` false and P1 `x` 342.25. Frame 29 has P1 `x` 373.4388 and `vx` 220.
- **Rematch.** Run `bash scripts/ffc.sh run --seed 1 --mode local --frames 20 --input scripts/driver/examples/restart.json --out /tmp/ffc-restart.jsonl`. P1 `x` is past the spawn by frame 11. The frame after `restart` has P1 `x` back at the spawn and `time_left` at 60.

## Gotchas

- Pause is an edge. Holding the button does not toggle every frame. Release it, then press it again to resume.
- The driver writes the state line before `Match._process`. Resume clears `paused` on frame 18. The clock moves on frame 19.
- Restart reloads the match scene. Scripted setup positions from `--setup-p1-x` are not reapplied. The new round uses the scene defaults.
- The pause panel is visible in a `--render xvfb` screenshot. `--render headless` does not write that PNG.

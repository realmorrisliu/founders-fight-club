---
name: verify-ffc
description: "Drive Founders Fight Club headlessly and prove a match, menu, or training change from state logs and screenshots. Use when changing combat, rules, HUD, CPU, story, training, or pause, or when asked to verify the game without playing it."
---

# Verify Founders Fight Club

Founders Fight Club is a Godot 4.5.1 platform fighter. The surface a player touches is the Godot window: the main menu, then a match. This skill drives that same game with `scripts/ffc.sh`. There is no long-running server. Each drive is its own process, its own disposable `HOME`, and a fixed 60Hz simulation that does not follow the wall clock.

Read `features/README.md` before a proof, then follow one feature file. Do not report a feature as verified because a different entry point happened to pass.

## Launch

From the repo root:

```bash
bash scripts/ffc.sh doctor
```

Ready means stdout contains `godot=4.5.1` and `ok=1`. The command downloads the pinned Godot into `.godot-bin/` when it is missing. There is no port and no login. A fresh `HOME` has no saved control preset when `XDG_DATA_HOME` is unset or is not an absolute path, so the menu opens on the first-launch control overlay. Godot stores that preset at `user://settings.cfg`. An absolute `XDG_DATA_HOME` wins over the disposable `HOME`. After one command saves the preset there, the next command skips the overlay.

`just ffc` is the same entry. Example: `just ffc doctor`.

## Doctor

Run doctor again whenever a drive fails before the first state line. Check all of these:

- `godot=` starts with `4.5.1` (the value in `GODOT_VERSION`).
- `headless=true` for the default renderer. Screenshot proofs need `--render xvfb` instead.
- `ok=1` and exit code 0.
- The repo root is the current directory. `scripts/ffc.sh` resolves Godot and the project from its own path.

Doctor does not start a match and does not write a state log.

## Drive

`scripts/ffc.sh` is the harness. A match replay is a JSON object. An input sample replaces that side's held buttons from that frame onward. Omit a side to leave it unchanged. Button names are `move_left`, `move_right`, `move_up`, `move_down`, `jump`, `attack_light`, `attack_heavy`, `attack_special`, `throw`, `dash`, `block`, `pause`, and `restart`. Aliases `left`, `right`, `up`, `down`, `light`, `heavy`, and `special` are accepted.

`scripts/driver/examples/heavy.json` is a full replay object. This command runs it as written:

```bash
bash scripts/ffc.sh replay --replay scripts/driver/examples/heavy.json --out /tmp/ffc-heavy-replay.jsonl
```

Setup flags override fields in that replay:

```bash
bash scripts/ffc.sh run \
  --replay scripts/driver/examples/heavy.json \
  --setup-p2-percent 50 \
  --out /tmp/ffc-heavy-50.jsonl
```

`--input scripts/driver/examples/heavy.json` also works, because an input file may be a JSON array or an object that contains `inputs`. The other files in `scripts/driver/examples/` are input arrays.

Modes:

- `local` loads `scenes/Main.tscn`. Both fighters are human unless a control flag says otherwise.
- `cpu` loads the same versus scene and sets P2 `is_ai`. The menu has no Versus CPU button. Story is the user path that fields a CPU.
- `story` loads `scenes/Story.tscn`. P2 is the CPU rival from the story roster.
- `training` loads `scenes/Training.tscn`. The timer is off. P2 is a training dummy, not the story CPU.

Menu clicks, in order, on a fresh profile:

```bash
bash scripts/ffc.sh ui \
  --press first-launch-modern \
  --press story \
  --out /tmp/ffc-ui-story.json
```

`first-launch-classic` is the other overlay button. `advanced` then `control-style` toggles Modern and Classic. `versus` is the Local VS button. `training` is the other route button. A disabled button fails the command. Do not treat a disabled press as a successful click.

The match loop is one physics tick and one process tick per logged frame, launched with Godot `--fixed-fps 60`. Same seed and same inputs must produce byte-identical state logs. Confirm with two runs and `bash scripts/ffc.sh hash <log>`.

## Evidence

Write proof outside `.ffc-home/`. The harness deletes only that disposable home.

- Match proof is the state log plus the stdout `hash=` line. Each line is one frame: `phase`, `winner`, `time_left`, `timer_enabled`, `stock_count`, `paused`, and both players' `x`, `y`, `vx`, `vy`, `percent`, `hp`, `stocks`, `action`, `state`, `on_floor`, `blocking`, `is_ai`, `hitbox_active`.
- Quote the frame numbers and those fields. A green unit test is not a substitute for the log.
- Menu proof is the JSON from `ui`. It must include the button text before and after each press, the scene name, `match_mode`, and `p2_is_ai` when a match loaded.
- Screenshots need a virtual display. `--render headless` does not write PNGs. Use `--render xvfb --screenshots 20,112 --screenshot-dir <dir>`.
- Setup percent must be from 0 to 100. `--setup-p2-percent 150` exits 1 with `setup percent must be from 0 to 100`. A real hit still stops at 0 hp, so play cannot pass 100%. A fighter already at 0 hp ignores further hits.

## Cleanup

`ffc.sh` removes its temporary `HOME` when the process exits. That home lives under `.ffc-home/`. After a failed or finished proof:

```bash
rm -rf .ffc-home
```

Do not delete the `--out` log, the `ui` JSON, or the screenshot directory. Those are the proof.

## Helpers

- `bash scripts/ffc.sh doctor`
- `bash scripts/ffc.sh run ... --out <state.jsonl>`
- `bash scripts/ffc.sh replay --replay scripts/driver/examples/heavy.json --out /tmp/ffc-heavy-replay.jsonl`
- `bash scripts/ffc.sh ui --press <button> --out <ui.json>`
- `bash scripts/ffc.sh hash <state.jsonl>`
- `just ffc <same arguments>`

Input examples used by the feature map live in `scripts/driver/examples/`. Keep the map in `features/` honest when a route changes. `/maintain-verification-skill` is the later pass that checks this map against the game.

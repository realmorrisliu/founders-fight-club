# Founders Fight Club verification map

This directory is the maintained source for verifying player-facing behavior. Read this index, then use the matching feature file.

## Baseline preconditions

- Run from the repo root.
- `bash scripts/ffc.sh doctor` prints `godot=4.5.1` and `ok=1`.
- Each `ffc.sh` process gets a new `HOME` under `.ffc-home/`. That profile is fresh when `XDG_DATA_HOME` is unset or is not an absolute path. Godot keeps the control preset at `user://settings.cfg`. An absolute `XDG_DATA_HOME` keeps that preset across homes. A fresh profile shows the first-launch control overlay and disables Local VS, Story (Auto Rival), and Training Mode until Modern or Classic is chosen.
- Button text quoted in the feature files is the English copy in `i18n/en.tres`. Locales `zh`, `zh_CN`, and `zh_TW` use `i18n/zh.tres`. `scripts/Menu.gd` leaves a locale that begins with `en` or `zh` unchanged. A name such as `zho` still shows the English source strings.
- Pass `--out` and `--screenshot-dir` outside `.ffc-home/`. Cleanup deletes the home and leaves those files.
- The only stage id is `grand_arena`.

## Driving conventions

- Start from the baseline unless the feature file adds a precondition.
- Treat every command as literal.
- Menu presses go through `bash scripts/ffc.sh ui --press ...`.
- Match inputs go through `bash scripts/ffc.sh run` or `replay` and a JSON input file.
- Do not call a disabled menu button a successful entry. The command exits 1 and names the button.
- A match screenshot is the 3D picture from `scripts/picture/StagePicture.gd`. The state log stays 2D pixels on `Node2D` fighters. The stage id stays `grand_arena`. HUD and the screen flash stay canvas layers. Impact sparks and other sprites parented to the match, including projectiles, are drawn on the stage. The fighter aura and the ground-shadow ellipse are not. There is no look switch. Headless hashes do not prove the picture. `--render xvfb` does, and only while `StagePicture/Camera` is current.

## Proof and skip reporting

- Quote frame numbers and state-log fields, or the `ui` JSON fields the feature names.
- A passing unit test does not replace that quote.
- Record which feature file and which entry point produced the artifact.
- If an entry point cannot be reached, report the command and the unmet precondition. Do not substitute a different entry point and call it verified.

## Feature entry contract

Each feature file has an H1, one opening paragraph, then these H2 sections in order: `Sub-features`, `How to get to it (user POV)`, `Driving it with ffc.sh`, `Gotchas`.

## Features

- [Versus and CPU](./versus-cpu.md) covers local versus and the CPU brain the versus menu does not start.
- [Story mode](./story.md) covers the menu path that starts a CPU rival.
- [Training mode](./training.md) covers the dummy and the disabled round timer.
- [Menu and control style](./menu.md) covers the first-launch overlay, routes, and Modern versus Classic.
- [Pause and rematch](./pause.md) covers pause, resume, and restart.
- [Knockback](./knockback.md) covers a heavy hit and how travel grows with percent.
- [Ring-out](./ring-out.md) covers a blast-zone stock loss and respawn.
- [Result banner](./result-banner.md) covers the end-of-match banner under the stat rows.

## Known issues

- On `Training.tscn` the training panel (y 144 to 392) intersects the result chip (y 168 to 214). Training does not show a match result today, so the overlap is not reachable. See [Result banner](./result-banner.md).

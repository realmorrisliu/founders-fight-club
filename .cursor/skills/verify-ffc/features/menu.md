# Menu and control style

The menu picks a control style, then a route. A fresh profile asks for Modern or Classic before the route buttons accept a click.

## Sub-features

- `menu-overlay` requires a first-launch control choice.
- `menu-routes` starts Versus, Story, or Training from that choice.
- `menu-control-style` toggles Modern and Classic from Advanced Setup.

## How to get to it (user POV)

- Launch the game. The first screen that accepts a click is the control overlay: Modern or Classic.
- Then choose Versus, Story, or Training.
- Choose Advanced Setup, then Control Style, to switch Modern and Classic.

## Driving it with ffc.sh

Preconditions:

- `bash scripts/ffc.sh doctor` prints `ok=1`.
- Each command is a new process, so each one starts from the overlay again.

- **Overlay blocks Story.** Run `bash scripts/ffc.sh ui --press story --out /tmp/ffc-menu-blocked.json`. Exit code is 1. Stdout names `story` as disabled.
- **Choose Modern.** Run `bash scripts/ffc.sh ui --press first-launch-modern --out /tmp/ffc-menu-modern.json`. The step `button_text_before` is `Modern`. `scene` stays `Menu`.
- **Toggle control style.** Run `bash scripts/ffc.sh ui --press first-launch-modern --press advanced --press control-style --out /tmp/ffc-menu-style.json`. Steps show `Advanced Setup` becoming `Hide Advanced`, then `Control Style: Modern` becoming `Control Style: Classic`.
- **Route buttons.** After Modern, Versus, Story, and Training are the presses in `versus-cpu.md`, `story.md`, and `training.md`.

## Gotchas

- Control Style stays disabled until Advanced Setup is open. Pressing it immediately after the overlay fails.
- The saved preset lives in that process's `HOME`. The next `ffc.sh` command is a fresh profile and shows the overlay again.
- Button text is the proof. Do not infer the preset from the press name alone.

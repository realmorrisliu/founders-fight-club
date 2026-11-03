# Menu and control style

The menu picks a control style, then a route. A fresh profile asks for Modern or Classic before the route buttons accept a click.

## Sub-features

- `menu-overlay` requires a first-launch control choice.
- `menu-routes` starts Versus, Story, or Training from that choice.
- `menu-control-style` toggles Modern and Classic from Advanced Setup.

## How to get to it (user POV)

- Launch the game. The first screen that accepts a click is the control overlay: Modern or Classic.
- Then choose Local VS, Story (Auto Rival), or Training Mode.
- Choose Advanced Setup, then Control Style, to switch Modern and Classic.

## Driving it with ffc.sh

Preconditions:

- `bash scripts/ffc.sh doctor` prints `ok=1`.
- Each command is a new process. It starts from the overlay again when `XDG_DATA_HOME` is unset or is not an absolute path.

- **Overlay blocks Story.** Run `bash scripts/ffc.sh ui --press story --out /tmp/ffc-menu-blocked.json`. Exit code is 1. Stdout names `story` as disabled.
- **Choose Modern.** Run `bash scripts/ffc.sh ui --press first-launch-modern --out /tmp/ffc-menu-modern.json`. The step `button_text_before` is `Modern`. `scene` stays `Menu`.
- **Toggle control style.** Run `bash scripts/ffc.sh ui --press first-launch-modern --press advanced --press control-style --out /tmp/ffc-menu-style.json`. Steps show `Advanced Setup` becoming `Hide Advanced`, then `Control Style: Modern` becoming `Control Style: Classic`.
- **Route buttons.** After Modern, Versus, Story, and Training are the presses in `versus-cpu.md`, `story.md`, and `training.md`.

## Gotchas

- Control Style stays disabled until Advanced Setup is open. Pressing it immediately after the overlay fails.
- The saved preset lives at `user://settings.cfg`. The next `ffc.sh` command shows the overlay again when `XDG_DATA_HOME` is unset or is not an absolute path. An absolute `XDG_DATA_HOME` keeps the preset, and a later Story press then succeeds.
- Button text is the proof. Do not infer the preset from the press name alone. The strings in this file are English. Locales `zh`, `zh_CN`, and `zh_TW` use `i18n/zh.tres`. A name such as `zho` still shows these English strings.

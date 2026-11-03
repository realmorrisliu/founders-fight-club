# Story mode

Story mode starts a stock match whose second fighter is a CPU rival. Winning or losing a round is still a stock match on the same stage.

## Sub-features

- `story-open` reaches Story from the menu after the control overlay.
- `story-cpu` puts a roster rival under CPU control.
- `story-approach` shows that rival moving and attacking.

## How to get to it (user POV)

- On a fresh profile, choose Modern or Classic on the first-launch overlay, then choose Story (Auto Rival).
- Versus does not start this mode.

## Driving it with ffc.sh

Preconditions:

- `bash scripts/ffc.sh doctor` prints `ok=1`.
- Use a fresh `ffc.sh` process without an absolute `XDG_DATA_HOME` so the first-launch overlay is up.

- **Open story.** Choose Modern, then Story. Run `bash scripts/ffc.sh ui --press first-launch-modern --press story --out /tmp/ffc-story-ui.json`. `steps` shows `Story (Auto Rival)` before the press. After the click, `scene` is `Story`, `match_mode` is `story`, `p2_is_ai` is true, `p1_is_ai` is false, `stocks` is 3, and `timer_enabled` is true.
- **Watch the rival.** Run `bash scripts/ffc.sh run --seed 8 --mode story --frames 180 --p1 elon_mvsk --out /tmp/ffc-story.jsonl`. P2 `character` is `mark_zuck` when P1 is `elon_mvsk` (the first rival that is not P1). P2 `is_ai` is true. P2 `x` changes toward P1 and some frames have `state` `attack` or `dash`.
- **Blocked direct press.** Run `bash scripts/ffc.sh ui --press story --out /tmp/ffc-story-blocked.json`. Exit code is 1 and stdout says `story` is disabled.

## Gotchas

- Story replaces P2 with the roster. `--p2` does not keep an arbitrary character in this mode.
- The round timer still starts at 60 seconds. Story does not switch that off.
- A fresh profile disables Story until the overlay choice. Emitting the button while it is disabled is not the player path, and the harness rejects it.

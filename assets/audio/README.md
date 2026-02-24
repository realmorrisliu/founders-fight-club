# Audio Placeholder Pipeline

Current placeholder combat SFX live in `sfx/`:

- `hit_light.wav`
- `hit_heavy.wav`
- `hit_special.wav`
- `block_light.wav`
- `block_heavy.wav`
- `block_special.wav`
- `counter.wav`
- `combo.wav`
- `tech.wav`

Runtime wiring:

- `scripts/Match.gd` loads these files at startup
- Plays layered SFX for hit/block by attack type (`light`, `heavy`, `special`)
- Plays dedicated SFX for `counter`, combo callouts, and tech recovery

These are placeholders and can be replaced with final SFX while keeping filenames.

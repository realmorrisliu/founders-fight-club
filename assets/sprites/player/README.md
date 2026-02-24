# Player Pixel Pipeline

Use `PlayerSpriteFrames.tres` as the runtime animation source for `Player.gd`.

## Required animation names

- `idle`
- `walk`
- `jump`
- `light`
- `heavy`
- `special`
- `throw`
- `block`
- `hit_light`
- `hit_heavy`
- `hit`
- `fall`
- `getup`
- `ko`

## Recommended setup

1. Keep source frame size consistent (current placeholder baseline is `24x48`).
2. Import sprite textures with:
   - Filter: `Nearest`
   - Mipmaps: `Off`
   - Compression: `Lossless` or uncompressed for crisp pixels
3. Edit `assets/sprites/player/PlayerSpriteFrames.tres` in Godot:
   - Assign frames to each animation listed above.
   - Keep speed/loop defaults unless combat feel tests suggest changes.

## First-pass frames in repo

The project now includes a starter playable set in `assets/sprites/player/first_pass/`:

- `idle_0.png`, `idle_1.png`
- `walk_0.png` ... `walk_3.png`
- `jump_0.png`, `jump_1.png`
- `light_0.png`, `light_1.png`, `light_2.png`
- `heavy_0.png`, `heavy_1.png`, `heavy_2.png`
- `special_0.png`, `special_1.png`, `special_2.png`
- `throw_0.png`, `throw_1.png`, `throw_2.png`
- `block_0.png`, `block_1.png`
- `hit_light_0.png`, `hit_light_1.png`
- `hit_heavy_0.png`, `hit_heavy_1.png`
- `hit_0.png`, `hit_1.png`
- `fall_0.png`, `fall_1.png`
- `getup_0.png`, `getup_1.png`, `getup_2.png`
- `ko_0.png`

These are currently wired into `PlayerSpriteFrames.tres` for all required animations.

## Runtime behavior

- `Player.gd` loads external frames from `PlayerSpriteFrames.tres` by default.
- If an animation is missing or empty, the script falls back to internal placeholder frames.
- You can override with an exported `sprite_frames_resource` per player instance.

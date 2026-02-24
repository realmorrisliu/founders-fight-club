# Assets

Pixel-art assets live here.

- `sprites/player/`: fighter spritesheets and frame sources.
- `sprites/arena/`: stage background and floor textures.
- `sprites/ui/`: HUD and menu sprites.
- `sprites/effects/`: combat impact and guard/counter VFX sprites.
- `audio/`: SFX and BGM.

Player runtime animation resource:

- `sprites/player/PlayerSpriteFrames.tres`

`scripts/Player.gd` loads this resource by default and will fall back to procedural
placeholder frames for any missing animations.

Current player first-pass frames also include block / hit reaction / knockdown flow:

- `sprites/player/first_pass/block_*.png`
- `sprites/player/first_pass/hit_light_*.png`
- `sprites/player/first_pass/hit_heavy_*.png`
- `sprites/player/first_pass/fall_*.png`
- `sprites/player/first_pass/getup_*.png`

Impact effect runtime animation resource:

- `sprites/effects/ImpactSpriteFrames.tres`

Stage/HUD textures now in use:

- `sprites/arena/arena_bg.png`
- `sprites/arena/arena_floor.png`
- `sprites/ui/hp_under.png`
- `sprites/ui/hp_fill_p1.png`
- `sprites/ui/hp_fill_p2.png`
- `sprites/ui/hud_timer_chip.png`
- `sprites/ui/hud_result_chip.png`
- `sprites/ui/hud_pause_panel.png`

Combat placeholder SFX now in use:

- `audio/sfx/hit_light.wav`
- `audio/sfx/hit_heavy.wav`
- `audio/sfx/hit_special.wav`
- `audio/sfx/block_light.wav`
- `audio/sfx/block_heavy.wav`
- `audio/sfx/block_special.wav`
- `audio/sfx/counter.wav`
- `audio/sfx/combo.wav`
- `audio/sfx/tech.wav`

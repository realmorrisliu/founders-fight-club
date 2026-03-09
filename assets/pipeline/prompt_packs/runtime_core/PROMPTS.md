# Runtime Core Art

- Manifest: `assets/pipeline/runtime_asset_manifest.csv`
- Assets: `39`
- Style lock: `assets/pipeline/style_lock.yaml`

Use these prompts either with `scripts/tools/auto_generate_assets.py` or by pasting them into your preferred image model manually.

## grand_arena_stage_background

- Subject: `grand_arena`
- Type: `stage_background`
- Route: `pro`
- Size: `2048x1152`
- Aspect ratio: `16:9`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Founders Grand Arena. Tech-founder fight night staged like a premium broadcast event, not a practice box.
[PROPS] Keep visible cues: full-bleed background architecture, center-stage hero lane, warm floor highlights against cool back-wall light, depth fog and haze around upper lighting rigs.
[PALETTE] Target palette: #08111F, #13345E, #FF8A3D, #3CC7FF.
[TASK] Create a full-bleed 2D fighter stage background plate. Wide cinematic composition, no characters, clear horizon depth, designed to fill the entire 16:9 frame without side gutters. Include stage layers such as towering LED wall with scrolling market-ticker energy, distant crowd glow and camera flashes, structural octagon frame and light rails, rim-lit center lane with reflective floor breakup. Keep visible props: full-bleed background architecture, center-stage hero lane, warm floor highlights against cool back-wall light, depth fog and haze around upper lighting rigs.
[OUTPUT] 2048x1152.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, gray side gutters, blank matte edges, flat practice-room walls, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## grand_arena_stage_floor

- Subject: `grand_arena`
- Type: `stage_floor`
- Route: `pro`
- Size: `2048x1024`
- Aspect ratio: `16:9`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:grand_arena_stage_background`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Founders Grand Arena. Tech-founder fight night staged like a premium broadcast event, not a practice box.
[PROPS] Keep visible cues: full-bleed background architecture, center-stage hero lane, warm floor highlights against cool back-wall light, depth fog and haze around upper lighting rigs.
[PALETTE] Target palette: #08111F, #13345E, #FF8A3D, #3CC7FF.
[TASK] Create the matching arena floor layer for a side-view 2D fighter. Foreground lane, reflective material breakup, rim-lit edges, no characters, perspective aligned with a combat camera and ready to tile/extend horizontally. Keep visible props: full-bleed background architecture, center-stage hero lane, warm floor highlights against cool back-wall light, depth fog and haze around upper lighting rigs.
[OUTPUT] 2048x1024.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, gray side gutters, blank matte edges, flat practice-room walls, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## grand_arena_stage_keyart

- Subject: `grand_arena`
- Type: `stage_keyart`
- Route: `pro`
- Size: `2048x1152`
- Aspect ratio: `16:9`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:grand_arena_stage_background`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Founders Grand Arena. Tech-founder fight night staged like a premium broadcast event, not a practice box.
[PROPS] Keep visible cues: full-bleed background architecture, center-stage hero lane, warm floor highlights against cool back-wall light, depth fog and haze around upper lighting rigs.
[PALETTE] Target palette: #08111F, #13345E, #FF8A3D, #3CC7FF.
[TASK] Create promotional key art for the stage itself. Show the arena as a premium spectacle venue with depth fog, LED architecture, crowd glow, and a readable centerline focal lane. No empty framing voids.
[OUTPUT] 2048x1152.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, gray side gutters, blank matte edges, flat practice-room walls, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## combat_hit_spark_sheet

- Subject: `global`
- Type: `vfx_sheet`
- Route: `nano2`
- Size: `1536x1024`
- Aspect ratio: `3:2`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Global asset. Distinct showpiece game asset.
[TASK] Create a VFX concept sheet for combat impact effects. Show 6 to 9 motifs on a dark neutral backdrop: hit sparks, slash bursts, radial rings, and smoke pops.
[OUTPUT] 1536x1024.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## combat_guard_counter_sheet

- Subject: `global`
- Type: `vfx_sheet`
- Route: `nano2`
- Size: `1536x1024`
- Aspect ratio: `3:2`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Global asset. Distinct showpiece game asset.
[TASK] Create a VFX concept sheet for guard sparks and counter bursts. Show 6 to 9 clean motifs on a dark neutral backdrop: deflection arcs, shield sparks, counter starbursts, and ring impacts.
[OUTPUT] 1536x1024.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## combat_signature_trails_sheet

- Subject: `global`
- Type: `vfx_sheet`
- Route: `nano2`
- Size: `1536x1024`
- Aspect ratio: `3:2`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Global asset. Distinct showpiece game asset.
[TASK] Create a VFX concept sheet for signature trails. Show 6 to 9 motifs on a dark neutral backdrop: afterimage sweeps, aura rings, trap glyphs, dash streaks, and ground scrape traces.
[OUTPUT] 1536x1024.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## combat_ui_panel_pack

- Subject: `global`
- Type: `ui_panel_pack`
- Route: `pro`
- Size: `2048x1152`
- Aspect ratio: `16:9`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:grand_arena_stage_keyart`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Global asset. Distinct showpiece game asset.
[TASK] Create a UI panel pack for a flashy satirical fighter. Include menu panels, HUD chips, choice cards, and pause/result panels on one cohesive sheet. Premium event-broadcast feel, clean edge highlights, minimal clutter.
[OUTPUT] 2048x1152.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## elon_mvsk_sprite_turnaround

- Subject: `elon_mvsk`
- Type: `sprite_turnaround`
- Route: `pro`
- Size: `1536x1536`
- Aspect ratio: `1:1`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Elon Mvsk. Volatile rushdown with social pressure and explosive vertical threat.
[SILHOUETTE] angled_hair, long_dark_coat, rocket_back_glow.
[PROPS] Keep visible cues: phone-like social app device, mini rocket thruster, futuristic EV cue.
[PALETTE] Target palette: #111111, #00AEEF, #FF6A3D.
[RIVAL CONTEXT] Rival hooks: mark_zuck, sam_altmyn.
[TASK] Create a character turnaround sheet for 2D fighter production. Include front 3/4, combat side view, back 3/4, and prop callouts. Keep proportions locked, side-view combat readability high, plain background.
[OUTPUT] 1536x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Tesla logo, exact X logo, exact real UI screenshot, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## elon_mvsk_sprite_keypose_sheet

- Subject: `elon_mvsk`
- Type: `sprite_keypose_sheet`
- Route: `pro`
- Size: `2048x1536`
- Aspect ratio: `4:3`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:elon_mvsk_sprite_turnaround`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Elon Mvsk. Volatile rushdown with social pressure and explosive vertical threat.
[SILHOUETTE] angled_hair, long_dark_coat, rocket_back_glow.
[PROPS] Keep visible cues: phone-like social app device, mini rocket thruster, futuristic EV cue.
[PALETTE] Target palette: #111111, #00AEEF, #FF6A3D.
[RIVAL CONTEXT] Rival hooks: mark_zuck, sam_altmyn.
[TASK] Create a sprite reference key-pose sheet for 2D fighter animation. Include idle, walk contact, walk passing, jump rise, jump apex, light attack, heavy attack, signature attack, block, and hit recoil. Use the character's signature move language such as Signature skill. Orthographic-feeling side-view presentation, plain background, no perspective camera.
[OUTPUT] 2048x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Tesla logo, exact X logo, exact real UI screenshot, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## mark_zuck_sprite_turnaround

- Subject: `mark_zuck`
- Type: `sprite_turnaround`
- Route: `pro`
- Size: `1536x1536`
- Aspect ratio: `1:1`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Mark Zuck. Counter-trap specialist who controls rhythm and corner pace.
[SILHOUETTE] tight_athletic_top, minimal_hair_shape, neon_octagon_ui.
[PROPS] Keep visible cues: holographic ring-ui accents, clone afterimage, threads-like line trap motif.
[PALETTE] Target palette: #1E1E1E, #27D3A2, #7E9BFF.
[RIVAL CONTEXT] Rival hooks: elon_mvsk, sam_altmyn.
[TASK] Create a character turnaround sheet for 2D fighter production. Include front 3/4, combat side view, back 3/4, and prop callouts. Keep proportions locked, side-view combat readability high, plain background.
[OUTPUT] 1536x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Meta logo, exact Threads logo, exact headset product copy, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## mark_zuck_sprite_keypose_sheet

- Subject: `mark_zuck`
- Type: `sprite_keypose_sheet`
- Route: `pro`
- Size: `2048x1536`
- Aspect ratio: `4:3`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:mark_zuck_sprite_turnaround`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Mark Zuck. Counter-trap specialist who controls rhythm and corner pace.
[SILHOUETTE] tight_athletic_top, minimal_hair_shape, neon_octagon_ui.
[PROPS] Keep visible cues: holographic ring-ui accents, clone afterimage, threads-like line trap motif.
[PALETTE] Target palette: #1E1E1E, #27D3A2, #7E9BFF.
[RIVAL CONTEXT] Rival hooks: elon_mvsk, sam_altmyn.
[TASK] Create a sprite reference key-pose sheet for 2D fighter animation. Include idle, walk contact, walk passing, jump rise, jump apex, light attack, heavy attack, signature attack, block, and hit recoil. Use the character's signature move language such as Signature skill. Orthographic-feeling side-view presentation, plain background, no perspective camera.
[OUTPUT] 2048x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Meta logo, exact Threads logo, exact headset product copy, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## sam_altmyn_sprite_turnaround

- Subject: `sam_altmyn`
- Type: `sprite_turnaround`
- Route: `pro`
- Size: `1536x1536`
- Aspect ratio: `1:1`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Sam Altmyn. Adaptive control fighter with read-based conversions.
[SILHOUETTE] tailored_jacket, data_gauntlet, calm_forward_stance.
[PROPS] Keep visible cues: AI-core gauntlet, floating token particles, terminal-like hit flashes.
[PALETTE] Target palette: #202020, #45C3FF, #F4B942.
[RIVAL CONTEXT] Rival hooks: peter_thyell, elon_mvsk, jensen_hwang.
[TASK] Create a character turnaround sheet for 2D fighter production. Include front 3/4, combat side view, back 3/4, and prop callouts. Keep proportions locked, side-view combat readability high, plain background.
[OUTPUT] 1536x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact OpenAI logo, exact ChatGPT icon, exact UI screenshot, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## sam_altmyn_sprite_keypose_sheet

- Subject: `sam_altmyn`
- Type: `sprite_keypose_sheet`
- Route: `pro`
- Size: `2048x1536`
- Aspect ratio: `4:3`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:sam_altmyn_sprite_turnaround`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Sam Altmyn. Adaptive control fighter with read-based conversions.
[SILHOUETTE] tailored_jacket, data_gauntlet, calm_forward_stance.
[PROPS] Keep visible cues: AI-core gauntlet, floating token particles, terminal-like hit flashes.
[PALETTE] Target palette: #202020, #45C3FF, #F4B942.
[RIVAL CONTEXT] Rival hooks: peter_thyell, elon_mvsk, jensen_hwang.
[TASK] Create a sprite reference key-pose sheet for 2D fighter animation. Include idle, walk contact, walk passing, jump rise, jump apex, light attack, heavy attack, signature attack, block, and hit recoil. Use the character's signature move language such as Signature skill. Orthographic-feeling side-view presentation, plain background, no perspective camera.
[OUTPUT] 2048x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact OpenAI logo, exact ChatGPT icon, exact UI screenshot, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## peter_thyell_sprite_turnaround

- Subject: `peter_thyell`
- Type: `sprite_turnaround`
- Route: `pro`
- Size: `1536x1536`
- Aspect ratio: `1:1`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Peter Thyell. Slow but high-reward punish game with turn-steal tools.
[SILHOUETTE] long_formal_coat, cane_shape, heavy_step_pose.
[PROPS] Keep visible cues: cane-like pointer, boardroom sigil overlay, scan ring effect.
[PALETTE] Target palette: #161616, #8B5CF6, #A5A5A5.
[RIVAL CONTEXT] Rival hooks: sam_altmyn.
[TASK] Create a character turnaround sheet for 2D fighter production. Include front 3/4, combat side view, back 3/4, and prop callouts. Keep proportions locked, side-view combat readability high, plain background.
[OUTPUT] 1536x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Palantir logo, exact fund brand marks, real company presentation slides, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## peter_thyell_sprite_keypose_sheet

- Subject: `peter_thyell`
- Type: `sprite_keypose_sheet`
- Route: `pro`
- Size: `2048x1536`
- Aspect ratio: `4:3`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:peter_thyell_sprite_turnaround`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Peter Thyell. Slow but high-reward punish game with turn-steal tools.
[SILHOUETTE] long_formal_coat, cane_shape, heavy_step_pose.
[PROPS] Keep visible cues: cane-like pointer, boardroom sigil overlay, scan ring effect.
[PALETTE] Target palette: #161616, #8B5CF6, #A5A5A5.
[RIVAL CONTEXT] Rival hooks: sam_altmyn.
[TASK] Create a sprite reference key-pose sheet for 2D fighter animation. Include idle, walk contact, walk passing, jump rise, jump apex, light attack, heavy attack, signature attack, block, and hit recoil. Use the character's signature move language such as Signature skill. Orthographic-feeling side-view presentation, plain background, no perspective camera.
[OUTPUT] 2048x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Palantir logo, exact fund brand marks, real company presentation slides, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## zef_bezos_sprite_turnaround

- Subject: `zef_bezos`
- Type: `sprite_turnaround`
- Route: `pro`
- Size: `1536x1536`
- Aspect ratio: `1:1`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Zef Bezos. Zoning setplay with delayed triggers and lane control.
[SILHOUETTE] bomber_jacket, drone_halo, boxy_shoulder_shape.
[PROPS] Keep visible cues: delivery-drone motif, package warning icon, orbital pop trail.
[PALETTE] Target palette: #151515, #FF9900, #49B5FF.
[RIVAL CONTEXT] Rival hooks: elon_mvsk, bill_geytz, jensen_hwang.
[TASK] Create a character turnaround sheet for 2D fighter production. Include front 3/4, combat side view, back 3/4, and prop callouts. Keep proportions locked, side-view combat readability high, plain background.
[OUTPUT] 1536x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Amazon logo, exact Prime logo, exact Blue Origin logo, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## zef_bezos_sprite_keypose_sheet

- Subject: `zef_bezos`
- Type: `sprite_keypose_sheet`
- Route: `pro`
- Size: `2048x1536`
- Aspect ratio: `4:3`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:zef_bezos_sprite_turnaround`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Zef Bezos. Zoning setplay with delayed triggers and lane control.
[SILHOUETTE] bomber_jacket, drone_halo, boxy_shoulder_shape.
[PROPS] Keep visible cues: delivery-drone motif, package warning icon, orbital pop trail.
[PALETTE] Target palette: #151515, #FF9900, #49B5FF.
[RIVAL CONTEXT] Rival hooks: elon_mvsk, bill_geytz, jensen_hwang.
[TASK] Create a sprite reference key-pose sheet for 2D fighter animation. Include idle, walk contact, walk passing, jump rise, jump apex, light attack, heavy attack, signature attack, block, and hit recoil. Use the character's signature move language such as Signature skill. Orthographic-feeling side-view presentation, plain background, no perspective camera.
[OUTPUT] 2048x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Amazon logo, exact Prime logo, exact Blue Origin logo, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## bill_geytz_sprite_turnaround

- Subject: `bill_geytz`
- Type: `sprite_turnaround`
- Route: `pro`
- Size: `1536x1536`
- Aspect ratio: `1:1`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Bill Geytz. Trap-control veteran with system-reset tempo tools.
[SILHOUETTE] retro_sweater_shape, square_glasses, blue_pulse_ring.
[PROPS] Keep visible cues: blue-screen pulse motif, legacy window frame cue, cloud wall effect.
[PALETTE] Target palette: #1C1C1C, #2D7FF9, #B7C7E6.
[RIVAL CONTEXT] Rival hooks: larry_pagyr, steve_jobz.
[TASK] Create a character turnaround sheet for 2D fighter production. Include front 3/4, combat side view, back 3/4, and prop callouts. Keep proportions locked, side-view combat readability high, plain background.
[OUTPUT] 1536x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Microsoft logo, exact Windows logo, exact Copilot icon, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## bill_geytz_sprite_keypose_sheet

- Subject: `bill_geytz`
- Type: `sprite_keypose_sheet`
- Route: `pro`
- Size: `2048x1536`
- Aspect ratio: `4:3`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:bill_geytz_sprite_turnaround`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Bill Geytz. Trap-control veteran with system-reset tempo tools.
[SILHOUETTE] retro_sweater_shape, square_glasses, blue_pulse_ring.
[PROPS] Keep visible cues: blue-screen pulse motif, legacy window frame cue, cloud wall effect.
[PALETTE] Target palette: #1C1C1C, #2D7FF9, #B7C7E6.
[RIVAL CONTEXT] Rival hooks: larry_pagyr, steve_jobz.
[TASK] Create a sprite reference key-pose sheet for 2D fighter animation. Include idle, walk contact, walk passing, jump rise, jump apex, light attack, heavy attack, signature attack, block, and hit recoil. Use the character's signature move language such as Signature skill. Orthographic-feeling side-view presentation, plain background, no perspective camera.
[OUTPUT] 2048x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Microsoft logo, exact Windows logo, exact Copilot icon, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## sundar_pichoy_sprite_turnaround

- Subject: `sundar_pichoy`
- Type: `sprite_turnaround`
- Route: `pro`
- Size: `1536x1536`
- Aspect ratio: `1:1`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Sundar Pichoy. Low-risk neutral control with clean delayed confirms.
[SILHOUETTE] clean_suit_outline, chrome_arc_trail, steady_guard_pose.
[PROPS] Keep visible cues: dual-strike split arc, chrome-like speed trail, mini bot swarm.
[PALETTE] Target palette: #1F1F1F, #34A853, #4285F4.
[RIVAL CONTEXT] Rival hooks: sam_altmyn, mark_zuck, sergey_brinn.
[TASK] Create a character turnaround sheet for 2D fighter production. Include front 3/4, combat side view, back 3/4, and prop callouts. Keep proportions locked, side-view combat readability high, plain background.
[OUTPUT] 1536x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Google logo, exact Chrome logo, exact Android robot icon, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## sundar_pichoy_sprite_keypose_sheet

- Subject: `sundar_pichoy`
- Type: `sprite_keypose_sheet`
- Route: `pro`
- Size: `2048x1536`
- Aspect ratio: `4:3`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:sundar_pichoy_sprite_turnaround`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Sundar Pichoy. Low-risk neutral control with clean delayed confirms.
[SILHOUETTE] clean_suit_outline, chrome_arc_trail, steady_guard_pose.
[PROPS] Keep visible cues: dual-strike split arc, chrome-like speed trail, mini bot swarm.
[PALETTE] Target palette: #1F1F1F, #34A853, #4285F4.
[RIVAL CONTEXT] Rival hooks: sam_altmyn, mark_zuck, sergey_brinn.
[TASK] Create a sprite reference key-pose sheet for 2D fighter animation. Include idle, walk contact, walk passing, jump rise, jump apex, light attack, heavy attack, signature attack, block, and hit recoil. Use the character's signature move language such as Signature skill. Orthographic-feeling side-view presentation, plain background, no perspective camera.
[OUTPUT] 2048x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Google logo, exact Chrome logo, exact Android robot icon, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## jensen_hwang_sprite_turnaround

- Subject: `jensen_hwang`
- Type: `sprite_turnaround`
- Route: `pro`
- Size: `1536x1536`
- Aspect ratio: `1:1`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Jensen Hwang. Damage-scaling offense that becomes lethal after momentum.
[SILHOUETTE] leather_jacket_outline, broad_shoulders, neon_hardware_lines.
[PROPS] Keep visible cues: compute-core glow, vector chip shards, overclock aura.
[PALETTE] Target palette: #0E0E0E, #76B900, #4CE0FF.
[RIVAL CONTEXT] Rival hooks: sam_altmyn, zef_bezos.
[TASK] Create a character turnaround sheet for 2D fighter production. Include front 3/4, combat side view, back 3/4, and prop callouts. Keep proportions locked, side-view combat readability high, plain background.
[OUTPUT] 1536x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact NVIDIA logo, exact GeForce branding, exact RTX badge, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## jensen_hwang_sprite_keypose_sheet

- Subject: `jensen_hwang`
- Type: `sprite_keypose_sheet`
- Route: `pro`
- Size: `2048x1536`
- Aspect ratio: `4:3`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:jensen_hwang_sprite_turnaround`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Jensen Hwang. Damage-scaling offense that becomes lethal after momentum.
[SILHOUETTE] leather_jacket_outline, broad_shoulders, neon_hardware_lines.
[PROPS] Keep visible cues: compute-core glow, vector chip shards, overclock aura.
[PALETTE] Target palette: #0E0E0E, #76B900, #4CE0FF.
[RIVAL CONTEXT] Rival hooks: sam_altmyn, zef_bezos.
[TASK] Create a sprite reference key-pose sheet for 2D fighter animation. Include idle, walk contact, walk passing, jump rise, jump apex, light attack, heavy attack, signature attack, block, and hit recoil. Use the character's signature move language such as Signature skill. Orthographic-feeling side-view presentation, plain background, no perspective camera.
[OUTPUT] 2048x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact NVIDIA logo, exact GeForce branding, exact RTX badge, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## larry_pagyr_sprite_turnaround

- Subject: `larry_pagyr`
- Type: `sprite_turnaround`
- Route: `pro`
- Size: `1536x1536`
- Aspect ratio: `1:1`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Larry Pagyr. Map-control tactician who wins by information and spacing.
[SILHOUETTE] clean_founder_blazer, lens_motif_particles, upright_composed_posture.
[PROPS] Keep visible cues: floating query particle trail, lens flare cue, routing arc motif.
[PALETTE] Target palette: #1A1A1A, #3EA6FF, #7BD66D.
[RIVAL CONTEXT] Rival hooks: bill_geytz, sergey_brinn, sundar_pichoy.
[TASK] Create a character turnaround sheet for 2D fighter production. Include front 3/4, combat side view, back 3/4, and prop callouts. Keep proportions locked, side-view combat readability high, plain background.
[OUTPUT] 1536x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Google logo, exact Alphabet logo, exact Search UI screenshot, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## larry_pagyr_sprite_keypose_sheet

- Subject: `larry_pagyr`
- Type: `sprite_keypose_sheet`
- Route: `pro`
- Size: `2048x1536`
- Aspect ratio: `4:3`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:larry_pagyr_sprite_turnaround`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Larry Pagyr. Map-control tactician who wins by information and spacing.
[SILHOUETTE] clean_founder_blazer, lens_motif_particles, upright_composed_posture.
[PROPS] Keep visible cues: floating query particle trail, lens flare cue, routing arc motif.
[PALETTE] Target palette: #1A1A1A, #3EA6FF, #7BD66D.
[RIVAL CONTEXT] Rival hooks: bill_geytz, sergey_brinn, sundar_pichoy.
[TASK] Create a sprite reference key-pose sheet for 2D fighter animation. Include idle, walk contact, walk passing, jump rise, jump apex, light attack, heavy attack, signature attack, block, and hit recoil. Use the character's signature move language such as Signature skill. Orthographic-feeling side-view presentation, plain background, no perspective camera.
[OUTPUT] 2048x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Google logo, exact Alphabet logo, exact Search UI screenshot, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## sergey_brinn_sprite_turnaround

- Subject: `sergey_brinn`
- Type: `sprite_turnaround`
- Route: `pro`
- Size: `1536x1536`
- Aspect ratio: `1:1`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Sergey Brinn. Acrobatic chaos fighter who forces awkward angle fights.
[SILHOUETTE] lab_goggle_shape, spring_loaded_pose, split_jacket_flare.
[PROPS] Keep visible cues: lab-goggle cue, glass-rift afterimage, experimental launch column.
[PALETTE] Target palette: #191919, #7FD7FF, #F6D24A.
[RIVAL CONTEXT] Rival hooks: sundar_pichoy, sam_altmyn, larry_pagyr.
[TASK] Create a character turnaround sheet for 2D fighter production. Include front 3/4, combat side view, back 3/4, and prop callouts. Keep proportions locked, side-view combat readability high, plain background.
[OUTPUT] 1536x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Google logo, exact X logo, exact moonshot branding, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## sergey_brinn_sprite_keypose_sheet

- Subject: `sergey_brinn`
- Type: `sprite_keypose_sheet`
- Route: `pro`
- Size: `2048x1536`
- Aspect ratio: `4:3`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:sergey_brinn_sprite_turnaround`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Sergey Brinn. Acrobatic chaos fighter who forces awkward angle fights.
[SILHOUETTE] lab_goggle_shape, spring_loaded_pose, split_jacket_flare.
[PROPS] Keep visible cues: lab-goggle cue, glass-rift afterimage, experimental launch column.
[PALETTE] Target palette: #191919, #7FD7FF, #F6D24A.
[RIVAL CONTEXT] Rival hooks: sundar_pichoy, sam_altmyn, larry_pagyr.
[TASK] Create a sprite reference key-pose sheet for 2D fighter animation. Include idle, walk contact, walk passing, jump rise, jump apex, light attack, heavy attack, signature attack, block, and hit recoil. Use the character's signature move language such as Signature skill. Orthographic-feeling side-view presentation, plain background, no perspective camera.
[OUTPUT] 2048x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Google logo, exact X logo, exact moonshot branding, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## satya_nadello_sprite_turnaround

- Subject: `satya_nadello`
- Type: `sprite_turnaround`
- Route: `pro`
- Size: `1536x1536`
- Aspect ratio: `1:1`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Satya Nadello. Smooth defensive converter who turns calm structure into offense.
[SILHOUETTE] executive_coat_line, cloud_ring_shield, measured_guard_pose.
[PROPS] Keep visible cues: cloud-ring shield motif, forked echo trail, enterprise stack aura.
[PALETTE] Target palette: #1E1E1E, #5AA6FF, #9AD8FF.
[RIVAL CONTEXT] Rival hooks: bill_geytz, sam_altmyn, tim_cuke.
[TASK] Create a character turnaround sheet for 2D fighter production. Include front 3/4, combat side view, back 3/4, and prop callouts. Keep proportions locked, side-view combat readability high, plain background.
[OUTPUT] 1536x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Microsoft logo, exact Azure logo, exact GitHub logo, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## satya_nadello_sprite_keypose_sheet

- Subject: `satya_nadello`
- Type: `sprite_keypose_sheet`
- Route: `pro`
- Size: `2048x1536`
- Aspect ratio: `4:3`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:satya_nadello_sprite_turnaround`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Satya Nadello. Smooth defensive converter who turns calm structure into offense.
[SILHOUETTE] executive_coat_line, cloud_ring_shield, measured_guard_pose.
[PROPS] Keep visible cues: cloud-ring shield motif, forked echo trail, enterprise stack aura.
[PALETTE] Target palette: #1E1E1E, #5AA6FF, #9AD8FF.
[RIVAL CONTEXT] Rival hooks: bill_geytz, sam_altmyn, tim_cuke.
[TASK] Create a sprite reference key-pose sheet for 2D fighter animation. Include idle, walk contact, walk passing, jump rise, jump apex, light attack, heavy attack, signature attack, block, and hit recoil. Use the character's signature move language such as Signature skill. Orthographic-feeling side-view presentation, plain background, no perspective camera.
[OUTPUT] 2048x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Microsoft logo, exact Azure logo, exact GitHub logo, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## tim_cuke_sprite_turnaround

- Subject: `tim_cuke`
- Type: `sprite_turnaround`
- Route: `pro`
- Size: `1536x1536`
- Aspect ratio: `1:1`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Tim Cuke. Precision punish specialist with elegant spacing traps.
[SILHOUETTE] minimal_black_top, clean_white_arc, needle_precise_stance.
[PROPS] Keep visible cues: white arc slash, device-edge geometry cue, high-polish glass light.
[PALETTE] Target palette: #111111, #F4F4F4, #7AC7FF.
[RIVAL CONTEXT] Rival hooks: bill_geytz, steve_jobz, satya_nadello.
[TASK] Create a character turnaround sheet for 2D fighter production. Include front 3/4, combat side view, back 3/4, and prop callouts. Keep proportions locked, side-view combat readability high, plain background.
[OUTPUT] 1536x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Apple logo, exact iPhone silhouette, exact product UI, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## tim_cuke_sprite_keypose_sheet

- Subject: `tim_cuke`
- Type: `sprite_keypose_sheet`
- Route: `pro`
- Size: `2048x1536`
- Aspect ratio: `4:3`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:tim_cuke_sprite_turnaround`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Tim Cuke. Precision punish specialist with elegant spacing traps.
[SILHOUETTE] minimal_black_top, clean_white_arc, needle_precise_stance.
[PROPS] Keep visible cues: white arc slash, device-edge geometry cue, high-polish glass light.
[PALETTE] Target palette: #111111, #F4F4F4, #7AC7FF.
[RIVAL CONTEXT] Rival hooks: bill_geytz, steve_jobz, satya_nadello.
[TASK] Create a sprite reference key-pose sheet for 2D fighter animation. Include idle, walk contact, walk passing, jump rise, jump apex, light attack, heavy attack, signature attack, block, and hit recoil. Use the character's signature move language such as Signature skill. Orthographic-feeling side-view presentation, plain background, no perspective camera.
[OUTPUT] 2048x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Apple logo, exact iPhone silhouette, exact product UI, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## jack_dorsee_sprite_turnaround

- Subject: `jack_dorsee`
- Type: `sprite_turnaround`
- Route: `pro`
- Size: `1536x1536`
- Aspect ratio: `1:1`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Jack Dorsee. Tempo breaker with awkward rhythm control and delayed pressure.
[SILHOUETTE] monochrome_techwear, long_beard_shape, old_feed_blue_glow.
[PROPS] Keep visible cues: old-feed blue particle trail, chain-link motif, square swipe slash.
[PALETTE] Target palette: #141414, #5DAFFF, #DDE6F5.
[RIVAL CONTEXT] Rival hooks: elon_mvsk, reed_hestings, travis_kalanik.
[TASK] Create a character turnaround sheet for 2D fighter production. Include front 3/4, combat side view, back 3/4, and prop callouts. Keep proportions locked, side-view combat readability high, plain background.
[OUTPUT] 1536x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact X logo, exact Twitter bird, exact Square logo, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## jack_dorsee_sprite_keypose_sheet

- Subject: `jack_dorsee`
- Type: `sprite_keypose_sheet`
- Route: `pro`
- Size: `2048x1536`
- Aspect ratio: `4:3`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:jack_dorsee_sprite_turnaround`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Jack Dorsee. Tempo breaker with awkward rhythm control and delayed pressure.
[SILHOUETTE] monochrome_techwear, long_beard_shape, old_feed_blue_glow.
[PROPS] Keep visible cues: old-feed blue particle trail, chain-link motif, square swipe slash.
[PALETTE] Target palette: #141414, #5DAFFF, #DDE6F5.
[RIVAL CONTEXT] Rival hooks: elon_mvsk, reed_hestings, travis_kalanik.
[TASK] Create a sprite reference key-pose sheet for 2D fighter animation. Include idle, walk contact, walk passing, jump rise, jump apex, light attack, heavy attack, signature attack, block, and hit recoil. Use the character's signature move language such as Signature skill. Orthographic-feeling side-view presentation, plain background, no perspective camera.
[OUTPUT] 2048x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact X logo, exact Twitter bird, exact Square logo, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## travis_kalanik_sprite_turnaround

- Subject: `travis_kalanik`
- Type: `sprite_turnaround`
- Route: `pro`
- Size: `1536x1536`
- Aspect ratio: `1:1`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Travis Kalanik. Violent pace-control bruiser who steals lane space by force.
[SILHOUETTE] forward_aggressive_lean, black_car_streak, broad_jacket_shape.
[PROPS] Keep visible cues: surge meter aura, black-car streak motif, market-takeover lane slash.
[PALETTE] Target palette: #121212, #00D0FF, #FF6A3D.
[RIVAL CONTEXT] Rival hooks: reed_hestings, jack_dorsee, elon_mvsk.
[TASK] Create a character turnaround sheet for 2D fighter production. Include front 3/4, combat side view, back 3/4, and prop callouts. Keep proportions locked, side-view combat readability high, plain background.
[OUTPUT] 1536x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Uber logo, exact app UI, exact black-car product imagery, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## travis_kalanik_sprite_keypose_sheet

- Subject: `travis_kalanik`
- Type: `sprite_keypose_sheet`
- Route: `pro`
- Size: `2048x1536`
- Aspect ratio: `4:3`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:travis_kalanik_sprite_turnaround`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Travis Kalanik. Violent pace-control bruiser who steals lane space by force.
[SILHOUETTE] forward_aggressive_lean, black_car_streak, broad_jacket_shape.
[PROPS] Keep visible cues: surge meter aura, black-car streak motif, market-takeover lane slash.
[PALETTE] Target palette: #121212, #00D0FF, #FF6A3D.
[RIVAL CONTEXT] Rival hooks: reed_hestings, jack_dorsee, elon_mvsk.
[TASK] Create a sprite reference key-pose sheet for 2D fighter animation. Include idle, walk contact, walk passing, jump rise, jump apex, light attack, heavy attack, signature attack, block, and hit recoil. Use the character's signature move language such as Signature skill. Orthographic-feeling side-view presentation, plain background, no perspective camera.
[OUTPUT] 2048x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Uber logo, exact app UI, exact black-car product imagery, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## reed_hestings_sprite_turnaround

- Subject: `reed_hestings`
- Type: `sprite_turnaround`
- Route: `pro`
- Size: `1536x1536`
- Aspect ratio: `1:1`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Reed Hestings. Setplay planner who wins through long, disciplined sequences.
[SILHOUETTE] calm_blazer_shape, red_stream_trails, timeline_ui_marks.
[PROPS] Keep visible cues: streaming red trail, timeline motif, buffer extension glow.
[PALETTE] Target palette: #161616, #E53935, #F0F0F0.
[RIVAL CONTEXT] Rival hooks: jack_dorsee, travis_kalanik, mark_zuck.
[TASK] Create a character turnaround sheet for 2D fighter production. Include front 3/4, combat side view, back 3/4, and prop callouts. Keep proportions locked, side-view combat readability high, plain background.
[OUTPUT] 1536x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Netflix logo, exact UI screenshots, exact streaming thumbnails, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## reed_hestings_sprite_keypose_sheet

- Subject: `reed_hestings`
- Type: `sprite_keypose_sheet`
- Route: `pro`
- Size: `2048x1536`
- Aspect ratio: `4:3`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:reed_hestings_sprite_turnaround`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Reed Hestings. Setplay planner who wins through long, disciplined sequences.
[SILHOUETTE] calm_blazer_shape, red_stream_trails, timeline_ui_marks.
[PROPS] Keep visible cues: streaming red trail, timeline motif, buffer extension glow.
[PALETTE] Target palette: #161616, #E53935, #F0F0F0.
[RIVAL CONTEXT] Rival hooks: jack_dorsee, travis_kalanik, mark_zuck.
[TASK] Create a sprite reference key-pose sheet for 2D fighter animation. Include idle, walk contact, walk passing, jump rise, jump apex, light attack, heavy attack, signature attack, block, and hit recoil. Use the character's signature move language such as Signature skill. Orthographic-feeling side-view presentation, plain background, no perspective camera.
[OUTPUT] 2048x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Netflix logo, exact UI screenshots, exact streaming thumbnails, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## steve_jobz_sprite_turnaround

- Subject: `steve_jobz`
- Type: `sprite_turnaround`
- Route: `pro`
- Size: `1536x1536`
- Aspect ratio: `1:1`
- Image size: `2K`
- Edit source: `-`
- Reference images: `-`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Steve Jobz. Final-boss showman whose taste and timing distort the fight.
[SILHOUETTE] iconic_mock_turtleneck, glass_light_arc, precise_stage_presence.
[PROPS] Keep visible cues: glass-light distortion, clean keynote stage cue, reality-warp arc.
[PALETTE] Target palette: #050505, #F4F4F4, #8DD7FF.
[RIVAL CONTEXT] Rival hooks: tim_cuke, bill_geytz, mark_zuck.
[TASK] Create a character turnaround sheet for 2D fighter production. Include front 3/4, combat side view, back 3/4, and prop callouts. Keep proportions locked, side-view combat readability high, plain background.
[OUTPUT] 1536x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Apple logo, photoreal likeness, exact keynote slide UI, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

## steve_jobz_sprite_keypose_sheet

- Subject: `steve_jobz`
- Type: `sprite_keypose_sheet`
- Route: `pro`
- Size: `2048x1536`
- Aspect ratio: `4:3`
- Image size: `2K`
- Edit source: `-`
- Reference images: `asset:steve_jobz_sprite_turnaround`

```text
[STYLE LOCK] Founders Fight Club. A hybrid of platform-fighter fun and premium modern 2D fighter spectacle. Stylized 2D game art, satirical-comedic, bold outlines, graphic shape language, rich lighting, no photorealism. Characters and effects must read instantly during chaos; silhouette and pose clarity matter more than micro-detail. Stages must feel like full-window event venues with no gutters, no gray voids, and no boxed-in central playfield. Sprite reference art must stay orthographic-feeling, side-view ready, and proportionally stable across key poses. UI art should feel like a premium tournament broadcast package, not a debug overlay. Global must-haves: bold silhouette hierarchy, showtime lighting with warm/cool contrast, graphic materials and color blocking, motion accents that support gameplay read. Avoid: photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor.
[SUBJECT] Steve Jobz. Final-boss showman whose taste and timing distort the fight.
[SILHOUETTE] iconic_mock_turtleneck, glass_light_arc, precise_stage_presence.
[PROPS] Keep visible cues: glass-light distortion, clean keynote stage cue, reality-warp arc.
[PALETTE] Target palette: #050505, #F4F4F4, #8DD7FF.
[RIVAL CONTEXT] Rival hooks: tim_cuke, bill_geytz, mark_zuck.
[TASK] Create a sprite reference key-pose sheet for 2D fighter animation. Include idle, walk contact, walk passing, jump rise, jump apex, light attack, heavy attack, signature attack, block, and hit recoil. Use the character's signature move language such as Signature skill. Orthographic-feeling side-view presentation, plain background, no perspective camera.
[OUTPUT] 2048x1536.
[NEGATIVE] photoreal public-figure likenesses, exact real-world trademarks or logos, empty matte side borders, muddy values, generic mobile-game fantasy armor, exact Apple logo, photoreal likeness, exact keynote slide UI, low-resolution mush, muddy lighting, text overlays, background clutter hiding the silhouette.
```

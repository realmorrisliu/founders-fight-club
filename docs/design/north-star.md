# Design direction

This file is the check for later visual, control, and feel decisions in Founders Fight Club. Morris approved the goals below. A prototype does not change a goal. Morris changes it, and the change gets a row in the decisions log.

The project is pinned to Godot 4.5.1 in `GODOT_VERSION`. `project.godot` tags feature `4.5`.

## Confirmed goals

### Gameplay

Founders Fight Club is a Smash Bros-style platform fighter. A hit raises percent. Higher percent means more knockback and a launch off the stage is more likely. Each player has a few stocks. The stage has a few platform layers. A match runs about 2 to 3 minutes. The game is quick to pick up. Hits need a satisfying, weighty impact.

### Look

Characters are 2D sprites on a 3D stage. The camera has perspective and a shallow depth of field, in the HD-2D look of Octopath Traveler. Lighting is warm. A KO zooms the camera in and shakes the screen. Play stays on a 2D plane. The camera may show depth. A dodge does not leave that plane.

### Who it is for

Startup founders brawl, comic and full of in-jokes. Play is mainly local, with friends in the room, plus fights against the CPU.

### What polished means

- Controls respond. Extra delay past the latency bar fails this check.
- The picture is one style. It does not look like debug UI.
- The CPU plays like a human. It blocks, recovers, and approaches.
- The match has music and sound effects.

## The build today

These gaps are not picks.

Outside training, `_uses_stock_rule` is on, `stock_count` is 3, and the main scene turns side platforms on. `ROUND_TIME_SECONDS` is 60 and the timer starts enabled, so a match can end at 60 seconds. Damage is still hit points. `MAX_HP` is 100, and knockback grows by `0.70` of the damage ratio, capped at `1.65`. The approved goal is a rising percent. The camera is a `Camera2D` created in `scripts/Match.gd`. There is no `Camera3D`. Hit sounds are in `assets/audio/sfx/`. There are no music files.

## References

Do not commit screenshots from these games. The repo is public.

### Octopath Traveler

HD-2D is Square Enix's name for pixel characters in a 3D scene, with modern light and a shallow focus. Morris named that look. This project stays a platform fighter.

- [OCTOPATH TRAVELER](https://www.square-enix-games.com/en_US/games/octopath-traveler) says the visuals are inspired by retro 2D RPGs, with realistic elements, set in a 3D world.
- [The Japanese official site](https://www.jp.square-enix.com/octopathtraveler/) lists an IGN Japan best-visual prize for 2018.
- [The Nintendo eShop page](https://www.nintendo.com/us/store/products/octopath-traveler-switch/) hosts the publisher screenshots.
- [Square Enix introduction video](https://www.youtube.com/watch?v=kPor-DgiHBE) and [Web CM Vol.1](https://www.youtube.com/watch?v=tuZg9WaXtDE) are on the Square Enix channel.
- [Digital Foundry, 18 July 2018, Thomas Morgan](https://www.digitalfoundry.net/articles/digitalfoundry-2018-octopath-traveler-a-hybrid-game-for-a-hybrid-console) describes sprites on 3D towns, bokeh depth of field that stays sharp at the center, tilt-shift scale, and sprites that cast shadows. The same article measured a locked 30 frames per second on Switch. Our floor is 60.
- [Unreal Engine spotlight](https://www.unrealengine.com/en-US/spotlights/octopath-traveler-s-hd-2d-art-style-and-story-make-for-a-jrpg-dream-come-true) is Acquire's production write-up. A scripted request gets HTTP 403, so this file does not quote it.
- [FeatherBrain, 9 March 2022](https://forums.unrealengine.com/t/paper-2d-sprites-top-down-camera-how-to-get-shadows-consistent-with-3d-space-4-26/505228) estimates the Octopath camera at about 10 degrees above a side view. That is his estimate.

Take the sprite on a 3D stage, the shallow center focus, and light that casts a shadow on a hit. Leave the 30 frame cap, the role-playing camera, and any depth of field that softens the fighters. [Godot 4.5](https://docs.godotengine.org/en/4.5/classes/class_cameraattributespractical.html) says to keep `dof_blur_amount` low.

### tibo.dog

[tibo.dog](https://tibo.dog/) is a free pixel game by @poteto. The home page calls the picture 2.5D. It plays in the browser and inside posts on X. [The about page](https://tibo.dog/about/) says you move and dash, weapons fire on their own, and a level asks you to survive 20 minutes. It lists 27 languages and credits poteto at [x.com/poteto](https://x.com/poteto).

Morris named the taste-alignment process. Set a numeric bar. Build two or three prototypes. Morris picks. Encode the pick as a palette, timing constants, lints, tests, or bot targets. That process is his instruction for this project. This file does not quote a launch post, because a search of X did not return one.

Leave the survivors-like rules, the 20 minute timer, and the 27 languages. Our UI stays English and Chinese. Our jokes are about startup founders.

## How we decide

Use this sequence for a visual choice or a feel choice.

1. Build two or three prototypes you can switch while a match runs.
2. Drive each one with verify-ffc. Until that check exists, write down the command you ran.
3. Morris picks from screenshots or from video.
4. Add a row to the decisions log.
5. Encode the pick in a palette file, a timing constant, a lint, a test, or a verify-ffc check. The log names that file or check.

## Decisions log

Leave the goals out of this table.

| Date | Decision | Options shown | Pick | Where it is encoded |
| --- | --- | --- | --- | --- |
| 2026-11-03 | HD-2D camera, focus, and light | Looks 0, A, B, and C, in draft [PR #34](https://github.com/realmorrisliu/founders-fight-club/pull/34) | B | `docs/design/north-star.md`, Camera, focus, and light |

Use `YYYY-MM-DD` in the date column.

Look B, the pick, uses these values from that draft. Pitch is 10 degrees. Depth of field near distance is 3.4 m, far distance is 7.4 m, and amount is 0.18. Bloom intensity is 0.85, bloom is 0.16, and the HDR threshold is 0.80. The key light is red 1.0, green 0.90, blue 0.72, at energy 0.8. The hit point light is red 1.0, green 0.84, blue 0.60, at energy 1.2, range 3.2 m, and it is on during hitstun. The camera is 5.436778 m from the fighter plane. At zoom 1.42, pitch 10 degrees, and a 720 px tall window, the vertical field of view is 37.37 degrees.

Measured on that draft. Fighters in the mid-fight frame were about 185 px tall, against 126 px in look 0. One replay hash, `34e8c9d2c9b376b280109eb8d9577d8d1699aa1ee2e99d2255e6862bfffce085`, was byte-identical with the prototype off and with looks A, B, and C on. Depth of field and bloom require Forward+. Compatibility skips them. The real build is not in the tree yet.

## Bars

A bar stays PROVISIONAL until a prototype or a headless run replaces it, and the pick is logged. Camera, focus, and light is logged. The other bars stay PROVISIONAL.

### Frame rate

60 rendered frames per second during a match.

`project.godot` does not set a tick rate or a frame cap. [Godot 4.5 Engine.physics_ticks_per_second](https://docs.godotengine.org/en/4.5/classes/class_engine.html) defaults to 60, and a rate under 60 looks stuttery. No match has been profiled.

### Input latency

One physics tick, 16.7 milliseconds, while hit-stop is off. The 16.7 is one sixtieth of a second. Holding the delay to one tick is a guess.

The [Godot 4.5 Engine class](https://docs.godotengine.org/en/4.5/classes/class_engine.html) says a higher tick rate makes input more reactive. `DIRECTION_INPUT_BUFFER_SECONDS` is 0.10 and `INPUT_BUFFER_SECONDS` is 0.22. Those keep an early press. While `hitstop_active` is true, `scripts/Player.gd` returns before it reads the press.

### Hit-stop

0.0473 to 0.172 seconds.

`HITSTOP_BY_TIER` is 0.055 seconds for a light hit through 0.142 for an ultimate. A counter adds 0.030, so the top is 0.172. Combo 3 scales a light hit to 0.0528. The 0.86 floor starts at combo 6, and `0.055 * 0.86` is 0.0473. The code stores seconds and ceils them to milliseconds.

### Round length

2 to 3 minutes.

Morris approved that length. `ROUND_TIME_SECONDS` is 60 and the timer starts enabled, so the current match can end at one minute. No bot match has been timed. [SmashWiki](https://www.ssbwiki.com/Tournament_rulesets_%28SSBU%29) lists a 6 to 8 minute cap for Ultimate. That cap is longer than our target.

### KO rate

3 to 5 stock losses, for two equal bots with 3 stocks, after 30 seconds and before the timer. Guess.

`stock_count` is 3. HP at 0 and the blast zone both call `_lose_stock`. Three HP defeats can finish the match with zero ring-outs. The extra 0 to 2 losses, and the 30 second floor, are the guess. When verify-ffc runs a batch, count stock losses.

### Camera, focus, and light

Morris picked look B on 2026-11-03. These are the targets. The real build must match them. The fighters stay on the 2D plane. The floor in `scenes/Arena.tscn` is 760 by 40. One hundred pixels is one meter.

Pitch. 10 degrees above a side view.

Depth of field. `CameraAttributesPractical`, with near blur and far blur on. Near distance 3.4 m, far distance 7.4 m, amount 0.18. [Godot 4.5](https://docs.godotengine.org/en/4.5/classes/class_cameraattributespractical.html) runs this blur in Forward+ and Mobile, not Compatibility. `project.godot` sets no renderer. The pick requires Forward+.

Bloom. `glow_intensity` 0.85, `glow_bloom` 0.16, `glow_hdr_threshold` 0.80, blend mode soft light. [Godot 4.5 Environment](https://docs.godotengine.org/en/4.5/classes/class_environment.html) defaults `glow_enabled` to false.

Key light. One warm directional light, so a sprite casts a shadow on the floor. Color is red 1.0, green 0.90, blue 0.72, energy 0.8. Warm is an accent on the night city and the floor art.

Hit point light. One omni light. Color is red 1.0, green 0.84, blue 0.60, energy 1.2, range 3.2 m. It is on while the defender is in hitstun. That color is the heavy-hit flash in `SCREEN_FLASH_BY_TIER`.

Camera. The camera is 5.436778 m from the fighter plane. That distance yields a 50 degree vertical field of view at zoom 1.42 on a 720 px tall window, before the frame is tightened. The chosen frame divides the visible height by 1.4. At zoom 1.42 and a pitch of 10 degrees, the vertical field of view is 37.37 degrees. In the mid-fight capture, fighters were about 185 px tall. In look 0 they were 126 px tall.

KO zoom stays PROVISIONAL. Add 0.08 for 0.25 seconds, 0.15 for 0.40 seconds, or 0.25 for 0.55 seconds, and raise the upper clamp by the same amount. [Godot 4.5 Camera2D](https://docs.godotengine.org/en/4.5/classes/class_camera2d.html) says a higher zoom is more zoomed in. [camera_2d.cpp on 4.5-stable](https://github.com/godotengine/godot/blob/4.5-stable/scene/2d/camera_2d.cpp) sets `zoom_scale` to 1 divided by zoom. The current punch subtracts 0.020 to 0.060, which widens the view. The main scene clamps zoom from 1.08 to 1.42, so an add past 1.42 is cut off unless the clamp rises. The add amounts are guesses. Keep at least the heavy shake of 6.6 units for 0.14 seconds. A counter multiplies that shake by 1.42 and the duration by 1.15, which is 9.372 units for 0.161 seconds. Signature and ultimate shakes fall back to 2.8 units for 0.08 seconds.

# Design direction

This file is the check for later visual, control, and feel decisions in Founders Fight Club. Morris approved the goals below as written. A prototype that disagrees with a goal does not change the goal. Morris changes the goal, and the change gets a row in the decisions log.

Read the goals first. Use the bars when you need a number. Every bar is marked PROVISIONAL until a prototype or a headless run replaces it. A number is either from the current project, from a page linked below, or a guess. The sentence says which.

## Confirmed goals

### Gameplay

Founders Fight Club is a platform fighter in the Smash Bros style. A hit raises the opponent's percent. Higher percent means more knockback, and a high percent is more likely to launch someone off the stage. Each player has a few stocks. The stage has a few platform layers. A match runs about 2 to 3 minutes. The game is quick to pick up. Hits need a satisfying, weighty impact.

### Look

Characters are 2D sprites on a 3D stage. The camera has perspective and a shallow depth of field, in the HD-2D look of Octopath Traveler. Lighting is warm. A KO zooms the camera in and shakes the screen. Play stays on a 2D plane. The camera may show depth. A dodge does not leave that plane.

### Who it is for

The theme is startup founders in a comic brawl, full of in-jokes. The main way to play is local, with friends in the room. Fights against the CPU are part of the game too.

### What polished means

Polished means four things.

- Controls respond. Extra delay past the latency bar below fails this check.
- The picture is one style. It does not look like debug UI.
- The CPU plays like a human. It blocks, recovers, and approaches.
- The match has music and sound effects.

## The build today

The goals above are not all true in the current scenes. These gaps are not picks. The decisions log is empty until Morris chooses from prototypes.

Damage is still hit points. `scripts/Player.gd` sets `MAX_HP` to 100, and knockback grows as those points fall. The scale is `1.0 + damage_ratio * 0.70`, capped at `1.65` by `KNOCKBACK_GROWTH_MAX_SCALE`. The approved goal is a rising percent. That change has no row yet.

`scenes/Main.tscn` sets `win_rule` to `hp_timer` and `ruleset_profile` to `duel`. It also sets `side_platforms_enabled` to false. `scripts/Match.gd` defaults `stock_count` to 3 and `ROUND_TIME_SECONDS` to 60, with the round timer enabled. A match from the main scene is a 60 second timer on one floor. It is not yet a 2 to 3 minute stock match on several platforms.

`scripts/Arena.gd` can show `PlatformLeft` and `PlatformRight`. In `scenes/Arena.tscn` those two platforms sit at one height, y 282, above a floor whose collision is centered at y 360. That is two heights, and the main scene turns the upper one off.

The match camera is a `Camera2D` created in `scripts/Match.gd`. The project has no `Camera3D`, no depth of field, and no world light. `project.godot` sets the window to 1280 by 720 and does not set a renderer or a physics tick rate.

Hit sounds are wired in `SFX_PATHS` inside `scripts/Match.gd`, and the files live under `assets/audio/sfx/`. A search of the repo found no music files. `assets/art_direction/style_lock.yaml` still asks for stylized 2D art and warm and cool contrast. The README still calls the game a 2D pixel-art prototype for one player. This file is the later check. Those older lines stay until a logged pick updates them.

## References

Each reference says what to take and what to leave. Do not commit screenshots from these games. The repo is public. Follow the link.

### Octopath Traveler

HD-2D is Square Enix's name for pixel characters in a 3D scene, with modern light and a shallow focus. Morris named that look. This project stays a platform fighter.

Pages and video:

- [OCTOPATH TRAVELER](https://www.square-enix-games.com/en_US/games/octopath-traveler) on the Square Enix games site. The page says the visuals are inspired by retro 2D RPGs, with realistic elements, set in a 3D world.
- [The Japanese official site](https://www.jp.square-enix.com/octopathtraveler/). The awards list includes an IGN Japan best-visual prize for 2018. The page is the publisher's home for the game. Camera numbers are in the Digital Foundry article and in the bars below.
- [Octopath Traveler on the Nintendo eShop](https://www.nintendo.com/us/store/products/octopath-traveler-switch/). The product page hosts the publisher's screenshots. Its text describes the role-playing game.
- [Square Enix introduction video, March edition](https://www.youtube.com/watch?v=kPor-DgiHBE), on the Square Enix YouTube channel. Watch this for the picture.
- [Square Enix Web CM Vol.1](https://www.youtube.com/watch?v=tuZg9WaXtDE), on the same channel.
- [Digital Foundry, 18 July 2018, Thomas Morgan](https://www.digitalfoundry.net/articles/digitalfoundry-2018-octopath-traveler-a-hybrid-game-for-a-hybrid-console). This is the write-up on how the picture is built.
- [Unreal Engine spotlight on the HD-2D art](https://www.unrealengine.com/en-US/spotlights/octopath-traveler-s-hd-2d-art-style-and-story-make-for-a-jrpg-dream-come-true). Acquire and Square Enix describe the production choices summarized below.
- [A community camera estimate on the Unreal Engine forums](https://forums.unrealengine.com/t/paper-2d-sprites-top-down-camera-how-to-get-shadows-consistent-with-3d-space-4-26/505228). FeatherBrain wrote this on 9 March 2022. The angle below is that post's estimate. Acquire did not publish the number.

Take the sprite on a 3D stage, the shallow focus, and a point light that casts a shadow during a hit.

Digital Foundry describes sprite characters on towns modeled in 3D and wrapped in pixelated textures. The article calls out bokeh depth of field that stays sharp at the center and distorts specular points toward the back and the foreground. Morgan writes that this mimics tilt-shift photography and makes the scene look like a miniature. The same article says the sprites are given a physical place in the 3D scene so they cast perspective-correct shadows, and that light in the scene bounces on nearby objects. Battle effects brighten the room.

In the Unreal Engine spotlight, producer Masashi Takahashi says the team fused 2D pixels with a 3D environment and named that HD-2D. Lead artist Mika Iizuka says the first combat effects looked too plain, so the team added a point light together with the visual effects. That light casts the characters' shadows onto the stage.

Leave the parts that conflict with the goals above.

Digital Foundry measured a locked 30 frames per second on Switch, with battle frame times jumping between 16, 33, and 50 milliseconds. Our frame-rate floor is 60. Do not copy the 30 frame cap.

Keep our camera on a side view. FeatherBrain estimates Octopath at about 10 degrees above the ground plane, and writes that a steeper top-down angle makes a flat sprite look sheared. The pitches in the bars stay in that low range.

Do not copy characters, maps, interface, or music. Do not let depth of field or bloom soften the fighters. Godot's own note on `dof_blur_amount` says to keep the amount as low as the style allows. The sharp band is where the two fighters stand.

### tibo.dog

[tibo.dog](https://tibo.dog/) is a free pixel survivors-like by @poteto. The home page calls the picture 2.5D. It plays in the browser and inside posts on X. [The about page](https://tibo.dog/about/) says you move and dash, weapons fire on their own, and a level asks you to survive 20 minutes. It lists 27 languages. The about page credits poteto at [x.com/poteto](https://x.com/poteto).

Morris named two things to take from it. One is a polished, crafted feel. The other is the taste-alignment process.

That phrase does not appear on tibo.dog, and it does not appear in the launch notes below. A search of X during this writing returned no posts for those notes. The notes here come from a transcript that attributes them to @poteto on 1 November 2026.

- [Launch-post transcript](https://tibopoteto.lol/rounds/tibo-poteto-2117328788438851750). The engineering list below is that page's quotation of the post.

The quoted post says the author set numeric bars and then encoded them. It names a shared palette, with every sprite drawn from that palette. It names headless bots that play the game and tune each difficulty against a target survival rate. It names a lint for each repeated bug, a ban on comments, and a bar of 60 frames per second. It also says music and sound effects are part of the build, synthesized in the browser, with no audio files.

Take that practice. A person sets the bar. Two or three concrete options are compared. The person picks. The pick becomes a palette file, a constant, a lint, a test, or a bot target. Later work hits the check. The same choice does not have to be settled again in chat. That is the process to copy, under the name Morris used.

Leave the game it belongs to. Do not copy the survivors-like rules, the 20 minute timer, the 124 KB download budget, the 500-enemy phone bar, the Game Boy sound chip, or the joke about Tibo. Our jokes are about startup founders. Our languages, for the game UI, stay English and Chinese. Do not treat a four-day production story as a requirement.

## How we decide

Use this sequence for a visual choice or a feel choice.

1. Build two or three prototypes you can switch while a match runs.
2. Drive each one with verify-ffc. That check is not in this change. Another change is adding the headless match driver and the verify-ffc skill. Until that check exists, write down the command you ran, and replace the note when verify-ffc can run the same scene.
3. Morris picks from screenshots or from video.
4. Add a row to the decisions log. Date, decision, options shown, pick, and where it is encoded.
5. Encode the pick in the project. Put a color in a palette file, a duration in a timing constant, a banned pattern in a lint, an observable result in a test, or a pass rule in a verify-ffc check. A sentence in this file does not encode the pick by itself. The last column of the log names the file or the check.

## Decisions log

No pick has been logged. Leave the goals out of this table. Morris approved them as the starting point, before any prototype.

| Date | Decision | Options shown | Pick | Where it is encoded |
| --- | --- | --- | --- | --- |

Use `YYYY-MM-DD` in the date column.

## Bars

Every bar below is PROVISIONAL. Replace a row only after a prototype or a headless run, and log the pick. Do not treat a guess as a measurement.

### Frame rate

PROVISIONAL. The floor is 60 rendered frames per second during a match.

From the project and from Godot's docs. `project.godot` does not set `physics/common/physics_ticks_per_second` and does not set a max fps. [Godot 4.2's input-lag notes](https://docs.godotengine.org/en/4.2/tutorials/rendering/jitter_stutter.html) say the physics tick rate defaults to 60. `scripts/Player.gd` reads `Engine.physics_ticks_per_second` and uses 60 only when that value is 0 or less. Nobody has profiled a match on a target machine for this file. The floor is the inherited default, plus the 60 frame bar in the tibo.dog notes above. This file has no captured frame time.

Digital Foundry's Switch reading was 30 frames per second. This floor stays at 60. The [Godot 4.2 Engine class](https://docs.godotengine.org/en/4.2/classes/class_engine.html) says to keep the physics tick rate at 60 or above, because a rate under 60 looks stuttery.

### Input latency

PROVISIONAL. Hold simulation delay to one physics tick. At 60 ticks per second, one tick is one sixtieth of a second, which is 16.7 milliseconds. That figure is arithmetic. Treating one tick as the delay to hold is a guess.

[Godot 4.2's input-lag notes](https://docs.godotengine.org/en/4.2/tutorials/rendering/jitter_stutter.html) say the tick rate defaults to 60, and that raising it reduces physics-induced input latency. The same page says a full lag report needs a high-speed camera that sees both the key and the screen. This repo has no such capture. Those notes state the default and the effect of raising the rate. Wording that input waits for the next physics tick is from a later Engine class page, so this 4.2 project does not use that sentence as a source. The [4.2 Engine class](https://docs.godotengine.org/en/4.2/classes/class_engine.html) says a higher tick rate makes input more reactive, and that a rate under 60 looks stuttery.

The input buffers are a different number. `scripts/Player.gd` sets `DIRECTION_INPUT_BUFFER_SECONDS` to 0.10 and `INPUT_BUFFER_SECONDS` to 0.22. Those windows keep a press that arrives a little before the fighter can act. The latency bar is the wait before the game applies a press.

Guess. The full path from key to pixels on a monitor is longer than one physics tick, because the frame still has to draw and the display still has to show it. There is no number for that path yet. The next prototype should measure it. Until then, the bar to hold is one physics tick. A change that adds another tick of delay fails the bar.

### Hit-stop

PROVISIONAL. The current code freezes a connecting hit from 0.0473 seconds to 0.172 seconds. Hold that band until a prototype replaces it.

From the project. `scripts/Match.gd` sets `HITSTOP_BY_TIER` to 0.055 seconds for a light hit, 0.078 for a throw, 0.090 for a heavy hit, 0.102 for a special, 0.118 for a signature, and 0.142 for an ultimate. `COUNTER_HITSTOP_BONUS` adds 0.030, so an unscaled ultimate plus a counter is 0.172 seconds. A combo of 3 or more scales the tier. The scale is the larger of 0.86 and `1 - 0.04 * (combo_count - 2)`. Combo 3 uses 0.96, so a light hit becomes 0.0528 seconds. The 0.86 floor starts at combo 6. `0.055 * 0.86` is 0.0473 seconds, and the code's `ceil` of that duration in milliseconds is 48. While the flag is set, `scripts/Player.gd` returns early from `_physics_process`, so that fighter skips movement for the span. The span is wall-clock time from `Time.get_ticks_msec`. The file does not store a frame count.

At 60 ticks per second, 0.0473 seconds is under 3 ticks, and 0.172 seconds is a little over 10. That conversion is arithmetic. The code stores seconds.

[SmashWiki's hitlag page](https://www.ssbwiki.com/Hitlag) is a community record of the Smash formulas. It is not a Nintendo document in this repo. The page says Ultimate hitlag for a plain hit includes a `+ 6` frame term and caps at 30 frames. Thirty frames at 60 Hz is 0.5 seconds. Our band stays under 0.172 seconds because controls have to answer on the next tick. A prototype still has to show whether 0.055 seconds of freeze is enough weight for a light hit. That choice has no log row yet.

### Round length

PROVISIONAL. The target is about 2 to 3 minutes. That duration is the approved goal. No match has been timed for this file.

From the project, the main scene still uses a timer. `ROUND_TIME_SECONDS` is 60, the timer starts enabled, and `scenes/Main.tscn` uses `hp_timer`. `stock_count` defaults to 3 in `scripts/Match.gd`, and the export range allows 1 to 7. The main scene leaves the win rule on the timer.

[SmashWiki's Ultimate tournament rules](https://www.ssbwiki.com/Tournament_rulesets_%28SSBU%29) list 3 stocks and a time limit of 6 to 8 minutes. That limit stops a game from stalling. Our target stays the 2 to 3 minutes Morris approved.

Guess. Once stock rules are the match, two equal bots on 3 stocks should finish between 120 and 180 seconds because one side reaches 0 stocks. A finish caused by the current 60 second timer misses the target. No bot match has been timed for this file.

### KO rate

PROVISIONAL. For two equal bots with 3 stocks each, the match produces 3 to 5 ring-outs. It ends because one fighter reaches 0 stocks. It does not end in the first 30 seconds, and it does not hit the timer with zero ring-outs.

Guess. This repo has no headless bot-vs-bot runs. The driver that would produce them is a separate change. Do not cite these counts as measured.

The 3 is from the project. The loser must be rung out 3 times when `stock_count` is 3. The extra 0 to 2 ring-outs are a guess about a close game, in which the winner also loses stocks. Three ring-outs means the winner lost none. Five means the winner lost two. More than 5, or a match over in under 30 seconds, misses the guess. The 30 second floor is a guess too. When verify-ffc can run a batch, a passing batch lands inside this band, and a logged pick can replace the band with the measured rate.

### Camera, focus, and light

PROVISIONAL. The project has none of the 3D camera settings below. Build three switchable prototypes for each group. The values are guesses, except where the sentence names a Godot default or a current constant. Godot 4.2 measures depth-of-field distances in meters. This stage is still in 2D units. The floor collision in `scenes/Arena.tscn` is 760 by 40. The meter values assume a later 3D stage a few meters wide. They are not encoded.

The fighters stay on the 2D plane. A prototype that moves a hurtbox on a depth axis to dodge fails the look goal.

Pitch, in degrees above a pure side view. Try 6, 10, and 16. The 10 is FeatherBrain's estimate of Octopath, from the forum post above. Acquire did not publish it. The 6 and the 16 are the neighbors to compare against that estimate.

Depth of field uses `CameraAttributesPractical` on the `Camera3D`. Property names and defaults are from the [Godot 4.2 class page](https://docs.godotengine.org/en/4.2/classes/class_cameraattributespractical.html). Depth of field runs in the Forward+ and Mobile renderers. The Compatibility renderer skips it. `project.godot` does not choose a renderer, so the prototype has to show that the blur is actually visible.

- Off. `dof_blur_far_enabled` and `dof_blur_near_enabled` stay false. That is the Godot default.
- Mild. Far blur on, `dof_blur_far_distance` 8, `dof_blur_far_transition` 4, `dof_blur_amount` 0.08. Near blur on, `dof_blur_near_distance` 1.5, `dof_blur_near_transition` 0.6. The fighters stand in the sharp gap. Godot's default amount is 0.1, and the page says to keep the amount low.
- Strong. Far distance 4, transition 3, amount 0.2. Near distance 2.5, transition 1. This option exists so it can be rejected. If the fighters go soft, it fails the look goal.

Bloom uses `Environment` glow. Defaults are from the [Godot 4.2 Environment page](https://docs.godotengine.org/en/4.2/classes/class_environment.html). `glow_enabled` defaults to false, `glow_intensity` to 0.8, `glow_bloom` to 0, and `glow_hdr_threshold` to 1.

- Off. `glow_enabled` false.
- Low. `glow_enabled` true, `glow_intensity` 0.3, `glow_bloom` 0.05, `glow_hdr_threshold` 1.0.
- Medium. `glow_intensity` 0.8, `glow_bloom` 0.15, `glow_hdr_threshold` 1.0. The 0.8 intensity is Godot's default, and it does nothing until glow is enabled.

Key light. One warm light from the front of the stage, so a sprite can cast a shadow on the floor. The shadow is the part Acquire described. Bloom stays in the separate group above, and it stays low enough that sprites keep their edges. Colors use the same 0 to 1 channels as the hit flashes already in `scripts/Match.gd`.

- Soft. Red 1.0, green 0.92, blue 0.80, energy 1.0. Guess.
- Matched to the current heavy-hit flash. `SCREEN_FLASH_BY_TIER` uses red 1.0, green 0.84, blue 0.60, alpha 0.24. Use that red, green, and blue at energy 1.2. The color is from the project. The energy is a guess.
- Strong. Red 1.0, green 0.72, blue 0.45, energy 1.6. Guess.

`style_lock.yaml` asks for warm and cool contrast. The approved look goal says warm lighting. Warm wins until a logged pick says otherwise.

KO zoom and shake are separate from the HD-2D setup. The goal asks for a zoom-in and a screen shake on a KO. Today the punch is on a hit, and there is no KO-only camera.

From the project, and from the 4.2 engine. The [Godot 4.2 Camera2D page](https://docs.godotengine.org/en/4.2/classes/class_camera2d.html) says a zoom of 2 shows twice as much of the stage. The 4.2 engine does the other thing. In [camera_2d.cpp on the 4.2-stable branch](https://github.com/godotengine/godot/blob/4.2-stable/scene/2d/camera_2d.cpp), `zoom_scale` is 1 divided by zoom, and the visible rectangle is the screen size times that scale. `scripts/Arena.gd` uses the same division. `world_view_size` is the viewport size divided by `presentation_zoom`. A larger zoom shows less of the stage.

`scenes/Main.tscn` sets the close zoom to 1.42 and the far zoom to 1.18. On a 1280-wide view, 1280 divided by 1.42 is about 901 world units across, and 1280 divided by 1.18 is about 1085. Close framing is the tighter view.

`CAMERA_PUNCH_BY_TIER` subtracts 0.020 to 0.060 from zoom for 0.080 to 0.170 seconds. That subtraction widens the view. The current hit punch is a short zoom-out. `scripts/Match.gd` clamps zoom between `camera_zoom_min_limit` and the larger of the near and far zooms. On the main scene that clamp is 1.08 to 1.42. Adding zoom past 1.42 is cut back to 1.42, so a zoom-in also has to raise the upper clamp.

`CAMERA_SHAKE_BY_ATTACK` offsets the camera by up to 3.0 scene units on a light hit and 7.4 on a special, for 0.09 to 0.16 seconds. A heavy hit uses 6.6 units for 0.14 seconds. The floor in `scenes/Arena.tscn` is 760 units wide, so 6.6 is under 1 percent of that width.

Guess. Three KO zoom-ins, each added on top of the resting zoom, with the upper clamp raised by the same amount. Keep at least the heavy shake of 6.6 units for 0.14 seconds.

- Small. Add 0.08 for 0.25 seconds.
- Medium. Add 0.15 for 0.40 seconds.
- Large. Add 0.25 for 0.55 seconds.

The zoom has to keep both fighters readable. A zoom that loses the survivor, or that moves either fighter off the 2D plane, fails the goal.

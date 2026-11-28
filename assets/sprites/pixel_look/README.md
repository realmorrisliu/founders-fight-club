# Pixel look

Review prototype for Elon Mvsk and Steve Jobz. One shared pixel-art language on a flat side-view stage. It is off unless `--character-style pixel` is set. F8 toggles the fighter sheets for every fighter. The stage stays the flat pixel stage for that match. The default path keeps the Look B presentation.

Canvas is **48×96**. That is an even 2× of the 24×48 fighter contract. `CharacterLook.SCALE_MULTIPLIER` is `0.5`, so a 96px frame at half of `VISUAL_BASE_SCALE` keeps the same on-stage height as a 48px frame. Feet sit on the bottom pixel row.

Authored clips are idle, walk, light, heavy, special, jump, and hit. Other required clips stay on their existing poses, nearest-scaled up to this canvas, so a missing attack is not a frozen idle.

Regenerate the fighters with `python3 scripts/tools/paint_pixel_look.py`. Regenerate the stage with `python3 scripts/tools/paint_flat_stage.py`.

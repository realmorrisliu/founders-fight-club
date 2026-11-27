# Pixel look

Review prototype for Elon Mvsk and Steve Jobz. One shared pixel-art language. It is off unless `--character-style pixel` is set, or F8 toggles it in a match.

Canvas is **48×96**. That is an even 2× of the 24×48 fighter contract. `CharacterLook.SCALE_MULTIPLIER` is `0.5`, so a 96px frame at half of `VISUAL_BASE_SCALE` keeps the same on-stage height as a 48px frame. Feet sit on the bottom pixel row.

Authored clips are idle, walk, light, jump, and hit. Other required clips stay on their existing poses, nearest-scaled up to this canvas, so a missing attack is not a frozen idle.

Regenerate with `python3 scripts/tools/paint_pixel_look.py`.

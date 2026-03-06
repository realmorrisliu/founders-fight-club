# Effects Pixel Pipeline

Impact VFX source files:

- `counter_spark_0.png` ... `counter_spark_3.png`
- `guard_spark_0.png` ... `guard_spark_3.png`
- `ImpactSpriteFrames.tres`
- `scripts/tools/generate_combat_ui_assets.py`

Runtime wiring:

- `scripts/Match.gd` assembles runtime SpriteFrames from the PNG frame files
- Guarded hits spawn animation `guard`
- Counter hits spawn animation `counter`

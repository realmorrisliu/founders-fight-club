# Effects Pixel Pipeline

Impact VFX runtime animation source:

- `ImpactSpriteFrames.tres`

Current first-pass frame files:

- `guard_spark_0.png` ... `guard_spark_3.png`
- `counter_spark_0.png` ... `counter_spark_3.png`

Runtime wiring:

- `scripts/Match.gd` loads `res://assets/sprites/effects/ImpactSpriteFrames.tres`
- Guarded hits spawn animation `guard`
- Counter hits spawn animation `counter`

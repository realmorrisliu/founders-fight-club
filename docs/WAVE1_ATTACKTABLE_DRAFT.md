# Wave 1 AttackTable Draft (v1)

This draft defines the first eight launch fighters as concrete `AttackTable` resources.

## 1. Files Added

- `assets/data/characters/ElonMvskAttackTable.tres`
- `assets/data/characters/MarkZuckAttackTable.tres`
- `assets/data/characters/SamAltmynAttackTable.tres`
- `assets/data/characters/PeterThyellAttackTable.tres`
- `assets/data/characters/ZefBezosAttackTable.tres`
- `assets/data/characters/BillGeytzAttackTable.tres`
- `assets/data/characters/SundarPichoyAttackTable.tres`
- `assets/data/characters/JensenHwangAttackTable.tres`

## 2. Draft Intent Per Fighter

- `Elon Mvsk`: fastest entry, highest burst special, riskier block recovery.
- `Mark Zuck`: stable counter/trap pressure, lower raw damage, safer flow.
- `Sam Altmyn`: adaptive all-rounder with strong control special timing.
- `Peter Thyell`: slower startup, higher punish reward and throw threat.
- `Zef Bezos`: delayed-pressure special profile (long active, lower lunge).
- `Bill Geytz`: trap/control pacing, lower mobility and slower pressure setup.
- `Sundar Pichoy`: easy neutral toolkit, stable/safe special profile.
- `Jensen Hwang`: high damage snowball profile with volatile special reward.

## 3. Priority Tuning Knobs (First Pass)

Tune in this order during playtests:

1. `special.startup`, `special.recovery`, `special.lunge_speed`
2. `light.startup`, `light.recovery`
3. `heavy.damage`, `heavy.hitstun`, `heavy.recovery`
4. `throw.damage`, `throw.recovery`

## 4. Non-Functional Metadata in Draft

Each special entry includes:

- `signature_primary`
- `signature_alt`

These are descriptive tags for content/UI wiring and are not consumed by gameplay logic yet.

## 5. Current Scope Note

These resources are draft balance values and are not auto-assigned in scenes yet.
Use them by assigning the relevant `.tres` to a player instance `attack_table_resource`.


# Loadout and Character-Linked Item System Spec (V1)

## 1. Purpose
Define an implementation-ready system for:
- Multi-skill selection per character.
- Character-linked items (meme identity strongly tied to the fighter).
- Pre-match strategy through fixed loadout slots and point budget.

This spec is the execution baseline for engineering, content design, and QA.

## 2. Design Decision (Locked)
- Items are **pre-match equipped only**.
- Items are **not spawned as in-match pickups**.
- Loadout is locked when match starts.
- Strategy depth comes from:
  - slot allocation,
  - point budget,
  - round-between tuning,
  - in-match item evolution triggers.

## 3. Scope and Non-Goals

### In Scope (V1)
- Skill pool + item pool per character.
- Fixed slot system with legality validation.
- Point-budget constraints.
- Round-between micro-upgrade choice (2 options, choose 1).
- Trigger-based item evolution (single upgrade step).
- Save and reuse loadout presets.

### Out of Scope (V1)
- Ground pickup items.
- Mid-match free reconfiguration of slots.
- Cross-character shared universal item pool.

## 4. Core Rules

### 4.1 Slots
Each fighter enters match with:
- `2` Signature slots (`signature_a`, `signature_b`)
- `1` Ultimate slot (`ultimate`)
- `1` Item slot (`item`)
- `1` Passive slot (`passive`)

`signature_c` is reserved for V2 expansion and is not equip-configurable in V1.

### 4.2 Budget
- Total budget cap per loadout: `10`.
- Every selectable skill/item/passive has `cost`.
- Loadout is valid only if:
  - all required slots filled,
  - total cost `<= 10`,
  - tag constraints pass.

### 4.3 Tag Constraints
To prevent degenerate kits:
- Max `1` `hard_cc` tag across equipped entries.
- Max `1` `burst_mobility` tag across equipped entries.
- Max `1` `high_chip` tag across equipped entries.
- At least `1` entry tagged `neutral_tool`.

### 4.4 Character Identity
- Item definitions are character-bound (`owner_character_id` required).
- Matchmaker and menu must reject item equip if owner mismatch.

## 5. Data Contracts

### 5.1 File Layout
Add these files/directories:

```text
scripts/
  config/
    LoadoutCatalog.gd
  loadout/
    LoadoutValidator.gd
    LoadoutResolver.gd
    EvolutionEngine.gd
    RoundTuningEngine.gd
  resources/
    SkillDef.gd
    ItemDef.gd
    PassiveDef.gd
assets/
  data/
    loadouts/
      characters/
        <character_id>/
          skills/
          items/
          passives/
      presets/
```

### 5.2 SkillDef Resource Schema
`scripts/resources/SkillDef.gd`

Required fields:
- `id: String`
- `owner_character_id: String`
- `display_name_key: String`
- `slot_type: String` (`signature` or `ultimate`)
- `cost: int`
- `tags: PackedStringArray`
- `attack_entry_key: String` (maps to runtime attack profile key)
- `cooldown_seconds: float`

Optional fields:
- `evolution_id: String` (target skill id after evolution)
- `notes: String`

### 5.3 ItemDef Resource Schema
`scripts/resources/ItemDef.gd`

Required fields:
- `id: String`
- `owner_character_id: String`
- `display_name_key: String`
- `cost: int`
- `tags: PackedStringArray`
- `trigger_type: String`
- `trigger_value: float`
- `effect_type: String`
- `effect_payload: Dictionary`
- `max_charges: int`
- `cooldown_seconds: float`

Optional fields:
- `evolution_id: String`
- `round_tuning_options: Array[Dictionary]`

`round_tuning_options` entry schema:
- `id: String`
- `display_name_key: String`
- `payload_patch: Dictionary`

### 5.4 PassiveDef Resource Schema
`scripts/resources/PassiveDef.gd`

Required fields:
- `id: String`
- `owner_character_id: String`
- `display_name_key: String`
- `cost: int`
- `tags: PackedStringArray`
- `effect_type: String`
- `effect_payload: Dictionary`

### 5.5 Loadout Preset Schema
Stored as dictionary in `user://settings.cfg` and optional content preset files:

```gdscript
{
	"character_id": "sam_altmyn",
	"signature_a": "sam_signature_a_v1",
	"signature_b": "sam_signature_b_v2",
	"ultimate": "sam_ultimate_v1",
	"item": "sam_item_context_window",
	"passive": "sam_passive_stable_release",
	"version": 1
}
```

## 6. Runtime Flow

### 6.1 Menu Flow
1. Player selects character.
2. Loadout panel shows valid pool for that character.
3. Selection updates live budget meter and legality warnings.
4. Confirm only enabled when loadout is legal.
5. Save to `SessionState` for scene transition.

### 6.2 Match Start Flow
1. `LoadoutResolver` resolves IDs to runtime definitions.
2. `LoadoutValidator` re-validates to avoid tampered state.
3. Apply equipped skills to player runtime skill map.
4. Register item and passive runtime hooks.

### 6.3 During Match
- Item can trigger only by declared trigger contract (event-driven).
- Evolution checks run after each relevant combat event.
- On evolution success:
  - replace current item/skill with target definition,
  - preserve or reset cooldown based on definition flag (default: preserve remaining cooldown),
  - fire HUD evolution toast.

### 6.4 Round-Between Tuning
At round end (except final round):
1. Generate 2 legal tuning options from equipped item definition.
2. Player chooses 1 option during short intermission.
3. `RoundTuningEngine` applies `payload_patch` to current runtime item state.
4. Choice lasts for remaining rounds in current match only.

## 7. Integration With Existing Runtime

### 7.1 Existing Files to Extend
- `scripts/Menu.gd`
  - Add loadout UI and confirm gate.
- `scripts/SessionState.gd`
  - Add selected loadout payload for P1/P2.
- `scripts/Player.gd`
  - Accept resolved loadout entries and runtime hooks.
- `scripts/Match.gd`
  - Add round-between tuning selection state.
- `scripts/player/PlayerAttackRuntimeBuilder.gd`
  - Merge equipped skill entries into runtime attacks.

### 7.2 Session Keys
Add keys in `scripts/config/SessionKeys.gd`:
- `p1_loadout`
- `p2_loadout`

### 7.3 Backward Compatibility
- If loadout payload missing, fallback to character default preset.
- Ensure old tests and story/training scenes still boot with defaults.

## 8. Validation Rules (Authoring and Runtime)
- Definition IDs must be unique globally.
- `owner_character_id` must exist in `CharacterCatalog`.
- Slot compatibility must match selected slot.
- Budget and tag constraints must pass.
- Evolution target must reference same `owner_character_id`.
- Round tuning options must not violate budget or tag constraints after patch.

Validation failures:
- Content-time: fail in data validation test.
- Runtime: fallback to character default preset and log warning.

## 9. Telemetry for Balance Iteration
Track per match:
- Pick rate per skill/item/passive id.
- Win rate by full loadout signature.
- Round tuning option pick rate.
- Evolution success rate and average trigger time.

Store locally first (`user://match_metrics.jsonl`), external pipeline can be added later.

## 10. Test Gates

Add tests in `tests/TestRunner.gd`:
- Loadout legality pass/fail cases.
- Owner mismatch rejection.
- Budget overflow rejection.
- Tag constraint rejection.
- Default preset fallback when payload missing.
- Item trigger and cooldown behavior.
- Evolution trigger success/failure boundaries.
- Round-between tuning application and persistence in-match.
- Menu confirm disabled on invalid loadout.

Required command gates:
1. `./scripts/test.sh smoke`
2. `./scripts/test.sh full`

## 11. Delivery Plan

### Phase A: Foundation (Data + Validation)
- Add `SkillDef/ItemDef/PassiveDef`.
- Add `LoadoutCatalog` and `LoadoutValidator`.
- Add content validation tests.

Done criteria:
- Can validate one character with at least 4 skills, 2 items, 2 passives.

### Phase B: Menu + Session Wiring
- Add loadout panel and budget UI in menu.
- Persist selected loadout into session keys.
- Add default preset fallback path.

Done criteria:
- VS and story can start with selected legal loadout.

### Phase C: Runtime Hooks
- Apply loadout into `Player.gd` attack and item runtime.
- Add item trigger processing.
- Add item evolution processing.

Done criteria:
- Equipped item and selected signatures affect real combat behavior.

### Phase D: Round-Between Tuning
- Add round intermission choice panel (2 choose 1).
- Apply tuning patch with legality checks.

Done criteria:
- Choice affects later rounds in same match and never leaks to next match.

### Phase E: Polish and Balance Loop
- Add telemetry writes.
- Add tuning tables for first 4 characters.
- Add balancing checklist and QA matrix.

Done criteria:
- All test gates pass and telemetry file output is stable.

## 12. Initial Balancing Defaults
- Budget cap: `10`
- Signature cost: `2-3`
- Ultimate cost: `3-4`
- Item cost: `2-4`
- Passive cost: `1-2`
- Hard CC duration cap:
  - on hit: `<= 1.2s`
  - on block: `<= 0.6s`
- Evolution power delta target: `+10% to +18%` effective value

## 13. Acceptance Checklist
- [x] No in-match item pickup path exists in gameplay code.
- [x] All items are owner-bound and validated.
- [x] Loadout legality gates block invalid starts.
- [x] Runtime fallback path works without crashes.
- [x] Round-between tuning works for at least one character.
- [x] Evolution path works for at least one item (V1 scope).
- [x] Smoke/full test suites pass.

Status update:
- As of March 5, 2026, Phase A through Phase E are implemented in code and gated by automated smoke/full suites.

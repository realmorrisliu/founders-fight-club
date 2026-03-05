# Loadout Balance Checklist and QA Matrix (Phase E)

## Scope
This document closes Phase E for the loadout/item system by defining:
- Wave 1 (first 4 fighters) tuning table.
- Balance review checklist.
- QA matrix (automated + manual).

## Wave 1 Tuning Table

| Character ID | Signature Damage | Signature Cooldown | Ultimate Damage | Ultimate Cooldown | Core Item Trigger | Core Item Cooldown | Core Item Duration | Hype Item Trigger | Hype Item Cooldown | Hype Item Amount | Passive Startup | Passive Damage | Passive Chip |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `elon_mvsk` | `+6%` | `-4%` | `+2%` | `0%` | `0` | `0s` | `0s` | `-1` | `0s` | `+4` | `0` | `0` | `0` |
| `mark_zuck` | `-2%` | `+4%` | `0%` | `0%` | `-1` | `0s` | `+0.6s` | `0` | `0s` | `0` | `-0.02` | `0` | `0` |
| `sam_altmyn` | `+2%` | `0%` | `+8%` | `-5%` | `0` | `-0.5s` | `0s` | `0` | `0s` | `0` | `0` | `0` | `+0.01` |
| `peter_thyell` | `-3%` | `-6%` | `0%` | `0%` | `0` | `0s` | `0s` | `0` | `-0.6s` | `+6` | `0` | `+0.01` | `0` |

Source: `scripts/config/LoadoutCatalog.gd` (`WAVE1_CHARACTER_TUNING`).

## Balance Checklist

Run this checklist before changing costs, tags, trigger thresholds, or evolution values.

1. Legality and constraints
- Budget cap remains `<= 10` for all default presets.
- Tag limits (`hard_cc`, `burst_mobility`, `high_chip`) remain respected.
- At least one `neutral_tool` entry exists in every default preset.
- Owner-bound rule is preserved (`owner_character_id` == loadout character).

2. Runtime behavior
- Item trigger can activate only through declared trigger type.
- Cooldown and charge gates prevent repeated activation abuse.
- Evolution can only trigger after threshold and only to same-owner target.
- Round tuning applies once per selection and persists for later stocks in current match.

3. Data/telemetry
- Match summary writes to `user://match_metrics.jsonl`.
- Record contains loadout signatures and slot-level picks.
- Record contains round tuning pick events.
- Record contains item activation/evolution events and evolution success metrics.

4. Regression gate
- `./scripts/test.sh smoke` passes.
- `./scripts/test.sh full` passes.

## QA Matrix

| Area | Test Type | Coverage | Reference |
| --- | --- | --- | --- |
| Loadout legality, budget, tags, owner mismatch | Automated | Pass/fail validator and resolver fallback | `tests/TestRunner.gd::_test_loadout_system_foundation` |
| Session flow (menu -> runtime) | Automated | Preset selection persisted and applied | `tests/TestRunner.gd::_test_loadout_session_flow_runtime_apply` |
| Item trigger and cooldown gate | Automated | Trigger threshold, cooldown lock, charge consumption | `tests/TestRunner.gd::_test_loadout_item_trigger_and_cooldown_runtime` |
| Evolution threshold boundaries | Automated | Before threshold fail / at threshold evolve | `tests/TestRunner.gd::_test_loadout_item_evolution_boundaries` |
| Round tuning flow + persistence | Automated | Intermission UI, option apply, in-match persistence | `tests/TestRunner.gd::_test_round_tuning_intermission_flow` |
| Wave 1 tuning profile wiring | Automated | First 4 fighter tuning entries and applied deltas | `tests/TestRunner.gd::_test_loadout_wave1_tuning_profiles_present` |
| Match telemetry schema stability | Automated | JSONL schema fields and evol/tuning metrics | `tests/TestRunner.gd::_test_match_metrics_telemetry_schema` |
| Meta gate | Automated | End-to-end regression suites | `scripts/test.sh smoke`, `scripts/test.sh full` |

## Manual QA Scenarios

1. Round tuning UX sanity
- Start stock match with `round_tuning_enabled = true`.
- Lose one stock; verify panel appears and pause menu stays hidden.
- Pick option A/B; verify panel closes and gameplay resumes immediately.

2. Evolution readability
- Play until item evolves; verify evolution callout appears and does not block controls.

3. Cross-mode safety
- Verify VS / Story / Training still enter match normally with default loadouts.
- Verify no in-match item pickup flow exists (items remain pre-match equipped only).

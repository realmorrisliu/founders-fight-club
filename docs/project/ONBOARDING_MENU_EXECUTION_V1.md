# Onboarding and Menu Execution V1 (14-Point Delivery)

## Goals
- 30-second promise: new players can move, jump, guard, dodge, attack, throw, and use a special action within one short guided flow.
- 3-minute promise: players can reliably enter `VS`, `Story`, or `Training` with readable loadout feedback.
- 10-minute promise: telemetry can identify onboarding drop-off and menu entry behavior for the next tuning cycle.

## Funnel Map
1. Menu loads with roster and loadout selectors.
2. Player chooses mode (`VS`, `Story`, `Training`, or `Guided Start`).
3. Scene boots with selected fighters/loadouts.
4. If onboarding is enabled and required (or forced replay), HUD displays progressive steps.
5. Onboarding completes or is skipped.
6. Match telemetry writes onboarding summary and gameplay metrics.

## Implemented Scope
1. Design targets documented in this file.
2. Progressive in-match onboarding state machine implemented.
3. Guided replay path added from menu (`Guided Start`).
4. Menu IA clarified with flow subtitle and mode-specific hints.
5. Loadout tooltip now includes explicit readiness/fallback status.
6. Round tuning anti-snowball lock added for far-ahead players (`round_tuning_leader_lock_stock_gap`).
7. Skip and replay controls added to HUD onboarding panel.
8. Onboarding completion persisted in settings.
9. Forced onboarding replay supported through session keys.
10. Menu event telemetry written to `user://menu_metrics.jsonl`.
11. Match telemetry includes structured onboarding summary.
12. Regression tests added for onboarding settings/surface and round-tuning leader lock.
13. Bilingual localization coverage added for new onboarding/menu strings.
14. Changelog and docs index updated.

## Metrics Added
- `match_metrics.jsonl` now includes `onboarding.started/completed/skipped/forced_replay/steps_completed/completed_at_seconds`.
- `menu_metrics.jsonl` includes mode entry event, locale, control preset, window config, and loadout fallback flags.

## Next Tuning Knobs
- `Match.gd::onboarding_enabled`
- `Match.gd::round_tuning_leader_lock_stock_gap`
- `GameSettings.gd::onboarding.completed`
- `GameSettings.gd::onboarding.hints_enabled`

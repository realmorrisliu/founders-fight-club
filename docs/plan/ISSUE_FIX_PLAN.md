# Issue Fix Plan

Status legend: `[ ]` pending, `[~]` in progress, `[x]` done.

## P0 Critical
- [x] P0-1 Double-KO result can be overwritten by later `defeated` signal; enforce deterministic draw/win resolution.
- [x] P0-2 Gamepad mapping uses risky/system buttons (`Guide`, `Back`, stick-click) for core combat actions; normalize mappings and docs.
- [x] P0-3 Skill entity visual update uses delayed alpha path every frame and updates position one frame late.
- [x] P0-4 Attack table runtime reads rely on direct dictionary indexing; add safe access and stronger validation.
- [x] P0-5 `scripts/test.sh` exits early under `set -e`, so post-run log checks can be skipped on failures.

## P1 High
- [x] P1-1 Camera framing lacks dynamic zoom/readability when fighters are far apart.
- [x] P1-2 Training mode toggle can re-enable full AI behavior unexpectedly.
- [x] P1-3 HUD and training log still contain hard-coded English abbreviations/format tokens.
- [x] P1-4 Incorrect Chinese translation for overhead callout.
- [x] P1-5 `--suite` argument is not consumed by `tests/TestRunner.gd`.
- [x] P1-6 Pause panel missing "Back to Menu" path.
- [x] P1-7 Main menu wording implies PvP while runtime is PvE (vs AI).

## P2 Medium
- [x] P2-1 Character selection/session data uses implicit global engine metadata.
- [x] P2-2 First-launch flow applies Modern controls before explicit player selection.
- [x] P2-3 Training scene still shows timer UI even with timer disabled.
- [x] P2-4 Skill entities ignore stage geometry/walls.
- [x] P2-5 Teleport mobility effect can bypass stage boundaries.
- [x] P2-6 Character readability too uniform; add lightweight per-character visual differentiation.
- [x] P2-7 Prototype attack tables used by direct scene launch miss signature/ultimate entries.

## P3 Low
- [x] P3-1 `scripts/Combat.gd` is unused dead code; remove or integrate.
- [x] P3-2 CI job name `smoke` is misleading vs actual suite behavior.
- [x] P3-3 Add at least one higher-level (less white-box) runtime test path for match flow.

## Working Notes
- Execute in order from P0 -> P3.
- After each item: run tests and append a short verification note in commit/message history.

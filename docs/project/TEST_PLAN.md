# Test Plan & Verification Guide

## 1. Objective
Verify the implementation of MVP features: Dash, Hitstun, Restart, Pause, Camera, and Global Hitstop.

## 2. Prerequisites
- Godot 4.5.1, the version pinned in `GODOT_VERSION`.
- `bash scripts/test.sh full` downloads that official build into `.godot-bin/` when it is missing.
- Gamepad connected (optional, verifying keyboard inputs first).

## 2.1 Automated Regression (Required)
- Command: `bash scripts/test.sh full`
- Smoke subset: `bash scripts/test.sh` (or `just test`)
- Entrypoint: `tests/TestRunner.gd` (headless, Godot 4.5.1)
- Scope:
	- Scene boot smoke checks (`Menu`, `Main`, `Training`)
	- Character attack-table structural validation
	- Core damage/block flow validation
	- Skill runtime primitive validation (cooldown/status/effects)
	- Wave1 explicit skill wiring validation
	- Full 16-roster runtime signature coverage validation

## 2.2 CI Automation
- Workflow: `.github/workflows/test.yml`
- Trigger:
	- Every pull request
	- Every push to `main`
- Gate:
	- Runs `bash scripts/test.sh full` on the pinned Godot 4.5.1 binary
	- Build is considered failed if any assertion or script/runtime parse check fails

## 3. Test Cases

### TC-01: Dash
- **Input**: Press `L` (Keyboard) or `Y` (Gamepad) while on ground.
- **Expected**: Character dashes forward quickly (faster than walk).
- **Verification**: Visually confirm burst of speed.

### TC-02: Hitstun & Hitstop
- **Input**: Player 1 attacks Player 2 (AI).
- **Expected**: 
    - On hit, the game freezes briefly (0.08s) -> **Global Hitstop**.
    - Target (AI) stops moving for a short duration (0.18s) -> **Hitstun**.
- **Verification**: Hitting feels "crunchy" and not floaty.

### TC-03: Camera & Blast Zones
- **Input**: Move P1 toward a stage edge, then off the stage.
- **Expected**:
    - Camera follows the midpoint of P1 and P2 and can widen vertically.
    - There are no side walls. Leaving a blast zone spends a stock and respawns the fighter.
    - Side platforms stay enabled.
- **Verification**: Walk off the edge and confirm a stock is spent instead of a wall stop.

### TC-04: Match Flow & Restart
- **Input**: Ring out the opponent until their stocks are gone, or wait for the timer.
- **Expected**:
    - The HUD shows stocks and damage percent, not an HP bar.
    - "Player 1 Wins" (or result) appears when a side has no stocks left, or when the timer expires.
    - "Press R to Restart" message appears.
    - Press `R` -> Match reloads instantly.
- **Verification**: Complete a full loop.

### TC-05: Pause
- **Input**: Press `Esc` during match.
- **Expected**: Game freezes (physics/timer stop). Press `Esc` again to resume.
- **Verification**: Timer stops decrementing.

## 4. Known Issues / Limitations
- No "Pause Menu" UI (just freezes).
- Camera has basic smoothing; might jitter if FPS is low (unlikely).

# Test Plan & Verification Guide

## 1. Objective
Verify the implementation of MVP features: Dash, Hitstun, Restart, Pause, Camera, and Global Hitstop.

## 2. Prerequisites
- Godot 4.2+ installed.
- Gamepad connected (optional, verifying keyboard inputs first).

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

### TC-03: Camera & Bounds
- **Input**: Move P1 to the far left/right.
- **Expected**: 
    - Camera follows the midpoint of P1 and P2.
    - Player stops at invisible walls (cannot walk off platform).
- **Verification**: Try to walk off the edge; camera smoothness.

### TC-04: Match Flow & Restart
- **Input**: Defeat P2 or wait for timer.
- **Expected**: 
    - "Player 1 Wins" (or result) appears.
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

# Roster 16 Dev Table (v1)

This table is the production-facing balance and implementation sheet for the launch 16 roster.

## 1. Scale Definition

- `Speed`: movement + startup pace. (1 slow - 5 fast)
- `Damage`: average reward per confirmed opening. (1 low - 5 high)
- `Pressure`: ability to sustain offense on block/knockdown. (1 low - 5 high)
- `Mobility`: approach/escape/position shift power. (1 low - 5 high)
- `Ease`: onboarding difficulty for new players. (1 easy - 5 hard)
- `Priority`:
  - `P0`: launch trailer and balance core.
  - `P1`: launch complete and competitive viable.
  - `P2`: launch complete, lower immediate tuning urgency.

## 2. Launch Matrix

| Fighter | Archetype | Speed | Damage | Pressure | Mobility | Ease | Priority | Ship Wave | Initial Signature Mapping (on current system) |
|---|---|---:|---:|---:|---:|---:|---|---|---|
| Elon Mvsk | Volatile Rushdown | 5 | 4 | 5 | 4 | 3 | P0 | Wave 1 | `special`: SpaceX Launch, alt-special: Tesla Ram |
| Mark Zuck | Counter Trap | 4 | 3 | 4 | 3 | 2 | P0 | Wave 1 | `special`: Threads Snare, alt-special: Meta Mirror |
| Sam Altmyn | Adaptive Control | 3 | 4 | 4 | 3 | 4 | P0 | Wave 1 | `special`: GPT Burst, alt-special: Sora Cutscene |
| Peter Thyell | Strategic Punish | 2 | 5 | 3 | 2 | 4 | P0 | Wave 1 | `special`: Palantir Scan, alt-special: Board Coup |
| Zef Bezos | Zoning Setplay | 2 | 4 | 4 | 2 | 4 | P0 | Wave 1 | `special`: Prime Drone Fleet, alt-special: Checkout Trap |
| Bill Geytz | Trap Control | 2 | 3 | 4 | 2 | 3 | P0 | Wave 1 | `special`: Azure Flood, alt-special: Blue Screen Stun |
| Sundar Pichoy | Stable Neutral | 3 | 3 | 4 | 3 | 2 | P0 | Wave 1 | `special`: Gemini Split, alt-special: Chrome Rush |
| Jensen Hwang | Snowball Offense | 3 | 5 | 4 | 3 | 3 | P0 | Wave 1 | `special`: CUDA Barrage, alt-special: RTX Flash |
| Larry Pagyr | Spacing Control | 3 | 3 | 3 | 3 | 3 | P1 | Wave 2 | `special`: Search Index, alt-special: Waymo Roll |
| Sergey Brinn | Mobility Trickster | 4 | 3 | 3 | 5 | 5 | P1 | Wave 2 | `special`: X-Lab Leap, alt-special: Glass Blink |
| Satya Nadello | Defense-to-Offense | 3 | 3 | 3 | 3 | 4 | P1 | Wave 2 | `special`: Cloud Pivot, alt-special: GitHub Fork |
| Tim Cuke | Precision Punish | 3 | 4 | 3 | 4 | 4 | P1 | Wave 2 | `special`: iPhone Arc, alt-special: Airdrop Snap |
| Jack Dorsee | Tempo Breaker | 4 | 3 | 4 | 3 | 4 | P2 | Wave 3 | `special`: Tweet Storm Classic, alt-special: Block Chain |
| Travis Kalanik | Brute Aggro | 4 | 4 | 4 | 3 | 3 | P2 | Wave 3 | `special`: Ride Share Rush, alt-special: Black Car Crash |
| Reed Hestings | Long Setplay | 3 | 3 | 5 | 2 | 5 | P2 | Wave 3 | `special`: Auto-Play String, alt-special: Skip Intro Kick |
| Steve Jobz (Boss) | Mythic Exam | 4 | 5 | 5 | 4 | 5 | P0 (Boss) | Boss Wave | `special`: One More Thing (phase variants) |

## 3. Rivalry Priority for Writing & Events

| Pair | Heat Level | First Implement |
|---|---|---|
| Elon Mvsk vs Mark Zuck | S | Yes (launch) |
| Sam Altmyn vs Peter Thyell | S | Yes (launch) |
| Sam Altmyn vs Jensen Hwang | A | Yes (launch) |
| Elon Mvsk vs Sam Altmyn | A | Yes (launch) |
| Bill Geytz vs Larry Pagyr | B | Post-launch patch 1 |
| Tim Cuke vs Steve Jobz | A | Yes (boss unlock route) |
| Zef Bezos vs Jensen Hwang | A | Yes (final seed route) |
| Jack Dorsee vs Elon Mvsk | B | Post-launch patch 1 |

## 4. Event Assignment (Arcade Route)

| Event Node | Candidate Fighters | Notes |
|---|---|---|
| Cold Open Challenge | Elon Mvsk, Mark Zuck | Mandatory social hook scene |
| Qualifier Pool A | Bill Geytz, Larry Pagyr, Jack Dorsee, Travis Kalanik | Broad style showcase |
| Qualifier Pool B | Satya Nadello, Tim Cuke, Reed Hestings, Sergey Brinn | Less explosive, more technical |
| Board Coup Chapter | Sam Altmyn, Peter Thyell | Mandatory narrative gate |
| Main Event Split | Elon Mvsk, Mark Zuck | Route A/B order swap |
| Final Seed Match | Jensen Hwang / Sundar Pichoy / Zef Bezos | Rotating seed for replayability |
| Legend Encounter | Steve Jobz | Unlock after first clear |

## 5. Balance Targets (v1)

- Keep total roster spread readable:
  - Fast archetypes: 4-5 characters.
  - Heavy-damage archetypes: 4-5 characters.
  - High-pressure archetypes: 5-6 characters.
  - High-mobility archetypes: 3-4 characters.
- Ensure at least 3 `Ease <= 2` characters for onboarding:
  - Mark Zuck, Sundar Pichoy, Bill Geytz.
- Ensure at least 3 `Ease >= 5` characters for mastery:
  - Sergey Brinn, Reed Hestings, Steve Jobz.

## 6. First Build Checklist (Practical)

- Build Wave 1 eight fighters first (all `P0` non-boss).
- For each fighter in Wave 1:
  - one base AttackTable,
  - one alt-special profile,
  - 2 intro lines and 2 win lines.
- Implement boss phase script only after Wave 1 tuning pass is playable.


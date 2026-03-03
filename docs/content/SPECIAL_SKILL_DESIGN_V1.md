# Special Skill Design Spec (Roster 16, v1)

This document defines implementation-ready design targets for all special skills across the launch roster.
It bridges creative intent, gameplay behavior, and engineering implementation.

## 1. Scope

- Roster: 16 fighters.
- Skill set per fighter: `Signature A`, `Signature B`, `Signature C`, and `Ultimate`.
- Focus: behavior, control intent, counterplay, creative source, and implementation hooks.
- This is a design baseline and should be tuned by playtests.

## 2. Command Model

Use this command model consistently:

- `Signature A`: `Neutral + Special` (`N+SP`)
- `Signature B`: `Forward + Special` (`6+SP`)
- `Signature C`: `Down + Special` (`2+SP`)
- `Ultimate`: `Special + Heavy` while Hype meter is full (`SP+HVY`)

Notes:

- Current runtime still has one generic `attack_special` action.
- `Ultimate` entries are target designs for the meter phase.

## 3. Shared Rules

- Every skill must create a distinct decision pattern, not just extra damage.
- Every skill must expose clear counterplay.
- Crowd-control windows should be short and readable:
  - `slow`: 0.6s to 1.2s
  - `silence` (disable specials): 0.8s to 1.6s
  - `root`: max 0.5s
  - `vision disruption`: max 0.9s
- Fast/reactive tools must be unsafe, spacing-dependent, or setup-gated.
- Trap/summon tools need explicit telegraph VFX.
- Install buffs need clear state visuals and fixed duration.

## 4. Fighter Skill Designs

## 4.1 Elon Mvsk

Design pillar: volatile momentum and spotlight burst.

| Skill | Cmd | Type | Creative Source | Mechanic Rationale (Why This Design) | Hit / Block | Counterplay | V1 Implementation Hook |
|---|---|---|---|---|---|---|---|
| X Dogpile | `N+SP` | Projectile lane control | X/Twitter dogpile waves and sentiment spikes. | Horizontal pressure lane models constant public pressure and attention drag. | Hit: light stagger + chip. Block: push + chip. | Jump lane, pre-poke startup, projectile clash. | `projectile_single` + optional camera jitter. |
| SpaceX Launch | `6+SP` | Rising anti-air | Rocket launch imagery and vertical thrust. | Anti-air launcher expresses "go up and dominate the sky" identity. | Hit: launch state, combo starter. Block: punishable landing. | Bait and punish descent, late drift. | `rising_strike` + landing recovery state. |
| Tesla Autopilot Ram | `2+SP` | Summon rush | Self-driving car surprise impact. | Off-screen rush captures sudden market-disrupt style and lane theft. | Hit: carry + knockback. Block: heavy push, Elon minus. | Jump arc, force miss with spacing, hit startup. | `summon_dash_entity` delayed spawn. |
| Mars Colony Drop | `SP+HVY` | Delayed AoE cinematic | Mars mission spectacle and scale fantasy. | Marker + delayed blast creates headline-level threat and area denial. | Hit: hard knockdown. Block: high chip/guard load. | Move out of marker, invuln through detonation. | `delayed_aoe_marker` + cinematic confirm. |

## 4.2 Mark Zuck

Design pillar: disciplined trap pressure and controlled proximity.

| Skill | Cmd | Type | Creative Source | Mechanic Rationale (Why This Design) | Hit / Block | Counterplay | V1 Implementation Hook |
|---|---|---|---|---|---|---|---|
| Threads Snare | `N+SP` | Trap slow | Threads-style engagement net and capture metaphor. | Floor snare slows tempo and forces deliberate spacing decisions. | Trigger: root then slow. | Jump lane, bait placement, whiff punish. | `trap_floor` with slow + dash lockout. |
| Meta Mirror | `6+SP` | Feint / clone | Meta avatar and mirror identity themes. | Clone feint forces left-right reads and attention split. | Hit: feint follow-up confirm. Block: spacing-safe. | Track real body, anti-air fake jump routes. | `clone_feint` + follow-up window. |
| Reels Loop | `2+SP` | Advancing multi-hit | Short-form loop feed rhythm. | Repeating advancing hits model retention loop and corner carry pressure. | Hit: carry route. Block: minus unless tip-spaced. | Challenge known gap, backdash first beat. | `multi_hit_dash_string`. |
| Octagon Lock-In | `SP+HVY` | Arena control | Cage/octagon showdown narrative. | Temporary boundary shrink enforces close combat where Mark excels. | No direct hit required. | Defend until timer ends, use escapes early. | `arena_modifier` + timeout restore. |

## 4.3 Sam Altmyn

Design pillar: adaptation, delayed sequencing, and read conversion.

| Skill | Cmd | Type | Creative Source | Mechanic Rationale (Why This Design) | Hit / Block | Counterplay | V1 Implementation Hook |
|---|---|---|---|---|---|---|---|
| GPT Burst | `N+SP` | Adaptive strike | Model adaptation and prompt-response behavior. | Auto-switching high/low rewards learning opponent tendencies in-match. | Hit: medium stagger. Block: not truly plus. | Mix guard timings, interrupt startup. | `adaptive_block_type` from guard history. |
| Sora Cutscene | `6+SP` | Delay control | Generative video beat: freeze then impact. | Freeze cue + delayed hit punishes autopilot reactions. | Hit: delayed stun window. Block: chip, Sam minus. | Wait out timing, invuln second beat. | `freeze_cue` + delayed strike spawn. |
| Codex Assist | `2+SP` | Summon extender | Coding assistant co-agent fantasy. | Delayed helper creates layered offense and route extension. | Hit: extender re-juggle. Block: pressure remains contestable. | Hit summon startup, reposition out lane. | `summon_slash_delayed`. |
| AGI Deadline | `SP+HVY` | Install pressure | "Race to AGI" deadline pressure metaphor. | Timed install boosts chip/traps to emulate accelerating stakes. | Hit: stronger conversions. Block: sustained chip threat. | Turtle timer, interrupt activation. | `install_buff` chip + cancel modifiers. |

## 4.4 Peter Thyell

Design pillar: patient manipulation, absorb-to-punish, and governance pressure.

| Skill | Cmd | Type | Creative Source | Mechanic Rationale (Why This Design) | Hit / Block | Counterplay | V1 Implementation Hook |
|---|---|---|---|---|---|---|---|
| Palantir Scan | `N+SP` | Read stance | Surveillance/analytics motif. | Read stance converts opponent commitment into future punish edge. | Hit: next punish buff. | Throw beats stance, delay strings. | `read_stance` + cached attack class. |
| Board Coup | `6+SP` | Armored advance | Boardroom takeover and power shift. | Armor step expresses turn-steal authority and slow inevitability. | Hit: turn steal knockback. Block: unsafe if armor unused. | Multi-hit, throw, spacing punish. | `armor_step` single-hit absorb. |
| Fund Freeze | `2+SP` | Debuff strike | Capital freeze and budget clamp. | Resource suppression directly translates to strategic denial. | Hit: resource debuff duration. Block: reduced effect. | Disengage until debuff expires. | `on_hit_debuff` resource scalar. |
| Liquidation Event | `SP+HVY` | Command grab cinematic | Liquidation event and forced restructuring metaphor. | High-threat command grab fits his "one read, huge swing" identity. | Hit: hard knockdown + side control. | Jump/backdash/read spacing. | `command_grab` + side-reset resolver. |

## 4.5 Zef Bezos

Design pillar: logistics zoning and delayed fulfillment pressure.

| Skill | Cmd | Type | Creative Source | Mechanic Rationale (Why This Design) | Hit / Block | Counterplay | V1 Implementation Hook |
|---|---|---|---|---|---|---|---|
| Prime Drone Fleet | `N+SP` | Multi-wave summon | Delivery drones and staggered logistics flow. | Two-wave timing locks routes and punishes impatient movement. | Hit: anti-air follow-up routes. Block: layered chip. | Dash gap between waves, jump timing read. | `summon_projectile_sequence`. |
| Blue Origin Pop | `6+SP` | Vertical burst | Rocket pop and vertical reposition motif. | Vertical burst gives anti-air + escape dual function for zoning archetype. | Hit: pop-up/reset. Block: landing punish risk. | Bait and punish descent. | `vertical_burst_strike`. |
| Checkout Trap | `2+SP` | Hidden trap | Checkout trigger and transaction trap concept. | Hidden floor trigger rewards lane planning and delayed control. | Hit: pop-up starter. Block: chip + push. | Trap scouting, pressure Zef during setup. | `trap_floor_hidden`. |
| 1-Day Doom Delivery | `SP+HVY` | Lane bombardment | Rapid delivery at scale, all-lane saturation. | Multi-lane pulses force route choices under time pressure. | Hit: repeated knockdowns. Block: heavy chip in corner. | Find safe lane windows, invuln final slam. | `aoe_lane_barrage`. |

## 4.6 Bill Geytz

Design pillar: system disruption and compatibility-era control.

| Skill | Cmd | Type | Creative Source | Mechanic Rationale (Why This Design) | Hit / Block | Counterplay | V1 Implementation Hook |
|---|---|---|---|---|---|---|---|
| Blue Screen Stun | `N+SP` | Pulse disruptor | Blue-screen crash joke and hard stop moment. | Extra hitstop/stun creates "system halted" feel. | Hit: bonus lock. Block: modest chip, Bill minus. | Stay out range, whiff punish pulse. | `pulse_hit` + bonus hitstop flag. |
| Azure Flood | `6+SP` | Slow wall projectile | Cloud platform "flood" visual metaphor. | Slow wall enforces long-term space planning and attrition pressure. | Hit: push + control. Block: continuous chip touch. | Jump over wall edge, rush Bill first. | `persistent_wall_projectile`. |
| Copilot Correct | `2+SP` | Reactive counter tool | AI assistant auto-correct theme. | Trigger-on-block tool rewards defense into offense conversion. | Hit: auto follow-up punish. | Throw to bypass trigger, wait window out. | `block_reactive_trigger`. |
| Windows 95 Reboot | `SP+HVY` | Global tempo reset | Legacy reboot reference and state reset fantasy. | Tempo reset supports veteran setup style and neutral re-control. | No direct hit needed. | Plan resources for post-reset scramble. | `global_time_scale_event` + spacing reset. |

## 4.7 Larry Pagyr

Design pillar: route optimization, tracking, and spacing taxation.

| Skill | Cmd | Type | Creative Source | Mechanic Rationale (Why This Design) | Hit / Block | Counterplay | V1 Implementation Hook |
|---|---|---|---|---|---|---|---|
| Search Index | `N+SP` | Tracking projectile | Search ranking and target relevance. | One-time tracking rewards prediction without becoming unavoidable. | Hit: lane check stagger. Block: modest push. | Move after lock, late jump arc. | `projectile_retarget_once`. |
| Ad Auction | `6+SP` | Resource steal | Ad auction competition and value extraction. | On-hit steal creates economic advantage style in combat terms. | Hit: steals meter/momentum. Block: no steal. | Challenge startup in close range. | `on_hit_resource_transfer`. |
| Waymo Roll | `2+SP` | Ground summon | Autonomous car lane-crossing reference. | Ground roller creates lane denial while Larry plays spacing game. | Hit: knockdown contact. Block: one chip tick. | Hop over, destroy if system allows. | `summon_ground_roller`. |
| Alphabet Rain | `SP+HVY` | Pattern barrage | Multi-product umbrella scale and spread. | Multi-angle barrage pressures routing decisions over reaction only. | Hit: repeated confirm chances. Block: chip in trapped routes. | Track safe corridor and burst out. | `pattern_projectile_barrage`. |

## 4.8 Sergey Brinn

Design pillar: moonshot movement and awkward-angle offense.

| Skill | Cmd | Type | Creative Source | Mechanic Rationale (Why This Design) | Hit / Block | Counterplay | V1 Implementation Hook |
|---|---|---|---|---|---|---|---|
| X-Lab Leap | `N+SP` | Angle leap strike | X-lab experimentation and unusual movement vectors. | Variable landing angle stresses anti-air discipline and spacing reads. | Hit: cross-up starter. Block: minus on high guard. | Pre-emptive anti-air, hold center. | `leap_attack` with angle variant. |
| Glass Blink | `6+SP` | Teleport feint | Smart-glass blink and "appear elsewhere" gag. | Short blink adds uncertainty without full-screen unfairness. | Hit: side-switch confirm. Block: minus if overused. | Cover reappear spot with active button. | `short_teleport` + follow-up gate. |
| Moonshot Kick | `2+SP` | Arc kick | Moonshot arc and risky ambition tone. | Curved trajectory creates front/back ambiguity and rhythm break. | Hit: juggle on clean cross. Block: punishable descent. | Delay anti-air, maintain anti-cross spacing. | `arc_kick` cross-up detector. |
| Prototype Overflow | `SP+HVY` | Random branch chain | Prototype instability and experimental variance. | Random finisher branch makes defense adapt, not autopilot. | Hit: branch-specific enders. Block: finisher risk remains. | React to branch telegraph and punish unsafe end. | `scripted_chain_rng_branch`. |

## 4.9 Sundar Pichoy

Design pillar: stable fundamentals and controlled timing flexibility.

| Skill | Cmd | Type | Creative Source | Mechanic Rationale (Why This Design) | Hit / Block | Counterplay | V1 Implementation Hook |
|---|---|---|---|---|---|---|---|
| Gemini Split | `N+SP` | Two-phase strike | Gemini duality and two-thought cadence. | Optional delay on phase 2 creates timing mind game while staying readable. | Hit: confirm either phase. Block: spacing-dependent safety. | Challenge delayed gap. | `two_phase_strike` hold delay. |
| Chrome Rush | `6+SP` | Spacing dash | Browser speed and polished movement theme. | Tip-only plus frames reward precision rather than blind rush. | Hit: carry starter. Block: plus only at tip. | Step in to deny tip spacing. | `dash_strike_spacing_curve`. |
| Android Swarm | `2+SP` | Stagger summon | Android ecosystem swarm metaphor. | Staggered mini-hits maintain pressure in controllable cadence. | Hit: stagger into approach. Block: layered chip. | Jump before second pulse. | `summon_stagger_hits`. |
| Default Engine | `SP+HVY` | Neutral install | "Default" reliability and platform stability. | Install improves consistency metrics (speed/recovery) over burst. | Hit: safer conversions. Block: safer pressure loops. | Stall timer with defense. | `install_buff` movement + recovery. |

## 4.10 Jensen Hwang

Design pillar: compute-powered escalation and lead snowball.

| Skill | Cmd | Type | Creative Source | Mechanic Rationale (Why This Design) | Hit / Block | Counterplay | V1 Implementation Hook |
|---|---|---|---|---|---|---|---|
| CUDA Barrage | `N+SP` | Projectile burst | CUDA parallel shot fantasy. | Multi-shot sequence rewards lead pressure and corner push. | Hit: extender at close range. Block: escalating pushback. | Jump first shot, disrupt chain close-up. | `projectile_burst_3`. |
| Tensor Core Smash | `6+SP` | Armor-break overhead | Heavy compute hardware impact motif. | Big overhead with armor break punishes passive tanking. | Hit: high stagger/knockdown threat. Block: very unsafe. | Backdash/poke startup punish. | `overhead_slam` + `armor_break`. |
| RTX Flash | `2+SP` | Vision disruption | RTX lighting burst meme. | Brief visual disruption creates read pressure without hard disable. | Hit: short disorient + confirm chance. Block: chip + visual noise. | Play by audio/spacing, compact guard. | `flash_debuff` short duration. |
| Blackwell Overclock | `SP+HVY` | Damage install | Overclocking GPU concept. | Temporary acceleration + damage boost captures snowball identity. | Hit: amplified offense. Block: oppressive windows. | Kite timer, force non-damaging use. | `install_buff` startup/damage multipliers. |

## 4.11 Satya Nadello

Design pillar: calm defense converted into clean offense.

| Skill | Cmd | Type | Creative Source | Mechanic Rationale (Why This Design) | Hit / Block | Counterplay | V1 Implementation Hook |
|---|---|---|---|---|---|---|---|
| Cloud Pivot | `N+SP` | Counter stance | Cloud pivot strategy and adaptive posture. | Defensive stance into jab conversion reflects defense-to-offense identity. | Hit: counter launch. | Throw and delay beat stance. | `counter_stance` class filter. |
| GitHub Fork | `6+SP` | Copy profile | Forking code and reusing structure. | Mirroring last normal turns opponent habits into liability. | Hit: mirrored punish route. Block: risk from copied slow moves. | Vary normals to deny strong copy. | `copy_last_attack_profile`. |
| Teams Mute | `2+SP` | Silence debuff | Mute control metaphor from communication apps. | Disabling specials briefly creates tactical denial without full stun. | Hit: silence 1.2s target. Block: reduced/no silence. | Use normals while muted; avoid contact range. | `on_hit_silence_debuff`. |
| Enterprise Stack | `SP+HVY` | Multi-layer install | Enterprise stack layering and stability. | Layered utility buff (guard/meter/safety) supports strategic tempo control. | Hit: stronger stable conversions. Block: safer long exchanges. | Force Satya into defense until expiry. | `multi_buff_install`. |

## 4.12 Tim Cuke

Design pillar: precision discipline and option shaping.

| Skill | Cmd | Type | Creative Source | Mechanic Rationale (Why This Design) | Hit / Block | Counterplay | V1 Implementation Hook |
|---|---|---|---|---|---|---|---|
| iPhone Arc | `N+SP` | Precision slash | Hardware polish and edge perfection motif. | Tip-range bonus enforces exact spacing mastery. | Hit: tip bonus stun/dmg. Block: safe at tip only. | Crowd Tim's range band. | `range_sensitive_bonus`. |
| Airdrop Snap | `6+SP` | Position swap | Instant transfer metaphor (airdrop). | Hit-confirmed swap creates elegant positional punish play. | Hit: side swap + edge. Block: no swap, Tim minus. | Keep out close range, jump read. | `on_hit_position_swap`. |
| M-Series Burst | `2+SP` | Startup buff | Performance chip burst analogy. | Temporary startup reduction rewards planned offense windows. | No direct hit needed. | Pressure activation, burn timer. | `queued_startup_buff`. |
| Ecosystem Lock | `SP+HVY` | Option limiter field | Closed ecosystem metaphor. | Temporary movement-option constraint forces predictable responses. | Hit: route trap. Block: zone chip. | Escape field early with movement resource. | `zone_field_debuff`. |

## 4.13 Jack Dorsee

Design pillar: tempo disruption and timing ambiguity.

| Skill | Cmd | Type | Creative Source | Mechanic Rationale (Why This Design) | Hit / Block | Counterplay | V1 Implementation Hook |
|---|---|---|---|---|---|---|---|
| Square Swipe | `N+SP` | Fast linear check | Payment swipe / feed swipe gesture motif. | Fast check tool establishes tempo and interrupts greedy approach. | Hit: quick reset knockback. Block: slight minus. | Bait and whiff punish. | `fast_linear_slash`. |
| Block Chain | `6+SP` | Delayed chain | Blockchain confirmation delay metaphor. | Built-in gap models delayed confirmation and punishes panic mashing. | Hit: delayed carry confirm. Block: gap can be challenged. | Lab the gap and challenge cleanly. | `multihit_with_gap_index`. |
| Tweet Storm Classic | `2+SP` | Accelerating projectile | Legacy feed posts that suddenly trend. | Slow-then-fast velocity curve catches late movement decisions. | Hit: late movement catch. Block: chip + push after accel. | Early jump or pre-hit close startup. | `projectile_velocity_curve`. |
| Decentralized Knockout | `SP+HVY` | Multi-phase timing ult | Decentralized, non-linear rhythm concept. | Variable beat timings prevent one defensive rhythm from solving all phases. | Hit: full chain if read wrong. Block: late phase punish windows. | Defend early, punish predictable finisher. | `timing_variant_phase_chain`. |

## 4.14 Travis Kalanik

Design pillar: aggressive lane theft and armored commitment.

| Skill | Cmd | Type | Creative Source | Mechanic Rationale (Why This Design) | Hit / Block | Counterplay | V1 Implementation Hook |
|---|---|---|---|---|---|---|---|
| Surge Pricing | `N+SP` | Risk-reward buff | Dynamic surge pricing reference. | Damage/chip up with defense tax embodies profit-vs-risk tradeoff. | Hit: bigger conversions. Block: stronger chip threat. | Turtle and punish overextension. | `install_buff` offense up defense down. |
| Ride Share Rush | `6+SP` | Two-stage charge | Ride-share pickup into second impact rhythm. | Optional stage 2 creates greed decision with punish risk. | Hit: carry/wall threat. Block: stage2 punishable. | Block stage1 then punish extension. | `charge_2stage`. |
| Black Car Crash | `2+SP` | Armored dash | Black car crash-force visual. | Armor dash lets Travis force entry against light pokes. | Hit: wall-splat style knockback. Block: long end-lag risk. | Throw/multi-hit/backdash punish. | `armored_dash` armor_hp + endlag. |
| City Takeover | `SP+HVY` | Lane assault ult | City-scale expansion motif. | Alternating lane assaults create macro movement test under pressure. | Hit: cinematic carry + KD. Block: high chip in corner. | Read lane order and escape early. | `lane_dash_sequence`. |

## 4.15 Reed Hestings

Design pillar: long-form sequence planning and pressure retention.

| Skill | Cmd | Type | Creative Source | Mechanic Rationale (Why This Design) | Hit / Block | Counterplay | V1 Implementation Hook |
|---|---|---|---|---|---|---|---|
| Auto-Play String | `N+SP` | Loop pressure | Auto-play binge continuation metaphor. | Loop string models relentless sequence pressure and decision fatigue. | Hit: loop-to-KD routes. Block: tight but escapable pressure. | Challenge loop gap or jump before lock. | `loop_string` branch cancel. |
| Binge Buffer | `6+SP` | Input utility buff | Binge queue behavior and continuous flow. | Buffer extension improves execution consistency for planned strings. | No direct hit needed. | Force defense to waste buff window. | `input_buffer_buff`. |
| Skip Intro Kick | `2+SP` | Fast engage | "Skip intro" immediate jump-to-content joke. | Instant engage punishes passive spacing and slow setup starts. | Hit: momentum steal. Block: minus but hard to whiff punish at tip. | Pre-emptive low-profile or bait range. | `quick_lunge_kick`. |
| Streaming Collapse | `SP+HVY` | Escalating sequence ult | Streaming load escalation concept. | Each beat speeding up emulates compounding pressure over time. | Hit: escalating route damage. Block: prolonged guard stress. | Burst out early before pace ramps. | `escalating_phase_chain`. |

## 4.16 Steve Jobz (Legend Boss)

Design pillar: mythic precision exam and phase-distortion pressure.

| Skill | Cmd | Type | Creative Source | Mechanic Rationale (Why This Design) | Hit / Block | Counterplay | V1 Implementation Hook |
|---|---|---|---|---|---|---|---|
| Keynote Cut | `N+SP` | Precision opener | Keynote reveal precision and stage control. | Narrow safe band rewards mastery and punishes sloppy spacing. | Hit: high opener stun. Block: safe only at exact band. | Step out of ideal band and punish. | `precision_strike` safe-band check. |
| Reality Distortion Arc | `6+SP` | Variable-speed overhead | Reality-distortion charisma and expectation break. | Mid-arc speed shift breaks defensive rhythm memory. | Hit: heavy anti-crouch stagger. Block: punishable if read. | Delayed stand/fuzzy guard. | `variable_speed_attack`. |
| One More Thing | `2+SP` | Feint retreat re-entry | Famous "one more thing" surprise reveal beat. | Fake retreat then re-entry weaponizes overchasing reactions. | Hit: whiff punish + side chance. Block: minus on read. | Hold center, do not chase retreat instantly. | `feint_retreat` + reentry branch. |
| Think Different | `SP+HVY` | Phase install | Brand-defining phase shift concept. | Temporary move-table rewrite creates true boss-phase feeling. | Hit: unpredictable pressure trees. Block: high cognitive load. | Survive phase timer with safe defense. | `phase_install` temporary move profile swap. |

## 5. Implementation Backlog Proposal

1. Build reusable effect primitives in combat core:
   - projectile, trap, summon, teleport, stance, install, debuff, arena/zone modifier.
2. Implement full behavior for Wave 1 first:
   - Elon, Mark, Sam, Peter, Zef, Bill, Sundar, Jensen.
3. Implement Wave 2 and Wave 3 kits.
4. Add meter/Hype system and enable ultimates.
5. Add Steve Jobz boss-only phase variants and encounter scripting.

## 6. Discussion Questions

- Should ultimate usage be round-limited, meter-limited, or both?
- Should silence disable only specials, or also special-cancel routes?
- Should traps/summons be destructible, and by which move classes?
- Should summon ownership persist when caster is hit?
- Which 3 fighters should anchor baseline matchup speed in first balance pass?

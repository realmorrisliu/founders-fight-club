# Character Pixel Art Pipeline (Godot + Aseprite)

This document defines a repeatable pipeline for producing multiple fighter characters and animations for Founders Fight Club.

The goals are:
- Keep visual style consistent across many characters
- Ship new characters quickly with a template-based workflow
- Match the runtime expectations in `scripts/Player.gd`
- Avoid animation jitter and import mistakes

## 1. Scope and Runtime Contract

Current runtime character animation source:
- `assets/sprites/player/PlayerSpriteFrames.tres`

Runtime-required animation names (must exist):
- `idle`
- `walk`
- `jump`
- `light`
- `heavy`
- `special`
- `throw`
- `block`
- `hit_light`
- `hit_heavy`
- `hit`
- `fall`
- `getup`
- `ko`

Important runtime behavior:
- `scripts/Player.gd` enforces animation speed/loop defaults for required animations.
- Artists should focus on frame quality, silhouette readability, and consistent anchoring.
- Missing animations fall back to placeholder frames, but production assets should not rely on fallback.

## 2. V1 Character Art Standard

Use this standard for all prototype-era fighters unless the team explicitly upgrades to V2.

### Canvas and alignment

- Canvas size (all frames for one character): `24x48` pixels
- Coordinate origin: top-left
- Baseline (ground contact line): `y = 47` (0-based)
- Default body center / stance anchor target: `x = 12`
- Keep feet planted on the same baseline for grounded idle/walk/block/hit poses unless intentional
- Avoid per-frame vertical jitter unless the pose is a jump, fall, knockdown, or impact reaction

### Silhouette and style

- Outline thickness: `1px` outer contour
- Light direction: top-left (consistent across all characters)
- Use clear pose exaggeration for attack readability over detail density
- Keep facial details minimal at this scale; prioritize head shape / hair silhouette / accessories

### Palette rules (recommended)

- Shared global ramps (workspace-wide):
  - Skin: 3-4 tones
  - Neutral darks: 3 tones
  - Neutral lights: 2-3 tones
- Per-character ramps:
  - Primary costume color: 3 tones
  - Secondary color: 2-3 tones
  - Accent color: 1-2 tones
- Total target palette per character sprite set: ~12-20 colors
- Reuse ramps across characters when possible to preserve style and speed up production

## 3. Multi-Character Production Strategy

To create many fighters efficiently, do not animate every character from scratch.

### Template-first approach

Build and maintain reusable animation templates by body type:
- `human_slim_v1`
- `human_medium_v1` (recommended first template)
- `human_heavy_v1`

Each template should include the full required animation set.

### Character variance layers

Create new characters mostly through:
- Head shape / hair
- Glasses / beard / hat / headphones
- Jacket / hoodie / shirt silhouette
- Palette swaps
- Small accessory offsets

Then add a small number of bespoke frames for identity:
- 1-2 unique attack poses (`special`, `heavy`, or `throw`)
- Unique VFX colors or callout art (optional later)

Recommended allocation per new character:
- 70% template reuse
- 20% visual customization
- 10% bespoke animation polish

## 4. Directory and File Naming Convention

### Current runtime-compatible assets (existing)

- `assets/sprites/player/PlayerSpriteFrames.tres`
- `assets/sprites/player/first_pass/*.png`

### Recommended scalable structure for multiple characters (new)

Use one folder per character:

```text
assets/
  sprites/
    characters/
      founder_alpha/
        source/
          aseprite/
            founder_alpha_v001.aseprite
          prompts/
            prompt_v001.txt
          refs/
            pose_reference_sheet.png
        raw/
        clean/
        exports/
          idle_0.png
          idle_1.png
          walk_0.png
          ...
        review/
        FounderAlphaSpriteFrames.tres
        character_manifest.json
      founder_beta/
        source/
        exports/
        FounderBetaSpriteFrames.tres
  data/
    characters/
      FounderAlphaAttackTable.tres
      FounderBetaAttackTable.tres
```

Naming rules:
- Character folder id: `snake_case` (example: `founder_alpha`)
- SpriteFrames resource file: `PascalCase` + `SpriteFrames.tres`
- Attack table resource file: `PascalCase` + `AttackTable.tres`
- Exported frame files: `<animation_name>_<index>.png`
- Frame index starts at `0` and is contiguous (`0,1,2...`)
- Animation names must exactly match the runtime-required names above

## 5. Aseprite File Template Standard

Use one `.aseprite` source file per character (or per template) that contains all required animations.

### Required animation tags

Create Aseprite tags with these exact names:
- `idle`
- `walk`
- `jump`
- `light`
- `heavy`
- `special`
- `throw`
- `block`
- `hit_light`
- `hit_heavy`
- `hit`
- `fall`
- `getup`
- `ko`

### Recommended layer structure

- `guides` (hidden on export)
- `shadow_preview` (optional, hidden on export)
- `body_base`
- `costume`
- `head_hair`
- `accessories`
- `fx_preview` (optional, hidden on export)
- `notes` (hidden on export)

Rules:
- Keep guide/reference layers hidden before export
- Do not resize canvas mid-production
- Do not trim individual frames before export

### Pivot / anchor discipline

Because Godot will display frames directly from textures, anchor consistency is critical.

Use one of these methods and keep it consistent:
- A fixed pixel marker on a hidden guide layer for the stance anchor
- A fixed "foot contact" guide line at `y=47`

Before export, scrub each tag and verify:
- Grounded loops do not float or sink
- Head does not jitter horizontally unless intentional

## 6. Animation Specs (V1)

The runtime currently applies animation FPS defaults in `scripts/Player.gd`.

Use this table as the production target. "Min" means acceptable for prototype throughput. "Target" means better readability/polish.

| Animation | Code FPS | Loop | Min Frames | Target Frames | Notes |
|---|---:|:---:|---:|---:|---|
| `idle` | 8 | Yes | 2 | 2-4 | Breathing + small head/shoulder motion |
| `walk` | 11 | Yes | 4 | 4-6 | Clear contact/pass poses; avoid foot slide |
| `jump` | 9 | No | 2 | 3-4 | Lift-off + airborne apex; landing uses other states |
| `light` | 18 | No | 3 | 3-4 | Fast readability: startup, hit, recovery |
| `heavy` | 9 | No | 3 | 4-5 | Strong anticipation + follow-through |
| `special` | 10 | No | 3 | 4-6 | Distinct silhouette from `heavy` |
| `throw` | 12 | No | 3 | 4-5 | Grab/readability pose > realism |
| `block` | 8 | Yes | 2 | 2-3 | Idle guard with clear defensive silhouette |
| `hit_light` | 11 | No | 2 | 2-3 | Short recoil; readable head/torso snap |
| `hit_heavy` | 8 | No | 2 | 3 | Bigger recoil, stronger pose break |
| `hit` | 10 | No | 2 | 2-3 | Generic fallback reaction |
| `fall` | 8 | No | 2 | 2-3 | Airborne knockdown / collapse progression |
| `getup` | 9 | No | 3 | 4-5 | Ground -> rise -> ready |
| `ko` | 1 | No | 1 | 1-2 | Final defeated pose; usually static |

Notes:
- Current first-pass repository assets already satisfy the minimum for all required animations.
- Add frames only when they improve readability or match gameplay timing.
- Do not add complexity that makes `light` look as slow as `heavy`.

## 7. Attack Readability Rules (Gameplay-Driven)

Animation should support gameplay semantics already present in the prototype.

### `light`
- Fast, compact, low anticipation
- Hit frame should read instantly in 1 glance
- Keep recovery visually short

### `heavy` (currently overhead semantic)
- Strong anticipation
- Clear "high" strike silhouette (raise arm/weapon/body line)
- Bigger recoil/follow-through than `light`

### `special` (currently low semantic in attack data)
- Distinct forward/lunging intent
- Lower body commitment / forward reach silhouette
- Should not be mistaken for `heavy`

### `throw`
- Clear grab pose before impact/launch
- Do not rely on target sprite to explain the move

### Defensive and reactions
- `block` must be readable even at a glance
- `hit_light` and `hit_heavy` should be visibly different in amplitude
- `fall` / `getup` should communicate state clearly for gameplay timing

## 8. Export Rules (Aseprite -> PNG Frames)

Export one PNG per frame with transparent background.

Requirements:
- RGBA PNG
- No scaling during export
- No trimming/cropping
- Preserve canvas size for every exported frame
- Export hidden layers: off
- Frame numbering starts at 0

Filename template:
- `<tag>_<frame>.png`

Examples:
- `light_0.png`
- `light_1.png`
- `light_2.png`

### Aseprite export options (example)

Use Aseprite UI export or CLI. If using CLI, keep tags and filenames aligned.

Example pattern (adjust for your local Aseprite version):

```bash
aseprite -b founder_alpha_v001.aseprite --split-tags --save-as exports/{tag}_{frame}.png
```

If your Aseprite version formats frame numbers differently, rename outputs to match the repository convention.

## 9. Godot Import and Wiring Checklist

### Texture import settings (per PNG)

For crisp pixel rendering:
- Filter: `Nearest`
- Mipmaps: `Off`
- Compression: `Lossless` (or uncompressed if needed)

### SpriteFrames setup

Per character:
1. Duplicate an existing `SpriteFrames.tres` as a starting point.
2. Name it `PascalCaseSpriteFrames.tres`.
3. Fill all required animations with the exported frames.
4. Verify animation names exactly match runtime contract.
5. Verify playback looks correct in Godot preview.

Runtime note:
- `scripts/Player.gd` will apply speed/loop defaults for required animations.

### Character scene wiring

When adding a new playable/opponent character:
- Assign the character `SpriteFrames` resource to the player scene instance (`sprite_frames_resource`) or by scene variant
- Assign the character `AttackTable` resource (`attack_table_resource`)

Keep art and gameplay data separate:
- Art changes should not require attack table edits
- Balance changes should not require sprite export edits

## 10. Quality Gate (Before Commit)

A character animation set is "ready for integration" only if all items pass.

### Asset completeness

- All required animations exist
- No missing frame indices in any animation
- No accidental duplicate exports with wrong names
- Source `.aseprite` file is included in `source/`

### Visual consistency

- Grounded animations share baseline alignment
- No unintentional jitter in idle/walk/block
- Attack silhouettes are readable against arena background
- Character still reads well when horizontally flipped

### Gameplay readability

- `light` vs `heavy` vs `special` are distinguishable
- `overhead`-looking attacks read high
- `low`-looking attacks read low
- `throw` startup reads as grab attempt
- `hit_light` / `hit_heavy` / `fall` are visually distinct

### Import correctness

- Pixel filtering remains sharp in Godot
- SpriteFrames previews play expected loops/non-loops
- In-match playback shows no offset jitter

## 11. Versioning and Iteration Rules

Use simple versioning for source art:
- `founder_alpha_v001.aseprite`
- `founder_alpha_v002.aseprite`

Rules:
- Do not overwrite a source file before a risky redesign pass
- Exports may be regenerated, but source art should preserve milestones
- Note major art changes in `docs/CHANGELOG.md` when they affect gameplay readability or asset structure

## 12. Suggested Next Steps (Practical)

1. Promote the current `assets/sprites/player/first_pass/` set into a named template character (recommended: medium body template).
2. Create one Aseprite master template file with:
   - `24x48` canvas
   - guide layers
   - all required tags
   - palette ramps
3. Produce a second character using mostly template reuse plus a unique `special`.
4. Verify the second character in `Training.tscn` before creating more.

This validates the pipeline before scaling up character count.

## 13. Automation Scripts (Developer Workflow)

The repository includes helper scripts for AI-assisted asset production:

- `scripts/tools/validate_character_exports.py`
  - Validates filename format, frame index continuity, and canvas size
- `scripts/tools/generate_character_manifest.py`
  - Generates a JSON manifest (frame inventory + embedded validation results)
- `scripts/tools/batch_pixelize.sh`
  - Normalizes AI-generated images into fixed-size PNG frames for review
- `scripts/tools/init_character_asset_dirs.sh`
  - Creates the standard per-character AI asset workspace (`source/raw/clean/exports/review`)
- `scripts/tools/ImportCharacterSpriteFrames.gd`
  - Builds a `SpriteFrames.tres` resource directly from an `exports/` folder via Godot CLI

### Validate an export folder

```bash
python3 scripts/tools/validate_character_exports.py assets/sprites/player/first_pass --require-all
```

### Generate a character manifest

```bash
python3 scripts/tools/generate_character_manifest.py \
  assets/sprites/characters/founder_alpha/exports \
  --require-all
```

Default output:
- `assets/sprites/characters/founder_alpha/character_manifest.json`

### Batch-process AI outputs into a fixed pixel canvas

```bash
scripts/tools/batch_pixelize.sh \
  --input-dir /path/to/ai-exports \
  --output-dir /path/to/normalized-frames \
  --width 24 \
  --height 48 \
  --colors 24
```

Optional flags:
- `--remove-bg` (requires `rembg`)
- `--skip-quantize` (skip `pngquant`)
- `--dry-run`

### Initialize a character asset workspace

```bash
scripts/tools/init_character_asset_dirs.sh founder_alpha
```

### Build SpriteFrames from exports (Godot CLI)

```bash
godot --headless --path . --script scripts/tools/ImportCharacterSpriteFrames.gd -- \
  --exports res://assets/sprites/characters/founder_alpha/exports \
  --output res://assets/sprites/characters/founder_alpha/FounderAlphaSpriteFrames.tres \
  --require-all
```

See also:
- `docs/AI_ASSET_WORKFLOW.md` for an end-to-end AI-assisted production workflow

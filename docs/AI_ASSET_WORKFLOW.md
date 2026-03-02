# AI-Assisted Character Asset Workflow (Developer-Friendly)

This workflow is for developers with little or no drawing experience.

For API-key-driven bulk generation automation, see:
- `docs/AI_AUTOMATION_WORKFLOW.md`

The key idea:
- AI generates candidate art and key poses
- Scripts enforce naming, sizing, and structure
- Godot imports the final frames into `SpriteFrames.tres`

## 1. Directory Template (Per Character)

Use this standard workspace for each character:

```text
assets/sprites/characters/<character_id>/
  source/
    aseprite/      # Aseprite source files (template + edits)
    prompts/       # prompts, seeds, model settings, notes
    refs/          # pose refs / concept refs / control images
  raw/             # raw AI outputs
  clean/           # selected + cleaned intermediate images
  exports/         # final runtime PNGs: <animation>_<index>.png
  review/          # contact sheets / GIF previews / comparisons
  <PascalCase>SpriteFrames.tres
  character_manifest.json
```

Create the structure with:

```bash
scripts/tools/init_character_asset_dirs.sh founder_alpha
```

## 2. Minimal Production Loop (5 Animations First)

For a new character, validate the pipeline with:
- `idle`
- `walk`
- `light`
- `heavy`
- `special`

Do not start with all 14 animations on day 1.

## 3. AI Output to Runtime-Ready Frames

### Step A: Generate into `raw/`

Put raw AI outputs in:
- `assets/sprites/characters/<character_id>/raw/`

Recommended to store metadata in:
- `assets/sprites/characters/<character_id>/source/prompts/`

### Step B: Curate into `clean/`

Manually select the best candidates and move/copy them to:
- `assets/sprites/characters/<character_id>/clean/`

At this stage you can do lightweight fixes (background cleanup, silhouette edits).

### Step C: Normalize with `batch_pixelize.sh`

Convert the curated images to fixed-size PNGs:

```bash
scripts/tools/batch_pixelize.sh \
  --input-dir assets/sprites/characters/<character_id>/clean \
  --output-dir assets/sprites/characters/<character_id>/exports \
  --width 24 \
  --height 48 \
  --colors 24 \
  --overwrite
```

Optional flags:
- `--remove-bg` (requires `rembg`)
- `--skip-quantize` (if you want to preserve colors for manual polish)
- `--no-trim` (if trimming hurts alignment)

## 4. Export Naming Rules (Critical)

Godot import and runtime expect:
- `<animation>_<index>.png`

Examples:
- `idle_0.png`
- `walk_3.png`
- `light_2.png`

Animation names must match `scripts/Player.gd`:
- `idle`, `walk`, `jump`, `light`, `heavy`, `special`, `throw`, `block`
- `hit_light`, `hit_heavy`, `hit`, `fall`, `getup`, `ko`

## 5. Validation and Manifest Generation

Validate the export folder:

```bash
python3 scripts/tools/validate_character_exports.py \
  assets/sprites/characters/<character_id>/exports \
  --require-all
```

Generate manifest (frame inventory + embedded validation):

```bash
python3 scripts/tools/generate_character_manifest.py \
  assets/sprites/characters/<character_id>/exports \
  --require-all
```

Default output:
- `assets/sprites/characters/<character_id>/character_manifest.json`

## 6. Godot Auto-Import into `SpriteFrames.tres`

Use the Godot CLI import script to build/update a `SpriteFrames` resource from `exports/`.

```bash
godot --headless --path . --script scripts/tools/ImportCharacterSpriteFrames.gd -- \
  --exports res://assets/sprites/characters/<character_id>/exports \
  --output res://assets/sprites/characters/<character_id>/<PascalCase>SpriteFrames.tres \
  --require-all \
  --verbose
```

Example:

```bash
godot --headless --path . --script scripts/tools/ImportCharacterSpriteFrames.gd -- \
  --exports res://assets/sprites/characters/founder_alpha/exports \
  --output res://assets/sprites/characters/founder_alpha/FounderAlphaSpriteFrames.tres \
  --require-all
```

Notes:
- The script applies animation FPS/loop defaults aligned with `scripts/Player.gd`
- Use `--dry-run` first if you only want to inspect detected frames

## 7. Command Templates (Copy/Paste)

Replace placeholders before running.

### Initialize a character workspace

```bash
scripts/tools/init_character_asset_dirs.sh <character_id>
```

### Normalize curated AI frames

```bash
scripts/tools/batch_pixelize.sh \
  --input-dir assets/sprites/characters/<character_id>/clean \
  --output-dir assets/sprites/characters/<character_id>/exports \
  --width 24 --height 48 --colors 24 --overwrite
```

### Validate exports

```bash
python3 scripts/tools/validate_character_exports.py \
  assets/sprites/characters/<character_id>/exports \
  --require-all
```

### Generate manifest

```bash
python3 scripts/tools/generate_character_manifest.py \
  assets/sprites/characters/<character_id>/exports \
  --require-all
```

### Build SpriteFrames resource with Godot

```bash
godot --headless --path . --script scripts/tools/ImportCharacterSpriteFrames.gd -- \
  --exports res://assets/sprites/characters/<character_id>/exports \
  --output res://assets/sprites/characters/<character_id>/<PascalCase>SpriteFrames.tres \
  --require-all
```

## 8. Recommended First Milestone

For your first AI-driven character:
1. Create `founder_alpha`
2. Ship only 5 animations (`idle/walk/light/heavy/special`)
3. Run in `Training.tscn`
4. Fix alignment/readability
5. Then complete the remaining defensive/reaction states

This keeps scope small and validates the pipeline before scaling.

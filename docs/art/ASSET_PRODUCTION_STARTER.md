# Asset Production Starter

This is the production entrypoint for replacing procedural placeholder art with real generated assets.

The repository is now configured for a Gemini-first workflow:

- `pro` -> `gemini-3-pro-image-preview`
- `nano2` -> `gemini-3.1-flash-image-preview`

## What Exists Now

- Project style lock: `assets/pipeline/style_lock.yaml`
- Character briefs: `assets/pipeline/character_briefs/*.yaml`
- Stage briefs: `assets/pipeline/stage_briefs/*.yaml`
- Optional reference pack workspace: `assets/pipeline/reference_packs/`
- Marketing art manifest: `assets/pipeline/asset_manifest.csv`
- Runtime art manifest: `assets/pipeline/runtime_asset_manifest.csv`
- Prompt pack exporter: `scripts/tools/export_asset_prompt_pack.py`
- API generation script: `scripts/tools/auto_generate_assets.py`
- Gemini execution guide: `docs/art/GEMINI_ASSET_WORKFLOW.md`

## Primary Workflows

### 1. Export prompt packs for manual generation

```bash
python3 scripts/tools/export_asset_prompt_pack.py \
  --manifest assets/pipeline/asset_manifest.csv \
  --status queued \
  --characters elon_mvsk,mark_zuck,sam_altmyn,peter_thyell,zef_bezos,bill_geytz,sundar_pichoy,jensen_hwang \
  --bundle-name "Wave 1 Marketing Art" \
  --output-dir assets/pipeline/prompt_packs/wave1_marketing
```

```bash
python3 scripts/tools/export_asset_prompt_pack.py \
  --manifest assets/pipeline/runtime_asset_manifest.csv \
  --status queued \
  --bundle-name "Runtime Core Art" \
  --output-dir assets/pipeline/prompt_packs/runtime_core
```

### 2. Generate images through model APIs

Dry run first:

```bash
python3 scripts/tools/auto_generate_assets.py \
  --manifest assets/pipeline/runtime_asset_manifest.csv \
  --dry-run \
  --status queued \
  --limit 10 \
  --verbose
```

Then generate:

```bash
python3 scripts/tools/auto_generate_assets.py \
  --manifest assets/pipeline/runtime_asset_manifest.csv \
  --status queued \
  --route-stage first \
  --write-back
```

### 3. Gemini multi-turn / reference-image workflow

The manifest supports optional row fields:

- `reference_paths`
- `edit_source_path`
- `aspect_ratio`
- `image_size`
- `media_resolution`

Use `reference_paths` for side references or anchor sheets.
Use `edit_source_path` when you want Gemini to revise an existing generated image.

You can reference previously generated assets with `asset:<asset_id>`.

Example from runtime art:

- `grand_arena_stage_floor` references `asset:grand_arena_stage_background`
- `mark_zuck_sprite_keypose_sheet` references `asset:mark_zuck_sprite_turnaround`

Example dry run:

```bash
python3 scripts/tools/auto_generate_assets.py \
  --manifest assets/pipeline/runtime_asset_manifest.csv \
  --characters mark_zuck \
  --asset-types sprite_turnaround,sprite_keypose_sheet \
  --dry-run \
  --verbose
```

After the turnaround is generated, rerun the keypose row and Gemini will attach it automatically through the `asset:` reference.

## Recommended Order

1. `grand_arena_stage_background`
2. `grand_arena_stage_floor`
3. `combat_hit_spark_sheet`
4. `combat_signature_trails_sheet`
5. `wave1` character `sprite_turnaround`
6. `wave1` character `sprite_keypose_sheet`
7. Select portraits and hero splash refinement

## Gemini Route Guidance

- `pro`: stage background/floor/key art, turnarounds, key-pose sheets, select portraits, hero splash, rivalry cards
- `nano2`: skill icons, dialogue portraits, VFX sheets, fast variants

Use `pro` for identity-defining assets.
Use `nano2` for throughput and iteration.

## Review Rule

Do not approve an asset just because it is detailed.

- Stage art must fill the window and feel like a venue.
- Character art must read instantly at small size.
- Sprite reference sheets must prioritize consistent proportions.
- VFX sheets must communicate gameplay classes, not just “look cool”.

# Gemini Asset Workflow

This project now treats Gemini as the default image-production path for real art assets.

## Model Roles

- `pro` -> `gemini-3-pro-image-preview`
- `nano2` -> `gemini-3.1-flash-image-preview`

Use `pro` when identity and consistency matter.
Use `nano2` when throughput matters.

## Best Fit By Asset Type

- `pro`
  - stage background
  - stage floor
  - stage key art
  - sprite turnaround sheets
  - sprite key-pose sheets
  - select portraits
  - hero splash
  - rivalry cards
  - event key art
- `nano2`
  - skill icons
  - dialogue portraits
  - VFX motif sheets
  - fast concept variants

## Core Production Pattern

Do not ask Gemini for final runtime sprite sheets first.

Use this order:

1. Generate `sprite_turnaround`
2. Approve silhouette, palette, props, and body proportions
3. Generate `sprite_keypose_sheet` using `reference_paths=asset:<character>_sprite_turnaround`
4. Use the approved key-pose sheet as human reference for sprite cleanup / Aseprite / pixel workflow
5. Generate splash, dialogue, and UI-facing art only after character identity is stable

The same rule applies to stages:

1. Generate `stage_background`
2. Generate `stage_floor` referencing the background
3. Generate `stage_keyart` after the environment language is stable

## Manifest Fields

Optional Gemini-oriented fields supported by `scripts/tools/auto_generate_assets.py`:

- `reference_paths`
  - Pipe-separated paths or generated-asset references
  - Example: `asset:mark_zuck_sprite_turnaround|assets/pipeline/reference_packs/style/show_lighting_board.png`
- `edit_source_path`
  - Single image to revise in-place through Gemini
- `aspect_ratio`
  - Example: `1:1`, `4:3`, `16:9`
- `image_size`
  - Example: `1K`, `2K`, `4K`
- `media_resolution`
  - Example: `MEDIA_RESOLUTION_HIGH`, `MEDIA_RESOLUTION_MEDIUM`

## Commands

Export prompt pack:

```bash
python3 scripts/tools/export_asset_prompt_pack.py \
  --manifest assets/pipeline/runtime_asset_manifest.csv \
  --status queued \
  --bundle-name "Runtime Core Art" \
  --output-dir assets/pipeline/prompt_packs/runtime_core
```

Dry-run a single character:

```bash
python3 scripts/tools/auto_generate_assets.py \
  --manifest assets/pipeline/runtime_asset_manifest.csv \
  --characters mark_zuck \
  --asset-types sprite_turnaround,sprite_keypose_sheet \
  --dry-run \
  --verbose
```

Generate only turnaround sheets first:

```bash
python3 scripts/tools/auto_generate_assets.py \
  --manifest assets/pipeline/runtime_asset_manifest.csv \
  --asset-types sprite_turnaround \
  --status queued \
  --write-back
```

Generate key-pose sheets after turnarounds exist:

```bash
python3 scripts/tools/auto_generate_assets.py \
  --manifest assets/pipeline/runtime_asset_manifest.csv \
  --asset-types sprite_keypose_sheet \
  --status queued \
  --write-back
```

Generate Wave 1 marketing portraits and splash:

```bash
python3 scripts/tools/auto_generate_assets.py \
  --manifest assets/pipeline/asset_manifest.csv \
  --characters elon_mvsk,mark_zuck,sam_altmyn,peter_thyell,zef_bezos,bill_geytz,sundar_pichoy,jensen_hwang \
  --status queued \
  --write-back
```

## Review Rules

- Do not approve a turnaround with inconsistent head/body ratios.
- Do not approve a key-pose sheet if side view drift appears.
- Do not approve stage art with boxed-in center playfields or side gutters.
- Do not approve VFX sheets that look cool but fail to separate gameplay classes.

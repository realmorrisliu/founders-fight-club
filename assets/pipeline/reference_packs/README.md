# Reference Packs

Drop local reference images here when you want Gemini to condition on existing art direction.

Recommended structure:

- `assets/pipeline/reference_packs/style/`
- `assets/pipeline/reference_packs/characters/<character_id>/`
- `assets/pipeline/reference_packs/stages/<stage_id>/`

Then point manifest rows at those files through:

- `reference_paths`
- `edit_source_path`

Examples:

- `assets/pipeline/reference_packs/style/show_lighting_board.png`
- `assets/pipeline/reference_packs/characters/mark_zuck/octagon_pose_anchor.png`
- `assets/pipeline/reference_packs/stages/grand_arena/floor_material_board.png`

You can also reference already-generated repo assets with `asset:<asset_id>`.

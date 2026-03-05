# Docs Index

This directory is organized by purpose so production docs stay easy to find.

## Structure

```text
docs/
  README.md
  CHANGELOG.md
  art/
  content/
  project/
```

## Art Docs (`docs/art/`)

- `AI_AUTOMATION_WORKFLOW.md`
  - API-key-based bulk image generation workflow (`auto_generate_assets.py`)
- `AI_ART_TEMPLATE_PACK.md`
  - Style lock, manifest templates, prompt templates, QA checklist
- `AI_ASSET_WORKFLOW.md`
  - Character asset production loop from AI output to runtime-ready exports
- `ART_PIPELINE.md`
  - Detailed pixel pipeline standards and naming/runtime contract
- `AI_ART_EXECUTION_GUIDE_2026.md`
  - Model routing strategy, rollout plan, and risk controls

Recommended read order for asset production:
1. `AI_AUTOMATION_WORKFLOW.md`
2. `AI_ART_TEMPLATE_PACK.md`
3. `AI_ASSET_WORKFLOW.md`
4. `ART_PIPELINE.md`

## Content Docs (`docs/content/`)

- `CONTENT_BIBLE.md`
  - High-level launch narrative and roster direction
- `ROSTER_16_DETAIL.md`
  - Detailed sheets for all 16 fighters
- `SPECIAL_SKILL_DESIGN_V1.md`
  - Full per-fighter Signature A/B/C + Ultimate gameplay design spec
- `ROSTER_16_DEV_TABLE.md`
  - Balance/production matrix and wave priorities
- `WAVE1_ATTACKTABLE_DRAFT.md`
  - Wave 1 attack table parameter draft
- `DIALOGUE_PACK_V1.md`
  - Dialogue pack format and integration notes

Recommended read order for gameplay content:
1. `CONTENT_BIBLE.md`
2. `ROSTER_16_DEV_TABLE.md`
3. `ROSTER_16_DETAIL.md`
4. `SPECIAL_SKILL_DESIGN_V1.md`
5. `DIALOGUE_PACK_V1.md`

## Project Docs (`docs/project/`)

- `MVP.md`
  - MVP scope and early goals
- `TEST_PLAN.md`
  - Test/verification checklist
- `SKILL_IMPLEMENTATION_TASKS.md`
  - Step-by-step task backlog and automated test gates for roster skill rollout
- `SKILL_RUNTIME_ARCHITECTURE.md`
  - Runtime skill system architecture, data contract, and coverage strategy
- `LOADOUT_ITEM_SYSTEM_SPEC.md`
  - Implementation-ready spec for fixed-slot loadouts, character-linked items, evolution, and round-between tuning
- `LOADOUT_BALANCE_QA_MATRIX.md`
  - Phase E wave-1 tuning table, balance checklist, and QA coverage matrix for the loadout/item system
- `ENGINEERING_MODULE_GUIDELINES.md`
  - Module boundaries, dependency direction, refactor thresholds, and test gates

## Change Tracking

- `CHANGELOG.md` is kept at `docs/` root as the single timeline of notable doc/gameplay/pipeline updates.

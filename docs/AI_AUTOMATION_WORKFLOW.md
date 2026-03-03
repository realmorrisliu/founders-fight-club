# AI Asset Automation Workflow (Manifest + API Keys)

This guide describes the end-to-end automation flow using:
- `assets/pipeline/asset_manifest.csv`
- `assets/pipeline/character_briefs/*.yaml`
- `scripts/tools/auto_generate_assets.py`

The pipeline is built for bulk generation with model routing per asset row.

## 1) What The Script Does

`scripts/tools/auto_generate_assets.py`:
- reads asset rows from manifest by status filter,
- builds prompts from character briefs + asset type,
- resolves `model_route` (for example `nano2->gpt15`),
- calls provider APIs (Google/OpenAI/Volcengine),
- saves outputs under `assets/generated/<character_id>/`,
- writes metadata json per generated image,
- optionally updates manifest status/path/review note.

## 2) Required Environment Variables

Set only the keys you need for the selected route stage/provider.

```bash
export GOOGLE_API_KEY="your_google_key"
export OPENAI_API_KEY="your_openai_key"
export VOLCENGINE_API_KEY="your_volcengine_key"
# optional (default is Ark Beijing base URL)
export VOLCENGINE_API_BASE_URL="https://ark.cn-beijing.volces.com/api/v3"
```

Notes:
- Keep keys in local shell env or local `.env` (ignored by `.gitignore`).
- Never commit keys to repository files.
- Volcengine key can also be provided as `ARK_API_KEY`.

## 2.1) `model_route` Tokens

Built-in short tokens:
- `nano2`, `pro`, `gpt15`
- `doubao40`, `doubao45`, `doubao5lite`

Also supported:
- full model ids (for example `gemini-3.1-flash-image-preview`, `gpt-image-1.5-2025-12-16`, `doubao-seedream-4.5`)
- Ark endpoint IDs (for example `ep-...`)
- explicit Volcengine route form: `volc:<model_or_endpoint_id>`

## 3) Dry Run First (No API Calls)

```bash
python3 scripts/tools/auto_generate_assets.py \
  --dry-run \
  --status queued \
  --limit 10 \
  --verbose
```

This verifies:
- row selection,
- prompt generation,
- model routing,
- output planning.

## 4) First-Pass Batch Generation

Use first route hop (default), usually `nano2` from `nano2->gpt15`.

```bash
python3 scripts/tools/auto_generate_assets.py \
  --status queued \
  --route-stage first \
  --limit 40 \
  --write-back
```

Recommended:
- start with one character first (`--characters elon_mvsk`),
- then scale to full Wave 1.

To run on Doubao directly, set manifest rows to routes like `doubao45` or `doubao45->gpt15`.

## 5) Selective Refinement Pass

Use manifest status and filters to target specific rows.

Example: rerun only hero splash assets with last route hop:

```bash
python3 scripts/tools/auto_generate_assets.py \
  --status generated \
  --asset-types hero_splash \
  --route-stage last \
  --limit 8 \
  --force \
  --write-back
```

Important:
- v1 script does regeneration by prompt route, not image-to-image editing.
- Keep refinement set small and curated.

## 6) Useful Filters

- `--characters elon_mvsk,mark_zuck`
- `--asset-types portrait_select,skill_icon`
- `--status queued,backlog`
- `--limit 20`
- `--max-errors 3`

## 7) Output Layout

```text
assets/generated/
  <character_id>/
    <asset_id>.<ext>
    <asset_id>.json
```

Metadata JSON contains:
- provider/model,
- prompt text,
- source row info,
- timestamp,
- raw API response payload.

## 8) Suggested Operating Policy

1. Run dry-run on every new manifest change.
2. Generate by wave (`wave1` first).
3. Human-approve P0 assets before refinement.
4. Run second pass only for failed QA rows.
5. Keep manifest status authoritative.

## 9) Example Wave 1 Commands

### 9.1 Start with two characters

```bash
python3 scripts/tools/auto_generate_assets.py \
  --status queued \
  --characters elon_mvsk,mark_zuck \
  --route-stage first \
  --limit 20 \
  --write-back
```

### 9.2 Generate all Wave 1 queued rows

```bash
python3 scripts/tools/auto_generate_assets.py \
  --status queued \
  --route-stage first \
  --write-back
```

### 9.3 Re-run only select portraits

```bash
python3 scripts/tools/auto_generate_assets.py \
  --status generated \
  --asset-types portrait_select \
  --route-stage last \
  --force \
  --limit 8 \
  --write-back
```

### 9.4 Run only Doubao rows

```bash
python3 scripts/tools/auto_generate_assets.py \
  --status queued \
  --characters elon_mvsk \
  --route-stage first \
  --write-back
```

Use manifest routes such as:
- `doubao45`
- `doubao5lite`
- `doubao45->gpt15`

## 10) Current Limitations

- No built-in image-to-image edit chain yet (generation-only in v1).
- Provider-side size support may vary by model/API version.
- Prompt quality still determines consistency; keep style lock stable.

Use this as v1 automation base, then evolve to add edit chains and post-processing.

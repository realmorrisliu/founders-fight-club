# AI Character Art Template Pack (v2026-03)

This template pack is for producing the launch roster (16 characters) with consistent style, faster iteration, and easier integration into Godot.

Use this together with:
- `docs/AI_ASSET_WORKFLOW.md`
- `docs/ART_PIPELINE.md`

---

## 1) Style Lock Card Template

Copy and fill once before mass generation. Do not change this mid-wave unless you do a full re-baseline.

```md
# Style Lock Card v1
project: Founders Fight Club
genre: 2D satirical-comedic fighter
render_style: stylized cartoon, not photoreal
line_weight: medium-bold outlines
color_direction: high contrast, high readability on mobile
silhouette_priority: very high (recognizable at 128x128)
background_rule: plain or minimal gradient (easy cutout)
camera_rule: bust / half-body / full-body only
forbidden:
  - photoreal face texture
  - exact real-world trademark/logo copy
  - realistic gore
```

---

## 2) Asset Manifest Template

Create `assets/pipeline/asset_manifest.csv` and track production status.

```csv
asset_id,character_id,asset_type,shot,expression,priority,width,height,model_route,status,review_note,file_path
elon_mvsk_portrait_select,elon_mvsk,portrait_select,bust,smirk,P0,1024,1024,nano2->gpt15,wip,,
elon_mvsk_skill_x_blast,elon_mvsk,skill_icon,icon,aggressive,P0,512,512,nano2,queued,,
elon_mvsk_hero_splash,elon_mvsk,hero_splash,full_body,confident,P0,2048,2048,nano2->pro,wip,,
```

### Suggested `asset_type`
- `portrait_select` (character select avatar)
- `hero_splash` (menu/banner)
- `skill_icon` (base/special/ultimate icons)
- `dialogue_portrait` (pre-fight / victory)
- `event_keyart` (story event frame)

---

## 3) Character Brief Template

One brief per character in `assets/pipeline/character_briefs/<character_id>.yaml`.

```yaml
character_id: elon_mvsk
display_name: "Elon Mvsk"
parody_target: "well-known tech founder archetype"
hook: "rocket + social media + EV pressure play"
silhouette_keys: ["spiky_hair","tech_jacket","rocket_glow"]
palette: ["#121212","#00AEEF","#F25F4C"]
must_have_props: ["phone-like social app device","mini rocket","futuristic sports EV cue"]
forbidden_props: ["exact Tesla logo","exact X logo","exact product UI screenshot"]
skills:
  - name: "X Pulse"
    visual: "blue rumor-wave projectile"
  - name: "Orbital Drop"
    visual: "top-down rocket pressure zone"
```

---

## 4) Prompt Templates

### 4.1 Base Prompt Skeleton

```txt
[STYLE LOCK v1]
2D fighting game character art, satirical-comedic, stylized cartoon, bold outlines, high contrast colors, clean silhouette, game-ready, no photorealism.

[CHARACTER]
{display_name}, parody of a famous tech founder archetype, exaggerated expression, signature props: {must_have_props}

[SHOT]
{shot_type}, {camera}, {pose}, {expression}, plain background.

[OUTPUT]
{width}x{height}, readable at thumbnail size, minimal background clutter.

[NEGATIVE]
photoreal skin texture, exact real-world logo copy, realistic gore, blurry hands, text-heavy UI
```

### 4.2 Character Select Portrait Prompt

```txt
Use STYLE LOCK v1.
Create a character select portrait for {display_name}.
Bust shot, 3/4 front angle, confident expression.
Keep signature prop hint: {prop_1}.
Plain background.
Output 1024x1024.
```

### 4.3 Skill Icon Prompt

```txt
Use STYLE LOCK v1.
Create a clean game skill icon for "{skill_name}".
One central action motif, no tiny details, no text.
High contrast silhouette, transparent-friendly composition.
Output 512x512.
```

---

## 5) Per-Character Minimum Launch Set

For each of the 16 launch characters, ship this minimum first:
- 1x `portrait_select` (1024)
- 1x `hero_splash` (2048)
- 4x `skill_icon` (512)
- 2x `dialogue_portrait` (pre-fight / victory)

Then expand:
- 1x rivalry intro card
- 1x story-event card

---

## 6) Naming and Folder Convention

Keep generated source and runtime assets separated.

```text
assets/
  pipeline/
    asset_manifest.csv
    character_briefs/
  sprites/
    characters/<character_id>/
      source/
      raw/
      clean/
      exports/
      review/
```

Naming:
- Character id: `snake_case`
- Runtime asset file: `<character_id>_<asset_type>_<variant>.png`
- Keep frame names compatible with `docs/ART_PIPELINE.md` when exporting animation frames.

---

## 7) QA Checklist Template

Use this checklist before marking `status=done`.

```md
- [ ] Blind recognizability: 5 testers, >=4 can identify the parody target
- [ ] Thumbnail readability: still clear at 256x256
- [ ] Consistency: hair / palette / prop unchanged vs anchor
- [ ] Skill semantics: icon meaning is clear without text
- [ ] Compliance: no exact trademark copy, no photoreal public figure rendering
- [ ] Runtime check: imported and visible in Godot scene/HUD
```

---

## 8) Route Preset (Recommended)

- Batch generation: `Nano Banana 2`
- Hero/complex key art: `Nano Banana Pro`
- Precision edits and style alignment: `GPT-Image-1.5`

Keep route metadata in `model_route` so later replacements are auditable.

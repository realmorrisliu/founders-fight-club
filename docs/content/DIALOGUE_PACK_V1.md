# Dialogue Pack v1

Structured dialogue draft for launch 16 roster.

## 1. Source File

- `assets/data/dialogue/DialoguePackV1.json`

## 2. Coverage

- 16 fighters:
  - 2 intro lines (EN/ZH) each
  - 2 win lines (EN/ZH) each
- 8 rivalry exchanges with pre-fight and post-fight snippets (EN/ZH)
- 6 story event blocks:
  - `cold_open`
  - `board_coup`
  - `main_event`
  - `legend_encounter`
  - `ending_open_stack`
  - `ending_walled_garden`

## 3. JSON Shape

```json
{
  "version": "v1",
  "fighters": {
    "fighter_id": {
      "name": "Display Name",
      "intro": {"en": ["..."], "zh": ["..."]},
      "win": {"en": ["..."], "zh": ["..."]}
    }
  },
  "rivalries": [
    {
      "id": "pair_id",
      "fighters": ["fighter_a", "fighter_b"],
      "pre_fight": {"en": ["..."], "zh": ["..."]},
      "post_fight": {"en": ["..."], "zh": ["..."]}
    }
  ],
  "story_events": {
    "event_id": {"en": ["..."], "zh": ["..."]}
  }
}
```

## 4. Integration Notes

- Keep lines short for HUD readability and meme clipping.
- Use fighter IDs from the same naming convention as `AttackTable.character_id`.
- For runtime selection:
  - Intro: random choose one of `intro`.
  - Win: random choose one of `win`.
  - Rivalry: if exact pair match, prefer rivalry lines over generic lines.


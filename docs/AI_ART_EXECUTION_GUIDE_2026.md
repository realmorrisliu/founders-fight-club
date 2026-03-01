# AI Art Execution Guide (Founders Fight Club, 2026-03-02)

This guide translates the latest model research into a practical, ship-focused production plan for the launch roster.

---

## 1) Target and Constraints

Target:
- Produce character-related art for 16 launch fighters fast enough for social rollout.
- Keep style consistent across menu, select portraits, dialogue portraits, skill icons, and key story/event images.

Constraints:
- Satirical parody tone (recognizable but stylized, not photoreal).
- Cross-language release (EN/ZH UI and social posts).
- Open-source distribution and public visibility.

---

## 2) Current Model Landscape (Verified in Research)

As of 2026-03-02:
- Google batch model: `gemini-3.1-flash-image-preview` (Nano Banana 2)
- Google high-fidelity model: `gemini-3-pro-image-preview` (Nano Banana Pro Preview)
- OpenAI image model: `gpt-image-1.5-2025-12-16` (GPT-Image-1.5)

Working interpretation for this project:
- Nano Banana 2 = high throughput and good cost/perf for large asset queues.
- Nano Banana Pro = stronger for complex key art and multi-character scenes.
- GPT-Image-1.5 = strong iterative editing / detail correction / style alignment pass.

---

## 3) Recommended Model Routing

Use deterministic routing by asset priority:

| Priority | Asset Type | Primary Route | Fallback |
|---|---|---|---|
| P0 | select portrait, hero splash, core skill icons | nano2 -> gpt15 | nano2 -> pro |
| P1 | rivalry cards, dialogue portraits | nano2 | nano2 -> gpt15 |
| P2 | optional social variants, meme alternates | nano2 only | skip if schedule risk |

Rules:
- Do not send everything to the expensive route.
- Keep one route per asset family to reduce style drift.
- Escalate only failed QA assets to Pro/GPT-Image pass.

---

## 4) End-to-End Production Workflow

1. Freeze style:
- Lock `Style Lock Card v1` once (see `docs/AI_ART_TEMPLATE_PACK.md`).

2. Define character anchors:
- For each character: `face_anchor`, `full_body_anchor`, `signature_pose_anchor`.

3. Batch generation:
- Use Nano Banana 2 for first-pass sets (6-8 candidates per asset).

4. Curate and anchor:
- Pick 1 candidate per asset as anchor.
- Reject assets with silhouette ambiguity immediately.

5. Edit rounds:
- Round A: expression and pose cleanup.
- Round B: prop consistency and color alignment.
- Round C: readability and anti-clutter.

6. Escalation pass:
- Only P0 failures go to Nano Banana Pro or GPT-Image-1.5.

7. Integration and runtime check:
- Import to project folders.
- Verify in menu/select/HUD scene context.

8. Final QA gate:
- Run checklist from template pack.

---

## 5) 16-Character Rollout Plan

### Wave plan
- Wave 1 (8 fighters): ship all P0 assets first.
- Wave 2 (8 fighters): same template with no style-policy change.

### Suggested 7-day schedule
1. Day 1: freeze style card + finalize 16 character briefs.
2. Day 2: Wave 1 portraits + core icons batch.
3. Day 3: Wave 1 hero splash and dialogue portraits.
4. Day 4: integrate Wave 1 and do in-engine readability checks.
5. Day 5: Wave 2 portraits + core icons batch.
6. Day 6: Wave 2 hero/dialogue + global consistency pass.
7. Day 7: publish pack prep (social tiles, short video frames, fallback variants).

---

## 6) Definition of Done (Per Character)

A character is `content_ready` only if:
- `portrait_select`, `hero_splash`, `4x skill_icon`, `2x dialogue_portrait` exist.
- All items are tracked in `asset_manifest.csv` with final path and model route.
- Blind recognizability passes target.
- Compliance checklist is signed off by a human reviewer.

---

## 7) Risk Controls (Important)

For public-figure parody projects:
- Keep visuals stylized and exaggerated; avoid photoreal face reproduction.
- Avoid exact trademark/logo cloning.
- Keep audit trail of prompt + route + selected outputs.
- Add a final human review step for legal/policy-sensitive content before publishing.

This guide is a production workflow, not legal advice.

---

## 8) Team Operating Rules

- Never change style lock mid-wave.
- Never merge unreviewed P0 assets into release branch.
- If timeline slips, cut P2 first (not P0 consistency).
- Replace controversial assets quickly using manifest-driven IDs.

---

## 9) Sources Used in Research

- Google blog (Nano Banana 2 update):  
  https://blog.google/innovation-and-ai/technology/ai/nano-banana-2/
- Gemini image generation docs:  
  https://ai.google.dev/gemini-api/docs/image-generation
- Gemini API pricing:  
  https://ai.google.dev/gemini-api/docs/pricing
- Gemini 3.1 Flash Image model card:  
  https://deepmind.google/models/model-cards/gemini-3-1-flash-image/
- OpenAI GPT-Image-1.5 model docs:  
  https://developers.openai.com/api/docs/models/gpt-image-1.5
- OpenAI image generation guide/API references:  
  https://developers.openai.com/api/docs/guides/tools-image-generation  
  https://platform.openai.com/docs/api-reference/images/createEdit%3Flang%3Dpython
- OpenAI usage policies:  
  https://openai.com/policies/usage-policies/

#!/usr/bin/env python3
"""Shared prompt-building helpers for the art production pipeline."""

from __future__ import annotations

import ast
import re
from pathlib import Path
from typing import Any


DEFAULT_STYLE_LOCK = {
	"project": "Founders Fight Club",
	"visual_target": "A playful platform-fighter spirit packaged with premium modern 2D fighter spectacle.",
	"render_style": "Stylized 2D game art, satirical-comedic, bold outlines, graphic shapes, no photorealism.",
	"combat_readability": "Prioritize strong silhouettes, high contrast, and thumbnail readability before detail density.",
	"stage_rule": "Stage art must feel full-bleed and showtime-ready, never like a test room or boxed-in backdrop.",
	"sprite_rule": "Sprite references must stay side-view, grounded, orthographic-feeling, and consistent in body proportions.",
	"ui_rule": "UI assets should feel premium and punchy, with broadcast-show energy instead of flat debug panels.",
	"must_have_global": [
		"clear silhouette hierarchy",
		"premium tournament-show lighting",
		"graphic color separation",
	],
	"avoid_global": [
		"photoreal faces",
		"exact real-world trademarks",
		"flat gray voids",
		"blurry details",
	],
}


def parse_inline_value(value: str) -> Any:
	value = value.strip()
	if not value:
		return ""
	if value.startswith('"') and value.endswith('"'):
		return value[1:-1]
	if value.startswith("'") and value.endswith("'"):
		return value[1:-1]
	if value.startswith("[") and value.endswith("]"):
		try:
			parsed = ast.literal_eval(value)
			if isinstance(parsed, list):
				return [str(x) for x in parsed]
		except Exception:
			pass
	return value


def load_structured_yaml(path: Path) -> dict[str, Any]:
	if not path.exists():
		return {}

	text = path.read_text(encoding="utf-8")

	try:
		import yaml  # type: ignore

		loaded = yaml.safe_load(text)
		if isinstance(loaded, dict):
			return loaded
	except Exception:
		pass

	data: dict[str, Any] = {}
	current_list_key: str | None = None
	current_list_item: dict[str, Any] | None = None

	for raw_line in text.splitlines():
		line = raw_line.rstrip()
		if not line.strip() or line.strip().startswith("#"):
			continue

		indent = len(raw_line) - len(raw_line.lstrip(" "))
		stripped = line.strip()

		if stripped.startswith("- ") and current_list_key:
			item_raw = stripped[2:].strip()
			data.setdefault(current_list_key, [])
			target_list = data[current_list_key]
			if not isinstance(target_list, list):
				target_list = []
				data[current_list_key] = target_list

			if ":" in item_raw:
				key, _, value_raw = item_raw.partition(":")
				item: dict[str, Any] = {key.strip(): parse_inline_value(value_raw)}
				target_list.append(item)
				current_list_item = item
			else:
				target_list.append(parse_inline_value(item_raw))
				current_list_item = None
			continue

		match = re.match(r"^([A-Za-z0-9_]+)\s*:\s*(.*)$", stripped)
		if not match:
			continue

		key = match.group(1)
		value_raw = match.group(2)
		if indent > 0 and current_list_item is not None:
			current_list_item[key] = parse_inline_value(value_raw)
			continue

		current_list_item = None
		if value_raw == "":
			current_list_key = key
			data.setdefault(key, [])
		else:
			current_list_key = None
			data[key] = parse_inline_value(value_raw)

	return data


def load_style_lock(path: Path | None) -> dict[str, Any]:
	if path is None or not path.exists():
		return DEFAULT_STYLE_LOCK.copy()

	loaded = load_structured_yaml(path)
	style_lock = DEFAULT_STYLE_LOCK.copy()
	style_lock.update(loaded)
	return style_lock


def humanize_slug(slug: str) -> str:
	parts = [p for p in slug.split("_") if p]
	return " ".join(p.capitalize() for p in parts)


def safe_list(data: dict[str, Any], key: str) -> list[str]:
	value = data.get(key, [])
	if isinstance(value, list):
		return [str(v) for v in value if str(v).strip()]
	return []


def slugify(value: str) -> str:
	return re.sub(r"[^a-z0-9]+", "_", value.lower()).strip("_")


def extract_skill_slug(asset_id: str) -> str:
	match = re.search(r"_skill_([a-z0-9_]+)$", asset_id)
	if not match:
		return ""
	return match.group(1)


def extract_skill_entry(brief: dict[str, Any], asset_id: str) -> dict[str, Any]:
	skill_slug = extract_skill_slug(asset_id)
	if not skill_slug:
		return {}
	for item in brief.get("skills", []):
		if not isinstance(item, dict):
			continue
		name = str(item.get("name", ""))
		if slugify(name) == skill_slug:
			return item
	return {}


def get_subject_id(row: dict[str, str]) -> str:
	stage_id = str(row.get("stage_id", "")).strip()
	character_id = str(row.get("character_id", "")).strip()
	if character_id:
		return character_id
	if stage_id:
		return stage_id
	return "global"


def get_output_bucket(row: dict[str, str]) -> str:
	return get_subject_id(row)


def load_subject_brief(
	row: dict[str, str],
	character_brief_dir: Path,
	stage_brief_dir: Path,
) -> dict[str, Any]:
	character_id = str(row.get("character_id", "")).strip().lower()
	if character_id:
		return load_structured_yaml(character_brief_dir / f"{character_id}.yaml")
	stage_id = str(row.get("stage_id", "")).strip().lower()
	if stage_id:
		return load_structured_yaml(stage_brief_dir / f"{stage_id}.yaml")
	return {}


def build_style_lock_text(style_lock: dict[str, Any]) -> str:
	project = str(style_lock.get("project", DEFAULT_STYLE_LOCK["project"]))
	visual_target = str(style_lock.get("visual_target", DEFAULT_STYLE_LOCK["visual_target"]))
	render_style = str(style_lock.get("render_style", DEFAULT_STYLE_LOCK["render_style"]))
	combat_readability = str(style_lock.get("combat_readability", DEFAULT_STYLE_LOCK["combat_readability"]))
	stage_rule = str(style_lock.get("stage_rule", DEFAULT_STYLE_LOCK["stage_rule"]))
	sprite_rule = str(style_lock.get("sprite_rule", DEFAULT_STYLE_LOCK["sprite_rule"]))
	ui_rule = str(style_lock.get("ui_rule", DEFAULT_STYLE_LOCK["ui_rule"]))
	must_have = ", ".join(safe_list(style_lock, "must_have_global"))
	avoid = ", ".join(safe_list(style_lock, "avoid_global"))

	return (
		f"{project}. {visual_target} {render_style} "
		f"{combat_readability} {stage_rule} {sprite_rule} {ui_rule} "
		f"Global must-haves: {must_have}. Avoid: {avoid}."
	)


def build_subject_text(row: dict[str, str], brief: dict[str, Any]) -> str:
	character_id = str(row.get("character_id", "")).strip()
	stage_id = str(row.get("stage_id", "")).strip()
	display_name = str(
		brief.get("display_name")
		or brief.get("stage_name")
		or humanize_slug(character_id or stage_id or "global asset")
	)
	hook = str(brief.get("hook") or brief.get("fantasy") or "Distinct showpiece game asset").rstrip(". ")
	return f"{display_name}. {hook}."


def _build_stage_asset_task(row: dict[str, str], brief: dict[str, Any]) -> str:
	asset_type = str(row.get("asset_type", "")).strip().lower()
	layers = ", ".join(safe_list(brief, "layers"))
	props = ", ".join(safe_list(brief, "must_have_props"))

	if asset_type == "stage_background":
		return (
			"Create a full-bleed 2D fighter stage background plate. Wide cinematic composition, "
			"no characters, clear horizon depth, designed to fill the entire 16:9 frame without side gutters. "
			f"Include stage layers such as {layers}. Keep visible props: {props}."
		)
	if asset_type == "stage_floor":
		return (
			"Create the matching arena floor layer for a side-view 2D fighter. "
			"Foreground lane, reflective material breakup, rim-lit edges, no characters, "
			"perspective aligned with a combat camera and ready to tile/extend horizontally. "
			f"Keep visible props: {props}."
		)
	if asset_type == "stage_keyart":
		return (
			"Create promotional key art for the stage itself. "
			"Show the arena as a premium spectacle venue with depth fog, LED architecture, crowd glow, "
			"and a readable centerline focal lane. No empty framing voids."
		)
	return (
		"Create a premium stage support asset for a 2D fighter presentation layer, full-bleed and production-ready."
	)


def _build_character_asset_task(row: dict[str, str], brief: dict[str, Any]) -> str:
	asset_type = str(row.get("asset_type", "")).strip().lower()
	asset_id = str(row.get("asset_id", "")).strip()
	expression = str(row.get("expression", "")).strip() or "focused"
	shot = str(row.get("shot", "")).strip() or "full_body"
	skill_entry = extract_skill_entry(brief, asset_id)
	skill_name = str(skill_entry.get("name", humanize_slug(extract_skill_slug(asset_id) or "signature skill")))
	skill_visual = str(skill_entry.get("visual", "")).strip()

	if asset_type == "portrait_select":
		return (
			"Create a premium character-select portrait. Bust shot, 3/4 angle, strong read at thumbnail size, "
			f"expression={expression}, minimal background, clean roster consistency."
		)
	if asset_type == "hero_splash":
		return (
			"Create hero splash art. Full-body dominant pose, high-end tournament-poster composition, "
			"graphic motion accents, minimal but atmospheric background, readable focal silhouette."
		)
	if asset_type == "dialogue_portrait":
		return (
			"Create a combat dialogue portrait. Bust shot, clear mouth/eye expression, "
			f"expression={expression}, minimal background, consistent with the roster's premium satirical style."
		)
	if asset_type == "rivalry_intro_card":
		return (
			"Create a rivalry intro card image. Half-body standoff framing, taunt energy, "
			"broadcast-event polish, clean compositional separation for title overlays."
		)
	if asset_type == "event_keyart":
		return (
			"Create story-event key art. Dynamic action beat, strong theatrical lighting, "
			"social-ready framing, full-body emphasis, and clear meme-worthy storytelling."
		)
	if asset_type == "skill_icon":
		return (
			f'Create a clean gameplay skill icon for "{skill_name}". One central action motif, no text, '
			f"readable at 128x128, transparent-friendly silhouette. Visual direction: {skill_visual or 'clear signature motion motif'}."
		)
	if asset_type == "sprite_turnaround":
		return (
			"Create a character turnaround sheet for 2D fighter production. "
			"Include front 3/4, combat side view, back 3/4, and prop callouts. "
			"Keep proportions locked, side-view combat readability high, plain background."
		)
	if asset_type == "sprite_keypose_sheet":
		return (
			"Create a sprite reference key-pose sheet for 2D fighter animation. "
			"Include idle, walk contact, walk passing, jump rise, jump apex, light attack, heavy attack, signature attack, block, and hit recoil. "
			f"Use the character's signature move language such as {skill_visual or skill_name}. "
			"Orthographic-feeling side-view presentation, plain background, no perspective camera."
		)
	return (
		f"Create production-ready character art for asset_type={asset_type}. "
		"Keep silhouette clarity, prop consistency, and showmanship."
	)


def _build_global_asset_task(row: dict[str, str]) -> str:
	asset_type = str(row.get("asset_type", "")).strip().lower()
	asset_id = str(row.get("asset_id", "")).strip().lower()

	if asset_type == "vfx_sheet":
		if "guard" in asset_id or "counter" in asset_id:
			return (
				"Create a VFX concept sheet for guard sparks and counter bursts. "
				"Show 6 to 9 clean motifs on a dark neutral backdrop: deflection arcs, shield sparks, counter starbursts, and ring impacts."
			)
		if "signature" in asset_id or "trail" in asset_id:
			return (
				"Create a VFX concept sheet for signature trails. "
				"Show 6 to 9 motifs on a dark neutral backdrop: afterimage sweeps, aura rings, trap glyphs, dash streaks, and ground scrape traces."
			)
		return (
			"Create a VFX concept sheet for combat impact effects. "
			"Show 6 to 9 motifs on a dark neutral backdrop: hit sparks, slash bursts, radial rings, and smoke pops."
		)
	if asset_type == "ui_panel_pack":
		return (
			"Create a UI panel pack for a flashy satirical fighter. "
			"Include menu panels, HUD chips, choice cards, and pause/result panels on one cohesive sheet. "
			"Premium event-broadcast feel, clean edge highlights, minimal clutter."
		)
	return "Create a premium support asset for the game's visual package."


def build_prompt(row: dict[str, str], brief: dict[str, Any], style_lock: dict[str, Any]) -> str:
	asset_type = str(row.get("asset_type", "")).strip().lower()
	width = str(row.get("width", "1024")).strip()
	height = str(row.get("height", "1024")).strip()
	props = ", ".join(safe_list(brief, "must_have_props"))
	palette = ", ".join(safe_list(brief, "palette"))
	silhouette = ", ".join(safe_list(brief, "silhouette_keys"))
	forbidden = ", ".join(safe_list(brief, "forbidden_props"))
	rivals = ", ".join(safe_list(brief, "rival_hooks"))

	if str(row.get("stage_id", "")).strip():
		task = _build_stage_asset_task(row, brief)
	elif str(row.get("character_id", "")).strip():
		task = _build_character_asset_task(row, brief)
	else:
		task = _build_global_asset_task(row)

	negative_items = safe_list(style_lock, "avoid_global")
	if forbidden:
		negative_items.append(forbidden)
	negative_items.extend(
		[
			"low-resolution mush",
			"muddy lighting",
			"text overlays",
			"background clutter hiding the silhouette",
		]
	)
	negative = ", ".join([item for item in negative_items if item])

	lines = [
		f"[STYLE LOCK] {build_style_lock_text(style_lock)}",
		f"[SUBJECT] {build_subject_text(row, brief)}",
	]
	if silhouette:
		lines.append(f"[SILHOUETTE] {silhouette}.")
	if props:
		lines.append(f"[PROPS] Keep visible cues: {props}.")
	if palette:
		lines.append(f"[PALETTE] Target palette: {palette}.")
	if rivals:
		lines.append(f"[RIVAL CONTEXT] Rival hooks: {rivals}.")
	lines.extend(
		[
			f"[TASK] {task}",
			f"[OUTPUT] {width}x{height}.",
			f"[NEGATIVE] {negative}.",
		]
	)
	return "\n".join(lines)

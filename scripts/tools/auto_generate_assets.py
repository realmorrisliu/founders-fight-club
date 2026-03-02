#!/usr/bin/env python3
"""Automated AI asset generation pipeline (manifest-driven).

Reads `assets/pipeline/asset_manifest.csv`, builds prompts from character briefs,
calls provider image APIs, saves outputs, and optionally writes back manifest status.
"""

from __future__ import annotations

import argparse
import ast
import base64
import csv
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


STYLE_LOCK_TEXT = (
	"2D fighting game character art, satirical-comedic, stylized cartoon, "
	"bold outlines, high contrast colors, clean silhouette, game-ready, no photorealism."
)

MODEL_TOKEN_MAP: dict[str, tuple[str, str]] = {
	"nano2": ("google", "gemini-3.1-flash-image-preview"),
	"pro": ("google", "gemini-3-pro-image-preview"),
	"gpt15": ("openai", "gpt-image-1.5-2025-12-16"),
}


@dataclass
class ModelSpec:
	provider: str
	model: str


@dataclass
class GeneratedAsset:
	image_path: Path
	metadata_path: Path
	provider: str
	model: str
	mime_type: str


def _build_parser() -> argparse.ArgumentParser:
	parser = argparse.ArgumentParser(
		description=(
			"Generate game assets from manifest rows by calling provider image APIs. "
			"Supports Google Gemini image models and OpenAI image models."
		)
	)
	parser.add_argument(
		"--manifest",
		default="assets/pipeline/asset_manifest.csv",
		help="Path to asset manifest CSV",
	)
	parser.add_argument(
		"--brief-dir",
		default="assets/pipeline/character_briefs",
		help="Directory containing character brief YAML files",
	)
	parser.add_argument(
		"--output-dir",
		default="assets/generated",
		help="Directory to write generated images/metadata",
	)
	parser.add_argument(
		"--status",
		default="queued",
		help="Comma-separated statuses to process (default: queued)",
	)
	parser.add_argument(
		"--characters",
		default="",
		help="Optional comma-separated character_id filter",
	)
	parser.add_argument(
		"--asset-types",
		default="",
		help="Optional comma-separated asset_type filter",
	)
	parser.add_argument(
		"--route-stage",
		choices=("first", "last"),
		default="first",
		help="Pick first/last hop from model_route (default: first)",
	)
	parser.add_argument(
		"--limit",
		type=int,
		default=0,
		help="Max number of rows to process (0 means no limit)",
	)
	parser.add_argument(
		"--sleep-seconds",
		type=float,
		default=0.8,
		help="Delay between API calls (default: 0.8)",
	)
	parser.add_argument(
		"--max-errors",
		type=int,
		default=5,
		help="Abort run when this many errors are hit (default: 5)",
	)
	parser.add_argument(
		"--success-status",
		default="generated",
		help="Manifest status set on success when --write-back is enabled",
	)
	parser.add_argument(
		"--write-back",
		action="store_true",
		help="Write updated status/file_path/review_note back to manifest",
	)
	parser.add_argument(
		"--dry-run",
		action="store_true",
		help="Do not call APIs or write files; print what would run",
	)
	parser.add_argument(
		"--force",
		action="store_true",
		help="Regenerate assets even if output image already exists",
	)
	parser.add_argument(
		"--verbose",
		action="store_true",
		help="Print prompt previews and API model routing",
	)
	return parser


def _normalize_list_arg(raw: str) -> set[str]:
	items = [x.strip().lower() for x in raw.split(",") if x.strip()]
	return set(items)


def _load_manifest(path: Path) -> tuple[list[dict[str, str]], list[str]]:
	if not path.exists():
		raise FileNotFoundError(f"Manifest not found: {path}")
	with path.open("r", encoding="utf-8", newline="") as f:
		reader = csv.DictReader(f)
		rows = list(reader)
		if not reader.fieldnames:
			raise ValueError(f"Manifest has no header: {path}")
		return rows, list(reader.fieldnames)


def _write_manifest(path: Path, rows: list[dict[str, str]], fieldnames: list[str]) -> None:
	with path.open("w", encoding="utf-8", newline="") as f:
		writer = csv.DictWriter(f, fieldnames=fieldnames)
		writer.writeheader()
		writer.writerows(rows)


def _parse_inline_value(value: str) -> Any:
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


def _load_character_brief(path: Path) -> dict[str, Any]:
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
	for raw_line in text.splitlines():
		line = raw_line.rstrip()
		if not line.strip() or line.strip().startswith("#"):
			continue
		if line.lstrip().startswith("- ") and current_list_key:
			value = line.strip()[2:].strip()
			data.setdefault(current_list_key, [])
			if isinstance(data[current_list_key], list):
				data[current_list_key].append(_parse_inline_value(value))
			continue

		m = re.match(r"^([A-Za-z0-9_]+)\s*:\s*(.*)$", line.strip())
		if not m:
			continue
		key = m.group(1)
		value_raw = m.group(2)
		if value_raw == "":
			current_list_key = key
			data.setdefault(key, [])
		else:
			current_list_key = None
			data[key] = _parse_inline_value(value_raw)
	return data


def _humanize_slug(slug: str) -> str:
	parts = [p for p in slug.split("_") if p]
	return " ".join(p.capitalize() for p in parts)


def _safe_list(brief: dict[str, Any], key: str) -> list[str]:
	value = brief.get(key, [])
	if isinstance(value, list):
		return [str(v) for v in value]
	return []


def _extract_skill_name_from_asset_id(asset_id: str) -> str:
	m = re.search(r"_skill_([a-z0-9_]+)$", asset_id)
	if not m:
		return "Signature Skill"
	return _humanize_slug(m.group(1))


def _build_prompt(row: dict[str, str], brief: dict[str, Any]) -> str:
	asset_type = (row.get("asset_type") or "").strip()
	asset_id = (row.get("asset_id") or "").strip()
	display_name = str(brief.get("display_name") or row.get("character_id") or "Unknown Fighter")
	hook = str(brief.get("hook") or "Distinct parody fighter identity")
	props = _safe_list(brief, "must_have_props")
	forbidden = _safe_list(brief, "forbidden_props")
	palette = _safe_list(brief, "palette")

	width = row.get("width", "1024").strip()
	height = row.get("height", "1024").strip()
	prop_text = ", ".join(props[:3]) if props else "signature prop cues"
	forbidden_text = ", ".join(forbidden) if forbidden else "exact real-world logos, photoreal faces"
	palette_text = ", ".join(palette[:3]) if palette else "high-contrast game palette"

	base = [
		f"[STYLE LOCK] {STYLE_LOCK_TEXT}",
		f"[CHARACTER] {display_name}. {hook}.",
		f"[PROPS] Keep visible cues: {prop_text}.",
		f"[PALETTE] Target palette: {palette_text}.",
	]

	if asset_type == "portrait_select":
		task = (
			"Create a character-select portrait. Bust shot, 3/4 front angle, confident expression, "
			"plain background, thumbnail-readable silhouette."
		)
	elif asset_type == "hero_splash":
		task = (
			"Create a hero splash art. Full-body dynamic pose, strong motion lines, minimal background, "
			"promo-ready composition."
		)
	elif asset_type == "skill_icon":
		skill_name = _extract_skill_name_from_asset_id(asset_id)
		task = (
			f'Create a clean gameplay skill icon for "{skill_name}". One central motif, no text, '
			"high contrast, readable at 128x128."
		)
	elif asset_type == "dialogue_portrait":
		expression = (row.get("expression") or "focused").strip()
		task = (
			f"Create a dialogue portrait for combat UI. Bust shot, expression={expression}, "
			"consistent with roster style, minimal background."
		)
	elif asset_type == "rivalry_intro_card":
		task = (
			"Create a rivalry intro card image. Half-body cinematic standoff framing, comedic taunt energy, "
			"dramatic but clean background."
		)
	elif asset_type == "event_keyart":
		task = (
			"Create a story event key art frame. Dynamic action moment, full-body emphasis, "
			"social-media-friendly composition."
		)
	else:
		task = (
			f"Create game-ready art for asset_type={asset_type}. Keep silhouette clear and style consistent."
		)

	base.extend(
		[
			f"[TASK] {task}",
			f"[OUTPUT] {width}x{height}.",
			f"[NEGATIVE] {forbidden_text}, realistic gore, blurry hands, dense tiny details.",
		]
	)
	return "\n".join(base)


def _resolve_model_spec(route_value: str, stage: str) -> ModelSpec:
	route = [x.strip().lower() for x in route_value.split("->") if x.strip()]
	if not route:
		raise ValueError(f"Invalid empty model_route: {route_value!r}")

	token = route[0] if stage == "first" else route[-1]

	if token in MODEL_TOKEN_MAP:
		provider, model = MODEL_TOKEN_MAP[token]
		return ModelSpec(provider=provider, model=model)

	if token.startswith("gemini-"):
		return ModelSpec(provider="google", model=token)
	if token.startswith("gpt-image"):
		return ModelSpec(provider="openai", model=token)

	raise ValueError(
		f"Unknown model route token: {token!r} from {route_value!r}. "
		"Use known tokens (nano2/pro/gpt15) or full model ids."
	)


def _json_http_post(url: str, headers: dict[str, str], payload: dict[str, Any], timeout: float = 90.0) -> dict[str, Any]:
	data = json.dumps(payload).encode("utf-8")
	request = urllib.request.Request(url=url, method="POST", headers=headers, data=data)
	try:
		with urllib.request.urlopen(request, timeout=timeout) as response:
			body = response.read()
	except urllib.error.HTTPError as e:
		body = e.read().decode("utf-8", errors="replace")
		raise RuntimeError(f"HTTP {e.code} error for {url}: {body}") from e
	except urllib.error.URLError as e:
		raise RuntimeError(f"Network error for {url}: {e}") from e

	try:
		return json.loads(body.decode("utf-8"))
	except Exception as e:
		raise RuntimeError(f"Failed to parse JSON response from {url}: {e}") from e


def _download_binary(url: str, timeout: float = 90.0) -> bytes:
	request = urllib.request.Request(url=url, method="GET")
	with urllib.request.urlopen(request, timeout=timeout) as response:
		return response.read()


def _call_openai_generate(model: str, prompt: str, width: int, height: int, api_key: str) -> tuple[bytes, str, dict[str, Any]]:
	url = "https://api.openai.com/v1/images/generations"
	headers = {
		"Authorization": f"Bearer {api_key}",
		"Content-Type": "application/json",
	}
	payload = {
		"model": model,
		"prompt": prompt,
		"size": f"{width}x{height}",
	}

	response_json = _json_http_post(url=url, headers=headers, payload=payload)
	data = response_json.get("data") or []
	if not data:
		raise RuntimeError(f"OpenAI response missing data array: {response_json}")
	item = data[0]

	if "b64_json" in item:
		raw = base64.b64decode(item["b64_json"])
		return raw, "image/png", response_json
	if "url" in item:
		raw = _download_binary(item["url"])
		return raw, "image/png", response_json
	raise RuntimeError(f"OpenAI response missing b64_json/url: {item}")


def _call_google_generate(model: str, prompt: str, api_key: str) -> tuple[bytes, str, dict[str, Any]]:
	base_url = f"https://generativelanguage.googleapis.com/v1beta/models/{urllib.parse.quote(model)}:generateContent"
	url = f"{base_url}?key={urllib.parse.quote(api_key)}"
	headers = {"Content-Type": "application/json"}
	payload = {
		"contents": [{"parts": [{"text": prompt}]}],
		"generationConfig": {"responseModalities": ["TEXT", "IMAGE"]},
	}

	response_json = _json_http_post(url=url, headers=headers, payload=payload)
	candidates = response_json.get("candidates") or []
	for candidate in candidates:
		content = candidate.get("content") or {}
		for part in content.get("parts") or []:
			inline_data = part.get("inlineData") or part.get("inline_data")
			if not inline_data:
				continue
			data = inline_data.get("data")
			if not data:
				continue
			mime_type = inline_data.get("mimeType") or inline_data.get("mime_type") or "image/png"
			return base64.b64decode(data), mime_type, response_json

	raise RuntimeError(f"Google response did not include inline image data: {response_json}")


def _mime_to_extension(mime_type: str) -> str:
	mime = mime_type.lower()
	if "png" in mime:
		return "png"
	if "jpeg" in mime or "jpg" in mime:
		return "jpg"
	if "webp" in mime:
		return "webp"
	return "png"


def _write_asset_files(
	row: dict[str, str],
	prompt: str,
	response_json: dict[str, Any],
	image_bytes: bytes,
	mime_type: str,
	output_dir: Path,
	model_spec: ModelSpec,
) -> GeneratedAsset:
	character_id = (row.get("character_id") or "unknown").strip()
	asset_id = (row.get("asset_id") or "unnamed_asset").strip()
	timestamp = datetime.now(timezone.utc).isoformat()
	ext = _mime_to_extension(mime_type)

	character_dir = output_dir / character_id
	character_dir.mkdir(parents=True, exist_ok=True)
	image_path = character_dir / f"{asset_id}.{ext}"
	image_path.write_bytes(image_bytes)

	metadata = {
		"asset_id": asset_id,
		"character_id": character_id,
		"asset_type": row.get("asset_type"),
		"width": row.get("width"),
		"height": row.get("height"),
		"provider": model_spec.provider,
		"model": model_spec.model,
		"model_route": row.get("model_route"),
		"generated_at_utc": timestamp,
		"mime_type": mime_type,
		"prompt": prompt,
		"source_manifest_status": row.get("status"),
		"raw_response": response_json,
	}
	metadata_path = character_dir / f"{asset_id}.json"
	metadata_path.write_text(json.dumps(metadata, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

	return GeneratedAsset(
		image_path=image_path,
		metadata_path=metadata_path,
		provider=model_spec.provider,
		model=model_spec.model,
		mime_type=mime_type,
	)


def _get_api_key(provider: str) -> str:
	if provider == "openai":
		value = os.environ.get("OPENAI_API_KEY", "").strip()
		if not value:
			raise RuntimeError("OPENAI_API_KEY is required for OpenAI model routes.")
		return value
	if provider == "google":
		value = os.environ.get("GOOGLE_API_KEY", "").strip()
		if not value:
			raise RuntimeError("GOOGLE_API_KEY is required for Google model routes.")
		return value
	raise RuntimeError(f"Unsupported provider: {provider}")


def _generate_with_provider(
	model_spec: ModelSpec,
	prompt: str,
	width: int,
	height: int,
	api_key: str,
) -> tuple[bytes, str, dict[str, Any]]:
	if model_spec.provider == "openai":
		return _call_openai_generate(
			model=model_spec.model,
			prompt=prompt,
			width=width,
			height=height,
			api_key=api_key,
		)
	if model_spec.provider == "google":
		return _call_google_generate(
			model=model_spec.model,
			prompt=prompt,
			api_key=api_key,
		)
	raise RuntimeError(f"Unsupported provider: {model_spec.provider}")


def _append_review_note(existing: str, addition: str) -> str:
	existing = (existing or "").strip()
	if not existing:
		return addition
	return f"{existing} | {addition}"


def main() -> int:
	args = _build_parser().parse_args()

	manifest_path = Path(args.manifest)
	brief_dir = Path(args.brief_dir)
	output_dir = Path(args.output_dir)

	status_filter = _normalize_list_arg(args.status)
	character_filter = _normalize_list_arg(args.characters)
	asset_type_filter = _normalize_list_arg(args.asset_types)
	limit = max(0, int(args.limit))

	rows, fieldnames = _load_manifest(manifest_path)

	missing_fields = {"asset_id", "character_id", "asset_type", "width", "height", "model_route", "status"} - set(fieldnames)
	if missing_fields:
		raise ValueError(f"Manifest missing required fields: {sorted(missing_fields)}")

	processed = 0
	successes = 0
	skipped = 0
	errors = 0

	for idx, row in enumerate(rows):
		row_status = (row.get("status") or "").strip().lower()
		character_id = (row.get("character_id") or "").strip().lower()
		asset_type = (row.get("asset_type") or "").strip().lower()
		asset_id = (row.get("asset_id") or "").strip()

		if status_filter and row_status not in status_filter:
			continue
		if character_filter and character_id not in character_filter:
			continue
		if asset_type_filter and asset_type not in asset_type_filter:
			continue
		if limit and processed >= limit:
			break

		processed += 1
		try:
			model_spec = _resolve_model_spec(row.get("model_route", ""), args.route_stage)
		except Exception as e:
			errors += 1
			print(f"[ERROR] {asset_id}: model route resolve failed: {e}")
			if errors >= args.max_errors:
				print("[ABORT] Max errors reached.")
				break
			continue

		brief_path = brief_dir / f"{character_id}.yaml"
		brief = _load_character_brief(brief_path)
		prompt = _build_prompt(row=row, brief=brief)

		width = int((row.get("width") or "1024").strip())
		height = int((row.get("height") or "1024").strip())

		character_output_dir = output_dir / character_id
		existing_candidates = list(character_output_dir.glob(f"{asset_id}.*"))
		if existing_candidates and not args.force:
			skipped += 1
			print(f"[SKIP] {asset_id}: output already exists ({existing_candidates[0].name})")
			continue

		if args.verbose or args.dry_run:
			print(
				f"[PLAN] {asset_id} | {character_id} | {asset_type} | "
				f"{model_spec.provider}:{model_spec.model} | {width}x{height}"
			)
			if args.verbose:
				preview = prompt.replace("\n", " ")[:220]
				print(f"       prompt> {preview}...")

		if args.dry_run:
			continue

		try:
			api_key = _get_api_key(model_spec.provider)
			image_bytes, mime_type, response_json = _generate_with_provider(
				model_spec=model_spec,
				prompt=prompt,
				width=width,
				height=height,
				api_key=api_key,
			)
			generated = _write_asset_files(
				row=row,
				prompt=prompt,
				response_json=response_json,
				image_bytes=image_bytes,
				mime_type=mime_type,
				output_dir=output_dir,
				model_spec=model_spec,
			)
			successes += 1
			print(f"[OK] {asset_id}: {generated.image_path}")

			if args.write_back:
				row["status"] = args.success_status
				row["file_path"] = str(generated.image_path.as_posix())
				note = f"{args.route_stage}:{generated.provider}:{generated.model}"
				row["review_note"] = _append_review_note(row.get("review_note", ""), note)

			time.sleep(max(0.0, args.sleep_seconds))
		except Exception as e:
			errors += 1
			print(f"[ERROR] {asset_id}: {e}")
			if errors >= args.max_errors:
				print("[ABORT] Max errors reached.")
				break

	if args.write_back and not args.dry_run:
		_write_manifest(manifest_path, rows, fieldnames)
		print(f"[WRITE] Manifest updated: {manifest_path}")

	print(
		f"[SUMMARY] selected={processed} success={successes} skipped={skipped} errors={errors} "
		f"dry_run={args.dry_run}"
	)

	return 0 if errors == 0 else 1


if __name__ == "__main__":
	sys.exit(main())

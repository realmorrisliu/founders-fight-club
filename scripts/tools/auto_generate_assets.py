#!/usr/bin/env python3
"""Automated AI asset generation pipeline (manifest-driven).

Reads `assets/pipeline/asset_manifest.csv`, builds prompts from character briefs,
calls provider image APIs, saves outputs, and optionally writes back manifest status.
"""

from __future__ import annotations

import argparse
import base64
import csv
import json
import mimetypes
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from asset_prompt_utils import build_prompt, get_output_bucket, load_style_lock, load_subject_brief

MODEL_TOKEN_MAP: dict[str, tuple[str, str]] = {
	"nano2": ("google", "gemini-3.1-flash-image-preview"),
	"pro": ("google", "gemini-3-pro-image-preview"),
	"gemini31flash": ("google", "gemini-3.1-flash-image-preview"),
	"gemini31flashimage": ("google", "gemini-3.1-flash-image-preview"),
	"gemini3pro": ("google", "gemini-3-pro-image-preview"),
	"gemini3proimage": ("google", "gemini-3-pro-image-preview"),
	"gemini31pro": ("google", "gemini-3-pro-image-preview"),
	"geminiproimage": ("google", "gemini-3-pro-image-preview"),
	"gpt15": ("openai", "gpt-image-1.5-2025-12-16"),
	"doubao40": ("volcengine", "doubao-seedream-4.0"),
	"doubao45": ("volcengine", "doubao-seedream-4.5"),
	"doubao5lite": ("volcengine", "bytedance-seedream-5-0-lite"),
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


GEMINI_SUPPORTED_ASPECT_RATIOS = [
	"1:1",
	"2:3",
	"3:2",
	"3:4",
	"4:3",
	"4:5",
	"5:4",
	"9:16",
	"16:9",
	"21:9",
]


def _build_parser() -> argparse.ArgumentParser:
	parser = argparse.ArgumentParser(
		description=(
			"Generate game assets from manifest rows by calling provider image APIs. "
			"Supports Google Gemini, OpenAI, and Volcengine (Doubao/Seedream) image models."
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
		"--stage-brief-dir",
		default="assets/pipeline/stage_briefs",
		help="Directory containing stage brief YAML files",
	)
	parser.add_argument(
		"--style-lock",
		default="assets/pipeline/style_lock.yaml",
		help="Path to style lock YAML",
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
		"--stages",
		default="",
		help="Optional comma-separated stage_id filter",
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


def _split_manifest_paths(raw: str) -> list[str]:
	if not raw.strip():
		return []
	normalized = raw.replace(";", "|").replace(",", "|")
	return [item.strip() for item in normalized.split("|") if item.strip()]


def _resolve_reference_path(raw_path: str, output_dir: Path) -> Path:
	if raw_path.startswith("asset:"):
		asset_id = raw_path.split(":", 1)[1].strip()
		if not asset_id:
			raise FileNotFoundError(f"Invalid asset reference: {raw_path!r}")
		candidates = sorted(output_dir.glob(f"**/{asset_id}.*"))
		candidates = [candidate for candidate in candidates if candidate.suffix.lower() != ".json"]
		if not candidates:
			raise FileNotFoundError(f"Asset reference not found under {output_dir}: {raw_path}")
		return candidates[0]

	path = Path(raw_path)
	if not path.is_absolute():
		path = Path.cwd() / path
	return path


def _guess_mime_type(path: Path) -> str:
	mime_type, _ = mimetypes.guess_type(path.as_posix())
	if mime_type:
		return mime_type
	return "image/png"


def _load_reference_images(row: dict[str, str], output_dir: Path) -> tuple[list[dict[str, Any]], list[str]]:
	parts: list[dict[str, Any]] = []
	resolved_paths: list[str] = []
	edit_source_path = str(row.get("edit_source_path", "")).strip()
	reference_paths = _split_manifest_paths(str(row.get("reference_paths", "")).strip())

	for raw_path in [edit_source_path] + reference_paths:
		if not raw_path:
			continue
		path = _resolve_reference_path(raw_path, output_dir)
		if not path.exists():
			raise FileNotFoundError(f"Reference image not found: {path}")
		parts.append(
			{
				"inlineData": {
					"mimeType": _guess_mime_type(path),
					"data": base64.b64encode(path.read_bytes()).decode("utf-8"),
				}
			}
		)
		resolved_paths.append(path.as_posix())

	return parts, resolved_paths


def _infer_aspect_ratio(width: int, height: int) -> str:
	if width <= 0 or height <= 0:
		return "1:1"
	target = float(width) / float(height)
	best_ratio = "1:1"
	best_delta = 999.0
	for candidate in GEMINI_SUPPORTED_ASPECT_RATIOS:
		left, right = candidate.split(":")
		value = float(left) / float(right)
		delta = abs(value - target)
		if delta < best_delta:
			best_delta = delta
			best_ratio = candidate
	return best_ratio


def _infer_image_size(width: int, height: int) -> str:
	max_dim = max(width, height)
	if max_dim <= 768:
		return "1K"
	if max_dim <= 1536:
		return "2K"
	return "4K"


def _build_google_generation_config(row: dict[str, str], width: int, height: int) -> dict[str, Any]:
	aspect_ratio = str(row.get("aspect_ratio", "")).strip() or _infer_aspect_ratio(width, height)
	image_size = str(row.get("image_size", "")).strip() or _infer_image_size(width, height)
	media_resolution = str(row.get("media_resolution", "")).strip() or "MEDIA_RESOLUTION_HIGH"

	config: dict[str, Any] = {
		"responseModalities": ["TEXT", "IMAGE"],
		"mediaResolution": media_resolution,
	}
	image_config: dict[str, Any] = {}
	if aspect_ratio:
		image_config["aspectRatio"] = aspect_ratio
	if image_size:
		image_config["imageSize"] = image_size
	if image_config:
		config["imageConfig"] = image_config
	return config


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
	if token.startswith(("doubao-seedream", "bytedance-seedream", "seedream", "ep-")):
		return ModelSpec(provider="volcengine", model=token)
	if token.startswith("volc:"):
		model = token.split(":", 1)[1].strip()
		if not model:
			raise ValueError(f"Invalid volc route token: {token!r}")
		return ModelSpec(provider="volcengine", model=model)

	raise ValueError(
		f"Unknown model route token: {token!r} from {route_value!r}. "
		"Use known tokens (nano2/pro/gpt15/doubao40/doubao45/doubao5lite) or full model ids."
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


def _call_openai_compatible_images_generate(
	url: str,
	model: str,
	prompt: str,
	width: int,
	height: int,
	api_key: str,
) -> tuple[bytes, str, dict[str, Any]]:
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
		raise RuntimeError(f"Image API response missing data array: {response_json}")
	item = data[0]

	if "b64_json" in item:
		raw = base64.b64decode(item["b64_json"])
		mime_type = str(item.get("mime_type") or "image/png")
		return raw, mime_type, response_json
	if "url" in item:
		raw = _download_binary(item["url"])
		mime_type = str(item.get("mime_type") or "image/png")
		return raw, mime_type, response_json
	raise RuntimeError(f"Image API response missing b64_json/url: {item}")


def _call_openai_generate(model: str, prompt: str, width: int, height: int, api_key: str) -> tuple[bytes, str, dict[str, Any]]:
	return _call_openai_compatible_images_generate(
		url="https://api.openai.com/v1/images/generations",
		model=model,
		prompt=prompt,
		width=width,
		height=height,
		api_key=api_key,
	)


def _normalize_base_url(raw: str) -> str:
	base = raw.strip().rstrip("/")
	if not base:
		raise ValueError("Empty base URL")
	return base


def _call_volcengine_generate(model: str, prompt: str, width: int, height: int, api_key: str) -> tuple[bytes, str, dict[str, Any]]:
	base_url = _normalize_base_url(os.environ.get("VOLCENGINE_API_BASE_URL", "https://ark.cn-beijing.volces.com/api/v3"))
	return _call_openai_compatible_images_generate(
		url=f"{base_url}/images/generations",
		model=model,
		prompt=prompt,
		width=width,
		height=height,
		api_key=api_key,
	)


def _call_google_generate(
	model: str,
	prompt: str,
	width: int,
	height: int,
	api_key: str,
	row: dict[str, str],
	output_dir: Path,
) -> tuple[bytes, str, dict[str, Any]]:
	base_url = f"https://generativelanguage.googleapis.com/v1beta/models/{urllib.parse.quote(model)}:generateContent"
	url = f"{base_url}?key={urllib.parse.quote(api_key)}"
	headers = {"Content-Type": "application/json"}
	reference_parts, resolved_paths = _load_reference_images(row=row, output_dir=output_dir)
	prompt_parts = reference_parts + [{"text": prompt}]
	payload = {
		"contents": [{"parts": prompt_parts}],
		"generationConfig": _build_google_generation_config(row=row, width=width, height=height),
	}

	response_json = _json_http_post(url=url, headers=headers, payload=payload)
	if resolved_paths:
		response_json["_resolved_reference_paths"] = resolved_paths
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
	character_id = (row.get("character_id") or "").strip()
	stage_id = (row.get("stage_id") or "").strip()
	asset_id = (row.get("asset_id") or "unnamed_asset").strip()
	timestamp = datetime.now(timezone.utc).isoformat()
	ext = _mime_to_extension(mime_type)

	output_bucket = get_output_bucket(row)
	subject_dir = output_dir / output_bucket
	subject_dir.mkdir(parents=True, exist_ok=True)
	image_path = subject_dir / f"{asset_id}.{ext}"
	image_path.write_bytes(image_bytes)

	metadata = {
		"asset_id": asset_id,
		"character_id": character_id,
		"stage_id": stage_id,
		"asset_type": row.get("asset_type"),
		"width": row.get("width"),
		"height": row.get("height"),
		"provider": model_spec.provider,
		"model": model_spec.model,
		"model_route": row.get("model_route"),
		"generated_at_utc": timestamp,
		"mime_type": mime_type,
		"prompt": prompt,
		"reference_paths": str(row.get("reference_paths", "")).strip(),
		"edit_source_path": str(row.get("edit_source_path", "")).strip(),
		"aspect_ratio": str(row.get("aspect_ratio", "")).strip(),
		"image_size": str(row.get("image_size", "")).strip(),
		"media_resolution": str(row.get("media_resolution", "")).strip(),
		"source_manifest_status": row.get("status"),
		"raw_response": response_json,
	}
	metadata_path = subject_dir / f"{asset_id}.json"
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
	if provider == "volcengine":
		value = os.environ.get("VOLCENGINE_API_KEY", "").strip() or os.environ.get("ARK_API_KEY", "").strip()
		if not value:
			raise RuntimeError("VOLCENGINE_API_KEY (or ARK_API_KEY) is required for Volcengine model routes.")
		return value
	raise RuntimeError(f"Unsupported provider: {provider}")


def _generate_with_provider(
	model_spec: ModelSpec,
	prompt: str,
	width: int,
	height: int,
	api_key: str,
	row: dict[str, str],
	output_dir: Path,
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
			width=width,
			height=height,
			api_key=api_key,
			row=row,
			output_dir=output_dir,
		)
	if model_spec.provider == "volcengine":
		return _call_volcengine_generate(
			model=model_spec.model,
			prompt=prompt,
			width=width,
			height=height,
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
	stage_brief_dir = Path(args.stage_brief_dir)
	style_lock = load_style_lock(Path(args.style_lock))
	output_dir = Path(args.output_dir)

	status_filter = _normalize_list_arg(args.status)
	character_filter = _normalize_list_arg(args.characters)
	stage_filter = _normalize_list_arg(args.stages)
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
		stage_id = (row.get("stage_id") or "").strip().lower()
		asset_type = (row.get("asset_type") or "").strip().lower()
		asset_id = (row.get("asset_id") or "").strip()

		if status_filter and row_status not in status_filter:
			continue
		if character_filter and character_id not in character_filter:
			continue
		if stage_filter and stage_id not in stage_filter:
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

		brief = load_subject_brief(
			row=row,
			character_brief_dir=brief_dir,
			stage_brief_dir=stage_brief_dir,
		)
		prompt = build_prompt(row=row, brief=brief, style_lock=style_lock)

		width = int((row.get("width") or "1024").strip())
		height = int((row.get("height") or "1024").strip())

		output_bucket = get_output_bucket(row)
		subject_output_dir = output_dir / output_bucket
		existing_candidates = list(subject_output_dir.glob(f"{asset_id}.*"))
		if existing_candidates and not args.force:
			skipped += 1
			print(f"[SKIP] {asset_id}: output already exists ({existing_candidates[0].name})")
			continue

		if args.verbose or args.dry_run:
			print(
				f"[PLAN] {asset_id} | {output_bucket} | {asset_type} | "
				f"{model_spec.provider}:{model_spec.model} | {width}x{height}"
			)
			reference_paths = _split_manifest_paths(str(row.get("reference_paths", "")).strip())
			edit_source_path = str(row.get("edit_source_path", "")).strip()
			if reference_paths or edit_source_path:
				print(
					f"       refs> edit={edit_source_path or '-'} "
					f"extras={len(reference_paths)} aspect={row.get('aspect_ratio', '') or _infer_aspect_ratio(width, height)} "
					f"size={row.get('image_size', '') or _infer_image_size(width, height)}"
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
				row=row,
				output_dir=output_dir,
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

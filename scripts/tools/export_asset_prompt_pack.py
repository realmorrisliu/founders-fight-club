#!/usr/bin/env python3
"""Export combined prompt packs from asset manifests."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path

from asset_prompt_utils import build_prompt, get_subject_id, load_style_lock, load_subject_brief


def _normalize_list_arg(raw: str) -> set[str]:
	return {item.strip().lower() for item in raw.split(",") if item.strip()}


def _load_manifest(path: Path) -> tuple[list[dict[str, str]], list[str]]:
	with path.open("r", encoding="utf-8", newline="") as handle:
		reader = csv.DictReader(handle)
		rows = list(reader)
		return rows, list(reader.fieldnames or [])


def _write_snapshot(path: Path, rows: list[dict[str, str]], fieldnames: list[str]) -> None:
	with path.open("w", encoding="utf-8", newline="") as handle:
		writer = csv.DictWriter(handle, fieldnames=fieldnames)
		writer.writeheader()
		writer.writerows(rows)


def _build_parser() -> argparse.ArgumentParser:
	parser = argparse.ArgumentParser(description="Export prompt pack markdown from asset manifests.")
	parser.add_argument("--manifest", required=True, help="Path to the asset manifest CSV")
	parser.add_argument("--output-dir", required=True, help="Directory to write the prompt pack")
	parser.add_argument("--bundle-name", required=True, help="Human-readable name for the prompt bundle")
	parser.add_argument("--status", default="queued", help="Comma-separated statuses to include")
	parser.add_argument("--characters", default="", help="Optional comma-separated character_id filter")
	parser.add_argument("--stages", default="", help="Optional comma-separated stage_id filter")
	parser.add_argument("--asset-types", default="", help="Optional comma-separated asset_type filter")
	parser.add_argument("--limit", type=int, default=0, help="Limit number of exported rows")
	parser.add_argument("--style-lock", default="assets/pipeline/style_lock.yaml", help="Path to style lock yaml")
	parser.add_argument("--brief-dir", default="assets/pipeline/character_briefs", help="Character brief directory")
	parser.add_argument("--stage-brief-dir", default="assets/pipeline/stage_briefs", help="Stage brief directory")
	return parser


def main() -> int:
	args = _build_parser().parse_args()

	manifest_path = Path(args.manifest)
	output_dir = Path(args.output_dir)
	output_dir.mkdir(parents=True, exist_ok=True)

	rows, fieldnames = _load_manifest(manifest_path)
	style_lock = load_style_lock(Path(args.style_lock))

	status_filter = _normalize_list_arg(args.status)
	character_filter = _normalize_list_arg(args.characters)
	stage_filter = _normalize_list_arg(args.stages)
	asset_type_filter = _normalize_list_arg(args.asset_types)
	limit = max(0, int(args.limit))

	selected_rows: list[dict[str, str]] = []
	for row in rows:
		row_status = str(row.get("status", "")).strip().lower()
		character_id = str(row.get("character_id", "")).strip().lower()
		stage_id = str(row.get("stage_id", "")).strip().lower()
		asset_type = str(row.get("asset_type", "")).strip().lower()

		if status_filter and row_status not in status_filter:
			continue
		if character_filter and character_id not in character_filter:
			continue
		if stage_filter and stage_id not in stage_filter:
			continue
		if asset_type_filter and asset_type not in asset_type_filter:
			continue

		selected_rows.append(row)
		if limit and len(selected_rows) >= limit:
			break

	lines = [
		f"# {args.bundle_name}",
		"",
		f"- Manifest: `{manifest_path.as_posix()}`",
		f"- Assets: `{len(selected_rows)}`",
		f"- Style lock: `{args.style_lock}`",
		"",
		"Use these prompts either with `scripts/tools/auto_generate_assets.py` or by pasting them into your preferred image model manually.",
		"",
	]

	for row in selected_rows:
		brief = load_subject_brief(
			row=row,
			character_brief_dir=Path(args.brief_dir),
			stage_brief_dir=Path(args.stage_brief_dir),
		)
		prompt = build_prompt(row=row, brief=brief, style_lock=style_lock)
		asset_id = str(row.get("asset_id", "")).strip()
		asset_type = str(row.get("asset_type", "")).strip()
		subject_id = get_subject_id(row)
		lines.extend(
			[
				f"## {asset_id}",
				"",
				f"- Subject: `{subject_id}`",
				f"- Type: `{asset_type}`",
				f"- Route: `{row.get('model_route', '')}`",
				f"- Size: `{row.get('width', '')}x{row.get('height', '')}`",
				f"- Aspect ratio: `{row.get('aspect_ratio', '') or 'auto'}`",
				f"- Image size: `{row.get('image_size', '') or 'auto'}`",
				f"- Edit source: `{row.get('edit_source_path', '') or '-'}`",
				f"- Reference images: `{row.get('reference_paths', '') or '-'}`",
				"",
				"```text",
				prompt,
				"```",
				"",
			]
		)

	(output_dir / "PROMPTS.md").write_text("\n".join(lines), encoding="utf-8")
	_write_snapshot(output_dir / "manifest_snapshot.csv", selected_rows, fieldnames)
	print(f"[OK] Prompt pack written: {(output_dir / 'PROMPTS.md').as_posix()}")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())

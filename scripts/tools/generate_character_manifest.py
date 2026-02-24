#!/usr/bin/env python3
"""Generate a JSON manifest for a character exports directory."""

from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

from character_exports_common import build_manifest_dict, scan_character_exports


def _infer_character_id(exports_dir: Path) -> str:
	if exports_dir.name == "exports" and exports_dir.parent.name:
		return exports_dir.parent.name
	return exports_dir.name


def _infer_output_path(exports_dir: Path, explicit_output: str | None) -> Path:
	if explicit_output:
		return Path(explicit_output)
	if exports_dir.name == "exports":
		return exports_dir.parent / "character_manifest.json"
	return exports_dir / "character_manifest.json"


def _build_parser() -> argparse.ArgumentParser:
	parser = argparse.ArgumentParser(
		description=(
			"Generate a JSON manifest for a character exports directory and embed validation results."
		)
	)
	parser.add_argument("exports_dir", help="Directory containing exported PNG frames")
	parser.add_argument(
		"--character-id",
		help="Character id to embed in the manifest (default: inferred from path)",
	)
	parser.add_argument(
		"--output",
		help="Output JSON path (default: <character>/character_manifest.json)",
	)
	parser.add_argument(
		"--width",
		type=int,
		default=24,
		help="Expected frame canvas width (default: 24)",
	)
	parser.add_argument(
		"--height",
		type=int,
		default=48,
		help="Expected frame canvas height (default: 48)",
	)
	parser.add_argument(
		"--no-size-check",
		action="store_true",
		help="Disable PNG canvas size validation",
	)
	parser.add_argument(
		"--require-all",
		action="store_true",
		help="Validate that all required runtime animations exist",
	)
	parser.add_argument(
		"--strict",
		action="store_true",
		help="Do not write a manifest if validation has errors",
	)
	return parser


def main() -> int:
	args = _build_parser().parse_args()

	exports_dir = Path(args.exports_dir)
	expected_size = None if args.no_size_check else (args.width, args.height)
	result = scan_character_exports(
		exports_dir,
		expected_size=expected_size,
		require_all=args.require_all,
	)

	if args.strict and result.errors:
		print("Manifest generation aborted: validation errors present (use without --strict to write anyway).")
		for error in result.errors:
			print(f"  - {error}")
		return 1

	character_id = args.character_id or _infer_character_id(exports_dir)
	manifest = build_manifest_dict(result, character_id=character_id)
	manifest["generated_at_utc"] = datetime.now(timezone.utc).isoformat()

	output_path = _infer_output_path(exports_dir, args.output)
	output_path.parent.mkdir(parents=True, exist_ok=True)
	output_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

	print(f"Wrote manifest: {output_path}")
	print(
		f"Character id: {character_id} | Animations: {result.animation_count} | Frames: {result.total_frames}"
	)
	if result.warnings:
		print(f"Warnings: {len(result.warnings)}")
	if result.errors:
		print(f"Errors embedded in manifest: {len(result.errors)}")
	else:
		print("Validation status embedded in manifest: clean")
	return 0


if __name__ == "__main__":
	sys.exit(main())


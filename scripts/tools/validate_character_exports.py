#!/usr/bin/env python3
"""Validate character export PNGs against repository naming and size conventions."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from character_exports_common import scan_character_exports


def _build_parser() -> argparse.ArgumentParser:
	parser = argparse.ArgumentParser(
		description=(
			"Validate a character exports directory (e.g. assets/sprites/characters/<id>/exports)."
		)
	)
	parser.add_argument("exports_dir", help="Directory containing exported PNG frames")
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
		help="Fail if any required runtime animation is missing",
	)
	parser.add_argument(
		"--strict-warnings",
		action="store_true",
		help="Treat warnings as failures (non-zero exit)",
	)
	return parser


def main() -> int:
	args = _build_parser().parse_args()
	expected_size = None if args.no_size_check else (args.width, args.height)

	result = scan_character_exports(
		args.exports_dir,
		expected_size=expected_size,
		require_all=args.require_all,
	)

	print(f"Exports directory: {Path(args.exports_dir)}")
	if expected_size is None:
		print("Expected canvas: (size check disabled)")
	else:
		print(f"Expected canvas: {expected_size[0]}x{expected_size[1]}")
	print(
		f"Detected animations: {result.animation_count} | Detected frames: {result.total_frames}"
	)

	for animation in sorted(result.frames_by_animation.keys()):
		frames = result.frames_by_animation[animation]
		indices = [f.index for f in frames]
		sizes = sorted({(f.width, f.height) for f in frames})
		size_text = ", ".join(f"{w}x{h}" for (w, h) in sizes)
		print(
			f"  - {animation}: {len(frames)} frame(s), indices={indices}, sizes=[{size_text}]"
		)

	if result.missing_required and not args.require_all:
		print(
			"Missing required animations (warning only, use --require-all to fail): "
			+ ", ".join(result.missing_required)
		)

	if result.warnings:
		print("Warnings:")
		for warning in result.warnings:
			print(f"  - {warning}")

	if result.errors:
		print("Errors:")
		for error in result.errors:
			print(f"  - {error}")

	has_failure = bool(result.errors) or (args.strict_warnings and bool(result.warnings))
	if has_failure:
		print("Validation result: FAIL")
		return 1

	print("Validation result: PASS")
	return 0


if __name__ == "__main__":
	sys.exit(main())


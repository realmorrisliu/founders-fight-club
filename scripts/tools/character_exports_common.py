#!/usr/bin/env python3
"""Shared helpers for character export validation and manifest generation."""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
import re
import struct
from typing import Iterable


DEFAULT_REQUIRED_ANIMATIONS: list[str] = [
	"idle",
	"walk",
	"jump",
	"light",
	"heavy",
	"special",
	"throw",
	"block",
	"hit_light",
	"hit_heavy",
	"hit",
	"fall",
	"getup",
	"ko",
]

FRAME_FILENAME_RE = re.compile(r"^(?P<animation>[a-z0-9_]+)_(?P<index>\d+)\.png$")
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"


@dataclass(frozen=True)
class FrameRecord:
	animation: str
	index: int
	filename: str
	path: Path
	width: int
	height: int


@dataclass
class ScanResult:
	exports_dir: Path
	required_animations: list[str]
	expected_size: tuple[int, int] | None
	frames_by_animation: dict[str, list[FrameRecord]] = field(default_factory=dict)
	errors: list[str] = field(default_factory=list)
	warnings: list[str] = field(default_factory=list)

	@property
	def total_frames(self) -> int:
		return sum(len(frames) for frames in self.frames_by_animation.values())

	@property
	def animation_count(self) -> int:
		return len(self.frames_by_animation)

	@property
	def missing_required(self) -> list[str]:
		required = set(self.required_animations)
		return [name for name in self.required_animations if name not in self.frames_by_animation and name in required]


def _parse_png_dimensions(path: Path) -> tuple[int, int]:
	with path.open("rb") as f:
		if f.read(8) != PNG_SIGNATURE:
			raise ValueError("invalid PNG signature")
		length_bytes = f.read(4)
		chunk_type = f.read(4)
		if len(length_bytes) != 4 or len(chunk_type) != 4:
			raise ValueError("truncated PNG header")
		(length,) = struct.unpack(">I", length_bytes)
		if chunk_type != b"IHDR":
			raise ValueError("IHDR chunk not found")
		ihdr = f.read(length)
		if len(ihdr) < 8:
			raise ValueError("truncated IHDR chunk")
		width, height = struct.unpack(">II", ihdr[:8])
		return width, height


def _sorted_unique(items: Iterable[str]) -> list[str]:
	return sorted(set(items))


def scan_character_exports(
	exports_dir: str | Path,
	*,
	required_animations: list[str] | None = None,
	expected_size: tuple[int, int] | None = (24, 48),
	require_all: bool = False,
) -> ScanResult:
	path = Path(exports_dir)
	required = list(required_animations or DEFAULT_REQUIRED_ANIMATIONS)
	result = ScanResult(
		exports_dir=path,
		required_animations=required,
		expected_size=expected_size,
	)

	if not path.exists():
		result.errors.append(f"Exports directory does not exist: {path}")
		return result
	if not path.is_dir():
		result.errors.append(f"Exports path is not a directory: {path}")
		return result

	frame_map: dict[str, list[FrameRecord]] = {}

	for entry in sorted(path.iterdir(), key=lambda p: p.name):
		if entry.name.startswith("."):
			continue
		if entry.is_dir():
			result.warnings.append(f"Ignoring subdirectory: {entry.name}")
			continue
		if entry.name.endswith(".import"):
			continue
		if entry.suffix.lower() != ".png":
			result.warnings.append(f"Ignoring non-PNG file: {entry.name}")
			continue

		match = FRAME_FILENAME_RE.match(entry.name)
		if not match:
			result.warnings.append(
				f"Filename does not match '<animation>_<index>.png': {entry.name}"
			)
			continue

		animation = match.group("animation")
		index = int(match.group("index"))
		try:
			width, height = _parse_png_dimensions(entry)
		except Exception as exc:  # noqa: BLE001
			result.errors.append(f"Failed to read PNG header for {entry.name}: {exc}")
			continue

		frame = FrameRecord(
			animation=animation,
			index=index,
			filename=entry.name,
			path=entry,
			width=width,
			height=height,
		)
		frame_map.setdefault(animation, []).append(frame)

		if expected_size is not None and (width, height) != expected_size:
			exp_w, exp_h = expected_size
			result.errors.append(
				f"Wrong canvas size for {entry.name}: {width}x{height} (expected {exp_w}x{exp_h})"
			)

	for animation, frames in frame_map.items():
		frames.sort(key=lambda f: (f.index, f.filename))

		seen_indices: dict[int, list[str]] = {}
		for frame in frames:
			seen_indices.setdefault(frame.index, []).append(frame.filename)
		for index, names in sorted(seen_indices.items()):
			if len(names) > 1:
				result.errors.append(
					f"Duplicate frame index in animation '{animation}' for index {index}: {', '.join(names)}"
				)

		indices = [f.index for f in frames]
		if indices and indices[0] != 0:
			result.errors.append(
				f"Animation '{animation}' must start at frame 0 (found {indices[0]})"
			)
		if indices:
			max_index = max(indices)
			missing = [str(i) for i in range(0, max_index + 1) if i not in seen_indices]
			if missing:
				result.errors.append(
					f"Animation '{animation}' has missing frame indices: {', '.join(missing)}"
				)

	if frame_map:
		unknown = [a for a in _sorted_unique(frame_map.keys()) if a not in set(required)]
		for animation in unknown:
			result.warnings.append(
				f"Animation '{animation}' is not in the required runtime list (kept, but verify usage)"
			)
	else:
		result.errors.append("No valid exported PNG frames found")

	result.frames_by_animation = {
		animation: frame_map[animation] for animation in sorted(frame_map.keys())
	}
	if require_all:
		for animation in result.missing_required:
			result.errors.append(f"Missing required animation: {animation}")
	return result


def build_manifest_dict(
	result: ScanResult,
	*,
	character_id: str,
	include_missing_required: bool = True,
) -> dict:
	all_sizes = sorted(
		{
			(frame.width, frame.height)
			for frames in result.frames_by_animation.values()
			for frame in frames
		}
	)
	animations: dict[str, dict] = {}
	for animation in sorted(result.frames_by_animation.keys()):
		frames = result.frames_by_animation[animation]
		animations[animation] = {
			"frame_count": len(frames),
			"indices": [frame.index for frame in frames],
			"frames": [
				{
					"file": frame.filename,
					"index": frame.index,
					"width": frame.width,
					"height": frame.height,
				}
				for frame in frames
			],
		}

	manifest: dict = {
		"schema_version": 1,
		"character_id": character_id,
		"exports_dir": str(result.exports_dir),
		"expected_canvas": (
			{"width": result.expected_size[0], "height": result.expected_size[1]}
			if result.expected_size is not None
			else None
		),
		"required_animations": list(result.required_animations),
		"animations": animations,
		"summary": {
			"animation_count": result.animation_count,
			"frame_count": result.total_frames,
			"detected_canvas_sizes": [
				{"width": width, "height": height} for (width, height) in all_sizes
			],
		},
		"validation": {
			"errors": list(result.errors),
			"warnings": list(result.warnings),
		},
	}
	if include_missing_required:
		manifest["summary"]["missing_required_animations"] = list(result.missing_required)
	return manifest

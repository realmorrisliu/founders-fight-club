#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<'EOF'
Usage:
  scripts/godot.sh run
  scripts/godot.sh editor
  scripts/godot.sh run-scene <scene_path>

Env:
  GODOT_BIN=/path/to/godot  # optional override
EOF
}

resolve_godot_bin() {
	if [ -n "${GODOT_BIN:-}" ]; then
		printf '%s\n' "$GODOT_BIN"
		return 0
	fi

	if command -v godot4 >/dev/null 2>&1; then
		command -v godot4
		return 0
	fi

	if command -v godot >/dev/null 2>&1; then
		command -v godot
		return 0
	fi

	if [ -x "/Applications/Godot.app/Contents/MacOS/Godot" ]; then
		printf '%s\n' "/Applications/Godot.app/Contents/MacOS/Godot"
		return 0
	fi

	echo "error: Godot executable not found. Set GODOT_BIN=/path/to/godot" >&2
	return 1
}

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
godot_bin="$(resolve_godot_bin)"
cmd="${1:-}"

case "$cmd" in
	run)
		echo "Launching with $godot_bin"
		exec "$godot_bin" --path "$repo_root"
		;;
	editor)
		echo "Opening editor with $godot_bin"
		exec "$godot_bin" --path "$repo_root" -e
		;;
	run-scene)
		scene="${2:-}"
		if [ -z "$scene" ]; then
			echo "error: missing scene path for run-scene" >&2
			usage >&2
			exit 1
		fi
		echo "Running scene $scene with $godot_bin"
		exec "$godot_bin" --path "$repo_root" --scene "$scene"
		;;
	-h|--help|help|"")
		usage
		;;
	*)
		echo "error: unknown command: $cmd" >&2
		usage >&2
		exit 1
		;;
esac

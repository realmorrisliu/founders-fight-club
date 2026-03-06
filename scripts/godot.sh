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
  GODOT_ATTACH=1            # optional: keep Godot attached to the terminal
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

should_detach_gui() {
	[ "${GODOT_ATTACH:-0}" != "1" ] && [ "$(uname -s)" = "Darwin" ]
}

launch_godot() {
	local mode="${1:-run}"
	shift
	if should_detach_gui; then
		local log_dir="$repo_root/.godot-user/logs"
		local log_file="$log_dir/${mode}.log"
		mkdir -p "$log_dir"
		echo "Launching with $godot_bin (detached)"
		echo "Logs: $log_file"
		nohup "$godot_bin" "$@" >"$log_file" 2>&1 </dev/null &
		echo "Started Godot (pid $!)"
		return 0
	fi
	echo "Launching with $godot_bin"
	exec "$godot_bin" "$@"
}

case "$cmd" in
	run)
		launch_godot "run" --path "$repo_root"
		;;
	editor)
		launch_godot "editor" --path "$repo_root" -e
		;;
	run-scene)
		scene="${2:-}"
		if [ -z "$scene" ]; then
			echo "error: missing scene path for run-scene" >&2
			usage >&2
			exit 1
		fi
		scene_tag="$(printf '%s' "$scene" | tr '/:' '__')"
		launch_godot "run-scene-${scene_tag}" --path "$repo_root" --scene "$scene"
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

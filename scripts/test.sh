#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<'USAGE'
Usage:
  scripts/test.sh [suite]

Examples:
  scripts/test.sh
  scripts/test.sh smoke

Env:
  GODOT_BIN=/path/to/godot  # optional override
USAGE
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

suite="${1:-smoke}"
if [ "${suite}" = "-h" ] || [ "${suite}" = "--help" ] || [ "${suite}" = "help" ]; then
	usage
	exit 0
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
godot_bin="$(resolve_godot_bin)"
user_data_dir="$repo_root/.godot-user"
mkdir -p "$user_data_dir/logs"
log_file="$user_data_dir/logs/test.log"
rm -f "$log_file"

error_pattern="SCRIPT ERROR:|Parse Error:|ERROR: Failed to load script"
find_errors() {
	if command -v rg >/dev/null 2>&1; then
		rg -n "$error_pattern" "$log_file"
	else
		grep -En "$error_pattern" "$log_file"
	fi
}

printf 'Running %s suite with %s\n' "$suite" "$godot_bin"
set +e
"$godot_bin" --headless --path "$repo_root" --log-file "$log_file" --script "res://tests/TestRunner.gd" -- --suite "$suite"
status=$?
set -e

if find_errors >/dev/null 2>&1; then
	echo "Detected script parse/runtime errors in $log_file" >&2
	find_errors >&2 || true
	status=1
fi

exit "$status"

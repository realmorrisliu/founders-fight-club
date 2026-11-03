#!/usr/bin/env bash
# Shared resolver for the Godot executable pinned in GODOT_VERSION.

resolve_godot_bin() {
	local repo_root="$1"
	local expected_version
	expected_version="$(tr -d '[:space:]' < "$repo_root/GODOT_VERSION")"
	local bin=""
	if [ -n "${GODOT_BIN:-}" ]; then
		bin="$GODOT_BIN"
	else
		bin="$(bash "$repo_root/scripts/install_godot.sh")"
	fi
	if [ ! -x "$bin" ]; then
		echo "error: Godot executable not found at $bin" >&2
		return 1
	fi
	local reported
	reported="$("$bin" --version 2>/dev/null || true)"
	case "$reported" in
		"${expected_version}".*) ;;
		*)
			echo "error: Godot $bin reports '$reported', expected ${expected_version}.x from GODOT_VERSION" >&2
			return 1
			;;
	esac
	printf '%s\n' "$bin"
}

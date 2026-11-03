#!/usr/bin/env bash
# Headless match driver. Same seed and same inputs write the same state log.
set -euo pipefail

usage() {
	cat <<'EOF'
Usage:
  scripts/ffc.sh doctor
  scripts/ffc.sh run --frames N --out states.jsonl [options]
  scripts/ffc.sh replay --replay match.json --out states.jsonl
  scripts/ffc.sh ui --press versus|story|training|control-style --out ui.json
  scripts/ffc.sh hash states.jsonl

Options for run/replay:
  --seed N
  --mode local|cpu|story|training
  --stage grand_arena
  --p1 CHARACTER_ID --p2 CHARACTER_ID
  --p1-control script|cpu|idle
  --p2-control script|cpu|idle
  --stocks N
  --timer-enabled true|false
  --timer-seconds N
  --onboarding true|false
  --control-preset modern|classic
  --input samples.json
  --screenshots 10,40
  --screenshot-dir DIR
  --setup-p1-percent N  and the p2 / x / y variants
  --render headless|xvfb

The simulation steps at a fixed 60Hz and does not follow the wall clock.
headless is the default. xvfb opens a virtual display so PNG capture can use
the normal renderer when the headless viewport image is empty.
Each run gets a disposable HOME. State logs and screenshots are not deleted.
EOF
}

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/godot_bin.sh
source "$repo_root/scripts/godot_bin.sh"

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] || [ "${1:-}" = "help" ] || [ "${1:-}" = "" ]; then
	usage
	exit 0
fi

render="headless"
forward=()
while [ "$#" -gt 0 ]; do
	case "$1" in
		--render)
			render="${2:-}"
			if [ "$#" -lt 2 ]; then
				echo "error: --render needs headless or xvfb" >&2
				exit 1
			fi
			shift 2
			;;
		*)
			forward+=("$1")
			shift
			;;
	esac
done

case "$render" in
	headless|xvfb) ;;
	*)
		echo "error: --render must be headless or xvfb" >&2
		exit 1
		;;
esac

godot_bin="$(resolve_godot_bin "$repo_root")"
home_root="$repo_root/.ffc-home"
mkdir -p "$home_root"
run_home="$(mktemp -d "$home_root/run.XXXXXX")"
cleanup() {
	rm -rf "$run_home"
}
trap cleanup EXIT

godot_args=(--fixed-fps 60 --path "$repo_root" --script "res://scripts/driver/MatchDriverCli.gd" --)
if [ "$render" = "headless" ]; then
	godot_args=(--headless "${godot_args[@]}")
fi

if [ "$render" = "xvfb" ]; then
	if ! command -v xvfb-run >/dev/null 2>&1; then
		echo "error: xvfb-run is not installed. Use --render headless." >&2
		exit 1
	fi
	HOME="$run_home" xvfb-run -a "$godot_bin" "${godot_args[@]}" "${forward[@]}"
else
	HOME="$run_home" "$godot_bin" "${godot_args[@]}" "${forward[@]}"
fi

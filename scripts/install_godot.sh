#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="$(tr -d '[:space:]' < "$repo_root/GODOT_VERSION")"
dest="$repo_root/.godot-bin"

version_matches() {
	local bin="$1"
	local reported
	reported="$("$bin" --version 2>/dev/null || true)"
	case "$reported" in
		"${version}".*) return 0 ;;
	esac
	return 1
}

resolve_installed() {
	if [ -x "$dest/godot" ]; then
		printf '%s\n' "$dest/godot"
		return 0
	fi
	if [ -x "$dest/Godot.app/Contents/MacOS/Godot" ]; then
		printf '%s\n' "$dest/Godot.app/Contents/MacOS/Godot"
		return 0
	fi
	return 1
}

if installed="$(resolve_installed)" && version_matches "$installed"; then
	printf '%s\n' "$installed"
	exit 0
fi

os_name="$(uname -s)"
case "$os_name" in
	Linux)
		asset="Godot_v${version}-stable_linux.x86_64.zip"
		;;
	Darwin)
		asset="Godot_v${version}-stable_macos.universal.zip"
		;;
	*)
		echo "error: unsupported OS '$os_name' for the pinned Godot ${version} download. Set GODOT_BIN to a Godot ${version} executable." >&2
		exit 1
		;;
esac

url="https://github.com/godotengine/godot/releases/download/${version}-stable/${asset}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
echo "Downloading Godot ${version} from ${url}" >&2
curl -fsSL -o "$tmp_dir/godot.zip" -L "$url"
unzip -q -o "$tmp_dir/godot.zip" -d "$tmp_dir"
rm -rf "$dest"
mkdir -p "$dest"
if [ "$os_name" = "Linux" ]; then
	linux_bin="$tmp_dir/Godot_v${version}-stable_linux.x86_64"
	if [ ! -f "$linux_bin" ]; then
		echo "error: Linux Godot binary missing from ${asset}" >&2
		exit 1
	fi
	install -m 755 "$linux_bin" "$dest/godot"
else
	if [ ! -d "$tmp_dir/Godot.app" ]; then
		echo "error: macOS Godot.app missing from ${asset}" >&2
		exit 1
	fi
	mv "$tmp_dir/Godot.app" "$dest/Godot.app"
fi

installed="$(resolve_installed)"
if ! version_matches "$installed"; then
	echo "error: downloaded Godot did not report version ${version} ('$("$installed" --version 2>/dev/null || true)')" >&2
	exit 1
fi
printf '%s\n' "$installed"

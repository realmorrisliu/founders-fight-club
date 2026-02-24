#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<'EOF'
Usage:
  scripts/tools/batch_pixelize.sh --input-dir <dir> --output-dir <dir> [options]

Purpose:
  Normalize AI-generated character frames into a fixed pixel-art canvas for review/integration.

Options:
  --input-dir <dir>       Source images directory (png/jpg/jpeg/webp)
  --output-dir <dir>      Output directory for processed PNGs
  --width <n>             Output canvas width (default: 24)
  --height <n>            Output canvas height (default: 48)
  --colors <n>            pngquant color limit (default: 24)
  --quality <min-max>     pngquant quality range (default: 40-100)
  --remove-bg             Run rembg before processing (requires `rembg`)
  --skip-quantize         Skip pngquant palette quantization
  --no-trim               Disable transparent-border trim before resize
  --overwrite             Overwrite existing output files
  --dry-run               Print planned actions without writing files
  --help                  Show this help

Notes:
  - Requires ImageMagick (`magick` or `convert`)
  - Preserves filename stem and writes `.png`
  - Uses bottom-center alignment (`-gravity south`) to reduce foot baseline drift
EOF
}

INPUT_DIR=""
OUTPUT_DIR=""
WIDTH="24"
HEIGHT="48"
COLORS="24"
QUALITY="40-100"
REMOVE_BG=0
SKIP_QUANTIZE=0
DO_TRIM=1
OVERWRITE=0
DRY_RUN=0

while [ "$#" -gt 0 ]; do
	case "$1" in
		--input-dir)
			INPUT_DIR="${2:-}"
			shift 2
			;;
		--output-dir)
			OUTPUT_DIR="${2:-}"
			shift 2
			;;
		--width)
			WIDTH="${2:-}"
			shift 2
			;;
		--height)
			HEIGHT="${2:-}"
			shift 2
			;;
		--colors)
			COLORS="${2:-}"
			shift 2
			;;
		--quality)
			QUALITY="${2:-}"
			shift 2
			;;
		--remove-bg)
			REMOVE_BG=1
			shift
			;;
		--skip-quantize)
			SKIP_QUANTIZE=1
			shift
			;;
		--no-trim)
			DO_TRIM=0
			shift
			;;
		--overwrite)
			OVERWRITE=1
			shift
			;;
		--dry-run)
			DRY_RUN=1
			shift
			;;
		--help|-h)
			usage
			exit 0
			;;
		*)
			echo "Unknown argument: $1" >&2
			usage >&2
			exit 1
			;;
	esac
done

if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_DIR" ]; then
	echo "Both --input-dir and --output-dir are required." >&2
	usage >&2
	exit 1
fi

if [ ! -d "$INPUT_DIR" ]; then
	echo "Input directory not found: $INPUT_DIR" >&2
	exit 1
fi

if ! [[ "$WIDTH" =~ ^[0-9]+$ ]] || ! [[ "$HEIGHT" =~ ^[0-9]+$ ]]; then
	echo "Width and height must be positive integers." >&2
	exit 1
fi

if ! [[ "$COLORS" =~ ^[0-9]+$ ]]; then
	echo "Colors must be a positive integer." >&2
	exit 1
fi

if command -v magick >/dev/null 2>&1; then
	IMAGEMAGICK_BIN="magick"
elif command -v convert >/dev/null 2>&1; then
	IMAGEMAGICK_BIN="convert"
else
	echo "ImageMagick not found. Install `magick` (preferred) or `convert` to use this script." >&2
	exit 1
fi

if [ "$REMOVE_BG" -eq 1 ] && ! command -v rembg >/dev/null 2>&1; then
	echo "--remove-bg was set but `rembg` is not installed." >&2
	exit 1
fi

if [ "$SKIP_QUANTIZE" -eq 0 ] && ! command -v pngquant >/dev/null 2>&1; then
	echo "pngquant not found; continuing without quantization." >&2
	SKIP_QUANTIZE=1
fi

run_imagemagick() {
	if [ "$IMAGEMAGICK_BIN" = "magick" ]; then
		magick "$@"
	else
		convert "$@"
	fi
}

is_supported_image() {
	case "$1" in
		*.png|*.PNG|*.jpg|*.JPG|*.jpeg|*.JPEG|*.webp|*.WEBP)
			return 0
			;;
		*)
			return 1
			;;
	esac
}

mkdir -p "$OUTPUT_DIR"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ffc-pixelize.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

processed=0
skipped=0

echo "Input:  $INPUT_DIR"
echo "Output: $OUTPUT_DIR"
echo "Canvas: ${WIDTH}x${HEIGHT}"
echo "ImageMagick: $IMAGEMAGICK_BIN"
if [ "$SKIP_QUANTIZE" -eq 0 ]; then
	echo "pngquant: enabled (colors=$COLORS, quality=$QUALITY)"
else
	echo "pngquant: disabled"
fi
if [ "$REMOVE_BG" -eq 1 ]; then
	echo "rembg: enabled"
else
	echo "rembg: disabled"
fi
if [ "$DRY_RUN" -eq 1 ]; then
	echo "Mode: dry-run"
fi

while IFS= read -r -d '' src; do
	base="$(basename "$src")"
	if ! is_supported_image "$base"; then
		continue
	fi

	stem="${base%.*}"
	dst="$OUTPUT_DIR/$stem.png"

	if [ -e "$dst" ] && [ "$OVERWRITE" -ne 1 ]; then
		echo "Skip (exists): $dst"
		skipped=$((skipped + 1))
		continue
	fi

	echo "Process: $base -> $(basename "$dst")"
	if [ "$DRY_RUN" -eq 1 ]; then
		processed=$((processed + 1))
		continue
	fi

	work_src="$src"
	if [ "$REMOVE_BG" -eq 1 ]; then
		bg_removed="$TMP_DIR/${stem}.rembg.png"
		rembg i "$src" "$bg_removed" >/dev/null 2>&1
		work_src="$bg_removed"
	fi

	processed_png="$TMP_DIR/${stem}.processed.png"
	trim_args=()
	if [ "$DO_TRIM" -eq 1 ]; then
		trim_args=(-trim +repage)
	fi

	run_imagemagick \
		"$work_src" \
		-background none \
		-alpha on \
		"${trim_args[@]}" \
		-filter point \
		-resize "${WIDTH}x${HEIGHT}" \
		-gravity south \
		-extent "${WIDTH}x${HEIGHT}" \
		"PNG32:$processed_png"

	cp "$processed_png" "$dst"

	if [ "$SKIP_QUANTIZE" -eq 0 ]; then
		quantized_png="$TMP_DIR/${stem}.quantized.png"
		if pngquant \
			--force \
			--skip-if-larger \
			--speed 1 \
			--quality="$QUALITY" \
			--output "$quantized_png" \
			-- "$dst" >/dev/null 2>&1; then
			mv "$quantized_png" "$dst"
		fi
	fi

	processed=$((processed + 1))
done < <(find "$INPUT_DIR" -maxdepth 1 -type f -print0)

echo "Done. Processed=$processed Skipped=$skipped"

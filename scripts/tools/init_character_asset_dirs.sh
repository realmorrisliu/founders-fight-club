#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<'EOF'
Usage:
  scripts/tools/init_character_asset_dirs.sh <character_id> [--force] [--dry-run]

Creates a standard AI-assisted character asset workspace:
  assets/sprites/characters/<character_id>/
    source/
      aseprite/
      prompts/
      refs/
    raw/
    clean/
    exports/
    review/

Options:
  --force     Overwrite README.md if it already exists
  --dry-run   Print actions without creating files
  --help      Show this help
EOF
}

CHAR_ID=""
FORCE=0
DRY_RUN=0

while [ "$#" -gt 0 ]; do
	case "$1" in
		--help|-h)
			usage
			exit 0
			;;
		--force)
			FORCE=1
			shift
			;;
		--dry-run)
			DRY_RUN=1
			shift
			;;
		-*)
			echo "Unknown option: $1" >&2
			usage >&2
			exit 1
			;;
		*)
			if [ -n "$CHAR_ID" ]; then
				echo "Only one <character_id> is supported." >&2
				usage >&2
				exit 1
			fi
			CHAR_ID="$1"
			shift
			;;
	esac
done

if [ -z "$CHAR_ID" ]; then
	echo "Missing <character_id>." >&2
	usage >&2
	exit 1
fi

if ! [[ "$CHAR_ID" =~ ^[a-z0-9_]+$ ]]; then
	echo "character_id must be snake_case (lowercase letters, numbers, underscores)." >&2
	exit 1
fi

ROOT_DIR="assets/sprites/characters/$CHAR_ID"
DIRS=(
	"$ROOT_DIR/source"
	"$ROOT_DIR/source/aseprite"
	"$ROOT_DIR/source/prompts"
	"$ROOT_DIR/source/refs"
	"$ROOT_DIR/raw"
	"$ROOT_DIR/clean"
	"$ROOT_DIR/exports"
	"$ROOT_DIR/review"
)

README_PATH="$ROOT_DIR/README.md"
PROMPT_TEMPLATE_PATH="$ROOT_DIR/source/prompts/prompt_template.txt"

write_file() {
	local path="$1"
	local content="$2"
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "Would write: $path"
		return
	fi
	printf "%s" "$content" > "$path"
}

for dir in "${DIRS[@]}"; do
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "Would create dir: $dir"
	else
		mkdir -p "$dir"
		touch "$dir/.gitkeep"
	fi
done

README_CONTENT=$(cat <<EOF
# $CHAR_ID Asset Workspace

Folder purposes:

- \`source/aseprite/\`: Aseprite source files (template + iterations)
- \`source/prompts/\`: AI prompts, seeds, model settings, notes
- \`source/refs/\`: reference images, pose references, concept boards
- \`raw/\`: raw AI outputs (do not rename aggressively yet)
- \`clean/\`: selected/cleaned frames (background removed, manual fixes)
- \`exports/\`: runtime-ready frames using \`<animation>_<index>.png\`
- \`review/\`: contact sheets, GIF previews, comparison images

Typical flow:

1. Generate candidates into \`raw/\`
2. Select and clean into \`clean/\`
3. Normalize/pixelize into \`exports/\`
4. Validate + generate manifest
5. Import into \`SpriteFrames.tres\`
EOF
)

if [ ! -f "$README_PATH" ] || [ "$FORCE" -eq 1 ]; then
	write_file "$README_PATH" "$README_CONTENT"$'\n'
else
	echo "Skip existing README: $README_PATH (use --force to overwrite)"
fi

PROMPT_TEMPLATE_CONTENT=$(cat <<'EOF'
# Character prompt template (fill in and version)

character_id:
model:
seed:
sampler:
steps:
cfg:
reference_images:

style_prompt:
- 2d pixel fighter character, side view
- readable silhouette
- consistent proportions across frames
- transparent background preferred (or plain background)

negative_prompt:
- extra limbs
- inconsistent clothing
- blurry edges
- perspective camera
- front-facing pose

notes:
- Keep pose aligned to template frame
- Prioritize key poses for light/heavy/special
EOF
)
if [ ! -f "$PROMPT_TEMPLATE_PATH" ] || [ "$FORCE" -eq 1 ]; then
	write_file "$PROMPT_TEMPLATE_PATH" "$PROMPT_TEMPLATE_CONTENT"$'\n'
else
	echo "Skip existing prompt template: $PROMPT_TEMPLATE_PATH (use --force to overwrite)"
fi

echo "Initialized asset workspace: $ROOT_DIR"


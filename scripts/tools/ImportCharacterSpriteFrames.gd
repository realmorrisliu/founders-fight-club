extends SceneTree

const REQUIRED_ANIMATION_NAMES := [
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
	"ko"
]

const ANIMATION_PROFILES := {
	"idle": {"fps": 8.0, "loop": true},
	"walk": {"fps": 11.0, "loop": true},
	"jump": {"fps": 9.0, "loop": false},
	"light": {"fps": 18.0, "loop": false},
	"heavy": {"fps": 9.0, "loop": false},
	"special": {"fps": 10.0, "loop": false},
	"throw": {"fps": 12.0, "loop": false},
	"block": {"fps": 8.0, "loop": true},
	"hit_light": {"fps": 11.0, "loop": false},
	"hit_heavy": {"fps": 8.0, "loop": false},
	"hit": {"fps": 10.0, "loop": false},
	"fall": {"fps": 8.0, "loop": false},
	"getup": {"fps": 9.0, "loop": false},
	"ko": {"fps": 1.0, "loop": false}
}

const FRAME_FILE_REGEX := "^(?<animation>[a-z0-9_]+)_(?<index>\\d+)\\.png$"

func _init() -> void:
	call_deferred("_main")

func _main() -> void:
	var exit_code := _run()
	quit(exit_code)

func _run() -> int:
	var args := OS.get_cmdline_user_args()
	var opts := _parse_args(args)
	if bool(opts.get("help", false)):
		_print_usage()
		return OK

	if not opts.has("exports") or not opts.has("output"):
		printerr("Missing required arguments: --exports and --output")
		_print_usage()
		return ERR_INVALID_PARAMETER

	var exports_dir := _normalize_project_path(String(opts["exports"]))
	var output_path := _normalize_project_path(String(opts["output"]))
	var require_all := bool(opts.get("require_all", false))
	var dry_run := bool(opts.get("dry_run", false))
	var verbose := bool(opts.get("verbose", false))

	var scan := _scan_exports(exports_dir)
	var errors: Array = scan.get("errors", [])
	var warnings: Array = scan.get("warnings", [])
	var frames_by_animation: Dictionary = scan.get("frames_by_animation", {})
	var missing_required: Array = scan.get("missing_required", [])
	var total_frames := int(scan.get("total_frames", 0))

	for warning in warnings:
		print("WARN: %s" % warning)
	for err in errors:
		printerr("ERROR: %s" % err)
	if require_all:
		for name in missing_required:
			printerr("ERROR: Missing required animation: %s" % name)
	if not errors.is_empty() or (require_all and not missing_required.is_empty()):
		return ERR_PARSE_ERROR

	print("Exports: %s" % exports_dir)
	print("Output:  %s" % output_path)
	print("Animations: %d | Frames: %d" % [frames_by_animation.size(), total_frames])
	if not missing_required.is_empty():
		print("Missing required animations (allowed): %s" % ", ".join(PackedStringArray(missing_required)))

	if verbose:
		var animation_names_verbose: Array = frames_by_animation.keys()
		animation_names_verbose.sort()
		for animation_name_variant in animation_names_verbose:
			var animation_name := String(animation_name_variant)
			var anim_frames: Array = frames_by_animation[animation_name]
			var indices: PackedStringArray = []
			for frame_data_variant in anim_frames:
				var frame_data: Dictionary = frame_data_variant
				indices.append(str(int(frame_data["index"])))
			print("  - %s: %d frame(s) [%s]" % [animation_name, anim_frames.size(), ", ".join(indices)])

	if dry_run:
		print("Dry run enabled; skipping SpriteFrames save.")
		return OK

	var make_dir_error := _ensure_output_directory_exists(output_path)
	if make_dir_error != OK:
		printerr("Failed to create output directory for %s (error %d)" % [output_path, make_dir_error])
		return make_dir_error

	var sprite_frames_result := _build_sprite_frames(exports_dir, frames_by_animation)
	if sprite_frames_result.has("errors") and not (sprite_frames_result["errors"] as Array).is_empty():
		for build_error in sprite_frames_result["errors"]:
			printerr("ERROR: %s" % build_error)
		return ERR_CANT_CREATE

	var sprite_frames := sprite_frames_result.get("sprite_frames") as SpriteFrames
	if sprite_frames == null:
		printerr("ERROR: Failed to build SpriteFrames resource")
		return ERR_CANT_CREATE

	var save_error := ResourceSaver.save(sprite_frames, output_path)
	if save_error != OK:
		printerr("ERROR: ResourceSaver.save failed for %s (error %d)" % [output_path, save_error])
		return save_error

	print("Saved SpriteFrames: %s" % output_path)
	return OK

func _parse_args(args: PackedStringArray) -> Dictionary:
	var opts := {}
	var index := 0
	while index < args.size():
		var arg := String(args[index])
		if arg in ["--help", "-h"]:
			opts["help"] = true
			index += 1
			continue
		if arg == "--require-all":
			opts["require_all"] = true
			index += 1
			continue
		if arg == "--dry-run":
			opts["dry_run"] = true
			index += 1
			continue
		if arg == "--verbose":
			opts["verbose"] = true
			index += 1
			continue
		if arg.begins_with("--exports="):
			opts["exports"] = arg.trim_prefix("--exports=")
			index += 1
			continue
		if arg.begins_with("--output="):
			opts["output"] = arg.trim_prefix("--output=")
			index += 1
			continue
		if arg == "--exports":
			if index + 1 < args.size():
				opts["exports"] = String(args[index + 1])
				index += 2
				continue
			opts["help"] = true
			return opts
		if arg == "--output":
			if index + 1 < args.size():
				opts["output"] = String(args[index + 1])
				index += 2
				continue
			opts["help"] = true
			return opts
		printerr("WARN: Unknown argument ignored: %s" % arg)
		index += 1
	return opts

func _normalize_project_path(path: String) -> String:
	var normalized := path.replace("\\", "/").strip_edges()
	if normalized.begins_with("res://") or normalized.begins_with("user://"):
		return normalized
	var project_root := ProjectSettings.globalize_path("res://").replace("\\", "/")
	var absolute_candidate := normalized
	if not absolute_candidate.begins_with("/"):
		absolute_candidate = (project_root.path_join(normalized)).replace("\\", "/")
	if absolute_candidate.begins_with(project_root):
		var relative := absolute_candidate.substr(project_root.length())
		return "res://%s" % relative
	return normalized

func _scan_exports(exports_dir: String) -> Dictionary:
	var result := {
		"frames_by_animation": {},
		"errors": [],
		"warnings": [],
		"missing_required": [],
		"total_frames": 0
	}
	var dir := DirAccess.open(exports_dir)
	if dir == null:
		result["errors"].append("Cannot open exports directory: %s" % exports_dir)
		return result

	var regex := RegEx.new()
	var regex_error := regex.compile(FRAME_FILE_REGEX)
	if regex_error != OK:
		result["errors"].append("Failed to compile frame filename regex (error %d)" % regex_error)
		return result

	var files := dir.get_files()
	files.sort()
	var frames_by_animation: Dictionary = {}
	for file_name_variant in files:
		var file_name := String(file_name_variant)
		if file_name.ends_with(".import"):
			continue
		if file_name.get_extension().to_lower() != "png":
			result["warnings"].append("Ignoring non-PNG file: %s" % file_name)
			continue
		var match := regex.search(file_name)
		if match == null:
			result["warnings"].append("Ignoring file with invalid naming format: %s" % file_name)
			continue

		var animation_name := match.get_string("animation")
		var frame_index := int(match.get_string("index"))
		if not frames_by_animation.has(animation_name):
			frames_by_animation[animation_name] = []
		var frame_path := "%s/%s" % [exports_dir.trim_suffix("/"), file_name]
		(frames_by_animation[animation_name] as Array).append({
			"file": file_name,
			"path": frame_path,
			"index": frame_index
		})

	var animation_names: Array = frames_by_animation.keys()
	animation_names.sort()
	for animation_name_variant in animation_names:
		var animation_name := String(animation_name_variant)
		var anim_frames := frames_by_animation[animation_name] as Array
		anim_frames.sort_custom(Callable(self, "_sort_frame_entry"))
		var seen := {}
		for frame_data_variant in anim_frames:
			var frame_data: Dictionary = frame_data_variant
			var idx := int(frame_data["index"])
			if seen.has(idx):
				result["errors"].append(
					"Duplicate frame index %d in animation '%s'" % [idx, animation_name]
				)
			else:
				seen[idx] = true
		if not anim_frames.is_empty():
			var first_idx := int((anim_frames[0] as Dictionary)["index"])
			if first_idx != 0:
				result["errors"].append(
					"Animation '%s' must start at frame 0 (found %d)" % [animation_name, first_idx]
				)
			var last_idx := int((anim_frames[-1] as Dictionary)["index"])
			var missing_indices: PackedStringArray = []
			for expected_idx in range(last_idx + 1):
				if not seen.has(expected_idx):
					missing_indices.append(str(expected_idx))
			if not missing_indices.is_empty():
				result["errors"].append(
					"Animation '%s' has missing indices: %s" % [animation_name, ", ".join(missing_indices)]
				)
			result["total_frames"] = int(result["total_frames"]) + anim_frames.size()

	for required_name in REQUIRED_ANIMATION_NAMES:
		if not frames_by_animation.has(required_name):
			(result["missing_required"] as Array).append(required_name)

	result["frames_by_animation"] = frames_by_animation
	return result

func _sort_frame_entry(a: Dictionary, b: Dictionary) -> bool:
	var a_index := int(a["index"])
	var b_index := int(b["index"])
	if a_index == b_index:
		return String(a["file"]) < String(b["file"])
	return a_index < b_index

func _build_sprite_frames(exports_dir: String, frames_by_animation: Dictionary) -> Dictionary:
	var result := {"sprite_frames": null, "errors": []}
	var sprite_frames := SpriteFrames.new()
	var animation_names: Array = frames_by_animation.keys()
	animation_names.sort()

	for animation_name_variant in animation_names:
		var animation_name := String(animation_name_variant)
		var anim_frames := frames_by_animation[animation_name] as Array
		if anim_frames.is_empty():
			continue
		if sprite_frames.has_animation(animation_name):
			sprite_frames.remove_animation(animation_name)
		sprite_frames.add_animation(animation_name)
		var profile: Dictionary = ANIMATION_PROFILES.get(animation_name, {})
		if profile.has("fps"):
			sprite_frames.set_animation_speed(animation_name, float(profile["fps"]))
		if profile.has("loop"):
			sprite_frames.set_animation_loop(animation_name, bool(profile["loop"]))

		for frame_data_variant in anim_frames:
			var frame_data: Dictionary = frame_data_variant
			var frame_path := String(frame_data["path"])
			var texture := load(frame_path)
			if texture is Texture2D:
				sprite_frames.add_frame(animation_name, texture)
			else:
				(result["errors"] as Array).append(
					"Failed to load texture: %s" % frame_path
				)
	return {
		"sprite_frames": sprite_frames,
		"errors": result["errors"]
	}

func _ensure_output_directory_exists(output_path: String) -> int:
	var output_dir_res := output_path.get_base_dir()
	if output_dir_res == "":
		return OK
	if output_dir_res.begins_with("res://") or output_dir_res.begins_with("user://"):
		var output_dir_abs := ProjectSettings.globalize_path(output_dir_res)
		if DirAccess.dir_exists_absolute(output_dir_abs):
			return OK
		return DirAccess.make_dir_recursive_absolute(output_dir_abs)
	return OK

func _print_usage() -> void:
	print("ImportCharacterSpriteFrames.gd")
	print("Usage:")
	print("  godot --headless --path . --script scripts/tools/ImportCharacterSpriteFrames.gd -- \\")
	print("    --exports res://assets/sprites/characters/founder_alpha/exports \\")
	print("    --output res://assets/sprites/characters/founder_alpha/FounderAlphaSpriteFrames.tres \\")
	print("    [--require-all] [--dry-run] [--verbose]")


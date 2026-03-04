extends RefCounted
class_name GameSettings

const SETTINGS_PATH := "user://settings.cfg"
const SETTINGS_SECTION := "controls"
const SETTINGS_KEY_PRESET := "preset"
const ENGINE_META_KEY := "ffc_control_preset"
const DISPLAY_SETTINGS_SECTION := "display"
const DISPLAY_SETTINGS_KEY_WINDOW_MODE := "window_mode"
const DISPLAY_SETTINGS_KEY_RESOLUTION := "resolution"

const CONTROL_PRESET_MODERN := "modern"
const CONTROL_PRESET_CLASSIC := "classic"
const CONTROL_PRESETS := [CONTROL_PRESET_MODERN, CONTROL_PRESET_CLASSIC]
const WINDOW_MODE_WINDOWED := "windowed"
const WINDOW_MODE_MAXIMIZED := "maximized"
const WINDOW_MODE_FULLSCREEN := "fullscreen"
const WINDOW_MODE_BORDERLESS := "borderless"
const WINDOW_MODES := [
	WINDOW_MODE_WINDOWED,
	WINDOW_MODE_MAXIMIZED,
	WINDOW_MODE_FULLSCREEN,
	WINDOW_MODE_BORDERLESS
]
const DEFAULT_RESOLUTION := Vector2i(1280, 720)
const RESOLUTION_OPTIONS := [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440)
]

const ACTIONS_WITH_KEYBOARD_LAYOUT := [
	"move_left",
	"move_right",
	"move_up",
	"move_down",
	"jump",
	"attack_light",
	"attack_heavy",
	"attack_special",
	"throw",
	"dash",
	"block"
]

const KEYBOARD_LAYOUTS := {
	CONTROL_PRESET_MODERN: {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"jump": [KEY_SPACE],
		"attack_light": [KEY_J],
		"attack_heavy": [KEY_K],
		"attack_special": [KEY_I],
		"throw": [KEY_U],
		"dash": [KEY_L],
		"block": [KEY_H]
	},
	CONTROL_PRESET_CLASSIC: {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"jump": [KEY_W, KEY_UP],
		"attack_light": [KEY_J],
		"attack_heavy": [KEY_K],
		"attack_special": [KEY_L],
		"throw": [KEY_U],
		"dash": [KEY_I],
		"block": []
	}
}

static func normalize_control_preset(preset: String) -> String:
	var normalized := preset.strip_edges().to_lower()
	if CONTROL_PRESETS.has(normalized):
		return normalized
	return CONTROL_PRESET_MODERN

static func normalize_window_mode(window_mode: String) -> String:
	var normalized := window_mode.strip_edges().to_lower()
	if WINDOW_MODES.has(normalized):
		return normalized
	return WINDOW_MODE_WINDOWED

static func normalize_resolution(resolution: Vector2i) -> Vector2i:
	var width := maxi(640, int(resolution.x))
	var height := maxi(360, int(resolution.y))
	return Vector2i(width, height)

static func resolution_to_string(resolution: Vector2i) -> String:
	var normalized := normalize_resolution(resolution)
	return "%dx%d" % [normalized.x, normalized.y]

static func parse_resolution_string(value: String, fallback: Vector2i = DEFAULT_RESOLUTION) -> Vector2i:
	var tokens := value.strip_edges().to_lower().split("x")
	if tokens.size() != 2:
		return normalize_resolution(fallback)
	var width := int(tokens[0])
	var height := int(tokens[1])
	if width <= 0 or height <= 0:
		return normalize_resolution(fallback)
	return normalize_resolution(Vector2i(width, height))

static func get_control_preset() -> String:
	var config := ConfigFile.new()
	var load_error := config.load(SETTINGS_PATH)
	if load_error != OK:
		var absolute_path := ProjectSettings.globalize_path(SETTINGS_PATH)
		load_error = config.load(absolute_path)
	if load_error != OK:
		var meta_value := str(Engine.get_meta(ENGINE_META_KEY, ""))
		return "" if meta_value == "" else normalize_control_preset(meta_value)
	var value := str(config.get_value(SETTINGS_SECTION, SETTINGS_KEY_PRESET, ""))
	if value == "":
		var meta_value := str(Engine.get_meta(ENGINE_META_KEY, ""))
		return "" if meta_value == "" else normalize_control_preset(meta_value)
	return normalize_control_preset(value)

static func has_control_preset() -> bool:
	return get_control_preset() != ""

static func get_video_settings() -> Dictionary:
	var config := ConfigFile.new()
	var load_error := config.load(SETTINGS_PATH)
	if load_error != OK:
		var absolute_path := ProjectSettings.globalize_path(SETTINGS_PATH)
		load_error = config.load(absolute_path)
	var window_mode := WINDOW_MODE_WINDOWED
	var resolution := DEFAULT_RESOLUTION
	if load_error == OK:
		window_mode = normalize_window_mode(str(config.get_value(DISPLAY_SETTINGS_SECTION, DISPLAY_SETTINGS_KEY_WINDOW_MODE, WINDOW_MODE_WINDOWED)))
		resolution = parse_resolution_string(
			str(config.get_value(DISPLAY_SETTINGS_SECTION, DISPLAY_SETTINGS_KEY_RESOLUTION, resolution_to_string(DEFAULT_RESOLUTION))),
			DEFAULT_RESOLUTION
		)
	return {
		"window_mode": window_mode,
		"resolution": resolution
	}

static func set_control_preset(preset: String) -> void:
	var normalized := normalize_control_preset(preset)
	apply_control_preset(normalized)
	_save_control_preset(normalized)

static func set_video_settings(window_mode: String, resolution: Vector2i) -> void:
	var normalized_mode := normalize_window_mode(window_mode)
	var normalized_resolution := normalize_resolution(resolution)
	apply_video_settings(normalized_mode, normalized_resolution)
	_save_video_settings(normalized_mode, normalized_resolution)

static func apply_control_preset(preset: String) -> void:
	var normalized := normalize_control_preset(preset)
	var layout: Dictionary = KEYBOARD_LAYOUTS.get(normalized, KEYBOARD_LAYOUTS[CONTROL_PRESET_MODERN])
	for action_name in ACTIONS_WITH_KEYBOARD_LAYOUT:
		_clear_action_keyboard_events(action_name)
		var keys: Array = layout.get(action_name, [])
		for key in keys:
			_add_key_event(action_name, int(key))
	Engine.set_meta(ENGINE_META_KEY, normalized)

static func apply_saved_video_settings() -> void:
	var settings := get_video_settings()
	var window_mode := normalize_window_mode(str(settings.get("window_mode", WINDOW_MODE_WINDOWED)))
	var resolution_value: Variant = settings.get("resolution", DEFAULT_RESOLUTION)
	var resolution := DEFAULT_RESOLUTION
	if resolution_value is Vector2i:
		resolution = normalize_resolution(resolution_value as Vector2i)
	apply_video_settings(window_mode, resolution)

static func apply_video_settings(window_mode: String, resolution: Vector2i) -> void:
	var normalized_mode := normalize_window_mode(window_mode)
	var normalized_resolution := normalize_resolution(resolution)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	match normalized_mode:
		WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		WINDOW_MODE_MAXIMIZED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		WINDOW_MODE_BORDERLESS:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			var screen_size := _get_primary_screen_size()
			if screen_size.x > 0 and screen_size.y > 0:
				DisplayServer.window_set_size(screen_size)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(normalized_resolution)

static func _save_control_preset(preset: String) -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value(SETTINGS_SECTION, SETTINGS_KEY_PRESET, preset)
	var save_error := config.save(SETTINGS_PATH)
	if save_error == OK:
		return
	var absolute_path := ProjectSettings.globalize_path(SETTINGS_PATH)
	var dir_path := absolute_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir_path)
	config.save(absolute_path)

static func _save_video_settings(window_mode: String, resolution: Vector2i) -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value(DISPLAY_SETTINGS_SECTION, DISPLAY_SETTINGS_KEY_WINDOW_MODE, normalize_window_mode(window_mode))
	config.set_value(DISPLAY_SETTINGS_SECTION, DISPLAY_SETTINGS_KEY_RESOLUTION, resolution_to_string(resolution))
	var save_error := config.save(SETTINGS_PATH)
	if save_error == OK:
		return
	var absolute_path := ProjectSettings.globalize_path(SETTINGS_PATH)
	var dir_path := absolute_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir_path)
	config.save(absolute_path)

static func _clear_action_keyboard_events(action_name: String) -> void:
	if not InputMap.has_action(action_name):
		return
	var events := InputMap.action_get_events(action_name)
	for event in events:
		if event is InputEventKey:
			InputMap.action_erase_event(action_name, event)

static func _add_key_event(action_name: String, keycode: int) -> void:
	if not InputMap.has_action(action_name):
		return
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	InputMap.action_add_event(action_name, event)

static func _get_primary_screen_size() -> Vector2i:
	return DisplayServer.screen_get_size()

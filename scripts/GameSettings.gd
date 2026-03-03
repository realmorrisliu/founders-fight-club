extends RefCounted
class_name GameSettings

const SETTINGS_PATH := "user://settings.cfg"
const SETTINGS_SECTION := "controls"
const SETTINGS_KEY_PRESET := "preset"
const ENGINE_META_KEY := "ffc_control_preset"

const CONTROL_PRESET_MODERN := "modern"
const CONTROL_PRESET_CLASSIC := "classic"
const CONTROL_PRESETS := [CONTROL_PRESET_MODERN, CONTROL_PRESET_CLASSIC]

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

static func set_control_preset(preset: String) -> void:
	var normalized := normalize_control_preset(preset)
	apply_control_preset(normalized)
	_save_control_preset(normalized)

static func apply_control_preset(preset: String) -> void:
	var normalized := normalize_control_preset(preset)
	var layout: Dictionary = KEYBOARD_LAYOUTS.get(normalized, KEYBOARD_LAYOUTS[CONTROL_PRESET_MODERN])
	for action_name in ACTIONS_WITH_KEYBOARD_LAYOUT:
		_clear_action_keyboard_events(action_name)
		var keys: Array = layout.get(action_name, [])
		for key in keys:
			_add_key_event(action_name, int(key))
	Engine.set_meta(ENGINE_META_KEY, normalized)

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

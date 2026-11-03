extends RefCounted

const SCHEMA_VERSION := 1
const MAX_FRAMES := 22000
const MODES := ["local", "cpu", "story", "training"]
const CONTROLS := ["script", "cpu", "idle"]
const SCENE_BY_MODE := {
	"local": "res://scenes/Main.tscn",
	"cpu": "res://scenes/Main.tscn",
	"story": "res://scenes/Story.tscn",
	"training": "res://scenes/Training.tscn"
}
const STAGE_ID := "grand_arena"
const BUTTONS := [
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
	"block",
	"pause",
	"restart"
]
const BUTTON_ALIASES := {
	"left": "move_left",
	"right": "move_right",
	"up": "move_up",
	"down": "move_down",
	"light": "attack_light",
	"heavy": "attack_heavy",
	"special": "attack_special"
}

static func load_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "error": "replay file not found: %s" % path}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "error": "replay file must be a JSON object: %s" % path}
	return normalize(parsed)

static func normalize(raw: Dictionary) -> Dictionary:
	var source := raw.duplicate(true)
	var nested_value: Variant = source.get("overrides", {})
	if typeof(nested_value) == TYPE_DICTIONARY:
		var nested := nested_value as Dictionary
		for key in ["stocks", "timer_enabled", "timer_seconds"]:
			if nested.has(key) and not source.has(key):
				source[key] = nested[key]
	raw = source
	var mode := str(raw.get("mode", "local")).strip_edges().to_lower()
	if mode == "vs" or mode == "versus":
		mode = "local"
	if not MODES.has(mode):
		return {"ok": false, "error": "mode must be local, cpu, story, or training"}
	var stage := str(raw.get("stage", STAGE_ID)).strip_edges().to_lower()
	if stage == "":
		stage = STAGE_ID
	if stage != STAGE_ID:
		return {"ok": false, "error": "only stage '%s' exists" % STAGE_ID}
	var frames := _as_int(raw.get("frames", 0), 0)
	if frames < 1 or frames > MAX_FRAMES:
		return {"ok": false, "error": "frames must be from 1 to %d" % MAX_FRAMES}
	var seed := _as_int(raw.get("seed", 1), 1)
	var p1_control := _control(raw.get("p1_control", ""), mode, true)
	var p2_control := _control(raw.get("p2_control", ""), mode, false)
	if p1_control == "":
		return {"ok": false, "error": "p1_control must be script, cpu, or idle"}
	if p2_control == "":
		return {"ok": false, "error": "p2_control must be script, cpu, or idle"}
	var inputs_value: Variant = raw.get("inputs", [])
	var parsed_inputs := _parse_inputs(inputs_value, frames)
	if not bool(parsed_inputs.get("ok", false)):
		return parsed_inputs
	var screenshots := _parse_frames(raw.get("screenshots", []), frames)
	if not bool(screenshots.get("ok", false)):
		return screenshots
	var spec := {
		"version": SCHEMA_VERSION,
		"seed": seed,
		"mode": mode,
		"scene": SCENE_BY_MODE[mode],
		"stage": stage,
		"frames": frames,
		"p1": str(raw.get("p1", "")).strip_edges(),
		"p2": str(raw.get("p2", "")).strip_edges(),
		"p1_control": p1_control,
		"p2_control": p2_control,
		"onboarding": _as_bool(raw.get("onboarding", false), false),
		"control_preset": _preset(raw.get("control_preset", "modern")),
		"inputs": parsed_inputs.get("inputs", []),
		"screenshots": screenshots.get("frames", []),
		"setup": _parse_setup(raw.get("setup", {})),
		"overrides": {}
	}
	var overrides: Dictionary = spec["overrides"]
	if raw.has("stocks"):
		var stocks := _as_int(raw.get("stocks", 3), 3)
		if stocks < 1 or stocks > 7:
			return {"ok": false, "error": "stocks must be from 1 to 7"}
		overrides["stocks"] = stocks
	if raw.has("timer_enabled"):
		overrides["timer_enabled"] = _as_bool(raw.get("timer_enabled", true), true)
	if raw.has("timer_seconds"):
		var timer_seconds := float(raw.get("timer_seconds", 60.0))
		if timer_seconds < 0.0 or timer_seconds > 600.0:
			return {"ok": false, "error": "timer_seconds must be from 0 to 600"}
		overrides["timer_seconds"] = timer_seconds
	return {"ok": true, "spec": spec}

static func merge_input_file(spec_raw: Dictionary, path: String) -> Dictionary:
	if path == "":
		return spec_raw
	if not FileAccess.file_exists(path):
		return {"ok": false, "error": "input file not found: %s" % path}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	var merged := spec_raw.duplicate(true)
	if typeof(parsed) == TYPE_ARRAY:
		merged["inputs"] = parsed
		return merged
	if typeof(parsed) == TYPE_DICTIONARY:
		var doc := parsed as Dictionary
		if doc.has("inputs"):
			merged["inputs"] = doc.get("inputs", [])
			return merged
	return {"ok": false, "error": "input file must be a JSON array or an object with inputs"}

static func _control(value: Variant, mode: String, is_p1: bool) -> String:
	var text := str(value).strip_edges().to_lower()
	if text == "":
		if is_p1:
			return "script" if mode != "training" else "script"
		match mode:
			"cpu", "story":
				return "cpu"
			"training":
				return "idle"
			_:
				return "script"
	if CONTROLS.has(text):
		return text
	return ""

static func _preset(value: Variant) -> String:
	var text := str(value).strip_edges().to_lower()
	if text == "classic":
		return "classic"
	return "modern"

static func _parse_inputs(value: Variant, frames: int) -> Dictionary:
	if typeof(value) != TYPE_ARRAY:
		return {"ok": false, "error": "inputs must be an array"}
	var samples: Array = []
	for item in value:
		if typeof(item) != TYPE_DICTIONARY:
			return {"ok": false, "error": "each input sample must be an object"}
		var sample := item as Dictionary
		var frame := _as_int(sample.get("frame", sample.get("f", -1)), -1)
		if frame < 0 or frame >= frames:
			return {"ok": false, "error": "input frame %s is outside 0..%d" % [str(frame), frames - 1]}
		var parsed := {"frame": frame}
		if sample.has("p1"):
			var p1_buttons := _parse_buttons(sample.get("p1", {}))
			if not bool(p1_buttons.get("ok", false)):
				return p1_buttons
			parsed["p1"] = p1_buttons.get("buttons", {})
		if sample.has("p2"):
			var p2_buttons := _parse_buttons(sample.get("p2", {}))
			if not bool(p2_buttons.get("ok", false)):
				return p2_buttons
			parsed["p2"] = p2_buttons.get("buttons", {})
		samples.append(parsed)
	samples.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("frame", 0)) < int(b.get("frame", 0)))
	return {"ok": true, "inputs": samples}

static func _parse_buttons(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return {"ok": false, "error": "player input must be an object of buttons"}
	var source := value as Dictionary
	var buttons := {}
	for key in source.keys():
		var name := str(key).strip_edges().to_lower()
		if BUTTON_ALIASES.has(name):
			name = str(BUTTON_ALIASES[name])
		if not BUTTONS.has(name):
			return {"ok": false, "error": "unknown button '%s'" % name}
		buttons[name] = _as_bool(source[key], false) or _as_int(source[key], 0) > 0
	return {"ok": true, "buttons": buttons}

static func _parse_frames(value: Variant, frames: int) -> Dictionary:
	if typeof(value) != TYPE_ARRAY:
		return {"ok": false, "error": "screenshots must be an array of frame indexes"}
	var indexes: Array[int] = []
	for item in value:
		var frame := _as_int(item, -1)
		if frame < 0 or frame >= frames:
			return {"ok": false, "error": "screenshot frame %s is outside 0..%d" % [str(item), frames - 1]}
		if not indexes.has(frame):
			indexes.append(frame)
	indexes.sort()
	return {"ok": true, "frames": indexes}

static func _parse_setup(value: Variant) -> Dictionary:
	var setup := {"p1": {}, "p2": {}}
	if typeof(value) != TYPE_DICTIONARY:
		return setup
	var source := value as Dictionary
	for side in ["p1", "p2"]:
		var side_value: Variant = source.get(side, {})
		if typeof(side_value) != TYPE_DICTIONARY:
			continue
		var side_raw := side_value as Dictionary
		var side_setup := {}
		for key in ["percent", "x", "y"]:
			if side_raw.has(key):
				side_setup[key] = float(side_raw.get(key, 0.0))
		setup[side] = side_setup
	return setup

static func _as_int(value: Variant, fallback: int) -> int:
	match typeof(value):
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return int(value)
		TYPE_BOOL:
			return 1 if bool(value) else 0
		_:
			var text := str(value).strip_edges()
			if text.is_valid_int():
				return int(text)
			if text.is_valid_float():
				return int(float(text))
	return fallback

static func _as_bool(value: Variant, fallback: bool) -> bool:
	if typeof(value) == TYPE_BOOL:
		return bool(value)
	if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
		return float(value) != 0.0
	var text := str(value).strip_edges().to_lower()
	if text in ["1", "true", "yes", "on"]:
		return true
	if text in ["0", "false", "no", "off"]:
		return false
	return fallback

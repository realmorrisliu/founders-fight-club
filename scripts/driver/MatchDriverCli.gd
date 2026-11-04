extends SceneTree

const ReplayScriptStore := preload("res://scripts/driver/ReplayScript.gd")
const MatchDriverScript := preload("res://scripts/driver/MatchDriver.gd")
const SessionKeysStore := preload("res://scripts/config/SessionKeys.gd")
const SessionStateStore := preload("res://scripts/SessionState.gd")

const MENU_BUTTONS := {
	"first-launch-modern": "FirstLaunchControlOverlay/Panel/ModernButton",
	"first-launch-classic": "FirstLaunchControlOverlay/Panel/ClassicButton",
	"versus": "CenterPanel/VersusButton",
	"story": "CenterPanel/StoryButton",
	"training": "CenterPanel/TrainingButton",
	"advanced": "AdvancedToggleButton",
	"control-style": "CenterPanel/ControlStyleButton"
}

func _initialize() -> void:
	call_deferred("_main")

func _main() -> void:
	var args := OS.get_cmdline_user_args()
	var command := "run"
	var rest: PackedStringArray = args
	if args.size() > 0 and not str(args[0]).begins_with("--"):
		command = str(args[0]).strip_edges().to_lower()
		rest = _slice(args, 1)
	match command:
		"doctor":
			_doctor()
		"hash":
			_hash_command(rest)
		"ui":
			await _ui_command(rest)
		"run", "replay":
			await _run_command(rest)
		"help", "--help", "-h":
			_print_help()
			quit(0)
		_:
			print("error: unknown command '%s'" % command)
			_print_help()
			quit(1)

func _doctor() -> void:
	var info := Engine.get_version_info()
	var version := "%s.%s.%s" % [str(info.get("major", "")), str(info.get("minor", "")), str(info.get("patch", ""))]
	var expected := FileAccess.get_file_as_string("res://GODOT_VERSION").strip_edges()
	print("godot=%s" % version)
	print("expected=%s" % expected)
	print("project=res://project.godot")
	print("driver=res://scripts/driver/MatchDriverCli.gd")
	print("headless=%s" % str(DisplayServer.get_name() == "headless" or OS.has_feature("headless")))
	if not version.begins_with(expected):
		print("ok=0")
		quit(1)
		return
	print("ok=1")
	quit(0)

func _hash_command(args: PackedStringArray) -> void:
	if args.is_empty() or not FileAccess.file_exists(str(args[0])):
		print("error: hash needs an existing state log")
		quit(1)
		return
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(FileAccess.get_file_as_bytes(str(args[0])))
	print("hash=%s" % ctx.finish().hex_encode())
	print("ok=1")
	quit(0)

func _run_command(args: PackedStringArray) -> void:
	var parsed := _parse_run_args(args)
	if not bool(parsed.get("ok", false)):
		print("error: %s" % str(parsed.get("error", "bad arguments")))
		quit(1)
		return
	var raw: Dictionary = parsed.get("raw", {})
	var out_path := str(parsed.get("out", ""))
	var screenshot_dir := str(parsed.get("screenshot_dir", ""))
	if out_path == "":
		print("error: --out is required")
		quit(1)
		return
	var parent := out_path.get_base_dir()
	if parent != "":
		DirAccess.make_dir_recursive_absolute(parent)
	var driver := MatchDriverScript.new()
	driver.name = "MatchDriver"
	root.add_child(driver)
	var result: Dictionary = await driver.run(raw, out_path, screenshot_dir)
	if not bool(result.get("ok", false)):
		print("error: %s" % str(result.get("error", "driver failed")))
		print("ok=0")
		quit(1)
		return
	var final_state: Dictionary = result.get("final", {})
	print("hash=%s" % str(result.get("hash", "")))
	print("frames=%s" % str(result.get("frames", 0)))
	print("out=%s" % str(result.get("out", out_path)))
	print("final_phase=%s" % str(final_state.get("phase", "")))
	print("final_winner=%s" % str(final_state.get("winner", "")))
	print("ok=1")
	quit(0)

func _ui_command(args: PackedStringArray) -> void:
	var presses: Array[String] = []
	var out_path := ""
	var screenshot := ""
	var index := 0
	while index < args.size():
		var arg := str(args[index])
		if arg == "--press" and index + 1 < args.size():
			presses.append(str(args[index + 1]).strip_edges().to_lower())
			index += 2
			continue
		if arg == "--out" and index + 1 < args.size():
			out_path = str(args[index + 1])
			index += 2
			continue
		if arg == "--screenshot" and index + 1 < args.size():
			screenshot = str(args[index + 1])
			index += 2
			continue
		print("error: unknown ui argument '%s'" % arg)
		quit(1)
		return
	if presses.is_empty():
		print("error: --press must be first-launch-modern, first-launch-classic, versus, story, training, or control-style")
		quit(1)
		return
	for press in presses:
		if not MENU_BUTTONS.has(press):
			print("error: unknown --press '%s'" % press)
			quit(1)
			return
	var packed := load("res://scenes/Menu.tscn")
	if packed == null or not (packed is PackedScene):
		print("error: menu scene failed to load")
		quit(1)
		return
	var menu := (packed as PackedScene).instantiate()
	root.add_child(menu)
	current_scene = menu
	await process_frame
	await process_frame
	var steps: Array = []
	for press in presses:
		var button := menu.get_node_or_null(str(MENU_BUTTONS[press])) as BaseButton
		if button == null or not is_instance_valid(button):
			button = current_scene.get_node_or_null(str(MENU_BUTTONS[press])) as BaseButton if current_scene != null else null
		if button == null:
			print("error: menu button '%s' is missing" % press)
			quit(1)
			return
		if button.disabled:
			print("error: '%s' is disabled. A fresh profile must press first-launch-modern or first-launch-classic first." % press)
			quit(1)
			return
		var before_text := str(button.text)
		button.pressed.emit()
		await process_frame
		await process_frame
		await process_frame
		steps.append({
			"press": press,
			"button_text_before": before_text,
			"button_text_after": str(button.text) if is_instance_valid(button) else ""
		})
		menu = current_scene
	var press := presses[presses.size() - 1]
	var scene := current_scene as Node
	var record := {
		"press": press,
		"steps": steps,
		"match_mode": str(SessionStateStore.get_value(SessionKeysStore.MATCH_MODE, "")),
		"p1_character": str(SessionStateStore.get_value(SessionKeysStore.PLAYER_1_ID, "")),
		"p2_character": str(SessionStateStore.get_value(SessionKeysStore.PLAYER_2_ID, "")),
		"scene": str(scene.name) if scene != null else "",
		"scene_script": str(scene.get_script().resource_path) if scene != null and scene.get_script() != null else ""
	}
	if scene != null:
		var p1 := scene.get_node_or_null("Player1")
		var p2 := scene.get_node_or_null("Player2")
		record["p1_is_ai"] = _prop_bool(p1, "is_ai")
		record["p2_is_ai"] = _prop_bool(p2, "is_ai")
		record["training"] = _prop_bool(scene, "training_scene_enabled")
		record["stocks"] = _prop_int(scene, "stock_count")
		record["time_left"] = _prop_float(scene, "time_left", -1.0)
		record["timer_enabled"] = _prop_bool(scene, "round_timer_enabled")
		var hud := scene.get_node_or_null("Hud")
		if hud != null:
			var pause_panel := hud.get_node_or_null("PausePanel")
			record["pause_visible"] = bool(pause_panel.visible) if pause_panel is CanvasItem else false
	if screenshot != "":
		var parent := screenshot.get_base_dir()
		if parent != "":
			DirAccess.make_dir_recursive_absolute(parent)
		if not (OS.has_feature("headless") or DisplayServer.get_name() == "headless"):
			await RenderingServer.frame_post_draw
		var image := root.get_viewport().get_texture().get_image()
		if image != null:
			image.save_png(screenshot)
			record["screenshot"] = screenshot
	var body := JSON.stringify(record, "\t")
	if out_path != "":
		var parent_dir := out_path.get_base_dir()
		if parent_dir != "":
			DirAccess.make_dir_recursive_absolute(parent_dir)
		var file := FileAccess.open(out_path, FileAccess.WRITE)
		if file == null:
			print("error: cannot write %s" % out_path)
			quit(1)
			return
		file.store_string(body)
		file.close()
	print(body)
	print("ok=1")
	quit(0)

func _parse_run_args(args: PackedStringArray) -> Dictionary:
	var raw := {
		"mode": "local",
		"stage": "grand_arena",
		"seed": 1,
		"frames": 0,
		"p1": "",
		"p2": "",
		"inputs": [],
		"screenshots": [],
		"setup": {"p1": {}, "p2": {}},
		"onboarding": false,
		"control_preset": "modern"
	}
	var out_path := ""
	var screenshot_dir := ""
	var input_path := ""
	var replay_path := ""
	var index := 0
	while index < args.size():
		var arg := str(args[index])
		var value := ""
		if index + 1 < args.size():
			value = str(args[index + 1])
		match arg:
			"--replay":
				replay_path = value
				index += 2
			"--seed":
				raw["seed"] = value
				index += 2
			"--mode":
				raw["mode"] = value
				index += 2
			"--stage":
				raw["stage"] = value
				index += 2
			"--frames":
				raw["frames"] = value
				index += 2
			"--p1":
				raw["p1"] = value
				index += 2
			"--p2":
				raw["p2"] = value
				index += 2
			"--p1-control":
				raw["p1_control"] = value
				index += 2
			"--p2-control":
				raw["p2_control"] = value
				index += 2
			"--stocks":
				raw["stocks"] = value
				index += 2
			"--timer-enabled":
				raw["timer_enabled"] = value
				index += 2
			"--timer-seconds":
				raw["timer_seconds"] = value
				index += 2
			"--onboarding":
				raw["onboarding"] = value
				index += 2
			"--control-preset":
				raw["control_preset"] = value
				index += 2
			"--hud":
				if value == "" or value.begins_with("--"):
					return {"ok": false, "error": "hud must be cards, corners, or marquee"}
				raw["hud"] = value
				index += 2
			"--input":
				input_path = value
				index += 2
			"--out":
				out_path = value
				index += 2
			"--screenshot-dir":
				screenshot_dir = value
				index += 2
			"--screenshots":
				var frames: Array = []
				for piece in value.split(",", false):
					frames.append(int(piece.strip_edges()))
				raw["screenshots"] = frames
				index += 2
			"--setup-p1-percent", "--setup-p2-percent", "--setup-p1-x", "--setup-p1-y", "--setup-p2-x", "--setup-p2-y":
				_assign_setup(raw, arg, value)
				index += 2
			_:
				return {"ok": false, "error": "unknown argument '%s'" % arg}
	if replay_path != "":
		var loaded := ReplayScriptStore.load_file(replay_path)
		if not bool(loaded.get("ok", false)):
			return loaded
		var spec: Dictionary = loaded.get("spec", {})
		raw = _spec_to_raw(spec)
		# Flags after the file override it. Re-parse is unnecessary because we already applied flags into raw first.
		# A replay file is the source when --replay is set, then explicit flags win because they were written into a fresh raw.
		# Rebuild by loading the file and overlaying only the flags that were present.
		raw = _overlay_replay(replay_path, args)
		if not bool(raw.get("ok", true)) and raw.has("error") and not raw.has("mode"):
			return raw
	if input_path != "":
		var merged := ReplayScriptStore.merge_input_file(raw, input_path)
		if merged.has("error") and not merged.has("mode"):
			return merged
		raw = merged
	return {"ok": true, "raw": raw, "out": out_path, "screenshot_dir": screenshot_dir}

func _overlay_replay(path: String, args: PackedStringArray) -> Dictionary:
	var loaded := ReplayScriptStore.load_file(path)
	if not bool(loaded.get("ok", false)):
		return loaded
	var spec: Dictionary = loaded.get("spec", {})
	var raw := _spec_to_raw(spec)
	var index := 0
	while index < args.size():
		var arg := str(args[index])
		if arg == "--replay" or arg == "--input" or arg == "--out" or arg == "--screenshot-dir":
			index += 2
			continue
		if arg == "--screenshots" or arg.begins_with("--setup-") or arg in ["--seed", "--mode", "--stage", "--frames", "--p1", "--p2", "--p1-control", "--p2-control", "--stocks", "--timer-enabled", "--timer-seconds", "--onboarding", "--control-preset", "--hud"]:
			var value := str(args[index + 1]) if index + 1 < args.size() else ""
			match arg:
				"--seed":
					raw["seed"] = value
				"--mode":
					raw["mode"] = value
				"--stage":
					raw["stage"] = value
				"--frames":
					raw["frames"] = value
				"--p1":
					raw["p1"] = value
				"--p2":
					raw["p2"] = value
				"--p1-control":
					raw["p1_control"] = value
				"--p2-control":
					raw["p2_control"] = value
				"--stocks":
					raw["stocks"] = value
				"--timer-enabled":
					raw["timer_enabled"] = value
				"--timer-seconds":
					raw["timer_seconds"] = value
				"--onboarding":
					raw["onboarding"] = value
				"--control-preset":
					raw["control_preset"] = value
				"--hud":
					if value == "" or value.begins_with("--"):
						return {"ok": false, "error": "hud must be cards, corners, or marquee"}
					raw["hud"] = value
				"--screenshots":
					var frames: Array = []
					for piece in value.split(",", false):
						frames.append(int(piece.strip_edges()))
					raw["screenshots"] = frames
				_:
					_assign_setup(raw, arg, value)
			index += 2
			continue
		return {"ok": false, "error": "unknown argument '%s'" % arg}
	return raw

func _spec_to_raw(spec: Dictionary) -> Dictionary:
	var raw := spec.duplicate(true)
	var overrides: Dictionary = spec.get("overrides", {})
	if overrides.has("stocks"):
		raw["stocks"] = overrides.get("stocks")
	if overrides.has("timer_enabled"):
		raw["timer_enabled"] = overrides.get("timer_enabled")
	if overrides.has("timer_seconds"):
		raw["timer_seconds"] = overrides.get("timer_seconds")
	raw.erase("overrides")
	raw.erase("scene")
	return raw

func _assign_setup(raw: Dictionary, arg: String, value: String) -> void:
	var setup: Dictionary = raw.get("setup", {"p1": {}, "p2": {}})
	var side := "p1" if arg.begins_with("--setup-p1") else "p2"
	var side_setup: Dictionary = setup.get(side, {})
	if arg.ends_with("percent"):
		side_setup["percent"] = float(value)
	elif arg.ends_with("-x"):
		side_setup["x"] = float(value)
	elif arg.ends_with("-y"):
		side_setup["y"] = float(value)
	setup[side] = side_setup
	raw["setup"] = setup

func _prop_bool(node: Node, property_name: String) -> bool:
	if node == null:
		return false
	var value: Variant = node.get(property_name)
	return typeof(value) == TYPE_BOOL and bool(value)

func _prop_int(node: Node, property_name: String) -> int:
	if node == null:
		return 0
	var value: Variant = node.get(property_name)
	if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
		return int(value)
	return 0

func _prop_float(node: Node, property_name: String, fallback: float) -> float:
	if node == null:
		return fallback
	var value: Variant = node.get(property_name)
	if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
		return float(value)
	return fallback

func _slice(args: PackedStringArray, start: int) -> PackedStringArray:
	var rest := PackedStringArray()
	for index in range(start, args.size()):
		rest.append(str(args[index]))
	return rest

func _print_help() -> void:
	print("Usage:")
	print("  ffc.sh doctor")
	print("  ffc.sh run --frames N --out states.jsonl [--seed N] [--mode local|cpu|story|training] [--hud cards|corners|marquee]")
	print("  ffc.sh replay --replay match.json --out states.jsonl")
	print("  ffc.sh ui --press first-launch-modern --press story --out ui.json")
	print("  ffc.sh hash states.jsonl")
	print("Buttons in an input sample: move_left, move_right, move_up, move_down, jump,")
	print("attack_light, attack_heavy, attack_special, throw, dash, block, pause, restart.")
	print("A sample replaces that side's held buttons. Omit a side to leave it unchanged.")

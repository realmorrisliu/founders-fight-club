extends Node

const ReplayScriptStore := preload("res://scripts/driver/ReplayScript.gd")
const CharacterCatalogStore := preload("res://scripts/config/CharacterCatalog.gd")
const SessionKeysStore := preload("res://scripts/config/SessionKeys.gd")
const SessionStateStore := preload("res://scripts/SessionState.gd")
const GameSettingsStore := preload("res://scripts/GameSettings.gd")

const MAX_HP := 100
const SESSION_KEYS := [
	SessionKeysStore.PLAYER_1_ID,
	SessionKeysStore.PLAYER_2_ID,
	SessionKeysStore.PLAYER_1_TABLE_PATH,
	SessionKeysStore.PLAYER_2_TABLE_PATH,
	SessionKeysStore.PLAYER_1_NAME,
	SessionKeysStore.PLAYER_2_NAME,
	SessionKeysStore.PLAYER_1_LOADOUT,
	SessionKeysStore.PLAYER_2_LOADOUT,
	SessionKeysStore.MATCH_MODE,
	SessionKeysStore.STORY_ROUND_INDEX,
	SessionKeysStore.ONBOARDING_FORCE_REPLAY,
	SessionKeysStore.ONBOARDING_ENTRY_POINT
]

var _match: Node = null
var _held := {"p1": {}, "p2": {}}
var _match_buttons := {"pause": false, "restart": false}

func run(raw_spec: Dictionary, log_path: String, screenshot_dir: String = "") -> Dictionary:
	var normalized := ReplayScriptStore.normalize(raw_spec)
	if not bool(normalized.get("ok", false)):
		return {"ok": false, "error": str(normalized.get("error", "invalid replay"))}
	var spec: Dictionary = normalized.get("spec", {})
	var saved_session := _snapshot_session()
	var saved_preset := str(Engine.get_meta(GameSettingsStore.ENGINE_META_KEY, ""))
	var log_file := FileAccess.open(log_path, FileAccess.WRITE)
	if log_file == null:
		return {"ok": false, "error": "cannot write %s" % log_path}
	var failure := _boot(spec)
	if failure != "":
		log_file.close()
		_restore_session(saved_session)
		_restore_preset(saved_preset)
		return {"ok": false, "error": failure}
	var frames := int(spec.get("frames", 0))
	var screenshot_set := {}
	for frame_value in spec.get("screenshots", []):
		screenshot_set[int(frame_value)] = true
	if screenshot_dir != "" and not screenshot_set.is_empty():
		DirAccess.make_dir_recursive_absolute(screenshot_dir)
	for frame_index in range(frames):
		# Press inside the physics frame so just_pressed lines up with _physics_process.
		await get_tree().physics_frame
		if not is_instance_valid(_match):
			_match = get_tree().current_scene
			_prepare_reloaded_match(spec)
		_apply_frame_inputs(spec, frame_index)
		_deliver_match_buttons()
		await get_tree().process_frame
		_record_frame(log_file, frame_index)
		if screenshot_set.has(frame_index) and screenshot_dir != "":
			# Headless never emits frame_post_draw, so waiting there stalls the run.
			if not _headless_display():
				await RenderingServer.frame_post_draw
			_save_screenshot(screenshot_dir, frame_index)
	log_file.close()
	var digest := _hash_file(log_path)
	var final_state := _read_last_state(log_path)
	_release_driver_inputs()
	_drop_match()
	_match = null
	await get_tree().process_frame
	_restore_session(saved_session)
	_restore_preset(saved_preset)
	return {
		"ok": true,
		"hash": digest,
		"frames": frames,
		"out": log_path,
		"final": final_state
	}

func _drop_match() -> void:
	if not is_instance_valid(_match):
		return
	if get_tree().current_scene == _match:
		var stale := get_tree().root.get_node_or_null("MatchDriverPlaceholder")
		if stale != null:
			stale.free()
		var placeholder := Node2D.new()
		placeholder.name = "MatchDriverPlaceholder"
		get_tree().root.add_child(placeholder)
		get_tree().current_scene = placeholder
	_match.queue_free()

func _boot(spec: Dictionary) -> String:
	_held = {"p1": {}, "p2": {}}
	_match_buttons = {"pause": false, "restart": false}
	var unknown := _unknown_character(spec)
	if unknown != "":
		return "unknown character '%s'" % unknown
	_apply_session(spec)
	Engine.set_meta(GameSettingsStore.ENGINE_META_KEY, str(spec.get("control_preset", "modern")))
	seed(int(spec.get("seed", 1)))
	var packed := load(str(spec.get("scene", "")))
	if packed == null or not (packed is PackedScene):
		return "scene failed to load: %s" % str(spec.get("scene", ""))
	var match_node := (packed as PackedScene).instantiate()
	_apply_overrides_before_ready(match_node, spec)
	get_tree().root.add_child(match_node)
	get_tree().current_scene = match_node
	_match = match_node
	_reseed_match_rngs(match_node, int(spec.get("seed", 1)))
	_apply_setup(match_node, spec)
	_apply_controls(match_node, spec)
	return ""

func _prepare_reloaded_match(spec: Dictionary) -> void:
	if not is_instance_valid(_match):
		return
	_reseed_match_rngs(_match, int(spec.get("seed", 1)))
	_apply_controls(_match, spec)

func _apply_overrides_before_ready(match_node: Node, spec: Dictionary) -> void:
	match_node.set("onboarding_enabled", bool(spec.get("onboarding", false)))
	var overrides: Dictionary = spec.get("overrides", {})
	if overrides.has("stocks"):
		match_node.set("stock_count", int(overrides.get("stocks", 3)))
	if overrides.has("timer_enabled"):
		match_node.set("round_timer_enabled", bool(overrides.get("timer_enabled", true)))

func _reseed_match_rngs(match_node: Node, match_seed: int) -> void:
	for property_name in ["camera_rng", "dialogue_rng"]:
		var rng_value: Variant = match_node.get(property_name)
		if rng_value is RandomNumberGenerator:
			(rng_value as RandomNumberGenerator).seed = match_seed

func _apply_setup(match_node: Node, spec: Dictionary) -> void:
	var setup: Dictionary = spec.get("setup", {})
	var overrides: Dictionary = spec.get("overrides", {})
	if overrides.has("timer_seconds"):
		match_node.set("time_left", float(overrides.get("timer_seconds", 60.0)))
	for side in ["p1", "p2"]:
		var fighter := _fighter(match_node, side)
		if fighter == null:
			continue
		var side_setup: Dictionary = setup.get(side, {})
		if side_setup.has("percent"):
			fighter.set("current_hp", MAX_HP - int(round(float(side_setup.get("percent", 0.0)))))
		if side_setup.has("x") or side_setup.has("y"):
			var position := fighter.global_position
			if side_setup.has("x"):
				position.x = float(side_setup.get("x", position.x))
			if side_setup.has("y"):
				position.y = float(side_setup.get("y", position.y))
			fighter.global_position = position
			fighter.set("velocity", Vector2.ZERO)

func _apply_controls(match_node: Node, spec: Dictionary) -> void:
	_set_control(_fighter(match_node, "p1"), str(spec.get("p1_control", "script")))
	_set_control(_fighter(match_node, "p2"), str(spec.get("p2_control", "script")))

func _set_control(fighter: Node, control: String) -> void:
	if fighter == null:
		return
	fighter.set("is_ai", control == "cpu")
	if control == "cpu" and fighter.has_method("set_training_dummy_options"):
		fighter.call("set_training_dummy_options", false, "stand")

func _apply_session(spec: Dictionary) -> void:
	var mode := str(spec.get("mode", "local"))
	var session_mode := "vs"
	match mode:
		"cpu":
			session_mode = "cpu"
		"story":
			session_mode = "story"
		"training":
			session_mode = "training"
		_:
			session_mode = "vs"
	SessionStateStore.set_value(SessionKeysStore.MATCH_MODE, session_mode)
	if mode == "story":
		SessionStateStore.set_value(SessionKeysStore.STORY_ROUND_INDEX, 0)
	else:
		SessionStateStore.clear_keys(PackedStringArray([SessionKeysStore.STORY_ROUND_INDEX]))
	_apply_character_session("p1", str(spec.get("p1", "")))
	_apply_character_session("p2", str(spec.get("p2", "")))

func _apply_character_session(side: String, character_id: String) -> void:
	var id_key := SessionKeysStore.PLAYER_1_ID if side == "p1" else SessionKeysStore.PLAYER_2_ID
	var path_key := SessionKeysStore.PLAYER_1_TABLE_PATH if side == "p1" else SessionKeysStore.PLAYER_2_TABLE_PATH
	var name_key := SessionKeysStore.PLAYER_1_NAME if side == "p1" else SessionKeysStore.PLAYER_2_NAME
	if character_id == "":
		SessionStateStore.clear_keys(PackedStringArray([id_key, path_key, name_key]))
		return
	var entry := _character_entry(character_id)
	if entry.is_empty():
		return
	SessionStateStore.set_value(id_key, str(entry.get("id", character_id)))
	SessionStateStore.set_value(path_key, str(entry.get("attack_table_path", "")))
	SessionStateStore.set_value(name_key, str(entry.get("name", character_id)))

func _unknown_character(spec: Dictionary) -> String:
	for side in ["p1", "p2"]:
		var character_id := str(spec.get(side, "")).strip_edges()
		if character_id == "":
			continue
		if _character_entry(character_id).is_empty():
			return character_id
	return ""

func _character_entry(character_id: String) -> Dictionary:
	for entry in CharacterCatalogStore.CHARACTER_OPTIONS:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		if str((entry as Dictionary).get("id", "")) == character_id:
			return (entry as Dictionary).duplicate(true)
	return {}

func _apply_frame_inputs(spec: Dictionary, frame_index: int) -> void:
	for sample_value in spec.get("inputs", []):
		if typeof(sample_value) != TYPE_DICTIONARY:
			continue
		var sample := sample_value as Dictionary
		if int(sample.get("frame", -1)) != frame_index:
			continue
		if sample.has("p1"):
			_held["p1"] = (sample.get("p1", {}) as Dictionary).duplicate(true)
		if sample.has("p2"):
			_held["p2"] = (sample.get("p2", {}) as Dictionary).duplicate(true)
	_sync_held_actions("p1", 1)
	_sync_held_actions("p2", 2)

func _sync_held_actions(side: String, player_id: int) -> void:
	var held: Dictionary = _held.get(side, {})
	var prefix := "p1" if player_id == 1 else "p2"
	for button in ReplayScriptStore.BUTTONS:
		if button == "pause" or button == "restart":
			continue
		var action_name := "%s_%s" % [prefix, button]
		var down := bool(held.get(button, false))
		_set_action_down(action_name, down)
	for command_name in ["pause", "restart"]:
		var pressed := false
		for side_name in ["p1", "p2"]:
			var side_held: Dictionary = _held.get(side_name, {})
			if bool(side_held.get(command_name, false)):
				pressed = true
		_match_buttons[command_name] = pressed

func _set_action_down(action_name: String, down: bool) -> void:
	if not InputMap.has_action(action_name):
		return
	var pressed := Input.is_action_pressed(action_name)
	if down and not pressed:
		Input.action_press(action_name)
	elif not down and pressed:
		Input.action_release(action_name)

func _deliver_match_buttons() -> void:
	if _match == null:
		return
	for command_name in ["pause", "restart"]:
		var down := bool(_match_buttons.get(command_name, false))
		var was_down := Input.is_action_pressed(command_name) if InputMap.has_action(command_name) else false
		if down and not was_down:
			if InputMap.has_action(command_name):
				Input.action_press(command_name)
			var event := InputEventAction.new()
			event.action = command_name
			event.pressed = true
			if _match.has_method("_unhandled_input"):
				_match.call("_unhandled_input", event)
		elif not down and was_down and InputMap.has_action(command_name):
			Input.action_release(command_name)

func _record_frame(log_file: FileAccess, frame_index: int) -> void:
	log_file.store_line(JSON.stringify(_snapshot(frame_index)))

func _snapshot(frame_index: int) -> Dictionary:
	var match_over := false
	var winner := ""
	var time_left := 0.0
	var stocks := {"p1": 0, "p2": 0}
	var timer_enabled := false
	var stock_count := 0
	if _match != null:
		match_over = bool(_match.get("match_over"))
		winner = str(_match.get("match_result_key"))
		time_left = float(_match.get("time_left"))
		timer_enabled = bool(_match.get("round_timer_enabled"))
		stock_count = int(_match.get("stock_count"))
		var stocks_value: Variant = _match.get("stocks")
		if typeof(stocks_value) == TYPE_DICTIONARY:
			var stocks_raw := stocks_value as Dictionary
			stocks = {
				"p1": int(stocks_raw.get("p1", 0)),
				"p2": int(stocks_raw.get("p2", 0))
			}
	return {
		"frame": frame_index,
		"phase": "ended" if match_over else "fight",
		"winner": winner,
		"time_left": _n(time_left),
		"timer_enabled": timer_enabled,
		"stock_count": stock_count,
		"paused": get_tree().paused,
		"players": [_player_snapshot("p1", int(stocks.get("p1", 0))), _player_snapshot("p2", int(stocks.get("p2", 0)))]
	}

func _player_snapshot(side: String, stocks: int) -> Dictionary:
	var fighter := _fighter(_match, side) if _match != null else null
	if fighter == null:
		return {"id": side, "present": false, "stocks": stocks}
	var velocity := Vector2.ZERO
	var velocity_value: Variant = fighter.get("velocity")
	if velocity_value is Vector2:
		velocity = velocity_value
	var position := fighter.global_position
	var character_id := ""
	if _match != null:
		var ids_value: Variant = _match.get("selected_character_ids")
		if typeof(ids_value) == TYPE_DICTIONARY:
			character_id = str((ids_value as Dictionary).get(side, ""))
	var attack_state := str(fighter.get("attack_state"))
	var state := _fighter_state(fighter)
	return {
		"id": side,
		"present": true,
		"character": character_id,
		"x": _n(position.x),
		"y": _n(position.y),
		"vx": _n(velocity.x),
		"vy": _n(velocity.y),
		"percent": int(fighter.get("current_hp")) * -1 + MAX_HP,
		"hp": int(fighter.get("current_hp")),
		"stocks": stocks,
		"action": attack_state if attack_state != "" else state,
		"state": state,
		"attack_phase": str(fighter.get("attack_phase")),
		"facing": int(fighter.get("facing")),
		"on_floor": bool(fighter.call("is_on_floor")) if fighter.has_method("is_on_floor") else false,
		"blocking": bool(fighter.get("is_blocking")),
		"is_ai": bool(fighter.get("is_ai")),
		"hitstun": _n(float(fighter.get("hitstun_time"))),
		"hitbox_active": _hitbox_active(fighter),
		"hitbox": _hitbox_rect(fighter)
	}

func _fighter_state(fighter: Node) -> String:
	if int(fighter.get("current_hp")) <= 0:
		return "ko"
	if bool(fighter.get("is_ledge_hanging")):
		return "ledge"
	if bool(fighter.get("is_knocked_down")):
		return "knockdown"
	if float(fighter.get("getup_time")) > 0.0:
		return "getup"
	if float(fighter.get("dodge_time")) > 0.0:
		return "dodge"
	if float(fighter.get("hitstun_time")) > 0.0:
		return "hitstun"
	if float(fighter.get("blockstun_time")) > 0.0:
		return "blockstun"
	if float(fighter.get("shield_break_time")) > 0.0:
		return "shield_break"
	if float(fighter.get("landing_lag_time")) > 0.0:
		return "landing"
	if bool(fighter.get("is_dashing")):
		return "dash"
	if str(fighter.get("attack_state")) != "":
		return "attack"
	if bool(fighter.get("is_blocking")):
		return "block"
	if fighter.has_method("is_on_floor") and not bool(fighter.call("is_on_floor")):
		return "air"
	var velocity_value: Variant = fighter.get("velocity")
	if velocity_value is Vector2 and absf((velocity_value as Vector2).x) > 34.0:
		return "walk"
	return "idle"

func _hitbox_active(fighter: Node) -> bool:
	var hitbox := fighter.get_node_or_null("Hitbox")
	var shape_node := fighter.get_node_or_null("Hitbox/CollisionShape2D")
	if hitbox == null or shape_node == null:
		return false
	return bool(hitbox.get("monitoring")) and not bool(shape_node.get("disabled"))

func _hitbox_rect(fighter: Node) -> Variant:
	if not _hitbox_active(fighter):
		return null
	var shape_node := fighter.get_node_or_null("Hitbox/CollisionShape2D") as CollisionShape2D
	var hitbox := fighter.get_node_or_null("Hitbox") as Node2D
	if shape_node == null or hitbox == null or not (shape_node.shape is RectangleShape2D):
		return null
	var size := (shape_node.shape as RectangleShape2D).size
	var center := hitbox.global_position
	return {
		"x": _n(center.x - size.x * 0.5),
		"y": _n(center.y - size.y * 0.5),
		"w": _n(size.x),
		"h": _n(size.y)
	}

func _headless_display() -> bool:
	return OS.has_feature("headless") or DisplayServer.get_name() == "headless"

func _save_screenshot(screenshot_dir: String, frame_index: int) -> void:
	if _match == null:
		return
	var viewport := _match.get_viewport()
	if viewport == null:
		return
	var texture := viewport.get_texture()
	if texture == null:
		return
	var image := texture.get_image()
	if image == null:
		return
	image.save_png("%s/frame_%04d.png" % [screenshot_dir, frame_index])

func _fighter(match_node: Node, side: String) -> Node2D:
	if match_node == null:
		return null
	return match_node.get_node_or_null("Player1" if side == "p1" else "Player2") as Node2D

func _release_driver_inputs() -> void:
	for prefix in ["p1", "p2"]:
		for button in ReplayScriptStore.BUTTONS:
			if button == "pause" or button == "restart":
				continue
			var action_name := "%s_%s" % [prefix, button]
			if InputMap.has_action(action_name) and Input.is_action_pressed(action_name):
				Input.action_release(action_name)
	for command_name in ["pause", "restart"]:
		if InputMap.has_action(command_name) and Input.is_action_pressed(command_name):
			Input.action_release(command_name)

func _snapshot_session() -> Dictionary:
	var saved := {}
	for key in SESSION_KEYS:
		if SessionStateStore.has_value(key):
			saved[key] = SessionStateStore.get_value(key)
	return saved

func _restore_session(saved: Dictionary) -> void:
	SessionStateStore.clear_keys(PackedStringArray(SESSION_KEYS))
	for key in saved.keys():
		SessionStateStore.set_value(str(key), saved[key])

func _restore_preset(saved_preset: String) -> void:
	if saved_preset == "":
		if Engine.has_meta(GameSettingsStore.ENGINE_META_KEY):
			Engine.remove_meta(GameSettingsStore.ENGINE_META_KEY)
		return
	Engine.set_meta(GameSettingsStore.ENGINE_META_KEY, saved_preset)

func _hash_file(path: String) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(FileAccess.get_file_as_bytes(path))
	return ctx.finish().hex_encode()

func _read_last_state(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	var lines := text.split("\n", false)
	if lines.is_empty():
		return {}
	var parsed: Variant = JSON.parse_string(lines[lines.size() - 1])
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed as Dictionary

func _n(value: float) -> float:
	return snappedf(value, 0.0001)

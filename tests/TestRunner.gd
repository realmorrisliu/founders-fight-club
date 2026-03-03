extends SceneTree

const GameSettingsStore := preload("res://scripts/GameSettings.gd")
const REQUIRED_BASE_ATTACKS := ["light", "heavy", "special", "throw"]

var _failures: Array[String] = []
var _passes := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _test_character_attack_tables_are_valid()
	await _test_core_scenes_boot()
	await _test_control_preset_profiles()
	await _test_hitstop_overlap_recovery()
	await _test_player_damage_and_block_flow()
	await _test_skill_runtime_primitives()
	await _test_motion_feel_primitives()
	await _test_ai_behavior_profiles()
	await _test_wave1_vertical_slice_skills()
	await _test_full_roster_signature_coverage()
	_finish()

func _assert_true(condition: bool, message: String) -> void:
	if condition:
		_passes += 1
		print("[PASS] %s" % message)
	else:
		_failures.append(message)
		push_error("[FAIL] %s" % message)

func _finish() -> void:
	print("\n=== Test Summary ===")
	print("Passed: %d" % _passes)
	print("Failed: %d" % _failures.size())
	if _failures.is_empty():
		print("Result: PASS")
		quit(0)
		return
	for item in _failures:
		print(" - %s" % item)
	quit(1)

func _test_character_attack_tables_are_valid() -> void:
	var dir := DirAccess.open("res://assets/data/characters")
	_assert_true(dir != null, "can open character attack table directory")
	if dir == null:
		return

	var table_count := 0
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name == "":
			break
		if dir.current_is_dir():
			continue
		if not file_name.ends_with("AttackTable.tres"):
			continue
		table_count += 1
		var path := "res://assets/data/characters/%s" % file_name
		var resource := load(path)
		_assert_true(resource != null, "load attack table %s" % file_name)
		if resource == null:
			continue
		var attacks := _resolve_attacks_dictionary(resource)
		_assert_true(not attacks.is_empty(), "%s has attack entries" % file_name)
		for key in REQUIRED_BASE_ATTACKS:
			_assert_true(attacks.has(key), "%s includes %s" % [file_name, key])
			if not attacks.has(key):
				continue
			var entry: Variant = attacks[key]
			_assert_true(typeof(entry) == TYPE_DICTIONARY, "%s.%s entry is dictionary" % [file_name, key])
			if typeof(entry) != TYPE_DICTIONARY:
				continue
			var entry_dict := entry as Dictionary
			_assert_true(entry_dict.has("startup"), "%s.%s has startup" % [file_name, key])
			_assert_true(entry_dict.has("active"), "%s.%s has active" % [file_name, key])
			_assert_true(entry_dict.has("recovery"), "%s.%s has recovery" % [file_name, key])
	dir.list_dir_end()
	_assert_true(table_count >= 16, "character roster has at least 16 attack tables")

func _resolve_attacks_dictionary(resource: Resource) -> Dictionary:
	if resource == null:
		return {}
	if resource.has_method("get_runtime_attacks"):
		var runtime_value: Variant = resource.call("get_runtime_attacks")
		if typeof(runtime_value) == TYPE_DICTIONARY:
			return (runtime_value as Dictionary).duplicate(true)
	var raw: Variant = resource.get("attacks")
	if typeof(raw) == TYPE_DICTIONARY:
		return (raw as Dictionary).duplicate(true)
	return {}

func _test_core_scenes_boot() -> void:
	await _assert_scene_boot("res://scenes/Menu.tscn")
	await _assert_scene_boot("res://scenes/Main.tscn")
	await _assert_scene_boot("res://scenes/Training.tscn")

func _assert_scene_boot(path: String) -> void:
	var packed := load(path)
	_assert_true(packed is PackedScene, "%s is loadable PackedScene" % path)
	if packed is not PackedScene:
		return
	var instance := (packed as PackedScene).instantiate()
	get_root().add_child(instance)
	await process_frame
	await process_frame
	_assert_true(is_instance_valid(instance), "%s booted for 2 frames" % path)
	if is_instance_valid(instance):
		instance.queue_free()
	await process_frame

func _test_control_preset_profiles() -> void:
	GameSettingsStore.apply_control_preset(GameSettingsStore.CONTROL_PRESET_MODERN)
	_assert_true(_action_has_keyboard_key("jump", KEY_SPACE), "modern preset keeps jump on Space")
	_assert_true(_action_has_keyboard_key("block", KEY_H), "modern preset keeps dedicated block key")

	GameSettingsStore.apply_control_preset(GameSettingsStore.CONTROL_PRESET_CLASSIC)
	_assert_true(_action_has_keyboard_key("jump", KEY_W), "classic preset maps jump to W")
	_assert_true(_action_has_keyboard_key("jump", KEY_UP), "classic preset maps jump to Up")
	_assert_true(not _action_has_any_keyboard_key("block"), "classic preset removes keyboard block key")

	GameSettingsStore.set_control_preset(GameSettingsStore.CONTROL_PRESET_CLASSIC)
	_assert_true(GameSettingsStore.get_control_preset() == GameSettingsStore.CONTROL_PRESET_CLASSIC, "control preset persists to user settings")
	GameSettingsStore.set_control_preset(GameSettingsStore.CONTROL_PRESET_MODERN)
	_assert_true(GameSettingsStore.get_control_preset() == GameSettingsStore.CONTROL_PRESET_MODERN, "control preset can switch back to modern")

func _action_has_keyboard_key(action_name: String, keycode: int) -> bool:
	if not InputMap.has_action(action_name):
		return false
	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey:
			var key_event := event as InputEventKey
			if int(key_event.keycode) == keycode:
				return true
	return false

func _action_has_any_keyboard_key(action_name: String) -> bool:
	if not InputMap.has_action(action_name):
		return false
	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey:
			return true
	return false

func _test_hitstop_overlap_recovery() -> void:
	Engine.time_scale = 1.0
	var packed := load("res://scenes/Main.tscn")
	_assert_true(packed is PackedScene, "main scene loads for hitstop overlap test")
	if packed is not PackedScene:
		return
	var match_node := (packed as PackedScene).instantiate()
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	match_node.call("_apply_hitstop", 0.03)
	match_node.call("_apply_hitstop", 0.09)
	_assert_true(Engine.time_scale < 0.5, "overlapping hitstop requests enter slow scale")
	await create_timer(0.14, true, false, true).timeout
	await process_frame
	_assert_true(is_equal_approx(Engine.time_scale, 1.0), "overlapping hitstop requests recover to normal speed")
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame
	Engine.time_scale = 1.0

func _test_player_damage_and_block_flow() -> void:
	var player_scene := load("res://scenes/Player.tscn")
	_assert_true(player_scene is PackedScene, "player scene is loadable")
	if player_scene is not PackedScene:
		return

	var host := Node2D.new()
	host.name = "TestHost"
	get_root().add_child(host)

	var p1 := (player_scene as PackedScene).instantiate() as CharacterBody2D
	var p2 := (player_scene as PackedScene).instantiate() as CharacterBody2D
	_assert_true(p1 != null and p2 != null, "can instantiate two players")
	if p1 == null or p2 == null:
		host.queue_free()
		await process_frame
		return

	p1.name = "Player1"
	p2.name = "Player2"
	p1.position = Vector2(100, 300)
	p2.position = Vector2(160, 300)
	p1.set("player_id", 1)
	p2.set("player_id", 2)
	p1.set("is_ai", false)
	p2.set("is_ai", false)
	p1.set("opponent_path", NodePath("../Player2"))
	p2.set("opponent_path", NodePath("../Player1"))

	host.add_child(p1)
	host.add_child(p2)
	await process_frame
	await process_frame

	var hp_before := int(p2.get("current_hp"))
	var hit_result: Dictionary = p2.call("apply_damage", 10, Vector2(120, -30), 0.12, "light", {})
	_assert_true(not bool(hit_result.get("blocked", false)), "light hit is not blocked by default")
	_assert_true(int(p2.get("current_hp")) == hp_before - 10, "light hit reduces hp by expected damage")

	p2.set("current_hp", 100)
	p2.set("hitstun_time", 0.0)
	p2.set("blockstun_time", 0.0)
	p2.set("is_knocked_down", false)
	p2.set("getup_time", 0.0)
	p2.set("wake_invuln_time", 0.0)
	p2.set("is_blocking", true)
	var block_meta := {
		"block_type": "mid",
		"air_blockable": true,
		"blockstun": 0.1
	}
	var block_result: Dictionary = p2.call("apply_damage", 10, Vector2(120, -20), 0.12, "light", block_meta)
	_assert_true(bool(block_result.get("blocked", false)), "blocking defender can block mid attack")
	_assert_true(int(p2.get("current_hp")) == 100, "light attack block deals zero chip")

	host.queue_free()
	await process_frame

func _test_skill_runtime_primitives() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var p2 := setup.get("p2") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or p2 == null or host == null:
		return

	var custom_table := AttackTable.new()
	custom_table.character_id = "runtime_test"
	custom_table.display_name = "Runtime Test"
	custom_table.attacks = {
		"light": _make_attack_template(6, "mid"),
		"heavy": _make_attack_template(12, "overhead"),
		"special": _make_attack_template(14, "low"),
		"throw": _make_attack_template(10, "throw", true),
		"signature_a": _make_skill_attack_with_effect("signature_a", "projectile", {
			"speed": 420.0,
			"duration": 0.9,
			"size": Vector2(24, 16),
			"knockback": Vector2(170, -55),
			"damage": 9
		}),
		"signature_b": _make_skill_attack_with_effect("signature_b", "mobility", {
			"mode": "dash",
			"speed": 300.0
		}),
		"signature_c": _make_skill_attack_with_effect("signature_c", "trap", {
			"duration": 1.0,
			"spawn_offset_x": 28.0,
			"size": Vector2(28, 18),
			"knockback": Vector2(130, -40),
			"damage": 7,
			"slow_seconds": 0.8,
			"slow_factor": 0.55
		}),
		"ultimate": _make_skill_attack_with_effect("ultimate", "buff", {
			"buff": {
				"duration": 2.5,
				"damage_multiplier": 1.35,
				"speed_multiplier": 1.2,
				"startup_multiplier": 0.85,
				"chip_bonus": 0.08
			}
		})
	}
	p1.call("apply_attack_table", custom_table)
	await process_frame

	p1.call("_start_attack", "signature_a")
	_assert_true(float(p1.call("get_skill_cooldown_remaining", "signature_a")) > 0.0, "signature cooldown starts after activation")
	_assert_true(not bool(p1.call("_can_trigger_attack_kind", "signature_a")), "cooldown prevents immediate re-use")

	p1.set("hype_meter", 100.0)
	p1.call("_start_attack", "ultimate")
	_assert_true(float(p1.call("get_hype_meter")) <= 0.001, "ultimate consumes full hype meter")

	p1.set("hype_meter", 0.0)
	_assert_true(not bool(p1.call("_can_trigger_attack_kind", "ultimate")), "ultimate blocked when hype is not full")
	p1.set("hype_meter", 100.0)
	p1.set("attack_state", "")
	p1.set("skill_cooldowns", {})
	p1.set("special_input_buffer_time", 0.08)
	p1.set("heavy_input_buffer_time", 0.08)
	_assert_true(bool(p1.call("_can_trigger_buffered_ultimate")), "ultimate chord input buffer supports leniency window")
	p1.call("_consume_ultimate_chord_buffer")
	var runtime_state_value: Variant = p1.call("get_runtime_status_snapshot")
	_assert_true(typeof(runtime_state_value) == TYPE_DICTIONARY, "runtime status snapshot is dictionary")
	if typeof(runtime_state_value) == TYPE_DICTIONARY:
		var runtime_state := runtime_state_value as Dictionary
		_assert_true(runtime_state.has("hype"), "runtime status snapshot includes hype")
		_assert_true(runtime_state.has("cooldowns"), "runtime status snapshot includes cooldown dictionary")

	var debuff_meta := {
		"silence_seconds": 1.2,
		"slow_seconds": 1.0,
		"slow_factor": 0.5,
		"root_seconds": 0.4
	}
	p2.call("apply_damage", 5, Vector2(120, -20), 0.1, "signature_a", debuff_meta)
	_assert_true(float(p2.get("status_silence_time")) > 0.0, "silence status applied from control meta")
	_assert_true(float(p2.get("status_slow_time")) > 0.0, "slow status applied from control meta")
	_assert_true(float(p2.get("status_root_time")) > 0.0, "root status applied from control meta")
	p1.set("attack_state", "")
	p1.call("_start_attack", "light")
	var locked_facing := int(p1.get("facing"))
	p2.position.x = p1.position.x - 36.0 if locked_facing > 0 else p1.position.x + 36.0
	p1.call("_update_facing")
	_assert_true(bool(p1.get("facing_locked")), "starting an attack locks facing direction")
	_assert_true(int(p1.get("facing")) == locked_facing, "facing remains stable while attack lock is active")

	p1.set("current_hp", 100)
	p2.set("current_hp", 100)
	p1.set("attack_state", "")
	p1.set("skill_cooldowns", {})
	p1.call("_start_attack", "signature_a")
	p1.call("_update_attack", 0.09)
	var entities := p1.get("skill_entities") as Array
	_assert_true(entities.size() > 0, "projectile effect spawns runtime entity")
	if entities.size() > 0:
		var first_entity := (entities[0] as Dictionary).duplicate(true)
		first_entity["position"] = p2.global_position + Vector2(0.0, -22.0)
		var overlaps := bool(p1.call("_skill_entity_hit_test", first_entity, p2))
		_assert_true(overlaps, "runtime projectile collision probe detects overlap")
		var payload := first_entity.get("payload", {}) as Dictionary
		p1.call("_apply_skill_entity_hit", p2, payload)
	_assert_true(int(p2.get("current_hp")) < 100, "runtime projectile entity can hit opponent")

	host.queue_free()
	await process_frame

func _test_motion_feel_primitives() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or host == null:
		return

	p1.set("velocity", Vector2.ZERO)
	p1.call("_apply_horizontal_intent", 220.0, 0.016, 1.0, 1.0)
	var velocity_after_accel := p1.get("velocity") as Vector2
	_assert_true(velocity_after_accel.x > 0.0 and velocity_after_accel.x < 220.0, "horizontal acceleration ramps toward target speed")

	p1.set("velocity", Vector2(220.0, 0.0))
	p1.call("_apply_horizontal_intent", 0.0, 0.016, 1.0, 1.0)
	var velocity_after_decel := p1.get("velocity") as Vector2
	_assert_true(velocity_after_decel.x > 0.0 and velocity_after_decel.x < 220.0, "horizontal deceleration ramps down instead of snapping")

	p1.set("attack_state", "heavy")
	p1.set("attack_phase", "startup")
	var startup_speed := float(p1.call("_resolve_attack_animation_speed_scale", StringName("heavy")))
	p1.set("attack_phase", "active")
	var active_speed := float(p1.call("_resolve_attack_animation_speed_scale", StringName("heavy")))
	p1.set("attack_phase", "recovery")
	var recovery_speed := float(p1.call("_resolve_attack_animation_speed_scale", StringName("heavy")))
	_assert_true(startup_speed < active_speed and recovery_speed < active_speed, "attack animation speed follows startup/active/recovery pacing")

	p1.set("attack_state", "")
	p1.set("attack_phase", "")
	var neutral_speed := float(p1.call("_resolve_attack_animation_speed_scale", StringName("idle")))
	_assert_true(is_equal_approx(neutral_speed, 1.0), "neutral animation speed scale remains default")

	host.queue_free()
	await process_frame

func _test_ai_behavior_profiles() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or host == null:
		return

	p1.set("is_ai", true)
	p1.set("hype_meter", 100.0)
	p1.set("skill_cooldowns", {})

	var travis_table := load("res://assets/data/characters/TravisKalanikAttackTable.tres")
	_assert_true(travis_table != null, "travis attack table loads for ai profile test")
	if travis_table == null:
		host.queue_free()
		await process_frame
		return
	p1.call("apply_attack_table", travis_table)
	await process_frame
	var travis_profile := p1.get("ai_style_profile") as Dictionary
	_assert_true(travis_profile.has("preferred_range"), "ai style profile contains preferred range")
	_assert_true(travis_profile.has("signature_bias"), "ai style profile contains signature bias")

	var close_weights_value: Variant = p1.call("_build_ai_attack_weight_map", 24.0)
	_assert_true(typeof(close_weights_value) == TYPE_DICTIONARY, "ai weight map builder returns dictionary")
	if typeof(close_weights_value) == TYPE_DICTIONARY:
		var close_weights := close_weights_value as Dictionary
		_assert_true(close_weights.has("light"), "close-range ai candidates include light")
		_assert_true(close_weights.has("heavy"), "close-range ai candidates include heavy")
		_assert_true(close_weights.has("signature_a"), "close-range ai candidates include signature skill")
		_assert_true(float(close_weights.get("heavy", 0.0)) > float(close_weights.get("signature_a", 0.0)), "rushdown profile favors heavy over signature at point-blank")

	var larry_table := load("res://assets/data/characters/LarryPagyrAttackTable.tres")
	_assert_true(larry_table != null, "larry attack table loads for ai profile test")
	if larry_table != null:
		p1.call("apply_attack_table", larry_table)
		await process_frame
		var far_weights_value: Variant = p1.call("_build_ai_attack_weight_map", 96.0)
		_assert_true(typeof(far_weights_value) == TYPE_DICTIONARY, "far-range ai weight map builder returns dictionary")
		if typeof(far_weights_value) == TYPE_DICTIONARY:
			var far_weights := far_weights_value as Dictionary
			_assert_true(far_weights.has("signature_a"), "far-range ai candidates include projectile signature")
			_assert_true(far_weights.has("heavy"), "far-range ai candidates keep heavy candidate")
			_assert_true(float(far_weights.get("signature_a", 0.0)) > float(far_weights.get("heavy", 0.0)), "zoning profile favors signature over heavy at long range")

	var selected_kind := str(p1.call("_select_ai_attack_kind", 54.0))
	_assert_true(selected_kind != "", "ai weighted selector can resolve an actionable attack kind")

	host.queue_free()
	await process_frame

func _spawn_test_players() -> Dictionary:
	var player_scene := load("res://scenes/Player.tscn")
	_assert_true(player_scene is PackedScene, "player scene is loadable for runtime tests")
	if player_scene is not PackedScene:
		return {}
	var host := Node2D.new()
	host.name = "SkillRuntimeHost"
	get_root().add_child(host)
	var p1 := (player_scene as PackedScene).instantiate() as CharacterBody2D
	var p2 := (player_scene as PackedScene).instantiate() as CharacterBody2D
	_assert_true(p1 != null and p2 != null, "runtime tests instantiate two players")
	if p1 == null or p2 == null:
		host.queue_free()
		await process_frame
		return {}
	p1.name = "Player1"
	p2.name = "Player2"
	p1.position = Vector2(120, 300)
	p2.position = Vector2(170, 300)
	p1.set("player_id", 1)
	p2.set("player_id", 2)
	p1.set("is_ai", false)
	p2.set("is_ai", false)
	p1.set("opponent_path", NodePath("../Player2"))
	p2.set("opponent_path", NodePath("../Player1"))
	host.add_child(p1)
	host.add_child(p2)
	await process_frame
	await process_frame
	return {"host": host, "p1": p1, "p2": p2}

func _make_attack_template(damage: int, block_type: String, throw_techable: bool = false) -> Dictionary:
	return {
		"startup": 0.07,
		"active": 0.10,
		"recovery": 0.18,
		"block_recovery": 0.21,
		"damage": damage,
		"hitstun": 0.14,
		"blockstun": 0.11,
		"cancel_on_hit": true,
		"cancel_on_block": true,
		"cancel_options": ["light", "heavy", "signature_a"],
		"block_type": block_type,
		"air_blockable": block_type != "throw",
		"throw_techable": throw_techable,
		"knockback_ground": Vector2(165, -62),
		"knockback_air": Vector2(130, -94),
		"hitbox_size_ground": Vector2(28, 18),
		"hitbox_size_air": Vector2(24, 16),
		"hitbox_offset_ground": Vector2(24, -2),
		"hitbox_offset_air": Vector2(20, -8)
	}

func _make_skill_attack_with_effect(kind: String, effect_type: String, effect_payload: Dictionary) -> Dictionary:
	var attack := _make_attack_template(10, "mid")
	attack["cancel_on_hit"] = false
	attack["cancel_on_block"] = false
	attack["cancel_options"] = []
	attack["cooldown"] = 1.0 if kind != "ultimate" else 6.0
	attack["effect"] = {"type": effect_type}
	var effect_dict := attack["effect"] as Dictionary
	for key in effect_payload.keys():
		effect_dict[key] = effect_payload[key]
	attack["effect"] = effect_dict
	return attack

func _test_wave1_vertical_slice_skills() -> void:
	var wave1_paths := [
		"res://assets/data/characters/ElonMvskAttackTable.tres",
		"res://assets/data/characters/MarkZuckAttackTable.tres",
		"res://assets/data/characters/SamAltmynAttackTable.tres",
		"res://assets/data/characters/PeterThyellAttackTable.tres"
	]
	for path in wave1_paths:
		var resource := load(path)
		_assert_true(resource != null, "wave1 table loads: %s" % path)
		if resource == null:
			continue
		var attacks := _resolve_attacks_dictionary(resource)
		for key in ["signature_a", "signature_b", "signature_c", "ultimate"]:
			_assert_true(attacks.has(key), "%s includes %s" % [path, key])
			if not attacks.has(key):
				continue
			var entry_value: Variant = attacks[key]
			_assert_true(typeof(entry_value) == TYPE_DICTIONARY, "%s.%s is dictionary" % [path, key])
			if typeof(entry_value) != TYPE_DICTIONARY:
				continue
			var entry := entry_value as Dictionary
			_assert_true(float(entry.get("cooldown", 0.0)) > 0.0, "%s.%s has cooldown" % [path, key])
			var has_behavior: bool = entry.has("effect") or entry.has("control") or key == "ultimate"
			_assert_true(has_behavior, "%s.%s has special behavior payload" % [path, key])

	var setup := await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or host == null:
		return
	for path in wave1_paths:
		var resource := load(path)
		if resource == null:
			continue
		p1.call("apply_attack_table", resource)
		await process_frame
		for key in ["signature_a", "signature_b", "signature_c"]:
			p1.set("attack_state", "")
			p1.set("skill_cooldowns", {})
			p1.call("_start_attack", key)
			_assert_true(str(p1.get("attack_state")) == key, "%s can start %s" % [path, key])
		p1.set("attack_state", "")
		p1.set("skill_cooldowns", {})
		p1.set("hype_meter", 100.0)
		p1.call("_start_attack", "ultimate")
		_assert_true(str(p1.get("attack_state")) == "ultimate", "%s can start ultimate with full hype" % path)
	host.queue_free()
	await process_frame

func _test_full_roster_signature_coverage() -> void:
	var roster_paths := [
		"res://assets/data/characters/ElonMvskAttackTable.tres",
		"res://assets/data/characters/MarkZuckAttackTable.tres",
		"res://assets/data/characters/SamAltmynAttackTable.tres",
		"res://assets/data/characters/PeterThyellAttackTable.tres",
		"res://assets/data/characters/ZefBezosAttackTable.tres",
		"res://assets/data/characters/BillGeytzAttackTable.tres",
		"res://assets/data/characters/SundarPichoyAttackTable.tres",
		"res://assets/data/characters/JensenHwangAttackTable.tres",
		"res://assets/data/characters/LarryPagyrAttackTable.tres",
		"res://assets/data/characters/SergeyBrinnAttackTable.tres",
		"res://assets/data/characters/SatyaNadelloAttackTable.tres",
		"res://assets/data/characters/TimCukeAttackTable.tres",
		"res://assets/data/characters/JackDorseeAttackTable.tres",
		"res://assets/data/characters/TravisKalanikAttackTable.tres",
		"res://assets/data/characters/ReedHestingsAttackTable.tres",
		"res://assets/data/characters/SteveJobzAttackTable.tres"
	]
	var setup := await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or host == null:
		return
	for path in roster_paths:
		var table := load(path) as Resource
		_assert_true(table != null, "roster table loads: %s" % path)
		if table == null:
			continue
		p1.call("apply_attack_table", table)
		await process_frame
		for key in ["signature_a", "signature_b", "signature_c", "ultimate"]:
			_assert_true(bool(p1.call("_has_attack_kind", key)), "%s has runtime %s" % [path, key])
		p1.set("attack_state", "")
		p1.set("skill_cooldowns", {})
		p1.call("_start_attack", "signature_a")
		_assert_true(str(p1.get("attack_state")) == "signature_a", "%s runtime can start signature_a" % path)
		p1.set("attack_state", "")
		p1.set("skill_cooldowns", {})
		p1.set("hype_meter", 100.0)
		p1.call("_start_attack", "ultimate")
		_assert_true(str(p1.get("attack_state")) == "ultimate", "%s runtime can start ultimate" % path)
	host.queue_free()
	await process_frame

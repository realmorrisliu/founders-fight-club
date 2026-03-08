extends Node

const STORY_SCENE_PATH := "res://scenes/Story.tscn"
const OUTPUT_DIR := "/tmp/ffc-gui-story-autoplay"

var story_match: Node = null
var events: Array[String] = []
var bot_attack_index := 0
var bot_action_cooldown := 0.0
var bot_block_time := 0.0
var last_p1_hp := 100
var last_p2_hp := 100
var match_start_usec := 0

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	TranslationServer.set_locale("en")
	_prepare_output_dir()
	var packed := load(STORY_SCENE_PATH)
	if packed is not PackedScene:
		push_error("GUI autoplay failed to load Story scene")
		get_tree().quit(1)
		return

	story_match = (packed as PackedScene).instantiate()
	add_child(story_match)
	await _wait_frames(6)
	await _capture("00_story_intro")

	var p1 := story_match.get_node_or_null("Player1")
	var p2 := story_match.get_node_or_null("Player2")
	if p1 == null or p2 == null:
		push_error("GUI autoplay failed to resolve fighters")
		get_tree().quit(1)
		return

	last_p1_hp = int(p1.get("current_hp"))
	last_p2_hp = int(p2.get("current_hp"))
	match_start_usec = Time.get_ticks_usec()
	_connect_fighter_events("p1", p1)
	_connect_fighter_events("p2", p2)
	await _capture("01_match_ready")

	for second in range(0, 13):
		await _play_for_duration(1.0, p1, p2)
		var state_line := "STATE t=%.2f p1_hp=%d p2_hp=%d p1_pos=(%.1f,%.1f) p2_pos=(%.1f,%.1f) p1_attack=%s p2_attack=%s result=%s" % [
			_elapsed_seconds(),
			int(p1.get("current_hp")),
			int(p2.get("current_hp")),
			(p1 as Node2D).global_position.x,
			(p1 as Node2D).global_position.y,
			(p2 as Node2D).global_position.x,
			(p2 as Node2D).global_position.y,
			str(p1.get("attack_state")),
			str(p2.get("attack_state")),
			str(story_match.get("match_result_key"))
		]
		print(state_line)
		events.append(state_line)
		if second in [1, 5, 9, 12]:
			await _capture("match_t%02d" % second)
		if bool(story_match.get("match_over")):
			break

	_release_all_inputs()
	await _wait_frames(4)
	await _capture("99_match_final")
	_write_log()
	print("GUI_AUTOPLAY_OUTPUT %s" % OUTPUT_DIR)
	get_tree().quit()

func _prepare_output_dir() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)

func _wait_frames(count: int) -> void:
	for _index in range(maxi(1, count)):
		await get_tree().process_frame

func _capture(name: String) -> void:
	await _wait_frames(2)
	var image := get_viewport().get_texture().get_image()
	if image == null:
		push_warning("GUI autoplay capture skipped: %s" % name)
		return
	var path := "%s/%s.png" % [OUTPUT_DIR, name]
	var error := image.save_png(path)
	if error != OK:
		push_warning("GUI autoplay capture failed: %s (%s)" % [path, error_string(error)])
		return
	print("CAPTURE %s" % path)

func _write_log() -> void:
	var file := FileAccess.open("%s/autoplay.log" % OUTPUT_DIR, FileAccess.WRITE)
	if file == null:
		push_warning("GUI autoplay could not open log file")
		return
	for line in events:
		file.store_line(line)

func _play_for_duration(duration: float, p1: Node, p2: Node) -> void:
	var time_left := duration
	while time_left > 0.0:
		var delta := 1.0 / 60.0
		await _bot_step(p1, p2, delta)
		await get_tree().physics_frame
		time_left -= delta

func _bot_step(p1: Node, p2: Node, delta: float) -> void:
	bot_action_cooldown = maxf(0.0, bot_action_cooldown - delta)
	bot_block_time = maxf(0.0, bot_block_time - delta)
	var dx := (p2 as Node2D).global_position.x - (p1 as Node2D).global_position.x
	var distance := absf(dx)
	var p1_hp := int(p1.get("current_hp"))
	var p2_hp := int(p2.get("current_hp"))

	if p1_hp < last_p1_hp:
		bot_block_time = 0.35
	_log_hp_drop("p1", last_p1_hp, p1_hp)
	_log_hp_drop("p2", last_p2_hp, p2_hp)
	last_p1_hp = p1_hp
	last_p2_hp = p2_hp

	if bot_block_time > 0.0 and distance < 90.0:
		_hold_direction_away_from(dx)
		Input.action_press("p1_block")
		return
	Input.action_release("p1_block")

	if str(p1.get("attack_state")) != "" or float(p1.get("landing_lag_time")) > 0.0 or float(p1.get("blockstun_time")) > 0.0:
		_release_movement()
		return

	if distance > 84.0:
		_hold_direction_toward(dx)
		if distance > 150.0 and bot_action_cooldown <= 0.0:
			await _tap_action("p1_dash", 2)
			bot_action_cooldown = 0.26
		return

	_release_movement()
	if bot_action_cooldown > 0.0:
		return

	match bot_attack_index % 5:
		0:
			await _tap_action("p1_attack_light", 2)
			bot_action_cooldown = 0.16
		1:
			await _tap_action("p1_attack_light", 2)
			bot_action_cooldown = 0.16
		2:
			await _tap_action("p1_attack_heavy", 2)
			bot_action_cooldown = 0.24
		3:
			await _tap_action("p1_attack_special", 2)
			bot_action_cooldown = 0.32
		_:
			await _tap_action("p1_jump", 2)
			await _tap_action("p1_attack_heavy", 2)
			bot_action_cooldown = 0.38
	bot_attack_index += 1

func _hold_direction_toward(dx: float) -> void:
	if dx >= 0.0:
		Input.action_press("p1_move_right")
		Input.action_release("p1_move_left")
	else:
		Input.action_press("p1_move_left")
		Input.action_release("p1_move_right")

func _hold_direction_away_from(dx: float) -> void:
	if dx >= 0.0:
		Input.action_press("p1_move_left")
		Input.action_release("p1_move_right")
	else:
		Input.action_press("p1_move_right")
		Input.action_release("p1_move_left")

func _release_movement() -> void:
	Input.action_release("p1_move_left")
	Input.action_release("p1_move_right")
	Input.action_release("p1_move_up")
	Input.action_release("p1_move_down")

func _release_all_inputs() -> void:
	_release_movement()
	for action in ["p1_jump", "p1_attack_light", "p1_attack_heavy", "p1_attack_special", "p1_throw", "p1_dash", "p1_block"]:
		Input.action_release(action)

func _tap_action(action_name: String, frames: int = 2) -> void:
	Input.action_press(action_name)
	for _index in range(maxi(1, frames)):
		await get_tree().physics_frame
	Input.action_release(action_name)

func _connect_fighter_events(label: String, fighter: Node) -> void:
	if fighter.has_signal("hit_landed"):
		fighter.hit_landed.connect(func(attacker: Node, target: Node, attack_kind: String, is_counter: bool, combo_count: int):
			var attacker_label := label if attacker == fighter else "other"
			var target_hp := int(target.get("current_hp")) if target != null else -1
			var line := "EVENT t=%.2f hit attacker=%s kind=%s counter=%s combo=%d target_hp=%d" % [
				_elapsed_seconds(),
				attacker_label,
				attack_kind,
				str(is_counter),
				combo_count,
				target_hp
			]
			print(line)
			events.append(line)
		)
	if fighter.has_signal("blocked_landed"):
		fighter.blocked_landed.connect(func(attacker: Node, _target: Node, attack_kind: String):
			var attacker_label := label if attacker == fighter else "other"
			var line := "EVENT t=%.2f block attacker=%s kind=%s" % [_elapsed_seconds(), attacker_label, attack_kind]
			print(line)
			events.append(line)
		)
	if fighter.has_signal("defeated"):
		fighter.defeated.connect(func():
			var line := "EVENT t=%.2f defeated fighter=%s" % [_elapsed_seconds(), label]
			print(line)
			events.append(line)
		)

func _log_hp_drop(label: String, from_hp: int, to_hp: int) -> void:
	if to_hp >= from_hp:
		return
	var line := "EVENT t=%.2f hp_drop fighter=%s from=%d to=%d" % [_elapsed_seconds(), label, from_hp, to_hp]
	print(line)
	events.append(line)

func _elapsed_seconds() -> float:
	if match_start_usec <= 0:
		return 0.0
	return float(Time.get_ticks_usec() - match_start_usec) / 1000000.0

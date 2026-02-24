extends Node2D

const ROUND_TIME_SECONDS := 60.0
const RESULT_TO_TEXT_KEY := {
	"p1_win": "RESULT_P1_WIN",
	"p2_win": "RESULT_P2_WIN",
	"draw": "RESULT_DRAW"
}
const HITSTOP_BY_ATTACK := {
	"light": 0.06,
	"heavy": 0.09,
	"special": 0.10,
	"throw": 0.08
}
const BLOCKSTOP_BY_ATTACK := {
	"light": 0.03,
	"heavy": 0.05,
	"special": 0.06,
	"throw": 0.0
}
const CAMERA_SHAKE_BY_ATTACK := {
	"light": {"duration": 0.08, "strength": 2.2},
	"heavy": {"duration": 0.12, "strength": 4.8},
	"special": {"duration": 0.14, "strength": 5.8},
	"throw": {"duration": 0.10, "strength": 3.6}
}
const CAMERA_SHAKE_BY_BLOCK := {
	"light": {"duration": 0.05, "strength": 1.4},
	"heavy": {"duration": 0.08, "strength": 2.2},
	"special": {"duration": 0.09, "strength": 2.8},
	"throw": {"duration": 0.04, "strength": 1.0}
}
const COUNTER_HITSTOP_BONUS := 0.03
const COUNTER_SHAKE_MULTIPLIER := 1.28
const TRAINING_DEFAULT_OPTIONS := {
	"enabled": true,
	"dummy_mode": "stand",
	"show_detail": false
}
const IMPACT_SPRITE_FRAMES_PATH := "res://assets/sprites/effects/ImpactSpriteFrames.tres"
const SFX_PATHS := {
	"hit_light": "res://assets/audio/sfx/hit_light.wav",
	"hit_heavy": "res://assets/audio/sfx/hit_heavy.wav",
	"hit_special": "res://assets/audio/sfx/hit_special.wav",
	"block_light": "res://assets/audio/sfx/block_light.wav",
	"block_heavy": "res://assets/audio/sfx/block_heavy.wav",
	"block_special": "res://assets/audio/sfx/block_special.wav",
	"counter": "res://assets/audio/sfx/counter.wav",
	"combo": "res://assets/audio/sfx/combo.wav",
	"tech": "res://assets/audio/sfx/tech.wav"
}
const SFX_VOLUME_DB := {
	"hit_light": -7.0,
	"hit_heavy": -4.0,
	"hit_special": -3.0,
	"block_light": -10.0,
	"block_heavy": -8.0,
	"block_special": -7.0,
	"counter": -5.0,
	"combo": -8.5,
	"tech": -10.0
}

var time_left := ROUND_TIME_SECONDS
var match_over := false
var match_result_key := ""
var camera_shake_time := 0.0
var camera_shake_duration := 0.0
var camera_shake_strength := 0.0
var camera_rng := RandomNumberGenerator.new()

@export var round_timer_enabled := true
@export var training_scene_enabled := false
@export var training_panel_enabled := false
@export var training_controls_enabled := false
@export_enum("stand", "force_block", "random_block") var training_dummy_default_mode := "stand"
@export var training_detail_default_visible := false

@onready var player_1 := $Player1
@onready var player_2 := $Player2
@onready var hud := $Hud

var camera: Camera2D
var effects_layer: Node2D
var impact_sprite_frames: SpriteFrames
var sfx_streams := {}
var training_options := TRAINING_DEFAULT_OPTIONS.duplicate(true)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	camera_rng.randomize()
	training_options["enabled"] = training_scene_enabled
	training_options["dummy_mode"] = training_dummy_default_mode
	training_options["show_detail"] = training_detail_default_visible
	_setup_camera()
	_setup_walls()
	_setup_effects_layer()
	_load_impact_sprite_frames()
	_load_sfx_streams()

	player_1.health_changed.connect(_on_player_health_changed)
	player_2.health_changed.connect(_on_player_health_changed)
	player_1.defeated.connect(func(): _end_match("p2_win"))
	player_2.defeated.connect(func(): _end_match("p1_win"))
	
	if player_1.has_signal("hit_landed"):
		player_1.hit_landed.connect(_on_hit_landed)
	if player_2.has_signal("hit_landed"):
		player_2.hit_landed.connect(_on_hit_landed)
	if player_1.has_signal("blocked_landed"):
		player_1.blocked_landed.connect(_on_block_landed)
	if player_2.has_signal("blocked_landed"):
		player_2.blocked_landed.connect(_on_block_landed)
	if player_1.has_signal("tech_recovered"):
		player_1.tech_recovered.connect(_on_tech_recovered)
	if player_2.has_signal("tech_recovered"):
		player_2.tech_recovered.connect(_on_tech_recovered)
	if player_1.has_signal("throw_teched"):
		player_1.throw_teched.connect(_on_throw_teched)
	if player_2.has_signal("throw_teched"):
		player_2.throw_teched.connect(_on_throw_teched)

	if hud:
		if hud.has_signal("resume_requested"):
			hud.resume_requested.connect(_on_hud_resume_requested)
		if hud.has_signal("restart_requested"):
			hud.restart_requested.connect(_on_hud_restart_requested)
		if hud.has_signal("locale_changed"):
			hud.locale_changed.connect(_on_locale_changed)
		if hud.has_signal("training_options_changed"):
			hud.training_options_changed.connect(_on_hud_training_options_changed)
		if hud.has_method("set_pause_visible"):
			hud.set_pause_visible(false)
		if hud.has_method("set_training_panel_visible"):
			hud.set_training_panel_visible(training_panel_enabled)
		if hud.has_method("set_training_controls_visible"):
			hud.set_training_controls_visible(training_controls_enabled)
	
	_apply_training_options()
	_update_hud()
	_refresh_result_text()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		_restart_match()
	elif event.is_action_pressed("pause"):
		_toggle_pause()

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	if match_over:
		return
	if not round_timer_enabled:
		_update_hud()
		_update_camera(delta)
		return
	if time_left <= 0.0:
		time_left = 0.0
		_end_match(_resolve_timeout())
		return
	time_left = maxf(0.0, time_left - delta)
	_update_hud()
	_update_camera(delta)

func _setup_camera() -> void:
	camera = Camera2D.new()
	add_child(camera)
	camera.zoom = Vector2(1.1, 1.1)
	camera.position_smoothing_enabled = false
	camera.limit_left = 0
	camera.limit_right = 900
	camera.limit_bottom = 500
	camera.limit_top = -200

func _setup_walls() -> void:
	var walls = StaticBody2D.new()
	add_child(walls)
	
	var left_shape = CollisionShape2D.new()
	var left_rect = RectangleShape2D.new()
	left_rect.size = Vector2(40, 1000)
	left_shape.shape = left_rect
	left_shape.position = Vector2(-20, 300)
	walls.add_child(left_shape)
	
	var right_shape = CollisionShape2D.new()
	var right_rect = RectangleShape2D.new()
	right_rect.size = Vector2(40, 1000)
	right_shape.shape = right_rect
	right_shape.position = Vector2(920, 300)
	walls.add_child(right_shape)

func _setup_effects_layer() -> void:
	effects_layer = Node2D.new()
	effects_layer.name = "Effects"
	add_child(effects_layer)

func _load_impact_sprite_frames() -> void:
	var loaded := load(IMPACT_SPRITE_FRAMES_PATH)
	if loaded is SpriteFrames:
		impact_sprite_frames = loaded as SpriteFrames
	else:
		impact_sprite_frames = null
		push_warning("Impact sprite frames missing or invalid: %s" % IMPACT_SPRITE_FRAMES_PATH)

func _load_sfx_streams() -> void:
	sfx_streams.clear()
	for key in SFX_PATHS.keys():
		var path := String(SFX_PATHS[key])
		var stream := load(path)
		if stream is AudioStream:
			sfx_streams[key] = stream
		else:
			push_warning("SFX missing or invalid: %s (%s)" % [key, path])

func _update_camera(delta: float) -> void:
	if player_1 and player_2 and camera:
		var center_x = (player_1.position.x + player_2.position.x) / 2.0
		var camera_pos := Vector2(round(center_x), 270.0)
		if camera_shake_time > 0.0:
			camera_shake_time = maxf(0.0, camera_shake_time - delta)
			var falloff := 0.0
			if camera_shake_duration > 0.0:
				falloff = camera_shake_time / camera_shake_duration
			var strength := camera_shake_strength * falloff
			camera_pos.x = round(camera_pos.x + camera_rng.randf_range(-strength, strength))
			camera_pos.y = round(camera_pos.y + camera_rng.randf_range(-strength, strength))
		camera.position = camera_pos

func _resolve_timeout() -> String:
	if player_1.current_hp > player_2.current_hp:
		return "p1_win"
	if player_2.current_hp > player_1.current_hp:
		return "p2_win"
	return "draw"

func _end_match(result_key: String) -> void:
	match_over = true
	match_result_key = result_key
	get_tree().paused = false
	if hud and hud.has_method("set_pause_visible"):
		hud.set_pause_visible(false)
	_refresh_result_text()

func _restart_match() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().reload_current_scene()

func _toggle_pause() -> void:
	var is_paused = get_tree().paused
	get_tree().paused = not is_paused
	if hud and hud.has_method("set_pause_visible"):
		hud.set_pause_visible(get_tree().paused)

func _on_player_health_changed() -> void:
	_update_hud()

func _update_hud() -> void:
	if hud and hud.has_method("set_timer_seconds"):
		hud.set_timer_seconds(time_left)
	if hud and hud.has_method("set_health"):
		hud.set_health(player_1.current_hp, player_2.current_hp)

func _refresh_result_text() -> void:
	if not hud or not hud.has_method("set_result"):
		return
	if match_result_key == "":
		hud.set_result("")
		return
	var result_text_key: String = RESULT_TO_TEXT_KEY.get(match_result_key, "")
	if result_text_key == "":
		hud.set_result(match_result_key)
		return
	hud.set_result(tr(result_text_key) + tr("RESULT_RESTART_HINT"))

func _on_hit_landed(_attacker, _target, _kind, _is_counter: bool, _combo_count: int) -> void:
	var hitstop := float(HITSTOP_BY_ATTACK.get(_kind, 0.07))
	if _is_counter:
		hitstop += COUNTER_HITSTOP_BONUS
	_apply_hitstop(hitstop)
	_play_attack_sfx("hit", _kind)
	_start_camera_shake(_kind, false, _is_counter)
	if _is_counter:
		_play_sfx_key("counter")
		_show_combat_callout("HUD_CALLOUT_COUNTER", Color(1.0, 0.90, 0.54, 1.0))
	elif _combo_count >= 2:
		_play_sfx_key("combo", -8.5, 1.0 + minf(0.15, float(_combo_count - 2) * 0.03))
		_show_combo_callout(_combo_count)
	if _is_counter and _target is Node2D:
		_spawn_counter_spark((_target as Node2D).global_position + Vector2(0, -24), _kind)
	var training_info := _push_training_info(_attacker)
	_show_hit_type_feedback(training_info, false)

func _on_block_landed(_attacker, target, _kind) -> void:
	var blockstop := float(BLOCKSTOP_BY_ATTACK.get(_kind, 0.04))
	_apply_hitstop(blockstop)
	_play_attack_sfx("block", _kind)
	_start_camera_shake(_kind, true)
	_show_combat_callout("HUD_CALLOUT_GUARD", Color(0.74, 0.92, 1.0, 1.0))
	if target is Node2D:
		_spawn_guard_spark((target as Node2D).global_position + Vector2(0, -26), _kind)
	var training_info := _push_training_info(_attacker)
	_show_hit_type_feedback(training_info, true)

func _on_throw_teched(attacker, target) -> void:
	_apply_hitstop(0.035)
	_play_sfx_key("tech", -8.5, 1.08)
	_start_camera_shake("light", true)
	_show_combat_callout("HUD_CALLOUT_THROW_TECH", Color(0.80, 1.0, 0.88, 1.0))
	if target is Node2D:
		_spawn_impact_animation(
			(target as Node2D).global_position + Vector2(0, -24),
			&"guard",
			"light",
			Color(0.84, 1.0, 0.90, 0.95),
			0.9
		)
	_push_training_info(attacker)

func _on_tech_recovered(fighter, tech_kind: String) -> void:
	_show_combat_callout("HUD_CALLOUT_TECH", Color(0.78, 1.0, 0.80, 1.0))
	_play_sfx_key("tech", -10.0, 1.0 if tech_kind == "quick" else 0.92)
	_start_camera_shake("light", true)
	if fighter is Node2D:
		_spawn_impact_animation(
			(fighter as Node2D).global_position + Vector2(0, -22),
			&"guard",
			"light",
			Color(0.76, 1.0, 0.84, 0.92),
			0.8 if tech_kind == "quick" else 0.92
		)

func _apply_hitstop(duration: float) -> void:
	var old_scale = Engine.time_scale
	Engine.time_scale = 0.01 # Almost freeze
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = old_scale

func _on_hud_resume_requested() -> void:
	if get_tree().paused:
		_toggle_pause()

func _on_hud_restart_requested() -> void:
	_restart_match()

func _on_locale_changed(_locale: String) -> void:
	_update_hud()
	_refresh_result_text()
	if hud and hud.has_method("set_training_options"):
		hud.set_training_options(training_options)

func _show_combat_callout(message_key: String, tint: Color) -> void:
	if hud and hud.has_method("show_combat_callout"):
		hud.show_combat_callout(message_key, tint)

func _show_combo_callout(combo_count: int) -> void:
	if hud and hud.has_method("show_combat_callout_with_value"):
		hud.show_combat_callout_with_value(
			"HUD_CALLOUT_COMBO_HIT",
			combo_count,
			Color(1.0, 0.80, 0.56, 1.0)
		)

func _push_training_info(fighter: Node) -> Dictionary:
	if not bool(training_options.get("enabled", true)):
		return {}
	if not hud or not hud.has_method("set_training_data"):
		return {}
	if fighter == null or not fighter.has_method("get_last_training_info"):
		return {}
	var info_value: Variant = fighter.call("get_last_training_info")
	if typeof(info_value) != TYPE_DICTIONARY:
		return {}
	var info := (info_value as Dictionary).duplicate(true)
	hud.set_training_data(info)
	if hud.has_method("add_training_log_entry"):
		hud.add_training_log_entry(info)
	return info

func _show_hit_type_feedback(training_info: Dictionary, is_block_event: bool) -> void:
	if training_info.is_empty():
		return
	if not bool(training_options.get("enabled", true)):
		return
	if not hud or not hud.has_method("show_hit_type_callout"):
		return
	var block_type := str(training_info.get("block_type", "mid"))
	match block_type:
		"overhead", "high":
			hud.show_hit_type_callout(
				"HUD_CALLOUT_OVERHEAD",
				Color(0.98, 0.78, 0.54, 1.0) if not is_block_event else Color(0.90, 0.84, 1.0, 1.0)
			)
		"low":
			hud.show_hit_type_callout(
				"HUD_CALLOUT_LOW",
				Color(0.90, 1.0, 0.62, 1.0) if not is_block_event else Color(0.74, 0.98, 0.86, 1.0)
			)

func _apply_training_options() -> void:
	var enabled := bool(training_options.get("enabled", true))
	var dummy_mode := str(training_options.get("dummy_mode", "stand"))
	if hud and hud.has_method("set_training_options"):
		hud.set_training_options(training_options)
	if not enabled and hud:
		if hud.has_method("set_training_data"):
			hud.set_training_data({})
		if hud.has_method("clear_training_log"):
			hud.clear_training_log()
	if player_2 and player_2.has_method("set_training_dummy_options"):
		player_2.call("set_training_dummy_options", enabled, dummy_mode)
	if player_1 and player_1.has_method("set_training_dummy_options"):
		player_1.call("set_training_dummy_options", false, "stand")

func _on_hud_training_options_changed(options: Dictionary) -> void:
	training_options["enabled"] = bool(options.get("enabled", training_options.get("enabled", true)))
	var dummy_mode := str(options.get("dummy_mode", training_options.get("dummy_mode", "stand")))
	if dummy_mode not in ["stand", "force_block", "random_block"]:
		dummy_mode = "stand"
	training_options["dummy_mode"] = dummy_mode
	training_options["show_detail"] = bool(options.get("show_detail", training_options.get("show_detail", false)))
	_apply_training_options()

func _play_attack_sfx(prefix: String, attack_kind: String) -> void:
	var key := "%s_%s" % [prefix, attack_kind]
	if not sfx_streams.has(key):
		if attack_kind == "throw":
			key = "%s_heavy" % prefix
		else:
			return
	_play_sfx_key(key)

func _play_sfx_key(key: String, volume_override_db: float = INF, pitch_scale: float = 1.0) -> void:
	if not sfx_streams.has(key):
		return
	var stream := sfx_streams[key] as AudioStream
	if stream == null:
		return
	var volume_db := float(SFX_VOLUME_DB.get(key, -8.0))
	if volume_override_db != INF:
		volume_db = volume_override_db
	_play_sfx_stream(stream, volume_db, pitch_scale)

func _play_sfx_stream(stream: AudioStream, volume_db: float, pitch_scale: float) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	add_child(player)
	player.finished.connect(
		func():
			if is_instance_valid(player):
				player.queue_free(),
		CONNECT_ONE_SHOT
	)
	player.play()

func _start_camera_shake(attack_kind: String, is_block: bool, is_counter: bool = false) -> void:
	var source := CAMERA_SHAKE_BY_BLOCK if is_block else CAMERA_SHAKE_BY_ATTACK
	var profile: Dictionary = source.get(attack_kind, {})
	var duration := float(profile.get("duration", 0.08))
	var strength := float(profile.get("strength", 2.8))
	if is_counter and not is_block:
		strength *= COUNTER_SHAKE_MULTIPLIER
		duration *= 1.15
	camera_shake_duration = duration
	camera_shake_time = duration
	camera_shake_strength = strength

func _spawn_guard_spark(world_position: Vector2, attack_kind: String) -> void:
	_spawn_impact_animation(
		world_position,
		&"guard",
		attack_kind,
		Color(0.78, 0.95, 1.0, 0.95),
		0.95
	)

func _spawn_counter_spark(world_position: Vector2, attack_kind: String) -> void:
	_spawn_impact_animation(
		world_position,
		&"counter",
		attack_kind,
		Color(1.0, 0.92, 0.60, 0.96),
		1.08
	)

func _spawn_impact_animation(
	world_position: Vector2,
	animation_name: StringName,
	attack_kind: String,
	tint: Color,
	base_scale: float
) -> void:
	if effects_layer == null or impact_sprite_frames == null:
		return
	if not impact_sprite_frames.has_animation(animation_name):
		return
	var spark := AnimatedSprite2D.new()
	spark.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spark.sprite_frames = impact_sprite_frames
	spark.centered = true
	spark.z_index = 12
	spark.position = world_position
	spark.modulate = tint

	var scale_factor := base_scale
	if attack_kind == "heavy":
		scale_factor *= 1.18
	elif attack_kind == "special":
		scale_factor *= 1.28
	spark.scale = Vector2.ONE * scale_factor

	effects_layer.add_child(spark)
	spark.animation_finished.connect(
		func():
			if is_instance_valid(spark):
				spark.queue_free(),
		CONNECT_ONE_SHOT
	)
	spark.play(animation_name)

extends Node2D

const CharacterCatalogStore := preload("res://scripts/config/CharacterCatalog.gd")
const SessionKeysStore := preload("res://scripts/config/SessionKeys.gd")
const StageConfigStore := preload("res://scripts/config/StageConfig.gd")
const SessionStateStore := preload("res://scripts/SessionState.gd")

const ROUND_TIME_SECONDS := 60.0
const WIN_RULE_HP_TIMER := "hp_timer"
const WIN_RULE_STOCK := "stock"
const DEFAULT_STAGE_LEFT_X := StageConfigStore.DEFAULT_LEFT_X
const DEFAULT_STAGE_RIGHT_X := StageConfigStore.DEFAULT_RIGHT_X
const DEFAULT_STAGE_FLOOR_Y := StageConfigStore.DEFAULT_FLOOR_Y
const BLAST_ZONE_SIDE_MARGIN := 120.0
const BLAST_ZONE_TOP_Y := -260.0
const BLAST_ZONE_BOTTOM_Y := 620.0
const RESULT_TO_TEXT_KEY := {
	"p1_win": "RESULT_P1_WIN",
	"p2_win": "RESULT_P2_WIN",
	"draw": "RESULT_DRAW"
}
const HITSTOP_BY_TIER := {
	"light": 0.055,
	"heavy": 0.090,
	"special": 0.102,
	"throw": 0.078,
	"signature": 0.118,
	"ultimate": 0.142
}
const BLOCKSTOP_BY_TIER := {
	"light": 0.028,
	"heavy": 0.050,
	"special": 0.061,
	"throw": 0.0,
	"signature": 0.073,
	"ultimate": 0.089
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
const MENU_SCENE_PATH := "res://scenes/Menu.tscn"
const STORY_SCENE_PATH := "res://scenes/Story.tscn"
const STORY_SCENE_MODE := "story"
const STORY_ROUND_TRANSITION_SECONDS := 1.35
const SFX_PLAYER_POOL_SIZE := 12
const MAX_ACTIVE_IMPACTS := 24
const CAMERA_TRACK_BASE_Y := 270.0
const CAMERA_TRACK_TOP_Y := 128.0
const CAMERA_TRACK_BOTTOM_Y := 360.0
const CAMERA_TRACK_X_SMOOTH_SPEED := 7.8
const CAMERA_TRACK_Y_SMOOTH_SPEED := 6.2
const CAMERA_EDGE_BIAS_DISTANCE := 72.0
const CAMERA_EDGE_BIAS_WEIGHT := 0.24
const CAMERA_HORIZONTAL_NEAR_DISTANCE := 180.0
const CAMERA_HORIZONTAL_FAR_DISTANCE := 640.0
const CAMERA_VERTICAL_NEAR_DISTANCE := 72.0
const CAMERA_VERTICAL_FAR_DISTANCE := 360.0
const CAMERA_VERTICAL_ZOOM_WEIGHT := 0.86
const CAMERA_VERTICAL_FOCUS_RANGE := 240.0
const CAMERA_ZOOM_NEAR := 0.96
const CAMERA_ZOOM_FAR := 1.22
const CAMERA_ZOOM_SMOOTH_SPEED := 6.0
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
const DIALOGUE_PACK_PATH := "res://assets/data/dialogue/DialoguePackV1.json"
const DIALOGUE_LINE_DELAY_SECONDS := 0.45

var time_left := ROUND_TIME_SECONDS
var stocks := {"p1": 0, "p2": 0}
var spawn_points := {"p1": Vector2(200, 300), "p2": Vector2(600, 300)}
var stage_left_x := DEFAULT_STAGE_LEFT_X
var stage_right_x := DEFAULT_STAGE_RIGHT_X
var stage_floor_y := DEFAULT_STAGE_FLOOR_Y
var blast_zone_left_x := DEFAULT_STAGE_LEFT_X - BLAST_ZONE_SIDE_MARGIN
var blast_zone_right_x := DEFAULT_STAGE_RIGHT_X + BLAST_ZONE_SIDE_MARGIN
var match_over := false
var match_result_key := ""
var camera_shake_time := 0.0
var camera_shake_duration := 0.0
var camera_shake_strength := 0.0
var camera_rng := RandomNumberGenerator.new()
var hitstop_active := false
var hitstop_end_msec := 0
var sfx_player_pool: Array[AudioStreamPlayer] = []
var sfx_player_pool_cursor := 0

@export var round_timer_enabled := true
@export_enum("hp_timer", "stock") var win_rule := WIN_RULE_STOCK
@export_range(1, 7, 1) var stock_count := 3
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
var selected_character_ids := {"p1": "", "p2": ""}
var selected_character_names := {"p1": "Player 1", "p2": "Player 2"}
var selected_character_profiles := {"p1": {}, "p2": {}}
var dialogue_pack := {}
var dialogue_rng := RandomNumberGenerator.new()
var story_mode_active := false
var story_round_index := 0
var story_roster: Array[Dictionary] = []
var story_round_transition_time := 0.0
var camera_track_x := 0.0
var camera_track_y := CAMERA_TRACK_BASE_Y
var dialogue_timer: Timer
var pending_dialogue_text := ""
var pending_dialogue_duration := 0.0
var pending_dialogue_tint := Color(1.0, 1.0, 1.0, 1.0)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_clear_hitstop()
	camera_rng.randomize()
	dialogue_rng.randomize()
	_resolve_stage_bounds_from_scene()
	_apply_stage_bounds_to_players()
	if player_1:
		spawn_points["p1"] = player_1.position
	if player_2:
		spawn_points["p2"] = player_2.position
	_reset_stocks()
	training_options["enabled"] = training_scene_enabled
	training_options["dummy_mode"] = training_dummy_default_mode
	training_options["show_detail"] = training_detail_default_visible
	_setup_camera()
	_setup_walls()
	_setup_effects_layer()
	_load_impact_sprite_frames()
	_load_sfx_streams()
	_setup_sfx_player_pool()
	_apply_selected_character_tables()
	_apply_session_match_mode()
	_load_dialogue_pack()
	_setup_dialogue_timer()

	if player_1:
		player_1.health_changed.connect(_on_player_health_changed)
		player_1.defeated.connect(func(): _on_player_defeated("p1"))
	if player_2:
		player_2.health_changed.connect(_on_player_health_changed)
		player_2.defeated.connect(func(): _on_player_defeated("p2"))
	
	if player_1 and player_1.has_signal("hit_landed"):
		player_1.hit_landed.connect(_on_hit_landed)
	if player_2 and player_2.has_signal("hit_landed"):
		player_2.hit_landed.connect(_on_hit_landed)
	if player_1 and player_1.has_signal("blocked_landed"):
		player_1.blocked_landed.connect(_on_block_landed)
	if player_2 and player_2.has_signal("blocked_landed"):
		player_2.blocked_landed.connect(_on_block_landed)
	if player_1 and player_1.has_signal("tech_recovered"):
		player_1.tech_recovered.connect(_on_tech_recovered)
	if player_2 and player_2.has_signal("tech_recovered"):
		player_2.tech_recovered.connect(_on_tech_recovered)
	if player_1 and player_1.has_signal("throw_teched"):
		player_1.throw_teched.connect(_on_throw_teched)
	if player_2 and player_2.has_signal("throw_teched"):
		player_2.throw_teched.connect(_on_throw_teched)

	if hud:
		if hud.has_signal("resume_requested"):
			hud.resume_requested.connect(_on_hud_resume_requested)
		if hud.has_signal("restart_requested"):
			hud.restart_requested.connect(_on_hud_restart_requested)
		if hud.has_signal("menu_requested"):
			hud.menu_requested.connect(_on_hud_menu_requested)
		if hud.has_signal("locale_changed"):
			hud.locale_changed.connect(_on_locale_changed)
		if hud.has_signal("training_options_changed"):
			hud.training_options_changed.connect(_on_hud_training_options_changed)
		if hud.has_method("set_pause_visible"):
			hud.set_pause_visible(false)
		if hud.has_method("set_timer_visible"):
			hud.set_timer_visible(round_timer_enabled)
		if hud.has_method("set_training_panel_visible"):
			hud.set_training_panel_visible(training_panel_enabled)
		if hud.has_method("set_training_controls_visible"):
			hud.set_training_controls_visible(training_controls_enabled)
	
	_apply_training_options()
	_update_hud()
	_refresh_result_text()
	_trigger_pre_fight_dialogue()

func _exit_tree() -> void:
	_clear_hitstop()
	if dialogue_timer and is_instance_valid(dialogue_timer):
		dialogue_timer.stop()
	pending_dialogue_text = ""
	pending_dialogue_duration = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		_restart_match()
	elif event.is_action_pressed("pause"):
		_toggle_pause()

func _process(delta: float) -> void:
	_update_hitstop_state()
	if get_tree().paused:
		return
	if match_over:
		_update_story_round_transition(delta)
		return
	if _uses_stock_rule():
		_update_stock_ring_out_state()
		if match_over:
			_update_hud()
			_update_camera(delta)
			return
		if round_timer_enabled:
			if time_left <= 0.0:
				time_left = 0.0
				_end_match(_resolve_timeout())
				return
			time_left = maxf(0.0, time_left - delta)
		_update_hud()
		_update_camera(delta)
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
	camera.zoom = Vector2(1.08, 1.08)
	camera.position_smoothing_enabled = false
	camera_track_x = (player_1.position.x + player_2.position.x) * 0.5 if player_1 and player_2 else (stage_left_x + stage_right_x) * 0.5
	camera_track_y = CAMERA_TRACK_BASE_Y
	if _uses_stock_rule():
		camera.limit_left = int(floor(blast_zone_left_x))
		camera.limit_right = int(ceil(blast_zone_right_x))
		camera.limit_bottom = int(ceil(BLAST_ZONE_BOTTOM_Y))
		camera.limit_top = int(floor(BLAST_ZONE_TOP_Y))
	else:
		camera.limit_left = int(floor(stage_left_x))
		camera.limit_right = int(ceil(stage_right_x))
		camera.limit_bottom = 500
		camera.limit_top = -200

func _setup_walls() -> void:
	if _uses_stock_rule():
		return
	var walls = StaticBody2D.new()
	add_child(walls)
	
	var left_shape = CollisionShape2D.new()
	var left_rect = RectangleShape2D.new()
	left_rect.size = Vector2(40, 1000)
	left_shape.shape = left_rect
	left_shape.position = Vector2(stage_left_x - 20.0, 300)
	walls.add_child(left_shape)
	
	var right_shape = CollisionShape2D.new()
	var right_rect = RectangleShape2D.new()
	right_rect.size = Vector2(40, 1000)
	right_shape.shape = right_rect
	right_shape.position = Vector2(stage_right_x + 20.0, 300)
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

func _setup_sfx_player_pool() -> void:
	for player in sfx_player_pool:
		if is_instance_valid(player):
			player.queue_free()
	sfx_player_pool.clear()
	sfx_player_pool_cursor = 0
	for _index in range(SFX_PLAYER_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		add_child(player)
		sfx_player_pool.append(player)

func _update_camera(delta: float) -> void:
	if player_1 and player_2 and camera:
		var center_x: float = (player_1.position.x + player_2.position.x) / 2.0
		var center_y: float = (player_1.position.y + player_2.position.y) / 2.0
		var distance_x: float = absf(player_1.position.x - player_2.position.x)
		var distance_y: float = absf(player_1.position.y - player_2.position.y)
		var zoom_t_horizontal: float = clampf(
			(distance_x - CAMERA_HORIZONTAL_NEAR_DISTANCE) / maxf(1.0, CAMERA_HORIZONTAL_FAR_DISTANCE - CAMERA_HORIZONTAL_NEAR_DISTANCE),
			0.0,
			1.0
		)
		var zoom_t_vertical: float = clampf(
			(distance_y - CAMERA_VERTICAL_NEAR_DISTANCE) / maxf(1.0, CAMERA_VERTICAL_FAR_DISTANCE - CAMERA_VERTICAL_NEAR_DISTANCE),
			0.0,
			1.0
		)
		var zoom_t: float = maxf(zoom_t_horizontal, zoom_t_vertical * CAMERA_VERTICAL_ZOOM_WEIGHT)
		var target_zoom: float = lerpf(CAMERA_ZOOM_NEAR, CAMERA_ZOOM_FAR, zoom_t)
		var zoom_blend: float = clampf(delta * CAMERA_ZOOM_SMOOTH_SPEED, 0.0, 1.0)
		var next_zoom: float = lerpf(camera.zoom.x, target_zoom, zoom_blend)
		camera.zoom = Vector2(next_zoom, next_zoom)

		var p1_near_stage: bool = player_1.position.x >= stage_left_x - CAMERA_EDGE_BIAS_DISTANCE and player_1.position.x <= stage_right_x + CAMERA_EDGE_BIAS_DISTANCE
		var p2_near_stage: bool = player_2.position.x >= stage_left_x - CAMERA_EDGE_BIAS_DISTANCE and player_2.position.x <= stage_right_x + CAMERA_EDGE_BIAS_DISTANCE
		if p1_near_stage != p2_near_stage:
			var stage_anchor_x: float = player_1.position.x if p1_near_stage else player_2.position.x
			center_x = lerpf(center_x, stage_anchor_x, CAMERA_EDGE_BIAS_WEIGHT)
		var x_blend: float = clampf(delta * CAMERA_TRACK_X_SMOOTH_SPEED, 0.0, 1.0)
		camera_track_x = lerpf(camera_track_x, center_x, x_blend)

		var target_track_y: float = _resolve_camera_track_y_target(center_y)
		var y_blend: float = clampf(delta * CAMERA_TRACK_Y_SMOOTH_SPEED, 0.0, 1.0)
		camera_track_y = lerpf(camera_track_y, target_track_y, y_blend)
		var camera_pos := Vector2(round(camera_track_x), round(camera_track_y))
		if camera_shake_time > 0.0:
			camera_shake_time = maxf(0.0, camera_shake_time - delta)
			var falloff := 0.0
			if camera_shake_duration > 0.0:
				falloff = camera_shake_time / camera_shake_duration
			var strength := camera_shake_strength * falloff
			camera_pos.x = round(camera_pos.x + camera_rng.randf_range(-strength, strength))
			camera_pos.y = round(camera_pos.y + camera_rng.randf_range(-strength, strength))
		camera.position = camera_pos

func _resolve_camera_track_y_target(center_y: float) -> float:
	var up_t := clampf((CAMERA_TRACK_BASE_Y - center_y) / maxf(1.0, CAMERA_VERTICAL_FOCUS_RANGE), 0.0, 1.0)
	if up_t > 0.0:
		return lerpf(CAMERA_TRACK_BASE_Y, CAMERA_TRACK_TOP_Y, up_t)
	var down_t := clampf((center_y - CAMERA_TRACK_BASE_Y) / maxf(1.0, CAMERA_VERTICAL_FOCUS_RANGE), 0.0, 1.0)
	return lerpf(CAMERA_TRACK_BASE_Y, CAMERA_TRACK_BOTTOM_Y, down_t * 0.72)

func _resolve_timeout() -> String:
	if _uses_stock_rule():
		var p1_stock := int(stocks.get("p1", 0))
		var p2_stock := int(stocks.get("p2", 0))
		if p1_stock > p2_stock:
			return "p1_win"
		if p2_stock > p1_stock:
			return "p2_win"
	if player_1.current_hp > player_2.current_hp:
		return "p1_win"
	if player_2.current_hp > player_1.current_hp:
		return "p2_win"
	return "draw"

func _end_match(result_key: String) -> void:
	if match_over:
		return
	match_over = true
	match_result_key = result_key
	_clear_hitstop()
	get_tree().paused = false
	if hud and hud.has_method("set_pause_visible"):
		hud.set_pause_visible(false)
	_refresh_result_text()
	_queue_story_progression(result_key)
	_trigger_victory_dialogue(result_key)

func _queue_story_progression(result_key: String) -> void:
	story_round_transition_time = 0.0
	if not story_mode_active:
		return
	if result_key != "p1_win":
		SessionStateStore.clear_keys(PackedStringArray([SessionKeysStore.STORY_ROUND_INDEX]))
		return
	if story_round_index + 1 >= story_roster.size():
		SessionStateStore.clear_keys(PackedStringArray([SessionKeysStore.STORY_ROUND_INDEX]))
		return
	SessionStateStore.set_value(SessionKeysStore.STORY_ROUND_INDEX, story_round_index + 1)
	story_round_transition_time = STORY_ROUND_TRANSITION_SECONDS

func _update_story_round_transition(delta: float) -> void:
	if not story_mode_active:
		return
	if story_round_transition_time <= 0.0:
		return
	story_round_transition_time = maxf(0.0, story_round_transition_time - delta)
	if story_round_transition_time > 0.0:
		return
	if match_result_key != "p1_win":
		return
	get_tree().change_scene_to_file(STORY_SCENE_PATH)

func _restart_match() -> void:
	if story_mode_active:
		SessionStateStore.set_value(SessionKeysStore.STORY_ROUND_INDEX, 0)
	_clear_hitstop()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _toggle_pause() -> void:
	var is_paused = get_tree().paused
	get_tree().paused = not is_paused
	if hud and hud.has_method("set_pause_visible"):
		hud.set_pause_visible(get_tree().paused)

func _uses_stock_rule() -> bool:
	return win_rule == WIN_RULE_STOCK

func _reset_stocks() -> void:
	var initial := maxi(1, stock_count)
	stocks["p1"] = initial
	stocks["p2"] = initial

func _update_stock_ring_out_state() -> void:
	var p1_out := player_1 and _is_outside_blast_zone(player_1.global_position)
	var p2_out := player_2 and _is_outside_blast_zone(player_2.global_position)
	if p1_out and p2_out:
		_lose_stocks_simultaneously()
		return
	if p1_out:
		_lose_stock("p1")
	if p2_out:
		_lose_stock("p2")

func _is_outside_blast_zone(world_position: Vector2) -> bool:
	if world_position.x < blast_zone_left_x:
		return true
	if world_position.x > blast_zone_right_x:
		return true
	if world_position.y < BLAST_ZONE_TOP_Y:
		return true
	if world_position.y > BLAST_ZONE_BOTTOM_Y:
		return true
	return false

func _resolve_stage_bounds_from_scene() -> void:
	var fallback := Vector2(DEFAULT_STAGE_LEFT_X, DEFAULT_STAGE_RIGHT_X)
	stage_left_x = fallback.x
	stage_right_x = fallback.y
	stage_floor_y = DEFAULT_STAGE_FLOOR_Y
	var shape_node := get_node_or_null("Arena/Ground/CollisionShape2D")
	if shape_node == null:
		_refresh_blast_zone_bounds()
		return
	if shape_node is not CollisionShape2D:
		_refresh_blast_zone_bounds()
		return
	var collision_shape := shape_node as CollisionShape2D
	var rect_shape := collision_shape.shape as RectangleShape2D
	if rect_shape == null:
		_refresh_blast_zone_bounds()
		return
	var world_center := collision_shape.global_position
	var world_center_x := world_center.x
	var half_width := rect_shape.size.x * 0.5 * absf(collision_shape.global_scale.x)
	var half_height := rect_shape.size.y * 0.5 * absf(collision_shape.global_scale.y)
	if half_width <= 0.0 or half_height <= 0.0:
		_refresh_blast_zone_bounds()
		return
	stage_left_x = world_center_x - half_width
	stage_right_x = world_center_x + half_width
	stage_floor_y = world_center.y - half_height
	_refresh_blast_zone_bounds()

func _refresh_blast_zone_bounds() -> void:
	blast_zone_left_x = stage_left_x - BLAST_ZONE_SIDE_MARGIN
	blast_zone_right_x = stage_right_x + BLAST_ZONE_SIDE_MARGIN

func _apply_stage_bounds_to_players() -> void:
	if player_1:
		if player_1.has_method("set_stage_geometry"):
			player_1.call("set_stage_geometry", stage_left_x, stage_right_x, stage_floor_y)
		elif player_1.has_method("set_stage_bounds"):
			player_1.call("set_stage_bounds", stage_left_x, stage_right_x)
	if player_2:
		if player_2.has_method("set_stage_geometry"):
			player_2.call("set_stage_geometry", stage_left_x, stage_right_x, stage_floor_y)
		elif player_2.has_method("set_stage_bounds"):
			player_2.call("set_stage_bounds", stage_left_x, stage_right_x)

func _lose_stock(player_key: String) -> void:
	if not _uses_stock_rule():
		return
	if match_over:
		return
	var current := int(stocks.get(player_key, 0))
	if current <= 0:
		return
	stocks[player_key] = current - 1
	var p1_stock := int(stocks.get("p1", 0))
	var p2_stock := int(stocks.get("p2", 0))
	if p1_stock <= 0 and p2_stock <= 0:
		_end_match("draw")
		return
	if p1_stock <= 0:
		_end_match("p2_win")
		return
	if p2_stock <= 0:
		_end_match("p1_win")
		return
	_respawn_player_by_key(player_key)
	_update_hud()

func _lose_stocks_simultaneously() -> void:
	if not _uses_stock_rule():
		return
	if match_over:
		return
	var p1_stock := maxi(0, int(stocks.get("p1", 0)) - 1)
	var p2_stock := maxi(0, int(stocks.get("p2", 0)) - 1)
	stocks["p1"] = p1_stock
	stocks["p2"] = p2_stock
	if p1_stock <= 0 and p2_stock <= 0:
		_end_match("draw")
		return
	if p1_stock <= 0:
		_end_match("p2_win")
		return
	if p2_stock <= 0:
		_end_match("p1_win")
		return
	_respawn_player_by_key("p1")
	_respawn_player_by_key("p2")
	_update_hud()

func _respawn_player_by_key(player_key: String) -> void:
	var fighter := _get_player_by_key(player_key)
	if fighter == null:
		return
	var spawn_value: Variant = spawn_points.get(player_key, Vector2(200, 300))
	var spawn: Vector2 = Vector2(200, 300)
	if spawn_value is Vector2:
		spawn = spawn_value
	var facing_direction := 1 if player_key == "p1" else -1
	if fighter.has_method("force_respawn"):
		fighter.call("force_respawn", spawn, facing_direction)
	else:
		fighter.global_position = spawn
		fighter.set("current_hp", 100)

func _get_player_by_key(player_key: String) -> CharacterBody2D:
	if player_key == "p1":
		return player_1
	if player_key == "p2":
		return player_2
	return null

func _on_player_health_changed() -> void:
	_update_hud()

func _on_player_defeated(loser_key: String) -> void:
	if match_over:
		return
	if _uses_stock_rule():
		var p1_defeated: bool = player_1 != null and int(player_1.current_hp) <= 0
		var p2_defeated: bool = player_2 != null and int(player_2.current_hp) <= 0
		if p1_defeated and p2_defeated:
			if loser_key != "p1":
				return
			_lose_stocks_simultaneously()
			return
		_lose_stock(loser_key)
		return
	var p1_defeated: bool = player_1 != null and int(player_1.current_hp) <= 0
	var p2_defeated: bool = player_2 != null and int(player_2.current_hp) <= 0
	if p1_defeated and p2_defeated:
		_end_match("draw")
		return
	if loser_key == "p1":
		_end_match("p2_win")
		return
	_end_match("p1_win")

func _update_hud() -> void:
	if hud and hud.has_method("set_timer_seconds"):
		hud.set_timer_seconds(time_left)
	if hud and hud.has_method("set_stocks"):
		hud.set_stocks(int(stocks.get("p1", 0)), int(stocks.get("p2", 0)))
	if hud and hud.has_method("set_match_ui_mode"):
		hud.set_match_ui_mode(win_rule)
	if hud and hud.has_method("set_character_profiles"):
		hud.set_character_profiles(
			selected_character_profiles.get("p1", {}),
			selected_character_profiles.get("p2", {})
		)
	if hud and hud.has_method("set_health"):
		hud.set_health(player_1.current_hp, player_2.current_hp)
	if hud and hud.has_method("set_combat_state"):
		var p1_state := {}
		var p2_state := {}
		if player_1 and player_1.has_method("get_runtime_status_snapshot"):
			var p1_state_value: Variant = player_1.call("get_runtime_status_snapshot")
			if typeof(p1_state_value) == TYPE_DICTIONARY:
				p1_state = (p1_state_value as Dictionary).duplicate(true)
		if player_2 and player_2.has_method("get_runtime_status_snapshot"):
			var p2_state_value: Variant = player_2.call("get_runtime_status_snapshot")
			if typeof(p2_state_value) == TYPE_DICTIONARY:
				p2_state = (p2_state_value as Dictionary).duplicate(true)
		hud.set_combat_state(p1_state, p2_state)

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
	var hint_key := "RESULT_RESTART_HINT"
	if story_mode_active:
		if match_result_key == "p1_win":
			hint_key = "RESULT_STORY_CLEAR_HINT" if story_round_index + 1 >= story_roster.size() else "RESULT_STORY_NEXT_HINT"
		else:
			hint_key = "RESULT_STORY_FAIL_HINT"
	hud.set_result(tr(result_text_key) + tr(hint_key))

func _on_hit_landed(_attacker, _target, _kind, _is_counter: bool, _combo_count: int) -> void:
	var hitstop := _resolve_hitstop_duration(_kind, _is_counter, _combo_count)
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
	var blockstop := _resolve_blockstop_duration(_kind)
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

func _resolve_hitstop_duration(attack_kind: String, is_counter: bool, combo_count: int) -> float:
	var tier := _resolve_attack_tier(attack_kind)
	var duration := float(HITSTOP_BY_TIER.get(tier, HITSTOP_BY_TIER.get("special", 0.10)))
	if combo_count >= 3:
		var combo_scale := maxf(0.86, 1.0 - float(combo_count - 2) * 0.04)
		duration *= combo_scale
	if is_counter:
		duration += COUNTER_HITSTOP_BONUS
	return duration

func _resolve_blockstop_duration(attack_kind: String) -> float:
	var tier := _resolve_attack_tier(attack_kind)
	return float(BLOCKSTOP_BY_TIER.get(tier, BLOCKSTOP_BY_TIER.get("special", 0.05)))

func _resolve_attack_tier(attack_kind: String) -> String:
	if attack_kind == "ultimate":
		return "ultimate"
	if attack_kind.begins_with("signature_"):
		return "signature"
	if attack_kind.begins_with("heavy"):
		return "heavy"
	if attack_kind.begins_with("light"):
		return "light"
	if attack_kind == "throw":
		return "throw"
	if attack_kind == "special":
		return "special"
	return "special"

func _apply_hitstop(duration: float) -> void:
	if duration <= 0.0:
		return
	var now_msec := Time.get_ticks_msec()
	var request_end_msec := now_msec + int(ceil(duration * 1000.0))
	if not hitstop_active:
		hitstop_active = true
		_set_players_hitstop_active(true)
		hitstop_end_msec = request_end_msec
		return
	hitstop_end_msec = maxi(hitstop_end_msec, request_end_msec)

func _update_hitstop_state() -> void:
	if not hitstop_active:
		return
	if Time.get_ticks_msec() < hitstop_end_msec:
		return
	_clear_hitstop()

func _clear_hitstop() -> void:
	_set_players_hitstop_active(false)
	hitstop_active = false
	hitstop_end_msec = 0

func _set_players_hitstop_active(active: bool) -> void:
	if player_1 and player_1.has_method("set_hitstop_active"):
		player_1.call("set_hitstop_active", active)
	if player_2 and player_2.has_method("set_hitstop_active"):
		player_2.call("set_hitstop_active", active)

func _on_hud_resume_requested() -> void:
	if get_tree().paused:
		_toggle_pause()

func _on_hud_restart_requested() -> void:
	_restart_match()

func _on_hud_menu_requested() -> void:
	_clear_hitstop()
	if story_mode_active:
		SessionStateStore.clear_keys(PackedStringArray([SessionKeysStore.STORY_ROUND_INDEX]))
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE_PATH)

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
	var attacker_key := _resolve_player_key_for_node(fighter)
	if attacker_key != "":
		info["attacker_key"] = attacker_key
	hud.set_training_data(info)
	if hud.has_method("add_training_log_entry"):
		hud.add_training_log_entry(info)
	return info

func _resolve_player_key_for_node(node: Node) -> String:
	if node == player_1:
		return "p1"
	if node == player_2:
		return "p2"
	return ""

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
	if training_scene_enabled:
		if player_2 != null:
			player_2.set("is_ai", false)
		if player_1 != null:
			player_1.set("is_ai", false)

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
	if sfx_player_pool.is_empty():
		_setup_sfx_player_pool()
	if sfx_player_pool.is_empty():
		return
	var player := sfx_player_pool[sfx_player_pool_cursor]
	sfx_player_pool_cursor = (sfx_player_pool_cursor + 1) % sfx_player_pool.size()
	if player == null or not is_instance_valid(player):
		return
	player.stop()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
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
	while effects_layer.get_child_count() >= MAX_ACTIVE_IMPACTS:
		var oldest := effects_layer.get_child(0)
		if oldest:
			oldest.queue_free()
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

func _apply_selected_character_tables() -> void:
	_apply_selected_character_table_for_player(
		player_1,
		SessionKeysStore.PLAYER_1_TABLE_PATH,
		SessionKeysStore.PLAYER_1_ID,
		SessionKeysStore.PLAYER_1_NAME,
		"p1"
	)
	_apply_selected_character_table_for_player(
		player_2,
		SessionKeysStore.PLAYER_2_TABLE_PATH,
		SessionKeysStore.PLAYER_2_ID,
		SessionKeysStore.PLAYER_2_NAME,
		"p2"
	)
	if _is_story_session_mode():
		_apply_story_opponent_round()

func _apply_selected_character_table_for_player(
	player: Node,
	table_path_key: String,
	character_id_key: String,
	character_name_key: String,
	player_key: String
) -> void:
	if player == null:
		return
	if not (player is CharacterBody2D):
		return
	var selected_table_path := ""
	if SessionStateStore.has_value(table_path_key):
		selected_table_path = str(SessionStateStore.get_value(table_path_key, ""))
	var loaded_resource: Resource = null
	if selected_table_path != "":
		var loaded := load(selected_table_path)
		if loaded is Resource:
			loaded_resource = loaded as Resource
	if loaded_resource != null and player.has_method("apply_attack_table"):
		player.call("apply_attack_table", loaded_resource)

	var character_id := ""
	if SessionStateStore.has_value(character_id_key):
		character_id = str(SessionStateStore.get_value(character_id_key, ""))
	if character_id == "" and player.has_method("get_character_id"):
		character_id = str(player.call("get_character_id"))
	selected_character_ids[player_key] = character_id

	var display_name := ""
	if SessionStateStore.has_value(character_name_key):
		display_name = str(SessionStateStore.get_value(character_name_key, ""))
	if display_name == "" and player.has_method("get_character_display_name"):
		display_name = str(player.call("get_character_display_name"))
	if display_name == "":
		display_name = "Player 1" if player_key == "p1" else "Player 2"
	selected_character_names[player_key] = display_name
	var profile := {}
	if player.has_method("get_character_profile"):
		var profile_value: Variant = player.call("get_character_profile")
		if typeof(profile_value) == TYPE_DICTIONARY:
			profile = (profile_value as Dictionary).duplicate(true)
	if profile.is_empty():
		profile = {
			"character_id": character_id,
			"display_name": display_name,
			"archetype_key": "all_rounder",
			"archetype_label_key": "ARCHETYPE_ALL_ROUNDER",
			"archetype_hint_key": "ARCHETYPE_HINT_ALL_ROUNDER",
			"signature_primary": "Signature A",
			"signature_alt": "Signature B",
			"signature_names": {
				"signature_a": "Signature A",
				"signature_b": "Signature B",
				"signature_c": "Mix Signature",
				"ultimate": "Ultimate"
			}
		}
	selected_character_profiles[player_key] = profile

func _is_story_session_mode() -> bool:
	if not SessionStateStore.has_value(SessionKeysStore.MATCH_MODE):
		return false
	return str(SessionStateStore.get_value(SessionKeysStore.MATCH_MODE, "")).to_lower() == STORY_SCENE_MODE

func _build_story_roster() -> Array[Dictionary]:
	var p1_id := str(selected_character_ids.get("p1", ""))
	var roster: Array[Dictionary] = []
	for entry in CharacterCatalogStore.get_story_opponent_pool():
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var item := (entry as Dictionary).duplicate(true)
		var opponent_id := str(item.get("id", ""))
		if opponent_id == "" or opponent_id == p1_id:
			continue
		roster.append(item)
	return roster

func _apply_story_opponent_round() -> void:
	story_roster = _build_story_roster()
	if story_roster.is_empty():
		story_round_index = 0
		return
	var requested_round := 0
	if SessionStateStore.has_value(SessionKeysStore.STORY_ROUND_INDEX):
		requested_round = int(SessionStateStore.get_value(SessionKeysStore.STORY_ROUND_INDEX, 0))
	story_round_index = clampi(requested_round, 0, story_roster.size() - 1)
	var opponent_data := story_roster[story_round_index]
	var table_path := str(opponent_data.get("attack_table_path", "")).strip_edges()
	if table_path != "":
		var loaded := load(table_path)
		if loaded is Resource and player_2 and player_2.has_method("apply_attack_table"):
			player_2.call("apply_attack_table", loaded as Resource)
	selected_character_ids["p2"] = str(opponent_data.get("id", selected_character_ids.get("p2", "")))
	selected_character_names["p2"] = str(opponent_data.get("name", selected_character_names.get("p2", "Player 2")))
	if player_2 and player_2.has_method("get_character_profile"):
		var profile_value: Variant = player_2.call("get_character_profile")
		if typeof(profile_value) == TYPE_DICTIONARY:
			selected_character_profiles["p2"] = (profile_value as Dictionary).duplicate(true)

func _apply_session_match_mode() -> void:
	story_mode_active = false
	story_round_transition_time = 0.0
	var match_mode := ""
	if SessionStateStore.has_value(SessionKeysStore.MATCH_MODE):
		match_mode = str(SessionStateStore.get_value(SessionKeysStore.MATCH_MODE, "")).to_lower()
	if match_mode == "vs":
		if player_1:
			player_1.set("is_ai", false)
		if player_2:
			player_2.set("is_ai", false)
		return
	if match_mode == STORY_SCENE_MODE:
		story_mode_active = true
		if player_1:
			player_1.set("is_ai", false)
		if player_2:
			player_2.set("is_ai", true)

func _load_dialogue_pack() -> void:
	dialogue_pack.clear()
	if not FileAccess.file_exists(DIALOGUE_PACK_PATH):
		push_warning("Dialogue pack file not found: %s" % DIALOGUE_PACK_PATH)
		return
	var raw_text := FileAccess.get_file_as_string(DIALOGUE_PACK_PATH)
	var parsed: Variant = JSON.parse_string(raw_text)
	if typeof(parsed) == TYPE_DICTIONARY:
		dialogue_pack = parsed as Dictionary
	else:
		push_warning("Dialogue pack JSON parse failed: %s" % DIALOGUE_PACK_PATH)

func _setup_dialogue_timer() -> void:
	if dialogue_timer and is_instance_valid(dialogue_timer):
		return
	dialogue_timer = Timer.new()
	dialogue_timer.name = "DialogueDelayTimer"
	dialogue_timer.one_shot = true
	dialogue_timer.autostart = false
	dialogue_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	dialogue_timer.timeout.connect(_on_dialogue_timer_timeout)
	add_child(dialogue_timer)

func _trigger_pre_fight_dialogue() -> void:
	if dialogue_pack.is_empty():
		return
	if not hud or not hud.has_method("show_dialogue_line"):
		return
	var text := _build_pre_fight_dialogue_text()
	if text == "":
		return
	_queue_dialogue_line(text, 2.8, Color(0.94, 0.97, 1.0, 1.0))

func _trigger_victory_dialogue(result_key: String) -> void:
	if dialogue_pack.is_empty():
		return
	if not hud or not hud.has_method("show_dialogue_line"):
		return
	var winner_key := ""
	if result_key == "p1_win":
		winner_key = "p1"
	elif result_key == "p2_win":
		winner_key = "p2"
	if winner_key == "":
		return
	var character_id := str(selected_character_ids.get(winner_key, ""))
	var winner_name := str(selected_character_names.get(winner_key, "Player"))
	var win_line := _get_fighter_dialogue_line(character_id, "win")
	if win_line == "":
		return
	var text := "%s: %s" % [winner_name, win_line]
	_queue_dialogue_line(text, 3.0, Color(1.0, 0.92, 0.72, 1.0))

func _queue_dialogue_line(text: String, duration: float, tint: Color) -> void:
	pending_dialogue_text = text
	pending_dialogue_duration = maxf(duration, 0.1)
	pending_dialogue_tint = tint
	if not dialogue_timer or not is_instance_valid(dialogue_timer):
		_show_pending_dialogue_line()
		return
	dialogue_timer.stop()
	dialogue_timer.wait_time = DIALOGUE_LINE_DELAY_SECONDS
	dialogue_timer.start()

func _on_dialogue_timer_timeout() -> void:
	_show_pending_dialogue_line()

func _show_pending_dialogue_line() -> void:
	if pending_dialogue_text == "":
		return
	var text := pending_dialogue_text
	var duration := pending_dialogue_duration
	var tint := pending_dialogue_tint
	pending_dialogue_text = ""
	pending_dialogue_duration = 0.0
	if hud and hud.has_method("show_dialogue_line"):
		hud.show_dialogue_line(text, duration, tint)

func _build_pre_fight_dialogue_text() -> String:
	var p1_id := str(selected_character_ids.get("p1", ""))
	var p2_id := str(selected_character_ids.get("p2", ""))
	var p1_name := str(selected_character_names.get("p1", "Player 1"))
	var p2_name := str(selected_character_names.get("p2", "Player 2"))
	var rivalry_result := _find_rivalry_entry(p1_id, p2_id)
	if not rivalry_result.is_empty():
		var entry: Dictionary = rivalry_result.get("entry", {})
		var reversed_pair := bool(rivalry_result.get("reversed", false))
		var pre_block_value: Variant = entry.get("pre_fight", {})
		if typeof(pre_block_value) == TYPE_DICTIONARY:
			var lines := _get_localized_lines(pre_block_value as Dictionary)
			if lines.size() >= 2:
				var first_line := lines[0]
				var second_line := lines[1]
				if reversed_pair:
					var tmp := first_line
					first_line = second_line
					second_line = tmp
				return "%s: %s  |  %s: %s" % [p1_name, first_line, p2_name, second_line]
			if lines.size() == 1:
				return lines[0]
	var p1_line := _get_fighter_dialogue_line(p1_id, "intro")
	var p2_line := _get_fighter_dialogue_line(p2_id, "intro")
	if p1_line != "" and p2_line != "":
		return "%s: %s  |  %s: %s" % [p1_name, p1_line, p2_name, p2_line]
	if p1_line != "":
		return "%s: %s" % [p1_name, p1_line]
	if p2_line != "":
		return "%s: %s" % [p2_name, p2_line]
	return ""

func _find_rivalry_entry(p1_id: String, p2_id: String) -> Dictionary:
	var rivalries_value: Variant = dialogue_pack.get("rivalries", [])
	if typeof(rivalries_value) != TYPE_ARRAY:
		return {}
	for entry_value in rivalries_value:
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue
		var entry := entry_value as Dictionary
		var fighters_value: Variant = entry.get("fighters", [])
		if typeof(fighters_value) != TYPE_ARRAY:
			continue
		var fighters := fighters_value as Array
		if fighters.size() < 2:
			continue
		var first := str(fighters[0])
		var second := str(fighters[1])
		if first == p1_id and second == p2_id:
			return {"entry": entry, "reversed": false}
		if first == p2_id and second == p1_id:
			return {"entry": entry, "reversed": true}
	return {}

func _get_fighter_dialogue_line(character_id: String, bucket: String) -> String:
	if character_id == "":
		return ""
	var fighters_value: Variant = dialogue_pack.get("fighters", {})
	if typeof(fighters_value) != TYPE_DICTIONARY:
		return ""
	var fighters_dict := fighters_value as Dictionary
	if not fighters_dict.has(character_id):
		return ""
	var fighter_value: Variant = fighters_dict[character_id]
	if typeof(fighter_value) != TYPE_DICTIONARY:
		return ""
	var fighter_dict := fighter_value as Dictionary
	var bucket_value: Variant = fighter_dict.get(bucket, {})
	if typeof(bucket_value) != TYPE_DICTIONARY:
		return ""
	var lines := _get_localized_lines(bucket_value as Dictionary)
	if lines.is_empty():
		return ""
	var pick := dialogue_rng.randi_range(0, lines.size() - 1)
	return lines[pick]

func _get_localized_lines(language_block: Dictionary) -> PackedStringArray:
	var locale_key := _dialogue_locale_key()
	var lines_value: Variant = language_block.get(locale_key, [])
	if typeof(lines_value) != TYPE_ARRAY:
		return PackedStringArray()
	var result := PackedStringArray()
	for line_value in lines_value:
		var line := str(line_value).strip_edges()
		if line != "":
			result.append(line)
	return result

func _dialogue_locale_key() -> String:
	var locale := TranslationServer.get_locale().to_lower()
	if locale.begins_with("zh"):
		return "zh"
	return "en"

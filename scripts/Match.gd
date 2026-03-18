extends Node2D

const GameSettingsStore := preload("res://scripts/GameSettings.gd")
const CharacterCatalogStore := preload("res://scripts/config/CharacterCatalog.gd")
const LoadoutCatalogStore := preload("res://scripts/config/LoadoutCatalog.gd")
const SessionKeysStore := preload("res://scripts/config/SessionKeys.gd")
const StageConfigStore := preload("res://scripts/config/StageConfig.gd")
const SessionStateStore := preload("res://scripts/SessionState.gd")
const LoadoutResolverStore := preload("res://scripts/loadout/LoadoutResolver.gd")

const ROUND_TIME_SECONDS := 60.0
const WIN_RULE_HP_TIMER := "hp_timer"
const WIN_RULE_STOCK := "stock"
const RULESET_DUEL := "duel"
const RULESET_PLATFORM := "platform"
const TRAINING_DRILL_DUEL_CORE := "duel_core"
const TRAINING_DRILL_RECOVERY_ROUTE := "recovery_route"
const TRAINING_DRILL_LEDGE_ESCAPE := "ledge_escape"
const TRAINING_DRILL_DI_SURVIVAL := "di_survival"
const TRAINING_DRILL_IDS := [
	TRAINING_DRILL_DUEL_CORE,
	TRAINING_DRILL_RECOVERY_ROUTE,
	TRAINING_DRILL_LEDGE_ESCAPE,
	TRAINING_DRILL_DI_SURVIVAL
]
const TRAINING_DRILL_RULESET_BY_ID := {
	TRAINING_DRILL_DUEL_CORE: RULESET_DUEL,
	TRAINING_DRILL_RECOVERY_ROUTE: RULESET_PLATFORM,
	TRAINING_DRILL_LEDGE_ESCAPE: RULESET_PLATFORM,
	TRAINING_DRILL_DI_SURVIVAL: RULESET_PLATFORM
}
const TRAINING_DRILL_STATUS_IDLE := "idle"
const TRAINING_DRILL_STATUS_ACTIVE := "active"
const TRAINING_DRILL_RECOVERY_START_OFFSET := Vector2(88.0, -112.0)
const TRAINING_DRILL_RECOVERY_START_VELOCITY := Vector2(-28.0, 18.0)
const TRAINING_DRILL_LEDGE_DUMMY_OFFSET_X := 92.0
const TRAINING_DRILL_DI_PLAYER_HP := 38
const TRAINING_DRILL_DI_LAUNCH_DELAY_SECONDS := 0.24
const TRAINING_DRILL_DI_DAMAGE := 18
const TRAINING_DRILL_DI_KNOCKBACK := Vector2(248.0, -312.0)
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
	"light": {"duration": 0.09, "strength": 3.0},
	"heavy": {"duration": 0.14, "strength": 6.6},
	"special": {"duration": 0.16, "strength": 7.4},
	"throw": {"duration": 0.11, "strength": 4.2}
}
const CAMERA_SHAKE_BY_BLOCK := {
	"light": {"duration": 0.06, "strength": 1.8},
	"heavy": {"duration": 0.09, "strength": 3.0},
	"special": {"duration": 0.10, "strength": 3.6},
	"throw": {"duration": 0.05, "strength": 1.2}
}
const COUNTER_HITSTOP_BONUS := 0.03
const COUNTER_SHAKE_MULTIPLIER := 1.42
const MENU_SCENE_PATH := "res://scenes/Menu.tscn"
const STORY_SCENE_PATH := "res://scenes/Story.tscn"
const STORY_SCENE_MODE := "story"
const STORY_ROUND_TRANSITION_SECONDS := 1.35
const SFX_PLAYER_POOL_SIZE := 12
const MAX_ACTIVE_IMPACTS := 48
const CAMERA_TRACK_BASE_Y := 252.0
const CAMERA_TRACK_TOP_Y := 132.0
const CAMERA_TRACK_BOTTOM_Y := 304.0
const CAMERA_TRACK_X_SMOOTH_SPEED := 10.0
const CAMERA_TRACK_Y_SMOOTH_SPEED := 7.6
const CAMERA_EDGE_BIAS_DISTANCE := 44.0
const CAMERA_EDGE_BIAS_WEIGHT := 0.12
const CAMERA_HORIZONTAL_NEAR_DISTANCE := 72.0
const CAMERA_HORIZONTAL_FAR_DISTANCE := 360.0
const CAMERA_VERTICAL_NEAR_DISTANCE := 40.0
const CAMERA_VERTICAL_FAR_DISTANCE := 188.0
const CAMERA_VERTICAL_ZOOM_WEIGHT := 0.98
const CAMERA_VERTICAL_FOCUS_RANGE := 188.0
const CAMERA_ZOOM_NEAR := 1.08
const CAMERA_ZOOM_FAR := 0.90
const CAMERA_ZOOM_SMOOTH_SPEED := 8.2
const CAMERA_PUNCH_BY_TIER := {
	"light": {"duration": 0.080, "zoom": 0.020},
	"heavy": {"duration": 0.110, "zoom": 0.034},
	"special": {"duration": 0.130, "zoom": 0.042},
	"throw": {"duration": 0.095, "zoom": 0.026},
	"signature": {"duration": 0.145, "zoom": 0.050},
	"ultimate": {"duration": 0.170, "zoom": 0.060}
}
const CAMERA_PUNCH_BLOCK_SCALE := 0.64
const COUNTER_CAMERA_PUNCH_SCALE := 1.14
const ONBOARDING_ALLOWED_ENTRY_POINTS := ["guided_start", "training", "hud_replay"]
const TRAINING_DEFAULT_OPTIONS := {
	"enabled": true,
	"dummy_mode": "stand",
	"show_detail": false,
	"ruleset_profile": RULESET_DUEL,
	"drill_id": TRAINING_DRILL_DUEL_CORE,
	"throw_tech_assist_mode": "throw_only"
}
const IMPACT_ANIMATION_TEXTURE_PATHS := {
	"hit": [
		"res://assets/sprites/effects/counter_spark_0.png",
		"res://assets/sprites/effects/counter_spark_1.png",
		"res://assets/sprites/effects/counter_spark_2.png",
		"res://assets/sprites/effects/counter_spark_3.png"
	],
	"counter": [
		"res://assets/sprites/effects/counter_spark_0.png",
		"res://assets/sprites/effects/counter_spark_1.png",
		"res://assets/sprites/effects/counter_spark_2.png",
		"res://assets/sprites/effects/counter_spark_3.png"
	],
	"guard": [
		"res://assets/sprites/effects/guard_spark_0.png",
		"res://assets/sprites/effects/guard_spark_1.png",
		"res://assets/sprites/effects/guard_spark_2.png",
		"res://assets/sprites/effects/guard_spark_3.png"
	]
}
const IMPACT_ANIMATION_SPEEDS := {
	"hit": 20.0,
	"counter": 22.0,
	"guard": 20.0
}
const IMPACT_PLACEHOLDER_COLORS := {
	"hit": [
		Color(1.0, 0.98, 0.86, 0.98),
		Color(1.0, 0.88, 0.54, 0.92),
		Color(1.0, 0.76, 0.30, 0.84),
		Color(1.0, 0.64, 0.18, 0.70)
	],
	"counter": [
		Color(1.0, 0.95, 0.72, 0.96),
		Color(1.0, 0.88, 0.45, 0.90),
		Color(1.0, 0.78, 0.28, 0.82),
		Color(1.0, 0.70, 0.18, 0.68)
	],
	"guard": [
		Color(0.86, 0.98, 1.0, 0.96),
		Color(0.64, 0.90, 1.0, 0.90),
		Color(0.42, 0.78, 0.96, 0.82),
		Color(0.28, 0.62, 0.88, 0.68)
	]
}
const IMPACT_PLACEHOLDER_SIZE := Vector2i(32, 32)
const IMPACT_RING_TEXTURE_SIZE := Vector2i(96, 96)
const IMPACT_BLOOM_TEXTURE_SIZE := Vector2i(112, 112)
const SCREEN_FLASH_BY_TIER := {
	"light": {"duration": 0.080, "color": Color(1.0, 0.94, 0.82, 0.16)},
	"heavy": {"duration": 0.100, "color": Color(1.0, 0.84, 0.60, 0.24)},
	"special": {"duration": 0.115, "color": Color(1.0, 0.76, 0.48, 0.28)},
	"throw": {"duration": 0.075, "color": Color(0.92, 1.0, 0.86, 0.14)},
	"signature": {"duration": 0.130, "color": Color(1.0, 0.80, 0.42, 0.30)},
	"ultimate": {"duration": 0.150, "color": Color(1.0, 0.74, 0.30, 0.34)}
}
const BLOCK_FLASH_ALPHA_SCALE := 0.65
const COUNTER_FLASH_ALPHA_BONUS := 0.08
const IMPACT_TINT_BY_TIER := {
	"light": Color(1.0, 0.94, 0.78, 0.96),
	"heavy": Color(1.0, 0.82, 0.48, 0.98),
	"special": Color(1.0, 0.72, 0.32, 0.98),
	"throw": Color(0.92, 1.0, 0.84, 0.94),
	"signature": Color(1.0, 0.68, 0.26, 1.0),
	"ultimate": Color(1.0, 0.60, 0.18, 1.0)
}
const IMPACT_ACCENT_TINT_BY_ATTACK := {
	"special": Color(0.72, 0.90, 1.0, 1.0),
	"signature_a": Color(1.0, 0.72, 0.30, 1.0),
	"signature_b": Color(0.54, 0.94, 1.0, 1.0),
	"signature_c": Color(0.74, 1.0, 0.56, 1.0),
	"ultimate": Color(1.0, 0.84, 0.34, 1.0)
}
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
const MATCH_METRICS_LOG_PATH := "user://match_metrics.jsonl"
const MATCH_METRICS_SCHEMA_VERSION := 2
const ONBOARDING_STEPS := [
	{"id": "move", "key": "HUD_ONBOARDING_STEP_MOVE", "fallback": "Move left / right to continue."},
	{"id": "jump", "key": "HUD_ONBOARDING_STEP_JUMP", "fallback": "Jump once to continue."},
	{"id": "guard", "key": "HUD_ONBOARDING_STEP_GUARD", "fallback": "Hold guard once to continue."},
	{"id": "dodge", "key": "HUD_ONBOARDING_STEP_DODGE", "fallback": "Press Guard + Dash to dodge."},
	{"id": "attack", "key": "HUD_ONBOARDING_STEP_ATTACK", "fallback": "Use light or heavy attack once."},
	{"id": "throw", "key": "HUD_ONBOARDING_STEP_THROW", "fallback": "Use throw once."},
	{"id": "special", "key": "HUD_ONBOARDING_STEP_SPECIAL", "fallback": "Use special or ultimate once."}
]

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
var camera_punch_time := 0.0
var camera_punch_duration := 0.0
var camera_punch_amount := 0.0
var hitstop_active := false
var hitstop_end_msec := 0
var sfx_player_pool: Array[AudioStreamPlayer] = []
var sfx_player_pool_cursor := 0

@export var round_timer_enabled := true
@export_enum("hp_timer", "stock") var win_rule := WIN_RULE_HP_TIMER
@export_enum("duel", "platform") var ruleset_profile := RULESET_DUEL
@export_range(1, 7, 1) var stock_count := 3
@export var training_scene_enabled := false
@export var training_panel_enabled := false
@export var training_controls_enabled := false
@export_enum("stand", "force_block", "random_block") var training_dummy_default_mode := "stand"
@export var training_detail_default_visible := false
@export var round_tuning_enabled := false
@export_range(0, 5, 1) var round_tuning_max_picks_per_player := 2
@export_range(0, 3, 1) var round_tuning_leader_lock_stock_gap := 2
@export var round_tuning_force_ui_in_headless := false
@export var onboarding_enabled := true
@export_range(0.25, 2.50, 0.01) var camera_zoom_near := CAMERA_ZOOM_NEAR
@export_range(0.25, 2.50, 0.01) var camera_zoom_far := CAMERA_ZOOM_FAR
@export_range(0.25, 2.50, 0.01) var camera_zoom_min_limit := 0.82
@export_range(16.0, 640.0, 1.0) var camera_horizontal_near_distance := CAMERA_HORIZONTAL_NEAR_DISTANCE
@export_range(32.0, 960.0, 1.0) var camera_horizontal_far_distance := CAMERA_HORIZONTAL_FAR_DISTANCE
@export_range(16.0, 480.0, 1.0) var camera_vertical_near_distance := CAMERA_VERTICAL_NEAR_DISTANCE
@export_range(32.0, 640.0, 1.0) var camera_vertical_far_distance := CAMERA_VERTICAL_FAR_DISTANCE

@onready var player_1 := $Player1
@onready var player_2 := $Player2
@onready var hud := $Hud
@onready var arena_node := get_node_or_null("Arena")

var camera: Camera2D
var effects_layer: Node2D
var screen_fx_layer: CanvasLayer
var screen_flash: ColorRect
var impact_sprite_frames: SpriteFrames
var impact_additive_material: CanvasItemMaterial
var impact_ring_texture: Texture2D
var impact_bloom_texture: Texture2D
var screen_flash_color := Color(1.0, 1.0, 1.0, 0.0)
var screen_flash_time := 0.0
var screen_flash_duration := 0.0
var sfx_streams := {}
var walls_node: StaticBody2D
var training_options := TRAINING_DEFAULT_OPTIONS.duplicate(true)
var training_drill_state := {}
var training_drill_runtime := {}
var selected_character_ids := {"p1": "", "p2": ""}
var selected_character_names := {"p1": "Player 1", "p2": "Player 2"}
var selected_character_profiles := {"p1": {}, "p2": {}}
var selected_character_loadouts := {"p1": {}, "p2": {}}
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
var round_tuning_active := false
var round_tuning_pending_player_key := ""
var round_tuning_option_cache: Array[Dictionary] = []
var round_tuning_pending_queue: Array[String] = []
var round_tuning_pick_counts := {"p1": 0, "p2": 0}
var match_elapsed_seconds := 0.0
var onboarding_active := false
var onboarding_started := false
var onboarding_completed := false
var onboarding_skipped := false
var onboarding_forced_replay := false
var onboarding_step_index := 0
var onboarding_steps_completed := PackedStringArray()
var onboarding_completed_seconds := -1.0
var onboarding_entry_point := "match_start"
var telemetry_round_tuning_picks: Array[Dictionary] = []
var telemetry_item_activation_events: Array[Dictionary] = []
var telemetry_item_evolution_events: Array[Dictionary] = []
var telemetry_expected_item_evolution_count := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_clear_hitstop()
	camera_rng.randomize()
	dialogue_rng.randomize()
	_resolve_stage_bounds_from_scene()
	_apply_stage_bounds_to_players()
	if player_1:
		spawn_points["p1"] = _resolve_spawn_point_for_player(player_1)
	if player_2:
		spawn_points["p2"] = _resolve_spawn_point_for_player(player_2)
	_reset_stocks()
	_apply_ruleset_profile()
	training_options["enabled"] = training_scene_enabled
	training_options["dummy_mode"] = training_dummy_default_mode
	training_options["show_detail"] = training_detail_default_visible
	training_options["ruleset_profile"] = ruleset_profile
	training_options["drill_id"] = _resolve_default_training_drill_id(ruleset_profile)
	_setup_camera()
	_setup_walls()
	_setup_effects_layer()
	_setup_screen_fx_layer()
	_load_impact_sprite_frames()
	_load_sfx_streams()
	_setup_sfx_player_pool()
	_apply_selected_character_tables()
	_apply_session_match_mode()
	_reset_match_telemetry()
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
	if player_1 and player_1.has_signal("throw_whiffed"):
		player_1.throw_whiffed.connect(_on_throw_whiffed)
	if player_2 and player_2.has_signal("throw_whiffed"):
		player_2.throw_whiffed.connect(_on_throw_whiffed)
	if player_1 and player_1.has_signal("loadout_item_activated"):
		player_1.loadout_item_activated.connect(_on_player_loadout_item_activated)
	if player_2 and player_2.has_signal("loadout_item_activated"):
		player_2.loadout_item_activated.connect(_on_player_loadout_item_activated)
	if player_1 and player_1.has_signal("loadout_item_evolved"):
		player_1.loadout_item_evolved.connect(_on_player_loadout_item_evolved)
	if player_2 and player_2.has_signal("loadout_item_evolved"):
		player_2.loadout_item_evolved.connect(_on_player_loadout_item_evolved)

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
		if hud.has_signal("round_tuning_option_selected"):
			hud.round_tuning_option_selected.connect(_on_hud_round_tuning_option_selected)
		if hud.has_signal("onboarding_skip_requested"):
			hud.onboarding_skip_requested.connect(_on_hud_onboarding_skip_requested)
		if hud.has_signal("onboarding_replay_requested"):
			hud.onboarding_replay_requested.connect(_on_hud_onboarding_replay_requested)
		if hud.has_method("set_pause_visible"):
			hud.set_pause_visible(false)
		if hud.has_method("set_timer_visible"):
			hud.set_timer_visible(round_timer_enabled)
		if hud.has_method("set_training_panel_visible"):
			hud.set_training_panel_visible(training_panel_enabled)
		if hud.has_method("set_training_controls_visible"):
			hud.set_training_controls_visible(training_controls_enabled)
	
	_apply_training_options()
	_initialize_onboarding_flow()
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
	_update_screen_fx(delta)
	if get_tree().paused:
		return
	match_elapsed_seconds += maxf(0.0, delta)
	_update_onboarding_progress()
	if match_over:
		_update_story_round_transition(delta)
		return
	if _uses_stock_rule():
		_update_stock_ring_out_state()
		if match_over:
			_update_hud()
			_update_camera(delta)
			return
	elif _uses_training_platform_sandbox():
		_update_training_platform_ring_out_state()
	if _uses_training_sandbox():
		_update_training_drill_behaviors(delta)
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
	camera.enabled = true
	var starting_zoom := clampf(camera_zoom_near, camera_zoom_min_limit, maxf(camera_zoom_near, camera_zoom_far))
	camera.zoom = Vector2(starting_zoom, starting_zoom)
	camera.position_smoothing_enabled = false
	camera_track_x = (player_1.position.x + player_2.position.x) * 0.5 if player_1 and player_2 else (stage_left_x + stage_right_x) * 0.5
	camera_track_y = CAMERA_TRACK_BASE_Y
	_refresh_camera_limits()
	camera.position = Vector2(round(camera_track_x), round(camera_track_y))
	camera.make_current()
	_sync_arena_presentation()

func _setup_walls() -> void:
	_refresh_boundary_walls()

func _refresh_camera_limits() -> void:
	if camera == null:
		return
	if _uses_platform_ruleset():
		camera.limit_left = int(floor(blast_zone_left_x))
		camera.limit_right = int(ceil(blast_zone_right_x))
		camera.limit_bottom = int(ceil(BLAST_ZONE_BOTTOM_Y))
		camera.limit_top = int(floor(BLAST_ZONE_TOP_Y))
	else:
		camera.limit_left = int(floor(stage_left_x))
		camera.limit_right = int(ceil(stage_right_x))
		camera.limit_bottom = 500
		camera.limit_top = -200

func _refresh_boundary_walls() -> void:
	if walls_node != null and is_instance_valid(walls_node):
		remove_child(walls_node)
		walls_node.free()
		walls_node = null
	if _uses_platform_ruleset():
		return
	walls_node = StaticBody2D.new()
	walls_node.name = "BoundaryWalls"
	add_child(walls_node)
	
	var left_shape = CollisionShape2D.new()
	var left_rect = RectangleShape2D.new()
	left_rect.size = Vector2(40, 1000)
	left_shape.shape = left_rect
	left_shape.position = Vector2(stage_left_x - 20.0, 300)
	walls_node.add_child(left_shape)
	
	var right_shape = CollisionShape2D.new()
	var right_rect = RectangleShape2D.new()
	right_rect.size = Vector2(40, 1000)
	right_shape.shape = right_rect
	right_shape.position = Vector2(stage_right_x + 20.0, 300)
	walls_node.add_child(right_shape)

func _setup_effects_layer() -> void:
	effects_layer = Node2D.new()
	effects_layer.name = "Effects"
	add_child(effects_layer)
	if impact_additive_material == null:
		impact_additive_material = CanvasItemMaterial.new()
		impact_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	if impact_ring_texture == null:
		impact_ring_texture = _make_impact_ring_texture(IMPACT_RING_TEXTURE_SIZE)
	if impact_bloom_texture == null:
		impact_bloom_texture = _make_impact_bloom_texture(IMPACT_BLOOM_TEXTURE_SIZE)

func _setup_screen_fx_layer() -> void:
	screen_fx_layer = CanvasLayer.new()
	screen_fx_layer.name = "ScreenFx"
	screen_fx_layer.layer = 24
	add_child(screen_fx_layer)
	screen_flash = ColorRect.new()
	screen_flash.name = "Flash"
	screen_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen_flash.color = Color(1.0, 1.0, 1.0, 0.0)
	screen_flash.visible = false
	screen_fx_layer.add_child(screen_flash)

func _load_impact_sprite_frames() -> void:
	impact_sprite_frames = SpriteFrames.new()
	_add_impact_animation(&"hit")
	_add_impact_animation(&"counter")
	_add_impact_animation(&"guard")

func _add_impact_animation(animation_name: StringName) -> void:
	if impact_sprite_frames == null:
		return
	var animation_key := String(animation_name)
	var texture_paths: Array = IMPACT_ANIMATION_TEXTURE_PATHS.get(animation_key, [])
	var placeholder_colors: Array = IMPACT_PLACEHOLDER_COLORS.get(animation_key, [])
	if impact_sprite_frames.has_animation(animation_name):
		impact_sprite_frames.remove_animation(animation_name)
	impact_sprite_frames.add_animation(animation_name)
	impact_sprite_frames.set_animation_speed(
		animation_name,
		float(IMPACT_ANIMATION_SPEEDS.get(animation_key, 18.0))
	)
	impact_sprite_frames.set_animation_loop(animation_name, false)
	for frame_index in range(texture_paths.size()):
		var fill := Color(1.0, 1.0, 1.0, 0.9)
		if frame_index < placeholder_colors.size():
			fill = placeholder_colors[frame_index] as Color
		impact_sprite_frames.add_frame(
			animation_name,
			_load_impact_texture_or_placeholder(String(texture_paths[frame_index]), fill)
		)

func _load_impact_texture_or_placeholder(path: String, fill: Color) -> Texture2D:
	if not _is_headless_visual_runtime():
		var loaded = load(path)
		if loaded is Texture2D:
			return loaded as Texture2D
	return _make_impact_placeholder_texture(fill)

func _is_headless_visual_runtime() -> bool:
	return OS.has_feature("headless") or DisplayServer.get_name() == "headless"

func _make_impact_placeholder_texture(fill: Color) -> Texture2D:
	var image := Image.create(
		IMPACT_PLACEHOLDER_SIZE.x,
		IMPACT_PLACEHOLDER_SIZE.y,
		false,
		Image.FORMAT_RGBA8
	)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	for y in range(IMPACT_PLACEHOLDER_SIZE.y):
		for x in range(IMPACT_PLACEHOLDER_SIZE.x):
			var uv := Vector2(
				(float(x) + 0.5) / float(IMPACT_PLACEHOLDER_SIZE.x),
				(float(y) + 0.5) / float(IMPACT_PLACEHOLDER_SIZE.y)
			)
			var distance := uv.distance_to(Vector2(0.5, 0.5))
			if distance > 0.48:
				continue
			var strength := clampf((0.48 - distance) / 0.48, 0.0, 1.0)
			var pixel := fill
			pixel.a *= strength
			image.set_pixel(x, y, pixel)
	return ImageTexture.create_from_image(image)

func _make_impact_ring_texture(size: Vector2i) -> Texture2D:
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	for y in range(size.y):
		for x in range(size.x):
			var uv := Vector2(
				(float(x) + 0.5) / float(size.x),
				(float(y) + 0.5) / float(size.y)
			)
			var distance := uv.distance_to(Vector2(0.5, 0.5))
			if distance < 0.18 or distance > 0.48:
				continue
			var alpha := 1.0 - absf(distance - 0.33) / 0.15
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, clampf(alpha, 0.0, 1.0)))
	return ImageTexture.create_from_image(image)

func _make_impact_bloom_texture(size: Vector2i) -> Texture2D:
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	for y in range(size.y):
		for x in range(size.x):
			var uv := Vector2(
				(float(x) + 0.5) / float(size.x),
				(float(y) + 0.5) / float(size.y)
			)
			var distance := uv.distance_to(Vector2(0.5, 0.5))
			if distance > 0.50:
				continue
			var alpha := clampf((0.50 - distance) / 0.50, 0.0, 1.0)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return ImageTexture.create_from_image(image)

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
			(distance_x - camera_horizontal_near_distance) / maxf(1.0, camera_horizontal_far_distance - camera_horizontal_near_distance),
			0.0,
			1.0
		)
		var zoom_t_vertical: float = clampf(
			(distance_y - camera_vertical_near_distance) / maxf(1.0, camera_vertical_far_distance - camera_vertical_near_distance),
			0.0,
			1.0
		)
		var zoom_t: float = maxf(zoom_t_horizontal, zoom_t_vertical * CAMERA_VERTICAL_ZOOM_WEIGHT)
		var target_zoom: float = lerpf(camera_zoom_near, camera_zoom_far, zoom_t)
		if camera_punch_time > 0.0:
			camera_punch_time = maxf(0.0, camera_punch_time - delta)
			var punch_progress := camera_punch_time / maxf(0.001, camera_punch_duration)
			target_zoom -= sin(punch_progress * PI) * camera_punch_amount
		target_zoom = clampf(target_zoom, camera_zoom_min_limit, maxf(camera_zoom_near, camera_zoom_far))
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
		_sync_arena_presentation()

func _sync_arena_presentation() -> void:
	if arena_node == null or camera == null:
		return
	if arena_node.has_method("set_presentation_state"):
		arena_node.call("set_presentation_state", camera.position, camera.zoom.x, get_viewport_rect().size)

func _update_screen_fx(delta: float) -> void:
	if screen_flash == null:
		return
	if screen_flash_time <= 0.0:
		screen_flash.visible = false
		return
	screen_flash_time = maxf(0.0, screen_flash_time - delta)
	var progress := screen_flash_time / maxf(0.001, screen_flash_duration)
	var alpha := screen_flash_color.a * progress * progress
	screen_flash.color = Color(screen_flash_color.r, screen_flash_color.g, screen_flash_color.b, alpha)
	screen_flash.visible = alpha > 0.002

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
	_cancel_round_tuning_intermission()
	_clear_hitstop()
	get_tree().paused = false
	if hud and hud.has_method("set_pause_visible"):
		hud.set_pause_visible(false)
	_refresh_result_text()
	_append_match_metrics_log(result_key)
	_queue_story_progression(result_key)
	_trigger_victory_dialogue(result_key)

func _append_match_metrics_log(result_key: String) -> void:
	var p1_loadout := (selected_character_loadouts.get("p1", {}) as Dictionary).duplicate(true)
	var p2_loadout := (selected_character_loadouts.get("p2", {}) as Dictionary).duplicate(true)
	var evolution_success_count := telemetry_item_evolution_events.size()
	var evolution_expected_count := maxi(0, telemetry_expected_item_evolution_count)
	var evolution_success_rate := 0.0
	if evolution_expected_count > 0:
		evolution_success_rate = float(evolution_success_count) / float(evolution_expected_count)
	var record := {
		"schema_version": MATCH_METRICS_SCHEMA_VERSION,
		"timestamp_utc": Time.get_datetime_string_from_system(true),
		"match_mode": _resolve_active_match_mode(),
		"result": result_key,
		"match_elapsed_seconds": match_elapsed_seconds,
		"p1_character_id": str(selected_character_ids.get("p1", "")),
		"p2_character_id": str(selected_character_ids.get("p2", "")),
		"p1_loadout": p1_loadout,
		"p2_loadout": p2_loadout,
		"p1_loadout_signature": _build_loadout_signature("p1", p1_loadout),
		"p2_loadout_signature": _build_loadout_signature("p2", p2_loadout),
		"loadout_picks": _build_loadout_pick_entries(),
		"round_tuning_picks": telemetry_round_tuning_picks.duplicate(true),
		"item_activation_events": telemetry_item_activation_events.duplicate(true),
		"item_evolution_events": telemetry_item_evolution_events.duplicate(true),
		"item_evolution_expected_count": evolution_expected_count,
		"item_evolution_success_count": evolution_success_count,
		"item_evolution_success_rate": evolution_success_rate,
		"item_evolution_avg_trigger_time_seconds": _calc_average_evolution_trigger_seconds(),
		"onboarding": {
			"started": onboarding_started,
			"completed": onboarding_completed,
			"skipped": onboarding_skipped,
			"forced_replay": onboarding_forced_replay,
			"entry_point": onboarding_entry_point,
			"steps_completed": onboarding_steps_completed,
			"completed_at_seconds": onboarding_completed_seconds
		}
	}
	var line := JSON.stringify(record)
	if line == "":
		return
	var file := FileAccess.open(MATCH_METRICS_LOG_PATH, FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open(MATCH_METRICS_LOG_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.seek_end()
	file.store_string("%s\n" % line)

func _resolve_active_match_mode() -> String:
	if training_scene_enabled:
		return "training"
	if story_mode_active:
		return STORY_SCENE_MODE
	if SessionStateStore.has_value(SessionKeysStore.MATCH_MODE):
		return str(SessionStateStore.get_value(SessionKeysStore.MATCH_MODE, "vs")).to_lower()
	return "vs"

func _reset_match_telemetry() -> void:
	round_tuning_active = false
	round_tuning_pending_player_key = ""
	round_tuning_option_cache.clear()
	round_tuning_pending_queue.clear()
	round_tuning_pick_counts["p1"] = 0
	round_tuning_pick_counts["p2"] = 0
	match_elapsed_seconds = 0.0
	onboarding_active = false
	onboarding_started = false
	onboarding_completed = false
	onboarding_skipped = false
	onboarding_forced_replay = false
	onboarding_step_index = 0
	onboarding_steps_completed = PackedStringArray()
	onboarding_completed_seconds = -1.0
	onboarding_entry_point = "match_start"
	telemetry_round_tuning_picks.clear()
	telemetry_item_activation_events.clear()
	telemetry_item_evolution_events.clear()
	telemetry_expected_item_evolution_count = _count_expected_item_evolutions()

func _count_expected_item_evolutions() -> int:
	var expected := 0
	for player_key in ["p1", "p2"]:
		var character_id := str(selected_character_ids.get(player_key, "")).strip_edges()
		var loadout := (selected_character_loadouts.get(player_key, {}) as Dictionary).duplicate(true)
		var item_id := str(loadout.get("item", "")).strip_edges()
		if character_id == "" or item_id == "":
			continue
		var item_def := LoadoutCatalogStore.get_item_definition(character_id, item_id)
		if item_def.is_empty():
			continue
		var evolution_id := str(item_def.get("evolution_id", "")).strip_edges()
		if evolution_id != "":
			expected += 1
	return expected

func _build_loadout_signature(player_key: String, loadout: Dictionary) -> String:
	var character_id := str(selected_character_ids.get(player_key, "")).strip_edges()
	var signature_a := str(loadout.get("signature_a", "")).strip_edges()
	var signature_b := str(loadout.get("signature_b", "")).strip_edges()
	var ultimate := str(loadout.get("ultimate", "")).strip_edges()
	var item := str(loadout.get("item", "")).strip_edges()
	var passive := str(loadout.get("passive", "")).strip_edges()
	return "|".join([character_id, signature_a, signature_b, ultimate, item, passive])

func _build_loadout_pick_entries() -> Dictionary:
	var picks := {}
	for player_key in ["p1", "p2"]:
		var loadout := (selected_character_loadouts.get(player_key, {}) as Dictionary).duplicate(true)
		picks[player_key] = {
			"character_id": str(selected_character_ids.get(player_key, "")),
			"signature_a": str(loadout.get("signature_a", "")),
			"signature_b": str(loadout.get("signature_b", "")),
			"ultimate": str(loadout.get("ultimate", "")),
			"item": str(loadout.get("item", "")),
			"passive": str(loadout.get("passive", ""))
		}
	return picks

func _calc_average_evolution_trigger_seconds() -> float:
	if telemetry_item_evolution_events.is_empty():
		return -1.0
	var sum := 0.0
	for event in telemetry_item_evolution_events:
		sum += float(event.get("elapsed_seconds", 0.0))
	return sum / float(telemetry_item_evolution_events.size())

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
	_cancel_round_tuning_intermission()
	_clear_hitstop()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _toggle_pause() -> void:
	if round_tuning_active:
		return
	var is_paused = get_tree().paused
	get_tree().paused = not is_paused
	if hud and hud.has_method("set_pause_visible"):
		hud.set_pause_visible(get_tree().paused)

func _normalize_ruleset_profile(profile: String) -> String:
	var normalized := profile.strip_edges().to_lower()
	if normalized == RULESET_PLATFORM:
		return RULESET_PLATFORM
	return RULESET_DUEL

func _resolve_ruleset_for_training_drill(drill_id: String) -> String:
	return str(TRAINING_DRILL_RULESET_BY_ID.get(drill_id, RULESET_DUEL))

func _resolve_default_training_drill_id(profile: String) -> String:
	if _normalize_ruleset_profile(profile) == RULESET_PLATFORM:
		return TRAINING_DRILL_RECOVERY_ROUTE
	return TRAINING_DRILL_DUEL_CORE

func _normalize_training_drill_id(drill_id: String, profile: String = "") -> String:
	var normalized := drill_id.strip_edges().to_lower()
	if TRAINING_DRILL_IDS.has(normalized):
		return normalized
	return _resolve_default_training_drill_id(profile if profile != "" else ruleset_profile)

func _build_training_drill_state(drill_id: String, patch: Dictionary = {}) -> Dictionary:
	var resolved_drill_id := _normalize_training_drill_id(drill_id, str(patch.get("ruleset_profile", ruleset_profile)))
	var resolved_ruleset := _resolve_ruleset_for_training_drill(resolved_drill_id)
	var metrics_value: Variant = patch.get("metrics", {})
	var metrics := {}
	if typeof(metrics_value) == TYPE_DICTIONARY:
		metrics = (metrics_value as Dictionary).duplicate(true)
	var affected_players_value: Variant = patch.get("affected_players", [])
	var affected_players := PackedStringArray()
	if typeof(affected_players_value) == TYPE_ARRAY:
		for player_key_value in affected_players_value:
			var player_key := str(player_key_value).strip_edges()
			if player_key != "":
				affected_players.append(player_key)
	return {
		"drill_id": resolved_drill_id,
		"ruleset_profile": resolved_ruleset,
		"rep_index": maxi(0, int(patch.get("rep_index", 0))),
		"rep_status": str(
			patch.get(
				"rep_status",
				TRAINING_DRILL_STATUS_ACTIVE if bool(training_options.get("enabled", true)) else TRAINING_DRILL_STATUS_IDLE
			)
		),
		"last_result": str(patch.get("last_result", "")).strip_edges().to_lower(),
		"success_reason": str(patch.get("success_reason", "")).strip_edges().to_lower(),
		"fail_reason": str(patch.get("fail_reason", "")).strip_edges().to_lower(),
		"reset_reason": str(patch.get("reset_reason", "")).strip_edges().to_lower(),
		"reset_timer_seconds": maxf(0.0, float(patch.get("reset_timer_seconds", 0.0))),
		"affected_players": affected_players,
		"metrics": metrics
	}

func _sync_training_drill_state_to_hud() -> void:
	if hud and hud.has_method("set_training_drill_state"):
		hud.set_training_drill_state(training_drill_state)

func _refresh_training_drill_state(reset_result: bool = false) -> void:
	var enabled := bool(training_options.get("enabled", true))
	var drill_id := _normalize_training_drill_id(
		str(training_options.get("drill_id", "")),
		str(training_options.get("ruleset_profile", ruleset_profile))
	)
	var ruleset := _resolve_ruleset_for_training_drill(drill_id)
	training_options["drill_id"] = drill_id
	training_options["ruleset_profile"] = ruleset
	var current := training_drill_state if typeof(training_drill_state) == TYPE_DICTIONARY else {}
	var drill_changed := str(current.get("drill_id", "")) != drill_id
	var next_state := _build_training_drill_state(
		drill_id,
		{
			"ruleset_profile": ruleset,
			"rep_index": 0 if drill_changed else int(current.get("rep_index", 0)),
			"rep_status": TRAINING_DRILL_STATUS_ACTIVE if enabled else TRAINING_DRILL_STATUS_IDLE,
			"last_result": "" if (drill_changed or reset_result) else str(current.get("last_result", "")),
			"success_reason": "" if (drill_changed or reset_result) else str(current.get("success_reason", "")),
			"fail_reason": "" if (drill_changed or reset_result) else str(current.get("fail_reason", "")),
			"reset_reason": "" if (drill_changed or reset_result) else str(current.get("reset_reason", "")),
			"reset_timer_seconds": 0.0 if (drill_changed or reset_result) else float(current.get("reset_timer_seconds", 0.0)),
			"affected_players": [] if (drill_changed or reset_result) else current.get("affected_players", []),
			"metrics": {} if (drill_changed or reset_result) else current.get("metrics", {})
		}
	)
	training_drill_state = next_state
	_sync_training_drill_state_to_hud()

func _record_training_drill_rep_result(result: String, reason: String, affected_players: Array[String], metrics: Dictionary = {}) -> void:
	if not bool(training_options.get("enabled", true)):
		return
	var current := training_drill_state if typeof(training_drill_state) == TYPE_DICTIONARY else {}
	var rep_index := int(current.get("rep_index", 0)) + 1
	var normalized_result := str(result).strip_edges().to_lower()
	var normalized_reason := str(reason).strip_edges().to_lower()
	var patch := {
		"rep_index": rep_index,
		"rep_status": TRAINING_DRILL_STATUS_ACTIVE,
		"last_result": normalized_result,
		"success_reason": normalized_reason if normalized_result == "success" else "",
		"fail_reason": normalized_reason if normalized_result == "fail" else "",
		"reset_reason": normalized_reason if normalized_result not in ["success", "fail"] else "",
		"affected_players": affected_players,
		"metrics": metrics
	}
	training_drill_state = _build_training_drill_state(
		str(current.get("drill_id", training_options.get("drill_id", TRAINING_DRILL_DUEL_CORE))),
		patch
	)
	_sync_training_drill_state_to_hud()

func _reset_training_drill_runtime(drill_id: String) -> void:
	training_drill_runtime = {
		"drill_id": drill_id,
		"elapsed_seconds": 0.0,
		"launch_attempted": false,
		"launch_triggered": false,
		"launch_delay_seconds": TRAINING_DRILL_DI_LAUNCH_DELAY_SECONDS,
		"success_armed": false
	}

func _apply_training_patch_to_player(player_key: String, patch: Dictionary) -> void:
	var fighter := _get_player_by_key(player_key)
	if fighter == null:
		return
	if fighter.has_method("apply_training_state_patch"):
		fighter.call("apply_training_state_patch", patch)

func _prepare_training_drill_rep(player_keys: Array[String]) -> void:
	if not training_scene_enabled or not bool(training_options.get("enabled", true)):
		training_drill_runtime.clear()
		return
	var drill_id := str(training_options.get("drill_id", TRAINING_DRILL_DUEL_CORE))
	_reset_training_drill_runtime(drill_id)
	match drill_id:
		TRAINING_DRILL_RECOVERY_ROUTE:
			_setup_recovery_route_drill(player_keys)
		TRAINING_DRILL_LEDGE_ESCAPE:
			_setup_ledge_escape_drill(player_keys)
		TRAINING_DRILL_DI_SURVIVAL:
			_setup_di_survival_drill(player_keys)
		_:
			training_drill_runtime.clear()

func _setup_recovery_route_drill(_player_keys: Array[String]) -> void:
	_apply_training_patch_to_player(
		"p1",
		{
			"position": Vector2(stage_right_x, stage_floor_y) + TRAINING_DRILL_RECOVERY_START_OFFSET,
			"velocity": TRAINING_DRILL_RECOVERY_START_VELOCITY,
			"facing": -1,
			"air_jumps": 1,
			"air_dodge_ready": true,
			"current_hp": 100
		}
	)
	_apply_training_patch_to_player(
		"p2",
		{
			"position": Vector2(stage_right_x - 108.0, stage_floor_y),
			"velocity": Vector2.ZERO,
			"facing": 1,
			"current_hp": 100
		}
	)
	training_drill_runtime["entry_side"] = "right"

func _setup_ledge_escape_drill(_player_keys: Array[String]) -> void:
	_apply_training_patch_to_player(
		"p1",
		{
			"position": Vector2(stage_right_x - 12.0, stage_floor_y - 18.0),
			"velocity": Vector2.ZERO,
			"facing": -1,
			"air_jumps": 1,
			"air_dodge_ready": true,
			"current_hp": 100,
			"ledge_hang_side": 1
		}
	)
	_apply_training_patch_to_player(
		"p2",
		{
			"position": Vector2(stage_right_x - TRAINING_DRILL_LEDGE_DUMMY_OFFSET_X, stage_floor_y),
			"velocity": Vector2.ZERO,
			"facing": 1,
			"current_hp": 100
		}
	)
	training_drill_runtime["entry_side"] = "right"

func _setup_di_survival_drill(_player_keys: Array[String]) -> void:
	_apply_training_patch_to_player(
		"p1",
		{
			"position": Vector2(stage_right_x - 126.0, stage_floor_y),
			"velocity": Vector2.ZERO,
			"facing": 1,
			"air_jumps": 1,
			"air_dodge_ready": true,
			"current_hp": TRAINING_DRILL_DI_PLAYER_HP
		}
	)
	_apply_training_patch_to_player(
		"p2",
		{
			"position": Vector2(stage_right_x - 210.0, stage_floor_y),
			"velocity": Vector2.ZERO,
			"facing": 1,
			"current_hp": 100
		}
	)

func _complete_training_drill_rep(reason: String, metrics: Dictionary = {}) -> void:
	_reset_training_sandbox_players(["p1", "p2"], "success", reason, metrics)

func _update_training_drill_behaviors(delta: float) -> void:
	if not bool(training_options.get("enabled", true)):
		if not training_drill_runtime.is_empty():
			training_drill_runtime.clear()
		return
	var drill_id := str(training_options.get("drill_id", TRAINING_DRILL_DUEL_CORE))
	if drill_id == TRAINING_DRILL_DUEL_CORE:
		return
	if training_drill_runtime.is_empty() or str(training_drill_runtime.get("drill_id", "")) != drill_id:
		_prepare_training_drill_rep(["p1", "p2"])
	if training_drill_runtime.is_empty():
		return
	training_drill_runtime["elapsed_seconds"] = float(training_drill_runtime.get("elapsed_seconds", 0.0)) + maxf(0.0, delta)
	match drill_id:
		TRAINING_DRILL_RECOVERY_ROUTE:
			_update_recovery_route_drill()
		TRAINING_DRILL_LEDGE_ESCAPE:
			_update_ledge_escape_drill()
		TRAINING_DRILL_DI_SURVIVAL:
			_update_di_survival_drill()

func _update_recovery_route_drill() -> void:
	if player_1 == null:
		return
	if bool(player_1.get("is_ledge_hanging")):
		_complete_training_drill_rep("ledge_recovery", {"finish_state": "ledge"})
		return
	if player_1.is_on_floor() and player_1.global_position.x <= stage_right_x - 24.0:
		_complete_training_drill_rep("stage_recovery", {"finish_state": "stage"})

func _update_ledge_escape_drill() -> void:
	if player_1 == null:
		return
	var was_hanging := bool(training_drill_runtime.get("success_armed", false))
	if bool(player_1.get("is_ledge_hanging")):
		training_drill_runtime["success_armed"] = true
		return
	if not was_hanging:
		return
	if player_1.is_on_floor() and player_1.global_position.x <= stage_right_x - 34.0:
		_complete_training_drill_rep(
			"stage_reclaim",
			{
				"finish_state": "stage",
				"dodge_state": str(player_1.get("dodge_state")),
				"attack_state": str(player_1.get("attack_state"))
			}
		)

func _update_di_survival_drill() -> void:
	if player_1 == null:
		return
	var launch_triggered := bool(training_drill_runtime.get("launch_triggered", false))
	if not launch_triggered:
		var launch_delay := float(training_drill_runtime.get("launch_delay_seconds", TRAINING_DRILL_DI_LAUNCH_DELAY_SECONDS))
		if float(training_drill_runtime.get("elapsed_seconds", 0.0)) < launch_delay:
			return
		_trigger_di_survival_launch()
		return
	if not bool(training_drill_runtime.get("success_armed", false)):
		return
	if bool(player_1.get("is_ledge_hanging")):
		_complete_training_drill_rep("survived_launch", {"finish_state": "ledge"})
		return
	if player_1.is_on_floor() and float(player_1.get("hitstun_time")) <= 0.0:
		_complete_training_drill_rep("survived_launch", {"finish_state": "ground"})

func _trigger_di_survival_launch() -> void:
	if player_1 == null:
		return
	if bool(training_drill_runtime.get("launch_attempted", false)):
		return
	training_drill_runtime["launch_attempted"] = true
	var launch_result_value: Variant = player_1.call(
		"apply_damage",
		TRAINING_DRILL_DI_DAMAGE,
		TRAINING_DRILL_DI_KNOCKBACK,
		0.22,
		"heavy",
		{}
	)
	var launch_result := {}
	if typeof(launch_result_value) == TYPE_DICTIONARY:
		launch_result = (launch_result_value as Dictionary).duplicate(true)
	var blocked := bool(launch_result.get("blocked", false))
	var ignored := bool(launch_result.get("ignored", false))
	if blocked or ignored:
		_reset_training_sandbox_players(
			["p1", "p2"],
			"fail",
			"launch_denied",
			{
				"launch_blocked": blocked,
				"launch_ignored": ignored,
				"guard_mode": str(launch_result.get("guard_mode", "none")),
				"ruleset_profile": ruleset_profile
			}
		)
		return
	training_drill_runtime["launch_triggered"] = true
	training_drill_runtime["success_armed"] = true

func _normalize_throw_tech_assist_mode(mode: String) -> String:
	var normalized := str(mode).strip_edges().to_lower()
	if normalized in ["off", "button_assist"]:
		return normalized
	return "throw_only"

func _uses_platform_ruleset() -> bool:
	return ruleset_profile == RULESET_PLATFORM

func _uses_training_sandbox() -> bool:
	return training_scene_enabled

func _uses_training_platform_sandbox() -> bool:
	return _uses_training_sandbox() and _uses_platform_ruleset() and not _uses_stock_rule()

func _uses_stock_rule() -> bool:
	return win_rule == WIN_RULE_STOCK

func _apply_ruleset_profile() -> void:
	ruleset_profile = _normalize_ruleset_profile(ruleset_profile)
	training_options["ruleset_profile"] = ruleset_profile
	var side_platforms_enabled := _uses_platform_ruleset()
	if arena_node:
		if arena_node.has_method("set_side_platforms_enabled"):
			arena_node.call("set_side_platforms_enabled", side_platforms_enabled)
		else:
			arena_node.set("side_platforms_enabled", side_platforms_enabled)
	for fighter in [player_1, player_2]:
		if fighter != null and fighter.has_method("set_ruleset_profile"):
			fighter.call("set_ruleset_profile", ruleset_profile)
	_refresh_camera_limits()
	_refresh_boundary_walls()
	if hud and hud.has_method("set_training_options"):
		hud.set_training_options(training_options)

func _reset_stocks() -> void:
	var initial := maxi(1, stock_count)
	stocks["p1"] = initial
	stocks["p2"] = initial

func _update_training_platform_ring_out_state() -> void:
	var reset_keys: Array[String] = []
	if player_1 and _is_outside_blast_zone(player_1.global_position):
		reset_keys.append("p1")
	if player_2 and _is_outside_blast_zone(player_2.global_position):
		reset_keys.append("p2")
	if reset_keys.is_empty():
		return
	_reset_training_sandbox_players(
		["p1", "p2"],
		"fail",
		"ring_out",
		{"ring_out_count": reset_keys.size(), "ruleset_profile": ruleset_profile}
	)

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

func _resolve_spawn_point_for_player(fighter: CharacterBody2D) -> Vector2:
	if fighter == null:
		return Vector2.ZERO
	var spawn := fighter.global_position
	var shape_node := fighter.get_node_or_null("CollisionShape2D")
	if shape_node is CollisionShape2D:
		var collision_shape := shape_node as CollisionShape2D
		var rect_shape := collision_shape.shape as RectangleShape2D
		if rect_shape != null:
			var half_height := rect_shape.size.y * 0.5 * absf(collision_shape.global_scale.y)
			spawn.y = stage_floor_y - half_height
	return spawn

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
	var player_keys: Array[String] = [player_key]
	_queue_round_tuning_intermissions(player_keys)

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
	var shared_player_key := _resolve_shared_round_tuning_player_key(["p1", "p2"])
	if shared_player_key != "":
		var shared_keys: Array[String] = [shared_player_key]
		_queue_round_tuning_intermissions(shared_keys)

func _resolve_shared_round_tuning_player_key(player_keys: Array[String]) -> String:
	var selected_key := ""
	var selected_pick_count := 9999
	for player_key_value in player_keys:
		var player_key := str(player_key_value).strip_edges()
		if player_key == "":
			continue
		if not _can_player_receive_round_tuning_pick(player_key):
			continue
		var options := _resolve_player_round_tuning_options(player_key)
		if options.is_empty():
			continue
		var pick_count := int(round_tuning_pick_counts.get(player_key, 0))
		if selected_key == "" or pick_count < selected_pick_count:
			selected_key = player_key
			selected_pick_count = pick_count
	return selected_key

func _queue_round_tuning_intermissions(player_keys: Array[String]) -> void:
	if player_keys.is_empty():
		return
	for player_key_value in player_keys:
		var player_key := str(player_key_value).strip_edges()
		if player_key == "":
			continue
		if round_tuning_pending_queue.has(player_key):
			continue
		round_tuning_pending_queue.append(player_key)
	_maybe_start_next_round_tuning_intermission()

func _maybe_start_next_round_tuning_intermission() -> void:
	if round_tuning_active:
		return
	if match_over:
		round_tuning_pending_queue.clear()
		return
	while not round_tuning_pending_queue.is_empty():
		var player_key := str(round_tuning_pending_queue.pop_front()).strip_edges()
		if player_key == "":
			continue
		var started := _maybe_start_round_tuning_intermission(player_key)
		if started and round_tuning_active:
			return

func _maybe_start_round_tuning_intermission(player_key: String) -> bool:
	if not round_tuning_enabled:
		return false
	if not _uses_stock_rule():
		return false
	if match_over:
		return false
	if round_tuning_active:
		return false
	if not _can_player_receive_round_tuning_pick(player_key):
		return false
	var options := _resolve_player_round_tuning_options(player_key)
	if options.is_empty():
		return false
	round_tuning_pending_player_key = player_key
	round_tuning_option_cache.clear()
	for option in options:
		round_tuning_option_cache.append(option.duplicate(true))
	var should_force_pick := OS.has_feature("headless") and not round_tuning_force_ui_in_headless
	if hud == null or not hud.has_method("show_round_tuning_options"):
		should_force_pick = true
	if should_force_pick:
		var option_id := str(round_tuning_option_cache[0].get("id", "")).strip_edges()
		if option_id != "":
			_record_round_tuning_pick(player_key, option_id)
			_apply_round_tuning_option_to_player(player_key, option_id)
		round_tuning_pending_player_key = ""
		round_tuning_option_cache.clear()
		_update_hud()
		return true
	round_tuning_active = true
	get_tree().paused = true
	if hud.has_method("set_pause_visible"):
		hud.set_pause_visible(false)
	hud.show_round_tuning_options(round_tuning_option_cache)
	return true

func _can_player_receive_round_tuning_pick(player_key: String) -> bool:
	var cap := maxi(0, round_tuning_max_picks_per_player)
	if cap <= 0:
		return false
	var lock_gap := maxi(0, round_tuning_leader_lock_stock_gap)
	if lock_gap > 0 and _uses_stock_rule():
		var self_stock := int(stocks.get(player_key, 0))
		var other_key := "p2" if player_key == "p1" else "p1"
		var other_stock := int(stocks.get(other_key, 0))
		if self_stock - other_stock >= lock_gap:
			return false
	return int(round_tuning_pick_counts.get(player_key, 0)) < cap

func _resolve_player_round_tuning_options(player_key: String) -> Array[Dictionary]:
	var fighter := _get_player_by_key(player_key)
	var options: Array[Dictionary] = []
	if fighter == null:
		return options
	if not fighter.has_method("get_round_tuning_options"):
		return options
	var options_value: Variant = fighter.call("get_round_tuning_options")
	if typeof(options_value) != TYPE_ARRAY:
		return options
	for option_variant in options_value:
		if typeof(option_variant) != TYPE_DICTIONARY:
			continue
		var option := (option_variant as Dictionary).duplicate(true)
		var option_id := str(option.get("id", "")).strip_edges()
		if option_id == "":
			continue
		options.append(option)
		if options.size() >= 2:
			break
	return options

func _apply_round_tuning_option_to_player(player_key: String, option_id: String) -> bool:
	var fighter := _get_player_by_key(player_key)
	if fighter == null:
		return false
	if not fighter.has_method("apply_round_tuning_option"):
		return false
	fighter.call("apply_round_tuning_option", option_id)
	return true

func _cancel_round_tuning_intermission() -> void:
	round_tuning_active = false
	round_tuning_pending_player_key = ""
	round_tuning_option_cache.clear()
	if hud and hud.has_method("hide_round_tuning_options"):
		hud.hide_round_tuning_options()

func _record_round_tuning_pick(player_key: String, option_id: String) -> void:
	var current_count := int(round_tuning_pick_counts.get(player_key, 0))
	round_tuning_pick_counts[player_key] = current_count + 1
	telemetry_round_tuning_picks.append(
		{
			"player_key": player_key,
			"option_id": option_id,
			"elapsed_seconds": match_elapsed_seconds
		}
	)

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

func _reset_training_sandbox_players(
	player_keys: Array[String],
	result: String = "",
	reason: String = "",
	metrics: Dictionary = {}
) -> void:
	var seen := {}
	var normalized_keys: Array[String] = []
	for player_key_value in player_keys:
		var player_key := str(player_key_value).strip_edges()
		if player_key == "" or seen.has(player_key):
			continue
		seen[player_key] = true
		normalized_keys.append(player_key)
	var respawn_keys: Array[String] = []
	for player_key in normalized_keys:
		respawn_keys.append(player_key)
	if str(training_options.get("drill_id", TRAINING_DRILL_DUEL_CORE)) != TRAINING_DRILL_DUEL_CORE:
		respawn_keys.clear()
		respawn_keys.append("p1")
		respawn_keys.append("p2")
	for player_key in respawn_keys:
		_respawn_player_by_key(player_key)
	if result != "" or reason != "":
		_record_training_drill_rep_result(result, reason, respawn_keys, metrics)
	_prepare_training_drill_rep(respawn_keys)

func _get_player_by_key(player_key: String) -> CharacterBody2D:
	if player_key == "p1":
		return player_1
	if player_key == "p2":
		return player_2
	return null

func _initialize_onboarding_flow() -> void:
	onboarding_active = false
	onboarding_started = false
	onboarding_completed = false
	onboarding_skipped = false
	onboarding_step_index = 0
	onboarding_steps_completed = PackedStringArray()
	onboarding_completed_seconds = -1.0
	onboarding_forced_replay = false
	onboarding_entry_point = "match_start"
	if not onboarding_enabled:
		_refresh_onboarding_hud()
		return
	if SessionStateStore.has_value(SessionKeysStore.ONBOARDING_ENTRY_POINT):
		onboarding_entry_point = str(SessionStateStore.get_value(SessionKeysStore.ONBOARDING_ENTRY_POINT, "match_start"))
	var force_replay := false
	if SessionStateStore.has_value(SessionKeysStore.ONBOARDING_FORCE_REPLAY):
		force_replay = bool(SessionStateStore.get_value(SessionKeysStore.ONBOARDING_FORCE_REPLAY, false))
	onboarding_forced_replay = force_replay
	SessionStateStore.clear_keys(
		PackedStringArray([
			SessionKeysStore.ONBOARDING_FORCE_REPLAY,
			SessionKeysStore.ONBOARDING_ENTRY_POINT
		])
	)
	var onboarding_settings := GameSettingsStore.get_onboarding_settings()
	var hints_enabled := bool(onboarding_settings.get("hints_enabled", true))
	var already_completed := bool(onboarding_settings.get("completed", false))
	var entry_supports_onboarding := training_scene_enabled or onboarding_entry_point in ONBOARDING_ALLOWED_ENTRY_POINTS
	if not entry_supports_onboarding:
		_refresh_onboarding_hud()
		return
	if not force_replay and (not hints_enabled or already_completed):
		_refresh_onboarding_hud()
		return
	_start_onboarding_sequence()

func _start_onboarding_sequence() -> void:
	onboarding_active = true
	onboarding_started = true
	onboarding_completed = false
	onboarding_skipped = false
	onboarding_step_index = 0
	onboarding_steps_completed = PackedStringArray()
	onboarding_completed_seconds = -1.0
	_refresh_onboarding_hud()

func _update_onboarding_progress() -> void:
	if not onboarding_active:
		return
	if onboarding_step_index < 0 or onboarding_step_index >= ONBOARDING_STEPS.size():
		_complete_onboarding(false)
		return
	var step := ONBOARDING_STEPS[onboarding_step_index] as Dictionary
	var step_id := str(step.get("id", "")).strip_edges()
	if step_id == "":
		onboarding_step_index += 1
		_refresh_onboarding_hud()
		return
	if not _is_onboarding_step_completed(step_id):
		return
	onboarding_steps_completed.append(step_id)
	onboarding_step_index += 1
	if onboarding_step_index >= ONBOARDING_STEPS.size():
		_complete_onboarding(false)
		return
	_refresh_onboarding_hud()

func _get_active_control_preset() -> String:
	var preset_value := str(Engine.get_meta(GameSettingsStore.ENGINE_META_KEY, ""))
	if preset_value == "":
		preset_value = GameSettingsStore.get_control_preset()
	return GameSettingsStore.normalize_control_preset(preset_value)

func _resolve_onboarding_step_copy(step_id: String, default_key: String, default_fallback: String) -> Dictionary:
	if step_id == "guard" and _get_active_control_preset() == GameSettingsStore.CONTROL_PRESET_CLASSIC:
		return {
			"key": "HUD_ONBOARDING_STEP_GUARD_CLASSIC",
			"fallback": "Hold back once to guard."
		}
	if step_id == "dodge" and _get_active_control_preset() == GameSettingsStore.CONTROL_PRESET_CLASSIC:
		return {
			"key": "HUD_ONBOARDING_STEP_DODGE_CLASSIC",
			"fallback": "Hold back, then press Dash to dodge."
		}
	return {
		"key": default_key,
		"fallback": default_fallback
	}

func _resolve_onboarding_step_text(step: Dictionary) -> String:
	var step_id := str(step.get("id", "")).strip_edges()
	var default_key := str(step.get("key", "")).strip_edges()
	var default_fallback := str(step.get("fallback", "Follow the prompt to continue."))
	var copy := _resolve_onboarding_step_copy(step_id, default_key, default_fallback)
	return _tr_or_fallback(
		str(copy.get("key", default_key)).strip_edges(),
		str(copy.get("fallback", default_fallback))
	)

func _is_onboarding_step_completed(step_id: String) -> bool:
	if player_1 == null:
		return false
	var attack_state := str(player_1.attack_state)
	match step_id:
		"move":
			return absf(player_1.velocity.x) >= 24.0
		"jump":
			return not player_1.is_on_floor() and player_1.velocity.y <= -24.0
		"guard":
			return bool(player_1.is_blocking)
		"dodge":
			return str(player_1.dodge_state) != "" or float(player_1.dodge_time) > 0.0
		"attack":
			return (
				attack_state.begins_with("light")
				or attack_state.begins_with("heavy")
			)
		"throw":
			return attack_state == "throw"
		"special":
			return (
				attack_state == "special"
				or attack_state == "ultimate"
				or attack_state.begins_with("signature_")
			)
	return false

func _complete_onboarding(skipped: bool) -> void:
	onboarding_active = false
	onboarding_completed = true
	onboarding_skipped = skipped
	onboarding_completed_seconds = match_elapsed_seconds
	GameSettingsStore.set_onboarding_completed(true)
	_refresh_onboarding_hud()

func _refresh_onboarding_hud() -> void:
	if hud == null or not hud.has_method("set_onboarding_state"):
		return
	if not onboarding_active:
		hud.set_onboarding_state(false, "", "", "", false, false)
		return
	var step := ONBOARDING_STEPS[onboarding_step_index] as Dictionary
	var step_text := _resolve_onboarding_step_text(step)
	var progress_template := _tr_or_fallback("HUD_ONBOARDING_PROGRESS", "Step %d/%d")
	var progress_text := ""
	if progress_template.find("%") == -1:
		progress_text = "Step %d/%d" % [onboarding_step_index + 1, ONBOARDING_STEPS.size()]
	else:
		progress_text = progress_template % [onboarding_step_index + 1, ONBOARDING_STEPS.size()]
	var title_text := _tr_or_fallback("HUD_ONBOARDING_TITLE", "Quick Onboarding")
	hud.set_onboarding_state(true, title_text, step_text, progress_text, true, true)

func _on_player_health_changed() -> void:
	_update_hud()

func _on_player_defeated(loser_key: String) -> void:
	if match_over:
		return
	if _uses_training_sandbox():
		var p1_defeated: bool = player_1 != null and int(player_1.current_hp) <= 0
		var p2_defeated: bool = player_2 != null and int(player_2.current_hp) <= 0
		if not p1_defeated and not p2_defeated:
			return
		if p1_defeated and p2_defeated and loser_key != "p1":
			return
		var reset_keys: Array[String] = []
		if p1_defeated:
			reset_keys.append("p1")
		if p2_defeated:
			reset_keys.append("p2")
		_reset_training_sandbox_players(
			reset_keys,
			"reset",
			"ko",
			{"defeated_count": reset_keys.size(), "ruleset_profile": ruleset_profile}
		)
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
	_start_camera_punch(_kind, false, _is_counter)
	_trigger_screen_flash(_kind, false, _is_counter)
	if _is_counter:
		_play_sfx_key("counter")
		_show_combat_callout("HUD_CALLOUT_COUNTER", Color(1.0, 0.90, 0.54, 1.0))
	elif _combo_count >= 2:
		_play_sfx_key("combo", -8.5, 1.0 + minf(0.15, float(_combo_count - 2) * 0.03))
		_show_combo_callout(_combo_count)
	if _target is Node2D:
		var hit_position := (_target as Node2D).global_position + Vector2(0, -24)
		if _is_counter:
			_spawn_counter_spark(hit_position, _kind)
		else:
			_spawn_hit_spark(hit_position, _kind)
	var training_info := _push_training_info(_attacker)
	_show_hit_type_feedback(training_info, false)

func _on_block_landed(_attacker, target, _kind) -> void:
	var blockstop := _resolve_blockstop_duration(_kind)
	_apply_hitstop(blockstop)
	_play_attack_sfx("block", _kind)
	_start_camera_shake(_kind, true)
	_start_camera_punch(_kind, true)
	_trigger_screen_flash(_kind, true)
	_show_combat_callout("HUD_CALLOUT_GUARD", Color(0.74, 0.92, 1.0, 1.0))
	if target is Node2D:
		_spawn_guard_spark((target as Node2D).global_position + Vector2(0, -26), _kind)
	var training_info := _push_training_info(_attacker)
	_show_hit_type_feedback(training_info, true)

func _on_throw_teched(attacker, target) -> void:
	_apply_hitstop(0.035)
	_play_sfx_key("tech", -8.5, 1.08)
	_start_camera_shake("light", true)
	_start_camera_punch("light", true)
	_trigger_screen_flash("light", true)
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

func _on_throw_whiffed(attacker) -> void:
	if bool(training_options.get("enabled", true)):
		_show_combat_callout("HUD_CALLOUT_WHIFF", Color(1.0, 0.86, 0.68, 1.0))
	_push_training_info(attacker)

func _on_tech_recovered(fighter, tech_kind: String) -> void:
	_show_combat_callout("HUD_CALLOUT_TECH", Color(0.78, 1.0, 0.80, 1.0))
	_play_sfx_key("tech", -10.0, 1.0 if tech_kind == "quick" else 0.92)
	_start_camera_shake("light", true)
	_start_camera_punch("light", true)
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
	_cancel_round_tuning_intermission()
	round_tuning_pending_queue.clear()
	_clear_hitstop()
	if story_mode_active:
		SessionStateStore.clear_keys(PackedStringArray([SessionKeysStore.STORY_ROUND_INDEX]))
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE_PATH)

func _on_locale_changed(_locale: String) -> void:
	_update_hud()
	_refresh_result_text()
	_refresh_onboarding_hud()
	if hud and hud.has_method("set_training_options"):
		hud.set_training_options(training_options)

func _on_hud_round_tuning_option_selected(option_id: String) -> void:
	if not round_tuning_active:
		return
	var selected_option_id := option_id.strip_edges()
	if selected_option_id == "":
		return
	var option_exists := false
	for option in round_tuning_option_cache:
		if str(option.get("id", "")) == selected_option_id:
			option_exists = true
			break
	if not option_exists:
		return
	var player_key := round_tuning_pending_player_key
	if player_key != "":
		_record_round_tuning_pick(player_key, selected_option_id)
		_apply_round_tuning_option_to_player(player_key, selected_option_id)
	_cancel_round_tuning_intermission()
	get_tree().paused = false
	if hud and hud.has_method("set_pause_visible"):
		hud.set_pause_visible(false)
	_update_hud()
	_maybe_start_next_round_tuning_intermission()

func _on_hud_onboarding_skip_requested() -> void:
	if not onboarding_active:
		return
	_complete_onboarding(true)

func _on_hud_onboarding_replay_requested() -> void:
	if not onboarding_enabled:
		return
	onboarding_forced_replay = true
	onboarding_entry_point = "hud_replay"
	_start_onboarding_sequence()

func _on_player_loadout_item_activated(
	fighter: Node,
	item_id: String,
	activation_count: int,
	elapsed_seconds: float
) -> void:
	var player_key := _resolve_player_key_for_node(fighter)
	if player_key == "":
		return
	telemetry_item_activation_events.append(
		{
			"player_key": player_key,
			"item_id": item_id,
			"activation_count": activation_count,
			"elapsed_seconds": elapsed_seconds
		}
	)
	var item_name := _resolve_item_callout_name(fighter, item_id)
	if item_name != "" and hud and hud.has_method("show_combat_callout_text"):
		hud.show_combat_callout_text("%s x%d" % [item_name, activation_count], Color(0.86, 0.98, 1.0, 1.0))

func _on_player_loadout_item_evolved(
	fighter: Node,
	from_item_id: String,
	to_item_id: String,
	activation_count: int,
	elapsed_seconds: float
) -> void:
	var player_key := _resolve_player_key_for_node(fighter)
	if player_key == "":
		return
	telemetry_item_evolution_events.append(
		{
			"player_key": player_key,
			"from_item_id": from_item_id,
			"to_item_id": to_item_id,
			"activation_count": activation_count,
			"elapsed_seconds": elapsed_seconds
		}
	)
	var from_name := _resolve_item_callout_name(fighter, from_item_id)
	var to_name := _resolve_item_callout_name(fighter, to_item_id)
	if from_name != "" and to_name != "" and hud and hud.has_method("show_combat_callout_text"):
		hud.show_combat_callout_text("%s -> %s" % [from_name, to_name], Color(1.0, 0.92, 0.68, 1.0))
		return
	_show_combat_callout("HUD_CALLOUT_ITEM_EVOLVED", Color(1.0, 0.92, 0.68, 1.0))

func _resolve_item_callout_name(fighter: Node, fallback_item_id: String) -> String:
	if fighter and fighter.has_method("get_loadout_runtime_snapshot"):
		var snapshot_value: Variant = fighter.call("get_loadout_runtime_snapshot")
		if typeof(snapshot_value) == TYPE_DICTIONARY:
			var snapshot := snapshot_value as Dictionary
			var item_runtime := snapshot.get("item_runtime", {}) as Dictionary
			var item_name := str(item_runtime.get("display_name_fallback", "")).strip_edges()
			if item_name != "":
				return item_name
	return fallback_item_id.replace("_", " ").capitalize()

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
	info["training_drill_id"] = str(training_drill_state.get("drill_id", training_options.get("drill_id", TRAINING_DRILL_DUEL_CORE)))
	info["training_drill_rep_index"] = int(training_drill_state.get("rep_index", 0))
	hud.set_training_data(info)
	if hud.has_method("add_training_log_entry"):
		hud.add_training_log_entry(info)
	_sync_training_drill_state_to_hud()
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

func _apply_training_options(previous_enabled: bool = true) -> void:
	var enabled := bool(training_options.get("enabled", true))
	var dummy_mode := str(training_options.get("dummy_mode", "stand"))
	var drill_id := _normalize_training_drill_id(
		str(training_options.get("drill_id", "")),
		str(training_options.get("ruleset_profile", ruleset_profile))
	)
	var requested_ruleset := _resolve_ruleset_for_training_drill(drill_id)
	training_options["drill_id"] = drill_id
	training_options["ruleset_profile"] = requested_ruleset
	if ruleset_profile != requested_ruleset:
		ruleset_profile = requested_ruleset
		_apply_ruleset_profile()
	var throw_tech_assist_mode := _normalize_throw_tech_assist_mode(
		str(training_options.get("throw_tech_assist_mode", "throw_only"))
	)
	training_options["throw_tech_assist_mode"] = throw_tech_assist_mode
	if hud and hud.has_method("set_training_options"):
		hud.set_training_options(training_options)
	_refresh_training_drill_state(training_scene_enabled and not enabled)
	if training_scene_enabled:
		if not enabled:
			training_drill_runtime.clear()
		elif not previous_enabled and drill_id != TRAINING_DRILL_DUEL_CORE:
			_reset_training_sandbox_players(["p1", "p2"])
		elif drill_id == TRAINING_DRILL_DUEL_CORE:
			training_drill_runtime.clear()
		elif training_drill_runtime.is_empty() or str(training_drill_runtime.get("drill_id", "")) != drill_id:
			_prepare_training_drill_rep(["p1", "p2"])
	if not enabled and hud:
		if hud.has_method("set_training_data"):
			hud.set_training_data({})
		if hud.has_method("clear_training_log"):
			hud.clear_training_log()
	if player_2 and player_2.has_method("set_training_dummy_options"):
		player_2.call("set_training_dummy_options", enabled, dummy_mode)
	if player_1 and player_1.has_method("set_training_dummy_options"):
		player_1.call("set_training_dummy_options", false, "stand")
	if player_2 and player_2.has_method("set_training_throw_tech_options"):
		player_2.call("set_training_throw_tech_options", enabled, throw_tech_assist_mode)
	if player_1 and player_1.has_method("set_training_throw_tech_options"):
		player_1.call("set_training_throw_tech_options", enabled, throw_tech_assist_mode)
	if training_scene_enabled:
		if player_2 != null:
			player_2.set("is_ai", false)
		if player_1 != null:
			player_1.set("is_ai", false)

func _on_hud_training_options_changed(options: Dictionary) -> void:
	var previous_enabled := bool(training_options.get("enabled", true))
	training_options["enabled"] = bool(options.get("enabled", training_options.get("enabled", true)))
	var dummy_mode := str(options.get("dummy_mode", training_options.get("dummy_mode", "stand")))
	if dummy_mode not in ["stand", "force_block", "random_block"]:
		dummy_mode = "stand"
	training_options["dummy_mode"] = dummy_mode
	training_options["show_detail"] = bool(options.get("show_detail", training_options.get("show_detail", false)))
	var requested_ruleset := _normalize_ruleset_profile(str(options.get("ruleset_profile", training_options.get("ruleset_profile", ruleset_profile))))
	var requested_drill_id := _normalize_training_drill_id(
		str(options.get("drill_id", training_options.get("drill_id", _resolve_default_training_drill_id(requested_ruleset)))),
		requested_ruleset
	)
	training_options["drill_id"] = requested_drill_id
	training_options["ruleset_profile"] = _resolve_ruleset_for_training_drill(requested_drill_id)
	training_options["throw_tech_assist_mode"] = _normalize_throw_tech_assist_mode(
		str(options.get("throw_tech_assist_mode", training_options.get("throw_tech_assist_mode", "throw_only")))
	)
	if training_scene_enabled and (training_options["ruleset_profile"] != ruleset_profile or requested_drill_id != str(training_drill_state.get("drill_id", ""))):
		ruleset_profile = str(training_options.get("ruleset_profile", requested_ruleset))
		_apply_ruleset_profile()
		_reset_training_sandbox_players(["p1", "p2"])
		if hud:
			if hud.has_method("set_training_data"):
				hud.set_training_data({})
			if hud.has_method("clear_training_log"):
				hud.clear_training_log()
		_refresh_training_drill_state(true)
	_apply_training_options(previous_enabled)

func _play_attack_sfx(prefix: String, attack_kind: String) -> void:
	var attack_tier := _resolve_attack_tier(attack_kind)
	var key := "%s_%s" % [prefix, attack_tier]
	if not sfx_streams.has(key):
		if attack_tier == "signature" or attack_tier == "ultimate":
			key = "%s_special" % prefix
		elif attack_tier == "throw":
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
	var attack_tier := _resolve_attack_tier(attack_kind)
	var profile: Dictionary = source.get(attack_tier, {})
	var duration := float(profile.get("duration", 0.08))
	var strength := float(profile.get("strength", 2.8))
	if is_counter and not is_block:
		strength *= COUNTER_SHAKE_MULTIPLIER
		duration *= 1.15
	camera_shake_duration = duration
	camera_shake_time = duration
	camera_shake_strength = strength

func _start_camera_punch(attack_kind: String, is_block: bool, is_counter: bool = false) -> void:
	var attack_tier := _resolve_attack_tier(attack_kind)
	var profile: Dictionary = CAMERA_PUNCH_BY_TIER.get(attack_tier, CAMERA_PUNCH_BY_TIER["special"])
	var duration := float(profile.get("duration", 0.10))
	var amount := float(profile.get("zoom", 0.03))
	if is_block:
		duration *= 0.92
		amount *= CAMERA_PUNCH_BLOCK_SCALE
	elif is_counter:
		amount *= COUNTER_CAMERA_PUNCH_SCALE
	camera_punch_duration = duration
	camera_punch_time = duration
	camera_punch_amount = amount

func _trigger_screen_flash(attack_kind: String, is_block: bool, is_counter: bool = false) -> void:
	var attack_tier := _resolve_attack_tier(attack_kind)
	var profile: Dictionary = SCREEN_FLASH_BY_TIER.get(attack_tier, SCREEN_FLASH_BY_TIER["special"])
	var color := profile.get("color", Color(1.0, 0.82, 0.48, 0.24)) as Color
	var duration := float(profile.get("duration", 0.10))
	if is_block:
		color = color.lerp(Color(0.80, 0.95, 1.0, color.a), 0.42)
		color.a *= BLOCK_FLASH_ALPHA_SCALE
	elif is_counter:
		color = color.lerp(Color(1.0, 0.82, 0.48, color.a), 0.30)
		color.a = minf(0.42, color.a + COUNTER_FLASH_ALPHA_BONUS)
	screen_flash_color = color
	screen_flash_duration = duration
	screen_flash_time = duration
	if screen_flash:
		screen_flash.color = color
		screen_flash.visible = true

func _spawn_hit_spark(world_position: Vector2, attack_kind: String) -> void:
	_spawn_impact_animation(
		world_position,
		&"hit",
		attack_kind,
		_resolve_impact_tint(attack_kind, false, false),
		1.06
	)

func _spawn_guard_spark(world_position: Vector2, attack_kind: String) -> void:
	_spawn_impact_animation(
		world_position,
		&"guard",
		attack_kind,
		_resolve_impact_tint(attack_kind, true, false),
		1.10
	)

func _spawn_counter_spark(world_position: Vector2, attack_kind: String) -> void:
	_spawn_impact_animation(
		world_position,
		&"counter",
		attack_kind,
		_resolve_impact_tint(attack_kind, false, true),
		1.26
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
	_trim_effects_layer()
	var spark := AnimatedSprite2D.new()
	spark.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spark.sprite_frames = impact_sprite_frames
	spark.centered = true
	spark.z_as_relative = false
	spark.z_index = 12
	spark.position = world_position
	spark.modulate = tint
	spark.material = impact_additive_material
	spark.rotation = camera_rng.randf_range(-0.16, 0.16)

	var attack_tier := _resolve_attack_tier(attack_kind)
	var scale_factor := _resolve_impact_scale(base_scale, attack_tier)
	spark.scale = Vector2.ONE * scale_factor

	effects_layer.add_child(spark)
	_spawn_impact_burst(
		world_position,
		tint,
		scale_factor,
		attack_tier,
		animation_name == &"guard"
	)
	spark.animation_finished.connect(
		func():
			if is_instance_valid(spark):
				spark.queue_free(),
		CONNECT_ONE_SHOT
	)
	spark.play(animation_name)

func _spawn_impact_burst(
	world_position: Vector2,
	tint: Color,
	scale_factor: float,
	attack_tier: String,
	is_guard: bool
) -> void:
	if effects_layer == null or impact_ring_texture == null or impact_bloom_texture == null:
		return
	var bloom := Sprite2D.new()
	bloom.texture = impact_bloom_texture
	bloom.centered = true
	bloom.z_as_relative = false
	bloom.z_index = 10
	bloom.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	bloom.material = impact_additive_material
	bloom.position = world_position
	bloom.modulate = Color(tint.r, tint.g, tint.b, 0.36 if is_guard else 0.52)
	bloom.scale = Vector2.ONE * (scale_factor * (1.22 if is_guard else 1.42))
	_trim_effects_layer()
	effects_layer.add_child(bloom)
	_tween_transient_effect(
		bloom,
		bloom.scale * 1.82,
		0.16 if is_guard else 0.18,
		Color(tint.r, tint.g, tint.b, 0.0),
		Vector2(0.0, -5.0)
	)

	var ring := Sprite2D.new()
	ring.texture = impact_ring_texture
	ring.centered = true
	ring.z_as_relative = false
	ring.z_index = 11
	ring.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	ring.material = impact_additive_material
	ring.position = world_position
	ring.modulate = Color(1.0, 1.0, 1.0, 0.56 if is_guard else 0.76)
	ring.scale = Vector2.ONE * (scale_factor * (0.84 if is_guard else 0.96))
	ring.rotation = camera_rng.randf_range(-0.22, 0.22)
	_trim_effects_layer()
	effects_layer.add_child(ring)
	var expansion := 1.84
	match attack_tier:
		"heavy":
			expansion = 2.04
		"special":
			expansion = 2.22
		"signature":
			expansion = 2.34
		"ultimate":
			expansion = 2.52
	_tween_transient_effect(
		ring,
		ring.scale * expansion,
		0.14 if is_guard else 0.16,
		Color(ring.modulate.r, ring.modulate.g, ring.modulate.b, 0.0),
		Vector2(0.0, -7.0)
	)

func _tween_transient_effect(
	sprite: Sprite2D,
	final_scale: Vector2,
	duration: float,
	final_modulate: Color,
	drift: Vector2
) -> void:
	if sprite == null or not is_instance_valid(sprite):
		return
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "scale", final_scale, duration)
	tween.parallel().tween_property(sprite, "modulate", final_modulate, duration)
	tween.parallel().tween_property(sprite, "position", sprite.position + drift, duration)
	tween.finished.connect(
		func():
			if is_instance_valid(sprite):
				sprite.queue_free(),
		CONNECT_ONE_SHOT
	)

func _trim_effects_layer() -> void:
	if effects_layer == null:
		return
	while effects_layer.get_child_count() >= MAX_ACTIVE_IMPACTS:
		var oldest := effects_layer.get_child(0)
		if oldest:
			oldest.free()
		else:
			break

func _resolve_impact_scale(base_scale: float, attack_tier: String) -> float:
	var scale_factor := base_scale
	match attack_tier:
		"heavy":
			scale_factor *= 1.26
		"special":
			scale_factor *= 1.38
		"signature":
			scale_factor *= 1.46
		"ultimate":
			scale_factor *= 1.56
	return scale_factor

func _resolve_impact_tint(attack_kind: String, is_guard: bool, is_counter: bool) -> Color:
	var attack_tier := _resolve_attack_tier(attack_kind)
	var tint := IMPACT_TINT_BY_TIER.get(attack_tier, IMPACT_TINT_BY_TIER["special"]) as Color
	if IMPACT_ACCENT_TINT_BY_ATTACK.has(attack_kind):
		tint = tint.lerp(IMPACT_ACCENT_TINT_BY_ATTACK[attack_kind] as Color, 0.56)
	if is_guard:
		tint = tint.lerp(Color(0.74, 0.95, 1.0, tint.a), 0.58)
		tint.a = 0.95
	elif is_counter:
		tint = tint.lerp(Color(1.0, 0.94, 0.64, tint.a), 0.24)
	return tint

func _apply_selected_character_tables() -> void:
	_apply_selected_character_table_for_player(
		player_1,
		SessionKeysStore.PLAYER_1_TABLE_PATH,
		SessionKeysStore.PLAYER_1_ID,
		SessionKeysStore.PLAYER_1_NAME,
		SessionKeysStore.PLAYER_1_LOADOUT,
		"p1"
	)
	_apply_selected_character_table_for_player(
		player_2,
		SessionKeysStore.PLAYER_2_TABLE_PATH,
		SessionKeysStore.PLAYER_2_ID,
		SessionKeysStore.PLAYER_2_NAME,
		SessionKeysStore.PLAYER_2_LOADOUT,
		"p2"
	)
	if _is_story_session_mode():
		_apply_story_opponent_round()

func _apply_selected_character_table_for_player(
	player: Node,
	table_path_key: String,
	character_id_key: String,
	character_name_key: String,
	loadout_key: String,
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
	var selected_loadout := {}
	if SessionStateStore.has_value(loadout_key):
		var loadout_value: Variant = SessionStateStore.get_value(loadout_key, {})
		if typeof(loadout_value) == TYPE_DICTIONARY:
			selected_loadout = (loadout_value as Dictionary).duplicate(true)
	var resolved_loadout := LoadoutResolverStore.resolve_character_loadout(character_id, selected_loadout)
	selected_character_loadouts[player_key] = (resolved_loadout.get("loadout", {}) as Dictionary).duplicate(true)
	if player.has_method("apply_loadout_runtime"):
		player.call("apply_loadout_runtime", resolved_loadout)
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
				"signature_c": "Down Special",
				"ultimate": "Ultimate"
			}
		}
	profile["loadout_summary"] = (resolved_loadout.get("summary", {}) as Dictionary).duplicate(true)
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
	var opponent_id := str(selected_character_ids.get("p2", ""))
	var default_loadout := LoadoutCatalogStore.get_default_loadout(opponent_id)
	var resolved_loadout := LoadoutResolverStore.resolve_character_loadout(opponent_id, default_loadout)
	selected_character_loadouts["p2"] = (resolved_loadout.get("loadout", {}) as Dictionary).duplicate(true)
	if player_2 and player_2.has_method("apply_loadout_runtime"):
		player_2.call("apply_loadout_runtime", resolved_loadout)
	if player_2 and player_2.has_method("get_character_profile"):
		var profile_value: Variant = player_2.call("get_character_profile")
		if typeof(profile_value) == TYPE_DICTIONARY:
			var profile := (profile_value as Dictionary).duplicate(true)
			profile["loadout_summary"] = (resolved_loadout.get("summary", {}) as Dictionary).duplicate(true)
			selected_character_profiles["p2"] = profile

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

func _tr_or_fallback(key: String, fallback: String) -> String:
	var value := tr(key)
	if value == key:
		return fallback
	return value

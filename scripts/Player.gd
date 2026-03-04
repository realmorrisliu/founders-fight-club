extends CharacterBody2D

const PlayerDataStore := preload("res://scripts/player/PlayerData.gd")
const GeneratedSkillProfilesStore := preload("res://scripts/player/GeneratedSkillProfiles.gd")
const PlayerSignatureAttackBuilderStore := preload("res://scripts/player/PlayerSignatureAttackBuilder.gd")
const PlayerAttackRuntimeBuilderStore := preload("res://scripts/player/PlayerAttackRuntimeBuilder.gd")
const StageConfigStore := preload("res://scripts/config/StageConfig.gd")
const GameSettingsStore := preload("res://scripts/GameSettings.gd")

signal health_changed
signal defeated
signal hit_landed(attacker: Node, target: Node, attack_kind: String, is_counter: bool, combo_count: int)
signal blocked_landed(attacker: Node, target: Node, attack_kind: String)
signal tech_recovered(fighter: Node, tech_kind: String)
signal throw_teched(attacker: Node, target: Node)

const MAX_HP := 100
const MOVE_SPEED := 220.0
const JUMP_VELOCITY := -380.0
const DASH_SPEED := 420.0
const DASH_DURATION := 0.16
const DASH_COOLDOWN := 0.45
const BLOCK_WALK_SPEED_FACTOR := 0.32
const HITSTUN_SECONDS := 0.18
const BLOCKSTUN_SECONDS := 0.14
const KNOCKDOWN_HITSTUN_THRESHOLD := 0.22
const KNOCKDOWN_VERTICAL_THRESHOLD := 145.0
const KNOCKDOWN_GROUND_SECONDS := 0.42
const GETUP_SECONDS := 0.30
const TECH_GETUP_SECONDS := 0.18
const TECH_QUICK_KNOCKDOWN_SECONDS := 0.04
const TECH_SLIDE_DURATION := 0.12
const TECH_SLIDE_SPEED := 180.0
const WAKE_INVULN_SECONDS := 0.18
const RESPAWN_INVULN_SECONDS := 0.72
const THROW_TECH_BUFFER_SECONDS := 0.10
const THROW_TECH_PUSHBACK := 70.0
const THROW_TECH_AI_CHANCE := 0.20
const AI_BLOCK_REACTION_DISTANCE := 76.0
const AI_BLOCK_STARTUP_REACTION_THRESHOLD := 0.62
const TRAINING_RANDOM_BLOCK_CHANCE := 0.5
const TRAINING_RANDOM_BLOCK_HOLD_SECONDS := 0.22
const TRAINING_BLOCK_THREAT_DISTANCE := 108.0
const INPUT_BUFFER_SECONDS := 0.22
const DIRECTION_INPUT_BUFFER_SECONDS := 0.10
const ULTIMATE_CHORD_BUFFER_SECONDS := 0.12
const JUMP_BUFFER_SECONDS := 0.12
const COYOTE_TIME_SECONDS := 0.10
const JUMP_CUT_VELOCITY_MULTIPLIER := 0.52
const FAST_FALL_MIN_DESCENT_SPEED := 32.0
const FAST_FALL_GRAVITY_MULTIPLIER := 1.90
const FAST_FALL_MAX_SPEED := 980.0
const AERIAL_LANDING_LAG_DEFAULT := 0.11
const AERIAL_LANDING_LAG_AUTO_CANCEL := 0.03
const AERIAL_AUTO_CANCEL_RECOVERY_PROGRESS := 0.60
const AERIAL_FAST_FALL_LANDING_LAG_BONUS := 0.015
const SHIELD_MAX := 100.0
const SHIELD_BLOCK_MIN_REQUIRED := 2.0
const SHIELD_DRAIN_PER_SECOND := 34.0
const SHIELD_HIT_DAMAGE_SCALE := 1.15
const SHIELD_REGEN_PER_SECOND := 24.0
const SHIELD_REGEN_DELAY_SECONDS := 0.42
const SHIELD_BREAK_STUN_SECONDS := 0.95
const SHIELD_BREAK_RECOVER_SHIELD := 34.0
const SHIELD_BREAK_PUSHBACK := 96.0
const DODGE_COOLDOWN_SECONDS := 0.28
const SPOT_DODGE_DURATION := 0.18
const SPOT_DODGE_INVULN_SECONDS := 0.13
const ROLL_DODGE_DURATION := 0.24
const ROLL_DODGE_INVULN_SECONDS := 0.15
const ROLL_DODGE_SPEED := 255.0
const AIR_DODGE_DURATION := 0.24
const AIR_DODGE_INVULN_SECONDS := 0.16
const AIR_DODGE_SPEED := 220.0
const AIR_DODGE_FALL_SPEED := 36.0
const AIR_DODGE_END_LAG_SECONDS := 0.18
const MAX_AIR_JUMPS := 1
const GROUND_ACCELERATION := 1720.0
const GROUND_DECELERATION := 2140.0
const AIR_ACCELERATION := 980.0
const AIR_DECELERATION := 820.0
const BLOCK_ACCELERATION_SCALE := 0.72
const BLOCK_DECELERATION_SCALE := 1.14
const WALK_ANIMATION_SPEED_THRESHOLD := 34.0
const AI_PROFILE_DEFAULT := PlayerDataStore.AI_PROFILE_DEFAULT
const AI_PROFILE_BY_CHARACTER := PlayerDataStore.AI_PROFILE_BY_CHARACTER
const COMBO_CHAIN_TIMEOUT_SECONDS := 0.95
const COMBO_DAMAGE_SCALING_STEP := 0.12
const COMBO_DAMAGE_SCALING_MIN := 0.45
const COMBO_MIN_DAMAGE := 2
const COMBO_SCALING_PROFILE_BY_TIER := {
	"light": {"step": 0.10, "min": 0.50},
	"heavy": {"step": 0.14, "min": 0.42},
	"special": {"step": 0.12, "min": 0.45},
	"signature": {"step": 0.11, "min": 0.46},
	"ultimate": {"step": 0.08, "min": 0.56},
	"throw": {"step": 0.08, "min": 0.60}
}
const KNOCKBACK_GROWTH_PER_DAMAGE_RATIO := 0.70
const KNOCKBACK_GROWTH_MAX_SCALE := 1.65
const DI_INPUT_DEADZONE := 0.20
const DI_MIN_KNOCKBACK_SPEED := 80.0
const DI_MAX_ANGLE_DEGREES := 18.0
const DI_SURVIVAL_SCALE := 0.10
const AI_DI_CHANCE := 0.66
const AI_GUARD_LOW_READ_CHANCE := 0.22
const HURTBOX_HEAD_SCALE := Vector2(0.76, 0.40)
const HURTBOX_TORSO_SCALE := Vector2(0.92, 0.56)
const HURTBOX_LEGS_SCALE := Vector2(0.84, 0.38)
const HIT_ZONE_HEAD_DAMAGE_BONUS := 1
const HIT_ZONE_HEAD_LAUNCH_BONUS := 24.0
const HIT_ZONE_LEGS_DAMAGE_PENALTY := 1
const HIT_ZONE_LEGS_LAUNCH_PENALTY := 20.0
const GUARD_COUNTER_WINDOW_SECONDS := 0.24
const GUARD_COUNTER_DAMAGE_BONUS := 3
const GUARD_COUNTER_HITSTUN_BONUS := 0.05
const GUARD_COUNTER_KNOCKBACK_SCALE := 1.15
const PLACEHOLDER_FRAME_SIZE := Vector2i(24, 48)
const OUTLINE_COLOR := Color(0.09, 0.09, 0.09, 1.0)
const DEFAULT_SPRITE_FRAMES_PATH := "res://assets/sprites/player/PlayerSpriteFrames.tres"
const DEFAULT_ATTACK_TABLE_PATH := "res://assets/data/PlayerAttackTable.tres"
const HYPE_MAX := 100.0
const HYPE_GAIN_ON_HIT := 12.0
const HYPE_GAIN_ON_BLOCK := 6.0
const HYPE_GAIN_ON_TAKING_HIT := 4.0
const SKILL_ENTITY_TARGET_HEIGHT_OFFSET := 22.0
const SKILL_ENTITY_MIN_SIZE := Vector2(12.0, 10.0)
const SKILL_ENTITY_STAGE_PADDING := 2.0
const DEFAULT_STAGE_LEFT_X := StageConfigStore.DEFAULT_LEFT_X
const DEFAULT_STAGE_RIGHT_X := StageConfigStore.DEFAULT_RIGHT_X
const DEFAULT_STAGE_FLOOR_Y := StageConfigStore.DEFAULT_FLOOR_Y
const PLAYER_STAGE_MARGIN := 12.0
const LEDGE_GRAB_HORIZONTAL_RANGE := 32.0
const LEDGE_GRAB_ABOVE_FLOOR_MARGIN := 18.0
const LEDGE_GRAB_BELOW_FLOOR_MARGIN := 70.0
const LEDGE_HANG_X_OFFSET := 8.0
const LEDGE_HANG_Y_OFFSET := 10.0
const LEDGE_HOLD_MAX_SECONDS := 1.0
const LEDGE_REGRAB_LOCK_SECONDS := 0.24
const LEDGE_GRAB_INVULN_SECONDS := 0.12
const LEDGE_JUMP_HORIZONTAL_SPEED := 168.0
const LEDGE_DROP_VERTICAL_SPEED := 92.0
const LEDGE_DROP_HORIZONTAL_SPEED := 26.0
const LEDGE_ROLL_GETUP_INSET_X := 20.0
const LEDGE_ATTACK_GETUP_INSET_X := 22.0
const PLATFORM_COLLISION_LAYER_BIT := 2
const PLATFORM_DROP_THROUGH_SECONDS := 0.18
const PLATFORM_DROP_FLOOR_Y_MARGIN := 10.0
const SIGNATURE_ATTACK_KEYS := ["signature_a", "signature_b", "signature_c", "ultimate"]
const STATUS_SILENCE_CAP_SECONDS := 1.6
const STATUS_SLOW_CAP_SECONDS := 1.2
const STATUS_ROOT_CAP_SECONDS := 0.5
const CHARACTER_TINT_BY_ID := PlayerDataStore.CHARACTER_TINT_BY_ID
const REQUIRED_BASE_ATTACK_KEYS := ["light", "heavy", "special", "throw"]
const ARCHETYPE_ALL_ROUNDER := "all_rounder"
const ARCHETYPE_RUSHDOWN := "rushdown"
const ARCHETYPE_ZONER := "zoner"
const ARCHETYPE_BRUISER := "bruiser"
const ARCHETYPE_COUNTER := "counter"
const BLOCK_CHIP_BY_ATTACK := {
	"light": 0.0,
	"heavy": 0.08,
	"special": 0.12,
	"throw": 0.0,
	"signature_a": 0.10,
	"signature_b": 0.12,
	"signature_c": 0.12,
	"ultimate": 0.15
}
const REQUIRED_ANIMATION_NAMES := [
	"idle",
	"walk",
	"jump",
	"light",
	"heavy",
	"special",
	"throw",
	"block",
	"hit_light",
	"hit_heavy",
	"hit",
	"fall",
	"getup",
	"ko"
]
const ANIMATION_PROFILES := PlayerDataStore.ANIMATION_PROFILES
const LOCAL_INPUT_ACTIONS := PlayerDataStore.LOCAL_INPUT_ACTIONS
const LOCAL_INPUT_PREFIX_BY_PLAYER_ID := PlayerDataStore.LOCAL_INPUT_PREFIX_BY_PLAYER_ID
const LOCAL_GAMEPAD_DEVICE_BY_PLAYER_ID := PlayerDataStore.LOCAL_GAMEPAD_DEVICE_BY_PLAYER_ID
const PLAYER2_LOCAL_KEYBOARD_LAYOUT := PlayerDataStore.PLAYER2_LOCAL_KEYBOARD_LAYOUT
const ATTACK_DATA := PlayerDataStore.ATTACK_DATA

@export var use_external_sprite_frames := true
@export var sprite_frames_resource: SpriteFrames
@export_file("*.tres", "*.res") var sprite_frames_path := DEFAULT_SPRITE_FRAMES_PATH
@export var use_external_attack_table := true
@export var attack_table_resource: Resource
@export_file("*.tres", "*.res") var attack_table_path := DEFAULT_ATTACK_TABLE_PATH
@export var player_id := 1
@export var is_ai := false
@export var opponent_path: NodePath

var current_hp := MAX_HP
var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var stage_left_x := DEFAULT_STAGE_LEFT_X
var stage_right_x := DEFAULT_STAGE_RIGHT_X
var stage_floor_y := DEFAULT_STAGE_FLOOR_Y

var facing := 1
var attack_state := ""
var attack_phase := ""
var attack_time := 0.0
var hit_targets := {}
var ai_attack_cooldown := 0.0
var hitbox_offset := Vector2(20, 0)
var dash_time := 0.0
var dash_cooldown_timer := 0.0
var hitstun_time := 0.0
var blockstun_time := 0.0
var knockdown_time := 0.0
var getup_time := 0.0
var is_dashing := false
var is_blocking := false
var is_knocked_down := false
var runtime_sprite_frames: SpriteFrames
var runtime_attack_data: Dictionary = {}
var hit_reaction_animation: StringName = &"hit"
var ai_block_time := 0.0
var guard_counter_time := 0.0
var next_attack_is_counter := false
var attack_recovery_override := -1.0
var buffered_attack := ""
var buffered_attack_time := 0.0
var attack_confirmed_hit := false
var attack_confirmed_block := false
var combo_target: Node = null
var combo_hits := 0
var combo_damage_total := 0
var combo_chain_timer := 0.0
var wake_invuln_time := 0.0
var tech_slide_time := 0.0
var tech_slide_speed := 0.0
var ai_tech_decision_roll := false
var ai_guard_mode := "high"
var ai_style_profile: Dictionary = AI_PROFILE_DEFAULT.duplicate(true)
var throw_tech_buffer_time := 0.0
var last_training_info := {}
var training_dummy_enabled := false
var training_dummy_mode := "stand"
var training_random_block_hold_time := 0.0
var training_random_block_signature := ""
var skill_cooldowns: Dictionary = {}
var skill_entities: Array[Dictionary] = []
var attack_effect_triggered := false
var attack_startup_duration := 0.0
var attack_active_duration := 0.0
var attack_recovery_duration := 0.0
var status_silence_time := 0.0
var status_slow_time := 0.0
var status_slow_factor := 0.65
var status_root_time := 0.0
var install_buff_time := 0.0
var install_damage_multiplier := 1.0
var install_speed_multiplier := 1.0
var install_startup_multiplier := 1.0
var install_chip_bonus := 0.0
var hype_meter := 0.0
var skill_entity_texture_cache: Dictionary = {}
var facing_locked := false
var facing_locked_direction := 1
var forward_input_buffer_time := 0.0
var forward_input_was_pressed := false
var up_input_buffer_time := 0.0
var down_input_buffer_time := 0.0
var special_input_buffer_time := 0.0
var heavy_input_buffer_time := 0.0
var is_ledge_hanging := false
var ledge_side := 0
var ledge_hold_time := 0.0
var ledge_regrab_lock_time := 0.0
var coyote_time := 0.0
var jump_buffer_time := 0.0
var jump_cut_available := false
var fast_fall_active := false
var landing_lag_time := 0.0
var was_on_floor_last_frame := false
var attack_started_in_air := false
var shield_meter := SHIELD_MAX
var shield_regen_delay := 0.0
var shield_break_time := 0.0
var shield_broken := false
var dodge_state := ""
var dodge_time := 0.0
var dodge_cooldown_time := 0.0
var dodge_direction := 1
var air_dodge_end_lag_time := 0.0
var air_dodge_available := true
var air_jumps_remaining := MAX_AIR_JUMPS
var control_preset := GameSettingsStore.CONTROL_PRESET_MODERN
var local_input_prefix := "p1"
var local_gamepad_device := 0
var platform_drop_through_time := 0.0
var hitstop_active := false

static var _ledge_occupancy_by_side := {
	-1: 0,
	1: 0
}

@onready var hitbox := $Hitbox as Area2D
@onready var hitbox_shape := $Hitbox/CollisionShape2D
@onready var visual := $Visual as AnimatedSprite2D
@onready var opponent: CharacterBody2D = get_node_or_null(opponent_path) as CharacterBody2D

func _ready() -> void:
	add_to_group("fighters")
	_ensure_local_input_actions()
	_sync_control_preset()
	_setup_attack_data()
	_refresh_ai_style_profile()
	_setup_visual()
	hitbox.monitoring = false
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	_update_facing()
	_update_visual()
	was_on_floor_last_frame = is_on_floor()
	platform_drop_through_time = 0.0
	air_dodge_end_lag_time = 0.0
	_update_platform_collision_mask()

func _exit_tree() -> void:
	_release_occupied_ledge()

func _physics_process(delta: float) -> void:
	if hitstop_active:
		_update_facing()
		_update_visual()
		return
	platform_drop_through_time = maxf(0.0, platform_drop_through_time - delta)
	_update_platform_collision_mask()
	var was_on_floor := was_on_floor_last_frame
	_update_command_input_buffers(delta)
	_update_jump_mobility_timers(delta)
	_apply_air_gravity(delta)
	_apply_jump_cut()
	guard_counter_time = maxf(0.0, guard_counter_time - delta)
	wake_invuln_time = maxf(0.0, wake_invuln_time - delta)
	ledge_regrab_lock_time = maxf(0.0, ledge_regrab_lock_time - delta)
	dodge_cooldown_time = maxf(0.0, dodge_cooldown_time - delta)
	if is_on_floor():
		air_dodge_end_lag_time = 0.0
	else:
		air_dodge_end_lag_time = maxf(0.0, air_dodge_end_lag_time - delta)
	_update_skill_runtime(delta)
	_update_throw_tech_buffer(delta)
	_update_attack_buffer(delta)
	_update_combo_chain(delta)
	_try_enter_ledge_hang()
	if is_ledge_hanging:
		_process_ledge_hang(delta)
		_update_facing()
		_update_visual()
		was_on_floor_last_frame = false
		return

	if is_knocked_down:
		_update_knockdown(delta)
		_update_facing()
		_update_visual()
		_move_and_finalize(was_on_floor)
		return

	if getup_time > 0.0:
		getup_time = maxf(0.0, getup_time - delta)
		if tech_slide_time > 0.0:
			tech_slide_time = maxf(0.0, tech_slide_time - delta)
			velocity.x = tech_slide_speed
			velocity.y = 0.0
		else:
			velocity = Vector2.ZERO
		_update_facing()
		_update_visual()
		_move_and_finalize(was_on_floor)
		return

	if hitstun_time > 0.0:
		hitstun_time -= delta
		_update_facing()
		_update_visual()
		_move_and_finalize(was_on_floor)
		return

	if blockstun_time > 0.0:
		blockstun_time -= delta
		velocity.x = move_toward(velocity.x, 0.0, MOVE_SPEED * delta * 2.5)
		_update_facing()
		_update_visual()
		_move_and_finalize(was_on_floor)
		return

	if shield_break_time > 0.0:
		shield_break_time = maxf(0.0, shield_break_time - delta)
		is_blocking = false
		_apply_horizontal_intent(0.0, delta, 0.55, 1.85)
		if shield_break_time <= 0.0:
			_recover_from_shield_break()
		_update_facing()
		_update_visual()
		_move_and_finalize(was_on_floor)
		return

	if dodge_time > 0.0:
		dodge_time = maxf(0.0, dodge_time - delta)
		is_blocking = false
		_update_dodge_motion(delta)
		if dodge_time <= 0.0:
			_end_dodge_state()
		_update_facing()
		_update_visual()
		_move_and_finalize(was_on_floor)
		return

	if landing_lag_time > 0.0:
		landing_lag_time = maxf(0.0, landing_lag_time - delta)
		is_blocking = false
		_apply_horizontal_intent(0.0, delta, 0.7, 1.4)
		_update_facing()
		_update_visual()
		_move_and_finalize(was_on_floor)
		return

	if is_dashing:
		dash_time -= delta
		if dash_time <= 0.0:
			is_dashing = false
			velocity.x = 0.0
		_update_facing()
		_update_visual()
		_move_and_finalize(was_on_floor)
		return

	dash_cooldown_timer = maxf(0.0, dash_cooldown_timer - delta)
	ai_block_time = maxf(0.0, ai_block_time - delta)
	training_random_block_hold_time = maxf(0.0, training_random_block_hold_time - delta)

	if _is_training_dummy_active():
		_process_training_dummy(delta)
	elif is_ai:
		_process_ai(delta)
	else:
		_process_player_input(delta)

	_update_shield_state(delta)
	_update_attack(delta)
	_try_start_buffered_attack_from_neutral()
	_try_enter_ledge_hang()
	if is_ledge_hanging:
		_process_ledge_hang(delta)
		_update_facing()
		_update_visual()
		was_on_floor_last_frame = false
		return
	_update_facing()
	_update_visual()
	_move_and_finalize(was_on_floor)

func _process_player_input(delta: float) -> void:
	if attack_state == "":
		if _try_start_platform_drop_through():
			return
		var move_axis := _get_axis_input("move_left", "move_right")
		if _is_rooted():
			move_axis = 0.0
		if _is_action_just_pressed("dash") and _try_start_defensive_dodge(move_axis, _get_axis_input("move_up", "move_down")):
			return
		var move_speed := MOVE_SPEED * _get_move_speed_multiplier()
		var wants_block := _can_enter_block() and _is_block_input_pressed()
		if wants_block:
			is_blocking = true
			var block_target_speed := move_axis * move_speed * BLOCK_WALK_SPEED_FACTOR
			if is_on_floor():
				_apply_horizontal_intent(block_target_speed, delta, BLOCK_ACCELERATION_SCALE, BLOCK_DECELERATION_SCALE)
			else:
				_apply_horizontal_intent(block_target_speed * 0.45, delta, BLOCK_ACCELERATION_SCALE, BLOCK_DECELERATION_SCALE)
			if _try_consume_buffered_jump():
				is_blocking = false
			return

		is_blocking = false
		_apply_horizontal_intent(move_axis * move_speed, delta)
		_try_consume_buffered_jump()
		var requested_attack := _read_requested_attack()
		if requested_attack != "":
			_request_attack(requested_attack)
		elif (_is_action_just_pressed("dash") or _is_forward_tap_pressed()) and dash_cooldown_timer <= 0.0 and (is_on_floor() or coyote_time > 0.0) and not _is_rooted():
			_start_dash()
	else:
		is_blocking = false
		_apply_horizontal_intent(0.0, delta, 0.8, 1.3)
		var buffered_kind := _read_requested_attack()
		if buffered_kind != "":
			_buffer_attack(buffered_kind)

func _update_platform_collision_mask() -> void:
	var enable_platform_layer := platform_drop_through_time <= 0.0
	set_collision_mask_value(PLATFORM_COLLISION_LAYER_BIT, enable_platform_layer)

func _try_start_platform_drop_through() -> bool:
	if not _is_action_just_pressed("jump"):
		return false
	if not _is_action_pressed("move_down"):
		return false
	if not is_on_floor():
		return false
	if not _is_on_drop_through_platform():
		return false
	platform_drop_through_time = PLATFORM_DROP_THROUGH_SECONDS
	_update_platform_collision_mask()
	velocity.y = maxf(velocity.y, LEDGE_DROP_VERTICAL_SPEED)
	jump_buffer_time = 0.0
	coyote_time = 0.0
	is_blocking = false
	return true

func _is_on_drop_through_platform() -> bool:
	return global_position.y < stage_floor_y - PLATFORM_DROP_FLOOR_Y_MARGIN

func _try_enter_ledge_hang() -> void:
	if is_ledge_hanging:
		return
	if ledge_regrab_lock_time > 0.0:
		return
	if stage_right_x <= stage_left_x:
		return
	if current_hp <= 0:
		return
	if is_on_floor():
		return
	if velocity.y < 0.0:
		return
	if attack_state != "" or is_dashing or is_blocking or dodge_time > 0.0:
		return
	if is_knocked_down or getup_time > 0.0:
		return
	if hitstun_time > 0.0 or blockstun_time > 0.0:
		return
	var side := _resolve_ledge_grab_side()
	if side == 0:
		return
	if not _is_ledge_slot_available(side):
		return
	_start_ledge_hang(side)

func _resolve_ledge_grab_side() -> int:
	var min_y := stage_floor_y - LEDGE_GRAB_ABOVE_FLOOR_MARGIN
	var max_y := stage_floor_y + LEDGE_GRAB_BELOW_FLOOR_MARGIN
	if global_position.y < min_y or global_position.y > max_y:
		return 0
	var near_left := absf(global_position.x - stage_left_x) <= LEDGE_GRAB_HORIZONTAL_RANGE and global_position.x <= stage_left_x + LEDGE_GRAB_HORIZONTAL_RANGE
	if near_left:
		return -1
	var near_right := absf(global_position.x - stage_right_x) <= LEDGE_GRAB_HORIZONTAL_RANGE and global_position.x >= stage_right_x - LEDGE_GRAB_HORIZONTAL_RANGE
	if near_right:
		return 1
	return 0

func _start_ledge_hang(side: int) -> void:
	ledge_side = -1 if side < 0 else 1
	_claim_ledge_slot(ledge_side)
	is_ledge_hanging = true
	ledge_hold_time = LEDGE_HOLD_MAX_SECONDS
	velocity = Vector2.ZERO
	is_dashing = false
	is_blocking = false
	attack_state = ""
	attack_phase = ""
	attack_time = 0.0
	attack_recovery_override = -1.0
	attack_effect_triggered = false
	attack_startup_duration = 0.0
	attack_active_duration = 0.0
	attack_recovery_duration = 0.0
	attack_confirmed_hit = false
	attack_confirmed_block = false
	attack_started_in_air = false
	dodge_state = ""
	dodge_time = 0.0
	dodge_cooldown_time = 0.0
	hit_targets.clear()
	_set_hitbox_active(false)
	_clear_attack_buffer()
	jump_cut_available = false
	landing_lag_time = 0.0
	air_dodge_available = true
	air_jumps_remaining = MAX_AIR_JUMPS
	facing_locked = true
	facing_locked_direction = -ledge_side
	global_position = _get_ledge_anchor_position(ledge_side)
	wake_invuln_time = maxf(wake_invuln_time, LEDGE_GRAB_INVULN_SECONDS)

func _process_ledge_hang(delta: float) -> void:
	if not is_ledge_hanging:
		return
	ledge_hold_time = maxf(0.0, ledge_hold_time - delta)
	velocity = Vector2.ZERO
	global_position = _get_ledge_anchor_position(ledge_side)
	is_blocking = false
	if current_hp <= 0:
		_drop_from_ledge(false)
		return
	if _is_action_just_pressed("jump") or _is_action_just_pressed("move_up"):
		_launch_from_ledge()
		return
	if _is_action_just_pressed("dash"):
		_roll_getup_from_ledge()
		return
	if _is_action_just_pressed("attack_light") or _is_action_just_pressed("attack_heavy"):
		_attack_getup_from_ledge()
		return
	if _is_action_pressed("move_down"):
		_drop_from_ledge(true)
		return
	if _is_away_from_stage_input_pressed():
		_drop_from_ledge(true)
		return
	if ledge_hold_time <= 0.0:
		_drop_from_ledge(false)

func _is_away_from_stage_input_pressed() -> bool:
	if ledge_side < 0:
		return _is_action_pressed("move_left")
	return _is_action_pressed("move_right")

func _get_ledge_anchor_position(side: int) -> Vector2:
	var direction := -1 if side < 0 else 1
	return Vector2(
		(stage_left_x if direction < 0 else stage_right_x) + float(direction) * LEDGE_HANG_X_OFFSET,
		stage_floor_y - LEDGE_HANG_Y_OFFSET
	)

func _launch_from_ledge() -> void:
	var side := ledge_side
	_end_ledge_hang()
	velocity.y = JUMP_VELOCITY * 0.92
	velocity.x = -float(side) * LEDGE_JUMP_HORIZONTAL_SPEED * _get_move_speed_multiplier()
	jump_cut_available = false
	wake_invuln_time = maxf(wake_invuln_time, 0.10)
	air_jumps_remaining = MAX_AIR_JUMPS

func _roll_getup_from_ledge() -> void:
	var side := ledge_side
	_end_ledge_hang()
	var edge_x := stage_left_x if side < 0 else stage_right_x
	global_position = Vector2(edge_x - float(side) * LEDGE_ROLL_GETUP_INSET_X, stage_floor_y - 2.0)
	_start_roll_dodge(-side)
	wake_invuln_time = maxf(wake_invuln_time, 0.08)

func _attack_getup_from_ledge() -> void:
	var side := ledge_side
	_end_ledge_hang()
	var edge_x := stage_left_x if side < 0 else stage_right_x
	global_position = Vector2(edge_x - float(side) * LEDGE_ATTACK_GETUP_INSET_X, stage_floor_y - 2.0)
	velocity = Vector2.ZERO
	coyote_time = COYOTE_TIME_SECONDS
	air_jumps_remaining = MAX_AIR_JUMPS
	_start_attack("light")

func _drop_from_ledge(apply_horizontal_push: bool) -> void:
	var side := ledge_side
	_end_ledge_hang()
	velocity.y = LEDGE_DROP_VERTICAL_SPEED
	velocity.x = float(side) * LEDGE_DROP_HORIZONTAL_SPEED if apply_horizontal_push else 0.0

func _end_ledge_hang() -> void:
	var previous_side := ledge_side
	is_ledge_hanging = false
	ledge_hold_time = 0.0
	ledge_side = 0
	_release_ledge_slot(previous_side)
	facing_locked = false
	ledge_regrab_lock_time = LEDGE_REGRAB_LOCK_SECONDS
	fast_fall_active = false
	air_dodge_available = true

func _is_ledge_slot_available(side: int) -> bool:
	var slot := -1 if side < 0 else 1
	var occupant_id := int(_ledge_occupancy_by_side.get(slot, 0))
	if occupant_id == 0 or occupant_id == get_instance_id():
		return true
	var occupant := instance_from_id(occupant_id)
	if occupant == null:
		_ledge_occupancy_by_side[slot] = 0
		return true
	return false

func _claim_ledge_slot(side: int) -> void:
	var slot := -1 if side < 0 else 1
	_ledge_occupancy_by_side[slot] = get_instance_id()

func _release_ledge_slot(side: int) -> void:
	if side == 0:
		return
	var slot := -1 if side < 0 else 1
	var occupant_id := int(_ledge_occupancy_by_side.get(slot, 0))
	if occupant_id == get_instance_id():
		_ledge_occupancy_by_side[slot] = 0

func _release_occupied_ledge() -> void:
	_release_ledge_slot(-1)
	_release_ledge_slot(1)

func _update_jump_mobility_timers(delta: float) -> void:
	coyote_time = maxf(0.0, coyote_time - delta)
	jump_buffer_time = maxf(0.0, jump_buffer_time - delta)
	if is_on_floor():
		coyote_time = COYOTE_TIME_SECONDS
		fast_fall_active = false
		jump_cut_available = false
		air_dodge_available = true
		air_jumps_remaining = MAX_AIR_JUMPS
	if is_ledge_hanging:
		fast_fall_active = false
		jump_cut_available = false
		air_dodge_available = true
		air_jumps_remaining = MAX_AIR_JUMPS
	if is_ai:
		return
	if _is_action_just_pressed("jump"):
		jump_buffer_time = JUMP_BUFFER_SECONDS

func _try_start_defensive_dodge(horizontal_axis: float, vertical_axis: float) -> bool:
	if not _can_start_dodge():
		return false
	if is_on_floor():
		var guarding := _is_block_input_pressed() or is_blocking
		if not guarding:
			return false
		var direction := int(signf(horizontal_axis))
		if direction != 0:
			_start_roll_dodge(direction)
		else:
			_start_spot_dodge()
		return true
	return _start_air_dodge(horizontal_axis, vertical_axis)

func _can_start_dodge() -> bool:
	if current_hp <= 0:
		return false
	if shield_break_time > 0.0:
		return false
	if dodge_time > 0.0 or dodge_state != "":
		return false
	if air_dodge_end_lag_time > 0.0:
		return false
	if attack_state != "":
		return false
	if is_dashing:
		return false
	if is_knocked_down or getup_time > 0.0:
		return false
	if hitstun_time > 0.0 or blockstun_time > 0.0:
		return false
	if landing_lag_time > 0.0:
		return false
	if is_ledge_hanging:
		return false
	if _is_rooted():
		return false
	if is_on_floor():
		return dodge_cooldown_time <= 0.0
	return air_dodge_available

func _start_spot_dodge() -> void:
	dodge_state = "spot"
	dodge_time = SPOT_DODGE_DURATION
	dodge_direction = facing
	dodge_cooldown_time = maxf(dodge_cooldown_time, DODGE_COOLDOWN_SECONDS)
	wake_invuln_time = maxf(wake_invuln_time, SPOT_DODGE_INVULN_SECONDS)
	is_blocking = false
	facing_locked = true
	facing_locked_direction = facing
	velocity.x = 0.0
	if is_on_floor():
		velocity.y = 0.0
	_clear_attack_buffer()

func _start_roll_dodge(direction: int) -> void:
	var resolved_direction := direction
	if resolved_direction == 0:
		resolved_direction = facing
	dodge_state = "roll"
	dodge_time = ROLL_DODGE_DURATION
	dodge_direction = 1 if resolved_direction >= 0 else -1
	dodge_cooldown_time = maxf(dodge_cooldown_time, DODGE_COOLDOWN_SECONDS)
	wake_invuln_time = maxf(wake_invuln_time, ROLL_DODGE_INVULN_SECONDS)
	is_blocking = false
	facing_locked = true
	facing_locked_direction = dodge_direction
	velocity.x = float(dodge_direction) * ROLL_DODGE_SPEED * _get_move_speed_multiplier()
	velocity.y = 0.0
	_clear_attack_buffer()

func _start_air_dodge(horizontal_axis: float, vertical_axis: float) -> bool:
	if not air_dodge_available:
		return false
	air_dodge_available = false
	air_dodge_end_lag_time = 0.0
	dodge_state = "air"
	dodge_time = AIR_DODGE_DURATION
	dodge_cooldown_time = maxf(dodge_cooldown_time, 0.08)
	wake_invuln_time = maxf(wake_invuln_time, AIR_DODGE_INVULN_SECONDS)
	is_blocking = false
	var direction := Vector2(horizontal_axis, vertical_axis)
	if direction.length() < 0.2:
		direction = Vector2(float(facing), 0.0)
	direction = direction.normalized()
	velocity = direction * AIR_DODGE_SPEED
	dodge_direction = 1 if direction.x >= 0.0 else -1
	facing_locked = true
	facing_locked_direction = dodge_direction
	_clear_attack_buffer()
	return true

func _update_dodge_motion(delta: float) -> void:
	match dodge_state:
		"spot":
			velocity.x = move_toward(velocity.x, 0.0, MOVE_SPEED * delta * 6.0)
			if is_on_floor():
				velocity.y = 0.0
		"roll":
			var roll_speed := ROLL_DODGE_SPEED * _get_move_speed_multiplier()
			var target_speed := float(dodge_direction) * roll_speed
			if dodge_time <= 0.08:
				target_speed *= 0.42
			velocity.x = move_toward(velocity.x, target_speed, roll_speed * delta * 8.0)
			velocity.y = 0.0
		"air":
			velocity.y = move_toward(velocity.y, AIR_DODGE_FALL_SPEED, gravity * delta * 0.45)
			velocity.x = move_toward(velocity.x, 0.0, AIR_DODGE_SPEED * delta * 1.8)
		_:
			pass

func _end_dodge_state() -> void:
	if dodge_state == "":
		return
	if dodge_state == "air":
		velocity.x *= 0.55
		air_dodge_end_lag_time = AIR_DODGE_END_LAG_SECONDS
	dodge_state = ""
	dodge_time = 0.0
	facing_locked = false

func _move_and_finalize(was_on_floor: bool) -> void:
	move_and_slide()
	var now_on_floor := is_on_floor()
	if not was_on_floor and now_on_floor:
		_on_landed_from_air()
	was_on_floor_last_frame = now_on_floor

func _on_landed_from_air() -> void:
	var landed_while_fast_fall := fast_fall_active
	fast_fall_active = false
	jump_cut_available = false
	coyote_time = COYOTE_TIME_SECONDS
	if attack_state != "" and attack_started_in_air:
		var data := _get_attack_data(attack_state)
		_apply_aerial_landing_lag(data, landed_while_fast_fall)
	if landing_lag_time > 0.0:
		_clear_attack_buffer()

func _apply_aerial_landing_lag(data: Dictionary, landed_while_fast_fall: bool = false) -> void:
	var landing_lag := float(data.get("landing_lag", AERIAL_LANDING_LAG_DEFAULT))
	var auto_cancel_lag := float(data.get("landing_lag_autocancel", AERIAL_LANDING_LAG_AUTO_CANCEL))
	var auto_cancel := _is_attack_auto_cancel_window(data)
	var resolved_lag := auto_cancel_lag if auto_cancel else landing_lag
	if landed_while_fast_fall and not auto_cancel:
		resolved_lag += AERIAL_FAST_FALL_LANDING_LAG_BONUS
	landing_lag_time = maxf(landing_lag_time, maxf(0.0, resolved_lag))
	_clear_attack_state()

func _is_attack_auto_cancel_window(data: Dictionary) -> bool:
	if attack_phase == "startup":
		return true
	if attack_phase != "recovery":
		return false
	var recovery_duration := attack_recovery_duration if attack_recovery_duration > 0.0 else float(data.get("recovery", 0.20))
	if recovery_duration <= 0.0:
		return false
	var recovery_progress := clampf(attack_time / recovery_duration, 0.0, 1.0)
	return recovery_progress >= AERIAL_AUTO_CANCEL_RECOVERY_PROGRESS

func _apply_air_gravity(delta: float) -> void:
	if is_on_floor() or is_ledge_hanging:
		return
	_try_start_fast_fall()
	var gravity_scale := FAST_FALL_GRAVITY_MULTIPLIER if fast_fall_active else 1.0
	velocity.y += gravity * gravity_scale * delta
	if fast_fall_active:
		velocity.y = minf(velocity.y, FAST_FALL_MAX_SPEED)

func _apply_jump_cut() -> void:
	if is_ai:
		jump_cut_available = false
		return
	if not jump_cut_available:
		return
	if is_ledge_hanging or is_on_floor():
		jump_cut_available = false
		return
	if attack_state != "":
		jump_cut_available = false
		return
	if is_knocked_down or getup_time > 0.0:
		jump_cut_available = false
		return
	if hitstun_time > 0.0 or blockstun_time > 0.0:
		jump_cut_available = false
		return
	if velocity.y >= 0.0:
		jump_cut_available = false
		return
	if _is_action_pressed("jump"):
		return
	velocity.y *= JUMP_CUT_VELOCITY_MULTIPLIER
	jump_cut_available = false

func _try_start_fast_fall() -> bool:
	if fast_fall_active:
		return true
	if is_ai:
		return false
	if velocity.y < FAST_FALL_MIN_DESCENT_SPEED:
		return false
	if down_input_buffer_time <= 0.0:
		return false
	if is_knocked_down or getup_time > 0.0:
		return false
	if hitstun_time > 0.0 or blockstun_time > 0.0:
		return false
	fast_fall_active = true
	return true

func _try_consume_buffered_jump() -> bool:
	if jump_buffer_time <= 0.0:
		return false
	if not _can_execute_jump():
		return false
	var using_air_jump := not is_on_floor() and coyote_time <= 0.0
	velocity.y = JUMP_VELOCITY
	jump_buffer_time = 0.0
	coyote_time = 0.0
	jump_cut_available = true
	fast_fall_active = false
	if using_air_jump:
		air_jumps_remaining = maxi(0, air_jumps_remaining - 1)
	return true

func _can_execute_jump() -> bool:
	if current_hp <= 0:
		return false
	if shield_break_time > 0.0:
		return false
	if dodge_time > 0.0:
		return false
	if air_dodge_end_lag_time > 0.0:
		return false
	if is_ledge_hanging:
		return false
	if landing_lag_time > 0.0:
		return false
	if _is_rooted():
		return false
	if is_knocked_down or getup_time > 0.0:
		return false
	if hitstun_time > 0.0 or blockstun_time > 0.0:
		return false
	if is_on_floor():
		return true
	if coyote_time > 0.0:
		return true
	return air_jumps_remaining > 0

func _sync_control_preset() -> void:
	var preset_value := str(Engine.get_meta(GameSettingsStore.ENGINE_META_KEY, ""))
	if preset_value == "":
		preset_value = GameSettingsStore.get_control_preset()
	control_preset = GameSettingsStore.normalize_control_preset(preset_value)

func _ensure_local_input_actions() -> void:
	local_input_prefix = str(LOCAL_INPUT_PREFIX_BY_PLAYER_ID.get(player_id, "p1"))
	local_gamepad_device = _resolve_local_gamepad_device()
	for base_action in LOCAL_INPUT_ACTIONS:
		var action_name := _build_local_input_action_name(base_action)
		_ensure_input_action_exists(action_name)
		_clear_action_events(action_name)
		_copy_joypad_events_to_local_action(base_action, action_name, local_gamepad_device)
		if player_id == 2:
			var keycodes: Array = PLAYER2_LOCAL_KEYBOARD_LAYOUT.get(base_action, [])
			for keycode_value in keycodes:
				_add_key_event_to_action(action_name, int(keycode_value))
		else:
			_copy_keyboard_events_to_local_action(base_action, action_name)

func _resolve_local_gamepad_device() -> int:
	var fallback_device := int(LOCAL_GAMEPAD_DEVICE_BY_PLAYER_ID.get(player_id, 0))
	var joypads := Input.get_connected_joypads()
	if joypads.is_empty():
		return fallback_device
	if player_id == 1:
		return int(joypads[0])
	if player_id == 2:
		if joypads.size() >= 2:
			return int(joypads[1])
		return fallback_device
	return fallback_device

func _ensure_input_action_exists(action_name: String) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

func _clear_action_events(action_name: String) -> void:
	if not InputMap.has_action(action_name):
		return
	for event in InputMap.action_get_events(action_name):
		InputMap.action_erase_event(action_name, event)

func _add_key_event_to_action(action_name: String, keycode: int) -> void:
	if not InputMap.has_action(action_name):
		return
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	InputMap.action_add_event(action_name, event)

func _copy_keyboard_events_to_local_action(source_action: String, local_action: String) -> void:
	if not InputMap.has_action(source_action):
		return
	for event in InputMap.action_get_events(source_action):
		if event is not InputEventKey:
			continue
		var key_event := (event as InputEventKey).duplicate()
		if key_event is InputEventKey:
			(key_event as InputEventKey).device = -1
		InputMap.action_add_event(local_action, key_event)

func _copy_joypad_events_to_local_action(source_action: String, local_action: String, device_id: int) -> void:
	if not InputMap.has_action(source_action):
		return
	for event in InputMap.action_get_events(source_action):
		if event is InputEventJoypadButton:
			var button_event := (event as InputEventJoypadButton).duplicate()
			if button_event is InputEventJoypadButton:
				(button_event as InputEventJoypadButton).device = device_id
			InputMap.action_add_event(local_action, button_event)
		elif event is InputEventJoypadMotion:
			var axis_event := (event as InputEventJoypadMotion).duplicate()
			if axis_event is InputEventJoypadMotion:
				(axis_event as InputEventJoypadMotion).device = device_id
			InputMap.action_add_event(local_action, axis_event)

func _build_local_input_action_name(base_action: String) -> String:
	return "%s_%s" % [local_input_prefix, base_action]

func _resolve_input_action(base_action: String) -> String:
	if player_id in [1, 2]:
		var local_action := _build_local_input_action_name(base_action)
		if InputMap.has_action(local_action):
			return local_action
	return base_action

func _is_action_pressed(base_action: String) -> bool:
	var resolved_action := _resolve_input_action(base_action)
	return InputMap.has_action(resolved_action) and Input.is_action_pressed(resolved_action)

func _is_action_just_pressed(base_action: String) -> bool:
	var resolved_action := _resolve_input_action(base_action)
	return InputMap.has_action(resolved_action) and Input.is_action_just_pressed(resolved_action)

func _get_axis_input(negative_action: String, positive_action: String) -> float:
	var resolved_negative := _resolve_input_action(negative_action)
	var resolved_positive := _resolve_input_action(positive_action)
	if not InputMap.has_action(resolved_negative) or not InputMap.has_action(resolved_positive):
		return 0.0
	return Input.get_axis(resolved_negative, resolved_positive)

func _is_block_input_pressed() -> bool:
	if _uses_classic_controls():
		return _is_back_input_pressed()
	return _is_action_pressed("block")

func _uses_classic_controls() -> bool:
	return control_preset == GameSettingsStore.CONTROL_PRESET_CLASSIC

func _is_back_input_pressed() -> bool:
	if facing >= 0:
		return _is_action_pressed("move_left")
	return _is_action_pressed("move_right")

func _apply_horizontal_intent(target_speed: float, delta: float, acceleration_scale: float = 1.0, deceleration_scale: float = 1.0) -> void:
	var resolved_target := target_speed
	if _is_rooted():
		resolved_target = 0.0
	var acceleration := (GROUND_ACCELERATION if is_on_floor() else AIR_ACCELERATION) * maxf(0.1, acceleration_scale)
	var deceleration := (GROUND_DECELERATION if is_on_floor() else AIR_DECELERATION) * maxf(0.1, deceleration_scale)
	var accelerating := absf(resolved_target) > absf(velocity.x)
	var target_sign := signf(resolved_target)
	var current_sign := signf(velocity.x)
	if not is_zero_approx(target_sign) and not is_zero_approx(current_sign) and target_sign != current_sign:
		accelerating = true
	var rate := acceleration if accelerating else deceleration
	velocity.x = move_toward(velocity.x, resolved_target, rate * delta)

func _process_ai(delta: float) -> void:
	if opponent == null:
		return
	ai_attack_cooldown = maxf(0.0, ai_attack_cooldown - delta)
	var distance = opponent.global_position.x - global_position.x
	var distance_abs := absf(distance)
	var ai_move_speed := MOVE_SPEED * _get_move_speed_multiplier()
	var preferred_range := _get_ai_profile_number("preferred_range", 56.0)
	var chase_range := _get_ai_profile_number("chase_range", 108.0)
	var retreat_range := _get_ai_profile_number("retreat_range", 20.0)
	var retreat_chance := _get_ai_profile_number("retreat_chance", 0.24)
	if attack_state == "":
		if _should_ai_block(distance):
			is_blocking = true
			ai_guard_mode = _resolve_ai_guard_mode()
			_apply_horizontal_intent(0.0, delta, BLOCK_ACCELERATION_SCALE, BLOCK_DECELERATION_SCALE)
			return

		is_blocking = false
		ai_guard_mode = "high"
		var target_speed := 0.0
		if distance_abs > chase_range:
			target_speed = signf(distance) * ai_move_speed * 0.86
		elif distance_abs > preferred_range:
			target_speed = signf(distance) * ai_move_speed * 0.62
		elif distance_abs < retreat_range and randf() < retreat_chance:
			target_speed = -signf(distance) * ai_move_speed * 0.42
		_apply_horizontal_intent(target_speed, delta)

		var dash_in_chance := _get_ai_profile_number("dash_in_chance", 0.08)
		if distance_abs > chase_range + 20.0 and dash_cooldown_timer <= 0.0 and is_on_floor() and not _is_rooted() and randf() < dash_in_chance:
			_start_dash()
			return

		if distance_abs <= preferred_range + 18.0 and ai_attack_cooldown <= 0.0:
			var ai_attack_kind := _select_ai_attack_kind(distance_abs)
			if ai_attack_kind != "":
				_request_attack(ai_attack_kind)
				var cooldown_min := _get_ai_profile_number("cooldown_min", 0.40)
				var cooldown_max := maxf(cooldown_min + 0.04, _get_ai_profile_number("cooldown_max", 0.72))
				ai_attack_cooldown = randf_range(cooldown_min, cooldown_max)
	else:
		is_blocking = false
		ai_guard_mode = "high"
		_apply_horizontal_intent(0.0, delta, 0.8, 1.2)

func _select_ai_attack_kind(distance: float) -> String:
	var candidates := _build_ai_attack_candidates(distance)
	return _pick_weighted_ai_attack(candidates)

func _build_ai_attack_weight_map(distance: float) -> Dictionary:
	var weight_map := {}
	var candidates := _build_ai_attack_candidates(distance)
	for candidate in candidates:
		if typeof(candidate) != TYPE_DICTIONARY:
			continue
		var entry := candidate as Dictionary
		var kind := str(entry.get("kind", ""))
		var weight := float(entry.get("weight", 0.0))
		if kind == "" or weight <= 0.0:
			continue
		weight_map[kind] = weight
	return weight_map

func _build_ai_attack_candidates(distance: float) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	_append_ai_attack_candidate(candidates, "light", 1.0, distance)
	_append_ai_attack_candidate(candidates, "heavy", 0.62 * _get_ai_profile_number("heavy_bias", 1.0), distance)
	_append_ai_attack_candidate(candidates, "throw", 0.44 * _get_ai_profile_number("throw_bias", 1.0), distance)
	_append_ai_attack_candidate(candidates, "special", 0.68 * _get_ai_profile_number("special_bias", 1.0), distance)
	var signature_bias := _get_ai_profile_number("signature_bias", 1.0)
	_append_ai_attack_candidate(candidates, "signature_a", 0.66 * signature_bias, distance)
	_append_ai_attack_candidate(candidates, "signature_b", 0.60 * signature_bias, distance)
	_append_ai_attack_candidate(candidates, "signature_c", 0.58 * signature_bias, distance)
	_append_ai_attack_candidate(candidates, "ultimate", 0.54 * _get_ai_profile_number("ultimate_bias", 1.0), distance)
	return candidates

func _append_ai_attack_candidate(candidates: Array[Dictionary], kind: String, base_weight: float, distance: float) -> void:
	if base_weight <= 0.0:
		return
	if not _can_trigger_ai_attack_kind(kind):
		return
	var weighted := base_weight * _get_ai_distance_weight(kind, distance)
	if weighted <= 0.0:
		return
	candidates.append({"kind": kind, "weight": weighted})

func _pick_weighted_ai_attack(candidates: Array[Dictionary]) -> String:
	if candidates.is_empty():
		return ""
	var total_weight := 0.0
	for candidate in candidates:
		if typeof(candidate) != TYPE_DICTIONARY:
			continue
		total_weight += maxf(0.0, float((candidate as Dictionary).get("weight", 0.0)))
	if total_weight <= 0.0:
		return str((candidates[0] as Dictionary).get("kind", ""))
	var roll := randf() * total_weight
	for candidate in candidates:
		if typeof(candidate) != TYPE_DICTIONARY:
			continue
		var entry := candidate as Dictionary
		roll -= maxf(0.0, float(entry.get("weight", 0.0)))
		if roll <= 0.0:
			return str(entry.get("kind", ""))
	return str((candidates[candidates.size() - 1] as Dictionary).get("kind", ""))

func _can_trigger_ai_attack_kind(kind: String) -> bool:
	if not _has_attack_kind(kind):
		return false
	if _is_silenced() and kind in ["special", "signature_a", "signature_b", "signature_c", "ultimate"]:
		return false
	return _can_trigger_attack_kind(kind)

func _get_ai_distance_weight(kind: String, distance: float) -> float:
	var weight := 1.0
	var attack_data := _get_attack_data(kind)
	var effect_type := _resolve_attack_effect_type(attack_data)
	if distance >= 78.0:
		if effect_type in ["projectile", "trap", "summon"]:
			weight *= 1.40
		elif kind in ["special", "signature_a", "signature_b", "signature_c", "ultimate"]:
			weight *= 1.18
		if kind in ["throw", "heavy"]:
			weight *= 0.58
	elif distance <= 30.0:
		if kind == "throw":
			weight *= 1.45
		elif kind == "heavy":
			weight *= 1.25
		elif kind == "light":
			weight *= 1.12
		if effect_type in ["projectile", "trap", "summon"]:
			weight *= 0.74
	return weight

func _resolve_attack_effect_type(attack_data: Dictionary) -> String:
	if attack_data.is_empty():
		return ""
	var effect_value: Variant = attack_data.get("effect", {})
	if typeof(effect_value) != TYPE_DICTIONARY:
		return ""
	return str((effect_value as Dictionary).get("type", ""))

func _is_training_dummy_active() -> bool:
	return training_dummy_enabled

func _process_training_dummy(delta: float) -> void:
	if opponent == null:
		is_blocking = false
		_apply_horizontal_intent(0.0, delta, 0.8, 1.2)
		return
	if attack_state != "":
		is_blocking = false
		ai_guard_mode = "high"
		_apply_horizontal_intent(0.0, delta, 0.8, 1.2)
		return

	_apply_horizontal_intent(0.0, delta, 0.8, 1.5)
	var wants_block := false
	match training_dummy_mode:
		"force_block":
			wants_block = _training_dummy_should_auto_block()
		"random_block":
			wants_block = _training_dummy_should_random_block()
		_:
			wants_block = false

	if wants_block and _can_enter_block():
		is_blocking = true
		ai_guard_mode = _resolve_ai_guard_mode()
	else:
		is_blocking = false
		ai_guard_mode = "high"

func _training_dummy_should_auto_block() -> bool:
	if not _can_enter_block():
		return false
	return _is_opponent_attack_threatening()

func _training_dummy_should_random_block() -> bool:
	if not _can_enter_block():
		return false
	var attack_signature := _get_opponent_attack_signature()
	if attack_signature == "":
		training_random_block_signature = ""
		return training_random_block_hold_time > 0.0 and _is_opponent_attack_threatening()
	if attack_signature != training_random_block_signature:
		training_random_block_signature = attack_signature
		if randf() < TRAINING_RANDOM_BLOCK_CHANCE:
			training_random_block_hold_time = TRAINING_RANDOM_BLOCK_HOLD_SECONDS
	return training_random_block_hold_time > 0.0 and _is_opponent_attack_threatening()

func _get_opponent_attack_signature() -> String:
	if opponent == null:
		return ""
	var state_value: Variant = opponent.get("attack_state")
	var state := str(state_value)
	if state == "":
		return ""
	return state

func _is_opponent_attack_threatening() -> bool:
	if opponent == null:
		return false
	var horizontal_distance := absf(opponent.global_position.x - global_position.x)
	if horizontal_distance > TRAINING_BLOCK_THREAT_DISTANCE:
		return false
	var state_value: Variant = opponent.get("attack_state")
	var state := str(state_value)
	return state != ""

func _should_ai_block(distance: float) -> bool:
	if not _can_enter_block():
		return false
	if ai_block_time > 0.0:
		return true
	if opponent == null:
		return false
	if absf(distance) > AI_BLOCK_REACTION_DISTANCE:
		return false
	if not _is_opponent_attack_in_block_window(opponent):
		return false
	if randf() < _get_ai_profile_number("block_chance", 0.35):
		ai_block_time = _get_ai_profile_number("block_hold_time", 0.18)
	return ai_block_time > 0.0

func _is_opponent_attack_in_block_window(target: Node) -> bool:
	if target == null:
		return false
	var attack_state := str(target.get("attack_state"))
	if attack_state == "":
		return false
	var horizontal_distance := absf(target.global_position.x - global_position.x)
	if horizontal_distance > AI_BLOCK_REACTION_DISTANCE:
		return false
	var attack_phase := str(target.get("attack_phase"))
	if attack_phase == "active":
		return true
	if attack_phase != "startup":
		return false
	var startup_duration := float(target.get("attack_startup_duration"))
	var startup_elapsed := float(target.get("attack_time"))
	var normalized_startup := maxf(0.08, startup_duration)
	var startup_progress := clampf(startup_elapsed / normalized_startup, 0.0, 1.0)
	var proximity_bonus := clampf((AI_BLOCK_REACTION_DISTANCE - horizontal_distance) / maxf(1.0, AI_BLOCK_REACTION_DISTANCE), 0.0, 1.0) * 0.18
	var threshold := clampf(AI_BLOCK_STARTUP_REACTION_THRESHOLD - proximity_bonus, 0.42, 0.90)
	return startup_progress >= threshold

func _resolve_ai_guard_mode() -> String:
	if not is_on_floor():
		return "air"
	if randf() < AI_GUARD_LOW_READ_CHANCE:
		return "low"
	return "high"

func set_training_dummy_options(enabled: bool, mode: String) -> void:
	training_dummy_enabled = enabled
	training_dummy_mode = mode if mode in ["stand", "force_block", "random_block"] else "stand"
	if not training_dummy_enabled or training_dummy_mode == "stand":
		training_random_block_hold_time = 0.0
		training_random_block_signature = ""
		is_blocking = false

func get_training_dummy_options() -> Dictionary:
	return {
		"enabled": training_dummy_enabled,
		"dummy_mode": training_dummy_mode
	}

func apply_attack_table(resource: Resource) -> void:
	if resource == null:
		return
	attack_table_resource = resource
	_setup_attack_data()
	_refresh_ai_style_profile()

func get_character_id() -> String:
	if attack_table_resource:
		var id_value: Variant = attack_table_resource.get("character_id")
		if typeof(id_value) == TYPE_STRING or typeof(id_value) == TYPE_STRING_NAME:
			var character_id := str(id_value).strip_edges()
			if character_id != "":
				return character_id
	return "player_%d" % player_id

func get_character_display_name() -> String:
	if attack_table_resource:
		var name_value: Variant = attack_table_resource.get("display_name")
		if typeof(name_value) == TYPE_STRING or typeof(name_value) == TYPE_STRING_NAME:
			var display_name := str(name_value).strip_edges()
			if display_name != "":
				return display_name
	return "Player %d" % player_id

func get_character_profile() -> Dictionary:
	var archetype_key := _resolve_archetype_key()
	var primary_signature := _resolve_signature_display_name("signature_a", "signature_primary", "Signature A")
	var alt_signature := _resolve_signature_display_name("signature_b", "signature_alt", "Signature B")
	var mix_signature := _resolve_signature_display_name("signature_c", "signature_mix", "Mix Signature")
	var ultimate_signature := _resolve_signature_display_name("ultimate", "signature_ultimate", "Ultimate")
	return {
		"character_id": get_character_id(),
		"display_name": get_character_display_name(),
		"archetype_key": archetype_key,
		"archetype_label_key": _resolve_archetype_label_key(archetype_key),
		"archetype_hint_key": _resolve_archetype_hint_key(archetype_key),
		"signature_primary": primary_signature,
		"signature_alt": alt_signature,
		"signature_names": {
			"signature_a": primary_signature,
			"signature_b": alt_signature,
			"signature_c": mix_signature,
			"ultimate": ultimate_signature
		}
	}

func _resolve_archetype_key() -> String:
	var preferred_range := _get_ai_profile_number("preferred_range", 56.0)
	var combo_pressure := _get_ai_profile_number("combo_pressure", 0.52)
	var signature_bias := _get_ai_profile_number("signature_bias", 1.0)
	var special_bias := _get_ai_profile_number("special_bias", 1.0)
	var heavy_bias := _get_ai_profile_number("heavy_bias", 1.0)
	var block_chance := _get_ai_profile_number("block_chance", 0.35)
	if combo_pressure >= 0.66 and preferred_range <= 58.0:
		return ARCHETYPE_RUSHDOWN
	if preferred_range >= 72.0 and signature_bias >= 1.20 and heavy_bias <= 0.95:
		return ARCHETYPE_ZONER
	if heavy_bias >= 1.14 or special_bias >= 1.14:
		return ARCHETYPE_BRUISER
	if block_chance >= 0.40:
		return ARCHETYPE_COUNTER
	return ARCHETYPE_ALL_ROUNDER

func _resolve_archetype_label_key(archetype_key: String) -> String:
	match archetype_key:
		ARCHETYPE_RUSHDOWN:
			return "ARCHETYPE_RUSHDOWN"
		ARCHETYPE_ZONER:
			return "ARCHETYPE_ZONER"
		ARCHETYPE_BRUISER:
			return "ARCHETYPE_BRUISER"
		ARCHETYPE_COUNTER:
			return "ARCHETYPE_COUNTER"
		_:
			return "ARCHETYPE_ALL_ROUNDER"

func _resolve_archetype_hint_key(archetype_key: String) -> String:
	match archetype_key:
		ARCHETYPE_RUSHDOWN:
			return "ARCHETYPE_HINT_RUSHDOWN"
		ARCHETYPE_ZONER:
			return "ARCHETYPE_HINT_ZONER"
		ARCHETYPE_BRUISER:
			return "ARCHETYPE_HINT_BRUISER"
		ARCHETYPE_COUNTER:
			return "ARCHETYPE_HINT_COUNTER"
		_:
			return "ARCHETYPE_HINT_ALL_ROUNDER"

func _resolve_signature_display_name(attack_key: String, meta_key: String, fallback: String) -> String:
	var attack_data := _get_attack_data(attack_key)
	var explicit_name := str(attack_data.get("display_name", "")).strip_edges()
	if explicit_name != "":
		return explicit_name
	var special_data := _get_attack_data("special")
	var special_meta_name := str(special_data.get(meta_key, "")).strip_edges()
	if special_meta_name != "":
		return special_meta_name
	if attack_table_resource:
		var meta_value: Variant = attack_table_resource.get(meta_key)
		if typeof(meta_value) == TYPE_STRING or typeof(meta_value) == TYPE_STRING_NAME:
			var direct_meta_name := str(meta_value).strip_edges()
			if direct_meta_name != "":
				return direct_meta_name
	return fallback

func _refresh_ai_style_profile() -> void:
	var character_id := get_character_id()
	ai_style_profile = AI_PROFILE_DEFAULT.duplicate(true)
	var override_value: Variant = AI_PROFILE_BY_CHARACTER.get(character_id, {})
	if typeof(override_value) == TYPE_DICTIONARY:
		var overrides := override_value as Dictionary
		for key in overrides.keys():
			ai_style_profile[str(key)] = overrides[key]

func _get_ai_profile_number(key: String, fallback: float) -> float:
	return float(ai_style_profile.get(key, fallback))

func _update_attack(delta: float) -> void:
	if attack_state == "":
		return
	if _try_execute_buffered_cancel():
		return
	_apply_hitbox_profile()
	attack_time += delta
	var data := _get_attack_data(attack_state)
	var startup_duration := attack_startup_duration if attack_startup_duration > 0.0 else float(data.get("startup", 0.06))
	var active_duration := attack_active_duration if attack_active_duration > 0.0 else float(data.get("active", 0.10))
	var recovery_duration := attack_recovery_duration if attack_recovery_duration > 0.0 else float(data.get("recovery", 0.20))
	if attack_recovery_override > 0.0:
		recovery_duration = attack_recovery_override
	if attack_phase == "startup" and attack_time >= startup_duration:
		attack_phase = "active"
		attack_time = 0.0
		_set_hitbox_active(true)
		_on_attack_active_started(data)
	elif attack_phase == "active" and attack_time >= active_duration:
		attack_phase = "recovery"
		attack_time = 0.0
		_set_hitbox_active(false)
	elif attack_phase == "recovery" and attack_time >= recovery_duration:
		_clear_attack_state()

	if attack_phase in ["startup", "active"] and data.has("lunge_speed"):
		velocity.x = float(data.get("lunge_speed", 320.0)) * facing

func _update_skill_runtime(delta: float) -> void:
	_update_skill_cooldowns(delta)
	_update_status_timers(delta)
	_update_skill_entities(delta)

func _update_skill_cooldowns(delta: float) -> void:
	if skill_cooldowns.is_empty():
		return
	var keys := skill_cooldowns.keys()
	for key in keys:
		var cooldown_key := str(key)
		var remaining := maxf(0.0, float(skill_cooldowns.get(cooldown_key, 0.0)) - delta)
		if remaining <= 0.0:
			skill_cooldowns.erase(cooldown_key)
		else:
			skill_cooldowns[cooldown_key] = remaining

func _update_status_timers(delta: float) -> void:
	status_silence_time = maxf(0.0, status_silence_time - delta)
	status_slow_time = maxf(0.0, status_slow_time - delta)
	status_root_time = maxf(0.0, status_root_time - delta)
	install_buff_time = maxf(0.0, install_buff_time - delta)
	if install_buff_time <= 0.0:
		install_damage_multiplier = 1.0
		install_speed_multiplier = 1.0
		install_startup_multiplier = 1.0
		install_chip_bonus = 0.0

func _update_skill_entities(delta: float) -> void:
	if skill_entities.is_empty():
		return
	if opponent == null or not is_instance_valid(opponent):
		_free_skill_entity_nodes(skill_entities)
		skill_entities.clear()
		return
	var remaining_entities: Array[Dictionary] = []
	for entity_variant in skill_entities:
		if typeof(entity_variant) != TYPE_DICTIONARY:
			continue
		var entity := (entity_variant as Dictionary).duplicate(true)
		var delay := maxf(0.0, float(entity.get("delay", 0.0)) - delta)
		entity["delay"] = delay
		if delay > 0.0:
			_update_skill_entity_visual(entity, true)
			remaining_entities.append(entity)
			continue
		var life := maxf(0.0, float(entity.get("life", 0.0)) - delta)
		entity["life"] = life
		if life <= 0.0:
			_free_skill_entity_node(entity)
			continue
		var velocity_value: Variant = entity.get("velocity", Vector2.ZERO)
		var velocity_vec: Vector2 = velocity_value if velocity_value is Vector2 else Vector2.ZERO
		var position_value: Variant = entity.get("position", global_position)
		var position_vec: Vector2 = position_value if position_value is Vector2 else global_position
		position_vec += velocity_vec * delta
		var entity_size_value: Variant = entity.get("size", Vector2(26, 18))
		var entity_size: Vector2 = entity_size_value if entity_size_value is Vector2 else Vector2(26, 18)
		var stage_bounds := _resolve_skill_entity_stage_bounds(entity_size)
		if position_vec.x < stage_bounds.x or position_vec.x > stage_bounds.y:
			if bool(entity.get("destroy_on_wall", true)):
				_free_skill_entity_node(entity)
				continue
			position_vec.x = clampf(position_vec.x, stage_bounds.x, stage_bounds.y)
			velocity_vec.x = 0.0
			entity["velocity"] = velocity_vec
		entity["position"] = position_vec
		_update_skill_entity_visual(entity, false)
		var destroy_on_hit := bool(entity.get("destroy_on_hit", true))
		if _skill_entity_hit_test(entity, opponent):
			var payload: Dictionary = entity.get("payload", {}) as Dictionary
			_apply_skill_entity_hit(opponent, payload)
			if destroy_on_hit:
				_free_skill_entity_node(entity)
				continue
		remaining_entities.append(entity)
	skill_entities = remaining_entities

func _update_skill_entity_visual(entity: Dictionary, is_delayed: bool) -> void:
	var node_value: Variant = entity.get("node", null)
	if node_value == null or not (node_value is Node2D):
		return
	var node := node_value as Node2D
	if not is_instance_valid(node):
		return
	var pos_value: Variant = entity.get("position", global_position)
	var pos: Vector2 = pos_value if pos_value is Vector2 else global_position
	node.global_position = pos
	var alpha := 0.9
	if is_delayed:
		var phase := sin(float(Time.get_ticks_msec()) * 0.02)
		alpha = 0.28 + (phase + 1.0) * 0.16
	node.modulate.a = clampf(alpha, 0.2, 0.95)

func _free_skill_entity_node(entity: Dictionary) -> void:
	var node_value: Variant = entity.get("node", null)
	if node_value == null or not (node_value is Node2D):
		return
	var node := node_value as Node2D
	if is_instance_valid(node):
		node.queue_free()

func _free_skill_entity_nodes(entities: Array[Dictionary]) -> void:
	for entry in entities:
		_free_skill_entity_node(entry)

func _skill_entity_hit_test(entity: Dictionary, target: Node2D) -> bool:
	if target == null:
		return false
	var position_value: Variant = entity.get("position", Vector2.ZERO)
	var entity_pos: Vector2 = position_value if position_value is Vector2 else Vector2.ZERO
	var size_value: Variant = entity.get("size", Vector2(26, 18))
	var entity_size: Vector2 = size_value if size_value is Vector2 else Vector2(26, 18)
	var target_half_size := _get_target_body_half_size(target)
	var target_pos := target.global_position + Vector2(0.0, -SKILL_ENTITY_TARGET_HEIGHT_OFFSET)
	return absf(entity_pos.x - target_pos.x) <= (entity_size.x * 0.5 + target_half_size.x) and absf(entity_pos.y - target_pos.y) <= (entity_size.y * 0.5 + target_half_size.y)

func _get_target_body_half_size(target: Node2D) -> Vector2:
	if target.has_node("CollisionShape2D"):
		var shape_node := target.get_node("CollisionShape2D") as CollisionShape2D
		if shape_node and shape_node.shape is RectangleShape2D:
			var rect := shape_node.shape as RectangleShape2D
			return rect.size * 0.5
	return Vector2(12.0, 24.0)

func _apply_skill_entity_hit(target: Node, payload: Dictionary) -> void:
	if target == null or not target.has_method("apply_damage"):
		return
	var kind := str(payload.get("attack_kind", "signature_a"))
	var base_damage := int(payload.get("damage", 8))
	var damage := int(round(float(base_damage) * _get_damage_multiplier_for_attack(kind)))
	var hitstun := float(payload.get("hitstun", HITSTUN_SECONDS))
	var knockback_value: Variant = payload.get("knockback", Vector2(180, -70))
	var knockback: Vector2 = knockback_value if knockback_value is Vector2 else Vector2(180, -70)
	knockback.x *= facing
	var meta := {
		"blockstun": float(payload.get("blockstun", BLOCKSTUN_SECONDS)),
		"counter": false,
		"block_type": str(payload.get("block_type", "mid")),
		"air_blockable": bool(payload.get("air_blockable", true)),
		"throw_techable": bool(payload.get("throw_techable", false)),
		"silence_seconds": float(payload.get("silence_seconds", 0.0)),
		"slow_seconds": float(payload.get("slow_seconds", 0.0)),
		"slow_factor": float(payload.get("slow_factor", 0.65)),
		"root_seconds": float(payload.get("root_seconds", 0.0)),
		"status_scale_on_block": float(payload.get("status_scale_on_block", 0.5)),
		"chip_bonus": install_chip_bonus
	}
	var hit_result: Variant = target.call("apply_damage", damage, knockback, hitstun, kind, meta)
	if typeof(hit_result) != TYPE_DICTIONARY:
		return
	var result_dict := hit_result as Dictionary
	if bool(result_dict.get("ignored", false)):
		return
	if bool(result_dict.get("blocked", false)):
		_gain_hype(HYPE_GAIN_ON_BLOCK)
		blocked_landed.emit(self, target, kind)
	else:
		_gain_hype(HYPE_GAIN_ON_HIT)
		var combo_count := _record_combo_hit(target)
		if result_dict.has("damage_total"):
			_record_combo_damage(int(result_dict.get("damage_total", 0)))
		hit_landed.emit(self, target, kind, false, combo_count)

func _on_attack_active_started(data: Dictionary) -> void:
	if attack_effect_triggered:
		return
	attack_effect_triggered = true
	_try_apply_attack_effect(data)

func _try_apply_attack_effect(data: Dictionary) -> void:
	var effect_value: Variant = data.get("effect", {})
	if typeof(effect_value) != TYPE_DICTIONARY:
		return
	var effect := effect_value as Dictionary
	var effect_type := str(effect.get("type", ""))
	match effect_type:
		"projectile", "trap", "summon":
			_spawn_skill_entity_from_effect(effect, data)
		"mobility":
			_apply_mobility_effect(effect)
		"buff":
			var buff_value: Variant = effect.get("buff", {})
			if typeof(buff_value) == TYPE_DICTIONARY:
				_apply_install_buff(buff_value as Dictionary)
		_:
			pass

func _spawn_skill_entity_from_effect(effect: Dictionary, data: Dictionary) -> void:
	var size_value: Variant = effect.get("size", Vector2(26, 18))
	var size: Vector2 = size_value if size_value is Vector2 else Vector2(26, 18)
	size.x = maxf(SKILL_ENTITY_MIN_SIZE.x, size.x)
	size.y = maxf(SKILL_ENTITY_MIN_SIZE.y, size.y)
	var base_offset := float(effect.get("spawn_offset_x", 36.0))
	var spawn_height := float(effect.get("spawn_offset_y", -14.0))
	var start_position := global_position + Vector2(base_offset * facing, spawn_height)
	var stage_bounds := _resolve_skill_entity_stage_bounds(size)
	start_position.x = clampf(start_position.x, stage_bounds.x, stage_bounds.y)
	var speed := float(effect.get("speed", 260.0))
	var velocity := Vector2(speed * facing, float(effect.get("velocity_y", 0.0)))
	var payload := {
		"attack_kind": attack_state,
		"damage": int(effect.get("damage", int(data.get("damage", 10)))),
		"hitstun": float(effect.get("hitstun", float(data.get("hitstun", HITSTUN_SECONDS)))),
		"blockstun": float(effect.get("blockstun", float(data.get("blockstun", BLOCKSTUN_SECONDS)))),
		"block_type": str(effect.get("block_type", str(data.get("block_type", "mid")))),
		"air_blockable": bool(effect.get("air_blockable", bool(data.get("air_blockable", true)))),
		"throw_techable": bool(effect.get("throw_techable", false)),
		"knockback": effect.get("knockback", data.get("knockback_ground", Vector2(180, -80))),
		"silence_seconds": float(effect.get("silence_seconds", 0.0)),
		"slow_seconds": float(effect.get("slow_seconds", 0.0)),
		"slow_factor": float(effect.get("slow_factor", 0.65)),
		"root_seconds": float(effect.get("root_seconds", 0.0)),
		"status_scale_on_block": float(effect.get("status_scale_on_block", 0.5))
	}
	var entity := {
		"type": str(effect.get("type", "projectile")),
		"position": start_position,
		"velocity": velocity if str(effect.get("type", "")) != "trap" else Vector2.ZERO,
		"size": size,
		"life": float(effect.get("duration", 0.9)),
		"delay": float(effect.get("spawn_delay", 0.0)),
		"destroy_on_hit": bool(effect.get("destroy_on_hit", true)),
		"destroy_on_wall": bool(effect.get("destroy_on_wall", str(effect.get("type", "")) != "trap")),
		"payload": payload
	}
	entity["node"] = _create_skill_entity_visual(str(entity.get("type", "projectile")), size, start_position)
	skill_entities.append(entity)

func _create_skill_entity_visual(effect_type: String, size: Vector2, start_position: Vector2) -> Node2D:
	if get_parent() == null:
		return null
	var node := Node2D.new()
	var sprite := Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = true
	sprite.z_index = 8
	sprite.texture = _get_skill_entity_texture(effect_type, size)
	node.add_child(sprite)
	node.global_position = start_position
	node.modulate = _get_skill_entity_color(effect_type)
	get_parent().add_child(node)
	return node

func _get_skill_entity_texture(effect_type: String, size: Vector2) -> Texture2D:
	var key := "%s:%dx%d" % [effect_type, int(round(size.x)), int(round(size.y))]
	if skill_entity_texture_cache.has(key):
		var cached: Variant = skill_entity_texture_cache.get(key, null)
		if cached is Texture2D:
			return cached as Texture2D
	var fill := _get_skill_entity_color(effect_type)
	var border := fill.darkened(0.45)
	var image := Image.create(maxi(4, int(round(size.x))), maxi(4, int(round(size.y))), false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	_draw_rect(image, Rect2i(0, 0, image.get_width(), image.get_height()), fill)
	_draw_rect_outline(image, Rect2i(0, 0, image.get_width(), image.get_height()), border)
	var texture := ImageTexture.create_from_image(image)
	skill_entity_texture_cache[key] = texture
	return texture

func _get_skill_entity_color(effect_type: String) -> Color:
	match effect_type:
		"projectile":
			return Color(1.0, 0.88, 0.48, 0.90)
		"trap":
			return Color(0.68, 0.94, 1.0, 0.85)
		"summon":
			return Color(0.86, 0.80, 1.0, 0.9)
		_:
			return Color(0.95, 0.95, 0.95, 0.86)

func _apply_mobility_effect(effect: Dictionary) -> void:
	var mode := str(effect.get("mode", "dash"))
	match mode:
		"teleport":
			var distance := float(effect.get("distance", 120.0))
			global_position.x = _clamp_player_to_stage_x(global_position.x + distance * facing)
			velocity.x = 0.0
		"rising":
			velocity.y = -absf(float(effect.get("rise_speed", 320.0)))
			velocity.x = float(effect.get("forward_speed", 120.0)) * facing
		_:
			velocity.x = float(effect.get("speed", 360.0)) * facing

func _resolve_skill_entity_stage_bounds(size: Vector2) -> Vector2:
	var half_width := maxf(2.0, size.x * 0.5)
	return Vector2(
		stage_left_x + half_width + SKILL_ENTITY_STAGE_PADDING,
		stage_right_x - half_width - SKILL_ENTITY_STAGE_PADDING
	)

func _clamp_player_to_stage_x(value: float) -> float:
	return clampf(value, stage_left_x + PLAYER_STAGE_MARGIN, stage_right_x - PLAYER_STAGE_MARGIN)

func set_stage_bounds(left_x: float, right_x: float) -> void:
	if right_x <= left_x:
		stage_left_x = DEFAULT_STAGE_LEFT_X
		stage_right_x = DEFAULT_STAGE_RIGHT_X
		stage_floor_y = DEFAULT_STAGE_FLOOR_Y
		return
	stage_left_x = left_x
	stage_right_x = right_x

func set_stage_geometry(left_x: float, right_x: float, floor_y: float) -> void:
	set_stage_bounds(left_x, right_x)
	stage_floor_y = floor_y

func _apply_install_buff(buff: Dictionary) -> void:
	install_buff_time = maxf(install_buff_time, float(buff.get("duration", 4.0)))
	install_damage_multiplier = maxf(install_damage_multiplier, float(buff.get("damage_multiplier", 1.0)))
	install_speed_multiplier = maxf(install_speed_multiplier, float(buff.get("speed_multiplier", 1.0)))
	install_startup_multiplier = minf(install_startup_multiplier, float(buff.get("startup_multiplier", 1.0)))
	install_chip_bonus = maxf(install_chip_bonus, float(buff.get("chip_bonus", 0.0)))

func _is_signature_attack(kind: String) -> bool:
	return kind in SIGNATURE_ATTACK_KEYS

func _is_silenced() -> bool:
	return status_silence_time > 0.0

func _is_rooted() -> bool:
	return status_root_time > 0.0

func _get_move_speed_multiplier() -> float:
	var multiplier := install_speed_multiplier
	if status_slow_time > 0.0:
		multiplier *= status_slow_factor
	return clampf(multiplier, 0.2, 2.0)

func _get_damage_multiplier_for_attack(kind: String) -> float:
	if install_buff_time <= 0.0:
		return 1.0
	if kind == "throw":
		return 1.0
	return maxf(1.0, install_damage_multiplier)

func _get_startup_multiplier_for_attack(kind: String) -> float:
	if install_buff_time <= 0.0:
		return 1.0
	if kind == "throw":
		return 1.0
	return clampf(install_startup_multiplier, 0.55, 1.0)

func _resolve_directional_special_kind() -> String:
	var pressing_down := down_input_buffer_time > 0.0
	var pressing_forward := forward_input_buffer_time > 0.0
	if pressing_forward and _has_attack_kind("signature_b"):
		return "signature_b"
	if pressing_down and _has_attack_kind("signature_c"):
		return "signature_c"
	if _has_attack_kind("signature_a"):
		return "signature_a"
	return ""

func _resolve_basic_attack_variant(base_kind: String) -> String:
	if base_kind == "":
		return ""
	if not is_on_floor():
		var air_kind := "%s_air" % base_kind
		if _has_attack_kind(air_kind):
			return air_kind
	if up_input_buffer_time > 0.0:
		var up_kind := "%s_up" % base_kind
		if _has_attack_kind(up_kind):
			return up_kind
	if down_input_buffer_time > 0.0:
		var down_kind := "%s_down" % base_kind
		if _has_attack_kind(down_kind):
			return down_kind
	return base_kind

func _can_trigger_attack_kind(kind: String) -> bool:
	if kind == "":
		return false
	if shield_break_time > 0.0:
		return false
	if dodge_time > 0.0:
		return false
	if is_ledge_hanging:
		return false
	if not _has_attack_kind(kind):
		return false
	if _is_signature_attack(kind) and _is_silenced():
		return false
	var cooldown := float(skill_cooldowns.get(kind, 0.0))
	if cooldown > 0.0:
		return false
	if kind == "ultimate" and hype_meter < HYPE_MAX:
		return false
	return true

func _start_skill_cooldown_for_kind(kind: String) -> void:
	var data := _get_attack_data(kind)
	var cooldown := float(data.get("cooldown", 0.0))
	if cooldown <= 0.0:
		return
	skill_cooldowns[kind] = cooldown

func _consume_hype_for_attack(kind: String) -> void:
	if kind != "ultimate":
		return
	hype_meter = maxf(0.0, hype_meter - HYPE_MAX)

func _gain_hype(amount: float) -> void:
	hype_meter = clampf(hype_meter + amount, 0.0, HYPE_MAX)

func _build_attack_meta(data: Dictionary, is_counter_hit: bool) -> Dictionary:
	var meta := {
		"blockstun": float(data.get("blockstun", BLOCKSTUN_SECONDS)),
		"counter": is_counter_hit,
		"block_type": str(data.get("block_type", "mid")),
		"air_blockable": bool(data.get("air_blockable", true)),
		"throw_techable": bool(data.get("throw_techable", false)),
		"chip_bonus": install_chip_bonus
	}
	var control_value: Variant = data.get("control", {})
	if typeof(control_value) == TYPE_DICTIONARY:
		var control := control_value as Dictionary
		meta["silence_seconds"] = float(control.get("silence_seconds", 0.0))
		meta["slow_seconds"] = float(control.get("slow_seconds", 0.0))
		meta["slow_factor"] = float(control.get("slow_factor", 0.65))
		meta["root_seconds"] = float(control.get("root_seconds", 0.0))
		meta["status_scale_on_block"] = float(control.get("status_scale_on_block", 0.5))
	return meta

func _apply_status_from_meta(attack_meta: Dictionary, blocked: bool) -> void:
	if attack_meta.is_empty():
		return
	var scale := 1.0
	if blocked:
		scale = clampf(float(attack_meta.get("status_scale_on_block", 0.5)), 0.0, 1.0)
	var silence_seconds := float(attack_meta.get("silence_seconds", 0.0)) * scale
	var slow_seconds := float(attack_meta.get("slow_seconds", 0.0)) * scale
	var root_seconds := float(attack_meta.get("root_seconds", 0.0)) * scale
	if silence_seconds > 0.0:
		status_silence_time = maxf(status_silence_time, minf(STATUS_SILENCE_CAP_SECONDS, silence_seconds))
	if slow_seconds > 0.0:
		status_slow_time = maxf(status_slow_time, minf(STATUS_SLOW_CAP_SECONDS, slow_seconds))
		status_slow_factor = clampf(float(attack_meta.get("slow_factor", status_slow_factor)), 0.35, 0.95)
	if root_seconds > 0.0:
		status_root_time = maxf(status_root_time, minf(STATUS_ROOT_CAP_SECONDS, root_seconds))

func _inject_generated_signature_attacks() -> void:
	runtime_attack_data = PlayerSignatureAttackBuilderStore.inject_generated_signature_attacks(
		runtime_attack_data,
		get_character_id(),
		ATTACK_DATA,
		SIGNATURE_ATTACK_KEYS,
		HITSTUN_SECONDS,
		BLOCKSTUN_SECONDS
	)

func _build_generated_signature_attack_from_special(kind: String, special_base: Dictionary, config: Dictionary) -> Dictionary:
	return PlayerSignatureAttackBuilderStore.build_generated_signature_attack_from_special(
		kind,
		special_base,
		config,
		HITSTUN_SECONDS,
		BLOCKSTUN_SECONDS
	)

func _get_generated_skill_profile_for_character(character_id: String) -> Dictionary:
	return GeneratedSkillProfilesStore.get_profile(character_id)

func _read_requested_attack() -> String:
	if _can_trigger_buffered_ultimate():
		_consume_ultimate_chord_buffer()
		return "ultimate"
	if _is_action_just_pressed("attack_special"):
		if not _is_silenced():
			var special_kind := _resolve_directional_special_kind()
			if special_kind != "":
				special_input_buffer_time = 0.0
				return special_kind
			if _has_attack_kind("special"):
				special_input_buffer_time = 0.0
				return "special"
	if _is_action_just_pressed("attack_light"):
		return _resolve_basic_attack_variant("light")
	if _is_action_just_pressed("attack_heavy"):
		heavy_input_buffer_time = 0.0
		return _resolve_basic_attack_variant("heavy")
	if _is_action_just_pressed("throw"):
		return "throw"
	return ""

func _update_command_input_buffers(delta: float) -> void:
	forward_input_buffer_time = maxf(0.0, forward_input_buffer_time - delta)
	up_input_buffer_time = maxf(0.0, up_input_buffer_time - delta)
	down_input_buffer_time = maxf(0.0, down_input_buffer_time - delta)
	special_input_buffer_time = maxf(0.0, special_input_buffer_time - delta)
	heavy_input_buffer_time = maxf(0.0, heavy_input_buffer_time - delta)
	if is_ai:
		return
	var forward_pressed_now := _is_forward_input_pressed()
	if forward_pressed_now and not forward_input_was_pressed:
		forward_input_buffer_time = DIRECTION_INPUT_BUFFER_SECONDS
	forward_input_was_pressed = forward_pressed_now
	if _is_action_pressed("move_up"):
		up_input_buffer_time = DIRECTION_INPUT_BUFFER_SECONDS
	if _is_action_pressed("move_down"):
		down_input_buffer_time = DIRECTION_INPUT_BUFFER_SECONDS
	if _is_action_just_pressed("attack_special"):
		special_input_buffer_time = ULTIMATE_CHORD_BUFFER_SECONDS
	if _is_action_just_pressed("attack_heavy"):
		heavy_input_buffer_time = ULTIMATE_CHORD_BUFFER_SECONDS

func _is_forward_input_pressed() -> bool:
	if facing >= 0:
		return _is_action_pressed("move_right")
	return _is_action_pressed("move_left")

func _is_forward_tap_pressed() -> bool:
	var forward_pressed_now := _is_forward_input_pressed()
	var edge_pressed := forward_pressed_now and not forward_input_was_pressed
	forward_input_was_pressed = forward_pressed_now
	if facing >= 0:
		return _is_action_just_pressed("move_right") or edge_pressed
	return _is_action_just_pressed("move_left") or edge_pressed

func _can_trigger_buffered_ultimate() -> bool:
	if special_input_buffer_time <= 0.0 or heavy_input_buffer_time <= 0.0:
		return false
	return _can_trigger_attack_kind("ultimate")

func _consume_ultimate_chord_buffer() -> void:
	special_input_buffer_time = 0.0
	heavy_input_buffer_time = 0.0

func _update_throw_tech_buffer(delta: float) -> void:
	throw_tech_buffer_time = maxf(0.0, throw_tech_buffer_time - delta)
	if is_ai:
		return
	if _is_throw_tech_input_pressed():
		throw_tech_buffer_time = THROW_TECH_BUFFER_SECONDS

func _is_throw_tech_input_pressed() -> bool:
	if _is_action_just_pressed("throw"):
		return true
	if _is_action_just_pressed("attack_light"):
		return true
	if _is_action_just_pressed("attack_heavy"):
		return true
	return false

func _request_attack(kind: String) -> void:
	if kind == "":
		return
	if not _can_trigger_attack_kind(kind):
		return
	if attack_state == "":
		_start_attack(kind)
	else:
		_buffer_attack(kind)

func _buffer_attack(kind: String) -> void:
	if kind == "":
		return
	if not _has_attack_kind(kind):
		return
	buffered_attack = kind
	buffered_attack_time = INPUT_BUFFER_SECONDS

func _clear_attack_buffer() -> void:
	buffered_attack = ""
	buffered_attack_time = 0.0

func _setup_attack_data() -> void:
	var external := _load_external_attack_table()
	runtime_attack_data = PlayerAttackRuntimeBuilderStore.build_runtime_attack_data(
		ATTACK_DATA,
		external,
		get_character_id(),
		SIGNATURE_ATTACK_KEYS,
		REQUIRED_BASE_ATTACK_KEYS,
		HITSTUN_SECONDS,
		BLOCKSTUN_SECONDS,
		self
	)

func _inject_directional_basic_attack_variants() -> void:
	runtime_attack_data = PlayerAttackRuntimeBuilderStore.inject_directional_basic_attack_variants(runtime_attack_data)

func _build_directional_variant_attack(base_data: Dictionary, overrides: Dictionary) -> Dictionary:
	return PlayerAttackRuntimeBuilderStore.build_directional_variant_attack(base_data, overrides)

func _load_external_attack_table() -> Dictionary:
	return PlayerAttackRuntimeBuilderStore.load_external_attack_table(
		use_external_attack_table,
		attack_table_resource,
		attack_table_path,
		DEFAULT_ATTACK_TABLE_PATH,
		self
	)

func _extract_attack_table_dictionary(resource: Resource) -> Dictionary:
	return PlayerAttackRuntimeBuilderStore.extract_attack_table_dictionary(resource)

func _sanitize_runtime_attack_data() -> void:
	runtime_attack_data = PlayerAttackRuntimeBuilderStore.sanitize_runtime_attack_data(
		runtime_attack_data,
		ATTACK_DATA,
		SIGNATURE_ATTACK_KEYS,
		REQUIRED_BASE_ATTACK_KEYS,
		self
	)

func _default_attack_entry_for_kind(kind: String) -> Dictionary:
	return PlayerAttackRuntimeBuilderStore.default_attack_entry_for_kind(
		kind,
		ATTACK_DATA,
		SIGNATURE_ATTACK_KEYS
	)

func _merge_attack_defaults(target: Dictionary, defaults: Dictionary) -> void:
	PlayerAttackRuntimeBuilderStore.merge_attack_defaults(target, defaults)

func _sanitize_attack_field_types(entry: Dictionary, defaults: Dictionary, attack_key: String) -> void:
	PlayerAttackRuntimeBuilderStore.sanitize_attack_field_types(entry, defaults, attack_key, self)

func _has_attack_kind(kind: String) -> bool:
	return runtime_attack_data.has(kind)

func _get_attack_data(kind: String) -> Dictionary:
	if runtime_attack_data.has(kind):
		return runtime_attack_data[kind]
	return {}

func _update_attack_buffer(delta: float) -> void:
	if buffered_attack == "":
		return
	buffered_attack_time = maxf(0.0, buffered_attack_time - delta)
	if buffered_attack_time <= 0.0:
		_clear_attack_buffer()

func _can_start_attack() -> bool:
	if current_hp <= 0:
		return false
	if shield_break_time > 0.0:
		return false
	if dodge_time > 0.0:
		return false
	if air_dodge_end_lag_time > 0.0:
		return false
	if attack_state != "":
		return false
	if is_dashing or is_knocked_down or getup_time > 0.0:
		return false
	if hitstun_time > 0.0 or blockstun_time > 0.0:
		return false
	if landing_lag_time > 0.0:
		return false
	return true

func _try_start_buffered_attack_from_neutral() -> void:
	if buffered_attack == "":
		return
	if not _can_start_attack():
		return
	var next_attack := buffered_attack
	_clear_attack_buffer()
	_start_attack(next_attack)

func _start_attack(kind: String) -> void:
	if not _has_attack_kind(kind):
		return
	if not _can_trigger_attack_kind(kind):
		return
	if is_knocked_down or getup_time > 0.0 or blockstun_time > 0.0:
		return
	is_blocking = false
	landing_lag_time = 0.0
	attack_recovery_override = -1.0
	next_attack_is_counter = false
	if guard_counter_time > 0.0 and kind != "throw":
		next_attack_is_counter = true
	guard_counter_time = 0.0
	attack_state = kind
	attack_phase = "startup"
	attack_time = 0.0
	attack_confirmed_hit = false
	attack_confirmed_block = false
	attack_effect_triggered = false
	attack_started_in_air = not is_on_floor()
	var data := _get_attack_data(kind)
	attack_startup_duration = float(data.get("startup", 0.06)) * _get_startup_multiplier_for_attack(kind)
	attack_active_duration = float(data.get("active", 0.10))
	attack_recovery_duration = float(data.get("recovery", 0.20))
	facing_locked = true
	facing_locked_direction = facing
	hit_targets.clear()
	_set_hitbox_active(false)
	_apply_hitbox_profile()
	_start_skill_cooldown_for_kind(kind)
	_consume_hype_for_attack(kind)

func _clear_attack_state() -> void:
	attack_state = ""
	attack_phase = ""
	attack_time = 0.0
	attack_recovery_override = -1.0
	next_attack_is_counter = false
	attack_confirmed_hit = false
	attack_confirmed_block = false
	attack_effect_triggered = false
	attack_startup_duration = 0.0
	attack_active_duration = 0.0
	attack_recovery_duration = 0.0
	attack_started_in_air = false
	facing_locked = false
	_set_hitbox_active(false)

func _apply_hitbox_profile() -> void:
	if attack_state == "":
		return
	var data := _get_attack_data(attack_state)
	var default_data := _default_attack_entry_for_kind(attack_state)
	var offset_ground := _read_attack_vector2(data, "hitbox_offset_ground", _read_attack_vector2(default_data, "hitbox_offset_ground", Vector2(22, 0)))
	var offset_air := _read_attack_vector2(data, "hitbox_offset_air", _read_attack_vector2(default_data, "hitbox_offset_air", Vector2(20, -6)))
	hitbox_offset = offset_ground if is_on_floor() else offset_air
	var shape := hitbox_shape.shape as RectangleShape2D
	if shape:
		var size_ground := _read_attack_vector2(data, "hitbox_size_ground", _read_attack_vector2(default_data, "hitbox_size_ground", Vector2(26, 18)))
		var size_air := _read_attack_vector2(data, "hitbox_size_air", _read_attack_vector2(default_data, "hitbox_size_air", Vector2(24, 16)))
		shape.size = size_ground if is_on_floor() else size_air

func _set_hitbox_active(active: bool) -> void:
	hitbox.set_deferred("monitoring", active)
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", not active)

func _update_facing() -> void:
	if facing_locked:
		facing = facing_locked_direction
	elif opponent:
		facing = -1 if opponent.global_position.x < global_position.x else 1
	hitbox.position = Vector2(hitbox_offset.x * facing, hitbox_offset.y)
	if visual:
		visual.flip_h = facing < 0

func _update_visual() -> void:
	if visual == null:
		return
	var base_tint := Color(0.75, 0.9, 1.0, 1.0) if player_id == 1 else Color(1.0, 0.82, 0.82, 1.0)
	var character_id := get_character_id()
	var palette_tint_value: Variant = CHARACTER_TINT_BY_ID.get(character_id, Color(1.0, 1.0, 1.0, 1.0))
	if palette_tint_value is Color:
		base_tint = base_tint.lerp(palette_tint_value as Color, 0.32)
	if guard_counter_time > 0.0 and current_hp > 0 and attack_state == "":
		base_tint = base_tint.lerp(Color(0.92, 1.0, 0.80, 1.0), 0.42)
	visual.modulate = base_tint

	var animation: StringName = &"idle"
	if current_hp <= 0:
		animation = &"ko"
	elif is_knocked_down:
		animation = &"fall"
	elif getup_time > 0.0:
		animation = &"getup"
	elif is_ledge_hanging:
		animation = &"jump"
	elif dodge_time > 0.0:
		animation = &"block" if is_on_floor() else &"jump"
	elif hitstun_time > 0.0:
		animation = _select_hit_reaction_animation()
	elif blockstun_time > 0.0 or (is_blocking and is_on_floor()):
		animation = &"block"
	elif attack_state != "":
		animation = StringName(attack_state)
	elif not is_on_floor():
		animation = &"jump"
	elif absf(velocity.x) > WALK_ANIMATION_SPEED_THRESHOLD:
		animation = &"walk"

	animation = _resolve_visual_animation(animation)
	var animation_speed := _resolve_attack_animation_speed_scale(animation)
	if not is_equal_approx(visual.speed_scale, animation_speed):
		visual.speed_scale = animation_speed

	if visual.animation != animation:
		visual.play(animation)
		return

	if visual.is_playing():
		return

	if _is_animation_loop(animation):
		visual.play(animation)
	elif runtime_sprite_frames and runtime_sprite_frames.has_animation(animation):
		var frame_count := runtime_sprite_frames.get_frame_count(animation)
		if frame_count > 0:
			visual.frame = frame_count - 1

func _on_hitbox_body_entered(body: Node) -> void:
	if body == self:
		return
	if not body.is_in_group("fighters"):
		return
	if hit_targets.has(body):
		return
	hit_targets[body] = true
	var data := _get_attack_data(attack_state)
	var default_data := _default_attack_entry_for_kind(attack_state)
	var knockback_ground := _read_attack_vector2(data, "knockback_ground", _read_attack_vector2(default_data, "knockback_ground", Vector2(150, -65)))
	var knockback_air := _read_attack_vector2(data, "knockback_air", _read_attack_vector2(default_data, "knockback_air", Vector2(120, -110)))
	var knockback = knockback_ground if is_on_floor() else knockback_air
	var hitstun := float(data.get("hitstun", HITSTUN_SECONDS))
	var damage := int(data.get("damage", 0))
	damage = int(round(float(damage) * _get_damage_multiplier_for_attack(attack_state)))
	var is_counter_hit := next_attack_is_counter and attack_state != "throw"
	var predicted_combo_count := _peek_combo_hit_count(body)
	if is_counter_hit:
		damage += GUARD_COUNTER_DAMAGE_BONUS
		hitstun += GUARD_COUNTER_HITSTUN_BONUS
		knockback *= GUARD_COUNTER_KNOCKBACK_SCALE

	var hit_zone := ""
	if body is CharacterBody2D:
		hit_zone = _resolve_hurtbox_hit_zone(
			body as CharacterBody2D,
			_get_current_attack_hitbox_rect(),
			str(data.get("block_type", "mid"))
		)
		if hit_zone == "":
			hit_targets.erase(body)
			return
		damage = _apply_hit_zone_damage_modifier(damage, hit_zone)
		knockback = _apply_hit_zone_knockback_modifier(knockback, hit_zone)

	damage = _apply_combo_damage_scaling(damage, predicted_combo_count, attack_state)
	knockback.x *= facing
	if body.has_method("apply_damage"):
		var attack_meta := _build_attack_meta(data, is_counter_hit)
		if hit_zone != "":
			attack_meta["hit_zone"] = hit_zone
		var hit_result: Variant = body.apply_damage(
			damage,
			knockback,
			hitstun,
			attack_state,
			attack_meta
		)
		var was_throw_teched := false
		if typeof(hit_result) == TYPE_DICTIONARY:
			was_throw_teched = bool((hit_result as Dictionary).get("throw_teched", false))
		if was_throw_teched:
			attack_confirmed_block = false
			attack_confirmed_hit = false
			_on_attack_blocked(data)
			_apply_throw_tech_pushback(knockback)
			next_attack_is_counter = false
			_reset_combo_chain()
			if is_ai:
				ai_attack_cooldown = maxf(ai_attack_cooldown, 0.32)
			_record_training_exchange("throw_tech", attack_state, data, hit_result as Dictionary, false, 0, 0, damage)
			throw_teched.emit(self, body)
			return

		var was_blocked := false
		if typeof(hit_result) == TYPE_DICTIONARY:
			was_blocked = bool((hit_result as Dictionary).get("blocked", false))
		elif typeof(hit_result) == TYPE_BOOL:
			was_blocked = bool(hit_result)

		if was_blocked:
			attack_confirmed_block = true
			_gain_hype(HYPE_GAIN_ON_BLOCK)
			_on_attack_blocked(data)
			next_attack_is_counter = false
			_reset_combo_chain()
			if is_ai:
				_plan_ai_combo_follow_up(true)
			if typeof(hit_result) == TYPE_DICTIONARY:
				_record_training_exchange("block", attack_state, data, hit_result as Dictionary, false, 0, 0, damage)
			blocked_landed.emit(self, body, attack_state)
		else:
			var was_ignored := false
			if typeof(hit_result) == TYPE_DICTIONARY:
				was_ignored = bool((hit_result as Dictionary).get("ignored", false))
			if was_ignored:
				hit_targets.erase(body)
				return
			attack_confirmed_hit = true
			_gain_hype(HYPE_GAIN_ON_HIT)
			var combo_count := _record_combo_hit(body)
			var combo_damage := combo_damage_total
			if typeof(hit_result) == TYPE_DICTIONARY:
				combo_damage = _record_combo_damage(int((hit_result as Dictionary).get("damage_total", 0)))
			if typeof(hit_result) == TYPE_DICTIONARY:
				_record_training_exchange("hit", attack_state, data, hit_result as Dictionary, is_counter_hit, combo_count, combo_damage, damage)
			if is_ai:
				_plan_ai_combo_follow_up(false)
			hit_landed.emit(self, body, attack_state, is_counter_hit, combo_count)
			next_attack_is_counter = false

func _apply_throw_tech_pushback(knockback: Vector2) -> void:
	var push_direction := signf(knockback.x)
	if is_zero_approx(push_direction):
		push_direction = float(facing)
	velocity.x = -push_direction * THROW_TECH_PUSHBACK
	velocity.y = minf(velocity.y, 0.0)

func _get_current_attack_hitbox_rect() -> Rect2:
	var size := Vector2(24.0, 16.0)
	if hitbox_shape and hitbox_shape.shape is RectangleShape2D:
		size = (hitbox_shape.shape as RectangleShape2D).size
	var center := hitbox.global_position
	return Rect2(center - size * 0.5, size)

func _resolve_hurtbox_hit_zone(target: CharacterBody2D, hitbox_rect: Rect2, attack_block_type: String) -> String:
	if target == null:
		return ""
	var zones := _build_target_hurtbox_zones(target)
	if zones.is_empty():
		return ""
	var allowed_zones := _resolve_allowed_hurt_zones(attack_block_type)
	var best_zone := ""
	var best_overlap_area := 0.0
	for zone_entry in zones:
		if typeof(zone_entry) != TYPE_DICTIONARY:
			continue
		var entry := zone_entry as Dictionary
		var zone_name := str(entry.get("name", ""))
		if zone_name == "" or not allowed_zones.has(zone_name):
			continue
		var rect_value: Variant = entry.get("rect", Rect2())
		if rect_value is not Rect2:
			continue
		var overlap := hitbox_rect.intersection(rect_value as Rect2)
		if overlap.size.x <= 0.0 or overlap.size.y <= 0.0:
			continue
		var overlap_area := overlap.size.x * overlap.size.y
		if overlap_area > best_overlap_area:
			best_overlap_area = overlap_area
			best_zone = zone_name
	return best_zone

func _build_target_hurtbox_zones(target: CharacterBody2D) -> Array[Dictionary]:
	var half_size := _get_target_body_half_size(target)
	var center := target.global_position
	var head_size := Vector2(half_size.x * HURTBOX_HEAD_SCALE.x * 2.0, half_size.y * HURTBOX_HEAD_SCALE.y * 2.0)
	var torso_size := Vector2(half_size.x * HURTBOX_TORSO_SCALE.x * 2.0, half_size.y * HURTBOX_TORSO_SCALE.y * 2.0)
	var legs_size := Vector2(half_size.x * HURTBOX_LEGS_SCALE.x * 2.0, half_size.y * HURTBOX_LEGS_SCALE.y * 2.0)
	var is_airborne := not target.is_on_floor()
	if is_airborne:
		legs_size.y *= 0.72
	var head_center := center + Vector2(0.0, -half_size.y * 0.62)
	var torso_center := center + Vector2(0.0, -half_size.y * 0.08)
	var legs_center := center + Vector2(0.0, half_size.y * 0.56)
	return [
		{"name": "head", "rect": Rect2(head_center - head_size * 0.5, head_size)},
		{"name": "torso", "rect": Rect2(torso_center - torso_size * 0.5, torso_size)},
		{"name": "legs", "rect": Rect2(legs_center - legs_size * 0.5, legs_size)}
	]

func _resolve_allowed_hurt_zones(attack_block_type: String) -> PackedStringArray:
	match attack_block_type:
		"low":
			return PackedStringArray(["legs", "torso"])
		"overhead", "high":
			return PackedStringArray(["head", "torso"])
		_:
			return PackedStringArray(["head", "torso", "legs"])

func _apply_hit_zone_damage_modifier(base_damage: int, hit_zone: String) -> int:
	match hit_zone:
		"head":
			return base_damage + HIT_ZONE_HEAD_DAMAGE_BONUS
		"legs":
			return maxi(1, base_damage - HIT_ZONE_LEGS_DAMAGE_PENALTY)
		_:
			return base_damage

func _apply_hit_zone_knockback_modifier(base_knockback: Vector2, hit_zone: String) -> Vector2:
	var adjusted := base_knockback
	match hit_zone:
		"head":
			adjusted.y -= HIT_ZONE_HEAD_LAUNCH_BONUS
		"legs":
			adjusted.y += HIT_ZONE_LEGS_LAUNCH_PENALTY
		_:
			pass
	return adjusted

func _is_animation_loop(animation_name: StringName) -> bool:
	if runtime_sprite_frames == null:
		return false
	if not runtime_sprite_frames.has_animation(animation_name):
		return false
	return runtime_sprite_frames.get_animation_loop(animation_name)

func _can_enter_block() -> bool:
	if current_hp <= 0:
		return false
	if shield_break_time > 0.0 or shield_broken:
		return false
	if dodge_time > 0.0:
		return false
	if shield_meter < SHIELD_BLOCK_MIN_REQUIRED:
		return false
	if attack_state != "" or is_dashing:
		return false
	if is_knocked_down or getup_time > 0.0:
		return false
	if hitstun_time > 0.0 or blockstun_time > 0.0:
		return false
	return true

func _get_guard_mode() -> String:
	if not is_blocking:
		return "none"
	if not is_on_floor():
		return "air"
	if is_ai:
		return ai_guard_mode
	if _is_action_pressed("move_down"):
		return "low"
	return "high"

func _can_block_hit(knockback: Vector2, attack_kind: String, attack_meta: Dictionary) -> bool:
	if attack_kind == "throw":
		return false
	if not is_blocking:
		return false
	if not _can_enter_block():
		return false
	var guard_mode := _get_guard_mode()
	if guard_mode == "air":
		var block_type := str(attack_meta.get("block_type", "mid"))
		if not bool(attack_meta.get("air_blockable", true)):
			return false
	var attack_direction := signf(knockback.x)
	if is_zero_approx(attack_direction):
		return true
	return int(attack_direction) == -facing

func _can_cancel_into(next_attack: String) -> bool:
	if attack_state == "":
		return false
	if attack_phase == "startup":
		return false
	var current_data: Dictionary = _get_attack_data(attack_state)
	var options: Array = current_data.get("cancel_options", [])
	if not options.has(next_attack):
		return false
	var allows_hit_cancel := bool(current_data.get("cancel_on_hit", false))
	var allows_block_cancel := bool(current_data.get("cancel_on_block", false))
	if allows_hit_cancel and attack_confirmed_hit:
		return true
	if allows_block_cancel and attack_confirmed_block:
		return true
	return false

func _try_execute_buffered_cancel() -> bool:
	if buffered_attack == "":
		return false
	if not _can_cancel_into(buffered_attack):
		return false
	var next_attack := buffered_attack
	_clear_attack_buffer()
	_start_attack(next_attack)
	return true

func _plan_ai_combo_follow_up(was_blocked: bool) -> void:
	if not is_ai:
		return
	var pressure := _get_ai_profile_number("combo_pressure", 0.52)
	if attack_state == "light":
		var chance := pressure * (0.62 if was_blocked else 1.0)
		if randf() < chance:
			var extension := _select_ai_combo_extension(was_blocked)
			if extension != "":
				_buffer_attack(extension)
	elif attack_state == "heavy" and not was_blocked and randf() < pressure * 0.78:
		var extension := _select_ai_combo_extension(false)
		if extension != "":
			_buffer_attack(extension)

func _select_ai_combo_extension(was_blocked: bool) -> String:
	var preferred: Array[String] = []
	if was_blocked:
		preferred = ["throw", "heavy", "signature_b", "light"]
	else:
		preferred = ["heavy", "special", "signature_b", "signature_a", "light"]
	for kind in preferred:
		if _can_trigger_ai_attack_kind(kind):
			return kind
	return ""

func _record_combo_hit(target: Node) -> int:
	if combo_target == target and combo_chain_timer > 0.0:
		combo_hits += 1
	else:
		combo_target = target
		combo_hits = 1
		combo_damage_total = 0
	combo_chain_timer = COMBO_CHAIN_TIMEOUT_SECONDS
	return combo_hits

func _record_combo_damage(event_damage: int) -> int:
	combo_damage_total += maxi(0, event_damage)
	return combo_damage_total

func _peek_combo_hit_count(target: Node) -> int:
	if combo_target == target and combo_chain_timer > 0.0:
		return combo_hits + 1
	return 1

func _resolve_combo_attack_tier(attack_kind: String) -> String:
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
	return "special"

func _apply_combo_damage_scaling(base_damage: int, combo_count: int, attack_kind: String = "") -> int:
	if combo_count <= 1:
		return base_damage
	var tier := _resolve_combo_attack_tier(attack_kind)
	var profile_value: Variant = COMBO_SCALING_PROFILE_BY_TIER.get(tier, {})
	var profile: Dictionary = {}
	if typeof(profile_value) == TYPE_DICTIONARY:
		profile = profile_value as Dictionary
	var step := float(profile.get("step", COMBO_DAMAGE_SCALING_STEP))
	var min_scale := float(profile.get("min", COMBO_DAMAGE_SCALING_MIN))
	var scaled_hits := combo_count - 1
	var scale := maxf(min_scale, 1.0 - float(scaled_hits) * step)
	var scaled_damage := int(round(float(base_damage) * scale))
	return maxi(COMBO_MIN_DAMAGE, scaled_damage)

func _update_combo_chain(delta: float) -> void:
	if combo_chain_timer <= 0.0:
		return
	combo_chain_timer = maxf(0.0, combo_chain_timer - delta)
	if combo_chain_timer <= 0.0:
		_reset_combo_chain()

func _reset_combo_chain() -> void:
	combo_target = null
	combo_hits = 0
	combo_damage_total = 0
	combo_chain_timer = 0.0

func _on_attack_blocked(attack_data: Dictionary) -> void:
	if attack_state == "":
		return
	attack_phase = "recovery"
	attack_time = 0.0
	attack_recovery_override = float(attack_data.get("block_recovery", attack_data.get("recovery", 0.20)))
	_set_hitbox_active(false)
	velocity.x *= 0.3

func _get_attack_recovery_remaining_seconds(attack_data: Dictionary) -> float:
	if attack_state == "":
		return 0.0
	var startup := attack_startup_duration if attack_startup_duration > 0.0 else float(attack_data.get("startup", 0.0))
	var active := attack_active_duration if attack_active_duration > 0.0 else float(attack_data.get("active", 0.0))
	var recovery := attack_recovery_duration if attack_recovery_duration > 0.0 else float(attack_data.get("recovery", 0.0))
	if attack_recovery_override > 0.0:
		recovery = attack_recovery_override
	match attack_phase:
		"startup":
			return maxf(0.0, startup - attack_time) + active + recovery
		"active":
			return maxf(0.0, active - attack_time) + recovery
		"recovery":
			return maxf(0.0, recovery - attack_time)
	return recovery

func _seconds_to_frames(seconds: float) -> int:
	if seconds <= 0.0:
		return 0
	var fps := float(Engine.physics_ticks_per_second)
	if fps <= 0.0:
		fps = 60.0
	return int(round(seconds * fps))

func _record_training_exchange(
	event_type: String,
	attack_kind: String,
	attack_data: Dictionary,
	hit_result: Dictionary,
	is_counter_hit: bool,
	combo_count: int,
	combo_damage: int,
	requested_damage: int
) -> void:
	var stun_seconds := float(hit_result.get("stun_seconds", 0.0))
	var recovery_seconds := _get_attack_recovery_remaining_seconds(attack_data)
	var stun_frames := _seconds_to_frames(stun_seconds)
	var recovery_frames := _seconds_to_frames(recovery_seconds)
	last_training_info = {
		"event_type": event_type,
		"attack_kind": attack_kind,
		"block_type": str(attack_data.get("block_type", "mid")),
		"guard_mode": str(hit_result.get("guard_mode", "none")),
		"stun_seconds": stun_seconds,
		"stun_frames": stun_frames,
		"recovery_seconds": recovery_seconds,
		"recovery_frames": recovery_frames,
		"advantage_frames": stun_frames - recovery_frames,
		"combo_count": combo_count,
		"combo_damage": combo_damage,
		"requested_damage": requested_damage,
		"damage_total": int(hit_result.get("damage_total", 0)),
		"damage_taken": int(hit_result.get("damage_taken", 0)),
		"chip_damage": int(hit_result.get("chip_damage", 0)),
		"hp_before": int(hit_result.get("hp_before", 0)),
		"hp_after": int(hit_result.get("hp_after", 0)),
		"is_counter": is_counter_hit
	}

func _can_throw_tech(attack_meta: Dictionary) -> bool:
	if not bool(attack_meta.get("throw_techable", false)):
		return false
	if current_hp <= 0:
		return false
	if is_knocked_down or getup_time > 0.0:
		return false
	if hitstun_time > 0.0 or blockstun_time > 0.0:
		return false
	if wake_invuln_time > 0.0:
		return false
	if is_ai:
		return randf() < THROW_TECH_AI_CHANCE
	return throw_tech_buffer_time > 0.0

func _apply_throw_tech_defense(knockback: Vector2) -> void:
	var push_direction := signf(knockback.x)
	if is_zero_approx(push_direction):
		push_direction = -float(facing)
	velocity.x = push_direction * THROW_TECH_PUSHBACK
	velocity.y = minf(velocity.y, 0.0)
	hitstun_time = 0.0
	blockstun_time = 0.0
	is_blocking = false
	is_dashing = false
	guard_counter_time = 0.0
	throw_tech_buffer_time = 0.0
	ai_block_time = 0.0
	health_changed.emit()

func _apply_block_impact(
	amount: int,
	knockback: Vector2,
	hitstun_override: float,
	attack_kind: String,
	attack_meta: Dictionary
) -> int:
	var chip_scale := float(BLOCK_CHIP_BY_ATTACK.get(attack_kind, 0.0))
	chip_scale += maxf(0.0, float(attack_meta.get("chip_bonus", 0.0)))
	var chip_damage := maxi(0, int(round(float(amount) * chip_scale)))
	if chip_damage > 0:
		current_hp = max(0, current_hp - chip_damage)

	var pushback := maxf(40.0, absf(knockback.x) * 0.28)
	velocity = Vector2(signf(knockback.x) * pushback, minf(velocity.y, 0.0))
	var resolved_blockstun := float(attack_meta.get("blockstun", maxf(BLOCKSTUN_SECONDS, hitstun_override * 0.72)))
	blockstun_time = maxf(BLOCKSTUN_SECONDS, resolved_blockstun)
	hitstun_time = 0.0
	guard_counter_time = GUARD_COUNTER_WINDOW_SECONDS
	is_dashing = false
	attack_state = ""
	attack_phase = ""
	attack_recovery_override = -1.0
	attack_effect_triggered = false
	attack_startup_duration = 0.0
	attack_active_duration = 0.0
	attack_recovery_duration = 0.0
	facing_locked = false
	next_attack_is_counter = false
	_set_hitbox_active(false)
	_consume_shield(maxf(4.0, float(amount) * SHIELD_HIT_DAMAGE_SCALE))

	health_changed.emit()
	if current_hp <= 0:
		defeated.emit()
	return chip_damage

func _update_shield_state(delta: float) -> void:
	shield_regen_delay = maxf(0.0, shield_regen_delay - delta)
	if shield_break_time > 0.0:
		return
	if is_blocking:
		_consume_shield(SHIELD_DRAIN_PER_SECOND * delta)
		return
	if shield_regen_delay > 0.0:
		return
	if shield_meter >= SHIELD_MAX:
		return
	shield_meter = minf(SHIELD_MAX, shield_meter + SHIELD_REGEN_PER_SECOND * delta)

func _consume_shield(amount: float) -> void:
	if amount <= 0.0:
		return
	if shield_break_time > 0.0:
		return
	shield_meter = maxf(0.0, shield_meter - amount)
	shield_regen_delay = maxf(shield_regen_delay, SHIELD_REGEN_DELAY_SECONDS)
	if shield_meter <= 0.001:
		_trigger_shield_break()

func _trigger_shield_break() -> void:
	if shield_break_time > 0.0:
		return
	shield_meter = 0.0
	shield_broken = true
	shield_break_time = SHIELD_BREAK_STUN_SECONDS
	shield_regen_delay = maxf(shield_regen_delay, SHIELD_REGEN_DELAY_SECONDS + 0.30)
	is_blocking = false
	blockstun_time = 0.0
	hitstun_time = 0.0
	landing_lag_time = 0.0
	is_dashing = false
	guard_counter_time = 0.0
	_clear_attack_state()
	_clear_attack_buffer()
	velocity.x = -float(facing) * SHIELD_BREAK_PUSHBACK
	velocity.y = minf(velocity.y, -36.0)
	health_changed.emit()

func _recover_from_shield_break() -> void:
	if not shield_broken:
		return
	shield_broken = false
	shield_meter = maxf(shield_meter, SHIELD_BREAK_RECOVER_SHIELD)
	shield_regen_delay = maxf(shield_regen_delay, 0.24)

func _should_knockdown(knockback: Vector2, hitstun_override: float, attack_kind: String) -> bool:
	if attack_kind == "throw":
		return true
	if hitstun_override >= KNOCKDOWN_HITSTUN_THRESHOLD:
		return true
	return -knockback.y >= KNOCKDOWN_VERTICAL_THRESHOLD

func _apply_knockback_growth(base_knockback: Vector2, hp_before_hit: int) -> Vector2:
	if base_knockback == Vector2.ZERO:
		return base_knockback
	var damage_ratio := clampf(float(MAX_HP - hp_before_hit) / float(MAX_HP), 0.0, 1.0)
	var growth_scale := minf(KNOCKBACK_GROWTH_MAX_SCALE, 1.0 + damage_ratio * KNOCKBACK_GROWTH_PER_DAMAGE_RATIO)
	return base_knockback * growth_scale

func _apply_directional_influence(base_knockback: Vector2, attack_meta: Dictionary) -> Vector2:
	if base_knockback.length() < DI_MIN_KNOCKBACK_SPEED:
		return base_knockback
	var di_input := _resolve_directional_influence_input(base_knockback, attack_meta)
	if di_input.length() < DI_INPUT_DEADZONE:
		return base_knockback
	var base_angle := base_knockback.angle()
	var target_angle := di_input.angle()
	var max_delta := deg_to_rad(DI_MAX_ANGLE_DEGREES)
	var delta_angle := wrapf(target_angle - base_angle, -PI, PI)
	var adjusted_angle := base_angle + clampf(delta_angle, -max_delta, max_delta)
	var adjusted := Vector2.from_angle(adjusted_angle) * base_knockback.length()
	var survival_alignment := 0.0
	if not is_zero_approx(base_knockback.x):
		survival_alignment = clampf(-signf(base_knockback.x) * di_input.x, 0.0, 1.0)
	if survival_alignment > 0.0:
		adjusted *= 1.0 - survival_alignment * DI_SURVIVAL_SCALE
	return adjusted

func _resolve_directional_influence_input(base_knockback: Vector2, attack_meta: Dictionary) -> Vector2:
	if attack_meta.has("di_override"):
		var override_value: Variant = attack_meta.get("di_override", Vector2.ZERO)
		if override_value is Vector2:
			var override_vec := override_value as Vector2
			if override_vec.length() >= DI_INPUT_DEADZONE:
				return override_vec.normalized()
	if is_ai:
		if randf() > AI_DI_CHANCE:
			return Vector2.ZERO
		var horizontal := -signf(base_knockback.x)
		if is_zero_approx(horizontal):
			horizontal = -float(facing)
		var vertical := -0.55 if base_knockback.y < 0.0 else -0.25
		return Vector2(horizontal, vertical).normalized()
	var input_vec := Vector2(
		_get_axis_input("move_left", "move_right"),
		_get_axis_input("move_up", "move_down")
	)
	if input_vec.length() < DI_INPUT_DEADZONE:
		return Vector2.ZERO
	return input_vec.normalized()

func _update_knockdown(delta: float) -> void:
	if not is_on_floor():
		return
	if _try_tech_recovery():
		return
	velocity.x = move_toward(velocity.x, 0.0, MOVE_SPEED * delta * 2.0)
	velocity.y = 0.0
	knockdown_time = maxf(0.0, knockdown_time - delta)
	if knockdown_time > 0.0:
		return
	is_knocked_down = false
	is_blocking = false
	tech_slide_time = 0.0
	tech_slide_speed = 0.0
	getup_time = GETUP_SECONDS
	velocity = Vector2.ZERO

func _try_tech_recovery() -> bool:
	if not is_knocked_down:
		return false
	if knockdown_time <= 0.02:
		return false
	var tech_kind := _poll_tech_input()
	if tech_kind == "":
		return false
	_start_tech_recovery(tech_kind)
	return true

func _poll_tech_input() -> String:
	if is_ai:
		if knockdown_time > KNOCKDOWN_GROUND_SECONDS - 0.08:
			if randf() < 0.22:
				ai_tech_decision_roll = randf() < 0.45
				return "roll" if ai_tech_decision_roll else "quick"
		return ""
	if _is_action_just_pressed("dash"):
		return "roll"
	if _is_action_just_pressed("jump") or _is_action_just_pressed("block"):
		return "quick"
	return ""

func _start_tech_recovery(tech_kind: String) -> void:
	is_knocked_down = false
	is_blocking = false
	knockdown_time = 0.0
	getup_time = TECH_GETUP_SECONDS
	wake_invuln_time = RESPAWN_INVULN_SECONDS
	guard_counter_time = 0.0
	tech_slide_time = 0.0
	tech_slide_speed = 0.0
	velocity = Vector2.ZERO
	if tech_kind == "roll":
		tech_slide_time = TECH_SLIDE_DURATION
		tech_slide_speed = -facing * TECH_SLIDE_SPEED
	tech_recovered.emit(self, tech_kind)

func apply_damage(
	amount: int,
	knockback: Vector2 = Vector2.ZERO,
	hitstun_override: float = HITSTUN_SECONDS,
	attack_kind: String = "",
	attack_meta: Dictionary = {}
) -> Dictionary:
	var result := {
		"blocked": false,
		"throw_teched": false,
		"knockdown": false,
		"defeated": false,
		"ignored": false,
		"stun_seconds": 0.0,
		"guard_mode": "none",
		"hp_before": current_hp,
		"hp_after": current_hp,
		"damage_total": 0,
		"damage_taken": 0,
		"chip_damage": 0,
		"requested_damage": amount
	}
	_reset_combo_chain()

	if current_hp <= 0:
		return result
	if is_ledge_hanging:
		_end_ledge_hang()
	if is_knocked_down or getup_time > 0.0 or wake_invuln_time > 0.0:
		result["ignored"] = true
		result["hp_after"] = current_hp
		return result

	if attack_kind == "throw" and _can_throw_tech(attack_meta):
		_apply_throw_tech_defense(knockback)
		result["throw_teched"] = true
		result["guard_mode"] = "throw_break"
		result["hp_after"] = current_hp
		throw_tech_buffer_time = 0.0
		return result

	var guard_mode := _get_guard_mode()
	if _can_block_hit(knockback, attack_kind, attack_meta):
		var chip_damage := _apply_block_impact(amount, knockback, hitstun_override, attack_kind, attack_meta)
		_apply_status_from_meta(attack_meta, true)
		result["blocked"] = true
		result["defeated"] = current_hp <= 0
		result["stun_seconds"] = blockstun_time
		result["guard_mode"] = guard_mode
		result["chip_damage"] = chip_damage
		result["damage_total"] = chip_damage
		result["damage_taken"] = 0
		result["hp_after"] = current_hp
		return result

	var hp_before := current_hp
	current_hp = max(0, current_hp - amount)
	var scaled_knockback := _apply_knockback_growth(knockback, hp_before)
	var final_knockback := _apply_directional_influence(scaled_knockback, attack_meta)
	_gain_hype(HYPE_GAIN_ON_TAKING_HIT)
	velocity = final_knockback
	hitstun_time = maxf(0.0, hitstun_override)
	blockstun_time = 0.0
	hit_reaction_animation = _resolve_hit_reaction_animation(final_knockback, hitstun_override)
	is_dashing = false
	is_blocking = false
	ai_block_time = 0.0
	ai_tech_decision_roll = false
	guard_counter_time = 0.0
	next_attack_is_counter = false
	attack_state = ""
	attack_phase = ""
	attack_recovery_override = -1.0
	attack_effect_triggered = false
	attack_startup_duration = 0.0
	attack_active_duration = 0.0
	attack_recovery_duration = 0.0
	facing_locked = false
	getup_time = 0.0
	wake_invuln_time = 0.0
	tech_slide_time = 0.0
	tech_slide_speed = 0.0
	_set_hitbox_active(false)
	_apply_status_from_meta(attack_meta, false)

	if _should_knockdown(final_knockback, hitstun_override, attack_kind):
		is_knocked_down = true
		knockdown_time = KNOCKDOWN_GROUND_SECONDS
		hit_reaction_animation = &"fall"
		ai_tech_decision_roll = false
		result["knockdown"] = true
	else:
		is_knocked_down = false
		knockdown_time = 0.0

	health_changed.emit()
	result["hp_before"] = hp_before
	result["hp_after"] = current_hp
	result["damage_total"] = hp_before - current_hp
	result["damage_taken"] = hp_before - current_hp
	result["stun_seconds"] = hitstun_time
	if current_hp <= 0:
		is_knocked_down = false
		getup_time = 0.0
		defeated.emit()
		result["defeated"] = true

	return result

func get_current_attack_block_type() -> String:
	if attack_state == "":
		return "mid"
	var attack_data := _get_attack_data(attack_state)
	return str(attack_data.get("block_type", "mid"))

func get_last_training_info() -> Dictionary:
	return last_training_info.duplicate(true)

func get_hype_meter() -> float:
	return hype_meter

func force_respawn(spawn_position: Vector2, facing_direction: int = 1) -> void:
	_release_occupied_ledge()
	global_position = spawn_position
	velocity = Vector2.ZERO
	current_hp = MAX_HP
	facing = 1 if facing_direction >= 0 else -1
	facing_locked = false
	facing_locked_direction = facing
	attack_state = ""
	attack_phase = ""
	attack_time = 0.0
	attack_recovery_override = -1.0
	attack_confirmed_hit = false
	attack_confirmed_block = false
	attack_effect_triggered = false
	attack_startup_duration = 0.0
	attack_active_duration = 0.0
	attack_recovery_duration = 0.0
	next_attack_is_counter = false
	_clear_attack_buffer()
	_set_hitbox_active(false)
	hit_targets.clear()
	is_dashing = false
	is_blocking = false
	is_knocked_down = false
	hitstun_time = 0.0
	blockstun_time = 0.0
	knockdown_time = 0.0
	getup_time = 0.0
	guard_counter_time = 0.0
	wake_invuln_time = WAKE_INVULN_SECONDS
	throw_tech_buffer_time = 0.0
	ai_block_time = 0.0
	ai_attack_cooldown = 0.0
	ai_tech_decision_roll = false
	training_random_block_hold_time = 0.0
	training_random_block_signature = ""
	status_silence_time = 0.0
	status_slow_time = 0.0
	status_root_time = 0.0
	install_buff_time = 0.0
	install_damage_multiplier = 1.0
	install_speed_multiplier = 1.0
	install_startup_multiplier = 1.0
	install_chip_bonus = 0.0
	hype_meter = 0.0
	shield_meter = SHIELD_MAX
	shield_regen_delay = 0.0
	shield_break_time = 0.0
	shield_broken = false
	tech_slide_time = 0.0
	tech_slide_speed = 0.0
	is_ledge_hanging = false
	ledge_side = 0
	ledge_hold_time = 0.0
	ledge_regrab_lock_time = 0.0
	dodge_state = ""
	dodge_time = 0.0
	dodge_cooldown_time = 0.0
	dodge_direction = facing
	air_dodge_end_lag_time = 0.0
	air_dodge_available = true
	air_jumps_remaining = MAX_AIR_JUMPS
	platform_drop_through_time = 0.0
	_update_platform_collision_mask()
	_free_skill_entity_nodes(skill_entities)
	skill_entities.clear()
	_reset_combo_chain()
	_update_facing()
	_update_visual()
	health_changed.emit()

func set_hitstop_active(active: bool) -> void:
	hitstop_active = active
	if active:
		velocity = Vector2.ZERO

func get_runtime_status_snapshot() -> Dictionary:
	return {
		"hype": hype_meter,
		"shield": shield_meter,
		"shield_max": SHIELD_MAX,
		"shield_break_seconds": shield_break_time,
		"shield_broken": shield_broken,
		"dodge_seconds": dodge_time,
		"dodge_mode": dodge_state,
		"air_dodge_ready": air_dodge_available,
		"air_jumps": air_jumps_remaining,
		"silence_seconds": status_silence_time,
		"slow_seconds": status_slow_time,
		"root_seconds": status_root_time,
		"install_seconds": install_buff_time,
		"cooldowns": {
			"signature_a": float(skill_cooldowns.get("signature_a", 0.0)),
			"signature_b": float(skill_cooldowns.get("signature_b", 0.0)),
			"signature_c": float(skill_cooldowns.get("signature_c", 0.0)),
			"ultimate": float(skill_cooldowns.get("ultimate", 0.0))
		}
	}

func get_skill_cooldown_remaining(kind: String) -> float:
	return float(skill_cooldowns.get(kind, 0.0))

func _select_hit_reaction_animation() -> StringName:
	if _has_runtime_animation(hit_reaction_animation):
		return hit_reaction_animation
	return &"hit"

func _resolve_visual_animation(animation_name: StringName) -> StringName:
	if _has_runtime_animation(animation_name):
		return animation_name
	var base_attack_animation := _resolve_base_attack_animation_name(animation_name)
	if base_attack_animation != animation_name and _has_runtime_animation(base_attack_animation):
		return base_attack_animation
	match animation_name:
		&"signature_a", &"signature_b", &"signature_c", &"ultimate":
			if _has_runtime_animation(&"special"):
				return &"special"
		&"hit_light", &"hit_heavy":
			if _has_runtime_animation(&"hit"):
				return &"hit"
		&"block":
			if _has_runtime_animation(&"idle"):
				return &"idle"
		&"fall":
			if _has_runtime_animation(&"hit_heavy"):
				return &"hit_heavy"
			if _has_runtime_animation(&"hit"):
				return &"hit"
		&"getup":
			if _has_runtime_animation(&"idle"):
				return &"idle"
	if _has_runtime_animation(&"idle"):
		return &"idle"
	return animation_name

func _resolve_base_attack_animation_name(animation_name: StringName) -> StringName:
	var animation_text := String(animation_name)
	if animation_text.begins_with("light_"):
		return &"light"
	if animation_text.begins_with("heavy_"):
		return &"heavy"
	return animation_name

func _resolve_attack_animation_speed_scale(animation_name: StringName) -> float:
	if attack_state == "":
		return 1.0
	var attack_animation := _resolve_base_attack_animation_name(StringName(attack_state))
	var is_attack_animation := animation_name == attack_animation
	if not is_attack_animation and animation_name == StringName(attack_state):
		is_attack_animation = true
	if not is_attack_animation and animation_name == &"special" and attack_state in ["signature_a", "signature_b", "signature_c", "ultimate"]:
		is_attack_animation = true
	if not is_attack_animation:
		return 1.0
	match attack_phase:
		"startup":
			return 0.90
		"active":
			return 1.18
		"recovery":
			return 0.82
		_:
			return 1.0

func _resolve_hit_reaction_animation(knockback: Vector2, hitstun_override: float) -> StringName:
	var heavy_hit := hitstun_override >= 0.20 or absf(knockback.y) >= 140.0
	if heavy_hit and _has_runtime_animation(&"hit_heavy"):
		return &"hit_heavy"
	if not heavy_hit and _has_runtime_animation(&"hit_light"):
		return &"hit_light"
	return &"hit"

func _has_runtime_animation(animation_name: StringName) -> bool:
	if runtime_sprite_frames == null:
		return false
	if not runtime_sprite_frames.has_animation(animation_name):
		return false
	return runtime_sprite_frames.get_frame_count(animation_name) > 0

func _start_dash() -> void:
	if _is_rooted():
		return
	facing_locked = false
	is_dashing = true
	is_blocking = false
	dash_time = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN
	velocity.x = facing * DASH_SPEED * _get_move_speed_multiplier()
	velocity.y = 0.0

func _setup_visual() -> void:
	if visual == null:
		return
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	runtime_sprite_frames = _resolve_runtime_sprite_frames()
	visual.sprite_frames = runtime_sprite_frames
	if visual.sprite_frames and visual.sprite_frames.has_animation("idle"):
		visual.play("idle")

func _resolve_runtime_sprite_frames() -> SpriteFrames:
	var fallback := _build_placeholder_sprite_frames()
	var external := _load_external_sprite_frames()
	if external == null:
		return fallback
	var merged := external.duplicate(true) as SpriteFrames
	if merged == null:
		return fallback
	_merge_missing_animations(merged, fallback)
	return merged

func _load_external_sprite_frames() -> SpriteFrames:
	if not use_external_sprite_frames:
		return null
	if sprite_frames_resource:
		return sprite_frames_resource
	var path := sprite_frames_path.strip_edges()
	if path == "":
		path = DEFAULT_SPRITE_FRAMES_PATH
	if not ResourceLoader.exists(path):
		return null
	var loaded = load(path)
	if loaded is SpriteFrames:
		return loaded as SpriteFrames
	push_warning("Sprite frames resource is not SpriteFrames: %s" % path)
	return null

func _merge_missing_animations(target: SpriteFrames, fallback: SpriteFrames) -> void:
	for animation_name in REQUIRED_ANIMATION_NAMES:
		var has_required := target.has_animation(animation_name) and target.get_frame_count(animation_name) > 0
		if not has_required:
			_copy_animation(fallback, target, animation_name)
			continue
		var profile: Dictionary = ANIMATION_PROFILES.get(animation_name, {})
		if profile.has("fps"):
			target.set_animation_speed(animation_name, float(profile["fps"]))
		if profile.has("loop"):
			target.set_animation_loop(animation_name, bool(profile["loop"]))

func _copy_animation(source: SpriteFrames, target: SpriteFrames, animation_name: StringName) -> void:
	if not source.has_animation(animation_name):
		return
	if target.has_animation(animation_name):
		target.remove_animation(animation_name)
	target.add_animation(animation_name)
	target.set_animation_speed(animation_name, source.get_animation_speed(animation_name))
	target.set_animation_loop(animation_name, source.get_animation_loop(animation_name))
	for frame_index in range(source.get_frame_count(animation_name)):
		target.add_frame(
			animation_name,
			source.get_frame_texture(animation_name, frame_index),
			source.get_frame_duration(animation_name, frame_index)
		)

func _build_placeholder_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	_add_placeholder_animation(
		frames,
		"idle",
		[_make_placeholder_texture("idle")],
		_profile_fps("idle", 8.0),
		_profile_loop("idle", true)
	)
	_add_placeholder_animation(
		frames,
		"walk",
		[_make_placeholder_texture("walk", 0), _make_placeholder_texture("walk", 1)],
		_profile_fps("walk", 11.0),
		_profile_loop("walk", true)
	)
	_add_placeholder_animation(
		frames,
		"jump",
		[_make_placeholder_texture("jump")],
		_profile_fps("jump", 9.0),
		_profile_loop("jump", false)
	)
	_add_placeholder_animation(
		frames,
		"light",
		[_make_placeholder_texture("light")],
		_profile_fps("light", 18.0),
		_profile_loop("light", false)
	)
	_add_placeholder_animation(
		frames,
		"heavy",
		[_make_placeholder_texture("heavy")],
		_profile_fps("heavy", 9.0),
		_profile_loop("heavy", false)
	)
	_add_placeholder_animation(
		frames,
		"special",
		[_make_placeholder_texture("special")],
		_profile_fps("special", 10.0),
		_profile_loop("special", false)
	)
	_add_placeholder_animation(
		frames,
		"throw",
		[_make_placeholder_texture("throw")],
		_profile_fps("throw", 12.0),
		_profile_loop("throw", false)
	)
	_add_placeholder_animation(
		frames,
		"block",
		[_make_placeholder_texture("block", 0), _make_placeholder_texture("block", 1)],
		_profile_fps("block", 8.0),
		_profile_loop("block", true)
	)
	_add_placeholder_animation(
		frames,
		"hit_light",
		[_make_placeholder_texture("hit_light", 0), _make_placeholder_texture("hit_light", 1)],
		_profile_fps("hit_light", 11.0),
		_profile_loop("hit_light", false)
	)
	_add_placeholder_animation(
		frames,
		"hit_heavy",
		[_make_placeholder_texture("hit_heavy", 0), _make_placeholder_texture("hit_heavy", 1)],
		_profile_fps("hit_heavy", 8.0),
		_profile_loop("hit_heavy", false)
	)
	_add_placeholder_animation(
		frames,
		"hit",
		[_make_placeholder_texture("hit")],
		_profile_fps("hit", 10.0),
		_profile_loop("hit", false)
	)
	_add_placeholder_animation(
		frames,
		"fall",
		[_make_placeholder_texture("fall", 0), _make_placeholder_texture("fall", 1)],
		_profile_fps("fall", 8.0),
		_profile_loop("fall", false)
	)
	_add_placeholder_animation(
		frames,
		"getup",
		[
			_make_placeholder_texture("getup", 0),
			_make_placeholder_texture("getup", 1),
			_make_placeholder_texture("getup", 2)
		],
		_profile_fps("getup", 9.0),
		_profile_loop("getup", false)
	)
	_add_placeholder_animation(
		frames,
		"ko",
		[_make_placeholder_texture("ko")],
		_profile_fps("ko", 1.0),
		_profile_loop("ko", false)
	)
	return frames

func _add_placeholder_animation(
	frames: SpriteFrames,
	name: StringName,
	textures: Array[Texture2D],
	fps: float,
	loop: bool
) -> void:
	frames.add_animation(name)
	frames.set_animation_speed(name, fps)
	frames.set_animation_loop(name, loop)
	for texture in textures:
		frames.add_frame(name, texture)

func _profile_fps(animation_name: StringName, fallback: float) -> float:
	var profile: Dictionary = ANIMATION_PROFILES.get(animation_name, {})
	return float(profile.get("fps", fallback))

func _profile_loop(animation_name: StringName, fallback: bool) -> bool:
	var profile: Dictionary = ANIMATION_PROFILES.get(animation_name, {})
	return bool(profile.get("loop", fallback))

func _make_placeholder_texture(pose: String, variant: int = 0) -> Texture2D:
	var image := Image.create(PLACEHOLDER_FRAME_SIZE.x, PLACEHOLDER_FRAME_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))

	var fill := Color(0.9, 0.9, 0.9, 1.0)
	var head := Rect2i(8, 4, 8, 8)
	var torso := Rect2i(7, 13, 10, 14)
	var left_arm := Rect2i(4, 14, 3, 10)
	var right_arm := Rect2i(17, 14, 3, 10)
	var left_leg := Rect2i(8, 27, 4, 14)
	var right_leg := Rect2i(12, 27, 4, 14)

	match pose:
		"walk":
			if variant == 0:
				left_leg = Rect2i(7, 27, 4, 14)
				right_leg = Rect2i(13, 27, 4, 14)
			else:
				left_leg = Rect2i(9, 27, 4, 14)
				right_leg = Rect2i(11, 27, 4, 14)
		"jump":
			torso = Rect2i(7, 15, 10, 12)
			left_leg = Rect2i(7, 28, 4, 10)
			right_leg = Rect2i(13, 28, 4, 10)
		"light":
			right_arm = Rect2i(17, 15, 5, 6)
		"heavy":
			right_arm = Rect2i(17, 14, 6, 10)
		"special":
			fill = Color(0.78, 0.95, 0.78, 1.0)
			left_arm = Rect2i(3, 15, 4, 9)
			right_arm = Rect2i(17, 12, 6, 8)
		"throw":
			left_arm = Rect2i(2, 15, 5, 7)
			right_arm = Rect2i(17, 15, 5, 7)
		"block":
			fill = Color(0.78, 0.86, 1.0, 1.0)
			torso = Rect2i(7, 14, 10, 14)
			left_arm = Rect2i(5, 15, 4, 10)
			right_arm = Rect2i(15, 12, 5, 12)
			if variant == 1:
				right_arm = Rect2i(14, 11, 6, 12)
		"hit_light":
			fill = Color(1.0, 0.84, 0.84, 1.0)
			torso = Rect2i(8, 14, 9, 14)
			left_arm = Rect2i(5, 15, 3, 9)
			right_arm = Rect2i(17, 16, 3, 8)
			if variant == 1:
				torso = Rect2i(9, 15, 8, 13)
				left_leg = Rect2i(8, 28, 4, 12)
		"hit_heavy":
			fill = Color(1.0, 0.74, 0.74, 1.0)
			torso = Rect2i(9, 16, 8, 12)
			left_arm = Rect2i(3, 17, 4, 7)
			right_arm = Rect2i(16, 11, 4, 11)
			left_leg = Rect2i(7, 30, 5, 10)
			right_leg = Rect2i(12, 29, 4, 11)
			if variant == 1:
				head = Rect2i(10, 8, 8, 8)
				torso = Rect2i(10, 18, 8, 10)
				left_leg = Rect2i(8, 32, 6, 8)
				right_leg = Rect2i(13, 31, 4, 9)
		"hit":
			fill = Color(1.0, 0.78, 0.78, 1.0)
			torso = Rect2i(8, 14, 9, 14)
		"fall":
			fill = Color(0.86, 0.86, 0.92, 1.0)
			head = Rect2i(4, 30, 8, 8)
			torso = Rect2i(12, 30, 10, 8)
			left_arm = Rect2i(11, 27, 4, 3)
			right_arm = Rect2i(17, 37, 4, 3)
			left_leg = Rect2i(6, 37, 4, 3)
			right_leg = Rect2i(1, 37, 4, 3)
			if variant == 1:
				head = Rect2i(6, 29, 8, 8)
				torso = Rect2i(14, 29, 9, 8)
				left_arm = Rect2i(13, 26, 4, 3)
				right_arm = Rect2i(18, 37, 4, 3)
				left_leg = Rect2i(8, 37, 4, 3)
				right_leg = Rect2i(3, 37, 4, 3)
		"getup":
			fill = Color(0.88, 0.88, 0.88, 1.0)
			if variant == 0:
				head = Rect2i(4, 30, 8, 8)
				torso = Rect2i(12, 30, 10, 8)
				left_arm = Rect2i(11, 27, 4, 3)
				right_arm = Rect2i(17, 37, 4, 3)
				left_leg = Rect2i(6, 37, 4, 3)
				right_leg = Rect2i(1, 37, 4, 3)
			elif variant == 1:
				head = Rect2i(7, 18, 8, 8)
				torso = Rect2i(8, 26, 10, 10)
				left_arm = Rect2i(4, 28, 4, 7)
				right_arm = Rect2i(18, 24, 3, 10)
				left_leg = Rect2i(8, 36, 4, 6)
				right_leg = Rect2i(12, 36, 4, 6)
			else:
				head = Rect2i(8, 7, 8, 8)
				torso = Rect2i(7, 15, 10, 13)
				left_arm = Rect2i(5, 17, 3, 8)
				right_arm = Rect2i(17, 16, 3, 9)
				left_leg = Rect2i(8, 28, 4, 12)
				right_leg = Rect2i(12, 28, 4, 12)
		"ko":
			fill = Color(0.75, 0.75, 0.75, 1.0)
			head = Rect2i(3, 30, 8, 8)
			torso = Rect2i(11, 30, 10, 8)
			left_arm = Rect2i(11, 27, 4, 3)
			right_arm = Rect2i(17, 37, 4, 3)
			left_leg = Rect2i(6, 37, 4, 3)
			right_leg = Rect2i(1, 37, 4, 3)

	var shade := fill.darkened(0.25)
	_draw_rect(image, head, fill)
	_draw_rect(image, torso, fill)
	var torso_shadow_height := maxi(1, torso.size.y / 2)
	_draw_rect(
		image,
		Rect2i(torso.position.x, torso.position.y + torso.size.y - torso_shadow_height, torso.size.x, torso_shadow_height),
		shade
	)
	_draw_rect(image, left_arm, fill)
	_draw_rect(image, right_arm, fill)
	_draw_rect(image, left_leg, fill)
	_draw_rect(image, right_leg, fill)

	_draw_rect_outline(image, head, OUTLINE_COLOR)
	_draw_rect_outline(image, torso, OUTLINE_COLOR)
	_draw_rect_outline(image, left_arm, OUTLINE_COLOR)
	_draw_rect_outline(image, right_arm, OUTLINE_COLOR)
	_draw_rect_outline(image, left_leg, OUTLINE_COLOR)
	_draw_rect_outline(image, right_leg, OUTLINE_COLOR)

	if pose in ["ko", "fall"] or (pose == "getup" and variant == 0):
		image.set_pixel(5, 33, OUTLINE_COLOR)
		image.set_pixel(8, 33, OUTLINE_COLOR)
	elif pose == "hit_heavy" and variant == 1:
		image.set_pixel(12, 11, OUTLINE_COLOR)
		image.set_pixel(15, 11, OUTLINE_COLOR)
	else:
		image.set_pixel(10, 7, OUTLINE_COLOR)
		image.set_pixel(13, 7, OUTLINE_COLOR)

	return ImageTexture.create_from_image(image)

func _draw_rect(image: Image, rect: Rect2i, color: Color) -> void:
	var x0 := maxi(0, rect.position.x)
	var y0 := maxi(0, rect.position.y)
	var x1 := mini(image.get_width(), rect.position.x + rect.size.x)
	var y1 := mini(image.get_height(), rect.position.y + rect.size.y)
	for y in range(y0, y1):
		for x in range(x0, x1):
			image.set_pixel(x, y, color)

func _draw_rect_outline(image: Image, rect: Rect2i, color: Color) -> void:
	if rect.size.x <= 0 or rect.size.y <= 0:
		return
	_draw_rect(image, Rect2i(rect.position.x, rect.position.y, rect.size.x, 1), color)
	_draw_rect(image, Rect2i(rect.position.x, rect.position.y + rect.size.y - 1, rect.size.x, 1), color)
	_draw_rect(image, Rect2i(rect.position.x, rect.position.y, 1, rect.size.y), color)
	_draw_rect(image, Rect2i(rect.position.x + rect.size.x - 1, rect.position.y, 1, rect.size.y), color)

func _read_attack_vector2(data: Dictionary, key: String, fallback: Vector2) -> Vector2:
	var value: Variant = data.get(key, fallback)
	return value if value is Vector2 else fallback

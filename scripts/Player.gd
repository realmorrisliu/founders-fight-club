extends CharacterBody2D

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
const THROW_TECH_BUFFER_SECONDS := 0.16
const THROW_TECH_PUSHBACK := 70.0
const THROW_TECH_AI_CHANCE := 0.34
const TRAINING_RANDOM_BLOCK_CHANCE := 0.5
const TRAINING_RANDOM_BLOCK_HOLD_SECONDS := 0.22
const TRAINING_BLOCK_THREAT_DISTANCE := 108.0
const INPUT_BUFFER_SECONDS := 0.22
const COMBO_CHAIN_TIMEOUT_SECONDS := 0.95
const COMBO_DAMAGE_SCALING_STEP := 0.12
const COMBO_DAMAGE_SCALING_MIN := 0.45
const COMBO_MIN_DAMAGE := 2
const GUARD_COUNTER_WINDOW_SECONDS := 0.24
const GUARD_COUNTER_DAMAGE_BONUS := 3
const GUARD_COUNTER_HITSTUN_BONUS := 0.05
const GUARD_COUNTER_KNOCKBACK_SCALE := 1.15
const PLACEHOLDER_FRAME_SIZE := Vector2i(24, 48)
const OUTLINE_COLOR := Color(0.09, 0.09, 0.09, 1.0)
const DEFAULT_SPRITE_FRAMES_PATH := "res://assets/sprites/player/PlayerSpriteFrames.tres"
const DEFAULT_ATTACK_TABLE_PATH := "res://assets/data/PlayerAttackTable.tres"
const BLOCK_CHIP_BY_ATTACK := {
	"light": 0.0,
	"heavy": 0.08,
	"special": 0.12,
	"throw": 0.0
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
const ANIMATION_PROFILES := {
	"idle": {"fps": 8.0, "loop": true},
	"walk": {"fps": 11.0, "loop": true},
	"jump": {"fps": 9.0, "loop": false},
	"light": {"fps": 18.0, "loop": false},
	"heavy": {"fps": 9.0, "loop": false},
	"special": {"fps": 10.0, "loop": false},
	"throw": {"fps": 12.0, "loop": false},
	"block": {"fps": 8.0, "loop": true},
	"hit_light": {"fps": 11.0, "loop": false},
	"hit_heavy": {"fps": 8.0, "loop": false},
	"hit": {"fps": 10.0, "loop": false},
	"fall": {"fps": 8.0, "loop": false},
	"getup": {"fps": 9.0, "loop": false},
	"ko": {"fps": 1.0, "loop": false}
}
const ATTACK_DATA := {
	"light": {
		"startup": 0.06, "active": 0.09, "recovery": 0.16, "block_recovery": 0.19, "damage": 6, "hitstun": 0.12, "blockstun": 0.10,
		"cancel_on_hit": true, "cancel_on_block": true, "cancel_options": ["light", "heavy", "special"],
		"block_type": "mid", "air_blockable": true,
		"knockback_ground": Vector2(115, -36), "knockback_air": Vector2(88, -72),
		"hitbox_size_ground": Vector2(26, 18), "hitbox_size_air": Vector2(24, 16),
		"hitbox_offset_ground": Vector2(22, 0), "hitbox_offset_air": Vector2(20, -6)
	},
	"heavy": {
		"startup": 0.16, "active": 0.12, "recovery": 0.26, "block_recovery": 0.33, "damage": 13, "hitstun": 0.20, "blockstun": 0.16,
		"cancel_on_hit": true, "cancel_on_block": false, "cancel_options": ["special"],
		"block_type": "overhead", "air_blockable": true,
		"knockback_ground": Vector2(220, -95), "knockback_air": Vector2(170, -145),
		"hitbox_size_ground": Vector2(34, 20), "hitbox_size_air": Vector2(30, 18),
		"hitbox_offset_ground": Vector2(26, -2), "hitbox_offset_air": Vector2(24, -10)
	},
	"special": {
		"startup": 0.10, "active": 0.17, "recovery": 0.28, "block_recovery": 0.40, "damage": 16, "hitstun": 0.22, "blockstun": 0.19,
		"cancel_on_hit": false, "cancel_on_block": false, "cancel_options": [],
		"block_type": "low", "air_blockable": true,
		"lunge_speed": 350.0,
		"knockback_ground": Vector2(260, -70), "knockback_air": Vector2(220, -130),
		"hitbox_size_ground": Vector2(36, 20), "hitbox_size_air": Vector2(32, 18),
		"hitbox_offset_ground": Vector2(28, -2), "hitbox_offset_air": Vector2(26, -8)
	},
	"throw": {
		"startup": 0.08, "active": 0.08, "recovery": 0.22, "block_recovery": 0.22, "damage": 11, "hitstun": 0.24, "blockstun": 0.0,
		"cancel_on_hit": false, "cancel_on_block": false, "cancel_options": [],
		"block_type": "throw", "air_blockable": false, "throw_techable": true,
		"knockback_ground": Vector2(180, -155), "knockback_air": Vector2(130, -190),
		"hitbox_size_ground": Vector2(20, 16), "hitbox_size_air": Vector2(18, 14),
		"hitbox_offset_ground": Vector2(18, 0), "hitbox_offset_air": Vector2(18, -6)
	}
}

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
var throw_tech_buffer_time := 0.0
var last_training_info := {}
var training_dummy_enabled := false
var training_dummy_mode := "stand"
var training_random_block_hold_time := 0.0
var training_random_block_signature := ""

@onready var hitbox := $Hitbox as Area2D
@onready var hitbox_shape := $Hitbox/CollisionShape2D
@onready var visual := $Visual as AnimatedSprite2D
@onready var opponent: CharacterBody2D = get_node_or_null(opponent_path) as CharacterBody2D

func _ready() -> void:
	add_to_group("fighters")
	_setup_attack_data()
	_setup_visual()
	hitbox.monitoring = false
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	_update_facing()
	_update_visual()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	guard_counter_time = maxf(0.0, guard_counter_time - delta)
	wake_invuln_time = maxf(0.0, wake_invuln_time - delta)
	_update_throw_tech_buffer(delta)
	_update_attack_buffer(delta)
	_update_combo_chain(delta)

	if is_knocked_down:
		_update_knockdown(delta)
		_update_facing()
		_update_visual()
		move_and_slide()
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
		move_and_slide()
		return

	if hitstun_time > 0.0:
		hitstun_time -= delta
		_update_facing()
		_update_visual()
		move_and_slide()
		return

	if blockstun_time > 0.0:
		blockstun_time -= delta
		velocity.x = move_toward(velocity.x, 0.0, MOVE_SPEED * delta * 2.5)
		_update_facing()
		_update_visual()
		move_and_slide()
		return

	if is_dashing:
		dash_time -= delta
		if dash_time <= 0.0:
			is_dashing = false
			velocity.x = 0.0
		_update_facing()
		_update_visual()
		move_and_slide()
		return

	dash_cooldown_timer = maxf(0.0, dash_cooldown_timer - delta)
	ai_block_time = maxf(0.0, ai_block_time - delta)
	training_random_block_hold_time = maxf(0.0, training_random_block_hold_time - delta)

	if _is_training_dummy_active():
		_process_training_dummy(delta)
	elif is_ai:
		_process_ai(delta)
	else:
		_process_player_input()

	_update_attack(delta)
	_try_start_buffered_attack_from_neutral()
	_update_facing()
	_update_visual()
	move_and_slide()

func _process_player_input() -> void:
	if attack_state == "":
		var move_axis := Input.get_axis("move_left", "move_right")
		var wants_block := _can_enter_block() and InputMap.has_action("block") and Input.is_action_pressed("block")
		if wants_block:
			is_blocking = true
			if is_on_floor():
				velocity.x = move_axis * MOVE_SPEED * BLOCK_WALK_SPEED_FACTOR
			else:
				velocity.x = move_axis * MOVE_SPEED * 0.45
			if is_on_floor() and Input.is_action_just_pressed("jump"):
				is_blocking = false
				velocity.y = JUMP_VELOCITY
			return

		is_blocking = false
		velocity.x = move_axis * MOVE_SPEED
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
		var requested_attack := _read_requested_attack()
		if requested_attack != "":
			_request_attack(requested_attack)
		elif Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0 and is_on_floor():
			_start_dash()
	else:
		is_blocking = false
		velocity.x = 0.0
		var buffered_kind := _read_requested_attack()
		if buffered_kind != "":
			_buffer_attack(buffered_kind)

func _process_ai(delta: float) -> void:
	if opponent == null:
		return
	ai_attack_cooldown = maxf(0.0, ai_attack_cooldown - delta)
	var distance = opponent.global_position.x - global_position.x
	if attack_state == "":
		if _should_ai_block(distance):
			is_blocking = true
			ai_guard_mode = _resolve_ai_guard_mode()
			velocity.x = 0.0
			return

		is_blocking = false
		ai_guard_mode = "high"
		if absf(distance) > 48.0:
			velocity.x = sign(distance) * MOVE_SPEED * 0.7
		else:
			velocity.x = 0.0
			if ai_attack_cooldown <= 0.0:
				_request_attack("light")
				ai_attack_cooldown = 0.6
	else:
		is_blocking = false
		ai_guard_mode = "high"
		velocity.x = 0.0

func _is_training_dummy_active() -> bool:
	return training_dummy_enabled

func _process_training_dummy(delta: float) -> void:
	if opponent == null:
		is_blocking = false
		velocity.x = 0.0
		return
	if attack_state != "":
		is_blocking = false
		ai_guard_mode = "high"
		velocity.x = 0.0
		return

	velocity.x = move_toward(velocity.x, 0.0, MOVE_SPEED * delta * 4.0)
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
	if absf(distance) > 88.0:
		return false
	var opponent_attack_state_value: Variant = opponent.get("attack_state")
	var value_type: int = typeof(opponent_attack_state_value)
	if value_type != TYPE_STRING and value_type != TYPE_STRING_NAME:
		return false
	var opponent_attack_state := str(opponent_attack_state_value)
	if opponent_attack_state == "":
		return false
	if randf() < 0.35:
		ai_block_time = 0.18
	return ai_block_time > 0.0

func _resolve_ai_guard_mode() -> String:
	if not is_on_floor():
		return "air"
	if opponent and opponent.has_method("get_current_attack_block_type"):
		var block_type_value: Variant = opponent.call("get_current_attack_block_type")
		var block_type := str(block_type_value)
		if block_type == "low":
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

func _update_attack(delta: float) -> void:
	if attack_state == "":
		return
	if _try_execute_buffered_cancel():
		return
	_apply_hitbox_profile()
	attack_time += delta
	var data := _get_attack_data(attack_state)
	var recovery_duration := float(data["recovery"])
	if attack_recovery_override > 0.0:
		recovery_duration = attack_recovery_override
	if attack_phase == "startup" and attack_time >= data["startup"]:
		attack_phase = "active"
		attack_time = 0.0
		_set_hitbox_active(true)
	elif attack_phase == "active" and attack_time >= data["active"]:
		attack_phase = "recovery"
		attack_time = 0.0
		_set_hitbox_active(false)
	elif attack_phase == "recovery" and attack_time >= recovery_duration:
		attack_state = ""
		attack_phase = ""
		attack_time = 0.0
		attack_recovery_override = -1.0
		next_attack_is_counter = false
		attack_confirmed_hit = false
		attack_confirmed_block = false
		_set_hitbox_active(false)

	if attack_state == "special" and attack_phase in ["startup", "active"]:
		velocity.x = float(data.get("lunge_speed", 320.0)) * facing

func _read_requested_attack() -> String:
	if Input.is_action_just_pressed("attack_light"):
		return "light"
	if Input.is_action_just_pressed("attack_heavy"):
		return "heavy"
	if Input.is_action_just_pressed("attack_special"):
		return "special"
	if Input.is_action_just_pressed("throw"):
		return "throw"
	return ""

func _update_throw_tech_buffer(delta: float) -> void:
	throw_tech_buffer_time = maxf(0.0, throw_tech_buffer_time - delta)
	if is_ai:
		return
	if _is_throw_tech_input_pressed():
		throw_tech_buffer_time = THROW_TECH_BUFFER_SECONDS

func _is_throw_tech_input_pressed() -> bool:
	if Input.is_action_just_pressed("throw"):
		return true
	if Input.is_action_just_pressed("attack_light"):
		return true
	if Input.is_action_just_pressed("attack_heavy"):
		return true
	return false

func _request_attack(kind: String) -> void:
	if kind == "":
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
	runtime_attack_data = ATTACK_DATA.duplicate(true)
	var external := _load_external_attack_table()
	if external.is_empty():
		return
	for key in external.keys():
		var attack_key := str(key)
		var entry: Variant = external[key]
		if typeof(entry) == TYPE_DICTIONARY:
			runtime_attack_data[attack_key] = (entry as Dictionary).duplicate(true)

func _load_external_attack_table() -> Dictionary:
	if not use_external_attack_table:
		return {}
	if attack_table_resource:
		var resource_dict := _extract_attack_table_dictionary(attack_table_resource)
		if not resource_dict.is_empty():
			return resource_dict
	var path := attack_table_path.strip_edges()
	if path == "":
		path = DEFAULT_ATTACK_TABLE_PATH
	if not ResourceLoader.exists(path):
		return {}
	var loaded := load(path)
	var loaded_dict := _extract_attack_table_dictionary(loaded)
	if loaded_dict.is_empty():
		push_warning("Attack table resource missing attacks dictionary: %s" % path)
	return loaded_dict

func _extract_attack_table_dictionary(resource: Resource) -> Dictionary:
	if resource == null:
		return {}
	if resource.has_method("get_runtime_attacks"):
		var method_value: Variant = resource.call("get_runtime_attacks")
		if typeof(method_value) == TYPE_DICTIONARY:
			return (method_value as Dictionary).duplicate(true)
	var value: Variant = resource.get("attacks")
	if typeof(value) == TYPE_DICTIONARY:
		return (value as Dictionary).duplicate(true)
	return {}

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
	if attack_state != "":
		return false
	if is_dashing or is_knocked_down or getup_time > 0.0:
		return false
	if hitstun_time > 0.0 or blockstun_time > 0.0:
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
	if is_knocked_down or getup_time > 0.0 or blockstun_time > 0.0:
		return
	is_blocking = false
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
	hit_targets.clear()
	_set_hitbox_active(false)
	_apply_hitbox_profile()

func _apply_hitbox_profile() -> void:
	if attack_state == "":
		return
	var data := _get_attack_data(attack_state)
	hitbox_offset = data["hitbox_offset_ground"] if is_on_floor() else data["hitbox_offset_air"]
	var shape := hitbox_shape.shape as RectangleShape2D
	if shape:
		shape.size = data["hitbox_size_ground"] if is_on_floor() else data["hitbox_size_air"]

func _set_hitbox_active(active: bool) -> void:
	hitbox.set_deferred("monitoring", active)
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", not active)

func _update_facing() -> void:
	if opponent:
		facing = -1 if opponent.global_position.x < global_position.x else 1
	hitbox.position = Vector2(hitbox_offset.x * facing, hitbox_offset.y)
	if visual:
		visual.flip_h = facing < 0

func _update_visual() -> void:
	if visual == null:
		return
	var base_tint := Color(0.75, 0.9, 1.0, 1.0) if player_id == 1 else Color(1.0, 0.82, 0.82, 1.0)
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
	elif hitstun_time > 0.0:
		animation = _select_hit_reaction_animation()
	elif blockstun_time > 0.0 or (is_blocking and is_on_floor()):
		animation = &"block"
	elif attack_state != "":
		animation = StringName(attack_state)
	elif not is_on_floor():
		animation = &"jump"
	elif absf(velocity.x) > 20.0:
		animation = &"walk"

	animation = _resolve_visual_animation(animation)

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
	var knockback = data["knockback_ground"] if is_on_floor() else data["knockback_air"]
	var hitstun := float(data.get("hitstun", HITSTUN_SECONDS))
	var damage := int(data.get("damage", 0))
	var is_counter_hit := next_attack_is_counter and attack_state != "throw"
	var predicted_combo_count := _peek_combo_hit_count(body)
	if is_counter_hit:
		damage += GUARD_COUNTER_DAMAGE_BONUS
		hitstun += GUARD_COUNTER_HITSTUN_BONUS
		knockback *= GUARD_COUNTER_KNOCKBACK_SCALE
	damage = _apply_combo_damage_scaling(damage, predicted_combo_count)
	knockback.x *= facing
	if body.has_method("apply_damage"):
		var hit_result: Variant = body.apply_damage(
			damage,
			knockback,
			hitstun,
			attack_state,
			{
				"blockstun": float(data.get("blockstun", BLOCKSTUN_SECONDS)),
				"counter": is_counter_hit,
				"block_type": str(data.get("block_type", "mid")),
				"air_blockable": bool(data.get("air_blockable", true)),
				"throw_techable": bool(data.get("throw_techable", false))
			}
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

func _is_animation_loop(animation_name: StringName) -> bool:
	if runtime_sprite_frames == null:
		return false
	if not runtime_sprite_frames.has_animation(animation_name):
		return false
	return runtime_sprite_frames.get_animation_loop(animation_name)

func _can_enter_block() -> bool:
	if current_hp <= 0:
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
	if InputMap.has_action("move_down") and Input.is_action_pressed("move_down"):
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
	var block_type := str(attack_meta.get("block_type", "mid"))
	if guard_mode == "air":
		if not bool(attack_meta.get("air_blockable", true)):
			return false
	else:
		match block_type:
			"low":
				if guard_mode != "low":
					return false
			"overhead", "high":
				if guard_mode == "low":
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
	if attack_state == "light":
		if was_blocked and randf() < 0.35:
			_buffer_attack("heavy")
		elif not was_blocked and randf() < 0.55:
			_buffer_attack("heavy")
	elif attack_state == "heavy" and not was_blocked and randf() < 0.50:
		_buffer_attack("special")

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

func _apply_combo_damage_scaling(base_damage: int, combo_count: int) -> int:
	if combo_count <= 1:
		return base_damage
	var scaled_hits := combo_count - 1
	var scale := maxf(COMBO_DAMAGE_SCALING_MIN, 1.0 - float(scaled_hits) * COMBO_DAMAGE_SCALING_STEP)
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
	var startup := float(attack_data.get("startup", 0.0))
	var active := float(attack_data.get("active", 0.0))
	var recovery := float(attack_data.get("recovery", 0.0))
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
	next_attack_is_counter = false
	_set_hitbox_active(false)

	health_changed.emit()
	if current_hp <= 0:
		defeated.emit()
	return chip_damage

func _should_knockdown(knockback: Vector2, hitstun_override: float, attack_kind: String) -> bool:
	if attack_kind == "throw":
		return true
	if hitstun_override >= KNOCKDOWN_HITSTUN_THRESHOLD:
		return true
	return -knockback.y >= KNOCKDOWN_VERTICAL_THRESHOLD

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
	if Input.is_action_just_pressed("dash"):
		return "roll"
	if Input.is_action_just_pressed("jump") or (InputMap.has_action("block") and Input.is_action_just_pressed("block")):
		return "quick"
	return ""

func _start_tech_recovery(tech_kind: String) -> void:
	is_knocked_down = false
	is_blocking = false
	knockdown_time = 0.0
	getup_time = TECH_GETUP_SECONDS
	wake_invuln_time = WAKE_INVULN_SECONDS
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
	velocity = knockback
	hitstun_time = maxf(0.0, hitstun_override)
	blockstun_time = 0.0
	hit_reaction_animation = _resolve_hit_reaction_animation(knockback, hitstun_override)
	is_dashing = false
	is_blocking = false
	ai_block_time = 0.0
	ai_tech_decision_roll = false
	guard_counter_time = 0.0
	next_attack_is_counter = false
	attack_state = ""
	attack_phase = ""
	attack_recovery_override = -1.0
	getup_time = 0.0
	wake_invuln_time = 0.0
	tech_slide_time = 0.0
	tech_slide_speed = 0.0
	_set_hitbox_active(false)

	if _should_knockdown(knockback, hitstun_override, attack_kind):
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

func _select_hit_reaction_animation() -> StringName:
	if _has_runtime_animation(hit_reaction_animation):
		return hit_reaction_animation
	return &"hit"

func _resolve_visual_animation(animation_name: StringName) -> StringName:
	if _has_runtime_animation(animation_name):
		return animation_name
	match animation_name:
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
	is_dashing = true
	is_blocking = false
	dash_time = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN
	velocity.x = facing * DASH_SPEED
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

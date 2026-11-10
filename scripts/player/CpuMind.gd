extends RefCounted
class_name CpuMind

const DIFFICULTY_TABLE := {
	"easy": {
		"reaction_delay": 0.36,
		"aggression": 0.22,
		"mistake_rate": 0.48,
	},
	"normal": {
		"reaction_delay": 0.12,
		"aggression": 0.64,
		"mistake_rate": 0.14,
	},
	"hard": {
		"reaction_delay": 0.04,
		"aggression": 0.90,
		"mistake_rate": 0.04,
	},
}

const LIP_MARGIN := 28.0
const KO_PERCENT := 80.0
const WALK_SPEED := 220.0

var difficulty_id := "normal"
var rng := RandomNumberGenerator.new()
var seeded := false
var reaction_left := 0.0
var block_left := 0.0
var defend_choice := ""
var threat_id := ""
var edge_episode := false
var edge_engage := false
var whiff_left := 0.0
var recover_wait := -1.0
var platform_wait := 0.0
var platform_goal_time := 0.0
var platform_goal_left := 0.0
var platform_goal_right := 0.0
var platform_spans: Array = []


static func tuning_for(id: String) -> Dictionary:
	if DIFFICULTY_TABLE.has(id):
		return (DIFFICULTY_TABLE[id] as Dictionary).duplicate()
	return (DIFFICULTY_TABLE["normal"] as Dictionary).duplicate()


func bind_seed(match_seed: int, player_id: int) -> void:
	rng.seed = (int(match_seed) * 0x9E3779B1) ^ (int(player_id) * 0x85EBCA77)
	seeded = true


func ensure_seed(fighter: Node) -> void:
	if seeded:
		return
	bind_seed(int(fighter.get("player_id")), 0)


func needs_offstage_steer(fighter: Node2D) -> bool:
	if bool(fighter.call("is_on_floor")):
		return false
	return _offstage(fighter) or _below_stage(fighter)


func steer_offstage(fighter: Node2D, delta: float) -> void:
	ensure_seed(fighter)
	_recover(fighter, delta, tuning_for(difficulty_id))


func choose_ledge(fighter: Node2D) -> void:
	ensure_seed(fighter)
	var opponent := fighter.get("opponent") as Node2D
	var tuning := tuning_for(difficulty_id)
	if opponent == null:
		fighter.call("_roll_getup_from_ledge")
		return
	var distance := absf(opponent.global_position.x - fighter.global_position.x)
	var aggression := float(tuning["aggression"])
	var mistake := float(tuning["mistake_rate"])
	if _percent(opponent) >= KO_PERCENT and distance < 88.0 and aggression >= 0.6 and rng.randf() > mistake:
		fighter.call("_attack_getup_from_ledge")
		return
	if distance < 130.0:
		fighter.call("_roll_getup_from_ledge")
		return
	fighter.call("_launch_from_ledge")


func tick(fighter: Node2D, delta: float) -> void:
	ensure_seed(fighter)
	var opponent := fighter.get("opponent") as Node2D
	if opponent == null:
		return
	var tuning := tuning_for(difficulty_id)
	fighter.set("ai_attack_cooldown", maxf(0.0, float(fighter.get("ai_attack_cooldown")) - delta))
	block_left = maxf(0.0, block_left - delta)
	reaction_left = maxf(0.0, reaction_left - delta)
	whiff_left = maxf(0.0, whiff_left - delta)
	platform_wait = maxf(0.0, platform_wait - delta)
	if bool(fighter.call("is_on_floor")) and not _offstage(fighter):
		recover_wait = -1.0
	_track_opponent(opponent, tuning)
	if _offstage(fighter) or _below_stage(fighter) or _returning_over_lip(fighter):
		_recover(fighter, delta, tuning)
		return
	if str(fighter.get("attack_state")) != "":
		fighter.set("is_blocking", false)
		fighter.call("_apply_horizontal_intent", 0.0, delta, 0.8, 1.2)
		return
	if block_left > 0.0 and _can_block(fighter):
		_hold_block(fighter, delta)
		return
	if _try_defend(fighter, opponent, delta):
		return
	if _try_punish(fighter, opponent, delta, tuning):
		return
	if _try_edgeguard(fighter, opponent, delta, tuning):
		return
	if _try_platform(fighter, opponent, delta, tuning):
		return
	_neutral(fighter, opponent, delta, tuning)


func _track_opponent(opponent: Node2D, tuning: Dictionary) -> void:
	var state := str(opponent.get("attack_state"))
	var phase := str(opponent.get("attack_phase"))
	if phase == "recovery":
		whiff_left = 0.28
	if state == "":
		threat_id = ""
		defend_choice = ""
		return
	var signature := "%s:%s" % [state, phase]
	if signature == threat_id:
		return
	threat_id = signature
	reaction_left = float(tuning["reaction_delay"])
	var mistake := float(tuning["mistake_rate"])
	var aggression := float(tuning["aggression"])
	var roll := rng.randf()
	if roll < mistake:
		defend_choice = "none"
	elif roll < mistake + (1.0 - mistake) * 0.34 * aggression:
		defend_choice = "dodge"
	else:
		var shield_odds := lerpf(0.40, 0.95, aggression) * (1.0 - mistake * 0.35)
		defend_choice = "block" if rng.randf() < shield_odds else "none"


func _recover(fighter: Node2D, delta: float, tuning: Dictionary) -> void:
	fighter.set("is_blocking", false)
	if recover_wait < 0.0:
		recover_wait = 0.0 if _recovery_urgent(fighter) else float(tuning["reaction_delay"])
	recover_wait = maxf(0.0, recover_wait - delta)
	var inward := _inward_sign(fighter)
	_move_toward(fighter, inward, delta, true)
	var urgent := _recovery_urgent(fighter)
	if recover_wait > 0.0 and not urgent:
		return
	var floor_y := float(fighter.get("stage_floor_y"))
	var left := float(fighter.get("stage_left_x"))
	var right := float(fighter.get("stage_right_x"))
	var position := fighter.global_position
	var velocity := fighter.get("velocity") as Vector2
	var vertical_speed := 0.0 if velocity == null else velocity.y
	var nearest := left if absf(position.x - left) <= absf(position.x - right) else right
	var lip_distance := absf(position.x - nearest)
	var in_grab_band := position.y >= floor_y - 18.0 and position.y <= floor_y + 70.0 and lip_distance <= 40.0
	var on_floor := bool(fighter.call("is_on_floor"))
	var inside := position.x >= left and position.x <= right
	if inside and position.y < floor_y - 24.0 and not on_floor and not in_grab_band:
		fighter.set("fast_fall_active", true)
	else:
		fighter.set("fast_fall_active", false)
	if in_grab_band and vertical_speed >= -8.0:
		fighter.call("_ai_release_tumble")
		return
	var need_height := position.y > floor_y - 8.0
	if not need_height or vertical_speed < -80.0:
		return
	if bool(fighter.call("_ai_try_jump")):
		return
	if int(fighter.get("air_jumps_remaining")) <= 0 and not on_floor:
		fighter.call("_ai_try_air_dodge", inward, -0.65)


func _try_defend(fighter: Node2D, opponent: Node2D, delta: float) -> bool:
	if defend_choice == "" or defend_choice == "done" or reaction_left > 0.0:
		return false
	if str(opponent.get("attack_state")) == "":
		return false
	var distance := absf(opponent.global_position.x - fighter.global_position.x)
	if distance > 96.0:
		return false
	if defend_choice == "block" and _can_block(fighter):
		block_left = 0.22
		defend_choice = "done"
		_hold_block(fighter, delta)
		return true
	if defend_choice == "dodge" and distance < 72.0 and _try_dodge(fighter, opponent):
		defend_choice = "done"
		return true
	return false


func _try_punish(fighter: Node2D, opponent: Node2D, delta: float, tuning: Dictionary) -> bool:
	if whiff_left <= 0.0:
		return false
	if str(opponent.get("attack_phase")) != "recovery":
		return false
	if float(fighter.get("ai_attack_cooldown")) > 0.0:
		return false
	var distance := absf(opponent.global_position.x - fighter.global_position.x)
	var reach := _reach(fighter, "light")
	if distance > reach + 36.0:
		_move_toward(fighter, signf(opponent.global_position.x - fighter.global_position.x) * lerpf(0.4, 0.9, float(tuning["aggression"])), delta, false)
		return true
	if rng.randf() < float(tuning["mistake_rate"]):
		whiff_left = 0.0
		return false
	var kind := "light"
	if _percent(opponent) >= KO_PERCENT and distance <= _reach(fighter, "heavy") + 8.0:
		kind = "heavy"
	fighter.call("_request_attack", kind)
	fighter.set("ai_attack_cooldown", lerpf(0.55, 0.28, float(tuning["aggression"])))
	whiff_left = 0.0
	return true


func _try_edgeguard(fighter: Node2D, opponent: Node2D, delta: float, tuning: Dictionary) -> bool:
	if not bool(fighter.call("is_on_floor")) or not _fighter_offstage(opponent, fighter):
		edge_episode = false
		return false
	if not edge_episode:
		edge_episode = true
		edge_engage = rng.randf() < float(tuning["aggression"])
	if not edge_engage:
		return false
	var left := float(fighter.get("stage_left_x"))
	var right := float(fighter.get("stage_right_x"))
	var lip := left if opponent.global_position.x < left else right
	var hold_x := lip + LIP_MARGIN if lip == left else lip - LIP_MARGIN
	var gap := hold_x - fighter.global_position.x
	if absf(gap) > 12.0:
		_move_toward(fighter, signf(gap) * 0.72, delta, false)
	else:
		fighter.call("_apply_horizontal_intent", 0.0, delta)
	var distance := absf(opponent.global_position.x - fighter.global_position.x)
	var vertical := absf(opponent.global_position.y - fighter.global_position.y)
	if distance < _reach(fighter, "light") + 24.0 and vertical < 110.0 and float(fighter.get("ai_attack_cooldown")) <= 0.0:
		if rng.randf() >= float(tuning["mistake_rate"]):
			var kind := "heavy" if _percent(opponent) >= KO_PERCENT else "light"
			fighter.call("_request_attack", kind)
			fighter.set("ai_attack_cooldown", 0.38)
	return true


func _try_platform(fighter: Node2D, opponent: Node2D, delta: float, tuning: Dictionary) -> bool:
	var aggression := float(tuning["aggression"])
	if not bool(fighter.call("is_on_floor")):
		return false
	var floor_y := float(fighter.get("stage_floor_y"))
	var opponent_on_platform := bool(opponent.call("is_on_floor")) and opponent.global_position.y < floor_y - 36.0
	var self_on_platform := fighter.global_position.y < floor_y - 30.0
	var distance := absf(opponent.global_position.x - fighter.global_position.x)
	if opponent_on_platform and not self_on_platform and distance < 150.0:
		fighter.call("_ai_try_jump")
		_move_toward(fighter, signf(opponent.global_position.x - fighter.global_position.x) * 0.82, delta, false)
		return true
	if self_on_platform and not opponent_on_platform and distance < 80.0 and bool(fighter.call("_is_on_drop_through_platform")):
		fighter.call("_ai_drop_through")
		return true
	if platform_goal_time > 0.0:
		platform_goal_time = maxf(0.0, platform_goal_time - delta)
		var x := fighter.global_position.x
		var inside := x >= platform_goal_left + 10.0 and x <= platform_goal_right - 10.0
		if inside:
			if bool(fighter.call("_ai_try_jump")):
				platform_goal_time = 0.0
				platform_wait = 2.4
		else:
			var center := (platform_goal_left + platform_goal_right) * 0.5
			_move_toward(fighter, signf(center - x), delta, false)
		return true
	if self_on_platform or opponent_on_platform or platform_wait > 0.0:
		return false
	if _percent(opponent) >= KO_PERCENT or distance < 42.0:
		return false
	var spans := _read_platform_spans(fighter)
	if spans.is_empty():
		return false
	var mid_x := (fighter.global_position.x + opponent.global_position.x) * 0.5
	var best: Dictionary = {}
	var best_gap := 10000.0
	for span_value in spans:
		var span := span_value as Dictionary
		var span_center := (float(span["left"]) + float(span["right"])) * 0.5
		var gap := absf(span_center - mid_x)
		if gap < best_gap:
			best_gap = gap
			best = span
	if best.is_empty() or best_gap > 260.0:
		return false
	var take_chance := maxf(aggression * 0.28, 0.16)
	if rng.randf() > take_chance:
		platform_wait = 0.55
		return false
	platform_goal_left = float(best["left"])
	platform_goal_right = float(best["right"])
	platform_goal_time = 0.9
	var center_x := (platform_goal_left + platform_goal_right) * 0.5
	_move_toward(fighter, signf(center_x - fighter.global_position.x), delta, false)
	return true


func _read_platform_spans(fighter: Node2D) -> Array:
	if not platform_spans.is_empty():
		return platform_spans
	var parent := fighter.get_parent()
	if parent == null:
		return platform_spans
	var arena := parent.get_node_or_null("Arena")
	if arena == null:
		return platform_spans
	for node in arena.get_children():
		if not str(node.name).begins_with("Platform"):
			continue
		var shape_node := node.get_node_or_null("CollisionShape2D") as Node2D
		if shape_node == null:
			continue
		var shape: Variant = shape_node.get("shape")
		if shape == null:
			continue
		var size: Variant = shape.get("size")
		if not (size is Vector2):
			continue
		var center: Vector2 = shape_node.global_position
		var half := (size as Vector2).x * 0.5
		platform_spans.append({
			"left": center.x - half,
			"right": center.x + half,
		})
	return platform_spans


func _neutral(fighter: Node2D, opponent: Node2D, delta: float, tuning: Dictionary) -> void:
	var aggression := float(tuning["aggression"])
	var mistake := float(tuning["mistake_rate"])
	var dx := opponent.global_position.x - fighter.global_position.x
	var distance := absf(dx)
	var preferred := float(fighter.call("_get_ai_profile_number", "preferred_range", 56.0))
	var chase := float(fighter.call("_get_ai_profile_number", "chase_range", 108.0))
	preferred += (1.0 - aggression) * 30.0
	var killing := _percent(opponent) >= KO_PERCENT
	if killing:
		preferred = minf(preferred, 52.0)
	var signed := 0.0
	if distance > chase:
		signed = signf(dx) * lerpf(0.34, 0.92, aggression)
	elif distance > preferred:
		signed = signf(dx) * lerpf(0.22, 0.66, aggression)
	elif distance < 18.0 and not killing:
		signed = -signf(dx) * 0.28
	_move_toward(fighter, signed, delta, false)
	if distance > chase + 16.0 and bool(fighter.call("is_on_floor")) and float(fighter.get("dash_cooldown_timer")) <= 0.0:
		var dash_chance := float(fighter.call("_get_ai_profile_number", "dash_in_chance", 0.08)) * lerpf(0.2, 1.15, aggression)
		var dash_direction := signf(dx)
		if absf(dash_direction) < 0.5:
			dash_direction = float(fighter.get("facing"))
		if rng.randf() < dash_chance and not _dash_leaves_stage(fighter, dash_direction):
			if not bool(fighter.get("facing_locked")):
				fighter.set("facing", -1 if dash_direction < 0.0 else 1)
			fighter.call("_start_dash")
			return
	if float(fighter.get("ai_attack_cooldown")) > 0.0:
		return
	var kind := _pick_attack(fighter, distance, killing)
	if kind == "":
		return
	if rng.randf() < mistake and not killing:
		if distance <= _reach(fighter, "light") + 28.0:
			kind = "light"
		else:
			return
	fighter.call("_request_attack", kind)
	var cooldown_min := float(fighter.call("_get_ai_profile_number", "cooldown_min", 0.40))
	var cooldown_max := maxf(cooldown_min + 0.04, float(fighter.call("_get_ai_profile_number", "cooldown_max", 0.72)))
	fighter.set("ai_attack_cooldown", rng.randf_range(cooldown_min, cooldown_max) * lerpf(1.65, 0.70, aggression))


func _try_dodge(fighter: Node2D, opponent: Node2D) -> bool:
	if not bool(fighter.call("_can_start_dodge")):
		return false
	if bool(fighter.call("is_on_floor")):
		if rng.randf() < 0.55:
			fighter.call("_start_spot_dodge")
		else:
			var away := -1 if opponent.global_position.x >= fighter.global_position.x else 1
			fighter.call("_start_roll_dodge", away)
		return true
	return bool(fighter.call("_ai_try_air_dodge", _inward_sign(fighter), -0.15))


func _pick_attack(fighter: Node2D, distance: float, killing: bool) -> String:
	var weights_value: Variant = fighter.call("_build_ai_attack_weight_map", distance)
	if typeof(weights_value) != TYPE_DICTIONARY:
		return ""
	var table := (weights_value as Dictionary).duplicate()
	if killing:
		for key in ["heavy", "special", "signature_a", "signature_b", "ultimate"]:
			if table.has(key):
				table[key] = float(table[key]) * 1.85
	for key in table.keys():
		var kind := str(key)
		var reach := _reach(fighter, kind)
		if reach < 200.0 and distance > reach + 12.0:
			table[kind] = float(table[kind]) * 0.04
	var picked := _pick_weighted(table)
	if picked == "":
		return ""
	var picked_reach := _reach(fighter, picked)
	if picked_reach < 200.0 and distance > picked_reach + 14.0:
		return ""
	return picked


func _pick_weighted(table: Dictionary) -> String:
	var total := 0.0
	for key in table.keys():
		total += maxf(0.0, float(table[key]))
	if total <= 0.0:
		return ""
	var roll := rng.randf() * total
	var last := ""
	for key in table.keys():
		last = str(key)
		roll -= maxf(0.0, float(table[key]))
		if roll <= 0.0:
			return last
	return last


func _reach(fighter: Node2D, kind: String) -> float:
	if kind == "":
		return 0.0
	var data_value: Variant = fighter.call("_get_attack_data", kind)
	if typeof(data_value) != TYPE_DICTIONARY:
		return 46.0
	var attack := data_value as Dictionary
	var effect := str(fighter.call("_resolve_attack_effect_type", attack))
	if effect in ["projectile", "trap", "summon"]:
		return 240.0
	var offset_x := 18.0
	var size_x := 24.0
	var offset_value: Variant = attack.get("hitbox_offset_ground", Vector2(18, 0))
	var size_value: Variant = attack.get("hitbox_size_ground", Vector2(24, 24))
	if offset_value is Vector2:
		offset_x = absf((offset_value as Vector2).x)
	if size_value is Vector2:
		size_x = (size_value as Vector2).x
	return offset_x + size_x * 0.5 + 16.0


func _move_toward(fighter: Node2D, signed_scale: float, delta: float, allow_offstage: bool) -> void:
	var speed := WALK_SPEED * float(fighter.call("_get_move_speed_multiplier"))
	var target := signed_scale * speed
	if not allow_offstage:
		target = _clamp_outward(fighter, target, delta)
	fighter.call("_apply_horizontal_intent", target, delta)


func _clamp_outward(fighter: Node2D, target: float, delta: float) -> float:
	var x := fighter.global_position.x
	var left := float(fighter.get("stage_left_x")) + LIP_MARGIN
	var right := float(fighter.get("stage_right_x")) - LIP_MARGIN
	if x <= left and target < 0.0:
		return 0.0
	if x >= right and target > 0.0:
		return 0.0
	if x + target * delta < left and target < 0.0:
		return 0.0
	if x + target * delta > right and target > 0.0:
		return 0.0
	return target


func _dash_leaves_stage(fighter: Node2D, direction: float) -> bool:
	var x := fighter.global_position.x
	var left := float(fighter.get("stage_left_x"))
	var right := float(fighter.get("stage_right_x"))
	if direction < 0.0 and x - left < 96.0:
		return true
	if direction > 0.0 and right - x < 96.0:
		return true
	return false


func _hold_block(fighter: Node2D, delta: float) -> void:
	fighter.set("is_blocking", true)
	fighter.call("_apply_horizontal_intent", 0.0, delta, 0.72, 1.14)


func _can_block(fighter: Node2D) -> bool:
	return bool(fighter.call("_can_enter_block"))


func _offstage(fighter: Node2D) -> bool:
	var x := fighter.global_position.x
	return x < float(fighter.get("stage_left_x")) - 4.0 or x > float(fighter.get("stage_right_x")) + 4.0


func _below_stage(fighter: Node2D) -> bool:
	if bool(fighter.call("is_on_floor")):
		return false
	return fighter.global_position.y > float(fighter.get("stage_floor_y")) + 16.0


func _fighter_offstage(body: Node2D, stage_owner: Node2D) -> bool:
	if body == null:
		return false
	var x := body.global_position.x
	var left := float(stage_owner.get("stage_left_x"))
	var right := float(stage_owner.get("stage_right_x"))
	if x < left - 4.0 or x > right + 4.0:
		return true
	if bool(body.call("is_on_floor")):
		return false
	return body.global_position.y > float(stage_owner.get("stage_floor_y")) + 16.0


func _returning_over_lip(fighter: Node2D) -> bool:
	if bool(fighter.call("is_on_floor")):
		return false
	var x := fighter.global_position.x
	var left := float(fighter.get("stage_left_x"))
	var right := float(fighter.get("stage_right_x"))
	var floor_y := float(fighter.get("stage_floor_y"))
	if fighter.global_position.y >= floor_y - 8.0:
		return false
	return x < left + 72.0 or x > right - 72.0


func _recovery_urgent(fighter: Node2D) -> bool:
	var x := fighter.global_position.x
	var y := fighter.global_position.y
	var left := float(fighter.get("stage_left_x"))
	var right := float(fighter.get("stage_right_x"))
	var floor_y := float(fighter.get("stage_floor_y"))
	if y > floor_y + 70.0 or _returning_over_lip(fighter):
		return true
	return x < left - 64.0 or x > right + 64.0


func _inward_sign(fighter: Node2D) -> float:
	var x := fighter.global_position.x
	var left := float(fighter.get("stage_left_x"))
	var right := float(fighter.get("stage_right_x"))
	var nearest := left if absf(x - left) <= absf(x - right) else right
	var direction := signf(nearest - x)
	if absf(direction) < 0.5:
		direction = signf((left + right) * 0.5 - x)
	if absf(direction) < 0.5:
		return 1.0
	return direction


func _percent(body: Node2D) -> float:
	return 100.0 - float(body.get("current_hp"))

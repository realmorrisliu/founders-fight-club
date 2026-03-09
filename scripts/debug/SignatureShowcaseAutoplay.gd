extends Node

const STORY_SCENE_PATH := "res://scenes/Story.tscn"
const OUTPUT_DIR := "/tmp/ffc-signature-showcase"
const SessionStateStore := preload("res://scripts/SessionState.gd")
const SessionKeysStore := preload("res://scripts/config/SessionKeys.gd")
const LoadoutCatalogStore := preload("res://scripts/config/LoadoutCatalog.gd")
const CHARACTER_LIBRARY := {
	"mark_zuck": {
		"name": "Mark Zuck",
		"table_path": "res://assets/data/characters/MarkZuckAttackTable.tres"
	},
	"sam_altmyn": {
		"name": "Sam Altmyn",
		"table_path": "res://assets/data/characters/SamAltmynAttackTable.tres"
	},
	"peter_thyell": {
		"name": "Peter Thyell",
		"table_path": "res://assets/data/characters/PeterThyellAttackTable.tres"
	},
	"zef_bezos": {
		"name": "Zef Bezos",
		"table_path": "res://assets/data/characters/ZefBezosAttackTable.tres"
	},
	"bill_geytz": {
		"name": "Bill Geytz",
		"table_path": "res://assets/data/characters/BillGeytzAttackTable.tres"
	},
	"sundar_pichoy": {
		"name": "Sundar Pichoy",
		"table_path": "res://assets/data/characters/SundarPichoyAttackTable.tres"
	}
}
const SHOWCASE_MATCHUPS := [
	{"slug": "mark_vs_sam", "p1": "mark_zuck", "p2": "sam_altmyn"},
	{"slug": "peter_vs_zef", "p1": "peter_thyell", "p2": "zef_bezos"},
	{"slug": "bill_vs_sundar", "p1": "bill_geytz", "p2": "sundar_pichoy"}
]
const SIGNATURE_PLAN_BY_CHARACTER := {
	"mark_zuck": [
		{"kind": "signature_a", "delay_frames": 10},
		{"kind": "signature_b", "delay_frames": 12},
		{"kind": "signature_c", "delay_frames": 11},
		{"kind": "ultimate", "delay_frames": 14}
	],
	"sam_altmyn": [
		{"kind": "signature_a", "delay_frames": 10},
		{"kind": "signature_b", "delay_frames": 12},
		{"kind": "signature_c", "delay_frames": 11},
		{"kind": "ultimate", "delay_frames": 14}
	],
	"peter_thyell": [
		{"kind": "signature_a", "delay_frames": 11},
		{"kind": "signature_b", "delay_frames": 12},
		{"kind": "signature_c", "delay_frames": 10},
		{"kind": "ultimate", "delay_frames": 13}
	],
	"zef_bezos": [
		{"kind": "signature_a", "delay_frames": 12},
		{"kind": "signature_b", "delay_frames": 16},
		{"kind": "signature_c", "delay_frames": 12},
		{"kind": "ultimate", "delay_frames": 14}
	],
	"bill_geytz": [
		{"kind": "signature_a", "delay_frames": 10},
		{"kind": "signature_b", "delay_frames": 12},
		{"kind": "signature_c", "delay_frames": 12},
		{"kind": "ultimate", "delay_frames": 14}
	],
	"sundar_pichoy": [
		{"kind": "signature_a", "delay_frames": 10},
		{"kind": "signature_b", "delay_frames": 12},
		{"kind": "signature_c", "delay_frames": 12},
		{"kind": "ultimate", "delay_frames": 14}
	]
}

var events: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	TranslationServer.set_locale("en")
	_prepare_output_dir()
	for matchup_value in SHOWCASE_MATCHUPS:
		if typeof(matchup_value) != TYPE_DICTIONARY:
			continue
		await _run_matchup(matchup_value as Dictionary)
	_write_log()
	SessionStateStore.clear_keys()
	print("SIGNATURE_SHOWCASE_OUTPUT %s" % OUTPUT_DIR)
	get_tree().quit()

func _run_matchup(matchup: Dictionary) -> void:
	var slug := str(matchup.get("slug", "showcase"))
	var p1_id := str(matchup.get("p1", ""))
	var p2_id := str(matchup.get("p2", ""))
	if not CHARACTER_LIBRARY.has(p1_id) or not CHARACTER_LIBRARY.has(p2_id):
		return
	for actor_key in ["p1", "p2"]:
		var actor_id := p1_id if actor_key == "p1" else p2_id
		var plan_value: Variant = SIGNATURE_PLAN_BY_CHARACTER.get(actor_id, [])
		if typeof(plan_value) != TYPE_ARRAY:
			continue
		for move_value in plan_value as Array:
			if typeof(move_value) != TYPE_DICTIONARY:
				continue
			await _run_signature_capture(slug, p1_id, p2_id, actor_key, move_value as Dictionary)

func _run_signature_capture(
	slug: String,
	p1_id: String,
	p2_id: String,
	actor_key: String,
	move: Dictionary
) -> void:
	_configure_session(p1_id, p2_id)
	var packed := load(STORY_SCENE_PATH)
	if packed is not PackedScene:
		push_error("Signature showcase failed to load Story scene")
		return
	var story_match := (packed as PackedScene).instantiate()
	add_child(story_match)
	await _wait_frames(6)
	var p1 := story_match.get_node_or_null("Player1")
	var p2 := story_match.get_node_or_null("Player2")
	if p1 == null or p2 == null:
		push_error("Signature showcase failed to resolve fighters")
		story_match.queue_free()
		await _wait_frames(2)
		return
	_prime_fighter_for_showcase(p1)
	_prime_fighter_for_showcase(p2)
	_layout_showcase_fighters(story_match, p1, p2)
	await _wait_frames(4)
	var actor := p1 if actor_key == "p1" else p2
	var actor_id := p1_id if actor_key == "p1" else p2_id
	var move_kind := str(move.get("kind", ""))
	var delay_frames := maxi(8, int(move.get("delay_frames", 12)))
	var anchor_position := (actor as Node2D).global_position
	actor.call("_start_attack", move_kind)
	var log_line := "SHOWCASE matchup=%s actor=%s move=%s frame_delay=%d" % [slug, actor_id, move_kind, delay_frames]
	print(log_line)
	events.append(log_line)
	await _wait_for_signature_read_frame(actor, move_kind, delay_frames, anchor_position)
	await _capture("%s_%s_%s" % [slug, actor_id, move_kind])
	await _wait_physics_frames(12)
	if is_instance_valid(story_match):
		story_match.queue_free()
	await _wait_frames(4)
	SessionStateStore.clear_keys()

func _configure_session(p1_id: String, p2_id: String) -> void:
	SessionStateStore.clear_keys()
	_apply_session_character("p1", p1_id)
	_apply_session_character("p2", p2_id)
	SessionStateStore.set_value(SessionKeysStore.MATCH_MODE, "vs")

func _apply_session_character(player_key: String, character_id: String) -> void:
	var data_value: Variant = CHARACTER_LIBRARY.get(character_id, {})
	if typeof(data_value) != TYPE_DICTIONARY:
		return
	var data := data_value as Dictionary
	var loadout: Dictionary = LoadoutCatalogStore.get_default_loadout(character_id)
	match player_key:
		"p1":
			SessionStateStore.set_value(SessionKeysStore.PLAYER_1_ID, character_id)
			SessionStateStore.set_value(SessionKeysStore.PLAYER_1_TABLE_PATH, str(data.get("table_path", "")))
			SessionStateStore.set_value(SessionKeysStore.PLAYER_1_NAME, str(data.get("name", "Player 1")))
			SessionStateStore.set_value(SessionKeysStore.PLAYER_1_LOADOUT, loadout.duplicate(true))
		"p2":
			SessionStateStore.set_value(SessionKeysStore.PLAYER_2_ID, character_id)
			SessionStateStore.set_value(SessionKeysStore.PLAYER_2_TABLE_PATH, str(data.get("table_path", "")))
			SessionStateStore.set_value(SessionKeysStore.PLAYER_2_NAME, str(data.get("name", "Player 2")))
			SessionStateStore.set_value(SessionKeysStore.PLAYER_2_LOADOUT, loadout.duplicate(true))

func _prime_fighter_for_showcase(fighter: Node) -> void:
	fighter.set("is_ai", false)
	fighter.set("current_hp", 100)
	fighter.set("hype_meter", 100.0)
	fighter.set("velocity", Vector2.ZERO)
	fighter.set("skill_cooldowns", {})
	fighter.call("_clear_attack_state")
	fighter.call("_clear_attack_buffer")
	fighter.call("_clear_transient_visual_fx")
	var entities := fighter.get("skill_entities") as Array
	fighter.call("_free_skill_entity_nodes", entities)
	fighter.set("skill_entities", [])

func _layout_showcase_fighters(story_match: Node, p1: Node, p2: Node) -> void:
	var baseline_y := maxf((p1 as Node2D).global_position.y, (p2 as Node2D).global_position.y)
	(p1 as Node2D).global_position = Vector2(470.0, baseline_y)
	(p2 as Node2D).global_position = Vector2(710.0, baseline_y)
	p1.set("velocity", Vector2.ZERO)
	p2.set("velocity", Vector2.ZERO)
	p1.set("facing", 1)
	p2.set("facing", -1)
	p1.set("facing_locked", false)
	p2.set("facing_locked", false)
	if story_match.has_method("_update_camera"):
		story_match.call("_update_camera", 1.0)

func _prepare_output_dir() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)

func _wait_frames(count: int) -> void:
	for _index in range(maxi(1, count)):
		await get_tree().process_frame

func _wait_physics_frames(count: int) -> void:
	for _index in range(maxi(1, count)):
		await get_tree().physics_frame

func _wait_for_signature_read_frame(actor: Node, move_kind: String, fallback_frames: int, anchor_position: Vector2) -> void:
	var min_ready_frames := maxi(4, fallback_frames / 2)
	var max_frames := maxi(fallback_frames + 18, 24)
	for frame_index in range(max_frames):
		await get_tree().physics_frame
		var attack_phase := str(actor.get("attack_phase"))
		var trail_count := (actor.get("transient_visual_fx") as Array).size()
		var entity_count := (actor.get("skill_entities") as Array).size()
		var moved := ((actor as Node2D).global_position - anchor_position).length() > 8.0
		var ready := false
		if trail_count > 0 or entity_count > 0:
			ready = true
		elif frame_index >= min_ready_frames and attack_phase == "active":
			ready = true
		elif move_kind == "signature_b" and moved and frame_index >= min_ready_frames:
			ready = true
		elif move_kind == "ultimate" and frame_index >= fallback_frames and attack_phase in ["active", "recovery"]:
			ready = true
		if ready:
			await _wait_physics_frames(2)
			return
	await _wait_physics_frames(maxi(1, fallback_frames / 2))

func _capture(name: String) -> void:
	await _wait_frames(2)
	var image := get_viewport().get_texture().get_image()
	if image == null:
		push_warning("Signature showcase capture skipped: %s" % name)
		return
	var path := "%s/%s.png" % [OUTPUT_DIR, name]
	var error := image.save_png(path)
	if error != OK:
		push_warning("Signature showcase capture failed: %s (%s)" % [path, error_string(error)])
		return
	var line := "CAPTURE %s" % path
	print(line)
	events.append(line)

func _write_log() -> void:
	var file := FileAccess.open("%s/showcase.log" % OUTPUT_DIR, FileAccess.WRITE)
	if file == null:
		push_warning("Signature showcase could not open log file")
		return
	for line in events:
		file.store_line(line)

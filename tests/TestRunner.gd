extends SceneTree

const GameSettingsStore := preload("res://scripts/GameSettings.gd")
const LoadoutCatalogStore := preload("res://scripts/config/LoadoutCatalog.gd")
const SessionKeysStore := preload("res://scripts/config/SessionKeys.gd")
const SessionStateStore := preload("res://scripts/SessionState.gd")
const LoadoutValidatorStore := preload("res://scripts/loadout/LoadoutValidator.gd")
const LoadoutResolverStore := preload("res://scripts/loadout/LoadoutResolver.gd")
const EvolutionEngineStore := preload("res://scripts/loadout/EvolutionEngine.gd")
const RoundTuningEngineStore := preload("res://scripts/loadout/RoundTuningEngine.gd")
const AttackTableStore := preload("res://scripts/resources/AttackTable.gd")
const GeneratedSkillProfilesStore := preload("res://scripts/player/GeneratedSkillProfiles.gd")
const PlayerDataStore := preload("res://scripts/player/PlayerData.gd")
const PlayerSignatureAttackBuilderStore := preload("res://scripts/player/PlayerSignatureAttackBuilder.gd")
const REQUIRED_BASE_ATTACKS := ["light", "heavy", "special", "throw"]
const SUITE_SMOKE := "smoke"
const SUITE_FULL := "full"

var _failures: Array[String] = []
var _passes := 0
var _suite := SUITE_SMOKE

func _initialize() -> void:
	_suite = _resolve_suite_from_args(OS.get_cmdline_user_args())
	call_deferred("_run")

func _run() -> void:
	_assert_true(_resolve_suite_from_args(["--suite", "smoke"]) == SUITE_SMOKE, "suite parser reads --suite smoke")
	_assert_true(_resolve_suite_from_args(["--suite=full"]) == SUITE_FULL, "suite parser reads --suite=full")
	_assert_true(_resolve_suite_from_args(["unknown"]) == SUITE_SMOKE, "suite parser falls back to smoke for unknown values")
	print("Running suite: %s" % _suite)
	if _suite == SUITE_FULL:
		await _run_full_suite()
	else:
		await _run_smoke_suite()
	_finish()

func _run_smoke_suite() -> void:
	await _test_character_attack_tables_are_valid()
	await _test_core_scenes_boot()
	await _test_main_scene_prototype_signature_coverage()
	await _test_main_scene_runtime_match_flow()
	await _test_main_scene_stock_ring_out_flow()
	await _test_menu_selection_session_flow()
	await _test_character_profile_surface_in_menu_and_hud()
	await _test_main_scene_vs_mode_local_control_flow()
	await _test_story_mode_sets_ai_opponent()
	await _test_story_mode_round_progression_override()
	await _test_story_mode_duel_rules_surface()
	await _test_story_mode_camera_profile_surface()
	await _test_main_scene_stage_bounds_sync()
	await _test_arena_extra_platform_colliders()
	await _test_main_scene_ledge_recovery_flow()
	await _test_platform_drop_through_collision_mask()
	await _test_ledge_slot_occupancy_arbitration()
	await _test_pause_panel_menu_route()
	await _test_training_timer_visibility()
	await _test_training_quick_start_hint_renders()
	await _test_onboarding_settings_and_guided_start_surface()
	await _test_story_mode_skips_first_run_onboarding_overlay()
	await _test_onboarding_progress_tracks_actual_player_state()
	await _test_menu_focus_path_and_summary_cards()
	await _test_control_preset_profiles()
	await _test_video_settings_profiles()
	await _test_loadout_system_foundation()
	await _test_loadout_session_flow_runtime_apply()
	await _test_menu_loadout_fallback_surface()
	await _test_loadout_item_trigger_and_cooldown_runtime()
	await _test_loadout_item_evolution_boundaries()
	await _test_loadout_wave1_tuning_profiles_present()
	await _test_generated_signature_profiles_are_normalized()
	await _test_generated_signature_builder_uses_role_skeletons()
	await _test_round_tuning_intermission_flow()
	await _test_round_tuning_simultaneous_stock_fairness()
	await _test_round_tuning_pick_cap_per_player()
	await _test_round_tuning_leader_lock_gap()
	await _test_round_tuning_max_charges_patch_grants_charges()
	await _test_match_metrics_telemetry_schema()
	await _test_directional_attack_variants()
	await _test_local_dual_gamepad_input_actions()
	await _test_forward_tap_triggers_ground_dash()
	await _test_jump_leniency_and_fast_fall()
	await _test_short_hop_jump_cut()
	await _test_aerial_landing_lag_and_auto_cancel()
	await _test_shield_resource_and_break_flow()
	await _test_duel_ruleset_defense_profile()
	await _test_defensive_dodge_layer()
	await _test_double_jump_and_ledge_getup_options()
	await _test_hitstop_overlap_recovery()
	await _test_camera_zoom_response()
	await _test_camera_vertical_framing_response()
	await _test_training_toggle_keeps_dummy_non_ai()
	await _test_training_sandbox_resets_on_ko_and_ring_out()
	await _test_air_edge_drills_have_rep_behaviors()
	await _test_character_visual_readability_tinting()
	await _test_player_visual_fx_pipeline()
	await _test_signature_visual_identity_pipeline()
	await _test_signature_showcase_autoplay_scene()
	await _test_double_ko_resolution()
	await _test_player_damage_and_block_flow()
	await _test_throw_tech_and_ai_defense_windows()
	await _test_knockback_growth_and_di_response()
	await _test_hitstop_tier_resolution()

func _run_full_suite() -> void:
	await _run_smoke_suite()
	await _test_skill_runtime_primitives()
	await _test_motion_feel_primitives()
	await _test_ai_behavior_profiles()
	await _test_wave1_vertical_slice_skills()
	await _test_full_roster_signature_coverage()

func _resolve_suite_from_args(args: PackedStringArray) -> String:
	var requested := ""
	for index in range(args.size()):
		var arg := str(args[index]).strip_edges()
		if arg == "--suite" and index + 1 < args.size():
			requested = str(args[index + 1]).strip_edges().to_lower()
			break
		if arg.begins_with("--suite="):
			requested = arg.substr(8).strip_edges().to_lower()
			break
	if requested == "" and args.size() > 0:
		var fallback_arg := str(args[0]).strip_edges().to_lower()
		if not fallback_arg.begins_with("--"):
			requested = fallback_arg
	if requested == SUITE_FULL or requested == "all":
		return SUITE_FULL
	if requested == SUITE_SMOKE:
		return SUITE_SMOKE
	return SUITE_SMOKE

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
			_assert_attack_entry_shape(file_name, key, entry_dict)
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

func _assert_attack_entry_shape(file_name: String, key: String, entry: Dictionary) -> void:
	for number_key in ["startup", "active", "recovery", "damage", "hitstun", "blockstun"]:
		var value: Variant = entry.get(number_key, null)
		_assert_true(value is int or value is float, "%s.%s.%s is numeric" % [file_name, key, number_key])
	for vector_key in [
		"hitbox_size_ground",
		"hitbox_size_air",
		"hitbox_offset_ground",
		"hitbox_offset_air",
		"knockback_ground",
		"knockback_air"
	]:
		var vector_value: Variant = entry.get(vector_key, null)
		_assert_true(vector_value is Vector2, "%s.%s.%s is Vector2" % [file_name, key, vector_key])

func _test_core_scenes_boot() -> void:
	await _assert_scene_boot("res://scenes/Menu.tscn")
	await _assert_scene_boot("res://scenes/Main.tscn")
	await _assert_scene_boot("res://scenes/Story.tscn")
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

func _test_main_scene_prototype_signature_coverage() -> void:
	var packed := load("res://scenes/Main.tscn")
	_assert_true(packed is PackedScene, "main scene loads for prototype signature coverage test")
	if packed is not PackedScene:
		return
	var match_node := (packed as PackedScene).instantiate()
	match_node.set("round_tuning_enabled", false)
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var p1 := match_node.get_node_or_null("Player1")
	var p2 := match_node.get_node_or_null("Player2")
	_assert_true(p1 != null and p2 != null, "prototype signature coverage resolves both players")
	if p1 != null and p2 != null:
		for key in ["signature_a", "signature_b", "signature_c", "ultimate"]:
			_assert_true(bool(p1.call("_has_attack_kind", key)), "Main Player1 runtime has %s" % key)
			_assert_true(bool(p2.call("_has_attack_kind", key)), "Main Player2 runtime has %s" % key)
		p1.set("attack_state", "")
		p1.set("skill_cooldowns", {})
		p1.call("_start_attack", "signature_a")
		_assert_true(str(p1.get("attack_state")) == "signature_a", "Main Player1 can start signature_a")
		p2.set("attack_state", "")
		p2.set("skill_cooldowns", {})
		p2.set("hype_meter", 100.0)
		p2.call("_start_attack", "ultimate")
		_assert_true(str(p2.get("attack_state")) == "ultimate", "Main Player2 can start ultimate")
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_main_scene_runtime_match_flow() -> void:
	var packed := load("res://scenes/Main.tscn")
	_assert_true(packed is PackedScene, "main scene loads for runtime match flow test")
	if packed is not PackedScene:
		return
	var match_node := (packed as PackedScene).instantiate()
	match_node.set("round_tuning_enabled", false)
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var p1 := match_node.get_node_or_null("Player1")
	var p2 := match_node.get_node_or_null("Player2")
	var result_label := match_node.get_node_or_null("Hud/ResultLabel")
	_assert_true(p1 != null and p2 != null, "runtime match flow test resolves both fighters")
	_assert_true(result_label is Label, "runtime match flow test resolves HUD result label")
	_assert_true(str(match_node.get("win_rule")) == "hp_timer", "runtime match flow defaults Main to duel win rule")
	if p2 != null:
		p2.set("is_ai", false)
		p2.call("apply_damage", 999, Vector2(180, -24), 0.14, "heavy", {})
		await process_frame
		await process_frame
		_assert_true(bool(match_node.get("match_over")), "duel mode ends match immediately after KO")
		_assert_true(str(match_node.get("match_result_key")) == "p1_win", "runtime match flow resolves KO winner as p1")
	if result_label is Label:
		_assert_true((result_label as Label).text.strip_edges() != "", "runtime match flow shows result text on HUD")
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_main_scene_stock_ring_out_flow() -> void:
	var packed := load("res://scenes/Main.tscn")
	_assert_true(packed is PackedScene, "main scene loads for stock ring-out test")
	if packed is not PackedScene:
		return
	var match_node := (packed as PackedScene).instantiate()
	match_node.set("win_rule", "stock")
	match_node.set("ruleset_profile", "platform")
	match_node.set("round_tuning_enabled", false)
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var p2 := match_node.get_node_or_null("Player2")
	_assert_true(p2 != null, "stock ring-out test resolves player2")
	if p2 != null:
		p2.set("is_ai", false)
		var before := int((match_node.get("stocks") as Dictionary).get("p2", 0))
		p2.position = Vector2(1300.0, p2.position.y)
		await process_frame
		await process_frame
		var after := int((match_node.get("stocks") as Dictionary).get("p2", 0))
		_assert_true(after == before - 1, "exiting blast zone consumes one stock")
		var spawn_points := match_node.get("spawn_points") as Dictionary
		var expected_spawn_value: Variant = spawn_points.get("p2", Vector2(600.0, 300.0))
		var expected_spawn: Vector2 = expected_spawn_value if expected_spawn_value is Vector2 else Vector2(600.0, 300.0)
		_assert_true(p2.global_position.distance_to(expected_spawn) <= 1.0, "ring-out respawns fighter at spawn point")
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_pause_panel_menu_route() -> void:
	var packed := load("res://scenes/ui/Hud.tscn")
	_assert_true(packed is PackedScene, "hud scene loads for pause menu route test")
	if packed is not PackedScene:
		return
	var hud_node := (packed as PackedScene).instantiate()
	get_root().add_child(hud_node)
	await process_frame
	_assert_true(hud_node.has_signal("menu_requested"), "hud exposes menu_requested signal")
	_assert_true(hud_node.get_node_or_null("PausePanel/BackMenuButton") != null, "pause panel has BackMenuButton")
	if is_instance_valid(hud_node):
		hud_node.queue_free()
	await process_frame

func _test_menu_selection_session_flow() -> void:
	var menu_packed := load("res://scenes/Menu.tscn")
	_assert_true(menu_packed is PackedScene, "menu scene loads for session flow test")
	if menu_packed is not PackedScene:
		return
	var menu_node := (menu_packed as PackedScene).instantiate()
	get_root().add_child(menu_node)
	await process_frame
	await process_frame
	menu_node.call("_store_character_selection", "vs")
	if is_instance_valid(menu_node):
		menu_node.queue_free()
	await process_frame

	var match_packed := load("res://scenes/Main.tscn")
	_assert_true(match_packed is PackedScene, "main scene loads for session flow test")
	if match_packed is not PackedScene:
		return
	var match_node := (match_packed as PackedScene).instantiate()
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var selected_ids_value: Variant = match_node.get("selected_character_ids")
	var selected_names_value: Variant = match_node.get("selected_character_names")
	_assert_true(typeof(selected_ids_value) == TYPE_DICTIONARY, "session flow exposes selected character ids")
	_assert_true(typeof(selected_names_value) == TYPE_DICTIONARY, "session flow exposes selected character names")
	if typeof(selected_ids_value) == TYPE_DICTIONARY:
		var selected_ids := selected_ids_value as Dictionary
		_assert_true(str(selected_ids.get("p1", "")) != "", "session flow resolves p1 id")
		_assert_true(str(selected_ids.get("p2", "")) != "", "session flow resolves p2 id")
	if typeof(selected_names_value) == TYPE_DICTIONARY:
		var selected_names := selected_names_value as Dictionary
		_assert_true(str(selected_names.get("p1", "")) != "", "session flow resolves p1 name")
		_assert_true(str(selected_names.get("p2", "")) != "", "session flow resolves p2 name")
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_character_profile_surface_in_menu_and_hud() -> void:
	var menu_packed := load("res://scenes/Menu.tscn")
	_assert_true(menu_packed is PackedScene, "menu scene loads for character profile surface test")
	if menu_packed is not PackedScene:
		return
	var menu_node := (menu_packed as PackedScene).instantiate()
	get_root().add_child(menu_node)
	await process_frame
	await process_frame
	var p1_profile_label := menu_node.get_node_or_null("CenterPanel/P1ProfileLabel")
	var p2_profile_label := menu_node.get_node_or_null("CenterPanel/P2ProfileLabel")
	_assert_true(p1_profile_label is Label and p2_profile_label is Label, "menu profile labels resolve for both players")
	if p1_profile_label is Label:
		_assert_true((p1_profile_label as Label).text.strip_edges() != "", "menu p1 profile preview text is populated")
		_assert_true((p1_profile_label as Label).tooltip_text.strip_edges() != "", "menu p1 archetype hint is exposed")
	if p2_profile_label is Label:
		_assert_true((p2_profile_label as Label).text.strip_edges() != "", "menu p2 profile preview text is populated")
		_assert_true((p2_profile_label as Label).tooltip_text.strip_edges() != "", "menu p2 archetype hint is exposed")
	menu_node.call("_store_character_selection", "vs")
	if is_instance_valid(menu_node):
		menu_node.queue_free()
	await process_frame

	var main_packed := load("res://scenes/Main.tscn")
	_assert_true(main_packed is PackedScene, "main scene loads for character profile hud surface test")
	if main_packed is not PackedScene:
		return
	var match_node := (main_packed as PackedScene).instantiate()
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var hud_node := match_node.get_node_or_null("Hud")
	_assert_true(hud_node != null, "profile surface test resolves HUD instance")
	if hud_node != null:
		var hud_p1_profile := hud_node.get_node_or_null("P1ProfileLabel")
		var hud_p2_profile := hud_node.get_node_or_null("P2ProfileLabel")
		_assert_true(hud_p1_profile is Label and hud_p2_profile is Label, "hud profile labels resolve for both players")
		if hud_p1_profile is Label:
			_assert_true((hud_p1_profile as Label).text.strip_edges() != "-", "hud displays p1 profile metadata row")
		if hud_p2_profile is Label:
			_assert_true((hud_p2_profile as Label).text.strip_edges() != "-", "hud displays p2 profile metadata row")
		var profiles_value: Variant = match_node.get("selected_character_profiles")
		if typeof(profiles_value) == TYPE_DICTIONARY:
			var profiles := profiles_value as Dictionary
			var p1_profile := profiles.get("p1", {}) as Dictionary
			var signature_names := p1_profile.get("signature_names", {}) as Dictionary
			var expected_name := str(signature_names.get("signature_a", ""))
			var resolved_name := str(hud_node.call("_resolve_training_attack_label", "signature_a", "p1"))
			_assert_true(resolved_name == expected_name, "training move label resolves to selected fighter signature name")
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_main_scene_vs_mode_local_control_flow() -> void:
	SessionStateStore.set_value(SessionKeysStore.MATCH_MODE, "vs")
	var packed := load("res://scenes/Main.tscn")
	_assert_true(packed is PackedScene, "main scene loads for vs mode local control test")
	if packed is not PackedScene:
		SessionStateStore.clear_keys(PackedStringArray([SessionKeysStore.MATCH_MODE]))
		return
	var match_node := (packed as PackedScene).instantiate()
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var p1 := match_node.get_node_or_null("Player1")
	var p2 := match_node.get_node_or_null("Player2")
	_assert_true(p1 != null and p2 != null, "vs mode local control test resolves both fighters")
	if p1 != null:
		_assert_true(not bool(p1.get("is_ai")), "vs mode keeps player1 as local fighter")
	if p2 != null:
		_assert_true(not bool(p2.get("is_ai")), "vs mode disables player2 ai for local versus")
	SessionStateStore.clear_keys(PackedStringArray([SessionKeysStore.MATCH_MODE]))
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_story_mode_sets_ai_opponent() -> void:
	SessionStateStore.set_value(SessionKeysStore.MATCH_MODE, "story")
	var packed := load("res://scenes/Story.tscn")
	_assert_true(packed is PackedScene, "story scene loads for single-player ai mode test")
	if packed is not PackedScene:
		SessionStateStore.clear_keys(PackedStringArray([SessionKeysStore.MATCH_MODE]))
		return
	var match_node := (packed as PackedScene).instantiate()
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var p1 := match_node.get_node_or_null("Player1")
	var p2 := match_node.get_node_or_null("Player2")
	_assert_true(p1 != null and p2 != null, "story mode test resolves both fighters")
	if p1 != null:
		_assert_true(not bool(p1.get("is_ai")), "story mode keeps player1 local")
	if p2 != null:
		_assert_true(bool(p2.get("is_ai")), "story mode enables player2 ai")
	SessionStateStore.clear_keys(PackedStringArray([SessionKeysStore.MATCH_MODE]))

func _test_story_mode_round_progression_override() -> void:
	SessionStateStore.set_value(SessionKeysStore.MATCH_MODE, "story")
	SessionStateStore.set_value(SessionKeysStore.PLAYER_1_ID, "mark_zuck")
	SessionStateStore.set_value(SessionKeysStore.PLAYER_1_NAME, "Mark Zuck")
	SessionStateStore.set_value(SessionKeysStore.PLAYER_1_TABLE_PATH, "res://assets/data/characters/MarkZuckAttackTable.tres")
	SessionStateStore.set_value(SessionKeysStore.STORY_ROUND_INDEX, 1)
	var packed := load("res://scenes/Story.tscn")
	_assert_true(packed is PackedScene, "story scene loads for round progression override test")
	if packed is not PackedScene:
		SessionStateStore.clear_keys(PackedStringArray([
			SessionKeysStore.MATCH_MODE,
			SessionKeysStore.PLAYER_1_ID,
			SessionKeysStore.PLAYER_1_NAME,
			SessionKeysStore.PLAYER_1_TABLE_PATH,
			SessionKeysStore.STORY_ROUND_INDEX
		]))
		return
	var match_node := (packed as PackedScene).instantiate()
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var selected_ids_value: Variant = match_node.get("selected_character_ids")
	_assert_true(typeof(selected_ids_value) == TYPE_DICTIONARY, "story round override exposes selected ids")
	if typeof(selected_ids_value) == TYPE_DICTIONARY:
		var selected_ids := selected_ids_value as Dictionary
		_assert_true(str(selected_ids.get("p2", "")) != str(selected_ids.get("p1", "")), "story round override picks AI opponent distinct from p1")
	_assert_true(int(match_node.get("story_round_index")) >= 0, "story round override resolves a valid story round index")
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame
	SessionStateStore.clear_keys(PackedStringArray([
		SessionKeysStore.MATCH_MODE,
		SessionKeysStore.PLAYER_1_ID,
		SessionKeysStore.PLAYER_1_NAME,
		SessionKeysStore.PLAYER_1_TABLE_PATH,
		SessionKeysStore.STORY_ROUND_INDEX
	]))
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_story_mode_duel_rules_surface() -> void:
	SessionStateStore.set_value(SessionKeysStore.MATCH_MODE, "story")
	var packed := load("res://scenes/Story.tscn")
	_assert_true(packed is PackedScene, "story scene loads for duel rules surface test")
	if packed is not PackedScene:
		SessionStateStore.clear_keys(PackedStringArray([SessionKeysStore.MATCH_MODE]))
		return
	var story_node := (packed as PackedScene).instantiate()
	get_root().add_child(story_node)
	await process_frame
	await process_frame
	_assert_true(str(story_node.get("win_rule")) == "hp_timer", "story mode switches to hp-timer duel rules")
	var arena_node := story_node.get_node_or_null("Arena")
	_assert_true(arena_node != null, "story duel rules test resolves arena")
	if arena_node != null:
		_assert_true(not bool(arena_node.get("side_platforms_enabled")), "story mode disables side platforms")
		for platform_name in ["PlatformLeft", "PlatformRight"]:
			var platform_node := arena_node.get_node_or_null(platform_name) as StaticBody2D
			_assert_true(platform_node != null, "story arena resolves %s" % platform_name)
			if platform_node != null:
				_assert_true(platform_node.collision_layer == 0, "story arena removes %s collision layer" % platform_name)
	if is_instance_valid(story_node):
		story_node.queue_free()
	await process_frame
	SessionStateStore.clear_keys(PackedStringArray([SessionKeysStore.MATCH_MODE]))

func _test_story_mode_camera_profile_surface() -> void:
	var packed := load("res://scenes/Story.tscn")
	_assert_true(packed is PackedScene, "story scene loads for camera profile surface test")
	if packed is not PackedScene:
		return
	var story_node := (packed as PackedScene).instantiate()
	get_root().add_child(story_node)
	await process_frame
	await process_frame
	_assert_true(float(story_node.get("camera_zoom_near")) >= 1.30, "story mode starts from a tighter close-range camera")
	_assert_true(float(story_node.get("camera_zoom_far")) >= 1.10, "story mode keeps duel framing tight even when fighters separate")
	_assert_true(float(story_node.get("camera_horizontal_far_distance")) <= 280.0, "story mode uses tighter horizontal camera framing")
	var arena_node := story_node.get_node_or_null("Arena")
	_assert_true(arena_node != null and arena_node.has_method("set_presentation_state"), "story arena exposes camera-synced presentation shell")
	var camera_value: Variant = story_node.get("camera")
	_assert_true(camera_value is Camera2D, "story mode resolves runtime camera instance")
	if camera_value is Camera2D:
		_assert_true((camera_value as Camera2D).is_current(), "story mode camera becomes the active viewport camera")
	if is_instance_valid(story_node):
		story_node.queue_free()
	await process_frame

func _test_main_scene_stage_bounds_sync() -> void:
	var packed := load("res://scenes/Main.tscn")
	_assert_true(packed is PackedScene, "main scene loads for stage bounds sync test")
	if packed is not PackedScene:
		return
	var match_node := (packed as PackedScene).instantiate()
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var p1 := match_node.get_node_or_null("Player1")
	var p2 := match_node.get_node_or_null("Player2")
	_assert_true(p1 != null and p2 != null, "stage bounds sync test resolves both fighters")
	var stage_left := float(match_node.get("stage_left_x"))
	var stage_right := float(match_node.get("stage_right_x"))
	var stage_floor := float(match_node.get("stage_floor_y"))
	_assert_true(stage_right > stage_left, "match stage bounds resolve valid range")
	_assert_true(stage_floor > -200.0 and stage_floor < 800.0, "match stage floor resolves plausible value")
	if p1 != null:
		_assert_true(is_equal_approx(float(p1.get("stage_left_x")), stage_left), "player1 receives stage left bound from match")
		_assert_true(is_equal_approx(float(p1.get("stage_right_x")), stage_right), "player1 receives stage right bound from match")
		_assert_true(is_equal_approx(float(p1.get("stage_floor_y")), stage_floor), "player1 receives stage floor from match")
	if p2 != null:
		_assert_true(is_equal_approx(float(p2.get("stage_left_x")), stage_left), "player2 receives stage left bound from match")
		_assert_true(is_equal_approx(float(p2.get("stage_right_x")), stage_right), "player2 receives stage right bound from match")
		_assert_true(is_equal_approx(float(p2.get("stage_floor_y")), stage_floor), "player2 receives stage floor from match")
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_arena_extra_platform_colliders() -> void:
	var packed := load("res://scenes/Arena.tscn")
	_assert_true(packed is PackedScene, "arena scene loads for extra platform collider test")
	if packed is not PackedScene:
		return
	var arena_node := (packed as PackedScene).instantiate()
	get_root().add_child(arena_node)
	await process_frame
	var ground_shape := arena_node.get_node_or_null("Ground/CollisionShape2D")
	_assert_true(ground_shape is CollisionShape2D, "arena test resolves ground collision shape")
	var ground_y := 360.0
	if ground_shape is CollisionShape2D:
		ground_y = float((ground_shape as CollisionShape2D).global_position.y)
	for platform_name in ["PlatformLeft", "PlatformRight"]:
		var platform_node := arena_node.get_node_or_null(platform_name)
		_assert_true(platform_node is StaticBody2D, "arena exposes %s platform body" % platform_name)
		if platform_node is not StaticBody2D:
			continue
		var platform_shape_node := (platform_node as StaticBody2D).get_node_or_null("CollisionShape2D")
		_assert_true(platform_shape_node is CollisionShape2D, "%s exposes collision shape" % platform_name)
		if platform_shape_node is not CollisionShape2D:
			continue
		var platform_shape := platform_shape_node as CollisionShape2D
		_assert_true(platform_shape.shape is RectangleShape2D, "%s collider uses rectangle shape" % platform_name)
		if platform_shape.shape is RectangleShape2D:
			var rect := platform_shape.shape as RectangleShape2D
			_assert_true(rect.size.x >= 120.0 and rect.size.y >= 10.0, "%s collider has platform-sized dimensions" % platform_name)
		_assert_true(platform_shape.one_way_collision, "%s collider uses one-way collision" % platform_name)
		_assert_true(float(platform_shape.global_position.y) < ground_y - 20.0, "%s collider is elevated above floor" % platform_name)
	if is_instance_valid(arena_node):
		arena_node.queue_free()
	await process_frame

func _test_main_scene_ledge_recovery_flow() -> void:
	var packed := load("res://scenes/Main.tscn")
	_assert_true(packed is PackedScene, "main scene loads for ledge recovery test")
	if packed is not PackedScene:
		return
	var match_node := (packed as PackedScene).instantiate()
	match_node.set("win_rule", "stock")
	match_node.set("ruleset_profile", "platform")
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var p1 := match_node.get_node_or_null("Player1")
	_assert_true(p1 != null, "ledge recovery test resolves player1")
	if p1 != null:
		p1.set("is_ai", false)
		var stage_right := float(match_node.get("stage_right_x"))
		var stage_floor := float(match_node.get("stage_floor_y"))
		p1.global_position = Vector2(stage_right + 10.0, stage_floor + 30.0)
		p1.set("velocity", Vector2(0.0, 120.0))
		p1.call("_physics_process", 1.0 / 60.0)
		_assert_true(bool(p1.get("is_ledge_hanging")), "off-stage descent near edge enters ledge hang")
		if bool(p1.get("is_ledge_hanging")):
			p1.call("_launch_from_ledge")
			_assert_true(not bool(p1.get("is_ledge_hanging")), "ledge launch exits ledge hang state")
			var velocity_value: Variant = p1.get("velocity")
			_assert_true(velocity_value is Vector2, "ledge launch exposes velocity vector")
			if velocity_value is Vector2:
				var launch_velocity := velocity_value as Vector2
				_assert_true(launch_velocity.y < -20.0, "ledge launch gives upward recovery velocity")
				_assert_true(launch_velocity.x < -20.0, "right-side ledge launch pushes fighter toward stage")
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_platform_drop_through_collision_mask() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or host == null:
		return
	p1.call("set_stage_geometry", 0.0, 900.0, 340.0)
	p1.global_position = Vector2(270.0, 250.0)
	_assert_true(bool(p1.call("_is_on_drop_through_platform")), "platform drop-through helper detects elevated one-way platform height")
	p1.set("platform_drop_through_time", 0.12)
	p1.call("_update_platform_collision_mask")
	_assert_true(not p1.get_collision_mask_value(2), "platform drop-through disables platform collision layer")
	p1.set("platform_drop_through_time", 0.0)
	p1.call("_update_platform_collision_mask")
	_assert_true(p1.get_collision_mask_value(2), "platform collision layer is restored after drop-through timer")
	host.queue_free()
	await process_frame

func _test_ledge_slot_occupancy_arbitration() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var p2 := setup.get("p2") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or p2 == null or host == null:
		return
	p1.call("_start_ledge_hang", 1)
	_assert_true(bool(p1.get("is_ledge_hanging")), "ledge occupancy test enters hang for first fighter")
	_assert_true(not bool(p2.call("_is_ledge_slot_available", 1)), "occupied ledge slot blocks second fighter from grabbing same edge")
	p1.call("_end_ledge_hang")
	_assert_true(bool(p2.call("_is_ledge_slot_available", 1)), "ledge slot becomes available after first fighter releases edge")
	host.queue_free()
	await process_frame

func _test_training_timer_visibility() -> void:
	var training_packed := load("res://scenes/Training.tscn")
	_assert_true(training_packed is PackedScene, "training scene loads for timer visibility test")
	if training_packed is not PackedScene:
		return
	var training_node := (training_packed as PackedScene).instantiate()
	get_root().add_child(training_node)
	await process_frame
	await process_frame
	var training_hud := training_node.get_node_or_null("Hud")
	_assert_true(training_hud != null, "training timer visibility test resolves hud")
	if training_hud != null:
		var training_timer_label := training_hud.get_node_or_null("TimerLabel")
		var training_timer_chip := training_hud.get_node_or_null("TimerChip")
		_assert_true(training_timer_label is CanvasItem and not (training_timer_label as CanvasItem).visible, "training scene hides timer label when round timer is disabled")
		_assert_true(training_timer_chip is CanvasItem and not (training_timer_chip as CanvasItem).visible, "training scene hides timer chip when round timer is disabled")
	if is_instance_valid(training_node):
		training_node.queue_free()
	await process_frame

	var main_packed := load("res://scenes/Main.tscn")
	_assert_true(main_packed is PackedScene, "main scene loads for timer visibility test")
	if main_packed is not PackedScene:
		return
	var main_node := (main_packed as PackedScene).instantiate()
	get_root().add_child(main_node)
	await process_frame
	await process_frame
	var main_hud := main_node.get_node_or_null("Hud")
	_assert_true(main_hud != null, "main timer visibility test resolves hud")
	if main_hud != null:
		var main_timer_label := main_hud.get_node_or_null("TimerLabel")
		_assert_true(main_timer_label is CanvasItem and (main_timer_label as CanvasItem).visible, "main scene keeps timer label visible when stock timer is enabled")
	if is_instance_valid(main_node):
		main_node.queue_free()
	await process_frame

func _test_training_quick_start_hint_renders() -> void:
	var previous_locale := TranslationServer.get_locale()
	var previous_preset := GameSettingsStore.get_control_preset()
	GameSettingsStore.apply_control_preset(GameSettingsStore.CONTROL_PRESET_MODERN)
	var training_packed := load("res://scenes/Training.tscn")
	_assert_true(training_packed is PackedScene, "training scene loads for quick-start hint test")
	if training_packed is not PackedScene:
		return
	var training_node := (training_packed as PackedScene).instantiate()
	get_root().add_child(training_node)
	await process_frame
	await process_frame
	var training_hud := training_node.get_node_or_null("Hud")
	_assert_true(training_hud != null, "training quick-start hint test resolves hud")
	if training_hud != null:
		var hint_label := training_hud.get_node_or_null("TrainingPanel/TrainingQuickHintLabel")
		_assert_true(hint_label is Label, "training panel exposes quick-start hint label")
		if hint_label is Label:
			TranslationServer.set_locale("en")
			await process_frame
			var en_hint := (hint_label as Label).text.strip_edges()
			TranslationServer.set_locale("zh")
			await process_frame
			var zh_hint := (hint_label as Label).text.strip_edges()
			_assert_true(en_hint != "" and en_hint != "HUD_TRAINING_QUICK_HINT", "quick-start hint renders English localized text")
			_assert_true(zh_hint != "" and zh_hint != "HUD_TRAINING_QUICK_HINT", "quick-start hint renders Chinese localized text")
			_assert_true(en_hint != zh_hint, "quick-start hint changes with locale switch")
			_assert_true(en_hint.find("U Throw") != -1, "quick-start hint surfaces throw input in duel-first control copy")
			_assert_true(en_hint.find("Dodge:") != -1, "quick-start hint surfaces dodge input alongside throw")
	if is_instance_valid(training_node):
		training_node.queue_free()
	await process_frame
	if previous_preset != "":
		GameSettingsStore.apply_control_preset(previous_preset)
	TranslationServer.set_locale(previous_locale)
	await process_frame

func _test_onboarding_settings_and_guided_start_surface() -> void:
	var previous_settings := GameSettingsStore.get_onboarding_settings()
	var previous_completed := bool(previous_settings.get("completed", false))
	var previous_hints_enabled := bool(previous_settings.get("hints_enabled", true))
	GameSettingsStore.set_onboarding_completed(false)
	GameSettingsStore.set_onboarding_hints_enabled(true)
	var latest_settings := GameSettingsStore.get_onboarding_settings()
	_assert_true(
		not bool(latest_settings.get("completed", true)) and bool(latest_settings.get("hints_enabled", false)),
		"onboarding settings can persist completion and hint toggles"
	)

	var menu_packed := load("res://scenes/Menu.tscn")
	_assert_true(menu_packed is PackedScene, "menu scene loads for guided-start surface test")
	if menu_packed is PackedScene:
		var menu_node := (menu_packed as PackedScene).instantiate()
		get_root().add_child(menu_node)
		await process_frame
		await process_frame
		var guided_button := menu_node.get_node_or_null("CenterPanel/GuidedStartButton")
		_assert_true(guided_button is Button, "menu exposes guided onboarding start button")
		if guided_button is Button:
			_assert_true(
				(guided_button as Button).text.strip_edges() != "",
				"guided onboarding start button renders readable text"
			)
		if is_instance_valid(menu_node):
			menu_node.queue_free()
		await process_frame

	SessionStateStore.set_value(SessionKeysStore.MATCH_MODE, "training")
	SessionStateStore.set_value(SessionKeysStore.ONBOARDING_FORCE_REPLAY, true)
	SessionStateStore.set_value(SessionKeysStore.ONBOARDING_ENTRY_POINT, "guided_start")
	var training_packed := load("res://scenes/Training.tscn")
	_assert_true(training_packed is PackedScene, "training scene loads for forced onboarding replay test")
	if training_packed is PackedScene:
		var training_node := (training_packed as PackedScene).instantiate()
		get_root().add_child(training_node)
		await process_frame
		await process_frame
		var onboarding_panel := training_node.get_node_or_null("Hud/OnboardingPanel")
		_assert_true(onboarding_panel is CanvasItem, "training HUD exposes onboarding panel")
		if onboarding_panel is CanvasItem:
			_assert_true((onboarding_panel as CanvasItem).visible, "forced onboarding replay shows onboarding panel on match start")
		var step_label := training_node.get_node_or_null("Hud/OnboardingPanel/StepLabel")
		_assert_true(step_label is Label, "onboarding panel exposes step label")
		if step_label is Label:
			_assert_true((step_label as Label).text.strip_edges() != "", "onboarding panel renders active step text")
		if is_instance_valid(training_node):
			training_node.queue_free()
		await process_frame

	GameSettingsStore.set_onboarding_completed(previous_completed)
	GameSettingsStore.set_onboarding_hints_enabled(previous_hints_enabled)
	SessionStateStore.clear_keys(
		PackedStringArray([
			SessionKeysStore.MATCH_MODE,
			SessionKeysStore.ONBOARDING_FORCE_REPLAY,
			SessionKeysStore.ONBOARDING_ENTRY_POINT
		])
	)

func _test_story_mode_skips_first_run_onboarding_overlay() -> void:
	var previous_settings := GameSettingsStore.get_onboarding_settings()
	var previous_completed := bool(previous_settings.get("completed", false))
	var previous_hints_enabled := bool(previous_settings.get("hints_enabled", true))
	GameSettingsStore.set_onboarding_completed(false)
	GameSettingsStore.set_onboarding_hints_enabled(true)
	SessionStateStore.set_value(SessionKeysStore.MATCH_MODE, "story")
	SessionStateStore.set_value(SessionKeysStore.ONBOARDING_ENTRY_POINT, "story")
	var story_packed := load("res://scenes/Story.tscn")
	_assert_true(story_packed is PackedScene, "story scene loads for first-run onboarding gate test")
	if story_packed is PackedScene:
		var story_node := (story_packed as PackedScene).instantiate()
		get_root().add_child(story_node)
		await process_frame
		await process_frame
		var onboarding_panel := story_node.get_node_or_null("Hud/OnboardingPanel")
		_assert_true(onboarding_panel is CanvasItem, "story onboarding gate test resolves onboarding panel")
		if onboarding_panel is CanvasItem:
			_assert_true(not (onboarding_panel as CanvasItem).visible, "story mode skips quick onboarding overlay on first run")
		if is_instance_valid(story_node):
			story_node.queue_free()
		await process_frame
	GameSettingsStore.set_onboarding_completed(previous_completed)
	GameSettingsStore.set_onboarding_hints_enabled(previous_hints_enabled)
	SessionStateStore.clear_keys(PackedStringArray([
		SessionKeysStore.MATCH_MODE,
		SessionKeysStore.ONBOARDING_ENTRY_POINT
	]))

func _test_onboarding_progress_tracks_actual_player_state() -> void:
	var previous_preset := GameSettingsStore.get_control_preset()
	var previous_locale := TranslationServer.get_locale()
	TranslationServer.set_locale("en")
	GameSettingsStore.apply_control_preset(GameSettingsStore.CONTROL_PRESET_CLASSIC)

	var training_packed := load("res://scenes/Training.tscn")
	_assert_true(training_packed is PackedScene, "training scene loads for onboarding runtime state test")
	if training_packed is PackedScene:
		var training_node := (training_packed as PackedScene).instantiate()
		get_root().add_child(training_node)
		await process_frame
		await process_frame
		var player_1 := training_node.get_node_or_null("Player1")
		var step_label := training_node.get_node_or_null("Hud/OnboardingPanel/StepLabel")
		var status_label := training_node.get_node_or_null("Hud/OnboardingPanel/StatusLabel")
		_assert_true(player_1 != null, "onboarding runtime state test resolves player1")
		_assert_true(step_label is Label, "onboarding runtime state test resolves step label")
		_assert_true(status_label is Label, "onboarding runtime state test resolves status label")
		if player_1 != null and step_label is Label and status_label is Label:
			training_node.call("_start_onboarding_sequence")
			training_node.set("onboarding_step_index", 2)
			training_node.call("_sync_current_onboarding_lesson_state")
			training_node.call("_refresh_onboarding_hud")
			await process_frame
			_assert_true(
				(step_label as Label).text.findn("back") != -1,
				"classic onboarding guard copy explains back-to-block"
			)
			_assert_true(
				(status_label as Label).text.findn("Guard") != -1 or (status_label as Label).text.findn("strikes") != -1,
				"onboarding status copy explains the guard lesson goal"
			)
			_assert_true(not _action_has_any_keyboard_key("block"), "classic preset still removes keyboard block action during onboarding")

			player_1.set("is_blocking", true)
			training_node.call("_update_onboarding_progress")
			_assert_true(
				int(training_node.get("onboarding_step_index")) == 3,
				"guard onboarding advances from actual blocking state"
			)

			player_1.set("is_blocking", false)
			training_node.call("_refresh_onboarding_hud")
			await process_frame
			_assert_true(
				(step_label as Label).text.findn("throw") != -1,
				"onboarding throw lesson now follows the defense lesson"
			)

			player_1.set("attack_state", "throw")
			training_node.call("_update_onboarding_progress")
			_assert_true(
				int(training_node.get("onboarding_step_index")) == 4,
				"throw onboarding advances from actual throw state"
			)

			player_1.set("attack_state", "")
			training_node.call("_refresh_onboarding_hud")
			await process_frame
			_assert_true(
				(step_label as Label).text.findn("dash") != -1,
				"classic onboarding dodge copy explains back-plus-dash"
			)

			player_1.set("dodge_state", "roll")
			player_1.set("dodge_time", 0.12)
			training_node.call("_update_onboarding_progress")
			_assert_true(
				int(training_node.get("onboarding_step_index")) == 5,
				"dodge onboarding advances from actual dodge state"
			)
		if is_instance_valid(training_node):
			training_node.queue_free()
		await process_frame

	GameSettingsStore.apply_control_preset(previous_preset)
	TranslationServer.set_locale(previous_locale)
	await process_frame

func _test_control_preset_profiles() -> void:
	_replace_action_keyboard_keys("jump", [KEY_Z])
	_replace_action_keyboard_keys("block", [KEY_X])
	var settings_path := ProjectSettings.globalize_path(GameSettingsStore.SETTINGS_PATH)
	if FileAccess.file_exists(settings_path):
		DirAccess.remove_absolute(settings_path)
	if Engine.has_meta(GameSettingsStore.ENGINE_META_KEY):
		Engine.remove_meta(GameSettingsStore.ENGINE_META_KEY)
	var menu_packed := load("res://scenes/Menu.tscn")
	_assert_true(menu_packed is PackedScene, "menu scene loads for first-launch control selection test")
	if menu_packed is PackedScene:
		var menu_node := (menu_packed as PackedScene).instantiate()
		get_root().add_child(menu_node)
		await process_frame
		await process_frame
		_assert_true(_action_has_keyboard_key("jump", KEY_Z), "first-launch flow does not auto-apply modern jump mapping")
		_assert_true(_action_has_keyboard_key("block", KEY_X), "first-launch flow does not auto-apply modern block mapping")
		_assert_true(
			str(menu_node.get("current_control_preset")) == GameSettingsStore.CONTROL_PRESET_MODERN,
			"first-launch flow recommends modern controls by default"
		)
		if is_instance_valid(menu_node):
			menu_node.queue_free()
		await process_frame

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

func _test_menu_focus_path_and_summary_cards() -> void:
	var previous_settings := GameSettingsStore.get_onboarding_settings()
	var previous_completed := bool(previous_settings.get("completed", false))
	var previous_hints_enabled := bool(previous_settings.get("hints_enabled", true))
	var previous_preset := GameSettingsStore.get_control_preset()
	var previous_locale := TranslationServer.get_locale()
	TranslationServer.set_locale("en")
	GameSettingsStore.set_control_preset(GameSettingsStore.CONTROL_PRESET_MODERN)
	GameSettingsStore.set_onboarding_completed(false)
	GameSettingsStore.set_onboarding_hints_enabled(true)

	var menu_packed := load("res://scenes/Menu.tscn")
	_assert_true(menu_packed is PackedScene, "menu scene loads for focused path summary test")
	if menu_packed is PackedScene:
		var menu_node := (menu_packed as PackedScene).instantiate()
		get_root().add_child(menu_node)
		await process_frame
		await process_frame
		var advanced_button := menu_node.get_node_or_null("AdvancedToggleButton")
		var quick_start_label := menu_node.get_node_or_null("CenterPanel/QuickStartLabel")
		var mode_step_label := menu_node.get_node_or_null("CenterPanel/ModeStepLabel")
		var guided_button := menu_node.get_node_or_null("CenterPanel/GuidedStartButton")
		var guided_hint_label := menu_node.get_node_or_null("CenterPanel/GuidedHintLabel")
		var p1_summary := menu_node.get_node_or_null("P1SummaryPanel/BodyLabel")
		var p2_summary := menu_node.get_node_or_null("P2SummaryPanel/BodyLabel")
		var route_preview_mode := menu_node.get_node_or_null("P2SummaryPanel/RoutePreviewModeLabel")
		var route_preview_footer := menu_node.get_node_or_null("P2SummaryPanel/RoutePreviewFooterLabel")
		var p2_option := menu_node.get_node_or_null("CenterPanel/P2CharacterOption")
		var control_button := menu_node.get_node_or_null("CenterPanel/ControlStyleButton")
		_assert_true(
			advanced_button is Button and quick_start_label is Label and mode_step_label is Label and guided_button is Button and guided_hint_label is Label and p1_summary is Label and p2_summary is Label and route_preview_mode is Label and route_preview_footer is Label,
			"focused path summary test resolves helper labels, guided CTA, summary cards, and route preview labels"
		)
		if quick_start_label is CanvasItem:
			_assert_true((quick_start_label as CanvasItem).visible, "focused menu path surfaces recommended first-run helper copy")
		if mode_step_label is CanvasItem:
			_assert_true((mode_step_label as CanvasItem).visible, "focused menu path surfaces explicit mode step copy")
		if guided_button is Button:
			_assert_true((guided_button as Button).text.find("Recommended") != -1, "focused menu path marks guided start as recommended before onboarding is completed")
		if guided_hint_label is Label:
			_assert_true((guided_hint_label as Label).text.find("Step 1") != -1, "focused menu path adds a fixed helper line under guided start")
		if p1_summary is Label:
			var p1_text := (p1_summary as Label).text
			_assert_true(p1_text.find("Core Loop") != -1, "p1 summary card surfaces the compact gameplan line")
			_assert_true(p1_text.find("Budget:") != -1, "p1 summary card surfaces budget state")
		if p2_summary is Label:
			_assert_true((p2_summary as Label).text.find("Replays move") != -1, "collapsed menu swaps the right summary body into a guided mode preview")
		if route_preview_mode is Label:
			_assert_true((route_preview_mode as Label).text.find("Guided") != -1, "collapsed menu defaults the right preview card to guided start")
		if route_preview_footer is Label:
			_assert_true((route_preview_footer as Label).text.find("Training") != -1, "collapsed menu preview explains where the selected route goes next")
		menu_node.call("_set_route_preview", "story")
		await process_frame
		if route_preview_mode is Label:
			_assert_true((route_preview_mode as Label).text.find("Story") != -1, "mode preview follows route hover and focus state")
		if p2_option is CanvasItem:
			_assert_true(not (p2_option as CanvasItem).visible, "focused menu path hides opponent picker until advanced setup is expanded")
		if control_button is CanvasItem:
			_assert_true(not (control_button as CanvasItem).visible, "focused menu path hides system settings until advanced setup is expanded")
		menu_node.call("_on_advanced_toggle_pressed")
		await process_frame
		if quick_start_label is CanvasItem:
			_assert_true(not (quick_start_label as CanvasItem).visible, "advanced setup hides first-run helper copy")
		if mode_step_label is CanvasItem:
			_assert_true(not (mode_step_label as CanvasItem).visible, "advanced setup hides simplified mode step copy")
		if guided_hint_label is CanvasItem:
			_assert_true(not (guided_hint_label as CanvasItem).visible, "advanced setup hides the guided replay helper line")
		if route_preview_mode is CanvasItem:
			_assert_true(not (route_preview_mode as CanvasItem).visible, "advanced setup hides the route preview headline so the rival preview can return")
		if route_preview_footer is CanvasItem:
			_assert_true(not (route_preview_footer as CanvasItem).visible, "advanced setup hides the route preview footer so the rival preview can return")
		if p2_option is CanvasItem:
			_assert_true((p2_option as CanvasItem).visible, "advanced toggle reveals opponent setup controls")
		if control_button is CanvasItem:
			_assert_true((control_button as CanvasItem).visible, "advanced toggle reveals system settings controls")
		if p2_summary is Label:
			var p2_text := (p2_summary as Label).text
			_assert_true(p2_text.find("Budget:") != -1, "advanced setup restores opponent summary details on the right card")
			_assert_true(p2_text.find("Story auto-rivals") != -1, "advanced setup keeps the story override note visible in rival preview")
		if is_instance_valid(menu_node):
			menu_node.queue_free()
		await process_frame

	GameSettingsStore.set_onboarding_completed(previous_completed)
	GameSettingsStore.set_onboarding_hints_enabled(previous_hints_enabled)
	if previous_preset != "":
		GameSettingsStore.set_control_preset(previous_preset)
	TranslationServer.set_locale(previous_locale)
	await process_frame

func _test_video_settings_profiles() -> void:
	var original_settings := GameSettingsStore.get_video_settings()
	var original_mode := GameSettingsStore.normalize_window_mode(str(original_settings.get("window_mode", GameSettingsStore.WINDOW_MODE_WINDOWED)))
	var original_resolution := GameSettingsStore.DEFAULT_RESOLUTION
	var original_resolution_value: Variant = original_settings.get("resolution", GameSettingsStore.DEFAULT_RESOLUTION)
	if original_resolution_value is Vector2i:
		original_resolution = GameSettingsStore.normalize_resolution(original_resolution_value as Vector2i)

	GameSettingsStore.set_video_settings(GameSettingsStore.WINDOW_MODE_WINDOWED, Vector2i(1600, 900))
	var updated_windowed := GameSettingsStore.get_video_settings()
	_assert_true(
		str(updated_windowed.get("window_mode", "")) == GameSettingsStore.WINDOW_MODE_WINDOWED,
		"video settings persist selected windowed mode"
	)
	var windowed_resolution_value: Variant = updated_windowed.get("resolution", Vector2i.ZERO)
	_assert_true(
		windowed_resolution_value is Vector2i and (windowed_resolution_value as Vector2i) == Vector2i(1600, 900),
		"video settings persist selected windowed resolution"
	)

	GameSettingsStore.set_video_settings(GameSettingsStore.WINDOW_MODE_FULLSCREEN, Vector2i(1920, 1080))
	var updated_fullscreen := GameSettingsStore.get_video_settings()
	_assert_true(
		str(updated_fullscreen.get("window_mode", "")) == GameSettingsStore.WINDOW_MODE_FULLSCREEN,
		"video settings persist selected fullscreen mode"
	)
	var fullscreen_resolution_value: Variant = updated_fullscreen.get("resolution", Vector2i.ZERO)
	_assert_true(
		fullscreen_resolution_value is Vector2i and (fullscreen_resolution_value as Vector2i) == Vector2i(1920, 1080),
		"video settings keep preferred resolution while fullscreen"
	)

	GameSettingsStore.set_video_settings(original_mode, original_resolution)

func _test_loadout_system_foundation() -> void:
	var character_id := "sam_altmyn"
	var pool := LoadoutCatalogStore.get_character_pool(character_id)
	var skills := pool.get("skills", []) as Array
	var items := pool.get("items", []) as Array
	var passives := pool.get("passives", []) as Array
	var presets := pool.get("presets", []) as Array
	_assert_true(not skills.is_empty(), "loadout foundation exposes skill pool entries")
	_assert_true(not items.is_empty(), "loadout foundation exposes item pool entries")
	_assert_true(not passives.is_empty(), "loadout foundation exposes passive pool entries")
	_assert_true(not presets.is_empty(), "loadout foundation exposes preset options")

	var default_loadout := LoadoutCatalogStore.get_default_loadout(character_id)
	var default_validation := LoadoutValidatorStore.validate_loadout(character_id, default_loadout)
	_assert_true(bool(default_validation.get("is_valid", false)), "default loadout passes validator gate")
	_assert_true(
		int(default_validation.get("total_cost", 0)) <= int(default_validation.get("budget_cap", 0)),
		"default loadout stays within budget cap"
	)

	var mismatched_owner_loadout := LoadoutCatalogStore.get_default_loadout("mark_zuck")
	var owner_mismatch_validation := LoadoutValidatorStore.validate_loadout(character_id, mismatched_owner_loadout)
	_assert_true(not bool(owner_mismatch_validation.get("is_valid", true)), "validator rejects owner-mismatched loadout")

	var overflow_loadout := default_loadout.duplicate(true)
	overflow_loadout["ultimate"] = "%s_ultimate_overclock" % character_id
	overflow_loadout["item"] = "%s_item_hype_loop" % character_id
	overflow_loadout["passive"] = "%s_passive_pressure_stack" % character_id
	var overflow_validation := LoadoutValidatorStore.validate_loadout(character_id, overflow_loadout)
	_assert_true(not bool(overflow_validation.get("is_valid", true)), "validator rejects budget-overflow loadout")

	var tag_overflow_loadout := default_loadout.duplicate(true)
	tag_overflow_loadout["signature_b"] = "%s_signature_b_mobility" % character_id
	tag_overflow_loadout["item"] = "%s_item_hype_loop" % character_id
	var tag_overflow_validation := LoadoutValidatorStore.validate_loadout(character_id, tag_overflow_loadout)
	_assert_true(not bool(tag_overflow_validation.get("is_valid", true)), "validator rejects tag-limit overflow loadout")

	var resolved := LoadoutResolverStore.resolve_character_loadout(character_id, mismatched_owner_loadout)
	var resolved_validation := resolved.get("validation", {}) as Dictionary
	_assert_true(bool(resolved.get("used_fallback", false)), "resolver falls back to default for invalid loadout")
	_assert_true(bool(resolved_validation.get("is_valid", false)), "resolver fallback result is validator-clean")
	var skill_by_id := pool.get("skill_by_id", {}) as Dictionary
	var signature_a_core := skill_by_id.get("%s_signature_a_core" % character_id, {}) as Dictionary
	_assert_true(
		str(signature_a_core.get("display_name_fallback", "")).find("GPT Burst") != -1,
		"loadout skills inherit character-specific signature names instead of generic slot labels"
	)
	_assert_true(
		str(signature_a_core.get("generated_role", "")) == str(GeneratedSkillProfilesStore.get_profile(character_id).get("signature_a", {}).get("role", "")),
		"loadout skills carry generated role metadata from normalized signature profiles"
	)
	var ultimate_core := skill_by_id.get("%s_ultimate_core" % character_id, {}) as Dictionary
	_assert_true(
		str(ultimate_core.get("display_name_fallback", "")).find("(Install)") != -1,
		"install-style ultimate loadout skills surface role-aware variant labels"
	)

func _test_loadout_session_flow_runtime_apply() -> void:
	var menu_packed := load("res://scenes/Menu.tscn")
	_assert_true(menu_packed is PackedScene, "menu scene loads for loadout session flow test")
	if menu_packed is not PackedScene:
		return
	var menu_node := (menu_packed as PackedScene).instantiate()
	get_root().add_child(menu_node)
	await process_frame
	await process_frame

	var p1_option := menu_node.get_node_or_null("CenterPanel/P1LoadoutOption")
	var p2_option := menu_node.get_node_or_null("CenterPanel/P2LoadoutOption")
	_assert_true(p1_option is OptionButton and p2_option is OptionButton, "menu exposes loadout preset selectors for both players")
	if p1_option is OptionButton and (p1_option as OptionButton).item_count > 1:
		(p1_option as OptionButton).select(1)
		menu_node.call("_on_p1_loadout_option_selected", 1)
	if p2_option is OptionButton and (p2_option as OptionButton).item_count > 1:
		(p2_option as OptionButton).select(1)
		menu_node.call("_on_p2_loadout_option_selected", 1)
	menu_node.call("_store_character_selection", "vs")
	var p1_loadout_value: Variant = SessionStateStore.get_value(SessionKeysStore.PLAYER_1_LOADOUT, {})
	var p2_loadout_value: Variant = SessionStateStore.get_value(SessionKeysStore.PLAYER_2_LOADOUT, {})
	_assert_true(typeof(p1_loadout_value) == TYPE_DICTIONARY and not (p1_loadout_value as Dictionary).is_empty(), "session flow stores p1 loadout payload")
	_assert_true(typeof(p2_loadout_value) == TYPE_DICTIONARY and not (p2_loadout_value as Dictionary).is_empty(), "session flow stores p2 loadout payload")
	if is_instance_valid(menu_node):
		menu_node.queue_free()
	await process_frame

	var main_packed := load("res://scenes/Main.tscn")
	_assert_true(main_packed is PackedScene, "main scene loads for runtime loadout apply test")
	if main_packed is not PackedScene:
		SessionStateStore.clear_keys(PackedStringArray([
			SessionKeysStore.MATCH_MODE,
			SessionKeysStore.PLAYER_1_LOADOUT,
			SessionKeysStore.PLAYER_2_LOADOUT
		]))
		return
	var match_node := (main_packed as PackedScene).instantiate()
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var player_1 := match_node.get_node_or_null("Player1")
	_assert_true(player_1 != null, "runtime loadout apply test resolves player1")
	if player_1 != null and player_1.has_method("get_loadout_runtime_snapshot"):
		var snapshot_value: Variant = player_1.call("get_loadout_runtime_snapshot")
		_assert_true(typeof(snapshot_value) == TYPE_DICTIONARY, "player exposes loadout runtime snapshot")
		if typeof(snapshot_value) == TYPE_DICTIONARY:
			var snapshot := snapshot_value as Dictionary
			var attack_overrides := snapshot.get("attack_overrides", {}) as Dictionary
			var item_runtime := snapshot.get("item_runtime", {}) as Dictionary
			_assert_true(not attack_overrides.is_empty(), "runtime loadout applies attack overrides to player")
			_assert_true(not item_runtime.is_empty(), "runtime loadout applies item runtime state to player")
	var selected_loadouts_value: Variant = match_node.get("selected_character_loadouts")
	_assert_true(typeof(selected_loadouts_value) == TYPE_DICTIONARY, "match exposes selected character loadouts")
	if typeof(selected_loadouts_value) == TYPE_DICTIONARY:
		var selected_loadouts := selected_loadouts_value as Dictionary
		var p1_loadout := selected_loadouts.get("p1", {}) as Dictionary
		_assert_true(not p1_loadout.is_empty(), "match stores resolved p1 loadout")
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame
	SessionStateStore.clear_keys(PackedStringArray([
		SessionKeysStore.MATCH_MODE,
		SessionKeysStore.PLAYER_1_ID,
		SessionKeysStore.PLAYER_2_ID,
		SessionKeysStore.PLAYER_1_TABLE_PATH,
		SessionKeysStore.PLAYER_2_TABLE_PATH,
		SessionKeysStore.PLAYER_1_NAME,
		SessionKeysStore.PLAYER_2_NAME,
		SessionKeysStore.PLAYER_1_LOADOUT,
		SessionKeysStore.PLAYER_2_LOADOUT,
		SessionKeysStore.STORY_ROUND_INDEX
	]))

func _test_menu_loadout_fallback_surface() -> void:
	var menu_packed := load("res://scenes/Menu.tscn")
	_assert_true(menu_packed is PackedScene, "menu scene loads for loadout fallback surface test")
	if menu_packed is not PackedScene:
		return
	var menu_node := (menu_packed as PackedScene).instantiate()
	get_root().add_child(menu_node)
	await process_frame
	await process_frame
	var p1_option := menu_node.get_node_or_null("CenterPanel/P1LoadoutOption")
	var p1_profile_label := menu_node.get_node_or_null("CenterPanel/P1ProfileLabel")
	var story_button := menu_node.get_node_or_null("CenterPanel/StoryButton")
	var p2_character_label := menu_node.get_node_or_null("CenterPanel/P2CharacterLabel")
	_assert_true(
		p1_option is OptionButton and p1_profile_label is Label and story_button is Button and p2_character_label is Label,
		"menu fallback surface test resolves key menu controls"
	)
	if story_button is Button:
		var story_text := str(menu_node.call("_resolve_menu_text", "MENU_STORY_AUTO_RIVAL_BUTTON", "Story (Auto Rival)"))
		_assert_true((story_button as Button).text == story_text, "story button surfaces automatic rival guidance in visible text")
	if p2_character_label is Label:
		var opponent_label_text := str(menu_node.call("_resolve_menu_text", "MENU_P2_CHARACTER_VS_ONLY", "Opponent (VS/Training)"))
		_assert_true((p2_character_label as Label).text == opponent_label_text, "menu surfaces opponent scope guidance without tooltip dependency")
	if p1_option is OptionButton and p1_profile_label is Label:
		var invalid_loadout := LoadoutCatalogStore.get_default_loadout("mark_zuck")
		menu_node.set("current_p1_loadout", invalid_loadout.duplicate(true))
		menu_node.call("_refresh_loadout_tooltip_for_player", "p1")
		menu_node.call("_refresh_character_profile_preview")
		var fallback_hint := str(menu_node.call(
			"_resolve_menu_text",
			"MENU_LOADOUT_FALLBACK_HINT",
			"Invalid loadout detected. Default preset applied."
		))
		var fallback_inline := str(menu_node.call("_resolve_menu_text", "MENU_LOADOUT_FALLBACK_INLINE", "Default Applied"))
		var cost_label := str(menu_node.call("_resolve_menu_text", "MENU_LOADOUT_INLINE_COST_LABEL", "Loadout"))
		_assert_true(
			(p1_option as OptionButton).tooltip_text.find(fallback_hint) != -1,
			"menu tooltip surfaces fallback warning when selected loadout is invalid"
		)
		_assert_true(
			(p1_profile_label as Label).text.find(cost_label) != -1,
			"menu profile row surfaces a clear loadout cost label"
		)
		_assert_true(
			(p1_profile_label as Label).text.find(fallback_inline) != -1,
			"menu profile row marks fallback-applied loadout with readable inline wording"
		)
	if is_instance_valid(menu_node):
		menu_node.queue_free()
	await process_frame

func _test_loadout_item_trigger_and_cooldown_runtime() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or host == null:
		return
	var character_id := "sam_altmyn"
	var loadout := LoadoutCatalogStore.get_default_loadout(character_id)
	var resolved := LoadoutResolverStore.resolve_character_loadout(character_id, loadout)
	p1.call("apply_loadout_runtime", resolved)
	await process_frame
	var before_snapshot_value: Variant = p1.call("get_loadout_runtime_snapshot")
	_assert_true(typeof(before_snapshot_value) == TYPE_DICTIONARY, "loadout item trigger test can read runtime snapshot before events")
	if typeof(before_snapshot_value) != TYPE_DICTIONARY:
		host.queue_free()
		await process_frame
		return
	var before_snapshot := (before_snapshot_value as Dictionary).duplicate(true)
	var before_item := before_snapshot.get("item_runtime", {}) as Dictionary
	_assert_true(not before_item.is_empty(), "loadout item trigger test has runtime item payload")
	if before_item.is_empty():
		host.queue_free()
		await process_frame
		return
	var trigger_steps := int(ceil(float(before_item.get("trigger_value", 1.0))))
	for _index in range(maxi(1, trigger_steps)):
		p1.call("_notify_loadout_item_event", "hit_landed")
	var status_snapshot_value: Variant = p1.call("get_runtime_status_snapshot")
	_assert_true(typeof(status_snapshot_value) == TYPE_DICTIONARY, "loadout item trigger test can read HUD-facing status snapshot")
	if typeof(status_snapshot_value) == TYPE_DICTIONARY:
		var status_snapshot := status_snapshot_value as Dictionary
		_assert_true(str(status_snapshot.get("loadout_item_name", "")).strip_edges() != "", "HUD-facing status snapshot exposes item name")
		_assert_true(
			float(status_snapshot.get("loadout_item_trigger_value", 0.0)) >= 1.0,
			"HUD-facing status snapshot exposes item trigger threshold"
		)
	var after_snapshot_value: Variant = p1.call("get_loadout_runtime_snapshot")
	_assert_true(typeof(after_snapshot_value) == TYPE_DICTIONARY, "loadout item trigger test can read runtime snapshot after activation")
	if typeof(after_snapshot_value) == TYPE_DICTIONARY:
		var after_snapshot := (after_snapshot_value as Dictionary).duplicate(true)
		var after_item := after_snapshot.get("item_runtime", {}) as Dictionary
		_assert_true(
			int(after_item.get("activation_count", 0)) == int(before_item.get("activation_count", 0)) + 1,
			"loadout item trigger threshold increments activation counter"
		)
		_assert_true(float(after_item.get("cooldown_remaining", 0.0)) > 0.0, "loadout item activation starts cooldown timer")
		_assert_true(
			int(after_item.get("charges_remaining", 0)) == int(before_item.get("charges_remaining", 0)) - 1,
			"loadout item activation consumes one charge"
		)
		var locked_activation_count := int(after_item.get("activation_count", 0))
		for _index in range(maxi(2, trigger_steps * 2)):
			p1.call("_notify_loadout_item_event", "hit_landed")
		var cooldown_snapshot_value: Variant = p1.call("get_loadout_runtime_snapshot")
		if typeof(cooldown_snapshot_value) == TYPE_DICTIONARY:
			var cooldown_snapshot := cooldown_snapshot_value as Dictionary
			var cooldown_item := cooldown_snapshot.get("item_runtime", {}) as Dictionary
			_assert_true(
				int(cooldown_item.get("activation_count", 0)) == locked_activation_count,
				"loadout item does not re-activate while cooldown is active"
			)
	host.queue_free()
	await process_frame

func _test_loadout_item_evolution_boundaries() -> void:
	var character_id := "sam_altmyn"
	var item_id := "%s_item_brand_core" % character_id
	var runtime := LoadoutResolverStore.build_item_runtime_from_definition(character_id, item_id)
	_assert_true(not runtime.is_empty(), "loadout evolution boundary test resolves item runtime definition")
	if runtime.is_empty():
		return
	var evolution_id := str(runtime.get("evolution_id", "")).strip_edges()
	_assert_true(evolution_id != "", "loadout evolution boundary test has evolution target")
	if evolution_id == "":
		return
	var required_activations := maxi(1, int(runtime.get("evolution_after_activations", 2)))
	var before_threshold := runtime.duplicate(true)
	before_threshold["activation_count"] = required_activations - 1
	var before_result := EvolutionEngineStore.maybe_evolve_item(character_id, before_threshold)
	_assert_true(
		not bool(before_result.get("evolved", true)),
		"evolution does not trigger before required activation count"
	)
	var on_threshold := runtime.duplicate(true)
	on_threshold["activation_count"] = required_activations
	var threshold_result := EvolutionEngineStore.maybe_evolve_item(character_id, on_threshold)
	_assert_true(bool(threshold_result.get("evolved", false)), "evolution triggers once activation threshold is reached")
	var evolved_runtime_value: Variant = threshold_result.get("item_runtime", {})
	_assert_true(typeof(evolved_runtime_value) == TYPE_DICTIONARY, "evolution boundary test returns evolved runtime payload")
	if typeof(evolved_runtime_value) == TYPE_DICTIONARY:
		var evolved_runtime := evolved_runtime_value as Dictionary
		_assert_true(str(evolved_runtime.get("id", "")) == evolution_id, "evolution resolves expected target item id")

func _test_loadout_wave1_tuning_profiles_present() -> void:
	var tuning_profiles := LoadoutCatalogStore.get_wave1_character_tuning_profiles()
	var wave1_ids := ["elon_mvsk", "mark_zuck", "sam_altmyn", "peter_thyell"]
	for character_id in wave1_ids:
		_assert_true(
			tuning_profiles.has(character_id),
			"wave1 tuning profile exists for %s" % character_id
		)
		var runtime_profile := GeneratedSkillProfilesStore.get_profile(character_id)
		_assert_true(not runtime_profile.is_empty(), "generated skill profile exists for %s" % character_id)
	var elon_pool := LoadoutCatalogStore.get_character_pool("elon_mvsk")
	var elon_items := elon_pool.get("item_by_id", {}) as Dictionary
	var elon_hype := elon_items.get("elon_mvsk_item_hype_loop", {}) as Dictionary
	_assert_true(
		is_equal_approx(float(elon_hype.get("trigger_value", 2.0)), 1.0),
		"wave1 tuning applies Elon hype trigger reduction"
	)
	var sam_pool := LoadoutCatalogStore.get_character_pool("sam_altmyn")
	var sam_items := sam_pool.get("item_by_id", {}) as Dictionary
	var sam_core := sam_items.get("sam_altmyn_item_brand_core", {}) as Dictionary
	_assert_true(
		is_equal_approx(float(sam_core.get("cooldown_seconds", 6.0)), 5.5),
		"wave1 tuning applies Sam core cooldown adjustment"
	)

func _test_generated_signature_profiles_are_normalized() -> void:
	for character_id_variant in GeneratedSkillProfilesStore.PROFILE_BY_CHARACTER.keys():
		var character_id := str(character_id_variant)
		var profile := GeneratedSkillProfilesStore.get_profile(character_id)
		_assert_true(not profile.is_empty(), "normalized generated profile loads for %s" % character_id)
		var generated_archetype := str(profile.get("generated_archetype", ""))
		_assert_true(generated_archetype != "", "normalized generated profile exposes archetype for %s" % character_id)
		_assert_true(
			generated_archetype == PlayerDataStore.resolve_character_archetype(character_id),
			"normalized generated profile archetype matches shared resolver for %s" % character_id
		)
		var slot_contracts_value: Variant = profile.get("slot_contracts", {})
		_assert_true(typeof(slot_contracts_value) == TYPE_DICTIONARY, "normalized generated profile exposes slot contracts for %s" % character_id)
		var slot_contracts := {}
		if typeof(slot_contracts_value) == TYPE_DICTIONARY:
			slot_contracts = slot_contracts_value as Dictionary
		for slot_key in ["signature_a", "signature_b", "signature_c", "ultimate"]:
			var entry_value: Variant = profile.get(slot_key, {})
			_assert_true(typeof(entry_value) == TYPE_DICTIONARY, "%s profile keeps %s entry as dictionary" % [character_id, slot_key])
			if typeof(entry_value) != TYPE_DICTIONARY:
				continue
			var entry := entry_value as Dictionary
			var contract := GeneratedSkillProfilesStore.get_slot_contract(profile, slot_key)
			_assert_true(str(entry.get("slot_key", "")) == slot_key, "%s profile annotates slot key for %s" % [character_id, slot_key])
			_assert_true(str(entry.get("generated_archetype", "")) == generated_archetype, "%s profile entry inherits archetype for %s" % [character_id, slot_key])
			_assert_true(str(entry.get("role", "")) != "", "%s profile entry exposes role for %s" % [character_id, slot_key])
			_assert_true(str(entry.get("skeleton", "")) != "", "%s profile entry exposes skeleton for %s" % [character_id, slot_key])
			_assert_true(not slot_contracts.is_empty() and slot_contracts.has(slot_key), "%s slot contract map includes %s" % [character_id, slot_key])
			_assert_true(str(contract.get("role", "")) == str(entry.get("role", "")), "%s slot contract role matches entry for %s" % [character_id, slot_key])
			_assert_true(str(contract.get("skeleton", "")) == str(entry.get("skeleton", "")), "%s slot contract skeleton matches entry for %s" % [character_id, slot_key])

func _test_generated_signature_builder_uses_role_skeletons() -> void:
	var special_base_value: Variant = PlayerDataStore.ATTACK_DATA.get("special", {})
	_assert_true(typeof(special_base_value) == TYPE_DICTIONARY, "builder regression test resolves special base data")
	if typeof(special_base_value) != TYPE_DICTIONARY:
		return
	var special_base := (special_base_value as Dictionary).duplicate(true)
	var distorted_special := special_base.duplicate(true)
	distorted_special["block_type"] = "throw"
	distorted_special["damage"] = 99
	distorted_special["lunge_speed"] = 0.0
	distorted_special["hitbox_size_ground"] = Vector2(80, 80)
	distorted_special["hitbox_offset_ground"] = Vector2(-30, -30)
	for character_id_variant in GeneratedSkillProfilesStore.PROFILE_BY_CHARACTER.keys():
		var character_id := str(character_id_variant)
		var profile := GeneratedSkillProfilesStore.get_profile(character_id)
		var unique_skeletons := {}
		var unique_roles := {}
		var unique_fingerprints := {}
		for slot_key in ["signature_a", "signature_b", "signature_c", "ultimate"]:
			var config_value: Variant = profile.get(slot_key, {})
			_assert_true(typeof(config_value) == TYPE_DICTIONARY, "%s builder test resolves %s config" % [character_id, slot_key])
			if typeof(config_value) != TYPE_DICTIONARY:
				continue
			var config := config_value as Dictionary
			var generated := PlayerSignatureAttackBuilderStore.build_generated_signature_attack(slot_key, config, 0.18, 0.14)
			var legacy_alias := PlayerSignatureAttackBuilderStore.build_generated_signature_attack_from_special(
				slot_key,
				distorted_special,
				config,
				0.18,
				0.14
			)
			_assert_true(not generated.is_empty(), "%s builder returns runtime attack for %s" % [character_id, slot_key])
			_assert_true(str(generated.get("generated_role", "")) == str(config.get("role", "")), "%s builder stamps generated role for %s" % [character_id, slot_key])
			_assert_true(str(generated.get("generated_skeleton", "")) == str(config.get("skeleton", "")), "%s builder stamps generated skeleton for %s" % [character_id, slot_key])
			_assert_true(str(legacy_alias.get("block_type", "")) == str(generated.get("block_type", "")), "%s generated %s no longer depends on special block type" % [character_id, slot_key])
			_assert_true(int(legacy_alias.get("damage", 0)) == int(generated.get("damage", 0)), "%s generated %s no longer depends on special damage" % [character_id, slot_key])
			_assert_true(legacy_alias.get("hitbox_size_ground", Vector2.ZERO) == generated.get("hitbox_size_ground", Vector2.ZERO), "%s generated %s no longer depends on special hitbox size" % [character_id, slot_key])
			var differs_from_special: bool = (
				str(generated.get("block_type", "")) != str(special_base.get("block_type", ""))
				or generated.get("hitbox_size_ground", Vector2.ZERO) != special_base.get("hitbox_size_ground", Vector2.ZERO)
				or generated.get("hitbox_offset_ground", Vector2.ZERO) != special_base.get("hitbox_offset_ground", Vector2.ZERO)
				or not is_equal_approx(float(generated.get("lunge_speed", 0.0)), float(special_base.get("lunge_speed", 0.0)))
			)
			_assert_true(differs_from_special, "%s generated %s differs from the base special profile" % [character_id, slot_key])
			unique_roles[str(generated.get("generated_role", ""))] = true
			unique_skeletons[str(generated.get("generated_skeleton", ""))] = true
			unique_fingerprints[_signature_attack_fingerprint(generated)] = true
		_assert_true(unique_roles.size() >= 3, "%s generated kit exposes at least three distinct roles" % character_id)
		_assert_true(unique_skeletons.size() >= 3, "%s generated kit exposes at least three distinct skeletons" % character_id)
		_assert_true(unique_fingerprints.size() >= 3, "%s generated kit exposes at least three distinct gameplay fingerprints" % character_id)

func _signature_attack_fingerprint(entry: Dictionary) -> String:
	return "%s|%s|%.2f|%s|%s|%s|%s" % [
		str(entry.get("block_type", "")),
		str(entry.get("generated_skeleton", "")),
		float(entry.get("lunge_speed", 0.0)),
		str(entry.get("hitbox_size_ground", Vector2.ZERO)),
		str(entry.get("hitbox_offset_ground", Vector2.ZERO)),
		str(entry.get("knockback_ground", Vector2.ZERO)),
		str(entry.get("cancel_options", []))
	]

func _test_match_metrics_telemetry_schema() -> void:
	var metrics_path := ProjectSettings.globalize_path("user://match_metrics.jsonl")
	if FileAccess.file_exists(metrics_path):
		DirAccess.remove_absolute(metrics_path)
	var packed := load("res://scenes/Main.tscn")
	_assert_true(packed is PackedScene, "main scene loads for telemetry schema test")
	if packed is not PackedScene:
		return
	var match_node := (packed as PackedScene).instantiate()
	match_node.set("round_tuning_enabled", false)
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	match_node.call("_end_match", "p1_win")
	await process_frame
	_assert_true(FileAccess.file_exists(metrics_path), "telemetry schema test writes match metrics jsonl file")
	if FileAccess.file_exists(metrics_path):
		var text := FileAccess.get_file_as_string(metrics_path)
		var lines := text.split("\n", false)
		_assert_true(not lines.is_empty(), "telemetry schema test writes at least one metrics line")
		if not lines.is_empty():
			var parsed: Variant = JSON.parse_string(lines[lines.size() - 1])
			_assert_true(typeof(parsed) == TYPE_DICTIONARY, "telemetry schema test parses latest jsonl line")
			if typeof(parsed) == TYPE_DICTIONARY:
				var record := parsed as Dictionary
				_assert_true(int(record.get("schema_version", 0)) >= 2, "telemetry record exposes schema version >= 2")
				_assert_true(record.has("p1_loadout_signature"), "telemetry record exposes p1 loadout signature")
				_assert_true(record.has("p2_loadout_signature"), "telemetry record exposes p2 loadout signature")
				_assert_true(record.has("loadout_picks"), "telemetry record exposes loadout pick payload")
				_assert_true(record.has("round_tuning_picks"), "telemetry record exposes round tuning pick events")
				_assert_true(record.has("item_activation_events"), "telemetry record exposes item activation events")
				_assert_true(record.has("item_evolution_events"), "telemetry record exposes item evolution events")
				_assert_true(record.has("item_evolution_success_rate"), "telemetry record exposes evolution success rate")
				_assert_true(record.has("item_evolution_avg_trigger_time_seconds"), "telemetry record exposes evolution trigger timing")
				_assert_true(record.has("onboarding"), "telemetry record exposes onboarding flow summary")
				var onboarding_value: Variant = record.get("onboarding", {})
				_assert_true(typeof(onboarding_value) == TYPE_DICTIONARY, "telemetry onboarding summary is dictionary")
				if typeof(onboarding_value) == TYPE_DICTIONARY:
					var onboarding := onboarding_value as Dictionary
					_assert_true(onboarding.has("started"), "telemetry onboarding summary includes started flag")
					_assert_true(onboarding.has("completed"), "telemetry onboarding summary includes completed flag")
					_assert_true(onboarding.has("steps_completed"), "telemetry onboarding summary includes completed step list")
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_round_tuning_intermission_flow() -> void:
	var packed := load("res://scenes/Main.tscn")
	_assert_true(packed is PackedScene, "main scene loads for round tuning intermission test")
	if packed is not PackedScene:
		return
	var match_node := (packed as PackedScene).instantiate()
	match_node.set("win_rule", "stock")
	match_node.set("ruleset_profile", "platform")
	match_node.set("round_tuning_enabled", true)
	match_node.set("round_tuning_force_ui_in_headless", true)
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var player_1 := match_node.get_node_or_null("Player1")
	var panel := match_node.get_node_or_null("Hud/RoundTuningPanel")
	var option_a_button := match_node.get_node_or_null("Hud/RoundTuningPanel/OptionAButton")
	_assert_true(player_1 != null, "round tuning test resolves player1")
	_assert_true(panel is Panel and option_a_button is Button, "round tuning test resolves hud intermission controls")
	if player_1 == null or panel is not Panel or option_a_button is not Button:
		if is_instance_valid(match_node):
			match_node.queue_free()
		await process_frame
		return
	var before_snapshot_value: Variant = player_1.call("get_loadout_runtime_snapshot")
	_assert_true(typeof(before_snapshot_value) == TYPE_DICTIONARY, "round tuning test can read pre-intermission runtime snapshot")
	var before_snapshot := {}
	if typeof(before_snapshot_value) == TYPE_DICTIONARY:
		before_snapshot = (before_snapshot_value as Dictionary).duplicate(true)
	var before_item_runtime := before_snapshot.get("item_runtime", {}) as Dictionary
	var option_values: Variant = player_1.call("get_round_tuning_options")
	_assert_true(typeof(option_values) == TYPE_ARRAY, "round tuning test can read player tuning options")
	if typeof(option_values) != TYPE_ARRAY:
		if is_instance_valid(match_node):
			match_node.queue_free()
		await process_frame
		return
	var options := option_values as Array
	_assert_true(options.size() >= 1, "round tuning test has at least one available option")
	if options.is_empty() or typeof(options[0]) != TYPE_DICTIONARY:
		if is_instance_valid(match_node):
			match_node.queue_free()
		await process_frame
		return
	var first_option := (options[0] as Dictionary).duplicate(true)
	var first_option_id := str(first_option.get("id", "")).strip_edges()
	_assert_true(first_option_id != "", "round tuning option has stable id")
	match_node.call("_lose_stock", "p1")
	await process_frame
	_assert_true((panel as Panel).visible, "round tuning panel opens after non-final stock loss")
	_assert_true(bool(match_node.get("round_tuning_active")), "round tuning state enters active intermission")
	_assert_true(get_root().get_tree().paused, "round tuning intermission pauses active match loop")
	(option_a_button as Button).emit_signal("pressed")
	await process_frame
	await process_frame
	_assert_true(not (panel as Panel).visible, "round tuning panel closes after selecting an option")
	_assert_true(not bool(match_node.get("round_tuning_active")), "round tuning state exits after option selection")
	_assert_true(not get_root().get_tree().paused, "round tuning selection restores match pause state")
	var after_snapshot_value: Variant = player_1.call("get_loadout_runtime_snapshot")
	_assert_true(typeof(after_snapshot_value) == TYPE_DICTIONARY, "round tuning test can read post-selection runtime snapshot")
	var after_item_runtime := {}
	if typeof(after_snapshot_value) == TYPE_DICTIONARY:
		var after_snapshot := (after_snapshot_value as Dictionary).duplicate(true)
		after_item_runtime = (after_snapshot.get("item_runtime", {}) as Dictionary).duplicate(true)
		_assert_true(
			_is_round_tuning_patch_applied(before_item_runtime, after_item_runtime, first_option),
			"round tuning selection applies item runtime patch for subsequent stocks"
		)
	if not after_item_runtime.is_empty():
		match_node.set("round_tuning_enabled", false)
		match_node.call("_lose_stock", "p1")
		await process_frame
		var persisted_snapshot_value: Variant = player_1.call("get_loadout_runtime_snapshot")
		_assert_true(typeof(persisted_snapshot_value) == TYPE_DICTIONARY, "round tuning test can read runtime snapshot after next stock loss")
		if typeof(persisted_snapshot_value) == TYPE_DICTIONARY:
			var persisted_snapshot := persisted_snapshot_value as Dictionary
			var persisted_item_runtime := persisted_snapshot.get("item_runtime", {}) as Dictionary
			_assert_true(
				_is_round_tuning_patch_applied(before_item_runtime, persisted_item_runtime, first_option),
				"round tuning patch persists for subsequent in-match stocks"
			)
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_round_tuning_simultaneous_stock_fairness() -> void:
	var packed := load("res://scenes/Main.tscn")
	_assert_true(packed is PackedScene, "main scene loads for round tuning fairness test")
	if packed is not PackedScene:
		return
	var match_node := (packed as PackedScene).instantiate()
	match_node.set("win_rule", "stock")
	match_node.set("ruleset_profile", "platform")
	match_node.set("round_tuning_enabled", true)
	match_node.set("round_tuning_force_ui_in_headless", true)
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var panel := match_node.get_node_or_null("Hud/RoundTuningPanel")
	var option_a_button := match_node.get_node_or_null("Hud/RoundTuningPanel/OptionAButton")
	_assert_true(panel is Panel and option_a_button is Button, "round tuning fairness test resolves hud controls")
	if panel is not Panel or option_a_button is not Button:
		if is_instance_valid(match_node):
			match_node.queue_free()
		await process_frame
		return
	match_node.call("_lose_stocks_simultaneously")
	await process_frame
	_assert_true(bool(match_node.get("round_tuning_active")), "simultaneous stock loss opens a shared round tuning intermission")
	(option_a_button as Button).emit_signal("pressed")
	await process_frame
	await process_frame
	_assert_true(not bool(match_node.get("round_tuning_active")), "shared round tuning intermission completes in one pick")
	var pick_counts_value: Variant = match_node.get("round_tuning_pick_counts")
	_assert_true(typeof(pick_counts_value) == TYPE_DICTIONARY, "round tuning fairness test reads pick count map")
	if typeof(pick_counts_value) == TYPE_DICTIONARY:
		var pick_counts := pick_counts_value as Dictionary
		var p1_picks := int(pick_counts.get("p1", 0))
		var p2_picks := int(pick_counts.get("p2", 0))
		_assert_true(
			(p1_picks == 1 and p2_picks == 0) or (p1_picks == 0 and p2_picks == 1),
			"simultaneous stock loss grants exactly one shared round tuning pick"
		)
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_round_tuning_pick_cap_per_player() -> void:
	var packed := load("res://scenes/Main.tscn")
	_assert_true(packed is PackedScene, "main scene loads for round tuning pick cap test")
	if packed is not PackedScene:
		return
	var match_node := (packed as PackedScene).instantiate()
	match_node.set("win_rule", "stock")
	match_node.set("ruleset_profile", "platform")
	match_node.set("round_tuning_enabled", true)
	match_node.set("round_tuning_force_ui_in_headless", true)
	match_node.set("round_tuning_max_picks_per_player", 2)
	match_node.set("stock_count", 4)
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var option_a_button := match_node.get_node_or_null("Hud/RoundTuningPanel/OptionAButton")
	_assert_true(option_a_button is Button, "round tuning pick cap test resolves hud controls")
	if option_a_button is not Button:
		if is_instance_valid(match_node):
			match_node.queue_free()
		await process_frame
		return
	for pick_index in range(2):
		match_node.call("_lose_stock", "p1")
		await process_frame
		_assert_true(bool(match_node.get("round_tuning_active")), "round tuning opens while pick cap has remaining slots (%d)" % [pick_index + 1])
		(option_a_button as Button).emit_signal("pressed")
		await process_frame
		await process_frame
	match_node.call("_lose_stock", "p1")
	await process_frame
	_assert_true(not bool(match_node.get("round_tuning_active")), "round tuning blocks additional picks after player reaches cap")
	var pick_counts_value: Variant = match_node.get("round_tuning_pick_counts")
	_assert_true(typeof(pick_counts_value) == TYPE_DICTIONARY, "round tuning pick cap test reads pick counts")
	if typeof(pick_counts_value) == TYPE_DICTIONARY:
		var pick_counts := pick_counts_value as Dictionary
		_assert_true(int(pick_counts.get("p1", 0)) == 2, "p1 pick count reaches configured per-player cap")
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_round_tuning_leader_lock_gap() -> void:
	var packed := load("res://scenes/Main.tscn")
	_assert_true(packed is PackedScene, "main scene loads for round tuning leader lock test")
	if packed is not PackedScene:
		return
	var match_node := (packed as PackedScene).instantiate()
	match_node.set("win_rule", "stock")
	match_node.set("ruleset_profile", "platform")
	match_node.set("round_tuning_enabled", true)
	match_node.set("round_tuning_leader_lock_stock_gap", 1)
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	match_node.set("stocks", {"p1": 3, "p2": 1})
	var p1_can_pick := bool(match_node.call("_can_player_receive_round_tuning_pick", "p1"))
	var p2_can_pick := bool(match_node.call("_can_player_receive_round_tuning_pick", "p2"))
	_assert_true(not p1_can_pick, "round tuning leader lock blocks extra pick for far-ahead player")
	_assert_true(p2_can_pick, "round tuning leader lock still allows trailing player to pick")
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_round_tuning_max_charges_patch_grants_charges() -> void:
	var runtime := {
		"max_charges": 1,
		"charges_remaining": 1,
		"round_tuning_options": [
			{
				"id": "charge_plus",
				"patch": {"max_charges_delta": 1}
			}
		]
	}
	var upgraded := RoundTuningEngineStore.apply_round_tuning_option(runtime, "charge_plus")
	_assert_true(int(upgraded.get("max_charges", 0)) == 2, "max_charges tuning increases runtime max charges")
	_assert_true(int(upgraded.get("charges_remaining", 0)) == 2, "max_charges tuning grants an extra usable charge")
	var depleted_runtime := runtime.duplicate(true)
	depleted_runtime["charges_remaining"] = 0
	var upgraded_from_zero := RoundTuningEngineStore.apply_round_tuning_option(depleted_runtime, "charge_plus")
	_assert_true(int(upgraded_from_zero.get("charges_remaining", 0)) == 1, "max_charges tuning restores one charge even when depleted")

func _is_round_tuning_patch_applied(before_item: Dictionary, after_item: Dictionary, option: Dictionary) -> bool:
	var patch_value: Variant = option.get("patch", {})
	if typeof(patch_value) != TYPE_DICTIONARY:
		return false
	var patch := patch_value as Dictionary
	var has_patch_clause := false
	var applied := true
	if patch.has("cooldown_seconds_delta"):
		has_patch_clause = true
		var expected_cooldown := maxf(
			0.0,
			float(before_item.get("cooldown_seconds", 0.0)) + float(patch.get("cooldown_seconds_delta", 0.0))
		)
		applied = applied and is_equal_approx(float(after_item.get("cooldown_seconds", 0.0)), expected_cooldown)
	if patch.has("trigger_value_delta"):
		has_patch_clause = true
		var expected_trigger := maxf(
			1.0,
			float(before_item.get("trigger_value", 1.0)) + float(patch.get("trigger_value_delta", 0.0))
		)
		applied = applied and is_equal_approx(float(after_item.get("trigger_value", 1.0)), expected_trigger)
	if patch.has("max_charges_delta"):
		has_patch_clause = true
		var before_max_charges := maxi(1, int(before_item.get("max_charges", 1)))
		var before_remaining := clampi(int(before_item.get("charges_remaining", before_max_charges)), 0, before_max_charges)
		var delta_charges := int(patch.get("max_charges_delta", 0))
		var expected_max_charges := maxi(
			1,
			before_max_charges + delta_charges
		)
		var expected_remaining := mini(before_remaining, expected_max_charges)
		if delta_charges > 0:
			expected_remaining = mini(expected_max_charges, before_remaining + delta_charges)
		applied = applied and int(after_item.get("max_charges", 1)) == expected_max_charges
		applied = applied and int(after_item.get("charges_remaining", 0)) == expected_remaining
	if patch.has("effect_payload_patch"):
		var payload_patch_value: Variant = patch.get("effect_payload_patch", {})
		if typeof(payload_patch_value) == TYPE_DICTIONARY:
			has_patch_clause = true
			var payload_patch := payload_patch_value as Dictionary
			var before_payload := before_item.get("effect_payload", {}) as Dictionary
			var after_payload := after_item.get("effect_payload", {}) as Dictionary
			for key in payload_patch.keys():
				var before_value: Variant = before_payload.get(key, 0.0)
				var delta_value: Variant = payload_patch[key]
				if before_value is int or before_value is float:
					var expected_value := float(before_value) + float(delta_value)
					applied = applied and is_equal_approx(float(after_payload.get(key, 0.0)), expected_value)
				else:
					applied = applied and after_payload.get(key, null) == delta_value
	return has_patch_clause and applied

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

func _replace_action_keyboard_keys(action_name: String, keycodes: Array) -> void:
	if not InputMap.has_action(action_name):
		return
	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey:
			InputMap.action_erase_event(action_name, event)
	for keycode_value in keycodes:
		var keycode := int(keycode_value)
		var key_event := InputEventKey.new()
		key_event.keycode = keycode
		key_event.physical_keycode = keycode
		InputMap.action_add_event(action_name, key_event)

func _test_hitstop_overlap_recovery() -> void:
	var packed := load("res://scenes/Main.tscn")
	_assert_true(packed is PackedScene, "main scene loads for hitstop overlap test")
	if packed is not PackedScene:
		return
	var match_node := (packed as PackedScene).instantiate()
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var p1 := match_node.get_node_or_null("Player1")
	var p2 := match_node.get_node_or_null("Player2")
	_assert_true(p1 != null and p2 != null, "hitstop overlap test resolves both fighters")
	match_node.call("_apply_hitstop", 0.03)
	match_node.call("_apply_hitstop", 0.09)
	if p1 != null and p2 != null:
		_assert_true(bool(p1.get("hitstop_active")) and bool(p2.get("hitstop_active")), "overlapping hitstop requests freeze both fighters")
	await create_timer(0.14, true, false, true).timeout
	await process_frame
	if p1 != null and p2 != null:
		_assert_true(not bool(p1.get("hitstop_active")) and not bool(p2.get("hitstop_active")), "overlapping hitstop requests recover fighter motion state")
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_camera_zoom_response() -> void:
	var packed := load("res://scenes/Main.tscn")
	_assert_true(packed is PackedScene, "main scene loads for camera zoom response test")
	if packed is not PackedScene:
		return
	var match_node := (packed as PackedScene).instantiate()
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var p1 := match_node.get_node_or_null("Player1")
	var p2 := match_node.get_node_or_null("Player2")
	var camera_value: Variant = match_node.get("camera")
	_assert_true(p1 != null and p2 != null and camera_value is Camera2D, "camera zoom test resolves fighters and camera")
	if p1 != null and p2 != null and camera_value is Camera2D:
		var camera_node := camera_value as Camera2D
		p1.position = Vector2(320, p1.position.y)
		p2.position = Vector2(420, p2.position.y)
		match_node.call("_update_camera", 1.0)
		var near_zoom := float(camera_node.zoom.x)
		p1.position = Vector2(80, p1.position.y)
		p2.position = Vector2(820, p2.position.y)
		match_node.call("_update_camera", 1.0)
		var far_zoom := float(camera_node.zoom.x)
		_assert_true(far_zoom < near_zoom - 0.05, "camera widens framing when fighters are far apart")
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_camera_vertical_framing_response() -> void:
	var packed := load("res://scenes/Main.tscn")
	_assert_true(packed is PackedScene, "main scene loads for camera vertical framing test")
	if packed is not PackedScene:
		return
	var match_node := (packed as PackedScene).instantiate()
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var p1 := match_node.get_node_or_null("Player1")
	var p2 := match_node.get_node_or_null("Player2")
	var camera_value: Variant = match_node.get("camera")
	_assert_true(p1 != null and p2 != null and camera_value is Camera2D, "camera vertical framing test resolves fighters and camera")
	if p1 != null and p2 != null and camera_value is Camera2D:
		var camera_node := camera_value as Camera2D
		p1.position = Vector2(330.0, 320.0)
		p2.position = Vector2(430.0, 320.0)
		match_node.call("_update_camera", 1.0)
		var base_y := float(camera_node.position.y)
		var base_zoom := float(camera_node.zoom.x)
		p1.position = Vector2(340.0, 20.0)
		p2.position = Vector2(420.0, 40.0)
		match_node.call("_update_camera", 1.0)
		var lifted_y := float(camera_node.position.y)
		_assert_true(lifted_y < base_y - 35.0, "camera shifts upward when both fighters are launched high")
		p1.position = Vector2(380.0, 40.0)
		p2.position = Vector2(390.0, 520.0)
		match_node.call("_update_camera", 1.0)
		var vertical_spread_zoom := float(camera_node.zoom.x)
		_assert_true(vertical_spread_zoom < base_zoom - 0.03, "camera widens framing for large vertical fighter separation")
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_training_toggle_keeps_dummy_non_ai() -> void:
	var packed := load("res://scenes/Training.tscn")
	_assert_true(packed is PackedScene, "training scene loads for dummy ai toggle test")
	if packed is not PackedScene:
		return
	var training_node := (packed as PackedScene).instantiate()
	get_root().add_child(training_node)
	await process_frame
	await process_frame
	var p1 := training_node.get_node_or_null("Player1")
	var p2 := training_node.get_node_or_null("Player2")
	var hud := training_node.get_node_or_null("Hud")
	_assert_true(p1 != null, "training dummy ai toggle test resolves player1")
	_assert_true(p2 != null, "training dummy ai toggle test resolves player2")
	_assert_true(hud != null, "training dummy ai toggle test resolves hud")
	if p1 != null and p2 != null:
		_assert_true(not bool(p2.get("is_ai")), "training scene keeps dummy non-ai by default")
		var initial_drill_state := training_node.get("training_drill_state") as Dictionary
		_assert_true(str(initial_drill_state.get("drill_id", "")) == "duel_core", "training scene defaults to duel-core drill contract")
		training_node.call("_on_hud_training_options_changed", {
			"enabled": true,
			"dummy_mode": "stand",
			"show_detail": false,
			"ruleset_profile": "platform",
			"drill_id": "recovery_route",
			"throw_tech_assist_mode": "button_assist"
		})
		await process_frame
		_assert_true(not bool(p2.get("is_ai")), "switching training ruleset does not re-enable dummy ai")
		_assert_true(str(training_node.get("ruleset_profile")) == "platform", "training ruleset toggle updates match ruleset")
		var recovery_drill_state := training_node.get("training_drill_state") as Dictionary
		_assert_true(str(recovery_drill_state.get("drill_id", "")) == "recovery_route", "training scene routes platform lab through an explicit recovery drill id")
		_assert_true(str(recovery_drill_state.get("rep_status", "")) == "active", "training drill state marks the current rep as active")
		_assert_true(str(p2.get("training_throw_tech_assist_mode")) == "button_assist", "training scene routes throw-tech assist mode to the dummy player")
		if hud != null:
			var mode_button := hud.get_node_or_null("TrainingPanel/TrainingModeButton") as Button
			var tech_button := hud.get_node_or_null("TrainingPanel/TrainingTechButton") as Button
			_assert_true(mode_button != null, "training hud exposes drill mode button")
			_assert_true(tech_button != null, "training hud exposes throw-tech assist button")
			if mode_button != null:
				var recovery_label := str(hud.call("_resolve_training_drill_label", "recovery_route"))
				_assert_true(mode_button.text.findn(recovery_label) != -1, "training hud button surfaces the active recovery drill label")
			if tech_button != null:
				var button_assist_label := str(hud.call("_resolve_throw_tech_assist_mode_label", "button_assist"))
				_assert_true(tech_button.text.findn(button_assist_label) != -1, "training hud button surfaces button-assist state")
		var arena_node := training_node.get_node_or_null("Arena")
		if arena_node != null:
			_assert_true(bool(arena_node.get("side_platforms_enabled")), "training ruleset toggle enables side platforms")
		training_node.call("_on_hud_training_options_changed", {
			"enabled": true,
			"dummy_mode": "stand",
			"show_detail": false,
			"ruleset_profile": "platform",
			"drill_id": "di_survival",
			"throw_tech_assist_mode": "button_assist"
		})
		await process_frame
		var stale_runtime := {
			"drill_id": "di_survival",
			"elapsed_seconds": 0.41,
			"launch_attempted": true,
			"launch_triggered": true,
			"launch_delay_seconds": 0.24,
			"success_armed": true
		}
		training_node.set("training_drill_runtime", stale_runtime)
		training_node.set("training_drill_state", training_node.call("_build_training_drill_state", "di_survival", {
			"ruleset_profile": "platform",
			"rep_index": 2,
			"rep_status": "active",
			"last_result": "success",
			"success_reason": "survived_launch"
		}))
		training_node.call("_on_hud_training_options_changed", {
			"enabled": false,
			"dummy_mode": "stand",
			"show_detail": false,
			"ruleset_profile": "platform",
			"drill_id": "di_survival",
			"throw_tech_assist_mode": "button_assist"
		})
		await process_frame
		var disabled_runtime := training_node.get("training_drill_runtime") as Dictionary
		var disabled_state := training_node.get("training_drill_state") as Dictionary
		_assert_true(disabled_runtime.is_empty(), "disabling training clears stale Air & Edge drill runtime")
		_assert_true(str(disabled_state.get("rep_status", "")) == "idle", "disabling training idles the drill state")
		_assert_true(str(disabled_state.get("last_result", "")) == "", "disabling training clears stale drill outcomes")
		p2.set("attack_state", "heavy")
		p2.set("attack_phase", "active")
		p2.set("blockstun_time", 0.12)
		p2.set("hitstun_time", 0.16)
		p1.call("_start_ledge_hang", 1)
		training_node.call("_on_hud_training_options_changed", {
			"enabled": true,
			"dummy_mode": "stand",
			"show_detail": false,
			"ruleset_profile": "platform",
			"drill_id": "di_survival",
			"throw_tech_assist_mode": "button_assist"
		})
		await process_frame
		var restored_runtime := training_node.get("training_drill_runtime") as Dictionary
		var restored_state := training_node.get("training_drill_state") as Dictionary
		_assert_true(str(restored_runtime.get("drill_id", "")) == "di_survival", "re-enabling training starts a fresh Air & Edge drill rep")
		_assert_true(float(restored_runtime.get("elapsed_seconds", 99.0)) < 0.05, "re-enabling training resets the drill timer")
		_assert_true(not bool(restored_runtime.get("launch_triggered", false)), "re-enabling training clears stale launch flags")
		_assert_true(not bool(restored_runtime.get("success_armed", false)), "re-enabling training clears stale success arming")
		_assert_true(str(restored_state.get("last_result", "")) == "", "re-enabling training keeps the drill summary clean for the new rep")
		_assert_true(not bool(p1.get("is_ledge_hanging")), "re-enabling training respawns the Air & Edge fighter out of stale ledge state")
		_assert_true(str(p2.get("attack_state")) == "", "re-enabling training clears stale dummy attack state")
		_assert_true(float(p2.get("blockstun_time")) <= 0.0, "re-enabling training clears stale dummy blockstun")
		_assert_true(float(p2.get("hitstun_time")) <= 0.0, "re-enabling training clears stale dummy hitstun")
		training_node.call("_on_hud_training_options_changed", {
			"enabled": true,
			"dummy_mode": "random_block",
			"show_detail": true,
			"ruleset_profile": "duel",
			"drill_id": "duel_core",
			"throw_tech_assist_mode": "throw_only"
		})
		await process_frame
		_assert_true(not bool(p2.get("is_ai")), "switching back to duel keeps dummy non-ai")
		_assert_true(str(training_node.get("ruleset_profile")) == "duel", "training ruleset toggle can return to duel")
		var duel_drill_state := training_node.get("training_drill_state") as Dictionary
		_assert_true(str(duel_drill_state.get("drill_id", "")) == "duel_core", "training scene restores duel-core drill id when switching back")
		_assert_true(str(p2.get("training_throw_tech_assist_mode")) == "throw_only", "training scene can restore throw-only tech contract")
		if hud != null:
			var throw_only_button := hud.get_node_or_null("TrainingPanel/TrainingTechButton") as Button
			if throw_only_button != null:
				var throw_only_label := str(hud.call("_resolve_throw_tech_assist_mode_label", "throw_only"))
				_assert_true(throw_only_button.text.findn(throw_only_label) != -1, "training hud button can restore throw-only label")
			var assist_log := str(
				hud.call("_resolve_training_log_line", {
					"event_type": "throw_tech",
					"attack_kind": "throw",
					"block_type": "throw",
					"throw_tech_source": "light",
					"throw_tech_window_type": "assist",
					"advantage_frames": 0,
					"damage_total": 0,
					"combo_damage": 0,
					"hp_before": 100,
					"hp_after": 100
				})
			)
			var assist_label := str(hud.call("_tr_or_fallback", "HUD_TRAINING_LOG_ASSIST_SHORT", "Assist"))
			_assert_true(assist_log.findn(assist_label) != -1, "training log line surfaces assist throw-tech metadata")
			var whiff_log := str(
				hud.call("_resolve_training_log_line", {
					"event_type": "throw_whiff",
					"attack_kind": "throw",
					"block_type": "throw",
					"advantage_frames": -12,
					"damage_total": 0,
					"combo_damage": 0,
					"hp_before": 100,
					"hp_after": 100
				})
			)
			var whiff_label := str(hud.call("_resolve_training_event_label", "throw_whiff"))
			_assert_true(whiff_log.findn(whiff_label) != -1, "training log line surfaces throw whiff events")
			var drill_log := str(
				hud.call("_resolve_training_log_line", {
					"event_type": "drill_result",
					"training_drill_id": "ledge_escape",
					"training_drill_result": "success",
					"training_drill_reason": "stage_reclaim",
					"metrics": {
						"success_rate": 0.5,
						"last_closest_blast_margin_px": 84.0,
						"last_ledge_option": "roll"
					}
				})
			)
			var option_label := str(hud.call("_resolve_training_drill_option_label", "roll"))
			_assert_true(drill_log.findn(option_label) != -1, "training log line surfaces Air & Edge option metrics")
			var previous_locale := TranslationServer.get_locale()
			TranslationServer.set_locale("zh")
			hud.call("set_training_options", {
				"enabled": true,
				"dummy_mode": "stand",
				"show_detail": true,
				"ruleset_profile": "duel",
				"throw_tech_assist_mode": "button_assist"
			})
			hud.call("set_training_data", {
				"event_type": "throw_tech",
				"attack_kind": "throw",
				"block_type": "throw",
				"guard_mode": "throw_break",
				"stun_frames": 0,
				"recovery_frames": 14,
				"stun_seconds": 0.0,
				"recovery_seconds": 0.23,
				"throw_tech_source": "light",
				"throw_tech_window_type": "assist"
			})
			var detail_label := hud.get_node_or_null("TrainingPanel/TrainingDetailLabel") as Label
			_assert_true(detail_label != null, "training hud exposes detail label for localized throw-tech detail")
			if detail_label != null:
				var tech_prefix := str(hud.call("_tr_or_fallback", "HUD_TRAINING_DETAIL_TECH_LABEL", "Tech"))
				_assert_true(detail_label.text.findn(tech_prefix) != -1, "training detail label localizes throw-tech prefix")
			_assert_true(str(hud.call("_resolve_training_drill_reason_label", "ring_out")) == "出界", "training drill ring-out reason localizes to Chinese")
			_assert_true(str(hud.call("_resolve_training_drill_reason_label", "ko")) == "KO 重置", "training drill KO reason localizes to Chinese")
			_assert_true(str(hud.call("_resolve_training_drill_reason_label", "ledge_recovery")) == "抓边", "training drill ledge recovery reason localizes to Chinese")
			_assert_true(str(hud.call("_resolve_training_drill_reason_label", "stage_recovery")) == "回台", "training drill stage recovery reason localizes to Chinese")
			_assert_true(str(hud.call("_resolve_training_drill_reason_label", "stage_reclaim")) == "上台", "training drill stage reclaim reason localizes to Chinese")
			_assert_true(str(hud.call("_resolve_training_drill_reason_label", "survived_launch")) == "存活", "training drill survival reason localizes to Chinese")
			_assert_true(str(hud.call("_resolve_training_drill_reason_label", "launch_denied")) == "击飞被化解", "training drill denied-launch reason localizes to Chinese")
			_assert_true(str(hud.call("_resolve_training_drill_label", "ledge_escape")) == "抓边脱困", "training drill label localizes to Chinese")
			_assert_true(str(hud.call("_resolve_training_drill_di_direction_label", "left_up")) == "左上", "training drill DI direction localizes to Chinese")
			_assert_true(str(hud.call("_resolve_training_drill_option_label", "roll")) == "翻滚", "training drill ledge option localizes to Chinese")
			TranslationServer.set_locale(previous_locale)
	if is_instance_valid(training_node):
		training_node.queue_free()
	await process_frame

func _test_training_sandbox_resets_on_ko_and_ring_out() -> void:
	var packed := load("res://scenes/Training.tscn")
	_assert_true(packed is PackedScene, "training scene loads for sandbox reset test")
	if packed is not PackedScene:
		return
	var training_node := (packed as PackedScene).instantiate()
	get_root().add_child(training_node)
	await process_frame
	await process_frame
	var p1 := training_node.get_node_or_null("Player1") as CharacterBody2D
	var p2 := training_node.get_node_or_null("Player2") as CharacterBody2D
	var hud := training_node.get_node_or_null("Hud")
	var spawn_points: Variant = training_node.get("spawn_points")
	_assert_true(p1 != null and p2 != null, "training sandbox reset test resolves both fighters")
	if p1 != null and p2 != null:
		training_node.call("_on_hud_training_options_changed", {
			"enabled": true,
			"dummy_mode": "stand",
			"show_detail": true,
			"ruleset_profile": "duel",
			"drill_id": "duel_core",
			"throw_tech_assist_mode": "throw_only"
		})
		await process_frame
		var duel_respawn := Vector2(570.0, 316.0)
		if typeof(spawn_points) == TYPE_DICTIONARY:
			var spawn_value: Variant = (spawn_points as Dictionary).get("p2", duel_respawn)
			if spawn_value is Vector2:
				duel_respawn = spawn_value
		if hud != null:
			hud.call("set_training_data", {
				"event_type": "hit",
				"attack_kind": "heavy",
				"attacker_key": "p1",
				"training_drill_rep_index": 0,
				"stun_frames": 18,
				"recovery_frames": 12,
				"advantage_frames": 6
			})
		p2.call("apply_damage", 999, Vector2(180, -24), 0.14, "heavy", {})
		await process_frame
		await process_frame
		var duel_drill_state := training_node.get("training_drill_state") as Dictionary
		_assert_true(not bool(training_node.get("match_over")), "training duel KO reset keeps sandbox active")
		_assert_true(p2.global_position.distance_to(duel_respawn) <= 4.0, "training duel KO reset respawns defender at drill spawn")
		_assert_true(int(p2.get("current_hp")) == 100, "training duel KO reset restores health for the next rep")
		_assert_true(str(duel_drill_state.get("last_result", "")) == "reset", "training duel KO reset records a drill reset outcome")
		_assert_true(str(duel_drill_state.get("reset_reason", "")) == "ko", "training duel KO reset records KO as the reset reason")
		_assert_true(int(duel_drill_state.get("rep_index", 0)) == 1, "training duel KO reset advances the drill rep counter")
		if hud != null:
			var summary_label := hud.get_node_or_null("TrainingPanel/TrainingSummaryLabel") as Label
			var detail_label := hud.get_node_or_null("TrainingPanel/TrainingDetailLabel") as Label
			_assert_true(summary_label != null, "training sandbox reset test resolves training summary label")
			_assert_true(detail_label != null, "training sandbox reset test resolves training detail label")
			if summary_label != null:
				var reset_label := str(hud.call("_resolve_training_drill_result_label", "reset"))
				var ko_label := str(hud.call("_resolve_training_drill_reason_label", "ko"))
				_assert_true(summary_label.text.findn(reset_label) != -1, "training summary surfaces drill reset outcome over stale hit data")
				_assert_true(summary_label.text.findn(ko_label) != -1, "training summary surfaces the drill reset reason over stale hit data")
			if detail_label != null:
				var ko_label := str(hud.call("_resolve_training_drill_reason_label", "ko"))
				_assert_true(detail_label.text.findn(ko_label) != -1, "training detail surfaces the latest drill reset reason over stale hit data")

		training_node.call("_on_hud_training_options_changed", {
			"enabled": true,
			"dummy_mode": "stand",
			"show_detail": true,
			"ruleset_profile": "platform",
			"drill_id": "recovery_route"
		})
		await process_frame
		await process_frame
		var platform_stage_right_x := float(training_node.get("stage_right_x"))
		var platform_stage_floor_y := float(training_node.get("stage_floor_y"))
		if hud != null:
			hud.call("set_training_data", {
				"event_type": "block",
				"attack_kind": "special",
				"attacker_key": "p1",
				"training_drill_rep_index": 0,
				"stun_frames": 9,
				"recovery_frames": 14,
				"advantage_frames": -5
			})
		p1.position = Vector2(1400.0, 300.0)
		p1.set("current_hp", 12)
		await process_frame
		await process_frame
		var platform_drill_state := training_node.get("training_drill_state") as Dictionary
		_assert_true(str(training_node.get("win_rule")) == "hp_timer", "platform drill keeps hp UI while sandboxing edge resets")
		_assert_true(not bool(training_node.get("match_over")), "platform drill ring-out reset keeps training sandbox active")
		_assert_true(
			p1.global_position.x > platform_stage_right_x + 40.0 and p1.global_position.y < platform_stage_floor_y - 40.0,
			"platform drill ring-out reset returns fighter to the recovery-route start position"
		)
		_assert_true(int(p1.get("current_hp")) == 100, "platform drill ring-out reset restores health for the next rep")
		_assert_true(str(platform_drill_state.get("drill_id", "")) == "recovery_route", "platform drill sandbox keeps the explicit recovery drill id")
		_assert_true(str(platform_drill_state.get("last_result", "")) == "fail", "platform drill ring-out records a fail outcome")
		_assert_true(str(platform_drill_state.get("fail_reason", "")) == "ring_out", "platform drill ring-out records the fail reason")
		_assert_true(int(platform_drill_state.get("rep_index", 0)) == 1, "platform drill ring-out advances the drill rep counter")
		if hud != null:
			var summary_label := hud.get_node_or_null("TrainingPanel/TrainingSummaryLabel") as Label
			var detail_label := hud.get_node_or_null("TrainingPanel/TrainingDetailLabel") as Label
			if summary_label != null:
				var fail_label := str(hud.call("_resolve_training_drill_result_label", "fail"))
				var ring_out_label := str(hud.call("_resolve_training_drill_reason_label", "ring_out"))
				_assert_true(summary_label.text.findn(fail_label) != -1, "training summary surfaces drill fail outcome over stale platform hit data")
				_assert_true(summary_label.text.findn(ring_out_label) != -1, "training summary surfaces drill fail reason over stale platform hit data")
			if detail_label != null:
				var ring_out_label := str(hud.call("_resolve_training_drill_reason_label", "ring_out"))
				_assert_true(detail_label.text.findn(ring_out_label) != -1, "training detail surfaces the latest drill fail reason over stale platform hit data")
		p2.set("attack_state", "heavy")
		p2.set("attack_phase", "active")
		p2.set("hitstun_time", 0.18)
		p2.set("blockstun_time", 0.12)
		p2.set("velocity", Vector2(-84.0, -46.0))
		p1.set("current_hp", 12)
		p1.set("wake_invuln_time", 0.0)
		p1.call("apply_damage", 999, Vector2(180, -24), 0.14, "heavy", {})
		await process_frame
		await process_frame
		var platform_ko_state := training_node.get("training_drill_state") as Dictionary
		_assert_true(float(p2.get("wake_invuln_time")) > 0.0, "platform drill KO reset respawns the surviving dummy before the next rep")
		_assert_true(str(p2.get("attack_state")) == "", "platform drill KO reset clears stale dummy attack state")
		_assert_true(float(p2.get("hitstun_time")) <= 0.0, "platform drill KO reset clears stale dummy hitstun")
		_assert_true(float(p2.get("blockstun_time")) <= 0.0, "platform drill KO reset clears stale dummy blockstun")
		_assert_true(str(platform_ko_state.get("last_result", "")) == "reset", "platform drill KO reset still records a reset outcome")
		_assert_true(str(platform_ko_state.get("reset_reason", "")) == "ko", "platform drill KO reset records KO as the reset reason")
	if is_instance_valid(training_node):
		training_node.queue_free()
	await process_frame

func _test_air_edge_drills_have_rep_behaviors() -> void:
	var packed := load("res://scenes/Training.tscn")
	_assert_true(packed is PackedScene, "training scene loads for Air & Edge drill behavior test")
	if packed is not PackedScene:
		return
	var training_node := (packed as PackedScene).instantiate()
	get_root().add_child(training_node)
	await process_frame
	await process_frame
	var p1 := training_node.get_node_or_null("Player1") as CharacterBody2D
	var hud := training_node.get_node_or_null("Hud")
	var stage_right_x := float(training_node.get("stage_right_x"))
	var stage_floor_y := float(training_node.get("stage_floor_y"))
	_assert_true(p1 != null, "Air & Edge drill behavior test resolves player1")
	if p1 != null:
		training_node.call("_on_hud_training_options_changed", {
			"enabled": true,
			"dummy_mode": "stand",
			"show_detail": true,
			"ruleset_profile": "platform",
			"drill_id": "recovery_route"
		})
		await process_frame
		await process_frame
		_assert_true(p1.global_position.x > stage_right_x + 40.0, "recovery drill starts player1 offstage to the side of the platform")
		p1.call("_start_ledge_hang", 1)
		await process_frame
		await process_frame
		var recovery_state := training_node.get("training_drill_state") as Dictionary
		var recovery_metrics := recovery_state.get("metrics", {}) as Dictionary
		_assert_true(str(recovery_state.get("last_result", "")) == "success", "recovery drill records success after a ledge grab")
		_assert_true(str(recovery_state.get("success_reason", "")) == "ledge_recovery", "recovery drill records ledge recovery as the success reason")
		_assert_true(int(recovery_metrics.get("success_count", 0)) == 1, "recovery drill metrics count a successful rep")
		_assert_true(absf(float(recovery_metrics.get("success_rate", 0.0)) - 1.0) < 0.001, "recovery drill metrics surface a 100% success rate after the opening rep")
		_assert_true(float(recovery_metrics.get("last_closest_blast_margin_px", -1.0)) >= 0.0, "recovery drill metrics capture the nearest blast-zone distance")
		if hud != null:
			hud.call("set_training_data", {
				"event_type": "block",
				"attack_kind": "heavy",
				"attacker_key": "p1",
				"training_drill_rep_index": 0,
				"stun_frames": 12,
				"recovery_frames": 9,
				"advantage_frames": -3
			})
			await process_frame
			var stun_label := hud.get_node_or_null("TrainingPanel/TrainingStunLabel") as Label
			var recovery_label := hud.get_node_or_null("TrainingPanel/TrainingRecoveryLabel") as Label
			var advantage_label := hud.get_node_or_null("TrainingPanel/TrainingAdvantageLabel") as Label
			var detail_label := hud.get_node_or_null("TrainingPanel/TrainingDetailLabel") as Label
			if stun_label != null:
				_assert_true(stun_label.text == str(hud.call("_resolve_training_drill_rate_label")), "Air & Edge HUD surfaces success-rate metrics instead of stale frame data")
			if recovery_label != null:
				_assert_true(recovery_label.text == str(hud.call("_resolve_training_drill_streak_label")), "Air & Edge HUD surfaces drill streak metrics")
			if advantage_label != null:
				_assert_true(advantage_label.text == str(hud.call("_resolve_training_drill_edge_label")), "Air & Edge HUD surfaces blast-margin metrics instead of frame advantage")
			if detail_label != null:
				var finish_label := str(hud.call("_resolve_training_drill_finish_label", "ledge"))
				_assert_true(detail_label.text.findn(finish_label) != -1, "Air & Edge detail surfaces recovery finish-state metrics")
		p1.position = Vector2(1400.0, 300.0)
		await process_frame
		await process_frame
		var recovery_fail_state := training_node.get("training_drill_state") as Dictionary
		var recovery_fail_metrics := recovery_fail_state.get("metrics", {}) as Dictionary
		_assert_true(int(recovery_fail_metrics.get("rep_total", 0)) == 2, "recovery drill metrics count both successful and failed reps")
		_assert_true(absf(float(recovery_fail_metrics.get("success_rate", 0.0)) - 0.5) < 0.001, "recovery drill metrics surface a mixed success rate after one success and one fail")
		_assert_true(str(recovery_fail_metrics.get("last_finish_state", "")) == "", "recovery drill clears the previous finish-state metric after a fail rep with no finish")
		if hud != null:
			var recovery_detail_label := hud.get_node_or_null("TrainingPanel/TrainingDetailLabel") as Label
			if recovery_detail_label != null:
				var stale_finish_label := str(hud.call("_resolve_training_drill_finish_label", "ledge"))
				_assert_true(recovery_detail_label.text.findn(stale_finish_label) == -1, "Air & Edge detail does not leak the previous finish-state metric into the latest fail rep")

		training_node.call("_on_hud_training_options_changed", {
			"enabled": true,
			"dummy_mode": "stand",
			"show_detail": true,
			"ruleset_profile": "platform",
			"drill_id": "ledge_escape"
		})
		await process_frame
		await process_frame
		_assert_true(bool(p1.get("is_ledge_hanging")), "ledge escape drill starts player1 in ledge hang")
		p1.call("_drop_from_ledge", true)
		p1.global_position = Vector2(stage_right_x - 96.0, stage_floor_y + 72.0)
		await process_frame
		await process_frame
		var ledge_fail_state := training_node.get("training_drill_state") as Dictionary
		_assert_true(str(ledge_fail_state.get("last_result", "")) != "success", "ledge escape drill does not award success while drifting below the stage")
		training_node.call("_on_hud_training_options_changed", {
			"enabled": true,
			"dummy_mode": "stand",
			"show_detail": false,
			"ruleset_profile": "platform",
			"drill_id": "recovery_route"
		})
		await process_frame
		await process_frame
		training_node.call("_on_hud_training_options_changed", {
			"enabled": true,
			"dummy_mode": "stand",
			"show_detail": true,
			"ruleset_profile": "platform",
			"drill_id": "ledge_escape"
		})
		await process_frame
		await process_frame
		_assert_true(bool(p1.get("is_ledge_hanging")), "ledge escape drill can reset after an under-stage drift when the sandbox rep is restarted")
		p1.call("_roll_getup_from_ledge")
		for _frame in range(12):
			await process_frame
			var current_ledge_state := training_node.get("training_drill_state") as Dictionary
			if str(current_ledge_state.get("last_result", "")) == "success":
				break
		var ledge_state := training_node.get("training_drill_state") as Dictionary
		var ledge_metrics := ledge_state.get("metrics", {}) as Dictionary
		_assert_true(str(ledge_state.get("last_result", "")) == "success", "ledge escape drill records success after reclaiming stage")
		_assert_true(str(ledge_state.get("success_reason", "")) == "stage_reclaim", "ledge escape drill records stage reclaim as the success reason")
		_assert_true(str(ledge_metrics.get("last_ledge_option", "")) == "roll", "ledge escape drill metrics remember the last ledge option that reclaimed stage")
		if hud != null:
			await process_frame
			var detail_label := hud.get_node_or_null("TrainingPanel/TrainingDetailLabel") as Label
			if detail_label != null:
				var option_label := str(hud.call("_resolve_training_drill_option_label", "roll"))
				_assert_true(detail_label.text.findn(option_label) != -1, "ledge escape detail surfaces the ledge-option outcome")

		training_node.call("_on_hud_training_options_changed", {
			"enabled": true,
			"dummy_mode": "stand",
			"show_detail": true,
			"ruleset_profile": "platform",
			"drill_id": "di_survival"
		})
		await process_frame
		await process_frame
		var di_runtime := training_node.get("training_drill_runtime") as Dictionary
		_assert_true(float(di_runtime.get("launch_delay_seconds", 0.0)) > 0.0, "DI survival drill exposes a positive launch delay configuration")
		p1.set("wake_invuln_time", 0.0)
		p1.set("is_blocking", false)
		training_node.call("_trigger_di_survival_launch")
		var launch_seen := bool((training_node.get("training_drill_runtime") as Dictionary).get("launch_triggered", false))
		_assert_true(launch_seen, "DI survival drill launch helper arms the rep")
		if launch_seen:
			p1.call("_start_ledge_hang", 1)
			training_node.call("_update_di_survival_drill")
			await process_frame
			var di_state := training_node.get("training_drill_state") as Dictionary
			var di_metrics := di_state.get("metrics", {}) as Dictionary
			_assert_true(str(di_state.get("last_result", "")) == "success", "DI survival drill records success after surviving the launch")
			_assert_true(str(di_state.get("success_reason", "")) == "survived_launch", "DI survival drill records survived launch as the success reason")
			_assert_true(str(di_metrics.get("last_di_direction", "")) == "neutral", "DI survival drill metrics record the last DI direction snapshot")
			if hud != null:
				var detail_label := hud.get_node_or_null("TrainingPanel/TrainingDetailLabel") as Label
				if detail_label != null:
					var di_label := str(hud.call("_resolve_training_drill_di_direction_label", "neutral"))
					_assert_true(detail_label.text.findn(di_label) != -1, "DI survival detail surfaces the DI direction metric")

		training_node.call("_on_hud_training_options_changed", {
			"enabled": true,
			"dummy_mode": "stand",
			"show_detail": true,
			"ruleset_profile": "platform",
			"drill_id": "di_survival"
		})
		await process_frame
		await process_frame
		p1.set("facing", -1)
		p1.set("is_blocking", true)
		p1.set("wake_invuln_time", 0.0)
		training_node.call("_trigger_di_survival_launch")
		await process_frame
		await process_frame
		var denied_state := training_node.get("training_drill_state") as Dictionary
		var denied_runtime := training_node.get("training_drill_runtime") as Dictionary
		_assert_true(str(denied_state.get("last_result", "")) == "fail", "DI survival drill fails the rep when the scripted launch gets denied")
		_assert_true(str(denied_state.get("fail_reason", "")) == "launch_denied", "DI survival drill records launch denial when no real launch connects")
		_assert_true(not bool(denied_runtime.get("launch_triggered", false)), "DI survival drill does not arm success after a denied launch")
	if is_instance_valid(training_node):
		training_node.queue_free()
	await process_frame

func _test_character_visual_readability_tinting() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var p2 := setup.get("p2") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or p2 == null or host == null:
		return
	p1.call("_update_visual")
	p2.call("_update_visual")
	var p1_visual := p1.get_node_or_null("Visual")
	var p2_visual := p2.get_node_or_null("Visual")
	_assert_true(p1_visual is CanvasItem and p2_visual is CanvasItem, "player visuals resolve for readability tint test")
	if p1_visual is CanvasItem and p2_visual is CanvasItem:
		var c1 := (p1_visual as CanvasItem).modulate
		var c2 := (p2_visual as CanvasItem).modulate
		var tint_delta := absf(c1.r - c2.r) + absf(c1.g - c2.g) + absf(c1.b - c2.b)
		_assert_true(tint_delta > 0.06, "different character profiles produce distinct readability tint")
	host.queue_free()
	await process_frame

func _test_player_visual_fx_pipeline() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or host == null:
		return
	p1.set("attack_state", "signature_a")
	p1.set("attack_phase", "startup")
	p1.call("_update_visual")
	var shadow := p1.get_node_or_null("GroundShadow")
	var aura := p1.get_node_or_null("AuraGlow")
	_assert_true(shadow is Sprite2D, "player visual fx pipeline creates ground shadow sprite")
	_assert_true(aura is Sprite2D, "player visual fx pipeline creates aura glow sprite")
	if shadow is Sprite2D:
		_assert_true((shadow as Sprite2D).modulate.a > 0.12, "ground shadow keeps readable grounding alpha")
	if aura is Sprite2D:
		_assert_true((aura as Sprite2D).visible, "signature startup enables aura glow")
		_assert_true((aura as Sprite2D).modulate.a > 0.10, "aura glow carries readable alpha during signature startup")
		var signature_a_tint := (aura as Sprite2D).modulate
		p1.set("attack_state", "signature_b")
		p1.set("attack_phase", "startup")
		p1.call("_update_visual")
		var signature_b_tint := (aura as Sprite2D).modulate
		var tint_shift := absf(signature_a_tint.r - signature_b_tint.r) + absf(signature_a_tint.g - signature_b_tint.g) + absf(signature_a_tint.b - signature_b_tint.b)
		_assert_true(tint_shift > 0.16, "different signature attacks surface distinct aura colors")
	host.queue_free()
	await process_frame

func _test_signature_visual_identity_pipeline() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or host == null:
		return
	var mark_table := load("res://assets/data/characters/MarkZuckAttackTable.tres")
	var sam_table := load("res://assets/data/characters/SamAltmynAttackTable.tres")
	var peter_table := load("res://assets/data/characters/PeterThyellAttackTable.tres")
	var zef_table := load("res://assets/data/characters/ZefBezosAttackTable.tres")
	var bill_table := load("res://assets/data/characters/BillGeytzAttackTable.tres")
	var sundar_table := load("res://assets/data/characters/SundarPichoyAttackTable.tres")
	_assert_true(
		mark_table is Resource and sam_table is Resource and peter_table is Resource and zef_table is Resource and bill_table is Resource and sundar_table is Resource,
		"signature visual identity test loads story character tables"
	)
	if mark_table is not Resource or sam_table is not Resource or peter_table is not Resource or zef_table is not Resource or bill_table is not Resource or sundar_table is not Resource:
		host.queue_free()
		await process_frame
		return
	p1.set("use_external_attack_table", true)
	p1.set("attack_table_resource", mark_table)
	p1.call("_setup_attack_data")
	var mark_signature_a := p1.call("_resolve_signature_visual_context", "signature_a") as Dictionary
	var mark_signature_b := p1.call("_resolve_signature_visual_context", "signature_b") as Dictionary
	_assert_true(str(mark_signature_a.get("variant", "")) == "threads", "Mark signature A resolves the threads trail override")
	_assert_true(str(mark_signature_b.get("variant", "")) == "mirror", "Mark signature B resolves the mirrored rift override")
	p1.set("attack_table_resource", sam_table)
	p1.call("_setup_attack_data")
	var sam_signature_a := p1.call("_resolve_signature_visual_context", "signature_a") as Dictionary
	var sam_signature_b := p1.call("_resolve_signature_visual_context", "signature_b") as Dictionary
	var sam_ultimate := p1.call("_resolve_signature_visual_context", "ultimate") as Dictionary
	_assert_true(str(sam_signature_a.get("variant", "")) == "gpt_wave", "GPT Burst resolves the authored GPT wave trail variant")
	_assert_true(str(sam_signature_b.get("variant", "")) == "cutscene", "trap-style signatures resolve the cutscene glyph variant")
	_assert_true(str(sam_ultimate.get("variant", "")) == "cutscene_halo", "buff-style ultimates resolve the cinematic halo ring variant")
	p1.set("attack_table_resource", peter_table)
	p1.call("_setup_attack_data")
	var peter_signature_b := p1.call("_resolve_signature_visual_context", "signature_b") as Dictionary
	_assert_true(str(peter_signature_b.get("variant", "")) == "coup", "Peter signature B resolves the coup slash override")
	p1.set("attack_table_resource", zef_table)
	p1.call("_setup_attack_data")
	var zef_signature_a := p1.call("_resolve_signature_visual_context", "signature_a") as Dictionary
	var zef_signature_b := p1.call("_resolve_signature_visual_context", "signature_b") as Dictionary
	_assert_true(str(zef_signature_a.get("variant", "")) == "drone", "Prime Drone Fleet resolves the drone-style summon trail variant")
	_assert_true(str(zef_signature_b.get("landing_variant", "")) == "launch", "Zef rising signature carries launch landing traces")
	p1.set("attack_table_resource", bill_table)
	p1.call("_setup_attack_data")
	var bill_signature_b := p1.call("_resolve_signature_visual_context", "signature_b") as Dictionary
	_assert_true(str(bill_signature_b.get("variant", "")) == "azure_flood", "Bill signature B resolves the azure flood projectile variant")
	p1.set("attack_table_resource", sundar_table)
	p1.call("_setup_attack_data")
	var sundar_signature_b := p1.call("_resolve_signature_visual_context", "signature_b") as Dictionary
	_assert_true(str(sundar_signature_b.get("variant", "")) == "chrome", "Sundar signature B resolves the chrome rush slash variant")
	p1.call("_clear_transient_visual_fx")
	p1.set("attack_table_resource", peter_table)
	p1.call("_setup_attack_data")
	p1.call("_emit_landing_trace", 360.0, false, "signature_b")
	var transient_fx := p1.get("transient_visual_fx") as Array
	_assert_true(transient_fx.size() >= 2, "signature landing trace spawns primary and support transient fx nodes")
	var saw_coup := false
	var saw_board := false
	for fx_value in transient_fx:
		if typeof(fx_value) != TYPE_DICTIONARY:
			continue
		var fx := fx_value as Dictionary
		if str(fx.get("variant", "")) == "coup":
			saw_coup = true
		if str(fx.get("variant", "")) == "board":
			saw_board = true
	_assert_true(saw_coup, "landing trace keeps Peter's coup impact variant")
	_assert_true(saw_board, "landing trace appends Peter's board support glyph")
	host.queue_free()
	await process_frame

func _test_signature_showcase_autoplay_scene() -> void:
	var packed := load("res://scenes/debug/SignatureShowcaseAutoplay.tscn")
	_assert_true(packed is PackedScene, "signature showcase autoplay scene loads for deterministic visual review")

func _test_double_ko_resolution() -> void:
	var packed := load("res://scenes/Main.tscn")
	_assert_true(packed is PackedScene, "main scene loads for double-KO resolution test")
	if packed is not PackedScene:
		return
	var match_node := (packed as PackedScene).instantiate()
	get_root().add_child(match_node)
	await process_frame
	await process_frame
	var p1 := match_node.get_node_or_null("Player1")
	var p2 := match_node.get_node_or_null("Player2")
	_assert_true(p1 != null and p2 != null, "double-KO test can resolve both fighters")
	if p1 != null and p2 != null:
		match_node.set("stocks", {"p1": 1, "p2": 1})
		p1.set("current_hp", 0)
		p2.set("current_hp", 0)
		p1.emit_signal("defeated")
		await process_frame
		await process_frame
		var result_key := str(match_node.get("match_result_key"))
		_assert_true(result_key == "draw", "double-KO resolves to draw instead of winner override")
	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

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

func _test_throw_tech_and_ai_defense_windows() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var p2 := setup.get("p2") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or p2 == null or host == null:
		return

	p1.set("is_ai", false)
	p2.set("is_ai", false)
	p1.call("set_ruleset_profile", "duel")
	p2.call("set_ruleset_profile", "duel")
	_reset_throw_tech_target_state(p2)

	var throw_meta := {
		"throw_techable": true,
		"block_type": "throw",
		"air_blockable": false
	}

	_reset_throw_tech_target_state(p2)
	p2.call("_prime_throw_tech_buffer", "light")
	var duel_light_result: Dictionary = p2.call("apply_damage", 10, Vector2(110, -16), 0.12, "throw", throw_meta)
	_assert_true(not bool(duel_light_result.get("throw_teched", false)), "duel throw tech ignores light mashing")

	_reset_throw_tech_target_state(p2)
	p2.call("_prime_throw_tech_buffer", "heavy")
	var duel_heavy_result: Dictionary = p2.call("apply_damage", 10, Vector2(110, -16), 0.12, "throw", throw_meta)
	_assert_true(not bool(duel_heavy_result.get("throw_teched", false)), "duel throw tech ignores heavy mashing")

	_reset_throw_tech_target_state(p2)
	p2.call("_prime_throw_tech_buffer", "throw")
	var tech_result: Dictionary = p2.call("apply_damage", 10, Vector2(110, -16), 0.12, "throw", throw_meta)
	_assert_true(bool(tech_result.get("throw_teched", false)), "throw tech succeeds inside tighter input buffer window")
	_assert_true(str(tech_result.get("throw_tech_source", "")) == "throw", "throw tech records throw input as its source")
	var defender_velocity_value: Variant = p2.get("velocity")
	if defender_velocity_value is Vector2:
		_assert_true(absf((defender_velocity_value as Vector2).x) >= 90.0, "throw tech pushback resets the defender out of throw range")

	_reset_throw_tech_target_state(p2)
	p2.call("_clear_throw_tech_buffer")
	var no_tech_result: Dictionary = p2.call("apply_damage", 10, Vector2(110, -16), 0.12, "throw", throw_meta)
	_assert_true(not bool(no_tech_result.get("throw_teched", false)), "throw tech fails when buffer is not primed")

	_reset_throw_tech_target_state(p2)
	p2.call("set_training_throw_tech_options", true, "button_assist")
	p2.call("_prime_throw_tech_buffer", "light")
	var assist_light_result: Dictionary = p2.call("apply_damage", 10, Vector2(110, -16), 0.12, "throw", throw_meta)
	_assert_true(bool(assist_light_result.get("throw_teched", false)), "training button assist allows light input to tech throws")
	_assert_true(str(assist_light_result.get("throw_tech_window_type", "")) == "assist", "training button assist records assist window metadata")

	_reset_throw_tech_target_state(p2)
	p2.call("set_training_throw_tech_options", true, "off")
	p2.call("_prime_throw_tech_buffer", "throw")
	var assist_off_result: Dictionary = p2.call("apply_damage", 10, Vector2(110, -16), 0.12, "throw", throw_meta)
	_assert_true(not bool(assist_off_result.get("throw_teched", false)), "training can disable throw-tech buffering entirely")

	p2.call("set_training_throw_tech_options", false, "throw_only")

	_reset_throw_tech_target_state(p1)
	_reset_throw_tech_target_state(p2)
	p1.call("_start_attack", "throw")
	p1.call("_update_attack", 0.08)
	p2.call("_start_spot_dodge")
	var dodge_throw_result: Dictionary = p2.call("apply_damage", 11, Vector2(180, -16), 0.24, "throw", throw_meta)
	_assert_true(bool(dodge_throw_result.get("ignored", false)), "spot dodge cleanly avoids throw attempts")
	p1.call("_update_attack", 0.08)
	var throw_data := p1.call("_get_attack_data", "throw") as Dictionary
	var whiff_recovery := float(p1.call("_get_attack_recovery_remaining_seconds", throw_data))
	_assert_true(whiff_recovery >= 0.24, "whiffed duel throw leaves a punishable recovery window")
	var whiff_training_info: Dictionary = p1.call("get_last_training_info")
	_assert_true(str(whiff_training_info.get("event_type", "")) == "throw_whiff", "throw whiff training event is recorded as soon as recovery starts")
	_assert_true(int(whiff_training_info.get("advantage_frames", 0)) < 0, "throw whiff training event preserves negative advantage during recovery")
	_assert_true(int(whiff_training_info.get("hp_before", -1)) == int(p1.get("current_hp")), "throw whiff training event records the attacker's current hp snapshot")
	_assert_true(int(whiff_training_info.get("hp_after", -1)) == int(p1.get("current_hp")), "throw whiff training event keeps hp_after aligned with unchanged health")
	p1.call("_record_training_exchange", "throw_whiff", "throw", throw_data, {}, false, 0, 0, 0)
	var fallback_training_info: Dictionary = p1.call("get_last_training_info")
	_assert_true(int(fallback_training_info.get("hp_before", -1)) == int(p1.get("current_hp")), "training exchange defaults missing hp_before to the current hp")
	_assert_true(int(fallback_training_info.get("hp_after", -1)) == int(p1.get("current_hp")), "training exchange defaults missing hp_after to the current hp")
	p2.set("dodge_time", 0.0)
	p2.call("_end_dodge_state")
	p1.call("_update_attack", 0.12)
	_assert_true(str(p1.get("attack_phase")) == "recovery", "throw stays in recovery after dodge invulnerability ends")
	_assert_true(bool(p2.call("_can_start_attack")), "defender can punish after dodging a throw")

	_reset_throw_tech_target_state(p1)
	_reset_throw_tech_target_state(p2)
	p1.call("_start_attack", "throw")
	p1.call("_update_attack", 0.08)
	var landed_throw_result: Dictionary = p2.call("apply_damage", 11, Vector2(180, -16), 0.24, "throw", throw_meta)
	_assert_true(not bool(landed_throw_result.get("throw_teched", false)), "landed throw test starts from an unteched grab")
	_assert_true(int(landed_throw_result.get("damage_total", 0)) > 0, "landed throw test confirms the defender actually took the throw")
	p1.set("attack_confirmed_hit", true)
	p1.call("_update_attack", 0.08)
	var landed_throw_recovery := float(p1.call("_get_attack_recovery_remaining_seconds", throw_data))
	_assert_true(landed_throw_recovery < 0.24, "landed throw keeps authored recovery instead of the whiff floor")

	_reset_throw_tech_target_state(p1)
	p1.call("_start_attack", "throw")
	p1.call("_update_attack", 0.08)
	p1.call("_on_attack_blocked", throw_data)
	p1.call("_record_training_exchange", "throw_tech", "throw", throw_data, {
		"throw_tech_source": "throw",
		"throw_tech_window_type": "duel"
	}, false, 0, 0, 11)
	p1.call("_update_attack", 0.40)
	var post_tech_training_info: Dictionary = p1.call("get_last_training_info")
	_assert_true(str(post_tech_training_info.get("event_type", "")) == "throw_tech", "throw tech feedback is not overwritten by whiff logging after recovery")

	p2.set("is_ai", true)
	p2.set("ai_style_profile", {
		"throw_tech_chance": 1.0,
		"block_chance": 0.32,
		"throw_bias": 1.0
	})
	_reset_throw_tech_target_state(p2)
	var ai_tech_result: Dictionary = p2.call("apply_damage", 10, Vector2(110, -16), 0.12, "throw", throw_meta)
	_assert_true(bool(ai_tech_result.get("throw_teched", false)), "ai throw tech uses profile-aware chance when explicitly configured")
	p2.call("set_training_throw_tech_options", true, "off")
	_reset_throw_tech_target_state(p2)
	var ai_training_off_result: Dictionary = p2.call("apply_damage", 10, Vector2(110, -16), 0.12, "throw", throw_meta)
	_assert_true(not bool(ai_training_off_result.get("throw_teched", false)), "training throw-tech off mode also disables ai techs in sandbox")
	p2.call("set_training_throw_tech_options", false, "throw_only")
	p2.set("ai_style_profile", {
		"block_chance": 0.20,
		"throw_bias": 0.72,
		"combo_pressure": 0.78
	})
	var low_ai_tech_chance := float(p2.call("_get_ai_throw_tech_chance"))
	p2.set("ai_style_profile", {
		"block_chance": 0.48,
		"throw_bias": 1.24,
		"combo_pressure": 0.40
	})
	var high_ai_tech_chance := float(p2.call("_get_ai_throw_tech_chance"))
	_assert_true(high_ai_tech_chance > low_ai_tech_chance, "ai throw-tech helper scales with defensive profile strength")
	p2.set("ai_block_time", 0.0)
	p2.set("is_blocking", false)
	p2.set("hitstun_time", 0.0)
	p2.set("blockstun_time", 0.0)
	p2.set("is_knocked_down", false)
	p2.set("getup_time", 0.0)
	p2.set("wake_invuln_time", 0.0)
	p2.set("ai_style_profile", {
		"block_chance": 1.0,
		"block_hold_time": 0.12
	})

	p1.set("attack_state", "heavy")
	p1.set("attack_phase", "startup")
	p1.set("attack_time", 0.02)
	p1.set("attack_startup_duration", 0.20)
	var early_block_roll := bool(p2.call("_should_ai_block", 40.0))
	_assert_true(not early_block_roll, "ai does not pre-block at very early startup")

	p2.set("ai_block_time", 0.0)
	p1.set("attack_time", 0.16)
	var late_startup_block_roll := bool(p2.call("_should_ai_block", 40.0))
	_assert_true(late_startup_block_roll, "ai can block when startup nears active threat")

	p2.set("ai_block_time", 0.0)
	p1.set("attack_phase", "active")
	var active_block_roll := bool(p2.call("_should_ai_block", 40.0))
	_assert_true(active_block_roll, "ai blocks reliably during active threat window")

	host.queue_free()
	await process_frame

func _test_knockback_growth_and_di_response() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var p2 := setup.get("p2") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or p2 == null or host == null:
		return

	p1.set("is_ai", false)
	p2.set("is_ai", false)
	p2.set("hitstun_time", 0.0)
	p2.set("blockstun_time", 0.0)
	p2.set("is_knocked_down", false)
	p2.set("getup_time", 0.0)
	p2.set("wake_invuln_time", 0.0)

	var base_knockback := Vector2(180.0, -88.0)
	p2.set("current_hp", 100)
	p2.call("apply_damage", 6, base_knockback, 0.12, "heavy", {})
	var low_damage_velocity := p2.get("velocity") as Vector2

	p2.set("hitstun_time", 0.0)
	p2.set("blockstun_time", 0.0)
	p2.set("is_knocked_down", false)
	p2.set("getup_time", 0.0)
	p2.set("wake_invuln_time", 0.0)
	p2.set("current_hp", 30)
	p2.call("apply_damage", 6, base_knockback, 0.12, "heavy", {})
	var high_damage_velocity := p2.get("velocity") as Vector2
	_assert_true(high_damage_velocity.length() > low_damage_velocity.length() + 8.0, "knockback growth scales with accumulated damage")

	p2.set("hitstun_time", 0.0)
	p2.set("blockstun_time", 0.0)
	p2.set("is_knocked_down", false)
	p2.set("getup_time", 0.0)
	p2.set("wake_invuln_time", 0.0)
	p2.set("current_hp", 90)
	p2.call("apply_damage", 4, base_knockback, 0.12, "heavy", {"di_override": Vector2(-1.0, 0.0)})
	var left_di_velocity := p2.get("velocity") as Vector2

	p2.set("hitstun_time", 0.0)
	p2.set("blockstun_time", 0.0)
	p2.set("is_knocked_down", false)
	p2.set("getup_time", 0.0)
	p2.set("wake_invuln_time", 0.0)
	p2.set("current_hp", 90)
	p2.call("apply_damage", 4, base_knockback, 0.12, "heavy", {"di_override": Vector2(1.0, 0.0)})
	var right_di_velocity := p2.get("velocity") as Vector2

	_assert_true(absf(left_di_velocity.x - right_di_velocity.x) > 18.0, "directional influence changes launch trajectory")
	_assert_true(absf(left_di_velocity.y - right_di_velocity.y) > 6.0, "directional influence affects vertical launch component")

	host.queue_free()
	await process_frame

func _test_hitstop_tier_resolution() -> void:
	var packed := load("res://scenes/Main.tscn")
	_assert_true(packed is PackedScene, "main scene loads for hitstop tier resolution test")
	if packed is not PackedScene:
		return
	var match_node := (packed as PackedScene).instantiate()
	get_root().add_child(match_node)
	await process_frame
	await process_frame

	var light_hitstop := float(match_node.call("_resolve_hitstop_duration", "light", false, 1))
	var heavy_hitstop := float(match_node.call("_resolve_hitstop_duration", "heavy_up", false, 1))
	var signature_hitstop := float(match_node.call("_resolve_hitstop_duration", "signature_b", false, 1))
	var ultimate_hitstop := float(match_node.call("_resolve_hitstop_duration", "ultimate", false, 1))
	_assert_true(heavy_hitstop > light_hitstop, "heavy hitstop tier is stronger than light tier")
	_assert_true(signature_hitstop > heavy_hitstop, "signature hitstop tier is stronger than heavy tier")
	_assert_true(ultimate_hitstop > signature_hitstop, "ultimate hitstop tier is strongest")

	var light_blockstop := float(match_node.call("_resolve_blockstop_duration", "light"))
	var ultimate_blockstop := float(match_node.call("_resolve_blockstop_duration", "ultimate"))
	_assert_true(ultimate_blockstop > light_blockstop, "blockstop tier scales up for ultimate attacks")

	if is_instance_valid(match_node):
		match_node.queue_free()
	await process_frame

func _test_skill_runtime_primitives() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var p2 := setup.get("p2") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or p2 == null or host == null:
		return

	var custom_table = AttackTableStore.new()
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

	p1.position = Vector2(888.0, p1.position.y)
	p2.position = Vector2(899.0, p2.position.y)
	p1.call("_update_facing")
	p1.set("attack_state", "")
	p1.set("skill_cooldowns", {})
	p1.call("_start_attack", "signature_a")
	p1.call("_update_attack", 0.09)
	p1.call("_update_skill_entities", 0.25)
	var wall_entities := p1.get("skill_entities") as Array
	var wall_bound_ok := wall_entities.is_empty()
	if not wall_entities.is_empty():
		var wall_entry := wall_entities[0] as Dictionary
		var wall_pos_value: Variant = wall_entry.get("position", Vector2.ZERO)
		if wall_pos_value is Vector2:
			wall_bound_ok = (wall_pos_value as Vector2).x <= 900.0
	_assert_true(wall_bound_ok, "skill entities respect stage wall bounds")

	p1.position = Vector2(890.0, p1.position.y)
	p2.position = Vector2(899.0, p2.position.y)
	p1.set("facing", 1)
	p1.call("_apply_mobility_effect", {"mode": "teleport", "distance": 240.0})
	_assert_true(p1.global_position.x <= 888.0 + 0.001, "teleport mobility clamps at right stage bound")
	p1.position = Vector2(10.0, p1.position.y)
	p2.position = Vector2(0.0, p2.position.y)
	p1.set("facing", -1)
	p1.call("_apply_mobility_effect", {"mode": "teleport", "distance": 240.0})
	_assert_true(p1.global_position.x >= 12.0 - 0.001, "teleport mobility clamps at left stage bound")

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

func _test_directional_attack_variants() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var p2 := setup.get("p2") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or p2 == null or host == null:
		return
	_assert_true(bool(p1.call("_has_attack_kind", "light_up")), "runtime attack data includes light_up variant")
	_assert_true(bool(p1.call("_has_attack_kind", "light_down")), "runtime attack data includes light_down variant")
	_assert_true(bool(p1.call("_has_attack_kind", "heavy_up")), "runtime attack data includes heavy_up variant")
	_assert_true(bool(p1.call("_has_attack_kind", "heavy_down")), "runtime attack data includes heavy_down variant")
	var grounded := p1.is_on_floor()
	var neutral_light_expected := "light" if grounded else "light_air"
	var up_light_expected := "light_up" if grounded else "light_air"
	var down_light_expected := "light_down" if grounded else "light_air"
	var up_heavy_expected := "heavy_up" if grounded else "heavy_air"
	var down_heavy_expected := "heavy_down" if grounded else "heavy_air"
	_assert_true(str(p1.call("_resolve_basic_attack_variant", "light")) == neutral_light_expected, "neutral light input resolves to expected variant")
	p1.set("up_input_buffer_time", 0.08)
	_assert_true(str(p1.call("_resolve_basic_attack_variant", "light")) == up_light_expected, "up input resolves light to expected variant")
	p1.set("up_input_buffer_time", 0.0)
	p1.set("down_input_buffer_time", 0.08)
	_assert_true(str(p1.call("_resolve_basic_attack_variant", "light")) == down_light_expected, "down input resolves light to expected variant")
	p1.set("down_input_buffer_time", 0.0)
	p1.set("up_input_buffer_time", 0.08)
	_assert_true(str(p1.call("_resolve_basic_attack_variant", "heavy")) == up_heavy_expected, "up input resolves heavy to expected variant")
	p1.set("up_input_buffer_time", 0.0)
	p1.set("down_input_buffer_time", 0.08)
	_assert_true(str(p1.call("_resolve_basic_attack_variant", "heavy")) == down_heavy_expected, "down input resolves heavy to expected variant")
	_assert_true(str(p2.call("_resolve_input_action", "move_left")) == "p2_move_left", "player2 resolves movement action through dedicated input channel")
	_assert_true(InputMap.has_action("p2_move_left"), "player2 dedicated input actions are registered")
	host.queue_free()
	await process_frame

func _test_local_dual_gamepad_input_actions() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var p2 := setup.get("p2") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or p2 == null or host == null:
		return
	_assert_true(str(p1.call("_resolve_input_action", "move_left")) == "p1_move_left", "player1 resolves movement action through dedicated local channel")
	_assert_true(str(p2.call("_resolve_input_action", "move_left")) == "p2_move_left", "player2 resolves movement action through dedicated local channel")
	_assert_true(InputMap.has_action("p1_move_left"), "player1 dedicated input actions are registered")
	_assert_true(InputMap.has_action("p2_move_left"), "player2 dedicated input actions are registered")
	var p1_device_id := int(p1.get("local_gamepad_device"))
	var p2_device_id := int(p2.get("local_gamepad_device"))
	var p1_device_mapped := false
	var p2_device_mapped := false
	for event in InputMap.action_get_events("p1_move_left"):
		if event is InputEventJoypadButton and (event as InputEventJoypadButton).device == p1_device_id:
			p1_device_mapped = true
		elif event is InputEventJoypadMotion and (event as InputEventJoypadMotion).device == p1_device_id:
			p1_device_mapped = true
	for event in InputMap.action_get_events("p2_move_left"):
		if event is InputEventJoypadButton and (event as InputEventJoypadButton).device == p2_device_id:
			p2_device_mapped = true
		elif event is InputEventJoypadMotion and (event as InputEventJoypadMotion).device == p2_device_id:
			p2_device_mapped = true
	_assert_true(p1_device_mapped, "player1 local channel binds resolved gamepad device")
	_assert_true(p2_device_mapped, "player2 local channel binds resolved gamepad device")
	host.queue_free()
	await process_frame

func _test_forward_tap_triggers_ground_dash() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or host == null:
		return
	p1.set("facing", 1)
	p1.set("is_dashing", false)
	p1.set("attack_state", "")
	p1.set("dash_cooldown_timer", 0.0)
	p1.set("hitstun_time", 0.0)
	p1.set("blockstun_time", 0.0)
	p1.set("is_knocked_down", false)
	p1.set("getup_time", 0.0)
	p1.set("shield_break_time", 0.0)
	p1.set("coyote_time", 0.08)
	p1.set("position", Vector2(200, 300))
	var floor := StaticBody2D.new()
	var floor_shape_node := CollisionShape2D.new()
	var floor_shape := RectangleShape2D.new()
	floor_shape.size = Vector2(900.0, 40.0)
	floor_shape_node.shape = floor_shape
	floor.add_child(floor_shape_node)
	floor.position = Vector2(450.0, 344.0)
	host.add_child(floor)
	await process_frame
	var forward_action := str(p1.call("_resolve_input_action", "move_right"))
	Input.action_press(forward_action, 1.0)
	p1.call("_process_player_input", 0.016)
	Input.action_release(forward_action)
	_assert_true(bool(p1.get("is_dashing")), "forward tap starts ground dash without dedicated dash button")
	host.queue_free()
	await process_frame

func _test_jump_leniency_and_fast_fall() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or host == null:
		return

	p1.set("velocity", Vector2(0.0, 64.0))
	p1.set("coyote_time", 0.08)
	p1.set("jump_buffer_time", 0.10)
	var coyote_jump_triggered := bool(p1.call("_try_consume_buffered_jump"))
	_assert_true(coyote_jump_triggered, "coyote jump window consumes buffered jump input")
	var coyote_velocity_value: Variant = p1.get("velocity")
	if coyote_velocity_value is Vector2:
		var coyote_velocity := coyote_velocity_value as Vector2
		_assert_true(coyote_velocity.y <= -300.0, "coyote jump applies upward launch velocity")
	_assert_true(float(p1.get("jump_buffer_time")) <= 0.0, "jump buffer clears after successful jump")
	_assert_true(float(p1.get("coyote_time")) <= 0.0, "coyote timer is consumed by jump")

	p1.set("is_ai", false)
	p1.set("velocity", Vector2(0.0, 120.0))
	p1.set("fast_fall_active", false)
	p1.set("down_input_buffer_time", 0.0)
	p1.call("_apply_air_gravity", 0.10)
	var normal_fall_velocity := (p1.get("velocity") as Vector2).y

	p1.set("velocity", Vector2(0.0, 120.0))
	p1.set("fast_fall_active", false)
	p1.set("down_input_buffer_time", 0.08)
	p1.call("_apply_air_gravity", 0.10)
	var fast_fall_velocity := (p1.get("velocity") as Vector2).y
	_assert_true(bool(p1.get("fast_fall_active")), "down input in descent enables fast-fall state")
	_assert_true(fast_fall_velocity > normal_fall_velocity + 30.0, "fast-fall increases downward velocity versus normal gravity")

	host.queue_free()
	await process_frame

func _test_short_hop_jump_cut() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or host == null:
		return

	p1.set("is_ai", false)
	p1.set("velocity", Vector2.ZERO)
	p1.set("coyote_time", 0.08)
	p1.set("jump_buffer_time", 0.10)
	var jump_started := bool(p1.call("_try_consume_buffered_jump"))
	_assert_true(jump_started, "jump cut test starts from successful buffered jump")
	_assert_true(bool(p1.get("jump_cut_available")), "successful jump enables jump-cut window")
	var before_cut := (p1.get("velocity") as Vector2).y
	p1.call("_apply_jump_cut")
	var after_cut := (p1.get("velocity") as Vector2).y
	_assert_true(after_cut > before_cut + 80.0, "releasing jump shortens ascent via jump-cut velocity")
	_assert_true(not bool(p1.get("jump_cut_available")), "jump-cut window is consumed after short-hop cut")

	host.queue_free()
	await process_frame

func _test_aerial_landing_lag_and_auto_cancel() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or host == null:
		return

	p1.set("attack_state", "heavy")
	p1.set("attack_phase", "active")
	p1.set("attack_time", 0.02)
	p1.set("attack_recovery_duration", 0.26)
	p1.set("attack_started_in_air", true)
	p1.set("fast_fall_active", true)
	p1.set("landing_lag_time", 0.0)
	p1.call("_on_landed_from_air")
	var fast_fall_lag := float(p1.get("landing_lag_time"))
	_assert_true(fast_fall_lag >= 0.12, "aerial landing lag adds fast-fall penalty when not auto-canceled")
	_assert_true(str(p1.get("attack_state")) == "", "landing during aerial attack clears attack state")

	p1.set("attack_state", "heavy")
	p1.set("attack_phase", "startup")
	p1.set("attack_time", 0.01)
	p1.set("attack_started_in_air", true)
	p1.set("fast_fall_active", false)
	p1.set("landing_lag_time", 0.0)
	p1.call("_on_landed_from_air")
	var startup_auto_cancel_lag := float(p1.get("landing_lag_time"))
	_assert_true(startup_auto_cancel_lag <= 0.04, "startup landing uses low auto-cancel lag")

	p1.set("attack_state", "heavy")
	p1.set("attack_phase", "recovery")
	p1.set("attack_recovery_duration", 0.26)
	p1.set("attack_time", 0.20)
	p1.set("attack_started_in_air", true)
	p1.set("fast_fall_active", false)
	p1.set("landing_lag_time", 0.0)
	p1.call("_on_landed_from_air")
	var late_recovery_auto_cancel_lag := float(p1.get("landing_lag_time"))
	_assert_true(late_recovery_auto_cancel_lag <= 0.04, "late recovery landing enters auto-cancel window")

	p1.set("attack_state", "heavy")
	p1.set("attack_phase", "recovery")
	p1.set("attack_recovery_duration", 0.26)
	p1.set("attack_time", 0.05)
	p1.set("attack_started_in_air", true)
	p1.set("fast_fall_active", false)
	p1.set("landing_lag_time", 0.0)
	p1.call("_on_landed_from_air")
	var early_recovery_lag := float(p1.get("landing_lag_time"))
	_assert_true(early_recovery_lag > late_recovery_auto_cancel_lag + 0.06, "early recovery landing keeps full landing lag")

	p1.set("attack_state", "")
	p1.set("is_dashing", false)
	p1.set("is_knocked_down", false)
	p1.set("getup_time", 0.0)
	p1.set("hitstun_time", 0.0)
	p1.set("blockstun_time", 0.0)
	p1.set("landing_lag_time", 0.03)
	_assert_true(not bool(p1.call("_can_start_attack")), "landing lag blocks immediate grounded attack")
	p1.set("landing_lag_time", 0.0)
	_assert_true(bool(p1.call("_can_start_attack")), "attack can start again when landing lag expires")

	host.queue_free()
	await process_frame

func _test_shield_resource_and_break_flow() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or host == null:
		return

	p1.set("shield_meter", 4.0)
	p1.set("is_blocking", true)
	p1.call("_apply_block_impact", 20, Vector2(120.0, 0.0), 0.12, "heavy", {"blockstun": 0.12})
	_assert_true(float(p1.get("shield_break_time")) > 0.80, "shield depletes into shield-break stun")
	_assert_true(not bool(p1.get("is_blocking")), "shield break exits block state")
	_assert_true(not bool(p1.call("_can_enter_block")), "shield break prevents immediate blocking")

	p1.call("_physics_process", 1.20)
	_assert_true(float(p1.get("shield_break_time")) <= 0.0, "shield break stun expires after duration")
	_assert_true(float(p1.get("shield_meter")) >= 30.0, "shield break restores minimum shield resource on recovery")

	p1.set("is_blocking", false)
	p1.set("shield_regen_delay", 0.0)
	p1.set("shield_meter", 50.0)
	p1.call("_update_shield_state", 0.50)
	_assert_true(float(p1.get("shield_meter")) > 50.0, "shield regenerates while idle")

	p1.set("shield_meter", 80.0)
	p1.set("shield_break_time", 0.0)
	p1.set("shield_broken", false)
	p1.set("is_blocking", true)
	p1.call("_update_shield_state", 0.50)
	_assert_true(float(p1.get("shield_meter")) < 80.0, "holding block drains shield over time")

	host.queue_free()
	await process_frame

func _test_duel_ruleset_defense_profile() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or host == null:
		return

	p1.call("set_ruleset_profile", "duel")
	_assert_true(int(p1.get("air_jumps_remaining")) == 0, "duel ruleset removes extra air jump resource")
	p1.set("air_dodge_available", true)
	_assert_true(bool(p1.call("_start_air_dodge", 1.0, 0.0)), "duel ruleset keeps a trimmed air dodge escape")
	_assert_true(float(p1.get("dodge_time")) <= 0.18, "duel air dodge stays shorter than platform air dodge")
	p1.call("_end_dodge_state")
	_assert_true(float(p1.get("air_dodge_end_lag_time")) >= 0.24, "duel air dodge pays heavier recovery")

	p1.set("shield_meter", 80.0)
	p1.set("shield_break_time", 0.0)
	p1.set("shield_broken", false)
	p1.set("is_blocking", true)
	p1.call("_update_shield_state", 0.50)
	_assert_true(float(p1.get("shield_meter")) < 80.0, "duel ruleset still drains shield while holding guard")

	p1.set("is_blocking", false)
	p1.set("shield_meter", 1.0)
	_assert_true(not bool(p1.call("_can_enter_block")), "duel ruleset still requires shield resource to block")

	p1.set("shield_meter", 40.0)
	p1.call("_start_roll_dodge", -1)
	_assert_true(str(p1.get("dodge_state")) == "roll", "duel ruleset keeps a grounded dodge option")
	_assert_true(float(p1.get("dodge_time")) <= 0.20, "duel grounded dodge stays shorter than platform dodge")
	var base_knockback := Vector2(180.0, -110.0)
	var adjusted_knockback: Variant = p1.call("_apply_directional_influence", base_knockback, {"di_override": Vector2(-1.0, -0.35)})
	if adjusted_knockback is Vector2:
		var duel_di := adjusted_knockback as Vector2
		_assert_true(duel_di.distance_to(base_knockback) > 0.1, "duel ruleset keeps directional influence trajectory control")
		_assert_true(duel_di.length() < base_knockback.length(), "duel directional influence still supports survival routing")

	host.queue_free()
	await process_frame

func _test_defensive_dodge_layer() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or host == null:
		return

	p1.set("current_hp", 100)
	p1.call("_start_spot_dodge")
	_assert_true(str(p1.get("dodge_state")) == "spot", "spot dodge enters dodge state")
	_assert_true(float(p1.get("dodge_time")) > 0.0, "spot dodge sets active dodge timer")
	var spot_result: Variant = p1.call("apply_damage", 12, Vector2(120.0, 0.0), 0.12, "light", {})
	if typeof(spot_result) == TYPE_DICTIONARY:
		_assert_true(bool((spot_result as Dictionary).get("ignored", false)), "spot dodge invulnerability ignores incoming hit")

	p1.call("_start_roll_dodge", -1)
	_assert_true(str(p1.get("dodge_state")) == "roll", "roll dodge enters roll state")
	var roll_velocity_value: Variant = p1.get("velocity")
	if roll_velocity_value is Vector2:
		_assert_true((roll_velocity_value as Vector2).x < -10.0, "roll dodge moves in requested direction")

	p1.set("air_dodge_available", true)
	var air_dodge_started := bool(p1.call("_start_air_dodge", 1.0, 0.0))
	_assert_true(air_dodge_started, "air dodge starts when resource is available")
	_assert_true(not bool(p1.get("air_dodge_available")), "air dodge consumes airtime dodge resource")
	var second_air_dodge := bool(p1.call("_start_air_dodge", 1.0, 0.0))
	_assert_true(not second_air_dodge, "air dodge cannot be started twice before refresh")

	p1.set("dodge_time", 0.12)
	_assert_true(not bool(p1.call("_can_start_attack")), "active dodge prevents attack startup")

	host.queue_free()
	await process_frame

func _test_double_jump_and_ledge_getup_options() -> void:
	var setup: Dictionary = await _spawn_test_players()
	var p1 := setup.get("p1") as CharacterBody2D
	var host := setup.get("host") as Node2D
	if p1 == null or host == null:
		return

	p1.set("air_jumps_remaining", 1)
	p1.set("coyote_time", 0.0)
	p1.set("jump_buffer_time", 0.10)
	p1.set("velocity", Vector2.ZERO)
	var first_air_jump := bool(p1.call("_try_consume_buffered_jump"))
	_assert_true(first_air_jump, "air jump can be consumed when coyote is unavailable")
	_assert_true(int(p1.get("air_jumps_remaining")) == 0, "air jump use decrements remaining jump resource")
	p1.set("jump_buffer_time", 0.10)
	var second_air_jump := bool(p1.call("_try_consume_buffered_jump"))
	_assert_true(not second_air_jump, "air jump cannot be used again when resource is exhausted")

	p1.set("stage_left_x", 0.0)
	p1.set("stage_right_x", 900.0)
	p1.set("stage_floor_y", 340.0)
	p1.call("_start_ledge_hang", 1)
	_assert_true(bool(p1.get("is_ledge_hanging")), "ledge getup test enters ledge hang state")
	p1.call("_roll_getup_from_ledge")
	_assert_true(not bool(p1.get("is_ledge_hanging")), "ledge roll getup exits ledge hang")
	_assert_true(str(p1.get("dodge_state")) == "roll", "ledge roll getup transitions into roll dodge state")

	p1.call("_start_ledge_hang", -1)
	p1.set("attack_state", "")
	p1.call("_attack_getup_from_ledge")
	_assert_true(not bool(p1.get("is_ledge_hanging")), "ledge attack getup exits ledge hang")
	_assert_true(str(p1.get("attack_state")) == "light", "ledge attack getup starts grounded attack")

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

func _reset_throw_tech_target_state(player: CharacterBody2D) -> void:
	if player == null:
		return
	player.set("current_hp", 100)
	player.set("hitstun_time", 0.0)
	player.set("blockstun_time", 0.0)
	player.set("is_knocked_down", false)
	player.set("knockdown_time", 0.0)
	player.set("getup_time", 0.0)
	player.set("wake_invuln_time", 0.0)
	player.set("velocity", Vector2.ZERO)
	player.call("_clear_throw_tech_buffer")

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

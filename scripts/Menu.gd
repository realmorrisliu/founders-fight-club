extends Control

const GameSettingsStore := preload("res://scripts/GameSettings.gd")
const LocalizationRegistryStore := preload("res://scripts/config/LocalizationRegistry.gd")
const CharacterCatalogStore := preload("res://scripts/config/CharacterCatalog.gd")
const LoadoutCatalogStore := preload("res://scripts/config/LoadoutCatalog.gd")
const SessionKeysStore := preload("res://scripts/config/SessionKeys.gd")
const SessionStateStore := preload("res://scripts/SessionState.gd")
const LoadoutResolverStore := preload("res://scripts/loadout/LoadoutResolver.gd")
const LoadoutValidatorStore := preload("res://scripts/loadout/LoadoutValidator.gd")
const VS_SCENE_PATH := "res://scenes/Main.tscn"
const STORY_SCENE_PATH := "res://scenes/Story.tscn"
const TRAINING_SCENE_PATH := "res://scenes/Training.tscn"
const MENU_METRICS_LOG_PATH := "user://menu_metrics.jsonl"
const MENU_METRICS_SCHEMA_VERSION := 1
const WINDOW_MODE_OPTIONS := [
	GameSettingsStore.WINDOW_MODE_WINDOWED,
	GameSettingsStore.WINDOW_MODE_MAXIMIZED,
	GameSettingsStore.WINDOW_MODE_FULLSCREEN,
	GameSettingsStore.WINDOW_MODE_BORDERLESS
]
const RESOLUTION_OPTIONS := GameSettingsStore.RESOLUTION_OPTIONS
const ARCHETYPE_BY_CHARACTER_ID := {
	"elon_mvsk": "zoner",
	"mark_zuck": "counter",
	"sam_altmyn": "all_rounder",
	"peter_thyell": "zoner",
	"zef_bezos": "bruiser",
	"bill_geytz": "zoner",
	"sundar_pichoy": "all_rounder",
	"jensen_hwang": "bruiser",
	"larry_pagyr": "zoner",
	"sergey_brinn": "rushdown",
	"satya_nadello": "counter",
	"tim_cuke": "all_rounder",
	"jack_dorsee": "rushdown",
	"travis_kalanik": "rushdown",
	"reed_hestings": "counter",
	"steve_jobz": "bruiser",
	"prototype_p1": "all_rounder",
	"prototype_p2": "all_rounder",
	"prototype": "all_rounder"
}

var character_options: Array[Dictionary] = CharacterCatalogStore.get_selectable_roster()
var current_control_preset := GameSettingsStore.CONTROL_PRESET_MODERN
var current_window_mode := GameSettingsStore.WINDOW_MODE_WINDOWED
var current_resolution := GameSettingsStore.DEFAULT_RESOLUTION
var main_menu_interactive := true
var character_profile_cache: Array[Dictionary] = []
var is_refreshing_video_options := false
var is_refreshing_loadout_options := false
var p1_loadout_presets: Array[Dictionary] = []
var p2_loadout_presets: Array[Dictionary] = []
var current_p1_loadout: Dictionary = {}
var current_p2_loadout: Dictionary = {}
var current_p1_preset_id := ""
var current_p2_preset_id := ""
var advanced_setup_expanded := false

@onready var title_label := $CenterPanel/TitleLabel
@onready var subtitle_label := $CenterPanel/SubtitleLabel
@onready var quick_start_label := $CenterPanel/QuickStartLabel
@onready var p1_character_label := $CenterPanel/P1CharacterLabel
@onready var p2_character_label := $CenterPanel/P2CharacterLabel
@onready var p1_character_option := $CenterPanel/P1CharacterOption
@onready var p2_character_option := $CenterPanel/P2CharacterOption
@onready var p1_loadout_label := $CenterPanel/P1LoadoutLabel
@onready var p1_loadout_option := $CenterPanel/P1LoadoutOption
@onready var p2_loadout_option := $CenterPanel/P2LoadoutOption
@onready var p1_profile_label := $CenterPanel/P1ProfileLabel
@onready var p2_profile_label := $CenterPanel/P2ProfileLabel
@onready var mode_step_label := $CenterPanel/ModeStepLabel
@onready var versus_button := $CenterPanel/VersusButton
@onready var story_button := $CenterPanel/StoryButton
@onready var training_button := $CenterPanel/TrainingButton
@onready var guided_start_button := $CenterPanel/GuidedStartButton
@onready var control_style_label := $CenterPanel/ControlStyleLabel
@onready var control_style_button := $CenterPanel/ControlStyleButton
@onready var video_settings_label := $CenterPanel/VideoSettingsLabel
@onready var window_mode_label := $CenterPanel/WindowModeLabel
@onready var window_mode_option := $CenterPanel/WindowModeOption
@onready var resolution_label := $CenterPanel/ResolutionLabel
@onready var resolution_option := $CenterPanel/ResolutionOption
@onready var lang_label := $CenterPanel/LanguageLabel
@onready var lang_en_button := $CenterPanel/LangEnButton
@onready var lang_zh_button := $CenterPanel/LangZhButton
@onready var advanced_toggle_button := $AdvancedToggleButton
@onready var advanced_hint_label := $AdvancedHintLabel
@onready var p1_summary_title_label := $P1SummaryPanel/TitleLabel
@onready var p1_summary_body_label := $P1SummaryPanel/BodyLabel
@onready var p2_summary_title_label := $P2SummaryPanel/TitleLabel
@onready var p2_summary_body_label := $P2SummaryPanel/BodyLabel
@onready var first_launch_overlay := $FirstLaunchControlOverlay
@onready var first_launch_title_label := $FirstLaunchControlOverlay/Panel/TitleLabel
@onready var first_launch_hint_label := $FirstLaunchControlOverlay/Panel/HintLabel
@onready var first_launch_classic_button := $FirstLaunchControlOverlay/Panel/ClassicButton
@onready var first_launch_modern_button := $FirstLaunchControlOverlay/Panel/ModernButton

func _ready() -> void:
	_ensure_translations_registered()
	var locale := TranslationServer.get_locale()
	if not locale.begins_with("en") and not locale.begins_with("zh"):
		TranslationServer.set_locale("en")
	versus_button.pressed.connect(_on_versus_pressed)
	story_button.pressed.connect(_on_story_pressed)
	training_button.pressed.connect(_on_training_pressed)
	guided_start_button.pressed.connect(_on_guided_start_pressed)
	control_style_button.pressed.connect(_on_control_style_button_pressed)
	advanced_toggle_button.pressed.connect(_on_advanced_toggle_pressed)
	lang_en_button.pressed.connect(func(): _set_locale("en"))
	lang_zh_button.pressed.connect(func(): _set_locale("zh"))
	window_mode_option.item_selected.connect(_on_window_mode_option_selected)
	resolution_option.item_selected.connect(_on_resolution_option_selected)
	p1_character_option.item_selected.connect(_on_p1_character_option_selected)
	p2_character_option.item_selected.connect(_on_p2_character_option_selected)
	p1_loadout_option.item_selected.connect(_on_p1_loadout_option_selected)
	p2_loadout_option.item_selected.connect(_on_p2_loadout_option_selected)
	first_launch_classic_button.pressed.connect(func(): _on_first_launch_preset_selected(GameSettingsStore.CONTROL_PRESET_CLASSIC))
	first_launch_modern_button.pressed.connect(func(): _on_first_launch_preset_selected(GameSettingsStore.CONTROL_PRESET_MODERN))
	_populate_character_options()
	_initialize_loadout_presets()
	_initialize_control_preset()
	_initialize_advanced_setup_state()
	_initialize_video_settings()
	_refresh_text()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh_text()

func _on_versus_pressed() -> void:
	_clear_onboarding_replay_session_flags()
	_store_character_selection("vs")
	SessionStateStore.set_value(SessionKeysStore.ONBOARDING_ENTRY_POINT, "vs")
	_append_menu_metrics_log("enter_vs")
	get_tree().change_scene_to_file(VS_SCENE_PATH)

func _on_story_pressed() -> void:
	_clear_onboarding_replay_session_flags()
	_store_character_selection("story")
	SessionStateStore.set_value(SessionKeysStore.ONBOARDING_ENTRY_POINT, "story")
	_append_menu_metrics_log("enter_story")
	get_tree().change_scene_to_file(STORY_SCENE_PATH)

func _on_training_pressed() -> void:
	_clear_onboarding_replay_session_flags()
	_store_character_selection("training")
	SessionStateStore.set_value(SessionKeysStore.ONBOARDING_ENTRY_POINT, "training")
	_append_menu_metrics_log("enter_training")
	get_tree().change_scene_to_file(TRAINING_SCENE_PATH)

func _on_guided_start_pressed() -> void:
	_store_character_selection("training")
	SessionStateStore.set_value(SessionKeysStore.ONBOARDING_FORCE_REPLAY, true)
	SessionStateStore.set_value(SessionKeysStore.ONBOARDING_ENTRY_POINT, "guided_start")
	_append_menu_metrics_log("enter_guided_start")
	get_tree().change_scene_to_file(TRAINING_SCENE_PATH)

func _set_locale(locale: String) -> void:
	if TranslationServer.get_locale().begins_with(locale):
		return
	TranslationServer.set_locale(locale)
	_refresh_text()

func _refresh_text() -> void:
	var onboarding_completed := _has_completed_onboarding()
	title_label.text = tr("MENU_TITLE")
	if advanced_setup_expanded:
		subtitle_label.text = _resolve_menu_text(
			"MENU_SUBTITLE_ADVANCED",
			"Advanced setup open: rival, controls, video, and language are editable."
		)
	else:
		subtitle_label.text = _resolve_menu_text(
			"MENU_SUBTITLE_SIMPLE",
			"Start here: pick your fighter, then choose Guided Start, Story, VS, or Training."
		)
	quick_start_label.text = _resolve_menu_text(
		"MENU_QUICK_START_LABEL",
		"Recommended First Run"
	)
	p1_character_label.text = _resolve_menu_text("MENU_P1_CHARACTER", "P1 Character")
	p2_character_label.text = _resolve_menu_text("MENU_P2_CHARACTER_VS_ONLY", "Opponent Character (VS/Training)")
	p1_loadout_label.text = _resolve_menu_text("MENU_LOADOUT_LABEL", "Build Preset")
	p1_profile_label.text = _resolve_menu_text("MENU_PROFILE_LOADING", "Loading profile...")
	p2_profile_label.text = _resolve_menu_text("MENU_PROFILE_LOADING", "Loading profile...")
	mode_step_label.text = _resolve_menu_text("MENU_MODE_STEP_LABEL", "Then Choose a Mode")
	guided_start_button.text = _resolve_menu_text(
		"MENU_GUIDED_START_PRIMARY" if not onboarding_completed else "MENU_GUIDED_START",
		"Guided Start (Recommended)" if not onboarding_completed else "Guided Start (Training)"
	)
	versus_button.text = tr("MENU_VERSUS")
	story_button.text = _resolve_menu_text("MENU_STORY_AUTO_RIVAL_BUTTON", "Story (Auto Rival)")
	training_button.text = tr("MENU_TRAINING")
	control_style_label.text = tr("MENU_CONTROL_STYLE")
	control_style_button.text = _resolve_control_preset_label(current_control_preset)
	video_settings_label.text = _resolve_menu_text("MENU_VIDEO_SETTINGS", "Video")
	window_mode_label.text = _resolve_menu_text("MENU_WINDOW_MODE", "Window Mode")
	resolution_label.text = _resolve_menu_text("MENU_RESOLUTION", "Resolution")
	_refresh_video_options()
	_refresh_loadout_options()
	_refresh_mode_hint_tooltips()
	lang_label.text = tr("PAUSE_LANGUAGE")
	lang_en_button.text = tr("PAUSE_LANG_EN")
	lang_zh_button.text = tr("PAUSE_LANG_ZH")
	advanced_hint_label.text = _resolve_menu_text(
		"MENU_ADVANCED_INLINE_HINT",
		"Rival / controls / video / language"
	)
	first_launch_title_label.text = tr("MENU_FIRST_LAUNCH_CONTROL_TITLE")
	first_launch_hint_label.text = tr("MENU_FIRST_LAUNCH_CONTROL_HINT")
	first_launch_classic_button.text = tr("MENU_CONTROL_STYLE_CLASSIC")
	first_launch_modern_button.text = tr("MENU_CONTROL_STYLE_MODERN")
	advanced_toggle_button.text = _resolve_menu_text(
		"MENU_ADVANCED_HIDE" if advanced_setup_expanded else "MENU_ADVANCED_SHOW",
		"Hide Advanced Setup" if advanced_setup_expanded else "Show Advanced Setup"
	)
	var locale := TranslationServer.get_locale()
	lang_en_button.disabled = not main_menu_interactive or locale.begins_with("en")
	lang_zh_button.disabled = not main_menu_interactive or locale.begins_with("zh")
	versus_button.disabled = not main_menu_interactive
	story_button.disabled = not main_menu_interactive
	training_button.disabled = not main_menu_interactive
	guided_start_button.disabled = not main_menu_interactive
	control_style_button.disabled = not main_menu_interactive
	window_mode_option.disabled = not main_menu_interactive
	resolution_option.disabled = not main_menu_interactive or not _is_resolution_editable(current_window_mode)
	p1_character_option.disabled = not main_menu_interactive
	p2_character_option.disabled = not main_menu_interactive
	p1_loadout_option.disabled = not main_menu_interactive
	p2_loadout_option.disabled = not main_menu_interactive
	advanced_toggle_button.disabled = not main_menu_interactive
	_refresh_advanced_setup_visibility()
	_refresh_character_profile_preview()

func _ensure_translations_registered() -> void:
	LocalizationRegistryStore.ensure_registered()

func _populate_character_options() -> void:
	p1_character_option.clear()
	p2_character_option.clear()
	character_profile_cache.clear()
	for character in character_options:
		var label := str(character.get("name", "Unknown"))
		p1_character_option.add_item(label)
		p2_character_option.add_item(label)
		character_profile_cache.append(_build_character_profile(character))
	if p1_character_option.item_count > 0:
		p1_character_option.select(0)
	if p2_character_option.item_count > 1:
		p2_character_option.select(1)
	elif p2_character_option.item_count > 0:
		p2_character_option.select(0)
	_refresh_character_profile_preview()

func _initialize_loadout_presets() -> void:
	_refresh_loadout_options()
	var p1_character_id := _get_selected_character_id("p1")
	var p2_character_id := _get_selected_character_id("p2")
	if p1_character_id != "":
		current_p1_loadout = LoadoutCatalogStore.get_default_loadout(p1_character_id)
	if p2_character_id != "":
		current_p2_loadout = LoadoutCatalogStore.get_default_loadout(p2_character_id)

func _build_character_profile(character: Dictionary) -> Dictionary:
	var character_id := str(character.get("id", "")).strip_edges()
	var display_name := str(character.get("name", "Unknown")).strip_edges()
	var attack_table_path := str(character.get("attack_table_path", "")).strip_edges()
	var profile := {
		"character_id": character_id,
		"display_name": display_name,
		"archetype_key": str(ARCHETYPE_BY_CHARACTER_ID.get(character_id, "all_rounder")),
		"archetype_hint_key": _resolve_archetype_hint_key(str(ARCHETYPE_BY_CHARACTER_ID.get(character_id, "all_rounder"))),
		"signature_primary": "Signature A",
		"signature_alt": "Signature B",
		"signature_c": "Down Special",
		"ultimate": "Ultimate"
	}
	if attack_table_path == "" or not ResourceLoader.exists(attack_table_path):
		return profile
	var resource := load(attack_table_path) as Resource
	if resource == null:
		return profile
	var attacks: Dictionary = {}
	if resource.has_method("get_runtime_attacks"):
		var attacks_value: Variant = resource.call("get_runtime_attacks")
		if typeof(attacks_value) == TYPE_DICTIONARY:
			attacks = (attacks_value as Dictionary).duplicate(true)
	else:
		var raw_attacks: Variant = resource.get("attacks")
		if typeof(raw_attacks) == TYPE_DICTIONARY:
			attacks = (raw_attacks as Dictionary).duplicate(true)
	if attacks.has("special"):
		var special_value: Variant = attacks.get("special", {})
		if typeof(special_value) == TYPE_DICTIONARY:
			var special := special_value as Dictionary
			var primary := str(special.get("signature_primary", "")).strip_edges()
			var alt := str(special.get("signature_alt", "")).strip_edges()
			if primary != "":
				profile["signature_primary"] = primary
			if alt != "":
				profile["signature_alt"] = alt
	profile["signature_c"] = _resolve_attack_display_name(attacks, "signature_c", "signature_mix", "Down Special", resource)
	profile["ultimate"] = _resolve_attack_display_name(attacks, "ultimate", "signature_ultimate", "Ultimate", resource)
	return profile

func _resolve_attack_display_name(
	attacks: Dictionary,
	attack_key: String,
	meta_key: String,
	fallback: String,
	resource: Resource
) -> String:
	var attack_value: Variant = attacks.get(attack_key, {})
	if typeof(attack_value) == TYPE_DICTIONARY:
		var attack_data := attack_value as Dictionary
		var explicit_name := str(attack_data.get("display_name", "")).strip_edges()
		if explicit_name != "":
			return explicit_name
	var special_value: Variant = attacks.get("special", {})
	if typeof(special_value) == TYPE_DICTIONARY:
		var special := special_value as Dictionary
		var special_name := str(special.get(meta_key, "")).strip_edges()
		if special_name != "":
			return special_name
	if resource != null:
		var meta_value: Variant = resource.get(meta_key)
		if typeof(meta_value) == TYPE_STRING or typeof(meta_value) == TYPE_STRING_NAME:
			var direct_name := str(meta_value).strip_edges()
			if direct_name != "":
				return direct_name
	return fallback

func _refresh_character_profile_preview() -> void:
	if p1_profile_label == null or p2_profile_label == null:
		return
	p1_profile_label.text = _build_profile_preview_text(p1_character_option.selected, "p1")
	p2_profile_label.text = _build_profile_preview_text(p2_character_option.selected, "p2")
	p1_profile_label.tooltip_text = _build_profile_hint_text(p1_character_option.selected)
	p2_profile_label.tooltip_text = _build_profile_hint_text(p2_character_option.selected)
	_refresh_summary_panels()

func _build_profile_preview_text(index: int, player_key: String) -> String:
	if index < 0 or index >= character_profile_cache.size():
		return "-"
	var profile := character_profile_cache[index]
	var archetype_key := str(profile.get("archetype_key", "all_rounder"))
	var archetype_label := _resolve_archetype_label(archetype_key)
	var signature_primary := str(profile.get("signature_primary", "Signature A"))
	var signature_alt := str(profile.get("signature_alt", "Signature B"))
	var row_template := tr("MENU_PROFILE_ROW")
	if row_template.find("%") == -1:
		row_template = "%s | %s / %s"
	var base_text := row_template % [archetype_label, signature_primary, signature_alt]
	var loadout_brief := _build_profile_loadout_brief(player_key, str(profile.get("character_id", "")))
	if loadout_brief == "":
		return base_text
	return "%s | %s" % [base_text, loadout_brief]

func _build_profile_hint_text(index: int) -> String:
	if index < 0 or index >= character_profile_cache.size():
		return ""
	var profile := character_profile_cache[index]
	return tr(str(profile.get("archetype_hint_key", "ARCHETYPE_HINT_ALL_ROUNDER")))

func _build_profile_loadout_brief(player_key: String, character_id: String) -> String:
	if character_id == "":
		return ""
	var current_loadout := _resolve_current_loadout_for_player(player_key, character_id)
	var resolved := LoadoutResolverStore.resolve_character_loadout(character_id, current_loadout)
	var summary := resolved.get("summary", {}) as Dictionary
	var total_cost := int(summary.get("total_cost", 0))
	var budget_cap := int(summary.get("budget_cap", LoadoutCatalogStore.get_budget_cap()))
	var cost_label := _resolve_menu_text("MENU_LOADOUT_INLINE_COST_LABEL", "Loadout")
	var text := "%s %d/%d" % [cost_label, total_cost, budget_cap]
	if bool(resolved.get("used_fallback", false)):
		var fallback_inline := _resolve_menu_text("MENU_LOADOUT_FALLBACK_INLINE", "Default Applied")
		return "%s (%s)" % [text, fallback_inline]
	return text

func _refresh_summary_panels() -> void:
	if p1_summary_title_label == null or p1_summary_body_label == null:
		return
	if p2_summary_title_label == null or p2_summary_body_label == null:
		return
	p1_summary_title_label.text = _build_summary_panel_title("p1")
	p1_summary_body_label.text = _build_summary_panel_body("p1")
	p2_summary_title_label.text = _build_summary_panel_title("p2")
	p2_summary_body_label.text = _build_summary_panel_body("p2")

func _build_summary_panel_title(player_key: String) -> String:
	if player_key == "p2" and not advanced_setup_expanded:
		return _resolve_menu_text("MENU_SUMMARY_ROUTE_TITLE", "Start Paths")
	var profile := _resolve_profile_for_player(player_key)
	return str(profile.get("display_name", "Player")).strip_edges()

func _build_summary_panel_body(player_key: String) -> String:
	if player_key == "p2" and not advanced_setup_expanded:
		return _build_route_summary_body()
	var profile := _resolve_profile_for_player(player_key)
	var character_id := str(profile.get("character_id", "")).strip_edges()
	if character_id == "":
		return "-"
	var loadout := _resolve_current_loadout_for_player(player_key, character_id)
	var resolved := LoadoutResolverStore.resolve_character_loadout(character_id, loadout)
	var summary := resolved.get("summary", {}) as Dictionary
	var lines: Array[String] = []
	lines.append(
		"%s: %s" % [
			_resolve_menu_text("MENU_SUMMARY_ARCHETYPE", "Archetype"),
			_resolve_archetype_label(str(profile.get("archetype_key", "all_rounder")))
		]
	)
	var preset_name := _resolve_selected_preset_name(player_key)
	if preset_name != "":
		lines.append("%s: %s" % [_resolve_menu_text("MENU_SUMMARY_PRESET", "Preset"), preset_name])
	lines.append("%s: %s" % [_resolve_menu_text("MENU_SUMMARY_SLOT_A", "A"), str(summary.get("signature_a", profile.get("signature_primary", "Signature A")))])
	lines.append("%s: %s" % [_resolve_menu_text("MENU_SUMMARY_SLOT_B", "B"), str(summary.get("signature_b", profile.get("signature_alt", "Signature B")))])
	lines.append(
		"%s: %s" % [
			_resolve_menu_text("MENU_SUMMARY_FIXED_DOWN_SPECIAL", "Fixed DS"),
			str(profile.get("signature_c", "Down Special"))
		]
	)
	lines.append("%s: %s" % [_resolve_menu_text("MENU_SUMMARY_SLOT_U", "U"), str(summary.get("ultimate", profile.get("ultimate", "Ultimate")))])
	lines.append("%s: %s" % [_resolve_menu_text("MENU_SUMMARY_ITEM", "Item"), str(summary.get("item", "Item"))])
	lines.append("%s: %s" % [_resolve_menu_text("MENU_SUMMARY_PASSIVE", "Passive"), str(summary.get("passive", "Passive"))])
	var status_text := _resolve_menu_text("MENU_SUMMARY_STATUS_READY", "Ready")
	if bool(summary.get("used_fallback", false)):
		status_text = _resolve_menu_text("MENU_SUMMARY_STATUS_FALLBACK", "Fallback Applied")
	lines.append(
		"%s: %d/%d | %s" % [
			_resolve_menu_text("MENU_SUMMARY_BUDGET", "Budget"),
			int(summary.get("total_cost", 0)),
			int(summary.get("budget_cap", LoadoutCatalogStore.get_budget_cap())),
			status_text
		]
	)
	if player_key == "p2":
		lines.append(_resolve_menu_text("MENU_SUMMARY_STORY_NOTE", "Story auto-rivals override manual opponent setup. This preview applies to VS and Training."))
	return "\n".join(lines)

func _build_route_summary_body() -> String:
	var lines: Array[String] = []
	lines.append(
		"%s: %s" % [
			_resolve_menu_text("MENU_SUMMARY_ROUTE_GUIDED", "Guided"),
			_resolve_menu_text(
				"MENU_SUMMARY_ROUTE_GUIDED_HINT",
				"Best first run. Replays move, jump, guard, dodge, and special."
			)
		]
	)
	lines.append(
		"%s: %s" % [
			_resolve_menu_text("MENU_SUMMARY_ROUTE_STORY", "Story"),
			_resolve_menu_text(
				"MENU_SUMMARY_ROUTE_STORY_HINT",
				"Solo ladder with automatic rivals."
			)
		]
	)
	lines.append(
		"%s: %s" % [
			_resolve_menu_text("MENU_SUMMARY_ROUTE_VS", "VS"),
			_resolve_menu_text(
				"MENU_SUMMARY_ROUTE_VS_HINT",
				"Two local fighters on one screen."
			)
		]
	)
	lines.append(
		"%s: %s" % [
			_resolve_menu_text("MENU_SUMMARY_ROUTE_TRAINING", "Training"),
			_resolve_menu_text(
				"MENU_SUMMARY_ROUTE_TRAINING_HINT",
				"Sandbox for drills, dummy logic, and timing."
			)
		]
	)
	return "\n".join(lines)

func _resolve_profile_for_player(player_key: String) -> Dictionary:
	var index := 0
	if player_key == "p1":
		index = p1_character_option.selected
	else:
		index = p2_character_option.selected
	if index < 0 or index >= character_profile_cache.size():
		return {}
	return (character_profile_cache[index] as Dictionary).duplicate(true)

func _resolve_selected_preset_name(player_key: String) -> String:
	var presets := p1_loadout_presets if player_key == "p1" else p2_loadout_presets
	var selected_id := current_p1_preset_id if player_key == "p1" else current_p2_preset_id
	for preset in presets:
		var entry := preset as Dictionary
		if str(entry.get("id", "")) != selected_id:
			continue
		var key := str(entry.get("display_name_key", "")).strip_edges()
		var fallback := str(entry.get("display_name_fallback", "Preset")).strip_edges()
		if key != "":
			return _resolve_menu_text(key, fallback)
		return fallback
	return ""

func _resolve_archetype_label(archetype_key: String) -> String:
	match archetype_key:
		"rushdown":
			return _resolve_menu_text("ARCHETYPE_RUSHDOWN", "Rushdown")
		"zoner":
			return _resolve_menu_text("ARCHETYPE_ZONER", "Zoner")
		"bruiser":
			return _resolve_menu_text("ARCHETYPE_BRUISER", "Bruiser")
		"counter":
			return _resolve_menu_text("ARCHETYPE_COUNTER", "Counter")
		_:
			return _resolve_menu_text("ARCHETYPE_ALL_ROUNDER", "All-rounder")

func _resolve_archetype_hint_key(archetype_key: String) -> String:
	match archetype_key:
		"rushdown":
			return "ARCHETYPE_HINT_RUSHDOWN"
		"zoner":
			return "ARCHETYPE_HINT_ZONER"
		"bruiser":
			return "ARCHETYPE_HINT_BRUISER"
		"counter":
			return "ARCHETYPE_HINT_COUNTER"
		_:
			return "ARCHETYPE_HINT_ALL_ROUNDER"

func _store_character_selection(match_mode: String) -> void:
	if character_options.is_empty():
		return
	var p1_index := clampi(p1_character_option.selected, 0, character_options.size() - 1)
	var p2_index := clampi(p2_character_option.selected, 0, character_options.size() - 1)
	var p1_character: Dictionary = character_options[p1_index]
	var p2_character: Dictionary = character_options[p2_index]
	SessionStateStore.set_value(SessionKeysStore.MATCH_MODE, match_mode)
	SessionStateStore.set_value(SessionKeysStore.PLAYER_1_ID, str(p1_character.get("id", "")))
	SessionStateStore.set_value(SessionKeysStore.PLAYER_2_ID, str(p2_character.get("id", "")))
	SessionStateStore.set_value(SessionKeysStore.PLAYER_1_TABLE_PATH, str(p1_character.get("attack_table_path", "")))
	SessionStateStore.set_value(SessionKeysStore.PLAYER_2_TABLE_PATH, str(p2_character.get("attack_table_path", "")))
	SessionStateStore.set_value(SessionKeysStore.PLAYER_1_NAME, str(p1_character.get("name", "Player 1")))
	SessionStateStore.set_value(SessionKeysStore.PLAYER_2_NAME, str(p2_character.get("name", "Player 2")))
	var p1_character_id := str(p1_character.get("id", ""))
	var p2_character_id := str(p2_character.get("id", ""))
	var p1_loadout := _resolve_selected_loadout("p1", p1_character_id)
	var p2_loadout := _resolve_selected_loadout("p2", p2_character_id)
	var p1_resolved := LoadoutResolverStore.resolve_character_loadout(p1_character_id, p1_loadout)
	var p2_resolved := LoadoutResolverStore.resolve_character_loadout(p2_character_id, p2_loadout)
	current_p1_loadout = (p1_resolved.get("loadout", {}) as Dictionary).duplicate(true)
	current_p2_loadout = (p2_resolved.get("loadout", {}) as Dictionary).duplicate(true)
	SessionStateStore.set_value(SessionKeysStore.PLAYER_1_LOADOUT, current_p1_loadout.duplicate(true))
	SessionStateStore.set_value(SessionKeysStore.PLAYER_2_LOADOUT, current_p2_loadout.duplicate(true))
	if match_mode == "story":
		SessionStateStore.set_value(SessionKeysStore.STORY_ROUND_INDEX, 0)
	else:
		SessionStateStore.clear_keys(PackedStringArray([SessionKeysStore.STORY_ROUND_INDEX]))

func _clear_onboarding_replay_session_flags() -> void:
	SessionStateStore.clear_keys(
		PackedStringArray([
			SessionKeysStore.ONBOARDING_FORCE_REPLAY,
			SessionKeysStore.ONBOARDING_ENTRY_POINT
		])
	)

func _append_menu_metrics_log(event_name: String) -> void:
	if event_name.strip_edges() == "":
		return
	var p1_character_id := _get_selected_character_id("p1")
	var p2_character_id := _get_selected_character_id("p2")
	var p1_loadout := _resolve_selected_loadout("p1", p1_character_id)
	var p2_loadout := _resolve_selected_loadout("p2", p2_character_id)
	var p1_resolved := LoadoutResolverStore.resolve_character_loadout(p1_character_id, p1_loadout)
	var p2_resolved := LoadoutResolverStore.resolve_character_loadout(p2_character_id, p2_loadout)
	var record := {
		"schema_version": MENU_METRICS_SCHEMA_VERSION,
		"timestamp_utc": Time.get_datetime_string_from_system(true),
		"event": event_name,
		"locale": TranslationServer.get_locale(),
		"control_preset": current_control_preset,
		"window_mode": current_window_mode,
		"resolution": GameSettingsStore.resolution_to_string(current_resolution),
		"p1_character_id": p1_character_id,
		"p2_character_id": p2_character_id,
		"p1_loadout_fallback": bool(p1_resolved.get("used_fallback", false)),
		"p2_loadout_fallback": bool(p2_resolved.get("used_fallback", false))
	}
	var line := JSON.stringify(record)
	if line == "":
		return
	var file := FileAccess.open(MENU_METRICS_LOG_PATH, FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open(MENU_METRICS_LOG_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.seek_end()
	file.store_string("%s\n" % line)

func _resolve_selected_loadout(player_key: String, character_id: String) -> Dictionary:
	var current := current_p1_loadout if player_key == "p1" else current_p2_loadout
	if not current.is_empty():
		return current.duplicate(true)
	return LoadoutCatalogStore.get_default_loadout(character_id)

func _initialize_control_preset() -> void:
	var saved_preset := GameSettingsStore.get_control_preset()
	if saved_preset == "":
		first_launch_overlay.visible = true
		_set_main_menu_interactive(false)
		current_control_preset = GameSettingsStore.CONTROL_PRESET_MODERN
		return
	_apply_control_preset(saved_preset, false)
	first_launch_overlay.visible = false
	_set_main_menu_interactive(true)

func _initialize_advanced_setup_state() -> void:
	advanced_setup_expanded = _has_completed_onboarding()
	_refresh_advanced_setup_visibility()

func _has_completed_onboarding() -> bool:
	var onboarding_settings := GameSettingsStore.get_onboarding_settings()
	return bool(onboarding_settings.get("completed", false))

func _initialize_video_settings() -> void:
	var settings := GameSettingsStore.get_video_settings()
	current_window_mode = GameSettingsStore.normalize_window_mode(str(settings.get("window_mode", GameSettingsStore.WINDOW_MODE_WINDOWED)))
	var resolution_value: Variant = settings.get("resolution", GameSettingsStore.DEFAULT_RESOLUTION)
	if resolution_value is Vector2i:
		current_resolution = GameSettingsStore.normalize_resolution(resolution_value as Vector2i)
	else:
		current_resolution = GameSettingsStore.DEFAULT_RESOLUTION
	_refresh_video_options()
	GameSettingsStore.apply_video_settings(current_window_mode, current_resolution)

func _refresh_video_options() -> void:
	if window_mode_option == null or resolution_option == null:
		return
	is_refreshing_video_options = true
	window_mode_option.clear()
	for window_mode in WINDOW_MODE_OPTIONS:
		window_mode_option.add_item(_resolve_window_mode_label(str(window_mode)))
	var window_mode_index := WINDOW_MODE_OPTIONS.find(current_window_mode)
	if window_mode_index < 0:
		window_mode_index = 0
		current_window_mode = str(WINDOW_MODE_OPTIONS[window_mode_index])
	window_mode_option.select(window_mode_index)

	resolution_option.clear()
	for resolution in RESOLUTION_OPTIONS:
		if resolution is Vector2i:
			resolution_option.add_item(GameSettingsStore.resolution_to_string(resolution as Vector2i))
	var resolution_index := _find_resolution_option_index(current_resolution)
	if resolution_index < 0:
		resolution_index = 0
		current_resolution = GameSettingsStore.normalize_resolution(RESOLUTION_OPTIONS[resolution_index] as Vector2i)
	resolution_option.select(resolution_index)
	resolution_option.disabled = not main_menu_interactive or not _is_resolution_editable(current_window_mode)
	is_refreshing_video_options = false

func _find_resolution_option_index(resolution: Vector2i) -> int:
	var normalized := GameSettingsStore.normalize_resolution(resolution)
	for index in range(RESOLUTION_OPTIONS.size()):
		var item: Variant = RESOLUTION_OPTIONS[index]
		if item is Vector2i and (item as Vector2i) == normalized:
			return index
	return -1

func _on_window_mode_option_selected(index: int) -> void:
	if is_refreshing_video_options:
		return
	if index < 0 or index >= WINDOW_MODE_OPTIONS.size():
		return
	current_window_mode = str(WINDOW_MODE_OPTIONS[index])
	_apply_video_settings(true)
	_refresh_text()

func _on_resolution_option_selected(index: int) -> void:
	if is_refreshing_video_options:
		return
	if index < 0 or index >= RESOLUTION_OPTIONS.size():
		return
	var selected: Variant = RESOLUTION_OPTIONS[index]
	if selected is not Vector2i:
		return
	current_resolution = GameSettingsStore.normalize_resolution(selected as Vector2i)
	_apply_video_settings(true)
	_refresh_text()

func _apply_video_settings(persist: bool) -> void:
	if persist:
		GameSettingsStore.set_video_settings(current_window_mode, current_resolution)
	else:
		GameSettingsStore.apply_video_settings(current_window_mode, current_resolution)

func _is_resolution_editable(window_mode: String) -> bool:
	return window_mode == GameSettingsStore.WINDOW_MODE_WINDOWED

func _on_control_style_button_pressed() -> void:
	var next_preset := GameSettingsStore.CONTROL_PRESET_CLASSIC if current_control_preset == GameSettingsStore.CONTROL_PRESET_MODERN else GameSettingsStore.CONTROL_PRESET_MODERN
	_apply_control_preset(next_preset, true)
	_refresh_text()

func _on_advanced_toggle_pressed() -> void:
	advanced_setup_expanded = not advanced_setup_expanded
	_refresh_text()

func _on_first_launch_preset_selected(preset: String) -> void:
	_apply_control_preset(preset, true)
	first_launch_overlay.visible = false
	_set_main_menu_interactive(true)
	_refresh_text()

func _set_main_menu_interactive(enabled: bool) -> void:
	main_menu_interactive = enabled
	versus_button.disabled = not enabled
	story_button.disabled = not enabled
	training_button.disabled = not enabled
	guided_start_button.disabled = not enabled
	control_style_button.disabled = not enabled
	advanced_toggle_button.disabled = not enabled
	window_mode_option.disabled = not enabled
	resolution_option.disabled = not enabled or not _is_resolution_editable(current_window_mode)
	lang_en_button.disabled = not enabled or TranslationServer.get_locale().begins_with("en")
	lang_zh_button.disabled = not enabled or TranslationServer.get_locale().begins_with("zh")
	p1_character_option.disabled = not enabled
	p2_character_option.disabled = not enabled
	p1_loadout_option.disabled = not enabled
	p2_loadout_option.disabled = not enabled

func _apply_control_preset(preset: String, persist: bool) -> void:
	var normalized := GameSettingsStore.normalize_control_preset(preset)
	if persist:
		GameSettingsStore.set_control_preset(normalized)
	else:
		GameSettingsStore.apply_control_preset(normalized)
	current_control_preset = normalized
	Engine.set_meta(GameSettingsStore.ENGINE_META_KEY, current_control_preset)

func _resolve_control_preset_label(preset: String) -> String:
	if preset == GameSettingsStore.CONTROL_PRESET_CLASSIC:
		return tr("MENU_CONTROL_STYLE_CLASSIC")
	return tr("MENU_CONTROL_STYLE_MODERN")

func _resolve_window_mode_label(window_mode: String) -> String:
	match window_mode:
		GameSettingsStore.WINDOW_MODE_MAXIMIZED:
			return _resolve_menu_text("MENU_WINDOW_MODE_MAXIMIZED", "Maximized")
		GameSettingsStore.WINDOW_MODE_FULLSCREEN:
			return _resolve_menu_text("MENU_WINDOW_MODE_FULLSCREEN", "Fullscreen")
		GameSettingsStore.WINDOW_MODE_BORDERLESS:
			return _resolve_menu_text("MENU_WINDOW_MODE_BORDERLESS", "Borderless")
		_:
			return _resolve_menu_text("MENU_WINDOW_MODE_WINDOWED", "Windowed")

func _refresh_loadout_options() -> void:
	_refresh_loadout_option_for_player("p1")
	_refresh_loadout_option_for_player("p2")

func _refresh_loadout_option_for_player(player_key: String) -> void:
	var character_id := _get_selected_character_id(player_key)
	var option_button := p1_loadout_option if player_key == "p1" else p2_loadout_option
	if option_button == null:
		return
	var presets := LoadoutCatalogStore.get_preset_options(character_id)
	is_refreshing_loadout_options = true
	option_button.clear()
	for preset in presets:
		var text := _resolve_loadout_preset_label(character_id, preset)
		option_button.add_item(text)
	if player_key == "p1":
		p1_loadout_presets = presets
	else:
		p2_loadout_presets = presets
	var selected_index := 0
	var selected_preset_id := current_p1_preset_id if player_key == "p1" else current_p2_preset_id
	if selected_preset_id != "":
		for index in range(presets.size()):
			var preset := presets[index]
			if str(preset.get("id", "")) == selected_preset_id:
				selected_index = index
				break
	if presets.is_empty():
		if player_key == "p1":
			current_p1_preset_id = ""
			current_p1_loadout = {}
		else:
			current_p2_preset_id = ""
			current_p2_loadout = {}
		option_button.tooltip_text = _build_loadout_tooltip(character_id, {})
		is_refreshing_loadout_options = false
		return
	option_button.select(selected_index)
	var selected_preset := presets[selected_index]
	var selected_loadout := (selected_preset.get("loadout", {}) as Dictionary).duplicate(true)
	if player_key == "p1":
		current_p1_preset_id = str(selected_preset.get("id", ""))
		current_p1_loadout = selected_loadout
	else:
		current_p2_preset_id = str(selected_preset.get("id", ""))
		current_p2_loadout = selected_loadout
	option_button.disabled = not main_menu_interactive
	_refresh_loadout_tooltip_for_player(player_key)
	is_refreshing_loadout_options = false

func _resolve_loadout_preset_label(character_id: String, preset: Dictionary) -> String:
	var preset_prefix := _resolve_menu_text("MENU_LOADOUT_PRESET_PREFIX", "Preset")
	var fallback_name := str(preset.get("display_name_fallback", "Preset"))
	var key := str(preset.get("display_name_key", ""))
	var name := fallback_name
	if key != "":
		name = _resolve_menu_text(key, fallback_name)
	var loadout := (preset.get("loadout", {}) as Dictionary).duplicate(true)
	var validation := LoadoutValidatorStore.validate_loadout(character_id, loadout)
	var total_cost := int(validation.get("total_cost", 0))
	var budget_cap := int(validation.get("budget_cap", LoadoutCatalogStore.get_budget_cap()))
	return "%s: %s (%d/%d)" % [preset_prefix, name, total_cost, budget_cap]

func _get_selected_character_id(player_key: String) -> String:
	if character_options.is_empty():
		return ""
	var option: OptionButton = p1_character_option if player_key == "p1" else p2_character_option
	var selected_index := 0
	if option != null:
		selected_index = option.selected
	var clamped_index := clampi(selected_index, 0, character_options.size() - 1)
	var character := character_options[clamped_index]
	return str(character.get("id", "")).strip_edges()

func _on_p1_character_option_selected(_index: int) -> void:
	current_p1_preset_id = ""
	current_p1_loadout = {}
	_refresh_loadout_option_for_player("p1")
	_refresh_character_profile_preview()

func _on_p2_character_option_selected(_index: int) -> void:
	current_p2_preset_id = ""
	current_p2_loadout = {}
	_refresh_loadout_option_for_player("p2")
	_refresh_character_profile_preview()

func _on_p1_loadout_option_selected(index: int) -> void:
	if is_refreshing_loadout_options:
		return
	if index < 0 or index >= p1_loadout_presets.size():
		return
	var preset := p1_loadout_presets[index]
	current_p1_preset_id = str(preset.get("id", ""))
	current_p1_loadout = (preset.get("loadout", {}) as Dictionary).duplicate(true)
	_refresh_loadout_tooltip_for_player("p1")
	_refresh_character_profile_preview()

func _on_p2_loadout_option_selected(index: int) -> void:
	if is_refreshing_loadout_options:
		return
	if index < 0 or index >= p2_loadout_presets.size():
		return
	var preset := p2_loadout_presets[index]
	current_p2_preset_id = str(preset.get("id", ""))
	current_p2_loadout = (preset.get("loadout", {}) as Dictionary).duplicate(true)
	_refresh_loadout_tooltip_for_player("p2")
	_refresh_character_profile_preview()

func _refresh_mode_hint_tooltips() -> void:
	var story_hint := _resolve_menu_text(
		"MENU_STORY_AUTO_RIVAL_HINT",
		"Story uses an automatic rival ladder. Opponent selection applies to Local VS and Training."
	)
	var versus_hint := _resolve_menu_text(
		"MENU_VERSUS_HINT",
		"Two local players share one screen. Best for immediate sparring."
	)
	var training_hint := _resolve_menu_text(
		"MENU_TRAINING_HINT",
		"Practice dummy behavior, frame advantage, and move timing."
	)
	var guided_hint := _resolve_menu_text(
		"MENU_GUIDED_START_HINT",
		"Starts Training with the onboarding sequence replayed from Step 1."
	)
	versus_button.tooltip_text = versus_hint
	story_button.tooltip_text = story_hint
	training_button.tooltip_text = training_hint
	guided_start_button.tooltip_text = guided_hint
	p2_character_option.tooltip_text = story_hint
	p2_loadout_option.tooltip_text = story_hint
	advanced_toggle_button.tooltip_text = _resolve_menu_text(
		"MENU_ADVANCED_HINT",
		"Advanced setup reveals rival, controls, video, and language configuration."
	)
	advanced_hint_label.tooltip_text = advanced_toggle_button.tooltip_text

func _refresh_advanced_setup_visibility() -> void:
	var show_advanced := advanced_setup_expanded
	for helper in [quick_start_label, p1_loadout_label, mode_step_label]:
		if helper is CanvasItem:
			(helper as CanvasItem).visible = not show_advanced
	for node in [
		p2_character_label,
		p2_character_option,
		p2_loadout_option,
		p2_profile_label,
		control_style_label,
		control_style_button,
		video_settings_label,
		window_mode_label,
		window_mode_option,
		resolution_label,
		resolution_option,
		lang_label,
		lang_en_button,
		lang_zh_button
	]:
		if node is CanvasItem:
			(node as CanvasItem).visible = show_advanced
	if p2_character_option:
		p2_character_option.disabled = not main_menu_interactive or not show_advanced
	if p2_loadout_option:
		p2_loadout_option.disabled = not main_menu_interactive or not show_advanced
	if control_style_button:
		control_style_button.disabled = not main_menu_interactive or not show_advanced
	if window_mode_option:
		window_mode_option.disabled = not main_menu_interactive or not show_advanced
	if resolution_option:
		resolution_option.disabled = not main_menu_interactive or not show_advanced or not _is_resolution_editable(current_window_mode)
	if lang_en_button:
		lang_en_button.disabled = not main_menu_interactive or not show_advanced or TranslationServer.get_locale().begins_with("en")
	if lang_zh_button:
		lang_zh_button.disabled = not main_menu_interactive or not show_advanced or TranslationServer.get_locale().begins_with("zh")
	_apply_focus_layout()

func _apply_focus_layout() -> void:
	if advanced_setup_expanded:
		_set_control_vertical_bounds(guided_start_button, 70.0, 94.0)
		_set_control_vertical_bounds(p1_character_label, 98.0, 118.0)
		_set_control_vertical_bounds(p1_character_option, 120.0, 152.0)
		_set_control_vertical_bounds(p1_loadout_option, 154.0, 184.0)
		_set_control_vertical_bounds(p1_profile_label, 186.0, 212.0)
		_set_control_vertical_bounds(story_button, 332.0, 364.0)
		_set_control_vertical_bounds(versus_button, 368.0, 400.0)
		_set_control_vertical_bounds(training_button, 404.0, 436.0)
		return
	_set_control_vertical_bounds(guided_start_button, 90.0, 122.0)
	_set_control_vertical_bounds(p1_character_label, 132.0, 152.0)
	_set_control_vertical_bounds(p1_character_option, 154.0, 186.0)
	_set_control_vertical_bounds(p1_loadout_option, 212.0, 244.0)
	_set_control_vertical_bounds(p1_profile_label, 248.0, 308.0)
	_set_control_vertical_bounds(story_button, 344.0, 376.0)
	_set_control_vertical_bounds(versus_button, 380.0, 412.0)
	_set_control_vertical_bounds(training_button, 416.0, 448.0)

func _set_control_vertical_bounds(control: Control, top: float, bottom: float) -> void:
	if control == null:
		return
	control.offset_top = top
	control.offset_bottom = bottom

func _refresh_loadout_tooltip_for_player(player_key: String) -> void:
	var character_id := _get_selected_character_id(player_key)
	var current_loadout := _resolve_current_loadout_for_player(player_key, character_id)
	var option_button := p1_loadout_option if player_key == "p1" else p2_loadout_option
	if option_button == null:
		return
	option_button.tooltip_text = _build_loadout_tooltip(character_id, current_loadout)

func _resolve_current_loadout_for_player(player_key: String, character_id: String) -> Dictionary:
	var current_loadout: Dictionary = {}
	if player_key == "p1":
		current_loadout = current_p1_loadout.duplicate(true)
	else:
		current_loadout = current_p2_loadout.duplicate(true)
	if current_loadout.is_empty():
		current_loadout = LoadoutCatalogStore.get_default_loadout(character_id)
	return current_loadout

func _build_loadout_tooltip(character_id: String, loadout: Dictionary) -> String:
	var resolved := LoadoutResolverStore.resolve_character_loadout(character_id, loadout)
	var summary := resolved.get("summary", {}) as Dictionary
	var used_fallback := bool(resolved.get("used_fallback", false))
	var slot_hint := _resolve_menu_text(
		"MENU_LOADOUT_SLOT_HINT",
		"Loadout slots: 2 signatures + 1 ultimate + item + passive."
	)
	var status_text := _resolve_menu_text("MENU_LOADOUT_STATUS_READY", "Status: Ready")
	if used_fallback:
		status_text = _resolve_menu_text("MENU_LOADOUT_STATUS_FALLBACK", "Status: Fallback Applied")
	var signature_a_name := str(summary.get("signature_a", "Signature A"))
	var signature_b_name := str(summary.get("signature_b", "Signature B"))
	var ultimate_name := str(summary.get("ultimate", "Ultimate"))
	var item_name := str(summary.get("item", "Item"))
	var passive_name := str(summary.get("passive", "Passive"))
	var total_cost := int(summary.get("total_cost", 0))
	var budget_cap := int(summary.get("budget_cap", LoadoutCatalogStore.get_budget_cap()))
	var tooltip := "%s | %s\nA: %s | B: %s | U: %s\nItem: %s | Passive: %s\nCost: %d/%d" % [
		slot_hint,
		status_text,
		signature_a_name,
		signature_b_name,
		ultimate_name,
		item_name,
		passive_name,
		total_cost,
		budget_cap
	]
	if used_fallback:
		var fallback_hint := _resolve_menu_text(
			"MENU_LOADOUT_FALLBACK_HINT",
			"Invalid loadout detected. Default preset applied."
		)
		return "%s\n%s" % [tooltip, fallback_hint]
	return tooltip

func _resolve_menu_text(key: String, fallback: String) -> String:
	var value := tr(key)
	if value == key:
		return fallback
	return value

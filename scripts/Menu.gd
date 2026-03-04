extends Control

const GameSettingsStore := preload("res://scripts/GameSettings.gd")
const LocalizationRegistryStore := preload("res://scripts/config/LocalizationRegistry.gd")
const CharacterCatalogStore := preload("res://scripts/config/CharacterCatalog.gd")
const SessionKeysStore := preload("res://scripts/config/SessionKeys.gd")
const SessionStateStore := preload("res://scripts/SessionState.gd")
const VS_SCENE_PATH := "res://scenes/Main.tscn"
const STORY_SCENE_PATH := "res://scenes/Story.tscn"
const TRAINING_SCENE_PATH := "res://scenes/Training.tscn"
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

@onready var title_label := $CenterPanel/TitleLabel
@onready var subtitle_label := $CenterPanel/SubtitleLabel
@onready var p1_character_label := $CenterPanel/P1CharacterLabel
@onready var p2_character_label := $CenterPanel/P2CharacterLabel
@onready var p1_character_option := $CenterPanel/P1CharacterOption
@onready var p2_character_option := $CenterPanel/P2CharacterOption
@onready var p1_profile_label := $CenterPanel/P1ProfileLabel
@onready var p2_profile_label := $CenterPanel/P2ProfileLabel
@onready var versus_button := $CenterPanel/VersusButton
@onready var story_button := $CenterPanel/StoryButton
@onready var training_button := $CenterPanel/TrainingButton
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
	control_style_button.pressed.connect(_on_control_style_button_pressed)
	lang_en_button.pressed.connect(func(): _set_locale("en"))
	lang_zh_button.pressed.connect(func(): _set_locale("zh"))
	window_mode_option.item_selected.connect(_on_window_mode_option_selected)
	resolution_option.item_selected.connect(_on_resolution_option_selected)
	p1_character_option.item_selected.connect(func(_index: int): _refresh_character_profile_preview())
	p2_character_option.item_selected.connect(func(_index: int): _refresh_character_profile_preview())
	first_launch_classic_button.pressed.connect(func(): _on_first_launch_preset_selected(GameSettingsStore.CONTROL_PRESET_CLASSIC))
	first_launch_modern_button.pressed.connect(func(): _on_first_launch_preset_selected(GameSettingsStore.CONTROL_PRESET_MODERN))
	_populate_character_options()
	_initialize_control_preset()
	_initialize_video_settings()
	_refresh_text()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh_text()

func _on_versus_pressed() -> void:
	_store_character_selection("vs")
	get_tree().change_scene_to_file(VS_SCENE_PATH)

func _on_story_pressed() -> void:
	_store_character_selection("story")
	get_tree().change_scene_to_file(STORY_SCENE_PATH)

func _on_training_pressed() -> void:
	_store_character_selection("training")
	get_tree().change_scene_to_file(TRAINING_SCENE_PATH)

func _set_locale(locale: String) -> void:
	if TranslationServer.get_locale().begins_with(locale):
		return
	TranslationServer.set_locale(locale)
	_refresh_text()

func _refresh_text() -> void:
	title_label.text = tr("MENU_TITLE")
	subtitle_label.text = tr("MENU_SUBTITLE")
	p1_character_label.text = _resolve_menu_text("MENU_P1_CHARACTER", "P1 Character")
	p2_character_label.text = _resolve_menu_text("MENU_P2_CHARACTER", "P2 Character")
	p1_profile_label.text = _resolve_menu_text("MENU_PROFILE_LOADING", "Loading profile...")
	p2_profile_label.text = _resolve_menu_text("MENU_PROFILE_LOADING", "Loading profile...")
	versus_button.text = tr("MENU_VERSUS")
	story_button.text = _resolve_menu_text("MENU_STORY", "Story Mode")
	training_button.text = tr("MENU_TRAINING")
	control_style_label.text = tr("MENU_CONTROL_STYLE")
	control_style_button.text = _resolve_control_preset_label(current_control_preset)
	video_settings_label.text = _resolve_menu_text("MENU_VIDEO_SETTINGS", "Video")
	window_mode_label.text = _resolve_menu_text("MENU_WINDOW_MODE", "Window Mode")
	resolution_label.text = _resolve_menu_text("MENU_RESOLUTION", "Resolution")
	_refresh_video_options()
	lang_label.text = tr("PAUSE_LANGUAGE")
	lang_en_button.text = tr("PAUSE_LANG_EN")
	lang_zh_button.text = tr("PAUSE_LANG_ZH")
	first_launch_title_label.text = tr("MENU_FIRST_LAUNCH_CONTROL_TITLE")
	first_launch_hint_label.text = tr("MENU_FIRST_LAUNCH_CONTROL_HINT")
	first_launch_classic_button.text = tr("MENU_CONTROL_STYLE_CLASSIC")
	first_launch_modern_button.text = tr("MENU_CONTROL_STYLE_MODERN")
	var locale := TranslationServer.get_locale()
	lang_en_button.disabled = not main_menu_interactive or locale.begins_with("en")
	lang_zh_button.disabled = not main_menu_interactive or locale.begins_with("zh")
	versus_button.disabled = not main_menu_interactive
	story_button.disabled = not main_menu_interactive
	training_button.disabled = not main_menu_interactive
	control_style_button.disabled = not main_menu_interactive
	window_mode_option.disabled = not main_menu_interactive
	resolution_option.disabled = not main_menu_interactive or not _is_resolution_editable(current_window_mode)
	p1_character_option.disabled = not main_menu_interactive
	p2_character_option.disabled = not main_menu_interactive
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
		"signature_alt": "Signature B"
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
	return profile

func _refresh_character_profile_preview() -> void:
	if p1_profile_label == null or p2_profile_label == null:
		return
	p1_profile_label.text = _build_profile_preview_text(p1_character_option.selected)
	p2_profile_label.text = _build_profile_preview_text(p2_character_option.selected)
	p1_profile_label.tooltip_text = _build_profile_hint_text(p1_character_option.selected)
	p2_profile_label.tooltip_text = _build_profile_hint_text(p2_character_option.selected)

func _build_profile_preview_text(index: int) -> String:
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
	var hint_template := tr("MENU_PROFILE_HINT_ROW")
	if hint_template.find("%") == -1:
		hint_template = "%s"
	var hint_text := tr(str(profile.get("archetype_hint_key", "ARCHETYPE_HINT_ALL_ROUNDER")))
	return "%s\n%s" % [
		row_template % [archetype_label, signature_primary, signature_alt],
		hint_template % [hint_text]
	]

func _build_profile_hint_text(index: int) -> String:
	if index < 0 or index >= character_profile_cache.size():
		return ""
	var profile := character_profile_cache[index]
	return tr(str(profile.get("archetype_hint_key", "ARCHETYPE_HINT_ALL_ROUNDER")))

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
	if match_mode == "story":
		SessionStateStore.set_value(SessionKeysStore.STORY_ROUND_INDEX, 0)
	else:
		SessionStateStore.clear_keys(PackedStringArray([SessionKeysStore.STORY_ROUND_INDEX]))

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
	control_style_button.disabled = not enabled
	window_mode_option.disabled = not enabled
	resolution_option.disabled = not enabled or not _is_resolution_editable(current_window_mode)
	lang_en_button.disabled = not enabled or TranslationServer.get_locale().begins_with("en")
	lang_zh_button.disabled = not enabled or TranslationServer.get_locale().begins_with("zh")
	p1_character_option.disabled = not enabled
	p2_character_option.disabled = not enabled

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

func _resolve_menu_text(key: String, fallback: String) -> String:
	var value := tr(key)
	if value == key:
		return fallback
	return value

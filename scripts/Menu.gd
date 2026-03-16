extends Control

const GameSettingsStore := preload("res://scripts/GameSettings.gd")
const UiSkinStore := preload("res://scripts/ui/UiSkin.gd")
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
const MENU_BG_TEXTURE_PATH := "res://assets/sprites/ui/menu_bg.png"
const MENU_CENTER_PANEL_TEXTURE_PATH := "res://assets/sprites/ui/menu_center_panel.png"
const MENU_SUMMARY_PANEL_TEXTURE_PATH := "res://assets/sprites/ui/menu_summary_panel.png"
const MENU_OVERLAY_PANEL_TEXTURE_PATH := "res://assets/sprites/ui/menu_overlay_panel.png"
const MENU_SLOT_CARD_TEXTURE_PATH := "res://assets/sprites/ui/menu_slot_card.png"
const MENU_ROUTE_ICON_PATHS := {
	"guided": "res://assets/sprites/ui/icon_guided.png",
	"story": "res://assets/sprites/ui/icon_story.png",
	"versus": "res://assets/sprites/ui/icon_versus.png",
	"training": "res://assets/sprites/ui/icon_training.png"
}
const MENU_CONTROL_ICON_PATHS := {
	GameSettingsStore.CONTROL_PRESET_CLASSIC: "res://assets/sprites/ui/icon_classic.png",
	GameSettingsStore.CONTROL_PRESET_MODERN: "res://assets/sprites/ui/icon_modern.png"
}
const MENU_SLOT_ICON_PATHS := {
	"signature_a": "res://assets/sprites/ui/icon_signature_a.png",
	"signature_b": "res://assets/sprites/ui/icon_signature_b.png",
	"signature_c": "res://assets/sprites/ui/icon_signature_c.png",
	"ultimate": "res://assets/sprites/ui/icon_ultimate.png",
	"item": "res://assets/sprites/ui/icon_item.png",
	"passive": "res://assets/sprites/ui/icon_passive.png"
}
const MENU_SLOT_PREVIEW_CONFIG := [
	{"key": "signature_a", "summary_key": "signature_a", "profile_key": "signature_primary", "label_key": "MENU_SUMMARY_SLOT_A", "fallback": "A"},
	{"key": "signature_b", "summary_key": "signature_b", "profile_key": "signature_alt", "label_key": "MENU_SUMMARY_SLOT_B", "fallback": "B"},
	{"key": "signature_c", "summary_key": "", "profile_key": "signature_c", "label_key": "MENU_SUMMARY_FIXED_DOWN_SPECIAL", "fallback": "DS"},
	{"key": "ultimate", "summary_key": "ultimate", "profile_key": "ultimate", "label_key": "MENU_SUMMARY_SLOT_U", "fallback": "U"},
	{"key": "item", "summary_key": "item", "profile_key": "", "label_key": "MENU_SUMMARY_ITEM", "fallback": "Item"},
	{"key": "passive", "summary_key": "passive", "profile_key": "", "label_key": "MENU_SUMMARY_PASSIVE", "fallback": "Passive"}
]
const MENU_ROUTE_CARD_CONFIG := [
	{
		"id": "guided",
		"title_key": "MENU_SUMMARY_ROUTE_GUIDED",
		"title_fallback": "Guided",
		"desc_key": "MENU_SUMMARY_ROUTE_GUIDED_HINT",
		"desc_fallback": "Best first run. Replays move, jump, guard, dodge, throw, and special.",
		"best_key": "MENU_ROUTE_PREVIEW_GUIDED_BEST",
		"best_fallback": "First session",
		"next_key": "MENU_ROUTE_PREVIEW_GUIDED_NEXT",
		"next_fallback": "Training with onboarding replay"
	},
	{
		"id": "story",
		"title_key": "MENU_SUMMARY_ROUTE_STORY",
		"title_fallback": "Story",
		"desc_key": "MENU_SUMMARY_ROUTE_STORY_HINT",
		"desc_fallback": "Solo ladder with automatic rivals.",
		"best_key": "MENU_ROUTE_PREVIEW_STORY_BEST",
		"best_fallback": "Solo ladder",
		"next_key": "MENU_ROUTE_PREVIEW_STORY_NEXT",
		"next_fallback": "Story mode with automatic rivals"
	},
	{
		"id": "versus",
		"title_key": "MENU_SUMMARY_ROUTE_VS",
		"title_fallback": "VS",
		"desc_key": "MENU_SUMMARY_ROUTE_VS_HINT",
		"desc_fallback": "Two local fighters on one screen.",
		"best_key": "MENU_ROUTE_PREVIEW_VS_BEST",
		"best_fallback": "Two local players",
		"next_key": "MENU_ROUTE_PREVIEW_VS_NEXT",
		"next_fallback": "Immediate sparring match"
	},
	{
		"id": "training",
		"title_key": "MENU_SUMMARY_ROUTE_TRAINING",
		"title_fallback": "Training",
		"desc_key": "MENU_SUMMARY_ROUTE_TRAINING_HINT",
		"desc_fallback": "Sandbox for drills, dummy logic, and timing.",
		"best_key": "MENU_ROUTE_PREVIEW_TRAINING_BEST",
		"best_fallback": "Drills and timing",
		"next_key": "MENU_ROUTE_PREVIEW_TRAINING_NEXT",
		"next_fallback": "Sandbox with dummy logic"
	}
]
const MENU_BUTTON_STORY_PALETTE := {
	"normal_fill": Color(0.23, 0.18, 0.08, 0.96),
	"hover_fill": Color(0.31, 0.24, 0.08, 0.99),
	"pressed_fill": Color(0.17, 0.13, 0.06, 0.99),
	"disabled_fill": Color(0.14, 0.12, 0.10, 0.84),
	"border": Color(1.0, 0.83, 0.43, 1.0),
	"font_color": Color(1.0, 0.96, 0.88, 1.0)
}
const MENU_BUTTON_VERSUS_PALETTE := {
	"normal_fill": Color(0.27, 0.14, 0.14, 0.96),
	"hover_fill": Color(0.35, 0.18, 0.18, 0.99),
	"pressed_fill": Color(0.20, 0.10, 0.10, 0.99),
	"disabled_fill": Color(0.14, 0.12, 0.10, 0.84),
	"border": Color(1.0, 0.62, 0.50, 1.0),
	"font_color": Color(1.0, 0.95, 0.94, 1.0)
}
const MENU_BUTTON_PRIMARY_PALETTE := {
	"normal_fill": Color(0.13, 0.26, 0.46, 0.97),
	"hover_fill": Color(0.18, 0.34, 0.58, 0.99),
	"pressed_fill": Color(0.10, 0.20, 0.36, 0.99),
	"disabled_fill": Color(0.12, 0.15, 0.20, 0.86),
	"border": Color(0.42, 0.84, 1.0, 1.0),
	"border_hover": Color(0.64, 0.92, 1.0, 1.0),
	"font_color": Color(0.96, 0.98, 1.0, 1.0)
}
const MENU_BUTTON_SECONDARY_PALETTE := {
	"normal_fill": Color(0.12, 0.18, 0.30, 0.94),
	"hover_fill": Color(0.16, 0.24, 0.40, 0.98),
	"pressed_fill": Color(0.10, 0.15, 0.26, 0.99),
	"disabled_fill": Color(0.12, 0.15, 0.20, 0.86),
	"border": Color(0.31, 0.52, 0.84, 1.0),
	"font_color": Color(0.94, 0.97, 1.0, 1.0)
}
const MENU_BUTTON_WARM_PALETTE := {
	"normal_fill": Color(0.28, 0.19, 0.10, 0.96),
	"hover_fill": Color(0.37, 0.24, 0.11, 0.99),
	"pressed_fill": Color(0.22, 0.15, 0.08, 0.99),
	"disabled_fill": Color(0.14, 0.12, 0.10, 0.84),
	"border": Color(1.0, 0.83, 0.43, 1.0),
	"font_color": Color(1.0, 0.96, 0.88, 1.0)
}
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
var ui_texture_cache := {}
var summary_slot_labels := {"p1": {}, "p2": {}}
var summary_slot_cards := {"p1": {}, "p2": {}}
var summary_slot_badge_labels := {"p1": {}, "p2": {}}
var summary_slot_grids := {"p1": null, "p2": null}
var current_route_preview_id := "guided"
var guided_hint_label: Label
var route_preview_icon_rect: TextureRect
var route_preview_mode_label: Label
var route_preview_tag_label: Label
var route_preview_footer_label: Label

@onready var background_rect := $Background
@onready var center_panel := $CenterPanel
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
@onready var p1_summary_panel := $P1SummaryPanel
@onready var p1_summary_title_label := $P1SummaryPanel/TitleLabel
@onready var p1_summary_body_label := $P1SummaryPanel/BodyLabel
@onready var p2_summary_panel := $P2SummaryPanel
@onready var p2_summary_title_label := $P2SummaryPanel/TitleLabel
@onready var p2_summary_body_label := $P2SummaryPanel/BodyLabel
@onready var first_launch_overlay := $FirstLaunchControlOverlay
@onready var first_launch_panel := $FirstLaunchControlOverlay/Panel
@onready var first_launch_title_label := $FirstLaunchControlOverlay/Panel/TitleLabel
@onready var first_launch_hint_label := $FirstLaunchControlOverlay/Panel/HintLabel
@onready var first_launch_classic_button := $FirstLaunchControlOverlay/Panel/ClassicButton
@onready var first_launch_modern_button := $FirstLaunchControlOverlay/Panel/ModernButton

func _ready() -> void:
	_ensure_translations_registered()
	var locale := TranslationServer.get_locale()
	if not locale.begins_with("en") and not locale.begins_with("zh"):
		TranslationServer.set_locale("en")
	_apply_runtime_skin()
	versus_button.pressed.connect(_on_versus_pressed)
	story_button.pressed.connect(_on_story_pressed)
	training_button.pressed.connect(_on_training_pressed)
	guided_start_button.pressed.connect(_on_guided_start_pressed)
	control_style_button.pressed.connect(_on_control_style_button_pressed)
	advanced_toggle_button.pressed.connect(_on_advanced_toggle_pressed)
	_bind_route_preview_button(guided_start_button, "guided")
	_bind_route_preview_button(story_button, "story")
	_bind_route_preview_button(versus_button, "versus")
	_bind_route_preview_button(training_button, "training")
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

func _apply_runtime_skin() -> void:
	if background_rect:
		UiSkinStore.ensure_backdrop(
			background_rect,
			"BackdropTexture",
			_load_ui_texture(MENU_BG_TEXTURE_PATH, Vector2i(1280, 720), Color(0.08, 0.11, 0.16, 1.0)),
			Color(1, 1, 1, 0.96)
		)
	for panel in [center_panel, p1_summary_panel, p2_summary_panel, first_launch_panel]:
		if panel is Panel:
			UiSkinStore.clear_panel_skin(panel as Panel)
	if center_panel:
		UiSkinStore.ensure_backdrop(
			center_panel,
			"BackdropTexture",
			_load_ui_texture(MENU_CENTER_PANEL_TEXTURE_PATH, Vector2i(360, 680), Color(0.10, 0.16, 0.28, 0.98))
		)
	if p1_summary_panel:
		UiSkinStore.ensure_backdrop(
			p1_summary_panel,
			"BackdropTexture",
			_load_ui_texture(MENU_SUMMARY_PANEL_TEXTURE_PATH, Vector2i(280, 396), Color(0.10, 0.16, 0.28, 0.98)),
			Color(0.88, 0.96, 1.0, 1.0)
		)
	if p2_summary_panel:
		UiSkinStore.ensure_backdrop(
			p2_summary_panel,
			"BackdropTexture",
			_load_ui_texture(MENU_SUMMARY_PANEL_TEXTURE_PATH, Vector2i(280, 396), Color(0.10, 0.16, 0.28, 0.98)),
			Color(1.0, 0.91, 0.88, 1.0)
		)
	if first_launch_panel:
		UiSkinStore.ensure_backdrop(
			first_launch_panel,
			"BackdropTexture",
			_load_ui_texture(MENU_OVERLAY_PANEL_TEXTURE_PATH, Vector2i(430, 220), Color(0.18, 0.16, 0.12, 0.98))
		)
	UiSkinStore.apply_button_skin(guided_start_button, MENU_BUTTON_WARM_PALETTE)
	UiSkinStore.apply_button_skin(story_button, MENU_BUTTON_STORY_PALETTE)
	UiSkinStore.apply_button_skin(versus_button, MENU_BUTTON_VERSUS_PALETTE)
	UiSkinStore.apply_button_skin(training_button, MENU_BUTTON_PRIMARY_PALETTE)
	UiSkinStore.apply_button_skin(first_launch_modern_button, MENU_BUTTON_PRIMARY_PALETTE)
	for button in [
		control_style_button,
		advanced_toggle_button,
		lang_en_button,
		lang_zh_button,
		first_launch_classic_button
	]:
		UiSkinStore.apply_button_skin(button, MENU_BUTTON_SECONDARY_PALETTE)
	for option_button in [
		p1_character_option,
		p2_character_option,
		p1_loadout_option,
		p2_loadout_option,
		window_mode_option,
		resolution_option
	]:
		UiSkinStore.apply_button_skin(option_button, MENU_BUTTON_SECONDARY_PALETTE)
	_assign_menu_button_icons()
	_ensure_guided_hint_label()
	_ensure_route_preview()
	_apply_menu_typography()
	_ensure_summary_slot_previews()

func _apply_menu_typography() -> void:
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 13)
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.clip_text = false
	quick_start_label.add_theme_font_size_override("font_size", 15)
	mode_step_label.add_theme_font_size_override("font_size", 15)
	p1_character_label.add_theme_font_size_override("font_size", 14)
	p2_character_label.add_theme_font_size_override("font_size", 13)
	p1_loadout_label.add_theme_font_size_override("font_size", 14)
	p1_profile_label.add_theme_font_size_override("font_size", 12)
	p2_profile_label.add_theme_font_size_override("font_size", 12)
	p1_summary_title_label.add_theme_font_size_override("font_size", 17)
	p2_summary_title_label.add_theme_font_size_override("font_size", 17)
	p1_summary_body_label.add_theme_font_size_override("font_size", 12)
	p2_summary_body_label.add_theme_font_size_override("font_size", 12)
	p1_summary_body_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	p2_summary_body_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	guided_start_button.add_theme_font_size_override("font_size", 15)
	for button in [story_button, versus_button, training_button, control_style_button, advanced_toggle_button]:
		button.add_theme_font_size_override("font_size", 14)
	if route_preview_mode_label:
		route_preview_mode_label.add_theme_font_size_override("font_size", 18)
	if route_preview_tag_label:
		route_preview_tag_label.add_theme_font_size_override("font_size", 11)
	if route_preview_footer_label:
		route_preview_footer_label.add_theme_font_size_override("font_size", 11)

func _ensure_guided_hint_label() -> void:
	if center_panel == null:
		return
	guided_hint_label = center_panel.get_node_or_null("GuidedHintLabel") as Label
	if guided_hint_label != null:
		return
	guided_hint_label = Label.new()
	guided_hint_label.name = "GuidedHintLabel"
	guided_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	guided_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guided_hint_label.clip_text = true
	guided_hint_label.add_theme_color_override("font_color", Color(0.79, 0.89, 1.0, 1.0))
	guided_hint_label.add_theme_font_size_override("font_size", 12)
	center_panel.add_child(guided_hint_label)

func _ensure_route_preview() -> void:
	if p2_summary_panel == null:
		return
	route_preview_icon_rect = p2_summary_panel.get_node_or_null("RoutePreviewIcon") as TextureRect
	if route_preview_icon_rect == null:
		route_preview_icon_rect = TextureRect.new()
		route_preview_icon_rect.name = "RoutePreviewIcon"
		route_preview_icon_rect.position = Vector2(18, 58)
		route_preview_icon_rect.size = Vector2(38, 38)
		route_preview_icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		route_preview_icon_rect.stretch_mode = TextureRect.STRETCH_SCALE
		route_preview_icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p2_summary_panel.add_child(route_preview_icon_rect)
	route_preview_mode_label = p2_summary_panel.get_node_or_null("RoutePreviewModeLabel") as Label
	if route_preview_mode_label == null:
		route_preview_mode_label = Label.new()
		route_preview_mode_label.name = "RoutePreviewModeLabel"
		route_preview_mode_label.position = Vector2(68, 58)
		route_preview_mode_label.size = Vector2(176, 24)
		route_preview_mode_label.clip_text = true
		route_preview_mode_label.add_theme_color_override("font_color", Color(0.98, 0.95, 0.84, 1.0))
		p2_summary_panel.add_child(route_preview_mode_label)
	route_preview_tag_label = p2_summary_panel.get_node_or_null("RoutePreviewTagLabel") as Label
	if route_preview_tag_label == null:
		route_preview_tag_label = Label.new()
		route_preview_tag_label.name = "RoutePreviewTagLabel"
		route_preview_tag_label.position = Vector2(68, 84)
		route_preview_tag_label.size = Vector2(176, 18)
		route_preview_tag_label.clip_text = true
		route_preview_tag_label.add_theme_color_override("font_color", Color(0.79, 0.89, 1.0, 1.0))
		p2_summary_panel.add_child(route_preview_tag_label)
	route_preview_footer_label = p2_summary_panel.get_node_or_null("RoutePreviewFooterLabel") as Label
	if route_preview_footer_label == null:
		route_preview_footer_label = Label.new()
		route_preview_footer_label.name = "RoutePreviewFooterLabel"
		route_preview_footer_label.position = Vector2(18, 326)
		route_preview_footer_label.size = Vector2(244, 34)
		route_preview_footer_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		route_preview_footer_label.clip_text = true
		route_preview_footer_label.add_theme_color_override("font_color", Color(0.78, 0.88, 1.0, 1.0))
		p2_summary_panel.add_child(route_preview_footer_label)

func _assign_menu_button_icons() -> void:
	guided_start_button.icon = _load_ui_texture(MENU_ROUTE_ICON_PATHS["guided"], Vector2i(24, 24), Color(1.0, 0.84, 0.47, 1.0))
	story_button.icon = _load_ui_texture(MENU_ROUTE_ICON_PATHS["story"], Vector2i(24, 24), Color(1.0, 0.83, 0.43, 1.0))
	versus_button.icon = _load_ui_texture(MENU_ROUTE_ICON_PATHS["versus"], Vector2i(24, 24), Color(1.0, 0.60, 0.48, 1.0))
	training_button.icon = _load_ui_texture(MENU_ROUTE_ICON_PATHS["training"], Vector2i(24, 24), Color(0.42, 0.84, 1.0, 1.0))
	first_launch_classic_button.icon = _load_ui_texture(MENU_CONTROL_ICON_PATHS[GameSettingsStore.CONTROL_PRESET_CLASSIC], Vector2i(24, 24), Color(1.0, 0.83, 0.43, 1.0))
	first_launch_modern_button.icon = _load_ui_texture(MENU_CONTROL_ICON_PATHS[GameSettingsStore.CONTROL_PRESET_MODERN], Vector2i(24, 24), Color(0.42, 0.84, 1.0, 1.0))
	_refresh_control_style_icon()

func _refresh_control_style_icon() -> void:
	var path := str(MENU_CONTROL_ICON_PATHS.get(current_control_preset, MENU_CONTROL_ICON_PATHS[GameSettingsStore.CONTROL_PRESET_MODERN]))
	var tint := Color(1.0, 0.83, 0.43, 1.0) if current_control_preset == GameSettingsStore.CONTROL_PRESET_CLASSIC else Color(0.42, 0.84, 1.0, 1.0)
	control_style_button.icon = _load_ui_texture(path, Vector2i(24, 24), tint)

func _refresh_guided_hint_label() -> void:
	if guided_hint_label == null:
		return
	guided_hint_label.text = _resolve_menu_text(
		"MENU_GUIDED_START_HINT",
		"Training opens with the onboarding path replayed from Step 1."
	)

func _refresh_route_preview() -> void:
	var show_preview := not advanced_setup_expanded
	for node in [route_preview_icon_rect, route_preview_mode_label, route_preview_tag_label, route_preview_footer_label]:
		if node is CanvasItem:
			(node as CanvasItem).visible = show_preview
	if not show_preview:
		return
	var config := _resolve_route_preview_config(current_route_preview_id)
	var route_id := str(config.get("id", "guided"))
	var title_text := _resolve_menu_text(str(config.get("title_key", "")), str(config.get("title_fallback", route_id.capitalize())))
	var best_text := _resolve_menu_text(str(config.get("best_key", "")), str(config.get("best_fallback", "")))
	var desc_text := _resolve_menu_text(str(config.get("desc_key", "")), str(config.get("desc_fallback", "")))
	var next_text := _resolve_menu_text(str(config.get("next_key", "")), str(config.get("next_fallback", "")))
	if route_preview_icon_rect:
		route_preview_icon_rect.texture = _load_ui_texture(
			str(MENU_ROUTE_ICON_PATHS.get(route_id, MENU_ROUTE_ICON_PATHS["guided"])),
			Vector2i(38, 38),
			Color(0.96, 0.98, 1.0, 1.0)
		)
	if route_preview_mode_label:
		route_preview_mode_label.text = title_text
	if route_preview_tag_label:
		route_preview_tag_label.text = "%s: %s" % [
			_resolve_menu_text("MENU_ROUTE_PREVIEW_BEST_FOR", "Best For"),
			best_text
		]
	p2_summary_body_label.text = desc_text
	if route_preview_footer_label:
		route_preview_footer_label.text = "%s: %s" % [
			_resolve_menu_text("MENU_ROUTE_PREVIEW_NEXT", "Starts In"),
			next_text
		]

func _resolve_route_preview_config(route_id: String) -> Dictionary:
	for config_variant in MENU_ROUTE_CARD_CONFIG:
		var config := config_variant as Dictionary
		if str(config.get("id", "")) == route_id:
			return config
	return MENU_ROUTE_CARD_CONFIG[0] as Dictionary

func _set_route_preview(route_id: String) -> void:
	current_route_preview_id = str(_resolve_route_preview_config(route_id).get("id", "guided"))
	_refresh_route_preview()

func _bind_route_preview_button(button: BaseButton, route_id: String) -> void:
	if button == null:
		return
	button.mouse_entered.connect(func(): _set_route_preview(route_id))
	button.focus_entered.connect(func(): _set_route_preview(route_id))

func _ensure_summary_slot_previews() -> void:
	_ensure_summary_slot_preview_for_panel("p1", p1_summary_panel)
	_ensure_summary_slot_preview_for_panel("p2", p2_summary_panel)
	_refresh_summary_slot_previews()

func _ensure_summary_slot_preview_for_panel(player_key: String, panel: Control) -> void:
	if panel == null:
		return
	var grid := panel.get_node_or_null("SlotPreviewGrid") as GridContainer
	if grid == null:
		grid = GridContainer.new()
		grid.name = "SlotPreviewGrid"
		grid.columns = 2
		grid.position = Vector2(18, 52)
		grid.custom_minimum_size = Vector2(244, 126)
		grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(grid)
	summary_slot_grids[player_key] = grid
	if grid.get_child_count() > 0:
		return
	for slot_config_variant in MENU_SLOT_PREVIEW_CONFIG:
		var slot_config := slot_config_variant as Dictionary
		var slot_key := str(slot_config.get("key", ""))
		var slot_card := Control.new()
		slot_card.name = "%sCard" % slot_key.capitalize()
		slot_card.custom_minimum_size = Vector2(116, 38)
		slot_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		grid.add_child(slot_card)
		summary_slot_cards[player_key][slot_key] = slot_card
		var accent := _resolve_slot_modulate(slot_key, player_key)
		UiSkinStore.ensure_backdrop(
			slot_card,
			"BackdropTexture",
			_load_ui_texture(MENU_SLOT_CARD_TEXTURE_PATH, Vector2i(116, 38), Color(0.10, 0.16, 0.28, 0.98)),
			accent
		)
		var badge_label := Label.new()
		badge_label.name = "BadgeLabel"
		badge_label.position = Vector2(6, 7)
		badge_label.size = Vector2(24, 22)
		badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge_label.clip_text = true
		badge_label.add_theme_color_override("font_color", accent)
		badge_label.add_theme_font_size_override("font_size", 11)
		badge_label.text = _resolve_slot_badge(slot_key)
		slot_card.add_child(badge_label)
		summary_slot_badge_labels[player_key][slot_key] = badge_label
		var value_label := Label.new()
		value_label.name = "ValueLabel"
		value_label.position = Vector2(34, 6)
		value_label.size = Vector2(76, 24)
		value_label.clip_text = true
		value_label.add_theme_color_override("font_color", Color(0.94, 0.97, 1.0, 1.0))
		value_label.add_theme_font_size_override("font_size", 10)
		value_label.text = "-"
		slot_card.add_child(value_label)
		summary_slot_labels[player_key][slot_key] = value_label

func _refresh_summary_slot_previews() -> void:
	_refresh_summary_slot_preview_for_player("p1")
	_refresh_summary_slot_preview_for_player("p2")
	_refresh_route_preview()

func _refresh_summary_slot_preview_for_player(player_key: String) -> void:
	var grid := summary_slot_grids.get(player_key, null) as GridContainer
	var body_label := p1_summary_body_label if player_key == "p1" else p2_summary_body_label
	var should_show_grid := player_key == "p1" or advanced_setup_expanded
	var show_route_preview := player_key == "p2" and not advanced_setup_expanded
	if grid:
		grid.visible = should_show_grid
	if body_label:
		body_label.visible = player_key == "p1" or advanced_setup_expanded or show_route_preview
		if show_route_preview:
			body_label.offset_top = 118.0
			body_label.offset_bottom = 310.0
		elif player_key == "p1" and not advanced_setup_expanded:
			body_label.offset_top = 162.0
			body_label.offset_bottom = 376.0
		else:
			body_label.offset_top = 194.0 if should_show_grid else 52.0
			body_label.offset_bottom = 376.0
	if not should_show_grid:
		return
	var profile := _resolve_profile_for_player(player_key)
	var character_id := str(profile.get("character_id", "")).strip_edges()
	var summary := {}
	if character_id != "":
		var loadout := _resolve_current_loadout_for_player(player_key, character_id)
		var resolved := LoadoutResolverStore.resolve_character_loadout(character_id, loadout)
		summary = resolved.get("summary", {}) as Dictionary
	for slot_config_variant in MENU_SLOT_PREVIEW_CONFIG:
		var slot_config := slot_config_variant as Dictionary
		var slot_key := str(slot_config.get("key", ""))
		var label := summary_slot_labels[player_key].get(slot_key, null) as Label
		var card := summary_slot_cards[player_key].get(slot_key, null) as Control
		if label == null or card == null:
			continue
		var should_show_card := _should_show_summary_slot_card(player_key, slot_key)
		card.visible = should_show_card
		if not should_show_card:
			continue
		var display_value := "-"
		var summary_key := str(slot_config.get("summary_key", ""))
		var profile_key := str(slot_config.get("profile_key", ""))
		if summary_key != "":
			display_value = str(summary.get(summary_key, "")).strip_edges()
		if display_value == "" and profile_key != "":
			display_value = str(profile.get(profile_key, "")).strip_edges()
		if display_value == "":
			display_value = str(slot_config.get("fallback", "-"))
		label.text = _compact_slot_name(display_value)
		var slot_label := _resolve_menu_text(str(slot_config.get("label_key", "")), str(slot_config.get("fallback", slot_key)))
		card.tooltip_text = "%s: %s" % [slot_label, display_value]

func _should_show_summary_slot_card(player_key: String, slot_key: String) -> bool:
	if advanced_setup_expanded:
		return true
	if player_key != "p1":
		return false
	return slot_key in ["signature_a", "signature_b", "ultimate", "item"]

func _compact_slot_name(raw_name: String) -> String:
	var cleaned := raw_name.strip_edges()
	if cleaned == "":
		return "-"
	var paren_index := cleaned.find(" (")
	if paren_index != -1:
		cleaned = cleaned.substr(0, paren_index).strip_edges()
	var words := cleaned.split(" ", false)
	if words.size() >= 3:
		var tail := "%s %s" % [words[words.size() - 2], words[words.size() - 1]]
		if tail.length() <= 16:
			cleaned = tail
	if cleaned.length() > 16:
		cleaned = "%s..." % cleaned.substr(0, 13)
	return cleaned

func _resolve_slot_badge(slot_key: String) -> String:
	match slot_key:
		"signature_a":
			return "A"
		"signature_b":
			return "B"
		"signature_c":
			return "DS"
		"ultimate":
			return "U"
		"item":
			return "I"
		"passive":
			return "P"
		_:
			return "?"

func _resolve_slot_modulate(slot_key: String, player_key: String) -> Color:
	var base := Color(0.88, 0.96, 1.0, 1.0) if player_key == "p1" else Color(1.0, 0.91, 0.88, 1.0)
	match slot_key:
		"ultimate":
			return Color(1.0, 0.92, 0.68, 1.0)
		"item":
			return Color(0.84, 1.0, 0.90, 1.0)
		"passive":
			return Color(0.94, 0.86, 1.0, 1.0)
		"signature_b":
			return Color(0.86, 0.97, 1.0, 1.0)
		"signature_c":
			return Color(0.90, 0.90, 1.0, 1.0)
		_:
			return base

func _load_ui_texture(path: String, size: Vector2i, fill: Color) -> Texture2D:
	var cache_key := "%s|%d|%d|%s" % [path, size.x, size.y, fill.to_html()]
	if ui_texture_cache.has(cache_key):
		return ui_texture_cache[cache_key] as Texture2D
	var texture := UiSkinStore.load_texture_or_placeholder(path, size, fill)
	ui_texture_cache[cache_key] = texture
	return texture

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
			"Advanced setup is open. Rival, controls, video, and language can be tuned here."
		)
	else:
		subtitle_label.text = _resolve_menu_text(
			"MENU_SUBTITLE_SIMPLE",
			"Pick your fighter, then jump straight into Guided Start, Story, VS, or Training."
		)
	quick_start_label.text = _resolve_menu_text(
		"MENU_QUICK_START_LABEL",
		"Recommended First Run"
	)
	p1_character_label.text = _resolve_menu_text("MENU_P1_CHARACTER", "P1 Character")
	p2_character_label.text = _resolve_menu_text("MENU_P2_CHARACTER_VS_ONLY", "Opponent Setup")
	p1_loadout_label.text = _resolve_menu_text("MENU_LOADOUT_LABEL", "Gameplan Preset")
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
	control_style_button.text = "%s: %s" % [
		_resolve_menu_text("MENU_CONTROL_STYLE", "Control"),
		_resolve_control_preset_label(current_control_preset)
	]
	_refresh_control_style_icon()
	video_settings_label.text = _resolve_menu_text("MENU_VIDEO_SETTINGS", "Video")
	window_mode_label.text = _resolve_menu_text("MENU_WINDOW_MODE", "Window Mode")
	resolution_label.text = _resolve_menu_text("MENU_RESOLUTION", "Resolution")
	_refresh_video_options()
	_refresh_loadout_options()
	_refresh_mode_hint_tooltips()
	lang_label.text = tr("PAUSE_LANGUAGE")
	lang_en_button.text = tr("PAUSE_LANG_EN")
	lang_zh_button.text = tr("PAUSE_LANG_ZH")
	_refresh_guided_hint_label()
	advanced_hint_label.text = _resolve_menu_text(
		"MENU_ADVANCED_INLINE_HINT",
		"Rival • Controls • Video • Language"
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
	var signature_primary := _compact_slot_name(str(profile.get("signature_primary", "Signature A")))
	var signature_alt := _compact_slot_name(str(profile.get("signature_alt", "Signature B")))
	var base_text := "%s | %s / %s" % [archetype_label, signature_primary, signature_alt]
	var loadout_brief := _build_profile_loadout_brief(player_key, str(profile.get("character_id", "")))
	if loadout_brief == "":
		return base_text
	return "%s\n%s" % [base_text, loadout_brief]

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
		return "%s • %s" % [text, fallback_inline]
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
	_refresh_summary_slot_previews()

func _build_summary_panel_title(player_key: String) -> String:
	if player_key == "p2" and not advanced_setup_expanded:
		return _resolve_menu_text("MENU_ROUTE_PREVIEW_TITLE", "Mode Preview")
	var profile := _resolve_profile_for_player(player_key)
	var display_name := str(profile.get("display_name", "Player")).strip_edges()
	if player_key == "p1":
		return "%s • P1" % display_name
	return "%s • Rival" % display_name

func _build_summary_panel_body(player_key: String) -> String:
	if player_key == "p2" and not advanced_setup_expanded:
		return ""
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
	if preset_name != "" and (advanced_setup_expanded or player_key == "p2"):
		lines.append("%s: %s" % [_resolve_menu_text("MENU_SUMMARY_PRESET", "Preset"), preset_name])
	lines.append(
		"%s: %s -> %s" % [
			_resolve_menu_text("MENU_SUMMARY_CORE_LOOP", "Core Loop"),
			_compact_slot_name(str(summary.get("signature_a", profile.get("signature_primary", "Signature A")))),
			_compact_slot_name(str(summary.get("signature_b", profile.get("signature_alt", "Signature B"))))
		]
	)
	lines.append(
		"%s: %s / %s" % [
			_resolve_menu_text("MENU_SUMMARY_SUPPORT", "Support"),
			_compact_slot_name(str(summary.get("item", "Item"))),
			_compact_slot_name(str(summary.get("passive", "Passive")))
		]
	)
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
	if not advanced_setup_expanded:
		current_route_preview_id = "guided"
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
	versus_button.tooltip_text = ""
	story_button.tooltip_text = ""
	training_button.tooltip_text = ""
	guided_start_button.tooltip_text = ""
	p2_character_option.tooltip_text = ""
	p2_loadout_option.tooltip_text = ""
	advanced_toggle_button.tooltip_text = ""
	advanced_hint_label.tooltip_text = ""

func _refresh_advanced_setup_visibility() -> void:
	var show_advanced := advanced_setup_expanded
	if quick_start_label is CanvasItem:
		(quick_start_label as CanvasItem).visible = not show_advanced
	if mode_step_label is CanvasItem:
		(mode_step_label as CanvasItem).visible = not show_advanced
	if p1_loadout_label is CanvasItem:
		(p1_loadout_label as CanvasItem).visible = show_advanced
	if p1_loadout_option is CanvasItem:
		(p1_loadout_option as CanvasItem).visible = show_advanced
	for node in [
		p2_character_label,
		p2_character_option,
		p2_loadout_option,
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
	if p2_profile_label is CanvasItem:
		(p2_profile_label as CanvasItem).visible = false
	if guided_hint_label is CanvasItem:
		(guided_hint_label as CanvasItem).visible = not show_advanced
	if advanced_hint_label is CanvasItem:
		(advanced_hint_label as CanvasItem).visible = show_advanced
	if video_settings_label is CanvasItem:
		(video_settings_label as CanvasItem).visible = false
	if window_mode_label is CanvasItem:
		(window_mode_label as CanvasItem).visible = false
	if resolution_label is CanvasItem:
		(resolution_label as CanvasItem).visible = false
	if lang_label is CanvasItem:
		(lang_label as CanvasItem).visible = false
	if p2_character_option:
		p2_character_option.disabled = not main_menu_interactive or not show_advanced
	if p1_loadout_option:
		p1_loadout_option.disabled = not main_menu_interactive or not show_advanced
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
	_set_control_rect(title_label, 24.0, 18.0, 336.0, 50.0)
	_set_control_rect(subtitle_label, 24.0, 54.0, 336.0, 100.0)
	_set_root_control_rect(advanced_toggle_button, -112.0, 294.0, 112.0, 326.0)
	_set_root_control_rect(advanced_hint_label, -120.0, 330.0, 120.0, 348.0)
	if advanced_setup_expanded:
		_set_control_rect(guided_start_button, 36.0, 112.0, 324.0, 152.0)
		_set_control_rect(p1_character_label, 50.0, 168.0, 310.0, 186.0)
		_set_control_rect(p1_character_option, 50.0, 192.0, 310.0, 224.0)
		_set_control_rect(p1_loadout_label, 50.0, 236.0, 310.0, 254.0)
		_set_control_rect(p1_loadout_option, 50.0, 260.0, 310.0, 292.0)
		_set_control_rect(p1_profile_label, 50.0, 304.0, 310.0, 344.0)
		_set_control_rect(story_button, 50.0, 364.0, 310.0, 398.0)
		_set_control_rect(versus_button, 50.0, 410.0, 310.0, 444.0)
		_set_control_rect(training_button, 50.0, 456.0, 310.0, 490.0)
		_set_control_rect(p2_character_label, 50.0, 512.0, 170.0, 530.0)
		_set_control_rect(control_style_label, 190.0, 512.0, 310.0, 530.0)
		_set_control_rect(p2_character_option, 50.0, 536.0, 170.0, 566.0)
		_set_control_rect(control_style_button, 190.0, 536.0, 310.0, 566.0)
		_set_control_rect(p2_loadout_option, 50.0, 574.0, 170.0, 604.0)
		_set_control_rect(window_mode_option, 190.0, 574.0, 310.0, 604.0)
		_set_control_rect(lang_en_button, 50.0, 612.0, 108.0, 640.0)
		_set_control_rect(lang_zh_button, 112.0, 612.0, 170.0, 640.0)
		_set_control_rect(resolution_option, 190.0, 612.0, 310.0, 640.0)
		return
	_set_control_rect(quick_start_label, 50.0, 110.0, 310.0, 128.0)
	_set_control_rect(guided_start_button, 32.0, 138.0, 328.0, 192.0)
	_set_control_rect(guided_hint_label, 42.0, 200.0, 318.0, 228.0)
	_set_control_rect(p1_character_label, 50.0, 244.0, 310.0, 262.0)
	_set_control_rect(p1_character_option, 50.0, 270.0, 310.0, 302.0)
	_set_control_rect(p1_loadout_label, 50.0, 0.0, 310.0, 0.0)
	_set_control_rect(p1_loadout_option, 50.0, 0.0, 310.0, 0.0)
	_set_control_rect(p1_profile_label, 50.0, 320.0, 310.0, 372.0)
	_set_control_rect(mode_step_label, 50.0, 396.0, 310.0, 414.0)
	_set_control_rect(story_button, 50.0, 426.0, 310.0, 462.0)
	_set_control_rect(versus_button, 50.0, 474.0, 310.0, 510.0)
	_set_control_rect(training_button, 50.0, 522.0, 310.0, 558.0)

func _set_control_rect(control: Control, left: float, top: float, right: float, bottom: float) -> void:
	if control == null:
		return
	control.offset_left = left
	control.offset_right = right
	control.offset_top = top
	control.offset_bottom = bottom

func _set_root_control_rect(control: Control, left: float, top: float, right: float, bottom: float) -> void:
	if control == null:
		return
	control.offset_left = left
	control.offset_top = top
	control.offset_right = right
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

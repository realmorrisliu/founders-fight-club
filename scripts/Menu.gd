extends Control

const VS_SCENE_PATH := "res://scenes/Main.tscn"
const TRAINING_SCENE_PATH := "res://scenes/Training.tscn"
const TRANSLATION_PATHS := [
	"res://i18n/en.tres",
	"res://i18n/zh.tres"
]
const CHARACTER_OPTIONS := [
	{
		"id": "elon_mvsk",
		"name": "Elon Mvsk",
		"attack_table_path": "res://assets/data/characters/ElonMvskAttackTable.tres"
	},
	{
		"id": "mark_zuck",
		"name": "Mark Zuck",
		"attack_table_path": "res://assets/data/characters/MarkZuckAttackTable.tres"
	},
	{
		"id": "sam_altmyn",
		"name": "Sam Altmyn",
		"attack_table_path": "res://assets/data/characters/SamAltmynAttackTable.tres"
	},
	{
		"id": "peter_thyell",
		"name": "Peter Thyell",
		"attack_table_path": "res://assets/data/characters/PeterThyellAttackTable.tres"
	},
	{
		"id": "zef_bezos",
		"name": "Zef Bezos",
		"attack_table_path": "res://assets/data/characters/ZefBezosAttackTable.tres"
	},
	{
		"id": "bill_geytz",
		"name": "Bill Geytz",
		"attack_table_path": "res://assets/data/characters/BillGeytzAttackTable.tres"
	},
	{
		"id": "sundar_pichoy",
		"name": "Sundar Pichoy",
		"attack_table_path": "res://assets/data/characters/SundarPichoyAttackTable.tres"
	},
	{
		"id": "jensen_hwang",
		"name": "Jensen Hwang",
		"attack_table_path": "res://assets/data/characters/JensenHwangAttackTable.tres"
	}
]
const SESSION_KEY_P1_ID := "ffc_selected_player_1_character_id"
const SESSION_KEY_P2_ID := "ffc_selected_player_2_character_id"
const SESSION_KEY_P1_TABLE_PATH := "ffc_selected_player_1_attack_table_path"
const SESSION_KEY_P2_TABLE_PATH := "ffc_selected_player_2_attack_table_path"
const SESSION_KEY_P1_NAME := "ffc_selected_player_1_name"
const SESSION_KEY_P2_NAME := "ffc_selected_player_2_name"
const SESSION_KEY_MATCH_MODE := "ffc_match_mode"

static var _translations_registered := false

@onready var title_label := $CenterPanel/TitleLabel
@onready var subtitle_label := $CenterPanel/SubtitleLabel
@onready var p1_character_label := $CenterPanel/P1CharacterLabel
@onready var p2_character_label := $CenterPanel/P2CharacterLabel
@onready var p1_character_option := $CenterPanel/P1CharacterOption
@onready var p2_character_option := $CenterPanel/P2CharacterOption
@onready var versus_button := $CenterPanel/VersusButton
@onready var training_button := $CenterPanel/TrainingButton
@onready var lang_label := $CenterPanel/LanguageLabel
@onready var lang_en_button := $CenterPanel/LangEnButton
@onready var lang_zh_button := $CenterPanel/LangZhButton

func _ready() -> void:
	_ensure_translations_registered()
	var locale := TranslationServer.get_locale()
	if not locale.begins_with("en") and not locale.begins_with("zh"):
		TranslationServer.set_locale("en")
	versus_button.pressed.connect(_on_versus_pressed)
	training_button.pressed.connect(_on_training_pressed)
	lang_en_button.pressed.connect(func(): _set_locale("en"))
	lang_zh_button.pressed.connect(func(): _set_locale("zh"))
	_populate_character_options()
	_refresh_text()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh_text()

func _on_versus_pressed() -> void:
	_store_character_selection("vs")
	get_tree().change_scene_to_file(VS_SCENE_PATH)

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
	p2_character_label.text = _resolve_menu_text("MENU_P2_CHARACTER", "Opponent Character")
	versus_button.text = tr("MENU_VERSUS")
	training_button.text = tr("MENU_TRAINING")
	lang_label.text = tr("PAUSE_LANGUAGE")
	lang_en_button.text = tr("PAUSE_LANG_EN")
	lang_zh_button.text = tr("PAUSE_LANG_ZH")
	var locale := TranslationServer.get_locale()
	lang_en_button.disabled = locale.begins_with("en")
	lang_zh_button.disabled = locale.begins_with("zh")

func _ensure_translations_registered() -> void:
	if _translations_registered:
		return
	for path in TRANSLATION_PATHS:
		var translation := load(path) as Translation
		if translation:
			TranslationServer.add_translation(translation)
	_translations_registered = true

func _populate_character_options() -> void:
	p1_character_option.clear()
	p2_character_option.clear()
	for character in CHARACTER_OPTIONS:
		var label := str(character.get("name", "Unknown"))
		p1_character_option.add_item(label)
		p2_character_option.add_item(label)
	if p1_character_option.item_count > 0:
		p1_character_option.select(0)
	if p2_character_option.item_count > 1:
		p2_character_option.select(1)
	elif p2_character_option.item_count > 0:
		p2_character_option.select(0)

func _store_character_selection(match_mode: String) -> void:
	if CHARACTER_OPTIONS.is_empty():
		return
	var p1_index := clampi(p1_character_option.selected, 0, CHARACTER_OPTIONS.size() - 1)
	var p2_index := clampi(p2_character_option.selected, 0, CHARACTER_OPTIONS.size() - 1)
	var p1_character: Dictionary = CHARACTER_OPTIONS[p1_index]
	var p2_character: Dictionary = CHARACTER_OPTIONS[p2_index]
	Engine.set_meta(SESSION_KEY_MATCH_MODE, match_mode)
	Engine.set_meta(SESSION_KEY_P1_ID, str(p1_character.get("id", "")))
	Engine.set_meta(SESSION_KEY_P2_ID, str(p2_character.get("id", "")))
	Engine.set_meta(SESSION_KEY_P1_TABLE_PATH, str(p1_character.get("attack_table_path", "")))
	Engine.set_meta(SESSION_KEY_P2_TABLE_PATH, str(p2_character.get("attack_table_path", "")))
	Engine.set_meta(SESSION_KEY_P1_NAME, str(p1_character.get("name", "Player 1")))
	Engine.set_meta(SESSION_KEY_P2_NAME, str(p2_character.get("name", "Player 2")))

func _resolve_menu_text(key: String, fallback: String) -> String:
	var value := tr(key)
	if value == key:
		return fallback
	return value

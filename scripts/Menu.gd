extends Control

const VS_SCENE_PATH := "res://scenes/Main.tscn"
const TRAINING_SCENE_PATH := "res://scenes/Training.tscn"
const TRANSLATION_PATHS := [
	"res://i18n/en.tres",
	"res://i18n/zh.tres"
]

static var _translations_registered := false

@onready var title_label := $CenterPanel/TitleLabel
@onready var subtitle_label := $CenterPanel/SubtitleLabel
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
	_refresh_text()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh_text()

func _on_versus_pressed() -> void:
	get_tree().change_scene_to_file(VS_SCENE_PATH)

func _on_training_pressed() -> void:
	get_tree().change_scene_to_file(TRAINING_SCENE_PATH)

func _set_locale(locale: String) -> void:
	if TranslationServer.get_locale().begins_with(locale):
		return
	TranslationServer.set_locale(locale)
	_refresh_text()

func _refresh_text() -> void:
	title_label.text = tr("MENU_TITLE")
	subtitle_label.text = tr("MENU_SUBTITLE")
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

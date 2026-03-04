extends RefCounted
class_name LocalizationRegistry

const TRANSLATION_PATHS := [
	"res://i18n/en.tres",
	"res://i18n/zh.tres"
]

static var _registered := false

static func ensure_registered() -> void:
	if _registered:
		return
	for path in TRANSLATION_PATHS:
		var translation := load(path) as Translation
		if translation:
			TranslationServer.add_translation(translation)
	_registered = true

extends CanvasLayer

signal resume_requested
signal restart_requested
signal locale_changed(locale: String)
signal training_options_changed(options: Dictionary)

const TRANSLATION_PATHS := [
	"res://i18n/en.tres",
	"res://i18n/zh.tres"
]

static var _translations_registered := false

@onready var timer_label := $TimerLabel
@onready var p1_hp_label := $P1HpLabel
@onready var p2_hp_label := $P2HpLabel
@onready var result_label := $ResultLabel
@onready var p1_hp_bar := $P1HpBar
@onready var p2_hp_bar := $P2HpBar
@onready var result_chip := $ResultChip
@onready var combat_callout_label := $CombatCalloutLabel
@onready var hit_type_callout_label := $HitTypeCalloutLabel
@onready var dialogue_label := $DialogueLabel
@onready var training_panel := $TrainingPanel
@onready var training_title_label := $TrainingPanel/TrainingTitleLabel
@onready var training_mode_button := $TrainingPanel/TrainingModeButton
@onready var training_dummy_button := $TrainingPanel/TrainingDummyButton
@onready var training_detail_button := $TrainingPanel/TrainingDetailButton
@onready var training_summary_label := $TrainingPanel/TrainingSummaryLabel
@onready var training_stun_label := $TrainingPanel/TrainingStunLabel
@onready var training_recovery_label := $TrainingPanel/TrainingRecoveryLabel
@onready var training_advantage_label := $TrainingPanel/TrainingAdvantageLabel
@onready var training_detail_label := $TrainingPanel/TrainingDetailLabel
@onready var training_log_title_label := $TrainingPanel/TrainingLogTitleLabel
@onready var training_log_label := $TrainingPanel/TrainingLogLabel
@onready var pause_panel := $PausePanel
@onready var pause_title_label := $PausePanel/PauseTitleLabel
@onready var resume_button := $PausePanel/ResumeButton
@onready var restart_button := $PausePanel/RestartButton
@onready var language_label := $PausePanel/LanguageLabel
@onready var lang_en_button := $PausePanel/LangEnButton
@onready var lang_zh_button := $PausePanel/LangZhButton

var cached_timer_seconds := 60.0
var cached_p1_hp := 100
var cached_p2_hp := 100
var cached_max_hp := 100
var callout_message_key := ""
var callout_message_value := 0
var callout_uses_value := false
var callout_custom_text := ""
var callout_tween: Tween
var hit_type_callout_message_key := ""
var hit_type_callout_tween: Tween
var dialogue_tween: Tween
var cached_training_info := {}
var training_options := {
	"enabled": true,
	"dummy_mode": "stand",
	"show_detail": false
}
var training_panel_visible := true
var training_controls_visible := true
var training_log_entries: Array[Dictionary] = []
const TRAINING_LOG_MAX_ENTRIES := 5

func _ready() -> void:
	_ensure_translations_registered()
	var locale := TranslationServer.get_locale()
	if not locale.begins_with("en") and not locale.begins_with("zh"):
		TranslationServer.set_locale("en")
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_panel.visible = false
	combat_callout_label.visible = false
	if hit_type_callout_label:
		hit_type_callout_label.visible = false
	if dialogue_label:
		dialogue_label.visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	lang_en_button.pressed.connect(_on_lang_en_pressed)
	lang_zh_button.pressed.connect(_on_lang_zh_pressed)
	training_mode_button.pressed.connect(_on_training_mode_pressed)
	training_dummy_button.pressed.connect(_on_training_dummy_pressed)
	training_detail_button.pressed.connect(_on_training_detail_pressed)
	_refresh_ui_text()

func set_training_data(info: Dictionary) -> void:
	cached_training_info = info.duplicate(true)
	_refresh_training_panel()

func set_training_panel_visible(is_visible: bool) -> void:
	training_panel_visible = is_visible
	_refresh_training_panel()

func set_training_controls_visible(is_visible: bool) -> void:
	training_controls_visible = is_visible
	_refresh_training_panel()

func set_training_options(options: Dictionary) -> void:
	training_options["enabled"] = bool(options.get("enabled", training_options.get("enabled", true)))
	var dummy_mode := str(options.get("dummy_mode", training_options.get("dummy_mode", "stand")))
	if dummy_mode not in ["stand", "force_block", "random_block"]:
		dummy_mode = "stand"
	training_options["dummy_mode"] = dummy_mode
	training_options["show_detail"] = bool(options.get("show_detail", training_options.get("show_detail", false)))
	_refresh_training_panel()

func add_training_log_entry(info: Dictionary) -> void:
	if info.is_empty():
		return
	training_log_entries.push_front(info.duplicate(true))
	while training_log_entries.size() > TRAINING_LOG_MAX_ENTRIES:
		training_log_entries.pop_back()
	_refresh_training_panel()

func clear_training_log() -> void:
	training_log_entries.clear()
	_refresh_training_panel()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh_ui_text()

func set_timer_seconds(seconds_left: float) -> void:
	cached_timer_seconds = seconds_left
	var display_seconds := int(ceil(seconds_left))
	timer_label.text = _format_stat(tr("HUD_TIMER"), "Time: %d", display_seconds)

func set_health(p1_hp: int, p2_hp: int) -> void:
	cached_p1_hp = p1_hp
	cached_p2_hp = p2_hp
	p1_hp_label.text = _format_stat(tr("HUD_P1_HP"), "P1 HP: %d", p1_hp)
	p2_hp_label.text = _format_stat(tr("HUD_P2_HP"), "P2 HP: %d", p2_hp)
	if p1_hp_bar:
		p1_hp_bar.max_value = cached_max_hp
		p1_hp_bar.value = clampf(float(p1_hp), 0.0, float(cached_max_hp))
	if p2_hp_bar:
		p2_hp_bar.max_value = cached_max_hp
		p2_hp_bar.value = clampf(float(p2_hp), 0.0, float(cached_max_hp))

func set_result(result_text: String) -> void:
	result_label.text = result_text
	if result_chip:
		result_chip.visible = result_text != ""

func set_pause_visible(is_visible: bool) -> void:
	pause_panel.visible = is_visible

func show_combat_callout(message_key: String, tint: Color = Color(1.0, 0.93, 0.64, 1.0)) -> void:
	callout_message_key = message_key
	callout_message_value = 0
	callout_uses_value = false
	callout_custom_text = ""
	_play_combat_callout(_resolve_callout_text(), tint)

func show_combat_callout_with_value(
	message_key: String,
	value: int,
	tint: Color = Color(1.0, 0.93, 0.64, 1.0)
) -> void:
	callout_message_key = message_key
	callout_message_value = value
	callout_uses_value = true
	callout_custom_text = ""
	_play_combat_callout(_resolve_callout_text(), tint)

func show_combat_callout_text(text: String, tint: Color = Color(1.0, 0.93, 0.64, 1.0)) -> void:
	callout_message_key = ""
	callout_message_value = 0
	callout_uses_value = false
	callout_custom_text = text
	_play_combat_callout(text, tint)

func show_hit_type_callout(message_key: String, tint: Color = Color(1.0, 0.82, 0.52, 1.0)) -> void:
	hit_type_callout_message_key = message_key
	_play_hit_type_callout(tr(message_key), tint)

func show_dialogue_line(text: String, duration: float = 2.4, tint: Color = Color(0.94, 0.97, 1.0, 1.0)) -> void:
	if dialogue_label == null:
		return
	if dialogue_tween and dialogue_tween.is_valid():
		dialogue_tween.kill()
	dialogue_label.text = text
	dialogue_label.visible = true
	dialogue_label.modulate = Color(tint.r, tint.g, tint.b, 0.0)
	dialogue_tween = create_tween()
	dialogue_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	dialogue_tween.tween_property(dialogue_label, "modulate:a", 1.0, 0.12)
	dialogue_tween.tween_interval(maxf(0.2, duration))
	dialogue_tween.tween_property(dialogue_label, "modulate:a", 0.0, 0.22)
	dialogue_tween.finished.connect(
		func():
			if dialogue_label:
				dialogue_label.visible = false
				dialogue_label.text = ""
		CONNECT_ONE_SHOT
	)

func _play_combat_callout(text: String, tint: Color) -> void:
	if combat_callout_label == null:
		return
	combat_callout_label.text = text
	combat_callout_label.visible = true
	combat_callout_label.scale = Vector2.ONE * 0.82
	combat_callout_label.modulate = Color(tint.r, tint.g, tint.b, 0.0)
	if callout_tween and callout_tween.is_valid():
		callout_tween.kill()
	callout_tween = create_tween()
	callout_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	callout_tween.tween_property(combat_callout_label, "modulate:a", 1.0, 0.06)
	callout_tween.parallel().tween_property(combat_callout_label, "scale", Vector2.ONE, 0.09)
	callout_tween.tween_interval(0.14)
	callout_tween.tween_property(combat_callout_label, "modulate:a", 0.0, 0.20)
	callout_tween.finished.connect(_on_callout_tween_finished)

func _play_hit_type_callout(text: String, tint: Color) -> void:
	if hit_type_callout_label == null:
		return
	hit_type_callout_label.text = text
	hit_type_callout_label.visible = true
	hit_type_callout_label.scale = Vector2.ONE * 0.88
	hit_type_callout_label.modulate = Color(tint.r, tint.g, tint.b, 0.0)
	if hit_type_callout_tween and hit_type_callout_tween.is_valid():
		hit_type_callout_tween.kill()
	hit_type_callout_tween = create_tween()
	hit_type_callout_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	hit_type_callout_tween.tween_property(hit_type_callout_label, "modulate:a", 1.0, 0.05)
	hit_type_callout_tween.parallel().tween_property(hit_type_callout_label, "scale", Vector2.ONE, 0.08)
	hit_type_callout_tween.tween_interval(0.11)
	hit_type_callout_tween.tween_property(hit_type_callout_label, "modulate:a", 0.0, 0.16)
	hit_type_callout_tween.finished.connect(_on_hit_type_callout_tween_finished)

func _refresh_ui_text() -> void:
	set_timer_seconds(cached_timer_seconds)
	set_health(cached_p1_hp, cached_p2_hp)
	if combat_callout_label.visible:
		combat_callout_label.text = _resolve_callout_text()
	if hit_type_callout_label and hit_type_callout_label.visible and hit_type_callout_message_key != "":
		hit_type_callout_label.text = tr(hit_type_callout_message_key)
	_refresh_training_panel()
	pause_title_label.text = tr("PAUSE_TITLE")
	resume_button.text = tr("PAUSE_RESUME")
	restart_button.text = tr("PAUSE_RESTART")
	language_label.text = tr("PAUSE_LANGUAGE")
	lang_en_button.text = tr("PAUSE_LANG_EN")
	lang_zh_button.text = tr("PAUSE_LANG_ZH")
	_update_language_buttons()

func _refresh_training_panel() -> void:
	if training_panel == null:
		return
	training_panel.visible = training_panel_visible
	if not training_panel_visible:
		return
	training_title_label.text = tr("HUD_TRAINING_TITLE")
	training_log_title_label.text = tr("HUD_TRAINING_LOG_TITLE")
	_refresh_training_option_buttons()
	if cached_training_info.is_empty():
		training_summary_label.text = tr("HUD_TRAINING_NO_DATA")
		training_stun_label.text = _format_stat(tr("HUD_TRAINING_STUN"), "Stun: %dF", 0)
		training_recovery_label.text = _format_stat(tr("HUD_TRAINING_RECOVERY"), "Recovery: %dF", 0)
		training_advantage_label.text = _format_advantage_label(0)
		training_advantage_label.modulate = Color(0.92, 0.95, 1.0, 1.0)
		_refresh_training_detail_label()
		_refresh_training_log_label()
		return

	var event_type := str(cached_training_info.get("event_type", ""))
	var attack_kind := str(cached_training_info.get("attack_kind", ""))
	var guard_mode := str(cached_training_info.get("guard_mode", "none"))
	var combo_count := int(cached_training_info.get("combo_count", 0))
	var is_counter := bool(cached_training_info.get("is_counter", false))
	var summary_parts: PackedStringArray = []
	summary_parts.append(_resolve_training_event_label(event_type))
	if attack_kind != "":
		summary_parts.append(_resolve_training_attack_label(attack_kind))
	if event_type == "block" and guard_mode != "none":
		summary_parts.append(_resolve_training_guard_label(guard_mode))
	if event_type == "throw_tech":
		summary_parts.append(_resolve_training_guard_label("throw_break"))
	if is_counter:
		summary_parts.append(tr("HUD_CALLOUT_COUNTER"))
	if combo_count >= 2:
		summary_parts.append(tr("HUD_TRAINING_COMBO_SUFFIX") % combo_count)
	training_summary_label.text = "  ".join(summary_parts)

	var stun_frames := int(cached_training_info.get("stun_frames", 0))
	var recovery_frames := int(cached_training_info.get("recovery_frames", 0))
	var advantage_frames := int(cached_training_info.get("advantage_frames", 0))
	training_stun_label.text = _format_stat(tr("HUD_TRAINING_STUN"), "Stun: %dF", stun_frames)
	training_recovery_label.text = _format_stat(tr("HUD_TRAINING_RECOVERY"), "Recovery: %dF", recovery_frames)
	training_advantage_label.text = _format_advantage_label(advantage_frames)
	if advantage_frames > 0:
		training_advantage_label.modulate = Color(0.80, 1.0, 0.84, 1.0)
	elif advantage_frames < 0:
		training_advantage_label.modulate = Color(1.0, 0.84, 0.80, 1.0)
	else:
		training_advantage_label.modulate = Color(0.92, 0.95, 1.0, 1.0)
	_refresh_training_detail_label()
	_refresh_training_log_label()

func _refresh_training_option_buttons() -> void:
	var enabled_value := tr("HUD_TRAINING_OPTION_ON") if bool(training_options.get("enabled", true)) else tr("HUD_TRAINING_OPTION_OFF")
	var detail_value := tr("HUD_TRAINING_OPTION_ON") if bool(training_options.get("show_detail", false)) else tr("HUD_TRAINING_OPTION_OFF")
	var dummy_mode := str(training_options.get("dummy_mode", "stand"))
	var dummy_label := _resolve_dummy_mode_label(dummy_mode)
	training_mode_button.text = _format_string_value(tr("HUD_TRAINING_MODE_BUTTON"), "Training: %s", enabled_value)
	training_dummy_button.text = _format_string_value(tr("HUD_TRAINING_DUMMY_BUTTON"), "Dummy: %s", dummy_label)
	training_detail_button.text = _format_string_value(tr("HUD_TRAINING_DETAIL_BUTTON"), "Adv Detail: %s", detail_value)
	training_mode_button.visible = training_controls_visible
	training_dummy_button.visible = training_controls_visible
	training_detail_button.visible = training_controls_visible
	var panel_enabled := bool(training_options.get("enabled", true))
	training_panel.modulate = Color(1.0, 1.0, 1.0, 1.0) if panel_enabled else Color(0.78, 0.78, 0.78, 0.94)

func _refresh_training_detail_label() -> void:
	if training_detail_label == null:
		return
	var show_detail := bool(training_options.get("show_detail", false))
	training_detail_label.visible = show_detail
	if not show_detail:
		training_detail_label.text = tr("HUD_TRAINING_DETAIL_HIDDEN")
		return
	if cached_training_info.is_empty():
		training_detail_label.text = tr("HUD_TRAINING_NO_DATA")
		return
	var event_label := _resolve_training_event_label(str(cached_training_info.get("event_type", "")))
	var move_label := _resolve_training_attack_label(str(cached_training_info.get("attack_kind", "")))
	var block_type := str(cached_training_info.get("block_type", "mid"))
	var guard_mode := str(cached_training_info.get("guard_mode", "none"))
	var guard_label := _resolve_training_guard_label(guard_mode) if guard_mode != "none" else _resolve_training_guard_label(block_type)
	var stun_frames := int(cached_training_info.get("stun_frames", 0))
	var recovery_frames := int(cached_training_info.get("recovery_frames", 0))
	var stun_seconds := float(cached_training_info.get("stun_seconds", 0.0))
	var recovery_seconds := float(cached_training_info.get("recovery_seconds", 0.0))
	training_detail_label.text = "%s | %s | %s\n%s %dF (%.2fs)  %s %dF (%.2fs)" % [
		event_label,
		move_label,
		guard_label,
		tr("HUD_TRAINING_DETAIL_STUN_SHORT"),
		stun_frames,
		stun_seconds,
		tr("HUD_TRAINING_DETAIL_REC_SHORT"),
		recovery_frames,
		recovery_seconds
	]

func _refresh_training_log_label() -> void:
	if training_log_label == null:
		return
	if training_log_entries.is_empty():
		training_log_label.text = tr("HUD_TRAINING_LOG_EMPTY")
		return
	var lines: Array[String] = []
	for entry in training_log_entries:
		lines.append(_resolve_training_log_line(entry))
	var text := ""
	for i in range(lines.size()):
		if i > 0:
			text += "\n"
		text += lines[i]
	training_log_label.text = text

func _on_callout_tween_finished() -> void:
	if combat_callout_label:
		combat_callout_label.visible = false
		combat_callout_label.scale = Vector2.ONE

func _on_hit_type_callout_tween_finished() -> void:
	if hit_type_callout_label:
		hit_type_callout_label.visible = false
		hit_type_callout_label.scale = Vector2.ONE

func _resolve_callout_text() -> String:
	if callout_message_key == "":
		return callout_custom_text
	var template := tr(callout_message_key)
	if callout_uses_value:
		if template.find("%") == -1:
			return str(callout_message_value)
		return template % callout_message_value
	return template

func _format_advantage_label(value: int) -> String:
	var template := tr("HUD_TRAINING_ADVANTAGE")
	var display := "%+d" % value
	if template.find("%") == -1:
		return "Adv: %sF" % display
	return template % display

func _format_string_value(template: String, fallback_template: String, value: String) -> String:
	if template.find("%") == -1:
		return fallback_template % value
	return template % value

func _resolve_training_event_label(event_type: String) -> String:
	match event_type:
		"hit":
			return tr("HUD_TRAINING_EVENT_HIT")
		"block":
			return tr("HUD_TRAINING_EVENT_BLOCK")
		"throw_tech":
			return tr("HUD_TRAINING_EVENT_THROW_TECH")
	return tr("HUD_TRAINING_EVENT_HIT")

func _resolve_training_attack_label(attack_kind: String) -> String:
	match attack_kind:
		"light":
			return tr("HUD_TRAINING_MOVE_LIGHT")
		"heavy":
			return tr("HUD_TRAINING_MOVE_HEAVY")
		"special":
			return tr("HUD_TRAINING_MOVE_SPECIAL")
		"throw":
			return tr("HUD_TRAINING_MOVE_THROW")
	return attack_kind.to_upper()

func _resolve_training_guard_label(guard_mode: String) -> String:
	match guard_mode:
		"high":
			return tr("HUD_TRAINING_GUARD_HIGH")
		"low":
			return tr("HUD_TRAINING_GUARD_LOW")
		"overhead":
			return tr("HUD_CALLOUT_OVERHEAD")
		"air":
			return tr("HUD_TRAINING_GUARD_AIR")
		"throw_break":
			return tr("HUD_TRAINING_GUARD_THROW_BREAK")
		"mid":
			return tr("HUD_TRAINING_GUARD_MID")
	return tr("HUD_TRAINING_GUARD_MID")

func _resolve_training_log_line(entry: Dictionary) -> String:
	var event_label := _resolve_training_event_label(str(entry.get("event_type", "")))
	var move_label := _resolve_training_attack_label(str(entry.get("attack_kind", "")))
	var block_type := str(entry.get("block_type", "mid"))
	var block_tag := ""
	if block_type == "overhead" or block_type == "high":
		block_tag = tr("HUD_CALLOUT_OVERHEAD")
	elif block_type == "low":
		block_tag = tr("HUD_CALLOUT_LOW")
	var adv := int(entry.get("advantage_frames", 0))
	var adv_text := "%+dF" % adv
	var damage_total := int(entry.get("damage_total", 0))
	var combo_damage := int(entry.get("combo_damage", 0))
	var hp_before := int(entry.get("hp_before", 0))
	var hp_after := int(entry.get("hp_after", 0))
	var chip_damage := int(entry.get("chip_damage", 0))
	var line := "%s %s" % [event_label, move_label]
	if block_tag != "":
		line += " %s" % block_tag
	line += " %s D%d C%d HP%d>%d" % [adv_text, damage_total, combo_damage, hp_before, hp_after]
	if chip_damage > 0:
		line += " chip%d" % chip_damage
	return line

func _resolve_dummy_mode_label(mode: String) -> String:
	match mode:
		"force_block":
			return tr("HUD_TRAINING_DUMMY_FORCE_BLOCK")
		"random_block":
			return tr("HUD_TRAINING_DUMMY_RANDOM_BLOCK")
		_:
			return tr("HUD_TRAINING_DUMMY_STAND")

func _update_language_buttons() -> void:
	var locale := TranslationServer.get_locale()
	lang_en_button.disabled = locale.begins_with("en")
	lang_zh_button.disabled = locale.begins_with("zh")

func _on_resume_pressed() -> void:
	resume_requested.emit()

func _on_restart_pressed() -> void:
	restart_requested.emit()

func _on_training_mode_pressed() -> void:
	training_options["enabled"] = not bool(training_options.get("enabled", true))
	_refresh_training_panel()
	training_options_changed.emit(training_options.duplicate(true))

func _on_training_dummy_pressed() -> void:
	var current := str(training_options.get("dummy_mode", "stand"))
	match current:
		"stand":
			current = "force_block"
		"force_block":
			current = "random_block"
		_:
			current = "stand"
	training_options["dummy_mode"] = current
	_refresh_training_panel()
	training_options_changed.emit(training_options.duplicate(true))

func _on_training_detail_pressed() -> void:
	training_options["show_detail"] = not bool(training_options.get("show_detail", false))
	_refresh_training_panel()
	training_options_changed.emit(training_options.duplicate(true))

func _on_lang_en_pressed() -> void:
	_set_locale("en")

func _on_lang_zh_pressed() -> void:
	_set_locale("zh")

func _set_locale(locale: String) -> void:
	if TranslationServer.get_locale().begins_with(locale):
		return
	TranslationServer.set_locale(locale)
	locale_changed.emit(locale)
	_refresh_ui_text()

func _format_stat(template: String, fallback_template: String, value: int) -> String:
	if template.find("%") == -1:
		return fallback_template % value
	return template % value

func _ensure_translations_registered() -> void:
	if _translations_registered:
		return
	for path in TRANSLATION_PATHS:
		var translation = load(path) as Translation
		if translation:
			TranslationServer.add_translation(translation)
	_translations_registered = true

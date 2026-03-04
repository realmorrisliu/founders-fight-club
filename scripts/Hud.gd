extends CanvasLayer

const LocalizationRegistryStore := preload("res://scripts/config/LocalizationRegistry.gd")

signal resume_requested
signal restart_requested
signal menu_requested
signal locale_changed(locale: String)
signal training_options_changed(options: Dictionary)

const MATCH_UI_MODE_HP_TIMER := "hp_timer"
const MATCH_UI_MODE_STOCK := "stock"

@onready var timer_label := $TimerLabel
@onready var timer_chip := $TimerChip
@onready var p1_hp_label := $P1HpLabel
@onready var p2_hp_label := $P2HpLabel
@onready var p1_hype_label := $P1HypeLabel
@onready var p2_hype_label := $P2HypeLabel
@onready var p1_hype_bar := $P1HypeBar
@onready var p2_hype_bar := $P2HypeBar
@onready var p1_state_label := $P1StateLabel
@onready var p2_state_label := $P2StateLabel
@onready var p1_profile_label := $P1ProfileLabel
@onready var p2_profile_label := $P2ProfileLabel
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
@onready var training_quick_hint_label := $TrainingPanel/TrainingQuickHintLabel
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
@onready var back_menu_button := $PausePanel/BackMenuButton
@onready var language_label := $PausePanel/LanguageLabel
@onready var lang_en_button := $PausePanel/LangEnButton
@onready var lang_zh_button := $PausePanel/LangZhButton

var cached_timer_seconds := 60.0
var cached_p1_hp := 100
var cached_p2_hp := 100
var cached_max_hp := 100
var cached_p1_stocks := 0
var cached_p2_stocks := 0
var match_ui_mode := MATCH_UI_MODE_HP_TIMER
var cached_p1_combat_state := {}
var cached_p2_combat_state := {}
var cached_p1_character_profile := {}
var cached_p2_character_profile := {}
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
const TRAINING_LOG_MAX_ENTRIES := 8

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
	back_menu_button.pressed.connect(_on_back_menu_pressed)
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

func set_timer_visible(is_visible: bool) -> void:
	timer_label.visible = is_visible
	if timer_chip:
		timer_chip.visible = is_visible

func set_health(p1_hp: int, p2_hp: int) -> void:
	cached_p1_hp = p1_hp
	cached_p2_hp = p2_hp
	var p1_hp_text := _format_stat(tr("HUD_P1_HP"), "P1 HP: %d", p1_hp)
	var p2_hp_text := _format_stat(tr("HUD_P2_HP"), "P2 HP: %d", p2_hp)
	if match_ui_mode == MATCH_UI_MODE_STOCK:
		var p1_stock_text := _format_stat(tr("HUD_P1_STOCK"), "Stock: %d", cached_p1_stocks)
		var p2_stock_text := _format_stat(tr("HUD_P2_STOCK"), "Stock: %d", cached_p2_stocks)
		var p1_damage_percent := clampi(cached_max_hp - p1_hp, 0, 999)
		var p2_damage_percent := clampi(cached_max_hp - p2_hp, 0, 999)
		var p1_damage_text := _format_stat(tr("HUD_P1_DAMAGE"), "P1 DMG: %d%%", p1_damage_percent)
		var p2_damage_text := _format_stat(tr("HUD_P2_DAMAGE"), "P2 DMG: %d%%", p2_damage_percent)
		p1_hp_label.text = "%s | %s" % [p1_stock_text, p1_damage_text]
		p2_hp_label.text = "%s | %s" % [p2_stock_text, p2_damage_text]
	else:
		p1_hp_label.text = p1_hp_text
		p2_hp_label.text = p2_hp_text
	if p1_hp_bar:
		p1_hp_bar.max_value = cached_max_hp
		p1_hp_bar.value = clampf(float(p1_hp), 0.0, float(cached_max_hp))
		p1_hp_bar.visible = match_ui_mode != MATCH_UI_MODE_STOCK
	if p2_hp_bar:
		p2_hp_bar.max_value = cached_max_hp
		p2_hp_bar.value = clampf(float(p2_hp), 0.0, float(cached_max_hp))
		p2_hp_bar.visible = match_ui_mode != MATCH_UI_MODE_STOCK

func set_stocks(p1_stocks: int, p2_stocks: int) -> void:
	cached_p1_stocks = maxi(0, p1_stocks)
	cached_p2_stocks = maxi(0, p2_stocks)
	set_health(cached_p1_hp, cached_p2_hp)

func set_match_ui_mode(mode: String) -> void:
	match_ui_mode = mode if mode in [MATCH_UI_MODE_HP_TIMER, MATCH_UI_MODE_STOCK] else MATCH_UI_MODE_HP_TIMER
	set_health(cached_p1_hp, cached_p2_hp)

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
	var hide_dialogue := func() -> void:
		if dialogue_label:
			dialogue_label.visible = false
			dialogue_label.text = ""
	dialogue_tween.finished.connect(hide_dialogue, CONNECT_ONE_SHOT)

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
	_refresh_combat_state_ui()
	_refresh_character_profile_labels()
	if combat_callout_label.visible:
		combat_callout_label.text = _resolve_callout_text()
	if hit_type_callout_label and hit_type_callout_label.visible and hit_type_callout_message_key != "":
		hit_type_callout_label.text = tr(hit_type_callout_message_key)
	_refresh_training_panel()
	pause_title_label.text = tr("PAUSE_TITLE")
	resume_button.text = tr("PAUSE_RESUME")
	restart_button.text = tr("PAUSE_RESTART")
	back_menu_button.text = tr("PAUSE_BACK_TO_MENU")
	language_label.text = tr("PAUSE_LANGUAGE")
	lang_en_button.text = tr("PAUSE_LANG_EN")
	lang_zh_button.text = tr("PAUSE_LANG_ZH")
	_update_language_buttons()

func set_combat_state(p1_state: Dictionary, p2_state: Dictionary) -> void:
	cached_p1_combat_state = p1_state.duplicate(true)
	cached_p2_combat_state = p2_state.duplicate(true)
	_refresh_combat_state_ui()

func set_character_profiles(p1_profile: Dictionary, p2_profile: Dictionary) -> void:
	cached_p1_character_profile = p1_profile.duplicate(true)
	cached_p2_character_profile = p2_profile.duplicate(true)
	_refresh_character_profile_labels()

func _refresh_combat_state_ui() -> void:
	_refresh_side_combat_state(
		cached_p1_combat_state,
		p1_hype_bar,
		p1_hype_label,
		p1_state_label,
		false
	)
	_refresh_side_combat_state(
		cached_p2_combat_state,
		p2_hype_bar,
		p2_hype_label,
		p2_state_label,
		true
	)

func _refresh_side_combat_state(
	state: Dictionary,
	hype_bar: Range,
	hype_label: Label,
	state_label: Label,
	right_align: bool
) -> void:
	if hype_bar == null or hype_label == null or state_label == null:
		return
	var hype := clampf(float(state.get("hype", 0.0)), 0.0, 100.0)
	hype_bar.max_value = 100.0
	hype_bar.value = hype
	var hype_prefix := tr("HUD_HYPE")
	if hype_prefix == "HUD_HYPE":
		hype_prefix = "Hype"
	hype_label.text = "%s: %d" % [hype_prefix, int(round(hype))]
	var cooldowns_value: Variant = state.get("cooldowns", {})
	var cooldowns := {}
	if typeof(cooldowns_value) == TYPE_DICTIONARY:
		cooldowns = (cooldowns_value as Dictionary).duplicate(true)
	var cd_template := tr("HUD_COOLDOWN_ROW")
	if cd_template.find("%") == -1:
		cd_template = "CD A%s B%s C%s U%s"
	var cd_line := cd_template % [
		_format_cd_value(float(cooldowns.get("signature_a", 0.0))),
		_format_cd_value(float(cooldowns.get("signature_b", 0.0))),
		_format_cd_value(float(cooldowns.get("signature_c", 0.0))),
		_format_cd_value(float(cooldowns.get("ultimate", 0.0)))
	]
	var shield_max := maxf(1.0, float(state.get("shield_max", 100.0)))
	var shield_value := clampf(float(state.get("shield", shield_max)), 0.0, shield_max)
	var shield_percent := int(round((shield_value / shield_max) * 100.0))
	var shield_prefix := _tr_or_fallback("HUD_SHIELD", "SH")
	var shield_line := "%s %d" % [shield_prefix, shield_percent]
	var tags: Array[String] = []
	if bool(state.get("shield_broken", false)) or float(state.get("shield_break_seconds", 0.0)) > 0.0:
		tags.append(_tr_or_fallback("HUD_STATUS_SHIELD_BREAK", "BREAK"))
	if float(state.get("silence_seconds", 0.0)) > 0.0:
		tags.append(_tr_or_fallback("HUD_STATUS_SILENCE", "SIL"))
	if float(state.get("slow_seconds", 0.0)) > 0.0:
		tags.append(_tr_or_fallback("HUD_STATUS_SLOW", "SLOW"))
	if float(state.get("root_seconds", 0.0)) > 0.0:
		tags.append(_tr_or_fallback("HUD_STATUS_ROOT", "ROOT"))
	if float(state.get("install_seconds", 0.0)) > 0.0:
		tags.append(_tr_or_fallback("HUD_STATUS_BUFF", "BUFF"))
	var status_suffix := ""
	if not tags.is_empty():
		status_suffix = " | %s" % " ".join(tags)
	state_label.text = "%s | %s%s" % [cd_line, shield_line, status_suffix]
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if right_align else HORIZONTAL_ALIGNMENT_LEFT

func _refresh_character_profile_labels() -> void:
	if p1_profile_label:
		p1_profile_label.text = _format_character_profile_line(cached_p1_character_profile)
		p1_profile_label.tooltip_text = _resolve_archetype_hint(cached_p1_character_profile)
	if p2_profile_label:
		p2_profile_label.text = _format_character_profile_line(cached_p2_character_profile)
		p2_profile_label.tooltip_text = _resolve_archetype_hint(cached_p2_character_profile)

func _format_character_profile_line(profile: Dictionary) -> String:
	if profile.is_empty():
		return "-"
	var archetype_label := _resolve_archetype_label(profile)
	var signature_primary := str(profile.get("signature_primary", "")).strip_edges()
	var signature_alt := str(profile.get("signature_alt", "")).strip_edges()
	if signature_primary == "":
		signature_primary = _tr_or_fallback("HUD_SIGNATURE_PRIMARY_FALLBACK", "Signature A")
	if signature_alt == "":
		signature_alt = _tr_or_fallback("HUD_SIGNATURE_ALT_FALLBACK", "Signature B")
	var format_template := tr("HUD_PROFILE_ROW")
	if format_template.find("%") == -1:
		format_template = "%s | %s / %s"
	return format_template % [archetype_label, signature_primary, signature_alt]

func _resolve_archetype_label(profile: Dictionary) -> String:
	var key := str(profile.get("archetype_label_key", "")).strip_edges()
	if key == "":
		key = "ARCHETYPE_ALL_ROUNDER"
	return _tr_or_fallback(key, "All-rounder")

func _resolve_archetype_hint(profile: Dictionary) -> String:
	var key := str(profile.get("archetype_hint_key", "")).strip_edges()
	if key == "":
		key = "ARCHETYPE_HINT_ALL_ROUNDER"
	return _tr_or_fallback(key, "Balanced toolkit across ranges.")

func _format_cd_value(value: float) -> String:
	if value <= 0.0:
		return "0"
	if value < 1.0:
		return "%.1f" % value
	return str(int(ceil(value)))

func _refresh_training_panel() -> void:
	if training_panel == null:
		return
	training_panel.visible = training_panel_visible
	if not training_panel_visible:
		return
	training_title_label.text = tr("HUD_TRAINING_TITLE")
	training_log_title_label.text = tr("HUD_TRAINING_LOG_TITLE")
	if training_quick_hint_label:
		training_quick_hint_label.text = _tr_or_fallback(
			"HUD_TRAINING_QUICK_HINT",
			"Quick: WASD Move | Space Jump | H Guard | J/K/I/U Attack | L Dodge"
		)
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
	var attacker_key := str(cached_training_info.get("attacker_key", "p1"))
	var guard_mode := str(cached_training_info.get("guard_mode", "none"))
	var combo_count := int(cached_training_info.get("combo_count", 0))
	var is_counter := bool(cached_training_info.get("is_counter", false))
	var summary_parts: PackedStringArray = []
	summary_parts.append(_resolve_training_event_label(event_type))
	if attack_kind != "":
		summary_parts.append(_resolve_training_attack_label(attack_kind, attacker_key))
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
	var move_label := _resolve_training_attack_label(
		str(cached_training_info.get("attack_kind", "")),
		str(cached_training_info.get("attacker_key", "p1"))
	)
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

func _resolve_training_attack_label(attack_kind: String, attacker_key: String = "p1") -> String:
	if attack_kind in ["signature_a", "signature_b", "signature_c", "ultimate"]:
		var profile := cached_p1_character_profile
		if attacker_key == "p2":
			profile = cached_p2_character_profile
		var signature_names_value: Variant = profile.get("signature_names", {})
		if typeof(signature_names_value) == TYPE_DICTIONARY:
			var signature_names := signature_names_value as Dictionary
			var mapped_name := str(signature_names.get(attack_kind, "")).strip_edges()
			if mapped_name != "":
				return mapped_name
	match attack_kind:
		"light":
			return tr("HUD_TRAINING_MOVE_LIGHT")
		"heavy":
			return tr("HUD_TRAINING_MOVE_HEAVY")
		"special":
			return tr("HUD_TRAINING_MOVE_SPECIAL")
		"throw":
			return tr("HUD_TRAINING_MOVE_THROW")
		"signature_a":
			return _tr_or_fallback("HUD_TRAINING_MOVE_SIGNATURE_A", "SIGNATURE A")
		"signature_b":
			return _tr_or_fallback("HUD_TRAINING_MOVE_SIGNATURE_B", "SIGNATURE B")
		"signature_c":
			return _tr_or_fallback("HUD_TRAINING_MOVE_SIGNATURE_C", "SIGNATURE C")
		"ultimate":
			return _tr_or_fallback("HUD_TRAINING_MOVE_ULTIMATE", "ULTIMATE")
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
	var move_label := _resolve_training_attack_label(
		str(entry.get("attack_kind", "")),
		str(entry.get("attacker_key", "p1"))
	)
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
	var adv_short := _tr_or_fallback("HUD_TRAINING_LOG_ADV_SHORT", "Adv")
	var damage_short := _tr_or_fallback("HUD_TRAINING_LOG_DAMAGE_SHORT", "D")
	var combo_short := _tr_or_fallback("HUD_TRAINING_LOG_COMBO_SHORT", "C")
	var hp_short := _tr_or_fallback("HUD_TRAINING_LOG_HP_SHORT", "HP")
	var chip_short := _tr_or_fallback("HUD_TRAINING_LOG_CHIP_SHORT", "Chip")
	var line := "%s %s" % [event_label, move_label]
	if block_tag != "":
		line += " %s" % block_tag
	line += " %s %s" % [adv_short, adv_text]
	line += " %s%d %s%d %s%d>%d" % [damage_short, damage_total, combo_short, combo_damage, hp_short, hp_before, hp_after]
	if chip_damage > 0:
		line += " %s%d" % [chip_short, chip_damage]
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

func _on_back_menu_pressed() -> void:
	menu_requested.emit()

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

func _tr_or_fallback(key: String, fallback: String) -> String:
	var value := tr(key)
	if value == key:
		return fallback
	return value

func _format_stat(template: String, fallback_template: String, value: int) -> String:
	if template.find("%") == -1:
		return fallback_template % value
	return template % value

func _ensure_translations_registered() -> void:
	LocalizationRegistryStore.ensure_registered()

class_name HudCorners
extends RefCounted

const MARGIN := 18.0
const DIALOGUE_GAP := 16.0
const CARD_TOP := 16.0
const CARD_MAX_WIDTH := 220.0
const CARD_HEIGHT := 124.0
const TIMER_WIDTH := 132.0
const TIMER_HEIGHT := 32.0
const TIMER_TOP := 14.0
const TIMER_FONT := 16
const PORTRAIT := 44.0
const NAME_FONT := 14
const PERCENT_FONT := 34
const SECONDARY_FONT := 11
const OUTLINE_SIZE := 4
const POP_SCALE := 0.22
const SHAKE_PX := 5.0
const POP_DECAY_PER_SECOND := 3.4
const POP_DURATION_SECONDS := 1.0 / POP_DECAY_PER_SECOND
const PERCENT_WHITE := Color(0.95, 0.96, 0.98)
const PERCENT_GOLD := Color(1.0, 0.84, 0.22)
const PERCENT_ORANGE := Color(1.0, 0.46, 0.08)
const PERCENT_RED := Color(0.96, 0.16, 0.12)
const RAMP_GOLD := 0.35
const RAMP_ORANGE := 0.70
const DIALOGUE_MAX_WIDTH := 760.0
const DIALOGUE_TOP := 48.0
const DIALOGUE_HEIGHT := 34.0

static func percent_color(percent: int) -> Color:
	var amount := clampf(float(maxi(0, percent)) / 100.0, 0.0, 1.0)
	if amount < RAMP_GOLD:
		return PERCENT_WHITE.lerp(PERCENT_GOLD, amount / RAMP_GOLD)
	if amount < RAMP_ORANGE:
		return PERCENT_GOLD.lerp(PERCENT_ORANGE, (amount - RAMP_GOLD) / (RAMP_ORANGE - RAMP_GOLD))
	var span := maxf(0.001, 1.0 - RAMP_ORANGE)
	return PERCENT_ORANGE.lerp(PERCENT_RED, (amount - RAMP_ORANGE) / span)

static func portrait_color(fighter_name: String) -> Color:
	var tone := absi(fighter_name.hash()) % 3
	if tone == 0:
		return Color(0.18, 0.32, 0.58)
	if tone == 1:
		return Color(0.52, 0.24, 0.16)
	return Color(0.16, 0.40, 0.34)

static func secondary_line(state: Dictionary, labels: Dictionary) -> String:
	var parts: PackedStringArray = PackedStringArray()
	var hype := int(round(clampf(float(state.get("hype", 0.0)), 0.0, 100.0)))
	if hype > 0:
		parts.append("%s %d" % [str(labels.get("hype", "Hype")), hype])
	var cooldowns_value: Variant = state.get("cooldowns", {})
	var cooldowns := {}
	if typeof(cooldowns_value) == TYPE_DICTIONARY:
		cooldowns = cooldowns_value
	var cd_parts: PackedStringArray = PackedStringArray()
	var any_cooldown := false
	for key in ["signature_a", "signature_b", "signature_c", "ultimate"]:
		var remaining := maxf(0.0, float(cooldowns.get(key, 0.0)))
		if remaining > 0.05:
			any_cooldown = true
		cd_parts.append(_format_seconds(remaining))
	if any_cooldown:
		var template := str(labels.get("cooldown", "CD A%s B%s DS%s U%s"))
		if template.find("%") == -1:
			template = "CD A%s B%s DS%s U%s"
		parts.append(template % [cd_parts[0], cd_parts[1], cd_parts[2], cd_parts[3]])
	var shield_max := maxf(1.0, float(state.get("shield_max", 100.0)))
	var shield_value := clampf(float(state.get("shield", shield_max)), 0.0, shield_max)
	var shield_percent := int(round((shield_value / shield_max) * 100.0))
	if shield_percent < 100 or bool(state.get("shield_broken", false)):
		parts.append("%s %d" % [str(labels.get("shield", "SH")), shield_percent])
	var charges := maxi(0, int(state.get("loadout_item_charges", 0)))
	var item_cooldown := maxf(0.0, float(state.get("loadout_item_cooldown", 0.0)))
	if charges > 0 or item_cooldown > 0.05:
		if item_cooldown > 0.05:
			parts.append("%s %d %s" % [str(labels.get("item", "Item")), charges, _format_seconds(item_cooldown)])
		else:
			parts.append("%s %d" % [str(labels.get("item", "Item")), charges])
	var statuses: PackedStringArray = PackedStringArray()
	if bool(state.get("shield_broken", false)) or float(state.get("shield_break_seconds", 0.0)) > 0.0:
		statuses.append(str(labels.get("break", "BREAK")))
	if float(state.get("silence_seconds", 0.0)) > 0.0:
		statuses.append(str(labels.get("silence", "SIL")))
	if float(state.get("slow_seconds", 0.0)) > 0.0:
		statuses.append(str(labels.get("slow", "SLOW")))
	if float(state.get("root_seconds", 0.0)) > 0.0:
		statuses.append(str(labels.get("root", "ROOT")))
	if float(state.get("install_seconds", 0.0)) > 0.0:
		statuses.append(str(labels.get("buff", "BUFF")))
	if not statuses.is_empty():
		parts.append(" ".join(statuses))
	return "  ".join(parts)

static func layout(viewport: Vector2) -> Dictionary:
	var size := viewport
	if size.x < 2.0:
		size.x = 1280.0
	if size.y < 2.0:
		size.y = 720.0
	var card_w := minf(CARD_MAX_WIDTH, _side_width(size.x))
	var card := Rect2(MARGIN, CARD_TOP, card_w, CARD_HEIGHT)
	return {
		"timer": Rect2((size.x - TIMER_WIDTH) * 0.5, TIMER_TOP, TIMER_WIDTH, TIMER_HEIGHT),
		"timer_size": TIMER_FONT,
		"dialogue": _dialogue_rect(size.x),
		"p1": _cluster(card, true),
		"p2": _cluster(Rect2(size.x - MARGIN - card_w, CARD_TOP, card_w, CARD_HEIGHT), false)
	}

static func _side_width(viewport_w: float) -> float:
	var dialogue := _dialogue_rect(viewport_w)
	var from_dialogue := dialogue.position.x - DIALOGUE_GAP - MARGIN
	var pause_left := 160.0 + maxf(0.0, viewport_w - 640.0) * 0.5
	var from_pause := pause_left - DIALOGUE_GAP - MARGIN
	return maxf(96.0, minf(from_dialogue, from_pause))

static func _dialogue_rect(viewport_w: float) -> Rect2:
	var reserved := (MARGIN + CARD_MAX_WIDTH + DIALOGUE_GAP) * 2.0
	var width := clampf(viewport_w - reserved, 280.0, DIALOGUE_MAX_WIDTH)
	var left := maxf(MARGIN, (viewport_w - width) * 0.5)
	return Rect2(left, DIALOGUE_TOP, width, DIALOGUE_HEIGHT)

static func _cluster(card: Rect2, portrait_on_left: bool) -> Dictionary:
	var pad := 10.0
	var portrait_rect := Rect2(
		card.position.x + pad if portrait_on_left else card.end.x - pad - PORTRAIT,
		card.position.y + (card.size.y - PORTRAIT) * 0.5,
		PORTRAIT,
		PORTRAIT
	)
	var text_left := portrait_rect.end.x + 8.0 if portrait_on_left else card.position.x + pad
	var text_right := card.end.x - pad if portrait_on_left else portrait_rect.position.x - 8.0
	var text_w := maxf(24.0, text_right - text_left)
	var name_h := 18.0
	var stocks_h := 16.0
	var secondary_h := 16.0
	var y := card.position.y + 6.0
	var percent_h := maxf(28.0, card.size.y - 12.0 - name_h - stocks_h - secondary_h)
	return {
		"card": card,
		"portrait": portrait_rect,
		"name": Rect2(text_left, y, text_w, name_h),
		"percent": Rect2(text_left, y + name_h - 2.0, text_w, percent_h),
		"stocks": Rect2(text_left, y + name_h + percent_h - 4.0, text_w, stocks_h),
		"secondary": Rect2(text_left, card.end.y - 6.0 - secondary_h, text_w, secondary_h),
		"name_size": NAME_FONT,
		"percent_size": PERCENT_FONT,
		"secondary_size": SECONDARY_FONT,
		"align_right": not portrait_on_left
	}

static func _format_seconds(value: float) -> String:
	if value <= 0.05:
		return "0"
	if value < 10.0:
		var tenths := int(round(value * 10.0))
		if tenths % 10 == 0:
			return str(int(tenths / 10.0))
		return "%.1f" % value
	return str(int(ceil(value)))

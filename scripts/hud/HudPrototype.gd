class_name HudPrototype
extends RefCounted

const CARDS := "cards"
const CORNERS := "corners"
const MARQUEE := "marquee"
const IDS: Array[String] = [CARDS, CORNERS, MARQUEE]

static func parse(raw: String) -> Dictionary:
	var id := raw.strip_edges().to_lower()
	if id == "":
		return {"ok": true, "id": ""}
	if IDS.has(id):
		return {"ok": true, "id": id}
	return {"ok": false, "error": "hud must be cards, corners, or marquee"}

static func percent_color(percent: int) -> Color:
	var amount := clampf(float(maxi(0, percent)) / 100.0, 0.0, 1.0)
	var white := Color(0.95, 0.96, 0.98)
	var gold := Color(1.0, 0.84, 0.22)
	var orange := Color(1.0, 0.46, 0.08)
	var red := Color(0.96, 0.16, 0.12)
	if amount < 0.35:
		return white.lerp(gold, amount / 0.35)
	if amount < 0.7:
		return gold.lerp(orange, (amount - 0.35) / 0.35)
	return orange.lerp(red, (amount - 0.7) / 0.3)

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

static func layout(id: String, viewport: Vector2) -> Dictionary:
	var size := viewport
	if size.x < 2.0:
		size.x = 1280.0
	if size.y < 2.0:
		size.y = 720.0
	match id:
		CARDS:
			return _cards(size)
		CORNERS:
			return _corners(size)
		_:
			return _marquee(size)

static func _cards(size: Vector2) -> Dictionary:
	var margin := 28.0
	var card_w := minf(360.0, (size.x - margin * 3.0) * 0.5)
	var card_h := 136.0
	var card_y := size.y - margin - card_h
	var timer := _timer_rect(size, 168.0, 40.0, 16.0)
	return {
		"band": Rect2(),
		"show_band": false,
		"timer": timer,
		"timer_size": 22,
		"tag": Rect2(16.0, 8.0, 140.0, 18.0),
		"p1": _cluster(Rect2(margin, card_y, card_w, card_h), true, 78.0, 16, 40, 12),
		"p2": _cluster(Rect2(size.x - margin - card_w, card_y, card_w, card_h), false, 78.0, 16, 40, 12)
	}

static func _corners(size: Vector2) -> Dictionary:
	var margin := 18.0
	var dialogue_half := minf(380.0, (size.x - 80.0) * 0.5)
	var inner := maxf(96.0, size.x * 0.5 - dialogue_half - margin - 16.0)
	var card_w := minf(220.0, inner)
	var card_h := 146.0
	var timer := _timer_rect(size, 132.0, 32.0, 14.0)
	return {
		"band": Rect2(),
		"show_band": false,
		"timer": timer,
		"timer_size": 16,
		"tag": Rect2(margin, size.y - 26.0, 120.0, 16.0),
		"p1": _cluster(Rect2(margin, 16.0, card_w, card_h), true, 44.0, 14, 34, 11),
		"p2": _cluster(Rect2(size.x - margin - card_w, 16.0, card_w, card_h), false, 44.0, 14, 34, 11)
	}

static func _marquee(size: Vector2) -> Dictionary:
	var band_h := 156.0
	var band := Rect2(0.0, size.y - band_h, size.x, band_h)
	var margin := 32.0
	var card_w := minf(460.0, (size.x - margin * 3.0) * 0.5)
	var card_h := band_h - 28.0
	var card_y := band.position.y + 16.0
	var timer := _timer_rect(size, 180.0, 42.0, maxf(16.0, band.position.y - 52.0))
	return {
		"band": band,
		"show_band": true,
		"timer": timer,
		"timer_size": 24,
		"tag": Rect2(16.0, 8.0, 160.0, 18.0),
		"p1": _cluster(Rect2(margin, card_y, card_w, card_h), true, 78.0, 16, 42, 12),
		"p2": _cluster(Rect2(size.x - margin - card_w, card_y, card_w, card_h), false, 78.0, 16, 42, 12)
	}

static func _timer_rect(size: Vector2, width: float, height: float, top: float) -> Rect2:
	return Rect2((size.x - width) * 0.5, top, width, height)

static func _cluster(
	card: Rect2,
	portrait_on_left: bool,
	portrait: float,
	name_size: int,
	percent_size: int,
	secondary_size: int
) -> Dictionary:
	var pad := 10.0
	var portrait_rect := Rect2(
		card.position.x + pad if portrait_on_left else card.end.x - pad - portrait,
		card.position.y + (card.size.y - portrait) * 0.5,
		portrait,
		portrait
	)
	var text_left := portrait_rect.end.x + 8.0 if portrait_on_left else card.position.x + pad
	var text_right := card.end.x - pad if portrait_on_left else portrait_rect.position.x - 8.0
	var text_w := maxf(24.0, text_right - text_left)
	var name_h := 20.0
	var stocks_h := 16.0
	var secondary_h := 16.0
	var y := card.position.y + 8.0
	var percent_h := maxf(28.0, card.size.y - 16.0 - name_h - stocks_h - secondary_h)
	return {
		"card": card,
		"portrait": portrait_rect,
		"name": Rect2(text_left, y, text_w, name_h),
		"percent": Rect2(text_left, y + name_h - 2.0, text_w, percent_h),
		"stocks": Rect2(text_left, y + name_h + percent_h - 4.0, text_w, stocks_h),
		"secondary": Rect2(text_left, card.end.y - 8.0 - secondary_h, text_w, secondary_h),
		"name_size": name_size,
		"percent_size": percent_size,
		"secondary_size": secondary_size,
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

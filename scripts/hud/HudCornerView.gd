extends Control

const HudCornersScript := preload("res://scripts/hud/HudCorners.gd")
const STOCK_CAP := 7

var _p1_pop := 0.0
var _p2_pop := 0.0
var _p1_percent := -1
var _p2_percent := -1
var _p1_layout := {}
var _p2_layout := {}
var _p1_card: Panel
var _p2_card: Panel
var _p1_portrait: Panel
var _p2_portrait: Panel
var _p1_mark: Label
var _p2_mark: Label
var _p1_name: Label
var _p2_name: Label
var _p1_percent_label: Label
var _p2_percent_label: Label
var _p1_secondary: Label
var _p2_secondary: Label
var _p1_stocks: Array[ColorRect] = []
var _p2_stocks: Array[ColorRect] = []

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0
	_p1_card = _make_panel("P1Card")
	_p2_card = _make_panel("P2Card")
	_p1_portrait = _make_panel("P1Portrait")
	_p2_portrait = _make_panel("P2Portrait")
	_p1_mark = _make_label_on(_p1_portrait, "Mark", 22, HORIZONTAL_ALIGNMENT_CENTER)
	_p2_mark = _make_label_on(_p2_portrait, "Mark", 22, HORIZONTAL_ALIGNMENT_CENTER)
	for mark in [_p1_mark, _p2_mark]:
		mark.set_anchors_preset(Control.PRESET_FULL_RECT)
		mark.offset_left = 0.0
		mark.offset_top = 0.0
		mark.offset_right = 0.0
		mark.offset_bottom = 0.0
	_p1_name = _make_label("P1Name", HudCornersScript.NAME_FONT, HORIZONTAL_ALIGNMENT_LEFT)
	_p2_name = _make_label("P2Name", HudCornersScript.NAME_FONT, HORIZONTAL_ALIGNMENT_RIGHT)
	_p1_percent_label = _make_label("P1Percent", HudCornersScript.PERCENT_FONT, HORIZONTAL_ALIGNMENT_LEFT)
	_p2_percent_label = _make_label("P2Percent", HudCornersScript.PERCENT_FONT, HORIZONTAL_ALIGNMENT_RIGHT)
	_p1_secondary = _make_label("P1Secondary", HudCornersScript.SECONDARY_FONT, HORIZONTAL_ALIGNMENT_LEFT)
	_p2_secondary = _make_label("P2Secondary", HudCornersScript.SECONDARY_FONT, HORIZONTAL_ALIGNMENT_RIGHT)
	_p1_stocks = _make_stock_row("P1Stock")
	_p2_stocks = _make_stock_row("P2Stock")
	for label in [_p1_name, _p2_name, _p1_percent_label, _p2_percent_label, _p1_mark, _p2_mark]:
		label.add_theme_constant_override("outline_size", HudCornersScript.OUTLINE_SIZE)
		label.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.03, 0.92))
	_style_cards()
	set_process(false)

func present(payload: Dictionary) -> void:
	if not is_node_ready():
		return
	visible = true
	var viewport: Vector2 = payload.get("viewport", Vector2(1280.0, 720.0))
	var placed: Dictionary = HudCornersScript.layout(viewport)
	var sides: Dictionary = payload.get("sides", {})
	_present_side("p1", placed.get("p1", {}), sides.get("p1", {}))
	_present_side("p2", placed.get("p2", {}), sides.get("p2", {}))
	_apply_pop()

func timer_rect(viewport: Vector2) -> Rect2:
	var placed: Dictionary = HudCornersScript.layout(viewport)
	return placed.get("timer", Rect2()) as Rect2

func timer_font_size() -> int:
	return HudCornersScript.TIMER_FONT

func dialogue_rect(viewport: Vector2) -> Rect2:
	var placed: Dictionary = HudCornersScript.layout(viewport)
	return placed.get("dialogue", Rect2()) as Rect2

func _process(delta: float) -> void:
	var moving := false
	if _p1_pop > 0.0:
		_p1_pop = maxf(0.0, _p1_pop - delta / HudCornersScript.POP_DURATION_SECONDS)
		moving = true
	if _p2_pop > 0.0:
		_p2_pop = maxf(0.0, _p2_pop - delta / HudCornersScript.POP_DURATION_SECONDS)
		moving = true
	_apply_pop()
	if not moving:
		set_process(false)

func _present_side(side: String, cluster: Dictionary, data: Dictionary) -> void:
	var card: Panel = _p1_card if side == "p1" else _p2_card
	var portrait: Panel = _p1_portrait if side == "p1" else _p2_portrait
	var mark: Label = _p1_mark if side == "p1" else _p2_mark
	var name_label: Label = _p1_name if side == "p1" else _p2_name
	var percent_label: Label = _p1_percent_label if side == "p1" else _p2_percent_label
	var secondary: Label = _p1_secondary if side == "p1" else _p2_secondary
	var stocks: Array[ColorRect] = _p1_stocks if side == "p1" else _p2_stocks
	var align_right := bool(cluster.get("align_right", false))
	var alignment := HORIZONTAL_ALIGNMENT_RIGHT if align_right else HORIZONTAL_ALIGNMENT_LEFT
	_place(card, cluster.get("card", Rect2()) as Rect2)
	_place(portrait, cluster.get("portrait", Rect2()) as Rect2)
	_place(name_label, cluster.get("name", Rect2()) as Rect2)
	_place(secondary, cluster.get("secondary", Rect2()) as Rect2)
	var fighter_name := str(data.get("name", "")).strip_edges()
	if fighter_name == "":
		fighter_name = "P1" if side == "p1" else "P2"
	name_label.text = fighter_name
	name_label.horizontal_alignment = alignment
	name_label.add_theme_font_size_override("font_size", int(cluster.get("name_size", HudCornersScript.NAME_FONT)))
	mark.text = fighter_name.substr(0, 1)
	_style_portrait(portrait, HudCornersScript.portrait_color(fighter_name))
	var percent := maxi(0, int(data.get("percent", 0)))
	percent_label.text = "%d%%" % percent
	percent_label.horizontal_alignment = alignment
	percent_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var percent_rect: Rect2 = cluster.get("percent", Rect2()) as Rect2
	var percent_size := mini(int(cluster.get("percent_size", HudCornersScript.PERCENT_FONT)), maxi(18, int(percent_rect.size.y * 0.9)))
	percent_label.add_theme_font_size_override("font_size", percent_size)
	percent_label.add_theme_color_override("font_color", HudCornersScript.percent_color(percent))
	var line := HudCornersScript.secondary_line(data.get("combat", {}), _secondary_labels())
	secondary.text = line
	secondary.visible = line != ""
	secondary.horizontal_alignment = alignment
	secondary.add_theme_font_size_override("font_size", int(cluster.get("secondary_size", HudCornersScript.SECONDARY_FONT)))
	_place_stocks(stocks, cluster.get("stocks", Rect2()) as Rect2, int(data.get("stocks", 0)), int(data.get("stock_cap", 3)), align_right)
	_note_percent(side, percent, cluster)

func _note_percent(side: String, percent: int, cluster: Dictionary) -> void:
	if side == "p1":
		if _p1_percent >= 0 and percent > _p1_percent:
			_p1_pop = 1.0
			set_process(true)
		_p1_percent = percent
		_p1_layout = cluster
	else:
		if _p2_percent >= 0 and percent > _p2_percent:
			_p2_pop = 1.0
			set_process(true)
		_p2_percent = percent
		_p2_layout = cluster

func _apply_pop() -> void:
	_place_percent(_p1_percent_label, _p1_layout, _p1_pop)
	_place_percent(_p2_percent_label, _p2_layout, _p2_pop)

func _place_percent(label: Label, cluster: Dictionary, pop: float) -> void:
	if label == null:
		return
	var rect: Rect2 = cluster.get("percent", Rect2()) as Rect2
	var align_right := bool(cluster.get("align_right", false))
	var wobble := sin(pop * PI * 3.5) * HudCornersScript.SHAKE_PX * pop
	var shift := -wobble if align_right else wobble
	label.offset_left = rect.position.x + shift
	label.offset_top = rect.position.y
	label.offset_right = rect.position.x + rect.size.x + shift
	label.offset_bottom = rect.position.y + rect.size.y
	label.pivot_offset = Vector2(rect.size.x if align_right else 0.0, rect.size.y * 0.5)
	label.scale = Vector2.ONE * (1.0 + HudCornersScript.POP_SCALE * pop)

func _place_stocks(icons: Array[ColorRect], rect: Rect2, stocks: int, stock_cap: int, align_right: bool) -> void:
	var cap := clampi(maxi(stock_cap, stocks), 1, STOCK_CAP)
	var filled := clampi(stocks, 0, cap)
	var icon := 13.0
	var gap := 5.0
	var row := cap * icon + float(cap - 1) * gap
	var origin := rect.end.x - row if align_right else rect.position.x
	var top := rect.position.y + maxf(0.0, (rect.size.y - icon) * 0.5)
	for index in STOCK_CAP:
		var swatch: ColorRect = icons[index]
		if index >= cap:
			swatch.visible = false
			continue
		swatch.visible = true
		swatch.offset_left = origin + float(index) * (icon + gap)
		swatch.offset_top = top
		swatch.offset_right = swatch.offset_left + icon
		swatch.offset_bottom = top + icon
		if index < filled:
			swatch.color = Color(0.96, 0.90, 0.72, 1.0)
		else:
			swatch.color = Color(0.22, 0.18, 0.16, 0.55)

func _make_panel(node_name: String) -> Panel:
	var panel := Panel.new()
	panel.name = node_name
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	return panel

func _make_label(node_name: String, font_size: int, alignment: HorizontalAlignment) -> Label:
	return _make_label_on(self, node_name, font_size, alignment)

func _make_label_on(parent: Node, node_name: String, font_size: int, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.name = node_name
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.clip_text = true
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.96, 0.97, 1.0))
	parent.add_child(label)
	return label

func _make_stock_row(prefix: String) -> Array[ColorRect]:
	var icons: Array[ColorRect] = []
	for index in STOCK_CAP:
		var swatch := ColorRect.new()
		swatch.name = "%s%d" % [prefix, index]
		swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
		swatch.visible = false
		add_child(swatch)
		icons.append(swatch)
	return icons

func _style_cards() -> void:
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(6)
	style.bg_color = Color(0.02, 0.03, 0.05, 0.55)
	style.border_color = Color(0.92, 0.94, 0.98, 0.45)
	style.set_border_width_all(1)
	_p1_card.add_theme_stylebox_override("panel", style)
	_p2_card.add_theme_stylebox_override("panel", style.duplicate())

func _style_portrait(panel: Panel, fill: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = Color(0.96, 0.92, 0.84, 0.9)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", style)

func _secondary_labels() -> Dictionary:
	return {
		"hype": _tr_or("HUD_HYPE", "Hype"),
		"cooldown": _tr_or("HUD_COOLDOWN_ROW", "CD A%s B%s DS%s U%s"),
		"shield": _tr_or("HUD_SHIELD", "SH"),
		"item": _tr_or("HUD_ITEM", "Item"),
		"break": _tr_or("HUD_STATUS_SHIELD_BREAK", "BREAK"),
		"silence": _tr_or("HUD_STATUS_SILENCE", "SIL"),
		"slow": _tr_or("HUD_STATUS_SLOW", "SLOW"),
		"root": _tr_or("HUD_STATUS_ROOT", "ROOT"),
		"buff": _tr_or("HUD_STATUS_BUFF", "BUFF")
	}

func _tr_or(key: String, fallback: String) -> String:
	var text := tr(key)
	if text == key:
		return fallback
	return text

func _place(control: Control, rect: Rect2) -> void:
	if control == null:
		return
	control.offset_left = rect.position.x
	control.offset_top = rect.position.y
	control.offset_right = rect.position.x + rect.size.x
	control.offset_bottom = rect.position.y + rect.size.y

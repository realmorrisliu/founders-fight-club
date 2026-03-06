class_name UiSkin
extends RefCounted

static func is_headless_runtime() -> bool:
	return OS.has_feature("headless") or DisplayServer.get_name() == "headless"

static func load_texture_or_placeholder(path: String, size: Vector2i, fill: Color) -> Texture2D:
	if not is_headless_runtime():
		var loaded = load(path)
		if loaded is Texture2D:
			return loaded as Texture2D
	return make_solid_texture(size, fill)

static func make_solid_texture(size: Vector2i, fill: Color) -> Texture2D:
	var safe_size := Vector2i(maxi(1, size.x), maxi(1, size.y))
	var image := Image.create(safe_size.x, safe_size.y, false, Image.FORMAT_RGBA8)
	image.fill(fill)
	return ImageTexture.create_from_image(image)

static func ensure_backdrop(
	parent: Control,
	node_name: String,
	texture: Texture2D,
	modulate: Color = Color(1, 1, 1, 1)
) -> TextureRect:
	if parent == null:
		return null
	var backdrop := parent.get_node_or_null(node_name) as TextureRect
	if backdrop == null:
		backdrop = TextureRect.new()
		backdrop.name = node_name
		parent.add_child(backdrop)
		parent.move_child(backdrop, 0)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.texture = texture
	backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	backdrop.stretch_mode = TextureRect.STRETCH_SCALE
	backdrop.modulate = modulate
	return backdrop

static func clear_panel_skin(panel: Panel) -> void:
	if panel == null:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = Color(0, 0, 0, 0)
	panel.add_theme_stylebox_override("panel", style)

static func apply_button_skin(button: BaseButton, palette: Dictionary) -> void:
	if button == null:
		return
	var normal_fill := palette.get("normal_fill", Color(0.10, 0.18, 0.30, 0.95)) as Color
	var hover_fill := palette.get("hover_fill", Color(0.14, 0.24, 0.40, 0.98)) as Color
	var pressed_fill := palette.get("pressed_fill", Color(0.08, 0.14, 0.24, 0.98)) as Color
	var disabled_fill := palette.get("disabled_fill", Color(0.12, 0.14, 0.18, 0.80)) as Color
	var border := palette.get("border", Color(0.37, 0.61, 0.94, 1.0)) as Color
	var border_hover := palette.get("border_hover", border.lightened(0.14)) as Color
	var border_pressed := palette.get("border_pressed", border.darkened(0.08)) as Color
	var disabled_border := palette.get("disabled_border", Color(0.32, 0.36, 0.46, 0.82)) as Color
	var font_color := palette.get("font_color", Color(0.96, 0.98, 1.0, 1.0)) as Color
	var font_disabled := palette.get("font_disabled", Color(0.68, 0.74, 0.82, 0.92)) as Color
	button.add_theme_stylebox_override("normal", _make_button_stylebox(normal_fill, border))
	button.add_theme_stylebox_override("hover", _make_button_stylebox(hover_fill, border_hover))
	button.add_theme_stylebox_override("pressed", _make_button_stylebox(pressed_fill, border_pressed))
	button.add_theme_stylebox_override("focus", _make_button_stylebox(hover_fill, border_hover))
	button.add_theme_stylebox_override("disabled", _make_button_stylebox(disabled_fill, disabled_border))
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", font_color)
	button.add_theme_color_override("font_pressed_color", font_color)
	button.add_theme_color_override("font_focus_color", font_color)
	button.add_theme_color_override("font_disabled_color", font_disabled)

static func _make_button_stylebox(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style

extends Node2D

const BACKGROUND_TEXTURE_PATH := "res://assets/sprites/arena/arena_bg.png"
const FLOOR_TEXTURE_PATH := "res://assets/sprites/arena/arena_floor.png"
const BACKGROUND_PLACEHOLDER_SIZE := Vector2i(960, 540)
const FLOOR_PLACEHOLDER_SIZE := Vector2i(960, 56)
const BACKGROUND_TARGET_POSITION := Vector2(-620.0, -220.0)
const BACKGROUND_TARGET_SIZE := Vector2(2140.0, 900.0)
const FLOOR_TARGET_POSITION := Vector2(-620.0, 334.0)
const FLOOR_TARGET_SIZE := Vector2(2140.0, 360.0)
const PLATFORM_COLLISION_LAYER := 2
const STAGE_GLOW_CENTER := Vector2(450.0, 216.0)
const STAGE_WARM_GLOW_CENTER := Vector2(450.0, 272.0)
const DRESSING_LINEAR_FILTER := CanvasItem.TEXTURE_FILTER_LINEAR
const COOL_GLOW_COLOR := Color(0.32, 0.72, 1.0, 0.48)
const WARM_GLOW_COLOR := Color(1.0, 0.62, 0.24, 0.34)
const FLOOR_RIM_COLOR := Color(0.46, 0.84, 1.0, 0.42)
const FRONT_FOG_COLOR := Color(0.04, 0.10, 0.16, 0.42)
const TOP_VIGNETTE_COLOR := Color(0.03, 0.06, 0.10, 0.58)
const NEON_RAIL_COLOR := Color(0.88, 0.96, 1.0, 0.32)
const STAGE_PULSE_SPEED := 0.88

@export var side_platforms_enabled := true

@onready var background := $Background
@onready var floor_visual := $FloorVisual
@onready var platform_left := $PlatformLeft as StaticBody2D
@onready var platform_right := $PlatformRight as StaticBody2D

var cool_glow: Sprite2D
var warm_glow: Sprite2D
var crowd_band: Sprite2D
var floor_rim: Sprite2D
var front_fog: Sprite2D
var top_vignette: Sprite2D
var left_frame: Sprite2D
var right_frame: Sprite2D
var neon_rail: Sprite2D
var backdrop_layer: CanvasLayer
var backdrop_rect: TextureRect
var additive_material: CanvasItemMaterial
var stage_fx_time := 0.0
var backdrop_viewport_size := Vector2i.ZERO

func _ready() -> void:
	if background:
		background.texture = _load_texture_or_placeholder(
			BACKGROUND_TEXTURE_PATH,
			BACKGROUND_PLACEHOLDER_SIZE,
			Color(0.08, 0.10, 0.17, 1.0)
		)
	if floor_visual:
		floor_visual.texture = _load_texture_or_placeholder(
			FLOOR_TEXTURE_PATH,
			FLOOR_PLACEHOLDER_SIZE,
			Color(0.18, 0.19, 0.24, 1.0)
		)
	_fit_sprite(background, BACKGROUND_TARGET_POSITION, BACKGROUND_TARGET_SIZE)
	_fit_sprite(floor_visual, FLOOR_TARGET_POSITION, FLOOR_TARGET_SIZE)
	_ensure_window_backdrop()
	_ensure_stage_dressing()
	_apply_side_platform_state()

func set_side_platforms_enabled(enabled: bool) -> void:
	side_platforms_enabled = enabled
	_apply_side_platform_state()

func _load_texture_or_placeholder(path: String, size: Vector2i, fill: Color) -> Texture2D:
	if not _is_headless_runtime():
		var loaded = load(path)
		if loaded is Texture2D:
			return loaded as Texture2D
	return _make_solid_texture(size, fill)

func _is_headless_runtime() -> bool:
	return OS.has_feature("headless") or DisplayServer.get_name() == "headless"

func _fit_sprite(sprite: Sprite2D, target_position: Vector2, target_size: Vector2) -> void:
	if sprite == null or sprite.texture == null:
		return
	var texture_size := sprite.texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	sprite.position = target_position
	sprite.scale = Vector2(
		target_size.x / texture_size.x,
		target_size.y / texture_size.y
	)

func _process(delta: float) -> void:
	stage_fx_time += maxf(0.0, delta)
	_refresh_window_backdrop_if_needed()
	if cool_glow:
		var alpha := 0.44 + sin(stage_fx_time * STAGE_PULSE_SPEED) * 0.05
		cool_glow.modulate = Color(COOL_GLOW_COLOR.r, COOL_GLOW_COLOR.g, COOL_GLOW_COLOR.b, alpha)
	if warm_glow:
		var alpha := 0.28 + sin(stage_fx_time * 1.18 + 0.8) * 0.05
		warm_glow.modulate = Color(WARM_GLOW_COLOR.r, WARM_GLOW_COLOR.g, WARM_GLOW_COLOR.b, alpha)
	if floor_rim:
		var alpha := 0.34 + sin(stage_fx_time * 1.42 + 0.3) * 0.04
		floor_rim.modulate = Color(FLOOR_RIM_COLOR.r, FLOOR_RIM_COLOR.g, FLOOR_RIM_COLOR.b, alpha)
	if neon_rail:
		var alpha := 0.20 + sin(stage_fx_time * 2.10 + 1.4) * 0.05
		neon_rail.modulate = Color(NEON_RAIL_COLOR.r, NEON_RAIL_COLOR.g, NEON_RAIL_COLOR.b, alpha)

func _ensure_stage_dressing() -> void:
	if additive_material == null:
		additive_material = CanvasItemMaterial.new()
		additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	left_frame = _configure_dressing_sprite(
		"LeftFrame",
		_make_side_frame_texture(Vector2i(140, 900), true),
		Vector2(-640.0, -220.0),
		Vector2(140.0, 900.0),
		false,
		-11,
		Color(1.0, 1.0, 1.0, 0.22),
		false
	)
	right_frame = _configure_dressing_sprite(
		"RightFrame",
		_make_side_frame_texture(Vector2i(140, 900), false),
		Vector2(1520.0, -220.0),
		Vector2(140.0, 900.0),
		false,
		-11,
		Color(1.0, 1.0, 1.0, 0.22),
		false
	)
	cool_glow = _configure_dressing_sprite(
		"BackdropGlow",
		_make_radial_glow_texture(Vector2i(980, 640), Color(1.0, 1.0, 1.0, 1.0), 0.12, 0.52),
		STAGE_GLOW_CENTER,
		Vector2(980.0, 640.0),
		true,
		-15,
		COOL_GLOW_COLOR,
		true
	)
	warm_glow = _configure_dressing_sprite(
		"WarmGlow",
		_make_radial_glow_texture(Vector2i(660, 380), Color(1.0, 1.0, 1.0, 1.0), 0.10, 0.54),
		STAGE_WARM_GLOW_CENTER,
		Vector2(660.0, 380.0),
		true,
		-14,
		WARM_GLOW_COLOR,
		true
	)
	crowd_band = _configure_dressing_sprite(
		"CrowdBand",
		_make_crowd_band_texture(Vector2i(2140, 176)),
		Vector2(-620.0, 174.0),
		Vector2(2140.0, 176.0),
		false,
		-4,
		Color(1.0, 1.0, 1.0, 0.92),
		false
	)
	floor_rim = _configure_dressing_sprite(
		"FloorRim",
		_make_floor_rim_texture(Vector2i(1560, 176)),
		Vector2(450.0, 328.0),
		Vector2(1560.0, 176.0),
		true,
		2,
		FLOOR_RIM_COLOR,
		true
	)
	neon_rail = _configure_dressing_sprite(
		"NeonRail",
		_make_neon_rail_texture(Vector2i(1720, 28)),
		Vector2(-410.0, 326.0),
		Vector2(1720.0, 28.0),
		false,
		3,
		NEON_RAIL_COLOR,
		true
	)
	front_fog = _configure_dressing_sprite(
		"FrontFog",
		_make_front_fog_texture(Vector2i(2140, 250)),
		Vector2(-620.0, 274.0),
		Vector2(2140.0, 250.0),
		false,
		8,
		FRONT_FOG_COLOR,
		false
	)
	top_vignette = _configure_dressing_sprite(
		"TopVignette",
		_make_top_vignette_texture(Vector2i(2140, 260)),
		Vector2(-620.0, -220.0),
		Vector2(2140.0, 260.0),
		false,
		9,
		TOP_VIGNETTE_COLOR,
		false
	)

func _ensure_window_backdrop() -> void:
	backdrop_layer = get_node_or_null("BackdropLayer") as CanvasLayer
	if backdrop_layer == null:
		backdrop_layer = CanvasLayer.new()
		backdrop_layer.name = "BackdropLayer"
		backdrop_layer.layer = -100
		add_child(backdrop_layer)
	backdrop_rect = backdrop_layer.get_node_or_null("BackdropRect") as TextureRect
	if backdrop_rect == null:
		backdrop_rect = TextureRect.new()
		backdrop_rect.name = "BackdropRect"
		backdrop_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		backdrop_rect.offset_left = 0.0
		backdrop_rect.offset_top = 0.0
		backdrop_rect.offset_right = 0.0
		backdrop_rect.offset_bottom = 0.0
		backdrop_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		backdrop_rect.stretch_mode = TextureRect.STRETCH_SCALE
		backdrop_rect.texture_filter = DRESSING_LINEAR_FILTER
		backdrop_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		backdrop_layer.add_child(backdrop_rect)
	backdrop_viewport_size = Vector2i.ZERO
	_refresh_window_backdrop_if_needed()

func _refresh_window_backdrop_if_needed() -> void:
	if backdrop_rect == null:
		return
	var viewport_size := Vector2i(get_viewport_rect().size)
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		return
	if viewport_size == backdrop_viewport_size and backdrop_rect.texture != null:
		return
	backdrop_viewport_size = viewport_size
	backdrop_rect.texture = _make_window_backdrop_texture(viewport_size)

func _configure_dressing_sprite(
	node_name: String,
	texture: Texture2D,
	position: Vector2,
	target_size: Vector2,
	centered: bool,
	z_index: int,
	modulate: Color,
	use_additive: bool
) -> Sprite2D:
	var sprite := get_node_or_null(node_name) as Sprite2D
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.name = node_name
		add_child(sprite)
	sprite.texture = texture
	sprite.centered = centered
	sprite.position = position
	sprite.z_as_relative = false
	sprite.z_index = z_index
	sprite.texture_filter = DRESSING_LINEAR_FILTER
	sprite.material = additive_material if use_additive else null
	sprite.modulate = modulate
	var texture_size := texture.get_size()
	sprite.scale = Vector2(
		target_size.x / maxf(1.0, texture_size.x),
		target_size.y / maxf(1.0, texture_size.y)
	)
	return sprite

func _apply_side_platform_state() -> void:
	for platform in [platform_left, platform_right]:
		if platform == null:
			continue
		platform.visible = side_platforms_enabled
		platform.collision_layer = PLATFORM_COLLISION_LAYER if side_platforms_enabled else 0
		var collision_shape := platform.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if collision_shape:
			collision_shape.disabled = not side_platforms_enabled

func _make_radial_glow_texture(size: Vector2i, fill: Color, inner_radius: float, outer_radius: float) -> Texture2D:
	var safe_size := Vector2i(maxi(1, size.x), maxi(1, size.y))
	var image := Image.create(safe_size.x, safe_size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	for y in range(safe_size.y):
		for x in range(safe_size.x):
			var uv := Vector2(
				(float(x) + 0.5) / float(safe_size.x),
				(float(y) + 0.5) / float(safe_size.y)
			)
			var distance := Vector2((uv.x - 0.5) * 1.28, uv.y - 0.5).length()
			if distance >= outer_radius:
				continue
			var alpha := 1.0
			if distance > inner_radius:
				alpha = 1.0 - (distance - inner_radius) / maxf(0.001, outer_radius - inner_radius)
			var pixel := Color(fill.r, fill.g, fill.b, clampf(alpha, 0.0, 1.0))
			image.set_pixel(x, y, pixel)
	return ImageTexture.create_from_image(image)

func _make_window_backdrop_texture(size: Vector2i) -> Texture2D:
	var safe_size := Vector2i(maxi(1, size.x), maxi(1, size.y))
	var image := Image.create(safe_size.x, safe_size.y, false, Image.FORMAT_RGBA8)
	for y in range(safe_size.y):
		var y_t := float(y) / maxf(1.0, float(safe_size.y - 1))
		var base := Color(0.05, 0.09, 0.16, 1.0)
		if y_t < 0.56:
			base = base.lerp(Color(0.10, 0.18, 0.30, 1.0), y_t / 0.56)
		else:
			base = Color(0.10, 0.18, 0.30, 1.0).lerp(Color(0.30, 0.22, 0.18, 1.0), (y_t - 0.56) / 0.44)
		for x in range(safe_size.x):
			var x_t := float(x) / maxf(1.0, float(safe_size.x - 1))
			var left_glow := clampf(1.0 - absf(x_t - 0.14) / 0.24, 0.0, 1.0)
			var right_glow := clampf(1.0 - absf(x_t - 0.86) / 0.24, 0.0, 1.0)
			var horizon_glow := clampf(1.0 - absf(y_t - 0.42) / 0.26, 0.0, 1.0)
			var floor_warmth := clampf((y_t - 0.58) / 0.30, 0.0, 1.0)
			var color := base
			color = color.lerp(Color(0.18, 0.40, 0.64, 1.0), left_glow * horizon_glow * 0.42)
			color = color.lerp(Color(0.54, 0.34, 0.22, 1.0), right_glow * horizon_glow * 0.34)
			color = color.lerp(Color(0.42, 0.30, 0.20, 1.0), floor_warmth * 0.28)
			if y % 2 == 0:
				color = color.darkened(0.03)
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)

func _make_side_frame_texture(size: Vector2i, is_left: bool) -> Texture2D:
	var safe_size := Vector2i(maxi(1, size.x), maxi(1, size.y))
	var image := Image.create(safe_size.x, safe_size.y, false, Image.FORMAT_RGBA8)
	for y in range(safe_size.y):
		var y_t := float(y) / maxf(1.0, float(safe_size.y - 1))
		for x in range(safe_size.x):
			var x_t := float(x) / maxf(1.0, float(safe_size.x - 1))
			var edge_t := 1.0 - x_t if is_left else x_t
			var base := Color(0.02, 0.06, 0.11, 0.92)
			var cyan_line := clampf((edge_t - 0.72) / 0.28, 0.0, 1.0)
			var warm_line := clampf((0.24 - absf(y_t - 0.70)) / 0.24, 0.0, 1.0) * clampf((edge_t - 0.52) / 0.48, 0.0, 1.0)
			base.r += 0.10 * cyan_line + 0.18 * warm_line
			base.g += 0.18 * cyan_line + 0.08 * warm_line
			base.b += 0.24 * cyan_line
			base.a = 0.86 + 0.10 * cyan_line
			image.set_pixel(x, y, base)
	return ImageTexture.create_from_image(image)

func _make_crowd_band_texture(size: Vector2i) -> Texture2D:
	var safe_size := Vector2i(maxi(1, size.x), maxi(1, size.y))
	var image := Image.create(safe_size.x, safe_size.y, false, Image.FORMAT_RGBA8)
	for y in range(safe_size.y):
		var y_t := float(y) / maxf(1.0, float(safe_size.y - 1))
		for x in range(safe_size.x):
			var x_t := float(x) / maxf(1.0, float(safe_size.x - 1))
			var stripe := 0.5 + 0.5 * sin(x_t * 40.0 + y_t * 14.0)
			var top_fade := clampf((y_t - 0.08) / 0.22, 0.0, 1.0)
			var alpha := 0.10 + top_fade * 0.64
			var pixel := Color(
				0.04 + stripe * 0.03,
				0.08 + stripe * 0.06,
				0.12 + stripe * 0.08,
				alpha
			)
			if y_t > 0.68:
				pixel.r += 0.06
				pixel.g += 0.04
			image.set_pixel(x, y, pixel)
	return ImageTexture.create_from_image(image)

func _make_floor_rim_texture(size: Vector2i) -> Texture2D:
	var safe_size := Vector2i(maxi(1, size.x), maxi(1, size.y))
	var image := Image.create(safe_size.x, safe_size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	for y in range(safe_size.y):
		var y_t := float(y) / maxf(1.0, float(safe_size.y - 1))
		for x in range(safe_size.x):
			var x_t := float(x) / maxf(1.0, float(safe_size.x - 1))
			var center_glow := 1.0 - minf(1.0, absf(x_t - 0.5) / 0.38)
			var rim_band := clampf((0.24 - absf(y_t - 0.24)) / 0.24, 0.0, 1.0)
			var spill := clampf((1.0 - y_t) * 0.42, 0.0, 0.42)
			var alpha := rim_band * center_glow * 0.92 + spill * center_glow * 0.46
			if alpha <= 0.0:
				continue
			var pixel := Color(1.0, 1.0, 1.0, alpha)
			image.set_pixel(x, y, pixel)
	return ImageTexture.create_from_image(image)

func _make_neon_rail_texture(size: Vector2i) -> Texture2D:
	var safe_size := Vector2i(maxi(1, size.x), maxi(1, size.y))
	var image := Image.create(safe_size.x, safe_size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	for y in range(safe_size.y):
		var y_t := float(y) / maxf(1.0, float(safe_size.y - 1))
		var line_alpha := clampf((0.18 - absf(y_t - 0.28)) / 0.18, 0.0, 1.0)
		var glow_alpha := clampf((0.42 - absf(y_t - 0.28)) / 0.42, 0.0, 1.0) * 0.42
		for x in range(safe_size.x):
			var x_t := float(x) / maxf(1.0, float(safe_size.x - 1))
			var hotspot := 0.84 + 0.16 * sin(x_t * 18.0)
			var alpha := (line_alpha + glow_alpha) * hotspot
			if alpha <= 0.0:
				continue
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return ImageTexture.create_from_image(image)

func _make_front_fog_texture(size: Vector2i) -> Texture2D:
	var safe_size := Vector2i(maxi(1, size.x), maxi(1, size.y))
	var image := Image.create(safe_size.x, safe_size.y, false, Image.FORMAT_RGBA8)
	for y in range(safe_size.y):
		var y_t := float(y) / maxf(1.0, float(safe_size.y - 1))
		for x in range(safe_size.x):
			var x_t := float(x) / maxf(1.0, float(safe_size.x - 1))
			var horizontal := 1.0 - minf(1.0, absf(x_t - 0.5) / 0.56)
			var alpha := clampf((y_t - 0.08) / 0.92, 0.0, 1.0) * (0.34 + horizontal * 0.26)
			var pixel := Color(1.0, 1.0, 1.0, alpha)
			image.set_pixel(x, y, pixel)
	return ImageTexture.create_from_image(image)

func _make_top_vignette_texture(size: Vector2i) -> Texture2D:
	var safe_size := Vector2i(maxi(1, size.x), maxi(1, size.y))
	var image := Image.create(safe_size.x, safe_size.y, false, Image.FORMAT_RGBA8)
	for y in range(safe_size.y):
		var y_t := float(y) / maxf(1.0, float(safe_size.y - 1))
		var alpha := clampf(1.0 - y_t / 0.92, 0.0, 1.0)
		for x in range(safe_size.x):
			var x_t := float(x) / maxf(1.0, float(safe_size.x - 1))
			var side_weight := clampf(absf(x_t - 0.5) / 0.5, 0.0, 1.0)
			var pixel := Color(1.0, 1.0, 1.0, alpha * (0.74 + side_weight * 0.22))
			image.set_pixel(x, y, pixel)
	return ImageTexture.create_from_image(image)

func _make_solid_texture(size: Vector2i, fill: Color) -> Texture2D:
	var safe_size := Vector2i(maxi(1, size.x), maxi(1, size.y))
	var image := Image.create(safe_size.x, safe_size.y, false, Image.FORMAT_RGBA8)
	image.fill(fill)
	return ImageTexture.create_from_image(image)

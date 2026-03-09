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
@onready var ground_collision := $Ground/CollisionShape2D as CollisionShape2D
@onready var platform_left := $PlatformLeft as StaticBody2D
@onready var platform_right := $PlatformRight as StaticBody2D

var cool_glow: Sprite2D
var warm_glow: Sprite2D
var crowd_band: Sprite2D
var floor_rim: Sprite2D
var front_fog: Sprite2D
var top_vignette: Sprite2D
var neon_rail: Sprite2D
var additive_material: CanvasItemMaterial
var stage_fx_time := 0.0
var presentation_center := Vector2(450.0, 252.0)
var presentation_zoom := 1.0
var presentation_viewport_size := Vector2(1280.0, 720.0)

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
	_configure_base_stage_sprite(background, -30)
	_configure_base_stage_sprite(floor_visual, -2)
	_ensure_stage_dressing()
	_sync_visual_shell()
	_apply_side_platform_state()

func set_presentation_state(camera_center: Vector2, camera_zoom: float, viewport_size: Vector2) -> void:
	presentation_center = camera_center
	presentation_zoom = maxf(0.01, camera_zoom)
	presentation_viewport_size = viewport_size
	_sync_visual_shell()

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

func _configure_base_stage_sprite(sprite: Sprite2D, z_index: int) -> void:
	if sprite == null:
		return
	sprite.visible = true
	sprite.centered = false
	sprite.z_as_relative = false
	sprite.z_index = z_index
	sprite.texture_filter = DRESSING_LINEAR_FILTER

func _process(delta: float) -> void:
	stage_fx_time += maxf(0.0, delta)
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

func _sync_visual_shell() -> void:
	var viewport_size := presentation_viewport_size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var world_view_size := viewport_size / maxf(0.01, presentation_zoom)
	var bleed_x := maxf(world_view_size.x * 0.24, 220.0)
	var top_bleed := world_view_size.y * 0.12
	var bottom_bleed := world_view_size.y * 0.18
	var top_left := presentation_center - world_view_size * 0.5
	var floor_y := _resolve_floor_y()
	var shell_width := maxf(world_view_size.x + bleed_x * 2.0, 1500.0)
	var shell_left := presentation_center.x - shell_width * 0.5
	var shell_top := top_left.y - top_bleed
	var shell_background_height := (floor_y - shell_top) + bottom_bleed * 0.58
	var floor_height := world_view_size.y * 0.56 + bottom_bleed
	var floor_top := floor_y - floor_height * 0.12
	var horizon_y := floor_y - world_view_size.y * 0.22
	_position_sprite(background, Vector2(shell_left, shell_top), Vector2(shell_width, shell_background_height), false)
	_position_sprite(floor_visual, Vector2(shell_left, floor_top), Vector2(shell_width, floor_height), false)
	_position_sprite(crowd_band, Vector2(shell_left, horizon_y - world_view_size.y * 0.07), Vector2(shell_width, world_view_size.y * 0.16), false)
	_position_sprite(floor_rim, Vector2(presentation_center.x, floor_y + world_view_size.y * 0.01), Vector2(world_view_size.x * 1.18, world_view_size.y * 0.14), true)
	_position_sprite(neon_rail, Vector2(shell_left, floor_y - world_view_size.y * 0.012), Vector2(shell_width, world_view_size.y * 0.018), false)
	_position_sprite(front_fog, Vector2(shell_left, floor_y - world_view_size.y * 0.12), Vector2(shell_width, world_view_size.y * 0.22), false)
	_position_sprite(top_vignette, Vector2(shell_left, shell_top), Vector2(shell_width, world_view_size.y * 0.24), false)
	_position_sprite(cool_glow, Vector2(presentation_center.x, horizon_y), Vector2(world_view_size.x * 0.96, world_view_size.y * 0.42), true)
	_position_sprite(warm_glow, Vector2(presentation_center.x, floor_y - world_view_size.y * 0.08), Vector2(world_view_size.x * 0.72, world_view_size.y * 0.24), true)

func _position_sprite(sprite: Sprite2D, position: Vector2, target_size: Vector2, centered: bool) -> void:
	if sprite == null or sprite.texture == null:
		return
	sprite.centered = centered
	_fit_sprite(sprite, position, target_size)

func _resolve_floor_y() -> float:
	if ground_collision == null or ground_collision.shape is not RectangleShape2D:
		return 340.0
	var rect := ground_collision.shape as RectangleShape2D
	return ground_collision.global_position.y - rect.size.y * 0.5 * absf(ground_collision.global_scale.y)

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
			var pixel := Color(1.0, 1.0, 1.0, alpha * (0.64 + side_weight * 0.08))
			image.set_pixel(x, y, pixel)
	return ImageTexture.create_from_image(image)

func _make_solid_texture(size: Vector2i, fill: Color) -> Texture2D:
	var safe_size := Vector2i(maxi(1, size.x), maxi(1, size.y))
	var image := Image.create(safe_size.x, safe_size.y, false, Image.FORMAT_RGBA8)
	image.fill(fill)
	return ImageTexture.create_from_image(image)

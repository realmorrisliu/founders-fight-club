extends Node2D

const BACKGROUND_TEXTURE_PATH := "res://assets/sprites/arena/arena_bg.png"
const FLOOR_TEXTURE_PATH := "res://assets/sprites/arena/arena_floor.png"
const BACKGROUND_PLACEHOLDER_SIZE := Vector2i(960, 540)
const FLOOR_PLACEHOLDER_SIZE := Vector2i(960, 56)

@onready var background := $Background
@onready var floor_visual := $FloorVisual

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

func _load_texture_or_placeholder(path: String, size: Vector2i, fill: Color) -> Texture2D:
	if not _is_headless_runtime():
		var loaded = load(path)
		if loaded is Texture2D:
			return loaded as Texture2D
	return _make_solid_texture(size, fill)

func _is_headless_runtime() -> bool:
	return OS.has_feature("headless") or DisplayServer.get_name() == "headless"

func _make_solid_texture(size: Vector2i, fill: Color) -> Texture2D:
	var safe_size := Vector2i(maxi(1, size.x), maxi(1, size.y))
	var image := Image.create(safe_size.x, safe_size.y, false, Image.FORMAT_RGBA8)
	image.fill(fill)
	return ImageTexture.create_from_image(image)

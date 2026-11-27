extends RefCounted
class_name CharacterLook

const STYLE_ID := "pixel"
const FRAME_SIZE := Vector2i(48, 96)
const SCALE_MULTIPLIER := 0.5
const _ROOT := "res://assets/sprites/pixel_look"
const _FRAME_COUNTS := {
	"idle": 4,
	"walk": 6,
	"light": 4,
	"jump": 3,
	"hit": 2,
}


static func covers(character_id: String) -> bool:
	return character_id == "elon_mvsk" or character_id == "steve_jobz"


static func apply(source: SpriteFrames, character_id: String) -> SpriteFrames:
	if source == null or not covers(character_id):
		return source
	var frames := source.duplicate(true) as SpriteFrames
	if frames == null:
		return source
	for animation_name in frames.get_animation_names():
		var name := String(animation_name)
		if _FRAME_COUNTS.has(name):
			_replace_authored(frames, character_id, name)
		else:
			_fit_existing(frames, name)
	return frames


static func _replace_authored(frames: SpriteFrames, character_id: String, name: String) -> void:
	var speed := frames.get_animation_speed(StringName(name))
	var loops := frames.get_animation_loop(StringName(name))
	var count := int(_FRAME_COUNTS[name])
	while frames.get_frame_count(StringName(name)) > 0:
		frames.remove_frame(StringName(name), 0)
	for index in count:
		var texture := _load_frame(character_id, name, index)
		if texture == null:
			continue
		frames.add_frame(StringName(name), texture, 1.0)
	frames.set_animation_speed(StringName(name), speed)
	frames.set_animation_loop(StringName(name), loops)


static func _fit_existing(frames: SpriteFrames, name: String) -> void:
	var animation := StringName(name)
	var count := frames.get_frame_count(animation)
	for index in count:
		var texture := frames.get_frame_texture(animation, index)
		var fitted := _fit_texture(texture)
		if fitted == texture:
			continue
		var duration := frames.get_frame_duration(animation, index)
		frames.remove_frame(animation, index)
		frames.add_frame(animation, fitted, duration, index)


static func _fit_texture(texture: Texture2D) -> Texture2D:
	if texture == null:
		return texture
	var image := texture.get_image()
	if image == null:
		return texture
	if image.get_width() == FRAME_SIZE.x and image.get_height() == FRAME_SIZE.y:
		return texture
	var fitted := image.duplicate()
	fitted.resize(FRAME_SIZE.x, FRAME_SIZE.y, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(fitted)


static func _load_frame(character_id: String, name: String, index: int) -> Texture2D:
	var path := "%s/%s/%s_%d.png" % [_ROOT, character_id, name, index]
	var image := Image.new()
	var err := image.load(ProjectSettings.globalize_path(path))
	if err != OK:
		push_warning("Pixel look frame missing: %s" % path)
		return null
	return ImageTexture.create_from_image(image)

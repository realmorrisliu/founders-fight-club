extends RefCounted
class_name CharacterLook

const PlayerDataStore := preload("res://scripts/player/PlayerData.gd")

const FRAMES_PATH := "res://assets/sprites/character_looks/frames.txt"
const ORDER := ["block", "ink", "ramp"]
const FRAME_SIZE := Vector2i(24, 48)
const AUTHORED := ["idle", "walk", "light"]

static var _id := ""
static var _bank: Dictionary = {}


static func current_id() -> String:
	return _id


static func label_key() -> String:
	match _id:
		"block":
			return "LOOK_STYLE_BLOCK"
		"ink":
			return "LOOK_STYLE_INK"
		"ramp":
			return "LOOK_STYLE_RAMP"
		_:
			return "LOOK_STYLE_SHARED"


static func set_id(style_id: String) -> String:
	var next := style_id.strip_edges().to_lower()
	if next == "" or next == "shared":
		_id = ""
		return ""
	_ensure_bank()
	if not _bank.has(next):
		return "unknown character style '%s'" % style_id.strip_edges()
	_id = next
	return ""


static func cycle() -> String:
	var index := ORDER.find(_id)
	if index < 0 or index + 1 >= ORDER.size():
		if _id == "" and not ORDER.is_empty():
			set_id(ORDER[0])
			return _id
		_id = ""
		return _id
	_id = ORDER[index + 1]
	return _id


static func covers(character_id: String) -> bool:
	if _id == "":
		return false
	_ensure_bank()
	var characters: Dictionary = _bank.get(_id, {})
	return characters.has(character_id)


static func frames_for(character_id: String) -> SpriteFrames:
	if _id == "":
		return null
	_ensure_bank()
	var characters: Dictionary = _bank.get(_id, {})
	var anims: Dictionary = characters.get(character_id, {})
	if anims.is_empty():
		return null
	for anim_name in AUTHORED:
		var images: Variant = anims.get(anim_name, [])
		if typeof(images) != TYPE_ARRAY or (images as Array).is_empty():
			return null
	var frames := SpriteFrames.new()
	for anim_name in AUTHORED:
		_add_animation(frames, anim_name, anims[anim_name])
	return frames


static func _ensure_bank() -> void:
	if not _bank.is_empty():
		return
	if not FileAccess.file_exists(FRAMES_PATH):
		return
	_bank = _parse(FileAccess.get_file_as_string(FRAMES_PATH))


static func _parse(text: String) -> Dictionary:
	var bank := {}
	var look_id := ""
	var character_id := ""
	var palette := {}
	var anim_name := ""
	var lines := text.split("\n", false)
	var index := 0
	while index < lines.size():
		var line := lines[index].strip_edges()
		index += 1
		if line == "" or line.begins_with("#"):
			continue
		var parts := line.split(" ", false)
		var head := parts[0]
		if head == "look" and parts.size() >= 2:
			look_id = parts[1]
			if not bank.has(look_id):
				bank[look_id] = {}
			continue
		if head == "character" and parts.size() >= 2:
			character_id = parts[1]
			palette = {}
			if look_id != "" and not bank[look_id].has(character_id):
				bank[look_id][character_id] = {}
			continue
		if head == "color" and parts.size() >= 3:
			palette[parts[1]] = _color_from_hex(parts[2])
			continue
		if head == "anim" and parts.size() >= 2:
			anim_name = parts[1]
			continue
		if head == "frame":
			var rows: PackedStringArray = []
			var row_count := 0
			while row_count < FRAME_SIZE.y and index < lines.size():
				rows.append(lines[index])
				index += 1
				row_count += 1
			if look_id == "" or character_id == "" or anim_name == "":
				continue
			var anims: Dictionary = bank[look_id][character_id]
			if not anims.has(anim_name):
				anims[anim_name] = []
			(anims[anim_name] as Array).append(_image_from_rows(rows, palette))
	return bank


static func _color_from_hex(text: String) -> Color:
	var hex := text.strip_edges()
	if hex.length() < 6:
		return Color.WHITE
	var red := float(hex.substr(0, 2).hex_to_int()) / 255.0
	var green := float(hex.substr(2, 2).hex_to_int()) / 255.0
	var blue := float(hex.substr(4, 2).hex_to_int()) / 255.0
	return Color(red, green, blue, 1.0)


static func _image_from_rows(rows: PackedStringArray, palette: Dictionary) -> Image:
	var image := Image.create(FRAME_SIZE.x, FRAME_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	for y in range(mini(rows.size(), FRAME_SIZE.y)):
		var line := rows[y]
		for x in range(mini(line.length(), FRAME_SIZE.x)):
			var letter := line.substr(x, 1)
			if letter == "." or not palette.has(letter):
				continue
			image.set_pixel(x, y, palette[letter])
	return image


static func _add_animation(frames: SpriteFrames, anim_name: String, images: Array) -> void:
	var profile: Dictionary = PlayerDataStore.ANIMATION_PROFILES.get(anim_name, {})
	frames.add_animation(anim_name)
	frames.set_animation_speed(anim_name, float(profile.get("fps", 8.0)))
	frames.set_animation_loop(anim_name, bool(profile.get("loop", false)))
	for image in images:
		if image is Image:
			frames.add_frame(anim_name, ImageTexture.create_from_image(image))

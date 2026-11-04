extends Node3D

const LookB := preload("res://scripts/picture/LookB.gd")
const StageConfigStore := preload("res://scripts/config/StageConfig.gd")

const PICTURE_SCRIPT := "res://scripts/picture/StagePicture.gd"
const PICTURE_NAME := "StagePicture"
const CAMERA_NAME := "Camera"
const WORLD_NAME := "World"
const KEY_NAME := "Key"
const FILL_NAME := "Fill"
const HIT_NAME := "Hit"
const FLOOR_NAME := "Floor"
const FLOOR_TOP_NAME := "Top"
const FLOOR_SKIRT_NAME := "Skirt"
const BACKDROP_NAME := "BackdropFar"
const FIGHTER_NAMES: PackedStringArray = ["Player1", "Player2"]
const VISUAL_NAME := "Visual"
const ARENA_NAME := "Arena"
const GROUND_NAME := "Ground"
const GROUND_SHAPE_PATH := "Ground/CollisionShape2D"
const COLLISION_SHAPE_NAME := "CollisionShape2D"
const BACKGROUND_NAME := "Background"
const FLOOR_VISUAL_NAME := "FloorVisual"
const EFFECTS_NAME := "Effects"
const FIGHTER_PREFIX := "Fighter"
const SLAB_PREFIX := "Platform"
const SPARK_PREFIX := "Spark"

var _match: Node
var _hidden: Dictionary = {}
var _camera: Camera3D
var _hit: OmniLight3D
var _floor_top: MeshInstance3D
var _floor_skirt: MeshInstance3D
var _floor_material: StandardMaterial3D
var _backdrop_material: StandardMaterial3D
var _fighters: Array[Sprite3D] = []
var _sparks: Array[Sprite3D] = []
var _spark_materials: Array[StandardMaterial3D] = []
var _slabs: Array[MeshInstance3D] = []


class RectPx:
	var center: Vector2
	var size: Vector2


class Framing:
	var center: Vector2
	var zoom: float
	var viewport_height_px: float


class FighterCard:
	var present: bool
	var texture: Texture2D
	var flip_h: bool
	var modulate: Color
	var offset: Vector2
	var scale: Vector2
	var origin: Vector2
	var has_origin: bool
	var stun_time: float


class SparkCard:
	var texture: Texture2D
	var modulate: Color
	var scale: Vector2
	var rotation: float
	var origin: Vector2
	var additive: bool
	var nearest: bool


class SlabCard:
	var active: bool
	var surface: Vector2
	var width_px: float
	var thickness_px: float


class FrameRead:
	var framing := Framing.new()
	var anchor_x: float
	var floor_y: float
	var floor_center_x: float
	var floor_width_px: float
	var floor_texture: Texture2D
	var backdrop_texture: Texture2D
	var fighters: Array[FighterCard] = []
	var sparks: Array[SparkCard] = []
	var slabs: Array[SlabCard] = []


static func attach(match_root: Node) -> void:
	if match_root == null:
		return
	if match_root.get_node_or_null(PICTURE_NAME) != null:
		return
	var picture := (load(PICTURE_SCRIPT) as GDScript).new() as Node3D
	picture.name = PICTURE_NAME
	picture.process_mode = Node.PROCESS_MODE_ALWAYS
	match_root.add_child(picture)


func _ready() -> void:
	_match = get_parent()
	_build_world()
	_publish()
	if not RenderingServer.frame_pre_draw.is_connected(_publish):
		RenderingServer.frame_pre_draw.connect(_publish)


func _exit_tree() -> void:
	if RenderingServer.frame_pre_draw.is_connected(_publish):
		RenderingServer.frame_pre_draw.disconnect(_publish)
	_restore_world_roots()


func _publish() -> void:
	if _match == null or not is_instance_valid(_match):
		return
	var read := _read(_match, _hidden)
	_present(read)
	_hide_world_roots(_match)


static func _read(match_root: Node, shown_memory: Dictionary) -> FrameRead:
	var read := FrameRead.new()
	read.framing.viewport_height_px = _viewport_height(match_root)
	var camera := _find_camera(match_root)
	if camera != null:
		camera.force_update_scroll()
		read.framing.center = camera.get_screen_center_position()
		read.framing.zoom = camera.zoom.x
	_read_floor(match_root, read)
	_read_fighters(match_root, read)
	_read_sparks(match_root, read, shown_memory)
	return read


static func _viewport_height(match_root: Node) -> float:
	if match_root is CanvasItem:
		return (match_root as CanvasItem).get_viewport_rect().size.y
	return 0.0


static func _find_camera(match_root: Node) -> Camera2D:
	for child in match_root.get_children():
		if child is Camera2D:
			return child as Camera2D
	return null


static func _read_floor(match_root: Node, read: FrameRead) -> void:
	read.anchor_x = LookB.fallback_anchor_x(StageConfigStore.DEFAULT_LEFT_X, StageConfigStore.DEFAULT_RIGHT_X)
	read.floor_y = StageConfigStore.DEFAULT_FLOOR_Y
	read.floor_center_x = read.anchor_x
	read.floor_width_px = 0.0
	var arena := match_root.get_node_or_null(ARENA_NAME)
	if arena == null:
		return
	var background := arena.get_node_or_null(BACKGROUND_NAME) as Sprite2D
	if background != null:
		read.backdrop_texture = background.texture
	var floor_visual := arena.get_node_or_null(FLOOR_VISUAL_NAME) as Sprite2D
	if floor_visual != null:
		read.floor_texture = floor_visual.texture
	var ground := arena.get_node_or_null(GROUND_SHAPE_PATH) as CollisionShape2D
	if ground != null and not ground.disabled and ground.shape is RectangleShape2D:
		var measured := _rect_px(ground)
		read.anchor_x = measured.center.x
		read.floor_y = LookB.surface_y(measured.center.y, measured.size.y)
		read.floor_center_x = measured.center.x
		read.floor_width_px = measured.size.x
	for child in arena.get_children():
		if not (child is StaticBody2D) or str(child.name) == GROUND_NAME:
			continue
		var body := child as StaticBody2D
		var shape_node := body.get_node_or_null(COLLISION_SHAPE_NAME) as CollisionShape2D
		if shape_node == null or not (shape_node.shape is RectangleShape2D):
			continue
		var slab_rect := _rect_px(shape_node)
		var slab := SlabCard.new()
		slab.surface = Vector2(slab_rect.center.x, LookB.surface_y(slab_rect.center.y, slab_rect.size.y))
		slab.width_px = slab_rect.size.x
		slab.thickness_px = slab_rect.size.y
		slab.active = body.collision_layer != 0 and not shape_node.disabled
		read.slabs.append(slab)


static func _rect_px(shape_node: CollisionShape2D) -> RectPx:
	var shape := shape_node.shape as RectangleShape2D
	var measured := RectPx.new()
	measured.center = shape_node.global_position
	measured.size = shape.size * shape_node.global_scale.abs()
	return measured


static func _read_fighters(match_root: Node, read: FrameRead) -> void:
	for node_name in FIGHTER_NAMES:
		var card := FighterCard.new()
		var body := match_root.get_node_or_null(node_name)
		if body == null:
			read.fighters.append(card)
			continue
		card.stun_time = float(body.get("hitstun_time"))
		var visual := body.get_node_or_null(VISUAL_NAME) as AnimatedSprite2D
		if visual != null:
			card.has_origin = true
			card.origin = visual.global_position
			card.flip_h = visual.flip_h
			card.modulate = visual.modulate
			card.offset = visual.offset
			card.scale = visual.scale
			card.texture = _frame_texture(visual)
			card.present = card.texture != null
		read.fighters.append(card)


static func _read_sparks(match_root: Node, read: FrameRead, shown_memory: Dictionary) -> void:
	var effects := match_root.get_node_or_null(EFFECTS_NAME)
	if effects != null:
		for child in effects.get_children():
			_collect_world_sprite(child, read, Color(1, 1, 1, 1), false)
	for child in match_root.get_children():
		if _is_structural_child(child):
			continue
		if not (child is CanvasItem):
			continue
		if not _was_shown(child as CanvasItem, shown_memory):
			continue
		_collect_world_sprite(child, read, Color(1, 1, 1, 1), true)


static func _is_structural_child(child: Node) -> bool:
	if child is Camera2D or child is CanvasLayer:
		return true
	var child_name := str(child.name)
	if child_name == PICTURE_NAME or child_name == ARENA_NAME or child_name == EFFECTS_NAME:
		return true
	return child_name == FIGHTER_NAMES[0] or child_name == FIGHTER_NAMES[1]


static func _was_shown(item: CanvasItem, shown_memory: Dictionary) -> bool:
	if shown_memory.has(item):
		return bool(shown_memory[item])
	return item.visible


static func _collect_world_sprite(node: Node, read: FrameRead, tint: Color, force_shown: bool) -> void:
	if not (node is CanvasItem):
		return
	var item := node as CanvasItem
	if not force_shown and not item.visible:
		return
	var color := tint * item.modulate
	if color.a > LookB.SPARK_ALPHA_FLOOR and (node is Sprite2D or node is AnimatedSprite2D):
		var texture := _spark_texture(item)
		if texture != null and node is Node2D:
			var flat := node as Node2D
			var card := SparkCard.new()
			card.texture = texture
			card.modulate = color
			card.scale = flat.scale
			card.rotation = flat.rotation
			card.origin = flat.global_position
			card.nearest = node is AnimatedSprite2D
			card.additive = _is_additive(item)
			read.sparks.append(card)
	for child in node.get_children():
		_collect_world_sprite(child, read, color, false)


static func _is_additive(item: CanvasItem) -> bool:
	if item.material is CanvasItemMaterial:
		return (item.material as CanvasItemMaterial).blend_mode == CanvasItemMaterial.BLEND_MODE_ADD
	return false


static func _spark_texture(item: CanvasItem) -> Texture2D:
	if item is AnimatedSprite2D:
		return _frame_texture(item)
	if item is Sprite2D:
		return (item as Sprite2D).texture
	return null


static func _frame_texture(visual: Node) -> Texture2D:
	if visual == null or not (visual is AnimatedSprite2D):
		return null
	var sprite := visual as AnimatedSprite2D
	var frames := sprite.sprite_frames
	if frames == null or not frames.has_animation(sprite.animation):
		return null
	var count := frames.get_frame_count(sprite.animation)
	if count <= 0:
		return null
	return frames.get_frame_texture(sprite.animation, clampi(sprite.frame, 0, count - 1))


func _present(read: FrameRead) -> void:
	_present_camera(read)
	_present_floor(read)
	_present_backdrop(read)
	_present_slabs(read)
	_present_fighters(read)
	_present_sparks(read)
	_present_hit(read)


func _present_camera(read: FrameRead) -> void:
	var pose_value = LookB.pose(
		read.framing.center,
		read.framing.zoom,
		read.framing.viewport_height_px,
		read.anchor_x,
		read.floor_y
	)
	if pose_value.valid:
		_camera.look_at_from_position(pose_value.eye, pose_value.aim, Vector3.UP)
		_camera.fov = pose_value.fov_y_deg
	_camera.make_current()


func _present_floor(read: FrameRead) -> void:
	var top_mesh := _floor_top.mesh as PlaneMesh
	top_mesh.size = LookB.floor_size_m(read.floor_width_px)
	_floor_top.position = LookB.floor_top_position(read.anchor_x, read.floor_y, read.floor_center_x)
	_floor_material.albedo_texture = read.floor_texture
	var skirt_mesh := _floor_skirt.mesh as BoxMesh
	skirt_mesh.size = LookB.skirt_size_m(read.floor_width_px)
	_floor_skirt.position = LookB.skirt_position(read.anchor_x, read.floor_y, read.floor_center_x)


func _present_backdrop(read: FrameRead) -> void:
	_backdrop_material.albedo_texture = read.backdrop_texture


func _present_slabs(read: FrameRead) -> void:
	while _slabs.size() < read.slabs.size():
		_slabs.append(_make_slab(_slabs.size()))
	for index in _slabs.size():
		var mesh_node := _slabs[index]
		if index >= read.slabs.size():
			mesh_node.visible = false
			continue
		var slab: SlabCard = read.slabs[index]
		mesh_node.visible = slab.active
		if not slab.active:
			continue
		var thickness := LookB.slab_thickness_m(slab.thickness_px)
		var box := mesh_node.mesh as BoxMesh
		box.size = Vector3(LookB.meters_of(slab.width_px), thickness, LookB.PLATFORM_DEPTH_M)
		mesh_node.position = LookB.slab_position(read.anchor_x, read.floor_y, slab.surface, thickness)


func _present_fighters(read: FrameRead) -> void:
	while _fighters.size() < read.fighters.size():
		_fighters.append(_make_fighter(_fighters.size()))
	for index in _fighters.size():
		var sprite := _fighters[index]
		if index >= read.fighters.size():
			sprite.visible = false
			continue
		var card: FighterCard = read.fighters[index]
		sprite.visible = card.present
		if not card.present:
			continue
		sprite.texture = card.texture
		sprite.flip_h = card.flip_h
		sprite.modulate = card.modulate
		sprite.offset = card.offset
		sprite.scale = Vector3(absf(card.scale.x), absf(card.scale.y), 1.0)
		sprite.position = LookB.fighter_position(read.anchor_x, read.floor_y, card.origin, index)
		sprite.sorting_offset = float(index)


func _present_sparks(read: FrameRead) -> void:
	while _sparks.size() < read.sparks.size():
		var material := _make_spark_material()
		_spark_materials.append(material)
		_sparks.append(_make_spark(_sparks.size(), material))
	for index in _sparks.size():
		var spark := _sparks[index]
		if index >= read.sparks.size():
			spark.visible = false
			continue
		_apply_spark(spark, _spark_materials[index], read.sparks[index], read)


func _apply_spark(spark: Sprite3D, material: StandardMaterial3D, card: SparkCard, read: FrameRead) -> void:
	spark.visible = true
	spark.texture = card.texture
	spark.modulate = card.modulate
	spark.scale = Vector3(absf(card.scale.x), absf(card.scale.y), 1.0)
	spark.rotation = Vector3(0.0, 0.0, -card.rotation)
	spark.position = LookB.spark_position(read.anchor_x, read.floor_y, card.origin)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = card.texture
	material.albedo_color = card.modulate
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if card.nearest:
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	else:
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	if card.additive:
		material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	else:
		material.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	spark.material_override = material


func _present_hit(read: FrameRead) -> void:
	var times := PackedFloat32Array()
	for card in read.fighters:
		times.append((card as FighterCard).stun_time)
	var slot := LookB.hit_slot(times)
	if slot < 0:
		_hit.light_energy = 0.0
		return
	_hit.light_energy = LookB.HIT_ENERGY
	var winner: FighterCard = read.fighters[slot]
	if winner.has_origin:
		_hit.position = LookB.hit_position(read.anchor_x, read.floor_y, winner.origin)


func _hide_world_roots(match_root: Node) -> void:
	for child in match_root.get_children():
		if child == self or child is CanvasLayer or child is Camera2D:
			continue
		if child is CanvasItem:
			var item := child as CanvasItem
			if not _hidden.has(item):
				_hidden[item] = item.visible
			item.visible = false


func _restore_world_roots() -> void:
	for key in _hidden.keys():
		if is_instance_valid(key) and key is CanvasItem:
			(key as CanvasItem).visible = bool(_hidden[key])
	_hidden.clear()


func _build_world() -> void:
	_build_environment()
	_build_camera()
	_build_lights()
	_build_floor()
	_build_backdrop()
	for _fighter_name in FIGHTER_NAMES:
		_fighters.append(_make_fighter(_fighters.size()))


func _build_environment() -> void:
	var world := WorldEnvironment.new()
	world.name = WORLD_NAME
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = LookB.SKY_COLOR
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = LookB.AMBIENT_COLOR
	environment.ambient_light_energy = LookB.AMBIENT_ENERGY
	environment.tonemap_mode = LookB.TONEMAP
	environment.glow_enabled = LookB.GLOW_ENABLED
	environment.glow_intensity = LookB.GLOW_INTENSITY
	environment.glow_bloom = LookB.GLOW_BLOOM
	environment.glow_hdr_threshold = LookB.GLOW_HDR_THRESHOLD
	environment.glow_blend_mode = LookB.GLOW_BLEND
	world.environment = environment
	add_child(world)


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.name = CAMERA_NAME
	_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	_camera.near = LookB.CAMERA_NEAR_M
	_camera.far = LookB.CAMERA_FAR_M
	var attributes := CameraAttributesPractical.new()
	attributes.dof_blur_near_enabled = LookB.DOF_NEAR_ENABLED
	attributes.dof_blur_far_enabled = LookB.DOF_FAR_ENABLED
	attributes.dof_blur_amount = LookB.DOF_AMOUNT
	attributes.dof_blur_near_distance = LookB.DOF_NEAR_M
	attributes.dof_blur_far_distance = LookB.DOF_FAR_M
	_camera.attributes = attributes
	add_child(_camera)


func _build_lights() -> void:
	var key := DirectionalLight3D.new()
	key.name = KEY_NAME
	key.shadow_enabled = LookB.KEY_SHADOW_ENABLED
	key.light_color = LookB.KEY_COLOR
	key.light_energy = LookB.KEY_ENERGY
	key.shadow_blur = LookB.KEY_SHADOW_BLUR
	key.shadow_bias = LookB.KEY_SHADOW_BIAS
	key.shadow_normal_bias = LookB.KEY_SHADOW_NORMAL_BIAS
	key.directional_shadow_max_distance = LookB.KEY_SHADOW_MAX_DISTANCE_M
	key.rotation_degrees = LookB.KEY_ROTATION_DEG
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.name = FILL_NAME
	fill.shadow_enabled = false
	fill.light_color = LookB.FILL_COLOR
	fill.light_energy = LookB.FILL_ENERGY
	fill.rotation_degrees = LookB.FILL_ROTATION_DEG
	add_child(fill)
	_hit = OmniLight3D.new()
	_hit.name = HIT_NAME
	_hit.shadow_enabled = false
	_hit.light_color = LookB.HIT_COLOR
	_hit.omni_range = LookB.HIT_RANGE_M
	_hit.light_energy = 0.0
	add_child(_hit)


func _build_floor() -> void:
	var root := Node3D.new()
	root.name = FLOOR_NAME
	add_child(root)
	_floor_top = MeshInstance3D.new()
	_floor_top.name = FLOOR_TOP_NAME
	_floor_top.mesh = PlaneMesh.new()
	_floor_top.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_floor_material = StandardMaterial3D.new()
	_floor_material.albedo_color = LookB.FLOOR_ALBEDO
	_floor_material.roughness = LookB.FLOOR_ROUGHNESS
	_floor_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	_floor_top.material_override = _floor_material
	root.add_child(_floor_top)
	_floor_skirt = MeshInstance3D.new()
	_floor_skirt.name = FLOOR_SKIRT_NAME
	_floor_skirt.mesh = BoxMesh.new()
	_floor_skirt.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var skirt_material := StandardMaterial3D.new()
	skirt_material.albedo_color = LookB.FLOOR_SKIRT_COLOR
	skirt_material.roughness = LookB.SKIRT_ROUGHNESS
	_floor_skirt.material_override = skirt_material
	root.add_child(_floor_skirt)


func _build_backdrop() -> void:
	var mesh_node := MeshInstance3D.new()
	mesh_node.name = BACKDROP_NAME
	var quad := QuadMesh.new()
	quad.size = LookB.BACKDROP_SIZE_M
	mesh_node.mesh = quad
	mesh_node.position = LookB.BACKDROP_POSITION_M
	mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_backdrop_material = StandardMaterial3D.new()
	_backdrop_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_backdrop_material.albedo_color = LookB.BACKDROP_ALBEDO
	_backdrop_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_backdrop_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	mesh_node.material_override = _backdrop_material
	add_child(mesh_node)


func _make_slab(slot: int) -> MeshInstance3D:
	var mesh_node := MeshInstance3D.new()
	mesh_node.name = "%s%s" % [SLAB_PREFIX, slot]
	mesh_node.mesh = BoxMesh.new()
	mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	material.albedo_color = LookB.PLATFORM_COLOR
	material.roughness = LookB.PLATFORM_ROUGHNESS
	mesh_node.material_override = material
	add_child(mesh_node)
	return mesh_node


func _make_fighter(slot: int) -> Sprite3D:
	var sprite := Sprite3D.new()
	sprite.name = "%s%s" % [FIGHTER_PREFIX, slot]
	_dress_card(sprite, true)
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.alpha_scissor_threshold = LookB.ALPHA_SCISSOR
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(sprite)
	return sprite


func _make_spark(slot: int, material: StandardMaterial3D) -> Sprite3D:
	var spark := Sprite3D.new()
	spark.name = "%s%s" % [SPARK_PREFIX, slot]
	_dress_card(spark, false)
	spark.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	spark.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	spark.material_override = material
	add_child(spark)
	return spark


func _make_spark_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


func _dress_card(sprite: Sprite3D, nearest: bool) -> void:
	sprite.double_sided = false
	sprite.shaded = false
	sprite.centered = true
	sprite.pixel_size = LookB.pixel_size()
	if nearest:
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	else:
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR

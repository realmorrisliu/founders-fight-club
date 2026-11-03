extends Node3D

const STAGE_NAME := "Hd2dStage"
const PIXELS_PER_METER := 100.0
const CLOSE_ZOOM := 1.42
const TARGET_FOV_Y_DEG := 50.0
const REFERENCE_VIEWPORT_H := 720.0
const FIGHTER_DRAW_ORDER_Z_M := 0.02
const FRONT_LIP_M := 2.4
const REAR_DEPTH_M := 5.2
const PLATFORM_DEPTH_M := 1.5
const HIT_COLOR := Color(1.0, 0.84, 0.60, 1.0)
const HIT_ENERGY := 1.2
const FILL_COLOR := Color(1.0, 0.90, 0.82, 1.0)
const FILL_ENERGY := 0.35
const StageConfigStore := preload("res://scripts/config/StageConfig.gd")

static var _look_id: StringName = &"0"
static var _rows: Dictionary = {}
static var _plane_distance_m := -1.0

class Look:
	var id: StringName
	var flat: bool
	var pitch_deg: float
	var dof_amount: float
	var dof_near_m: float
	var dof_far_m: float
	var glow_intensity: float
	var glow_bloom: float
	var glow_threshold: float
	var key_color: Color
	var key_energy: float
	var ambient_energy: float
	var shadow_blur: float
	var hit_light: bool


static func take_look(args: PackedStringArray) -> Dictionary:
	var kept := PackedStringArray()
	var chosen := StringName("0")
	var saw := false
	var index := 0
	while index < args.size():
		var arg := str(args[index])
		if arg != "--look":
			kept.append(arg)
			index += 1
			continue
		if index + 1 >= args.size():
			return {"ok": false, "error": "look must be 0, a, b, or c"}
		var token := str(args[index + 1]).strip_edges().to_lower()
		if _row(token) == null:
			return {"ok": false, "error": "look must be 0, a, b, or c"}
		chosen = StringName(token)
		saw = true
		index += 2
	_look_id = chosen if saw else StringName("0")
	return {"ok": true, "look": String(_look_id), "args": kept}


static func install(match_root: Node) -> void:
	_apply(match_root, _look_id)


static func cycle(match_root: Node) -> String:
	var order: Array[String] = ["0", "a", "b", "c"]
	var current := String(_look_id)
	var found := order.find(current)
	var next := order[(found + 1) % order.size()] if found >= 0 else "a"
	_look_id = StringName(next)
	_apply(match_root, _look_id)
	return next


static func _apply(match_root: Node, id: StringName) -> void:
	if match_root == null:
		return
	var look := _row(String(id))
	var stage := match_root.get_node_or_null(STAGE_NAME)
	if look == null or look.flat:
		if stage != null:
			stage.call("shutdown")
			stage.queue_free()
		return
	if stage == null:
		stage = (load("res://scripts/hd2d/Hd2d.gd") as GDScript).new()
		stage.name = STAGE_NAME
		match_root.add_child(stage)
	stage.call("bind", match_root, look)


static func _row(id: String) -> Look:
	if _rows.is_empty():
		_rows = _build_rows()
	return _rows.get(id) as Look


static func _build_rows() -> Dictionary:
	var rows := {}
	rows["0"] = _flat(&"0")
	rows["a"] = _grade({
		"id": &"a",
		"pitch_deg": 6.0,
		"dof_amount": 0.06,
		"dof_near_m": 1.6,
		"dof_far_m": 16.0,
		"glow_intensity": 0.28,
		"glow_bloom": 0.04,
		"glow_threshold": 1.05,
		"key_color": Color(1.0, 0.92, 0.80),
		"key_energy": 1.0,
		"ambient_energy": 0.70,
		"shadow_blur": 1.8,
		"hit_light": false
	})
	rows["b"] = _grade({
		"id": &"b",
		"pitch_deg": 10.0,
		"dof_amount": 0.18,
		"dof_near_m": 3.4,
		"dof_far_m": 7.4,
		"glow_intensity": 0.85,
		"glow_bloom": 0.16,
		"glow_threshold": 0.80,
		"key_color": Color(1.0, 0.90, 0.72),
		"key_energy": 1.2,
		"ambient_energy": 0.42,
		"shadow_blur": 0.7,
		"hit_light": true
	})
	rows["c"] = _grade({
		"id": &"c",
		"pitch_deg": 16.0,
		"dof_amount": 0.28,
		"dof_near_m": 4.5,
		"dof_far_m": 6.6,
		"glow_intensity": 1.35,
		"glow_bloom": 0.36,
		"glow_threshold": 0.55,
		"key_color": Color(1.0, 0.72, 0.45),
		"key_energy": 1.7,
		"ambient_energy": 0.20,
		"shadow_blur": 0.2,
		"hit_light": false
	})
	var plane_m := _plane_distance()
	for key in rows:
		var look: Look = rows[key]
		if look.flat:
			continue
		if look.dof_near_m >= plane_m or plane_m >= look.dof_far_m:
			push_error("hd2d look %s leaves the fighter plane outside the sharp band" % String(look.id))
	return rows


static func _flat(id: StringName) -> Look:
	var look := Look.new()
	look.id = id
	look.flat = true
	return look


static func _plane_distance() -> float:
	if _plane_distance_m > 0.0:
		return _plane_distance_m
	var visible_m := (REFERENCE_VIEWPORT_H / CLOSE_ZOOM) / PIXELS_PER_METER
	_plane_distance_m = visible_m / (2.0 * tan(deg_to_rad(TARGET_FOV_Y_DEG * 0.5)))
	return _plane_distance_m


static func _grade(fields: Dictionary) -> Look:
	var look := Look.new()
	look.id = fields["id"]
	look.flat = false
	look.pitch_deg = fields["pitch_deg"]
	look.dof_amount = fields["dof_amount"]
	look.dof_near_m = fields["dof_near_m"]
	look.dof_far_m = fields["dof_far_m"]
	look.glow_intensity = fields["glow_intensity"]
	look.glow_bloom = fields["glow_bloom"]
	look.glow_threshold = fields["glow_threshold"]
	look.key_color = fields["key_color"]
	look.key_energy = fields["key_energy"]
	look.ambient_energy = fields["ambient_energy"]
	look.shadow_blur = fields["shadow_blur"]
	look.hit_light = fields["hit_light"]
	return look


static func _pixel_to_meter(anchor_x: float, floor_y: float, px: Vector2) -> Vector3:
	return Vector3((px.x - anchor_x) / PIXELS_PER_METER, (floor_y - px.y) / PIXELS_PER_METER, 0.0)


static func _fov_y_deg(viewport_h: float, zoom: float, pitch_deg: float) -> float:
	var visible_m := (viewport_h / maxf(zoom, 0.01)) / PIXELS_PER_METER
	var perp_m := _plane_distance() * cos(deg_to_rad(pitch_deg))
	return rad_to_deg(2.0 * atan(visible_m / (2.0 * maxf(perp_m, 0.05))))


var _match: Node
var _look: Look
var _anchor_x := 450.0
var _floor_y := 340.0
var _hidden: Dictionary = {}
var _announced := false
var _camera: Camera3D
var _key: DirectionalLight3D
var _fill: DirectionalLight3D
var _hit: OmniLight3D
var _env: Environment
var _attributes: CameraAttributesPractical
var _fighters: Array[Sprite3D] = []


func bind(match_root: Node, look: Look) -> void:
	_match = match_root
	_look = look
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_world()
	_measure()
	_write_grade()
	_hide_world_roots()
	if not RenderingServer.frame_pre_draw.is_connected(_on_pre_draw):
		RenderingServer.frame_pre_draw.connect(_on_pre_draw)
	if not _announced:
		_announced = true
		var method := "unknown"
		if RenderingServer.has_method("get_current_rendering_method"):
			method = str(RenderingServer.get_current_rendering_method())
		var device := "none"
		var rendering_device := RenderingServer.get_rendering_device()
		if rendering_device != null:
			device = str(rendering_device.get_device_name())
		print("hd2d look=%s renderer=%s device=%s pitch=%s dof=%s/%s bloom=%s" % [String(look.id), method, device, look.pitch_deg, look.dof_near_m, look.dof_far_m, look.glow_bloom])


func shutdown() -> void:
	_restore_world_roots()
	if RenderingServer.frame_pre_draw.is_connected(_on_pre_draw):
		RenderingServer.frame_pre_draw.disconnect(_on_pre_draw)


func _exit_tree() -> void:
	shutdown()


func _on_pre_draw() -> void:
	if _match == null or not is_instance_valid(_match) or _look == null:
		return
	_hide_world_roots()
	_write_camera()
	_write_fighters()
	_write_hit_light()


func _ensure_world() -> void:
	if _env != null:
		return
	var world := WorldEnvironment.new()
	world.name = "World"
	_env = Environment.new()
	_env.background_mode = Environment.BG_COLOR
	_env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_env.ambient_light_color = Color(1.0, 0.86, 0.72)
	_env.tonemap_mode = Environment.TONE_MAPPER_ACES
	_env.glow_enabled = true
	_env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	world.environment = _env
	add_child(world)

	_camera = Camera3D.new()
	_camera.name = "Camera"
	_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	_camera.near = 0.05
	_camera.far = 80.0
	_attributes = CameraAttributesPractical.new()
	_attributes.dof_blur_near_enabled = true
	_attributes.dof_blur_far_enabled = true
	_camera.attributes = _attributes
	add_child(_camera)

	_key = DirectionalLight3D.new()
	_key.name = "Key"
	_key.shadow_enabled = true
	_key.shadow_bias = 0.04
	_key.shadow_normal_bias = 0.8
	_key.directional_shadow_max_distance = 40.0
	add_child(_key)

	_fill = DirectionalLight3D.new()
	_fill.name = "Fill"
	_fill.shadow_enabled = false
	_fill.light_color = FILL_COLOR
	_fill.light_energy = FILL_ENERGY
	_fill.rotation_degrees = Vector3(-20.0, 150.0, 0.0)
	add_child(_fill)

	_hit = OmniLight3D.new()
	_hit.name = "Hit"
	_hit.shadow_enabled = false
	_hit.light_color = HIT_COLOR
	_hit.omni_range = 3.2
	_hit.light_energy = 0.0
	add_child(_hit)

	_add_floor()
	_add_platforms()
	_add_backdrops()
	for slot in 2:
		var sprite := Sprite3D.new()
		sprite.name = "Fighter%s" % slot
		sprite.double_sided = true
		sprite.shaded = true
		sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		sprite.alpha_scissor_threshold = 0.5
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		sprite.pixel_size = 1.0 / PIXELS_PER_METER
		sprite.centered = true
		sprite.sorting_offset = float(slot)
		add_child(sprite)
		_fighters.append(sprite)


func _add_floor() -> void:
	var mesh_node := MeshInstance3D.new()
	mesh_node.name = "Floor"
	var box := BoxMesh.new()
	box.size = Vector3(7.6, 0.4, FRONT_LIP_M + REAR_DEPTH_M)
	mesh_node.mesh = box
	mesh_node.position = Vector3(0.0, -0.2, (FRONT_LIP_M - REAR_DEPTH_M) * 0.5)
	mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.72, 0.48, 0.32)
	material.roughness = 0.88
	var texture := load("res://assets/sprites/arena/arena_floor.png")
	if texture is Texture2D:
		material.albedo_texture = texture
		material.uv1_scale = Vector3(2.4, 1.2, 1.0)
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	mesh_node.material_override = material
	add_child(mesh_node)


func _add_platforms() -> void:
	for slot in 2:
		var mesh_node := MeshInstance3D.new()
		mesh_node.name = "Platform%s" % slot
		var box := BoxMesh.new()
		box.size = Vector3(1.44, 0.14, PLATFORM_DEPTH_M)
		mesh_node.mesh = box
		mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.86, 0.62, 0.40)
		material.roughness = 0.8
		mesh_node.material_override = material
		add_child(mesh_node)


func _add_backdrops() -> void:
	var specs := [
		{"name": "BackdropFar", "z": -14.0, "y": 4.2, "size": Vector2(34.0, 18.0), "color": Color(0.55, 0.32, 0.22), "texture": true},
		{"name": "BackdropMid", "z": -8.0, "y": 1.6, "size": Vector2(22.0, 4.2), "color": Color(0.28, 0.14, 0.10), "texture": false},
		{"name": "BackdropNear", "z": -4.4, "y": 0.85, "size": Vector2(16.0, 1.5), "color": Color(0.42, 0.22, 0.14), "texture": false}
	]
	var painting := load("res://assets/sprites/arena/arena_bg.png")
	for spec in specs:
		var mesh_node := MeshInstance3D.new()
		mesh_node.name = str(spec["name"])
		var quad := QuadMesh.new()
		quad.size = spec["size"]
		mesh_node.mesh = quad
		mesh_node.position = Vector3(0.0, float(spec["y"]), float(spec["z"]))
		mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = spec["color"]
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		if bool(spec["texture"]) and painting is Texture2D:
			material.albedo_texture = painting
			material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
		mesh_node.material_override = material
		add_child(mesh_node)


func _measure() -> void:
	var arena := _match.get_node_or_null("Arena")
	var ground := arena.get_node_or_null("Ground/CollisionShape2D") if arena != null else null
	if ground is CollisionShape2D and (ground as CollisionShape2D).shape is RectangleShape2D:
		var shape_node := ground as CollisionShape2D
		var shape := shape_node.shape as RectangleShape2D
		var scale := shape_node.global_scale.abs()
		var size := shape.size * scale
		var center := shape_node.global_position
		_anchor_x = center.x
		_floor_y = center.y - size.y * 0.5
		var floor := get_node_or_null("Floor") as MeshInstance3D
		if floor != null and floor.mesh is BoxMesh:
			var box := floor.mesh as BoxMesh
			box.size = Vector3(size.x / PIXELS_PER_METER, size.y / PIXELS_PER_METER, FRONT_LIP_M + REAR_DEPTH_M)
			var mid := _pixel_to_meter(_anchor_x, _floor_y, Vector2(center.x, _floor_y))
			floor.position = Vector3(mid.x, -box.size.y * 0.5, (FRONT_LIP_M - REAR_DEPTH_M) * 0.5)
	else:
		_anchor_x = (StageConfigStore.DEFAULT_LEFT_X + StageConfigStore.DEFAULT_RIGHT_X) * 0.5
		_floor_y = StageConfigStore.DEFAULT_FLOOR_Y
	_place_platform(0, "PlatformLeft")
	_place_platform(1, "PlatformRight")


func _place_platform(slot: int, node_name: String) -> void:
	var mesh_node := get_node_or_null("Platform%s" % slot) as MeshInstance3D
	if mesh_node == null:
		return
	var arena := _match.get_node_or_null("Arena")
	var body := arena.get_node_or_null(node_name) as CollisionObject2D if arena != null else null
	var shape_node := body.get_node_or_null("CollisionShape2D") as CollisionShape2D if body != null else null
	var active := body != null and body.collision_layer != 0 and shape_node != null and not shape_node.disabled and shape_node.shape is RectangleShape2D
	mesh_node.visible = active
	if not active:
		return
	var rect := shape_node
	var shape := rect.shape as RectangleShape2D
	var scale := rect.global_scale.abs()
	var size := shape.size * scale
	var center := rect.global_position
	var surface_y := center.y - size.y * 0.5
	var top := _pixel_to_meter(_anchor_x, _floor_y, Vector2(center.x, surface_y))
	var box := mesh_node.mesh as BoxMesh
	box.size = Vector3(size.x / PIXELS_PER_METER, maxf(size.y / PIXELS_PER_METER, 0.08), PLATFORM_DEPTH_M)
	mesh_node.position = Vector3(top.x, top.y - box.size.y * 0.5, 0.0)


func _write_grade() -> void:
	_env.background_color = Color(0.10, 0.05, 0.04)
	_env.ambient_light_energy = _look.ambient_energy
	_env.glow_intensity = _look.glow_intensity
	_env.glow_bloom = _look.glow_bloom
	_env.glow_hdr_threshold = _look.glow_threshold
	_attributes.dof_blur_amount = _look.dof_amount
	_attributes.dof_blur_near_distance = _look.dof_near_m
	_attributes.dof_blur_far_distance = _look.dof_far_m
	_key.light_color = _look.key_color
	_key.light_energy = _look.key_energy
	_key.shadow_blur = _look.shadow_blur
	_key.rotation_degrees = Vector3(-42.0, -36.0, 0.0)


func _write_camera() -> void:
	var camera := _match.get_viewport().get_camera_2d()
	if camera == null:
		return
	camera.force_update_scroll()
	var center := camera.get_screen_center_position()
	var zoom := maxf(camera.zoom.x, 0.01)
	var viewport_h: float = _match.get_viewport_rect().size.y
	var look := _pixel_to_meter(_anchor_x, _floor_y, center)
	var pitch := deg_to_rad(_look.pitch_deg)
	var eye := look
	var plane_m := _plane_distance()
	eye.y += plane_m * sin(pitch)
	# Sit on +Z. A camera on -Z yaws 180 and swaps left and right.
	eye.z += plane_m * cos(pitch)
	_camera.look_at_from_position(eye, look, Vector3.UP)
	_camera.fov = _fov_y_deg(viewport_h, zoom, _look.pitch_deg)
	_camera.make_current()


func _write_fighters() -> void:
	var names: Array[String] = ["Player1", "Player2"]
	for slot in names.size():
		var sprite := _fighters[slot]
		var body := _match.get_node_or_null(names[slot])
		var visual := body.get_node_or_null("Visual") as AnimatedSprite2D if body != null else null
		var texture := _frame_texture(visual)
		sprite.visible = texture != null
		if texture == null or visual == null:
			continue
		sprite.texture = texture
		sprite.flip_h = visual.flip_h
		sprite.modulate = visual.modulate
		sprite.offset = visual.offset
		sprite.scale = Vector3(absf(visual.scale.x), absf(visual.scale.y), 1.0)
		var point := _pixel_to_meter(_anchor_x, _floor_y, visual.global_position)
		point.z = FIGHTER_DRAW_ORDER_Z_M * float(slot)
		sprite.position = point


func _frame_texture(visual: Node) -> Texture2D:
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


func _write_hit_light() -> void:
	if not _look.hit_light:
		_hit.light_energy = 0.0
		return
	var best := 0.0
	var at := Vector3.ZERO
	var found := false
	var names: Array[String] = ["Player1", "Player2"]
	for node_name in names:
		var body := _match.get_node_or_null(node_name)
		if body == null:
			continue
		var stun := float(body.get("hitstun_time")) if body.get("hitstun_time") != null else 0.0
		if stun <= best:
			continue
		var visual := body.get_node_or_null("Visual") as Node2D
		if visual == null:
			continue
		best = stun
		at = _pixel_to_meter(_anchor_x, _floor_y, visual.global_position)
		found = true
	if found:
		_hit.light_energy = HIT_ENERGY
		_hit.position = at + Vector3(0.0, 0.45, 0.45)
		return
	var flash := _match.get_node_or_null("ScreenFx/Flash") as ColorRect
	var alpha := flash.color.a if flash != null else 0.0
	_hit.light_energy = HIT_ENERGY * alpha
	if alpha > 0.0 and _fighters.size() == 2:
		_hit.position = (_fighters[0].position + _fighters[1].position) * 0.5 + Vector3(0.0, 0.4, 0.4)


func _hide_world_roots() -> void:
	if _match == null:
		return
	for child in _match.get_children():
		if child is CanvasLayer or child is Camera2D:
			continue
		if str(child.name) == STAGE_NAME:
			continue
		if child is CanvasItem:
			var item := child as CanvasItem
			if not _hidden.has(item):
				_hidden[item] = item.visible
			item.visible = false


func _restore_world_roots() -> void:
	for item in _hidden.keys():
		if is_instance_valid(item) and item is CanvasItem:
			(item as CanvasItem).visible = bool(_hidden[item])
	_hidden.clear()

extends RefCounted

const LookB := preload("res://scripts/picture/LookB.gd")
const HudCorners := preload("res://scripts/hud/HudCorners.gd")

const _LOOK_B_SCRIPT := "res://scripts/picture/LookB.gd"
const _PICTURE_SCRIPT := "res://scripts/picture/StagePicture.gd"
const _NUMBER := "(\\d+(?:\\.\\d+)?)"


static func scan(project_root: String) -> PackedStringArray:
	var failures := PackedStringArray()
	var root := _trim_slash(project_root)
	var doc := _read_text(_join(root, "docs/design/north-star.md"))
	var camera := _section_after(doc, "### Camera, focus, and light", "\n### ")
	var decisions := _section_after(doc, "Look B, the pick,", "\n\n")
	if camera == "":
		failures.append("missing Camera, focus, and light section")
	if decisions == "":
		failures.append("missing Look B decisions paragraph")
	_lock_prose(failures, camera, decisions)
	_lock_hud(failures, doc)
	_lock_formula(failures, camera)
	_lock_cover(failures)
	_lock_backdrop_disc(failures, root)
	_lock_project(failures, _read_text(_join(root, "project.godot")))
	_lock_sources(failures, root)
	_lock_picture_source(failures, root)
	_lock_grade_behavior(failures)
	return failures


static func boot(tree: SceneTree) -> PackedStringArray:
	var failures := PackedStringArray()
	tree.paused = false
	failures.append_array(await _boot_menu(tree))
	for path in ["res://scenes/Main.tscn", "res://scenes/Story.tscn", "res://scenes/Training.tscn"]:
		failures.append_array(await _boot_match(tree, path))
	tree.paused = false
	return failures


static func _lock_prose(failures: PackedStringArray, camera: String, decisions: String) -> void:
	_require(failures, camera, "One hundred pixels is one meter.")
	_lock(failures, "pixels per meter", LookB.PIXELS_PER_METER, "100")
	_lock_found(failures, "pitch", LookB.PITCH_DEG, camera, "Pitch\\. " + _NUMBER + " degrees above a side view")
	_lock_found(failures, "pitch in the tightened sentence", LookB.PITCH_DEG, camera, "pitch of " + _NUMBER + " degrees")
	_lock_found(failures, "decisions pitch", LookB.PITCH_DEG, decisions, "Pitch is " + _NUMBER + " degrees")
	_lock_found(failures, "decisions pitch repeat", LookB.PITCH_DEG, decisions, "pitch " + _NUMBER + " degrees")
	_require(failures, camera, "with near blur and far blur on")
	if not LookB.DOF_NEAR_ENABLED or not LookB.DOF_FAR_ENABLED:
		failures.append("depth of field blurs are off")
	_lock_triple(
		failures,
		"depth of field",
		camera,
		"Near distance " + _NUMBER + " m, far distance " + _NUMBER + " m, amount " + _NUMBER,
		[LookB.DOF_NEAR_M, LookB.DOF_FAR_M, LookB.DOF_AMOUNT]
	)
	_lock_triple(
		failures,
		"decisions depth of field",
		decisions,
		"near distance is " + _NUMBER + " m, far distance is " + _NUMBER + " m, and amount is " + _NUMBER,
		[LookB.DOF_NEAR_M, LookB.DOF_FAR_M, LookB.DOF_AMOUNT]
	)
	_lock_triple(
		failures,
		"bloom",
		camera,
		"`glow_intensity`\\s+" + _NUMBER + ",\\s+`glow_bloom`\\s+" + _NUMBER + ",\\s+`glow_hdr_threshold`\\s+" + _NUMBER,
		[LookB.GLOW_INTENSITY, LookB.GLOW_BLOOM, LookB.GLOW_HDR_THRESHOLD]
	)
	_lock_triple(
		failures,
		"decisions bloom",
		decisions,
		"Bloom intensity is " + _NUMBER + ", bloom is " + _NUMBER + ", and the HDR threshold is " + _NUMBER,
		[LookB.GLOW_INTENSITY, LookB.GLOW_BLOOM, LookB.GLOW_HDR_THRESHOLD]
	)
	_require(failures, camera, "blend mode soft light")
	if not LookB.GLOW_ENABLED:
		failures.append("glow is off")
	if LookB.GLOW_BLEND != Environment.GLOW_BLEND_MODE_SOFTLIGHT:
		failures.append("glow blend is not soft light")
	_require(failures, camera, "so a sprite casts a shadow on the floor")
	if not LookB.KEY_SHADOW_ENABLED:
		failures.append("key light shadow is off")
	var key := _paragraph_starting(camera, "Key light.")
	_lock_color(failures, "key light", LookB.KEY_COLOR, LookB.KEY_ENERGY, key, "Color is red " + _NUMBER + ", green " + _NUMBER + ", blue " + _NUMBER + ", energy " + _NUMBER)
	_lock_color(failures, "decisions key light", LookB.KEY_COLOR, LookB.KEY_ENERGY, decisions, "The key light is red " + _NUMBER + ", green " + _NUMBER + ", blue " + _NUMBER + ", at energy " + _NUMBER)
	var hit := _paragraph_starting(camera, "Hit point light.")
	_lock_color(failures, "hit light", LookB.HIT_COLOR, LookB.HIT_ENERGY, hit, "Color is red " + _NUMBER + ", green " + _NUMBER + ", blue " + _NUMBER + ", energy " + _NUMBER)
	_lock_found(failures, "hit range", LookB.HIT_RANGE_M, hit, "range " + _NUMBER + " m")
	_lock_color(failures, "decisions hit light", LookB.HIT_COLOR, LookB.HIT_ENERGY, decisions, "The hit point light is red " + _NUMBER + ", green " + _NUMBER + ", blue " + _NUMBER + ", at energy " + _NUMBER)
	_lock_found(failures, "decisions hit range", LookB.HIT_RANGE_M, decisions, "range " + _NUMBER + " m")
	var decisions_window := _search(decisions, "At zoom " + _NUMBER + ", pitch " + _NUMBER + " degrees, and a " + _NUMBER + " px tall window, the vertical field of view is " + _NUMBER + " degrees")
	if decisions_window == null:
		failures.append("missing decisions field of view sentence")
	else:
		_lock(failures, "decisions zoom", LookB.REFERENCE_ZOOM, decisions_window.get_string(1))
		_lock(failures, "decisions viewport height", LookB.REFERENCE_VIEWPORT_H, decisions_window.get_string(3))
		_lock(failures, "decisions field of view", LookB.fov_y_deg(LookB.REFERENCE_VIEWPORT_H, LookB.REFERENCE_ZOOM), decisions_window.get_string(4))
	_require(failures, camera, "It is on while the defender is in hitstun.")
	_require(failures, decisions, "it is on during hitstun")
	_lock_found(failures, "camera distance", LookB.PLANE_DISTANCE_M, camera, "The camera is " + _NUMBER + " m from the fighter plane")
	_lock_found(failures, "decisions camera distance", LookB.PLANE_DISTANCE_M, decisions, "The camera is " + _NUMBER + " m from the fighter plane")
	_lock_found(failures, "untightened field of view", LookB.UNTIGHTENED_FOV_Y_DEG, camera, _NUMBER + " degree vertical field of view")
	_lock_found(failures, "reference zoom", LookB.REFERENCE_ZOOM, camera, "at zoom " + _NUMBER + " on a " + _NUMBER + " px tall window")
	var window_match := _search(camera, "at zoom " + _NUMBER + " on a " + _NUMBER + " px tall window")
	if window_match != null:
		_lock(failures, "reference viewport height", LookB.REFERENCE_VIEWPORT_H, window_match.get_string(2))
	_lock_found(failures, "frame tighten", LookB.FRAME_TIGHTEN, camera, "divides the visible height by " + _NUMBER)
	_require(failures, camera, "The pick requires Forward+.")
	if LookB.RENDERER_METHOD != "forward_plus":
		failures.append("renderer method is %s" % LookB.RENDERER_METHOD)


static func _lock_hud(failures: PackedStringArray, doc: String) -> void:
	var hud := _section_after(doc, "### HUD", "\n### ")
	if hud == "":
		failures.append("missing HUD section")
		return
	_require(failures, hud, "P1 sits in the top-left block.")
	_require(failures, hud, "P2 sits in the top-right block.")
	_require(failures, hud, "The timer is centred.")
	_lock_found(failures, "hud margin", HudCorners.MARGIN, hud, "Margin is " + _NUMBER + " px")
	_lock_found(failures, "hud card top", HudCorners.CARD_TOP, hud, "starts " + _NUMBER + " px from the top")
	_lock_found(failures, "hud card height", HudCorners.CARD_HEIGHT, hud, "is " + _NUMBER + " px tall")
	_lock_found(failures, "hud card width", HudCorners.CARD_MAX_WIDTH, hud, "at most " + _NUMBER + " px wide")
	_lock_found(failures, "hud dialogue gap", HudCorners.DIALOGUE_GAP, hud, "gap before the dialogue bar is " + _NUMBER + " px")
	_lock_found(failures, "hud dialogue width", HudCorners.DIALOGUE_MAX_WIDTH, hud, "The dialogue bar is at most " + _NUMBER + " px wide")
	_lock_triple(failures, "hud white", hud, "Percent at 0 is red " + _NUMBER + ", green " + _NUMBER + ", blue " + _NUMBER, [HudCorners.PERCENT_WHITE.r, HudCorners.PERCENT_WHITE.g, HudCorners.PERCENT_WHITE.b])
	_lock_triple(failures, "hud gold", hud, "Gold is red " + _NUMBER + ", green " + _NUMBER + ", blue " + _NUMBER, [HudCorners.PERCENT_GOLD.r, HudCorners.PERCENT_GOLD.g, HudCorners.PERCENT_GOLD.b])
	_lock_triple(failures, "hud orange", hud, "Orange is red " + _NUMBER + ", green " + _NUMBER + ", blue " + _NUMBER, [HudCorners.PERCENT_ORANGE.r, HudCorners.PERCENT_ORANGE.g, HudCorners.PERCENT_ORANGE.b])
	_lock_triple(failures, "hud red", hud, "Full damage is red " + _NUMBER + ", green " + _NUMBER + ", blue " + _NUMBER, [HudCorners.PERCENT_RED.r, HudCorners.PERCENT_RED.g, HudCorners.PERCENT_RED.b])
	_lock_found(failures, "hud gold stop", HudCorners.RAMP_GOLD, hud, "The gold stop is " + _NUMBER)
	_lock_found(failures, "hud orange stop", HudCorners.RAMP_ORANGE, hud, "The orange stop is " + _NUMBER)
	_lock_found(failures, "hud pop scale", HudCorners.POP_SCALE, hud, "adds scale " + _NUMBER)
	_lock_found(failures, "hud shake", HudCorners.SHAKE_PX, hud, "shakes the percent by " + _NUMBER + " px")
	_lock_found(failures, "hud pop duration", HudCorners.POP_DURATION_SECONDS, hud, "The pop lasts " + _NUMBER + " seconds")
	_lock_found(failures, "hud outline", HudCorners.OUTLINE_SIZE, hud, "The percent outline is " + _NUMBER + " px")
	_require(failures, hud, "Hype, cooldowns, shield, and item charges stay off the block while they are at rest.")


static func _lock_formula(failures: PackedStringArray, camera: String) -> void:
	var visible_m := (LookB.REFERENCE_VIEWPORT_H / LookB.REFERENCE_ZOOM) / LookB.PIXELS_PER_METER
	var distance := visible_m / (2.0 * tan(deg_to_rad(LookB.UNTIGHTENED_FOV_Y_DEG * 0.5)))
	if absf(distance - LookB.PLANE_DISTANCE_M) > 1e-6:
		failures.append("plane distance constant misses the 50 degree formula")
	if absf(LookB.plane_distance_m() - LookB.PLANE_DISTANCE_M) > 1e-6:
		failures.append("plane_distance_m() misses PLANE_DISTANCE_M")
	if not (LookB.DOF_NEAR_M < LookB.plane_distance_m() and LookB.plane_distance_m() < LookB.DOF_FAR_M):
		failures.append("fighter plane leaves the sharp band")
	var fov_match := _search(camera, "the vertical field of view is " + _NUMBER + " degrees")
	if fov_match == null:
		failures.append("missing tightened field of view sentence")
		return
	var fov_token := fov_match.get_string(1)
	var window_match := _search(camera, "at zoom " + _NUMBER + " on a " + _NUMBER + " px tall window")
	if window_match == null:
		failures.append("missing reference zoom window sentence")
		return
	var close := LookB.fov_y_deg(float(window_match.get_string(2)), float(window_match.get_string(1)))
	_lock(failures, "tightened field of view", close, fov_token)
	var far_zoom := _camera_zoom_far(_read_text(ProjectSettings.globalize_path("res://scenes/Main.tscn")))
	if far_zoom <= 0.0:
		failures.append("missing camera_zoom_far on Main.tscn")
		return
	var far := LookB.fov_y_deg(float(window_match.get_string(2)), far_zoom)
	if _format_like(far, fov_token) == fov_token:
		failures.append("far zoom still formats as the reference field of view")
	var distance_match := _search(camera, "The camera is " + _NUMBER + " m from the fighter plane")
	if distance_match != null:
		_lock(failures, "computed plane distance", LookB.plane_distance_m(), distance_match.get_string(1))


static func _lock_cover(failures: PackedStringArray) -> void:
	var aim := Vector3(0.0, 0.88, 0.0)
	var views := [
		{"height": 720.0, "aspect": 16.0 / 9.0, "zoom": LookB.REFERENCE_ZOOM, "label": "720 16:9"},
		{"height": 1080.0, "aspect": 16.0 / 9.0, "zoom": LookB.REFERENCE_ZOOM, "label": "1080 16:9"},
		{"height": 1440.0, "aspect": 16.0 / 9.0, "zoom": LookB.REFERENCE_ZOOM, "label": "1440 16:9"},
		{"height": 720.0, "aspect": 2560.0 / 1080.0, "zoom": LookB.REFERENCE_ZOOM, "label": "720 ultrawide"},
		{"height": 960.0, "aspect": 4.0 / 3.0, "zoom": LookB.REFERENCE_ZOOM, "label": "960 4:3"},
		{"height": 720.0, "aspect": 16.0 / 9.0, "zoom": 1.08, "label": "720 zoomed out"},
	]
	for view in views:
		var height := float(view["height"])
		var aspect := float(view["aspect"])
		var zoom := float(view["zoom"])
		var label := str(view["label"])
		var fov := LookB.fov_y_deg(height, zoom)
		var frustum := LookB.frustum_rect_at_backdrop(fov, aspect, aim)
		var cover := LookB.backdrop_cover_rect(fov, aspect, aim)
		if not cover.encloses(frustum):
			failures.append("%s backdrop leaves the frustum" % label)
		var card := LookB.backdrop_card_rect()
		var center := card.position + card.size * 0.5
		var center_uv := LookB.backdrop_sample_uv(cover, center.x, center.y)
		if center_uv.distance_to(Vector2(0.5, 0.5)) > 0.001:
			failures.append("%s moved the backdrop center" % label)
		var top_left := Vector2(card.position.x, card.position.y + card.size.y)
		var top_left_uv := LookB.backdrop_sample_uv(cover, top_left.x, top_left.y)
		if top_left_uv.distance_to(Vector2.ZERO) > 0.001:
			failures.append("%s moved the backdrop top left" % label)
	_lock_floor_cover(failures, aim)


static func _lock_floor_cover(failures: PackedStringArray, aim: Vector3) -> void:
	var center_x := 0.0
	var width_px := 760.0
	var deck := LookB.floor_deck_rect(center_x, width_px)
	for view in [
		{"height": 720.0, "aspect": 16.0 / 9.0, "zoom": LookB.REFERENCE_ZOOM, "label": "floor 720"},
		{"height": 1080.0, "aspect": 16.0 / 9.0, "zoom": LookB.REFERENCE_ZOOM, "label": "floor 1080"},
		{"height": 1440.0, "aspect": 16.0 / 9.0, "zoom": LookB.REFERENCE_ZOOM, "label": "floor 1440"},
		{"height": 720.0, "aspect": 2560.0 / 1080.0, "zoom": LookB.REFERENCE_ZOOM, "label": "floor ultrawide"},
	]:
		var fov := LookB.fov_y_deg(float(view["height"]), float(view["zoom"]))
		var aspect := float(view["aspect"])
		var label := str(view["label"])
		var cover := LookB.floor_cover_rect(fov, aspect, aim, center_x, width_px)
		if not cover.encloses(deck):
			failures.append("%s dropped the stage deck" % label)
		var hit := LookB.floor_ray_hit(fov, aspect, aim, 0.0, -1.0)
		if not cover.has_point(Vector2(hit.x, hit.z)):
			failures.append("%s floor misses the bottom of the frame" % label)
		var uv: Dictionary = LookB.floor_uv_params(cover, deck)
		var scale: Vector2 = uv["scale"]
		var offset: Vector2 = uv["offset"]
		var center := deck.position + deck.size * 0.5
		var mesh_u := 0.5 + (center.x - (cover.position.x + cover.size.x * 0.5)) / cover.size.x
		var mesh_v := 0.5 + (center.y - (cover.position.y + cover.size.y * 0.5)) / cover.size.y
		var sampled := Vector2(mesh_u * scale.x + offset.x, mesh_v * scale.y + offset.y)
		if sampled.distance_to(Vector2(0.5, 0.5)) > 0.001:
			failures.append("%s moved the floor center" % label)


static func _lock_backdrop_disc(failures: PackedStringArray, root: String) -> void:
	var image := Image.new()
	var loaded := image.load(_join(root, "assets/sprites/arena/arena_bg.png"))
	if loaded != OK:
		failures.append("backdrop image failed to load")
		return
	var warm := 0
	var sky_rows := mini(180, image.get_height())
	for y in sky_rows:
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.r > 0.7 and color.g > 0.6 and color.b > 0.55 and color.r > color.b:
				warm += 1
	if warm > 0:
		failures.append("backdrop sky still has a bright disc (%d)" % warm)


static func _lock_project(failures: PackedStringArray, project_text: String) -> void:
	var expected := "renderer/rendering_method=\"%s\"" % LookB.RENDERER_METHOD
	var lines := PackedStringArray()
	for raw in project_text.split("\n"):
		var line := raw.strip_edges()
		if line.begins_with(";") or line.begins_with("#"):
			continue
		if line.find("rendering_method") >= 0:
			lines.append(line)
	if lines.size() != 1 or lines[0] != expected:
		failures.append("project.godot rendering method is %s" % _packed_text(lines))
	if project_text.find("--look") >= 0 or project_text.find("cycle_hd2d") >= 0:
		failures.append("project.godot contains a look switch")


static func _lock_sources(failures: PackedStringArray, root: String) -> void:
	var match_text := _read_text(_join(root, "scripts/Match.gd"))
	if _count(match_text, "attach(self)") != 1:
		failures.append("Match.gd attach(self) count is %d" % _count(match_text, "attach(self)"))
	if match_text.find(_PICTURE_SCRIPT) < 0:
		failures.append("Match.gd does not preload the picture")
	for token in ["Hd2d", "take_look", "cycle_hd2d", "--look"]:
		if match_text.find(token) >= 0:
			failures.append("Match.gd contains %s" % token)
	for relative in ["scripts/driver/MatchDriverCli.gd", "scripts/ffc.sh", "project.godot"]:
		var text := _read_text(_join(root, relative))
		if text.find("--look") >= 0 or text.find("cycle_hd2d") >= 0:
			failures.append("%s contains a look switch" % relative)
	var picture_dir := _join(root, "scripts/picture")
	var scripts := _gd_names(picture_dir)
	if scripts.size() != 2 or scripts.find("LookB.gd") < 0 or scripts.find("StagePicture.gd") < 0:
		failures.append("scripts/picture scripts are %s" % _packed_text(scripts))
	_lock_preloads(failures, root)


static func _lock_picture_source(failures: PackedStringArray, root: String) -> void:
	var picture_text := _read_text(_join(root, "scripts/picture/StagePicture.gd"))
	var stripped := _strip_hash_comments(picture_text)
	var regex := RegEx.new()
	regex.compile("(?<![\\w.])(?:\\d+\\.\\d+|\\d+)(?![\\w])")
	var allowed := {"0": true, "1": true, "0.0": true, "1.0": true}
	for found in regex.search_all(stripped):
		var token := found.get_string()
		if not allowed.has(token):
			failures.append("StagePicture.gd numeric literal %s" % token)
	var picture_sources := _read_text(_join(root, "scripts/picture/LookB.gd")) + "\n" + picture_text
	var code := _strip_hash_comments(picture_sources)
	for token in ["randf", "randi", "RandomNumberGenerator", "move_and_slide"]:
		if _has_call(code, token):
			failures.append("scripts/picture calls %s" % token)
	for name in ["velocity", "current_hp", "hitstun_time"]:
		if _assigns(code, name):
			failures.append("scripts/picture assigns %s" % name)
	if picture_text.find("class_name") >= 0 or _read_text(_join(root, "scripts/picture/LookB.gd")).find("class_name") >= 0:
		failures.append("picture scripts declare class_name")
	if picture_text.find("func _process") >= 0 or picture_text.find("func _physics_process") >= 0:
		failures.append("StagePicture.gd uses a process tick")
	if picture_text.find("Camera2D.new") >= 0:
		failures.append("StagePicture.gd builds a second 2D camera")


static func _lock_grade_behavior(failures: PackedStringArray) -> void:
	var ppm := LookB.PIXELS_PER_METER
	var point := LookB.plane_point(0.0, ppm, Vector2(ppm, 0.0))
	if not is_equal_approx(point.x, 1.0) or not is_equal_approx(point.y, 1.0) or not is_equal_approx(point.z, 0.0):
		failures.append("pixel map is not the gameplay plane")
	var tied := PackedFloat32Array([0.2, 0.2])
	if LookB.hit_slot(tied) != 0:
		failures.append("equal hitstun does not keep Player1")
	var later := PackedFloat32Array([0.1, 0.4])
	if LookB.hit_slot(later) != 1:
		failures.append("greater hitstun does not win")
	var idle := PackedFloat32Array([0.0, 0.0])
	if LookB.hit_slot(idle) != -1:
		failures.append("idle hitstun does not clear the lamp")
	var placed := LookB.fighter_position(0.0, 0.0, Vector2.ZERO, 1)
	if not is_equal_approx(placed.y, -LookB.FOOT_DROP_M) or not is_equal_approx(placed.z, LookB.FIGHTER_Z_STEP_M):
		failures.append("fighter card misses the foot drop or the z step")


static func _lock_preloads(failures: PackedStringArray, root: String) -> void:
	var files: Array[String] = []
	_collect_gd(_join(root, "scripts"), files)
	_collect_gd(_join(root, "tests"), files)
	for path in files:
		var text := _read_text(path)
		var base := path.get_file()
		if text.find(_LOOK_B_SCRIPT) >= 0 and base != "StagePicture.gd" and base != "PictureContract.gd":
			failures.append("%s preloads LookB" % base)
		if text.find(_PICTURE_SCRIPT) >= 0 and base != "Match.gd" and base != "StagePicture.gd" and base != "PictureContract.gd":
			failures.append("%s preloads StagePicture" % base)


static func _boot_menu(tree: SceneTree) -> PackedStringArray:
	var failures := PackedStringArray()
	var packed = load("res://scenes/Menu.tscn")
	if not packed is PackedScene:
		failures.append("menu scene failed to load")
		return failures
	var menu := (packed as PackedScene).instantiate()
	tree.root.add_child(menu)
	await tree.process_frame
	await tree.process_frame
	if menu.find_child("StagePicture", true, false) != null:
		failures.append("menu grew a StagePicture")
	menu.queue_free()
	await tree.process_frame
	return failures


static func _boot_match(tree: SceneTree, path: String) -> PackedStringArray:
	var failures := PackedStringArray()
	var packed = load(path)
	if not packed is PackedScene:
		failures.append("%s failed to load" % path)
		return failures
	var match_node := (packed as PackedScene).instantiate()
	tree.root.add_child(match_node)
	await tree.process_frame
	await tree.process_frame
	_check_match(failures, match_node, path)
	_check_world_sprite(failures, match_node, path)
	var picture_script = load(_PICTURE_SCRIPT)
	picture_script.attach(match_node)
	if _count_named(match_node, "StagePicture") != 1:
		failures.append("%s grew a second StagePicture" % path)
	var before := _simulation(match_node)
	tree.paused = true
	await tree.process_frame
	await tree.process_frame
	var after := _simulation(match_node)
	tree.paused = false
	if not _same_simulation(before, after):
		failures.append("%s pause moved the simulation" % path)
	match_node.queue_free()
	await tree.process_frame
	return failures


static func _check_match(failures: PackedStringArray, match_node: Node, path: String) -> void:
	for node_name in ["Player1", "Player2"]:
		var body := match_node.get_node_or_null(node_name)
		if not (body is CharacterBody2D):
			failures.append("%s %s is not a CharacterBody2D" % [path, node_name])
		elif body is CanvasItem and (body as CanvasItem).visible:
			failures.append("%s %s is still visible" % [path, node_name])
	var camera_value: Variant = match_node.get("camera")
	if not (camera_value is Camera2D):
		failures.append("%s has no Camera2D" % path)
	else:
		var camera_2d := camera_value as Camera2D
		if not camera_2d.enabled:
			failures.append("%s Camera2D is disabled" % path)
	var picture_camera := match_node.get_node_or_null("StagePicture/Camera") as Camera3D
	var viewport_camera := match_node.get_viewport().get_camera_3d() if match_node.get_viewport() != null else null
	if picture_camera == null or viewport_camera != picture_camera:
		failures.append("%s viewport camera is not StagePicture/Camera" % path)
	else:
		var ray_z := LookB.PLANE_DISTANCE_M * cos(deg_to_rad(LookB.PITCH_DEG))
		if not is_equal_approx(picture_camera.global_position.z, ray_z):
			failures.append("%s camera z is %s" % [path, picture_camera.global_position.z])
		var attributes := picture_camera.attributes as CameraAttributesPractical
		if attributes == null or not attributes.dof_blur_near_enabled or not attributes.dof_blur_far_enabled:
			failures.append("%s depth of field is off" % path)
		elif not is_equal_approx(attributes.dof_blur_amount, LookB.DOF_AMOUNT):
			failures.append("%s depth of field amount drifted" % path)
		elif not is_equal_approx(attributes.dof_blur_near_distance, LookB.DOF_NEAR_M) or not is_equal_approx(attributes.dof_blur_far_distance, LookB.DOF_FAR_M):
			failures.append("%s depth of field distances drifted" % path)
	var picture := match_node.get_node_or_null("StagePicture")
	if picture == null or picture.process_mode != Node.PROCESS_MODE_ALWAYS:
		failures.append("%s picture does not keep drawing while paused" % path)
	for layer_name in ["Hud", "ScreenFx"]:
		var layer := match_node.get_node_or_null(layer_name) as CanvasLayer
		if layer == null or not layer.visible:
			failures.append("%s %s is not a visible canvas layer" % [path, layer_name])
	var arena := match_node.get_node_or_null("Arena")
	if not (arena is CanvasItem) or (arena as CanvasItem).visible:
		failures.append("%s arena is not hidden" % path)
	_check_lamp(failures, match_node, path)
	_check_fighter_cards(failures, match_node, path)


static func _check_world_sprite(failures: PackedStringArray, match_node: Node, path: String) -> void:
	var image := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.2, 0.8, 0.4, 1.0))
	var texture := ImageTexture.create_from_image(image)
	var root := Node2D.new()
	root.name = "ProbeProjectile"
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = Vector2(12, -8)
	root.add_child(sprite)
	root.global_position = Vector2(450, 300)
	match_node.add_child(root)
	var picture := match_node.get_node_or_null("StagePicture")
	if picture != null and picture.has_method("_publish"):
		picture._publish()
	var found := false
	if picture != null:
		for child in picture.get_children():
			if child is Sprite3D and (child as Sprite3D).texture == texture and (child as Sprite3D).visible:
				found = true
	if not found:
		failures.append("%s hid a match sprite that is not an impact spark" % path)
	if is_instance_valid(root):
		root.queue_free()


static func _check_lamp(failures: PackedStringArray, match_node: Node, path: String) -> void:
	var picture := match_node.get_node_or_null("StagePicture")
	if picture == null:
		return
	var lamp: OmniLight3D = null
	for child in picture.get_children():
		if child is OmniLight3D:
			lamp = child as OmniLight3D
	if lamp == null:
		failures.append("%s has no hit lamp" % path)
		return
	var best := 0.0
	for node_name in ["Player1", "Player2"]:
		var body := match_node.get_node_or_null(node_name)
		if body != null:
			best = maxf(best, float(body.get("hitstun_time")))
	if best <= 0.0 and not is_equal_approx(lamp.light_energy, 0.0):
		failures.append("%s hit lamp is on without hitstun" % path)
	elif best > 0.0 and not is_equal_approx(lamp.light_energy, LookB.HIT_ENERGY):
		failures.append("%s hit lamp missed hitstun" % path)


static func _check_fighter_cards(failures: PackedStringArray, match_node: Node, path: String) -> void:
	var picture := match_node.get_node_or_null("StagePicture")
	if picture == null:
		return
	for slot in [0, 1]:
		var sprite := picture.get_node_or_null("Fighter%s" % slot) as Sprite3D
		if sprite == null or not sprite.visible:
			failures.append("%s fighter card %s is missing" % [path, slot])
			continue
		var expected_z := LookB.FIGHTER_Z_STEP_M * float(slot)
		if not is_equal_approx(sprite.position.z, expected_z):
			failures.append("%s fighter card %s depth is %s" % [path, slot, sprite.position.z])


static func _simulation(match_node: Node) -> Dictionary:
	var players: Array = []
	for node_name in ["Player1", "Player2"]:
		var body := match_node.get_node_or_null(node_name)
		if body == null:
			players.append({"missing": true})
			continue
		var velocity := Vector2.ZERO
		var velocity_value: Variant = body.get("velocity")
		if velocity_value is Vector2:
			velocity = velocity_value
		players.append({
			"missing": false,
			"x": body.global_position.x,
			"y": body.global_position.y,
			"vx": velocity.x,
			"vy": velocity.y,
			"hp": int(body.get("current_hp")),
			"stun": float(body.get("hitstun_time"))
		})
	var p1_stocks := 0
	var p2_stocks := 0
	var stocks_value: Variant = match_node.get("stocks")
	if typeof(stocks_value) == TYPE_DICTIONARY:
		var stocks: Dictionary = stocks_value
		p1_stocks = int(stocks.get("p1", 0))
		p2_stocks = int(stocks.get("p2", 0))
	return {"players": players, "p1_stocks": p1_stocks, "p2_stocks": p2_stocks}


static func _same_simulation(before: Dictionary, after: Dictionary) -> bool:
	if int(before.get("p1_stocks", -1)) != int(after.get("p1_stocks", -2)):
		return false
	if int(before.get("p2_stocks", -1)) != int(after.get("p2_stocks", -2)):
		return false
	var left: Array = before.get("players", [])
	var right: Array = after.get("players", [])
	if left.size() != right.size():
		return false
	for index in left.size():
		var a: Dictionary = left[index]
		var b: Dictionary = right[index]
		if bool(a.get("missing", true)) or bool(b.get("missing", true)):
			return false
		if not is_equal_approx(float(a.get("x", 0.0)), float(b.get("x", 1.0))):
			return false
		if not is_equal_approx(float(a.get("y", 0.0)), float(b.get("y", 1.0))):
			return false
		if not is_equal_approx(float(a.get("vx", 0.0)), float(b.get("vx", 1.0))):
			return false
		if not is_equal_approx(float(a.get("vy", 0.0)), float(b.get("vy", 1.0))):
			return false
		if int(a.get("hp", -1)) != int(b.get("hp", -2)):
			return false
		if not is_equal_approx(float(a.get("stun", 0.0)), float(b.get("stun", 1.0))):
			return false
	return true


static func _count_named(node: Node, node_name: String) -> int:
	var count := 0
	for child in node.get_children():
		if str(child.name) == node_name:
			count += 1
	return count


static func _lock_color(failures: PackedStringArray, label: String, color: Color, energy: float, text: String, pattern: String) -> void:
	var found := _search(text, pattern)
	if found == null:
		failures.append("missing %s color sentence" % label)
		return
	_lock(failures, "%s red" % label, color.r, found.get_string(1))
	_lock(failures, "%s green" % label, color.g, found.get_string(2))
	_lock(failures, "%s blue" % label, color.b, found.get_string(3))
	_lock(failures, "%s energy" % label, energy, found.get_string(4))


static func _lock_triple(failures: PackedStringArray, label: String, text: String, pattern: String, values: Array) -> void:
	var found := _search(text, pattern)
	if found == null:
		failures.append("missing %s sentence" % label)
		return
	for index in values.size():
		_lock(failures, "%s %d" % [label, index], float(values[index]), found.get_string(index + 1))


static func _lock_found(failures: PackedStringArray, label: String, value: float, text: String, pattern: String) -> void:
	var found := _search(text, pattern)
	if found == null:
		failures.append("missing %s sentence" % label)
		return
	_lock(failures, label, value, found.get_string(1))


static func _lock(failures: PackedStringArray, label: String, value: float, token: String) -> void:
	if token == "":
		failures.append("missing %s" % label)
		return
	var formatted := _format_like(value, token)
	if formatted != token:
		failures.append("%s formats as %s, prose has %s" % [label, formatted, token])


static func _format_like(value: float, token: String) -> String:
	var decimals := 0
	var dot := token.find(".")
	if dot >= 0:
		decimals = token.length() - dot - 1
	var text := String.num(value, decimals)
	if decimals <= 0:
		return text
	var point := text.find(".")
	if point < 0:
		text += "."
		point = text.length() - 1
	var fraction := text.length() - point - 1
	while fraction < decimals:
		text += "0"
		fraction += 1
	return text


static func _camera_zoom_far(scene_text: String) -> float:
	var found := _search(scene_text, "camera_zoom_far\\s*=\\s*" + _NUMBER)
	if found == null:
		return 0.0
	return float(found.get_string(1))


static func _search(text: String, pattern: String) -> RegExMatch:
	var regex := RegEx.new()
	if regex.compile(pattern) != OK:
		return null
	return regex.search(text)


static func _require(failures: PackedStringArray, text: String, sentence: String) -> void:
	if text.find(sentence) < 0:
		failures.append("missing sentence: %s" % sentence)


static func _paragraph_starting(text: String, prefix: String) -> String:
	return _section_after(text, prefix, "\n\n")


static func _section_after(text: String, start_marker: String, end_marker: String) -> String:
	var start := text.find(start_marker)
	if start < 0:
		return ""
	var rest := text.substr(start)
	var end := rest.find(end_marker, start_marker.length())
	if end < 0:
		return rest
	return rest.substr(0, end)


static func _assigns(text: String, property_name: String) -> bool:
	var regex := RegEx.new()
	regex.compile("(?:\\.|\\b)" + property_name + "\\s*=")
	return regex.search(text) != null


static func _has_call(text: String, token: String) -> bool:
	var regex := RegEx.new()
	regex.compile("\\b" + token + "\\b")
	return regex.search(text) != null


static func _strip_hash_comments(source: String) -> String:
	var text := ""
	for line in source.split("\n"):
		var cut := line.find("#")
		if cut >= 0:
			line = line.substr(0, cut)
		if text != "":
			text += "\n"
		text += line
	return text


static func _count(text: String, needle: String) -> int:
	var count := 0
	var from := 0
	while true:
		var at := text.find(needle, from)
		if at < 0:
			return count
		count += 1
		from = at + needle.length()
	return count


static func _gd_names(dir_path: String) -> PackedStringArray:
	var names := PackedStringArray()
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return names
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name == "":
			break
		if dir.current_is_dir():
			continue
		if file_name.ends_with(".gd"):
			names.append(file_name)
	return names


static func _collect_gd(dir_path: String, into: Array[String]) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name == "":
			break
		if file_name == "." or file_name == "..":
			continue
		var full := dir_path + "/" + file_name
		if dir.current_is_dir():
			_collect_gd(full, into)
		elif file_name.ends_with(".gd"):
			into.append(full)


static func _read_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	return FileAccess.get_file_as_string(path)


static func _trim_slash(path: String) -> String:
	if path.ends_with("/"):
		return path.substr(0, path.length() - 1)
	return path


static func _join(root: String, relative: String) -> String:
	return root + "/" + relative


static func _packed_text(lines: PackedStringArray) -> String:
	var text := ""
	for line in lines:
		if text != "":
			text += " | "
		text += line
	return text

extends RefCounted

const RENDERER_METHOD := "forward_plus"
const PIXELS_PER_METER := 100.0
const PITCH_DEG := 10.0
const UNTIGHTENED_FOV_Y_DEG := 50.0
const FRAME_TIGHTEN := 1.4
const REFERENCE_ZOOM := 1.42
const REFERENCE_VIEWPORT_H := 720.0
const PLANE_DISTANCE_M := 5.436778

const DOF_NEAR_ENABLED := true
const DOF_FAR_ENABLED := true
const DOF_AMOUNT := 0.18
const DOF_NEAR_M := 3.4
const DOF_FAR_M := 7.4

const GLOW_ENABLED := true
const GLOW_INTENSITY := 0.85
const GLOW_BLOOM := 0.16
const GLOW_HDR_THRESHOLD := 0.80
const GLOW_BLEND := Environment.GLOW_BLEND_MODE_SOFTLIGHT
const TONEMAP := Environment.TONE_MAPPER_LINEAR

const KEY_COLOR := Color(1.0, 0.90, 0.72)
const KEY_ENERGY := 0.8
const KEY_SHADOW_ENABLED := true
const HIT_COLOR := Color(1.0, 0.84, 0.60)
const HIT_ENERGY := 1.2
const HIT_RANGE_M := 3.2

const SKY_COLOR := Color(0.07, 0.10, 0.18)
const AMBIENT_COLOR := Color(0.72, 0.80, 0.95)
const AMBIENT_ENERGY := 0.78
const FILL_COLOR := Color(0.62, 0.74, 0.95)
const FILL_ENERGY := 0.35
const FILL_ROTATION_DEG := Vector3(-20.0, 150.0, 0.0)
const KEY_ROTATION_DEG := Vector3(-42.0, -36.0, 0.0)
const KEY_SHADOW_BLUR := 0.7
const KEY_SHADOW_BIAS := 0.04
const KEY_SHADOW_NORMAL_BIAS := 0.8
const KEY_SHADOW_MAX_DISTANCE_M := 40.0

const FRONT_LIP_M := 2.4
const REAR_DEPTH_M := 5.2
const FLOOR_TOP_Y_M := 0.01
const SKIRT_HEIGHT_M := 0.35
const SKIRT_CENTER_Y_M := -0.18
const FLOOR_ROUGHNESS := 0.92
const SKIRT_ROUGHNESS := 1.0
const FLOOR_SKIRT_COLOR := Color(0.07, 0.08, 0.12)
const FLOOR_ALBEDO := Color(1.0, 1.0, 1.0)
const PLATFORM_DEPTH_M := 1.5
const PLATFORM_COLOR := Color(0.20, 0.23, 0.30)
const PLATFORM_ROUGHNESS := 0.9
const PLATFORM_MIN_THICKNESS_M := 0.08
const BACKDROP_SIZE_M := Vector2(20.0, 11.0)
const BACKDROP_POSITION_M := Vector3(0.0, 3.1, -7.5)
const BACKDROP_ALBEDO := Color(1.0, 1.0, 1.0)

const FOOT_DROP_M := 0.10
const FIGHTER_Z_STEP_M := 0.02
const SPARK_Z_M := 0.12
const HIT_LIFT_M := Vector3(0.0, 0.45, 0.45)
const ALPHA_SCISSOR := 0.5
const CAMERA_NEAR_M := 0.05
const CAMERA_FAR_M := 80.0
const SPARK_ALPHA_FLOOR := 0.02


class CameraPose:
	var valid := false
	var eye := Vector3.ZERO
	var aim := Vector3.ZERO
	var fov_y_deg := 0.0


static func plane_distance_m() -> float:
	var visible_m := (REFERENCE_VIEWPORT_H / REFERENCE_ZOOM) / PIXELS_PER_METER
	return visible_m / (2.0 * tan(deg_to_rad(UNTIGHTENED_FOV_Y_DEG * 0.5)))


static func fov_y_deg(viewport_height_px: float, zoom: float) -> float:
	var height := viewport_height_px
	if height <= 0.0:
		height = REFERENCE_VIEWPORT_H
	var tight_m := (height / zoom) / PIXELS_PER_METER / FRAME_TIGHTEN
	var perp_m := PLANE_DISTANCE_M * cos(deg_to_rad(PITCH_DEG))
	return rad_to_deg(2.0 * atan(tight_m / (2.0 * perp_m)))


static func pose(center_px: Vector2, zoom: float, viewport_height_px: float, anchor_x: float, floor_y: float) -> CameraPose:
	var result := CameraPose.new()
	if zoom <= 0.0:
		return result
	result.valid = true
	var pitch := deg_to_rad(PITCH_DEG)
	result.aim = plane_point(anchor_x, floor_y, center_px)
	# A camera on -Z yaws 180 and swaps left and right.
	result.eye = result.aim + Vector3(0.0, PLANE_DISTANCE_M * sin(pitch), PLANE_DISTANCE_M * cos(pitch))
	result.fov_y_deg = fov_y_deg(viewport_height_px, zoom)
	return result


static func plane_point(anchor_x: float, floor_y: float, px: Vector2) -> Vector3:
	return Vector3(
		(px.x - anchor_x) / PIXELS_PER_METER,
		(floor_y - px.y) / PIXELS_PER_METER,
		0.0
	)


static func surface_y(center_y: float, height_px: float) -> float:
	return center_y - height_px * 0.5


static func fallback_anchor_x(left_x: float, right_x: float) -> float:
	return (left_x + right_x) * 0.5


static func pixel_size() -> float:
	return 1.0 / PIXELS_PER_METER


static func meters_of(px: float) -> float:
	return px / PIXELS_PER_METER


static func floor_depth_m() -> float:
	return FRONT_LIP_M + REAR_DEPTH_M


static func floor_center_z() -> float:
	return (FRONT_LIP_M - REAR_DEPTH_M) * 0.5


static func floor_size_m(width_px: float) -> Vector2:
	return Vector2(width_px / PIXELS_PER_METER, floor_depth_m())


static func floor_top_position(anchor_x: float, floor_y: float, center_x: float) -> Vector3:
	var mid := plane_point(anchor_x, floor_y, Vector2(center_x, floor_y))
	return Vector3(mid.x, FLOOR_TOP_Y_M, floor_center_z())


static func skirt_position(anchor_x: float, floor_y: float, center_x: float) -> Vector3:
	var mid := plane_point(anchor_x, floor_y, Vector2(center_x, floor_y))
	return Vector3(mid.x, SKIRT_CENTER_Y_M, floor_center_z())


static func skirt_size_m(width_px: float) -> Vector3:
	var deck := floor_size_m(width_px)
	return Vector3(deck.x, SKIRT_HEIGHT_M, deck.y)


static func slab_thickness_m(thickness_px: float) -> float:
	return maxf(thickness_px / PIXELS_PER_METER, PLATFORM_MIN_THICKNESS_M)


static func slab_position(anchor_x: float, floor_y: float, surface_px: Vector2, thickness_m: float) -> Vector3:
	var top := plane_point(anchor_x, floor_y, surface_px)
	# The box sits behind the fighter plane. A box centered on that plane
	# covers the legs, because the camera is on +Z.
	return Vector3(top.x, top.y - thickness_m * 0.5, -PLATFORM_DEPTH_M * 0.5)


static func fighter_position(anchor_x: float, floor_y: float, px: Vector2, slot: int) -> Vector3:
	var point := plane_point(anchor_x, floor_y, px)
	point.y -= FOOT_DROP_M
	point.z = FIGHTER_Z_STEP_M * float(slot)
	return point


static func spark_position(anchor_x: float, floor_y: float, px: Vector2) -> Vector3:
	var point := plane_point(anchor_x, floor_y, px)
	point.z = SPARK_Z_M
	return point


static func hit_position(anchor_x: float, floor_y: float, px: Vector2) -> Vector3:
	return plane_point(anchor_x, floor_y, px) + HIT_LIFT_M


static func backdrop_card_rect() -> Rect2:
	return Rect2(
		BACKDROP_POSITION_M.x - BACKDROP_SIZE_M.x * 0.5,
		BACKDROP_POSITION_M.y - BACKDROP_SIZE_M.y * 0.5,
		BACKDROP_SIZE_M.x,
		BACKDROP_SIZE_M.y
	)


static func frustum_rect_at_backdrop(fov_y_deg: float, aspect: float, aim: Vector3) -> Rect2:
	var pitch := deg_to_rad(PITCH_DEG)
	var eye := aim + Vector3(0.0, PLANE_DISTANCE_M * sin(pitch), PLANE_DISTANCE_M * cos(pitch))
	var forward := Vector3(0.0, -sin(pitch), -cos(pitch))
	var camera_up := Vector3(0.0, cos(pitch), -sin(pitch))
	var camera_right := Vector3(1.0, 0.0, 0.0)
	var tan_v := tan(deg_to_rad(fov_y_deg) * 0.5)
	var safe_aspect := aspect
	if safe_aspect <= 0.0:
		safe_aspect = 1.0
	var tan_h := tan_v * safe_aspect
	var plane_z := BACKDROP_POSITION_M.z
	var min_x := INF
	var max_x := -INF
	var min_y := INF
	var max_y := -INF
	for sx in [-1.0, 1.0]:
		for sy in [-1.0, 1.0]:
			var direction := forward + camera_right * (float(sx) * tan_h) + camera_up * (float(sy) * tan_v)
			var t := (plane_z - eye.z) / direction.z
			var hit := eye + direction * t
			min_x = minf(min_x, hit.x)
			max_x = maxf(max_x, hit.x)
			min_y = minf(min_y, hit.y)
			max_y = maxf(max_y, hit.y)
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)


static func backdrop_cover_rect(fov_y_deg: float, aspect: float, aim: Vector3) -> Rect2:
	var frustum := frustum_rect_at_backdrop(fov_y_deg, aspect, aim)
	if frustum.size.x < 0.0:
		return frustum
	return backdrop_card_rect()


static func backdrop_uv_params(cover: Rect2) -> Dictionary:
	var card := backdrop_card_rect()
	return {
		"scale": Vector2(cover.size.x / card.size.x, cover.size.y / card.size.y),
		"offset": Vector2(
			(cover.position.x - card.position.x) / card.size.x,
			((card.position.y + card.size.y) - (cover.position.y + cover.size.y)) / card.size.y
		),
	}


static func backdrop_sample_uv(cover: Rect2, world_x: float, world_y: float) -> Vector2:
	var params := backdrop_uv_params(cover)
	var scale: Vector2 = params["scale"]
	var offset: Vector2 = params["offset"]
	var mesh_u := (world_x - cover.position.x) / cover.size.x
	var mesh_v := ((cover.position.y + cover.size.y) - world_y) / cover.size.y
	return Vector2(mesh_u * scale.x + offset.x, mesh_v * scale.y + offset.y)


static func hit_slot(stun_times: PackedFloat32Array) -> int:
	var best_index := -1
	var best := 0.0
	for index in stun_times.size():
		var stun := stun_times[index]
		if stun > best:
			best = stun
			best_index = index
	return best_index

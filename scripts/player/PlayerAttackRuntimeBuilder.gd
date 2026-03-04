extends RefCounted
class_name PlayerAttackRuntimeBuilder

const PlayerSignatureAttackBuilderStore := preload("res://scripts/player/PlayerSignatureAttackBuilder.gd")

const DIRECTIONAL_VARIANT_OVERRIDES := {
	"light_up": {
		"startup": 0.07,
		"active": 0.10,
		"recovery": 0.18,
		"damage": 7,
		"block_type": "overhead",
		"knockback_ground": Vector2(92, -150),
		"knockback_air": Vector2(78, -172),
		"hitbox_size_ground": Vector2(24, 24),
		"hitbox_size_air": Vector2(22, 22),
		"hitbox_offset_ground": Vector2(18, -14),
		"hitbox_offset_air": Vector2(16, -16)
	},
	"light_down": {
		"startup": 0.05,
		"active": 0.09,
		"recovery": 0.17,
		"damage": 5,
		"block_type": "low",
		"knockback_ground": Vector2(142, -24),
		"knockback_air": Vector2(108, -58),
		"hitbox_size_ground": Vector2(28, 14),
		"hitbox_size_air": Vector2(24, 12),
		"hitbox_offset_ground": Vector2(24, 10),
		"hitbox_offset_air": Vector2(20, 8)
	},
	"light_air": {
		"startup": 0.07,
		"active": 0.11,
		"recovery": 0.21,
		"damage": 6,
		"block_type": "mid",
		"knockback_ground": Vector2(120, -74),
		"knockback_air": Vector2(132, -96),
		"hitbox_size_ground": Vector2(26, 16),
		"hitbox_size_air": Vector2(28, 18),
		"hitbox_offset_ground": Vector2(24, -6),
		"hitbox_offset_air": Vector2(24, -10)
	},
	"heavy_up": {
		"startup": 0.18,
		"active": 0.12,
		"recovery": 0.28,
		"damage": 15,
		"block_type": "overhead",
		"knockback_ground": Vector2(146, -212),
		"knockback_air": Vector2(128, -236),
		"hitbox_size_ground": Vector2(30, 26),
		"hitbox_size_air": Vector2(28, 24),
		"hitbox_offset_ground": Vector2(22, -18),
		"hitbox_offset_air": Vector2(20, -20)
	},
	"heavy_down": {
		"startup": 0.14,
		"active": 0.11,
		"recovery": 0.30,
		"damage": 12,
		"block_type": "low",
		"knockback_ground": Vector2(224, -32),
		"knockback_air": Vector2(178, -192),
		"hitbox_size_ground": Vector2(34, 18),
		"hitbox_size_air": Vector2(32, 20),
		"hitbox_offset_ground": Vector2(28, 8),
		"hitbox_offset_air": Vector2(26, 6)
	},
	"heavy_air": {
		"startup": 0.15,
		"active": 0.12,
		"recovery": 0.28,
		"damage": 13,
		"block_type": "overhead",
		"knockback_ground": Vector2(198, -88),
		"knockback_air": Vector2(184, -116),
		"hitbox_size_ground": Vector2(32, 18),
		"hitbox_size_air": Vector2(34, 20),
		"hitbox_offset_ground": Vector2(28, -4),
		"hitbox_offset_air": Vector2(30, -8)
	}
}

static func build_runtime_attack_data(
	base_attack_data: Dictionary,
	external_attack_data: Dictionary,
	character_id: String,
	signature_attack_keys: Array,
	required_base_attack_keys: Array,
	hitstun_seconds: float,
	blockstun_seconds: float,
	warning_target: Object = null
) -> Dictionary:
	var runtime_attack_data := base_attack_data.duplicate(true)
	for key in external_attack_data.keys():
		var attack_key := str(key)
		var entry: Variant = external_attack_data[key]
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		runtime_attack_data[attack_key] = (entry as Dictionary).duplicate(true)
	runtime_attack_data = PlayerSignatureAttackBuilderStore.inject_generated_signature_attacks(
		runtime_attack_data,
		character_id,
		base_attack_data,
		signature_attack_keys,
		hitstun_seconds,
		blockstun_seconds
	)
	runtime_attack_data = inject_directional_basic_attack_variants(runtime_attack_data)
	return sanitize_runtime_attack_data(
		runtime_attack_data,
		base_attack_data,
		signature_attack_keys,
		required_base_attack_keys,
		warning_target
	)

static func inject_directional_basic_attack_variants(runtime_attack_data: Dictionary) -> Dictionary:
	var updated := runtime_attack_data.duplicate(true)
	if updated.has("light"):
		var light_base := (updated["light"] as Dictionary).duplicate(true)
		updated["light_up"] = build_directional_variant_attack(light_base, DIRECTIONAL_VARIANT_OVERRIDES["light_up"])
		updated["light_down"] = build_directional_variant_attack(light_base, DIRECTIONAL_VARIANT_OVERRIDES["light_down"])
		updated["light_air"] = build_directional_variant_attack(light_base, DIRECTIONAL_VARIANT_OVERRIDES["light_air"])
	if updated.has("heavy"):
		var heavy_base := (updated["heavy"] as Dictionary).duplicate(true)
		updated["heavy_up"] = build_directional_variant_attack(heavy_base, DIRECTIONAL_VARIANT_OVERRIDES["heavy_up"])
		updated["heavy_down"] = build_directional_variant_attack(heavy_base, DIRECTIONAL_VARIANT_OVERRIDES["heavy_down"])
		updated["heavy_air"] = build_directional_variant_attack(heavy_base, DIRECTIONAL_VARIANT_OVERRIDES["heavy_air"])
	return updated

static func build_directional_variant_attack(base_data: Dictionary, overrides: Dictionary) -> Dictionary:
	var variant := base_data.duplicate(true)
	for key in overrides.keys():
		variant[key] = overrides[key]
	return variant

static func load_external_attack_table(
	use_external_attack_table: bool,
	attack_table_resource: Resource,
	attack_table_path: String,
	default_attack_table_path: String,
	warning_target: Object = null
) -> Dictionary:
	if not use_external_attack_table:
		return {}
	if attack_table_resource:
		var resource_dict := extract_attack_table_dictionary(attack_table_resource)
		if not resource_dict.is_empty():
			return resource_dict
	var path := attack_table_path.strip_edges()
	if path == "":
		path = default_attack_table_path
	if not ResourceLoader.exists(path):
		return {}
	var loaded := load(path)
	var loaded_dict := extract_attack_table_dictionary(loaded)
	if loaded_dict.is_empty():
		_warn(warning_target, "Attack table resource missing attacks dictionary: %s" % path)
	return loaded_dict

static func extract_attack_table_dictionary(resource: Resource) -> Dictionary:
	if resource == null:
		return {}
	if resource.has_method("get_runtime_attacks"):
		var method_value: Variant = resource.call("get_runtime_attacks")
		if typeof(method_value) == TYPE_DICTIONARY:
			return (method_value as Dictionary).duplicate(true)
	var value: Variant = resource.get("attacks")
	if typeof(value) == TYPE_DICTIONARY:
		return (value as Dictionary).duplicate(true)
	return {}

static func sanitize_runtime_attack_data(
	runtime_attack_data: Dictionary,
	base_attack_data: Dictionary,
	signature_attack_keys: Array,
	required_base_attack_keys: Array,
	warning_target: Object = null
) -> Dictionary:
	var sanitized := {}
	for key in runtime_attack_data.keys():
		var attack_key := str(key)
		var raw_entry: Variant = runtime_attack_data[key]
		var entry: Dictionary = {}
		if typeof(raw_entry) == TYPE_DICTIONARY:
			entry = (raw_entry as Dictionary).duplicate(true)
		else:
			_warn(warning_target, "Attack entry is not a dictionary, using defaults: %s" % attack_key)
		var defaults := default_attack_entry_for_kind(attack_key, base_attack_data, signature_attack_keys)
		merge_attack_defaults(entry, defaults)
		sanitize_attack_field_types(entry, defaults, attack_key, warning_target)
		sanitized[attack_key] = entry

	for required_key_variant in required_base_attack_keys:
		var required_key := str(required_key_variant)
		if sanitized.has(required_key):
			continue
		_warn(warning_target, "Missing required base attack, injecting fallback: %s" % required_key)
		sanitized[required_key] = default_attack_entry_for_kind(required_key, base_attack_data, signature_attack_keys)

	return sanitized

static func default_attack_entry_for_kind(
	kind: String,
	base_attack_data: Dictionary,
	signature_attack_keys: Array
) -> Dictionary:
	var source_kind := kind
	if source_kind.begins_with("light_"):
		source_kind = "light"
	elif source_kind.begins_with("heavy_"):
		source_kind = "heavy"
	if not base_attack_data.has(source_kind):
		source_kind = "special" if kind in signature_attack_keys else "light"
	var source_value: Variant = base_attack_data.get(source_kind, base_attack_data["light"])
	if typeof(source_value) != TYPE_DICTIONARY:
		source_value = base_attack_data["light"]
	return (source_value as Dictionary).duplicate(true)

static func merge_attack_defaults(target: Dictionary, defaults: Dictionary) -> void:
	for key in defaults.keys():
		if not target.has(key):
			target[key] = defaults[key]

static func sanitize_attack_field_types(
	entry: Dictionary,
	defaults: Dictionary,
	attack_key: String,
	warning_target: Object = null
) -> void:
	var vector_keys := [
		"knockback_ground",
		"knockback_air",
		"hitbox_size_ground",
		"hitbox_size_air",
		"hitbox_offset_ground",
		"hitbox_offset_air"
	]
	for key in vector_keys:
		var value: Variant = entry.get(key, defaults.get(key, Vector2.ZERO))
		if value is Vector2:
			continue
		_warn(warning_target, "Attack '%s' field '%s' must be Vector2; using default" % [attack_key, key])
		entry[key] = defaults.get(key, Vector2.ZERO)

static func _warn(warning_target: Object, message: String) -> void:
	if warning_target != null and warning_target.has_method("push_warning"):
		warning_target.push_warning(message)

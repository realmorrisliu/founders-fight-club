extends RefCounted
class_name PlayerSignatureAttackBuilder

const GeneratedSkillProfilesStore := preload("res://scripts/player/GeneratedSkillProfiles.gd")

const SIGNATURE_SKELETON_DEFAULTS := {
	"pressure_check": {
		"startup": 0.07,
		"active": 0.11,
		"recovery": 0.17,
		"block_recovery": 0.19,
		"damage": 10,
		"hitstun": 0.15,
		"blockstun": 0.12,
		"cancel_on_hit": true,
		"cancel_on_block": true,
		"cancel_options": ["light", "heavy", "special"],
		"block_type": "mid",
		"air_blockable": true,
		"lunge_speed": 210.0,
		"knockback_ground": Vector2(150, -46),
		"knockback_air": Vector2(128, -82),
		"hitbox_size_ground": Vector2(30, 18),
		"hitbox_size_air": Vector2(28, 16),
		"hitbox_offset_ground": Vector2(24, -2),
		"hitbox_offset_air": Vector2(22, -8)
	},
	"projectile_check": {
		"startup": 0.09,
		"active": 0.10,
		"recovery": 0.24,
		"block_recovery": 0.27,
		"damage": 9,
		"hitstun": 0.14,
		"blockstun": 0.11,
		"cancel_on_hit": true,
		"cancel_on_block": false,
		"cancel_options": ["heavy"],
		"block_type": "mid",
		"air_blockable": true,
		"lunge_speed": 70.0,
		"knockback_ground": Vector2(132, -54),
		"knockback_air": Vector2(120, -88),
		"hitbox_size_ground": Vector2(24, 18),
		"hitbox_size_air": Vector2(22, 16),
		"hitbox_offset_ground": Vector2(20, -2),
		"hitbox_offset_air": Vector2(18, -8)
	},
	"summon_check": {
		"startup": 0.10,
		"active": 0.10,
		"recovery": 0.25,
		"block_recovery": 0.29,
		"damage": 10,
		"hitstun": 0.15,
		"blockstun": 0.11,
		"cancel_on_hit": false,
		"cancel_on_block": false,
		"cancel_options": [],
		"block_type": "mid",
		"air_blockable": true,
		"lunge_speed": 120.0,
		"knockback_ground": Vector2(140, -62),
		"knockback_air": Vector2(128, -96),
		"hitbox_size_ground": Vector2(28, 18),
		"hitbox_size_air": Vector2(24, 16),
		"hitbox_offset_ground": Vector2(22, -2),
		"hitbox_offset_air": Vector2(20, -8)
	},
	"control_poke": {
		"startup": 0.08,
		"active": 0.11,
		"recovery": 0.22,
		"block_recovery": 0.26,
		"damage": 8,
		"hitstun": 0.16,
		"blockstun": 0.14,
		"cancel_on_hit": true,
		"cancel_on_block": true,
		"cancel_options": ["light", "special"],
		"block_type": "mid",
		"air_blockable": true,
		"lunge_speed": 120.0,
		"knockback_ground": Vector2(118, -40),
		"knockback_air": Vector2(106, -72),
		"hitbox_size_ground": Vector2(32, 16),
		"hitbox_size_air": Vector2(28, 14),
		"hitbox_offset_ground": Vector2(22, 4),
		"hitbox_offset_air": Vector2(20, 0)
	},
	"dash_burst": {
		"startup": 0.10,
		"active": 0.10,
		"recovery": 0.24,
		"block_recovery": 0.30,
		"damage": 12,
		"hitstun": 0.18,
		"blockstun": 0.12,
		"cancel_on_hit": false,
		"cancel_on_block": false,
		"cancel_options": [],
		"block_type": "mid",
		"air_blockable": true,
		"lunge_speed": 360.0,
		"knockback_ground": Vector2(182, -62),
		"knockback_air": Vector2(158, -104),
		"hitbox_size_ground": Vector2(34, 18),
		"hitbox_size_air": Vector2(30, 16),
		"hitbox_offset_ground": Vector2(26, -2),
		"hitbox_offset_air": Vector2(24, -8)
	},
	"teleport_punish": {
		"startup": 0.08,
		"active": 0.09,
		"recovery": 0.26,
		"block_recovery": 0.30,
		"damage": 12,
		"hitstun": 0.17,
		"blockstun": 0.12,
		"cancel_on_hit": false,
		"cancel_on_block": false,
		"cancel_options": [],
		"block_type": "overhead",
		"air_blockable": true,
		"lunge_speed": 0.0,
		"knockback_ground": Vector2(168, -76),
		"knockback_air": Vector2(150, -112),
		"hitbox_size_ground": Vector2(30, 22),
		"hitbox_size_air": Vector2(28, 20),
		"hitbox_offset_ground": Vector2(18, -12),
		"hitbox_offset_air": Vector2(16, -16)
	},
	"rising_launcher": {
		"startup": 0.12,
		"active": 0.12,
		"recovery": 0.29,
		"block_recovery": 0.34,
		"damage": 11,
		"hitstun": 0.22,
		"blockstun": 0.13,
		"cancel_on_hit": false,
		"cancel_on_block": false,
		"cancel_options": [],
		"block_type": "overhead",
		"air_blockable": true,
		"lunge_speed": 180.0,
		"knockback_ground": Vector2(140, -195),
		"knockback_air": Vector2(130, -220),
		"hitbox_size_ground": Vector2(28, 26),
		"hitbox_size_air": Vector2(26, 24),
		"hitbox_offset_ground": Vector2(20, -18),
		"hitbox_offset_air": Vector2(18, -20)
	},
	"control_snare": {
		"startup": 0.11,
		"active": 0.14,
		"recovery": 0.30,
		"block_recovery": 0.36,
		"damage": 9,
		"hitstun": 0.20,
		"blockstun": 0.16,
		"cancel_on_hit": false,
		"cancel_on_block": false,
		"cancel_options": [],
		"block_type": "low",
		"air_blockable": true,
		"lunge_speed": 60.0,
		"knockback_ground": Vector2(110, -32),
		"knockback_air": Vector2(104, -64),
		"hitbox_size_ground": Vector2(36, 16),
		"hitbox_size_air": Vector2(32, 14),
		"hitbox_offset_ground": Vector2(26, 8),
		"hitbox_offset_air": Vector2(22, 4)
	},
	"trap_seed": {
		"startup": 0.12,
		"active": 0.10,
		"recovery": 0.32,
		"block_recovery": 0.38,
		"damage": 8,
		"hitstun": 0.18,
		"blockstun": 0.15,
		"cancel_on_hit": false,
		"cancel_on_block": false,
		"cancel_options": [],
		"block_type": "mid",
		"air_blockable": true,
		"lunge_speed": 40.0,
		"knockback_ground": Vector2(120, -48),
		"knockback_air": Vector2(112, -76),
		"hitbox_size_ground": Vector2(24, 18),
		"hitbox_size_air": Vector2(22, 16),
		"hitbox_offset_ground": Vector2(20, -2),
		"hitbox_offset_air": Vector2(18, -6)
	},
	"trap_setplay": {
		"startup": 0.13,
		"active": 0.15,
		"recovery": 0.34,
		"block_recovery": 0.40,
		"damage": 9,
		"hitstun": 0.20,
		"blockstun": 0.16,
		"cancel_on_hit": false,
		"cancel_on_block": false,
		"cancel_options": [],
		"block_type": "low",
		"air_blockable": true,
		"lunge_speed": 20.0,
		"knockback_ground": Vector2(126, -42),
		"knockback_air": Vector2(118, -70),
		"hitbox_size_ground": Vector2(34, 18),
		"hitbox_size_air": Vector2(30, 16),
		"hitbox_offset_ground": Vector2(24, 6),
		"hitbox_offset_air": Vector2(22, 2)
	},
	"summon_screen": {
		"startup": 0.11,
		"active": 0.14,
		"recovery": 0.31,
		"block_recovery": 0.37,
		"damage": 10,
		"hitstun": 0.19,
		"blockstun": 0.14,
		"cancel_on_hit": false,
		"cancel_on_block": false,
		"cancel_options": [],
		"block_type": "mid",
		"air_blockable": true,
		"lunge_speed": 30.0,
		"knockback_ground": Vector2(138, -54),
		"knockback_air": Vector2(126, -82),
		"hitbox_size_ground": Vector2(32, 20),
		"hitbox_size_air": Vector2(30, 18),
		"hitbox_offset_ground": Vector2(24, -2),
		"hitbox_offset_air": Vector2(22, -8)
	},
	"projectile_screen": {
		"startup": 0.10,
		"active": 0.14,
		"recovery": 0.30,
		"block_recovery": 0.36,
		"damage": 10,
		"hitstun": 0.18,
		"blockstun": 0.15,
		"cancel_on_hit": false,
		"cancel_on_block": false,
		"cancel_options": [],
		"block_type": "mid",
		"air_blockable": true,
		"lunge_speed": 40.0,
		"knockback_ground": Vector2(144, -56),
		"knockback_air": Vector2(132, -84),
		"hitbox_size_ground": Vector2(30, 20),
		"hitbox_size_air": Vector2(28, 18),
		"hitbox_offset_ground": Vector2(24, -4),
		"hitbox_offset_air": Vector2(22, -10)
	},
	"install_pulse": {
		"startup": 0.09,
		"active": 0.10,
		"recovery": 0.20,
		"block_recovery": 0.25,
		"damage": 7,
		"hitstun": 0.12,
		"blockstun": 0.10,
		"cancel_on_hit": false,
		"cancel_on_block": false,
		"cancel_options": [],
		"block_type": "mid",
		"air_blockable": true,
		"lunge_speed": 0.0,
		"knockback_ground": Vector2(92, -28),
		"knockback_air": Vector2(84, -56),
		"hitbox_size_ground": Vector2(28, 18),
		"hitbox_size_air": Vector2(24, 16),
		"hitbox_offset_ground": Vector2(22, -2),
		"hitbox_offset_air": Vector2(18, -8)
	},
	"super_burst": {
		"startup": 0.13,
		"active": 0.16,
		"recovery": 0.34,
		"block_recovery": 0.40,
		"damage": 17,
		"hitstun": 0.24,
		"blockstun": 0.18,
		"cancel_on_hit": false,
		"cancel_on_block": false,
		"cancel_options": [],
		"block_type": "overhead",
		"air_blockable": true,
		"lunge_speed": 240.0,
		"knockback_ground": Vector2(240, -118),
		"knockback_air": Vector2(210, -170),
		"hitbox_size_ground": Vector2(38, 22),
		"hitbox_size_air": Vector2(34, 20),
		"hitbox_offset_ground": Vector2(30, -4),
		"hitbox_offset_air": Vector2(28, -10)
	},
	"screen_control_super": {
		"startup": 0.15,
		"active": 0.18,
		"recovery": 0.38,
		"block_recovery": 0.44,
		"damage": 16,
		"hitstun": 0.24,
		"blockstun": 0.19,
		"cancel_on_hit": false,
		"cancel_on_block": false,
		"cancel_options": [],
		"block_type": "mid",
		"air_blockable": true,
		"lunge_speed": 80.0,
		"knockback_ground": Vector2(220, -96),
		"knockback_air": Vector2(198, -150),
		"hitbox_size_ground": Vector2(40, 24),
		"hitbox_size_air": Vector2(36, 22),
		"hitbox_offset_ground": Vector2(30, -4),
		"hitbox_offset_air": Vector2(28, -10)
	},
	"install_overclock": {
		"startup": 0.11,
		"active": 0.12,
		"recovery": 0.24,
		"block_recovery": 0.30,
		"damage": 9,
		"hitstun": 0.14,
		"blockstun": 0.11,
		"cancel_on_hit": false,
		"cancel_on_block": false,
		"cancel_options": [],
		"block_type": "mid",
		"air_blockable": true,
		"lunge_speed": 0.0,
		"knockback_ground": Vector2(110, -36),
		"knockback_air": Vector2(100, -62),
		"hitbox_size_ground": Vector2(30, 18),
		"hitbox_size_air": Vector2(26, 16),
		"hitbox_offset_ground": Vector2(22, -4),
		"hitbox_offset_air": Vector2(20, -8)
	}
}

static func inject_generated_signature_attacks(
	runtime_attack_data: Dictionary,
	character_id: String,
	base_attack_data: Dictionary,
	signature_attack_keys: Array,
	hitstun_seconds: float,
	blockstun_seconds: float
) -> Dictionary:
	var updated := runtime_attack_data.duplicate(true)
	var profile := GeneratedSkillProfilesStore.get_profile(character_id)
	if profile.is_empty():
		return updated

	for key_variant in signature_attack_keys:
		var key := str(key_variant)
		if updated.has(key):
			continue
		var config_value: Variant = profile.get(key, {})
		if typeof(config_value) != TYPE_DICTIONARY:
			continue
		updated[key] = build_generated_signature_attack(
			key,
			config_value as Dictionary,
			hitstun_seconds,
			blockstun_seconds
		)
	return updated

static func build_generated_signature_attack(
	kind: String,
	config: Dictionary,
	hitstun_seconds: float,
	blockstun_seconds: float
) -> Dictionary:
	var skeleton_id := _resolve_signature_skeleton_id(kind, config)
	var skeleton := _resolve_signature_skeleton_defaults(skeleton_id)
	if skeleton.is_empty():
		return {}
	var entry := skeleton.duplicate(true)
	var damage_scale := float(config.get("damage_scale", 1.0))
	var base_damage := int(entry.get("damage", 10))
	entry["damage"] = maxi(5, int(round(float(base_damage) * damage_scale)))
	entry["hitstun"] = float(config.get("hitstun", float(entry.get("hitstun", hitstun_seconds))))
	entry["blockstun"] = float(config.get("blockstun", float(entry.get("blockstun", blockstun_seconds))))
	entry["cooldown"] = float(config.get("cooldown", 8.0 if kind == "ultimate" else 1.5))
	entry["generated_role"] = str(config.get("role", "")).strip_edges().to_lower()
	entry["generated_skeleton"] = skeleton_id
	entry["generated_archetype"] = str(config.get("generated_archetype", "")).strip_edges().to_lower()
	_apply_explicit_config_overrides(entry, config)
	if config.has("effect"):
		var effect_value: Variant = config.get("effect", {})
		if typeof(effect_value) == TYPE_DICTIONARY:
			entry["effect"] = (effect_value as Dictionary).duplicate(true)
	if config.has("control"):
		var control_value: Variant = config.get("control", {})
		if typeof(control_value) == TYPE_DICTIONARY:
			entry["control"] = (control_value as Dictionary).duplicate(true)
	return entry

static func build_generated_signature_attack_from_special(
	kind: String,
	special_base: Dictionary,
	config: Dictionary,
	hitstun_seconds: float,
	blockstun_seconds: float
) -> Dictionary:
	return build_generated_signature_attack(kind, config, hitstun_seconds, blockstun_seconds)

static func _build_generated_signature_attack_from_special(
	kind: String,
	special_base: Dictionary,
	config: Dictionary,
	hitstun_seconds: float,
	blockstun_seconds: float
) -> Dictionary:
	return build_generated_signature_attack_from_special(
		kind,
		special_base,
		config,
		hitstun_seconds,
		blockstun_seconds
	)

static func _resolve_signature_skeleton_id(kind: String, config: Dictionary) -> String:
	var explicit_skeleton := str(config.get("skeleton", "")).strip_edges().to_lower()
	if explicit_skeleton != "":
		return explicit_skeleton
	var role := str(config.get("role", "")).strip_edges().to_lower()
	match role:
		"approach":
			return "teleport_punish" if kind == "signature_b" else "dash_burst"
		"anti_air":
			return "rising_launcher"
		"control":
			return "control_snare" if kind == "signature_c" else "control_poke"
		"setplay":
			return "trap_setplay" if kind == "signature_c" else "trap_seed"
		"install":
			return "install_overclock" if kind == "ultimate" else "install_pulse"
		"super":
			return "screen_control_super" if kind == "ultimate" else "super_burst"
	return "super_burst" if kind == "ultimate" else "pressure_check"

static func _resolve_signature_skeleton_defaults(skeleton_id: String) -> Dictionary:
	var value: Variant = SIGNATURE_SKELETON_DEFAULTS.get(skeleton_id, SIGNATURE_SKELETON_DEFAULTS["pressure_check"])
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	return (value as Dictionary).duplicate(true)

static func _apply_explicit_config_overrides(entry: Dictionary, config: Dictionary) -> void:
	for key in ["startup", "active", "recovery", "block_recovery", "hitstun", "blockstun", "lunge_speed", "chip_bonus", "cooldown"]:
		if config.has(key):
			entry[key] = float(config.get(key, entry.get(key, 0.0)))
	if config.has("damage"):
		entry["damage"] = maxi(1, int(config.get("damage", entry.get("damage", 1))))
	for key in ["cancel_on_hit", "cancel_on_block", "air_blockable"]:
		if config.has(key):
			entry[key] = bool(config.get(key, entry.get(key, false)))
	if config.has("cancel_options"):
		var cancel_value: Variant = config.get("cancel_options", [])
		if typeof(cancel_value) == TYPE_ARRAY:
			entry["cancel_options"] = (cancel_value as Array).duplicate()
	if config.has("block_type"):
		entry["block_type"] = str(config.get("block_type", entry.get("block_type", "mid")))
	for key in [
		"knockback_ground",
		"knockback_air",
		"hitbox_size_ground",
		"hitbox_size_air",
		"hitbox_offset_ground",
		"hitbox_offset_air"
	]:
		if config.has(key):
			var value: Variant = config.get(key, entry.get(key, Vector2.ZERO))
			if value is Vector2:
				entry[key] = value

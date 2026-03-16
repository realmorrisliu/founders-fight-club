extends RefCounted
class_name PlayerSignatureAttackBuilder

const GeneratedSkillProfilesStore := preload("res://scripts/player/GeneratedSkillProfiles.gd")

const SIGNATURE_TEMPLATE_DEFAULTS := {
	"pressure": {
		"startup": 0.08,
		"active": 0.12,
		"recovery": 0.20,
		"block_recovery": 0.24,
		"lunge_speed": 250.0,
		"hitstun_bonus": 0.00,
		"blockstun_bonus": 0.00,
		"knockback_x_scale": 0.92,
		"knockback_y_scale": 0.94
	},
	"setplay": {
		"startup": 0.12,
		"active": 0.14,
		"recovery": 0.32,
		"block_recovery": 0.36,
		"lunge_speed": 60.0,
		"hitstun_bonus": 0.02,
		"blockstun_bonus": 0.02,
		"knockback_x_scale": 0.84,
		"knockback_y_scale": 0.88
	},
	"approach": {
		"startup": 0.09,
		"active": 0.12,
		"recovery": 0.25,
		"block_recovery": 0.30,
		"lunge_speed": 360.0,
		"hitstun_bonus": 0.01,
		"blockstun_bonus": 0.00,
		"knockback_x_scale": 1.02,
		"knockback_y_scale": 0.94
	},
	"launcher": {
		"startup": 0.12,
		"active": 0.12,
		"recovery": 0.30,
		"block_recovery": 0.35,
		"lunge_speed": 180.0,
		"hitstun_bonus": 0.03,
		"blockstun_bonus": 0.01,
		"knockback_x_scale": 0.88,
		"knockback_y_scale": 1.18,
		"block_type": "overhead"
	},
	"install": {
		"startup": 0.10,
		"active": 0.10,
		"recovery": 0.22,
		"block_recovery": 0.28,
		"lunge_speed": 0.0,
		"hitstun_bonus": -0.02,
		"blockstun_bonus": -0.01,
		"knockback_x_scale": 0.78,
		"knockback_y_scale": 0.82
	},
	"super": {
		"startup": 0.13,
		"active": 0.16,
		"recovery": 0.34,
		"block_recovery": 0.40,
		"lunge_speed": 240.0,
		"hitstun_bonus": 0.04,
		"blockstun_bonus": 0.02,
		"knockback_x_scale": 1.10,
		"knockback_y_scale": 1.06
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

	var special_base := {}
	var special_from_runtime: Variant = updated.get("special", {})
	if typeof(special_from_runtime) == TYPE_DICTIONARY:
		special_base = (special_from_runtime as Dictionary).duplicate(true)
	if special_base.is_empty():
		var fallback_special: Variant = base_attack_data.get("special", {})
		if typeof(fallback_special) == TYPE_DICTIONARY:
			special_base = (fallback_special as Dictionary).duplicate(true)
	if special_base.is_empty():
		return updated

	for key_variant in signature_attack_keys:
		var key := str(key_variant)
		if updated.has(key):
			continue
		var config_value: Variant = profile.get(key, {})
		if typeof(config_value) != TYPE_DICTIONARY:
			continue
		updated[key] = build_generated_signature_attack_from_special(
			key,
			special_base,
			config_value as Dictionary,
			hitstun_seconds,
			blockstun_seconds
		)
	return updated

static func build_generated_signature_attack_from_special(
	kind: String,
	special_base: Dictionary,
	config: Dictionary,
	hitstun_seconds: float,
	blockstun_seconds: float
) -> Dictionary:
	var entry := special_base.duplicate(true)
	var default_startup := float(special_base.get("startup", 0.10))
	var default_active := float(special_base.get("active", 0.15))
	var default_recovery := float(special_base.get("recovery", 0.28))
	var template_id := _resolve_signature_template_id(kind, config)
	var template := _resolve_signature_template_defaults(template_id)
	var damage_scale := float(config.get("damage_scale", 0.65))
	var base_damage := int(special_base.get("damage", 14))
	entry["startup"] = float(config.get("startup", float(template.get("startup", default_startup + (0.01 if kind != "signature_a" else -0.01)))))
	entry["active"] = float(config.get("active", float(template.get("active", default_active))))
	entry["recovery"] = float(config.get("recovery", float(template.get("recovery", default_recovery + (0.03 if kind == "ultimate" else 0.0)))))
	entry["block_recovery"] = float(config.get("block_recovery", float(template.get("block_recovery", float(entry.get("recovery", default_recovery)) + 0.08))))
	entry["damage"] = maxi(5, int(round(float(base_damage) * damage_scale)))
	entry["hitstun"] = float(config.get(
		"hitstun",
		float(special_base.get("hitstun", hitstun_seconds))
		+ float(template.get("hitstun_bonus", 0.0))
		+ (0.02 if kind == "ultimate" else 0.0)
	))
	entry["blockstun"] = float(config.get(
		"blockstun",
		float(special_base.get("blockstun", blockstun_seconds))
		+ float(template.get("blockstun_bonus", 0.0))
		+ (0.02 if kind == "ultimate" else 0.0)
	))
	entry["cancel_on_hit"] = false
	entry["cancel_on_block"] = false
	entry["cancel_options"] = []
	entry["cooldown"] = float(config.get("cooldown", 1.5 if kind != "ultimate" else 8.0))
	if config.has("block_type"):
		entry["block_type"] = str(config.get("block_type", "mid"))
	elif template.has("block_type"):
		entry["block_type"] = str(template.get("block_type", "mid"))
	entry["lunge_speed"] = float(config.get("lunge_speed", float(template.get("lunge_speed", special_base.get("lunge_speed", 0.0)))))
	_apply_knockback_profile(entry, template)
	if config.has("effect"):
		var effect_value: Variant = config.get("effect", {})
		if typeof(effect_value) == TYPE_DICTIONARY:
			entry["effect"] = (effect_value as Dictionary).duplicate(true)
	if config.has("control"):
		var control_value: Variant = config.get("control", {})
		if typeof(control_value) == TYPE_DICTIONARY:
			entry["control"] = (control_value as Dictionary).duplicate(true)
	return entry

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

static func _resolve_signature_template_id(kind: String, config: Dictionary) -> String:
	var explicit_template := str(config.get("template", "")).strip_edges().to_lower()
	if explicit_template != "":
		return explicit_template
	if kind == "ultimate":
		return "super"
	var effect_value: Variant = config.get("effect", {})
	if typeof(effect_value) == TYPE_DICTIONARY:
		var effect := effect_value as Dictionary
		var effect_type := str(effect.get("type", "")).strip_edges().to_lower()
		match effect_type:
			"buff":
				return "install"
			"mobility":
				var mode := str(effect.get("mode", "")).strip_edges().to_lower()
				if mode == "rising":
					return "launcher"
				return "approach"
			"projectile", "trap", "summon":
				return "setplay"
	var control_value: Variant = config.get("control", {})
	if typeof(control_value) == TYPE_DICTIONARY:
		return "pressure"
	return "pressure"

static func _resolve_signature_template_defaults(template_id: String) -> Dictionary:
	var value: Variant = SIGNATURE_TEMPLATE_DEFAULTS.get(template_id, SIGNATURE_TEMPLATE_DEFAULTS["pressure"])
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	return (value as Dictionary).duplicate(true)

static func _apply_knockback_profile(entry: Dictionary, template: Dictionary) -> void:
	var horizontal_scale := float(template.get("knockback_x_scale", 1.0))
	var vertical_scale := float(template.get("knockback_y_scale", 1.0))
	for key in ["knockback_ground", "knockback_air"]:
		var value: Variant = entry.get(key, Vector2.ZERO)
		if value is not Vector2:
			continue
		var knockback := value as Vector2
		entry[key] = Vector2(knockback.x * horizontal_scale, knockback.y * vertical_scale)

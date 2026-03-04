extends RefCounted
class_name PlayerSignatureAttackBuilder

const GeneratedSkillProfilesStore := preload("res://scripts/player/GeneratedSkillProfiles.gd")

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
	var damage_scale := float(config.get("damage_scale", 0.65))
	var base_damage := int(special_base.get("damage", 14))
	entry["startup"] = float(config.get("startup", default_startup + (0.01 if kind != "signature_a" else -0.01)))
	entry["active"] = float(config.get("active", default_active))
	entry["recovery"] = float(config.get("recovery", default_recovery + (0.03 if kind == "ultimate" else 0.0)))
	entry["block_recovery"] = float(config.get("block_recovery", float(entry.get("recovery", default_recovery)) + 0.08))
	entry["damage"] = maxi(5, int(round(float(base_damage) * damage_scale)))
	entry["hitstun"] = float(config.get("hitstun", float(special_base.get("hitstun", hitstun_seconds)) + (0.02 if kind == "ultimate" else 0.0)))
	entry["blockstun"] = float(config.get("blockstun", float(special_base.get("blockstun", blockstun_seconds)) + (0.02 if kind == "ultimate" else 0.0)))
	entry["cancel_on_hit"] = false
	entry["cancel_on_block"] = false
	entry["cancel_options"] = []
	entry["cooldown"] = float(config.get("cooldown", 1.5 if kind != "ultimate" else 8.0))
	if config.has("block_type"):
		entry["block_type"] = str(config.get("block_type", "mid"))
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

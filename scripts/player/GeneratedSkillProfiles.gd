extends RefCounted
class_name GeneratedSkillProfiles

const PlayerDataStore := preload("res://scripts/player/PlayerData.gd")

const PROFILE_BY_CHARACTER := {
	"prototype_p1": {
		"signature_a": {"damage_scale": 0.62, "cooldown": 1.4, "effect": {"type": "projectile", "speed": 300.0, "duration": 1.05, "size": Vector2(26, 16)}},
		"signature_b": {"damage_scale": 0.70, "cooldown": 1.9, "effect": {"type": "mobility", "mode": "dash", "speed": 320.0}},
		"signature_c": {"damage_scale": 0.64, "cooldown": 2.1, "effect": {"type": "trap", "duration": 1.25, "size": Vector2(32, 18), "spawn_delay": 0.08}},
		"ultimate": {"damage_scale": 0.98, "cooldown": 8.0, "effect": {"type": "buff", "buff": {"duration": 4.2, "damage_multiplier": 1.16, "speed_multiplier": 1.08, "startup_multiplier": 0.86}}}
	},
	"prototype_p2": {
		"signature_a": {"damage_scale": 0.58, "cooldown": 1.5, "control": {"slow_seconds": 0.65, "slow_factor": 0.68}},
		"signature_b": {"damage_scale": 0.68, "cooldown": 1.9, "effect": {"type": "mobility", "mode": "teleport", "distance": 110.0}},
		"signature_c": {"damage_scale": 0.62, "cooldown": 2.2, "effect": {"type": "summon", "speed": 250.0, "duration": 1.15, "size": Vector2(30, 18), "spawn_delay": 0.1}},
		"ultimate": {"damage_scale": 0.92, "cooldown": 8.2, "effect": {"type": "projectile", "speed": 410.0, "duration": 1.1, "size": Vector2(36, 20)}}
	},
	"prototype": {
		"signature_a": {"damage_scale": 0.58, "cooldown": 1.5, "control": {"slow_seconds": 0.65, "slow_factor": 0.68}},
		"signature_b": {"damage_scale": 0.68, "cooldown": 1.9, "effect": {"type": "mobility", "mode": "teleport", "distance": 110.0}},
		"signature_c": {"damage_scale": 0.62, "cooldown": 2.2, "effect": {"type": "summon", "speed": 250.0, "duration": 1.15, "size": Vector2(30, 18), "spawn_delay": 0.1}},
		"ultimate": {"damage_scale": 0.92, "cooldown": 8.2, "effect": {"type": "projectile", "speed": 410.0, "duration": 1.1, "size": Vector2(36, 20)}}
	},
	"elon_mvsk": {
		"signature_a": {"damage_scale": 0.60, "cooldown": 1.3, "effect": {"type": "projectile", "speed": 360.0, "duration": 1.0, "size": Vector2(24, 16)}},
		"signature_b": {"damage_scale": 0.62, "cooldown": 1.9, "control": {"slow_seconds": 0.55, "slow_factor": 0.72}},
		"signature_c": {"damage_scale": 0.72, "cooldown": 2.2, "effect": {"type": "mobility", "mode": "dash", "speed": 340.0}},
		"ultimate": {"damage_scale": 0.96, "cooldown": 7.8, "effect": {"type": "buff", "buff": {"duration": 4.4, "damage_multiplier": 1.18, "speed_multiplier": 1.06, "startup_multiplier": 0.86, "chip_bonus": 0.08}}}
	},
	"mark_zuck": {
		"signature_a": {"damage_scale": 0.58, "cooldown": 1.5, "effect": {"type": "summon", "speed": 255.0, "duration": 1.2, "size": Vector2(30, 18), "spawn_delay": 0.04}},
		"signature_b": {"damage_scale": 0.64, "cooldown": 1.8, "effect": {"type": "mobility", "mode": "teleport", "distance": 124.0}},
		"signature_c": {"damage_scale": 0.68, "cooldown": 2.0, "block_type": "low", "control": {"root_seconds": 0.12, "slow_seconds": 0.45, "slow_factor": 0.76}},
		"ultimate": {"damage_scale": 0.94, "cooldown": 8.0, "effect": {"type": "summon", "speed": 290.0, "duration": 1.25, "size": Vector2(36, 20), "spawn_delay": 0.08}}
	},
	"sam_altmyn": {
		"signature_a": {"damage_scale": 0.62, "cooldown": 1.4, "effect": {"type": "summon", "speed": 245.0, "duration": 1.15, "size": Vector2(30, 18), "spawn_delay": 0.12}},
		"signature_b": {"damage_scale": 0.54, "cooldown": 1.8, "effect": {"type": "buff", "buff": {"duration": 3.4, "damage_multiplier": 1.12, "speed_multiplier": 1.06, "startup_multiplier": 0.88}}},
		"signature_c": {"damage_scale": 0.68, "cooldown": 1.9, "control": {"silence_seconds": 0.65}},
		"ultimate": {"damage_scale": 0.90, "cooldown": 7.6, "effect": {"type": "buff", "buff": {"duration": 4.8, "damage_multiplier": 1.16, "speed_multiplier": 1.08, "startup_multiplier": 0.84, "chip_bonus": 0.08}}}
	},
	"peter_thyell": {
		"signature_a": {"damage_scale": 0.60, "cooldown": 1.5, "effect": {"type": "trap", "duration": 1.4, "size": Vector2(36, 20), "spawn_delay": 0.08}, "control": {"slow_seconds": 0.72, "slow_factor": 0.60}},
		"signature_b": {"damage_scale": 0.70, "cooldown": 2.0, "effect": {"type": "mobility", "mode": "teleport", "distance": 118.0}},
		"signature_c": {"damage_scale": 0.70, "cooldown": 2.0, "block_type": "overhead", "control": {"silence_seconds": 0.55}},
		"ultimate": {"damage_scale": 0.98, "cooldown": 8.1, "effect": {"type": "buff", "buff": {"duration": 4.0, "damage_multiplier": 1.20, "speed_multiplier": 1.04, "startup_multiplier": 0.84, "chip_bonus": 0.10}}}
	},
	"zef_bezos": {
		"signature_a": {"damage_scale": 0.62, "cooldown": 1.4, "effect": {"type": "summon", "speed": 280.0, "duration": 1.1, "size": Vector2(28, 18), "spawn_delay": 0.06}},
		"signature_b": {"damage_scale": 0.70, "cooldown": 1.9, "effect": {"type": "mobility", "mode": "rising", "rise_speed": 320.0, "forward_speed": 120.0}},
		"signature_c": {"damage_scale": 0.64, "cooldown": 2.1, "effect": {"type": "trap", "duration": 1.3, "size": Vector2(32, 18), "spawn_delay": 0.08}},
		"ultimate": {"damage_scale": 0.98, "cooldown": 8.0, "effect": {"type": "projectile", "speed": 430.0, "duration": 1.2, "size": Vector2(40, 22)}}
	},
	"bill_geytz": {
		"signature_a": {"damage_scale": 0.64, "cooldown": 1.5, "control": {"slow_seconds": 0.7, "slow_factor": 0.62}},
		"signature_b": {"damage_scale": 0.70, "cooldown": 1.8, "effect": {"type": "projectile", "speed": 210.0, "duration": 1.3, "size": Vector2(38, 20)}},
		"signature_c": {"damage_scale": 0.58, "cooldown": 2.0, "effect": {"type": "buff", "buff": {"duration": 2.6, "damage_multiplier": 1.1, "startup_multiplier": 0.92}}},
		"ultimate": {"damage_scale": 0.90, "cooldown": 8.4, "effect": {"type": "buff", "buff": {"duration": 4.5, "damage_multiplier": 1.18, "speed_multiplier": 1.06, "startup_multiplier": 0.88}}}
	},
	"larry_pagyr": {
		"signature_a": {"damage_scale": 0.60, "cooldown": 1.4, "effect": {"type": "projectile", "speed": 330.0, "duration": 1.0, "size": Vector2(24, 16)}},
		"signature_b": {"damage_scale": 0.65, "cooldown": 1.9, "control": {"slow_seconds": 0.6, "slow_factor": 0.7}},
		"signature_c": {"damage_scale": 0.66, "cooldown": 2.2, "effect": {"type": "summon", "speed": 260.0, "duration": 1.2, "size": Vector2(32, 18), "spawn_delay": 0.1}},
		"ultimate": {"damage_scale": 0.95, "cooldown": 8.0, "effect": {"type": "projectile", "speed": 430.0, "duration": 1.15, "size": Vector2(38, 22)}}
	},
	"sergey_brinn": {
		"signature_a": {"damage_scale": 0.68, "cooldown": 1.6, "effect": {"type": "mobility", "mode": "rising", "rise_speed": 340.0, "forward_speed": 150.0}},
		"signature_b": {"damage_scale": 0.62, "cooldown": 1.9, "effect": {"type": "mobility", "mode": "teleport", "distance": 120.0}},
		"signature_c": {"damage_scale": 0.72, "cooldown": 2.0, "effect": {"type": "mobility", "mode": "rising", "rise_speed": 300.0, "forward_speed": 220.0}},
		"ultimate": {"damage_scale": 1.0, "cooldown": 8.2, "effect": {"type": "summon", "speed": 280.0, "duration": 1.3, "size": Vector2(36, 20), "spawn_delay": 0.18}}
	},
	"sundar_pichoy": {
		"signature_a": {"damage_scale": 0.64, "cooldown": 1.3, "control": {"slow_seconds": 0.7, "slow_factor": 0.66}},
		"signature_b": {"damage_scale": 0.72, "cooldown": 1.8, "effect": {"type": "mobility", "mode": "dash", "speed": 320.0}},
		"signature_c": {"damage_scale": 0.62, "cooldown": 2.2, "effect": {"type": "summon", "speed": 260.0, "duration": 1.15, "size": Vector2(30, 18), "spawn_delay": 0.1}},
		"ultimate": {"damage_scale": 0.88, "cooldown": 7.6, "effect": {"type": "buff", "buff": {"duration": 4.6, "damage_multiplier": 1.14, "speed_multiplier": 1.1, "startup_multiplier": 0.86}}}
	},
	"jensen_hwang": {
		"signature_a": {"damage_scale": 0.68, "cooldown": 1.4, "effect": {"type": "projectile", "speed": 390.0, "duration": 0.95, "size": Vector2(26, 16)}},
		"signature_b": {"damage_scale": 0.82, "cooldown": 2.1, "block_type": "overhead", "effect": {"type": "mobility", "mode": "dash", "speed": 355.0}},
		"signature_c": {"damage_scale": 0.56, "cooldown": 1.9, "control": {"slow_seconds": 0.75, "slow_factor": 0.58}},
		"ultimate": {"damage_scale": 1.0, "cooldown": 8.0, "effect": {"type": "buff", "buff": {"duration": 4.2, "damage_multiplier": 1.24, "speed_multiplier": 1.12, "startup_multiplier": 0.82, "chip_bonus": 0.10}}}
	},
	"satya_nadello": {
		"signature_a": {"damage_scale": 0.58, "cooldown": 1.6, "effect": {"type": "buff", "buff": {"duration": 3.0, "damage_multiplier": 1.1, "startup_multiplier": 0.92}}},
		"signature_b": {"damage_scale": 0.66, "cooldown": 1.9, "effect": {"type": "projectile", "speed": 300.0, "duration": 0.95, "size": Vector2(26, 16)}},
		"signature_c": {"damage_scale": 0.60, "cooldown": 2.0, "effect": {"type": "projectile", "speed": 250.0, "duration": 1.0, "size": Vector2(28, 18), "silence_seconds": 1.2}},
		"ultimate": {"damage_scale": 0.90, "cooldown": 7.8, "effect": {"type": "buff", "buff": {"duration": 4.8, "damage_multiplier": 1.18, "speed_multiplier": 1.06, "startup_multiplier": 0.86, "chip_bonus": 0.09}}}
	},
	"tim_cuke": {
		"signature_a": {"damage_scale": 0.66, "cooldown": 1.5},
		"signature_b": {"damage_scale": 0.72, "cooldown": 1.9, "effect": {"type": "mobility", "mode": "teleport", "distance": 110.0}},
		"signature_c": {"damage_scale": 0.52, "cooldown": 2.2, "effect": {"type": "buff", "buff": {"duration": 2.8, "speed_multiplier": 1.08, "startup_multiplier": 0.78}}},
		"ultimate": {"damage_scale": 0.92, "cooldown": 7.9, "effect": {"type": "trap", "duration": 1.4, "size": Vector2(44, 24), "slow_seconds": 0.9, "slow_factor": 0.52, "root_seconds": 0.18}}
	},
	"jack_dorsee": {
		"signature_a": {"damage_scale": 0.62, "cooldown": 1.2, "effect": {"type": "projectile", "speed": 450.0, "duration": 0.8, "size": Vector2(22, 14)}},
		"signature_b": {"damage_scale": 0.72, "cooldown": 2.0, "effect": {"type": "summon", "speed": 260.0, "duration": 1.15, "spawn_delay": 0.2, "size": Vector2(32, 18)}},
		"signature_c": {"damage_scale": 0.68, "cooldown": 2.1, "effect": {"type": "projectile", "speed": 220.0, "duration": 1.2, "size": Vector2(30, 18)}},
		"ultimate": {"damage_scale": 0.94, "cooldown": 8.1, "effect": {"type": "summon", "speed": 300.0, "duration": 1.25, "size": Vector2(36, 20), "spawn_delay": 0.12}}
	},
	"travis_kalanik": {
		"signature_a": {"damage_scale": 0.54, "cooldown": 1.7, "effect": {"type": "buff", "buff": {"duration": 4.0, "damage_multiplier": 1.2, "speed_multiplier": 1.1, "startup_multiplier": 0.9, "chip_bonus": 0.1}}},
		"signature_b": {"damage_scale": 0.76, "cooldown": 2.1, "effect": {"type": "mobility", "mode": "dash", "speed": 360.0}},
		"signature_c": {"damage_scale": 0.78, "cooldown": 2.3, "effect": {"type": "mobility", "mode": "dash", "speed": 400.0}},
		"ultimate": {"damage_scale": 1.0, "cooldown": 8.2, "effect": {"type": "summon", "speed": 320.0, "duration": 1.3, "size": Vector2(38, 20), "spawn_delay": 0.1}}
	},
	"reed_hestings": {
		"signature_a": {"damage_scale": 0.68, "cooldown": 1.6, "effect": {"type": "summon", "speed": 250.0, "duration": 1.2, "size": Vector2(32, 18), "spawn_delay": 0.08}},
		"signature_b": {"damage_scale": 0.50, "cooldown": 1.8, "effect": {"type": "buff", "buff": {"duration": 3.2, "startup_multiplier": 0.8}}},
		"signature_c": {"damage_scale": 0.74, "cooldown": 2.0, "effect": {"type": "mobility", "mode": "dash", "speed": 330.0}},
		"ultimate": {"damage_scale": 0.96, "cooldown": 8.0, "effect": {"type": "buff", "buff": {"duration": 4.4, "damage_multiplier": 1.2, "speed_multiplier": 1.08, "startup_multiplier": 0.82, "chip_bonus": 0.09}}}
	},
	"steve_jobz": {
		"signature_a": {"damage_scale": 0.72, "cooldown": 1.5},
		"signature_b": {"damage_scale": 0.84, "cooldown": 2.0, "block_type": "overhead", "effect": {"type": "mobility", "mode": "dash", "speed": 380.0}},
		"signature_c": {"damage_scale": 0.70, "cooldown": 2.2, "effect": {"type": "mobility", "mode": "teleport", "distance": 130.0}},
		"ultimate": {"damage_scale": 1.12, "cooldown": 7.0, "effect": {"type": "buff", "buff": {"duration": 5.2, "damage_multiplier": 1.28, "speed_multiplier": 1.15, "startup_multiplier": 0.78, "chip_bonus": 0.12}}}
	}
}

const SLOT_KEYS := ["signature_a", "signature_b", "signature_c", "ultimate"]
const SLOT_CONTRACT_FALLBACKS_BY_ARCHETYPE := {
	PlayerDataStore.ARCHETYPE_ALL_ROUNDER: {
		"signature_a": {"role": "pressure", "skeleton": "pressure_check"},
		"signature_b": {"role": "approach", "skeleton": "dash_burst"},
		"signature_c": {"role": "control", "skeleton": "control_snare"},
		"ultimate": {"role": "super", "skeleton": "super_burst"}
	},
	PlayerDataStore.ARCHETYPE_RUSHDOWN: {
		"signature_a": {"role": "pressure", "skeleton": "pressure_check"},
		"signature_b": {"role": "approach", "skeleton": "dash_burst"},
		"signature_c": {"role": "anti_air", "skeleton": "rising_launcher"},
		"ultimate": {"role": "super", "skeleton": "super_burst"}
	},
	PlayerDataStore.ARCHETYPE_ZONER: {
		"signature_a": {"role": "pressure", "skeleton": "projectile_check"},
		"signature_b": {"role": "approach", "skeleton": "teleport_punish"},
		"signature_c": {"role": "setplay", "skeleton": "trap_setplay"},
		"ultimate": {"role": "super", "skeleton": "screen_control_super"}
	},
	PlayerDataStore.ARCHETYPE_BRUISER: {
		"signature_a": {"role": "pressure", "skeleton": "pressure_check"},
		"signature_b": {"role": "approach", "skeleton": "rising_launcher"},
		"signature_c": {"role": "control", "skeleton": "control_snare"},
		"ultimate": {"role": "super", "skeleton": "super_burst"}
	},
	PlayerDataStore.ARCHETYPE_COUNTER: {
		"signature_a": {"role": "control", "skeleton": "control_poke"},
		"signature_b": {"role": "approach", "skeleton": "teleport_punish"},
		"signature_c": {"role": "control", "skeleton": "control_snare"},
		"ultimate": {"role": "install", "skeleton": "install_overclock"}
	}
}

static func get_profile(character_id: String) -> Dictionary:
	var value: Variant = PROFILE_BY_CHARACTER.get(character_id, {})
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	return _normalize_profile(character_id, (value as Dictionary).duplicate(true))

static func get_generated_archetype(profile: Dictionary) -> String:
	return str(profile.get("generated_archetype", PlayerDataStore.ARCHETYPE_ALL_ROUNDER))

static func get_slot_contract(profile: Dictionary, slot_key: String) -> Dictionary:
	var slot_contracts_value: Variant = profile.get("slot_contracts", {})
	if typeof(slot_contracts_value) == TYPE_DICTIONARY:
		var slot_contracts := slot_contracts_value as Dictionary
		var contract_value: Variant = slot_contracts.get(slot_key, {})
		if typeof(contract_value) == TYPE_DICTIONARY:
			return (contract_value as Dictionary).duplicate(true)
	var entry_value: Variant = profile.get(slot_key, {})
	if typeof(entry_value) != TYPE_DICTIONARY:
		return {}
	var entry := entry_value as Dictionary
	return _build_slot_contract(
		slot_key,
		str(entry.get("role", "")),
		str(entry.get("skeleton", ""))
	)

static func _normalize_profile(character_id: String, profile: Dictionary) -> Dictionary:
	var normalized := profile.duplicate(true)
	var generated_archetype := str(normalized.get(
		"generated_archetype",
		PlayerDataStore.resolve_character_archetype(character_id)
	)).strip_edges().to_lower()
	if generated_archetype == "":
		generated_archetype = PlayerDataStore.ARCHETYPE_ALL_ROUNDER
	normalized["generated_archetype"] = generated_archetype
	var slot_contracts := {}
	for slot_key in SLOT_KEYS:
		var entry_value: Variant = normalized.get(slot_key, {})
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue
		var entry := (entry_value as Dictionary).duplicate(true)
		var contract := _resolve_slot_contract(slot_key, entry, generated_archetype)
		entry["slot_key"] = slot_key
		entry["generated_archetype"] = generated_archetype
		entry["role"] = str(contract.get("role", ""))
		entry["skeleton"] = str(contract.get("skeleton", ""))
		normalized[slot_key] = entry
		slot_contracts[slot_key] = contract
	normalized["slot_contracts"] = slot_contracts
	return normalized

static func _resolve_slot_contract(slot_key: String, entry: Dictionary, generated_archetype: String) -> Dictionary:
	var fallback := _get_archetype_slot_contract(generated_archetype, slot_key)
	var role := str(entry.get("role", "")).strip_edges().to_lower()
	var skeleton := str(entry.get("skeleton", "")).strip_edges().to_lower()
	if role != "" and skeleton != "":
		return _build_slot_contract(slot_key, role, skeleton)
	var inferred := _infer_slot_contract_from_payload(slot_key, entry, fallback)
	if role == "":
		role = str(inferred.get("role", fallback.get("role", ""))).strip_edges().to_lower()
	if skeleton == "":
		skeleton = str(inferred.get("skeleton", fallback.get("skeleton", ""))).strip_edges().to_lower()
	return _build_slot_contract(slot_key, role, skeleton)

static func _get_archetype_slot_contract(generated_archetype: String, slot_key: String) -> Dictionary:
	var contract_map_value: Variant = SLOT_CONTRACT_FALLBACKS_BY_ARCHETYPE.get(
		generated_archetype,
		SLOT_CONTRACT_FALLBACKS_BY_ARCHETYPE[PlayerDataStore.ARCHETYPE_ALL_ROUNDER]
	)
	if typeof(contract_map_value) != TYPE_DICTIONARY:
		return {}
	var contract_map := contract_map_value as Dictionary
	var contract_value: Variant = contract_map.get(slot_key, {})
	if typeof(contract_value) != TYPE_DICTIONARY:
		return {}
	var contract := contract_value as Dictionary
	return _build_slot_contract(
		slot_key,
		str(contract.get("role", "")),
		str(contract.get("skeleton", ""))
	)

static func _infer_slot_contract_from_payload(slot_key: String, entry: Dictionary, fallback: Dictionary) -> Dictionary:
	var effect_type := _resolve_effect_type(entry)
	var effect_mode := _resolve_effect_mode(entry)
	if slot_key == "ultimate":
		match effect_type:
			"buff":
				return _build_slot_contract(slot_key, "install", "install_overclock")
			"projectile", "trap", "summon":
				return _build_slot_contract(slot_key, "super", "screen_control_super")
		return fallback
	match effect_type:
		"mobility":
			if effect_mode == "rising":
				return _build_slot_contract(slot_key, "anti_air" if slot_key == "signature_c" else "approach", "rising_launcher")
			if effect_mode == "teleport":
				return _build_slot_contract(slot_key, "approach", "teleport_punish")
			return _build_slot_contract(slot_key, "approach", "dash_burst")
		"projectile":
			if slot_key == "signature_c":
				return _build_slot_contract(slot_key, "control", "projectile_screen")
			return _build_slot_contract(slot_key, "pressure", "projectile_check")
		"trap":
			if slot_key == "signature_a":
				return _build_slot_contract(slot_key, "setplay", "trap_seed")
			return _build_slot_contract(slot_key, "setplay", "trap_setplay")
		"summon":
			if slot_key == "signature_a":
				return _build_slot_contract(slot_key, "pressure", "summon_check")
			return _build_slot_contract(slot_key, "setplay", "summon_screen")
		"buff":
			return _build_slot_contract(slot_key, "install", "install_pulse")
	if _has_control_payload(entry):
		if slot_key == "signature_a":
			return _build_slot_contract(slot_key, "control", "control_poke")
		return _build_slot_contract(slot_key, "control", "control_snare")
	return fallback

static func _resolve_effect_type(entry: Dictionary) -> String:
	var effect_value: Variant = entry.get("effect", {})
	if typeof(effect_value) != TYPE_DICTIONARY:
		return ""
	return str((effect_value as Dictionary).get("type", "")).strip_edges().to_lower()

static func _resolve_effect_mode(entry: Dictionary) -> String:
	var effect_value: Variant = entry.get("effect", {})
	if typeof(effect_value) != TYPE_DICTIONARY:
		return ""
	return str((effect_value as Dictionary).get("mode", "")).strip_edges().to_lower()

static func _has_control_payload(entry: Dictionary) -> bool:
	var control_value: Variant = entry.get("control", {})
	if typeof(control_value) != TYPE_DICTIONARY:
		return false
	return not (control_value as Dictionary).is_empty()

static func _build_slot_contract(slot_key: String, role: String, skeleton: String) -> Dictionary:
	return {
		"slot_key": slot_key,
		"role": role,
		"skeleton": skeleton
	}

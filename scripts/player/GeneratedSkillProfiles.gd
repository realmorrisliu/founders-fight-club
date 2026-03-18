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
const ALLOWED_ROLES_BY_SLOT := {
	"signature_a": {"pressure": true, "control": true},
	"signature_b": {"approach": true},
	"signature_c": {"control": true, "setplay": true, "anti_air": true},
	"ultimate": {"super": true, "install": true}
}
const SKELETONS_BY_ROLE := {
	"pressure": {
		"pressure_check": true,
		"projectile_check": true,
		"summon_check": true,
		"trap_seed": true,
		"control_poke": true
	},
	"approach": {
		"dash_burst": true,
		"teleport_punish": true,
		"rising_launcher": true
	},
	"control": {
		"control_poke": true,
		"control_snare": true,
		"projectile_screen": true,
		"summon_screen": true
	},
	"setplay": {
		"trap_seed": true,
		"trap_setplay": true,
		"projectile_screen": true,
		"summon_screen": true
	},
	"anti_air": {
		"rising_launcher": true
	},
	"install": {
		"install_pulse": true,
		"install_overclock": true
	},
	"super": {
		"super_burst": true,
		"screen_control_super": true
	}
}
const ROLE_BALANCE_BANDS := {
	"pressure": {
		"damage_scale_min": 0.58,
		"damage_scale_max": 0.68,
		"cooldown_min": 1.3,
		"cooldown_max": 1.6
	},
	"approach": {
		"damage_scale_min": 0.60,
		"damage_scale_max": 0.78,
		"cooldown_min": 1.8,
		"cooldown_max": 2.1
	},
	"control": {
		"damage_scale_min": 0.56,
		"damage_scale_max": 0.70,
		"cooldown_min": 1.8,
		"cooldown_max": 2.2
	},
	"setplay": {
		"damage_scale_min": 0.60,
		"damage_scale_max": 0.72,
		"cooldown_min": 2.0,
		"cooldown_max": 2.3
	},
	"anti_air": {
		"damage_scale_min": 0.64,
		"damage_scale_max": 0.76,
		"cooldown_min": 1.9,
		"cooldown_max": 2.2
	},
	"install": {
		"damage_scale_min": 0.88,
		"damage_scale_max": 0.98,
		"cooldown_min": 7.8,
		"cooldown_max": 8.4
	},
	"super": {
		"damage_scale_min": 0.90,
		"damage_scale_max": 1.02,
		"cooldown_min": 7.8,
		"cooldown_max": 8.3
	}
}
const MOBILITY_EFFECT_LIMITS := {
	"dash": {
		"speed_min": 320.0,
		"speed_max": 360.0
	},
	"teleport": {
		"distance_min": 110.0,
		"distance_max": 124.0
	},
	"rising": {
		"rise_speed_min": 300.0,
		"rise_speed_max": 340.0,
		"forward_speed_min": 120.0,
		"forward_speed_max": 220.0
	}
}
const PROJECTILE_EFFECT_LIMITS := {
	"speed_min": 220.0,
	"speed_max": 430.0,
	"duration_min": 0.8,
	"duration_max": 1.2,
	"size_min": Vector2(22, 14),
	"size_max": Vector2(40, 22)
}
const SUMMON_EFFECT_LIMITS := {
	"speed_min": 245.0,
	"speed_max": 320.0,
	"duration_min": 1.1,
	"duration_max": 1.3,
	"spawn_delay_min": 0.04,
	"spawn_delay_max": 0.18,
	"size_min": Vector2(30, 18),
	"size_max": Vector2(38, 20)
}
const TRAP_EFFECT_LIMITS := {
	"duration_min": 1.25,
	"duration_max": 1.4,
	"spawn_delay_min": 0.08,
	"spawn_delay_max": 0.14,
	"size_min": Vector2(32, 18),
	"size_max": Vector2(44, 24)
}
const CONTROL_PAYLOAD_LIMITS := {
	"slow_seconds_min": 0.45,
	"slow_seconds_max": 0.72,
	"slow_factor_min": 0.58,
	"slow_factor_max": 0.76,
	"root_seconds_max": 0.14,
	"silence_seconds_max": 0.75
}
const SIGNATURE_BUFF_LIMITS := {
	"duration_min": 2.8,
	"duration_max": 4.0,
	"damage_multiplier_max": 1.12,
	"speed_multiplier_max": 1.10,
	"startup_multiplier_min": 0.82,
	"chip_bonus_max": 0.08
}
const ULTIMATE_BUFF_LIMITS := {
	"duration_min": 4.0,
	"duration_max": 4.8,
	"damage_multiplier_max": 1.24,
	"speed_multiplier_max": 1.12,
	"startup_multiplier_min": 0.80,
	"chip_bonus_max": 0.10
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
		_apply_balance_band(entry, contract)
		normalized[slot_key] = entry
		slot_contracts[slot_key] = contract
	normalized["slot_contracts"] = slot_contracts
	return normalized

static func _resolve_slot_contract(slot_key: String, entry: Dictionary, generated_archetype: String) -> Dictionary:
	var preferred := _get_archetype_slot_contract(generated_archetype, slot_key)
	var inferred := _infer_slot_contract_from_payload(slot_key, entry, preferred)
	var role := str(entry.get("role", inferred.get("role", preferred.get("role", "")))).strip_edges().to_lower()
	if not _is_role_allowed_for_slot(slot_key, role):
		role = str(preferred.get("role", role)).strip_edges().to_lower()
	var skeleton := str(entry.get("skeleton", inferred.get("skeleton", ""))).strip_edges().to_lower()
	if skeleton == "" or not _does_skeleton_match_role(skeleton, role):
		skeleton = _resolve_skeleton_for_role(role, slot_key, entry, preferred)
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

static func _is_role_allowed_for_slot(slot_key: String, role: String) -> bool:
	var allowed_value: Variant = ALLOWED_ROLES_BY_SLOT.get(slot_key, {})
	if typeof(allowed_value) != TYPE_DICTIONARY:
		return role != ""
	var allowed_roles := allowed_value as Dictionary
	return role != "" and allowed_roles.has(role)

static func _does_skeleton_match_role(skeleton: String, role: String) -> bool:
	var role_value: Variant = SKELETONS_BY_ROLE.get(role, {})
	if typeof(role_value) != TYPE_DICTIONARY:
		return false
	return (role_value as Dictionary).has(skeleton)

static func _resolve_skeleton_for_role(role: String, slot_key: String, entry: Dictionary, fallback: Dictionary) -> String:
	var effect_type := _resolve_effect_type(entry)
	var effect_mode := _resolve_effect_mode(entry)
	match role:
		"pressure":
			if effect_type == "projectile":
				return "projectile_check"
			if effect_type == "summon":
				return "summon_check"
			if effect_type == "trap":
				return "trap_seed"
			if slot_key == "signature_a" and _has_control_payload(entry):
				return "control_poke"
			return str(fallback.get("skeleton", "pressure_check"))
		"approach":
			if effect_type == "mobility":
				if effect_mode == "teleport":
					return "teleport_punish"
				if effect_mode == "rising":
					return "rising_launcher"
			return "dash_burst"
		"control":
			if effect_type == "projectile":
				return "projectile_screen"
			if effect_type == "summon":
				return "summon_screen"
			if slot_key == "signature_a":
				return "control_poke"
			return "control_snare"
		"setplay":
			if effect_type == "projectile":
				return "projectile_screen"
			if effect_type == "summon":
				return "summon_screen"
			return "trap_seed" if slot_key == "signature_a" else "trap_setplay"
		"anti_air":
			return "rising_launcher"
		"install":
			return "install_overclock" if slot_key == "ultimate" else "install_pulse"
		"super":
			if effect_type in ["projectile", "trap", "summon"]:
				return "screen_control_super"
			return "super_burst"
	return str(fallback.get("skeleton", "pressure_check"))

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

static func _apply_balance_band(entry: Dictionary, contract: Dictionary) -> void:
	var role := str(contract.get("role", "")).strip_edges().to_lower()
	var band_value: Variant = ROLE_BALANCE_BANDS.get(role, {})
	if typeof(band_value) != TYPE_DICTIONARY:
		return
	var band := band_value as Dictionary
	if entry.has("damage_scale"):
		entry["damage_scale"] = clampf(
			float(entry.get("damage_scale", band.get("damage_scale_min", 0.0))),
			float(band.get("damage_scale_min", 0.0)),
			float(band.get("damage_scale_max", 10.0))
		)
	if entry.has("cooldown"):
		entry["cooldown"] = clampf(
			float(entry.get("cooldown", band.get("cooldown_min", 0.0))),
			float(band.get("cooldown_min", 0.0)),
			float(band.get("cooldown_max", 99.0))
		)
	_normalize_effect_payload(entry)
	_normalize_control_payload(entry)

static func _normalize_effect_payload(entry: Dictionary) -> void:
	var effect_value: Variant = entry.get("effect", {})
	if typeof(effect_value) != TYPE_DICTIONARY:
		return
	var effect := (effect_value as Dictionary).duplicate(true)
	var effect_type := str(effect.get("type", "")).strip_edges().to_lower()
	match effect_type:
		"mobility":
			_normalize_mobility_effect(effect)
		"projectile":
			_clamp_float_key(effect, "speed", PROJECTILE_EFFECT_LIMITS)
			_clamp_float_key(effect, "duration", PROJECTILE_EFFECT_LIMITS)
			_clamp_vector2_key(effect, "size", PROJECTILE_EFFECT_LIMITS)
		"summon":
			_clamp_float_key(effect, "speed", SUMMON_EFFECT_LIMITS)
			_clamp_float_key(effect, "duration", SUMMON_EFFECT_LIMITS)
			_clamp_float_key(effect, "spawn_delay", SUMMON_EFFECT_LIMITS)
			_clamp_vector2_key(effect, "size", SUMMON_EFFECT_LIMITS)
		"trap":
			_clamp_float_key(effect, "duration", TRAP_EFFECT_LIMITS)
			_clamp_float_key(effect, "spawn_delay", TRAP_EFFECT_LIMITS)
			_clamp_vector2_key(effect, "size", TRAP_EFFECT_LIMITS)
		"buff":
			_normalize_buff_effect(effect, str(entry.get("slot_key", "")) == "ultimate")
	entry["effect"] = effect

static func _normalize_mobility_effect(effect: Dictionary) -> void:
	var mode := str(effect.get("mode", "")).strip_edges().to_lower()
	var limits_value: Variant = MOBILITY_EFFECT_LIMITS.get(mode, {})
	if typeof(limits_value) != TYPE_DICTIONARY:
		return
	var limits := limits_value as Dictionary
	match mode:
		"dash":
			_clamp_float_key(effect, "speed", limits)
		"teleport":
			_clamp_float_key(effect, "distance", limits)
		"rising":
			_clamp_float_key(effect, "rise_speed", limits)
			_clamp_float_key(effect, "forward_speed", limits)

static func _normalize_control_payload(entry: Dictionary) -> void:
	var control_value: Variant = entry.get("control", {})
	if typeof(control_value) == TYPE_DICTIONARY:
		var control := (control_value as Dictionary).duplicate(true)
		_clamp_float_key(control, "slow_seconds", CONTROL_PAYLOAD_LIMITS)
		_clamp_float_key(control, "slow_factor", CONTROL_PAYLOAD_LIMITS)
		if control.has("root_seconds"):
			control["root_seconds"] = minf(
				float(control.get("root_seconds", 0.0)),
				float(CONTROL_PAYLOAD_LIMITS.get("root_seconds_max", 0.14))
			)
		if control.has("silence_seconds"):
			control["silence_seconds"] = minf(
				float(control.get("silence_seconds", 0.0)),
				float(CONTROL_PAYLOAD_LIMITS.get("silence_seconds_max", 0.75))
			)
		entry["control"] = control
	var effect_value: Variant = entry.get("effect", {})
	if typeof(effect_value) != TYPE_DICTIONARY:
		return
	var effect := (effect_value as Dictionary).duplicate(true)
	if effect.has("slow_seconds"):
		_clamp_float_key(effect, "slow_seconds", CONTROL_PAYLOAD_LIMITS)
	if effect.has("slow_factor"):
		_clamp_float_key(effect, "slow_factor", CONTROL_PAYLOAD_LIMITS)
	if effect.has("root_seconds"):
		effect["root_seconds"] = minf(
			float(effect.get("root_seconds", 0.0)),
			float(CONTROL_PAYLOAD_LIMITS.get("root_seconds_max", 0.14))
		)
	if effect.has("silence_seconds"):
		effect["silence_seconds"] = minf(
			float(effect.get("silence_seconds", 0.0)),
			float(CONTROL_PAYLOAD_LIMITS.get("silence_seconds_max", 0.75))
		)
	entry["effect"] = effect

static func _normalize_buff_effect(effect: Dictionary, is_ultimate: bool) -> void:
	var buff_value: Variant = effect.get("buff", {})
	if typeof(buff_value) != TYPE_DICTIONARY:
		return
	var buff := (buff_value as Dictionary).duplicate(true)
	var limits: Dictionary = ULTIMATE_BUFF_LIMITS if is_ultimate else SIGNATURE_BUFF_LIMITS
	_clamp_float_key(buff, "duration", limits)
	if buff.has("damage_multiplier"):
		buff["damage_multiplier"] = minf(
			float(buff.get("damage_multiplier", 1.0)),
			float(limits.get("damage_multiplier_max", 1.0))
		)
	if buff.has("speed_multiplier"):
		buff["speed_multiplier"] = minf(
			float(buff.get("speed_multiplier", 1.0)),
			float(limits.get("speed_multiplier_max", 1.0))
		)
	if buff.has("startup_multiplier"):
		buff["startup_multiplier"] = maxf(
			float(buff.get("startup_multiplier", 1.0)),
			float(limits.get("startup_multiplier_min", 1.0))
		)
	if buff.has("chip_bonus"):
		buff["chip_bonus"] = minf(
			float(buff.get("chip_bonus", 0.0)),
			float(limits.get("chip_bonus_max", 0.0))
		)
	effect["buff"] = buff

static func _clamp_float_key(entry: Dictionary, key: String, limits: Dictionary) -> void:
	if not entry.has(key):
		return
	var min_key := "%s_min" % key
	var max_key := "%s_max" % key
	entry[key] = clampf(
		float(entry.get(key, limits.get(min_key, 0.0))),
		float(limits.get(min_key, entry.get(key, 0.0))),
		float(limits.get(max_key, entry.get(key, 0.0)))
	)

static func _clamp_vector2_key(entry: Dictionary, key: String, limits: Dictionary) -> void:
	if not entry.has(key):
		return
	var value: Variant = entry.get(key, Vector2.ZERO)
	if not (value is Vector2):
		return
	var min_key := "%s_min" % key
	var max_key := "%s_max" % key
	var min_value: Variant = limits.get(min_key, value)
	var max_value: Variant = limits.get(max_key, value)
	if not (min_value is Vector2) or not (max_value is Vector2):
		return
	var vector := value as Vector2
	var min_vector := min_value as Vector2
	var max_vector := max_value as Vector2
	entry[key] = Vector2(
		clampf(vector.x, min_vector.x, max_vector.x),
		clampf(vector.y, min_vector.y, max_vector.y)
	)

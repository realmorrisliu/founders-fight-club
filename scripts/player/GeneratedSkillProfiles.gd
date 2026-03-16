extends RefCounted
class_name GeneratedSkillProfiles

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

static func get_profile(character_id: String) -> Dictionary:
	var value: Variant = PROFILE_BY_CHARACTER.get(character_id, {})
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	return (value as Dictionary).duplicate(true)

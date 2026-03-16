extends RefCounted
class_name PlayerData

const AI_PROFILE_DEFAULT := {
	"preferred_range": 56.0,
	"chase_range": 108.0,
	"retreat_range": 20.0,
	"retreat_chance": 0.24,
	"block_chance": 0.35,
	"block_hold_time": 0.18,
	"signature_bias": 1.0,
	"special_bias": 1.0,
	"heavy_bias": 1.0,
	"throw_bias": 1.0,
	"ultimate_bias": 1.0,
	"dash_in_chance": 0.08,
	"cooldown_min": 0.40,
	"cooldown_max": 0.72,
	"combo_pressure": 0.52
}

const AI_PROFILE_BY_CHARACTER := {
	"elon_mvsk": {"preferred_range": 60.0, "chase_range": 112.0, "retreat_range": 16.0, "retreat_chance": 0.12, "block_chance": 0.24, "signature_bias": 0.98, "special_bias": 0.78, "heavy_bias": 1.02, "throw_bias": 0.84, "ultimate_bias": 1.18, "dash_in_chance": 0.10, "cooldown_min": 0.44, "cooldown_max": 0.72, "combo_pressure": 0.50},
	"mark_zuck": {"preferred_range": 54.0, "chase_range": 102.0, "retreat_range": 18.0, "retreat_chance": 0.18, "block_chance": 0.30, "signature_bias": 1.08, "special_bias": 0.96, "heavy_bias": 1.04, "throw_bias": 0.96, "ultimate_bias": 1.12, "dash_in_chance": 0.14, "cooldown_min": 0.36, "cooldown_max": 0.64, "combo_pressure": 0.64},
	"sam_altmyn": {"preferred_range": 52.0, "chase_range": 100.0, "retreat_range": 18.0, "retreat_chance": 0.18, "block_chance": 0.30, "signature_bias": 1.00, "special_bias": 0.94, "heavy_bias": 1.08, "throw_bias": 0.96, "ultimate_bias": 1.28, "dash_in_chance": 0.14, "cooldown_min": 0.36, "cooldown_max": 0.62, "combo_pressure": 0.62},
	"peter_thyell": {"preferred_range": 58.0, "chase_range": 108.0, "retreat_range": 18.0, "retreat_chance": 0.16, "block_chance": 0.34, "signature_bias": 1.06, "special_bias": 0.88, "heavy_bias": 1.10, "throw_bias": 0.88, "ultimate_bias": 1.16, "dash_in_chance": 0.12, "cooldown_min": 0.40, "cooldown_max": 0.70, "combo_pressure": 0.56},
	"zef_bezos": {"preferred_range": 46.0, "chase_range": 94.0, "retreat_range": 15.0, "retreat_chance": 0.18, "block_chance": 0.27, "signature_bias": 0.92, "special_bias": 1.18, "heavy_bias": 1.28, "throw_bias": 1.22, "ultimate_bias": 1.1, "dash_in_chance": 0.16, "cooldown_min": 0.34, "cooldown_max": 0.62, "combo_pressure": 0.72},
	"bill_geytz": {"preferred_range": 72.0, "chase_range": 126.0, "retreat_range": 20.0, "retreat_chance": 0.22, "block_chance": 0.42, "signature_bias": 1.35, "special_bias": 0.88, "heavy_bias": 0.78, "throw_bias": 0.60, "ultimate_bias": 1.2, "dash_in_chance": 0.05, "cooldown_min": 0.48, "cooldown_max": 0.84, "combo_pressure": 0.38},
	"sundar_pichoy": {"preferred_range": 60.0, "chase_range": 112.0, "retreat_range": 22.0, "retreat_chance": 0.25, "block_chance": 0.36, "signature_bias": 1.1, "special_bias": 1.0, "heavy_bias": 0.96, "throw_bias": 0.80, "ultimate_bias": 1.22, "dash_in_chance": 0.11, "cooldown_min": 0.40, "cooldown_max": 0.72, "combo_pressure": 0.56},
	"jensen_hwang": {"preferred_range": 55.0, "chase_range": 102.0, "retreat_range": 19.0, "retreat_chance": 0.20, "block_chance": 0.29, "signature_bias": 1.0, "special_bias": 1.18, "heavy_bias": 1.18, "throw_bias": 0.88, "ultimate_bias": 1.18, "dash_in_chance": 0.13, "cooldown_min": 0.36, "cooldown_max": 0.66, "combo_pressure": 0.66},
	"larry_pagyr": {"preferred_range": 76.0, "chase_range": 136.0, "retreat_range": 18.0, "retreat_chance": 0.16, "block_chance": 0.38, "signature_bias": 1.45, "special_bias": 0.82, "heavy_bias": 0.70, "throw_bias": 0.50, "ultimate_bias": 1.24, "dash_in_chance": 0.03, "cooldown_min": 0.54, "cooldown_max": 0.92, "combo_pressure": 0.34},
	"sergey_brinn": {"preferred_range": 68.0, "chase_range": 120.0, "retreat_range": 22.0, "retreat_chance": 0.24, "block_chance": 0.37, "signature_bias": 1.30, "special_bias": 0.94, "heavy_bias": 0.86, "throw_bias": 0.66, "ultimate_bias": 1.22, "dash_in_chance": 0.07, "cooldown_min": 0.48, "cooldown_max": 0.82, "combo_pressure": 0.46},
	"satya_nadello": {"preferred_range": 66.0, "chase_range": 116.0, "retreat_range": 22.0, "retreat_chance": 0.22, "block_chance": 0.44, "signature_bias": 1.22, "special_bias": 0.9, "heavy_bias": 0.82, "throw_bias": 0.64, "ultimate_bias": 1.18, "dash_in_chance": 0.06, "cooldown_min": 0.46, "cooldown_max": 0.80, "combo_pressure": 0.42},
	"tim_cuke": {"preferred_range": 59.0, "chase_range": 104.0, "retreat_range": 26.0, "retreat_chance": 0.30, "block_chance": 0.32, "signature_bias": 1.16, "special_bias": 1.05, "heavy_bias": 0.88, "throw_bias": 0.84, "ultimate_bias": 1.16, "dash_in_chance": 0.14, "cooldown_min": 0.38, "cooldown_max": 0.68, "combo_pressure": 0.60},
	"jack_dorsee": {"preferred_range": 64.0, "chase_range": 118.0, "retreat_range": 22.0, "retreat_chance": 0.24, "block_chance": 0.31, "signature_bias": 1.34, "special_bias": 0.98, "heavy_bias": 0.90, "throw_bias": 0.70, "ultimate_bias": 1.2, "dash_in_chance": 0.10, "cooldown_min": 0.40, "cooldown_max": 0.72, "combo_pressure": 0.54},
	"travis_kalanik": {"preferred_range": 48.0, "chase_range": 96.0, "retreat_range": 14.0, "retreat_chance": 0.14, "block_chance": 0.24, "signature_bias": 1.18, "special_bias": 1.2, "heavy_bias": 1.20, "throw_bias": 1.0, "ultimate_bias": 1.15, "dash_in_chance": 0.20, "cooldown_min": 0.32, "cooldown_max": 0.58, "combo_pressure": 0.78},
	"reed_hestings": {"preferred_range": 69.0, "chase_range": 122.0, "retreat_range": 21.0, "retreat_chance": 0.22, "block_chance": 0.39, "signature_bias": 1.26, "special_bias": 0.92, "heavy_bias": 0.84, "throw_bias": 0.68, "ultimate_bias": 1.25, "dash_in_chance": 0.07, "cooldown_min": 0.46, "cooldown_max": 0.82, "combo_pressure": 0.44},
	"steve_jobz": {"preferred_range": 53.0, "chase_range": 100.0, "retreat_range": 18.0, "retreat_chance": 0.20, "block_chance": 0.30, "signature_bias": 1.22, "special_bias": 1.08, "heavy_bias": 1.08, "throw_bias": 0.90, "ultimate_bias": 1.34, "dash_in_chance": 0.16, "cooldown_min": 0.34, "cooldown_max": 0.62, "combo_pressure": 0.70}
}

const CHARACTER_TINT_BY_ID := {
	"elon_mvsk": Color(0.90, 0.86, 1.0, 1.0),
	"mark_zuck": Color(0.84, 0.96, 1.0, 1.0),
	"sam_altmyn": Color(0.88, 1.0, 0.88, 1.0),
	"peter_thyell": Color(0.98, 0.90, 0.80, 1.0),
	"zef_bezos": Color(1.0, 0.90, 0.82, 1.0),
	"bill_geytz": Color(0.86, 0.92, 1.0, 1.0),
	"sundar_pichoy": Color(0.90, 1.0, 0.90, 1.0),
	"jensen_hwang": Color(0.98, 0.94, 0.78, 1.0),
	"larry_pagyr": Color(0.90, 0.86, 1.0, 1.0),
	"sergey_brinn": Color(0.86, 1.0, 0.94, 1.0),
	"satya_nadello": Color(0.86, 0.96, 1.0, 1.0),
	"tim_cuke": Color(0.94, 0.92, 1.0, 1.0),
	"jack_dorsee": Color(0.82, 0.96, 1.0, 1.0),
	"travis_kalanik": Color(1.0, 0.88, 0.82, 1.0),
	"reed_hestings": Color(0.90, 1.0, 0.84, 1.0),
	"steve_jobz": Color(1.0, 0.94, 0.84, 1.0),
	"prototype_p1": Color(0.84, 0.96, 1.0, 1.0),
	"prototype_p2": Color(1.0, 0.88, 0.84, 1.0)
}

const ANIMATION_PROFILES := {
	"idle": {"fps": 8.0, "loop": true},
	"walk": {"fps": 11.0, "loop": true},
	"jump": {"fps": 9.0, "loop": false},
	"light": {"fps": 18.0, "loop": false},
	"heavy": {"fps": 9.0, "loop": false},
	"special": {"fps": 10.0, "loop": false},
	"throw": {"fps": 12.0, "loop": false},
	"block": {"fps": 8.0, "loop": true},
	"hit_light": {"fps": 11.0, "loop": false},
	"hit_heavy": {"fps": 8.0, "loop": false},
	"hit": {"fps": 10.0, "loop": false},
	"fall": {"fps": 8.0, "loop": false},
	"getup": {"fps": 9.0, "loop": false},
	"ko": {"fps": 1.0, "loop": false}
}

const LOCAL_INPUT_ACTIONS := [
	"move_left",
	"move_right",
	"move_up",
	"move_down",
	"jump",
	"attack_light",
	"attack_heavy",
	"attack_special",
	"throw",
	"dash",
	"block"
]

const LOCAL_INPUT_PREFIX_BY_PLAYER_ID := {
	1: "p1",
	2: "p2"
}

const LOCAL_GAMEPAD_DEVICE_BY_PLAYER_ID := {
	1: 0,
	2: 1
}

const PLAYER2_LOCAL_KEYBOARD_LAYOUT := {
	"move_left": [KEY_F],
	"move_right": [KEY_G],
	"move_up": [KEY_T],
	"move_down": [KEY_V],
	"jump": [KEY_R],
	"attack_light": [KEY_N],
	"attack_heavy": [KEY_M],
	"attack_special": [KEY_COMMA],
	"throw": [KEY_PERIOD],
	"dash": [KEY_SLASH],
	"block": [KEY_B]
}

const ATTACK_DATA := {
	"light": {
		"startup": 0.06, "active": 0.09, "recovery": 0.16, "block_recovery": 0.19, "damage": 6, "hitstun": 0.12, "blockstun": 0.10,
		"cancel_on_hit": true, "cancel_on_block": true, "cancel_options": ["light", "heavy", "special"],
		"block_type": "mid", "air_blockable": true,
		"knockback_ground": Vector2(115, -36), "knockback_air": Vector2(88, -72),
		"hitbox_size_ground": Vector2(26, 18), "hitbox_size_air": Vector2(24, 16),
		"hitbox_offset_ground": Vector2(22, 0), "hitbox_offset_air": Vector2(20, -6)
	},
	"heavy": {
		"startup": 0.16, "active": 0.12, "recovery": 0.26, "block_recovery": 0.33, "damage": 13, "hitstun": 0.20, "blockstun": 0.16,
		"cancel_on_hit": true, "cancel_on_block": false, "cancel_options": ["special"],
		"block_type": "overhead", "air_blockable": true,
		"knockback_ground": Vector2(220, -95), "knockback_air": Vector2(170, -145),
		"hitbox_size_ground": Vector2(34, 20), "hitbox_size_air": Vector2(30, 18),
		"hitbox_offset_ground": Vector2(26, -2), "hitbox_offset_air": Vector2(24, -10)
	},
	"special": {
		"startup": 0.10, "active": 0.17, "recovery": 0.28, "block_recovery": 0.40, "damage": 16, "hitstun": 0.22, "blockstun": 0.19,
		"cancel_on_hit": false, "cancel_on_block": false, "cancel_options": [],
		"block_type": "low", "air_blockable": true,
		"lunge_speed": 350.0,
		"knockback_ground": Vector2(260, -70), "knockback_air": Vector2(220, -130),
		"hitbox_size_ground": Vector2(36, 20), "hitbox_size_air": Vector2(32, 18),
		"hitbox_offset_ground": Vector2(28, -2), "hitbox_offset_air": Vector2(26, -8)
	},
	"throw": {
		"startup": 0.08, "active": 0.08, "recovery": 0.22, "block_recovery": 0.22, "damage": 11, "hitstun": 0.24, "blockstun": 0.0,
		"cancel_on_hit": false, "cancel_on_block": false, "cancel_options": [],
		"block_type": "throw", "air_blockable": false, "throw_techable": true,
		"knockback_ground": Vector2(180, -155), "knockback_air": Vector2(130, -190),
		"hitbox_size_ground": Vector2(20, 16), "hitbox_size_air": Vector2(18, 14),
		"hitbox_offset_ground": Vector2(18, 0), "hitbox_offset_air": Vector2(18, -6)
	}
}

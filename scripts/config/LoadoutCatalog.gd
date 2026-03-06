extends RefCounted
class_name LoadoutCatalog

const CharacterCatalogStore := preload("res://scripts/config/CharacterCatalog.gd")
const GeneratedSkillProfilesStore := preload("res://scripts/player/GeneratedSkillProfiles.gd")

const LOADOUT_BUDGET_CAP := 10
const REQUIRED_LOADOUT_SLOTS := [
	"signature_a",
	"signature_b",
	"ultimate",
	"item",
	"passive"
]
const TAG_LIMITS := {
	"hard_cc": 1,
	"burst_mobility": 1,
	"high_chip": 1
}
const REQUIRED_TAGS := ["neutral_tool"]
const DEFAULT_PRESET_ID := "balanced"
const DEFAULT_CHARACTER_TUNING := {
	"signature_damage_multiplier": 1.0,
	"signature_cooldown_multiplier": 1.0,
	"ultimate_damage_multiplier": 1.0,
	"ultimate_cooldown_multiplier": 1.0,
	"item_core_trigger_delta": 0.0,
	"item_core_cooldown_delta": 0.0,
	"item_core_duration_delta": 0.0,
	"item_hype_trigger_delta": 0.0,
	"item_hype_cooldown_delta": 0.0,
	"item_hype_amount_delta": 0.0,
	"passive_startup_delta": 0.0,
	"passive_damage_delta": 0.0,
	"passive_chip_delta": 0.0
}
const WAVE1_CHARACTER_TUNING := {
	"elon_mvsk": {
		"signature_damage_multiplier": 1.06,
		"signature_cooldown_multiplier": 0.96,
		"ultimate_damage_multiplier": 1.02,
		"item_hype_trigger_delta": -1.0,
		"item_hype_amount_delta": 4.0
	},
	"mark_zuck": {
		"signature_damage_multiplier": 0.98,
		"signature_cooldown_multiplier": 1.04,
		"item_core_duration_delta": 0.6,
		"item_core_trigger_delta": -1.0,
		"passive_startup_delta": -0.02
	},
	"sam_altmyn": {
		"signature_damage_multiplier": 1.02,
		"ultimate_damage_multiplier": 1.08,
		"ultimate_cooldown_multiplier": 0.95,
		"item_core_cooldown_delta": -0.5,
		"passive_chip_delta": 0.01
	},
	"peter_thyell": {
		"signature_damage_multiplier": 0.97,
		"signature_cooldown_multiplier": 0.94,
		"item_hype_cooldown_delta": -0.6,
		"item_hype_amount_delta": 6.0,
		"passive_damage_delta": 0.01
	}
}

static var _character_pool_cache: Dictionary = {}
static var _character_move_name_cache: Dictionary = {}

static func get_budget_cap() -> int:
	return LOADOUT_BUDGET_CAP

static func get_required_loadout_slots() -> Array[String]:
	var slots: Array[String] = []
	for slot in REQUIRED_LOADOUT_SLOTS:
		slots.append(str(slot))
	return slots

static func get_tag_limits() -> Dictionary:
	return TAG_LIMITS.duplicate(true)

static func get_required_tags() -> PackedStringArray:
	var tags := PackedStringArray()
	for tag in REQUIRED_TAGS:
		tags.append(String(tag))
	return tags

static func get_wave1_character_tuning_profiles() -> Dictionary:
	return WAVE1_CHARACTER_TUNING.duplicate(true)

static func clear_cache() -> void:
	_character_pool_cache.clear()
	_character_move_name_cache.clear()

static func get_character_pool(character_id: String) -> Dictionary:
	var resolved_id := _resolve_character_id(character_id)
	if _character_pool_cache.has(resolved_id):
		return (_character_pool_cache[resolved_id] as Dictionary).duplicate(true)
	var profile := _resolve_generated_profile(resolved_id)
	var skills := _build_skill_defs(resolved_id, profile)
	var items := _build_item_defs(resolved_id)
	var passives := _build_passive_defs(resolved_id)
	var presets := _build_loadout_presets(resolved_id, skills, items, passives)
	var pool := {
		"character_id": resolved_id,
		"skills": skills,
		"items": items,
		"passives": passives,
		"presets": presets,
		"skill_by_id": _index_by_id(skills),
		"item_by_id": _index_by_id(items),
		"passive_by_id": _index_by_id(passives),
		"preset_by_id": _index_by_id(presets)
	}
	_character_pool_cache[resolved_id] = pool.duplicate(true)
	return pool

static func get_default_loadout(character_id: String) -> Dictionary:
	var pool := get_character_pool(character_id)
	var preset_by_id := pool.get("preset_by_id", {}) as Dictionary
	if preset_by_id.has(DEFAULT_PRESET_ID):
		var entry := preset_by_id.get(DEFAULT_PRESET_ID, {}) as Dictionary
		var loadout := entry.get("loadout", {}) as Dictionary
		return loadout.duplicate(true)
	var presets := pool.get("presets", []) as Array
	for preset in presets:
		if typeof(preset) != TYPE_DICTIONARY:
			continue
		var loadout := (preset as Dictionary).get("loadout", {}) as Dictionary
		if not loadout.is_empty():
			return loadout.duplicate(true)
	return {}

static func get_item_definition(character_id: String, item_id: String) -> Dictionary:
	if item_id.strip_edges() == "":
		return {}
	var pool := get_character_pool(character_id)
	var by_id := pool.get("item_by_id", {}) as Dictionary
	if not by_id.has(item_id):
		return {}
	return (by_id[item_id] as Dictionary).duplicate(true)

static func get_preset_options(character_id: String) -> Array[Dictionary]:
	var pool := get_character_pool(character_id)
	var options: Array[Dictionary] = []
	for preset in pool.get("presets", []):
		if typeof(preset) != TYPE_DICTIONARY:
			continue
		var entry := (preset as Dictionary).duplicate(true)
		var option := {
			"id": str(entry.get("id", "")),
			"display_name_key": str(entry.get("display_name_key", "")),
			"display_name_fallback": str(entry.get("display_name_fallback", "Preset")),
			"loadout": (entry.get("loadout", {}) as Dictionary).duplicate(true)
		}
		options.append(option)
	return options

static func _resolve_character_id(character_id: String) -> String:
	var normalized := character_id.strip_edges().to_lower()
	if normalized == "":
		return _resolve_fallback_character_id()
	for entry in CharacterCatalogStore.get_selectable_roster():
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var entry_id := str((entry as Dictionary).get("id", "")).to_lower()
		if entry_id == normalized:
			return entry_id
	return _resolve_fallback_character_id()

static func _resolve_fallback_character_id() -> String:
	var roster := CharacterCatalogStore.get_selectable_roster()
	if roster.is_empty():
		return "prototype_p1"
	var first := roster[0]
	if typeof(first) != TYPE_DICTIONARY:
		return "prototype_p1"
	return str((first as Dictionary).get("id", "prototype_p1")).strip_edges().to_lower()

static func _resolve_generated_profile(character_id: String) -> Dictionary:
	var profile := GeneratedSkillProfilesStore.get_profile(character_id)
	if profile.is_empty():
		profile = GeneratedSkillProfilesStore.get_profile("prototype")
	return profile

static func _build_skill_defs(character_id: String, profile: Dictionary) -> Array[Dictionary]:
	var signature_a := _read_profile_entry(profile, "signature_a")
	var signature_b := _read_profile_entry(profile, "signature_b")
	var ultimate := _read_profile_entry(profile, "ultimate")
	var move_names := _resolve_character_move_names(character_id)
	var tuning := _resolve_character_tuning(character_id)
	var signature_damage_multiplier := float(tuning.get("signature_damage_multiplier", 1.0))
	var signature_cooldown_multiplier := float(tuning.get("signature_cooldown_multiplier", 1.0))
	var ultimate_damage_multiplier := float(tuning.get("ultimate_damage_multiplier", 1.0))
	var ultimate_cooldown_multiplier := float(tuning.get("ultimate_cooldown_multiplier", 1.0))
	return [
		_build_skill_def(character_id, "signature_a", "core", 2, PackedStringArray(["neutral_tool"]), signature_a, 1.00 * signature_damage_multiplier, 1.00 * signature_cooldown_multiplier, str(move_names.get("signature_a", "Signature A")), "Core"),
		_build_skill_def(character_id, "signature_a", "burst", 2, PackedStringArray(["high_chip"]), signature_a, 1.12 * signature_damage_multiplier, 1.08 * signature_cooldown_multiplier, str(move_names.get("signature_a", "Signature A")), "Burst"),
		_build_skill_def(character_id, "signature_b", "mobility", 2, PackedStringArray(["burst_mobility"]), signature_b, 1.00 * signature_damage_multiplier, 0.96 * signature_cooldown_multiplier, str(move_names.get("signature_b", "Signature B")), "Mobility"),
		_build_skill_def(character_id, "signature_b", "control", 2, PackedStringArray(["hard_cc"]), signature_b, 0.92 * signature_damage_multiplier, 1.00 * signature_cooldown_multiplier, str(move_names.get("signature_b", "Signature B")), "Control"),
		_build_skill_def(character_id, "ultimate", "core", 2, PackedStringArray(["neutral_tool"]), ultimate, 1.00 * ultimate_damage_multiplier, 1.00 * ultimate_cooldown_multiplier, str(move_names.get("ultimate", "Ultimate")), "Core"),
		_build_skill_def(character_id, "ultimate", "overclock", 3, PackedStringArray(["neutral_tool"]), ultimate, 1.10 * ultimate_damage_multiplier, 1.10 * ultimate_cooldown_multiplier, str(move_names.get("ultimate", "Ultimate")), "Overclock")
	]

static func _build_skill_def(
	character_id: String,
	slot_key: String,
	variant: String,
	cost: int,
	tags: PackedStringArray,
	profile_entry: Dictionary,
	damage_scale_multiplier: float,
	cooldown_multiplier: float,
	base_name: String,
	variant_label: String
) -> Dictionary:
	var skill_id := "%s_%s_%s" % [character_id, slot_key, variant]
	var cooldown := maxf(0.35, float(profile_entry.get("cooldown", 1.6)) * cooldown_multiplier)
	var base_damage_scale := float(profile_entry.get("damage_scale", 0.62))
	var resolved_base_name := base_name.strip_edges()
	if resolved_base_name == "":
		resolved_base_name = _slot_fallback_name(slot_key)
	var display_name := "%s (%s)" % [resolved_base_name, variant_label]
	var attack_patch := {
		"damage_scale": clampf(base_damage_scale * damage_scale_multiplier, 0.35, 1.80),
		"cooldown": cooldown,
		"display_name": display_name
	}
	if profile_entry.has("effect"):
		var effect_value: Variant = profile_entry.get("effect", {})
		if typeof(effect_value) == TYPE_DICTIONARY:
			attack_patch["effect"] = (effect_value as Dictionary).duplicate(true)
	if profile_entry.has("control"):
		var control_value: Variant = profile_entry.get("control", {})
		if typeof(control_value) == TYPE_DICTIONARY:
			var control_patch := (control_value as Dictionary).duplicate(true)
			if tags.has("hard_cc"):
				control_patch["slow_seconds"] = maxf(float(control_patch.get("slow_seconds", 0.0)), 0.9)
				control_patch["slow_factor"] = minf(float(control_patch.get("slow_factor", 0.65)), 0.58)
			attack_patch["control"] = control_patch
	if slot_key == "signature_a" and tags.has("high_chip"):
		attack_patch["chip_bonus"] = 0.06
	return {
		"id": skill_id,
		"owner_character_id": character_id,
		"display_name_key": "",
		"display_name_fallback": display_name,
		"slot_type": "ultimate" if slot_key == "ultimate" else "signature",
		"slot_key": slot_key,
		"cost": cost,
		"tags": tags,
		"attack_entry_key": slot_key,
		"cooldown_seconds": cooldown,
		"attack_patch": attack_patch,
		"selectable": true
	}

static func _build_item_defs(character_id: String) -> Array[Dictionary]:
	var core_id := "%s_item_brand_core" % character_id
	var hype_id := "%s_item_hype_loop" % character_id
	var core_evolved_id := "%s_item_brand_core_plus" % character_id
	var hype_evolved_id := "%s_item_hype_loop_plus" % character_id
	var tuning := _resolve_character_tuning(character_id)
	var core_trigger_value := maxf(1.0, 3.0 + float(tuning.get("item_core_trigger_delta", 0.0)))
	var core_cooldown_seconds := maxf(0.0, 6.0 + float(tuning.get("item_core_cooldown_delta", 0.0)))
	var core_duration := maxf(0.8, 2.6 + float(tuning.get("item_core_duration_delta", 0.0)))
	var hype_trigger_value := maxf(1.0, 2.0 + float(tuning.get("item_hype_trigger_delta", 0.0)))
	var hype_cooldown_seconds := maxf(0.0, 5.0 + float(tuning.get("item_hype_cooldown_delta", 0.0)))
	var hype_amount := maxf(8.0, 24.0 + float(tuning.get("item_hype_amount_delta", 0.0)))
	return [
		{
			"id": core_id,
			"owner_character_id": character_id,
			"display_name_key": "",
			"display_name_fallback": "Brand Core",
			"cost": 2,
			"tags": PackedStringArray(["neutral_tool"]),
			"trigger_type": "hit_count",
			"trigger_value": core_trigger_value,
			"effect_type": "buff",
			"effect_payload": {
				"duration": core_duration,
				"damage_multiplier": 1.10,
				"speed_multiplier": 1.05,
				"startup_multiplier": 0.94
			},
			"max_charges": 2,
			"cooldown_seconds": core_cooldown_seconds,
			"evolution_id": core_evolved_id,
			"evolution_after_activations": 2,
			"round_tuning_options": [
				{
					"id": "quick_cycle",
					"display_name_key": "",
					"display_name_fallback": "Quick Cycle",
					"patch": {"cooldown_seconds_delta": -0.8}
				},
				{
					"id": "deep_cache",
					"display_name_key": "",
					"display_name_fallback": "Deep Cache",
					"patch": {"effect_payload_patch": {"duration": 0.8, "damage_multiplier": 0.04}}
				}
			],
			"selectable": true
		},
		{
			"id": hype_id,
			"owner_character_id": character_id,
			"display_name_key": "",
			"display_name_fallback": "Meme Loop",
			"cost": 3,
			"tags": PackedStringArray(["burst_mobility"]),
			"trigger_type": "block_count",
			"trigger_value": hype_trigger_value,
			"effect_type": "hype",
			"effect_payload": {"amount": hype_amount},
			"max_charges": 3,
			"cooldown_seconds": hype_cooldown_seconds,
			"evolution_id": hype_evolved_id,
			"evolution_after_activations": 2,
			"round_tuning_options": [
				{
					"id": "viral_spike",
					"display_name_key": "",
					"display_name_fallback": "Viral Spike",
					"patch": {"effect_payload_patch": {"amount": 8.0}}
				},
				{
					"id": "guard_cache",
					"display_name_key": "",
					"display_name_fallback": "Guard Cache",
					"patch": {"trigger_value_delta": -1.0}
				}
			],
			"selectable": true
		},
		{
			"id": core_evolved_id,
			"owner_character_id": character_id,
			"display_name_key": "",
			"display_name_fallback": "Brand Core+",
			"cost": 0,
			"tags": PackedStringArray(["neutral_tool"]),
			"trigger_type": "hit_count",
			"trigger_value": 2.0,
			"effect_type": "buff",
			"effect_payload": {
				"duration": 3.6,
				"damage_multiplier": 1.14,
				"speed_multiplier": 1.08,
				"startup_multiplier": 0.90,
				"chip_bonus": 0.04
			},
			"max_charges": 3,
			"cooldown_seconds": 5.0,
			"evolution_id": "",
			"round_tuning_options": [],
			"selectable": false
		},
		{
			"id": hype_evolved_id,
			"owner_character_id": character_id,
			"display_name_key": "",
			"display_name_fallback": "Meme Loop+",
			"cost": 0,
			"tags": PackedStringArray(["burst_mobility"]),
			"trigger_type": "block_count",
			"trigger_value": 1.0,
			"effect_type": "hype",
			"effect_payload": {"amount": 34.0},
			"max_charges": 4,
			"cooldown_seconds": 4.0,
			"evolution_id": "",
			"round_tuning_options": [],
			"selectable": false
		}
	]

static func _build_passive_defs(character_id: String) -> Array[Dictionary]:
	var tuning := _resolve_character_tuning(character_id)
	var stable_startup_multiplier := clampf(
		0.96 + float(tuning.get("passive_startup_delta", 0.0)),
		0.70,
		1.0
	)
	var pressure_damage_multiplier := maxf(
		1.0,
		1.06 + float(tuning.get("passive_damage_delta", 0.0))
	)
	var pressure_chip_bonus := maxf(0.0, 0.04 + float(tuning.get("passive_chip_delta", 0.0)))
	return [
		{
			"id": "%s_passive_stable_release" % character_id,
			"owner_character_id": character_id,
			"display_name_key": "",
			"display_name_fallback": "Stable Release",
			"cost": 1,
			"tags": PackedStringArray(["neutral_tool"]),
			"effect_type": "stat",
			"effect_payload": {
				"startup_multiplier": stable_startup_multiplier
			},
			"selectable": true
		},
		{
			"id": "%s_passive_pressure_stack" % character_id,
			"owner_character_id": character_id,
			"display_name_key": "",
			"display_name_fallback": "Pressure Stack",
			"cost": 2,
			"tags": PackedStringArray(["high_chip"]),
			"effect_type": "stat",
			"effect_payload": {
				"damage_multiplier": pressure_damage_multiplier,
				"chip_bonus": pressure_chip_bonus
			},
			"selectable": true
		}
	]

static func _build_loadout_presets(
	character_id: String,
	skills: Array[Dictionary],
	items: Array[Dictionary],
	passives: Array[Dictionary]
) -> Array[Dictionary]:
	var skill_by_id := _index_by_id(skills)
	var item_by_id := _index_by_id(items)
	var passive_by_id := _index_by_id(passives)
	var signature_a_core_id := "%s_signature_a_core" % character_id
	var signature_a_burst_id := "%s_signature_a_burst" % character_id
	var signature_b_mobility_id := "%s_signature_b_mobility" % character_id
	var signature_b_control_id := "%s_signature_b_control" % character_id
	var ultimate_core_id := "%s_ultimate_core" % character_id
	var ultimate_overclock_id := "%s_ultimate_overclock" % character_id
	var item_core_id := "%s_item_brand_core" % character_id
	var item_hype_id := "%s_item_hype_loop" % character_id
	var passive_stable_id := "%s_passive_stable_release" % character_id
	var passive_pressure_id := "%s_passive_pressure_stack" % character_id
	var presets := [
		_build_preset("balanced", "Balanced", {
			"character_id": character_id,
			"signature_a": signature_a_core_id,
			"signature_b": signature_b_mobility_id,
			"ultimate": ultimate_core_id,
			"item": item_core_id,
			"passive": passive_stable_id
		}),
		_build_preset("burst", "Burst", {
			"character_id": character_id,
			"signature_a": signature_a_burst_id,
			"signature_b": signature_b_mobility_id,
			"ultimate": ultimate_overclock_id,
			"item": item_core_id,
			"passive": passive_stable_id
		}),
		_build_preset("control", "Control", {
			"character_id": character_id,
			"signature_a": signature_a_core_id,
			"signature_b": signature_b_control_id,
			"ultimate": ultimate_core_id,
			"item": item_hype_id,
			"passive": passive_stable_id
		}),
		_build_preset("chip_pressure", "Chip Pressure", {
			"character_id": character_id,
			"signature_a": signature_a_burst_id,
			"signature_b": signature_b_control_id,
			"ultimate": ultimate_core_id,
			"item": item_core_id,
			"passive": passive_pressure_id
		})
	]
	var validated: Array[Dictionary] = []
	for preset in presets:
		if _preset_ids_exist(preset.get("loadout", {}) as Dictionary, skill_by_id, item_by_id, passive_by_id):
			validated.append((preset as Dictionary).duplicate(true))
	return validated

static func _build_preset(id_value: String, fallback_name: String, loadout: Dictionary) -> Dictionary:
	return {
		"id": id_value,
		"display_name_key": "",
		"display_name_fallback": fallback_name,
		"loadout": loadout.duplicate(true)
	}

static func _preset_ids_exist(
	loadout: Dictionary,
	skill_by_id: Dictionary,
	item_by_id: Dictionary,
	passive_by_id: Dictionary
) -> bool:
	if loadout.is_empty():
		return false
	var signature_a := str(loadout.get("signature_a", ""))
	var signature_b := str(loadout.get("signature_b", ""))
	var ultimate := str(loadout.get("ultimate", ""))
	var item := str(loadout.get("item", ""))
	var passive := str(loadout.get("passive", ""))
	return skill_by_id.has(signature_a) and skill_by_id.has(signature_b) and skill_by_id.has(ultimate) and item_by_id.has(item) and passive_by_id.has(passive)

static func _resolve_character_tuning(character_id: String) -> Dictionary:
	var merged := DEFAULT_CHARACTER_TUNING.duplicate(true)
	var override_value: Variant = WAVE1_CHARACTER_TUNING.get(character_id, {})
	if typeof(override_value) != TYPE_DICTIONARY:
		return merged
	var overrides := override_value as Dictionary
	for key in overrides.keys():
		merged[str(key)] = overrides[key]
	return merged

static func _read_profile_entry(profile: Dictionary, key: String) -> Dictionary:
	var value: Variant = profile.get(key, {})
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	return (value as Dictionary).duplicate(true)

static func _index_by_id(entries: Array) -> Dictionary:
	var by_id := {}
	for entry in entries:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var id_value := str((entry as Dictionary).get("id", ""))
		if id_value == "":
			continue
		by_id[id_value] = (entry as Dictionary).duplicate(true)
	return by_id

static func _resolve_character_move_names(character_id: String) -> Dictionary:
	if _character_move_name_cache.has(character_id):
		return (_character_move_name_cache[character_id] as Dictionary).duplicate(true)
	var names := {
		"signature_a": "Signature A",
		"signature_b": "Signature B",
		"signature_c": "Down Special",
		"ultimate": "Ultimate"
	}
	for entry in CharacterCatalogStore.get_selectable_roster():
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var character := entry as Dictionary
		if str(character.get("id", "")).strip_edges().to_lower() != character_id:
			continue
		var attack_table_path := str(character.get("attack_table_path", "")).strip_edges()
		if attack_table_path == "" or not ResourceLoader.exists(attack_table_path):
			break
		var resource := load(attack_table_path) as Resource
		if resource == null:
			break
		var attacks := _resolve_attacks(resource)
		names["signature_a"] = _resolve_attack_display_name(attacks, "signature_a", "signature_primary", "Signature A", resource)
		names["signature_b"] = _resolve_attack_display_name(attacks, "signature_b", "signature_alt", "Signature B", resource)
		names["signature_c"] = _resolve_attack_display_name(attacks, "signature_c", "signature_mix", "Down Special", resource)
		names["ultimate"] = _resolve_attack_display_name(attacks, "ultimate", "signature_ultimate", "Ultimate", resource)
		break
	_character_move_name_cache[character_id] = names.duplicate(true)
	return names

static func _resolve_attacks(resource: Resource) -> Dictionary:
	if resource == null:
		return {}
	if resource.has_method("get_runtime_attacks"):
		var attacks_value: Variant = resource.call("get_runtime_attacks")
		if typeof(attacks_value) == TYPE_DICTIONARY:
			return (attacks_value as Dictionary).duplicate(true)
	var raw_attacks: Variant = resource.get("attacks")
	if typeof(raw_attacks) == TYPE_DICTIONARY:
		return (raw_attacks as Dictionary).duplicate(true)
	return {}

static func _resolve_attack_display_name(
	attacks: Dictionary,
	attack_key: String,
	meta_key: String,
	fallback: String,
	resource: Resource
) -> String:
	var attack_value: Variant = attacks.get(attack_key, {})
	if typeof(attack_value) == TYPE_DICTIONARY:
		var attack_data := attack_value as Dictionary
		var explicit_name := str(attack_data.get("display_name", "")).strip_edges()
		if explicit_name != "":
			return explicit_name
	var special_value: Variant = attacks.get("special", {})
	if typeof(special_value) == TYPE_DICTIONARY:
		var special := special_value as Dictionary
		var special_name := str(special.get(meta_key, "")).strip_edges()
		if special_name != "":
			return special_name
	if resource != null:
		var meta_value: Variant = resource.get(meta_key)
		if typeof(meta_value) == TYPE_STRING or typeof(meta_value) == TYPE_STRING_NAME:
			var direct_name := str(meta_value).strip_edges()
			if direct_name != "":
				return direct_name
	return fallback

static func _slot_fallback_name(slot_key: String) -> String:
	match slot_key:
		"signature_a":
			return "Signature A"
		"signature_b":
			return "Signature B"
		"ultimate":
			return "Ultimate"
		_:
			return "Skill"

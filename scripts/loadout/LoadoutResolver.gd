extends RefCounted
class_name LoadoutResolver

const LoadoutCatalogStore := preload("res://scripts/config/LoadoutCatalog.gd")
const LoadoutValidatorStore := preload("res://scripts/loadout/LoadoutValidator.gd")

static func resolve_character_loadout(character_id: String, requested_loadout: Dictionary) -> Dictionary:
	var pool := LoadoutCatalogStore.get_character_pool(character_id)
	var normalized_character_id := str(pool.get("character_id", ""))
	var requested := requested_loadout.duplicate(true)
	if requested.is_empty():
		requested = LoadoutCatalogStore.get_default_loadout(normalized_character_id)
	var requested_validation := LoadoutValidatorStore.validate_loadout(normalized_character_id, requested)
	var validation := requested_validation.duplicate(true)
	var selected_loadout := requested
	var used_fallback := false
	if not bool(requested_validation.get("is_valid", false)):
		selected_loadout = LoadoutCatalogStore.get_default_loadout(normalized_character_id)
		validation = LoadoutValidatorStore.validate_loadout(normalized_character_id, selected_loadout)
		used_fallback = true
	var resolved := validation.get("resolved", {}) as Dictionary
	var skills := (resolved.get("skills", {}) as Dictionary).duplicate(true)
	var item := (resolved.get("item", {}) as Dictionary).duplicate(true)
	var passive := (resolved.get("passive", {}) as Dictionary).duplicate(true)
	var attack_overrides := _build_attack_overrides(skills)
	var item_runtime := _build_item_runtime(item)
	var passive_runtime := _build_passive_runtime(passive)
	return {
		"character_id": normalized_character_id,
		"loadout": selected_loadout.duplicate(true),
		"used_fallback": used_fallback,
		"requested_validation": requested_validation.duplicate(true),
		"validation": validation.duplicate(true),
		"attack_overrides": attack_overrides,
		"item_runtime": item_runtime,
		"passive_runtime": passive_runtime,
		"summary": _build_summary(skills, item, passive, validation, used_fallback)
	}

static func build_item_runtime_from_definition(character_id: String, item_id: String) -> Dictionary:
	var item_def := LoadoutCatalogStore.get_item_definition(character_id, item_id)
	if item_def.is_empty():
		return {}
	return _build_item_runtime(item_def)

static func _build_attack_overrides(skills: Dictionary) -> Dictionary:
	var overrides := {}
	for slot_key in ["signature_a", "signature_b", "ultimate"]:
		var entry_value: Variant = skills.get(slot_key, {})
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue
		var entry := entry_value as Dictionary
		var patch_value: Variant = entry.get("attack_patch", {})
		if typeof(patch_value) != TYPE_DICTIONARY:
			continue
		var attack_patch := (patch_value as Dictionary).duplicate(true)
		attack_patch["attack_entry_key"] = str(entry.get("attack_entry_key", slot_key))
		attack_patch["definition_id"] = str(entry.get("id", ""))
		attack_patch["slot_key"] = slot_key
		overrides[slot_key] = attack_patch
	return overrides

static func _build_item_runtime(item_entry: Dictionary) -> Dictionary:
	if item_entry.is_empty():
		return {}
	return {
		"id": str(item_entry.get("id", "")),
		"owner_character_id": str(item_entry.get("owner_character_id", "")),
		"display_name_fallback": str(item_entry.get("display_name_fallback", "Item")),
		"trigger_type": str(item_entry.get("trigger_type", "")),
		"trigger_value": maxf(1.0, float(item_entry.get("trigger_value", 1.0))),
		"effect_type": str(item_entry.get("effect_type", "")),
		"effect_payload": (item_entry.get("effect_payload", {}) as Dictionary).duplicate(true),
		"cooldown_seconds": maxf(0.0, float(item_entry.get("cooldown_seconds", 0.0))),
		"cooldown_remaining": 0.0,
		"max_charges": maxi(1, int(item_entry.get("max_charges", 1))),
		"charges_remaining": maxi(1, int(item_entry.get("max_charges", 1))),
		"activation_count": 0,
		"trigger_progress": 0.0,
		"evolution_id": str(item_entry.get("evolution_id", "")),
		"evolution_after_activations": maxi(1, int(item_entry.get("evolution_after_activations", 2))),
		"round_tuning_options": (item_entry.get("round_tuning_options", []) as Array).duplicate(true)
	}

static func _build_passive_runtime(passive_entry: Dictionary) -> Dictionary:
	if passive_entry.is_empty():
		return {}
	return {
		"id": str(passive_entry.get("id", "")),
		"effect_type": str(passive_entry.get("effect_type", "")),
		"effect_payload": (passive_entry.get("effect_payload", {}) as Dictionary).duplicate(true)
	}

static func _build_summary(
	skills: Dictionary,
	item: Dictionary,
	passive: Dictionary,
	validation: Dictionary,
	used_fallback: bool
) -> Dictionary:
	return {
		"signature_a": str((skills.get("signature_a", {}) as Dictionary).get("display_name_fallback", "Signature A")),
		"signature_b": str((skills.get("signature_b", {}) as Dictionary).get("display_name_fallback", "Signature B")),
		"ultimate": str((skills.get("ultimate", {}) as Dictionary).get("display_name_fallback", "Ultimate")),
		"item": str(item.get("display_name_fallback", "Item")),
		"passive": str(passive.get("display_name_fallback", "Passive")),
		"total_cost": int(validation.get("total_cost", 0)),
		"budget_cap": int(validation.get("budget_cap", 0)),
		"is_valid": bool(validation.get("is_valid", false)),
		"used_fallback": used_fallback
	}

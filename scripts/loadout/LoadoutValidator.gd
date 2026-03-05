extends RefCounted
class_name LoadoutValidator

const LoadoutCatalogStore := preload("res://scripts/config/LoadoutCatalog.gd")

static func validate_loadout(character_id: String, loadout: Dictionary) -> Dictionary:
	var pool := LoadoutCatalogStore.get_character_pool(character_id)
	var normalized_character_id := str(pool.get("character_id", "")).strip_edges().to_lower()
	var errors: Array[String] = []
	var resolved := {
		"skills": {},
		"item": {},
		"passive": {}
	}
	var total_cost := 0
	var tag_counts := {}
	var required_slots := LoadoutCatalogStore.get_required_loadout_slots()
	for required_slot in required_slots:
		if not loadout.has(required_slot):
			errors.append("missing_slot:%s" % required_slot)
	var skill_by_id := pool.get("skill_by_id", {}) as Dictionary
	var item_by_id := pool.get("item_by_id", {}) as Dictionary
	var passive_by_id := pool.get("passive_by_id", {}) as Dictionary

	var signature_a_id := str(loadout.get("signature_a", ""))
	var signature_b_id := str(loadout.get("signature_b", ""))
	var ultimate_id := str(loadout.get("ultimate", ""))
	var item_id := str(loadout.get("item", ""))
	var passive_id := str(loadout.get("passive", ""))

	_validate_skill_slot("signature_a", signature_a_id, "signature", "signature_a", normalized_character_id, skill_by_id, resolved, errors)
	_validate_skill_slot("signature_b", signature_b_id, "signature", "signature_b", normalized_character_id, skill_by_id, resolved, errors)
	_validate_skill_slot("ultimate", ultimate_id, "ultimate", "ultimate", normalized_character_id, skill_by_id, resolved, errors)
	_validate_item_slot(item_id, normalized_character_id, item_by_id, resolved, errors)
	_validate_passive_slot(passive_id, normalized_character_id, passive_by_id, resolved, errors)

	var all_entries: Array = []
	for key in ["signature_a", "signature_b", "ultimate"]:
		var value: Variant = (resolved.get("skills", {}) as Dictionary).get(key, {})
		if typeof(value) == TYPE_DICTIONARY and not (value as Dictionary).is_empty():
			all_entries.append((value as Dictionary).duplicate(true))
	var item_entry := resolved.get("item", {}) as Dictionary
	if not item_entry.is_empty():
		all_entries.append(item_entry.duplicate(true))
	var passive_entry := resolved.get("passive", {}) as Dictionary
	if not passive_entry.is_empty():
		all_entries.append(passive_entry.duplicate(true))

	for entry_variant in all_entries:
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry := entry_variant as Dictionary
		total_cost += int(entry.get("cost", 0))
		var tags_value: Variant = entry.get("tags", PackedStringArray())
		if tags_value is PackedStringArray:
			for tag in tags_value:
				var key := String(tag)
				tag_counts[key] = int(tag_counts.get(key, 0)) + 1
		elif typeof(tags_value) == TYPE_ARRAY:
			for tag_variant in tags_value:
				var key := str(tag_variant)
				tag_counts[key] = int(tag_counts.get(key, 0)) + 1

	var budget_cap := LoadoutCatalogStore.get_budget_cap()
	if total_cost > budget_cap:
		errors.append("budget_exceeded:%d>%d" % [total_cost, budget_cap])

	var tag_limits := LoadoutCatalogStore.get_tag_limits()
	for tag in tag_limits.keys():
		var count := int(tag_counts.get(tag, 0))
		var limit := int(tag_limits.get(tag, 0))
		if limit >= 0 and count > limit:
			errors.append("tag_limit:%s:%d>%d" % [str(tag), count, limit])

	var required_tags := LoadoutCatalogStore.get_required_tags()
	for required_tag in required_tags:
		if int(tag_counts.get(String(required_tag), 0)) <= 0:
			errors.append("required_tag_missing:%s" % String(required_tag))

	return {
		"is_valid": errors.is_empty(),
		"errors": errors,
		"character_id": normalized_character_id,
		"total_cost": total_cost,
		"budget_cap": budget_cap,
		"tag_counts": tag_counts.duplicate(true),
		"resolved": {
			"skills": (resolved.get("skills", {}) as Dictionary).duplicate(true),
			"item": (resolved.get("item", {}) as Dictionary).duplicate(true),
			"passive": (resolved.get("passive", {}) as Dictionary).duplicate(true)
		}
	}

static func sanitize_or_default_loadout(character_id: String, requested_loadout: Dictionary) -> Dictionary:
	var validation := validate_loadout(character_id, requested_loadout)
	if bool(validation.get("is_valid", false)):
		return requested_loadout.duplicate(true)
	return LoadoutCatalogStore.get_default_loadout(character_id)

static func _validate_skill_slot(
	slot_key: String,
	skill_id: String,
	expected_slot_type: String,
	expected_attack_key: String,
	expected_owner_id: String,
	skill_by_id: Dictionary,
	resolved: Dictionary,
	errors: Array[String]
) -> void:
	if skill_id.strip_edges() == "":
		errors.append("missing_skill:%s" % slot_key)
		return
	if not skill_by_id.has(skill_id):
		errors.append("unknown_skill:%s" % skill_id)
		return
	var entry := (skill_by_id[skill_id] as Dictionary).duplicate(true)
	if not bool(entry.get("selectable", true)):
		errors.append("skill_not_selectable:%s" % skill_id)
		return
	if str(entry.get("owner_character_id", "")).to_lower() != expected_owner_id:
		errors.append("skill_owner_mismatch:%s" % skill_id)
		return
	if str(entry.get("slot_type", "")) != expected_slot_type:
		errors.append("skill_slot_type_mismatch:%s" % skill_id)
		return
	if str(entry.get("attack_entry_key", "")) != expected_attack_key:
		errors.append("skill_slot_key_mismatch:%s" % skill_id)
		return
	var skills := resolved.get("skills", {}) as Dictionary
	skills[slot_key] = entry
	resolved["skills"] = skills

static func _validate_item_slot(
	item_id: String,
	expected_owner_id: String,
	item_by_id: Dictionary,
	resolved: Dictionary,
	errors: Array[String]
) -> void:
	if item_id.strip_edges() == "":
		errors.append("missing_item")
		return
	if not item_by_id.has(item_id):
		errors.append("unknown_item:%s" % item_id)
		return
	var entry := (item_by_id[item_id] as Dictionary).duplicate(true)
	if not bool(entry.get("selectable", true)):
		errors.append("item_not_selectable:%s" % item_id)
		return
	if str(entry.get("owner_character_id", "")).to_lower() != expected_owner_id:
		errors.append("item_owner_mismatch:%s" % item_id)
		return
	resolved["item"] = entry

static func _validate_passive_slot(
	passive_id: String,
	expected_owner_id: String,
	passive_by_id: Dictionary,
	resolved: Dictionary,
	errors: Array[String]
) -> void:
	if passive_id.strip_edges() == "":
		errors.append("missing_passive")
		return
	if not passive_by_id.has(passive_id):
		errors.append("unknown_passive:%s" % passive_id)
		return
	var entry := (passive_by_id[passive_id] as Dictionary).duplicate(true)
	if not bool(entry.get("selectable", true)):
		errors.append("passive_not_selectable:%s" % passive_id)
		return
	if str(entry.get("owner_character_id", "")).to_lower() != expected_owner_id:
		errors.append("passive_owner_mismatch:%s" % passive_id)
		return
	resolved["passive"] = entry

extends RefCounted
class_name RoundTuningEngine

static func get_round_tuning_options(item_runtime: Dictionary) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	if item_runtime.is_empty():
		return options
	var option_values: Variant = item_runtime.get("round_tuning_options", [])
	if typeof(option_values) != TYPE_ARRAY:
		return options
	for option_variant in option_values:
		if typeof(option_variant) != TYPE_DICTIONARY:
			continue
		var option := (option_variant as Dictionary).duplicate(true)
		if str(option.get("id", "")).strip_edges() == "":
			continue
		options.append(option)
		if options.size() >= 2:
			break
	return options

static func apply_round_tuning_option(item_runtime: Dictionary, option_id: String) -> Dictionary:
	var updated := item_runtime.duplicate(true)
	if updated.is_empty():
		return updated
	for option in get_round_tuning_options(updated):
		if str(option.get("id", "")) != option_id:
			continue
		var patch_value: Variant = option.get("patch", {})
		if typeof(patch_value) != TYPE_DICTIONARY:
			return updated
		var patch := patch_value as Dictionary
		_apply_patch(updated, patch)
		return updated
	return updated

static func _apply_patch(item_runtime: Dictionary, patch: Dictionary) -> void:
	if patch.has("cooldown_seconds_delta"):
		item_runtime["cooldown_seconds"] = maxf(
			0.0,
			float(item_runtime.get("cooldown_seconds", 0.0)) + float(patch.get("cooldown_seconds_delta", 0.0))
		)
	if patch.has("trigger_value_delta"):
		item_runtime["trigger_value"] = maxf(
			1.0,
			float(item_runtime.get("trigger_value", 1.0)) + float(patch.get("trigger_value_delta", 0.0))
		)
	if patch.has("max_charges_delta"):
		var previous_max_charges := maxi(1, int(item_runtime.get("max_charges", 1)))
		var previous_remaining := clampi(int(item_runtime.get("charges_remaining", previous_max_charges)), 0, previous_max_charges)
		var delta_charges := int(patch.get("max_charges_delta", 0))
		var updated_max_charges := maxi(1, previous_max_charges + delta_charges)
		item_runtime["max_charges"] = updated_max_charges
		if delta_charges > 0:
			item_runtime["charges_remaining"] = mini(updated_max_charges, previous_remaining + delta_charges)
		else:
			item_runtime["charges_remaining"] = mini(previous_remaining, updated_max_charges)
	if patch.has("effect_payload_patch"):
		var payload_value: Variant = item_runtime.get("effect_payload", {})
		var payload: Dictionary = {}
		if typeof(payload_value) == TYPE_DICTIONARY:
			payload = (payload_value as Dictionary).duplicate(true)
		var payload_patch_value: Variant = patch.get("effect_payload_patch", {})
		if typeof(payload_patch_value) == TYPE_DICTIONARY:
			var payload_patch := payload_patch_value as Dictionary
			for key in payload_patch.keys():
				var current_value: Variant = payload.get(key, 0.0)
				var delta_value: Variant = payload_patch[key]
				if current_value is int or current_value is float:
					payload[key] = float(current_value) + float(delta_value)
				else:
					payload[key] = delta_value
		item_runtime["effect_payload"] = payload

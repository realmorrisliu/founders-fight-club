extends Resource
class_name AttackTable

@export var character_id := "prototype"
@export var display_name := "Prototype"
@export var archetype_key := "all_rounder"
@export var signature_primary := ""
@export var signature_alt := ""
@export var signature_mix := ""
@export var signature_ultimate := ""
@export var attacks: Dictionary = {}

func get_runtime_attacks() -> Dictionary:
	var result := {}
	for key in attacks.keys():
		var attack_key := str(key)
		var entry: Variant = attacks[key]
		if typeof(entry) == TYPE_DICTIONARY:
			result[attack_key] = (entry as Dictionary).duplicate(true)
	return result

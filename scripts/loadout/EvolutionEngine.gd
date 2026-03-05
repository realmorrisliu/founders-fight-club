extends RefCounted
class_name EvolutionEngine

const LoadoutResolverStore := preload("res://scripts/loadout/LoadoutResolver.gd")

static func maybe_evolve_item(character_id: String, item_runtime: Dictionary) -> Dictionary:
	if item_runtime.is_empty():
		return {
			"evolved": false,
			"item_runtime": {}
		}
	var evolution_id := str(item_runtime.get("evolution_id", "")).strip_edges()
	if evolution_id == "":
		return {
			"evolved": false,
			"item_runtime": item_runtime.duplicate(true)
		}
	var activation_count := int(item_runtime.get("activation_count", 0))
	var required_activations := maxi(1, int(item_runtime.get("evolution_after_activations", 2)))
	if activation_count < required_activations:
		return {
			"evolved": false,
			"item_runtime": item_runtime.duplicate(true)
		}
	var evolved_runtime := LoadoutResolverStore.build_item_runtime_from_definition(character_id, evolution_id)
	if evolved_runtime.is_empty():
		return {
			"evolved": false,
			"item_runtime": item_runtime.duplicate(true)
		}
	return {
		"evolved": true,
		"item_runtime": evolved_runtime
	}

extends Resource
class_name ItemDef

@export var id := ""
@export var owner_character_id := ""
@export var display_name_key := ""
@export var cost := 0
@export var tags: PackedStringArray = PackedStringArray()
@export var trigger_type := ""
@export var trigger_value := 0.0
@export var effect_type := ""
@export var effect_payload := {}
@export var max_charges := 1
@export var cooldown_seconds := 0.0
@export var evolution_id := ""
@export var round_tuning_options: Array[Dictionary] = []

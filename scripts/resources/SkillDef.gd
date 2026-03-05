extends Resource
class_name SkillDef

@export var id := ""
@export var owner_character_id := ""
@export var display_name_key := ""
@export_enum("signature", "ultimate") var slot_type := "signature"
@export var cost := 0
@export var tags: PackedStringArray = PackedStringArray()
@export var attack_entry_key := ""
@export var cooldown_seconds := 0.0
@export var evolution_id := ""
@export var notes := ""

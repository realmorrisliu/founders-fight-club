extends Node
class_name CombatSystem

func apply_hit(target: Node, damage: int) -> void:
	if target == null:
		return
	if target.has_method("apply_damage"):
		target.apply_damage(damage)

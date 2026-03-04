extends RefCounted
class_name SessionState

static var _values: Dictionary = {}

static func set_value(key: String, value: Variant) -> void:
	_values[key] = value

static func get_value(key: String, fallback: Variant = null) -> Variant:
	return _values.get(key, fallback)

static func has_value(key: String) -> bool:
	return _values.has(key)

static func clear_keys(keys: PackedStringArray = PackedStringArray()) -> void:
	if keys.is_empty():
		_values.clear()
		return
	for key in keys:
		_values.erase(String(key))

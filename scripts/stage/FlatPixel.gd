extends RefCounted

static func apply(match_root: Node) -> void:
	if match_root == null:
		return
	var arena := match_root.get_node_or_null("Arena")
	if arena != null and arena.has_method("enable_flat_pixels"):
		arena.call("enable_flat_pixels")

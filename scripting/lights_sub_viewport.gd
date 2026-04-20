extends SubViewportContainer

func is_in_circle(loc: Vector2) -> bool:
		var radius = self.size.x / 2;
		var center = self.size / 2;
		return center.distance_to(loc) / radius > 1.0

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if is_in_circle(event.position):
			event.canceled = true

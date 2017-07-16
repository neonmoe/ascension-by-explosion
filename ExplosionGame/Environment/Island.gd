extends Spatial

func _on_falling_body_enter(body):
	body.translate(Vector3(0, 150, 0))
	var direction = -body.get_global_transform().origin
	direction.y = 0
	body.apply_impulse(Vector3(), direction)

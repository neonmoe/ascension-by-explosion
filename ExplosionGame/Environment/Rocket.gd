extends Spatial

export var flying_speed = 50
export var explosion_force = 500
var direction
var explodables = []

func init(pos, forward):
	get_node("RigidBody").apply_impulse(Vector3(), forward * flying_speed)
	get_node("RigidBody").look_at(forward, Vector3(0, 1, 0))
	get_node("RigidBody").set_translation(pos)
	direction = forward
	set_fixed_process(true)

func _fixed_process(delta):
	var bodies = get_node("RigidBody").get_colliding_bodies()
	if (bodies.size() > 0):
		var body = bodies[0]
		print("Bonk! (", body.get_path(), ")")
		print("Explodables: ", explodables)
		for explodable_body in explodables:
			var direction = explodable_body.get_global_transform().origin - get_node("RigidBody").get_global_transform().origin
			var distance = direction.length()
			explodable_body.apply_impulse(Vector3(), direction.normalized() * explosion_force / clamp(distance * distance / 30, 1, 100))
			print("Distance: ", distance)
		queue_free()


func _on_explosion_body_enter(body):
	if (body extends RigidBody):
		explodables.append(body)

func _on_explosion_body_exit(body):
	if (body extends RigidBody):
		explodables.remove(explodables.find(body))
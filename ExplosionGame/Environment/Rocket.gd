extends Spatial

export var flying_speed = 50
export var explosion_force = 500
var direction
var explodables = []
var damage
var explosion = load("res://ExplosionGame/Environment/Explosion.tscn")

func init(pos, forward, dmg):
	get_node("RigidBody").apply_impulse(Vector3(), forward * flying_speed)
	get_node("RigidBody").look_at(forward, Vector3(0, 1, 0))
	get_node("RigidBody").set_translation(pos)
	direction = forward
	damage = dmg
	set_fixed_process(true)

func _fixed_process(delta):
	var bodies = get_node("RigidBody").get_colliding_bodies()
	if ((bodies.size() > 0 && bodies[0].get_path().get_name(bodies[0].get_path().get_name_count() - 2) != "Player") ||
		Input.is_action_pressed("detonate")):
		for explodable_body in explodables:
			var parent = explodable_body.get_parent()
			if (parent.get_name().find("Enemy") != -1):
				parent.take_damage(damage)
			var direction = explodable_body.get_global_transform().origin - get_node("RigidBody").get_global_transform().origin
			var distance = direction.length()
			explodable_body.apply_impulse(Vector3(), direction.normalized() * explosion_force / clamp(distance * distance / 30, 1, 100))
		var smoke = explosion.instance()
		smoke.set_translation(get_node("RigidBody").get_global_transform().origin)
		get_node("../").add_child(smoke)
		smoke.init(damage)
		queue_free()

func _on_explosion_body_enter(body):
	if (body extends RigidBody):
		explodables.append(body)

func _on_explosion_body_exit(body):
	if (body extends RigidBody):
		explodables.remove(explodables.find(body))

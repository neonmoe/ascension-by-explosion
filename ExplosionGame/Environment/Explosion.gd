extends Spatial

var explosion = load("res://ExplosionGame/FX/Explosion/Explosion.scn")

var time = 0
var explosions = []

func _ready():
	set_fixed_process(true)

func init(explosivity):
	var n = 3 + round(randf() * explosivity)
	for i in range(0, n):
		var spawn = explosion.instance()
		add_child(spawn)
		spawn.set_scale(Vector3(0.8 + randf() * 0.4, 0.8 + randf() * 0.4, 0.8 + randf() * 0.4))
		spawn.set_translation(Vector3(randf() * 3 - 1.5, randf() * 0.5, randf() * 3 - 1.5))
		explosions.append(spawn)

func _fixed_process(delta):
	if (time == 0):
		get_node("Player").play("Explosion")
	time += delta
	if (time >= 2):
		queue_free()
		return
	for e in explosions:
		if (time < 1):
			e.set_scale(e.get_scale() * (1 + (1 - time) / 25))
		else:
			e.set_scale(e.get_scale() * 0.93)
	
	
	
extends Spatial

var explosion = load("res://ExplosionGame/FX/Explosion/Explosion.scn")

var time = 0
var explosions = []

func _ready():
	set_process(true)

func init(explosivity):
	var n = 3 + round(randf() * explosivity)
	for i in range(0, n):
		var spawn = explosion.instance()
		spawn.set_scale(Vector3(0.8 + randf() * 0.4, 0.8 + randf() * 0.4, 0.8 + randf() * 0.4))
		spawn.set_translation(get_global_transform().origin + Vector3(randf() * 3 - 1.5, randf() * 0.5, randf() * 3 - 1.5))
		explosions.append(spawn)
		add_child(spawn)
	get_node("Player").play("Explosion")

func _process(delta):
	time += delta
	if (time >= 2):
		queue_free()
		return
	for e in explosions:
		if (time < 1):
			e.set_scale(e.get_scale() * (1 + (1 - time) / 25))
		else:
			e.set_scale(e.get_scale() * 0.93)
	
	
	
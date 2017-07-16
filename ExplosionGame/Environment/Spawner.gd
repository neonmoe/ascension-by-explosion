extends Spatial

var enemies_per_wave = 4
var enemies_per_second = 0.5
var enemy = load("res://ExplosionGame/Environment/Enemy.tscn")
var spawned = []

var timer = 0
var last_spawn_time = 0
var state = 0

func _ready():
	set_process(true)

func _process(delta):
	timer += delta
	if (state == 0 && timer > 1):
		get_node("../SpawnGate").open()
		state = 1
	if (state == 1 && spawned.size() >= enemies_per_wave):
		get_node("../SpawnGate").close()
		state = 2
	if (timer - last_spawn_time > 1.0 / enemies_per_second && spawned.size() < enemies_per_wave):
		var spawn = enemy.instance()
		var pos = Vector3(10, 0, 10) * (randf() * 2 - 1) + get_global_transform().origin
		var player = get_node("/root/WorldRoot/Player/Body")
		var player_pos = player.get_global_transform().origin
		while ((pos - player_pos).length() < 3):
			pos = Vector3(10, 0, 10) * (randf() * 2 - 1) + get_global_transform().origin
		spawn.set_position(pos)
		spawned.append(spawn)
		add_child(spawn)
		last_spawn_time = timer

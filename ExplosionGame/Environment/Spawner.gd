extends Spatial

export var enemies_count = 10
export var enemy_spawn_rate_per_second = 0.3
var enemy = load("res://ExplosionGame/Environment/Enemy.tscn")
var spawned = []

var timer = 0
var last_spawn_time = 0

func _ready():
	set_process(true)

func _process(delta):
	timer += delta
	if (timer - last_spawn_time > 1.0 / enemy_spawn_rate_per_second && spawned.size() < enemies_count):
		var spawn = enemy.instance()
		var pos = Vector3(10, 0, 10) * (randf() * 2 - 1) + get_global_transform().origin
		var player = get_node("/root/WorldRoot/Player/Body")
		var player_pos = player.get_global_transform().origin
		while ((pos - player_pos).length() < 3):
			pos = Vector3(10, 0, 10) * (randf() * 2 - 1) + get_global_transform().origin
		spawn.set_position(pos)
		print("Spawned at ", pos, "!")
		spawned.append(spawn)
		add_child(spawn)
		last_spawn_time = timer

extends Spatial

var enemies_per_wave = 4
var enemies_per_second = 0.5
var enemies_points_scale = 0
var enemies_points_mobility = 0
var enemies_points_intelligence = 0
var enemy = load("res://ExplosionGame/Environment/Enemy.tscn")
var spawned = []

var scl_points = [0, 1, 1, 2]
var mob_points = [0, 0, 1, 1, 1, 2]
var int_points = [0, 0, 0, 0, 1, 1, 2]
var current_wave = 0

var time = 0
var last_spawn_time = -1
var wave_start_time = 6

func _ready():
	set_process(true)

func _process(delta):
	time += delta
	var time_until_wave = wave_start_time - time
	get_node("../WaveStartLabel").set_hidden(true)
	if (time_until_wave < 0 # Wave has started
		&& time - last_spawn_time > 1.0 / enemies_per_second): # Last enemy cooldown is done
		var someone_alive = false
		for s in spawned:
			var wr = weakref(s)
			if (wr.get_ref()):
				someone_alive = true
		if (spawned.size() < enemies_per_wave): # There are enemies left in the wave
			var spawn = enemy.instance()
			spawn.add_xp(enemies_points_scale, enemies_points_mobility, enemies_points_intelligence)
			spawn.construct()
			var pos = Vector3(15, 0, 15) * (randf() * 2 - 1) + get_global_transform().origin
			var player = get_node("/root/WorldRoot/Player/Body")
			var player_pos = player.get_global_transform().origin
			while ((pos - player_pos).length() < 3):
				pos = Vector3(10, 0, 10) * (randf() * 2 - 1) + get_global_transform().origin
			spawn.set_position(pos)
			spawned.append(spawn)
			add_child(spawn)
			last_spawn_time = time
		elif (someone_alive # No enemies left in wave, next
				|| time_until_wave < -(10 + 3 * enemies_per_second * enemies_per_wave)): # Or too slow!
			spawned.clear()
			current_wave += 1
			wave_start_time = time + 3
			enemies_per_second *= 1.1
			enemies_per_wave *= 1.3
			if (scl_points.size() > current_wave): enemies_points_scale = scl_points[current_wave]
			if (mob_points.size() > current_wave): enemies_points_mobility = mob_points[current_wave]
			if (int_points.size() > current_wave): enemies_points_intelligence = int_points[current_wave]
	elif (time_until_wave > 0 && time_until_wave < 5):
		get_node("../WaveStartLabel").set_hidden(false)
		get_node("../WaveStartLabel").set_text("Wave starting in " + str(round(time_until_wave)) + "...")

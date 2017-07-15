extends Spatial

export var DEATH_ANIM_LENGTH_IN_SECONDS = 0.5
export var CHARGER_SLEEP_SECONDS = 5

# All these values are configurable between 0-2
var scale = 0
var mobility = 0
var intelligence = 0

var roller = load("res://ExplosionGame/Environment/Roller/Roller.scn")
var jumper = load("res://ExplosionGame/Environment/Jumper/Jumper.scn")
var flier = load("res://ExplosionGame/Environment/Flier/Flier.scn")

var movement = Vector3()
var movement_speed = 4
var jumped = false
var grounded = false
var death_anim_timer = -1
var health = 1
var sleeping_time = 0

func _ready():
	add_xp(randf() * randf() * 10)
	construct()
	set_process(true)
	set_fixed_process(true)

func set_position(pos):
	get_node("Body").set_translation(pos + Vector3(0, 3, 0))

func add_xp(xp):
	var points = xp
	var sx = randf()
	var mx = randf()
	var ix = randf()
	var total = sx + mx + ix
	sx /= total
	mx /= total
	ix /= total
	scale = 1#min(2, round(sx * points))
	mobility = 1#min(2, round(mx * points))
	intelligence = 0#min(2, round(ix * points))

func construct():
	health += scale * scale
	movement_speed = 6 / (scale + 1)
	var spawn
	if (mobility == 0):
		spawn = roller.instance()
	if (mobility == 1):
		spawn = jumper.instance()
	if (mobility == 2):
		spawn = flier.instance()
		get_node("Body").set_gravity_scale(0.2)
	if (intelligence == 1):
		sleeping_time = CHARGER_SLEEP_SECONDS
		movement_speed = 20
	get_node("Body").add_child(spawn)

func take_damage(dmg):
	health -= dmg
	if (health <= 0 && death_anim_timer == -1):
		death_anim_timer = DEATH_ANIM_LENGTH_IN_SECONDS

func _process(delta):
	var player = get_node("/root/WorldRoot/Player/Body")
	var player_pos = player.get_global_transform().origin
	var player_direction = (player_pos - get_node("Body").get_global_transform().origin).normalized()
	var player_look_direction = get_node("/root/WorldRoot/Player").lookat
	# Move towards player
	movement.x = player_direction.x
	movement.z = player_direction.z
	if (mobility == 1):
		# Jump
		if (grounded && !jumped):
			get_node("Body").apply_impulse(Vector3(), Vector3(0, 5, 0))
			jumped = true
		elif (!grounded):
			jumped = false
	if (mobility == 2):
		# Fly
		if (get_node("GroundBelow").is_colliding()):
			get_node("Body").apply_impulse(Vector3(), Vector3(0, 0.5, 0))
	if (intelligence == 2 && (get_node("Body").get_global_transform().origin - get_node("../").get_global_transform().origin).length() < 15):
		# Run away if player is looking towards and we're not at the edge yet
		var dot = player_direction.dot(player_look_direction)
		if (dot < 0.2):
			movement *= -1

func _fixed_process(delta):
	var death_scale = 1
	if (death_anim_timer != -1):
		if (death_anim_timer > 0):
			death_anim_timer -= delta
		elif (death_anim_timer < 0):
			get_node("/root/WorldRoot/Player").add_xp(1 + scale + mobility + intelligence)
			queue_free()
		death_scale = death_anim_timer / DEATH_ANIM_LENGTH_IN_SECONDS
	get_node("Body").set_scale(Vector3(1, 1, 1) * (scale + 1) * death_scale)
	get_node("GroundBelow").set_translation(get_node("Body").get_global_transform().origin)
	sleeping_time -= delta
	if (sleeping_time <= 0):
		get_node("Body").translate(movement * delta * movement_speed)

func _on_body_enter(body):
	if (body extends StaticBody):
		grounded = true

func _on_body_exit(body):
	if (body extends StaticBody):
		grounded = false

func _on_damage_enter(body):
	var player = body.get_parent()
	if (player.get_name().find("Player") != -1 && death_anim_timer == -1):
		get_node("Body").apply_impulse(Vector3(), (movement * -1 + Vector3(0, 1, 0)) * 10)
		if (intelligence == 1):
			sleeping_time = CHARGER_SLEEP_SECONDS
		player.take_damage(1 + scale)

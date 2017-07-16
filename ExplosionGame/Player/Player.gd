extends Spatial

export var GRAVITY = 200
export var MOUSE_BOUNDS = Rect2(100, 100, 1080, 520)
export var FULL_HEALTH = 20
export var MAX_DAMAGE = 5
export var move_speed = 7.5
var last_mouse_pos = Vector2(-1, -1)
var rotation = Vector3()
var lookat = Vector3()
var shooting = false
var rocket = load("res://ExplosionGame/Environment/Rocket.tscn")
var health = FULL_HEALTH
var xp = 1
var shoot_anim = 0

var fx_health_delta = 0
var fx_damage_delta = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_process_input(true)
	set_fixed_process(true)
	set_process(true)

func shoot():
	get_node("Body/Camera/Gun/MuzzleFlash").set_emitting(true)
	var rocket_instance = rocket.instance()
	rocket_instance.init(get_node("Body/Camera/Gun/RocketLauncher").get_global_transform().origin, lookat, xp)
	var looking_down = lookat.dot(Vector3(0, -1, 0)) > 0.5
	if (!get_node("Body/Grounded").is_colliding() && looking_down): 
		get_node("Body").apply_impulse(Vector3(), lookat * -1 * 10)
	get_node("../").add_child(rocket_instance)
	shoot_anim = 1
	get_node("Body/Camera/Gun/LauncherSound").play("Shoot")

func heal(dmg):
	var new_health = clamp(health + dmg, 0, FULL_HEALTH)
	fx_health_delta += new_health - health
	health = new_health

func take_damage(dmg):
	var new_health = clamp(health - dmg, 0, FULL_HEALTH)
	fx_health_delta += new_health - health
	health = new_health
	fx_damage_delta += 1 - xp
	xp = 1

func add_xp(amt):
	var new_xp = clamp(xp + amt, 1, MAX_DAMAGE)
	fx_damage_delta += new_xp - xp
	xp = new_xp

func _input(event):
	if (event.type == InputEvent.MOUSE_MOTION):
		var mouse_pos = event.pos
		var delta_mouse = mouse_pos - last_mouse_pos
		# Loop mouse (except during the first mouse move)
		if (last_mouse_pos.x >= 0 && last_mouse_pos.y >= 0):
			var predicted_mouse_pos = (mouse_pos + delta_mouse)
			if (predicted_mouse_pos.x > MOUSE_BOUNDS.pos.x + MOUSE_BOUNDS.size.x): mouse_pos.x -= MOUSE_BOUNDS.size.x / 2
			if (predicted_mouse_pos.x < MOUSE_BOUNDS.pos.x): mouse_pos.x += MOUSE_BOUNDS.size.x / 2
			if (predicted_mouse_pos.y > MOUSE_BOUNDS.pos.y + MOUSE_BOUNDS.size.y): mouse_pos.y -= MOUSE_BOUNDS.size.y / 2
			if (predicted_mouse_pos.y < MOUSE_BOUNDS.pos.y): mouse_pos.y += MOUSE_BOUNDS.size.y / 2
			if (predicted_mouse_pos != mouse_pos + delta_mouse):
				Input.warp_mouse_pos(mouse_pos)
		# Update last mouse pos
		last_mouse_pos = mouse_pos
		# Mouselook
		rotation.x = clamp(rotation.x - delta_mouse.y * 0.005, -1, 1)
		rotation.y += delta_mouse.x * 0.005

func _process(delta):
	# Update HUD
	# Bars
	var hp_percent = health / FULL_HEALTH
	get_node("Health/Full").set_region_rect(Rect2(0, 0, 40 + 260 * hp_percent, 80))
	var xp_percent = (xp - 1) / (MAX_DAMAGE - 1)
	get_node("Damage/Full").set_region_rect(Rect2(0, 0, 40 + 260 * xp_percent, 80))
	# Delta FX
	var hp_delta_percent = fx_health_delta / FULL_HEALTH
	get_node("Health").set_scale(Vector2(1, 1) * (1 + hp_delta_percent))
	var xp_delta_percent = fx_damage_delta / (MAX_DAMAGE * 0.7)
	get_node("Damage").set_scale(Vector2(-1, 1) * (1 + xp_delta_percent))
	fx_health_delta = approach_zero(fx_health_delta, delta * delta * 500)
	fx_damage_delta = approach_zero(fx_damage_delta, delta * delta * 40)

func approach_zero(x, delta):
	if (x > 0):
		x -= delta
		if (x < 0):
			x = 0
	if (x < 0):
		x += delta
		if (x > 0):
			x = 0
	return x

func _fixed_process(delta):
	# Shooting inputs
	if (Input.is_action_pressed("shoot") && !shooting):
		shoot()
		shooting = true
	elif (!Input.is_action_pressed("shoot")):
		shooting = false
	
	# Animate gun
	shoot_anim = approach_zero(shoot_anim, delta * 2)
	get_node("Body/Camera/Gun/Launcher").set_rotation_deg(Vector3(-shoot_anim * 30, 0, 0))
	get_node("Body/Camera/Gun/Launcher").set_translation(Vector3(0, 0, -shoot_anim * 0.2))
	
	# Movement inputs
	var movement = Vector3()
	var grounded = get_node("Body/Grounded").is_colliding()
	if (Input.is_action_pressed("move_forward")):
		movement.z -= 1
	if (Input.is_action_pressed("move_backward")):
		movement.z += 1
	if (Input.is_action_pressed("move_left")):
		movement.x -= 1
	if (Input.is_action_pressed("move_right")):
		movement.x += 1
	if (grounded):
		if (Input.is_action_pressed("jump")):
			get_node("Body").apply_impulse(Vector3(), Vector3(0, 7, 0))
	# Transform the direction to be relative to the camera + normalize + apply movement speed
	movement = get_node("Body/Camera").get_transform().basis.xform(movement).normalized() * move_speed
	# Move the character
	get_node("Body").translate(movement * delta)
	
	# Apply mouselook
	lookat = Vector3(cos(rotation.y) * cos(rotation.x * PI / 2), rotation.x, sin(rotation.y) * cos(rotation.x * PI / 2))
	get_node("Body/Camera").look_at(get_node("Body/Camera").get_camera_transform().origin + lookat, Vector3(0, 1, 0))

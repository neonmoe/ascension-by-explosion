extends Spatial

export var GRAVITY = 200
export var MOUSE_BOUNDS = Rect2(100, 100, 1080, 520)
export var move_speed = 7.5
var last_mouse_pos = Vector2(-1, -1)
var rotation = Vector3()
var lookat = Vector3()
var shooting = false
var rocket = load("res://ExplosionGame/Environment/Rocket.tscn")
var health = 10
var xp = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_process_input(true)
	set_fixed_process(true)

func shoot():
	print("Bang!")
	get_node("Body/Camera/Gun/MuzzleFlash").set_emitting(true)
	var rocket_instance = rocket.instance()
	rocket_instance.init(get_node("Body/Camera/Gun/RocketLauncher").get_global_transform().origin, lookat)
	get_node("../").add_child(rocket_instance)

func take_damage(dmg):
	health -= dmg
	get_node("HealthLabel").set_text("HP: " + str(health))

func add_xp(amt):
	xp += amt
	get_node("XPLabel").set_text("XP: " + str(xp))

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

func _fixed_process(delta):
	# Shooting inputs
	if (Input.is_action_pressed("shoot") && !shooting):
		shoot()
		shooting = true
	elif (!Input.is_action_pressed("shoot")):
		shooting = false
	
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
			get_node("Body").apply_impulse(Vector3(), Vector3(0, 10, 0))
	# Transform the direction to be relative to the camera + normalize + apply movement speed
	movement = get_node("Body/Camera").get_transform().basis.xform(movement).normalized() * move_speed
	# Move the character
	get_node("Body").translate(movement * delta)
	
	# Apply mouselook
	lookat = Vector3(cos(rotation.y), rotation.x, sin(rotation.y))
	get_node("Body/Camera").look_at(get_node("Body/Camera").get_camera_transform().origin + lookat, Vector3(0, 1, 0))

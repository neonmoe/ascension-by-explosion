extends Spatial

export var HEALTH_PER_POINT = 4
export var DAMAGE_PER_POINT = 1

var health
var damage
var attracted_to = null

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if (attracted_to != null):
		var direction = attracted_to.get_global_transform().origin - get_node("Body").get_global_transform().origin
		get_node("Body").translate(direction.normalized() * 10 * delta)

func init(hp, dmg):
	var vel = 50
	get_node("Body").apply_impulse(Vector3(), Vector3(vel * 0.2 * (randf() * 2 - 1), 
		vel * (randf() * 2 - 1), vel * 0.2 * (randf() * 2 - 1)))
	health = hp * HEALTH_PER_POINT
	damage = dmg * DAMAGE_PER_POINT
	for i in range(0, get_node("Body/Mesh").get_child_count()):
		if (get_node("Body/Mesh").get_child(i) extends MeshInstance):
			var mesh = get_node("Body/Mesh").get_child(i).get_mesh()
			mesh = mesh.duplicate()
			get_node("Body/Mesh").get_child(i).set_mesh(mesh)
			var new_mat = FixedMaterial.new()
			new_mat.set_parameter(FixedMaterial.PARAM_DIFFUSE, Color(0.2 + 0.6 * hp, 0.3, 0.3 + 0.6 * dmg))
			mesh.surface_set_material(0, new_mat)

func _on_body_enter(body):
	var player = body.get_parent()
	if (player.get_name().find("Player") != -1):
		player.heal(health)
		player.add_xp(damage)
		queue_free()

func _on_AttractionField_body_enter(body):
	var player = body.get_parent()
	if (player.get_name().find("Player") != -1):
		attracted_to = body

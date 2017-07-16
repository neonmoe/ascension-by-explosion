extends Spatial

export var OPEN_ANIMATION_TIME = 1

var toggle_time = -1
var opening = false
var time = 0

func _ready():
	set_process(true)

func open():
	toggle_time = time
	opening = true

func close():
	toggle_time = time
	opening = false

func _process(delta):
	time += delta
	var t = (toggle_time - time) / OPEN_ANIMATION_TIME
	var portal_scale = 0.0
	var gate_scale = 0.0
	if (t >= 0 && t <= 1):
		if (opening):
			portal_scale = min(1, t * 4)
			gate_scale = max(0, min(1, (t - 0.25) * 4.0 / 3.0))
		else:
			portal_scale = min(1, t * 4)
			gate_scale = 1 - max(0, min(1, (t - 0.25) * 4.0 / 3.0))
	else:
		if (opening):
			gate_scale = 1
	get_node("Portal").set_scale(Vector3(1, 1, 1) * portal_scale)
	get_node("Gate").set_scale(Vector3(1, 1, 1) * gate_scale)

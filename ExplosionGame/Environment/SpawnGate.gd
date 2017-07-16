extends Spatial

export var OPEN_ANIMATION_TIME = 1.0

var toggle_time = -1
var opening = false
var time = 0.0

func _ready():
	set_process(true)

func open():
	toggle_time = time
	opening = true

func close():
	toggle_time = time
	opening = false

func _process(delta):
	return
	time += delta
	var t = (toggle_time - time) / OPEN_ANIMATION_TIME
	var gate_scale = 0.0
	if (toggle_time != -1):
		clamp(t, 0.0, 1.0)
		if (!opening):
			gate_scale = 1.0 - gate_scale
	get_node("Gate").set_scale(Vector3(1.0, 1.0, 1.0) * gate_scale)

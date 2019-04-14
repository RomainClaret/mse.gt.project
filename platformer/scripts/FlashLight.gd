extends SpotLight

var is_activated = false

func _process(delta):
	if Input.is_action_just_pressed("flashlight"):
		if !is_activated:
			show()
		else:
			hide()
		is_activated = !is_activated
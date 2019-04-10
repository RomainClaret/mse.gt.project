extends SpotLight


func _process(delta):
	if Input.is_action_just_pressed("flashlight"):
		if is_visible_in_tree():
			hide()
		else:
			show()
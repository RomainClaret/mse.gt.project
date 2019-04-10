extends Camera


func _physics_process(delta):
	# Put the camera higher over the player
	var vec = get_parent().get_parent().transform.origin
	vec.y += 15
	transform.origin = vec
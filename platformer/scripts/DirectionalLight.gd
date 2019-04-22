extends DirectionalLight


func random_position():
	var x = rand_range(-8, 8.01)
	var z = rand_range(-12.5, 12.51)
	return Vector3(x, 0, z)


func _physics_process(delta):
	var space_state = get_world().direct_space_state
	
	var result = space_state.intersect_ray(transform.origin, random_position())
	print(result)
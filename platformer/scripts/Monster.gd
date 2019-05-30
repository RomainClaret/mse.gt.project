extends KinematicBody


func get_closest_player():
	var players = get_tree().get_nodes_in_group("Player")
	
	var closest_player
	var closest_dist = 1000
	for player in players:	
		var player_pos = player.transform.origin
		var monster_pos = transform.origin
		var distance = sqrt((player_pos.x - monster_pos.x) * (player_pos.x - monster_pos.x) +
		(player_pos.y - monster_pos.y) * (player_pos.y - monster_pos.y) +
		(player_pos.z - monster_pos.z) * (player_pos.z - monster_pos.z))
		
		if distance < closest_dist:
			closest_dist = distance
			closest_player = player

	return closest_player


func _process(delta):
	var nav: Navigation = get_parent()
	
	var player = get_closest_player()
	
	var begin = nav.get_closest_point(transform.origin)
	var end = nav.get_closest_point(player.transform.origin)
	
	var path = Array(nav.get_simple_path(begin, end))
	path.invert()
	
	if path.size() > 1:
		var to_walk = delta
		var to_watch = Vector3(0, 1, 0)
		while to_walk > 0 and path.size() >= 2:
			var pfrom = path[path.size() - 1]
			var pto = path[path.size() - 2]
			to_watch = (pto - pfrom).normalized()
			var d = pfrom.distance_to(pto)
			if d <= to_walk:
				path.remove(path.size() - 1)
				to_walk -= d
			else:
				path[path.size() - 1] = pfrom.linear_interpolate(pto, to_walk/d)
				to_walk = 0
		
		var atpos = path[path.size() - 1]
		var atdir = to_watch
		atdir.y = 0
		
		var t = Transform()
		t.origin = atpos
		t = t.looking_at(atpos + atdir, Vector3(0, 1, 0))
		set_transform(t)
		set_scale(Vector3(0.25, 0.25, 0.25))
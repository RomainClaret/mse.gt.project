extends KinematicBody

var Bullet = preload("res://scenes/Bullet.tscn")

var initial_position
var player
var navigation: Navigation 
const MAX_DIST = 8

enum STATE { IDLE = 0, HUNT = 1, RETREAT = 2 }
var current_state

func _ready():
	initial_position = transform.origin
	navigation = get_parent()
	current_state = STATE.IDLE


func euclidean_distance(v1: Vector3, v2: Vector3):
	return sqrt((v1.x - v2.x) * (v1.x - v2.x) +
	(v1.y - v2.y) * (v1.y - v2.y) +
	(v1.z - v2.z) * (v1.z - v2.z))


func get_closest_player():
	var players = get_tree().get_nodes_in_group("Player")
	
	var closest_player
	var closest_dist = 1000
	for player in players:	
		var player_pos = player.transform.origin
		var monster_pos = transform.origin
		var distance = euclidean_distance(player_pos, monster_pos)
		
		if distance < closest_dist:
			closest_dist = distance
			closest_player = player

	return closest_player


func move_along_path(path, delta):
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

func hunt(delta):
	var player = get_closest_player()
	
	var begin = navigation.get_closest_point(transform.origin)
	var end = navigation.get_closest_point(player.transform.origin)
	
	var path = Array(navigation.get_simple_path(begin, end))
	path.invert()
	
	if path.size() > 1:
		move_along_path(path, delta)

func target_found():
	player = get_closest_player()
	if euclidean_distance(initial_position, player.transform.origin) < MAX_DIST:
		return true
	else:
		return false

func _process(delta):
	match current_state:
		STATE.IDLE:
			if target_found():
				$TimerShoot.start()
				current_state = STATE.HUNT
		STATE.HUNT:
			if euclidean_distance(transform.origin, initial_position) < MAX_DIST:
				hunt(delta)
			else:
				current_state = STATE.RETREAT
				$TimerShoot.stop()
		STATE.RETREAT:
			if target_found():
				$TimerShoot.start()
				current_state = STATE.HUNT
			else:
				var begin = navigation.get_closest_point(transform.origin)
				var end = navigation.get_closest_point(initial_position)
				
				if begin != end:
					var path = Array(navigation.get_simple_path(begin, end))
					path.invert()
					
					if path.size() > 1:
						move_along_path(path, delta)
				else:
					current_state = STATE.IDLE
					$TimerShoot.stop()

func _on_TimerShoot_timeout():
	if euclidean_distance(transform.origin, player.transform.origin) < 4:
		var bullet = Bullet.instance()
		bullet.SPEED = 10
		bullet.shooter = self # to avoid collision with the shooter
		var xform = $Muzzle.global_transform
		bullet.shoot(xform)
		get_parent().add_child(bullet)

func take_damage():
	set_process(false)
	$TimerShoot.stop()
	yield(get_tree().create_timer(3), "timeout")
	set_process(true)
	$TimerShoot.start()
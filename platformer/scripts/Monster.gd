extends KinematicBody


func _ready():
	pass # Replace with function body.


func _process(delta):
	var players = get_tree().get_nodes_in_group("Player")
	
#	for player in players:	
#		var player_pos = player.transform.origin
#		var monster_pos = transform.origin
#		var distance = sqrt((player_pos.x - monster_pos.x) * (player_pos.x - monster_pos.x) +
#		(player_pos.y - monster_pos.y) * (player_pos.y - monster_pos.y) +
#		(player_pos.z - monster_pos.z) * (player_pos.z - monster_pos.z))
#
#		print("distance: ", distance)
	
	var nav = get_tree().get_nodes_in_group("Navigation")[0]
	var end = nav.get_closest_point(players[0].transform.origin)
	
	var path = nav.get_simple_path(transform.origin, end)
extends Spatial

var CoinBronze = preload("res://scenes/pickup/CoinBronze.tscn")
var CoinSilver = preload("res://scenes/pickup/CoinSilver.tscn")
var CoinGold = preload("res://scenes/pickup/CoinGold.tscn")

var new_player

var rnd_generator

var coins = [ ]
slave var slave_coins = [ ]

remote func get_coins(request_from_id, master_coins):
	print('master: returning coins')


func random_position():
	var x = rnd_generator.randf_range(-8, 8.01)
	var z = rnd_generator.randf_range(-12.5, 12.51)
	return Vector3(x, 0, z)


func instanciate_coins(Coin, n):
	var space_state = get_world().direct_space_state
	var result
	var i = 0
	
	while i < n:
		# Ray casting from the sun, a better starting point may be find...
		result = space_state.intersect_ray(get_node("DirectionalLight").transform.origin, random_position())

		if len(result) > 0 and rad2deg(result.normal.angle_to(Vector3.UP)) < 45:
			var coin = Coin.instance()

			coin.transform.origin = result.position
			coin.transform.origin.y += 0.25
			
			coin.connect("coin_collected", self, "increase_coin_collected")
			add_child(coin)
			
			Network.coins[coin.name] = coin.transform.origin

			i += 1


func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	
	new_player = preload('res://scenes/Player.tscn').instance()
	new_player.name = str(get_tree().get_network_unique_id())
	new_player.set_network_master(get_tree().get_network_unique_id())
	add_child(new_player)
	var info = Network.self_data
	new_player.init(info.name, info.position, false)
	
	new_player.connect("damage_inflicted", self, "decrease_hp")
	
	# Load the minimap camera into its texture 
	var texture : Texture = new_player.get_minimap_texture()
	$HUD/Minimap/TextureRect.set_texture(texture)

	rnd_generator = RandomNumberGenerator.new()
	rnd_generator.randomize()
	
	if is_network_master():
		instanciate_coins(CoinBronze, 10)
		instanciate_coins(CoinSilver, 10)
		instanciate_coins(CoinGold, 10)

	for spike in $Spikes.get_children():
		spike.connect("damage_inflicted", self, "decrease_hp")
		
	$"HUD/HBoxContainer/VBoxContainer2/PlayerName".text = info.name
	set_game_score(int(info.score))
	set_game_time(Network.game_time)
	set_game_status(Network.game_status)

func set_game_time(time):
	$"HUD/HBoxContainer/VBoxContainer2/HBoxContainer/TimeLeft".text = str(time)
	
func set_game_status(status):
	if status == 0:
		$"HUD/HBoxContainer/VBoxContainer2/GameStatus".text = "Not connected to server"
	elif status == 1:
		$"HUD/HBoxContainer/VBoxContainer2/GameStatus".text = "Waiting"
	elif status == 2:
		$"HUD/HBoxContainer/VBoxContainer2/GameStatus".text = "Playing"
	elif status == 3:
		$"HUD/HBoxContainer/VBoxContainer2/GameStatus".text = "Finished"
	else:
		$"HUD/HBoxContainer/VBoxContainer2/GameStatus".text = "Unknown Error: "+str(status)
	
func set_game_score(score):
	$"HUD/HBoxContainer/VBoxContainer2/PlayerScore".text = str(score)
	#rpc("update_game_status", game_status)
	if not not Network.players:
		Network.update_score(Network.players.keys()[0],score)


# Handle signals

func increase_coin_collected(taker_name, coin_name):
	if taker_name == new_player.name:
		var label
		var points = 0
		if coin_name.match("*Gold*"):
			label = $HUD/HBoxCoin/LabelCoinGold
			points= 3
		elif coin_name.match("*Silver*"):
			label = $HUD/HBoxCoin/LabelCoinSilver
			points = 2
		else:
			label = $HUD/HBoxCoin/LabelCoinBronze
			points = 1
		
		var value = int(label.get_text())
		label.set_text(str(value + 1))
		
		Network.self_data.score += points
		set_game_score(Network.self_data.score)
		


func decrease_hp():
	var life = $HUD/HBoxHP.get_child_count()
	if life > 0:
		$HUD/HBoxHP.get_child(0).queue_free()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().set_network_peer(null)
		SceneSwitcher.change_scene('res://scenes/Loby.tscn', {"caption": "You loose !!!"})


func _on_player_disconnected(id):
	get_node(str(id)).queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	SceneSwitcher.change_scene('res://scenes/Loby.tscn', {"caption": "You win !!!"})
	

func _on_server_disconnected():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	SceneSwitcher.change_scene('res://scenes/Loby.tscn', {"caption": "You win !!!"})
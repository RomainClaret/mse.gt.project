extends Spatial

var CoinBronze = preload("res://scenes/pickup/CoinBronze.tscn")
var CoinSilver = preload("res://scenes/pickup/CoinSilver.tscn")
var CoinGold = preload("res://scenes/pickup/CoinGold.tscn")


var rnd_generator


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
			
			add_child(coin)
			coin.connect("coin_collected", self, "increase_coin_collected")
			
			i += 1


func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	
	var new_player = preload('res://scenes/Player.tscn').instance()
	new_player.name = str(get_tree().get_network_unique_id())
	new_player.set_network_master(get_tree().get_network_unique_id())
	add_child(new_player)
	var info = Network.self_data
	new_player.init(info.name, info.position, false)
	
	# Load the minimap camera into its texture 
	var texture : Texture = new_player.get_minimap_texture()
	$HUD/Minimap/TextureRect.set_texture(texture)

	rnd_generator = RandomNumberGenerator.new()
	rnd_generator.randomize()
	
	instanciate_coins(CoinBronze, 10)
	instanciate_coins(CoinSilver, 10)
	instanciate_coins(CoinGold, 10)


	for spike in $Spikes.get_children():
		spike.connect("damage_inflicted", self, "decrease_hp")


# Handle signals

func increase_coin_collected(name):
	var label
	if name.match("*Gold*"):
		label = $HUD/HBoxCoin/LabelCoinGold
	elif name.match("*Silver*"):
		label = $HUD/HBoxCoin/LabelCoinSilver
	else:
		label = $HUD/HBoxCoin/LabelCoinBronze
	
	var value = int(label.get_text())
	label.set_text(str(value + 1))


func decrease_hp():
	$HUD/HBoxHP.get_child(0).queue_free()


func _on_player_disconnected(id):
	get_node(str(id)).queue_free()

func _on_server_disconnected():
	get_tree().change_scene('res://interface/Menu.tscn')
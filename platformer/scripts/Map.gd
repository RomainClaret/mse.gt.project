extends Spatial


func _ready():
	# Load the minimap camera into its texture 
	var texture : Texture = $Player/Minimap.get_texture()
	$HUD/Minimap/TextureRect.set_texture(texture)
	
	for coin in $Platforms/Pickup/CoinBronze.get_children():
		coin.connect("coin_bronze_collected", self, "increase_coin_bronze")

	for coin in $Platforms/Pickup/CoinSilver.get_children():
		coin.connect("coin_silver_collected", self, "increase_coin_silver")

	for coin in $Platforms/Pickup/CoinGold.get_children():
		coin.connect("coin_gold_collected", self, "increase_coin_gold")

	for spike in $Platforms/Spikes.get_children():
		spike.connect("damage_inflicted", self, "decrease_hp")


# Handle signals

func increase_coin_bronze():
	var value = int($HUD/HBoxCoin/LabelCoinBronze.get_text())
	$HUD/HBoxCoin/LabelCoinBronze.set_text(str(value + 1))

func increase_coin_silver():
	var value = int($HUD/HBoxCoin/LabelCoinSilver.get_text())
	$HUD/HBoxCoin/LabelCoinSilver.set_text(str(value + 1))
	
func increase_coin_gold():
	var value = int($HUD/HBoxCoin/LabelCoinGold.get_text())
	$HUD/HBoxCoin/LabelCoinGold.set_text(str(value + 1))


func decrease_hp():
	$HUD/HBoxHP.get_child(0).queue_free()
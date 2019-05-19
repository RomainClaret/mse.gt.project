extends Area


signal coin_collected(name)

var already_took = false

func _ready():
	set_network_master(1) # server is the owner of the object

func _on_CoinBronze_body_entered(body):
	if body.is_in_group("Player") and body.is_network_master():
		rpc("master_pickup", body.get_path())

master func master_pickup(taker_path):
	if not already_took:
		already_took = true
		rpc("sync_pickup", taker_path)

sync func sync_pickup(taker_path):
	var taker = get_node(taker_path)
	emit_signal("coin_collected", taker.name, name)
	queue_free()
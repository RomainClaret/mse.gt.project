extends Area

signal coin_bronze_collected


func _on_CoinBronze_body_entered(body):
	emit_signal("coin_bronze_collected")
	queue_free()
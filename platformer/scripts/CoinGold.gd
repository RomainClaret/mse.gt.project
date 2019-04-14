extends Area

signal coin_gold_collected


func _on_CoinGold_body_entered(body):
	emit_signal("coin_gold_collected")
	queue_free()

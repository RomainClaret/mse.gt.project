extends Area

signal coin_silver_collected


func _on_CoinSilver_body_entered(body):
	emit_signal("coin_silver_collected")
	queue_free()
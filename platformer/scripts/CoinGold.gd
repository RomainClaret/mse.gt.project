extends Area


signal coin_collected(name)


func _on_CoinGold_body_entered(body):
	if body is KinematicBody:
		queue_free()
		emit_signal("coin_collected", name)

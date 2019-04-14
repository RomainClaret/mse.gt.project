extends Label

func _on_coin_gold():
	var value = int(get_text())
	set_text(value + 1)
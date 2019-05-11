extends Control

var _player_name = ""


func _ready():
	var caption = SceneSwitcher.get_param("caption")
	if caption != null:
		$VBoxContainer/WinLooseLabel.set_text(caption)


func _on_TextEdit_text_changed(new_text):
	_player_name = new_text

func _on_CreateButton_pressed():
	if _player_name == "":
		return
	Network.create_server(_player_name)
	_load_game()

func _on_JoinButton_pressed():
	if _player_name == "":
		return
	Network.connect_to_server(_player_name)
	_load_game()

func _load_game():
	get_tree().change_scene('res://scenes/Map.tscn')
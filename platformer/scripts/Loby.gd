extends Control

onready var player_name = get_node("VBoxContainer/HBoxContainer/VBoxContainer2/PseudoTextEdit")
onready var game_minutes_label = get_node("VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer2/HBoxContainer/MinutesLabel")
onready var game_minutes_slider = get_node("VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer2/MinutesHSlider")

func _ready():
	var caption = SceneSwitcher.get_param("caption")
	if caption != null:
		$VBoxContainer/WinLooseLabel.set_text(caption)
	game_minutes_label.text = str(game_minutes_slider.value)

func _on_CreateButton_pressed():
	if player_name.text == "":
		player_name.text = "Server"
	Network.create_server(player_name.text, game_minutes_slider.value)
	_load_game()

func _on_JoinButton_pressed():
	if player_name.text == "":
		player_name.text = "Client"
	Network.connect_to_server(player_name.text)
	_load_game()

func _load_game():
	get_tree().change_scene('res://scenes/Map.tscn')

func _on_HSlider_value_changed(value):
	game_minutes_label.text = str(value)

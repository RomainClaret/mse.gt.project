extends KinematicBody


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$Rotation_Helper.connect("player_y_rotation", $Viewport_Minimap/Camera_Minimap, "_on_player_y_rotation")


func _process(delta):
	# Capturing / Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_cursor_focus()


func toggle_cursor_focus():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


##
# Signals handlers
##

func _on_Mushroom_Blue_pick_up():
	var current = int($GUI/Mushrooms_Blue/HBoxContainer/NinePatchRect/Label.get_text())
	$GUI/Mushrooms_Blue/HBoxContainer/NinePatchRect/Label.set_text(str(current + 1))
	
	
func _on_Mushroom_Red_pick_up():
	var current = int($GUI/Mushrooms_Red/NinePatchRect/Label.get_text())
	$GUI/Mushrooms_Red/NinePatchRect/Label.set_text(str(current + 1))
	

func _on_Mushroom_Yellow_pick_up():
	print('ok')
	var current = int($GUI/Mushrooms_Yellow/HBoxContainer/NinePatchRect/Label.get_text())
	$GUI/Mushrooms_Yellow/HBoxContainer/NinePatchRect/Label.set_text(str(current + 1))

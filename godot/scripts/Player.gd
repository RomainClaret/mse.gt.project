extends KinematicBody

var ghost : AnimationPlayer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	ghost = $Ghost/AnimationPlayer
	ghost.play("idle")
	
	$Rotation_Helper.connect("sprinting", $GUI, "_on_sprinting")
	$Rotation_Helper.connect("stop_sprinting", $GUI, "_on_stop_sprinting")


func _physics_process(delta):
	# Capturing / Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_cursor_focus()
	
	if $Rotation_Helper.vel.x != 0 || $Rotation_Helper.vel.z != 0:
		ghost.play("marcher")
	else:
		ghost.play("idle")
	



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
	var current = int($GUI/Mushrooms_Yellow/HBoxContainer/NinePatchRect/Label.get_text())
	$GUI/Mushrooms_Yellow/HBoxContainer/NinePatchRect/Label.set_text(str(current + 1))

extends Spatial

func _process(delta):
	if Input.is_action_just_pressed("mouse_left"):
		$Dagger_Mesh/AnimationPlayer.play("Hit")
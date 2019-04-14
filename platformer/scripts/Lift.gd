extends Spatial

var player_in_range = false

export var time = 1.75
var current_time

func _ready():
	current_time = time
	

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("use") and $TimerUp.is_stopped():
		$TimerUp.start()


func _on_Lever_body_entered(body):
	if body.is_class('KinematicBody'):
		player_in_range = true
		$HUD.show()


func _on_Lever_body_exited(body):
	if body.is_class('KinematicBody'):
		player_in_range = false
		$HUD.hide()

func _on_TimerUp_timeout():
	if current_time > 0:
		$BlockMoving.translate(Vector3(0, $TimerUp.get_wait_time(), 0))
		current_time -= $TimerUp.get_wait_time()
	else:
		$TimerUp.stop()
		yield(get_tree().create_timer(1), "timeout")
		$TimerDown.start()

func _on_TimerDown_timeout():
	if current_time < time:
		$BlockMoving.translate(Vector3(0, -$TimerDown.get_wait_time(), 0))
		current_time += $TimerDown.get_wait_time()
	else:
		$TimerDown.stop()


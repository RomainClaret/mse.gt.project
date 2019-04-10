extends Spatial

const GRAVITY = -9.8
const MAX_SLOPE_ANGLE = 40

# not const because the user should be able to modify it from settings
var MOUSE_SENSITIVITY = 0.2  

var max_speed
const MAX_WALKING_SPEED = 3
const MAX_SPRINT_SPEED = 6

var accel
const WALKING_ACCEL = 4.5
const SPRINT_ACCEL = 8
const DEACCEL= 16

const JUMP_SPEED = 5

var zoom = 1
const MAX_ZOOM = 6


var vel : Vector3
var dir : Vector3


signal sprinting
signal stop_sprinting

func _physics_process(delta):
	walking()
	jumping()
	sprinting()
	
	process_movement(delta)


func walking():
	dir = Vector3()
	var cam_xform = $Camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("ui_up"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("ui_down"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("ui_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y


func jumping():
	if Input.is_action_just_pressed("ui_select"):
		if get_parent().is_on_floor():
			vel.y = JUMP_SPEED


func sprinting():
	if Input.is_action_pressed("sprint") and get_parent().get_node("GUI").mp > 0:
		max_speed = MAX_SPRINT_SPEED
		accel = SPRINT_ACCEL
		emit_signal("sprinting")
	else:
		max_speed = MAX_WALKING_SPEED
		accel = WALKING_ACCEL
		
	if Input.is_action_just_released("sprint"):
		emit_signal("stop_sprinting")


func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir * max_speed

	if dir.dot(hvel) == 0:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	
	vel = get_parent().move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))


func _input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:

		if event is InputEventMouseMotion:
			rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
			
			var angle = deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1)
			get_parent().rotate_y(angle)
			get_parent().get_node("Viewport_Minimap/Camera_Minimap").rotate_y(angle) 

			# Can't watch more/less than 60° upward/downward
			rotation_degrees.x = clamp(rotation_degrees.x, -60, 60 )


		if event is InputEventMouseButton:
			if event.button_index == BUTTON_WHEEL_UP and zoom > 1:
				$Camera.translate_object_local(Vector3(0, -1, -2))
				zoom -= 1
				if zoom == 1:
					get_parent().get_node("Ghost").hide()
			elif event.button_index == BUTTON_WHEEL_DOWN and zoom < MAX_ZOOM:
				$Camera.translate_object_local(Vector3(0, 1, 2))
				zoom += 1
				if zoom > 1:
					get_parent().get_node("Ghost").show()

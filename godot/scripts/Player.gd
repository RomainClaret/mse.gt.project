extends KinematicBody

const GRAVITY = -9.8

var max_speed
const MAX_WALKING_SPEED = 5
const MAX_SPRINT_SPEED = 10

const JUMP_SPEED = 5

var accel
const WALKING_ACCEL = 4.5
const SPRINT_ACCEL = 8
const DEACCEL= 16

const MAX_SLOPE_ANGLE = 40

var MOUSE_SENSITIVITY = 0.2

var vel : Vector3
var dir : Vector3

var camera
var rotation_helper
var flashlight

const MAX_ZOOM = 6
var zoom = 1

func _ready():
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper
	flashlight = $Rotation_Helper/Flashlight

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	process_input(delta)
	process_movement(delta)


func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70 )
		rotation_helper.rotation_degrees = camera_rot
	
	if event is InputEventMouseButton and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var cam_xform = camera.get_global_transform()
		if event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN:
			if event.button_index == BUTTON_WHEEL_UP and zoom > 1:
					camera.translate_object_local(Vector3(-1, -1, -2))
					var pos = $HUD/Crosshair.get_position()
					$HUD/Crosshair.set_position(pos)
					zoom -= 1
			elif event.button_index == BUTTON_WHEEL_DOWN and zoom < MAX_ZOOM:
					camera.translate_object_local(Vector3(1, 1, 2))
					var pos = $HUD/Crosshair.get_position()
					$HUD/Crosshair.set_position(pos)
					zoom += 1



func process_input(delta):
	walking()
	jumping()
	sprinting()
	
	toggle_flashlight()

	# Capturing / Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_cursor_focus()


func walking():
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

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
		if is_on_floor():
			vel.y = JUMP_SPEED


func sprinting():
	if Input.is_action_pressed("sprint"):
		max_speed = MAX_SPRINT_SPEED
		accel = SPRINT_ACCEL
	else:
		max_speed = MAX_WALKING_SPEED
		accel = WALKING_ACCEL


func toggle_flashlight():
	if Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()


func toggle_cursor_focus():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


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
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

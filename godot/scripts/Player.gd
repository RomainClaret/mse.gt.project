extends KinematicBody

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

var camera : Camera
var rotation_helper : Spatial
var flashlight : SpotLight
var minimap : Camera


func _ready():
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper
	flashlight = $Rotation_Helper/Flashlight
	minimap = $Viewport_Minimap/Camera_Minimap

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	walking()
	jumping()
	sprinting()
	attacking()
	
	var vec = transform.origin
	vec.y += 10
	minimap.transform.origin = vec
	
	toggle_flashlight()

	# Capturing / Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_cursor_focus()
	
	process_movement(delta)


func _input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				
		if event is InputEventMouseMotion:
			rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
			self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
			minimap.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
					
			var camera_rot = rotation_helper.rotation_degrees
			# Can't watch more/less than 60° upward/downward
			camera_rot.x = clamp(camera_rot.x, -60, 60 )
			rotation_helper.rotation_degrees = camera_rot
			
	
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_WHEEL_UP and zoom > 1:
				camera.translate_object_local(Vector3(0, -1, -2))
				zoom -= 1
				if zoom == 1:
					$"Penguin".hide()
			elif event.button_index == BUTTON_WHEEL_DOWN and zoom < MAX_ZOOM:
				camera.translate_object_local(Vector3(0, 1, 2))
				zoom += 1
				if zoom > 1:
					$"Penguin".show()


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
	
	if input_movement_vector.x != 0 or input_movement_vector.y != 0:
		$Penguin/AnimationPlayer.play("Walking")
	else:
		$Penguin/AnimationPlayer.stop()

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


func attacking():
	if Input.is_action_just_pressed("mouse_left"):
		$Rotation_Helper/Spatial/Dagger/AnimationPlayer.play("Hit")


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


##
# Signals handlers
##

func _on_Mushroom_Blue_pick_up():
	var current = int($GUI/Mushrooms_Blue/HBoxContainer/NinePatchRect/Label.get_text())
	$GUI/Mushrooms_Blue/HBoxContainer/NinePatchRect/Label.set_text(str(current + 1))
	
	
func _on_Mushroom_Red_pick_up():
	var current = int($GUI/Mushrooms_Red/NinePatchRect/Label.get_text())
	$GUI/Mushrooms_Red/NinePatchRect/Label.set_text(str(current + 1))
	

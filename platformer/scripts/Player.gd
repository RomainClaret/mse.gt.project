extends KinematicBody

class_name Player

var Bullet = preload("res://scenes/Bullet.tscn")

var GRAVITY = -12
var ACCEL = 8
var SPEED = 4
var SPRINT_COEFF = 1.6
var JUMP_SPEED = 4
var SPIN = 0.05
const MAX_SLOPE_ANGLE = 40

var velocity : Vector3
var direction : Vector3

var can_move = true
var camera : Camera

slave var slave_position = Vector3()
slave var slave_movement = Vector3()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera = $CameraFirst


func get_input():
	if can_move:	
			direction = Vector3()
			var input_movement_vector = Vector2()
			
			if Input.is_action_pressed("move_forward"):
				input_movement_vector.y += 1
			if Input.is_action_pressed("move_backward"):
				input_movement_vector.y -= 1
			if Input.is_action_pressed("starfe_right"):
				input_movement_vector.x += 1
			if Input.is_action_pressed("strafe_left"):
				input_movement_vector.x -= 1
				
			input_movement_vector = input_movement_vector.normalized()
	
			direction += transform.basis.x.normalized() * input_movement_vector.x
			direction -= transform.basis.z.normalized() * input_movement_vector.y
			
			if Input.is_action_pressed("sprint"):
				direction *= SPRINT_COEFF
	
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = JUMP_SPEED


	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta):
	if is_network_master():
		get_input()

		velocity.y += delta * GRAVITY
		
		var horizontal_velocity = velocity
		horizontal_velocity.y = 0
		
		var target = direction * SPEED
		var accel = ACCEL
		
		# Stop faster
		if direction.x == 0 and direction.y == 0:
			accel *= 2
			
		horizontal_velocity = horizontal_velocity.linear_interpolate(target, accel * delta)
		
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z
	
		rset_unreliable('slave_position', transform.origin)
		rset('slave_movement', velocity)
		
		velocity = move_and_slide(velocity, Vector3.UP, false, 4, deg2rad(MAX_SLOPE_ANGLE))
		
		$Minimap/Camera.transform.origin.x = transform.origin.x
		$Minimap/Camera.transform.origin.z = transform.origin.z
	else:
		velocity = move_and_slide(slave_movement, Vector3.UP, false, 4, deg2rad(MAX_SLOPE_ANGLE))
		transform.origin = slave_position

	if get_tree().is_network_server():
		Network.update_position(int(name), transform.origin)



func _unhandled_input(event):
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if $CameraFirst.is_current():
				if event.relative.y != 0:
					$CameraFirst.rotate_x(-lerp(0, SPIN, event.relative.y / 10))
					$CameraFirst.rotation_degrees.x = clamp($CameraFirst.rotation_degrees.x, -60, 60)
					$FlashLight.rotate_x(-lerp(0, SPIN, event.relative.y / 10))
					$FlashLight.rotation_degrees.x = clamp($CameraFirst.rotation_degrees.x, -60, 60)
				
			if event.relative.x != 0:
				rotate_y(-lerp(0, SPIN, event.relative.x / 10))
				$Minimap/Camera.rotate_y(-lerp(0, SPIN, event.relative.x / 10))
	
		if event.is_action_pressed("shoot"):
			if is_network_master():
				rpc('_shoot')
		
		if event.is_action_pressed("camera_switch"):
			if $CameraFirst.is_current():
				camera = $CameraThird
			else:
				camera = $CameraFirst
			camera.set_current(true)


sync func _shoot():
	var bullet = Bullet.instance()
	var xform = $Muzzle.global_transform
	if camera == $CameraFirst:
		xform.basis = camera.global_transform.basis
	bullet.shoot(xform)
	get_parent().add_child(bullet)

func take_damage():
	velocity *= -1
	velocity.y = JUMP_SPEED
	can_move = false
	yield(get_tree().create_timer(1), "timeout")
	can_move = true

func get_minimap_texture():
	return $Minimap.get_texture()

func init(nickname, start_position, is_slave):
	global_transform.origin = start_position

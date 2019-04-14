extends KinematicBody

class_name Player

var Bullet = preload("res://scenes/Bullet.tscn")

var GRAVITY = -12
var SPEED = 12
var SPRINT_COEFF = 1.6
var JUMP_SPEED = 4
var SPIN = 0.05
const MAX_SLOPE_ANGLE = 40

var velocity : Vector3
var can_move = true
var camera : Camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera = $CameraFirst


func get_input():
	if can_move:
		var vy = velocity.y
		velocity = Vector3()

		if Input.is_action_pressed("move_forward"):
			velocity -= transform.basis.z * SPEED
		if Input.is_action_pressed("move_backward"):
			velocity += transform.basis.z * SPEED
		if Input.is_action_pressed("starfe_right"):
			velocity += transform.basis.x * SPEED
		if Input.is_action_pressed("strafe_left"):
			velocity -= transform.basis.x * SPEED

		if Input.is_action_pressed("sprint"):
			velocity *= SPRINT_COEFF

		velocity.y = vy

		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_SPEED

	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta):
	get_input()
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector3.UP)
	
	$Minimap/Camera.transform.origin.x = transform.origin.x
	$Minimap/Camera.transform.origin.z = transform.origin.z


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if $CameraFirst.is_current():
			if event.relative.y != 0:
				$CameraFirst.rotate_x(-lerp(0, SPIN, event.relative.y / 10))
				$CameraFirst.rotation_degrees.x = clamp($CameraFirst.rotation_degrees.x, -60, 60 )
			
		if event.relative.x != 0:
			rotate_y(-lerp(0, SPIN, event.relative.x / 10))
			$Minimap/Camera.rotate_y(-lerp(0, SPIN, event.relative.x / 10))

	if event.is_action_pressed("shoot"):
		var bullet = Bullet.instance()
		var xform = $Muzzle.global_transform
		if camera == $CameraFirst:
			xform.basis = camera.global_transform.basis
		bullet.shoot(xform)
		get_parent().add_child(bullet)
	
	if event.is_action_pressed("camera_switch"):
		print('ok')
		camera.hide()
		if $CameraFirst.is_current():
			camera = $CameraThird
			camera.set_current(true)
		else:
			camera = $CameraFirst
			$CameraFirst.set_current(true)
		camera.show()



func take_damage():
	velocity *= -1
	velocity.y = JUMP_SPEED
	can_move = false
	yield(get_tree().create_timer(1), "timeout")
	can_move = true
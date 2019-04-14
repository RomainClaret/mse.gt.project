extends Area


var SPEED = 30
var velocity = Vector3()


func shoot(xform):
	transform = xform
	velocity = -transform.basis.z * SPEED


func _process(delta):
	transform.origin += velocity * delta

func _on_Timer_timeout():
	queue_free()


func _on_Bullet_body_entered(body):
	if body is StaticBody:
		queue_free()

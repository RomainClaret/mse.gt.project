extends Area

signal pick_up


func _ready():
	connect("body_entered", self, "_on_body_entered")
	

func _on_body_entered(body):
	disconnect("body_entered", self, "_on_body_entered")
	emit_signal("pick_up")
	hide()

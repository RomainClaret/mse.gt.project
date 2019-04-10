extends Control


var mp
var timer

func _ready():
	mp = $Health_Stats/Energy_Bar/TextureProgress.get_value()
	timer = $Health_Stats/Energy_Bar/Timer_Energy
	timer.connect("timeout", self, "_on_timer_energy")


# Regain mana
func _on_timer_energy():
	mp = $Health_Stats/Energy_Bar/TextureProgress.get_value()
	$Health_Stats/Energy_Bar/TextureProgress.set_value(mp + 1)


# Decrease mana, stop regaining mana
func _on_sprinting():
	mp -= 0.3
	$Health_Stats/Energy_Bar/TextureProgress.set_value(mp)
	timer.stop()


# Restart mana regeneration
func _on_stop_sprinting():
	timer.start()


func _on_Mushroom_Blue_pick_up():
	var current = int($Mushrooms_Blue/HBoxContainer/NinePatchRect/Label.get_text())
	$Mushrooms_Blue/HBoxContainer/NinePatchRect/Label.set_text(str(current + 1))


func _on_Mushroom_Red_pick_up():
	var current = int($Mushrooms_Red/NinePatchRect/Label.get_text())
	$Mushrooms_Red/NinePatchRect/Label.set_text(str(current + 1))
	

func _on_Mushroom_Yellow_pick_up():
	var current = int($Mushrooms_Yellow/HBoxContainer/NinePatchRect/Label.get_text())
	$Mushrooms_Yellow/HBoxContainer/NinePatchRect/Label.set_text(str(current + 1))
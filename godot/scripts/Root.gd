extends Spatial


func _ready():
	var mushrooms_blue = $Island_Large/Resources/Mushrooms_blue.get_children()
	var mushrooms_red = $Island_Large/Resources/Mushrooms_red.get_children()
	var mushrooms_yellow = $Island_Large/Resources/Mushrooms_yellow.get_children()
	
	for mushroom_blue in mushrooms_blue:
		mushroom_blue.connect("pick_up", $Player, "_on_Mushroom_Blue_pick_up")
		
	for mushroom_red in mushrooms_red:
		mushroom_red.connect("pick_up", $Player, "_on_Mushroom_Red_pick_up")

	for mushroom_yellow in mushrooms_yellow:
		mushroom_yellow.connect("pick_up", $Player, "_on_Mushroom_Yellow_pick_up")
		
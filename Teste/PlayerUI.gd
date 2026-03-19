extends Control

@onready var img = $Container/bg_img/img
@onready var poder = $Container/bg_pw/Label
@onready var lvl = $Container/bg_lvl/Label
@onready var class_player = $Container/bg_clss/Label
@onready var name_player = $Container/bg_name/Label

func update_data(data: Player):
	#img.texture = data.img #load(res://...)
	poder.text = str(data.get_power())
	lvl.text = str(data.level)
	#class_player.text = data._class
	name_player.text = data.name
	

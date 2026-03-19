extends Control


var player_ui = preload("res://Teste/control.tscn")
func _ready() -> void:

	for i in range(4):	
		var player = Player.new()
		player.name = "Teste "+str(i)
		var player2 = player_ui.instantiate()
		var container = $Control/HBoxContainer
		container.add_child(player2)
		player2.update_data(player)
		

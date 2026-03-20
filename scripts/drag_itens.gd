extends Panel

func _can_drop_data(position, data):
	var player =  data.player.UUID == GameData.player_turn
	return player

func _drop_data(position, data):
	print("Drop aconteceu")

	# remove o botão do container antigo
	if data.get_parent():
		data.get_parent().remove_child(data)

	# opcional: adiciona o botão no slot
	#add_child(data)

	# acessa o nome da carta que está dentro do botão
	print("Carta equipada no slot:", data.card.name, "dono:", data.player.name)

extends Panel
@onready var item_label: Label = $Item

func _ready():
	item_label.text = "Vazio"
	item_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

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
	item_label.text = data.card.name
	print("Carta equipada no slot:", data.card.name, "dono:", data.player.name)

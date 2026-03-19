extends Control

@onready var cards_node: Control = $Cards
@onready var card_scene = preload("res://cenas/card.tscn")
@onready var player: Player = GameData.current_player

var cards: Array = []
var deck = Deck.new()
func _ready() -> void:
	GameData.equipment_equip.connect(cards_for_play)

func cards_for_play():
	for card in player.hand:
		var card_ui = card_scene.instantiate()
		cards_node.add_child(card_ui)
		
		await get_tree().process_frame
		
		# Pivot e escala inicial
		card_ui.pivot_offset = card_ui.size / 2
		card_ui.scale = Vector2(0.2, 0.2)
		card_ui.global_position = $Button.global_position
		
		# Atualiza os dados da carta
		card_ui.update_card(card)
		cards.append(card)

		# Atualiza layout da mão
		update_hand_layout()
		
func add_card(card) -> void:
	var card_ui = card_scene.instantiate()
	cards_node.add_child(card_ui)
	
	await get_tree().process_frame
	
	# Pivot e escala inicial
	card_ui.pivot_offset = card_ui.size / 2
	card_ui.scale = Vector2(0.2, 0.2)
	card_ui.global_position = $Button.global_position
	
	# Atualiza os dados da carta
	card_ui.update_card(card)
	cards.append(card)
	
	# Atualiza layout da mão
	update_hand_layout()

# Atualiza posição, rotação e escala das cartas com tween
func update_hand_layout() -> void:
	var card_nodes = cards_node.get_children()
	var count := card_nodes.size()
	if count == 0:
		return

	var max_spacing := 110.0
	var min_spacing := 50.0
	# ternário GDScript 4 correto
	var spacing: float = max_spacing if count <= 5 else max(max_spacing - count * 4.0, min_spacing)

	var center_x := get_viewport_rect().size.x / 2
	var hand_y := get_viewport_rect().size.y - 220

	for i in range(count):
		var card_ui = card_nodes[i]
		card_ui.pivot_offset = card_ui.size / 2

		var t: float = (float(i) / float(count - 1)) * 2.0 - 1.0 if count > 1 else 0.0
		var x: float = center_x + t * spacing * (count - 1) / 2.0
		var y: float = hand_y + abs(t) * 30.0
		var rot: float = t * 12.0
		var target_pos := Vector2(x, y)

		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(card_ui, "global_position", target_pos, 0.30)
		tween.tween_property(card_ui, "rotation_degrees", rot, 0.30)
		tween.tween_property(card_ui, "scale", Vector2(1,1), 0.30)

# ======= Eventos das cartas =======
#func _on_card_hovered(card_ui):
	#card_ui.z_index = 100  # levanta a carta na frente
#	print(str(card_ui.rotation))

#func _on_card_unhovered(card_ui):
	#card_ui.z_index = 0
	
func _on_card_clicked(card_ui, card):
	print("Carta clicada:", card.name)
	# aqui você pode adicionar lógica de jogar a carta, equipar, etc.

# ======= Botão para puxar carta =======
func _on_button_pressed() -> void:
	var card = deck.draw_card()
	player.hand.append(card)
	add_card(card)

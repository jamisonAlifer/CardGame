extends Control

# ==========================
# ONREADY
# ==========================
@onready var cards_node: Control = $Cards

# ==========================
# VARIÁVEIS
# ==========================
var card_scene = preload("res://cenas/card.tscn")
var player: Player
var cards: Array = []  # guarda os nós card_ui para controle futuro
var deck = Deck.new()

var from_position: Vector2 = Vector2.ZERO
# ==========================
# READY
# ==========================
func _ready() -> void:
	from_position = Vector2(0,(get_viewport_rect().size.y / 2))
	GameData.equipment_equip.connect(cards_for_play)
	GameData.players_ready.connect(_on_players_ready)

func _on_players_ready() -> void:
	player = GameData.current_player

# ==========================
# POPULA A MÃO INICIAL
# ==========================
func cards_for_play() -> void:
	for card in player.hand:
		await add_card(card)

# ==========================
# ADICIONA UMA CARTA À MÃO
# ==========================
func add_card(card: Card) -> void:
	var card_ui = card_scene.instantiate()
	cards_node.add_child(card_ui)

	card_ui.modulate.a = 0.0
	await get_tree().process_frame

	card_ui.pivot_offset = card_ui.size / 2
	card_ui.scale = Vector2(0.2, 0.2)

	# ← define de onde a carta parte antes de qualquer tween
	card_ui.global_position = from_position if from_position != Vector2.ZERO \
		else Vector2(0, get_viewport_rect().size.y / 2)  # padrão = esquerda

	card_ui.update_card(card)
	cards.append(card_ui)

	# aparece e anima para a posição final
	var tween = create_tween()
	tween.tween_property(card_ui, "modulate:a", 1.0, 0.15)

	update_hand_layout()  # ← tween de posição roda depois, já com origem correta
	
# ATUALIZA LAYOUT DA MÃO COM TWEEN
# ==========================
func update_hand_layout() -> void:
	var card_nodes = cards_node.get_children()
	var count := card_nodes.size()
	if count == 0:
		return

	# Espaçamento entre cartas — diminui conforme a mão enche
	var max_spacing := 110.0  # espaço máximo (mão pequena)
	var min_spacing := 50.0   # espaço mínimo (mão cheia)
	var spacing: float = max_spacing if count <= 5 else max(max_spacing - count * 4.0, min_spacing)

	# Posição central da mão na tela — altere hand_y para subir/descer a mão
	var center_x := get_viewport_rect().size.x / 2
	var hand_y := get_viewport_rect().size.y - 220  # ← distância da borda inferior

	for i in range(count):
		var card_ui = card_nodes[i]
		card_ui.pivot_offset = card_ui.size / 2

		# t vai de -1.0 (carta mais à esquerda) até 1.0 (carta mais à direita)
		var t: float = (float(i) / float(count - 1)) * 2.0 - 1.0 if count > 1 else 0.0

		# Posição horizontal — altere o * spacing para as cartas ficarem mais juntas ou separadas
		var x: float = center_x + t * spacing * (count - 1) / 2.0

		# Curva da mão — aumente o * 30.0 para um arco mais pronunciado
		var y: float = hand_y + abs(t) * 30.0

		# Rotação — aumente o * 12.0 para cartas mais inclinadas nas pontas
		var rot: float = t * 12.0

		var tween = create_tween()
		tween.set_parallel(true)  # todas as propriedades animam ao mesmo tempo
		tween.tween_property(card_ui, "global_position", Vector2(x, y), 0.30)
		tween.tween_property(card_ui, "rotation_degrees", rot, 0.30)
		tween.tween_property(card_ui, "scale", Vector2(1, 1), 0.30)  # ← velocidade da animação em segundos

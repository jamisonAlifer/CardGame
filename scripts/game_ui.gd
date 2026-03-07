extends Control
# ==========================
# SINALS TURN
# ==========================
signal explorer
signal equip_equipment
# ==========================
# SLOTS DE JOGADORES
# ==========================
@onready var player_slot_1: Panel = $PlayerSlot1
@onready var player_slot_2: Panel = $PlayerSlot2
@onready var player_slot_3: Panel = $PlayerSlot3
@onready var player_slot_4: Panel = $PlayerSlot4
@onready var player_slot_5: Panel = $PlayerSlot5

var slots: Array[Panel] = []
var current_player_id: String  # UUID do jogador local

# ==========================
# READY - inicializa a UI
# ==========================
func _ready() -> void:
	print("Iniciando GUI")
	
	# Conecta sinais do GameData
	GameData.turn_timer_updated.connect(_on_timer_updated)
	GameData.turn_started.connect(_on_turn_started)
	GameData.play_phase_started.connect(_on_play_turn_started)
	GameData.combat_phase_started.connect(_on_combat_turn)
	GameData.players_data_updated.connect(_on_players_updated)

	slots = [
		player_slot_1,
		player_slot_2,
		player_slot_3,
		player_slot_4,
		player_slot_5
	]
	 # Atualiza imediatamente
	_on_players_updated(GameData.players)
	current_player_id = GameData.current_player.UUID
	$Label.text = "Player ID: " + current_player_id
# ==========================
# ATUALIZA OS SLOTS COM OS JOGADORES
# ==========================
func _on_players_updated(players: Array) -> void:
	print("Atualizando lista de jogadores")
	# Jogador local sempre no slot 0
	for player: Player in players:
		if player.UUID == current_player_id:
			_update_player_info(slots[0], player)
			_update_player_items(slots[0], player)
			break

	# Preenche os outros slots
	var slot_index: int = 1
	for player: Player in players:
		if player.UUID == current_player_id:
			continue
		if slot_index >= slots.size():
			break
		_update_player_info(slots[slot_index], player)
		_update_player_items(slots[slot_index], player)
		slot_index += 1
	print("finalizando de atualizar")

# ==========================
# FUNÇÕES AUXILIARES PARA UI
# ==========================
func _update_player_info(slot_panel: Panel, player: Player) -> void:
	slot_panel.get_node("NameLabel").text = player.name
	slot_panel.get_node("LevelLabel").text = str(player.level)

func _update_player_items(slot_panel: Panel, player: Player) -> void:
	var items_container := slot_panel.get_node("ItemsContainer") as VBoxContainer
	for child in items_container.get_children():
		child.queue_free()
	for slot_data in player.equipment.values():
		for card in slot_data["items"]:
			var label := Label.new()
			label.text = card.name
			items_container.add_child(label)

# ==========================
# REAGE AO INÍCIO DE TURNO
# ==========================
func _on_play_turn_started(player_uuid: String):
	print("vindo: ",player_uuid,"|  currente: ", current_player_id)
	var is_local = player_uuid == current_player_id
	print("/n/n Locla: ",str(is_local))
	var turno_inicio = $Turno_Player.get_node("Inicio_turno")
	turno_inicio.visible = is_local
	if is_local:
		print("É o turno do jogador local")
	else:
		print("Bot jogando")
		await get_tree().create_timer(1.0).timeout  # espera 2 segundos
		GameData.turn_ended.emit()
# ==========================
# ATUALIZA TIMER NA UI
# ==========================
func _on_turn_started(uuid):
	_update_timer_label(GameData.turn_time)

func _on_timer_updated(seconds_left):
	_update_timer_label(seconds_left)

func _update_timer_label(seconds_left: float):
	if seconds_left <= 0:
		#GameData.turn_ended.emit()
		return
	$timer_label.text = str(int(seconds_left))
	
func _on_combat_turn(player_uuid: String, card: Card):
	print("vindo: ",player_uuid," |  currente: ", current_player_id)
	var is_local = player_uuid == current_player_id
	if is_local:
		var turno= $Turno_Player.get_node("Turno")
		turno.visible = is_local
		turno.get_node("Combate").visible = is_local
		turno.get_node("Combate").get_node("Data").text = card.name
		print("Deu de cara com: ", card.name)
	print("Deu de cara com: ", card.name)
		
#==============================================================================
#==========================BUTÕES==============================================
#==============================================================================
func _on_explorar_pressed() -> void:
	print("Clicou em Explorar")
	var turno_inicio = $Turno_Player.get_node("Inicio_turno")
	turno_inicio.visible = false
	explorer.emit()


func _on_equipar_pressed() -> void:
	pass # Replace with function body.


func _on_lutar_pressed() -> void:
	pass # Replace with function body.


func _on_pedir_ajuda_pressed() -> void:
	pass # Replace with function body.


func _on_fugir_pressed() -> void:
	pass # Replace with function body.


func _on_invocar_pressed() -> void:
	pass # Replace with function body.


func _on_finalizar_pressed() -> void:
	pass # Replace with function body.

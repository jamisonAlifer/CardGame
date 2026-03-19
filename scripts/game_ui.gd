extends Control
# ==========================
# SINALS TURN
# ==========================
signal equip_equipment
var card_turn: Card
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
var bot: BotAi = BotAi.new()

var player_ui = preload("res://Teste/control.tscn")
# ==========================
# READY - inicializa a UI
# ==========================
func _ready() -> void:
	add_child(bot)
	# Conecta sinais do GameData
	GameData.play_phase_started.connect(_on_play_turn_started)
	GameData.combat_phase_started.connect(_on_combat_turn)
	GameData.players_data_updated.connect(_on_players_updated)
	GameData.find_helper.connect(_on_help_request)
	
	for i in range(GameData.players.size()):	
		var player = GameData.players[i]
		if player.UUID == GameData.current_player.UUID:
			continue
		player.name = player.name
		var player2 = player_ui.instantiate()
		var container = $Control/HBoxContainer
		container.add_child(player2)
		player2.update_data(player)
		slots.append(player2)
	 # Atualiza imediatamente
	current_player_id = GameData.current_player.UUID
	$Label.text = "Player ID: " + current_player_id
	_on_players_updated(GameData.players)
# ==========================
# ATUALIZA OS SLOTS COM OS JOGADORES
# ==========================
func _on_players_updated(players: Array) -> void:
	if current_player_id == "":
		return

	var other_players: Array = []
	print("------- ------ ------- ------ ------- ------ ------- ------ ------- ------")
	print("INICIANDO ATUALIZAÇÃO UI JOGADORES")

	for player: Player in players:
		if player.UUID == current_player_id:
			_update_player_info(player_slot_1, player)
		else:
			other_players.append(player)

	var slot_index := 1
	for player: Player in other_players:
		if slot_index >= slots.size():
			break
		_update_player_info(slots[slot_index], player)
		slot_index += 1
	print("FINALIZANDO ATUALIZAÇÃO UI JOGADORES")
	print("------- ------ ------- ------ ------- ------ ------- ------ ------- ------")

# ==========================
# FUNÇÕES AUXILIARES PARA UI
# ==========================
func _update_player_info(slot_panel: Panel, player: Player) -> void:
	slot_panel.get_node("NameLabel").text = player.name
	slot_panel.get_node("LevelLabel").text = str(player.level)

# ==========================
# REAGE AO INÍCIO DE TURNO
# ==========================
func _on_play_turn_started(player_uuid: String):
	print("\n---->TURNO DO JOGADOR INICIOU\n")
	var is_local = player_uuid == current_player_id
	print("\n-------------------> ",str(is_local))
	if !is_local:
		GameData.explorer.emit()
		print("---->JOGADOR EQUIPOU ITENS E EXPLOROU ------------------> ", is_local)
		print("------- ------ ------- ------ ------- ------ ------- ------ ------- ------\n\n")
		return 
	var turno_inicio = $Turno_Player.get_node("Inicio_turno")
	turno_inicio.visible = is_local
	
	
func _on_combat_turn(player_uuid: String, card: Card):
	card_turn = card
	var is_local = player_uuid == current_player_id
	if is_local:
		if card.category == "monster":
			var turno= $Turno_Player.get_node("Turno")
			turno.visible = is_local
			turno.get_node("Combate").visible = is_local
			turno.get_node("Combate").get_node("Data").text = card.name
			print("Deu de cara com: ", card.name)
		else:
			var turno= $Turno_Player.get_node("Turno")
			turno.visible = is_local
			turno.get_node("EndTurn").visible = is_local
	else:
		print("Deu de cara com: ", card.name)
		await bot.combat(player_uuid, card)
		GameData.turn_ended.emit()
		
func _on_help_request(player_uuid):
	$helper.visible = true
	await get_tree().create_timer(10.0).timeout 
	$helper.visible = false
#==============================================================================
#==========================BOTÕES==============================================
#==============================================================================
func _on_explorar_pressed() -> void:
	print("Clicou em Explorar")
	var turno_inicio = $Turno_Player.get_node("Inicio_turno")
	turno_inicio.visible = false
	GameData.explorer.emit()
	print("---->JOGADOR EQUIPOU ITENS E EXPLOROU")
	print("------- ------ ------- ------ ------- ------ ------- ------ ------- ------\n\n")
	
func _on_equipar_pressed() -> void:
	pass # Replace with function body.


func _on_lutar_pressed() -> void:
	var card = card_turn
	var player: Player =  GameData.getPlayer(GameData.player_turn)
	if player.get_power() >= card.monster_power:
		print("Parabéns, você venceu o monstro ", card.name)
		player.level_up(card.reward_levels)
	else:
		print("Morreu para monstro ", card.name)
	var turno= $Turno_Player.get_node("Turno")
	turno.visible = false
	turno.get_node("Combate").visible = false
	turno.get_node("Combate").get_node("Data").text = ""
	GameData.turn_ended.emit()

func _on_pedir_ajuda_pressed() -> void:
	pass # Replace with function body.


func _on_fugir_pressed() -> void:
	var rand = randi_range(1,6)
	if(rand >= 5):
		print("Fugiu com sucesso")
	else: 
		print("Você Morreu")
	var turno= $Turno_Player.get_node("Turno")
	turno.visible = false
	turno.get_node("Combate").visible = false
	turno.get_node("Combate").get_node("Data").text = ""
	GameData.turn_ended.emit()

func _on_invocar_pressed() -> void:
	var turno= $Turno_Player.get_node("Turno")
	turno.visible = false
	turno.get_node("Combate").visible = false
	turno.get_node("Combate").get_node("Data").text = ""
	GameData.turn_ended.emit()

func _on_finalizar_pressed() -> void:
	var turno= $Turno_Player.get_node("Turno")
	turno.visible = false
	turno.get_node("EndTurn").visible = false
	GameData.turn_ended.emit()


func _on_yes_pressed() -> void:
	if GameData.helper_locked:
		return
	GameData.helper_locked = true
	GameData.helper_selected.emit(GameData.current_player.UUID)
	$helper.visible = false

func _on_no_pressed() -> void:
	$helper.visible = false

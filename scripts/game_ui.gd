extends Control

# ==========================
# SINAIS
# ==========================
signal equip_equipment

# ==========================
# ONREADY - nós cacheados
# ==========================
@onready var inicio_turno = $CanvasLayer/Turno_Player/Inicio_turno
@onready var turno        = $CanvasLayer/Turno_Player/Turno
@onready var combate      = $CanvasLayer/Turno_Player/Turno/Combate
@onready var end_turn     = $CanvasLayer/Turno_Player/Turno/EndTurn
@onready var container    = $Control/HBoxContainer
@onready var player_stats = $Player_ui_stats
@onready var label        = $CanvasLayer/Label
@onready var helper       = $CanvasLayer/helper

# ==========================
# VARIÁVEIS
# ==========================
var card_turn: Card
var current_player_id: String
var bot: BotAi = BotAi.new()
var player_ui = preload("res://Teste/control.tscn")

# ==========================
# READY
# ==========================
func _ready() -> void:
	add_child(bot)
	current_player_id = GameData.current_player.UUID
	label.text = "Player ID: " + current_player_id

	GameData.play_phase_started.connect(_on_play_turn_started)
	GameData.combat_phase_started.connect(_on_combat_turn)
	GameData.find_helper.connect(_on_help_request)
	GameData.players_ready.connect(_on_players_ready)  # ← conecta aqui

func _on_players_ready() -> void:
	current_player_id = GameData.current_player.UUID  # atualiza também aqui
	
	for player in GameData.players:
		var instance = player_ui.instantiate()
		if player.UUID == current_player_id:
			player_stats.add_child(instance)
		else:
			container.add_child(instance)
		instance.update_data(player)

# ==========================
# AUXILIAR - reseta o turno
# ==========================
func _reset_turno() -> void:
	turno.visible        = false
	combate.visible      = false
	combate.get_node("Data").text = ""
	GameData.turn_ended.emit()

# ==========================
# REAGE AO INÍCIO DE TURNO
# ==========================
func _on_play_turn_started(player_uuid: String) -> void:
	print("\n----> TURNO INICIOU\n")
	var is_local = player_uuid == current_player_id

	if not is_local:
		bot.Start_turn()
		return
	GameData.turn_ended.emit()
	inicio_turno.visible = true

func _on_combat_turn(player_uuid: String, card: Card) -> void:
	card_turn = card
	var is_local = player_uuid == current_player_id

	if is_local:
		GameData.turn_ended.emit()
		return
		turno.visible = true
		if card.category == "monster":
			combate.visible = true
			combate.get_node("Data").text = card.name
			print("Deu de cara com: ", card.name)
		else:
			end_turn.visible = true
	else:
		print("Deu de cara com: ", card.name)
		await bot.combat(player_uuid, card)
		GameData.turn_ended.emit()

func _on_help_request(_player_uuid: String) -> void:
	helper.visible = true
	await get_tree().create_timer(10.0).timeout
	helper.visible = false

# ==========================
# BOTÕES
# ==========================
func _on_explorar_pressed() -> void:
	inicio_turno.visible = false
	GameData.explorer.emit()
	print("----> Jogador explorou")

func _on_equipar_pressed() -> void:
	pass

func _on_lutar_pressed() -> void:
	var player: Player = GameData.getPlayer(GameData.player_turn)
	if player.get_power() >= card_turn.monster_power:
		print("Venceu: ", card_turn.name)
		player.level_up(card_turn.reward_levels)
	else:
		print("Morreu para: ", card_turn.name)
	_reset_turno()

func _on_fugir_pressed() -> void:
	if randi_range(1, 6) >= 5:
		print("Fugiu com sucesso")
	else:
		print("Você morreu ao fugir")
	_reset_turno()

func _on_invocar_pressed() -> void:
	_reset_turno()

func _on_pedir_ajuda_pressed() -> void:
	pass

func _on_finalizar_pressed() -> void:
	end_turn.visible = false
	turno.visible    = false
	GameData.turn_ended.emit()

func _on_yes_pressed() -> void:
	if GameData.helper_locked:
		return
	GameData.helper_locked = true
	GameData.helper_selected.emit(GameData.current_player.UUID)
	helper.visible = false

func _on_no_pressed() -> void:
	helper.visible = false

extends Node

# ==================================================
# ESTADOS DO TURNO
# ==================================================
enum TurnState {
	WAITING_FOR_PLAYER,
	PLAY_PHASE,
	COMBAT_PHASE,
	END_PHASE
}

# ==================================================
# VARIÁVEIS PRINCIPAIS
# ==================================================
var players: Array[Player] = []
var deck: Deck
var current_player_index: int = 0
var turn_state: int = TurnState.WAITING_FOR_PLAYER
var game_running: bool = true
var combat_system = CombatSystem.new()
var max_players: int = 3

# ==================================================
# READY
# ==================================================
func _ready() -> void:
	GameData.explorer.connect(_on_explorer)
	GameData.turn_ended.connect(_end_turn)
	create_players()
	start_game()

# ==================================================
# CRIA JOGADORES
# ==================================================
func create_players() -> void:
	print("------- CRIANDO JOGADORES -------")

	for i in range(max_players - 1):
		var bot = Player.new()
		bot.setname("Bot" + str(i + 1))
		bot.UUID = "BOTUUID" + str(i)
		players.append(bot)

	var player = GameData.current_player
	if player == null:
		push_error("create_players: current_player é null")
		return

	players.append(player)
	GameData.savePlayers(players.duplicate())  # emite players_ready via sinal
	print("------- JOGADORES CRIADOS -------\n")

# ==================================================
# INICIA O JOGO
# ==================================================
func start_game() -> void:
	print("------- CONFIGURANDO JOGO -------")
	randomize()
	deck = Deck.new()
	distribution_cards()
	print("------- JOGO CONFIGURADO -------\n")
	start_turn()

# ==================================================
# DISTRIBUI CARTAS INICIAIS
# ==================================================
func distribution_cards() -> void:
	print("Distribuindo cartas...")
	for player in players:
		for i in range(5):
			var rand = randi_range(0, deck.cards.size() - 1)
			var drawn = deck.card_by_index(rand)
			player.hand.append(drawn)
			#player.equip_item(drawn)  # equipa automaticamente
	GameData.equipment_equip.emit()  # emite uma única vez ao final

# ==================================================
# INÍCIO DO TURNO
# ==================================================
func start_turn() -> void:
	if not game_running:
		return
	var current_player = players[current_player_index]
	turn_state = TurnState.WAITING_FOR_PLAYER
	print("\n############ TURNO DE -> ", current_player.name, " ############")
	GameData.set_turn(current_player.UUID)

# ==================================================
# FIM DO TURNO
# ==================================================
func _end_turn() -> void:
	turn_state = TurnState.END_PHASE
	print("\n--- FIM DO TURNO DE ", players[current_player_index].name, " ---")

	check_victory(players[current_player_index])  # verifica vitória antes de passar

	if not game_running:
		return

	GameData.players_data_updated.emit()
	next_player()
	start_turn()

# ==================================================
# PRÓXIMO JOGADOR
# ==================================================
func next_player() -> void:
	current_player_index = (current_player_index + 1) % players.size()

# ==================================================
# CHECAGEM DE VITÓRIA
# ==================================================
func check_victory(player: Player) -> void:
	if player.level >= 10:
		print("🏆 JOGADOR ", player.name, " VENCEU!")
		game_running = false

# ==================================================
# EXPLORAR (puxar carta do baralho)
# ==================================================
func _on_explorer() -> void:
	var player = players[current_player_index]
	print("\n----> ", player.name, " INICIOU A EXPLORAÇÃO")

	var drawn_card = deck.draw_card()
	if drawn_card == null:
		print("Sem cartas restantes!")
		game_running = false
		return

	print("\n---- CARTA PUXADA:")
	print("NOME:        ", drawn_card.name)
	print("TIPO:        ", drawn_card.category)
	print("PODER:       ", drawn_card.monster_power)
	print("TESOURO:     ", drawn_card.reward_treasures)
	print("GANHA LEVEL: ", drawn_card.reward_levels)

	if drawn_card.category == "monster":
		turn_state = TurnState.COMBAT_PHASE
	else:
		player.hand.append(drawn_card)
		player.equip_item(drawn_card)

	GameData.combat_phase_started.emit(player.UUID, drawn_card)

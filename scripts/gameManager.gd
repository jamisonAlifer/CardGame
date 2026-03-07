extends Node  # Cena principal do jogo (GameManager)

# ==========================
# ENUM DE ESTADOS DO TURNO
# ==========================
enum TurnState {
	WAITING_FOR_PLAYER,  # Turno começou, esperando ação do jogador
	PLAY_PHASE,          # Jogador jogando cartas ou usando habilidades
	COMBAT_PHASE,        # Combate com carta de monstro ou evento
	END_PHASE            # Turno está para terminar
}

# ==========================
# VARIÁVEIS DE CONTROLE
# ==========================
var players: Array[Player] = []          # Lista de jogadores
var deck: Deck                           # Baralho do jogo
var current_player_index: int = 0        # Jogador atual
var turn_state: int = TurnState.WAITING_FOR_PLAYER
var game_running: bool = true
var card: Card                            # Carta atual
var combat_system = CombatSystem.new()    # Sistema de combate
var max_players: int = 2                  # Número máximo de jogadores
@onready var ui: Control = get_node("../Ui")  # sobe um nível e pega o irmão
# ==========================
# INÍCIO DO JOGO
# ==========================
func _ready():
	ui.explorer.connect(_on_explorer)
	GameData.turn_ended.connect(_end_turn)
	randomize()
	start_game()

# ==========================
# Cria baralho, jogadores e inicia turno
# ==========================
func start_game():
	deck = Deck.new()  # Cria baralho

	# Cria bots
	for i in range(max_players-1):
		var p = Player.new()
		p.setname("Bot"+str(i+1))
		p.UUID = "BOTUUID" + str(i)
		players.append(p)

	
	var player = GameData.current_player
	if player == null: return
	players.append(player)

	# Atualiza GameData
	GameData.savePlayers(players.duplicate())

	# Distribui cartas
	distribution_cards()
	# Simula turno com timer de 5 segundos
	var turn_timer = get_tree().create_timer(1.0)
	print(player.name, " está jogando...")
	await turn_timer.timeout
	# Começa o primeiro turno
	start_turn()
   

# ==========================
# Começa o turno do jogador atual
# ==========================
func start_turn():
	if not game_running:
		return

	var current_player = players[current_player_index]

	# Atualiza estado do turno
	turn_state = TurnState.WAITING_FOR_PLAYER

	# Emite sinal de turno iniciado para o GameData (central)
	GameData.turn_started.emit(current_player.UUID)
	print("\n--- TURNO DE ", current_player.name, "---")
	
	# Entra na fase de jogar cartas / ações
	#turn_state = TurnState.PLAY_PHASE
	#GameData.play_phase_started.emit(current_player.UUID)
	
# ==========================
# Termina o turno do jogador atual e vai para o próximo
# ==========================
func _end_turn():
	turn_state = TurnState.END_PHASE

	# Salva estado
	GameData.savePlayers(players.duplicate())

	# Atualiza índice para próximo jogador
	next_player()

	# Começa novo turno
	start_turn()


# ==========================
# Atualiza índice do jogador atual
# ==========================
func next_player():
	current_player_index += 1
	if current_player_index >= players.size():
		current_player_index = 0

# ==========================
# Distribui cartas
# ==========================
func distribution_cards():
	print("Distribuindo cartas")
	for player in players:
		for i in range(5):
			var rand = randi_range(0, deck.cards.size()-1)
			var card = deck.card_by_index(rand)
			player.hand.append(card)


# ==========================
# Equipa itens automaticamente
# ==========================
func equip(player: Player):
	for item in player.hand:
		player.equip_item(item)
		
func equip_card(card: Card) -> void:
	players[current_player_index].hand.append(card)
	return
# ==========================
# Checa vitória
# ==========================
func check_victory(player: Player):
	if player.level >= 10:
		print("JOGADOR ", player.name, " VENCEU!")
		game_running = false
		
func _on_explorer():
	print("iniciando explorer")
	var player = players[current_player_index]
	# Puxa carta do baralho
	card = deck.draw_card()
	print("carta: ", card.name)
	if card == null:
		print("Sem cartas restantes!")
		game_running = false
		return
	if card.category == "monster":
		turn_state = TurnState.COMBAT_PHASE
		GameData.combat_phase_started.emit(player.UUID, card)
	else:
		# Equipa itens automaticamente
		equip_card(card)

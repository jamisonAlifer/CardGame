extends Node  # Gerenciador principal do jogo (GameManager)

# ==================================================
# ESTADOS DO TURNO
# Controla em qual fase do turno o jogo está
# ==================================================
enum TurnState {
	WAITING_FOR_PLAYER,  # Turno começou, aguardando ação do jogador
	PLAY_PHASE,          # Jogador pode usar cartas / habilidades
	COMBAT_PHASE,        # Combate iniciado
	END_PHASE            # Finalização do turno
}

# ==================================================
# VARIÁVEIS PRINCIPAIS DO JOGO
# ==================================================
var players: Array[Player] = []          # Lista de jogadores da partida
var deck: Deck                           # Baralho principal
var current_player_index: int = 0        # Índice do jogador atual
var turn_state: int = TurnState.WAITING_FOR_PLAYER
var game_running: bool = true            # Controla se a partida ainda está ativa
var card: Card                           # Carta atual puxada do baralho
var combat_system = CombatSystem.new()   # Sistema responsável pelo combate

var max_players: int = 3                 # Número máximo de jogadores

# ==================================================
# INICIALIZAÇÃO DO JOGO
# ==================================================
func _ready():
	GameData.explorer.connect(_on_explorer)       # Botão explorar da UI
	GameData.turn_ended.connect(_end_turn)  # Evento global de fim de turno

	#cria os jogadores
	await create_players()
	
	#inicia o jogo
	start_game()
	
# ==================================================
# CRIA BARALHO, JOGADORES E INICIA O PRIMEIRO TURNO
# ==================================================
func create_players():
	print("------- ------ ------- ------ ------- ------ ------- ------ ------- ------")
	print("------- CRIANDO JOGADORES ------")
		# Criação de bots
	for i in range(max_players - 1):
		var p = Player.new()
		p.setname("Bot" + str(i + 1))
		p.UUID = "BOTUUID" + str(i)
		players.append(p)

	# Adiciona o jogador principal
	var player = GameData.current_player
	if player == null:
		print("play ainda não está pronto")
		return
		
	players.append(player)
	
	print("------- JOGADORES CRIADOS ------")
	print("------- ------ ------- ------ ------- ------ ------- ------ ------- ------\n\n")
	# Atualiza dados globais
	GameData.savePlayers(players.duplicate())
	await get_tree().create_timer(1.0).timeout
	return 
func start_game():
	print("------- ------ ------- ------ ------- ------ ------- ------ ------- ------")
	print("------- CONFIGURANDO JOGO ------")
	randomize()
	
	#instancia o baralho
	deck = Deck.new()
	
	# Distribui cartas iniciais
	distribution_cards()
	print("------- ------ ------- ------ ------- ------ ------- ------ ------- ------\n\n")
	# Inicia o primeiro turno
	start_turn()
	
# ==================================================
# INÍCIO DO TURNO
# ==================================================
func start_turn():
	print("------- ------ ------- ------ ------- ------ ------- ------ ------- ------")
	print("#############  INICIANDO TURNO ##################")
	if not game_running:
		return

	var current_player = players[current_player_index]
	print("TURNO DE  -> ", current_player.name," <-")
	# Estado inicial do turno
	turn_state = TurnState.WAITING_FOR_PLAYER

	# Notifica sistemas externos (UI / lógica)
	#GameData.play_phase_started.emit(current_player.UUID)
	GameData.set_turn(current_player.UUID)
# ==================================================
# FINALIZA O TURNO ATUAL
# ==================================================
func _end_turn():
	turn_state = TurnState.END_PHASE
	
	# Salva estado atual dos jogadores
	GameData.savePlayers(players.duplicate())
	print("\n---FIM DO TURNO DE ",players[current_player_index].name,"---")
	# Passa para o próximo jogador
	next_player()
	# Inicia novo turno
	print("#############  FIM DO TURNO ##################")
	print("------- ------ ------- ------ ------- ------ ------- ------ ------- ------\n\n\n\n\n\n")
	start_turn()
# ==================================================
# DEFINE O PRÓXIMO JOGADOR
# ==================================================
func next_player():
	current_player_index += 1
	
	if current_player_index >= players.size():
		current_player_index = 0

# ==================================================
# DISTRIBUI CARTAS INICIAIS PARA TODOS OS JOGADORES
# ==================================================
func distribution_cards():
	print("Distribuindo cartas")

	for player in players:
		for i in range(5):
			var rand = randi_range(0, deck.cards.size() - 1)
			var card = deck.card_by_index(rand)
			player.hand.append(card)
		GameData.equipment_equip.emit()
# ==================================================
# EQUIPAR ITENS AUTOMATICAMENTE
# ==================================================
func equip(player: Player):
	for item in player.hand:
		player.equip_item(item)

# Adiciona uma carta diretamente à mão do jogador atual
func equip_card(card: Card) -> void:
	players[current_player_index].hand.append(card)
	return

# ==================================================
# CHECAGEM DE VITÓRIA
# ==================================================
func check_victory(player: Player):
	if player.level >= 10:
		print("JOGADOR ", player.name, " VENCEU!")
		game_running = false

# ==================================================
# AÇÃO DE EXPLORAR (Puxar carta do baralho)
# ==================================================
func _on_explorer():
	var player = players[current_player_index]
	print("\n---->",player.name," INICOU A EPLORAÇÃO")
	# Compra carta
	card = deck.draw_card()

	if card == null:
		print("Sem cartas restantes!")
		game_running = false
		return
		
	print("\n ---- DETALHES CARTA:")
	print("NOME:        ", card.name)
	print("TIPO:        ", card.category)
	print("PODER:       ", card.monster_power)
	print("TESOURO:     ", card.reward_treasures)
	print("GANHA LEVEL: ", card.reward_levels)
	
	# Se for monstro, inicia combate
	if card.category == "monster":
		turn_state = TurnState.COMBAT_PHASE
	else:
		#Caso contrário equipa/adiciona ao jogador
		equip_card(card)
	GameData.combat_phase_started.emit(player.UUID, card)

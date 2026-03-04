extends Node

var players: Array[Player] = []
var deck: Deck
var current_player_index: int = 0
var game_running: bool = true
var max_players: int = 2
var card: Card
var combat_system = CombatSystem.new()


func _ready():
	randomize()
	start_game()

func start_game():
	deck = Deck.new()
	
	for i in range(max_players):
		var p = Player.new()
		p.setname("Palyer"+str(i+1)) 
		players.append(p)
	
	distribution_cards()
	start_turn()

func start_turn():
	if not game_running:
		return
	
	var current_player = players[current_player_index]
	
	print("\n--- TURNO DO JOGADOR ", current_player_index + 1, "---")
	
	card = deck.draw_card()
	equip(current_player)
	
	if card == null:
		print("Sem cartas restantes!")
		game_running = false
		return
		
	combat_system.resolve_combat(current_player, card, players)
	deck.cards.erase(card)
	check_victory(current_player)
	next_player()
	start_turn()

func check_victory(player: Player):
	if player.level >= 10:
		print("JOGADOR", current_player_index + 1, "VENCEU O JOGO!")
		game_running = false
		
func next_player():
	current_player_index += 1
	if current_player_index >= players.size():
		current_player_index = 0
		
func distribution_cards():
	for player in players:
		print(player.name)
		for i in range(5):
			var rand = randi_range(0,deck.cards.size()-1)
			var card = deck.card_by_index(rand)
			player.hand.append(card)
			
func equip(player: Player):
	print("verificando equipamentos "+player.name)
	print("cartas na mão "+str(player.hand.size()))
	var itens = player.hand
	for item in itens:
		player.equip_item(item)		

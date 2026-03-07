extends Node

class_name CombatSystem

var bot = BotAi.new()

func resolve_combat(player: Player, card: Card, players: Array) -> void:
	print("jogador deu de cara com "+card.name)
	var total_power = player.get_power() 
	var monster: Card
	if card.category != "monster":
		
		print("Não é um monstro")
		print(card.category)
		for card_m in player.hand:
			if card_m.category == "monster" || card_m.monster_power < total_power:
				monster = card_m
		if monster == null:  return
		print("--- jogador invocou o monstro: "+monster.name)
		card = monster
	
	print("Total de poder combate Player: "+ str(total_power))
	print("Total de poder combate monster: "+ str(card.monster_power))
	
	if total_power < card.monster_power:
		var helper = find_helper(player, total_power, card.monster_power, players)
		if helper:
			total_power += helper.get_power()
			print("Venceu combate com a ajuda de "+helper.name)
			print("Ganhou %d tesouro(s)"%[card.reward_treasures])
			player.level_up(card.reward_levels)  # <-- adiciona os pontos aqui
		else: 
			print("Foi derrotado")
			return
	else:  # vence sozinho ou empata?
		player.level_up(card.reward_levels)
		print("Player venceu o monstro sozinho")
		print("Ganhou %d tesouro(s)"%[card.reward_treasures])
func find_helper(current_player, player_power, monster_power, players):
	for other in players:
		if other == current_player:
			continue

		if player_power + other.get_power() >= monster_power:
			print("pediu ajuda para o jogador "+ other.name)
			var result= bot.should_help(current_player,other)
			if result:
				return other
	return null

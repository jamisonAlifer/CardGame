extends Node

class_name CombatSystem

var bot = BotAi.new()

func resolve_combat(player: Player, card: Card, players: Array) -> void:
	print("jogador deu de cara com "+card.name)
	
	if card.category != "monster":
		player.hand.append(card)
		return
		
	var total_power = player.get_power() + randi() % 3
	print("Total de poder comabate Player: "+ str(total_power))
	print("Total de poder comabate monster: "+ str(card.monster_power))
	if total_power < card.monster_power:
		var helper = find_helper(player, total_power, card.monster_power, players)
		if helper:
			total_power += helper.get_power()
			print("Venceu combate com a ajuda de "+helper.name)
		else: 
			print("Foi derrotado")
	elif total_power > card.monster_power:
		player.level_up(card.reward_levels)
		print("Player venceu o monstro sozinho")
	else: 
			print("Foi derrotado")			
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

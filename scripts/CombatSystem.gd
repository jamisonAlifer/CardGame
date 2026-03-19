extends Node

class_name CombatSystem

var bot = BotAi.new()

func resolve_combat(player: Player, card: Card):
	print("jogador deu de cara com Combatsystem"+card.name)
	var total_power = player.get_power()
	var monster: Card
	if card.category != "monster":
		
		print("Não é um monstro")
		print(card.category)
		for card_m in player.hand:
			if card_m.category == "monster" && card_m.monster_power < total_power:
				monster = card_m
		if monster == null:
			print("-->Finalizando turno bot<---")
			return
		print("--- jogador invocou o monstro: "+monster.name)
		card = monster
	
	print("Total de poder combate Player: "+ str(total_power))
	print("Total de poder combate monster: "+ str(card.monster_power))
	
	if total_power < card.monster_power:
		var helper = await find_helper(player)
		if helper:
			total_power += helper.get_power()
			print("Venceu combate com a ajuda de "+helper.name)
			print("Ganhou %d tesouro(s)"%[card.reward_treasures])
			player.level_up(card.reward_levels)  # <-- adiciona os pontos aqui
		else:
			print("Foi derrotado")
			return true
	else:  # vence sozinho ou empata?
		player.level_up(card.reward_levels)
		print("Player venceu o monstro sozinho")
		print("Ganhou %d tesouro(s)"%[card.reward_treasures])
	return true
	
var helper_uuid = null
var helper_callback

func find_helper(current_player):

	helper_uuid = null

	GameData.helper_locked = false
	GameData.find_helper.emit(current_player)
	helper_callback = func(uuid):
		if helper_uuid == GameData.player_turn:
			return
		elif helper_uuid == null:
			helper_uuid = uuid

	GameData.helper_selected.connect(helper_callback)

	await get_tree().create_timer(10.0).timeout

	GameData.helper_selected.disconnect(helper_callback)

	if helper_uuid == null:
		print("Ninguém quis ajudar")
		return null

	return GameData.getPlayer(helper_uuid)

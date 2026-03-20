extends Node

class_name  BotAi
var bot: Player
# Called when the node enters the scene tree for the first time.
var combatsystem: CombatSystem

func _ready() -> void:
	combatsystem = CombatSystem.new()
	add_child(combatsystem)

func Start_turn(): 
	bot = GameData.getPlayer(GameData.player_turn)
	await get_tree().create_timer(1.0).timeout
	verify_equipament()
	print("\n\nchegou aqui famillllll")
	await get_tree().create_timer(1.5).timeout
	GameData.explorer.emit()
func should_help(player: Player, player_help: Player):
	var requester_distance = 10 - player.level
	var helper_distance = 10 - player_help.level
	if(requester_distance <= 3 || helper_distance <= 3):
		return false
	if(helper_distance >= 4 || requester_distance >= 4):
		return true
		
func combat(player_uuid, card: Card):
	if combatsystem == null:
		print("Combatsystem não inicializado!")
		return
	var bot: Player = GameData.getPlayer(player_uuid)
	await combatsystem.resolve_combat(bot, card)
	return

func verify_equipament():
	print("\n\n----- tentnado equipar itens: ")
	for iten in bot.hand:
		if iten.category == "equipment":
			bot_equip_item(iten)
		await get_tree().create_timer(1.0).timeout	
		
func bot_equip_item(item: Card) -> void:
	if not bot.equipment.has(item.slot):
		print("Equipamento não pode ser usado: "+ item.name)
		return
	
	var slot_data = bot.equipment[item.slot]
	
	# Special rule for hand (hands_required)
	if item.slot == "hands":
		var used_hands := 0
		for equipped in slot_data["items"]:
			print("\n\nITEM: ",item.name," Equipado por ", bot.name)
			used_hands += equipped.hands_required
		if used_hands + item.hands_required > slot_data["max"]:
			print("Mãos sem espaço: "+ item.name)
			return
	
	if slot_data["items"].size() < slot_data["max"]:
		print("\n\nITEM: ",item.name," Equipado por ", bot.name)
		slot_data["items"].append(item)
		print(item.slot)
		bot.hand.erase(item)

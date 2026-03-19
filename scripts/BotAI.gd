extends Node

class_name  BotAi
# Called when the node enters the scene tree for the first time.
var combatsystem: CombatSystem

func _ready() -> void:
	combatsystem = CombatSystem.new()
	add_child(combatsystem)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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

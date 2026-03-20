extends Control

@onready var img = $Container/bg_img/img
@onready var poder = $Container/bg_pw/Label
@onready var lvl = $Container/bg_lvl/Label
@onready var class_player = $Container/bg_clss/Label
@onready var name_player = $Container/bg_name/Label
var player: Player

func _ready() -> void:
	GameData.players_data_updated.connect(_on_update_in_game)
	GameData.play_phase_started.connect(_on_player_turn)
	
func update_data(data: Player):
	if data == null: return
	player = data
	poder.text = str(data.get_power())
	lvl.text = str(data.level)
	#class_player.text = data._class
	name_player.text = data.name
	
func _on_update_in_game()-> void:
	if player == null: return
	poder.text = str(player.get_power())
	lvl.text = str(player.level)
	
func _on_player_turn(id):
	var is_you_turn = id == player.UUID
	print("\n ------------------ Vez de ",player.name," :", str(is_you_turn))
	$is_turn.visible = is_you_turn
	
	

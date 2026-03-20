extends Control

@onready var solt01 = $Container/Slot01/Slot_data/Label
@onready var solt02 = $Container/Slot02/Slot_data/Label
@onready var solt02_01 = $Container/Slot02/Slot_data2/Label
@onready var solt03 = $Container/Slot03/Slot_data/Label
@onready var solt04 = $Container/Slot04/Slot_data/Label
@onready var solt05 = $Container/Slot05/Slot_data/Label


func _ready() -> void:
	update_equipments_data() 
	

func update_equipments_data() -> void:
	var eq = GameData.current_player.equipment

	solt01.text    = str(_get_power(eq["head"],  0))  # cabeça
	solt02.text    = str(_get_power(eq["hand"],  0))  # mão 1
	solt02_01.text = str(_get_power(eq["hand"],  1))  # mão 2
	solt03.text    = str(_get_power(eq["chest"], 0))  # torso
	solt04.text    = str(_get_power(eq["legs"],  0))  # pernas
	solt05.text    = str(_get_power(eq["feet"],  0))  # pés

# pega o power_bonus de um item específico do slot pelo índice
func _get_power(slot: Dictionary, index: int) -> int:
	if index >= slot["items"].size():
		return 0  # slot vazio
	return slot["items"][index].stats.get("power_bonus", 0)

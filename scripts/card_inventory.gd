extends Control

@onready var container: VBoxContainer = $VBoxContainer
@onready var player: Player = GameData.current_player

func _ready():
	GameData.equipment_equip.connect(update)
	update()

func update():
	for child in container.get_children():
		child.queue_free()

	for card_data in player.hand:
		var btn := CardButton.new()  # agora é do tipo CardButton
		btn.text = card_data.name
		btn.card = card_data
		btn.player = player
		container.add_child(btn)

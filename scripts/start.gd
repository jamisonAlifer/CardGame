extends Control

@onready var input = $Panel/LineEdit
@onready var btn = $Panel/Button

func _ready() -> void:
	var data = GameData.load_config()
	
	var turn_timer = get_tree().create_timer(1.0)
	await turn_timer.timeout
	
	$Panel3.visible = false
	if data != null:
		$Panel2.visible = true
		$Panel2/Label.text = data
	else:
		$Panel.visible = true
		input.grab_focus()

func _on_button_pressed() -> void:
	next_scene()

func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text.strip_edges().is_empty():
		return
	next_scene()

func next_scene():
	if $Panel.visible:
		GameData.create_player(input.text)
	get_tree().change_scene_to_file("res://cenas/main.tscn")

extends Control

@onready var input = $Panel/LineEdit
@onready var btn = $Panel/Button

func _ready() -> void:
	input.grab_focus()

func _on_button_pressed() -> void:
	if input.text.strip_edges().is_empty():
		return
	next_scene()

func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text.strip_edges().is_empty():
		return
	next_scene()

func next_scene():
	GameData.create_player(input.text)
	get_tree().change_scene_to_file("res://cenas/main.tscn")

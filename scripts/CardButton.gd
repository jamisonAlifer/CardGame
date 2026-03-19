class_name CardButton
extends Button

var card: Card
var player: Player

func _get_drag_data(_at_position):
	var preview = duplicate()
	set_drag_preview(preview)
	visible = false  # esconde o botão enquanto arrasta
	return self

func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_DRAG_BEGIN:
		print("Drag começou")
	elif what == Node.NOTIFICATION_DRAG_END:
		var success = get_viewport().gui_is_drag_successful()
		print("Drag terminou. Success:", success)
		# Se não foi bem-sucedido, restaura visibilidade
		if not success:
			visible = true

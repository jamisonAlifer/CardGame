extends Control

var dragging := false
var drag_offset := Vector2.ZERO
var original_position := Vector2.ZERO

func _ready():
	print(str(original_position))
	print(str(position))
	original_position = global_position
	mouse_filter = Control.MOUSE_FILTER_STOP  # impede clique atravessar

func _gui_input(event):
	print("----"+ str(original_position))
	print("----"+ str(position))
	if event is InputEventMouseButton:
		# começou o clique
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if get_global_rect().has_point(get_global_mouse_position()):
				dragging = true
				drag_offset = get_global_mouse_position() - global_position
				accept_event()  # garante que o evento não vá para outras cartas

		# soltou o botão
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if dragging:
				dragging = false
				check_drop()
				accept_event()

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position() - drag_offset

func check_drop():
	print("Soltou carta")

	for slot in get_tree().get_nodes_in_group("card_slot"):
		if slot.get_global_rect().has_point(get_global_mouse_position()):
			slot.try_receive(self)
			return
	
	# se não caiu em slot
	global_position = original_position

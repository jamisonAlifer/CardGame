extends Control

signal clicked
signal hovered
signal unhovered

var original_scale := Vector2(1, 1)
var hover_scale := Vector2(1.1, 1.1)
var original_position: Vector2
var original_z := 0
var hover_z := 100
var original_rotate := 0.0
var tween: Tween
var card: Card
var player: Player
var dragging := false
var drag_offset := Vector2.ZERO

func _ready() -> void:
	_set_children_mouse_filter(self)
	original_position.y = global_position.y
	original_z = z_index

func _set_children_mouse_filter(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_children_mouse_filter(child)

func update_card(c: Card) -> void:
	card = c
	$Card/Name.text = c.name
	$Card/Type.text = c.category
	match c.category:
		"monster":
			$Card/Power.text = str(c.monster_power)
			$Card/Equipment.text = ""
			$Card/Slots.text = ""
		"equipment":
			$Card/Power.text = ""
			$Card/Equipment.text = c.slot
			$Card/Slots.text = str(c.hands_required)
		_:
			$Card/Power.text = ""
			$Card/Equipment.text = ""
			$Card/Slots.text = ""

func _animate_card(pos_y: float, target_scale: Vector2, target_rotation: float) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", pos_y, 0.15)
	tween.tween_property(self, "scale", target_scale, 0.15)
	tween.tween_property(self, "rotation", target_rotation, 0.15)

func _on_mouse_entered() -> void:
	if dragging: return
	original_position.y = position.y
	original_rotate = rotation  # só salva rotate aqui pois pode mudar no layout
	z_index = hover_z
	_animate_card(-35, hover_scale, 0)
	hovered.emit()

func _on_mouse_exited() -> void:
	if dragging: return
	z_index = original_z
	_animate_card(original_position.y, original_scale, original_rotate)
	unhovered.emit()

func _get_drag_data(at_position: Vector2) -> Variant:
	dragging = true
	
	# cria um container vazio como wrapper
	var wrapper = Control.new()
	wrapper.custom_minimum_size = size
	
	var preview = duplicate()
	preview.set_script(null)
	# offset negativo para centralizar
	preview.position = Vector2(-50, -100)  # testa com valores fixos
	
	wrapper.add_child(preview)
	set_drag_preview(wrapper)
	return self

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		dragging = false
		# volta pra posição original se não houve drop
		if not get_viewport().gui_is_drag_successful():
			z_index = original_z
			scale = original_scale
			_animate_card(original_position.y, original_scale, original_rotate)

@tool
extends Control
class_name Chip

signal clicked

@export var pins: Array[Pin] = []:
	set(new_pins):
		pins = new_pins
		queue_redraw()
		
		for pin in pins:
			if pin:
				pin.changed.connect(func(): queue_redraw())
		
func get_color() -> Color:
	match(chip_type):
		Global.ChipType.CPU:
			return Color.LAWN_GREEN
	return Color.WHITE
	
@export var chip_type: Global.ChipType = Global.ChipType.CPU:
	set(new_chip_type):
		chip_type = new_chip_type
		caption = _get_new_caption()
		queue_redraw()
		
@export var caption := "":
	set(new_caption):
		caption = new_caption
		notify_property_list_changed()
		queue_redraw()
		
@export var bytes := PackedByteArray()

const _hex_editor_scene := preload("res://Chips/HexEditor.tscn")
var _hex_editor: HexEditor
		
func _get_new_caption() -> String:
	var caption: String
	match(chip_type):
		Global.ChipType.CPU:
			caption = "CPU"
	
	var board := _get_board()
	if board:
		var index := 1
		var ok := false
		var base_caption = caption
		caption = base_caption + str(index)
		while not ok:
			ok = true
			for child in board.get_children():
				if child and child != self and child is Chip and (child as Chip).caption == caption:
					index += 1
					caption = base_caption + str(index)
					ok = false
					break
	return caption

func _draw_centered_string(font: Font, str: String, modulate_color: Color):
	var string_size := font.get_string_size(str)
	draw_string(font, -string_size / 2 + Vector2(0, font.get_ascent()) + size / 2, str, 0, -1, 16, modulate_color)

var left_pins: Array[int] = []
var top_pins: Array[int] = []
var right_pins: Array[int] = []
var bottom_pins: Array[int] = []
var pin_locations: Array[Vector2] = []

func _update_pin_geometry() -> void:
	# init
	left_pins.clear()
	top_pins.clear()
	right_pins.clear()
	bottom_pins.clear()
	pin_locations.clear()
	
	# count the pins
	var i := 0
	for pin in pins:
		if pin:
			match(pin.location):
				Pin.Location.LEFT:
					left_pins.append(i)
				Pin.Location.TOP:
					top_pins.append(i)
				Pin.Location.RIGHT:
					right_pins.append(i)
				Pin.Location.BOTTOM:
					bottom_pins.append(i)
		i += 1
	
	# compute the pin geometry
	pin_locations.resize(pins.size())
	
	i = 0
	for pin_id in left_pins:
		pin_locations[pin_id] = Vector2(0, 5 + (size.y - 10) / (left_pins.size() + 1) * (i + 1))
		i += 1

	i = 0
	for pin_id in right_pins:
		pin_locations[pin_id] = Vector2(size.x, 0) + Vector2(0, 5 + (size.y - 10) / (right_pins.size() + 1) * (i + 1))
		i += 1

	i = 0
	for pin_id in top_pins:
		pin_locations[pin_id] = Vector2(5 + (size.x - 10) / (top_pins.size() + 1) * (i + 1), 0)
		i += 1
		
	i = 0
	for pin_id in bottom_pins:
		pin_locations[pin_id] = Vector2(0, size.y) + Vector2(5 + (size.x - 10) / (bottom_pins.size() + 1) * (i + 1), 0)
		i += 1

func _get_board() -> Board:
	return get_parent() as Board

func _draw() -> void:
	_update_pin_geometry()
	var color := get_color()
			
	_draw_centered_string(Global.font, caption, color)
	draw_rect(Rect2(Vector2.ZERO, size), color, false, 2.0)
					
	for pin_id in left_pins:
		var base := pin_locations[pin_id]
		draw_line(base - Vector2(5, 0), base + Vector2(5, 0), color, 2)
		draw_string(Global.font, base + Vector2(10, 6), str(pin_id))
				
	for pin_id in right_pins:
		var base := pin_locations[pin_id]
		draw_line(base - Vector2(5, 0), base + Vector2(5, 0), color, 2)
		draw_string(Global.font, base + Vector2(-20, 6), str(pin_id))

	for pin_id in top_pins:
		var base := pin_locations[pin_id]
		draw_line(base - Vector2(0, 5), base + Vector2(0, 5), color, 2)
		draw_string(Global.font, base + Vector2(-5, 25), str(pin_id))

	for pin_id in bottom_pins:
		var base := pin_locations[pin_id]
		draw_line(base - Vector2(0, 5), base + Vector2(0, 5), color, 2)
		draw_string(Global.font, base + Vector2(-5, -12), str(pin_id))

func _enter_tree() -> void:
	caption = _get_new_caption()
	var parent := get_parent() as Board
	if parent:
		parent.child_chip_added(self)

func _ready() -> void:
	size = Vector2(200, 100)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not event.canceled:
		var event_local := make_input_local(event)
		if not Rect2(Vector2.ZERO, size).has_point(event_local.position):
			return
		
		# show editor
		if not _hex_editor:
			var board := _get_board()
			
			_hex_editor = _hex_editor_scene.instantiate()
			_hex_editor.bind_chip(self)
			_hex_editor.set_anchors_preset(PRESET_TOP_LEFT)
			_hex_editor.size = Vector2(board.size * 0.9)
			_hex_editor.position = board.position + board.size * 0.05
			board.add_child(_hex_editor)
		_hex_editor.show()
		
		clicked.emit()

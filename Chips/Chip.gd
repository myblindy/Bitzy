@tool
extends Node2D
class_name Chip

@export var pins: Array[Pin] = []:
	set(new_pins):
		pins = new_pins
		_update_pin_geometry()
		queue_redraw()
		
		for pin in pins:
			if pin:
				pin.changed.connect(func(): queue_redraw())
		
@export var size := Vector2(200, 100):
	set(new_size):
		size = new_size
		queue_redraw()
		
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
		
var _font: Font

func _draw_centered_string(font: Font, str: String, modulate_color: Color):
	var string_size := font.get_string_size(str)
	draw_string(font, -string_size / 2 + Vector2(0, font.get_ascent()), str, 0, -1, 16, modulate_color)

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
		pin_locations[pin_id] = -size / 2 + Vector2(0, 5 + (size.y - 10) / (left_pins.size() + 1) * (i + 1))
		i += 1		

	i = 0
	for pin_id in right_pins:
		pin_locations[pin_id] = Vector2(size.x, -size.y) / 2 + Vector2(0, 5 + (size.y - 10) / (right_pins.size() + 1) * (i + 1))
		i += 1		

	i = 0
	for pin_id in top_pins:
		pin_locations[pin_id] = -size / 2 + Vector2(5 + (size.x - 10) / (top_pins.size() + 1) * (i + 1), 0)
		i += 1		
		
	i = 0
	for pin_id in bottom_pins:
		pin_locations[pin_id] = Vector2(-size.x, size.y) / 2 + Vector2(5 + (size.x - 10) / (bottom_pins.size() + 1) * (i + 1), 0)
		i += 1		


func _get_board() -> Board:
	return get_parent() as Board

func _draw() -> void:
	var color := get_color()
			
	_draw_centered_string(_font, caption, color)
	draw_rect(Rect2(-size / 2, size), color, false, 2.0)
					
	for pin_id in left_pins:
		var base := pin_locations[pin_id]
		draw_line(base - Vector2(5, 0), base + Vector2(5, 0), color, 2)
		draw_string(_font, base + Vector2(10, 6), str(pin_id))
				
	for pin_id in right_pins:
		var base := pin_locations[pin_id]
		draw_line(base - Vector2(5, 0), base + Vector2(5, 0), color, 2)
		draw_string(_font, base + Vector2(-20, 6), str(pin_id))

	for pin_id in top_pins:
		var base := pin_locations[pin_id]
		draw_line(base - Vector2(0, 5), base + Vector2(0, 5), color, 2)
		draw_string(_font, base + Vector2(-5, 25), str(pin_id))

	for pin_id in bottom_pins:
		var base := pin_locations[pin_id]
		draw_line(base - Vector2(0, 5), base + Vector2(0, 5), color, 2)
		draw_string(_font, base + Vector2(-5, -12), str(pin_id))

func _enter_tree() -> void:
	caption = _get_new_caption()
	var parent := get_parent() as Board
	if parent:
		parent.child_chip_added(self)

func _ready() -> void:
	_font = Control.new().get_theme_default_font()

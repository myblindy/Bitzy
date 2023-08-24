@tool
extends Node2D

@export var pins: Array[Pin]:
	set(new_pins):
		pins = new_pins
		queue_redraw()
		
@export var chip_type: Global.ChipType = Global.ChipType.CPU:
	set(new_chip_type):
		chip_type = new_chip_type
		queue_redraw()
		
var _font: Font

func _draw_centered_string(font: Font, rect: Rect2, str: String, modulate: Color):
	var string_size := font.get_string_size(str)
	draw_string(font, -string_size / 2 + Vector2(0, font.get_ascent()), str, 0, -1, 16, modulate)

func _draw() -> void:
	var size: Vector2
	var color: Color
	
	match(chip_type):
		Global.ChipType.CPU:
			size = Vector2(200, 100)
			color = Color.LAWN_GREEN
			
			_draw_centered_string(_font, Rect2(-size / 2, size), "CPU", color)
	
	draw_rect(Rect2(-size / 2, size), color, false, 2.0)
	
	# count the pins
	var left_pins: Array[int] = []
	var top_pins: Array[int] = []
	var right_pins: Array[int] = []
	var bottom_pins: Array[int] = []

	var i := 0
	for pin in pins:
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
				
	i = 0
	for pin_id in left_pins:
		var base := -size / 2 + Vector2(0, 5 + (size.y - 10) / (left_pins.size() + 1) * (i + 1))
		draw_line(base - Vector2(5, 0), base + Vector2(5, 0), color, 2)
		draw_string(_font, base + Vector2(10, 6), str(pin_id))
		i += 1		
				
	i = 0
	for pin_id in right_pins:
		var base := Vector2(size.x, -size.y) / 2 + Vector2(0, 5 + (size.y - 10) / (right_pins.size() + 1) * (i + 1))
		draw_line(base - Vector2(5, 0), base + Vector2(5, 0), color, 2)
		draw_string(_font, base + Vector2(-20, 6), str(pin_id))
		i += 1

	i = 0
	for pin_id in top_pins:
		var base := -size / 2 + Vector2(5 + (size.x - 10) / (top_pins.size() + 1) * (i + 1), 0)
		draw_line(base - Vector2(0, 5), base + Vector2(0, 5), color, 2)
		draw_string(_font, base + Vector2(-5, 25), str(pin_id))
		i += 1

	i = 0
	for pin_id in bottom_pins:
		var base := Vector2(-size.x, size.y) / 2 + Vector2(5 + (size.x - 10) / (bottom_pins.size() + 1) * (i + 1), 0)
		draw_line(base - Vector2(0, 5), base + Vector2(0, 5), color, 2)
		draw_string(_font, base + Vector2(-5, -12), str(pin_id))
		i += 1

func _ready() -> void:
	_font = Control.new().get_theme_default_font()

func _process(delta: float) -> void:
	pass

extends Control
class_name HexEditor

const _font: Font = preload("res://Fonts/FiraCode-Medium.woff2")
const _font_size := 16.0
var _font_character_size := Vector2.ZERO

var _chip: Chip
func bind_chip(chip: Chip):
	_chip = chip
	_build_ui()
	
func _build_ui():
	if not is_inside_tree() or size == Vector2.ZERO or _font_character_size == Vector2.ZERO:
		return
		
	for line in get_tree().get_nodes_in_group("lines"):
		remove_child(line)
		
	# figure out the geometry
	var line_count := floorf(size.y / _font_character_size.y)
	for i in range(0, line_count):
		var label := Label.new()
		label.add_theme_font_override("font", _font)
		label.add_theme_font_size_override("font_size", _font_size)
		label.text = "moopsies " + str(i)
		label.position.y = _font_character_size.y * i
		
		add_child(label)
		label.add_to_group("lines")
	
func _ready() -> void:
	if _font_character_size == Vector2.ZERO:
		_font_character_size = _font.get_string_size("0", HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size)
	
	resized.connect(_build_ui)
	_build_ui()

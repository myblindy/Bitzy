extends Control
class_name HexEditor

const _bytes_per_row := 16
const _font_size := 16.0
var _font_character_size := Vector2.ZERO
var _line_number_width: float

@onready var _lines_container := $VBoxContainer/LinesContainer
@onready var _cursor := $VBoxContainer/LinesContainer/Cursor

var _selected_character_index := Vector2i.ZERO:
	set(new_selected_character_index):
		_selected_character_index = new_selected_character_index
		_update_selected_character()

var _chip: Chip
func bind_chip(chip: Chip) -> void:
	_chip = chip
	_build_ui()
	
func _build_ui() -> void:
	if not is_inside_tree() or size == Vector2.ZERO or _font_character_size == Vector2.ZERO:
		return
		
	for line in get_tree().get_nodes_in_group("lines"):
		if is_ancestor_of(line):
			remove_child(line)
	for line in get_tree().get_nodes_in_group("lines_header"):
		if is_ancestor_of(line):
			remove_child(line)
	for line in get_tree().get_nodes_in_group("line_numbers"):
		if is_ancestor_of(line):
			remove_child(line)
		
	# figure out the geometry
	var line_count := int(floorf(_lines_container.size.y / _font_character_size.y))
	_line_number_width = Global.font.get_string_size("0000 ", 0, -1, _font_size).x
	
	for i in range(0, line_count):
		# line number
		if i > 0:
			var label := Label.new()
			label.add_theme_font_size_override("font_size", _font_size)
			label.position = Vector2(0, _font_character_size.y * i)
			label.modulate = Color.WEB_GRAY
			label.text = "%04X" % (i - 1)
			
			_lines_container.add_child(label)
			label.add_to_group("line_numbers")
		
		# line data
		var label := Label.new()
		label.add_theme_font_size_override("font_size", _font_size)
		label.position = Vector2(_line_number_width, _font_character_size.y * i)
		
		if i == 0:
			label.modulate = Color.WEB_GRAY
			for idx in range(_bytes_per_row):
				label.text += "%02X " % idx
		
		_lines_container.add_child(label)
		label.add_to_group("lines" if i > 0 else "lines_header")
		
	_set_ui_current_view()
	
func _set_ui_current_view() -> void:
	var line_idx := 0
	for line in get_tree().get_nodes_in_group("lines"):
		if is_ancestor_of(line) and _chip.bytes:
			line.text = ""
			for byte in _chip.bytes.slice(line_idx * _bytes_per_row, (line_idx + 1) * _bytes_per_row):
				line.text += "%02X " % byte
			line_idx += 1
	_update_selected_character()
	
func _update_selected_character() -> void:
	var selected_column_index := _selected_character_index.x / 2 * 3
	if _selected_character_index.x % 2:
		selected_column_index += 1
	_cursor.position = Vector2(5 +  selected_column_index, 2 + _selected_character_index.y) * _font_character_size \
		- Vector2(0, 4)
		
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_RIGHT:
			_selected_character_index = Vector2(_selected_character_index.x + 1, _selected_character_index.y)
	
func _ready() -> void:
	if _font_character_size == Vector2.ZERO:
		_font_character_size = Global.font.get_string_size("0", HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size)
	
	_cursor.size = Vector2(_font_character_size.x, 2)
	$VBoxContainer/HBoxContainer/CloseButton.pressed.connect(func(): hide())
	_lines_container.resized.connect(_build_ui)

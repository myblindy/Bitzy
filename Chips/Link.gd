@tool
extends Resource
class_name Link

@export var chip1: Chip:
	set(new_chip1):
		chip1 = new_chip1
		emit_changed()
		
@export var pin1: int:
	set(new_pin1):
		pin1 = new_pin1
		emit_changed()
		
@export var chip2: Chip:
	set(new_chip2):
		chip2 = new_chip2
		emit_changed()
		
@export var pin2: int:
	set(new_pin2):
		pin2 = new_pin2
		emit_changed()

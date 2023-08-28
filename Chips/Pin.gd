@tool
class_name Pin
extends Resource

enum Location { LEFT, TOP, RIGHT, BOTTOM }
@export var location: Location:
	set(new_location):
		location = new_location
		emit_changed()

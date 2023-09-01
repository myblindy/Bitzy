@tool
extends Control
class_name Board

@export var links: Array[Link] = []:
	set(new_links):
		links = new_links
		_rebuild_links()
		
func _rebuild_links() -> void:
	pass

func child_chip_added(chip: Chip) -> void:
	chip.clicked.connect(func():
		pass)

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

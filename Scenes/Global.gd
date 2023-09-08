class_name Global

const font: Font = preload("res://Fonts/FiraCode-Medium.woff2")

enum ChipType { CPU }

class IntMargin:
	var left: int
	var top: int
	var right: int
	var bottom: int
	
	func _init(left: int, top: int, right: int, bottom: int):
		self.left = left
		self.top = top
		self.right = right
		self.bottom = bottom

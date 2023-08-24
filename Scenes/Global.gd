class_name Global

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

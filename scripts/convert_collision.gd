extends CollisionShape2D

@export var parent: Area2D
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	update_color_rect_size()
	update_color_rect_color()

func update_color_rect_size() -> void:
	var rectshape = shape
	if rectshape is RectangleShape2D:
		var size = shape.extents * 2.0
		color_rect.size = size
		color_rect.position = -shape.extents
func update_color_rect_color() -> void:
	var parent_name = parent.TYPE_NAMES[parent.type_index]
	var color: Color
	match parent_name:
		"int": color = Color(0.2, 0.6, 1.0, 0.5)  # blue-ish
		"float": color = Color(0.5, 0.9, 0.3, 0.5)  # green-ish
		"str": color = Color(1.0, 0.8, 0.2, 0.5)  # yellow/orange
		"bool": color = Color(1.0, 0.3, 0.3, 0.5)  # red-ish
		_: color = Color(1.0, 1.0, 1.0, 0.05)   # default faint white
	color_rect.color = color

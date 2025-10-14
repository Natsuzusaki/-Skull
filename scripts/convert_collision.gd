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
	var parent_name = parent.TYPE_NAMES[parent.initial_type]
	var color: Color
	match parent_name:
		"int": color = Color(0.2, 0.6, 1.0, 0.5)
		"float": color = Color(0.5, 0.9, 0.3, 0.5)
		"str": color = Color(1.0, 0.8, 0.2, 0.5)
		"bool": color = Color(1.0, 0.3, 0.3, 0.5)
		_: color = Color(1.0, 1.0, 1.0, 0.05)
	var tween = create_tween()
	tween.tween_property(color_rect, "color", color, 0.3) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

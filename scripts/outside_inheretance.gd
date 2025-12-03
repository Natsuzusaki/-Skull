extends Marker2D

@export var parent : Node2D

func _ready() -> void:
	if parent:
		global_position = parent.global_position

func _process(_delta: float) -> void:
	if parent:
		global_position = parent.global_position

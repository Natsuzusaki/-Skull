extends Node2D

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("skip"):
		Engine.time_scale = 1
func _ready() -> void:
	Engine.time_scale = 1

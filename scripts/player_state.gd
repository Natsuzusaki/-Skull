extends Node2D
class_name PlayerState

@export var animation_name: String
@export var move_speed: int

var parent: Player

func enter() -> void:
	if parent.stay:
		parent.animation.play("idle")
	else:
		parent.animation.play(animation_name)
func exit() -> void:
	pass

func process_input(_event:InputEvent) -> PlayerState:
	return null
func process_frame(_delta: float) -> PlayerState:
	return null
func process_physics(_delta: float) -> PlayerState:
	return null

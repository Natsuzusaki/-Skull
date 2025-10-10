extends Node2D
class_name PlayerState

@export var animation_name: String
@export var move_speed: int

var parent: Player

func enter() -> void:
	if parent.stay:
		animation("idle")
	else:
		animation(animation_name)
func exit() -> void:
	pass

func animation(anim_name: String) -> void:
	parent.animation.play(anim_name)
	parent.animation2.play(anim_name)
	parent.animation3.play(anim_name)

func process_input(_event:InputEvent) -> PlayerState:
	return null
func process_frame(_delta: float) -> PlayerState:
	return null
func process_physics(_delta: float) -> PlayerState:
	return null

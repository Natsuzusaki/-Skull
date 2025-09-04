extends StaticBody2D

@export var new_pos: Vector2
var target: Vector2
var status := false

func activate(continuous: bool, time: float) -> void:
	if not continuous:
		status = not status
	target = (global_position + new_pos) if not status else (global_position - new_pos)
	var tween = create_tween()
	tween.tween_property(self, "global_position", target, time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

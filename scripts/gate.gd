extends StaticBody2D

@export var new_pos: Vector2

func activate(time: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "global_position", new_pos, time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

extends StaticBody2D

@export var new_pos: Vector2
@export var min_limit: Vector2
@export var max_limit: Vector2
@export var move_in_x: bool
@export var move_in_y: bool
var target: Vector2
var status := false

func activate(continuous: bool, time: float) -> void:
	if not continuous:
		status = not status
	target = (global_position + new_pos) if not status else (global_position - new_pos)
	var tween = create_tween()
	tween.tween_property(self, "global_position", target, time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func move(value) -> void:
	var newpos: Vector2
	if move_in_x:
		newpos = Vector2(value, 0)
	elif move_in_y:
		newpos = Vector2(0, value)
	else:
		return
	target = global_position + newpos
	target.x = clamp(target.x, min_limit.x, max_limit.x)
	target.y = clamp(target.y, min_limit.y, max_limit.y)
	var tween = create_tween()
	tween.tween_property(self, "global_position", target, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

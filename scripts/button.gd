extends Node2D
@export var output1: Node2D
@export var output2: Node2D
@export var output3: Node2D
@onready var label: Label = $Label
@onready var turn_on: Sprite2D = $TurnOn
@onready var turn_on_near: Sprite2D = $TurnOnNear
@onready var turn_off: Sprite2D = $TurnOff
@onready var turn_off_near: Sprite2D = $TurnOffNear
var disabled := false
var is_near := false
var button_status := false #false-off, true-on

func _on_body_entered(_body: Node2D) -> void:
	is_near = true
	label.visible = true

func _on_body_exited(_body: Node2D) -> void:
	is_near = false
	label.visible = false

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("carry") and label.visible and not disabled:
		button_status = not button_status
		if output1 is RigidBody2D:
			output1.gravity_scale = 1.0 if button_status else -1.0
		if output1 is StaticBody2D:
			disabled = true
			var target = output1.global_position + (Vector2(0, 120) if button_status else Vector2(0, -120))
			var tween = create_tween()
			tween.tween_property(output1, "global_position", target, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
func _process(_delta: float) -> void:
	label.visible = false
	turn_on_near.visible = false
	turn_on.visible = false
	turn_off_near.visible = false
	turn_off.visible = false
	if disabled:
		if button_status:
			turn_on.visible = true
		else:
			turn_off.visible = true
		return
	if button_status:
		if is_near:
			label.visible = true
			turn_on_near.visible = true
		else:
			turn_on.visible = true
	else:
		if is_near:
			label.visible = true
			turn_off_near.visible = true
		else:
			turn_off.visible = true

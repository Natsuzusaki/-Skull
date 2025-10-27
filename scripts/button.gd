extends Node2D
##disables after one use if true
@export var one_use: bool = false 
@export_group("Only turn on when One_Use is off")
##if true the output will be the same every activation
@export var continuous: bool = false 
@export_group("Outputs")
@export var active_time: float = 0.1
@export var outputs: Array[Node2D] = []

@onready var turn_on: Sprite2D = $TurnOn
@onready var turn_on_near: Sprite2D = $TurnOnNear
@onready var turn_off: Sprite2D = $TurnOff
@onready var turn_off_near: Sprite2D = $TurnOffNear
@onready var disable: Sprite2D = $Disabled
@onready var activation_cooldown: Timer = $ActivationCooldown
@onready var button: AnimatedSprite2D = $Button

var cooldown := false
var disabled := false
var is_near := false
var button_status := false #false-off, true-on

func _on_body_entered(_body: Node2D) -> void:
	is_near = true
	button.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_body_exited(_body: Node2D) -> void:
	is_near = false
	button.modulate = Color(1.0, 1.0, 1.0, 0.0)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("carry") and not disabled and not cooldown and is_near:
		activate()

func activate() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.LEVEL_BUTTON)
	cooldown = true
	activation_cooldown.start(active_time)
	button_status = not button_status
	for output in outputs:
		if output == null:
			continue
		if output is StaticBody2D or output is RigidBody2D:
			output.activate(continuous, active_time)
		elif output is Area2D:
			if output.is_in_group("LoopRoom"):
				output.activate = false
			else:
				output.change()
		elif output is Camera2D:
			output.unlock()
	if one_use:
		disabled = true

func _on_activation_cooldown_timeout() -> void:
	cooldown = false

func _process(_delta: float) -> void:
	turn_on_near.visible = false
	turn_on.visible = false
	turn_off_near.visible = false
	turn_off.visible = false
	disable.visible = false
	if disabled or cooldown:
		disable.visible = true
		return
	if button_status:
		if is_near:
			turn_on_near.visible = true
		else:
			turn_on.visible = true
	else:
		if is_near:
			turn_off_near.visible = true
		else:
			turn_off.visible = true

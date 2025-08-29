extends Area2D

@export var output1: Node2D
@export var output2: Node2D
@export var output3: Node2D

@onready var pressure_off: Sprite2D = $Pressure_Off
@onready var pressure_on: Sprite2D = $Pressure_On
var pressed := false

func _on_body_entered(_body: Node2D) -> void:
	pressed = true

func _on_body_exited(_body: Node2D) -> void:
	pressed = false

func _process(_delta: float) -> void:
	if pressed:
		pressure_on.visible = true
		pressure_off.visible = false
	else:
		pressure_on.visible = false
		pressure_off.visible = true

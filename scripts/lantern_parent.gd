extends Node2D

@export var wind_on: bool = true
@export var wind_strength: float = 10000.0
@onready var lantern_physics: RigidBody2D = $LanternPhysics

func _ready() -> void:
	lantern_physics.wind_enable = wind_on
	lantern_physics.wind_strength = wind_strength

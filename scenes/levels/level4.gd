extends Node2D

@onready var camera: Camera2D = %Camera
@onready var player: CharacterBody2D = %Player

func _ready() -> void:
	camera.back()

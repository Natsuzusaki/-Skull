extends Area2D

@export var tp_left : int
@export var tp_right : int
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var collision_shape2: CollisionShape2D = $CollisionShape2D2
@onready var area: Area2D = $Area
@onready var camera: Camera2D = %Camera
var activate := false

func _process(_delta: float) -> void:
	set_collision_disabled(not activate)

func _on_room_loop_body_entered(body: Node2D) -> void:
	var room_pos = global_position
	if body.position.x < room_pos.x:
		body.position.x = tp_right
	elif body.position.x > room_pos.x:
		body.position.x = tp_left

func set_collision_disabled(value: bool) -> void:
	collision_shape.disabled = value
	collision_shape2.disabled = value

func _on_area_body_entered(_body: Node2D) -> void:
	activate = true
	camera.lock()
	area.set_deferred("monitoring", false)

extends Area2D

@export var tp_left : Vector2
@export var tp_right : Vector2
@export var push : bool = false
@export var crystal_ctr : int = 1
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var collision_shape2: CollisionShape2D = $CollisionShape2D2
@onready var collision_shape3: CollisionShape2D = $CollisionShape2D3
@onready var area: Area2D = $Area
@onready var camera: Camera2D = %Camera
var activate := false
var loop_ctr := 0

signal looptriggered

func _process(_delta: float) -> void:
	set_collision_disabled(not activate)

func _on_room_loop_body_entered(body: Node2D) -> void:
	loop_ctr += 1
	var room_pos = global_position
	if body.global_position.x < room_pos.x:
		print("right")
		body.global_position = tp_right
		if push:
			body.jump()
	elif body.global_position.x > room_pos.x:
		print("left")
		body.global_position = tp_left
		if push:
			body.jump_side()
	looptriggered.emit(self.name, loop_ctr, false)

func set_collision_disabled(value: bool) -> void:
	collision_shape.disabled = value
	collision_shape2.disabled = value
	collision_shape3.disabled = value

func _on_area_body_entered(_body: Node2D) -> void:
	activate = true
	camera.lock()
	area.set_deferred("monitoring", false)

func speak() -> void:
	looptriggered.emit(self.name, loop_ctr, true)

extends Node2D

@export var console: Area2D
@export var min_limit: Vector2
@export var max_limit: Vector2
@export var move_in_x: bool
@export var move_in_y: bool
@export var spawn_horizontal: bool
@onready var instance_time: Timer = $InstanceTime
@onready var int_object = preload("res://scenes/environment_elements/int_object.tscn")
@onready var str_object = preload("res://scenes/environment_elements/str_object.tscn")
@onready var bool_object = preload("res://scenes/environment_elements/bool_object.tscn")
@onready var float_object = preload("res://scenes/environment_elements/float_object.tscn")
var original_pos: Vector2
var target: Vector2
var type := 0 #0-integer, 1-string, 2-boolean, 3-float
var blocked := false

func _ready() -> void:
	original_pos = global_position
	console.print_value.connect(_print_value)
func _print_value(_value, array_value) -> void:
	for v in array_value:
		spawn_object(v)
		instance_time.start()
		await instance_time.timeout

func spawn_object(value) -> void:
	var object_spawn
	if not blocked:
		if value is String:
			#print('s')
			if value.length() > console.characterlimit:
				value = value.substr(0, console.characterlimit)
			object_spawn = str_object.instantiate()
		elif value is float:
			#print('f')
			object_spawn = float_object.instantiate()
			object_spawn.apply_impulse(Vector2(0, 50))
		elif value is int:
			#print('i')
			object_spawn = int_object.instantiate()
		elif value is bool:
			#print('b')
			object_spawn = bool_object.instantiate()
		else:
			return
		object_spawn.initialize(value)
		call_deferred("_add_object_to_scene", object_spawn)

func _add_object_to_scene(object_spawn: Node2D) -> void:
	get_tree().get_current_scene().find_child("Objects").add_child(object_spawn)
	if spawn_horizontal:
		object_spawn.rotation_degrees = 90
		object_spawn.position = position + Vector2(0, 50)
	else:
		object_spawn.position = position + Vector2(0, 10)

func _on_blocked_area_body_entered(_body: Node2D) -> void:
	blocked = true
func _on_blocked_area_body_exited(_body: Node2D) -> void:
	blocked = false

func move(value) -> void:
	var newpos: Vector2
	if move_in_x:
		newpos = Vector2(value, 0)
	elif move_in_y:
		newpos = Vector2(0, value * -1)
	else:
		return
	target = original_pos + newpos
	target.x = clamp(target.x, min_limit.x, max_limit.x)
	target.y = clamp(target.y, min_limit.y, max_limit.y)
	var tween = create_tween()
	tween.tween_property(self, "global_position", target, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

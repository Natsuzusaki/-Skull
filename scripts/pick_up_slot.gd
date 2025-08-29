extends Control

@onready var object = preload("res://scenes/int_object.tscn")
@onready var pick_up_area: Area2D = $PickUp_Area
@onready var text: Label = $Text
@onready var player: CharacterBody2D = null
var current_obj = null
var previous_obj = null

signal pass_value_to_codeblocks()
signal in_area()

func _ready() -> void:
	player = get_tree().get_current_scene().find_child("Player")

func _on_pick_up_area_body_entered(body: Node2D) -> void:
	if body.value is int:
		pass_value_to_codeblocks.emit(body.value)
		if current_obj or current_obj == 0:
			#print("Instance: prev: " + str(previous_obj) + " curr: " + str(current_obj))
			var object_spawn = object.instantiate()
			object_spawn.initialize(current_obj)
			call_deferred("add_object_to_scene", object_spawn)
			object_spawn.global_position = pick_up_area.global_position + Vector2(0, -30)
			var throw_force = Vector2(150 * player.static_direction, -150)
			object_spawn.apply_torque((object_spawn.mass * 10000) * player.static_direction)
			object_spawn.apply_impulse(throw_force)
		
		body.pass_value_to_pickupslot.connect(_pass_value_from_object)
		in_area.emit(body)

func add_object_to_scene(object_spawn):
	get_tree().get_current_scene().find_child("Objects").add_child(object_spawn)

func _on_pick_up_area_body_exited(_body: Node2D) -> void:
	pass

func _pass_value_from_object(value) -> void:
	if value is int:
		previous_obj = current_obj
		current_obj = value
		if not previous_obj:
			previous_obj = current_obj
		text.text = str(current_obj)
		#print("Passing: prev: " + str(previous_obj) + " curr: " + str(current_obj))

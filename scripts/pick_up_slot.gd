extends Control

@onready var int_object = preload("res://scenes/environment_elements/int_object.tscn")
@onready var float_object = preload("res://scenes/environment_elements/float_object.tscn")
@onready var pick_up_area: Area2D = $PickUp_Area
@onready var text: Label = $Text
var current_obj: Variant = null
var previous_obj: Variant = null

signal pass_value_to_codeblocks() 

func _ready() -> void:
	pass

func _on_pick_up_area_body_entered(body: Node2D) -> void:
	if not (body is RigidBody2D):
		return
	if body.scene_file_path == float_object.resource_path:
		return
	var v: Variant = null
	if body.has_method("get_value_and_destroy"):
		v = body.get_value_and_destroy()
	else:
		v = body.value
		body.queue_free()
	if not (v is int):
		return
	previous_obj = current_obj
	current_obj = v
	text.text = str(current_obj)
	pass_value_to_codeblocks.emit(v)
	if previous_obj != null:
		var object_scene = int_object
		var object_spawn = object_scene.instantiate()
		object_spawn.initialize(previous_obj)
		call_deferred("add_object_to_scene", object_spawn)
		object_spawn.global_position = pick_up_area.global_position + Vector2(0, -30)
		var throw_force = Vector2(130, -150)
		object_spawn.apply_torque((object_spawn.mass * 10000))
		object_spawn.apply_impulse(throw_force)

func add_object_to_scene(object_spawn):
	get_tree().get_current_scene().find_child("Objects").add_child(object_spawn)

func _on_pick_up_area_body_exited(body: Node2D) -> void:
	if body.has_signal("pass_value_to_pickupslot"):
		if body.pass_value_to_pickupslot.is_connected(_pass_value_from_object):
			body.pass_value_to_pickupslot.disconnect(_pass_value_from_object)

func _pass_value_from_object(value) -> void:
	if value is int or value is float:
		previous_obj = current_obj
		current_obj = value
		if not previous_obj:
			previous_obj = current_obj
		text.text = str(current_obj)
		#print("Passing: prev: " + str(previous_obj) + " curr: " + str(current_obj))

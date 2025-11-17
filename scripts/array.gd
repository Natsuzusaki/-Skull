# ArrayObject.gd
extends Node2D

@export var arr_name: String
@export var initial_input = []
@onready var fill_0: Sprite2D = $Fill0
@onready var fill_1: Sprite2D = $Fill1
@onready var fill_3: Sprite2D = $Fill3
@onready var fill_5: Sprite2D = $Fill5
@onready var fill_10: Sprite2D = $Fill10
@onready var str_object = load("res://scenes/environment_elements/str_object.tscn")
@onready var float_object = load("res://scenes/environment_elements/float_object.tscn")
@onready var int_object = load("res://scenes/environment_elements/int_object.tscn")
@onready var bool_object = load("res://scenes/environment_elements/bool_object.tscn")
var inputs: Array = []
var spawn_object

signal array_action()

func _ready() -> void: 
	if initial_input: 
		for input in initial_input: 
			inputs.append(input) 
	filled()
func _on_area_entered(body: Node2D) -> void: 
	var obj = body.get_parent() 
	if obj: 
		inputs.append(obj.value) 
		obj.queue_free()
		array_action.emit("print_fill", obj.value)
	filled()
	print(inputs)

#Sprite Update
func filled() -> void:
	reset()
	if inputs.size() >= 10:
		fill_10.visible = true
	elif inputs.size() >= 5:
		fill_5.visible = true
	elif inputs.size() >= 3:
		fill_3.visible = true
	elif inputs.size() >= 1:
		fill_1.visible = true
	elif inputs.is_empty():
		fill_0.visible = true 
func reset() -> void:
	fill_0.visible = false
	fill_1.visible = false
	fill_3.visible = false
	fill_5.visible = false
	fill_10.visible = false

#Array Commands
func append(value) -> void:
	inputs.append(value)
	array_action.emit("append_fill", value)
	filled()
	print(inputs)
func clear() -> void:
	inputs.clear()
	array_action.emit("cleared")
	filled()
	print(inputs)
func remove(value) -> void:
	inputs.erase(value)
	array_action.emit("removed", value)
	filled()
	print(inputs)
func pop(arg: Variant = null):
	if inputs.is_empty():
		return
	if arg == null:
		return _pop_by_index(inputs.size() - 1)
	if typeof(arg) == TYPE_INT:
		if arg >= 0 and arg < inputs.size():
			return _pop_by_index(arg)
		return
	var idx := inputs.find(arg)
	if idx != -1:
		return _pop_by_index(idx)
func _pop_by_index(index: int):
	var value = inputs[index]
	inputs.remove_at(index)
	if typeof(value) == TYPE_INT:
		spawn_object = int_object.instantiate()
	elif typeof(value) == TYPE_FLOAT:
		spawn_object = float_object.instantiate()
	elif typeof(value) == TYPE_STRING:
		spawn_object = str_object.instantiate()
	elif typeof(value) == TYPE_BOOL:
		spawn_object = bool_object.instantiate()
	else:
		spawn_object = null
	if spawn_object:
		spawn_object.initialize(value)
		spawn(spawn_object)
	array_action.emit("popped", value, index)
	filled()
	print(inputs)
	return value

func insert(index, value) -> void:
	inputs.insert(index, value)
	array_action.emit("inserted", value, index)
	filled()
	print(inputs)
func sort() -> void:
	array_action.emit("sorted")
	inputs.sort()
	print(inputs)

#Accessing Array in []
func set_at(index: int, value):
	if index < inputs.size() and index >= 0:
		inputs[index] = value
	elif index == inputs.size():
		inputs.append(value)
	array_action.emit("replaced", value, index)
	print(inputs)
func get_at(index: int):
	if index >= 0 and index < inputs.size():
		return inputs[index]
	return null
func _set(property, value):
	if typeof(property) == TYPE_INT:
		set_at(property, value)
		return true
	return false
func _get(property):
	if typeof(property) == TYPE_INT:
		return get_at(property)
	return null

#Iteration/Loops
func _iter_init(_arg):
	return 0
func _iter_next(state):
	state += 1
	return state
func _iter_get(state):
	if state < inputs.size():
		return inputs[state]
	return null

func spawn(object_spawn:Node2D) -> void:
	get_tree().get_current_scene().find_child("Objects").add_child(object_spawn)
	object_spawn.position = position + Vector2(0, -40)
	object_spawn.apply_impulse(Vector2(300,-100))

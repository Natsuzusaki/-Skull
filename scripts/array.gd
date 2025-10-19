# ArrayObject.gd
extends Node2D

@export var arr_name: String
@export var initial_input = []
var inputs: Array = []

func _ready() -> void: 
	if initial_input: 
		for input in initial_input: 
			inputs.append(input) 
func _on_area_entered(body: Node2D) -> void: 
	var obj = body.get_parent() 
	if obj: 
		inputs.append(obj.value) 
		obj.queue_free()
	print(inputs)

func append(value) -> void:
	inputs.append(value)
	print(inputs)
func clear() -> void:
	inputs.clear()
	print(inputs)
func remove(value) -> void:
	inputs.erase(value)
	print(inputs)
func pop() -> void:
	if inputs.size() > 0:
		inputs.pop_back()
	print(inputs)
func insert(index, value) -> void:
	inputs.insert(index, value)
	print(inputs)
func sort() -> void:
	inputs.sort()
	print(inputs)

#Accessing Array in []
func set_at(index: int, value):
	if index < inputs.size() and index >= 0:
		inputs[index] = value
	elif index == inputs.size():
		inputs.append(value)
	print(inputs)
func get_at(index: int):
	if index >= 0 and index < inputs.size():
		return inputs[index]
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

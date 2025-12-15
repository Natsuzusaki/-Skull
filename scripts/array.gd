# ArrayObject.gd
extends Node2D

@onready var player: Player = %Player
@export var console: Node2D
@export var arr_name: String
@export var display_name: String
@export var initial_input = []
@export var pop_direction: bool = false
@onready var fill_0: Sprite2D = $Fill0
@onready var fill_1: Sprite2D = $Fill1
@onready var fill_3: Sprite2D = $Fill3
@onready var fill_5: Sprite2D = $Fill5
@onready var fill_10: Sprite2D = $Fill10
@onready var out_line: Sprite2D = $OutLine
@onready var instance_timer: Timer = $InstanceTimer
@onready var idle_timer: Timer = $IdleTimer
@onready var camera: Camera2D = %Camera
@onready var str_object = load("res://scenes/environment_elements/str_object.tscn")
@onready var float_object = load("res://scenes/environment_elements/float_object.tscn")
@onready var int_object = load("res://scenes/environment_elements/int_object.tscn")
@onready var bool_object = load("res://scenes/environment_elements/bool_object.tscn")
var popped_values := []
var clicked: bool = false
var inputs: Array = []
var spawn_object
signal array_action()
signal array_changed(new_value)

func _ready() -> void: 
	if initial_input: 
		for input in initial_input: 
			inputs.append(input) 
	filled()
func _on_area_entered(body: Node2D) -> void: 
	var status = player.is_carrying
	var obj = body.get_parent() 
	if obj: 
		inputs.append(obj.value) 
		obj.queue_free()	
		status = not status
		array_action.emit("print_fill", arr_name, obj.value)
		SfxManager.play_sfx(sfx_settings.SFX_NAME.PICKUP)
	filled()
	print(inputs)

func outline(activate:bool) -> void:
	if activate:
		out_line.visible = true
	else:
		out_line.visible = false

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
	array_action.emit("append_fill", arr_name, value)
	filled()
	_emit_after_camera_restore(null)
	print(inputs)
func clear() -> void:
	inputs.clear()
	array_action.emit("cleared", arr_name)
	filled()
	_emit_after_camera_restore(null)
	print(inputs)
func remove(value) -> void:
	inputs.erase(value)
	array_action.emit("removed", arr_name, value)
	filled()
	_emit_after_camera_restore(null)
	print(inputs)
func pop(arg: Variant = null):
	if inputs.is_empty():
		return
	idle_timer.stop()
	idle_timer.start()
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
		popped_values.append(spawn_object)
	array_action.emit("popped", arr_name, value, index)
	_emit_after_camera_restore(null)
	filled()
	print(inputs)
	return value

func insert(index, value) -> void:
	inputs.insert(index, value)
	array_action.emit("inserted", arr_name, value, index)
	filled()
	_emit_after_camera_restore(null)
	print(inputs)
func sort() -> void:
	array_action.emit("sorted", arr_name)
	inputs.sort()
	_emit_after_camera_restore(null)
	print(inputs)
func size() -> void:
	array_action.emit("sized", arr_name)
	if console:
		console.prevent_close = true
		console.stay()
		console.label.text = "The size of " + arr_name + " is: " + str(len(inputs))
	print(len(inputs))

#Accessing Array in []
func set_at(index: int, value):
	if index < inputs.size() and index >= 0:
		inputs[index] = value
	elif index == inputs.size():
		inputs.append(value)
	array_action.emit("replaced", arr_name, value, index)
	_emit_after_camera_restore(null)
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

func wait(time: float) -> void:
	await get_tree().create_timer(time).timeout
func spawn(object_spawn:Node2D) -> void:
	var direction : int
	if pop_direction:
		direction = 1
	else:
		direction = -1
	get_tree().get_current_scene().find_child("Objects").add_child(object_spawn)
	object_spawn.position = position + Vector2(0, 10)
	object_spawn.apply_impulse(Vector2(300 * direction, 0))
func delayed_spawn() -> void:
	for v in popped_values:
		spawn(v)
		instance_timer.start()
		await instance_timer.timeout
func _on_idle_timer_timeout() -> void:
	await delayed_spawn()
	popped_values.clear()
func _emit_after_camera_restore(value):
	if camera.zoom.distance_to(camera.zoom_out) > 0.01:
		await camera.zoom_restored
	array_changed.emit(value)

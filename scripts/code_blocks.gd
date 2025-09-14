extends Node2D

@export_multiline var statement: String
@export var outputs: Array[Node2D] = []
@export var is_a_variable: bool
@export var stored_val_access: Array[Node2D] = []

@onready var pick_up_slot: Control = $FirstLine/SecondLine/PickUp_Slot
@onready var func_name: Label = $FirstLine/Func_name
@onready var statement1: Label = $FirstLine/SecondLine/Statement1

var stored_value: Variant = null

func _ready() -> void:
	if is_a_variable:
		pick_up_slot.pass_value_to_codeblocks.connect(_store_value)
	else:
		pick_up_slot.pass_value_to_codeblocks.connect(_receive_value)
	var lines = statement.split("\n")
	func_name.text = lines[0]
	statement1.text = lines[1]

func _store_value(value: int) -> void:
	stored_value = value
	for output in stored_val_access:
		if output == null:
			continue
		if output.has_method("receive_value"):
			output.receive_value(stored_value)
func get_value() -> Variant:
	return stored_value

func _consume_value(value: int) -> void:
	var processed_value = value * 32
	_propagate(processed_value)

func _receive_value(value: int) -> void:
	var processed_value = value * 32
	_propagate(processed_value)

func _propagate(value: int) -> void:
	for output in outputs:
		if output == null:
			continue
		if output.has_method("move"):
			output.move(value)

extends Node2D

@export_multiline var statement: String
@export var outputs: Array[Node2D] = []

@onready var pick_up_slot: Control = $FirstLine/SecondLine/PickUp_Slot
@onready var func_name: Label = $FirstLine/Func_name
@onready var statement1: Label = $FirstLine/SecondLine/Statement1

func _ready() -> void:
	pick_up_slot.pass_value_to_codeblocks.connect(_pass_value_from_pickupslot)
	var lines = statement.split("\n")
	func_name.text = lines[0]
	statement1.text = lines[1]

func _pass_value_from_pickupslot(value: int) -> void:
	value = value * 10
	var target = value
	for output in outputs:
		if output == null:
			continue
		output.move(target)

func _process(_delta: float) -> void:
	pass

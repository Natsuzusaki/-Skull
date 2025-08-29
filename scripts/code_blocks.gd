extends Control

@export_multiline var statement: String
@export var output_1: Node2D
@export var output_2: Node2D
@export var output_3: Node2D

@onready var pick_up_slot: Control = $FirstLine/SecondLine/PickUp_Slot
@onready var func_name: Label = $FirstLine/Func_name
@onready var statement1: Label = $FirstLine/SecondLine/Statement1

var limit := 0

func _ready() -> void:
	pick_up_slot.pass_value_to_codeblocks.connect(_pass_value_from_pickupslot)
	var lines = statement.split("\n")
	func_name.text = lines[0]
	statement1.text = lines[1]

func _pass_value_from_pickupslot(value: int) -> void:
	limit = value * -1

func _process(_delta: float) -> void:
	if output_1.position.y > limit:
		output_1.position.y -= 1
	elif output_1.position.y < limit:
		output_1.position.y += 1

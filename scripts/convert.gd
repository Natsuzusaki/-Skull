extends Area2D

@export_enum("int", "float", "str", "bool") var type_index
@onready var label: Label = $Panel/Label

const TYPE_NAMES = ["int", "float", "str", "bool"]

func _ready() -> void:
	label.text = "%s()" % TYPE_NAMES[type_index]

func _on_area_entered(body: Node2D) -> void:
	var parent = body.get_parent()
	if parent.has_method("convert_type"):
		var type_str = TYPE_NAMES[type_index]
		parent.convert_type(type_str)

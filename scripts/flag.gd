extends Node

@export var flag_name: String = ""
signal flagged(flag_name:String, body:Node2D)

func _ready() -> void:
	add_to_group("flags")

func _on_body_entered(body: Node2D) -> void:
	if flag_name != "":
		flagged.emit(flag_name, body)

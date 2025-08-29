extends Node2D

@onready var instructions: Node2D = %Instructions
@onready var notes: Node2D = %Notes
var controls: Array = [] #true
var tips: Array = [] #false

func _ready() -> void:
	for child in instructions.get_children():
		child.visible = false
		controls.append(child)
	for child in notes.get_children():
		child.visible = false
		tips.append(child)

func hide_note() -> void:
	for child in instructions.get_children():
		child.visible = false
	for child in notes.get_children():
		child.visible = false

func show_note(value: int, type: bool) -> void:
	hide_note()
	if type:
		var note = controls[value]
		note.visible = true
	else:
		var note = tips[value]
		note.visible = true

extends Node2D

@onready var instructions: Node2D = %Instructions
var notes: Array = [] 

func _ready() -> void:
	for child in instructions.get_children():
		child.visible = false
		notes.append(child)

func hide_note() -> void:
	for child in instructions.get_children():
		child.visible = false

func show_note(value: int) -> void:
	hide_note()
	var note = notes[value]
	note.visible = true

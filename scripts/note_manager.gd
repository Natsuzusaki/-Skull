extends CanvasLayer

@onready var instructions: Node2D = %Instructions
var notes: Array = [] 

func _ready() -> void:
	self.visible = false
	for child in instructions.get_children():
		child.visible = false
		notes.append(child)

func hide_note() -> void:
	self.visible = false
	for child in instructions.get_children():
		child.visible = false

func show_note(value: int) -> void:
	hide_note()
	self.visible = true
	var note = notes[value]
	note.visible = true

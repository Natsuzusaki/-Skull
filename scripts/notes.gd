extends Area2D

@export var on: bool = true
@export var type: bool
@export var note_num: int
@export var note_manager: Node2D
@export var blur: Control

@onready var note: Sprite2D = $Note
@onready var note_near: Sprite2D = $Note_Near
@onready var label: Label = $Label
@onready var player: Player = %Player

var near := false

signal actions_sent(flag_name:String)

func _on_body_entered(_body: Node2D) -> void:
	if on:
		near = true
		note.visible = false
		note_near.visible = true
		label.visible = true

func _on_body_exited(_body: Node2D) -> void:
	if on:
		near = false
		note.visible = true
		note_near.visible = false
		label.visible = false

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("carry") and near:
		if note_manager.visible:
			blur.visible = false 
			note_manager.visible = false
			player.stay = false
			actions_sent.emit("note_closed")
		elif not note_manager.visible:
			note_manager.show_note(note_num, type)
			blur.visible = true
			note_manager.visible = true
			player.stay = true
			actions_sent.emit("note_interacted")

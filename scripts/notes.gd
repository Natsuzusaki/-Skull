extends Area2D

@export var on: bool = true
@export var note_num: int

@onready var note: Sprite2D = $Note
@onready var note_near: Sprite2D = $Note_Near
@onready var label: Label = $Label
@onready var player: Player = %Player

var show_status := false
var near := false

signal actions_sent(flag_name:String)

func _on_body_entered(_body: Node2D) -> void:
	if on:
		near = true
		note.visible = false
		note_near.visible = true
		label.visible = true
		player.near_note = true

func _on_body_exited(_body: Node2D) -> void:
	if on:
		near = false
		note.visible = true
		note_near.visible = false
		label.visible = false
		player.near_note = false

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("carry") and near:
		SfxManager.play_sfx(sfx_settings.SFX_NAME.NOTE)
		if show_status:
			show_status = false 
			NoteManager.hide_note()
			player.stay = false
			actions_sent.emit("note_closed")
		elif not show_status:
			show_status = true
			NoteManager.show_note(note_num)
			player.stay = true
			actions_sent.emit("note_interacted")

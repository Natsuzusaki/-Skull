extends Area2D

@export var on: bool = true
@export var note_num: int

@onready var note: Sprite2D = $Note
@onready var note_near: Sprite2D = $Note_Near
@onready var button: AnimatedSprite2D = $Button
@onready var player: Player = %Player

var show_status := false
var near := false

signal actions_sent(flag_name:String, num:int)

func _on_body_entered(_body: Node2D) -> void:
	if on:
		near = true
		note.visible = false
		note_near.visible = true
		button.visible = true
		player.near_note = true

func _on_body_exited(_body: Node2D) -> void:
	if on:
		near = false
		note.visible = true
		note_near.visible = false
		button.visible = false
		player.near_note = false

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("carry") and near:
		if not show_status:
			SfxManager.play_sfx(sfx_settings.SFX_NAME.NOTE)
			show_status = true
			NoteManager.show_note(note_num)
			player.on_note = true
			player.stay = true
			player.collision.scale = Vector2(2.5, 1.5)
			player.collision.position = Vector2(0, -7.143)
			actions_sent.emit("note_interacted", note_num)
	if Input.is_action_just_pressed("pause") and near:
		if show_status:
			get_viewport().set_input_as_handled()
			SfxManager.play_sfx(sfx_settings.SFX_NAME.NOTE)
			show_status = false 
			NoteManager.hide_note()
			player.on_note = false
			player.stay = false
			player.collision.scale = Vector2(1,1)
			player.collision.position = Vector2(0, -2.143)
			actions_sent.emit("note_closed", note_num)
		elif not show_status:
			pass

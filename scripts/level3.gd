extends Node2D
@onready var player: Player = %Player
@onready var printer: Node2D = $Printers/Printer
@onready var console: Area2D = $Consoles/Console
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var grid: CanvasLayer = $Grid
@onready var lantern_8: Node2D = $Lanterns/Lantern8
@onready var lantern_9: Node2D = $Lanterns/Lantern9
@onready var console_4: Area2D = $Consoles/Console4
@onready var camera: Camera2D = %Camera
@onready var consoles: Node2D = %Consoles
@onready var printers: Node2D = $Printers

@onready var if_1: Control = $Labels/if1
@onready var if_2: Control = $Labels/if2
@onready var if_3: Control = $Labels/if3
@onready var if_4: Control = $Labels/if4
@onready var if_5: Control = $Labels/if5
@onready var if_6: Control = $Labels/if6
@onready var timerr: Node = $Time
@onready var ui_level_complete: Control = $"UI's/UI_LevelComplete"


var data = SaveManager.load_game()
var ctr := false

var a = 12 > 3
#var b = false
#var c = null
#var d = false
#
#var e:bool


func _ready() -> void:
	#e = (a and not b) and (c or d == false)
	#print("test: ",e)
	print("a: ", a)
	
	MusicManager.play_music_with_fade("res://assets/music/[2-18] White Cliffs - Cave Story Remastered Soundtrack.mp3")
	if_1.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if_2.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if_3.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if_4.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if_5.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if_6.modulate = Color(1.0, 1.0, 1.0, 0.0)
	
		
	if data.has("Chapter3"):
		var chapter3 = data["Chapter3"]
		if chapter3.has("player_pos"):
			var pos = chapter3["player_pos"]
			player.global_position = Vector2(pos[0], pos[1])
		if chapter3.has("checkpoint_order"):
			var checkpoint = chapter3["checkpoint_order"]
			if checkpoint >= 1.0:
				ctr = true
			if checkpoint == 2.0:
				SaveManager.restore_objects()
		if chapter3.has("current_timer"):
			timerr.time = chapter3["current_timer"]
			timerr.update_display() 

func _process(_delta: float) -> void:
	if player.on_console:
		grid.visible = false
		timerr.visible = true

	
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("grid") and not player.on_console and not player.stay:
		if not grid.visible:
			grid.visible = true
			timerr.visible = false
		else:
			grid.visible = false
			timerr.visible = true
	if Input.is_action_just_pressed("pause") and not player.on_console and not player.stay:
		if not get_tree().paused:
			_pause_game()
			get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed("debug") and not player.stay:
		_save_timer_to_json()
		get_tree().reload_current_scene()
func _pause_game() -> void:
	get_tree().paused = true
	Pause.paused()

	
func _on_area_2d_body_entered(_body: Node2D) -> void:
	var duration = 0.5
	var tween := create_tween()
	tween.tween_property(if_1, "modulate", Color(1.0, 1.0, 1.0, 1.0), duration)
func _on_area_2d_2_body_entered(_body: Node2D) -> void:
	var duration = 0.5
	var tween := create_tween()
	tween.tween_property(if_2, "modulate", Color(1.0, 1.0, 1.0, 1.0), duration)
func _on_area_2d_3_body_entered(_body: Node2D) -> void:
	var duration = 0.5
	var tween := create_tween()
	tween.tween_property(if_3, "modulate", Color(1.0, 1.0, 1.0, 1.0), duration)
func _on_area_2d_4_body_entered(_body: Node2D) -> void:
	var duration = 0.5
	var tween := create_tween()
	tween.tween_property(if_4, "modulate", Color(1.0, 1.0, 1.0, 1.0), duration)
	
func _on_area_2d_5_body_entered(_body: Node2D) -> void:
	var duration = 0.5
	var tween := create_tween()
	tween.tween_property(if_5, "modulate", Color(1.0, 1.0, 1.0, 1.0), duration)

func _on_area_2d_6_body_entered(_body: Node2D) -> void:
	var duration = 0.5
	var tween := create_tween()
	tween.tween_property(if_6, "modulate", Color(1.0, 1.0, 1.0, 1.0), duration)


# Example: In a _on_level_complete signal or exit function
#func complete_level() -> void:
	#var time_node = $Time
	#SaveManager.save_level_completion("Chapter3", time_node, true)  # true for best-time min
	#
	## Optionally save other progress
	#var new_data = {"Chapter3": {"completed": true}}
	#SaveManager.update_save(new_data)
	#
	## Change to next scene/menu
	#get_tree().change_scene_to_file("res://scenes/next_level.tscn")  # Or main_menu
func _save_timer_to_json() -> void:
	SaveManager.save_timer_for_session("Chapter3", timerr.time)

func _on_finish_body_entered(_body: Node2D) -> void:
	player.stay = true
	ui_level_complete.drop_down()
	var time_node = $Time
	SaveManager.save_level_completion("Chapter3", time_node, true)  # true for best-time min
	MusicManager.set_volume(0)
	SaveManager.mark_level_completed(3)

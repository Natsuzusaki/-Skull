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
@onready var notes: Node2D = %Notes
@onready var printers: Node2D = $Printers
@onready var chapter_intro: CanvasLayer = $ChapterIntro
@onready var progress_bar: CanvasLayer = $ProgressBar
@onready var note_ui: CanvasLayer = $Note_UI

@onready var if_1: Control = $Labels/if1
@onready var if_2: Control = $Labels/if2
@onready var if_3: Control = $Labels/if3
@onready var if_4: Control = $Labels/if4
@onready var if_5: Control = $Labels/if5
@onready var if_6: Control = $Labels/if6
@onready var timerr: CanvasLayer = $Time
@onready var ui_level_complete: Control = $UIs/UI_LevelComplete

@onready var gate: StaticBody2D = $Gates/Gate
@onready var customizable_platform_2: TileMapLayer = $Platforms/Customizable_Platform2
@onready var int_object: RigidBody2D = $Objects/Int_Object
@onready var gate_8: StaticBody2D = $Gates/Gate8
@onready var gate_9: StaticBody2D = $Gates/Gate9
@onready var gate_11: StaticBody2D = $Gates/Gate11


var current_chapter = "Chapter3"
var data = SaveManager.load_game()
var talk_ctr := 0



func _ready() -> void:
	MusicManager.play_music_with_fade("res://assets/music/[2-18] White Cliffs - Cave Story Remastered Soundtrack.mp3", 0.03)
	if_1.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if_2.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if_3.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if_4.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if_5.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if_6.modulate = Color(1.0, 1.0, 1.0, 0.0)
	#connections()
	if data["Time_and_Medal_Score"].has("Chapter3"):
		var chap3 = data["Time_and_Medal_Score"]["Chapter3"]
		if chap3.has("saved_session_time"):
			var session_time = chap3["saved_session_time"]
			timerr.time = session_time
			print(timerr.time)
			timerr.update_display() 
			if session_time == 0.0:
				chapter_intro.show_intro()
	else: 
		chapter_intro.show_intro()
	if data.has("Chapter3"):
		var chapter3 = data["Chapter3"]
		if chapter3.has("player_pos"):
			var pos = chapter3["player_pos"]
			player.global_position = Vector2(pos[0], pos[1])
		if chapter3.has("checkpoint_order"):
			var checkpoint = chapter3["checkpoint_order"]
			if checkpoint == 2.0:
				gate.global_position += Vector2(0, 120)
				talk_ctr = 1
			if checkpoint == 3.0:
				talk_ctr = 1
			if checkpoint == 4.0:
				talk_ctr = 1
			if checkpoint == 5.0:
				talk_ctr = 1
				customizable_platform_2.position += Vector2(-160, 0)
				int_object.queue_free()
			if checkpoint == 6.0:
				talk_ctr = 2
				gate_8.global_position += Vector2(0, 120)
				gate_9.global_position += Vector2(0, 120)
			if checkpoint == 7.0:
				gate_11.global_position += Vector2(0, 120)
		
	

func _process(_delta: float) -> void:
	_save_time_on_death()
	if not grid.visible:
		note_ui.visible = true
		timerr.visible = true
		progress_bar.visible = true
	if player.on_console:
		grid.visible = false

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("grid") and not player.on_console and not player.stay:
		if not grid.visible:
			SfxManager.play_sfx(sfx_settings.SFX_NAME.GRID)
			note_ui.visible = false
			grid.visible = true
			timerr.visible = false
			progress_bar.visible = false
		else:
			grid.visible = false
			SfxManager.play_sfx(sfx_settings.SFX_NAME.GRID)
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
func _actions_recieved(action: String, num:int = 0) -> void:
	if action == "note_interacted":
		SaveManager.update_save({"Notes": {"note_%s" % num: true}})
func _actions_recieved2(_action: String, _user_code:String, _console:Node2D) -> void:
	pass
func connections() -> void:
	for note in notes.get_children():
		note.actions_sent.connect(_actions_recieved)
	for consolE in consoles.get_children():
		consolE.actions_sent.connect(_actions_recieved2)


func dialogue(talk: String) -> void:
	DialogueManager.show_dialogue_balloon(load("res://dialogue/dialogue3.dialogue"), talk)

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if talk_ctr == 1:
		dialogue("talk2")
		talk_ctr = 2
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

func _save_time_on_death() -> void:
	if player.dead:
		_save_timer_to_json()
	return

func _save_timer_to_json() -> void:
	SaveManager.save_timer_for_session("Chapter3", timerr.time)

func _on_finish_body_entered(_body: Node2D) -> void:
	player.stay = true
	ui_level_complete.drop_down()
	SaveManager.save_level_completion("Chapter3", timerr, ui_level_complete) 
	SaveManager.evaluate_level_score("Chapter3")
	SaveManager.reset_session_time("Chapter3")
	SaveManager.mark_level_completed(3)
	MusicManager.change_volume(0.01)
	await get_tree().create_timer(5).timeout
	MusicManager.change_volume(0.03)
	
func wait(time: float) -> void:
	await get_tree().create_timer(time).timeout

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_timer_to_json()
		get_tree().quit() 

func _on_room_1_body_entered(body: Node2D) -> void:
	if body == player:
		progress_bar.evaluate_progress(1)
func _on_room_2_body_entered(body: Node2D) -> void:
	if body == player:
		progress_bar.evaluate_progress(2)
func _on_room_3_body_entered(body: Node2D) -> void:
	if body == player:
		progress_bar.evaluate_progress(3)
func _on_room_4_body_entered(body: Node2D) -> void:
	if body == player:
		progress_bar.evaluate_progress(4)
func _on_room_5_body_entered(body: Node2D) -> void:
	if body == player:
		progress_bar.evaluate_progress(5)
func _on_room_6_body_entered(body: Node2D) -> void:
	if body == player:
		progress_bar.evaluate_progress(6)
func _on_room_7_body_entered(body: Node2D) -> void:
	if body == player:
		progress_bar.evaluate_progress(7)
func _on_room_8_body_entered(body: Node2D) -> void:
	if body == player:
		progress_bar.evaluate_progress(8)
 

func _on_cutscene_1_body_entered(_body: Node2D) -> void:
	if talk_ctr == 0:
		dialogue("talk1")
		talk_ctr = 1

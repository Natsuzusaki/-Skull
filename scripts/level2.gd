extends Node2D

#----References
@onready var grid: CanvasLayer = $Grid
@onready var star: ColorRect = $Star
@onready var player: Player = %Player
@onready var camera: Camera2D = %Camera
@onready var notes: Node2D = %Notes
@onready var consoles: Node2D = %Consoles
@onready var code_blocks: Node2D = %CodeBlocks
@onready var timerr: CanvasLayer = $Time
@onready var ui_level_complete: Control = $UIs/UI_LevelComplete
@onready var chapter_intro: CanvasLayer = $ChapterIntro
@onready var progress_bar: CanvasLayer = $ProgressBar
@onready var note_ui: CanvasLayer = $Note_UI
#----Markers
@onready var code_block: Marker2D = $CameraPoints/CodeBlock
@onready var wall: Marker2D = $CameraPoints/Wall
@onready var int_obj: Marker2D = $CameraPoints/Int
@onready var mouse_move: Marker2D = $CameraPoints/MouseMove
@onready var yuna_mouse: Area2D = $YunaMouse
#----Area2D
@onready var tutorial_end: Area2D = $Triggers/TutorialEnd
@onready var code_block_area: Area2D = $Triggers/CodeBlock
#----Labels
@onready var open_grid: Label = $Labels/OpenGrid
@onready var insert_int: Label = $Labels/InsertINT
@onready var move_platform: Label = $Labels/MovePlatform

var current_chapter = "Chapter2"
var data = SaveManager.load_game()
var ctr := false
var talk_ctr := 0
var retry_ctr := 0
var mouse_target: Vector2
var yuna_mouse_move := false
var mouse_speed: float = 550.0

func _ready() -> void:
	#Engine.time_scale = 0.1
	MusicManager.play_music_with_fade("res://assets/music/[1-15] Gestation - Cave Story Remastered Soundtrack [2CFvy4lMCcA].mp3", 0.08)
	connections()
	if data["Time_and_Medal_Score"].has("Chapter2"):
		var chap2 = data["Time_and_Medal_Score"]["Chapter2"]
		if chap2.has("saved_session_time"):
			var session_time = chap2["saved_session_time"]
			timerr.time = session_time
			print(timerr.time)
			timerr.update_display() 

	if data.has("Chapter2"):
		var chapter2 = data["Chapter2"]
		if chapter2.has("player_pos"):
			var pos = chapter2["player_pos"]
			player.global_position = Vector2(pos[0], pos[1])
		if chapter2.has("checkpoint_order"):
			var checkpoint = chapter2["checkpoint_order"]
			if checkpoint >= 1.0:
				pass
		
		if chapter2.has("flags"):
			var flags = chapter2["flags"]
			if flags.has("talk1"):
				if flags["talk1"]:
					talk_ctr = 1
					ctr = true
					tutorial_end.monitoring = false
					SaveManager.restore_objects()
			if flags.has("talk2"):
				if flags["talk2"]:
					talk_ctr = 2
			if flags.has("talk3"):
				if flags["talk3"]:
					talk_ctr = 3
	starting_scene()

#----SpecificTriggers
func starting_scene() -> void:
	if not ctr:
		timerr.pause()
		timerr.visible = false
		Cutscene.start_cutscene()
		player.stay = true
		camera.focus_on_player(true, true)
		chapter_intro.show_intro()
		await player.move_in_cutscene(Vector2(64, 440))
		dialogue("talk1")
		talk_ctr = 1
	return
func _actions_recieved(action: String, num:int = 0) -> void:
	if talk_ctr == 2 and action.contains("note_closed") and num == 6:
		dialogue("talk3")
		talk_ctr = 3
	if action == "note_interacted":
		SaveManager.update_save({"Notes": {"note_%s" % num: true}})
func _actions_recieved2(_action: String, _user_code:String, _console:Node2D) -> void:
	pass
func _codeblock_has_value(value) -> void:
	print(talk_ctr, retry_ctr)
	if talk_ctr == 1:
		fade_out(insert_int)
		fade_out(move_platform)
		code_block_area.set_deferred("monitoring", false)
		if (value < -3 and value > -7):
			retry_ctr += 1
			if retry_ctr >= 4:
				Cutscene.start_cutscene()
				player.stay = true
				dialogue("talk2")
				talk_ctr = 2
				retry_ctr = 0
		elif (value > -4 or value < -6) and retry_ctr <= 3:
			Cutscene.start_cutscene()
			player.stay = true
			dialogue("talk2_5")
			talk_ctr = 2
			retry_ctr = 0

#----Processes
func _process(delta: float) -> void:
	_save_time_on_death()
	if not grid.visible:
		note_ui.visible = true
		timerr.visible = true
		progress_bar.visible = true
	if player.on_console:
		grid.visible = false
	if yuna_mouse_move:
		var current = yuna_mouse.global_position
		if current.distance_to(mouse_target) > 2:
			var new_pos = current.move_toward(mouse_target, mouse_speed * delta)
			yuna_mouse.global_position = new_pos
		else:
			yuna_mouse.global_position = mouse_target
			yuna_mouse_move = false
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("grid") and not player.on_console and not player.stay:
		if not grid.visible:
			SfxManager.play_sfx(sfx_settings.SFX_NAME.GRID)
			note_ui.visible = false
			timerr.visible = false
			progress_bar.visible = false
			grid.visible = true
		else:
			SfxManager.play_sfx(sfx_settings.SFX_NAME.GRID)
			grid.visible = false
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

func _save_time_on_death() -> void:
	if player.dead:
		_save_timer_to_json()
	return

#----Helpers
func dialogue(talk: String) -> void:
	timerr.pause()
	timerr.visible = false
	progress_bar.visible = false
	note_ui.visible = false
	DialogueManager.show_dialogue_balloon(load("res://dialogue/dialogue2.dialogue"), talk)
func dialogue_end() -> void:
	timerr.start()
	timerr.visible = true
	progress_bar.visible = true
	note_ui.visible = true
func wait(time: float) -> void:
	await get_tree().create_timer(time).timeout
func connections() -> void:
	for note in notes.get_children():
		note.actions_sent.connect(_actions_recieved)
	for console in consoles.get_children():
		console.actions_sent.connect(_actions_recieved2)
	for blocks in code_blocks.get_children():
		blocks.has_value.connect(_codeblock_has_value)
func _save_timer_to_json() -> void:
	SaveManager.save_timer_for_session("Chapter2", timerr.time)
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_timer_to_json()
		get_tree().quit()
func fade_in(object) -> void:
	var tween = create_tween()
	tween.tween_property(object, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
func fade_out(object) -> void:
	var tween = create_tween()
	tween.tween_property(object, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)

#----Triggers
func _on_fall_cutscene_body_entered(_body: Node2D) -> void:
	SaveManager.mark_level_completed(2)
	camera.focus_on_player(true, true)
	await wait(1)
func _on_tutorial_end_body_entered(_body: Node2D) -> void:
	tutorial_end.set_deferred("monitoring", false)
	talk_ctr = 3
#func _on_area_2d_body_entered(_body: Node2D) -> void:
	#player.stay = true
	#ui_level_complete.drop_down()
	##SaveManager.save_level_completion("Chapter2", timerr, true)
	#SaveManager.mark_level_completed(2)
func _on_complete_body_entered(_body: Node2D) -> void:
	player.stay = true
	progress_bar.visible = false
	ui_level_complete.drop_down()
	SaveManager.save_level_completion("Chapter2", timerr, ui_level_complete)
	SaveManager.evaluate_level_score("Chapter2")
	SaveManager.reset_session_time("Chapter2")
	SaveManager.mark_level_completed(2)

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
func _on_room_9_body_entered(body: Node2D) -> void:
	if body == player:
		progress_bar.evaluate_progress(9)
func _on_room_10_body_entered(body: Node2D) -> void:
	if body == player:
		progress_bar.evaluate_progress(10)

#----NewTriggers
func _on_open_grid_body_entered(_body: Node2D) -> void:
	fade_in(open_grid)
func _on_open_grid_body_exited(_body: Node2D) -> void:
	fade_out(open_grid)
func _on_code_block_body_entered(_body: Node2D) -> void:
	fade_in(insert_int)
	fade_in(move_platform)
	code_block_area.set_deferred("monitoring", false)
func _on_tunnel_cam_body_entered(_body: Node2D) -> void:
	
	Cutscene.start_cutscene()
	camera.focus_on_player(true, true)
func _on_tunnel_cam_body_exited(_body: Node2D) -> void:
	Cutscene.end_cutscene()
	camera.back()

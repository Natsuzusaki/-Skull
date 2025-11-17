extends Node2D

#----UniqueReference
@onready var player: CharacterBody2D = %Player
@onready var camera: Camera2D = %Camera
@onready var notes: Node2D = %Notes
@onready var objects: Node2D = %Objects
@onready var consoles: Node2D = %Consoles
#----Reference
@onready var ui_level_complete: Control = $UIs/UI_LevelComplete
@onready var str_object_4: RigidBody2D = $Objects/Str_Object4
@onready var gate: StaticBody2D = $Gate
@onready var mid_ground: TileMapLayer = $MidGround
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var timerr: CanvasLayer = $Time
@onready var secretground: TileMapLayer = $SecretGround
@onready var chapter_intro: CanvasLayer = $ChapterIntro
@onready var progress_bar: CanvasLayer = $ProgressBar
#----Label
@onready var move_label: Label = $Labels/Move
@onready var jump_label: Label = $Labels/Jump
@onready var jump2_label: Label = $Labels/Jump2
@onready var jump3_label: Label = $Labels/Jump3
@onready var down_label: Label = $Labels/Down
@onready var restart_label: Label = $Labels/Restart
@onready var restart_label2: Label = $Labels/Restart2
@onready var restart_label3: Label = $Labels/Restart3
@onready var level_name: Panel = $Labels/LevelName
#----Area2D
@onready var console1: Area2D = $Consoles/Console
@onready var button_2: Area2D = $Buttons/Button2
@onready var cant_cross: Area2D = $Triggers/CantCross
@onready var can_cross_1: Area2D = $Triggers/CanCross1
@onready var can_cross_2_1: Area2D = $Triggers/CanCross2_1
@onready var can_cross_2_2: Area2D = $Triggers/CanCross2_2
@onready var noise: Area2D = $Triggers/Noise
@onready var note1: Area2D = $Notes/Note
@onready var tip_2: Area2D = $NewTriggers/Tip2
@onready var string_tip: Area2D = $NewTriggers/StringTip
@onready var restart_tip: Area2D = $NewTriggers/RestartTip

var current_chapter = "Chapter1"
var is_smart := false
var new_talkctr := 0
var talk_ctr := 0
var has_fallen := false
var is_first_present := false
var blocked := false

func _ready() -> void:
	MusicManager.play_music_with_fade("res://assets/music/New [1-02] Access - Cave Story Remastered Soundtrack.mp3", 0.08)
	console1.turned_on = false
	connections()
	var data = SaveManager.load_game()
	
	if data.has("Chapter1"):
		var chapter1 = data["Chapter1"]
		if chapter1.has("player_pos"):
			var pos = chapter1["player_pos"]
			player.global_position = Vector2(pos[0], pos[1])
		if chapter1.has("checkpoint_order"):
			if chapter1["checkpoint_order"] == 8.0:
				button_2.disabled = true
				gate.global_position += Vector2(0, 120)

		if chapter1.has("flags"):
			var flags = chapter1["flags"]
			if flags.has("talk1"):
				if flags["talk1"]:
					new_talkctr = 1
					fade_in(move_label)
			if flags.has("talk2"):
				if flags["talk2"]:
					new_talkctr = 2
					tip_2.set_deferred("monitoring", false)
					string_tip.set_deferred("monitoring", false)
			if flags.has("talk3"):
				if flags["talk3"]:
					new_talkctr = 3
					console1.turned_on = true
			if flags.has("talk4"):
				if flags["talk4"]:
					new_talkctr = 4
					SaveManager.restore_objects()
			if flags.has("talk5"):
				if flags["talk5"]:
					new_talkctr = 5
					can_cross_2_1.set_deferred("monitoring", false)
					can_cross_2_2.set_deferred("monitoring", false)

	if data["Time_and_Medal_Score"].has("Chapter1"):
		var chap1 = data["Time_and_Medal_Score"]["Chapter1"]
		if chap1.has("saved_session_time"):
			var session_time = chap1["saved_session_time"]
			timerr.time = session_time
			print(timerr.time)
			timerr.update_display() 
	start()

#----PresetFunctions
func start() -> void:
	if not new_talkctr:
		DeathFog.close_fog()
		DeathFog.open_fog()
		player.stay = true
		newdialogue("talk1")
		new_talkctr = 1
func entered_last_area() -> void:
	pass
func title_fadeout() -> void:
	await wait(0.2)
	fade_in(level_name)
	await wait(5)
	fade_out(level_name)

#----Processes
func _process(_delta: float) -> void:
	_save_time_on_death()
func _unhandled_input(_event: InputEvent) -> void:
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

#----Helpers
func connections() -> void:
	for note in notes.get_children():
		note.actions_sent.connect(_actions_recieved)
	for console in consoles.get_children():
		console.actions_sent.connect(_actions_recieved2)
func wait(time: float) -> void:
	await get_tree().create_timer(time).timeout
func dialogue(talk: String) -> void:
	DialogueManager.show_dialogue_balloon(load("res://dialogue/test.dialogue"), talk)
func newdialogue(talk: String) -> void:
	DialogueManager.show_dialogue_balloon(load("res://dialogue/dialogue1.dialogue"), talk)
func turn_dark_light(value) -> void:
	var tween = create_tween()
	tween.tween_property(canvas_modulate, "color", value, 1)
func _save_timer_to_json() -> void:
	SaveManager.save_timer_for_session("Chapter1", timerr.time)
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_timer_to_json()
		get_tree().quit()
func _save_time_on_death() -> void:
	if player.dead:
		_save_timer_to_json()
	return
func fade_in(object) -> void:
	var tween = create_tween()
	tween.tween_property(object, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
func fade_out(object) -> void:
	var tween = create_tween()
	tween.tween_property(object, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)

#----Triggers
func _on_kill_fail_objects_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		has_fallen = true
		body.queue_free()
		console1.turned_on = true
func _on_can_cross_body_entered(body: Node2D) -> void:
	await wait(1)
	if body in can_cross_1.get_overlapping_bodies():
		if new_talkctr == 3:
			new_talkctr = 4
			newdialogue("talk4")
func _on_can_cross_2_1_body_entered(body: Node2D) -> void:
	await wait(1)
	is_first_present = true if body in can_cross_2_1.get_overlapping_bodies() else false
func _on_can_cross_2_2_body_entered(body: Node2D) -> void:
	await wait(2)
	if body in can_cross_2_2.get_overlapping_bodies() and is_first_present and new_talkctr <= 4:
		new_talkctr = 5
		newdialogue("talk5")
	else:
		newdialogue("talk5_fail")
func _on_cant_cross_body_entered(body: Node2D) -> void:
	await wait(1)
	if body in cant_cross.get_overlapping_bodies() and body is RigidBody2D:
		blocked = true
	if body is CharacterBody2D and blocked:
		cant_cross.set_deferred("monitoring", false)
		newdialogue("blocked")
	elif body is CharacterBody2D:
		cant_cross.set_deferred("monitoring", false)
		SaveManager.update_save({"Chapter1": {"flags": {"finished_all_puzzle": true}}})
func _on_noise_body_entered(_body: Node2D) -> void:
	noise.set_deferred("monitoring", false)
	SaveManager.update_save({"Chapter1": {"flags": {"listened_to_noise": true}}})
	entered_last_area()
func _on_level_finished_body_entered(_body: Node2D) -> void:
	player.stay = true
	ui_level_complete.drop_down()
	SaveManager.save_level_completion("Chapter1", timerr, ui_level_complete)
	SaveManager.evaluate_level_score("Chapter1")
	SaveManager.reset_session_time("Chapter1")
	SaveManager.mark_level_completed(1)
#----NewTriggers
func _on_tip_body_entered(_body: Node2D) -> void:
	await wait(0.5)
	fade_in(jump3_label)
func _on_tip_2_body_entered(_body: Node2D) -> void:
	tip_2.set_deferred("monitoring", false)
	fade_out(jump3_label)
	await wait(0.1)
	fade_in(down_label)
func _on_string_tip_body_entered(_body: Node2D) -> void:
	string_tip.set_deferred("monitoring", false)
	newdialogue("talk2")
	new_talkctr = 2
func _on_restart_tip_body_entered(body: Node2D) -> void:
	await wait(10)
	if body in restart_tip.get_overlapping_bodies() and body is RigidBody2D:
		fade_in(restart_label2)
func _on_asri_body_entered(_body: Node2D) -> void:
	newdialogue("bazinga")
func _on_asri_2_body_entered(_body: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property(secretground, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)

#----Signals
func _actions_recieved(action:String) -> void:
	if new_talkctr == 2 and action.contains("note_closed"):
		new_talkctr = 3
		newdialogue("talk3")
func _actions_recieved2(action:String, _text:= "") -> void:
	if action == "console_run":
		await wait(1)
		if has_fallen:
			newdialogue("objectfall_talk")

#----SpecificTriggers
func _on_turn_dark_body_entered(_body: Node2D) -> void:
	turn_dark_light(Color8(27, 71, 95, 255))
func _on_turn_dark_body_exited(_body: Node2D) -> void:
	turn_dark_light(Color8(113, 185, 227, 255))
func _on_outside_cave_body_entered(_body: Node2D) -> void:
	turn_dark_light(Color8(255, 255, 255, 255))
func _on_outside_cave_body_exited(_body: Node2D) -> void:
	turn_dark_light(Color8(69, 145, 187, 255))
	await wait(0.5)
	fade_in(jump_label)
	await wait(1.5)
	fade_in(jump2_label)

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
func _on_room_11_body_entered(body: Node2D) -> void:
	if body == player:
		progress_bar.evaluate_progress(11)

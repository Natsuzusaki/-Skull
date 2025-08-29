extends Node2D
@onready var player: CharacterBody2D = %Player
@onready var camera: Camera2D = %Camera
@onready var pause: Control = %Pause
@onready var notes: Node2D = %Notes
@onready var objects: Node2D = %Objects
@onready var consoles: Node2D = %Consoles
@onready var cutscene_sfx: Node2D = %"Cutscene SFX"

@onready var str_object_4: RigidBody2D = $Objects/Str_Object4
@onready var console1: Area2D = $Consoles/Console
@onready var blur: ColorRect = $UIs/Blur
@onready var note_manager: Node2D = $UIs/NoteManager
@onready var cutscene_1: Area2D = $Triggers/Cutscene1
@onready var cutscene_2: Area2D = $Triggers/Cutscene2
@onready var cant_cross: Area2D = $Triggers/CantCross
@onready var can_cross_1: Area2D = $Triggers/CanCross1
@onready var can_cross_2_1: Area2D = $Triggers/CanCross2_1
@onready var can_cross_2_2: Area2D = $Triggers/CanCross2_2
@onready var noise: Area2D = $Triggers/Noise
@onready var note1: Area2D = $Notes/Note
@onready var printer1: Node2D = $Printers/Printer8
@onready var printer2: Node2D = $Printers/Printer9
@onready var printer3: Node2D = $Printers/Printer10
@onready var canvas_modulate: CanvasModulate = $CanvasModulate

var talk_ctr := 0
var has_fallen := false
var is_first_present := false
var blocked := false

func _ready() -> void:
	console1.turned_on = false
	note1.monitoring = false
	connections()
	var data = SaveManager.load_game()
	if data.has("Chapter1"):
		var chapter1 = data["Chapter1"]
		if chapter1.has("player_pos"):
			var pos = chapter1["player_pos"]
			player.global_position = Vector2(pos[0], pos[1])
		if chapter1.has("flags"):
			var flags = chapter1["flags"]
			if flags.has("has_done_cutscene"):
				if flags["has_done_cutscene"]:
					note1.monitoring = true
					cutscene_1.monitoring = false
					console1.turned_on = true
					talk_ctr = 2
			if flags.has("has_crossed"):
				if flags["has_crossed"]:
					console1.turned_on = false
					talk_ctr = 3
					SaveManager.restore_objects()
			if flags.has("has_done_cutscene2"):
				if flags["has_done_cutscene2"]:
					cutscene_2.monitoring = false
					talk_ctr = 5
			if flags.has("has_crossed2"):
				if flags["has_crossed2"]:
					can_cross_2_1.monitoring = false
					can_cross_2_2.monitoring = false
					talk_ctr = 5
			if flags.has("has_crossed3"):
				if flags["has_crossed3"]:
					cant_cross.monitoring = false
					talk_ctr = 5
			if flags.has("listened_to_noise"):
				if flags["listened_to_noise"]:
					noise.monitoring = false
func connections() -> void:
	for note in notes.get_children():
		note.actions_sent.connect(_actions_recieved)
	for console in consoles.get_children():
		console.actions_sent.connect(_actions_recieved2)

func _on_kill_fail_objects_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		has_fallen = true
		body.queue_free()
		console1.turned_on = true

func entered_last_area() -> void:
	var ctr := 0
	var time := 1.0
	var auto_print = ["blocked", "obstruct", "jammed", "closed", "damper", "barricade", "sealed"]
	for a in range(10):
		var random1 = randi_range(0, 6)
		var random2 = randi_range(0, 6)
		var random3 = randi_range(0, 6)
		printer1.spawn_object(auto_print[random1])
		printer2.spawn_object(auto_print[random2])
		printer3.spawn_object(auto_print[random3])
		await get_tree().create_timer(0.5).timeout
	for sound in cutscene_sfx.get_children():
		sound.play()
		if ctr == 2:
			time = 1
		else:
			time = 0.5
		await wait(time)
		ctr += 1
	DialogueManager.show_dialogue_balloon(load("res://dialogue/test.dialogue"), "talk11")
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if not get_tree().paused:
			_pause_game()
		else:
			_resume_game()
func _pause_game() -> void:
	blur.visible = true
	get_tree().paused = true
	pause.visible = true
func _resume_game() -> void:
	blur.visible = false
	get_tree().paused = false
	pause.visible = false

func _on_cutscene_1_body_entered(_body: Node2D) -> void:
	player.stay = true
	camera.focus_on_player(true)
	cutscene_1.set_deferred("monitoring", false)
	player.static_direction = 1
	await wait(1)
	await player.move_in_cutscene(Vector2(4480, 424))
	DialogueManager.show_dialogue_balloon(load("res://dialogue/test.dialogue"), "talk1")
	SaveManager.update_save({"Chapter1": {"flags": {"has_done_cutscene": true}}})
func _on_cutscene_2_body_entered(_body: Node2D) -> void:
	cutscene_2.set_deferred("monitoring", false)
	player.static_direction = 1
	DialogueManager.show_dialogue_balloon(load("res://dialogue/test.dialogue"), "talk9")
	SaveManager.update_save({"Chapter1": {"flags": {"has_done_cutscene2": true}}})
func _on_can_cross_body_entered(body: Node2D) -> void:
	await wait(1)
	if body in can_cross_1.get_overlapping_bodies():
		if talk_ctr == 2:
			talk_ctr = 3
			console1.turned_on = false
			console1.consolesprite.visible = true
			console1.consolesprite_near.visible = false
			DialogueManager.show_dialogue_balloon(load("res://dialogue/test.dialogue"), "talk4")
			SaveManager.update_save({"Chapter1": {"flags": {"has_crossed": true}}})
func _on_can_cross_2_1_body_entered(body: Node2D) -> void:
	await wait(1)
	is_first_present = true if body in can_cross_2_1.get_overlapping_bodies() else false
func _on_can_cross_2_2_body_entered(body: Node2D) -> void:
	await wait(2.5)
	print(is_first_present)
	print(talk_ctr)
	if body in can_cross_2_2.get_overlapping_bodies() and is_first_present and talk_ctr <= 4:
		talk_ctr = 5
		DialogueManager.show_dialogue_balloon(load("res://dialogue/test.dialogue"), "talk7")
		SaveManager.update_save({"Chapter1": {"flags": {"has_crossed2": true}}})
	else:
		DialogueManager.show_dialogue_balloon(load("res://dialogue/test.dialogue"), "talk8")
func _on_cant_cross_body_entered(body: Node2D) -> void:
	await wait(1)
	if body in cant_cross.get_overlapping_bodies() and body is RigidBody2D:
		blocked = true
	if body is CharacterBody2D and blocked:
		cant_cross.set_deferred("monitoring", false)
		DialogueManager.show_dialogue_balloon(load("res://dialogue/test.dialogue"), "talk10")
	elif body is CharacterBody2D:
		cant_cross.set_deferred("monitoring", false)
		SaveManager.update_save({"Chapter1": {"flags": {"has_crossed3": true}}})

func _actions_recieved(action:String) -> void:
	if not talk_ctr and action.contains("note_closed"):
		talk_ctr = 1
		player.stay = true
		DialogueManager.show_dialogue_balloon(load("res://dialogue/test.dialogue"), "talk2")
	if talk_ctr == 3 and action.contains("note_interacted"):
		talk_ctr = 4
		DialogueManager.show_dialogue_balloon(load("res://dialogue/test.dialogue"), "talk6")
func _actions_recieved2(action:String, _text:= "") -> void:
	if talk_ctr == 1 and action == "console_focused":
		talk_ctr = 2
		DialogueManager.show_dialogue_balloon(load("res://dialogue/test.dialogue"), "talk3")
	elif action == "console_run":
		await wait(0.3)
		if has_fallen:
			DialogueManager.show_dialogue_balloon(load("res://dialogue/test.dialogue"), "talk5")
			has_fallen = false

func _on_noise_body_entered(_body: Node2D) -> void:
	noise.set_deferred("monitoring", false)
	SaveManager.update_save({"Chapter1": {"flags": {"listened_to_noise": true}}})
	entered_last_area()
func _on_level_finished_body_entered(_body: Node2D) -> void:
	player.stay = true
	SaveManager.mark_level_completed(1)
func wait(time: float) -> void:
	await get_tree().create_timer(time).timeout
func turn_dark_light(value) -> void:
	var tween = create_tween()
	tween.tween_property(canvas_modulate, "color", value, 1)

func _on_turn_dark_body_entered(_body: Node2D) -> void:
	turn_dark_light(Color8(27, 71, 95, 255))
func _on_turn_dark_body_exited(_body: Node2D) -> void:
	turn_dark_light(Color8(113, 185, 227, 255))
func _on_outside_cave_body_entered(_body: Node2D) -> void:
	turn_dark_light(Color8(255, 255, 255, 255))
func _on_outside_cave_body_exited(_body: Node2D) -> void:
	turn_dark_light(Color8(113, 185, 227, 255))

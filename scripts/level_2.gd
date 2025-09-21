extends Node2D

@onready var grid: CanvasLayer = $Grid
@onready var player: Player = %Player
@onready var camera: Camera2D = %Camera
@onready var notes: Node2D = %Notes
@onready var consoles: Node2D = %Consoles

@onready var code_block: Marker2D = $CameraPoints/CodeBlock

var data = SaveManager.load_game()
var grid_speak := false
var ctr := false
var talk_ctr := 0

func _ready() -> void:
	connections()
	if data.has("Chapter2"):
		var chapter2 = data["Chapter2"]
		if chapter2.has("player_pos"):
			var pos = chapter2["player_pos"]
			player.global_position = Vector2(pos[0], pos[1])
		if chapter2.has("checkpoint_order"):
			var checkpoint = chapter2["checkpoint_order"]
			if checkpoint >= 1.0:
				ctr = true
			if checkpoint == 2.0:
				SaveManager.restore_objects()
	starting_scene()

#----SpecificTriggers
func starting_scene() -> void:
	if not ctr:
		Cutscene.start_cutscene()
		player.stay = true
		camera.focus_on_player(true, true)
		await player.move_in_cutscene(Vector2(64, 440))
		await wait(0.5)
		player.static_direction = -1
		await wait(1)
		player.static_direction = 1
		await wait(1)
		await player.move_in_cutscene(Vector2(128,440), 200)
		await wait(1.5)
		dialogue("talk1")
		talk_ctr = 1
	return
func _actions_recieved(action: String) -> void:
	if talk_ctr == 1 and action.contains("note_closed"):
		Cutscene.start_cutscene()
		player.stay = true
		camera.focus_on_player(true, true)
		dialogue("talk2")
		talk_ctr = 2
func _actions_recieved2() -> void:
	pass

#----Processes
func _process(_delta: float) -> void:
	if player.on_console:
		grid.visible = false
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("grid") and not player.on_console and not player.stay:
		if not grid.visible:
			if grid_speak:
				grid_speak = false
				dialogue("talk3")
				talk_ctr = 3
			grid.visible = true
		else:
			grid.visible = false
	if Input.is_action_just_pressed("pause") and not player.on_console and not player.stay:
		if not get_tree().paused:
			_pause_game()
			get_viewport().set_input_as_handled()
func _pause_game() -> void:
	get_tree().paused = true
	Pause.paused()

#----Helpers
func dialogue(talk: String) -> void:
	DialogueManager.show_dialogue_balloon(load("res://dialogue/dialogue2.dialogue"), talk)
func wait(time: float) -> void:
	await get_tree().create_timer(time).timeout
func connections() -> void:
	for note in notes.get_children():
		note.actions_sent.connect(_actions_recieved)
	for console in consoles.get_children():
		console.actions_sent.connect(_actions_recieved2)

#----Triggers
func _on_fall_cutscene_body_entered(_body: Node2D) -> void:
	camera.focus_on_player(true, true)
	await wait(1)
	dialogue("talk1")

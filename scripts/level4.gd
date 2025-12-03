extends Node2D

#Arrays
@onready var array1: Area2D = $Arrays/Array
@onready var array2: Area2D = $Arrays/Array2
@onready var array3: Area2D = $Arrays/Array3
@onready var array4: Area2D = $Arrays/Array4
@onready var array8: Area2D = $Arrays/Array8
#Gates
@onready var gate1: StaticBody2D = $Gates/Gate
@onready var gate2: StaticBody2D = $Gates/Gate2
@onready var gate3: StaticBody2D = $Gates/Gate3
@onready var gate4: StaticBody2D = $Gates/Gate4
@onready var gate5: StaticBody2D = $Gates/Gate5
@onready var gate6: StaticBody2D = $Gates/Gate6
@onready var gate7: StaticBody2D = $Gates/Gate7
@onready var gate8: StaticBody2D = $Gates/Gate8
#Consoles
@onready var console1: Area2D = $Consoles/Console
#Printers
@onready var printer1: Node2D = $Printers/Printer
#References
@onready var notes: Node2D = %Notes
@onready var consoles: Node2D = %Consoles
@onready var camera: Camera2D = %Camera
@onready var loops: Node2D = %Loops
@onready var player: CharacterBody2D = %Player
@onready var timerr: CanvasLayer = $Time
@onready var gates: Node2D = %Gates
@onready var arrays: Node2D = %Arrays
@onready var explosion: GPUParticles2D = $Explosion
@onready var gate_close: Area2D = $Triggers/GateClose
@onready var grid: CanvasLayer = $Grid
@onready var chapter_intro: CanvasLayer = $ChapterIntro
@onready var progress_bar: CanvasLayer = $ProgressBar
@onready var crystal: Sprite2D = $Crystals/Crystal
@onready var label_6: Label = $Labels/Label6
@onready var extra_jump: Area2D = $Triggers/ExtraJump
@onready var label9: Label = $Labels/Label9
@onready var label10: Label = $Labels/Label10
#Markers
@onready var printer_explode: Marker2D = $CameraPoints/PrinterExplode
@onready var empty_room: Marker2D = $CameraPoints/EmptyRoom

var current_chapter = "Chapter4"
var global_condition: int = 0
var condition_ctr: int = 0
var control_regex := RegEx.new()

func _ready() -> void:
	connections()
	camera.back()

#----ScriptedEvents
func printerexplode() -> void:
	player.stay = true
	console1._on_body_exited(player)
	await wait(0.7)
	camera.focus_on_point(printer_explode)
	await wait(0.5)
	explosion.emitting = true
	await wait(0.5)
	printer1.broken = true
	printer1.breaks()
	await wait(1)
	explosion.emitting = false
	await wait(0.5)
	console1._on_body_entered(player)
	console1.specific_printer.append(printer1)
	player.stay = false
	camera.back()

#----Processes
func _process(_delta: float) -> void:
	_save_time_on_death()
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("grid") and not player.on_console and not player.stay:
		if not grid.visible:
			timerr.visible = false
			progress_bar.visible = false
			grid.visible = true
		else:
			grid.visible = false
			timerr.visible = true
			progress_bar.visible = true
	if Input.is_action_just_pressed("pause") and not player.on_console and not player.stay:
		if grid.visible:
			grid.hide_grid()
			timerr.visible = true
			progress_bar.visible = true
		elif not get_tree().paused:
			_pause_game()
			get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed("debug") and not player.stay:
		_save_timer_to_json()
		get_tree().reload_current_scene()
func _pause_game() -> void:
	get_tree().paused = true
	Pause.paused()

#----Helper
func connections() -> void:
	for note in notes.get_children():
		note.actions_sent.connect(_actions_recieved)
	for console in consoles.get_children():
		console.actions_sent.connect(_actions_recieved2)
	for array in arrays.get_children():
		array.array_action.connect(_array_action)
	for loop in loops.get_children():
		loop.looptriggered.connect(_looptrigger)
func _save_timer_to_json() -> void:
	SaveManager.save_timer_for_session("Chapter4", timerr.time)
func _save_time_on_death() -> void:
	if player.dead:
		_save_timer_to_json()
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_timer_to_json()
		get_tree().quit()
func newdialogue(talk: String) -> void:
	DialogueManager.show_dialogue_balloon(load("res://dialogue/dialogue4.dialogue"), talk)
func wait(time: float) -> void:
	await get_tree().create_timer(time).timeout

#----Signals
func _actions_recieved(_action:String, _note_num:int = 0) -> void:
	pass
func _actions_recieved2(action:String, user_code:= "") -> void:
	control_regex.compile(r"print\s*\(([^)]*)\)")
	if control_regex.search(user_code) and action == "console_run" and not global_condition:
		global_condition = 1
		printer1.broken = true
		#await wait(0.5)
		printerexplode()
	if action == "console_focused":
		grid.visible = false
		progress_bar.visible = true
		timerr.visible = true

#----Hardcoded Conditions *sob
func _array_action(action:String, array_name:String, _value=null, _index=null) -> void:
	match array_name:
		array1.arr_name:
			if action == "append_fill" and array1.inputs.size() == 5 and condition_ctr == 1:
				await wait(0.7)
				gate1.activate(false, 0.5)
				condition_ctr = 2
		array2.arr_name:
			if action == "print_fill" and array2.inputs.size() == 5 and condition_ctr == 0:
				await wait(0.7)
				gate2.activate(false, 0.5)
				condition_ctr = 1
		array3.arr_name:
			if action == "removed" and array3.inputs.size() == 5 and condition_ctr == 2:
				await wait(0.7)
				gate5.activate(false, 0.5)
				condition_ctr = 3
		array4.arr_name:
			if array4.inputs.size() == 0 and condition_ctr == 3:
				await wait(0.7)
				gate4.activate(false, 0.5)
				condition_ctr = 4
		array8.arr_name:
			if array8.inputs.size() >= 50 and condition_ctr == 4:
				await wait(0.7)
				gate6.activate(false, 0.5)
				condition_ctr = 5
	#print("MATCH: " + array_name +"\nACTION: "+ action +"\nCTR: " + str(condition_ctr) + "\nPLEASE: " + str(array1.inputs.size()))
func _looptrigger(loop_name:String, ctr:int, condition:bool) -> void:
	match loop_name:
		"Loop1":
			if ctr == 2:
				crystal.disable = false
				label_6.text = "destroy the crystal\nto break the loop"
		"Loop2":
			if condition:
				extra_jump.set_deferred("monitoring", true)

func _on_area_2d_body_entered(_body: Node2D) -> void:
	gate3.activate(false, 0.5)
	gate4.activate(false, 0.5)
	gate5.activate(false, 0.5)
	gate_close.set_deferred("monitoring", false)
func _on_empty_room_body_entered(_body: Node2D) -> void:
	camera.focus_on_point("EmptyRoom")
func _on_empty_room_body_exited(_body: Node2D) -> void:
	camera.back()
func _on_extra_jump_body_entered(body: Node2D) -> void:
	body.position.y = -40
	extra_jump.set_deferred("monitoring", false)
func change_text() -> void:
	label9.text = "transfer the contents of\n\nto open gate2"
	label10.text = "\nlist2 to list1"

func _on_room_1_body_entered(body: Node2D) -> void:
	if body == player:
		pass
		#progress_bar.evaluate_progress(1)
func _on_room_2_body_entered(body: Node2D) -> void:
	if body == player:
		pass
		#progress_bar.evaluate_progress(2)
func _on_room_3_body_entered(body: Node2D) -> void:
	if body == player:
		pass
		#progress_bar.evaluate_progress(3)

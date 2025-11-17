extends Node2D

#Arrays

#Gates

#References
@onready var notes: Node2D = %Notes
@onready var consoles: Node2D = %Consoles
@onready var camera: Camera2D = %Camera
@onready var player: CharacterBody2D = %Player
@onready var timerr: CanvasLayer = $Time
@onready var gates: Node2D = %Gates
@onready var arrays: Node2D = %Arrays
@onready var explosion: GPUParticles2D = $Explosion
@onready var printer: Node2D = $Printers/Printer
#Markers
@onready var printer_explode: Marker2D = $CameraPoints/PrinterExplode

func _ready() -> void:
	connections()
	camera.back()
	printerexplode()

#----ScriptedEvents
func printerexplode() -> void:
	camera.focus_on_point(printer_explode)
	await wait(1)
	explosion.emitting = true
	await wait(0.5)
	printer.broken = true
	printer.breaks()
	await wait(1)
	explosion.emitting = false
	await wait(0.5)
	camera.back()

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

#----Helper
func connections() -> void:
	for note in notes.get_children():
		note.actions_sent.connect(_actions_recieved)
	for console in consoles.get_children():
		console.actions_sent.connect(_actions_recieved2)
	for array in arrays.get_children():
		array.array_action.connect(_array_action)
func _save_timer_to_json() -> void:
	SaveManager.save_timer_for_session("Chapter1", timerr.time)
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
func _actions_recieved(_action:String) -> void:
	pass
func _actions_recieved2(_action:String, _text:= "") -> void:
	pass
func _array_action(action:String, value=null, index=null) -> void:
	print(action, value, index)

#----Hardcoded Conditions *sob
func check() -> void:
	pass
func room_conditions() -> void:
	pass

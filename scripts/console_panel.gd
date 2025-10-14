extends Area2D

@export var turned_on: bool = true
@export var characterlimit: int
@export_multiline var base_text: String
@export_multiline var fixed_var: String
@export var outputs: Dictionary = {}

@onready var player: CharacterBody2D = %Player
@onready var camera: Camera2D = %Camera
@onready var label: Label = $Terminal/Panel/MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var code_edit: CodeEdit = $Terminal/Panel/MarginContainer/VBoxContainer/CodeEdit
@onready var pop_up_animation: AnimationPlayer = $"PopUp Animation"
@onready var control: Control = $Terminal
@onready var text_validator: Node2D = $TextValidator
@onready var button: Button = $Terminal/Panel/MarginContainer/VBoxContainer/HBoxContainer/Button
@onready var consolesprite: Sprite2D = $Console
@onready var consolesprite_near: Sprite2D = $Console_Near
@onready var console_off: Sprite2D = $Console_Off
@onready var limit: Label = $Terminal/Panel/MarginContainer/VBoxContainer/HBoxContainer/Limit
@onready var point_light_2d: PointLight2D = $Terminal/Panel/MarginContainer/VBoxContainer/PointLight2D

enum ConsoleState {IDLE, NEAR, INTERACTING}
var state: ConsoleState = ConsoleState.IDLE
var valid := false #is the script valid
var restart_text := false #restart fixed variables
var value = null #player script
var array_value = [] #player script

signal print_value()
signal actions_sent()

func _ready() -> void:
	limit.text = str(characterlimit)
	label.text = fixed_var
	code_edit.placeholder_text = base_text
	point_light_2d.visible = false
	
#WAS my greatest dissapointments, but now i fucking love it!
func execute_code(user_code: String) -> void:
	var script = GDScript.new()
	var formatted_code = text_validator.auto_indentation(user_code, characterlimit)
	formatted_code = text_validator.rewrite_code(formatted_code)
	var var_assignments = ""
	var init_assignments = ""
	for key in outputs.keys():
		var_assignments += "var %s\n" % key
		init_assignments += "	self.%s = ctx[\"%s\"]\n" % [key, key]
	var full_script = """
extends Node

var console: Node
var ctx: Dictionary
%s

func _init(real_console, context:Dictionary):
	console = real_console
	ctx = context
%s

func custom_print(varargs: Array) -> void:
	if console:
		for msg in varargs:
			console.array_value.append(msg)
		console.value = varargs.size() == 1 and varargs[0] or varargs
	else:
		print("Error! something is wrong")

func run():
%s
""" % [var_assignments, init_assignments, formatted_code]
	#print(full_script) #debug
	#print(outputs)
	if formatted_code.is_empty():
		return
	script.set_source_code(full_script)
	var error = script.reload()
	if text_validator.code_verify(error):
		return
	elif error == Error.OK:
		var ctx: Dictionary = {}
		print("OUTPUTS: ", outputs)

		for key in outputs.keys():
			var path = outputs[key]
			if typeof(path) == TYPE_NODE_PATH:
				ctx[key] = get_node(path)
			elif typeof(path) == TYPE_STRING:
				ctx[key] = get_node(NodePath(path))
			else:
				ctx[key] = path
		#print("CTX CONTENTS: ", ctx)
		var instance = script.new(self, ctx)
		add_child(instance)
		if instance.has_method("run"):
			instance.call("run")
			instance.queue_free()
		if value == null:
			value = null
		else:
			print_value.emit(value, array_value)
	else:
		return

#Terminal Interactions
func _on_button_pressed() -> void:
	code_run()
func _on_exit_pressed() -> void:
	console_exit()
func _on_body_entered(_body: Node2D) -> void:
	if not turned_on:
		return
	player.near_console = true
	state = ConsoleState.NEAR
	consolesprite.visible = false
	consolesprite_near.visible = true
	label.text = fixed_var
	control.show()
	pop_up_animation.play("pop_up")
	#actions_sent.emit("moved_closer","")
func _on_body_exited(_body: Node2D) -> void:
	if not turned_on:
		return
	player.near_console = false
	camera.back()
	state = ConsoleState.IDLE
	consolesprite.visible = true
	consolesprite_near.visible = false
	if control.visible:
		pop_up_animation.play("pop_down")
		control.hide()
func _on_code_edit_focus_entered() -> void:
	SFXManager.play("console")
	interacted()
func _on_code_edit_focus_exited() -> void:
	player.stay = false
	player.on_console = false
func _on_code_edit_lines_edited_from(_from_line: int, _to_line: int) -> void:
	if restart_text:
		label.text = fixed_var
		restart_text = false
func console_exit() -> void:
	SFXManager.play("console_exit")
	state = ConsoleState.IDLE
	player.stay = false
	player.on_console = false
	player.near_console = false
	camera.back()
	code_edit.release_focus()
	pop_up_animation.play("pop_down")
	control.hide()
func interacted() -> void:
	state = ConsoleState.INTERACTING
	label.text = fixed_var
	player.stay = true
	player.on_console = true
	camera.focus_on_point(self)
	camera.interact = true
	code_edit.grab_focus()
	actions_sent.emit("console_focused")
func code_run() -> void:
	array_value = []
	var user_code = code_edit.text
	if user_code.is_empty():
		SFXManager.play("console_error")
		label.text = "Nothing to print!"
		player.stay = true
		player.on_console = true
		return
	execute_code(user_code)
	SFXManager.play("console")
	player.stay = false
	player.on_console = false
	player.near_console = false
	camera.back()
	control.hide()
	state = ConsoleState.IDLE
	actions_sent.emit("console_run")
func _process(_delta: float) -> void:
	if not turned_on:
		consolesprite.visible = false
		consolesprite_near.visible = false
		console_off.visible = true
	else:
		console_off.visible = false
func _unhandled_input(_event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("pause") and player.on_console and state == ConsoleState.INTERACTING:
		console_exit()
		get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed("carry") and state == ConsoleState.NEAR:
		interacted()
	if Input.is_action_just_pressed("AutoPrint") and state == ConsoleState.INTERACTING:
		code_run()

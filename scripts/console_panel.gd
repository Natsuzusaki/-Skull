extends Area2D

@export var turned_on: bool = true
@export var characterlimit: int
@export_multiline var base_text: String
@export_multiline var fixed_var: String
@export var outputs: Dictionary = {}
@export var specific_printer: Array = []
@export var console2_5: bool = false

@onready var player: CharacterBody2D = %Player
@onready var camera: Camera2D = %Camera
@onready var label = %Label
@onready var code_edit: CodeEdit = $Terminal/Panel/MarginContainer/VBoxContainer/CodeEdit
@onready var pop_up_animation: AnimationPlayer = $"PopUp Animation"
@onready var control: Control = $Terminal
@onready var text_validator: Node2D = $TextValidator
@onready var consolesprite: Sprite2D = $Console
@onready var consolesprite_near: Sprite2D = $Console_Near
@onready var console_off: Sprite2D = $Console_Off
@onready var limit: Label = $Terminal/Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Limit
@onready var button: AnimatedSprite2D = $Button

enum ConsoleState {IDLE, NEAR, INTERACTING}
var state: ConsoleState = ConsoleState.IDLE
var valid := false #is the script valid
var restart_text := false #restart fixed variables
var value = null #player script
var array_value = [] #player script
var printer_isbroken := false
var prevent_close := false
var control_regex = RegEx.new()

signal print_value()
signal actions_sent()

func _ready() -> void:
	if console2_5:
		code_edit.release_focus()
		control.hide()
	limit.text += str(characterlimit)
	label.text = fixed_var
	code_edit.placeholder_text = base_text
func printer_status(user_code:String) -> bool:
	control_regex.compile(r"print\s*\(([^)]*)\)")
	if all_connected_printers_broken():
		if control_regex.search(user_code):
			return true
	return false
func all_connected_printers_broken() -> bool:
	if specific_printer.is_empty():
		return false
	for path in specific_printer:
		var printer: Node = null
		if typeof(path) == TYPE_NODE_PATH:
			printer = get_node_or_null(path)
		elif typeof(path) == TYPE_STRING:
			printer = get_node_or_null(NodePath(path))
		if printer == null:
			continue
		if not printer.broken:
			return false
	return true

#WAS my greatest dissapointments, but now i fucking love it!
func execute_code(user_code: String) -> bool:
	var script = GDScript.new()
	if user_code.is_empty():
		label.text = "Error: No Script"
		return false
	if printer_status(user_code):
		label.text = "Error: All connected printers are broken"
		return false
	if text_validator.detect_infinite_loops(user_code):
		SfxManager.play_sfx(sfx_settings.SFX_NAME.CONSOLE_ERROR)
		label.text = "Error: Infinite loop \ndetected! \nAdd an increment or break."
		return false
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
		return false
	script.set_source_code(full_script)
	var error = script.reload()
	if text_validator.code_verify(error):
		return false
	elif error == Error.OK:
		var ctx: Dictionary = {}
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
			return true
		else:
			print_value.emit(value, array_value)
			return true
	else:
		return false

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
	consolesprite_near.visible = true
	label.text = fixed_var
	button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	#actions_sent.emit("moved_closer","")
func _on_body_exited(_body: Node2D) -> void:
	if not turned_on:
		return
	player.near_console = false
	camera.back()
	state = ConsoleState.IDLE
	consolesprite_near.visible = false
	button.modulate = Color(1.0, 1.0, 1.0, 0.0)
func _on_code_edit_focus_entered() -> void:
	pass
	#SfxManager.play_sfx(sfx_settings.SFX_NAME.CONSOLE_ON)
	#interacted()
func _on_code_edit_focus_exited() -> void:
	player.stay = false
	player.on_console = false
func _on_code_edit_lines_edited_from(_from_line: int, _to_line: int) -> void:
	if restart_text:
		label.text = fixed_var
		restart_text = false
func console_exit() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.CONSOLE_EXIT)
	state = ConsoleState.NEAR
	player.stay = false
	player.on_console = false
	camera.back()
	code_edit.release_focus()
	pop_up_animation.play("pop_down")
	control.hide()
	actions_sent.emit("console_exited", "")
func interacted() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.CONSOLE_ON)
	state = ConsoleState.INTERACTING
	label.text = fixed_var
	player.stay = true
	player.on_console = true
	camera.focus_on_point(self)
	camera.interact = true
	code_edit.grab_focus()
	control.show()
	pop_up_animation.play("pop_up")
	actions_sent.emit("console_focused", "")
func code_run() -> void:
	array_value.clear()
	var user_code = code_edit.text
	actions_sent.emit("console_run", user_code)
	var success = execute_code(user_code)
	if success:
		if not prevent_close:
			SfxManager.play_sfx(sfx_settings.SFX_NAME.CONSOLE_ON)
			player.stay = false
			player.on_console = false
			camera.back()
			control.hide()
			state = ConsoleState.NEAR
		prevent_close = false
	else:
		SfxManager.play_sfx(sfx_settings.SFX_NAME.CONSOLE_ERROR)
		player.stay = true
		player.on_console = true
		state = ConsoleState.INTERACTING
		camera.focus_on_point(self)
		#label.text += "\n(Fix the error and \ntry again.)"

func stay() -> void:
	control.show()
	player.stay = true
	player.on_console = true
	state = ConsoleState.INTERACTING
	camera.focus_on_point(self)
func retrigger(val) -> void:
	_on_body_entered(val)

func _process(_delta: float) -> void:
	if not turned_on:
		consolesprite.visible = false
		consolesprite_near.visible = false
		console_off.visible = true
	else:
		console_off.visible = false
		consolesprite.visible = true
func _unhandled_input(_event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("pause") and player.on_console and state == ConsoleState.INTERACTING:
		console_exit()
		get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed("carry") and (player.near_console and state == ConsoleState.NEAR):
		interacted()
	if Input.is_action_just_pressed("AutoPrint") and state == ConsoleState.INTERACTING:
		code_run()

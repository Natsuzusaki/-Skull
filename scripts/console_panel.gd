extends Area2D

@export var turned_on: bool = true
@export var characterlimit: int
@export_multiline var base_text: String
@export_multiline var fixed_var: String

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
@onready var limit: Label = $Terminal/Panel/MarginContainer/VBoxContainer/HBoxContainer/Limit

var valid := false 
var restart_text := false
var button_pressed := false
var value = null #player script
var array_value = [] #player script

signal print_value()
signal actions_sent()

func _ready() -> void:
	limit.text = str(characterlimit)
	label.text = fixed_var
	code_edit.placeholder_text = base_text

#WAS my greatest dissapointments, but now i love it!
func execute_code(user_code: String) -> void:
	var script = GDScript.new()
	var formatted_code = text_validator.auto_indentation(user_code, characterlimit)
	var full_script = """
extends Node
%s

var console: Node
func _init(real_console):
	console = real_console

func custom_print(varargs: Array) -> void:
	if console:
		for msg in varargs:
			console.array_value.append(msg)
		console.value = varargs.size() == 1 and varargs[0] or varargs
	else:
		print("Error! something is wrong")

func run():
%s
""" % [fixed_var, formatted_code]
	#print(full_script) #debug
	if formatted_code.is_empty():
		return
	script.set_source_code(full_script)
	var error = script.reload()
	if text_validator.code_verify(error):
		return
	elif error == Error.OK:
		var instance = script.new(self)
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
	array_value = []
	player.stay = true
	var user_code = code_edit.text
	if user_code.is_empty():
		#actions_sent.emit("nothing","")
		label.text = "Nothing to print!"
	else:
		execute_code(user_code)
		player.stay = false
		button_pressed = true
		button.release_focus()
		camera.back()
		pop_up_animation.play("pop_down")
		await pop_up_animation.animation_finished
		control.hide()
		actions_sent.emit("console_run")
func _on_exit_pressed() -> void:
	player.stay = false
	camera.back()
	button_pressed = true
	pop_up_animation.play("pop_down")
	await pop_up_animation.animation_finished
	control.hide()
	#actions_sent.emit("console_exited","")
func _on_body_entered(_body: Node2D) -> void:
	if turned_on:
		consolesprite.visible = false
		consolesprite_near.visible = true
		label.text = fixed_var
		if not button_pressed:
			control.show()
			pop_up_animation.play("pop_up")
			#actions_sent.emit("moved_closer","")
func _on_body_exited(_body: Node2D) -> void:
	if turned_on:
		consolesprite.visible = true
		consolesprite_near.visible = false
		if not button_pressed:
			pop_up_animation.play("pop_down")
		else:
			control.show()
			button_pressed = false
func _on_code_edit_focus_entered() -> void:
	label.text = fixed_var
	player.stay = true
	camera.focus_on_point(self)
	camera.interact = true
	actions_sent.emit("console_focused")
func _on_code_edit_focus_exited() -> void:
	player.stay = false
func _on_code_edit_lines_edited_from(_from_line: int, _to_line: int) -> void:
	if restart_text:
		label.text = fixed_var
		restart_text = false

extends Control

@export var main_menu: Control
@export var settings: Control
@export var user_list: Control
@onready var current_user: Label = %CurrentUser
@onready var start_button: Button = $Background/Menu/MainButtons/Start
@onready var settings_button: Button = $Background/Menu/MainButtons/Settings
@onready var continue_button: Button = $Background/Menu/MainButtons/Continue
var data

func _ready() -> void:
	if SaveManager.current_user == "Guest":
		current_user.text = "Who is playing?"
		start_button.disabled = true
		settings_button.disabled = true
	else:
		current_user.text = "Welcome back! %s" % SaveManager.current_user

func _process(_delta: float) -> void:
	if SaveManager.current_user != "Guest":
		start_button.disabled = false
		settings_button.disabled = false
		data = SaveManager.load_game()
		if data.has("Chapter1"):
			if data["Chapter1"].has("checkpoint_order"):
				continue_button.disabled = false

func _on_startnewgame_pressed() -> void:
	if SaveManager.current_user == "Guest":
		pass
	else:
		get_tree().change_scene_to_file("res://scenes/UI/level_selection_menu.tscn")
		SaveManager.reset_save("Chapter1")

func _on_continue_pressed() -> void:
	Loading.next_scene_path = "res://scenes/levels/newtutorial.tscn"
	get_tree().change_scene_to_file("res://scenes/UI/loading_screen.tscn")

func _on_Settings_pressed() -> void:
	if SaveManager.current_user == "Guest":
		pass
	else:
		main_menu.visible = false
		settings.visible = true

func _on_Exit_pressed() -> void:
	get_tree().quit()

func _on_switch_user_pressed() -> void:
	main_menu.visible = false
	user_list.visible = true

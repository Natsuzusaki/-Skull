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
	MusicManager.play_music("res://assets/music/[1-01] Cave Story (Main Theme) - Cave Story Remastered Soundtrack.mp3", 0.08)
	if SaveManager.current_user == "Guest":
		current_user.text = "Who is playing?"
		start_button.disabled = true
		settings_button.disabled = true
	else:
		current_user.text = "Welcome back! %s" % SaveManager.current_user

func _process(_delta: float) -> void:
	if SaveManager.current_user != "Guest":
		data = SaveManager.load_game()
		start_button.disabled = false
		settings_button.disabled = false

func _on_startnewgame_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	if SaveManager.current_user == "Guest":
		pass
	else:
		get_tree().change_scene_to_file("res://scenes/UI/level_selection_menu.tscn")

func _on_continue_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	if data["Levels"]["level1"]:
		Loading.loading("res://scenes/levels/level2.tscn")
	else:
		Loading.loading("res://scenes/levels/level1.tscn")

func _on_Settings_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	if SaveManager.current_user == "Guest":
		pass
	else:
		main_menu.visible = false
		settings.visible = true

func _on_Exit_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	get_tree().quit()

func _on_switch_user_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	main_menu.visible = false
	user_list.visible = true

func check() -> void:
	print(SaveManager.current_user)
	print(SaveManager.load_game())
	if data.has("Chapter1"):
		if data["Chapter1"].has("checkpoint_order"):
			continue_button.disabled = false
		else:
			continue_button.disabled = true

extends Control

@export var main_menu: Control
#@export var settings: Control
@export var user_list: Control
@onready var current_user: Label = %CurrentUser
@onready var start_button: Button = $Background/Menu/MainButtons/Start
@onready var settings_button: Button = $Background/Menu/MainButtons/Settings
@onready var continue_button: Button = $Background/Menu/MainButtons/Continue
@onready var golden_badge: Sprite2D = $GoldenBadge
@onready var silver_badge: Sprite2D = $SilverBadge
@onready var menu: Panel = $Background/Menu
@onready var silver_trophy: TextureButton = $Background/Menu/SilverTrophy
@onready var golden_trophy: TextureButton = $Background/Menu/GoldenTrophy
@onready var animation_player: AnimationPlayer = $SilverBadge/AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $GoldenBadge/AnimationPlayer2
@onready var sparkle: CPUParticles2D = $Background/Menu/CPUParticles2D


var data = SaveManager.load_game()

func _ready() -> void:
	MusicManager.play_music("res://assets/music/[1-01] Cave Story (Main Theme) - Cave Story Remastered Soundtrack.mp3", 0.08)
	
	if SaveManager.current_user == "Guest":
		current_user.text = "Who is playing?"
		start_button.disabled = true
		settings_button.disabled = true
	else:
		current_user.text = "Welcome back! %s" % SaveManager.current_user
		

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause") and golden_badge.visible or silver_badge.visible:
		golden_badge.visible = false
		silver_badge.visible = false
		menu.visible = true
		
func _process(_delta: float) -> void:
	check_game_completion()
	if SaveManager.current_user != "Guest":
		start_button.disabled = false
		settings_button.disabled = false
		if data.has("Chapter1"):
			if data["Chapter1"].has("checkpoint_order"):
				continue_button.disabled = false
	
	

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
		Pause.show_settings()

func _on_Exit_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	get_tree().quit()

func _on_switch_user_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	main_menu.visible = false
	user_list.visible = true


func _on_silver_trophy_pressed() -> void:
	if golden_badge.visible:
		golden_badge.visible = false
	silver_badge.visible = true
	animation_player.play("silver_badge_animation")
	menu.visible = false


func _on_golden_trophy_pressed() -> void:
	if silver_badge:
		silver_badge.visible = false
	golden_badge.visible = true
	animation_player_2.play("golden_badge_animation")
	menu.visible = false
	
func check_game_completion() -> void:
	var user_data = SaveManager.load_game()
	if user_data.has("Time_and_Medal_Score"):
		if user_data["Time_and_Medal_Score"].has("Chapter1") and user_data["Time_and_Medal_Score"].has("Chapter2") and user_data["Time_and_Medal_Score"].has("Chapter3") and user_data["Time_and_Medal_Score"].has("Chapter4"):
			var lvl1 = user_data["Levels"]["level1"]
			var lvl2 = user_data["Levels"]["level2"]
			var lvl3 = user_data["Levels"]["level3"]
			var lvl4 = user_data["Levels"]["level4"]
			var lvl1_medals = user_data["Time_and_Medal_Score"]["Chapter1"]["prev_medals"]
			var lvl2_medals = user_data["Time_and_Medal_Score"]["Chapter2"]["prev_medals"]
			var lvl3_medals = user_data["Time_and_Medal_Score"]["Chapter3"]["prev_medals"]
			var lvl4_medals = user_data["Time_and_Medal_Score"]["Chapter4"]["prev_medals"]
			if lvl1 and lvl2 and lvl3 and lvl4:
				if lvl1_medals == 3.0 and lvl2_medals == 3.0 and lvl3_medals == 3.0 and lvl4_medals == 3.0:
					sparkle.visible = true
					silver_trophy.position = Vector2(1036, 509)
					silver_trophy.disabled = false
					silver_trophy.visible = true
					golden_trophy.disabled = false
					golden_trophy.visible = true
				else:
					sparkle.visible = false
					silver_trophy.disabled = false
					silver_trophy.visible = true
					silver_trophy.position = Vector2(1152, 509)
					golden_trophy.disabled = true
					golden_trophy.visible = false
		else:
			sparkle.visible = false
			silver_trophy.disabled = true
			silver_trophy.visible = false
			golden_trophy.disabled = true
			golden_trophy.visible = false
		

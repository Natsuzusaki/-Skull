extends Control
@onready var back_button: Button = $BackButton
@onready var main_menu: Control = $"."
@onready var button: Button = %Button
@onready var button_2: Button = %Button2
@onready var button_3: Button = %Button3
@onready var button_4: Button = %Button4
@onready var lvl_2_locked: Panel = $lvl2locked
@onready var lvl_3_locked: Panel = $lvl3locked
@onready var lvl_4_locked: Panel = $lvl4locked
@onready var time_result_1: Label = $Lvl1Completion/TimeResult1
@onready var lvl_1_medal_3: Sprite2D = $Lvl1Completion/lvl1medal3
@onready var lvl_1_medal_2: Sprite2D = $Lvl1Completion/lvl1medal2
@onready var lvl_1_medal_1: Sprite2D = $Lvl1Completion/lvl1medal1
@onready var time_result_2: Label = $Lvl2Completion/TimeResult2
@onready var lvl_2_medal_3: Sprite2D = $Lvl2Completion/lvl2medal3
@onready var lvl_2_medal_2: Sprite2D = $Lvl2Completion/lvl2medal2
@onready var lvl_2_medal_1: Sprite2D = $Lvl2Completion/lvl2medal1
@onready var time_result_3: Label = $Lvl3Completion/TimeResult3
@onready var lvl_3_medal_3: Sprite2D = $Lvl3Completion/lvl3medal3
@onready var lvl_3_medal_2: Sprite2D = $Lvl3Completion/lvl3medal2
@onready var lvl_3_medal_1: Sprite2D = $"Lvl3Completion/lvl3 medal1"
@onready var time_result_4: Label = $Lvl4Completion/TimeResult4
@onready var lvl_4_medal_3: Sprite2D = $Lvl4Completion/lvl4medal3
@onready var lvl_4_medal_2: Sprite2D = $Lvl4Completion/lvl4medal2
@onready var lvl_4_medal_1: Sprite2D = $"Lvl4Completion/lvl4 medal1"
@onready var lvl_1_completion: Control = $Lvl1Completion
@onready var lvl_2_completion: Control = $Lvl2Completion
@onready var lvl_3_completion: Control = $Lvl3Completion
@onready var lvl_4_completion: Control = $Lvl4Completion

var data = SaveManager.load_game()


func _ready() -> void:
	MusicManager.play_music("res://assets/music/[1-01] Cave Story (Main Theme) - Cave Story Remastered Soundtrack.mp3", 0.08)
	button_2.disabled = true
	button_3.disabled = true
	button_4.disabled = true
	
	if SaveManager.is_level_completed(1):
		var scores = data["Time_and_Medal_Score"]["Chapter1"]
		lvl_2_locked.visible = false
		button_2.disabled = false
		if scores.has("prev_time_formatted") and scores.has("prev_medals"):
			lvl_1_completion.visible = true
			var time = scores["prev_time_formatted"]
			time_result_1.text = time
			time_result_1.visible = true
			if scores["prev_medals"] == 3:
				lvl_1_medal_1.visible = false
				lvl_1_medal_2.visible = false
				lvl_1_medal_3.visible = true
			if scores["prev_medals"] == 2:
				lvl_1_medal_1.visible = false
				lvl_1_medal_2.visible = true
				lvl_1_medal_3.visible = false
			if scores["prev_medals"] == 1:
				lvl_1_medal_1.visible = true
				lvl_1_medal_2.visible = false
				lvl_1_medal_3.visible = false
	else:
		lvl_1_completion.visible = false
		
	if SaveManager.is_level_completed(2):
		var scores = data["Time_and_Medal_Score"]["Chapter2"]
		lvl_3_locked.visible = false
		button_3.disabled = false
		if scores.has("prev_time_formatted") and scores.has("prev_medals"):
			lvl_2_completion.visible = true
			var time = scores["prev_time_formatted"]
			time_result_2.text = time
			time_result_2.visible = true
			if scores["prev_medals"] == 3:
				lvl_2_medal_1.visible = false
				lvl_2_medal_2.visible = false
				lvl_2_medal_3.visible = true
			if scores["prev_medals"] == 2:
				lvl_2_medal_1.visible = false
				lvl_2_medal_2.visible = true
				lvl_2_medal_3.visible = false
			if scores["prev_medals"] == 1:
				lvl_2_medal_1.visible = true
				lvl_2_medal_2.visible = false
				lvl_2_medal_3.visible = false
	else:
		lvl_2_completion.visible = false
		
	if SaveManager.is_level_completed(3):
		var scores = data["Time_and_Medal_Score"]["Chapter3"]
		lvl_4_locked.visible = false
		button_4.disabled = false
		if scores.has("prev_time_formatted") and scores.has("prev_medals"):
			lvl_3_completion.visible = true
			var time = scores["prev_time_formatted"]
			time_result_3.text = time
			time_result_3.visible = true
			if scores["prev_medals"] == 3:
				lvl_3_medal_1.visible = false
				lvl_3_medal_2.visible = false
				lvl_3_medal_3.visible = true
			if scores["prev_medals"] == 2:
				lvl_3_medal_1.visible = false
				lvl_3_medal_2.visible = true
				lvl_3_medal_3.visible = false
			if scores["prev_medals"] == 1:
				lvl_3_medal_1.visible = true
				lvl_3_medal_2.visible = false
				lvl_3_medal_3.visible = false
	else:
		lvl_3_completion.visible = false
		
	if SaveManager.is_level_completed(4):
		var scores = data["Time_and_Medal_Score"]["Chapter4"]
		if scores.has("prev_time_formatted") and scores.has("prev_medals"):
			lvl_4_completion.visible = true
			var time = scores["prev_time_formatted"]
			time_result_4.text = time
			time_result_4.visible = true
			if scores["prev_medals"] == 3:
				lvl_4_medal_1.visible = false
				lvl_4_medal_2.visible = false
				lvl_4_medal_3.visible = true
			if scores["prev_medals"] == 2:
				lvl_4_medal_1.visible = false
				lvl_4_medal_2.visible = true
				lvl_4_medal_3.visible = false
			if scores["prev_medals"] == 1:
				lvl_4_medal_1.visible = true
				lvl_4_medal_2.visible = false
				lvl_4_medal_3.visible = false
	else:
		lvl_4_completion.visible = false
	

func _on_button_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	if SaveManager.is_level_completed(1):
		SaveManager.reset_save("Chapter1")
	Loading.loading("res://scenes/levels/level1.tscn")

		

func _on_button_2_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	Loading.loading("res://scenes/levels/level2.tscn")

func _on_button_3_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	#if SaveManager.is_level_completed(3):
		#SaveManager.reset_save("Chapter3")
	Loading.loading("res://scenes/levels/level3.tscn")

func _on_button_4_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	
		
func _on_back_button_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")

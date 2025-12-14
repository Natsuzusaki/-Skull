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
@onready var lvl_3_medal_1: Sprite2D = $"Lvl3Completion/lvl3medal1"
@onready var time_result_4: Label = $Lvl4Completion/TimeResult4
@onready var lvl_4_medal_3: Sprite2D = $Lvl4Completion/lvl4medal3
@onready var lvl_4_medal_2: Sprite2D = $Lvl4Completion/lvl4medal2
@onready var lvl_4_medal_1: Sprite2D = $"Lvl4Completion/lvl4medal1"
@onready var lvl_1_completion: Control = $Lvl1Completion
@onready var lvl_2_completion: Control = $Lvl2Completion
@onready var lvl_3_completion: Control = $Lvl3Completion
@onready var lvl_4_completion: Control = $Lvl4Completion
@onready var animation_player: AnimationPlayer = $Reward/AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $BackButton/AnimationPlayer2

var data = SaveManager.load_game()


func _ready() -> void:
	#animation_player.play("show_golden_trophy")
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
		
	
func _process(_delta: float) -> void:
	check_game_completion()

func _on_button_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	if SaveManager.is_level_completed(1):
		if not data["Time_and_Medal_Score"]["Chapter1"].has("saved_session_time") or data["Time_and_Medal_Score"]["Chapter1"]["saved_session_time"] == 0.0 :
			SaveManager.reset_save("Chapter1")
	Loading.loading("res://scenes/levels/level1.tscn")

		

func _on_button_2_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	if SaveManager.is_level_completed(2):
		if not data["Time_and_Medal_Score"]["Chapter2"].has("saved_session_time") or data["Time_and_Medal_Score"]["Chapter2"]["saved_session_time"] == 0.0 :
			SaveManager.reset_save("Chapter2")
	Loading.loading("res://scenes/levels/level2.tscn")

func _on_button_3_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	if SaveManager.is_level_completed(3):
		if not data["Time_and_Medal_Score"]["Chapter3"].has("saved_session_time") or data["Time_and_Medal_Score"]["Chapter3"]["saved_session_time"] == 0.0 :
			SaveManager.reset_save("Chapter3")
	Loading.loading("res://scenes/levels/level3.tscn")

func _on_button_4_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	if SaveManager.is_level_completed(4):
		if not data["Time_and_Medal_Score"]["Chapter4"].has("saved_session_time") or data["Time_and_Medal_Score"]["Chapter4"]["saved_session_time"] == 0.0 :
			SaveManager.reset_save("Chapter4")
	Loading.loading("res://scenes/levels/level4.tscn")
		
func _on_back_button_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	Scene_Manager.change_scene("res://scenes/UI/main_menu.tscn")
	#get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
	animation_player_2.stop()
	
func check_game_completion() -> void:
	var user_data = SaveManager.load_game()
	if user_data.has("Time_and_Medal_Score"):
		if user_data["Time_and_Medal_Score"].has("Chapter1") and user_data["Time_and_Medal_Score"].has("Chapter2") and user_data["Time_and_Medal_Score"].has("Chapter3") and user_data["Time_and_Medal_Score"].has("Chapter4"):
			var lvl1 = user_data["Levels"]["level1"]
			var lvl2 = user_data["Levels"]["level2"]
			var lvl3 = user_data["Levels"]["level3"]
			var lvl4 = user_data["Levels"]["level4"]
			if lvl1 and lvl2 and lvl3 and lvl4:
				var lvl1_medals = user_data["Time_and_Medal_Score"]["Chapter1"]["prev_medals"]
				var lvl2_medals = user_data["Time_and_Medal_Score"]["Chapter2"]["prev_medals"]
				var lvl3_medals = user_data["Time_and_Medal_Score"]["Chapter3"]["prev_medals"]
				var lvl4_medals = user_data["Time_and_Medal_Score"]["Chapter4"]["prev_medals"]
				if lvl1_medals == 3.0 and lvl2_medals == 3.0 and lvl3_medals == 3.0 and lvl4_medals == 3.0:
					if user_data["Levels"]["golden_trophy_shown"] == false and user_data["Levels"]["silver_trophy_shown"] == false:
						MusicManager.change_volume2(0.01)
						animation_player.play("show_both_rewards")
						user_data["Levels"]["golden_trophy_shown"] = true
						user_data["Levels"]["silver_trophy_shown"]= true
						SaveManager.update_save(user_data)
						await get_tree().create_timer(8).timeout
						animation_player_2.play("new_animation")
						MusicManager.change_volume2(0.08)
					if user_data["Levels"]["golden_trophy_shown"] == false and user_data["Levels"]["silver_trophy_shown"] == true:
						MusicManager.change_volume2(0.01)
						animation_player.play("show_golden_trophy")
						user_data["Levels"]["golden_trophy_shown"] = true
						SaveManager.update_save(user_data)
						await get_tree().create_timer(8).timeout
						animation_player_2.play("new_animation")
						MusicManager.change_volume2(0.08)
				else:
					if user_data["Levels"]["silver_trophy_shown"] == false:
						MusicManager.change_volume2(0.01)
						animation_player.play("show_silver_trophy")
						user_data["Levels"]["silver_trophy_shown"] = true
						SaveManager.update_save(user_data)
						await get_tree().create_timer(8).timeout
						animation_player_2.play("new_animation")
						MusicManager.change_volume2(0.08)
					

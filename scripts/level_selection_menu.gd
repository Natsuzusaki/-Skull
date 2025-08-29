extends Control
@onready var back_button: Button = $BackButton
@onready var main_menu: Control = $"."
@onready var button: Button = %Button
@onready var button_2: Button = %Button2
@onready var button_3: Button = %Button3
@onready var button_4: Button = %Button4
@onready var button_5: Button = %"Button5"
@onready var button_6: Button = %"Button6"
@onready var lvl_2_locked: Panel = $lvl2locked
@onready var lvl_3_locked: Panel = $lvl3locked
@onready var lvl_4_locked: Panel = $lvl4locked
@onready var lvl_5_locked: Panel = $lvl5locked
@onready var lvl_6_locked: Panel = $lvl6locked
@onready var lvl_1_check: Panel = $lvl1check
@onready var lvl_2_check: Panel = $lvl2check
@onready var lvl_3_check: Panel = $lvl3check
@onready var lvl_4_check: Panel = $lvl4check
@onready var lvl_5_check: Panel = $lvl5check
@onready var lvl_6_check: Panel = $lvl6check

func _ready() -> void:
	button_2.disabled = true
	button_3.disabled = true
	button_4.disabled = true
	button_5.disabled = true
	button_6.disabled = true
	
	if SaveManager.is_level_completed(1):
		lvl_1_check.visible = true
		lvl_2_locked.visible = false
		button_2.disabled = false
	else:
		lvl_1_check.visible = false
		
	if SaveManager.is_level_completed(2):
		lvl_2_check.visible = true
		lvl_3_locked.visible = false
		button_3.disabled = false
	else:
		lvl_2_check.visible = false
		
	if SaveManager.is_level_completed(3):
		lvl_3_check.visible = true
		lvl_4_locked.visible = false
		button_4.disabled = false
	else:
		lvl_3_check.visible = false
		
	if SaveManager.is_level_completed(4):
		lvl_4_check.visible = true
		lvl_5_locked.visible = false
		button_5.disabled = false
	else:
		lvl_4_check.visible = false
		
	if SaveManager.is_level_completed(5):
		lvl_5_check.visible = true
		lvl_6_locked.visible = false
		button_6.disabled = false
	else:
		lvl_5_check.visible = false
		
	if SaveManager.is_level_completed(6):
		lvl_6_check.visible = true
	else:
		lvl_6_check.visible = false

func _on_button_pressed() -> void:
	Loading.next_scene_path = "res://scenes/levels/newtutorial.tscn"
	get_tree().change_scene_to_file("res://scenes/UI/loading_screen.tscn")

func _on_button_2_pressed() -> void:
	if SaveManager.is_level_completed(1):
		Loading.next_scene_path = "res://scenes/levels/test.tscn"
		get_tree().change_scene_to_file("res://scenes/UI/loading_screen.tscn")

func _on_button_3_pressed() -> void:
	if SaveManager.is_level_completed(2):
		get_tree().change_scene_to_file("res://scenes/UI/loading_screen.tscn")

func _on_button_4_pressed() -> void:
	if SaveManager.is_level_completed(3):
		get_tree().change_scene_to_file("res://scenes/UI/loading_screen.tscn")

func _on_button_5_pressed() -> void:
	if SaveManager.is_level_completed(4):
		get_tree().change_scene_to_file("res://scenes/UI/loading_screen.tscn")

func _on_button_6_pressed() -> void:
	if SaveManager.is_level_completed(5):
		get_tree().change_scene_to_file("res://scenes/UI/loading_screen.tscn")
		

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")

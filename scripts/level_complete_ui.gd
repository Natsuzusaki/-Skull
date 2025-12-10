extends Control

@export_group("Minimum Minutes Required")
@export var _3star: int
@export var _2star: int
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var play_3_star: AnimationPlayer = $"3star/play3star"
@onready var newtime: Label = $TimeResult
@onready var show_time: AnimationPlayer = $ShowTime
@onready var main_menu_button: Button = $Control/LevelCompleteImage/MainMenuButton
@onready var next_level_button: Button = $Control/LevelCompleteImage/NextLevelButton
@onready var timer_2: Timer = $Timer2
@onready var label: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var button_label: Label = $Control/LevelCompleteImage/NextLevelButton/ButtonLabel

var converted_min3: float
var converted_min2: float
var total_formatted: String
var time_in_sec: float

var medals: int

func _ready() -> void:
	self.visible = false
	var scene_chapter = get_tree().current_scene.current_chapter
	if scene_chapter == "Chapter4":
		main_menu_button.visible = false
		button_label.text = "Return"
		next_level_button.position = Vector2(354,388)
	else:
		main_menu_button.visible = true
		button_label.text = "Next Level"
		next_level_button.position = Vector2(482,388)
		
		
	

func drop_down() -> void:
	self.visible = true
	main_menu_button.disabled = true
	next_level_button.disabled = true
	timer_2.start()
	converted_min3 = _3star * 60
	converted_min2 = _2star * 60
	var time_node = get_tree().current_scene.get_node("Time")
	time_node.stop()
	time_node.visible = false
	time_in_sec = time_node.time
	total_formatted = time_node.total_time
	newtime.text = total_formatted
	get_medal_value()
	animation_player.play("DropDown")
	timer.start()
	await get_tree().create_timer(2).timeout
	label.text = ": under %d minutes\n: under %d minutes\n: over %d minutes" % [_3star, _2star, _2star]
	show_time.play("Show time")

	
func _on_main_menu_button_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	Loading.loading("res://scenes/UI/main_menu.tscn")
	
func _on_next_level_button_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	Loading.loading("res://scenes/UI/level_selection_menu.tscn")
	


func _on_timer_timeout() -> void:
	if time_in_sec <= converted_min3:
		play_3_star.play("3star")
		await get_tree().create_timer(1).timeout
		play_3_star.play("3star_idle")
	if time_in_sec > converted_min3 and time_in_sec <= converted_min2:
		play_3_star.play("2star")
		await get_tree().create_timer(1).timeout
		play_3_star.play("2star_idle")
	if time_in_sec > converted_min2:
		play_3_star.play("1star")
		await get_tree().create_timer(1).timeout
		play_3_star.play("1star_idle")
		
func get_medal_value() -> void:
	if time_in_sec <= converted_min3:
		medals = 3
	if time_in_sec > converted_min3 and time_in_sec <= converted_min2:
		medals = 2
	if time_in_sec > converted_min2:
		medals = 1


func _on_timer_2_timeout() -> void:
	main_menu_button.disabled = false
	next_level_button.disabled = false

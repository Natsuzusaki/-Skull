extends Control

@export_group("Minimum Minutes Required")
@export var _3star: int
@export var _2star: int
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var play_3_star: AnimationPlayer = $"3star/play3star"
@onready var newtime: Label = $TimeResult
@onready var show_time: AnimationPlayer = $ShowTime

var converted_min3: float
var converted_min2: float

var total_formatted: String
var time_in_sec: float
var player: Node
func _ready() -> void:
	self.visible = false
	player = get_tree().current_scene.get_node("Player")
	

func drop_down() -> void:
	self.visible = true
	converted_min3 = _3star
	converted_min2 = _2star
	var time_node = get_tree().current_scene.get_node("Time")
	time_node.stop()
	time_node.visible = false
	time_in_sec = time_node.time
	total_formatted = time_node.total_time
	newtime.text = total_formatted
	animation_player.play("DropDown")
	timer.start()
	await get_tree().create_timer(2).timeout
	show_time.play("Show time")
	print(time_in_sec)

	
func _on_main_menu_button_pressed() -> void:
	SFXManager.play("button_menu")
	Loading.loading("res://scenes/UI/main_menu.tscn")
	
func _on_next_level_button_pressed() -> void:
	SFXManager.play("button_menu")
	Loading.loading("res://scenes/UI/level_selection_menu.tscn")
	


func _on_timer_timeout() -> void:
	print(converted_min3)
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

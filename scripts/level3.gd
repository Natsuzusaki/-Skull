extends Node2D
@onready var player: Player = %Player
@onready var printer: Node2D = $Printers/Printer
@onready var console: Area2D = $Consoles/Console
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var grid: CanvasLayer = $Grid
@onready var lantern_8: Node2D = $Lanterns/Lantern8
@onready var lantern_9: Node2D = $Lanterns/Lantern9
@onready var console_4: Area2D = $Consoles/Console4
@onready var camera: Camera2D = %Camera
@onready var consoles: Node2D = %Consoles
@onready var printers: Node2D = $Printers

@onready var if_1: Control = $Labels/if1
@onready var if_2: Control = $Labels/if2
@onready var if_3: Control = $Labels/if3
@onready var if_4: Control = $Labels/if4
@onready var if_5: Control = $Labels/if5
@onready var if_6: Control = $Labels/if6



var data = SaveManager.load_game()
var ctr := false

var a = 12 > 3
#var b = false
#var c = null
#var d = false
#
#var e:bool


func _ready() -> void:
	MusicManager.play_music_with_fade("res://assets/music/[2-18] White Cliffs - Cave Story Remastered Soundtrack.mp3")
	#e = (a and not b) and (c or d == false)
	#print("test: ",e)
	print("a: ", a)
	
	if_1.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if_2.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if_3.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if_4.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if_5.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if_6.modulate = Color(1.0, 1.0, 1.0, 0.0)
	
	if data.has("Chapter3"):
		var chapter3 = data["Chapter3"]
		if chapter3.has("player_pos"):
			var pos = chapter3["player_pos"]
			player.global_position = Vector2(pos[0], pos[1])
		if chapter3.has("checkpoint_order"):
			var checkpoint = chapter3["checkpoint_order"]
			if checkpoint >= 1.0:
				ctr = true
			if checkpoint == 2.0:
				SaveManager.restore_objects()
	#var light1: PointLight2D = lantern_8.get_node("LanternPhysics/PointLight2D")
	#light1.enabled = false
	#var light2: PointLight2D = lantern_9.get_node("LanternPhysics/PointLight2D")
	#light2.enabled = false
	#var console_light: PointLight2D = console_4.get_node("Terminal/Panel/MarginContainer/VBoxContainer/PointLight2D")
	#console_light.visible = true
	
func _process(_delta: float) -> void:
	if player.on_console:
		grid.visible = false
	#var dark: RigidBody2D = lantern_8.get_node("LanternPhysics")
	#if dark.enabled:
		#fade_to_transparent()

	
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("grid") and not player.on_console and not player.stay:
		if not grid.visible:
			grid.visible = true
		else:
			grid.visible = false
	if Input.is_action_just_pressed("pause") and not player.on_console and not player.stay:
		if not get_tree().paused:
			_pause_game()
			get_viewport().set_input_as_handled()
func _pause_game() -> void:
	get_tree().paused = true
	Pause.paused()


#func fade_to_black(duration: float = 0.3) -> void:
	#var tween := create_tween()
	#tween.tween_property(canvas_modulate, "color", Color(0.0, 0.0, 0.0, 1.0), duration)
#
#func fade_to_transparent(duration: float = 0.3) -> void:
	#var tween := create_tween()
	#tween.tween_property(canvas_modulate, "color", Color(0.317, 0.623, 0.795), duration)
	
#func _on_area_2d_body_entered(_body: Node2D) -> void:
	##player.emit_light()
	##fade_to_black()
#
#func _on_area_2d_body_exited(_body: Node2D) -> void:
	##player.disable_light()
	##fade_to_transparent()

	
func _on_area_2d_body_entered(_body: Node2D) -> void:
	var duration = 0.5
	var tween := create_tween()
	tween.tween_property(if_1, "modulate", Color(1.0, 1.0, 1.0, 1.0), duration)
func _on_area_2d_2_body_entered(_body: Node2D) -> void:
	var duration = 0.5
	var tween := create_tween()
	tween.tween_property(if_2, "modulate", Color(1.0, 1.0, 1.0, 1.0), duration)
func _on_area_2d_3_body_entered(_body: Node2D) -> void:
	var duration = 0.5
	var tween := create_tween()
	tween.tween_property(if_3, "modulate", Color(1.0, 1.0, 1.0, 1.0), duration)
func _on_area_2d_4_body_entered(_body: Node2D) -> void:
	var duration = 0.5
	var tween := create_tween()
	tween.tween_property(if_4, "modulate", Color(1.0, 1.0, 1.0, 1.0), duration)
	
func _on_area_2d_5_body_entered(_body: Node2D) -> void:
	var duration = 0.5
	var tween := create_tween()
	tween.tween_property(if_5, "modulate", Color(1.0, 1.0, 1.0, 1.0), duration)


func _on_area_2d_6_body_entered(_body: Node2D) -> void:
	var duration = 0.5
	var tween := create_tween()
	tween.tween_property(if_6, "modulate", Color(1.0, 1.0, 1.0, 1.0), duration)

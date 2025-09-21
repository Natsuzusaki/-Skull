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


func _ready() -> void:
	var light1: PointLight2D = lantern_8.get_node("LanternPhysics/PointLight2D")
	light1.color = Color(0.0, 0.0, 0.0, 1.0)
	var light2: PointLight2D = lantern_9.get_node("LanternPhysics/PointLight2D")
	light2.color = Color(0.0, 0.0, 0.0, 1.0)
	var console_light: PointLight2D = console_4.get_node("Terminal/Panel/MarginContainer/VBoxContainer/PointLight2D")
	console_light.visible = true
	
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

func fade_to_black(duration: float = 0.3) -> void:
	var tween := create_tween()
	tween.tween_property(canvas_modulate, "color", Color(0.0, 0.0, 0.0, 1.0), duration)

func fade_to_transparent(duration: float = 0.3) -> void:
	var tween := create_tween()
	tween.tween_property(canvas_modulate, "color", Color(0.317, 0.623, 0.795), duration)
	
func _on_area_2d_body_entered(_body: Node2D) -> void:
	player.emit_light()
	fade_to_black()

func _on_area_2d_body_exited(_body: Node2D) -> void:
	player.disable_light()
	fade_to_transparent()

	

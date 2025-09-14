extends Node2D
@onready var player: Player = %Player
@onready var printer: Node2D = $Printers/Printer
@onready var console: Area2D = $Consoles/Console
@onready var canvas_modulate: CanvasModulate = $CanvasModulate

@onready var camera: Camera2D = %Camera
@onready var consoles: Node2D = %Consoles

@onready var printers: Node2D = $Printers

func fade_to_black(duration: float = 0.3) -> void:
	var tween := create_tween()
	tween.tween_property(canvas_modulate, "color", Color(0,0,0,255), duration)

func fade_to_transparent(duration: float = 0.3) -> void:
	var tween := create_tween()
	tween.tween_property(canvas_modulate, "color", Color(0.317, 0.623, 0.795), duration)
	
func _on_area_2d_body_entered(_body: Node2D) -> void:
	player.emit_light()
	fade_to_black()
	#canvas_modulate.color = Color(0,0,0,255)
func _on_area_2d_body_exited(_body: Node2D) -> void:
	player.disable_light()
	fade_to_transparent()
	#canvas_modulate.color = Color(0.317, 0.623, 0.795)
	

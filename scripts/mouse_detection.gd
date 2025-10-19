extends Area2D

@export var parent : Node2D

@onready var platform_name: Label = $CanvasLayer/UI/Panel/MarginContainer/Panel/MarginContainer/VBoxContainer/PlatformName
@onready var movement_coords: Label = $CanvasLayer/UI/Panel/MarginContainer/Panel/MarginContainer/VBoxContainer/MovementCoords
@onready var current_coords: Label = $CanvasLayer/UI/Panel/MarginContainer/Panel/MarginContainer/VBoxContainer/CurrentCoords
@onready var ui: Control = $CanvasLayer/UI
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if parent.move_in_x and parent.move_in_y:
		movement_coords.text = "X and Y coords"
	elif parent.move_in_x and not parent.move_in_y:
		movement_coords.text = "X coords"
	elif parent.move_in_y and not parent.move_in_x:
		movement_coords.text = "Y coords"
	else:
		movement_coords.text = "set the coords"

	if parent.platform_name == "":
		set_collision_layer_value(11, false)
	platform_name.text = parent.platform_name
	ui.visible = false

func _process(_delta: float) -> void:
	if parent:
		var pos = parent.get_grid_pos()
		current_coords.text = "x (%d, %d) y" % [pos.x, pos.y]

func _on_mouse_entered() -> void:
	ui.visible = true
	animation_player.play("pop_up")
func _on_mouse_exited() -> void:
	animation_player.play("pop_down")
	ui.visible = false

func _on_area_entered(_body: Node2D) -> void:
	ui.visible = true
	animation_player.play("pop_up")
func _on_area_exited(_body: Node2D) -> void:
	animation_player.play("pop_down")
	ui.visible = false

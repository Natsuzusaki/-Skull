extends Area2D

@export var parent : Node2D
@export var is_array : bool = false

@onready var platform_name: Label = $CanvasLayer/UI/Platform/MarginContainer/Panel/MarginContainer/VBoxContainer/PlatformName
@onready var movement_coords: Label = $CanvasLayer/UI/Platform/MarginContainer/Panel/MarginContainer/VBoxContainer/MovementCoords
@onready var current_coords: Label = $CanvasLayer/UI/Platform/MarginContainer/Panel/MarginContainer/VBoxContainer/CurrentCoords
@onready var platform: Panel = $CanvasLayer/UI/Platform
@onready var array: Panel = $CanvasLayer/UI/Array
@onready var array_name: Label = $CanvasLayer/UI/Array/MarginContainer/Panel/MarginContainer/VBoxContainer/Name
@onready var array_value: Label = $CanvasLayer/UI/Array/MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer2/ScrollContainer/Value
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dot: Sprite2D = $Sprite2D

func _ready() -> void:
	if is_array:
		dot.visible = false
		array_name.text = parent.arr_name
		format()
		return
	if parent.move_in_x and parent.move_in_y:
		movement_coords.text = "X and Y coords"
	elif parent.move_in_x and not parent.move_in_y:
		movement_coords.text = "X coords"
	elif parent.move_in_y and not parent.move_in_x:
		movement_coords.text = "Y coords"
	else:
		movement_coords.text = "set the coords"

	if parent is TileMapLayer:
		if parent.platform_name == "":
			set_collision_layer_value(11, false)
		platform_name.text = parent.platform_name
	else:
		platform_name.text = "printer"
	platform.visible = false

func _process(_delta: float) -> void:
	if is_array:
		format()
		return
	if parent:
		var pos = parent.get_grid_pos()
		current_coords.text = "x (%d, %d) y" % [pos.x, pos.y]

func format() -> void:
	var formatted = []
	for x in parent.inputs:
		if x is String:
			formatted.append('"' + str(x) + '"')
		else:
			formatted.append(str(x))
	array_value.text = ", ".join(formatted)

func _on_mouse_entered() -> void:
	if is_array:
		array.visible = true
	else:
		platform.visible = true
	animation_player.play("pop_up")
func _on_mouse_exited() -> void:
	animation_player.play("pop_down")
	if is_array:
		array.visible = false
	else:
		platform.visible = false

func _on_area_entered(_body: Node2D) -> void:
	if is_array:
		array.visible = true
	else:
		platform.visible = true
	animation_player.play("pop_up")
func _on_area_exited(_body: Node2D) -> void:
	animation_player.play("pop_down")
	if is_array:
		array.visible = false
	else:
		platform.visible = false

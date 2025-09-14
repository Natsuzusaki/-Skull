extends TileMapLayer

@export var platform_name: String
@export var min_limit: Vector2
@export var max_limit: Vector2
@export var move_in_x: bool
@export var move_in_y: bool
@onready var mouse_detection: Area2D = $MouseDetection
@onready var platform_label: Label = $UI/Panel/MarginContainer/Panel/MarginContainer/VBoxContainer/PlatformName
@onready var movement_coords: Label = $UI/Panel/MarginContainer/Panel/MarginContainer/VBoxContainer/MovementCoords
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ui: Control = $UI

var tile_offset := Vector2.ZERO
var original_pos: Vector2
var target: Vector2

func _ready() -> void:
	if move_in_x and move_in_y:
		movement_coords.text = "X and Y coords"
	elif move_in_x and not move_in_y:
		movement_coords.text = "X coords"
	elif move_in_y and not move_in_x:
		movement_coords.text = "Y coords"
	else:
		movement_coords.text = "set the coords"

	if platform_name == "":
		mouse_detection.set_collision_layer_value(9, false)
	platform_label.text = platform_name
	ui.visible = false
	original_pos = global_position

func move(value) -> void:
	var newpos: Vector2
	if move_in_x:
		newpos = Vector2(value, 0)
	elif move_in_y:
		newpos = Vector2(0, value * 1)
	else:
		return
	target = original_pos + newpos
	target.x = clamp(target.x, min_limit.x, max_limit.x)
	target.y = clamp(target.y, min_limit.y, max_limit.y)
	var tween = create_tween()
	tween.tween_property(self, "global_position", target, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

var commanded_position: Vector2:
	set(value):
		tile_offset = value
		var scaled = original_pos + (tile_offset * 32.0) * -1
		var clamped = Vector2(
			clamp(scaled.x, min_limit.x, max_limit.x),
			clamp(scaled.y, min_limit.y, max_limit.y)
		)
		target = clamped
		#print(target, value, clamped, scaled)
		var tween = create_tween()
		tween.tween_property(self, "global_position", target, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	get:
		return tile_offset

func _on_mouse_detection_mouse_entered() -> void:
	ui.visible = true
	animation_player.play("pop_up")
func _on_mouse_detection_mouse_exited() -> void:
	animation_player.play("pop_down")
	ui.visible = false

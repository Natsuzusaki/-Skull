extends Camera2D

@onready var player: CharacterBody2D = null
@onready var camera_points_parent: Node2D = %CameraPoints
@export var zoom_out: Vector2 = Vector2(1.5, 1.5)
@export var zoom_in: Vector2 = Vector2(3.0, 3.0)
var camera_points: Dictionary = {}
var current_target: Node2D = null
var interact := false
var zoom_speed := 5.0
var follow_speed := 8.0

func _ready() -> void:
	if not player:
		player = get_tree().get_current_scene().find_child("Player")
	if camera_points_parent:
		for child in camera_points_parent.get_children():
			if child is Marker2D:
				camera_points[child.name] = child
	if current_target == null and player:
		current_target = player.cameramark
func _physics_process(delta: float) -> void:
	if interact:
		zoom = zoom.lerp(zoom_in, zoom_speed * delta)
	else:
		zoom = zoom.lerp(zoom_out, zoom_speed * delta)
	if current_target:
		global_position = global_position.lerp(current_target.global_position, follow_speed * delta)
func focus_on_point(point) -> void:
	if typeof(point) == TYPE_STRING and camera_points.has(point):
		current_target = camera_points[point]
	elif typeof(point) in [TYPE_OBJECT] and point is Node2D:
		current_target = point
func focus_on_player() -> void:
	if player:
		current_target = player.cameramark
func focus_on_console(console_node: Node2D) -> void:
	current_target = console_node
func back() -> void:
	interact = false
	current_target = player.cameramark

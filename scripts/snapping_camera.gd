extends Camera2D

@onready var player: CharacterBody2D = null
@onready var camera_points_parent: Node2D = %CameraPoints

@export var zoom_out: Vector2 = Vector2(1.509, 1.501) 
@export var zoom_in: Vector2 = Vector2(3.0, 3.0)   
@export var zoom_speed: float = 5.0
@export var follow_speed: float = 8.0

var camera_points: Dictionary = {}
var current_target: Node2D = null
var interact := false
var cutscene := false
var snapping_enabled := true

var screen_size: Vector2 = Vector2.ZERO
var cur_screen := Vector2.ZERO

func _ready() -> void:
	top_level = true
	make_current()
	if not player:
		player = get_tree().get_current_scene().find_child("Player")
	if camera_points_parent:
		for child in camera_points_parent.get_children():
			if child is Marker2D:
				camera_points[child.name] = child
	if player and player.has_node("cameramark"):
		current_target = player.get_node("cameramark")
	else:
		current_target = player
	screen_size = get_viewport().get_visible_rect().size / zoom
	_snap_to_player_screen()

func _physics_process(delta: float) -> void:
	if interact:
		zoom = zoom.lerp(zoom_in, zoom_speed * delta)
	else:
		zoom = zoom.lerp(zoom_out, zoom_speed * delta)
	if cutscene:
		zoom = zoom.lerp(Vector2(1.65, 1.7), zoom_speed * delta)
	if snapping_enabled:
		var player_screen: Vector2 = (player.global_position / screen_size).floor()
		if not player_screen.is_equal_approx(cur_screen):
			_update_screen(player_screen)
	else:
		if current_target:
			global_position = global_position.lerp(current_target.global_position, follow_speed * delta)

func focus_on_point(point) -> void:
	snapping_enabled = false
	interact = true
	if typeof(point) == TYPE_STRING and camera_points.has(point):
		current_target = camera_points[point]
	elif typeof(point) == TYPE_OBJECT and point is Node2D:
		current_target = point
func focus_on_console(console_node: Node2D) -> void:
	snapping_enabled = false
	interact = true
	current_target = console_node
func focus_on_player(value:bool) -> void:
	snapping_enabled = false
	cutscene = value
	current_target = player
func back() -> void:
	cutscene = false
	interact = false
	snapping_enabled = true
	_snap_to_player_screen()


func _update_screen(new_screen: Vector2) -> void:
	cur_screen = new_screen
	global_position = cur_screen * screen_size + screen_size * 0.5
func _snap_to_player_screen() -> void:
	var player_screen: Vector2 = (player.global_position / screen_size).floor()
	_update_screen(player_screen)

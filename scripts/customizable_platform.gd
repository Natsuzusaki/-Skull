extends TileMapLayer

@export var platform_name: String
@export var min_limit: Vector2
@export var max_limit: Vector2
@export var move_in_x: bool
@export var move_in_y: bool

@onready var camera: Camera2D = %Camera

var grid_pos: Vector2:
	get:
		return get_grid_coords(camera, 32)
var target: Vector2

func _ready() -> void:
	target = global_position

func get_grid_coords(origin: Node2D, tile_size: float = 32.0) -> Vector2:
	var diff: Vector2 = global_position - origin.global_position
	var coords: Vector2 = (diff / tile_size).round()
	coords.y = -coords.y
	return coords

func grid_to_world(coords: Vector2, origin: Node2D, tile_size: float = 32.0) -> Vector2:
	var pos = coords * tile_size
	pos.y = -pos.y
	return origin.global_position + pos

func move(steps: int) -> void:
	if camera.zoom.distance_to(camera.zoom_out) > 0.01:
		await camera.zoom_restored
	var new_grid = grid_pos
	if move_in_x:
		new_grid.x = steps
	elif move_in_y:
		new_grid.y = steps
	target = grid_to_world(new_grid, camera, 32)
	target.x = clamp(target.x, min_limit.x, max_limit.x)
	target.y = clamp(target.y, min_limit.y, max_limit.y)
	var tween = create_tween()
	tween.tween_property(self, "global_position", target, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

var commanded_position: Vector2:
	set(value):
		if camera.zoom.distance_to(camera.zoom_out) > 0.01:
			await camera.zoom_restored
		if move_in_x:
			grid_pos.x = value.x
		elif move_in_y:
			grid_pos.y = value.y
		target = grid_to_world(grid_pos, camera, 32)
		target.x = clamp(target.x, min_limit.x, max_limit.x)
		target.y = clamp(target.y, min_limit.y, max_limit.y)
		var tween = create_tween()
		tween.tween_property(self, "global_position", target, 1) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_IN_OUT)
	get:
		return grid_pos

func _process(_delta: float) -> void:
	grid_pos = get_grid_coords(camera, 32)

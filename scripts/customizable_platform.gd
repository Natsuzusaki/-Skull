extends TileMapLayer

@export var platform_name: String
@export var min_limit: Vector2 = Vector2(-99999, -99999)
@export var max_limit: Vector2 = Vector2( 99999,  99999)
@export var move_in_x: bool = true
@export var move_in_y: bool = false
@export var is_else: bool = false
@export var reverse: bool = false
@export var offset: int = 0
@export var inputs: Array[InputRef] = []

@onready var camera: Camera2D = %Camera

signal grid_pos_changed(new_pos: Vector2)

var target: Vector2
var _last_grid_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	target = global_position
	await get_tree().process_frame  # wait 1 frame so camera snaps
	_last_grid_pos = get_grid_coords(32)
	camera.screen_snapped.connect(func(_screen, _world_center):
		# Re-align to camera center whenever it moves
		_last_grid_pos = get_grid_coords(32)
		#print("[%s] re-synced grid to %s" % [name, _last_grid_pos])
	)
	for ref in inputs:
		var plat = get_node_or_null(ref.platform)
		if plat:
			if plat.has_signal("grid_pos_changed"):
				plat.grid_pos_changed.connect(func(_pos): recalculate())
	if inputs.size() > 0:
		recalculate()

# ----------------------------
# Grid helpers (tile coords relative to camera)
# ----------------------------
func get_grid_coords(tile_size: float = 32.0) -> Vector2:
	# diff relative to snapped camera center
	var diff: Vector2 = global_position - camera.global_position
	var coords: Vector2 = (diff / tile_size).round()
	coords.y = -coords.y
	return coords

func grid_to_world(coords: Vector2, tile_size: float = 32.0) -> Vector2:
	var pos = coords * tile_size
	pos.y = -pos.y
	# anchor world space back to camera center
	return camera.global_position + pos

func get_grid_pos() -> Vector2:
	return get_grid_coords(32)

# ----------------------------
# Movement API (keeps existing external interface)
# ----------------------------
func move(steps: int, axis: String = "") -> void:
	if camera.zoom.distance_to(camera.zoom_out) > 0.01:
		await camera.zoom_restored
	var new_grid = get_grid_pos()
	if move_in_x and move_in_y:
		move_in_x = false
		move_in_y = false
	if move_in_x or axis == "x":
		new_grid.x = steps + offset if not reverse else (steps + offset) * -1
	elif move_in_y or axis == "y":
		new_grid.y = steps + offset if not reverse else (steps + offset) * -1
	_move_to(new_grid)

var commanded_position: Vector2:
	set(value):
		if camera.zoom.distance_to(camera.zoom_out) > 0.01:
			await camera.zoom_restored
		var new_grid := get_grid_pos()
		if move_in_x and move_in_y:
			new_grid = value
		else:
			if move_in_x:
				new_grid.x = value.x
			if move_in_y:
				new_grid.y = value.y
		_move_to(new_grid)
	get:
		return get_grid_pos()

func set_grid_x(val) -> void:
	_last_grid_pos.x = float(val)
	commanded_position = _last_grid_pos

func set_grid_y(val) -> void:
	_last_grid_pos.y = float(val)
	commanded_position = _last_grid_pos

func _move_to(new_grid: Vector2) -> void:
	_last_grid_pos = new_grid
	target = grid_to_world(new_grid, 32)
	target.x = clamp(target.x, min_limit.x, max_limit.x)
	target.y = clamp(target.y, min_limit.y, max_limit.y)
	var tween = create_tween()
	tween.tween_property(self, "global_position", target, 1) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func():
		emit_signal("grid_pos_changed", new_grid)
		#print("[%s] moved to grid %s -> world %s" % [name, new_grid, target])
		)

# ----------------------------
# Input combining
# ----------------------------
func recalculate() -> void:
	if inputs.is_empty():
		return
	var base := get_grid_pos()
	var total := Vector2.ZERO
	var x_modified := false
	var y_modified := false
	for ref in inputs:
		var plat = get_node_or_null(ref.platform)
		if plat == null:
			continue
		var pos: Vector2
		if plat.has_method("get_grid_pos"):
			pos = plat.get_grid_pos()
		else:
			pos = ((plat.global_position - camera.global_position) / 32.0).round()
			pos.y = -pos.y
		var axis = String(ref.axis).to_lower()
		var op   = String(ref.operation).to_lower()
		if axis == "x":
			if x_modified:
				total.x = _apply_op(total.x, pos.x, op)
			else:
				total.x = pos.x
			x_modified = true
		elif axis == "y":
			if y_modified:
				total.y = _apply_op(total.y, pos.y, op)
			else:
				total.y = pos.y
			y_modified = true
	if not x_modified:
		total.x = base.x
	if not y_modified:
		total.y = base.y
	#print("[%s] Recalculated total = %s" % [name, total])
	_move_to(total)

func _apply_op(a: float, b: float, op: String) -> float:
	match op:
		"+": return a + b
		"-": return a - b
		"*": return a * b
		"/": return (a / b) if b != 0.0 else a
		_:   return a

extends RigidBody2D

@export var min_push_interval: float = 2.0
@export var max_push_interval: float = 6.0
@export var push_strength: float = 150.0
@export var enable_wind: bool = true

var bottom_segment: RigidBody2D = self
var wind_timer := 0.0
var next_push_time := 0.0

func _ready() -> void:
	_apply_wind()
	_reset_wind_timer()

func _physics_process(delta: float) -> void:
	if not enable_wind:
		return
	wind_timer += delta
	if wind_timer >= next_push_time:
		_apply_wind()
		_reset_wind_timer()

func _reset_wind_timer():
	wind_timer = 0.0
	next_push_time = randf_range(min_push_interval, max_push_interval)

func _apply_wind():
	var gust = -push_strength
	apply_force(Vector2(gust, 0), Vector2.ZERO)

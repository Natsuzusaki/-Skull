extends RigidBody2D

@export var wind_strength: float = 150.0   # how strong each gust is
@export var min_delay: float = 1.0         # minimum seconds between gusts
@export var max_delay: float = 3.0         # maximum seconds between gusts
var wind_timer := 0.0

func _ready() -> void:
	_reset_timer()

func _physics_process(delta: float) -> void:
	wind_timer -= delta
	if wind_timer <= 0:
		_push_gust()
		_reset_timer()

func _push_gust() -> void:
	# Random horizontal push (left or right)
	var gust = -wind_strength
	apply_force(Vector2(gust, 0), Vector2.ZERO)

func _reset_timer() -> void:
	wind_timer = randf_range(min_delay, max_delay)

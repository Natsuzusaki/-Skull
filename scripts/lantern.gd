extends RigidBody2D

@export var wind_strength: float = 150.0
@export var min_delay: float = 1.0
@export var max_delay: float = 3.0
@onready var point_light_2d: PointLight2D = $PointLight2D

var wind_enable := true
var wind_timer := 0.0
var enabled = false

func _ready() -> void:
	_reset_timer()

func _physics_process(delta: float) -> void:
	if wind_enable:
		wind_timer -= delta
		if wind_timer <= 0:
			_push_gust()
			_reset_timer()

func _push_gust() -> void:
	var gust = -wind_strength
	apply_force(Vector2(gust, 0), Vector2.ZERO)

func _reset_timer() -> void:
	wind_timer = randf_range(min_delay, max_delay)
	
func disable_light(duration: float = 2.0):
	enabled = false
	var tween := create_tween()
	tween.tween_property(point_light_2d, "enabled", false, duration)
	#point_light_2d.energy = 0.0
	
func enable_light(duration: float = 2.0):
	enabled = true
	var tween := create_tween()
	tween.tween_property(point_light_2d, "enabled", true, duration)
	#point_light_2d.energy = 1.0

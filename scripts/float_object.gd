extends RigidBody2D

@onready var player: CharacterBody2D = null
@onready var collision: CollisionShape2D = $Collision
@onready var text_value: Label = $TextValue
var value = null
var is_carried := false

func _ready() -> void:
	value = 0.5 if value == null else value
	if not player:
		player = get_tree().get_current_scene().find_child("Player")
	if player:
		player.on_interact.connect(_on_interact)
	text_value.text = str(value)
	if collision.shape:
		collision.shape = collision.shape.duplicate(true)
	update_collision_shape()

func _on_interact() -> void:
	if player.temp_current_object == self:
		is_carried = player.is_carrying
		if is_carried:
			collision.disabled = true
			freeze = true
		if not is_carried:
			freeze = false
			apply_torque((mass * 1000) * player.static_direction)
			apply_impulse(Vector2((mass * 250) * player.static_direction, 0))
			collision.disabled = false

func _process(_delta: float) -> void:
	if is_carried:
		global_position += Vector2.ZERO
		global_position = player.global_position + Vector2(0, -15)

func initialize(new_value: float) -> void:
	print(value)
	value = new_value
	print(value)

func update_collision_shape() -> void:
	var size = 6
	var text_length = text_value.text.length()
	var text_width = text_length * size
	var new_extents = Vector2(text_width + 3, 12)
	collision.shape.extents = new_extents

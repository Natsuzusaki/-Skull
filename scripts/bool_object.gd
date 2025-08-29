extends RigidBody2D

@onready var player: CharacterBody2D = null
@onready var collision: CollisionShape2D = $Collision
@onready var text_value: Label = $TextValue
var value = null
var is_carried := false

func _ready() -> void:
	value = true if value == null else value
	if not player:
		player = get_tree().get_current_scene().find_child("Player")
	if player:
		player.on_interact.connect(_on_interact)
	text_value.text = str(value)

func _on_interact() -> void:
	if player.temp_current_object == self:
		is_carried = player.is_carrying
		if is_carried:
			angular_damp = 0
			collision.disabled = true
			freeze = true
		if not is_carried:
			angular_damp = 0
			freeze = false
			global_position = player.global_position + Vector2(20 * player.static_direction, -20)
			collision.disabled = false

func _process(_delta: float) -> void:
	if is_carried:
		global_position += Vector2.ZERO
		global_position = player.global_position + Vector2(0, -20)

func initialize(new_value: bool) -> void:
	value = new_value

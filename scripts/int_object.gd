extends RigidBody2D

@export var initial_value: int
@onready var text_value: Label = $TextValue
@onready var collision: CollisionShape2D = $Collision
@onready var player: CharacterBody2D = null
@onready var slot: Control = null
var value = null
var is_carried := false

signal pass_value_to_pickupslot()

func _ready() -> void:
	value = initial_value if value == null else value
	if not player or not slot:
		slot = get_tree().get_current_scene().find_child("PickUp_Slot")
		player = get_tree().get_current_scene().find_child("Player")
	if player:
		player.on_interact.connect(_on_interact)
	if slot:
		slot.in_area.connect(_in_area)
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
			apply_torque((mass * 5000) * player.static_direction)
			apply_impulse(Vector2((mass * 500) * player.static_direction, -(mass * 300)))
			collision.disabled = false

func _in_area(body: Node2D) -> void:
	if body == self:
		pass_value_to_pickupslot.emit(value)
		if value is int:
			queue_free()

func _process(_delta: float) -> void:
	#print(global_position) #WHATT?!?!?!?!?
	if is_carried:
		global_position += Vector2.ZERO
		global_position = player.global_position + Vector2(0, -15)

func initialize(new_value: int) -> void:
	value = new_value

func update_collision_shape() -> void:
	var size = 6
	var text_length = text_value.text.length()
	var text_width = text_length * size
	var new_extents = Vector2(text_width + 3, 12)
	collision.shape.extents = new_extents

extends RigidBody2D

@export var initial_value: int
@onready var text_value: Label = $TextValue
@onready var collision: CollisionShape2D = $Collision
@onready var collision_shape_2d: CollisionShape2D = $ConvertDetect/CollisionShape2D
@onready var collision_shape_2d2: CollisionShape2D = $Die/CollisionShape2D
@onready var player: CharacterBody2D = null
@onready var slot: Control = null
@onready var str_object = load("res://scenes/environment_elements/str_object.tscn")
@onready var float_object = load("res://scenes/environment_elements/float_object.tscn")
@onready var bool_object = load("res://scenes/environment_elements/bool_object.tscn")
var value = null
var is_carried := false

func _ready() -> void:
	value = initial_value if value == null else value
	player = get_tree().get_current_scene().find_child("Player")
	if player:
		player.on_interact.connect(_on_interact)
	text_value.text = str(value)
	if collision.shape:
		collision.shape = collision.shape.duplicate(true)
		collision_shape_2d = collision_shape_2d.duplicate(true)
		collision_shape_2d2 = collision_shape_2d2.duplicate(true)
	update_collision_shape()

func _on_interact() -> void:
	if player.temp_current_object == self:
		is_carried = player.is_carrying
		if is_carried:
			collision.disabled = true
			freeze = true
		if not is_carried:
			freeze = false
			global_position = player.global_position + Vector2(0, -35)
			apply_torque((mass * 5000) * player.static_direction)
			apply_impulse(Vector2((mass * 500) * player.static_direction, -(mass * 300)))
			collision.disabled = false

func _in_area() -> int:
	var val = value
	queue_free()
	return val

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
	collision_shape_2d.shape.extents = new_extents
	collision_shape_2d2.shape.extents = new_extents

func _on_die_body_entered(_body: Node2D) -> void:
	queue_free()

func _convert_value(target_type: String, val) -> Variant:
	match target_type:
		"int": return null
		"float":
			if typeof(val) == TYPE_STRING:
				var parsed = float(val)
				if val.is_valid_float():
					return parsed
				else:
					return null
			elif typeof(val) in [TYPE_INT, TYPE_FLOAT, TYPE_BOOL]:
				return float(val)
			else:
				return null
		"str": return str(val)
		"bool":
			if typeof(val) == TYPE_STRING:
				if val.to_lower() == "true":
					return true
				elif val.to_lower() == "false":
					return false
				else:
					return null
			elif typeof(val) in [TYPE_INT, TYPE_FLOAT]:
				return val != 0
			else:
				return null
		_:
			return null

func convert_type(target_type: String) -> void:
	call_deferred("do_convert_type", target_type)

func do_convert_type(target_type: String) -> void:
	var new_scene: PackedScene = null
	match target_type:
		"float": new_scene = float_object
		"str": new_scene = str_object
		"bool": new_scene = bool_object
		_: return
	var new_value = _convert_value(target_type, value)
	if new_value == null:
		show_conversion_error()
		return
	if new_scene == null:
		push_warning("Conversion failed: no scene found for type " + target_type)
		return
	var new_obj = new_scene.instantiate()
	if new_obj == null:
		push_warning("Conversion failed: could not instantiate scene for " + target_type)
		return
	new_obj.modulate = Color(1, 1, 1, 0)
	new_obj.create_tween().tween_property(new_obj, "modulate:a", 1, 0.2)
	new_obj.global_position = global_position
	new_obj.global_rotation = global_rotation
	if new_obj is RigidBody2D:
		new_obj.linear_velocity = linear_velocity
		new_obj.angular_velocity = angular_velocity
	if new_obj.has_method("initialize"):
		new_obj.initialize(new_value)
	get_parent().add_child(new_obj)
	if player:
		if is_carried and player.temp_current_object == self:
			if target_type in ["int", "float", "bool"]:
				player.temp_current_object = new_obj
				new_obj.is_carried = true
				new_obj.freeze = true
				new_obj.collision.disabled = true
				new_obj.global_position = player.global_position + Vector2(0, -15)
			else:
				player.temp_current_object = null
				player.is_carrying = false
				new_obj.freeze = false
				new_obj.collision.disabled = false
	queue_free()

func show_conversion_error():
	var tween = create_tween()
	var original_color = modulate
	modulate = Color(1, 0.3, 0.3)
	tween.tween_property(self, "modulate", original_color, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

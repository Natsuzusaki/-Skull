extends RigidBody2D

@export var value:bool = true
@onready var player: CharacterBody2D = null
@onready var collision: CollisionShape2D = $Collision
@onready var text_value: Label = $TextValue
@onready var str_object = load("res://scenes/environment_elements/str_object.tscn")
@onready var float_object = load("res://scenes/environment_elements/float_object.tscn")
@onready var int_object = load("res://scenes/environment_elements/int_object.tscn")
#var value = null
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
			global_position = player.global_position + Vector2(45 * player.static_direction, -20)
			collision.disabled = false

func _process(_delta: float) -> void:
	if is_carried:
		global_position += Vector2.ZERO
		global_position = player.global_position + Vector2(0, -15)

func initialize(new_value: bool) -> void:
	value = new_value

func _convert_value(target_type: String) -> Variant:
	match target_type:
		"int":
			if value:
				return 1
			elif not value:
				return 0
			return null
		"float":
			if value:
				return 1.0
			elif not value:
				return 0.0
			return null
		"str":
			if value:
				return "True"
			elif not value:
				return "False"
			return null
		"bool": return null
		_: return null

func convert_type(target_type: String) -> void:
	call_deferred("do_convert_type", target_type)

func do_convert_type(target_type: String) -> void:
	var new_scene: PackedScene = null
	match target_type:
		"int": new_scene = int_object
		"str": new_scene = str_object
		"float": new_scene = float_object
		_: return
	var new_value = _convert_value(target_type)
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

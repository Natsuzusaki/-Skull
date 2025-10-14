extends RigidBody2D

@export var display_text: String 
@export var manipulate_gravity_on_activate: bool
@export var initial_gravity: float = 1.0
@onready var collision: CollisionShape2D = $Collision
@onready var collision2: CollisionShape2D = $ConvertDetect/CollisionShape2D
@onready var player: CharacterBody2D = null
@onready var text_value: Label = $TextValue
@onready var int_object = load("res://scenes/environment_elements/int_object.tscn")
@onready var float_object = load("res://scenes/environment_elements/float_object.tscn")
@onready var bool_object = load("res://scenes/environment_elements/bool_object.tscn")
var status := false
var text_pass = RegEx.new()
var text_add2 = RegEx.new()
var text_add3 = RegEx.new()
var text_sub3 = RegEx.new()
var text_sub2 = RegEx.new()
var text_sub1 = RegEx.new()
var text = null

func _ready() -> void:
	gravity_scale = initial_gravity
	text = display_text if text == null else text
	player = get_tree().get_current_scene().find_child("Player")
	if text:
		text_value.text = text
	if collision.shape:
		collision.shape = collision.shape.duplicate(true)
		collision2.shape = collision2.shape.duplicate(true)
	update_collision_shape()

func update_collision_shape() -> void:
	var base_size := 10
	var base_height := 12
	var total_width := 0
	text_add2.compile('(#)')
	text_add3.compile('(w|m|@|%|~|W|M)')
	text_sub3.compile('(l|i|!|/|I|:|;|,|`)')
	text_sub2.compile('(_)')
	text_sub1.compile('(-|=|1|<|>)')
	
	for chars in text_value.text:
		if text_add2.search(chars):
			total_width += base_size + 2
		elif text_add3.search(chars):
			total_width += base_size + 3
		elif text_sub3.search(chars) or chars.contains("|") or chars.contains(".") or chars.contains("'") or chars.contains('"'):
			total_width += base_size - 3
		elif text_sub2.search(chars):
			total_width += base_size - 2
		elif text_sub1.search(chars):
			total_width += base_size - 1
		else:
			total_width += base_size
	var new_extents = Vector2(total_width + 3, base_height)
	if new_extents.x < 0:
		new_extents = Vector2(0,0)
	collision.shape.extents = new_extents
	collision2.shape.extents = new_extents

func initialize(new_value: String) -> void:
	text = new_value

func activate(continuous: bool, _time: float) -> void:
	if not continuous:
		status = not status
	if manipulate_gravity_on_activate:
		gravity_scale = -initial_gravity if status else initial_gravity

func _convert_value(target_type: String, val) -> Variant:
	match target_type:
		"int":
			if typeof(val) == TYPE_STRING:
				var parsed = int(val)
				if str(parsed) == val:
					return parsed
				return null
			elif typeof(val) in [TYPE_INT, TYPE_FLOAT, TYPE_BOOL]:
				return int(val)
			else:
				return null
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
		"str": return null
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
		"int": new_scene = int_object
		"bool": new_scene = bool_object
		_: return
	var new_value = _convert_value(target_type, text)
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
		player.temp_current_object = null
		player.is_carrying = false
		new_obj.freeze = false
		new_obj.collision.disabled = false
	queue_free()

func show_conversion_error():
	var tween = create_tween()
	# Red flash feedback
	var original_color = modulate
	modulate = Color(1, 0.3, 0.3)  # red tint
	tween.tween_property(self, "modulate", original_color, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

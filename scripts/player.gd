extends CharacterBody2D
class_name Player

#Reference Variables
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var object_out_timer: Timer = $ObjectOutTimer
@onready var down_buffer_timer: Timer = $DownBufferTimer
@onready var jump_sfx: AudioStreamPlayer2D = $JumpSFX
@onready var animation = $Sprite
@onready var death_collision: CollisionShape2D = $DeathDetection/Death_Collision
@onready var pick_up_collision: CollisionShape2D = $PickUp_Area/PickUp_Collision
@onready var collision: CollisionShape2D = $Collision
@onready var state_machine = $StateMachine
@onready var cameramark = $CameraCenter
@onready var debug = $Label
@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

#Inpector Variables (Jump Values)
@export var jump_height: float
@export var jump_time_to_peak: float
@export var jump_time_to_descent: float

#Player's Local Variable
var stay := false # DONT MOVE WHEN INTERACTING THE TERMINAL PLEASE
var dead := false
var down_buffered := false
var jump_buffered := false
var can_coyote_jump := false
var has_double_jump := true
var can_double_jump := true
var push_force := 2000.0
var dynamic_direction := 0.0 #-1 left, 0 idle, 1 right
var static_direction := 0 #1-left, 0-right
var in_range := false
var is_carrying := false
var is_carry_pressed := false #key flagging
var is_jump_pressed := false #key flagging
var nearby_objects: Array = [] #all objects in range
var temp_current_object: Node2D #object reference
var current_object: Node2D #current object carrying

#Interactions with other object
signal on_interact()

#Starting StateMachine, Input, Frame and Physics
func _ready() -> void:
	Engine.time_scale = 1.0
	state_machine.init(self)
func _unhandled_input(event: InputEvent) -> void:
	if not Input.is_action_pressed("carry"):
		is_carry_pressed = false
	if not Input.is_action_pressed("jump"):
		is_jump_pressed = false
	if Input.is_action_just_pressed("debug") and not stay:
		get_tree().reload_current_scene()
	state_machine.process_input(event)
func _process(delta: float) -> void:
	if static_direction == -1:
		animation.flip_h = static_direction
	elif static_direction == 1:
		animation.flip_h = not static_direction
	state_machine.process_frame(delta)
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

#Player Actions
func gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
func jump() -> void:
	if not dead:
		if not can_double_jump:
			velocity.y = jump_velocity * 0.9
		else:
			velocity.y = jump_velocity
		jump_sfx.play()
		jump_buffered = false
func down() -> void:
	set_collision_mask_value(9, false)
	await get_tree().create_timer(0.1).timeout
	set_collision_mask_value(9, true)
func move(_delta: float, move_speed: int) -> void:
	if stay or dead:
		velocity.x = 0
		move_and_slide()
		return
	dynamic_direction = Input.get_axis("left", "right")
	velocity.x = dynamic_direction * move_speed
	var was_on_floor = is_on_floor()
	move_and_slide()
	if was_on_floor and not is_on_floor() and velocity.y >= 0:
		can_coyote_jump = true
		coyote_timer.start()
	if dynamic_direction > 0:
		static_direction = 1
	elif dynamic_direction < 0:
		static_direction = -1
	for i in get_slide_collision_count():
		var obj_collision = get_slide_collision(i)
		var body = obj_collision.get_collider()
		if body is RigidBody2D and body.is_in_group("Pushable"):
			body.angular_velocity = 0
			body.angular_damp = 200000
			var force_dir = -obj_collision.get_normal().normalized()
			body.apply_central_impulse(force_dir * push_force)
			for inner_i in range(body.get_contact_count()):
				var other = body.get_contact_collider(inner_i)
				if other is RigidBody2D and other.is_in_group("Pushable") and other != self:
					other.apply_central_impulse(force_dir * push_force * 0.8)
func move_in_cutscene(target_pos: Vector2, speed := 100) -> void:
	set_process_input(false)
	var dir = (target_pos - global_position).normalized()
	if dir.x > 0:
		static_direction = 1
	else:
		static_direction = -1
	animation.play("run")
	var distance = global_position.distance_to(target_pos)
	var duration = distance / speed
	var tween := create_tween()
	tween.tween_property(self, "global_position", target_pos, duration)
	await tween.finished
	animation.play("idle")
	tween.finished.connect(func():
		set_process_input(true))
func carry() -> void:
	if not dead:
		if not is_carrying and in_range and not is_carry_pressed:
			is_carry_pressed = true
			is_carrying = not is_carrying
			pick_up_collision.disabled = true
			on_interact.emit()
		elif is_carrying and not is_carry_pressed:
			is_carry_pressed = true
			is_carrying = not is_carrying
			object_out_timer.start()
			on_interact.emit()

#Timers
func _on_coyote_timer_timeout() -> void:
	can_coyote_jump = false
func _on_jump_buffer_timer_timeout() -> void:
	jump_buffered = false
func _on_down_buffer_timer_timeout() -> void:
	down_buffered = false
func _on_object_out_timer_timeout() -> void:
	pick_up_collision.disabled = false

#Area Triggers
func _on_pick_up_area_body_entered(body: Node2D) -> void:
	temp_current_object = body
	nearby_objects.append(body)
	update_current_object()
func _on_pick_up_area_body_exited(body: Node2D) -> void:
	nearby_objects.erase(body)
	update_current_object()
func update_current_object() -> void:
	if nearby_objects.is_empty():
		current_object = null
		in_range = false
		return
	var nearest = nearby_objects[0]
	var min_distance = (global_position - nearest.global_position).length()
	for obj in nearby_objects:
		var dist = (global_position - obj.global_position).length()
		if dist < min_distance:
			min_distance = dist
			nearest = obj
	current_object = nearest
	in_range = true
func _on_death_detection_body_entered(_body: Node2D) -> void:
	dead = true
	Engine.time_scale = 0.5
	var tree = get_tree()
	await tree.create_timer(1).timeout
	tree.reload_current_scene()

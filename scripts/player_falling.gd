extends PlayerState

@export var idle_state: PlayerState
@export var run_state: PlayerState
@export var jump_state: PlayerState

func enter() -> void:
	super.enter()
	parent.debug.text = "fall"

func exit() -> void:
	parent.can_double_jump = true
	pass

func process_input(_event: InputEvent) -> PlayerState:
	if Input.is_action_pressed("carry"):
		parent.carry()
	if Input.is_action_just_released("jump"):
		parent.velocity.y *= 0.5
	if Input.is_action_just_pressed("jump") and parent.can_double_jump and parent.has_double_jump:
		if not parent.is_on_floor():
			if not parent.jump_buffered:
				parent.jump_buffered = true
				parent.jump_buffer_timer.start()
			parent.can_double_jump = false
			parent.jump()
	if Input.is_action_just_pressed("down"):
		parent.down_buffer_timer.start()
		parent.down_buffered = true
	return null

func process_physics(delta: float) -> PlayerState:
	if not parent.is_on_floor():
		parent.velocity.y += parent.gravity() * delta
	parent.move(delta, move_speed)
	return null

func process_frame(_delta: float) -> PlayerState:
	if parent.is_on_floor():
		if Input.get_axis("left", "right"):
			return run_state
		return idle_state
	return null

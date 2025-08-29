extends PlayerState

@export var idle_state: PlayerState
@export var jump_state: PlayerState
@export var falling_state: PlayerState

func enter() -> void:
	super.enter()
	parent.debug.text = "run"

func process_input(_event: InputEvent) -> PlayerState:
	if parent.stay:
		return null
	if Input.is_action_just_pressed("down"):
		parent.down()
	if Input.is_action_pressed("carry"):
		parent.carry()
	if Input.is_action_just_pressed("jump"):
		if (parent.is_on_floor() or parent.can_coyote_jump) and not parent.is_jump_pressed:
			parent.is_jump_pressed = true
			parent.jump()
			if parent.can_coyote_jump:
				parent.can_coyote_jump = false
			return jump_state
	return null

func process_physics(delta: float) -> PlayerState:
	if not parent.is_on_floor() and not parent.can_coyote_jump:
		parent.velocity.y += parent.gravity() * delta
	parent.move(delta, move_speed)
	if not parent.dynamic_direction:
		return idle_state
	if parent.is_on_floor() and parent.down_buffered:
		parent.down()
	return null

func process_frame(_delta: float) -> PlayerState:
	if parent.jump_buffered and parent.is_on_floor() and not parent.is_jump_pressed:
		parent.is_jump_pressed = true
		parent.jump()
	if parent.velocity.y > 0 and not parent.is_on_floor():
		return falling_state
	return null

extends PlayerState

@export var idle_state: PlayerState
@export var run_state: PlayerState
@export var falling_state: PlayerState

func enter() -> void:
	super.enter()
	parent.debug.text = "jump"

func process_input(_event: InputEvent) -> PlayerState:
	if Input.is_action_just_released("jump"):
		parent.velocity.y *= 0.5
	if Input.is_action_just_pressed("jump") and parent.can_double_jump and parent.has_double_jump:
		parent.can_double_jump = false
		parent.jump()
	if Input.is_action_pressed("carry"):
		parent.carry()
	return null

func process_physics(delta: float) -> PlayerState:
	if not parent.is_on_floor():
		if parent.velocity.y > 0.1:
			return falling_state
		parent.velocity.y += parent.gravity() * delta

	parent.move(delta, move_speed)

	if parent.is_on_floor():
		if not parent.dynamic_direction:
			return idle_state
	return null

func prcoess_frame(_delta: float) -> PlayerState:
	return null

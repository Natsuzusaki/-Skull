extends Area2D

@export var continuous: bool = false
@export var active_time: float = 1.0
@export var is_opposite: bool = false
@export var outputs: Array[Node] = []

enum PlateMode { NORMAL, AND, OR, NOT }
@export var mode: PlateMode = PlateMode.NORMAL
@export var logic_group: String = ""
@onready var animation_player: AnimationPlayer = $Pressure_Off/AnimationPlayer

var current_object: Node = null
var activated: bool = false
var occupied: int = 0

func _ready() -> void:
	if logic_group != "":
		if not is_in_group(logic_group):
			add_to_group(logic_group)
			print(name, " added to group: ", logic_group)
	print(name, " ready, activated = ", activated, " mode = ", mode, " group = ", logic_group)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("Pushable"):
		print(name, " Not boolean")
		return

	occupied += 1
	print(name, " occupied = ", occupied)
	animation_player.play("pressed")
	current_object = body

	var value: bool = bool(body.get("value"))
	if is_opposite:
		value = !value
	print(name, " boolean value = ", value)

	if value != activated and occupied == 1:
		activated = value
		print(name, " activated = ", activated)
		_evaluate_logic()


func _on_body_exited(body: Node) -> void:
	occupied -= 1
	print(name, " occupied = ", occupied)
	animation_player.play("not_pressed")
	if body == current_object:
		if occupied <= 0:
			current_object = null

	


func _process_value(_value: bool) -> void:
	for output in outputs:
		if output != null:
			output.activate(continuous, active_time)



func _evaluate_logic() -> void:
	match mode:
		PlateMode.NORMAL:
			print(name, " Evaluating NORMAL plate...")
			_process_value(activated)

		PlateMode.AND:
			print(name, " Evaluating AND group: ", logic_group)
			_evaluate_and_group()

		PlateMode.OR:
			print(name, " Evaluating OR group: ", logic_group)
			_evaluate_or_group()

		PlateMode.NOT:
			print(name, " Evaluating NOT group: ", logic_group)
			_evaluate_not_group()



func _get_group_members() -> Array:
	if logic_group == "":
		return [self]

	var members = get_tree().get_nodes_in_group(logic_group)
	var plates := []
	for m in members:
		if m == null:
			continue
		
		if not m.is_inside_tree():
			continue
	
		if m.has_method("_evaluate_logic") or m.has_method("_process_value"):
			plates.append(m)

	print("Group members for '", logic_group, "': count=", plates.size(), " -> ", plates)
	return plates


func _evaluate_and_group() -> void:
	var plates = _get_group_members()
	if plates.is_empty():
		print("AND: no plates found in group ", logic_group)
		return

	var all_true := true
	for plate in plates:
		print("AND checking plate:", plate.name, " activated=", plate.activated)
		if not plate.activated:
			all_true = false
			break
	print("AND check: all plates true? -> ", all_true)


	var leader = _find_leader(plates)
	print("Leader: ", leader)
	
	if all_true:
		for output in leader.outputs:
			if output != null:
				output.activate(continuous, active_time)
				print("Group ", logic_group, " -> activated outputs by leader ", leader.name)
	else:
		print("Group ", logic_group, " not satisfied (AND); leader:", leader.name)


func _evaluate_or_group() -> void:
	var plates = _get_group_members()
	if plates.is_empty():
		print("OR: no plates found in group ", logic_group)
		return

	var any_true := false
	for plate in plates:
		print("OR checking plate:", plate.name, " activated=", plate.activated)
		if plate.activated:
			any_true = true
			break
	print("OR check: any plate true? -> ", any_true)
	var leader = _find_leader(plates)
	if leader == self:
		if any_true:
			for output in leader.outputs:
				if output != null:
					output.activate(continuous, active_time)
					print("Group ", logic_group, " -> activated outputs by leader ", leader.name)
		else:
			print("Group ", logic_group, " not satisfied (OR); leader:", leader.name)
func _evaluate_not_group() -> void:
	var plates = _get_group_members()
	if plates.is_empty():
		print("NOT: no plates found in group ", logic_group)
		return
	var result := true
	var not_plate_count := 0
	for plate in plates:
		print("NOT checking plate:", plate.name, " mode=", plate.mode, " activated=", plate.activated)
		if plate.mode == PlateMode.NOT:
			not_plate_count += 1
			if plate.activated:
				result = false
		else:
			if not plate.activated:
				result = false
	if not_plate_count != 1:
		result = false
	print("NOT check: -> ", result)
	var leader = _find_leader(plates)
	if leader == self:
		if result:
			for output in leader.outputs:
				if output != null:
					output.activate(continuous, active_time)
					print("Group ", logic_group, " -> activated outputs by leader ", leader.name)
		else:
			print("Group ", logic_group, " not satisfied (NOT); leader:", leader.name)
func _find_leader(plates: Array) -> Node:
	if plates.is_empty():
		return self
	for p in plates:
		if p.outputs and p.outputs.size() > 0:
			return p
	return plates[0]

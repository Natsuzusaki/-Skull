extends Area2D

# ----------------------------
# Exported Inspector Settings
# ----------------------------
@export var plate_num: int
@export var continuous: bool = false
@export var active_time: float = 1.0
@export var has_else: bool = false  
@export var is_not: bool = false              # Flip value (NOT gate)
@export var outputs: Array[Node] = []         # Only leader should assign outputs
@export var plat_coords: int
enum LogicOp { NONE, AND, OR }

@export var subgroup: int = 0                 # Subgroup ID (0 = none)
@export var subgroup_operator: LogicOp = LogicOp.NONE
@export var main_group: String = ""           # Main group ID ("" = none)
@export var main_group_operator: LogicOp = LogicOp.NONE

# ----------------------------
# Internal State
# ----------------------------
@onready var animation_player: AnimationPlayer = $red/AnimationPlayer
@onready var green: Sprite2D = $green
@onready var red: Sprite2D = $red
@onready var text: Label = $Label


var current_object: Node = null
var activated: bool = false
var occupied: int = 0
var idle: bool = true

# ----------------------------
# Lifecycle
# ----------------------------
func _ready() -> void:
	if plate_num == 0:
		text.text = " "
	else:
		text.text = str(plate_num)
	green.visible = false
	# Add to group for main group evaluation
	if main_group != "" and not is_in_group(main_group):
		add_to_group(main_group)
	print("Plate ready -> main_group:", main_group, " subgroup:", subgroup)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("Pushable"):
		return

	occupied += 1
	animation_player.play("pressed")
	green.visible = true
	red.visible = false
	current_object = body

	# Apply NOT logic
	var value: bool = bool(body.get("value"))
	if is_not:
		value = !value

	# Update activated state
	_evaluate_logic(value)


func _on_body_exited(body: Node) -> void:
	occupied -= 1
	animation_player.play("not_pressed")
	green.visible = false
	red.visible = true

	if body == current_object and occupied <= 0:
		current_object = null
		#activated = false
		#if main_group != "":
			#_evaluate_logic(value)


# ----------------------------
# Logic Evaluation
# ----------------------------
func _evaluate_logic(value: bool) -> void:
	# Case 1: Standalone (no subgroup, no main group, no operators)
	if (main_group == "" and subgroup == 0 and subgroup_operator == LogicOp.NONE and main_group_operator == LogicOp.NONE):
		if has_else != true:
			if value != activated and occupied == 1:
				activated = value
				_process_value(activated)
				print("Standalone Plate triggered")
				return
		else:
			if idle and occupied == 1:
				idle = false
				activated = value
				print("PLATE HAS ELSE")
				evaluate_else(value)
			elif not idle and value != activated and occupied == 1:
				activated = value
				print("PLATE HAS ELSE")
				evaluate_else(value)
				
			
			
			

	# Case 2: Full group evaluation
	else:
		activated = value
		_evaluate_main_group(value)
		print("Group Plate evaluated")


func _evaluate_main_group(_value: bool) -> void:
	var members = get_tree().get_nodes_in_group(main_group)
	if members.is_empty():
		return

	# --- Step 1: Collect subgroup plate values
	var subgroup_results := {}
	for plate in members:
		if not subgroup_results.has(plate.subgroup):			#"all_occupied": true,
			subgroup_results[plate.subgroup] = { "values": [], "op": plate.subgroup_operator, "plates": [] } #Create dict for every plate
		subgroup_results[plate.subgroup]["plates"].append(plate)
		if plate.occupied != 0:
			subgroup_results[plate.subgroup]["values"].append(plate.activated)	#Append value of every plate in dict
		else:
			pass
			#subgroup_results[plate.subgroup]["values"].append()
			#subgroup_results[plate.subgroup]["all_occupied"] = false
			
	print("Subgroup Plates: ",subgroup_results)
	# --- Step 2: Evaluate each subgroup
	var subgroup_outputs := {}
	
	for id in subgroup_results.keys():
		var entry = subgroup_results[id]
		var total = subgroup_results[id]["plates"].size()
		var values: Array = entry["values"]
		var op: LogicOp = entry["op"]
		
		var val: bool
		
		print("\n")
		print("Values: ",values)
		print("Entry: ",entry)
		
		if op == LogicOp.NONE:
			# No subgroup operator, take first plate's value if occupied
			subgroup_outputs[id] = values.size() > 0 and values[0]
		if op == LogicOp.OR:
			subgroup_outputs[id] = _evaluate_operator(values, op)
		else:
			# Respect operator (AND/OR), only valid if all occupied
			if values.size() == total:
				print("Values = Total, TRUE")
				subgroup_outputs[id] = _evaluate_operator(values, op)
				val = subgroup_outputs[id]
				print("     VAL: ", val)
			else:
				print("Values = Total, FALSE")
				subgroup_outputs[id] = false
		print("Total sg plates ", total)

	
		for plate in entry["plates"]:
			if val:
				print("     MOVING: ", plate.name)
				plate._move_plat(true)
			else:
				print("     NOT MOVING: ", plate.name)
	print("\nSubgroup Values: ", subgroup_outputs)
	# --- Step 3: Evaluate main group operator
	var final_values = subgroup_outputs.values()
	var final_result = false
	if main_group_operator == LogicOp.NONE:
		final_result = final_values.size() > 0 and final_values[0]
	else:
		final_result = _evaluate_operator(final_values, main_group_operator)

	# --- Step 4: Leader executes outputs
	var leader = _find_leader(members)
	if leader != null and final_result:
		for output in leader.outputs:
			if output != null:
				if output.has_method("activate"):
					output.activate(continuous, active_time)
		print("Main group", main_group, "-> final result TRUE (Leader:", leader.name, ")")
		leader.outputs.clear()
		print("Outputs Cleared, Leader: ", leader)
	else:
		print("Main group", main_group, "-> final result FALSE")


# ----------------------------
# Helpers
# ----------------------------
func _evaluate_operator(values: Array, op: LogicOp) -> bool:
	if values.is_empty():
		return false
	match op:
		LogicOp.NONE:
			for v in values:
				if not v: return false
			return true
		LogicOp.AND:
			for v in values:
				if not v: return false
			return true
		LogicOp.OR:
			for v in values:
				if v: return true
			return false
		_:
			return false

func _find_leader(members: Array) -> Node:
	for m in members:
		if m.outputs.size() > 0:
			return m
	return null

func _process_value(_value: bool) -> void:
	for output in outputs:
		if output != null:
			if not output.is_else:
				print("OUTPUT IS NOT ELSE: ", output)
				if output.has_method("activate"):
					output.activate(continuous, active_time)
				if output.has_method("move"):
					output.move(plat_coords)
				
func _move_plat(_value: bool) -> void:
	# Only move when the boolean is true
	if not _value:
		return
	for output in outputs:
		if output != null:
			if not output.has_method("activate") and output.has_method("move"):
				output.move(plat_coords)
				
func evaluate_else(_value: bool) -> void:
	print("EVALUATING ELSE")
	if _value:
		_process_value(_value)
	else:
		for output in outputs:
			if output != null:
				if output.is_else:
					print("OUTPUT IS ELSE: ",output)
					if output.has_method("activate"):
						output.activate(continuous, active_time)
					if output.has_method("move"):
						output.move(plat_coords)
	

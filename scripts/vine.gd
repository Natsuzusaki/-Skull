@tool
extends Node2D

@export var ceiling_path: NodePath = ^"Ceiling"
@export var top_scene: PackedScene
@export var mid1_scene: PackedScene
@export var mid2_scene: PackedScene
@export var bottom_scene: PackedScene

@export var length: int
@export var segment_spacing: float = 16.0

func _ready():
	length = get_random_length()
	if Engine.is_editor_hint():
		return
	build_vine()

func get_random_length() -> int:
	var options = [3, 3, 4, 4, 5, 5, 6, 7, 8]
	return options[randi() % options.size()]

func build_vine():
	for c in get_children():
		if c.name != "Ceiling":
			c.queue_free()
	var ceiling := get_node(ceiling_path) as StaticBody2D
	if ceiling == null:
		push_error("Ceiling node not found at: " + str(ceiling_path))
		return
	var previous_body: RigidBody2D = null
	for i in range(length):
		var segment: RigidBody2D
		if i == 0:
			segment = top_scene.instantiate()
		elif i == length - 1:
			segment = bottom_scene.instantiate()
		else:
			segment = mid1_scene.instantiate() if i % 2 == 0 else mid2_scene.instantiate()
		add_child(segment)
		segment.position = Vector2(0, i * segment_spacing)
		var joint := PinJoint2D.new()
		add_child(joint)
		if i == 0:
			joint.position = (ceiling.position + segment.position) * 0.5
			joint.node_a = ceiling.get_path()
			joint.node_b = segment.get_path()
		else:
			joint.position = (previous_body.position + segment.position) * 0.5
			joint.node_a = previous_body.get_path()
			joint.node_b = segment.get_path()
		previous_body = segment

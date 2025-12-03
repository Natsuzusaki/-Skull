@tool
extends Node2D

@export var ceiling_path: NodePath = ^"Ceiling"
@export var vine_top_scene: PackedScene
@export var vine_mid1_scene: PackedScene
@export var vine_mid2_scene: PackedScene
@export var vine_bottom_scene: PackedScene
@export var chain_top_scene: PackedScene
@export var chain_mid1_scene: PackedScene
@export var chain_mid2_scene: PackedScene
@export var chain_bottom_scene: PackedScene

@export var length: int
@export var segment_spacing: float = 16.0

@export var is_chain: bool = false

func _ready():
	length = get_random_length()
	if Engine.is_editor_hint():
		return
	if is_chain:
		pass
	build_vine()

func get_random_length() -> int:
	var options = [3, 3, 4, 4, 5, 5, 6, 7, 8]
	if is_chain:
		options = [2, 2, 3, 3, 4, 4, 5, 6]
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
		if not is_chain:
			if i == 0:
				segment = vine_top_scene.instantiate()
			elif i == length - 1:
				segment = vine_bottom_scene.instantiate()
			else:
				segment = vine_mid1_scene.instantiate() if i % 2 == 0 else vine_mid2_scene.instantiate()
		elif is_chain:
			if i == 0:
				segment = chain_top_scene.instantiate()
			elif i == length - 1:
				segment = chain_bottom_scene.instantiate()
			else:
				segment = chain_mid1_scene.instantiate() if i % 2 == 0 else chain_mid2_scene.instantiate()
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

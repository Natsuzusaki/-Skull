extends Area2D

@export_enum("int", "float", "str", "bool") var initial_type
@export var can_cycle: bool = false
@export var toggle: bool = false
@export_enum("int", "float", "str", "bool") var change_type
@export_enum("int", "float", "str", "bool") var current_type
@export var experiment: bool = false

@onready var label: Label = $Panel/Label

var status: bool = false
const TYPE_NAMES = ["int", "float", "str", "bool"]

func _ready() -> void:
	label.text = "%s()" % TYPE_NAMES[initial_type]

func _on_area_entered(body: Node2D) -> void:
	var parent = body.get_parent()
	if parent.has_method("convert_type"):
		var type_str = TYPE_NAMES[initial_type]
		parent.convert_type(type_str)

func change() -> void:
	if toggle:
		if not status:
			status = not status
			initial_type = change_type
		elif status:
			status = not status
			initial_type = current_type
	elif can_cycle:
		if experiment:
			initial_type = (initial_type + 1) % (TYPE_NAMES.size() -1)
		else:
			initial_type = (initial_type + 1) % TYPE_NAMES.size()
	var child_collision = $ConvertCollision
	if child_collision:
		child_collision.update_color_rect_color()
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func():
		label.text = "%s()" % TYPE_NAMES[initial_type]
	)
	tween.tween_property(label, "modulate:a", 1.0, 0.2)
	retrigger_bodies()

func retrigger_bodies() -> void:
	call_deferred("_deferred_trigger")

func _deferred_trigger() -> void:
	$ConvertCollision.disabled = true
	await get_tree().physics_frame
	$ConvertCollision.disabled = false
	await get_tree().physics_frame

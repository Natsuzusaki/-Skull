extends Area2D

@export var continuous: bool = false
@export var active_time: float = 1.0
@export var is_opposite: bool = false
@export var outputs: Array[Node] = []

@onready var pressure_off: Sprite2D = $Pressure_Off
@onready var pressure_on: Sprite2D = $Pressure_On
@onready var animation_player: AnimationPlayer = $Pressure_Off/AnimationPlayer

var current_object: Node = null
var activated: bool = false
var occupied: int = 0

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("Pushable"):
		print("Not boolean")
		return

	occupied += 1
	print("occupied = ", occupied)
	animation_player.play("pressed")
	current_object = body

	var value: bool = bool(body.get("value"))
	if is_opposite:
		value = !value
	print("boolean value = ", value)

	if value != activated and occupied == 1:
		activated = value
		_process_value(activated)
		print("activated = ", activated)

func _on_body_exited(body: Node) -> void:
	occupied -= 1
	print("occupied = ", occupied)
	animation_player.play("not_pressed")
	if body == current_object:
		if occupied <= 0:
			current_object = null

func _process_value(value: bool) -> void:
	for output in outputs:
		if output == null:
			continue

		
		if output.has_method("activate"):
			output.activate(continuous, active_time)

		
		if output.name.to_lower().find("lantern") != -1:
			for child in output.get_children():
				if child.has_method("enable_light") and child.has_method("disable_light"):
					if value:
						child.enable_light()
						print("Lantern light enabled")
					else:
						child.disable_light()
						print("Lantern light disabled")

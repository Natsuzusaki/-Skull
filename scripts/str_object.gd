extends RigidBody2D

@export var display_text: String 
@onready var collision: CollisionShape2D = $Collision
@onready var text_value: Label = $TextValue
var text_add2 = RegEx.new()
var text_add3 = RegEx.new()
var text_sub3 = RegEx.new()
var text_sub2 = RegEx.new()
var text_sub1 = RegEx.new()
var text = null

func _ready() -> void:
	text = display_text if text == null else text
	if text:
		text_value.text = text
	if collision.shape:
		collision.shape = collision.shape.duplicate(true)
	update_collision_shape()

func update_collision_shape() -> void:
	var size := 10
	text_add2.compile('(#)')
	text_add3.compile('(w|m|@|%|~|W|M)')
	text_sub3.compile('(l|i|!|/|I|:|;|,|`)')
	text_sub2.compile('(_)')
	text_sub1.compile('(-|=|1|<|>)')
	
	var total_width := 0
	for chars in text_value.text:
		if text_add2.search(chars):
			total_width += size + 2
		elif text_add3.search(chars):
			total_width += size + 3
		elif text_sub3.search(chars) or chars.contains("|") or chars.contains(".") or chars.contains("'") or chars.contains('"'):
			total_width += size - 3
		elif text_sub2.search(chars):
			total_width += size - 2
		elif text_sub1.search(chars):
			total_width += size - 1
		else:
			total_width += size
	var new_extents = Vector2(total_width + 3, 12)
	collision.shape.extents = new_extents 

func initialize(new_value: String) -> void:
	text = new_value

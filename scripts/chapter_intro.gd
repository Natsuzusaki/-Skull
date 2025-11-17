extends CanvasLayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export_multiline var title: String
@onready var label: Label = $Label



func _ready() -> void:
	label.text = title
	self.visible = false
	
func show_intro() -> void:
	self.visible = true
	print("SHOWING INTRO")
	animation_player.play("show")
	await get_tree().create_timer(3.2).timeout
	animation_player.clear_queue()
	self.visible = false

	
	

	

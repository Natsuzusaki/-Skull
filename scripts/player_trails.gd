extends AnimatedSprite2D

var animation_name: String = "run_trail"

func _ready() -> void:
	play(animation_name)
	self.animation_finished.connect(_on_anim_finish)

func _on_anim_finish() -> void:
	queue_free()

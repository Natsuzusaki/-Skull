extends CanvasLayer

func _ready() -> void:
	self.visible = false

func show_grid() -> void:
	self.visible = true

func hide_grid() -> void:
	self.visible = false

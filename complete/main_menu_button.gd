extends TextureButton

func _ready() -> void:
	pivot_offset = size / 2
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _on_mouse_entered() -> void:
	scale = Vector2(1.2, 1.2)

func _on_mouse_exited() -> void:
	scale = Vector2(1, 1)

func _on_pressed() -> void:
	#Butangi lang sa iyang tinuod nga path
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

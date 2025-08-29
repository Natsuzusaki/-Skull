extends TextureButton

func _on_pressed() -> void:
	#Butangi lang sa tinuod nga path
	get_tree().change_scene_to_file("res://scenes/Level2.tscn")


func _on_mouse_entered() -> void:
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	pass # Replace with function body.

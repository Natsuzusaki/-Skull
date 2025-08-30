extends Node

var next_scene_path: String = ""  # where the loading screen should send us

func loading(path: String) -> void:
	next_scene_path = path
	get_tree().change_scene_to_file("res://scenes/UI/loading_screen.tscn")

extends Node

var next_scene_path: String = ""  # where the loading screen should send us

func loading(path: String) -> void:
	next_scene_path = path
	Scene_Manager.play_transition()
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://scenes/UI/loading_screen.tscn")

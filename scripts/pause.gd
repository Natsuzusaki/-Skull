extends Control

@export var settings: Control
@export var pause_menu: Control
@export var blur: Control

func _on_resume_pressed() -> void:
	get_tree().call_group("main", "_resume_game")

func _on_restart_pressed() -> void:
	for checkpoint in get_tree().get_nodes_in_group("Checkpoint"):
		checkpoint.set_deferred("monitoring", true)
	SaveManager.reset_save("Chapter1")
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_settings_pressed() -> void:
	pause_menu.visible = false
	settings.visible = true

func _on_exit_pressed() -> void:
	#save progress
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")

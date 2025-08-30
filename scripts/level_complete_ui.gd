extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_main_menu_button_pressed() -> void:
	Loading.loading("res://scenes/UI/main_menu.tscn")
	
func _on_next_level_button_pressed() -> void:
	Loading.loading("res://scenes/UI/level_selection_menu.tscn")

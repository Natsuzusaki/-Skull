extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("new_animation")
	await get_tree().create_timer(7.0).timeout
	Scene_Manager.change_scene("res://scenes/UI/main_menu.tscn")

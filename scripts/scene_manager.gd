class_name SceneManager extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func change_scene(path: String) -> void:
	animation_player.play("transition_reverse")
	await animation_player.animation_finished
	animation_player.play("transition")
	get_tree().change_scene_to_file(path)
	
func play_transition() -> void:
	animation_player.play("transition_reverse")
	await animation_player.animation_finished
	animation_player.play("transition")
	

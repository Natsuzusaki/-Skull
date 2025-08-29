extends Area2D

@export var order: int
@export var respawn_pos: Vector2
@export var chapter: String

func _ready() -> void:
	_apply_checkpoint_state()

func _apply_checkpoint_state() -> void:
	var data = SaveManager.load_game().get(chapter, {})
	var current_order: int = data.get("checkpoint_order", 0)
	for check in get_tree().get_nodes_in_group("Checkpoint"):
		check.set_deferred("monitoring", check.order > current_order)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		SaveManager.update_save({
			chapter: {
				"checkpoint_order": order,
				"player_pos": [respawn_pos[0], respawn_pos[1]]
			}
		})
		SaveManager.snapshot_objects()
		for check in get_tree().get_nodes_in_group("Checkpoint"):
			if check.order <= order:
				check.set_deferred("monitoring", false)

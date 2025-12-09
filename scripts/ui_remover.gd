extends Area2D

func _on_body_entered(_body: Node2D) -> void:
	if UiManager.current_open and UiManager.current_open != self:
		UiManager.current_open.hide_self()

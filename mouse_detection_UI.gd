extends Panel

func _on_arrow_direction_mouse_entered() -> void:
	get_parent().get_parent().hovered = true
	get_parent().get_parent().highlight.visible = true
func _on_arrow_direction_mouse_exited() -> void:
	get_parent().get_parent().hovered = false
	get_parent().get_parent().highlight.visible = false
func _on_arrow_direction_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse and event.is_pressed() and get_parent().get_parent().hovered:
		if get_parent().get_parent().UI_status:
			get_parent().get_parent().UI_status = false
			get_parent().get_parent().close_shortcut()
		else:
			get_parent().get_parent().open_shortcut()
			get_parent().get_parent().UI_status = true

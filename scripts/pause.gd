extends CanvasLayer

@export var settings: Control
@export var pause_menu: Control
@onready var blur: ColorRect = $Blur


func _ready() -> void:
	self.visible = false

func paused() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.PAUSE)
	self.visible = true

func _unhandled_input(_event: InputEvent) -> void:
	var root = get_tree().current_scene
	var root_name: String
	if root:
		root_name = root.name
	#print(root_name)
	if root_name in ["Level1", "Level2", "Level3", "Level4"]:
		if Input.is_action_just_pressed("pause"):
			if self.visible and not settings.visible:
				SfxManager.play_sfx(sfx_settings.SFX_NAME.UNPAUSE)
				self.visible = false
				get_tree().paused = false
			elif self.visible and settings.visible and not pause_menu.visible:
				settings.visible = false
				pause_menu.visible = true

func _on_resume_pressed() -> void:
	self.visible = false
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	get_tree().paused = false

func _on_restart_pressed() -> void:
	self.visible = false
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	for checkpoint in get_tree().get_nodes_in_group("Checkpoint"):
		checkpoint.set_deferred("monitoring", true)
	var root_name := get_tree().current_scene.name
	var lvl := root_name.replace("Level", "")
	SaveManager.reset_save("Chapter%s" % lvl)
	SaveManager.reset_session_time("Chapter%s" % lvl)
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_settings_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	pause_menu.visible = false
	settings.visible = true

func _on_exit_pressed() -> void:
	self.visible = false
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	get_tree().paused = false
	var main_scene = get_tree().current_scene
	var scene_chapter = get_tree().current_scene.current_chapter
	if main_scene.has_node("Time") and scene_chapter:
		var time_node = main_scene.get_node("Time")
		SaveManager.save_timer_for_session(scene_chapter, time_node.time)
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")

func show_settings() -> void:
	self.visible = true
	blur.visible = false
	pause_menu.visible = false
	settings.visible = true
func hide_settings() -> void:
	self.visible = false
	blur.visible = true
	pause_menu.visible = true
	settings.visible = false
	

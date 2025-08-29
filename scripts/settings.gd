extends Panel

@export var previous_menu: Control
@onready var input_button_scene = preload("res://scenes/UI/rebindbutton.tscn")
@onready var action_list: VBoxContainer = %ActionList
@onready var music_slider: HSlider = $MarginContainer/ScrollContainer/Entire_settings/Sliders/Music_control/MusicSlider
@onready var sfx_slider: HSlider = $MarginContainer/ScrollContainer/Entire_settings/Sliders/SFX_control/SFXSlider

var is_remapping = false
var action_to_remap = null
var remapping_button = null
var music_bus_id: int
var sfx_bus_id: int

var input_actions = {
	"left": "Move Left",
	"right": "Move Right",
	"down": "Move Down",
	"jump": "Jump",
	"carry": "Interact/Carry",
	"debug": "Restart"
}
func _ready():
	music_bus_id = AudioServer.get_bus_index("Music")
	sfx_bus_id = AudioServer.get_bus_index("SFX")
	load_settings()

#Keybinds
func _create_action_list():
	for item in action_list.get_children():
		item.queue_free()
	var current_data = SaveManager.load_game()
	var keybinds = {}
	if current_data.has("Settings") and current_data["Settings"].has("keybinds"):
		keybinds = current_data["Settings"]["keybinds"]
	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		action_label.text = input_actions[action]
		if keybinds.has(action) and keybinds[action] != "":
			InputMap.action_erase_events(action)
			var ev := InputEventKey.new()
			ev.physical_keycode = OS.find_keycode_from_string(keybinds[action])
			InputMap.action_add_event(action, ev)
			input_label.text = keybinds[action]
		else:
			var events = InputMap.action_get_events(action)
			if events.size() > 0:
				input_label.text = events[0].as_text().trim_suffix(" (Physical)")
			else:
				input_label.text = ""
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))
func _on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press any key to bind..."
func _input(event):
	if is_remapping:
		if (event is InputEventKey ||(event is InputEventMouseButton && event.pressed)):
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			_update_action_list(remapping_button, event)
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			accept_event()
func _update_action_list(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")
func _on_reset_to_default_pressed() -> void:
	InputMap.load_from_project_settings()
	var keybinds = {}
	for action in input_actions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			keybinds[action] = events[0].as_text().trim_suffix(" (Physical)")
		else:
			keybinds[action] = ""
	SaveManager.update_save({
		"Settings": {
			"music_volume":music_slider.value,
			"sfx_volume":sfx_slider.value,
			"keybinds":keybinds
		}
	})
	_create_action_list()

#Sounds
func _on_music_slider_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(music_bus_id, db)
func _on_sfx_slider_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(sfx_bus_id, db)

#Load/save settings
func load_settings():
	var data = SaveManager.load_game()
	if data.is_empty():
		return
	if data.has("Settings"):
		var settings = data["Settings"]
		if settings.has("music_volume"):
			music_slider.value = settings["music_volume"]
			AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(settings["music_volume"]))
		if settings.has("sfx_volume"):
			sfx_slider.value = settings["sfx_volume"]
			AudioServer.set_bus_volume_db(sfx_bus_id, linear_to_db(settings["sfx_volume"]))
		if settings.has("keybinds"):
			for action in settings["keybinds"]:
				InputMap.action_erase_events(action)
				var ev := InputEventKey.new()
				ev.physical_keycode = OS.find_keycode_from_string(settings["keybinds"][action])
				InputMap.action_add_event(action, ev)
		_create_action_list()
func save_settings():
	var music_value = music_slider.value
	var sfx_value = sfx_slider.value
	var keybinds = {}
	for action in input_actions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			keybinds[action] = events[0].as_text().trim_suffix(" (Physical)")
		else:
			keybinds[action] = ""
	SaveManager.update_save({
		"Settings": {
			"music_volume": music_value,
			"sfx_volume": sfx_value,
			"keybinds": keybinds
		}
	})

#Back
func _on_back_pressed() -> void:
	save_settings()
	self.visible = false
	previous_menu.visible = true

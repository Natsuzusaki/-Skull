extends Node

var current_user: String = "Guest"
var users: Array = []
var object_scene: Array[PackedScene] = []

func _ready() -> void:
	_load_user_list()

#Saving player data
func save_game(data: Dictionary, user:String = current_user) -> void:
	var path = "user://%s_save.json" % user
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
#Call this when updating saved data
func update_save(new_data: Dictionary) -> void:
	var current_data = load_game()
	for chapter_key in new_data.keys():
		if not current_data.has(chapter_key):
			current_data[chapter_key] = {}
		for key in new_data[chapter_key].keys():
			var value = new_data[chapter_key][key]
			if typeof(value) == TYPE_DICTIONARY and current_data[chapter_key].has(key):
				current_data[chapter_key][key].merge(value, true)
			else:
				current_data[chapter_key][key] = value
	save_game(current_data)
#Load data duhh
func load_game() -> Dictionary:
	var path = "user://%s_save.json" % current_user
	if not FileAccess.file_exists(path):
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return JSON.parse_string(content)
#Reset specific key in data
func reset_save(key:String) -> void:
	var data = load_game()
	if data.has(key):
		data[key] = {}
	save_game(data)
#Save Objects in world
func snapshot_objects() -> void:
	object_scene.clear()
	for obj in get_tree().get_nodes_in_group("Dynamic_Objects"):
		if obj.is_in_group("Static_Objects"):
			pass
		else:
			var packed := PackedScene.new()
			packed.pack(obj)
			object_scene.append(packed)
#Load Objects in world
func restore_objects() -> void:
	for packed in object_scene:
		var inst = packed.instantiate()
		var objects_parent = get_tree().current_scene.get_node("Objects")
		objects_parent.add_child(inst)

# Level Progression
func mark_level_completed(level: int) -> void:
	var data = load_game()
	if not data.has("Levels"):
		data["Levels"] = {}
	data["Levels"]["level%s" % level] = true
	save_game(data)
func is_level_completed(level: int) -> bool:
	var data = load_game()
	if data.has("Levels") and data["Levels"].has("level%s" % level):
		return data["Levels"]["level%s" % level]
	return false

#User database
func create_user(user: String) -> void:
	if user in users:
		return
	users.append(user)
	save_game({
		"Levels": {
			"level1": false, 
			"level2": false, 
			"level3": false, 
			"level4": false, 
			"level5": false,
			"level6": false
			},
		"Settings": {
			"keybinds": {
				"left": "A",
				"right": "D",
				"down": "S",
				"jump": "Space",
				"carry": "E",
				"debug": "Q"
			}, 
			"music_volume": 1.0, 
			"sfx_volume": 1.0
		}
	}, user)
	_save_user_list()
func set_user(user : String) -> void:
	current_user = user
	load_game()
func _save_user_list() -> void:
	var file = FileAccess.open("user://users.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(users))
	file.close()
func _load_user_list() -> void:
	if FileAccess.file_exists("user://users.json"):
		var file = FileAccess.open("user://users.json", FileAccess.READ)
		var content = file.get_as_text()
		users = JSON.parse_string(content)
		file.close()
	else:
		users = []
func delete_user(user: String) -> void:
	if user in users:
		users.erase(user)
		_save_user_list()
		var path = "user://%s_save.json" % user
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
		if current_user == user:
			current_user = "Guest"

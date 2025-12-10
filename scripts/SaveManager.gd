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
	print("LEVEL RESETTED")
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

func evaluate_level_score(chapter: String) -> void:
	var data = load_game()
	if not data["Time_and_Medal_Score"].has(chapter):
		var chapt = {"Time_and_Medal_Score": {chapter: {}}}
		update_save(chapt)
		print("CREATING CHAPTER")
		
	var reload_data = load_game()
	var chap = reload_data["Time_and_Medal_Score"][chapter]
	
	if not chap.has("prev_time"):
		print("NO PREV DATA")
		var new_time = data[chapter]["level_time"]
		var new_time_formatted = data[chapter]["level_time_formatted"]
		var new_medals = data[chapter]["medals_earned"]
	
		var a = {"Time_and_Medal_Score": {chapter: {}}}
		a["Time_and_Medal_Score"][chapter]["prev_time_formatted"] = new_time_formatted
		a["Time_and_Medal_Score"][chapter]["prev_medals"] = new_medals
		a["Time_and_Medal_Score"][chapter]["prev_time"] = new_time
		update_save(a)

	else:
		print("HAS PREV DATA")
		var prev_time = data["Time_and_Medal_Score"][chapter]["prev_time"]
		
		var new_time = data[chapter]["level_time"]
		var new_time_formatted = data[chapter]["level_time_formatted"]
		var new_medals = data[chapter]["medals_earned"]
		if new_time < prev_time:
			var a = {"Time_and_Medal_Score": {chapter: {}}}
			a["Time_and_Medal_Score"][chapter]["prev_time"] = new_time
			a["Time_and_Medal_Score"][chapter]["prev_time_formatted"] = new_time_formatted
			a["Time_and_Medal_Score"][chapter]["prev_medals"] = new_medals
			update_save(a)
			print("OVERRIDING OLD DATA")
		else:
			print("Current score is not the best")
		

#User database
func create_user(user: String) -> void:
	if user in users:
		return
	users.append(user)
	save_game({
		"Chapter1":{
			"checkpoint_order": 0.0,
			"player_position":[],
			"flags":{}
		},
		"Chapter2":{
			"checkpoint_order": 0.0,
			"player_position":[],
			"flags":{}
		},
		"Chapter3":{
			"checkpoint_order": 0.0,
			"player_position":[],
			"flags":{}
		},
		"Chapter4":{
			"checkpoint_order": 0.0,
			"player_position":[],
			"flags":{}
		},
		"Time_and_Medal_Score":{
			
		},
		"Notes":{
			"note_0":false,
			"note_1":false,
			"note_2":false,
			"note_3":false,
			"note_4":false,
			"note_5":false,
			"note_6":false,
			"note_7":false,
			"note_8":false,
			"note_9":false,
			"note_10":false,
			"note_11":false,
			"note_12":false,
			"note_13":false,
			"note_14":false,
			"note_15":false,
			"note_16":false,
			"note_17":false,
			"note_18":false,
			"note_19":false
		},
		"Levels": {
			"level1": false, 
			"level2": false, 
			"level3": false, 
			"level4": false,
			"silver_trophy_shown": false,
			"golden_trophy_shown": false
			},
		"Settings": {
			"keybinds": {
				"up": "W",
				"left": "A",
				"right": "D",
				"down": "S",
				"jump": "Space",
				"carry": "E",
				"debug": "Q",
				"grid": "G"
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

func save_timer_for_session(chapter: String, timer_value: float) -> void:
	var timer_data = {"Time_and_Medal_Score": {chapter:{"saved_session_time": timer_value}}}
	update_save(timer_data)
	print("Saved current timer for '%s': %.2f seconds." % [chapter, timer_value])
	
func reset_session_time(chapter: String) -> void:
	var data = load_game()
	if data["Time_and_Medal_Score"].has(chapter):
		if not data["Time_and_Medal_Score"][chapter].has("saved_session_time"):
			return
	var session_time = {"Time_and_Medal_Score": {chapter: {}}}
	session_time["Time_and_Medal_Score"][chapter]["saved_session_time"] = 0.0
	update_save(session_time)
	
func save_level_completion(chapter: String, time_node: Node, level_complete_node: Node) -> void:
	if not time_node:
		print("Warning: No Time node provided for level completion save.")
		return
		
	time_node.stop()  
	var completion_time = time_node.time 

	var completion_data = {chapter: {"level_time": completion_time}}
	completion_data[chapter]["level_time_formatted"] = time_node.total_time
	completion_data[chapter]["medals_earned"] = level_complete_node.medals
	update_save(completion_data)

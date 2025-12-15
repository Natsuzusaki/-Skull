extends CanvasLayer

@onready var flag: AnimatedSprite2D = $Flag
@onready var player_icon: AnimatedSprite2D = $PlayerIcon
@onready var lvl1: TextureProgressBar = $lvl1
@onready var lvl2: TextureProgressBar = $lvl2
@onready var lvl3: TextureProgressBar = $lvl3
@onready var lvl4: TextureProgressBar = $lvl4

var working = true
var total_rooms: int = 0
var current_room: int = 1
var visited_rooms : Array = []

var lvl_vals = [9.1, 10.0, 12.5, 12.5]


func _ready() -> void:
	
	set_pb()
	var rooms = get_parent().get_node("Rooms").get_children()
	total_rooms = rooms.size()
	print("Total rooms: ", total_rooms)
	
func evaluate_progress(room_number: int) -> void:
	var scene_chapter = get_tree().current_scene.current_chapter
	var chap_num = int(scene_chapter.substr(7,1))
	var lvl_num = "lvl%s" % chap_num
	var lvl_node = get_node(lvl_num)
	
	if working:
		if visited_rooms.size() == 1 and room_number != 1:
			if not visited_rooms.has(room_number):
				for i in range(1, room_number + 1):
					if not visited_rooms.has(i):
						visited_rooms.append(i)
			var val = lvl_vals[chap_num - 1] * room_number
			var val2 = 24 * room_number - 24
			lvl_node.value = val
			player_icon.position.x = 58 + val2
			current_room = room_number
			print("yahoo")
			print("Entered room no.: ",room_number)
			print("Visited rooms:",visited_rooms)
			return
		
		if room_number == current_room and visited_rooms.size() == 0:
			if not visited_rooms.has(room_number):
				visited_rooms.append(room_number)
			print("Icon position: ", player_icon.position.x)
			print("Entered room no.: ",room_number)
			print("Visited rooms:",visited_rooms)
			return
			
		
		if not visited_rooms.has(room_number):
			visited_rooms.append(room_number)
			lvl_node.value += 9.1
			player_icon.position.x += 24
			
		
		else:
			if room_number > current_room:
				player_icon.position.x += 24
				
			
			elif room_number < current_room:
				if player_icon.position.x != 58:
					player_icon.position.x -= 24
					
				
		
		current_room = room_number
		print("Icon position: ", player_icon.position.x)
		print("Entered room no.: ",room_number)
		print("Visited rooms:",visited_rooms)
		print("Current Room: ",current_room)
	
	
func set_pb() -> void:
	var scene_chapter = get_tree().current_scene.current_chapter
	if scene_chapter == "Chapter1":
		lvl1.visible = true
		lvl2.visible = false
		lvl3.visible = false
		lvl4.visible = false
		lvl1.value = 9.1
		player_icon.position.x = 58
		flag.position.x = 327
	if scene_chapter == "Chapter2":
		lvl1.visible = false
		lvl2.visible = true
		lvl3.visible = false
		lvl4.visible = false
		lvl2.value = 9.1
		player_icon.position.x = 58
		flag.position.x = 304
	if scene_chapter == "Chapter3":
		lvl1.visible = false
		lvl2.visible = false
		lvl3.visible = true
		lvl4.visible = false
		lvl3.value = 9.1
		player_icon.position.x = 58
		flag.position.x = 256
	if scene_chapter == "Chapter4":
		lvl1.visible = false
		lvl2.visible = false
		lvl3.visible = false
		lvl4.visible = true
		lvl4.value = 9.1
		player_icon.position.x = 58
		flag.position.x = 256

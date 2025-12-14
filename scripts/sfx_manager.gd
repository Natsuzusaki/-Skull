extends Node

#@onready var sfx_player := AudioStreamPlayer2D.new()
var sfx_dict = {}
@export var SFX_SETTINGS: Array[sfx_settings]

func _ready():
	for sfx_setting : sfx_settings in SFX_SETTINGS:
		sfx_dict[sfx_setting.sfx_name] = sfx_setting
		
func play_sfx(type: sfx_settings.SFX_NAME):
	if sfx_dict.has(type):
		var sfx_setting: sfx_settings = sfx_dict[type]
		var sfx_player = AudioStreamPlayer.new()
		add_child(sfx_player)
		
		sfx_player.bus = "SFX"
		sfx_player.stream = sfx_setting.sfx_file
		sfx_player.volume_db = sfx_setting.volume
		var base_pitch = sfx_setting.pitch
		var random_offset = (randf() * 2 - 1) * sfx_setting.pitch_random
		sfx_player.pitch_scale = base_pitch + random_offset 
		sfx_player.finished.connect(sfx_player.queue_free)
		sfx_player.play()

func mute_sfx() -> void:
	var bus_index := AudioServer.get_bus_index("SFX")
	if bus_index == -1:
		return
	AudioServer.set_bus_mute(bus_index,true)
	await get_tree().create_timer(1.0).timeout
	AudioServer.set_bus_mute(bus_index,false)
	
	


















#var sfx: Dictionary = {
	#"button_menu": preload("res://assets/music/gameboy-pluck.mp3"),
	#"button": preload("res://assets/music/button_press_sfx.mp3"),
	#"note": preload("res://assets/music/note_sfx.mp3"),
	#"death": preload("res://assets/music/death_sfx.mp3"),
	#"death2": preload("res://assets/music/death2_sfx.wav"),
	#"console": preload("res://assets/music/console.mp3"),
	#"console_exit": preload("res://assets/music/console exit.mp3"),
	#"console_error": preload("res://assets/music/console error.mp3"),
	#"vine": preload("res://assets/music/vine-boom-392646.mp3"),
	#"vine2": preload("res://assets/music/vine-boom-spam-sound-effect-205568.mp3"),
	#"laugh": preload("res://assets/music/laugh.mp3"),
#}

#var sfx_volume = 0
#
#func _ready() -> void:
	#add_child(sfx_player)
	#sfx_player.bus = "SFX"
	#sfx_player.autoplay = false
	#sfx_player.volume_db = linear_to_db(sfx_volume)
	#
#func play(sfx_name: String) -> void:
	#if not sfx.has(sfx_name):
		#return
	#var new_sfx_player := AudioStreamPlayer.new()
	#new_sfx_player.stream = sfx[sfx_name]
	#new_sfx_player.bus = "SFX"
	#new_sfx_player.volume_db = linear_to_db(sfx_volume)
	#add_child(new_sfx_player)
	#new_sfx_player.play()
	#new_sfx_player.connect("finished", Callable(new_sfx_player, "queue_free"))

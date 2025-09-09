extends Node

@onready var sfx_player := AudioStreamPlayer2D.new()

var sfx_volume: int = 1

var sfx: Dictionary = {
	"button_menu": preload("res://assets/music/gameboy-pluck.mp3"),
	"button": preload("res://assets/music/button_press_sfx.mp3"),
	"note": preload("res://assets/music/note_sfx.mp3"),
	"death": preload("res://assets/music/death_sfx.mp3"),
	"death2": preload("res://assets/music/death2_sfx.wav"),
	"console": preload("res://assets/music/console.mp3"),
	"console_exit": preload("res://assets/music/console exit.mp3"),
	"console_error": preload("res://assets/music/console error.mp3"),
	"vine": preload("res://assets/music/vine-boom-392646.mp3"),
	"vine2": preload("res://assets/music/vine-boom-spam-sound-effect-205568.mp3"),
	"laugh": preload("res://assets/music/laugh.mp3"),
}

func _ready() -> void:
	add_child(sfx_player)
	sfx_player.bus = "SFX"
	sfx_player.autoplay = false
	sfx_player.volume_db = linear_to_db(sfx_volume)
	
func play(sfx_name: String) -> void:
	if not sfx.has(sfx_name):
		return
	var new_sfx_player := AudioStreamPlayer.new()
	new_sfx_player.stream = sfx[sfx_name]
	new_sfx_player.bus = "SFX"
	new_sfx_player.volume_db = linear_to_db(sfx_volume)
	add_child(new_sfx_player)
	new_sfx_player.play()
	new_sfx_player.connect("finished", Callable(new_sfx_player, "queue_free"))

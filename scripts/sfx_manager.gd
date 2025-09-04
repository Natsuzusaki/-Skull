extends Node

@onready var sfx_player := AudioStreamPlayer.new()

var sfx_volume: int

var sfx: Dictionary = {
	"button_click": preload("res://assets/music/gameboy-pluck.mp3"),
}

func _ready() -> void:
	add_child(sfx_player)
	sfx_player.bus = "SFX"
	sfx_player.autoplay = false
	
# Play a sound effect by name
func play(name: String) -> void:
	if not sfx.has(name):
		return
	
	var player := AudioStreamPlayer.new()
	player.stream = sfx[name]
	player.volume_db = linear_to_db(sfx_volume)
	add_child(player)

	# Play and queue free after finished
	player.play()
	player.connect("finished", Callable(player, "queue_free"))

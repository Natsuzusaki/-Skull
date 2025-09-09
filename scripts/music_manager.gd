extends Node

@onready var music_player := AudioStreamPlayer.new()
@onready var music_player_loop := AudioStreamPlayer.new()

var current_track: String = ""
var music_volume: float = 1.0
var fade_in_duration: float = 3.0
var tween: Tween

const MAX_VOLUME: float = 0.4

func _ready() -> void:
	add_child(music_player)
	add_child(music_player_loop)

	music_player.bus = "Music"
	music_player_loop.bus = "Music"

	music_player.autoplay = false
	music_player_loop.autoplay = false

	music_player.volume_db = linear_to_db(0)
	music_player_loop.volume_db = linear_to_db(clamp(music_volume, 0.0, MAX_VOLUME))

	music_player.finished.connect(_on_intro_finished)

func set_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, MAX_VOLUME)
	if music_player:
		music_player.volume_db = linear_to_db(music_volume)
	if music_player_loop:
		music_player_loop.volume_db = linear_to_db(music_volume)

func play_music(path: String) -> void:
	if current_track == path:
		return
	var stream = load(path)
	if stream and stream is AudioStream:
		stop_music()
		music_player.stream = stream
		set_volume(music_volume)
		music_player.play()
		current_track = path

func play_music_with_fade(path: String) -> void:
	if current_track == path:
		return
	var stream = load(path)
	if stream and stream is AudioStream:
		stop_music()
		current_track = path

		var intro_stream = stream.duplicate()
		if intro_stream is AudioStream: 
			intro_stream.loop = false
			
		music_player.stream = intro_stream
		music_player.play()
		music_player.volume_db = -80 
		
		tween = create_tween()
		tween.tween_property(
			music_player, "volume_db",
			linear_to_db(clamp(music_volume, 0.0, MAX_VOLUME)),
			fade_in_duration
		)
		var loop_stream = stream.duplicate()
		if loop_stream is AudioStream:
			loop_stream.loop = true
		music_player_loop.stream = loop_stream
		music_player_loop.volume_db = linear_to_db(clamp(music_volume, 0.0, MAX_VOLUME))

func _on_intro_finished() -> void:
	if music_player_loop.stream:
		music_player_loop.play()

func stop_music() -> void:
	music_player.stop()
	music_player_loop.stop()
	current_track = ""

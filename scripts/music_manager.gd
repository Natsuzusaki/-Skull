extends Node

@onready var music_player := AudioStreamPlayer.new()
@onready var music_player_loop := AudioStreamPlayer.new()

var current_track: String = ""
var music_volume: int = 1
var fade_in_duration: float = 6.0  # seconds
var tween: Tween

func _ready() -> void:
	add_child(music_player)
	add_child(music_player_loop)

	music_player.bus = "Music"
	music_player_loop.bus = "Music"

	music_player.autoplay = false
	music_player_loop.autoplay = false

	music_player.volume_db = linear_to_db(-80) # will fade in
	music_player_loop.volume_db = linear_to_db(music_volume)

	# Connect finished signal
	music_player.finished.connect(_on_intro_finished)

# Play a normal looping track (like menu music)
func play_music(path: String) -> void:
	if current_track == path:
		return
	var stream = load(path)
	if stream and stream is AudioStream:
		stop_music()
		music_player.stream = stream
		music_player.volume_db = linear_to_db(music_volume)
		music_player.play()
		current_track = path

# Play a track with fade-in intro, then loop same file normally
func play_music_with_fade(path: String) -> void:
	if current_track == path:
		return
	var stream = load(path)
	if stream and stream is AudioStream:
		stop_music()
		current_track = path
		fade_in_duration = fade_in_duration

		# First pass (fade in, no loop)
		var intro_stream = stream.duplicate()
		if intro_stream is AudioStream: # safety check
			intro_stream.loop = false
			
		music_player.stream = stream
		music_player.play()
		current_track = path
		music_player.volume_db = -80  # silent start
		tween = create_tween()
		tween.tween_property(music_player, "volume_db", linear_to_db(music_volume), fade_in_duration)
		#music_player.stream = intro_stream
		#music_player.volume_db = linear_to_db(0)
		#music_player.play()

		# Tween volume to full
		var tween = create_tween()
		tween.tween_property(
			music_player, "volume_db",
			linear_to_db(music_volume),
			fade_in_duration
		)

		# Loop version (will play after intro finishes)
		var loop_stream = stream.duplicate()
		if loop_stream is AudioStream:
			loop_stream.loop = true
		music_player_loop.stream = loop_stream
		music_player_loop.volume_db = linear_to_db(music_volume)


# Signal handler: intro finished → play looping track
func _on_intro_finished() -> void:
	if music_player_loop.stream:
		music_player_loop.play()

# Stop all music
func stop_music() -> void:
	music_player.stop()
	music_player_loop.stop()
	current_track = ""

# Set volume globally
#func set_volume(value: float) -> void:
	#music_volume = value
	## If fading intro is running, keep tween as-is
	#if music_player.playing:
		#music_player.volume_db = clamp(music_player.volume_db, -80, linear_to_db(value))
	#if music_player_loop.playing:
		#music_player_loop.volume_db = linear_to_db(value)
		

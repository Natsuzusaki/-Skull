extends Control

@onready var status_label: Label = $StatusLabel
@onready var progress_bar: ProgressBar = $ProgressBar

var next_scene_path: String
var min_display_time := 2.0
var elapsed_time := 0.0
var scene_loaded := false

var displayed_progress := 0.0

func _ready():
	next_scene_path = Loading.next_scene_path
	ResourceLoader.load_threaded_request(next_scene_path)

func _process(delta):
	elapsed_time += delta

	var progress = []
	var status = ResourceLoader.load_threaded_get_status(next_scene_path, progress)
	var target_progress = progress[0] if progress.size() > 0 else 0.0

	displayed_progress = lerp(displayed_progress, target_progress, 5 * delta)
	progress_bar.value = int(displayed_progress * 100)

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		scene_loaded = true

	if scene_loaded and elapsed_time >= min_display_time and abs(displayed_progress - 1.0) < 0.01:
		var packed_scene = ResourceLoader.load_threaded_get(next_scene_path)
		get_tree().change_scene_to_packed(packed_scene)

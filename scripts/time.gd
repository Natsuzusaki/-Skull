extends CanvasLayer
@onready var hours: Label = $Panel/Hours
@onready var minutes: Label = $Panel/Minutes
@onready var seconds: Label = $Panel/Seconds

var time: float = 0.0
var sec: int = 0
var minute: int = 0
var hr: int = 0
var total_time: String

func _ready() -> void:
	update_display()  # Optional: Ensure labels start at 00:00:00

func _process(delta) -> void:
	time += delta
	sec = int(fmod(time, 60))
	minute = int(fmod(time, 3600) / 60)
	hr = int(fmod(fmod(time, 216000) / 3600,24))
	
	hours.text = "%02d" % hr
	minutes.text = "%02d" % minute
	seconds.text = "%02d" % sec

func stop():
	set_process(false)
	total_time = "%02d:%02d:%02d" % [hr, minute, sec]
	print(total_time)

# New: Update display from current 'time' value (for instant restore after reload)
func update_display() -> void:
	sec = int(fmod(time, 60))
	minute = int(fmod(time, 3600) / 60)
	hr = int(fmod(fmod(time, 216000) / 3600, 24))
	
	hours.text = "%02d" % hr
	minutes.text = "%02d" % minute
	seconds.text = "%02d" % sec

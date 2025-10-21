extends Resource
class_name sfx_settings

enum SFX_NAME{
	MENU_BUTTON,
	LEVEL_BUTTON,
	NOTE,
	DEATH,
	DEATH2,
	CONSOLE_ON,
	CONSOLE_EXIT,
	CONSOLE_ERROR,
	STONE_PLATFORM
}

@export var sfx_name: SFX_NAME
@export var sfx_file: AudioStream
@export_range(-40.0, 1.0) var volume = 0.1
@export_range(0.0,4.0,.01) var pitch = 1.0
@export_range(0.0,0.5,.01) var pitch_random = 0.0

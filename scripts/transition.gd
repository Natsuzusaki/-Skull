extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect
@onready var color_rect_2: ColorRect = $ColorRect2

func _ready() -> void:
	color_rect.visible = false
	color_rect_2.visible = false

func start_cutscene() -> void:
	color_rect.visible = true
	color_rect_2.visible = true
	animation_player.play("cutscene_on")

func end_cutscene() -> void:
	animation_player.play("cutscene_off")
	await animation_player.animation_finished
	color_rect.visible = false
	color_rect_2.visible = false

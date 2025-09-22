extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

func _process(_delta: float) -> void:
	pass
	#if not color_rect or not player:
		#return
	#var vp = get_viewport()
	#var screen_pos: Vector2 = vp.get_screen_transform() * player.global_position
	#var mat := color_rect.material
	#if mat and mat is ShaderMaterial:
		#mat.set_shader_parameter("center_pos", screen_pos)
	#else:
		#if "set_shader_parameter" in color_rect:
			#color_rect.set_shader_parameter("center_pos", screen_pos)

func close_fog() -> void:
	color_rect.visible = true
	animation_player.play("black_zoom_in")
func open_fog() -> void:
	animation_player.play("black_zoom_out")
	await animation_player.animation_finished
	color_rect.visible = false

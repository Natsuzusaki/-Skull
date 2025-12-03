extends Sprite2D

@export var output: Node2D
@export var disable: bool = false
@onready var camera: Camera2D = %Camera
@onready var player: CharacterBody2D = %Player
@onready var explosion: GPUParticles2D = %CrystalExplosion
@onready var area: Area2D = $Area2D
var player_near: bool = false
var broken: bool = false

func _on_area_2d_body_entered(_body: Node2D) -> void:
	player_near = true

func _on_area_2d_body_exited(_body: Node2D) -> void:
	player_near = false

func _ready() -> void:
	if material:
		material = material.duplicate()

func _process(_delta: float) -> void:
	if player_near and not player.is_carrying and not player.dead and not player.near_button and not player.near_console and not player.near_note and not broken and not disable:
		if Input.is_action_just_pressed("carry"):
			if player.global_position < global_position:
				player.global_position = global_position + Vector2(-30, 8)
				player.static_direction = 1
			else:
				player.global_position = global_position + Vector2(30, 8)
				player.static_direction = -1
			broken = true
			player.stay = true
			player.sprite_animation("mining")
			flash_white()
			await wait(2)
			deactivate()
			player.sprite_animation("idle")
			player.stay = false
func flash_white():
	for a in range(2):
		await wait(0.8)
		var mat := material
		mat.set("shader_parameter/flash_amount", 1.0)
		var t = create_tween()
		t.tween_property(mat, "shader_parameter/flash_amount", 0.0, 0.4) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_OUT)
	await wait(0.1)
	explosion.position = position
	explosion.emitting = true
	await wait(0.1)
	self.visible = false
	await wait(0.5)
	explosion.emitting = false
	self.queue_free()

func deactivate() -> void:
	output.crystal_ctr -= 1
	if output.crystal_ctr == 0:
		output.speak()
		output.activate = false
		camera.unlock()

func wait(time) -> void:
	await get_tree().create_timer(time).timeout

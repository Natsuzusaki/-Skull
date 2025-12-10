extends Area2D

@export var parent : Node
@export var is_array : bool = false

@onready var platform_name: Label = $CanvasLayer/UI/Platform/MarginContainer/Panel/MarginContainer/VBoxContainer/PlatformName
@onready var movement_coords: Label = $CanvasLayer/UI/Platform/MarginContainer/Panel/MarginContainer/VBoxContainer/MovementCoords
@onready var current_coords: Label = $CanvasLayer/UI/Platform/MarginContainer/Panel/MarginContainer/VBoxContainer/CurrentCoords
@onready var platform: Panel = $CanvasLayer/UI/Platform
@onready var array: Panel = $CanvasLayer/UI/Array
@onready var array_name: Label = $CanvasLayer/UI/Array/MarginContainer/Panel/MarginContainer/VBoxContainer/Name
@onready var array_size: Label = $CanvasLayer/UI/Array/MarginContainer/Panel/MarginContainer/VBoxContainer/Size
@onready var array_value: RichTextLabel = $CanvasLayer/UI/Array/MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer2/ScrollContainer/Value
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dot: Sprite2D = $Sprite2D
var hovered: bool = false
var UI_status: bool = false
var book := false

func _ready() -> void:
	if parent is CanvasLayer:
		dot.visible = false
		book = true
		return
	if is_array:
		dot.visible = false
		array_name.text = parent.display_name
		format()
		return
	print(parent)
	if parent.move_in_x and parent.move_in_y:
		movement_coords.text = "X and Y coords"
	elif parent.move_in_x and not parent.move_in_y:
		movement_coords.text = "X coords"
	elif parent.move_in_y and not parent.move_in_x:
		movement_coords.text = "Y coords"
	else:
		movement_coords.text = "set the coords"

	if parent is TileMapLayer:
		if parent.platform_name == "":
			set_collision_layer_value(11, false)
		platform_name.text = parent.platform_name
	else:
		platform_name.text = "printer"
	platform.visible = false

func _process(_delta: float) -> void:
	if book:
		return
	if is_array:
		format()
		return
	if parent:
		var pos = parent.get_grid_pos()
		current_coords.text = "x (%d, %d) y" % [pos.x, pos.y]

func format() -> void:
	var formatted := []
	for x in parent.inputs:
		var text := ""
		if x is String:
			text = '[color=orange]"%s"[/color]' % x
		elif x is int:
			text = "[color=blue]%s[/color]" % x
		elif x is float:
			text = "[color=green]%s[/color]" % x
		elif x is bool:
			text = "[color=red]%s[/color]" % ("true" if x else "false")
		else:
			text = str(x)
		formatted.append(text)
	array_value.bbcode_enabled = true
	var final_text := "[ " + ", ".join(formatted) + " ]"
	array_value.parse_bbcode(final_text)
	array_size.text = str(parent.inputs.size())


func _on_mouse_entered() -> void:
	hovered = true
	if book:
		parent.high_light.visible = true
func _on_mouse_exited() -> void:
	hovered = false
	if book:
		parent.high_light.visible = false

func _on_area_entered(_body: Node2D) -> void:
	pass
	#if is_array:
		#array.visible = true
	#else:
		#platform.visible = true
	#animation_player.play("pop_up")
func _on_area_exited(_body: Node2D) -> void:
	pass
	#animation_player.play("pop_down")
	#if is_array:
		#array.visible = false
	#else:
		#platform.visible = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if hovered and event is InputEventMouseButton and event.pressed:
		if UI_status:
			if book:
				parent.show_book()
			else:
				hide_self()
			UI_status = false
		else:
			if book:
				parent.show_note()
			else:
				SfxManager.play_sfx(sfx_settings.SFX_NAME.HOVER)
				show_self()
			UI_status = true

func show_self():
	if UiManager.current_open and UiManager.current_open != self:
		UiManager.current_open.hide_self()
	if is_array:
		parent.outline(true)
		array.visible = true
	else:
		parent.outline(true)
		platform.visible = true
	animation_player.play("pop_up")
	UiManager.current_open = self
func hide_self():
	if is_array:
		parent.outline(false)
		array.visible = false
	else:
		parent.outline(false)
		platform.visible = false
	animation_player.play("pop_down")

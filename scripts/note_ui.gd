extends CanvasLayer

@onready var player: CharacterBody2D = %Player
@onready var blur: ColorRect = $Blur
@onready var notebook: Node2D = $Notebook
@onready var high_light: Sprite2D = $Notebook/HighLight
@onready var notes: Node2D = $Notes
@onready var button_1: AnimatedSprite2D = $Button1
@onready var button_2: AnimatedSprite2D = $Button2
@onready var button_3: AnimatedSprite2D = $Button3
@onready var panel: Panel = $Panel
@onready var panel2: Panel = $Panel2
@onready var label: Label = $Panel/Label
@onready var mouse_detection: Area2D = $MouseDetection

var note_nodes: Array = []
var empty_note: Node2D
var data: Dictionary
var note_ctr := 0

func _ready():
	load_data()
	show_book()
	for child in notes.get_children():
		if child.name == "Empty":
			empty_note = child
		else:
			note_nodes.append(child)
		child.visible = false

func load_data():
	data = SaveManager.load_game()
func show_book():
	SfxManager.play_sfx(sfx_settings.SFX_NAME.NOTE)
	mouse_detection.UI_status = false
	player.stay = false
	blur.visible = false
	notes.visible = false
	button_1.visible = false
	button_2.visible = false
	button_3.visible = false
	notebook.visible = true
	panel.visible = false
	panel2.visible = false
func show_note():
	SfxManager.play_sfx(sfx_settings.SFX_NAME.NOTE)
	var pb = get_tree().get_current_scene().find_child("ProgressBar")
	pb.visible = false
	mouse_detection.UI_status = true
	player.stay = true
	blur.visible = true
	notes.visible = true
	button_1.visible = true
	button_2.visible = true
	button_3.visible = true
	panel.visible = true
	panel2.visible = true
	load_data()
	display_note()

func display_note():
	load_data()
	for child in notes.get_children():
		child.visible = false
	var note_id = note_ctr
	var note_key = "note_%s" % note_id
	var is_found = data.get("Notes", {}).get(note_key, false)
	if is_found:
		if note_ctr < note_nodes.size():
			note_nodes[note_ctr].visible = true
		else:
			empty_note.visible = true
	else:
		empty_note.visible = true
	update_page_label()

func _unhandled_input(_event):
	var pb = get_tree().get_current_scene().find_child("ProgressBar")
	if not notes.visible:
		return
	if Input.is_action_just_pressed("pause"):
		if not pb.visible:
			pb.visible = true
		show_book()
		get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("left<-"):
		SfxManager.play_sfx(sfx_settings.SFX_NAME.NOTE)
		note_ctr -= 1
		if note_ctr < 0:
			note_ctr = note_nodes.size() - 1
		display_note()
	if Input.is_action_just_pressed("right") or Input.is_action_just_pressed("right->"):
		SfxManager.play_sfx(sfx_settings.SFX_NAME.NOTE)
		note_ctr += 1
		if note_ctr >= note_nodes.size():
			note_ctr = 0
		display_note()

func update_page_label():
	var total_notes = note_nodes.size()
	var display_number = note_ctr + 1
	label.text = "Note %s of %s" % [display_number, total_notes]

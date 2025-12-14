extends Panel

@export var parent: Control
@export var previous_menu: Control
@onready var user_list: ItemList = $%UserList
@onready var name_input: LineEdit = $VBoxContainer/Name_input
@onready var confirmation_panel: Control = $ConfirmationPanel
@onready var delete_user: Button = $VBoxContainer2/Delete_User
@onready var set_user: Button = $VBoxContainer/HBoxContainer/Set_User
@onready var create_user: Button = $VBoxContainer/HBoxContainer/Create_user
@onready var notice: Label = $Notice




var selected_user

const MAX_NAME_LENGTH := 16

func _ready() -> void:
	confirmation_panel.visible = false
	delete_user.disabled = true
	user_list.visible = true
	create_user.disabled = true
	set_user.disabled = true
	user_list.clear()
	for user in SaveManager.users:
		user_list.add_item(user)

func clear_selection() -> void:
	user_list.deselect_all()
	selected_user = null
	delete_user.disabled = true
	set_user.disabled = true

func _on_user_list_item_selected(index: int) -> void:
	delete_user.disabled = false
	set_user.disabled = false
	selected_user = user_list.get_item_text(index)
	
func _on_create_user_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	var new_user = name_input.text.strip_edges()
	if new_user == "" or SaveManager.users.has(new_user):
		return
	if new_user.length() > MAX_NAME_LENGTH:
		new_user = new_user.substr(0, MAX_NAME_LENGTH)
	SaveManager.create_user(new_user)
	user_list.add_item(new_user)
	name_input.clear()
	create_user.disabled = true
	clear_selection()
		
func _on_set_user_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	if selected_user != null:
		SaveManager.set_user(selected_user)
		var settings_scene = Pause.find_child("Settings", false, false)
		if settings_scene:
			print(settings_scene)
			settings_scene.load_settings()
		
		parent.current_user.text = "Welcome back! %s" % selected_user
		var parent2 = get_parent().get_parent()
		parent2.check_game_completion()
		Scene_Manager.play_transition()
		await get_tree().create_timer(0.4).timeout
		self.visible = false
		previous_menu.visible = true
func _on_user_list_item_activated(_index: int) -> void:
	_on_set_user_pressed()
	
func _on_name_input_text_changed(new_text: String) -> void:
	# Trim spaces and cut off at max length
	var trimmed = new_text.strip_edges()
	if trimmed.length() > MAX_NAME_LENGTH:
		trimmed = trimmed.substr(0, MAX_NAME_LENGTH)
		name_input.text = trimmed

	create_user.disabled = (trimmed == "" or SaveManager.users.has(trimmed))
	if SaveManager.users.has(trimmed):
		notice.visible = true
	else:
		notice.visible = false
		
	clear_selection()

func _on_delete_user_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	confirmation_panel.visible = true
	user_list.visible = false

#CONFIRMATION PANEL
func _on_no_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	confirmation_panel.visible = false
	user_list.visible = true
func _on_yes_pressed() -> void:
	SfxManager.play_sfx(sfx_settings.SFX_NAME.MENU_BUTTON)
	if selected_user != null:
		SaveManager.delete_user(selected_user)
		user_list.clear()
		for user in SaveManager.users:
			user_list.add_item(user)
		selected_user = null
	confirmation_panel.visible = false
	user_list.visible = true
	clear_selection()
func _on_name_input_focus_entered() -> void:
	clear_selection()

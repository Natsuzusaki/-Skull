extends Panel

@export var parent: Control
@export var previous_menu: Control
@onready var user_list: ItemList = $%UserList
@onready var name_input: LineEdit = $VBoxContainer/Name_input
@onready var confirmation_panel: Control = $ConfirmationPanel
@onready var delete_user: Button = $VBoxContainer/HBoxContainer/Delete_User
@onready var create_user: Button = $VBoxContainer/HBoxContainer/Create_user
@onready var set_user: Button = $VBoxContainer2/Set_User

var selected_user

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
	var new_user = name_input.text.strip_edges()
	if new_user != "" and not SaveManager.users.has(new_user):
		SaveManager.create_user(new_user)
		user_list.add_item(new_user)
		name_input.clear()
		create_user.disabled = true
		clear_selection()
func _on_set_user_pressed() -> void:
	if selected_user != null:
		SaveManager.set_user(selected_user)
		var parent_node = get_parent()
		var settings_scene = parent_node.find_child("Settings", false, false)
		if settings_scene:
			settings_scene.load_settings()
		self.visible = false
		parent.current_user.text = "Welcome back! %s" % selected_user
		previous_menu.visible = true
func _on_user_list_item_activated(_index: int) -> void:
	_on_set_user_pressed()
func _on_name_input_text_changed(new_text: String) -> void:
	create_user.disabled = (new_text.strip_edges() == "" or SaveManager.users.has(new_text.strip_edges()))
	clear_selection()
func _on_delete_user_pressed() -> void:
	confirmation_panel.visible = true
	user_list.visible = false

#CONFIRMATION PANEL
func _on_no_pressed() -> void:
	confirmation_panel.visible = false
	user_list.visible = true
func _on_yes_pressed() -> void:
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

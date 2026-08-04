extends Control

@onready var profile_list_container: VBoxContainer = %ProfileListContainer
@onready var create_button: Button = %CreateButton
@onready var create_popup: Control = %CreatePopup
@onready var name_input: LineEdit = %NameInput
@onready var confirm_create_button: Button = %ConfirmCreateButton
@onready var cancel_create_button: Button = %CancelCreateButton
@onready var back_button: Button = %BackButton

# Edit popup nodes
@onready var edit_popup: Control = %EditPopup
@onready var edit_name_input: LineEdit = %EditNameInput
@onready var edit_avatar_grid: GridContainer = %EditAvatarGrid
@onready var confirm_edit_button: Button = %ConfirmEditButton
@onready var cancel_edit_button: Button = %CancelEditButton

# Delete confirmation popup nodes
@onready var delete_popup: Control = %DeletePopup
@onready var delete_msg_label: Label = %DeleteMsgLabel
@onready var confirm_delete_button: Button = %ConfirmDeleteButton
@onready var cancel_delete_button: Button = %CancelDeleteButton

var selected_avatar_id: int = 0
var editing_avatar_id: int = 0
var editing_profile: Dictionary = {}
var pending_delete_filename: String = ""

@onready var avatar_grid: GridContainer = %AvatarGrid

const AVATAR_COLORS = [
	Color("#d4a574"), Color("#53d769"), Color("#e8a849"), Color("#e94560"),
	Color("#4a90e2"), Color("#9013fe"), Color("#bd10e0"), Color("#50e3c2")
]

func _ready() -> void:
	create_button.pressed.connect(_on_open_create)
	confirm_create_button.pressed.connect(_on_confirm_create)
	cancel_create_button.pressed.connect(_on_cancel_create)
	
	confirm_edit_button.pressed.connect(_on_confirm_edit)
	cancel_edit_button.pressed.connect(_on_cancel_edit)
	
	confirm_delete_button.pressed.connect(_on_confirm_delete)
	cancel_delete_button.pressed.connect(_on_cancel_delete)
	
	back_button.pressed.connect(_on_back_pressed)
	SaveManager.profile_list_updated.connect(_refresh_profiles)
	
	_setup_avatar_grid()
	_refresh_profiles()

func _setup_avatar_grid() -> void:
	for child in avatar_grid.get_children():
		child.queue_free()
		
	for i in range(AVATAR_COLORS.size()):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(40, 40)
		btn.text = "P" + str(i + 1)
		
		var style = StyleBoxFlat.new()
		style.bg_color = AVATAR_COLORS[i]
		style.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("normal", style)
		
		var idx = i
		btn.pressed.connect(func():
			selected_avatar_id = idx
		)
		avatar_grid.add_child(btn)

func _setup_edit_avatar_grid() -> void:
	for child in edit_avatar_grid.get_children():
		child.queue_free()
		
	for i in range(AVATAR_COLORS.size()):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(40, 40)
		btn.text = "P" + str(i + 1)
		
		var style = StyleBoxFlat.new()
		style.bg_color = AVATAR_COLORS[i]
		style.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("normal", style)
		
		var idx = i
		btn.pressed.connect(func():
			editing_avatar_id = idx
		)
		edit_avatar_grid.add_child(btn)

func _refresh_profiles() -> void:
	for child in profile_list_container.get_children():
		child.queue_free()
		
	var profiles = SaveManager.get_profile_list()
	
	if profiles.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "No profiles found. Create a new profile to begin your quest!"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		profile_list_container.add_child(empty_lbl)
		return
		
	for p in profiles:
		var card = _create_profile_card(p)
		profile_list_container.add_child(card)

func _select_and_play(fn: String) -> void:
	SaveManager.load_profile(fn)
	GameManager.change_scene(GameManager.WORLD_MAP)

func _create_profile_card(profile: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	var fn = profile.get("filename", "")
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	margin.add_child(hbox)
	
	# Clickable Avatar Badge
	var av_idx = int(profile.get("avatar_id", 0)) % AVATAR_COLORS.size()
	var avatar_btn = Button.new()
	avatar_btn.custom_minimum_size = Vector2(52, 52)
	avatar_btn.text = profile.get("name", "P")[0].to_upper()
	avatar_btn.add_theme_font_size_override("font_size", 22)
	avatar_btn.add_theme_color_override("font_color", Color("#ffffff"))
	
	var av_style = StyleBoxFlat.new()
	av_style.bg_color = AVATAR_COLORS[av_idx]
	av_style.set_corner_radius_all(8)
	avatar_btn.add_theme_stylebox_override("normal", av_style)
	avatar_btn.add_theme_stylebox_override("hover", av_style)
	avatar_btn.pressed.connect(func():
		_select_and_play(fn)
	)
	hbox.add_child(avatar_btn)
	
	# Info Box
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Clickable Name Button
	var pname = profile.get("name", "Unknown Writer")
	var name_btn = Button.new()
	name_btn.text = pname
	name_btn.flat = true
	name_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	name_btn.add_theme_font_size_override("font_size", 20)
	name_btn.add_theme_color_override("font_color", Color("#d4a574"))
	name_btn.add_theme_color_override("font_hover_color", Color("#e8a849"))
	name_btn.pressed.connect(func():
		_select_and_play(fn)
	)
	vbox.add_child(name_btn)
	
	var stats_lbl = Label.new()
	var points = profile.get("total_points", 0)
	var chapters_done = profile.get("chapters", {}).size()
	stats_lbl.text = "Points: " + str(points) + " XP  |  Chapters Completed: " + str(chapters_done) + " / 35"
	stats_lbl.add_theme_font_size_override("font_size", 13)
	stats_lbl.add_theme_color_override("font_color", Color("#e8dcc8"))
	vbox.add_child(stats_lbl)
	
	hbox.add_child(vbox)
	
	# Prominent "Play Quest" Button
	var select_btn = Button.new()
	select_btn.custom_minimum_size = Vector2(130, 44)
	select_btn.text = "Play Quest ▶"
	select_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	select_btn.add_theme_font_size_override("font_size", 15)
	
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color("#e8a849")
	btn_normal.set_corner_radius_all(6)
	btn_normal.content_margin_left = 12
	btn_normal.content_margin_right = 12
	btn_normal.content_margin_top = 8
	btn_normal.content_margin_bottom = 8
	select_btn.add_theme_stylebox_override("normal", btn_normal)
	select_btn.add_theme_color_override("font_color", Color("#1a1a2e"))
	
	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = Color("#f4be65")
	btn_hover.set_corner_radius_all(6)
	btn_hover.content_margin_left = 12
	btn_hover.content_margin_right = 12
	btn_hover.content_margin_top = 8
	btn_hover.content_margin_bottom = 8
	select_btn.add_theme_stylebox_override("hover", btn_hover)
	select_btn.add_theme_color_override("font_hover_color", Color("#1a1a2e"))
	
	select_btn.pressed.connect(func():
		_select_and_play(fn)
	)
	hbox.add_child(select_btn)
	
	# Edit Button (✏️) to the left of X
	var edit_btn = Button.new()
	edit_btn.custom_minimum_size = Vector2(40, 40)
	edit_btn.text = "✏️"
	edit_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	edit_btn.pressed.connect(func():
		_on_open_edit(profile)
	)
	hbox.add_child(edit_btn)
	
	# Delete Button (X)
	var del_btn = Button.new()
	del_btn.custom_minimum_size = Vector2(40, 40)
	del_btn.text = "X"
	del_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	del_btn.add_theme_color_override("font_color", Color("#e94560"))
	del_btn.pressed.connect(func():
		_on_open_delete(fn, pname)
	)
	hbox.add_child(del_btn)
	
	return panel

func _on_open_create() -> void:
	name_input.text = ""
	create_popup.visible = true
	name_input.grab_focus()

func _on_confirm_create() -> void:
	var pname = name_input.text.strip_edges()
	if pname != "":
		SaveManager.create_profile(pname, selected_avatar_id)
		create_popup.visible = false
		GameManager.change_scene(GameManager.WORLD_MAP)

func _on_cancel_create() -> void:
	create_popup.visible = false

func _on_open_edit(profile: Dictionary) -> void:
	editing_profile = profile
	editing_avatar_id = int(profile.get("avatar_id", 0))
	edit_name_input.text = profile.get("name", "")
	_setup_edit_avatar_grid()
	edit_popup.visible = true
	edit_name_input.grab_focus()

func _on_confirm_edit() -> void:
	var new_name = edit_name_input.text.strip_edges()
	if new_name != "" and not editing_profile.is_empty():
		editing_profile["name"] = new_name
		editing_profile["avatar_id"] = editing_avatar_id
		SaveManager.save_profile_data(editing_profile)
		
		# If editing currently active profile, sync current_profile
		if SaveManager.current_profile.get("filename") == editing_profile.get("filename"):
			SaveManager.current_profile = editing_profile
			
		edit_popup.visible = false
		_refresh_profiles()

func _on_cancel_edit() -> void:
	editing_profile = {}
	edit_popup.visible = false

func _on_open_delete(filename: String, profile_name: String) -> void:
	pending_delete_filename = filename
	delete_msg_label.text = "Are you sure you want to delete profile '" + profile_name + "'?\n\nAll saved progress and chapter grades will be permanently lost."
	delete_popup.visible = true

func _on_confirm_delete() -> void:
	if pending_delete_filename != "":
		SaveManager.delete_profile(pending_delete_filename)
		pending_delete_filename = ""
	delete_popup.visible = false

func _on_cancel_delete() -> void:
	pending_delete_filename = ""
	delete_popup.visible = false

func _on_back_pressed() -> void:
	GameManager.change_scene(GameManager.TITLE_SCREEN)

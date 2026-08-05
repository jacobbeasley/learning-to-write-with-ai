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

const AVATAR_PATHS = [
	"res://assets/images/avatars/avatar_01_novice_scribe.png",
	"res://assets/images/avatars/avatar_02_cyberpunk_hacker.png",
	"res://assets/images/avatars/avatar_03_wandering_bard.png",
	"res://assets/images/avatars/avatar_04_clockwork_engineer.png",
	"res://assets/images/avatars/avatar_05_high_elf_archivist.png",
	"res://assets/images/avatars/avatar_06_desert_cartographer.png",
	"res://assets/images/avatars/avatar_07_alchemist_researcher.png",
	"res://assets/images/avatars/avatar_08_shadow_scriptor.png",
	"res://assets/images/avatars/avatar_09_arcane_scholar.png",
	"res://assets/images/avatars/avatar_10_royal_historian.png",
	"res://assets/images/avatars/avatar_11_dragon_archivist.png",
	"res://assets/images/avatars/avatar_12_imperial_laureate.png",
	"res://assets/images/avatars/avatar_13_sea_captain_chronicler.png",
	"res://assets/images/avatars/avatar_14_paladin_scriptor.png",
	"res://assets/images/avatars/avatar_15_space_station_cryptographer.png",
	"res://assets/images/avatars/avatar_16_dwarven_runesmith.png"
]

const AVATAR_COLORS = [
	Color("#d4a574"), Color("#53d769"), Color("#e8a849"), Color("#e94560"),
	Color("#4a90e2"), Color("#9013fe"), Color("#bd10e0"), Color("#50e3c2"),
	Color("#e67e22"), Color("#1abc9c"), Color("#3498db"), Color("#9b59b6"),
	Color("#34495e"), Color("#f1c40f"), Color("#e74c3c"), Color("#7f8c8d")
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

func _get_avatar_texture(idx: int) -> Texture2D:
	idx = posmod(idx, AVATAR_PATHS.size())
	var path = AVATAR_PATHS[idx]
	
	# 1. Try standard load() first
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
			
	# 2. Try Image.load_from_file with globalized OS path
	var global_path = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(path):
		var img = Image.load_from_file(global_path)
		if img and not img.is_empty():
			return ImageTexture.create_from_image(img)
			
	return null

func _create_avatar_button(idx: int, size: Vector2) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = size
	btn.clip_contents = true
	
	var tex = _get_avatar_texture(idx)
	if tex:
		var tex_rect = TextureRect.new()
		tex_rect.texture = tex
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tex_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(tex_rect)
	else:
		btn.text = "A" + str(idx + 1)
		var style = StyleBoxFlat.new()
		style.bg_color = AVATAR_COLORS[idx % AVATAR_COLORS.size()]
		style.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("normal", style)
		
	return btn

func _setup_avatar_grid() -> void:
	for child in avatar_grid.get_children():
		child.queue_free()
		
	for i in range(AVATAR_PATHS.size()):
		var btn = _create_avatar_button(i, Vector2(52, 52))
		var idx = i
		btn.pressed.connect(func():
			selected_avatar_id = idx
			_update_grid_selection(avatar_grid, selected_avatar_id)
		)
		avatar_grid.add_child(btn)
	_update_grid_selection(avatar_grid, selected_avatar_id)

func _setup_edit_avatar_grid() -> void:
	for child in edit_avatar_grid.get_children():
		child.queue_free()
		
	for i in range(AVATAR_PATHS.size()):
		var btn = _create_avatar_button(i, Vector2(52, 52))
		var idx = i
		btn.pressed.connect(func():
			editing_avatar_id = idx
			_update_grid_selection(edit_avatar_grid, editing_avatar_id)
		)
		edit_avatar_grid.add_child(btn)
	_update_grid_selection(edit_avatar_grid, editing_avatar_id)

func _update_grid_selection(grid: GridContainer, active_idx: int) -> void:
	var children = grid.get_children()
	for i in range(children.size()):
		var btn = children[i] as Button
		if not btn:
			continue
		if i == active_idx:
			btn.modulate = Color(1.3, 1.3, 1.0, 1.0)
		else:
			btn.modulate = Color(0.6, 0.6, 0.6, 0.75)

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
	var av_idx = int(profile.get("avatar_id", 0)) % AVATAR_PATHS.size()
	var avatar_btn = _create_avatar_button(av_idx, Vector2(56, 56))
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
	
	# Stats / Progress Summary
	var progress = profile.get("progress", {})
	var completed = progress.get("completed_chapters", [])
	var count = completed.size()
	
	var stats_lbl = Label.new()
	stats_lbl.text = "Chapters Completed: %d  |  Last Active: %s" % [count, profile.get("last_played", "Never")]
	stats_lbl.add_theme_font_size_override("font_size", 13)
	stats_lbl.add_theme_color_override("font_color", Color("#888888"))
	vbox.add_child(stats_lbl)
	
	hbox.add_child(vbox)
	
	# Action Buttons
	var actions = HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	
	var play_btn = Button.new()
	play_btn.text = "Play"
	play_btn.custom_minimum_size = Vector2(70, 36)
	play_btn.pressed.connect(func():
		_select_and_play(fn)
	)
	actions.add_child(play_btn)
	
	var edit_btn = Button.new()
	edit_btn.text = "Edit"
	edit_btn.custom_minimum_size = Vector2(60, 36)
	edit_btn.pressed.connect(func():
		_on_open_edit(profile)
	)
	actions.add_child(edit_btn)
	
	var del_btn = Button.new()
	del_btn.text = "Delete"
	del_btn.custom_minimum_size = Vector2(70, 36)
	del_btn.pressed.connect(func():
		_on_open_delete(fn, pname)
	)
	actions.add_child(del_btn)
	
	hbox.add_child(actions)
	return panel

func _on_open_create() -> void:
	name_input.text = ""
	selected_avatar_id = 0
	_update_grid_selection(avatar_grid, selected_avatar_id)
	create_popup.visible = true
	name_input.grab_focus()

func _on_cancel_create() -> void:
	create_popup.visible = false

func _on_confirm_create() -> void:
	var wname = name_input.text.strip_edges()
	if wname.is_empty():
		wname = "Novice Scribe"
		
	SaveManager.create_profile(wname, selected_avatar_id)
	create_popup.visible = false

func _on_open_edit(profile: Dictionary) -> void:
	editing_profile = profile
	editing_avatar_id = int(profile.get("avatar_id", 0))
	edit_name_input.text = profile.get("name", "")
	_setup_edit_avatar_grid()
	edit_popup.visible = true
	edit_name_input.grab_focus()

func _on_cancel_edit() -> void:
	edit_popup.visible = false

func _on_confirm_edit() -> void:
	var new_name = edit_name_input.text.strip_edges()
	if not new_name.is_empty():
		editing_profile["name"] = new_name
	editing_profile["avatar_id"] = editing_avatar_id
	SaveManager.save_profile(editing_profile)
	edit_popup.visible = false
	_refresh_profiles()

func _on_open_delete(fn: String, pname: String) -> void:
	pending_delete_filename = fn
	delete_msg_label.text = "Are you sure you want to delete profile '%s'? This action cannot be undone." % pname
	delete_popup.visible = true

func _on_cancel_delete() -> void:
	delete_popup.visible = false
	pending_delete_filename = ""

func _on_confirm_delete() -> void:
	if not pending_delete_filename.is_empty():
		SaveManager.delete_profile(pending_delete_filename)
	delete_popup.visible = false
	pending_delete_filename = ""

func _on_back_pressed() -> void:
	GameManager.change_scene(GameManager.TITLE_SCREEN)

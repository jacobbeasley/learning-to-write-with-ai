extends Control

@onready var parts_container: VBoxContainer = %PartsContainer
@onready var profile_name_label: Label = %ProfileNameLabel
@onready var total_points_label: Label = %TotalPointsLabel
@onready var avatar_icon: TextureRect = %AvatarIcon
@onready var profile_button: Button = %ProfileButton
@onready var settings_button: Button = %SettingsButton
@onready var settings_panel: Control = %SettingsPanel

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

func _ready() -> void:
	profile_button.pressed.connect(_on_profile_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	
	_update_header()
	_populate_parts()

func _get_avatar_texture(idx: int) -> Texture2D:
	idx = posmod(idx, AVATAR_PATHS.size())
	var path = AVATAR_PATHS[idx]
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
	var global_path = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(path):
		var img = Image.load_from_file(global_path)
		if img and not img.is_empty():
			return ImageTexture.create_from_image(img)
	return null

func _update_header() -> void:
	if not SaveManager.current_profile.is_empty():
		profile_name_label.text = SaveManager.current_profile.get("name", "Writer")
		total_points_label.text = str(SaveManager.current_profile.get("total_points", 0)) + " XP"
		
		var av_idx = int(SaveManager.current_profile.get("avatar_id", 0))
		var tex = _get_avatar_texture(av_idx)
		if tex and avatar_icon:
			avatar_icon.texture = tex
			avatar_icon.visible = true
		elif avatar_icon:
			avatar_icon.visible = false
	else:
		profile_name_label.text = "No Profile"
		total_points_label.text = "0 XP"
		if avatar_icon:
			avatar_icon.visible = false

func _populate_parts() -> void:
	for child in parts_container.get_children():
		child.queue_free()
		
	var parts = GameManager.get_all_parts()
	var total_parts = parts.size()
	
	for i in range(total_parts):
		var part = parts[i]
		var card = _create_part_card(part)
		parts_container.add_child(card)

func _create_road_connector() -> CenterContainer:
	var center = CenterContainer.new()
	center.custom_minimum_size = Vector2(0, 20)
	
	var road_lbl = Label.new()
	road_lbl.text = "║   🗺️   ║"
	road_lbl.add_theme_font_size_override("font_size", 12)
	road_lbl.add_theme_color_override("font_color", Color("#d4a574"))
	road_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(road_lbl)
	
	return center

func _load_texture(path: String) -> Texture2D:
	if path == "":
		return null
		
	# 1. Standard load() if Godot imported it
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
		elif res is Image:
			return ImageTexture.create_from_image(res)
			
	# 2. Raw disk file buffer fallback
	var global_path = ProjectSettings.globalize_path(path)
	var f = FileAccess.open(global_path, FileAccess.READ)
	if f == null:
		f = FileAccess.open(path, FileAccess.READ)
		
	if f != null:
		var bytes = f.get_buffer(f.get_length())
		f.close()
		if bytes.size() > 0:
			var img = Image.new()
			var err = img.load_png_from_buffer(bytes)
			if err == OK and not img.is_empty():
				return ImageTexture.create_from_image(img)
				
	return null

func _create_part_card(part: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	var pid = part.get("id", "")
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	margin.add_child(hbox)
	
	# 8-Bit Square Graphic Icon Container
	var icon_path = part.get("map_icon", "")
	var tex = _load_texture(icon_path)
	
	if tex != null:
		var icon_rect = TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(72, 72)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon_rect.pivot_offset = Vector2(36, 36)
		icon_rect.texture = tex
		
		# Make icon interactive
		icon_rect.mouse_filter = Control.MOUSE_FILTER_STOP
		icon_rect.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		icon_rect.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				GameManager.show_part_comic(pid)
		)
		
		# Hover micro-animation (8-bit bounce scale)
		icon_rect.mouse_entered.connect(func():
			var tween = create_tween()
			tween.tween_property(icon_rect, "scale", Vector2(1.12, 1.12), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		)
		icon_rect.mouse_exited.connect(func():
			var tween = create_tween()
			tween.tween_property(icon_rect, "scale", Vector2(1.0, 1.0), 0.1)
		)
		hbox.add_child(icon_rect)
	else:
		# Fallback 8-bit text badge if image asset isn't loaded
		var badge_btn = Button.new()
		badge_btn.custom_minimum_size = Vector2(72, 72)
		badge_btn.text = "PART\n" + str(part.get("number", 1))
		badge_btn.add_theme_font_size_override("font_size", 13)
		badge_btn.add_theme_color_override("font_color", Color("#1a1a2e"))
		badge_btn.add_theme_color_override("font_hover_color", Color("#1a1a2e"))
		
		var badge_normal = StyleBoxFlat.new()
		badge_normal.bg_color = Color("#d4a574")
		badge_normal.set_corner_radius_all(8)
		badge_btn.add_theme_stylebox_override("normal", badge_normal)
		
		var badge_hover = StyleBoxFlat.new()
		badge_hover.bg_color = Color("#e8a849")
		badge_hover.set_corner_radius_all(8)
		badge_btn.add_theme_stylebox_override("hover", badge_hover)
		
		badge_btn.pressed.connect(func():
			GameManager.show_part_comic(pid)
		)
		hbox.add_child(badge_btn)
	
	# Info Box
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Clickable Part Title
	var title_btn = Button.new()
	title_btn.text = "PART " + str(part.get("number", 1)) + ": " + part.get("title", "").to_upper()
	title_btn.flat = true
	title_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_btn.add_theme_font_size_override("font_size", 20)
	title_btn.add_theme_color_override("font_color", Color("#d4a574"))
	title_btn.add_theme_color_override("font_hover_color", Color("#e8a849"))
	title_btn.pressed.connect(func():
		GameManager.show_part_comic(pid)
	)
	vbox.add_child(title_btn)
	
	var desc_lbl = Label.new()
	desc_lbl.text = part.get("description", "")
	desc_lbl.add_theme_font_size_override("font_size", 14)
	desc_lbl.add_theme_color_override("font_color", Color("#e8dcc8"))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_lbl)
	
	# Progress stats for this part
	var chapter_ids = part.get("chapter_ids", [])
	var completed = 0
	var part_points = 0
	for cid in chapter_ids:
		var prog = SaveManager.get_chapter_progress(cid)
		if not prog.is_empty() and prog.get("best_grade", "") != "":
			completed += 1
			part_points += prog.get("points", 0)
			
	var stats_lbl = Label.new()
	stats_lbl.text = "Chapters: " + str(completed) + "/" + str(chapter_ids.size()) + "  |  Points: " + str(part_points) + " XP"
	stats_lbl.add_theme_font_size_override("font_size", 13)
	stats_lbl.add_theme_color_override("font_color", Color("#8b8b9e"))
	vbox.add_child(stats_lbl)
	
	hbox.add_child(vbox)
	
	# Enter Button
	var enter_btn = Button.new()
	enter_btn.custom_minimum_size = Vector2(130, 44)
	enter_btn.text = "Enter Part →"
	enter_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	enter_btn.pressed.connect(func():
		GameManager.show_part_comic(pid)
	)
	hbox.add_child(enter_btn)
	
	return panel

func _on_profile_pressed() -> void:
	GameManager.change_scene(GameManager.PROFILE_SELECT)

func _on_settings_pressed() -> void:
	if settings_panel:
		settings_panel.visible = not settings_panel.visible

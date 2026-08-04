extends Control

@onready var parts_container: VBoxContainer = %PartsContainer
@onready var profile_name_label: Label = %ProfileNameLabel
@onready var total_points_label: Label = %TotalPointsLabel
@onready var profile_button: Button = %ProfileButton
@onready var settings_button: Button = %SettingsButton
@onready var settings_panel: Control = %SettingsPanel

func _ready() -> void:
	profile_button.pressed.connect(_on_profile_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	
	_update_header()
	_populate_parts()

func _update_header() -> void:
	if not SaveManager.current_profile.is_empty():
		profile_name_label.text = SaveManager.current_profile.get("name", "Writer")
		total_points_label.text = str(SaveManager.current_profile.get("total_points", 0)) + " XP"
	else:
		profile_name_label.text = "No Profile"
		total_points_label.text = "0 XP"

func _populate_parts() -> void:
	for child in parts_container.get_children():
		child.queue_free()
		
	var parts = GameManager.get_all_parts()
	
	for part in parts:
		var card = _create_part_card(part)
		parts_container.add_child(card)

func _create_part_card(part: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	margin.add_child(hbox)
	
	# Part Badge
	var badge = PanelContainer.new()
	badge.custom_minimum_size = Vector2(56, 56)
	var badge_style = StyleBoxFlat.new()
	badge_style.bg_color = Color("#d4a574")
	badge_style.set_corner_radius_all(8)
	badge.add_theme_stylebox_override("panel", badge_style)
	
	var b_lbl = Label.new()
	b_lbl.text = "PART\n" + str(part.get("number", 1))
	b_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	b_lbl.add_theme_font_size_override("font_size", 14)
	b_lbl.add_theme_color_override("font_color", Color("#1a1a2e"))
	badge.add_child(b_lbl)
	hbox.add_child(badge)
	
	# Info
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var title_lbl = Label.new()
	title_lbl.text = part.get("title", "")
	title_lbl.add_theme_font_size_override("font_size", 20)
	title_lbl.add_theme_color_override("font_color", Color("#d4a574"))
	vbox.add_child(title_lbl)
	
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
	var pid = part.get("id", "")
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

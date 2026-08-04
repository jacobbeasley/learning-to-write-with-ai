extends Control

@onready var part_title_label: Label = %PartTitleLabel
@onready var chapters_container: VBoxContainer = %ChaptersContainer
@onready var back_button: Button = %BackButton

const GRADE_BADGE = preload("res://src/ui/components/grade_badge.tscn")

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	_populate_chapters()

func _populate_chapters() -> void:
	for child in chapters_container.get_children():
		child.queue_free()
		
	var part = GameManager.get_part(GameManager.active_part_id)
	if part.is_empty():
		return
		
	part_title_label.text = "PART " + str(part.get("number", 1)) + ": " + part.get("title", "").to_upper()
	
	var chapters = GameManager.get_chapters_for_part(GameManager.active_part_id)
	
	for chap in chapters:
		var card = _create_chapter_card(chap)
		chapters_container.add_child(card)

func _create_chapter_card(chap: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	var cid = chap.get("id", "")
	
	panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	panel.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			GameManager.show_chapter_comic(cid)
	)
	
	var margin = MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	hbox.add_theme_constant_override("separation", 16)
	margin.add_child(hbox)
	
	# Clickable Chapter Number Button
	var num_btn = Button.new()
	num_btn.text = "Ch. " + str(chap.get("number", 1))
	num_btn.flat = true
	num_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	num_btn.add_theme_font_size_override("font_size", 16)
	num_btn.add_theme_color_override("font_color", Color("#d4a574"))
	num_btn.add_theme_color_override("font_hover_color", Color("#e8a849"))
	num_btn.custom_minimum_size = Vector2(60, 0)
	num_btn.pressed.connect(func():
		GameManager.show_chapter_comic(cid)
	)
	hbox.add_child(num_btn)
	
	# Clickable Chapter Title Button
	var title_btn = Button.new()
	title_btn.text = chap.get("title", "")
	title_btn.flat = true
	title_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	title_btn.add_theme_font_size_override("font_size", 18)
	title_btn.add_theme_color_override("font_color", Color("#e8dcc8"))
	title_btn.add_theme_color_override("font_hover_color", Color("#d4a574"))
	title_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_btn.pressed.connect(func():
		GameManager.show_chapter_comic(cid)
	)
	hbox.add_child(title_btn)
	
	# Grade & Progress
	var prog = SaveManager.get_chapter_progress(cid)
	var best_grade = prog.get("best_grade", "")
	var points = prog.get("points", 0)
	
	var badge = GRADE_BADGE.instantiate()
	hbox.add_child(badge)
	badge.set_grade(best_grade)
	
	var pts_lbl = Label.new()
	pts_lbl.text = str(points) + " XP"
	pts_lbl.add_theme_font_size_override("font_size", 14)
	pts_lbl.add_theme_color_override("font_color", Color("#e8a849"))
	pts_lbl.custom_minimum_size = Vector2(80, 0)
	pts_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hbox.add_child(pts_lbl)
	
	# Start Lesson Button
	var start_btn = Button.new()
	start_btn.custom_minimum_size = Vector2(120, 36)
	start_btn.text = "Begin Lesson →"
	start_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	start_btn.pressed.connect(func():
		GameManager.show_chapter_comic(cid)
	)
	hbox.add_child(start_btn)
	
	return panel

func _on_back_pressed() -> void:
	GameManager.change_scene(GameManager.WORLD_MAP)

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
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	margin.add_child(hbox)
	
	# Chapter Number Badge
	var num_lbl = Label.new()
	num_lbl.text = "Ch. " + str(chap.get("number", 1))
	num_lbl.add_theme_font_size_override("font_size", 16)
	num_lbl.add_theme_color_override("font_color", Color("#d4a574"))
	num_lbl.custom_minimum_size = Vector2(60, 0)
	hbox.add_child(num_lbl)
	
	# Title
	var title_lbl = Label.new()
	title_lbl.text = chap.get("title", "")
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color("#e8dcc8"))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(title_lbl)
	
	# Grade & Progress
	var cid = chap.get("id", "")
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
	start_btn.pressed.connect(func():
		GameManager.show_chapter_comic(cid)
	)
	hbox.add_child(start_btn)
	
	return panel

func _on_back_pressed() -> void:
	GameManager.change_scene(GameManager.WORLD_MAP)

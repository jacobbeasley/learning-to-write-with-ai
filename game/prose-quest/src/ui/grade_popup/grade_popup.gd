extends Control

signal popup_closed
signal try_again_pressed
signal continue_quest_pressed

@onready var grade_label: Label = %GradeLabel
@onready var points_label: Label = %PointsLabel
@onready var improvement_label: Label = %ImprovementLabel
@onready var summary_label: Label = %SummaryLabel
@onready var try_again_button: Button = %TryAgainButton
@onready var continue_quest_button: Button = %ContinueQuestButton

var current_grade: String = ""

func _ready() -> void:
	try_again_button.pressed.connect(_on_try_again_pressed)
	continue_quest_button.pressed.connect(_on_continue_quest_pressed)

func show_grade_result(grade: String, summary: String, grade_result: Dictionary) -> void:
	current_grade = grade.strip_edges().to_upper()
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_grade(grade)
	grade_label.text = grade
	grade_label.add_theme_color_override("font_color", GradeUtils.get_grade_color(grade))
	
	summary_label.text = summary
	
	var gained = grade_result.get("points_gained", 0)
	var improved = grade_result.get("improved", false)
	var old_grade = grade_result.get("old_grade", "")
	
	if improved:
		points_label.text = "+" + str(gained) + " XP Earned!"
		if old_grade != "":
			improvement_label.text = "★ Grade Improved from " + old_grade + " to " + grade + "! ★"
		else:
			improvement_label.text = "★ Lesson Grade Achieved! ★"
		improvement_label.visible = true
	else:
		points_label.text = "0 New XP (Best Grade remains " + old_grade + ")"
		improvement_label.visible = false
		
	# Configure buttons: if F grade, only show Try Again. If D or better, show 2 buttons!
	if current_grade == "F":
		try_again_button.text = "Try Again (Enter / Esc)"
		try_again_button.visible = true
		continue_quest_button.visible = false
	else:
		try_again_button.text = "Try Again (Esc)"
		try_again_button.visible = true
		continue_quest_button.text = "Continue Quest (Enter)"
		continue_quest_button.visible = true
		
	visible = true

func _input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			accept_event()
			_on_try_again_pressed()
		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			accept_event()
			if current_grade == "F":
				_on_try_again_pressed()
			else:
				_on_continue_quest_pressed()

func _on_try_again_pressed() -> void:
	visible = false
	try_again_pressed.emit()
	popup_closed.emit()

func _on_continue_quest_pressed() -> void:
	visible = false
	continue_quest_pressed.emit()
	popup_closed.emit()

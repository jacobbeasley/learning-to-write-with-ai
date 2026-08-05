extends Control

signal popup_closed

@onready var grade_label: Label = %GradeLabel
@onready var points_label: Label = %PointsLabel
@onready var improvement_label: Label = %ImprovementLabel
@onready var summary_label: Label = %SummaryLabel
@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)

func show_grade_result(grade: String, summary: String, grade_result: Dictionary) -> void:
	AudioManager.play_grade(grade)
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
		
	visible = true

func _on_continue_pressed() -> void:
	visible = false
	popup_closed.emit()

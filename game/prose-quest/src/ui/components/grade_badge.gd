extends PanelContainer

@onready var label: Label = $MarginContainer/Label

func set_grade(grade: String) -> void:
	if label:
		label.text = grade if grade != "" else "—"
	
	var color = GradeUtils.get_grade_color(grade)
	
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(4)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	add_theme_stylebox_override("panel", style)

extends PanelContainer

@onready var label: Label = $MarginContainer/Label
var current_grade: String = "I"

func _ready() -> void:
	_update_display()

func set_grade(grade: String) -> void:
	current_grade = grade if grade != "" else "I"
	_update_display()

func _update_display() -> void:
	var l = label if label else get_node_or_null("MarginContainer/Label")
	var display_grade = current_grade if current_grade != "" else "I"
	
	if l:
		l.text = display_grade
	
	var color = GradeUtils.get_grade_color(display_grade)
	
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(4)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	add_theme_stylebox_override("panel", style)

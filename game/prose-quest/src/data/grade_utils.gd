class_name GradeUtils
extends Node

const GRADES = {
	"A": {"points": 1000, "color": Color("#53d769"), "rank": 5},
	"B": {"points": 750, "color": Color("#e8a849"), "rank": 4},
	"C": {"points": 500, "color": Color("#d4a574"), "rank": 3},
	"D": {"points": 100, "color": Color("#e94560"), "rank": 2},
	"F": {"points": 0, "color": Color("#8b8b9e"), "rank": 1},
	"I": {"points": 0, "color": Color("#4a4a5e"), "rank": 0}
}

static func grade_to_points(grade: String) -> int:
	if GRADES.has(grade):
		return GRADES[grade]["points"]
	return 0

static func get_grade_color(grade: String) -> Color:
	if GRADES.has(grade):
		return GRADES[grade]["color"]
	return Color("#4a4a5e")

static func is_better_grade(new_grade: String, old_grade: String) -> bool:
	var new_rank = GRADES.get(new_grade, {}).get("rank", 0)
	var old_rank = GRADES.get(old_grade, {}).get("rank", 0)
	return new_rank > old_rank

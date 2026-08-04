extends Node

signal profile_loaded(profile_data: Dictionary)
signal profile_list_updated

var current_profile: Dictionary = {}
var profiles_dir: String = "user://profiles/"
var settings_file: String = "user://settings.json"

var settings: Dictionary = {
	"lm_studio_url": "http://127.0.0.1:1234/v1/chat/completions"
}

func _ready() -> void:
	_ensure_directories()
	load_settings()

func _ensure_directories() -> void:
	if not DirAccess.dir_exists_absolute(profiles_dir):
		DirAccess.make_dir_recursive_absolute(profiles_dir)

func load_settings() -> void:
	if FileAccess.file_exists(settings_file):
		var file = FileAccess.open(settings_file, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			var parsed = JSON.parse_string(json_string)
			if parsed is Dictionary:
				settings.merge(parsed, true)

func save_settings() -> void:
	var file = FileAccess.open(settings_file, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings, "\t"))

func get_profile_list() -> Array:
	var list = []
	var dir = DirAccess.open(profiles_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				var data = load_profile_file(file_name)
				if not data.is_empty():
					list.append(data)
			file_name = dir.get_next()
	return list

func load_profile_file(filename: String) -> Dictionary:
	var path = profiles_dir + filename
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			if data is Dictionary:
				data["filename"] = filename
				return data
	return {}

func create_profile(profile_name: String, avatar_id: int = 0) -> Dictionary:
	var safe_name = profile_name.validate_filename()
	var filename = safe_name + "_" + str(Time.get_unix_time_from_system()) + ".json"
	
	var new_data = {
		"filename": filename,
		"name": profile_name,
		"avatar_id": avatar_id,
		"created_at": Time.get_date_string_from_system(),
		"total_points": 0,
		"chapters": {}
	}
	
	save_profile_data(new_data)
	current_profile = new_data
	profile_loaded.emit(current_profile)
	profile_list_updated.emit()
	return current_profile

func load_profile(filename: String) -> bool:
	var data = load_profile_file(filename)
	if not data.is_empty():
		current_profile = data
		profile_loaded.emit(current_profile)
		return true
	return false

func save_profile_data(profile_data: Dictionary) -> void:
	if profile_data.has("filename"):
		var path = profiles_dir + profile_data["filename"]
		var file = FileAccess.open(path, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(profile_data, "\t"))

func save_current_profile() -> void:
	if not current_profile.is_empty():
		save_profile_data(current_profile)

func delete_profile(filename: String) -> void:
	var path = profiles_dir + filename
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		if current_profile.get("filename") == filename:
			current_profile = {}
		profile_list_updated.emit()

func record_chapter_grade(chap_id: String, new_grade: String) -> Dictionary:
	if current_profile.is_empty():
		return {"points_gained": 0, "improved": false, "old_grade": "", "new_grade": new_grade}
	
	var chapters = current_profile.get("chapters", {})
	var old_entry = chapters.get(chap_id, {})
	var old_grade = old_entry.get("best_grade", "")
	var old_points = old_entry.get("points", 0)
	
	var new_points = GradeUtils.grade_to_points(new_grade)
	var improved = old_grade == "" or GradeUtils.is_better_grade(new_grade, old_grade)
	
	var points_gained = 0
	if improved:
		points_gained = max(0, new_points - old_points)
		current_profile["total_points"] = current_profile.get("total_points", 0) + points_gained
		
		chapters[chap_id] = {
			"best_grade": new_grade,
			"points": new_points,
			"attempts": old_entry.get("attempts", 0) + 1,
			"last_attempt": Time.get_date_string_from_system()
		}
	else:
		chapters[chap_id]["attempts"] = old_entry.get("attempts", 0) + 1
		chapters[chap_id]["last_attempt"] = Time.get_date_string_from_system()
		
	current_profile["chapters"] = chapters
	save_current_profile()
	
	return {
		"points_gained": points_gained,
		"improved": improved,
		"old_grade": old_grade,
		"new_grade": new_grade
	}

func get_chapter_progress(chap_id: String) -> Dictionary:
	if current_profile.is_empty():
		return {}
	return current_profile.get("chapters", {}).get(chap_id, {})

extends Node

signal scene_changed(scene_name: String)

var book_data: Dictionary = {"parts": [], "chapters": []}
var parts_map: Dictionary = {}
var chapters_map: Dictionary = {}

var active_part_id: String = ""
var active_chapter_id: String = ""

# Scene navigation
const TITLE_SCREEN = "res://src/ui/title_screen/title_screen.tscn"
const PROFILE_SELECT = "res://src/ui/profile_select/profile_select.tscn"
const WORLD_MAP = "res://src/ui/world_map/world_map.tscn"
const CHAPTER_LIST = "res://src/ui/chapter_list/chapter_list.tscn"
const COMIC_VIEWER = "res://src/ui/comic_viewer/comic_viewer.tscn"
const LESSON_SCREEN = "res://src/ui/lesson_screen/lesson_screen.tscn"

# Comic viewer context
var comic_image_path: String = ""
var comic_title: String = ""
var comic_next_action: String = "" # "world_map", "chapter_list", "lesson"

func _ready() -> void:
	load_book_content()

func load_book_content() -> void:
	var path = "res://assets/data/book_content.json"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			if data is Dictionary:
				book_data = data
				_build_maps()

func _build_maps() -> void:
	parts_map.clear()
	chapters_map.clear()
	
	for p in book_data.get("parts", []):
		parts_map[p["id"]] = p
		
	for c in book_data.get("chapters", []):
		chapters_map[c["id"]] = c

func get_all_parts() -> Array:
	return book_data.get("parts", [])

func get_part(part_id: String) -> Dictionary:
	return parts_map.get(part_id, {})

func get_chapter(chap_id: String) -> Dictionary:
	return chapters_map.get(chap_id, {})

func get_chapters_for_part(part_id: String) -> Array:
	var list = []
	var part = get_part(part_id)
	for cid in part.get("chapter_ids", []):
		if chapters_map.has(cid):
			list.append(chapters_map[cid])
	return list

func change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
	scene_changed.emit(scene_path)

func show_part_comic(part_id: String) -> void:
	active_part_id = part_id
	var part = get_part(part_id)
	comic_image_path = part.get("comic", "")
	comic_title = "Part " + str(part.get("number", 1)) + ": " + part.get("title", "")
	comic_next_action = "chapter_list"
	change_scene(COMIC_VIEWER)

func show_chapter_comic(chap_id: String) -> void:
	active_chapter_id = chap_id
	var chap = get_chapter(chap_id)
	active_part_id = chap.get("part_id", active_part_id)
	comic_image_path = chap.get("comic", "")
	comic_title = "Chapter " + str(chap.get("number", 1)) + ": " + chap.get("title", "")
	comic_next_action = "lesson"
	change_scene(COMIC_VIEWER)

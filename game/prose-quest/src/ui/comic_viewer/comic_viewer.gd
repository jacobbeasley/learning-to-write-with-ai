extends Control

@onready var title_label: Label = %TitleLabel
@onready var comic_rect: TextureRect = %ComicRect
@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	
	# Clicking the comic image also triggers Continue
	comic_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	comic_rect.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	comic_rect.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_continue_pressed()
	)
	
	title_label.text = GameManager.comic_title
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_comic_reveal()
	
	var path = GameManager.comic_image_path
	var tex = _load_texture(path)
	if tex != null:
		comic_rect.texture = tex
	else:
		title_label.text += "\n[Image not found: " + path + "]"

func _load_texture(path: String) -> Texture2D:
	if path == "":
		return null
		
	# 1. Standard load() if Godot imported it
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
		elif res is Image:
			return ImageTexture.create_from_image(res)
			
	# 2. Raw disk file buffer fallback (for freshly generated PNGs before Godot editor re-indexes)
	var global_path = ProjectSettings.globalize_path(path)
	var f = FileAccess.open(global_path, FileAccess.READ)
	if f == null:
		f = FileAccess.open(path, FileAccess.READ)
		
	if f != null:
		var bytes = f.get_buffer(f.get_length())
		f.close()
		if bytes.size() > 0:
			var img = Image.new()
			var err = img.load_png_from_buffer(bytes)
			if err == OK and not img.is_empty():
				return ImageTexture.create_from_image(img)
				
	return null

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE:
			accept_event()
			_on_continue_pressed()

func _on_continue_pressed() -> void:
	match GameManager.comic_next_action:
		"chapter_list":
			GameManager.change_scene(GameManager.CHAPTER_LIST)
		"lesson":
			GameManager.change_scene(GameManager.LESSON_SCREEN)
		_:
			GameManager.change_scene(GameManager.WORLD_MAP)

extends Control

@onready var title_label: Label = %TitleLabel
@onready var comic_rect: TextureRect = %ComicRect
@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	
	# Make clicking on the comic image trigger 'Continue'
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
	print("ComicViewer loading path: ", path)
	
	if path != "":
		var tex: Texture2D = null
		
		# 1. Open file bytes from OS disk or res://
		var global_path = ProjectSettings.globalize_path(path)
		var f = FileAccess.open(global_path, FileAccess.READ)
		if f == null:
			f = FileAccess.open(path, FileAccess.READ)
			
		if f != null:
			var bytes = f.get_buffer(f.get_length())
			f.close()
			
			if bytes.size() > 0:
				var img = Image.new()
				
				# Try PNG, JPG, and WebP buffer decoders
				var img_err = img.load_png_from_buffer(bytes)
				if img_err != OK:
					img_err = img.load_jpg_from_buffer(bytes)
				if img_err != OK:
					img_err = img.load_webp_from_buffer(bytes)
					
				if img_err == OK and not img.is_empty():
					tex = ImageTexture.create_from_image(img)
					print("Successfully loaded image buffer! Format size: ", img.get_size())

		# 2. Standard load() fallback
		if tex == null and ResourceLoader.exists(path):
			var res = load(path)
			if res is Image:
				tex = ImageTexture.create_from_image(res)
			elif res is Texture2D:
				tex = res

		if tex != null:
			comic_rect.texture = tex
			print("SUCCESS: Comic texture assigned to comic_rect!")
		else:
			print("ERROR: All texture load methods failed for: ", path)
			title_label.text += "\n[Image File Missing: " + path + "]"

func _on_continue_pressed() -> void:
	match GameManager.comic_next_action:
		"chapter_list":
			GameManager.change_scene(GameManager.CHAPTER_LIST)
		"lesson":
			GameManager.change_scene(GameManager.LESSON_SCREEN)
		_:
			GameManager.change_scene(GameManager.WORLD_MAP)

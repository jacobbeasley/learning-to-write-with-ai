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
	if path != "" and ResourceLoader.exists(path):
		var tex = load(path)
		if tex is Texture2D:
			comic_rect.texture = tex
		else:
			title_label.text += "\n[Image not found: " + path + "]"

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

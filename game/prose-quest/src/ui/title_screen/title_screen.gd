extends Control

@onready var background_texture: TextureRect = $BackgroundTexture
@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var settings_panel: Control = %SettingsPanel

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	_load_bg_texture()

func _load_bg_texture() -> void:
	var path = "res://assets/images/title_screen_bg.png"
	var tex: Texture2D = null
	
	var global_path = ProjectSettings.globalize_path(path)
	var f = FileAccess.open(global_path, FileAccess.READ)
	if f == null:
		f = FileAccess.open(path, FileAccess.READ)
		
	if f != null:
		var bytes = f.get_buffer(f.get_length())
		f.close()
		
		if bytes.size() > 0:
			var img = Image.new()
			var img_err = img.load_png_from_buffer(bytes)
			if img_err != OK:
				img_err = img.load_jpg_from_buffer(bytes)
			if img_err != OK:
				img_err = img.load_webp_from_buffer(bytes)
				
			if img_err == OK and not img.is_empty():
				tex = ImageTexture.create_from_image(img)

	if tex == null and ResourceLoader.exists(path):
		var res = load(path)
		if res is Image:
			tex = ImageTexture.create_from_image(res)
		elif res is Texture2D:
			tex = res

	if tex != null:
		background_texture.texture = tex

func _on_start_pressed() -> void:
	if SaveManager.current_profile.is_empty():
		GameManager.change_scene(GameManager.PROFILE_SELECT)
	else:
		GameManager.change_scene(GameManager.WORLD_MAP)

func _on_settings_pressed() -> void:
	if settings_panel:
		settings_panel.visible = not settings_panel.visible

func _on_quit_pressed() -> void:
	get_tree().quit()

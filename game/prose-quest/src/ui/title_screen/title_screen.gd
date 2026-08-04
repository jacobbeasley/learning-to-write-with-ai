extends Control

@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var settings_panel: Control = %SettingsPanel

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

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

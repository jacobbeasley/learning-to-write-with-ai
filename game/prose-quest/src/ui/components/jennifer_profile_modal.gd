extends Control

@onready var profile_photo: TextureRect = %ProfilePhoto
@onready var close_button: Button = %CloseButton
@onready var dim_overlay: ColorRect = $DimOverlay

const PROF_JENNIFER_AVATAR: String = "res://assets/images/avatars/prof_jennifer.png"

func _ready() -> void:
	visible = false
	close_button.pressed.connect(hide_modal)
	
	if ResourceLoader.exists(PROF_JENNIFER_AVATAR):
		profile_photo.texture = load(PROF_JENNIFER_AVATAR)

func _gui_input(event: InputEvent) -> void:
	if visible and event is InputEventMouseButton and event.pressed:
		hide_modal()
		get_viewport().set_input_as_handled()

func show_modal() -> void:
	visible = true
	close_button.grab_focus()

func hide_modal() -> void:
	visible = false

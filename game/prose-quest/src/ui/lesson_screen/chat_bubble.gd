extends MarginContainer

@onready var panel: PanelContainer = $PanelContainer
@onready var sender_label: Label = %SenderLabel
@onready var message_label: RichTextLabel = %MessageLabel

func setup(sender: String, text: String) -> void:
	if sender == "user":
		sender_label.text = SaveManager.current_profile.get("name", "You")
		sender_label.add_theme_color_override("font_color", Color("#53d769"))
		size_flags_horizontal = Control.SIZE_SHRINK_END
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color("#1e3a2b")
		style.set_corner_radius_all(8)
		style.content_margin_left = 12
		style.content_margin_top = 10
		style.content_margin_right = 12
		style.content_margin_bottom = 10
		panel.add_theme_stylebox_override("panel", style)
	else:
		sender_label.text = "Prof. Jennifer (AI Coach)"
		sender_label.add_theme_color_override("font_color", Color("#4a90e2"))
		size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color("#16213e")
		style.set_corner_radius_all(8)
		style.content_margin_left = 12
		style.content_margin_top = 10
		style.content_margin_right = 12
		style.content_margin_bottom = 10
		panel.add_theme_stylebox_override("panel", style)
		
	message_label.text = text

extends MarginContainer

@onready var panel: PanelContainer = $PanelContainer
@onready var sender_label: Label = %SenderLabel
@onready var timestamp_label: Label = %TimestampLabel
@onready var message_label: RichTextLabel = %MessageLabel
@onready var avatar_icon: TextureRect = %AvatarIcon

var raw_text: String = ""

func setup(sender: String, text: String) -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Set Timestamp
	if timestamp_label:
		var time_dict = Time.get_time_dict_from_system()
		var hour = time_dict.get("hour", 0)
		var minute = time_dict.get("minute", 0)
		var am_pm = "AM"
		if hour >= 12:
			am_pm = "PM"
		if hour == 0:
			hour = 12
		elif hour > 12:
			hour -= 12
		timestamp_label.text = "%d:%02d %s" % [hour, minute, am_pm]
	
	var sm = get_node_or_null("/root/SaveManager")
	
	if sender == "user":
		var profile_name = "You"
		var av_path = ""
		if sm:
			profile_name = sm.current_profile.get("name", "You")
			var av_idx = int(sm.current_profile.get("avatar_id", 0))
			av_path = sm.get_avatar_path(av_idx)
		
		sender_label.text = profile_name
		sender_label.add_theme_color_override("font_color", Color("#53d769"))
		
		# Set User Avatar
		if av_path != "" and ResourceLoader.exists(av_path):
			avatar_icon.texture = load(av_path)
			avatar_icon.visible = true
		else:
			avatar_icon.visible = false
		
		# Indent on the left so user bubbles align right & span full width minus margin
		add_theme_constant_override("margin_left", 48)
		add_theme_constant_override("margin_right", 0)
		
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
		
		# Set Professor Jennifer Avatar
		var prof_av_path = "res://assets/images/avatars/prof_jennifer.png"
		if sm and sm.get("PROF_JENNIFER_AVATAR"):
			prof_av_path = sm.PROF_JENNIFER_AVATAR
			
		if ResourceLoader.exists(prof_av_path):
			avatar_icon.texture = load(prof_av_path)
			avatar_icon.visible = true
		else:
			avatar_icon.visible = false
		
		# Indent on the right so AI bubbles align left & span full width minus margin
		add_theme_constant_override("margin_left", 0)
		add_theme_constant_override("margin_right", 48)
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color("#16213e")
		style.set_corner_radius_all(8)
		style.content_margin_left = 12
		style.content_margin_top = 10
		style.content_margin_right = 12
		style.content_margin_bottom = 10
		panel.add_theme_stylebox_override("panel", style)
		
	raw_text = text
	_update_text_display()

func append_chunk(chunk_text: String) -> void:
	raw_text += chunk_text
	_update_text_display()

func set_raw_text(new_text: String) -> void:
	raw_text = new_text
	_update_text_display()

func _update_text_display() -> void:
	if message_label:
		message_label.bbcode_enabled = true
		message_label.text = markdown_to_bbcode(raw_text)

static func markdown_to_bbcode(md: String) -> String:
	if md == "":
		return ""
		
	var text = md

	# 1. Convert Bullet lists (- item or * item at start of line)
	var re_bullet = RegEx.new()
	re_bullet.compile("(?m)^[ \\t]*[-*]\\s+")
	text = re_bullet.sub(text, "• ", true)

	# 2. Convert Bold (**text**)
	var re_bold = RegEx.new()
	re_bold.compile("\\*\\*(.*?)\\*\\*")
	text = re_bold.sub(text, "[b]$1[/b]", true)

	# 3. Convert Italics (*text* or word-bounded _text_)
	var re_asterisk_italic = RegEx.new()
	re_asterisk_italic.compile("(?<!\\*)\\*([^\\*\\n]+)\\*(?!\\*)")
	text = re_asterisk_italic.sub(text, "[i]$1[/i]", true)

	var re_underscore_italic = RegEx.new()
	re_underscore_italic.compile("(?:^|\\s)_([^_\\n]+)_(?=\\s|[.,!\\?:]|$)")
	text = re_underscore_italic.sub(text, " [i]$1[/i]", true)

	# 4. Convert Headings (#, ##, ###) - executed LAST to preserve injected BBCode tags
	var re_h3 = RegEx.new()
	re_h3.compile("(?m)^###\\s+(.+)$")
	text = re_h3.sub(text, "[font_size=15][b]$1[/b][/font_size]", true)

	var re_h2 = RegEx.new()
	re_h2.compile("(?m)^##\\s+(.+)$")
	text = re_h2.sub(text, "[font_size=17][b][color=#e8a849]$1[/color][/b][/font_size]", true)

	var re_h1 = RegEx.new()
	re_h1.compile("(?m)^#\\s+(.+)$")
	text = re_h1.sub(text, "[font_size=19][b][color=#d4a574]$1[/color][/b][/font_size]", true)

	return text
